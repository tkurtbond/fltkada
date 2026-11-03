# FLTKAda completion plan

FLTKAda is a thick Ada binding to FLTK 1.4.5. This plan covers bringing it
level with pofltk, the Oberon-2 binding at `~/Repos/Oberon/pofltk`, in
three ways:

1. API coverage.
2. Example and test programs.
3. Fixes for the FLTK bugs and pitfalls pofltk recorded in
   `~/Repos/Oberon/pofltk/doc/fltk-issues.md`.

AGENTS.md has the operational notes: build commands, how to run tests
without touching the desktop, and conventions.

Organize additions by section: append to the relevant section rather than
starting a new document. Mark a finished phase `[done]`. When an open
question is decided, strike it through and say what was decided.

Written 2026-11-03. The triage and coverage findings below come from
reading code, not from running it. Each one is a claim to confirm with a
failing test before it is fixed (Phase 0 provides the means). When one
turns out to be wrong, say so here; don't silently drop it.

## Prior art

- **pofltk** (`~/Repos/Oberon/pofltk`) is an Oberon-2 binding to the same
  FLTK 1.4.5, built with poc. It borrowed FLTKAda's architecture (the
  `extern "C"` shim, and `My_X` subclasses that call back for
  `draw`/`handle`), then went further in three places, which are what
  this plan ports back:
  - **Tests.** About 50 unit-test modules with roughly 820 checks. About
    115 "halt" tests, one per misuse, each exiting with a specific
    assertion code. A `Probe` module that synthesizes events and reads
    back pixels. A generated constants check. Valgrind leak attribution.
    Headless Xvfb and sway targets. Smoke runs of every example.
  - **`doc/fltk-issues.md`.** 138 numbered FLTK bugs (the "Bugs" section)
    and pitfalls (the "Pitfalls" section), each with a reproducer and the
    workaround pofltk's shim uses. Its `src/**/*.cpp` shims are the
    reference implementation of those workarounds; most of the shim code
    can be copied with only renaming.
  - **Coverage.** UTF-8 functions, offscreens, file surfaces (EPS, PDF,
    SVG), `Fl_Shortcut_Button`, `Fl_ICO_Image`, `Fl_File_Icon`, image
    handlers, plugins, Forms, GLUT fonts, a Cairo subset, and about
    thirty extra example programs.
- **FLTKAda's own records:**
  - `FLTKAda-BUGS.md`: 14 fixed bugs.
  - `PROBLEMS-OUTSTANDING.md`.
  - `progress.txt`, including its Incomplete APIs and "Never" lists.
  - `doc/binding_architecture.md`, especially §7 (gap analysis) and §8
    (pitfalls).

  This plan extends them rather than replacing them.

## Scope

**In scope:**

- Every item in `fltk-issues.md` that affects FLTKAda, fixed or
  documented. Each comes with a test that failed before the fix and
  passes after it.
- An automated test suite that runs headless, reports pass/fail, and
  runs under valgrind.
- The classes and methods pofltk binds and FLTKAda doesn't (Phases 8–13).
- Ports of pofltk's extra examples, and of FLTK `test/` programs not yet
  in `test/`.
- Documentation: `doc/<header>.html`, `progress.txt`, and a FLTKAda
  record of FLTK issues.

- Forms, plugins and a Cairo drawing binding (Phase 16). They were on
  `progress.txt`'s "Never" list; pofltk binds all three, and the user
  decided on 2026-11-03 that FLTKAda will too (Open question 1).

**Out of scope:**

- Raw OpenGL calls.

## Target versions

- FLTK 1.4.5 (`/usr/local/sw/src/lang/C++/fltk/fltk-1.4.5`, headers in
  `/usr/include/FL`).
- GNAT 16.2.1 and gprbuild on Fedora 44.
- The language level the existing `.gpr` files set (Ada 2012, plus
  `tests_2022.gpr`).
- C++11 for the shim.

The BSD hosts pofltk tests on are covered in Phase 17.

## Architecture decisions

These apply to every fix phase below.

1. **Memory-safety checks are unconditional.** The release build has no
   `-gnata` (`proj/common.gpr:62`), so the library's own `Pre`,
   `Dynamic_Predicate` and `pragma Assert` checks are off. A guard that
   prevents memory corruption must therefore be either:
   - an explicit `if ... then raise ...` in the Ada body, or
   - a check in the C++ shim that returns an error code, which the Ada
     body turns into an exception.

   `Pre` stays for documentation and debug builds. This matches pofltk,
   whose halts are unconditional.
2. **Exceptions are the analogue of pofltk's halt codes.** Use the
   existing exceptions where they fit:
   - `Constraint_Error` for indexes and ranges.
   - `Program_Error` for misuse of state: not shown, dead object,
     re-entry, display not open.
   - The package-specific errors (`Draw_Error`, `Page_Error`,
     `Range_Error`, `Internal_FLTK_Error`, `No_Image_Error` /
     `Format_Error`, …).

   Add a new exception only when callers need to tell the case apart.
   **`FLTK.Unsupported_Error`** is one (decided 2026-11-03, Open
   question 5). It is declared in `spec/fltk.ads` beside
   `Internal_FLTK_Error`, and means "this FLTK, or this back end, can't
   do it": SVG missing, `gl_start` on Wayland, a Forms or Cairo call on an
   FLTK built without them. Phase 1 adds it. Every new raise is documented
   in the spec comment of the subprogram that raises it.
3. **Shim workarounds follow pofltk's.** When `fltk-issues.md` gives a
   workaround, port pofltk's C++ for it (`~/Repos/Oberon/pofltk/src/**/*.cpp`,
   functions named `ofl_*`) into the matching `body/c_fl_*.cpp`. Rename it
   to FLTKAda's `fl_*` style and fit it to `doc/cpp_formatting_standard.md`.
   It must still compile under `-std=c++11 -Wall -Wextra -Wpedantic -Werror`.
4. **Strings FLTK keeps are owned by the binding.** Never hand FLTK an
   `Interfaces.C.To_C` temporary or a `New_String` result when FLTK
   stores the pointer. Use FLTK's `copy_*` method when one exists.
   Otherwise keep the copy in the Ada record (freed in `Extra_Final`), or
   in a `static std::string` in the shim for process-wide state. Phase 2
   fixes every case of this that is known; the "Kept pointers" audit in
   Phase 2 finds the rest.
