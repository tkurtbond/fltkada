GPRINSTALL ?= gprinstall

.PHONY: build-dynamic build-static install-dynamic install-static

build-dynamic:
	gprbuild -p -Xlibrary_type=dynamic fltkada.gpr

build-static:
	gprbuild -p -Xlibrary_type=static fltkada.gpr

install-dynamic: build-dynamic
	$(GPRINSTALL) -f -p -m -Xlibrary_type=dynamic fltkada.gpr \
	    --build-name=dynamic --build-var=library_type

install-static: build-static
	$(GPRINSTALL) -f -p -m -Xlibrary_type=static fltkada.gpr \
	    --build-name=static --build-var=library_type


#  Tests (PLAN.md, Phase 0).  An agent uses only the -headless and -sway
#  targets: the others run on whatever display is set, which may be the
#  user's desktop (AGENTS.md).
#
#    make check            the unit tests in test/unit, and the programs in
#                          test/ that check their own results
#    make valgrind         the same under valgrind
#    make smoke            every program in bin/ and bin/examples/ starts
#    make check-headless   (and valgrind-, smoke-) under Xvfb, X11 back end
#    make check-sway       (and valgrind-, smoke-) on a headless sway, Wayland
#    make check-desktop    the tests only the user can answer, in
#                          test/desktop: native dialogs, on the desktop.
#                          An agent runs it only after asking the user, at
#                          the time, and getting a yes.

VALGRIND ?= valgrind --leak-check=full --show-leak-kinds=all \
    --errors-for-leak-kinds=none --error-exitcode=99
#  Seconds a test may run before it counts as hung.
TIMEOUT ?= 60
#  Seconds a waiting program must survive in a smoke run.
EXAMPLETIME ?= 3
XVFB := env -u WAYLAND_DISPLAY xvfb-run -a -s '-screen 0 1280x1024x24'

#  The programs, from the project files, so the lists can't drift apart.
gpr-mains = $(sort $(patsubst "%.adb",%,$(shell grep -o '"[a-z_0-9]*\.adb"' $(1))))
#  A program's executable can be named otherwise (FLTK's
#  native-filechooser), so the programs are listed by executable.
gpr-executables = $(sort $(shell sed -n 's/.*for Executable ("[a-z_0-9]*\.adb") *use "\([^"]*\)";.*/\1/p' $(1)))
UNITTESTS := $(call gpr-mains,tests_unit.gpr)

#  The separate libraries (PLAN.md, Phase 16) are built and tested only
#  where FLTK has what they bind.  Forms needs FLTK's fltk_forms library.
HAVE_FORMS := $(shell echo 'int main () { return 0; }' \
    | $(CXX) -x c++ - $$(fltk-config --use-forms --ldflags) -o /dev/null 2>/dev/null && echo yes)
PROGRAMS  := $(call gpr-executables,tests.gpr) $(call gpr-executables,tests_2022.gpr)
ifeq ($(HAVE_FORMS),yes)
UNITTESTS += $(call gpr-mains,tests_forms.gpr)
PROGRAMS  += $(call gpr-executables,tests_forms_programs.gpr)
endif
#  Cairo needs cairo's headers and library, which pkg-config finds.
HAVE_CAIRO := $(shell pkg-config --exists cairo && echo yes)
CAIRO_FLAGS := -XCAIRO_INCLUDE=$(shell pkg-config --variable=includedir cairo 2>/dev/null)/cairo
ifeq ($(HAVE_CAIRO),yes)
UNITTESTS += $(call gpr-mains,tests_cairo.gpr)
PROGRAMS  += $(call gpr-executables,tests_cairo_programs.gpr)
endif
#  GLU isn't FLTK's or GL's, and a system can have GL without it.
HAVE_GLU := $(shell pkg-config --exists glu && echo yes)
ifeq ($(HAVE_GLU),yes)
UNITTESTS += $(call gpr-mains,tests_glu.gpr)
PROGRAMS  += $(call gpr-executables,tests_glu_programs.gpr)
endif
EXAMPLES  := $(shell sed -n 's/.*for Executable ("[a-z_0-9]*\.adb") use "\([^"]*\)";.*/\1/p' examples.gpr)