5. **Opening the display: both lazily and explicitly** (decided
   2026-11-03, Open question 3). FLTKAda never calls `fl_open_display`.
   Phase 3 adds both paths, and documents both:
   - **Lazy:** the shim calls `fl_open_display` itself in the functions
     `fltk-issues.md` says crash without a display, so a program that
     doesn't know about the display is still safe.
   - **Explicit:** a new `FLTK.Static.Open_Display` binds
     `fl_open_display`, for programs that want the connection made, and
     any failure seen, at a point they choose. It is idempotent, as
     `fl_open_display` is.

   Neither goes in a library elaboration: that would make every program
   connect to a display, even ones that only use `FLTK.Filenames` or
   `FLTK.Environment`.
6. **Test-only C++ stays out of the library.** `Probe`'s shim is compiled
   by the test project only.

## The issue triage

Five read-only agents read FLTKAda's code against each of the 138
numbered issues in `fltk-issues.md`. Verdicts:

- **AFFECTED**: FLTKAda reaches the bug or pitfall, and nothing guards it.
- **PROBABLY AFFECTED**: very likely, but it depends on something only a
  run can show.
- **HANDLED**: FLTKAda already avoids it.
- **NOT BOUND**: the API isn't bound. When it is, it needs the workaround.
- **N/A**: a test-environment note or a `fltk-config` quirk.

`fltk-issues.md` uses a single numbering across its Bugs and Pitfalls
sections. The numbers below are its numbers. "New" marks a FLTKAda bug
the triage found that isn't in `fltk-issues.md` at all.

Each AFFECTED item is assigned to a fix phase below. The detail
(file:line, mechanism, fix, confirming test) is in the phase.

### Summary by verdict

- **AFFECTED or PROBABLY AFFECTED:**
  - 1–4, 5 (icon label only), 6 (minor), 8, 13 (gaps)
  - 16, 21, 23 (gaps), 26–28, 30, 34 (callbacks), 35, 36
  - 37 (filter), 38, 40 (doc), 41, 42, 43 (doc), 44 (doc)
  - 45, 47 (doc), 49, 50 (doc), 51, 52, 53, 54, 56, 57
  - 58–65, 72 (Table only), 73, 75, 76, 78, 79 (doc), 81
  - 83, 84, 87–94, 96–98, 99 (minor), 100–104
  - 109–114, 120, 121 (unless the caller uses `-gnata`), 122–134, 136, 138
- **HANDLED:** 12, 22, 31, 33, 39, 46, 74, 80, 119, and FLTKAda-BUGS
  #2/#6/#9/#10/#11.
- **NOT BOUND:** 24, 48, 55, 82, 85, 86, 95, 105–108, 115–118, 135, 137.
- **N/A:** 7, 9, 10 (doc), 11, 14, 15, 17–20, 25, 29, 32, 66–71, 77.
  Several of these (14, 17, 18, 29, 32, 68) are test-environment facts
  that Phase 0 must respect.

### New FLTKAda bugs found by the triage

None of these are in `fltk-issues.md`:

- **N1.** `fl_static_font_size_array_get` (`body/c_fl_static.cpp:228`)
  indexes an `int*` by `(i-1)*sizeof(int)`, so `Font_Sizes` reads the
  wrong entries, past the end of the array. It should be `a[i-1]`.
- **N2.** The `Draw_Image` and `Draw_Image_Mono` callback hook gives the
  Ada callback a buffer `W` long (`body/fltk-draw.adb:1052, 1123`), but
  FLTK's line holds `W*abs(Depth)` bytes.
- **N3.** `Expand_Text` (`body/fltk-draw.adb:1488-1501`) passes
  `maxbuf = 0`. `fl_expand_text` takes `buf` by value, so the Ada buffer
  stays `Null_Ptr`, and every non-empty result raises
  `Dereference_Error`. (Related to issue 125.)
- **N4.** The `Help_View` link hook reuses one buffer, `Hilda`, and frees
  it on every call (`body/fltk-widgets-groups-help_views.adb:265`). During
  `load()`, FLTK's `free_data` calls the hook again, so `localname` is
  freed before `fl_fopen` reads it. This happens on any page change after
  a page with `<IMG>` when a link callback is set. (Alongside issue 90.)
- **N5.** `File_Chooser.Forge.Create` passes the title as a `To_C`
  temporary, and FLTK keeps it as the window label. (Alongside issue 93.)
- ~~**N6.** A double `fclose` on every successful
  `Start_Job (Output => File_Type)`.~~ **Wrong.** `begin_job(FILE*)`
  installs a `dont_close` close command, so a successful `end_job` leaves
  the caller's file open (`src/drivers/PostScript/Fl_PostScript.cxx:92`;
  checked 2026-11-03). Only issue 101's Cairo-error path remains: FLTK
  `fclose`s the file, then writes to it, and Ada's `File_Type` closes it
  again. That case is in Phase 5.
- **N7.** `Widget.Set_Label (This, Kind, Text)` calls `This.Set_Label`
  without dispatching, so on a `Window` it reaches `Fl_Widget::copy_label`
  (`body/fltk-widgets.adb:1231-1238`). (A gap in issue 6.)
- **N8.** `Value_Input` and `Input_Choice` wrap the inner `Fl_Input` (and
  `Input_Choice` also its menu button). `Widget.Extra_Init` then
  overwrites `user_data` with the Ada record's address
  (`body/fltk-widgets.adb:690-692`). FLTK's `input_cb`, `inp_cb` and
  `menu_cb` cast `user_data` to the C++ parent. A keystroke or a menu pick
  probably crashes. (Issue 16 is worse in Ada.) `Table` avoids this by
  replacing its scrollbar callbacks; these two widgets don't.
- **N9.** `Table.Extra_Final` walks the `Fl_Table`'s *real* children,
  which are only its 3 internal widgets. Ada widgets added to cells are
  never detached, so `~Fl_Scroll` deletes them and Ada frees them again.
  (Issue 52.)
- **N10.** `Text_Buffer.Finalize` never removes the modify and predelete
  callbacks it registered with `This'Address`. A display that outlives
  the Ada buffer calls into a freed record. (Issue 34.)
- **N11.** `Browser.Set_Icon` doesn't keep the image alive. Its `Icons`
  vector is never shifted by `Insert`, `Remove`, `Move`, `Swap`, `Clear`
  or `Load`. (Issue 56.)
- **N12.** Ada exceptions raised in callbacks called from C++ are never
  caught at the boundary: `Callback_Hook`, the draw and handle hooks, the
  GLUT hooks, the image-line hook and the `Scroll` hook. Phase 0's
  experiment (below) found that they unwind through FLTK's frames to the
  Ada handler, but leave FLTK's state broken in several hooks
  (FLTK-issues.md F3). Decided: each hook catches the exception and the
  binding re-raises it later (Phase 2).

### Stale entries to remove

`PROBLEMS-OUTSTANDING.md` ("Missing small operations") and `progress.txt`
list two operations as unbound that are now bound. Remove both entries in
Phase 1:

- `Fl::redraw`: bound as `FLTK.Screen.Redraw` (`c_fl_screen.cpp:121`).
- Clearing a widget's image: bound as `FLTK.Widgets.Clear_Image` (commit
  7e2cf82).

## Build and test (target state, built in Phase 0)

```sh
make check                    # build tests.gpr and run every unit and exception test
make check-headless           # the same under Xvfb, X11 back end
make check-sway               # the same under a headless sway, Wayland back end
make valgrind-headless        # every unit test under valgrind, failing on FLTKAda-attributed leaks
make smoke-headless           # every bin/ and bin/examples/ program must survive EXAMPLETIME seconds
```

- `make check` refuses to run unless `DISPLAY` or `WAYLAND_DISPLAY` is
  set.
- Agents use only the `-headless` and `-sway` targets (see AGENTS.md).
- The existing `gprbuild` commands in AGENTS.md stay as they are.

Each test prints one line per check:

- `ok   - <label>`
- `FAIL - <label>`
- `skip - <label>` (the FLTK build or back end lacks the feature)

It then prints a summary and exits 1 on any failure.

## Phased roadmap

### Phase 0: Test infrastructure [done, 2026-11-03]

Everything after this phase is test-first. This phase adds:

- **`test/unit/checks.ads/.adb`** [done] (package `Checks`; the plan
  said `check.ads`).
  - `Check (OK : Boolean; Label : String)`, `Skip (Label)` and `Summary`
    (`Ada.Command_Line.Set_Exit_Status`).
  - `Raises (Proc : not null access procedure; E : Exception_Id; Label)`
    for exception tests. Several misuse cases fit in one file, which is
    better than pofltk's one program per halt code. Also `No_Raise`.
  - About 60 lines, with no AUnit dependency.
- **`test/unit/fltk-probe.ads/.adb` + `test/unit/c_probe.cpp`** [done]
  (package `FLTK.Probe`, a child of `FLTK` so it can reach a widget's C++
  object; the plan said `probe.ads`). Port pofltk's
  `test/Probe.Mod`/`Probe.cpp`:
  - Pixel capture: `Capture`, `Pixel`, `Shown_Pixel`.
  - Synthetic `Mouse`, `Wheel`, `Key` and `Shortcut` events.
  - `Modal` / `Modal_Key`, to answer a dialog from a timeout.
  - Pipe and fd helpers, and `Set_Env`.
  - The clipboard-notice hook.
  - `Has_Wayland`, `Has_X11`, `Has_SVG`, `Has_Cairo` feature queries.

  Linked by the test project only.
- **`tests_unit.gpr`** [done]. A new project, with `test/unit/` as its source
  directory and one `Main` per `test_<area>.adb` (decided 2026-11-03, Open
  question 4). It is kept separate so `tests.gpr` stays the demo set. It uses `proj/common.gpr` with `-gnata`
  on, so predicates in test code are checked.
- **A `Makefile` runner** [done]. The targets listed under Build and
  test, plus `valgrind-sway`, `smoke` and `smoke-sway`.
  `tools/with-sway.sh` is copied from pofltk. `test/vg-check.sh` comes
  from pofltk's `vg-check.sh`. ~~with the "FLTKAda's allocator" pattern
  changed to `fl_[a-z_0-9]*` shim frames and `fltk__*` GNAT frames.~~
  Without debug information valgrind names neither: shim frames show as
  `(in .../libfltkada.so)`, and GNAT's as `fltk.widgets.boxes.forge.create`.
  The script matches those.
  ~~`test/fltkada.supp` holds suppressions for fontconfig, Pango, libdecor
  and FLTK's font caches.~~ No suppression file: with
  `--errors-for-leak-kinds=none` those leaks never count as valgrind
  errors, and vg-check.sh ignores any whose allocator isn't FLTKAda's.
  Every run so far has had 0 valgrind errors, so there is nothing to
  suppress. Add a file only if a library outside FLTKAda gives one.
- ~~**The 8 existing self-checking programs** (`button`, `ask`, `dirlist`,
  `filename`, `preferences`, `group_children`, `clear_image_chosen`,
  `column_widths`).~~ Wrong: only 4 check themselves (`preferences`,
  `group_children`, `clear_image_chosen`, `column_widths`), and `make
  check` runs them [done]. `button` and `ask` wait for the user.
  `dirlist` and `filename` print a result for their argument and exit 0
  (1 without one), so the smoke run gives them one and expects 0.