#  Programs in test/ that check their own results and set the exit status.
SELFCHECK := preferences_check group_children clear_image_chosen column_widths unittests
#  A self-checking program's command line in check and valgrind, as
#  name=argument.  Without --core, unittests opens its window and waits.
SELFCHECK_ARGS := unittests=--core
#  Programs that wait for no one and end by themselves, with status 0.
#  (unittests checks itself only with --core: smoked plain, it keeps running.)
ONCE := $(filter-out unittests,$(SELFCHECK)) compare page_formats dirlist filename glut_test
#  A program's command line in a smoke run, as name=argument, run in test/
#  or examples/.  anim.gif is pofltk's.
ARGS := dirlist=. filename=../test/images/anim.gif \
    animgifimage-play=../test/images/anim.gif \
    animgifimage-resize=../test/images/anim.gif \
    animgifimage-simple=../test/images/anim.gif

#  The tests' FLTK preferences go in obj/check/config, not the user's:
#  check, valgrind and smoke set XDG_CONFIG_HOME there.  It must hold
#  fltk.org/, or FLTK writes to ~/.fltk instead (pofltk 158; FLTKAda-BUGS.md
#  137).

#  The C++ plugins test_plugins loads.  They aren't linked with FLTK: they
#  use the program's.
PLUGINS := bin/unit/plugins/one.so bin/unit/plugins/two.so

bin/unit/plugins/%.so: test/plugins/c_plugin.cpp
	@mkdir -p bin/unit/plugins
	$(CXX) -shared -fPIC -DPLUGIN='"$*"' $$(fltk-config --cxxflags) -o $@ $<

.PHONY: programs display check valgrind smoke \
    check-headless valgrind-headless smoke-headless \
    check-sway valgrind-sway smoke-sway check-desktop
.NOTPARALLEL:

programs: $(PLUGINS)
	gprbuild -p -q fltkada.gpr
	gprbuild -p -q tests_unit.gpr
	gprbuild -p -q tests.gpr
	gprbuild -p -q tests_2022.gpr
	gprbuild -p -q examples.gpr
ifeq ($(HAVE_FORMS),yes)
	gprbuild -p -q fltkada_forms.gpr
	gprbuild -p -q tests_forms.gpr
	gprbuild -p -q tests_forms_programs.gpr
else
	@echo "FLTK has no Forms library: FLTKAda's Forms isn't built or tested."
endif
ifeq ($(HAVE_CAIRO),yes)
	gprbuild -p -q $(CAIRO_FLAGS) fltkada_cairo.gpr
	gprbuild -p -q $(CAIRO_FLAGS) tests_cairo.gpr
	gprbuild -p -q $(CAIRO_FLAGS) tests_cairo_programs.gpr
else
	@echo "pkg-config finds no cairo: FLTKAda's Cairo isn't built or tested."
endif
ifeq ($(HAVE_GLU),yes)
	gprbuild -p -q fltkada_glu.gpr
	gprbuild -p -q tests_glu.gpr
	gprbuild -p -q tests_glu_programs.gpr
else
	@echo "pkg-config finds no glu: FLTKAda's GLU isn't built or tested."
endif

#  Every FLTK program needs a display.
display:
	@if [ -z "$$DISPLAY$$WAYLAND_DISPLAY" ]; then \
	  echo "FLTKAda's tests need a display: use make check-headless or make check-sway"; \
	  exit 1; \
	fi

#  Reports every test, and fails at the end if any failed.
check: programs display
	@status=0; skips=0; mkdir -p obj/check; mkdir -p obj/check/config/fltk.org; \
	export XDG_CONFIG_HOME=$(CURDIR)/obj/check/config; \
	for t in $(UNITTESTS); do \
	  echo "== $$t"; \
	  (cd test/unit && timeout $(TIMEOUT) $(CURDIR)/bin/unit/$$t) > obj/check/$$t.out 2>&1; got=$$?; \
	  cat obj/check/$$t.out; \
	  if [ $$got -ne 0 ]; then echo "FAIL - $$t exited with $$got"; status=1; fi; \
	  skips=$$((skips + $$(grep -c '^skip - ' obj/check/$$t.out))); \
	done; \
	for t in $(SELFCHECK); do \
	  echo "== $$t (checks itself)"; \
	  args=$$(for a in $(SELFCHECK_ARGS); do test "$${a%%=*}" = $$t && echo "$${a#*=}"; done); \
	  (cd test && timeout $(TIMEOUT) $(CURDIR)/bin/$$t $$args) > obj/check/$$t.out 2>&1; got=$$?; \
	  if [ $$got -eq 0 ]; then echo "ok   - $$t"; \
	  else cat obj/check/$$t.out; echo "FAIL - $$t exited with $$got"; status=1; fi; \
	done; \
	if [ $$skips -gt 0 ]; then echo "$$skips check(s) skipped."; fi; \
	exit $$status

#  Memory errors fail a test (--error-exitcode).  Leaks fail it only when
#  FLTKAda allocated the memory (test/vg-check.sh): FLTK, fontconfig,
#  Pango and libdecor leak by design.
valgrind: programs display
	@status=0; mkdir -p obj/check; mkdir -p obj/check/config/fltk.org; \
	export XDG_CONFIG_HOME=$(CURDIR)/obj/check/config; \
	for t in $(UNITTESTS:%=unit/%) $(SELFCHECK); do \
	  n=$$(basename $$t); echo "== valgrind $$n"; \
	  args=$$(for a in $(SELFCHECK_ARGS); do test "$${a%%=*}" = $$n && echo "$${a#*=}"; done); \
	  (cd $$(dirname test/$$t) && $(VALGRIND) --log-file=$(CURDIR)/obj/check/$$n.vg \
	    $(CURDIR)/bin/$$t $$args) > obj/check/$$n.out 2>&1; got=$$?; \
	  if [ $$got -ne 0 ]; then echo "FAIL - $$n exited with $$got"; status=1; fi; \
	  grep 'ERROR SUMMARY' obj/check/$$n.vg; \
	  test/vg-check.sh obj/check/$$n.vg \
	    || { echo "FAIL - $$n: memory FLTKAda allocated was not freed"; status=1; }; \
	done; \
	exit $$status

#  A program that waits for the user must still be running after
#  EXAMPLETIME seconds, when timeout ends it (status 124): it started,
#  drew, and didn't crash.  One of ONCE must end by itself, with status 0.
smoke: programs display
	@status=0; mkdir -p obj/check; mkdir -p obj/check/config/fltk.org; \
	export XDG_CONFIG_HOME=$(CURDIR)/obj/check/config; \
	for p in $(PROGRAMS:%=test:%) $(EXAMPLES:%=examples:%); do \
	  d=$${p%%:*}; n=$${p#*:}; \
	  if [ $$d = test ]; then bin=$(CURDIR)/bin/$$n; else bin=$(CURDIR)/bin/examples/$$n; fi; \
	  case " $(ONCE) " in *" $$n "*) want=0; t=$(TIMEOUT);; *) want=124; t=$(EXAMPLETIME);; esac; \
	  args=$$(for a in $(ARGS); do test "$${a%%=*}" = $$n && echo "$${a#*=}"; done); \
	  (cd $$d && timeout $$t $$bin $$args) > obj/check/$$n.smoke 2>&1; got=$$?; \
	  if [ $$got -eq $$want ]; then echo "ok   - $$n"; \
	  else cat obj/check/$$n.smoke; echo "FAIL - $$n exited with $$got, not $$want"; status=1; fi; \
	done; \
	exit $$status

#  Native dialogs, which open on the user's desktop and wait for the user
#  (test/desktop/desktop.gpr).  Never headless: no one could answer them.
check-desktop: display
	gprbuild -p -q fltkada.gpr
	gprbuild -p -q -P test/desktop/desktop.gpr
	@status=0; \
	for t in $(call gpr-mains,test/desktop/desktop.gpr); do \
	  echo "== $$t"; \
	  (cd test/desktop && $(CURDIR)/bin/desktop/$$t) || { echo "FAIL - $$t exited with $$?"; status=1; }; \
	done; \
	exit $$status

#  On a virtual X server (Xvfb), not the desktop.  WAYLAND_DISPLAY is unset
#  because FLTK prefers Wayland when it is set, even under xvfb-run.
check-headless valgrind-headless smoke-headless: programs
	$(XVFB) $(MAKE) --no-print-directory $(@:-headless=)

#  On a headless sway (tools/with-sway.sh), a compositor with no screen.
check-sway valgrind-sway smoke-sway: programs
	tools/with-sway.sh $(MAKE) --no-print-directory $(@:-sway=)