- **Smoke runs** [done]. Every program `tests.gpr`, `tests_2022.gpr`
  and `examples.gpr` name, not a `bin/*` glob: `bin/examples/` holds
  stale binaries under old names (`OpenGL3-glut-test`, `OpenGL3test`).
  A program must survive `EXAMPLETIME` seconds (status 124). One in
  `ONCE` must exit 0 by itself. `ARGS` gives `dirlist`, `filename` and
  the three GIF examples their arguments, with `test/images/anim.gif`
  (pofltk's) for the GIFs. All 74 programs pass under Xvfb and sway.
- **`tools/gen-constants.py`** [done, 2026-11-03]. Ported from pofltk. It compiles a C++
  table of `{name, value}` from `FL/*.H` and generates
  `test/unit/test_constants.adb`. That test compares each enumeration's
  `'Enum_Rep` and each constant in `spec/fltk.ads` (keys, events, boxes,
  fonts, alignments, colours, cursors, `when` flags, menu flags, …) with
  FLTK's value, so the next FLTK upgrade fails loudly instead of
  silently.

  As built, it writes two files:
  - `test/unit/c_constants.cpp`, an array of FLTK's values in order. The
    array, not `{name, value}` pairs, because the Ada side is generated
    in the same order.
  - `test/unit/fltk-test_constants.adb`, a child of `FLTK`, so that it
    can see the private conversions (`To_C`, `Flag_To_UChar`,
    `MFlag_To_Cint`, `Mask_To_UChar`, `Cursor_Values`).

  The hand-written `test/unit/test_constants.adb` runs it. Enumerations
  are compared by `'Pos`, which is what the bodies pass to C. The C++ is
  compiled against the installed headers, so an FLTK upgrade needs no
  rerun of the script, only a rebuild.

  Each enumeration's last value is checked too: `Free_Box`,
  `Free_Label`, `Free_Font`, and `Event_Kind'Last` against
  `FL_ZOOM_EVENT`. That way, an enumerator FLTK adds fails as well as
  one it renumbers.

  It found two bugs on its first run, FLTKAda-BUGS.md 31 and 32:
  - `Box_Kind` lacked FLTK 1.4's twelve Oxy box types, so `Free_Box`
    was 56, not 68;
  - `Event_Kind` lacked `FL_ZOOM_GESTURE` and `FL_ZOOM_EVENT`, so FLTK's
    zoom shortcut raised `Internal_FLTK_Error` through any Ada global
    handler, which a scratch program confirmed.

  Both are fixed here, not in a later phase, because Phase 0 is done
  only when `test_constants` passes, and each fix is an enumerator
  list. All 260 checks pass.

- **The N12 experiment: exceptions crossing C++ frames** [done,
  2026-11-03] (Open question 2). Write `test/unit/test_exceptions.adb`, which raises an Ada
  exception from each kind of hook FLTK calls: a widget callback, an
  overridden `Draw`, an overridden `Handle`, a timeout, an idle, a GLUT
  callback, and an `Fl_Image` line hook. For each, record:
  - whether the exception reaches the Ada handler around `Run`/`Wait`,
    on X11 and on Wayland, in release and debug builds;
  - whether FLTK still works after it: a later `Draw`, an event, a modal
    dialog, a `Fl::grab` or `Fl::pushed` left set, a `fl_push_clip` not
    popped, a `Fl_Widget_Tracker` not removed;
  - whether valgrind reports anything.

  Write the results up in PLAN.md under N12, then choose: (a) catch every
  exception in each hook and report it, or (b) let it propagate, with a
  list of the FLTK state the binding must restore. Phase 2 implements the
  choice.

  **Results.** `test/controls/n12.adb` (one case per hook, plus a
  no-exception redraw as a control) ran each case in release and debug
  builds, under Xvfb and headless sway, and under valgrind on X11.
  `test/unit/test_exceptions.adb` then checks, for each hook, what
  FLTKAda will promise afterwards: no grab or pushed widget left set, no
  dialog left up, a later click runs its callback, a later redraw paints
  correctly, a later timeout or idle runs.

  The exception reached the Ada handler around `Wait` in every case, on
  both back ends and in both builds, and C++ destructors ran on the way
  (so `Fl_Button::handle`'s `Fl_Widget_Tracker` was removed: valgrind
  saw no invalid access). Whether FLTK still worked:

  | Hook | X11 | Wayland |
  |---|---|---|
  | callback (`Do_Callback`, a click) | works | works |
  | `Handle` on push | works | works |
  | timeout | works; not run again | works |
  | timeout during a modal `Choice` | works; dialog gone | works |
  | idle | no idle ever runs again | same |
  | `Draw` | works after the next damage | works, except a window whose first frame raised is never drawn |
  | `Draw` that raised inside its own `Push_Clip` | after 2 or more, later redraws miss part of the window | not run |
  | image line | as `Draw`; FLTK's buffer leaks | as `Draw` |
  | GLUT display | GLUT window works; plain windows then draw black | GLUT window never displayed again |
  | timeout during `Popup` | `Fl::grab` left on a dead stack frame: invalid reads, then `Storage_Error` (release) or a segfault (debug) | popup closes at once, so untested |

  Valgrind (debug, X11) shows no invalid access in any case but the
  menu one, and vg-check.sh passes them all. The image case loses
  1,200 bytes, but FLTK allocated them, so vg-check.sh rightly doesn't
  count them. FLTK-issues.md F3 has the cause of each in FLTK's source.

  Option (b) would have the binding restore `in_idle`, `Fl::grab`,
  the Wayland flush state and GLUT's `indraw`, all FLTK statics it
  can't reach. So the choice is **(a), with a deferred re-raise**:
  - each hook catches every exception, saves it with
    `Ada.Exceptions.Save_Occurrence`, and returns normally (a `Handle`
    returns `Not_Handled`), so FLTK finishes what it was doing;
  - the binding re-raises the saved occurrence when control is back in
    Ada: on return from `Wait`, `Check`, `Run`, `Do_Callback`, `Popup`,
    `Choice` and the other dialogs, and the `FLTK.Probe` calls;
  - consequence: an exception can't cut a modal dialog or a menu short.
    The dialog or menu stays up until it ends normally, and the
    exception comes out after. Only the first is kept if several are
    raised before control returns; the rest are dropped (Phase 2 decides
    whether to count them);
  - a clip the user's own `Draw` pushed and didn't pop before raising
    stays pushed. That is the user's to fix with a handler. Document it
    (Phase 15), and perhaps add a controlled clip guard.

  This was recommended by the agent; the user can overturn it.
  `test_exceptions` encodes it, so it fails until Phase 2 and is not in
  `tests_unit.gpr`'s `Main` until then. On X11 its only failures now are
  the idle and GLUT cases, and the menu case, which is run last because
  it crashes. On Wayland they are the idle, first-frame and GLUT cases;
  the menu case is skipped, since pop-up menus close at once there.

- **Negative controls** [done, 2026-11-03]. Two programs in
  `test/controls/` (`controls.gpr`, built into `bin/controls/`), kept
  out of `make check` because they must fail:
  - one `Check (False, ...)` makes a test print `FAIL` and exit 1;
  - a `Box` allocated with `new`, under `pragma No_Heap_Finalization`
    and never freed, must trip vg-check.sh.

  The second found two bugs in the new vg-check.sh. Each made it pass
  every leak of its kind:
  - valgrind writes GNAT's allocator as `<__gnat_malloc>`, in angle
    brackets, so it wasn't skipped as an allocator, and every Ada `new`
    in FLTKAda looked like libgnat's;
  - it writes `operator new` mangled, as `<_Znwm>`, so every `new` in
    the shim (`new_fl_box`) looked like valgrind's own.

  pofltk's `test/vg-check.sh` has the same `operator new` pattern, so it
  probably misses leaks from `new` in its shim too (not checked there).
  With both fixed, the control fails on the lost Ada object and on the
  lost `Fl_Box`. The real tests then failed on two blocks still
  reachable from `fltk'Elab_Spec`: `Clipboard_Image` and
  `Clipboard_Plain_Text` (spec/fltk.ads:848), library-level `String`
  constants whose length GNAT learns only at run time, so it puts them
  on the heap. vg-check.sh now passes a still-reachable block that
  elaboration allocated, and only that. A lost block from elaboration
  still fails.

Done when `make check-headless`, `make check-sway`, `make
valgrind-headless` and `make smoke-headless` all pass, with
`test_constants` and the folded-in programs as the first tests. All four
passed on 2026-11-03: 277 checks under Xvfb and under sway, valgrind
clean, and 74 programs in the smoke run.

### Phase 1: Housekeeping

- Remove the two stale entries listed above.
- Add `Unsupported_Error : exception;` to `spec/fltk.ads` (decision 2),
  with a comment saying what it means. Later phases raise it.
- **Where findings are recorded:**
  - Bugs in FLTKAda's own code go in `FLTKAda-BUGS.md`. Its sections
    15 onward hold the open ones from this triage. Move each to "Fixed",
    giving the fix and the test, when it is done.
  - FLTK issues that pofltk's `doc/fltk-issues.md` doesn't have go in
    `FLTK-issues.md`, numbered F1, F2, …, in pofltk's format.
  - The per-issue verdicts for pofltk's numbers stay in this plan. Don't
    copy pofltk's text: cite its numbers.

### Phase 2: FLTKAda's own memory-safety bugs

These come first because they are FLTKAda's own errors, not FLTK's.

- **Strings FLTK keeps** (decision 4):
  - Window `Set_Icon_Label` (issue 5) and `Set_Labels`.
  - `Tooltips.Enter_Area` (issue 75): a static `std::string` in the shim.
  - `File_Browser.Set_Filter` (issue 37).
  - The `File_Chooser` title (N5).
  - `Asks.File_Chooser`/`Dir_Chooser` titles (issue 30).
  - `Draw.Add_Symbol` (issue 123): copy, keep, and also require the name
    to be non-empty, ASCII and free of `@`.
- **The kept-pointers audit.** For every `To_C (` and `New_String (`
  passed to a `body/c_fl_*.cpp` function, check whether FLTK stores the
  pointer. Use a grep plus the FLTK source to do it. Record the list in
  this phase.
- **N8:** the `Value_Input`/`Input_Choice` `user_data` collision. The test
  types into a `Value_Input` with `Probe.Key`, and picks an
  `Input_Choice` item with `Probe.Mouse`.
- **N4 and issue 90:** keep every answer the link hook gives, and return
  `""` for images (pofltk's `in_image`).
- **N9:** detach a `Table`'s cell children in `Extra_Final`. Also
  override `Group.Remove (Place)` for `Table` (issue 52).
- **N10:** remove the text buffer callbacks in `Finalize` (issue 34).
- **N11:** keep browser icons alive and in step with line changes
  (issue 56).
- **N1** (`Font_Sizes`), **N2** (the `Draw_Image` line buffer), **N3**
  (`Expand_Text`).
- **N12:** exceptions raised in hooks FLTK calls. Implement the choice
  Phase 0's experiment made, (a) with a deferred re-raise, in every hook:
  `Callback_Hook`, the draw and handle hooks, the timeout and idle hooks,
  the GLUT hooks, the image-line hook and the `Scroll` hook. Re-raise in
  `Wait`, `Check`, `Run`, `Do_Callback`, the menu and dialog calls, and
  `FLTK.Probe`. Add `test_exceptions` to `tests_unit.gpr`'s `Main`, and
  document the user's own `Push_Clip` (FLTK-issues.md F3).
- **Issue 126:** `Local_To_Mac_Roman`/`Mac_Roman_To_Local`. Call FLTK
  with `n = 0` first, then convert a byte at a time, and return
  `Value (ptr, len)`.

Each item has a valgrind-clean test in `test/unit/`.

### Phase 3: The display, and the window FLTK needs

Calls that crash before the display is open, or without a shown or
current window:

- **`FLTK.Static.Open_Display`** (decision 5): bind `fl_open_display`,
  and test that calling it twice is harmless and that the calls below
  then work. Document both paths in its spec comment, in
  `doc/fl.html` and in `doc/binding_architecture.md`: which calls open
  the display by themselves, and why a program may still want to call
  `Open_Display` first.
- **Issue 1:** port pofltk's `ensure_font` (Cairo text before
  `fl_font`).
- **Issues 3 and 53:** keys and `DND_LEAVE` with no window shown. Guard
  on `Fl::first_window()`.
- **Issue 4:** `Take_Focus` and `Set_Focus` on Wayland.
- **Issue 49:** `Copy`, `Selection` and `Paste` on X11.
- **Issue 131:** `Ready`, `Selection`, `Enable_IM`/`Disable_IM` and
  `Set_Box_Color`.
- **Issue 110:** `GL_Window.Can_Do` and `GLUT.Get (Display_Mode_Possible)`.
- **Issue 138:** `Copy_Surface`. Also document that finalizing it writes
  the clipboard.
- **Issue 100:** set a default font after PostScript and `Printer`
  `start_job`/`start_page`.
- **Issue 28:** `Popup` right after `Show` on Wayland. Wait for the
  expose first.
- **Issue 109:** `OpenGL.Start` on Wayland raises `Unsupported_Error`.
- **Issue 111:** `Make_Current` before `Show`; GL `Set_Font`/`Draw_Text`
  with no context; `Set_Mode` inside `Draw`.
- **Issue 124:** `Overlay_Rect` and `Scroll` outside a draw.
- **Issue 129:** `Set_Grab` on a window not shown, and a grab left on a
  finalized window. Clear `Fl::grab` in every window free function.

Each case is tested twice, once on X11 (Xvfb) and once on Wayland (sway).
The test is a program whose first call is the risky one, wrapped in
`Raises` or expected to succeed.

### Phase 4: Objects FLTK keeps after Ada frees them

- **Issue 27:** a `global()` menu. Use FLTKAda's own handler, cleared in
  `Finalize`.
- **Issue 35:** `Highlight_Data`. Reject an empty table, copy the table,
  and take a reference on the style buffer.
- **Issues 41, 42 and 59:** removing tree items. Remove descendants
  last-first, and clear `callback_item` and `_lastselect`. Port pofltk's
  `Tr`/`Reach`.
- **Issue 51:** Preferences groups whose nodes were deleted. Keep the
  database plus the path, and check `group_exists`.
- **Issue 54:** menu item image and multi-label pointers freed as text,
  in `Remove`, `Clear_Submenu`, `Replace`, `Find_Index`, `Item_Pathname`
  and `Text`. Port pofltk's plain/Names approach.
- **Issue 58:** a tree item's widget when the item or the widget goes.
- **Issue 61:** `Window.Shape` on X11. Hand FLTK a copy.
- **Issue 62:** an animation's canvas finalized while the animation
  plays.
- **Issue 78:** tree item user icons. Hold a reference.
- **Issue 84:** a shared image used as a `Tiled` tile. Port pofltk's
  `unpooled`.
- **Issue 89:** a `Help_View` link held across a page change.
- **Issue 91:** a `File_Chooser` freed in its own callback. Defer the
  delete with a timeout.
- **Issue 92:** a `File_Chooser` extra widget finalized first.
- **Issue 112:** GLUT liveness.
  - Keep a live window and menu table, and raise on dead numbers.
  - Defer destroy during display.
  - Port `seal` (the empty or unterminated menu) and `gl_int`.
  - Handle the 32-window collision and `Get (Window_Parent)`.
- **Issue 72 (Table) and issue 23 (gaps):** `Spinner` and `Color_Chooser`
  `Clear`, and `Pack` resizable.

### Phase 5: Overruns from bad input

- **Issue 21:** `Grid.Set_Widget` row and column bounds.
- **Issue 36:** text buffer case-matching search. Port
  `ofl_buffer_search`.
- **Issue 63:** `fl_numericsort`. Write it in Ada. It is used by
  `Filenames`, `File_Browser.Load` and `File_Chooser`.
- **Issues 87 and 88:** crafted BMP and GIF files, and `Animated` frames
  outside the screen.
  - Port `dib_ok`, `gif_ok`, `lzw_ok` and the frame-fits check.
  - Wrap every image constructor in the shim in `try`/`catch`, so
    `bad_alloc` never crosses `extern "C"`.
  - Copy pofltk's `test/images/` crafted files.
- **Issue 81:** XBM. As a minimum, set `alloc_array` (every XBM leaks
  today). Then port pofltk's pre-parse.
- **Issue 120:** `Filenames.Expand`. Port pofltk's own `expand`.
- **Issue 121:** `Is_Directory` with a long name. `stat` directly in the
  shim.
- **Issue 122:** `Filenames.Match` with an unclosed `[`/`{`. Pad with
  NULs.
- **Issue 130:** `Font_Image (Free_Font)` before the table grows; font
  names over 126 bytes; `Set_Font_Kind (Target, Source)` sharing a
  pointer.
- **Issue 136:** dash lengths over 127 and more than 127 dash pairs.
  Narrow `Dash_Length`, and add an explicit length check.
- **Issues 96 and 98:** `Terminal`. Port `Term::fit` after each size
  setter, and validate `Set_Error_Char`.
- **Issue 99:** `Terminal` zero columns or zero text size.
- **Issue 101:** PostScript `end_job` after a Cairo error `fclose`s the
  file and writes to it, then Ada's `File_Type` closes it again. Port
  pofltk's `Sink` stream (`fopencookie` on Linux, `funopen` elsewhere),
  or refuse the drawing that makes Cairo fail (`Scale` by 0, an
  unbalanced `Untranslate`). Test: write to `/dev/full` under valgrind.
- **Issue 103:** `Page_Format` `Media` passed to `Start_Job`;
  `Scale`/`Rotate`/`Set_Origin` outside a page.
- **Issue 133:** re-entering `Draw_Image` from its own line callback.
  Raise.
- **Issue 134:** GL `Draw_Text` of text with no width. Port
  `draw_some`/`draw_line`.
- **Issue 65:** `Chart` labels cut mid-UTF-8 character.
- **Issue 127:** `Read_Image` partly outside the window. Clip it.

### Phase 6: Wrong results

- **Issue 2:** `Clip_Box`. Zero the outputs, and compute "changed" in the
  shim.
- **Issue 8:** box and label types never defined. Call every
  `fl_define_FL_*` once (in the shim, on first use of a box or label
  setter). `test/hello.adb`'s shadow label is the visual check.
  `Probe.Capture` is the automated one.
- **Issue 26:** menu `Insert`/`Remove` move the chosen item.
- **Issue 38:** browser `Top_Line`/`Displayed` before a draw.
- **Issue 45:** PNM with a maxval under 255.
- **Issue 57:** `Parse_Args` and an unknown option. Port `ofl_args`.
- **Issue 60:** `Chart.Set_Maximum_Size (0)`.
- **Issue 64:** a copy of a stopped animation plays.
- **Issue 76:** `Clock.Set_Time`/`Get_Time` round trip.
- **Issue 83:** `Shared_Image.Reload` reorders the pool.
- **Issue 94:** `Filenames.Relative`'s `Changed`.
- **N7, issue 6:** dispatch in `Set_Label (This, Kind, Text)`.
- **Issue 13:** override `Spinner.Set_Colors`, and validate the format
  string.
- **Issue 128:** `Restore_Clip` on Cairo. Remove it from the spec, or
  document `Push_Clip`/`Pop_Clip` instead.

### Phase 7: Documentation-only pitfalls and portability

**Spec comments** (and the matching `doc/*.html`):

- 10: the default callback and `changed`.
- 40: `Load` return values and `Load ("")`.
- 43: `Root` can be null.
- 44: no window icons on Wayland.
- 47: XPM colour names only on X11.
- 50: no selection buffer on Wayland.
- 79: `Menu.Add` merging same labels.
- 93: `Help_View.Load` of a URL opens the browser.
- 102: PostScript `end_job` alerts on error.
- 113: `GL_Window` calls `end()`, and Wayland forces `Double`.
- 114: `Cairo_Callback` must balance save and restore.
- 132: `Selection_Clear` is never delivered.

**Portability:**

- 73: guard SVG with `FLTK_USE_SVG`, and raise `Unsupported_Error`
  otherwise.
- 104: guard the PostScript chooser title with `FL_NO_PRINT_SUPPORT`.
- 114: make it visible when `Set_Cairo_Draw` is a no-op because FLTK has
  no Cairo.
- 93: restore `Fl_Group::current()` around `new_fl_help_dialog`.

### Phase 8: Core statics

These go in `FLTK.Static`, `FLTK.Events`, `FLTK.Screen` and `FLTK.Draw`,
as the coverage comparison found.

- **Shutdown:** `program_should_quit` (get and set), `hide_all_windows`,
  `run_checks`, `run_idle`, `set_abort`, `set_atclose`.
- **Timestamps:** `now`, `seconds_since`, `seconds_between`,
  `ticks_since`, `ticks_between`. Use `Ada.Calendar` or `Ada.Real_Time`
  types if they fit; otherwise use a private `Timestamp`.
- **Screen scaling:** `screen_scale` (get and set),
  `screen_scaling_supported`, `keyboard_screen_scaling`.
- **Clipboard images:** taking the `Fl_Image*` from `event_clipboard`.
  Issue 48 applies: under Wayland FLTK never deletes the pasted image.
- **Selections:** `selection_owner` (get and set),
  `selection_to_clipboard`.
- **Colour:** `fl_contrast_mode`, `contrast_level`, `contrast_function`,
  `fl_lightness`, `fl_luminance`, `fl_parse_color`.
- **Boxes and menus:** `box_border_radius_max`, `box_shadow_width`,
  `Fl::callback_reason`, `menu_linespacing`.
- **`FLTK.Draw`:** `rounded_rect`/`rounded_rectf`, `draw_check`,
  `draw_radio`, `draw_arrow`, `focus_rect`, `frame2`, `draw_box_focus`,
  `antialias` (needs the issue 124 guard), `load_identity`/`load_matrix`,
  `override_scale`/`restore_scale`.
- **Schemes:** `Fl_Scheme`'s `count`, `name` and `add_scheme_name`, as
  `FLTK.Schemes` or in `FLTK.Static`.
- **`Fl_Widget_Tracker`,** as `FLTK.Widget_Trackers`. §7.2 calls it "not
  worth binding", but pofltk's `Trackers` example shows a use: callbacks
  that may delete their own widget. Revisit the §7.2 note.

### Phase 9: Offscreens, capture, and UTF-8

- **`FLTK.Draw.Offscreen`:** create, begin and end, copy, rescale and
  delete, as a controlled type.
- **Capture:** `fl_capture_window`, with the issue 127 clipping, and
  `Fl_Image_Surface::mask`. For `mask`, issue 137 applies: check for
  depth 3, and track the "begun" and "masked twice" state.
- **`FLTK.UTF8`:** the `fl_utf8.h` functions pofltk binds.
  - Issues 115–118 apply: pad copies, and size buffers in the shim.
  - Where Ada already provides a function
    (`Ada.Strings.UTF_Encoding`, `Ada.Wide_Wide_Characters.Handling`),
    bind only what FLTK adds: `fl_nonspacing`, `fl_wcwidth`,
    `fl_utf8locale`, `to_mb`/`from_mb`, `fl_utf8test`, and FLTK's
    case-folding. Say so in the spec.

### Phase 10: Widgets and images

- **`FLTK.Widgets.Buttons.Shortcut`** (`Fl_Shortcut_Button`).
- **`FLTK.Images.RGB.BMP.ICO`** (`Fl_ICO_Image`).
  - Load from a file and from memory. Issue 82 applies: the memory path
    calls `fopen(NULL)`, so port pofltk's memory path and its PNG-at-offset
    decode.
  - Also `ICO_Count`.
- **`FLTK.Images.File_Icons`** (`Fl_File_Icon`). Issues 85 and 86 apply.
- **`Shared_Image` additions:**
  - `add_handler`/`remove_handler`. Issue 95 applies. A handler is an Ada
    access-to-subprogram, called through a shim trampoline.
  - `images()`, the pool listing, already in Incomplete APIs. Return a
    plain Ada array, following the feedback on idiomatic translation.
- **`fl_write_png`,** as `Write_PNG`.
- **`Image.Data_W`/`Data_H`.**
- **Multi-label on a widget,** in `FLTK.Multi_Labels`. Issue 55 applies.

### Phase 11: File surfaces

`FLTK.Devices.Surface.EPS`, `…Paged.PDF` and `…SVG`, with the choice
binding_architecture.md §7.3 already discusses (the `Widget_Surface`
wrinkle).

- Issue 102 applies to PDF: `end_job` reports errors only with an alert.
  Return an error status, and never alert.
- Port pofltk's `SaveAs` example, which writes PostScript, EPS, PDF and
  SVG.

### Phase 12: Method gaps in classes already bound

**Dialogs and input:**

- `Asks`: message position (`Set_Position`, `Set_Position_Over`,
  `Position`), and the icon label and its default setter.
- `Input`: `Redo`, `Can_Redo`.
- `Text_Buffer`: `Undo`, `Redo`, `Can_Redo`.

**Layout and menus:**

- `Tabs`: `Tab_Align`, `Handle_Overflow`.
- `Tile`: `Size_Range` and `Init_Size_Range`. Issue 24 applies: call
  `init_sizes` first.
- `Menu`: `Menu_Box`.
- `Sys_Menu_Bar`: `About`, `Create_Window_Menu`, `Window_Menu_Style`
  (mostly macOS; bind for completeness).

**Single widgets:**

- `Clock`: `Shadow`.
- `Help_View`: `Text_Selected`, `Copy`.
- `GL_Window`: `Swap_Interval`.

**Tree:**

- Item label foreground and background colours.
- Tree `Item_Label_BG_Color`.
- `V_Position`/`H_Position`/`Scrollbar_Size`.
- Tree-wide open, close and user icons. Issues 78 and 84 apply.

**Terminal:**

- Cursor movement and state: up, down, left and right; home, end of line
  and start of line; CR and CR-LF; tab right and left; save and restore;
  `Clear_With`.
- Issue 97 applies to restore.

**Then, `progress.txt`'s Incomplete APIs, case by case:**

- `Pixmaps` data access.
- `Shared` compare.
- Text buffer 1-indexing.
- `GIF.Animated.Fail_Code` clamping.
- `Grid` cells.
- `Flex` protected methods.
- `Windows.Get_First_Window`/`Get_Next_Window` with windows created in
  C++.
- `Choices.Schemes` `init_value`.
- `Resize` overrides reaching FLTK for more than `Box`, `Table` and
  `Table_Row`.

Also the open bugs listed in `progress.txt`/`PROBLEMS-OUTSTANDING.md`:
the `Menu.Add (Text)` ambiguity, `Remove_Clipboard_Notify` inside a
handler, `Dispatch_Hook`'s `Constraint_Error` label, and `Menu_Item`
`Set_Label` with an image or multi-label kind.

### Phase 13: GLUT fonts

- `FLTK.GLUT` bitmap and stroke fonts. Issue 135 applies, together with
  the issue 134 width check.
- Fix the GLUT `Incomplete APIs` items: `glut_window`/`glut_menu`, Ada
  objects for windows from `Create_Window`, and leaked menu and title
  strings.
- pofltk doesn't bind the `glutWire*`/`glutSolid*` models either. Leave
  them out.

### Phase 14: Examples and test ports

**Demo programs.** These go in `test/`, built by `tests.gpr`, one file
each.

Ports of FLTK `test/` programs that pofltk has and FLTKAda lacks:

- `boxtype`, `cairo_test`, `cube`, `device` (subset), `doublebuffer`,
  `file_chooser`, `fonts`
- `gl_overlay`, `glut_test`, `help_dialog`, `input_choice`, `mandelbrot`,
  `menubar`, `offscreen`
- `overlay`, `pixmap_browser`, `symbols`, `utf8`
- `forms`, only if the Forms open question is decided for it.

pofltk's originals, rewritten in Ada as Ada programs, not
transliterations:

- `console`, `file_inputs`, `help_pages`, `icons`, `menus`, `positions`
- `presets`, `rects` (only if `Fl_Rect` is bound), `save_as`, `scribble`
- `selections`, `shortcuts`, `swatch`, `tooltips`, `trackers`,
  `tree_icons`

Follow the window-sizing feedback (`Set_Resizable (Window)`, not only a
size range) and the new-file header attribution rule.

**Unit tests.** These go in `test/unit/`, one per area, mirroring pofltk's
`Test*.Mod`:

- `widget`, `group`, `window`, `button`, `input`, `valuator`
- `menu`, `browser`, `text`, `tree`, `table`, `grid`, `flex`
- `image`, `draw`, `events`, `clipboard`, `timer`, `fd`
- `preferences`, `filenames`, `ask`, `help`, `terminal`
- `print`, `gl`, `glut`, `utf8`, `constants`

Use pofltk's checks as the checklist of what to assert.

Done when `make smoke-headless` covers every program, and `make
check-headless` and `make check-sway` pass.

### Phase 15: Documentation

- `doc/<header>.html` for every newly bound header, linked from
  `doc/index.html`.
- `progress.txt`: update Done, Partially Done, To-Do, Never and
  Incomplete APIs.
- `doc/binding_architecture.md` §7: strike the gaps closed. §8: add the
  pitfalls this plan found, such as N8's `user_data` collision with FLTK's
  internal callbacks, and N12.
- `readme.md`: the new make targets.

### Phase 16: Forms, plugins and Cairo

Decided 2026-11-03 (Open question 1): bind all three, following pofltk.
Each is a separate library, as in pofltk, so a program using only
widgets isn't linked with what it doesn't use. Each raises
`Unsupported_Error` when the FLTK in use was built without it. Move
the classes off `progress.txt`'s "Never" list as they are bound.

- **Forms** (`~/Repos/Oberon/pofltk/src/forms/FlForms.Mod`/`.cpp`), as
  `fltkada_forms.gpr` and `FLTK.Forms.*`:
  - `Fl_Free`, with issue 105.
  - `Fl_Timer`, with issue 107.
  - `Fl_FormsBitmap` and `Fl_FormsPixmap`, with issue 106.
  - `Fl_FormsText`.

  Port pofltk's `Forms` and `FreeForm` examples.
- **Plugins** (issue 108). pofltk keeps them with preferences
  (`src/FlPreferences.Mod`: `Plugin`, `PluginManager`), as FLTK does.
  Bind `Fl_Plugin` and `Fl_Plugin_Manager` as `FLTK.Environment.Plugins`
  (FLTKAda binds `Fl_Preferences` as `FLTK.Environment`). A plugin is a
  tagged type of the program's own, registered under a class name.
  Document the `-rdynamic` link FLTK needs for a C++ plugin when FLTK is
  static, as pofltk does. `Fl_Device_Plugin` is FLTK-internal: decide
  whether it is worth binding once the others are done. Port pofltk's
  `Plugins` example.
- **Cairo** (`~/Repos/Oberon/pofltk/src/cairo/FlCairo.Mod`/`.cpp`), as
  `fltkada_cairo.gpr` and `FLTK.Cairo`. Like pofltk's, it is not FLTK's
  `Fl_Cairo_Window`, which only an FLTK built for it has. It is a double
  window whose `Draw_Cairo` draws over its widgets with a context good
  for that call alone. It works on any FLTK, on X11 and Wayland. It binds
  the cairo calls FLTK's programs use (pofltk's 75 procedures), with
  `tools/gen-constants.py` generating the constants. A context kept and
  used after the draw raises `Program_Error`. FLTKAda's existing
  `FLTK.Widgets.Groups.Windows.Double.Cairo` is checked against it and
  either kept for FLTKs built with Cairo or folded in. Port pofltk's
  `CairoDrawX` and `CairoTest` examples.
- `Fl_Rect`.

Each part gets its own `test/unit/` tests, run by `make check` only when
the library is built.

### Phase 17: BSD and 32-bit hosts

Once GNAT and gprbuild are available on pofltk's BSD hosts (cymoril and
yishana are i386; artos, jherek, alerik and rackhir run FreeBSD):

- Run `make check` against a hand-started Xvfb.
- Port pofltk's AGENTS.md notes on `/usr/X11R6`, fontconfig, `ulimit -d`
  and `/dev/full`.
- Extend readme.md's thin NetBSD and OpenBSD notes (issues 66 and 71:
  X11 directories, the `-lpng` that pkgsrc doesn't ship).
- The 32-bit builds exercise `c_pointer_size` and the `Address`
  conversions. Issue 68 applies to `Valuator.Get_Step` on i386.

## Open questions

All five were decided by the user on 2026-11-03.

1. ~~**Forms, plugins and Cairo.** `progress.txt` puts Forms and plugins
   on "Never". pofltk bound both (Forms as a separate library), and its
   examples use them. Keep them as "Never", or do Phase 16?~~ **Decided:**
   bind all three in Phase 16.
2. ~~**N12: exceptions crossing C++ frames.** Option (a): catch
   everything in each hook and report it. Option (b): let it propagate,
   which GNAT ZCX may manage through g++ frames built with unwind
   tables.~~ **Decided:** run the experiment in Phase 0, and choose from
   its results. It ran on 2026-11-03 and chose (a), with the hook's
   exception saved and re-raised once control is back in Ada (Phase 0,
   N12 experiment).
3. ~~**Display opening (decision 5).** Open the display lazily in the
   specific shim functions, or offer an explicit
   `FLTK.Static.Open_Display`?~~ **Decided:** both, documented (decision
   5, Phase 3).
4. ~~**Where the unit tests live.** `test/unit/` with `tests_unit.gpr`,
   or in `tests.gpr` with a naming convention?~~ **Decided:**
   `test/unit/` with `tests_unit.gpr` (Phase 0).
5. ~~**`Unsupported_Error`.** A new exception, or `Program_Error`?~~
   **Decided:** a new exception, `FLTK.Unsupported_Error` (decision 2,
   Phase 1).
