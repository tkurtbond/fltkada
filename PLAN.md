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
  135 has been bound since Phase 13, with its workaround.
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
    raised before control returns; the rest are dropped
    (~~Phase 2 decides whether to count them~~: Phase 2 decided not
    to; they are dropped uncounted);
  - a clip the user's own `Draw` pushed and didn't pop before raising
    stays pushed. That is the user's to fix with a handler. Document it
    (Phase 15), and perhaps add a controlled clip guard.

  This was recommended by the agent; the user can overturn it.
  `test_exceptions` encodes it, so it failed until Phase 2 and was not
  in `tests_unit.gpr`'s `Main` until then. (Phase 2 added it; it passes.
  The failures below are from before.) On X11 its only failures now are
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

  Phase 2 found a third bug of the same kind, 2026-11-03.
  - **The bug.** A string made with `New_String` is allocated by GNAT's
    runtime: `__gnat_malloc`, called from
    `interfaces.c.strings.new_string`. vg-check.sh took that runtime
    frame for the allocator, so every FLTKAda leak through `New_String`
    passed. It showed up as test_glut_strings passing despite its leaks
    (FLTKAda-BUGS.md 37).
  - **The fix.** vg-check.sh now skips the runtime's frames as part of
    the allocator: units Ada, System, Interfaces and GNAT, or libgnat.
  - **The control.** A third control, `control_string_leak`, leaks a
    `New_String` copy from a unit named `FLTK.Control_Strings`. The old
    vg-check.sh passes it and the new one fails it. The leaking procedure
    has to do some work after the allocation. Otherwise GNAT compiles
    both calls as tail calls, and valgrind shows no FLTKAda frame at
    all. The binding's setters always call FLTK after `New_String`.

Done when `make check-headless`, `make check-sway`, `make
valgrind-headless` and `make smoke-headless` all pass, with
`test_constants` and the folded-in programs as the first tests. All four
passed on 2026-11-03: 277 checks under Xvfb and under sway, valgrind
clean, and 74 programs in the smoke run.

### Phase 1: Housekeeping [done, 2026-11-03]

- Remove the two stale entries listed above [done]: from
  PROBLEMS-OUTSTANDING.md's "Missing small operations", which had
  nothing else and is gone, and from progress.txt's Incomplete APIs.
- Add `Unsupported_Error : exception;` to `spec/fltk.ads` (decision 2),
  with a comment saying what it means. Later phases raise it [done; also
  listed under Errors in `doc/fl.html`. Nothing raises it yet].
- **Where findings are recorded** [done: AGENTS.md, "Where findings go",
  says the same]:
  - Bugs in FLTKAda's own code go in `FLTKAda-BUGS.md`. Its sections
    15 onward hold the open ones from this triage. Move each to "Fixed",
    giving the fix and the test, when it is done.
  - FLTK issues that pofltk's `doc/fltk-issues.md` doesn't have go in
    `FLTK-issues.md`, numbered F1, F2, …, in pofltk's format.
  - The per-issue verdicts for pofltk's numbers stay in this plan. Don't
    copy pofltk's text: cite its numbers.

### Phase 2: FLTKAda's own memory-safety bugs [done, 2026-11-03]

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

Findings (2026-11-03):

- **Strings FLTK keeps: done.** This is FLTKAda-BUGS.md 16. The test is
  `test_kept_strings`, and the details are in its section. Two findings:
  - **pofltk 75's fix is unsafe.** pofltk's shim frees its tooltip copy
    on an empty text. FLTK still holds that copy, and a pending
    `tooltip_timeout` reads it (FLTK-issues.md F4). Valgrind caught this
    as the dir chooser below drew. FLTKAda's shim frees the old copy only
    once `Fl_Tooltip::current()` is the widget again, which is when FLTK
    holds the new one.
  - **`Probe.Close_Modal`.** On headless sway, `Modal_Key (Escape)` on an
    `Fl_File_Chooser` is handled by its focused `Fl_File_Input`, and the
    chooser stays up. `Close_Modal` does what `Fl.cxx:1567-1570` does for
    Escape, `modal->do_callback (FL_REASON_CANCELLED)`, so the test closes
    the chooser on X11 and sway alike.
- **The kept-pointers audit: done.** A subagent mapped every `To_C (` and
  `New_String (` passed to the shim against FLTK's source. Each bug below
  was spot-checked in FLTKAda's code. The full map was kept only in the
  session scratchpad, so this list is the record:
  - **`Static.Set_Font_Kind`** frees the old name before `Fl::set_font`
    reads it, and the `Font_Kind` overload makes two kinds share one name
    (pofltk 130). FLTKAda-BUGS.md 33, fixed.
  - **`Menus.Set_Label` and `System_Menu_Bar.Set_Label`** pass a
    temporary, which FLTK keeps after `Set_Items` or `Use_Same_Items`
    (pofltk 5, 26). FLTKAda-BUGS.md 34, fixed.
  - **The `File_Chooser` static label setters** free a label that
    existing choosers show. FLTKAda-BUGS.md 35, fixed: the old copy
    is kept until the program ends, since the ask functions' chooser is
    never deleted.
  - **The printer dialog's static setters** free strings that the kept
    print panel shows. FLTKAda-BUGS.md 36, fixed the same way.
  - **Found on the way: `FLTK.Static.Option` stops at `FNFC_Uses_GTK`.**
    It lacks five of FLTK 1.4.5's options: `OPTION_FNFC_USES_ZENITY`,
    `OPTION_FNFC_USES_KDIALOG`, `OPTION_PRINTER_USES_GTK`,
    `OPTION_SHOW_SCALING` and `OPTION_SIMPLE_ZOOM_SHORTCUT`
    (`FL/Fl.H:274-292`). `test_printer_labels` sets the printer one
    through `FLTK.Probe`. Binding them is coverage work, for a later
    phase.
  - **Leaks:** the GLUT titles and menu entries (pofltk 112), and the
    `Spinner` format (pofltk 13). FLTKAda-BUGS.md 37, fixed. GLUT's
    copies are kept per menu item and per window and freed when GLUT
    lets go. Checking or bounding GLUT's item and window numbers is
    pofltk 112's other half, for Phase 4.
  - **Not lifetime bugs:** `Menus.Set_Items` passes pointers where
    `fl_menu_copy` expects structs, and `Static.Clipboard_Contains`
    passes a copy where FLTK compares the pointer. FLTKAda-BUGS.md 38,
    fixed. The shim copies the items and their texts, and makes the
    menu own them.
  - **Decided: `Use_Same_Items` copies.** FLTK's `menu(m)` shares the
    donor's array, which the donor frees when it is deleted or outgrows
    it, so the sharing menu then reads freed memory. FLTK gives the
    sharing menu no way to know. So `Use_Same_Items` now gives the menu
    its own copy of the donor's items and texts, like `Set_Items`. Later
    changes to one menu no longer show in the other. They did so only
    by accident before: the first `add` or `replace` on a sharing menu
    already made it copy (`Fl_Menu_add.cxx:400, 474`). FLTKAda-BUGS.md 38.
  - **Safe as bound, checked in FLTK's source:**
    - **The widget-constructor labels.** The constructor stores the
      `To_C` temporary, but `Extra_Init` replaces it at once with
      `copy_label` (`fl_widget_set_label`, `body/c_fl_widget.cpp:279`),
      or with null for an empty label.
    - **`File_Browser.Load`'s directory.** FLTK keeps the pointer
      (`directory_ = directory`, `Fl_File_Browser.cxx:422`), but reads
      it only inside `load`. The class has no accessor for it.
    - **The `File_Chooser` labels**, which FLTKAda keeps in its record.
  - Every other call either copies the string or uses it only during the
    call. That rests on the subagent's map.
- **N1, N2, N3 and issue 126: done.** Each test failed before its fix
  (126's and N3's by FLTK's behaviour, checked in a scratch C++ program
  under Xvfb), and passes after it on Xvfb and sway, with valgrind clean.
  - **N1** (`test_font_sizes`): the shim reads `a[i-1]`. A Cairo or Pango
    FLTK lists one size, 0, for every font
    (`Fl_Cairo_Graphics_Driver.cxx:1189-1201`), so `Font_Sizes` alone
    can't show the bug. The test also calls the shim's accessor on an
    array of its own, and failed at entries 2 to 8 before the fix.
  - **N2** (`test_image_lines`): the line hook gives the Ada callback
    `W * Depth` bytes, keeping the `Depth` its `Draw_Image` was given.
    Before, the right of a colour image, and of a mono image of `Depth`
    2, came out of whatever was in FLTK's buffer. Found on the way: this
    FLTK draws with Cairo on X11 too, and Cairo draws a mono image of
    `Depth` 3 or 4 as a colour one (`Fl_Cairo_Graphics_Driver.cxx:677-680`),
    where Xlib draws its first byte as grey. So the test's mono case uses
    `Depth` 2. That difference isn't checked on an Xlib FLTK, and isn't
    yet in FLTK-issues.md.
  - **N3** (`test_expand_text`): `Expand_Text` passes a buffer of
    `8 * Length + 16` bytes. A character expands to at most 8 (a tab),
    and FLTK stops 4 short of the end (`fl_draw.cxx:76, 133-145`), so the
    text is never cut short. `Last` is now an index into `Text` whatever
    its `'First`. The scratch program confirmed that with `maxbuf = 0`
    the caller's `buf` stays null.
  - **Issue 126** (`test_recode`): a new shim function, `fl_draw_recode`,
    calls FLTK's conversion with `n = 0` first, then converts a byte at a
    time, as pofltk does. All four conversions use it, and take and
    return the text by length, so a NUL in it is kept. The scratch
    program showed the first `fl_mac_roman_to_local ("ab", 2)` dying of
    SIGSEGV, and `fl_local_to_mac_roman` of "a", 0xC4, "b" giving only
    0x61 and then two bytes it never wrote.
- **N8: done** (`test_part_callbacks`). The shim's constructors keep
  FLTK's callback for each part (`Fl_Widget::callback()` returns it) and
  install a thunk that calls it with `w->parent()` as the data. The
  parts' `user_data` stays the Ada record, so nothing that finds the Ada
  side through it changes. Before the fix, typing "7" into a
  `Value_Input` left its value 0 with no callback, and typing into an
  `Input_Choice` died with `Storage_Error`. The test picks the menu item
  by its shortcut, through `Fl_Menu_::test_shortcut`, not with
  `Probe.Mouse`, so it needs no pop-up and runs on sway as well. Valgrind
  is clean. The audit F2 asked for found no other case: FLTKAda wraps
  parts of `Fl_Browser_`, `Fl_Scroll`, `Fl_Table` and `Fl_File_Chooser`
  too, but the browser and scroll scrollbars' callbacks ignore their
  data (`Fl_Browser_.cxx:52-58`), `Table` already replaces its own, and
  the file chooser's buttons find it through the window's `user_data`
  (`Fl_File_Chooser.cxx:56, 89, 96`), which FLTKAda doesn't wrap.
  `Fl_Spinner`, `Fl_Tree`, `Fl_Text_Display` and `Fl_Terminal` give
  their parts the parent as data too, but FLTKAda doesn't wrap those
  parts.
- **N4 and issue 90: done** (`test_help_links`, with the pages
  `test/unit/help_one.html` and `help_two.html`). Ported from pofltk's
  `FlHelp.cpp`. The shim now installs its own link function in the
  constructor and keeps the state beside the `Fl_Help_View`:
  - a flag set around `load()`, and around `handle(FL_RELEASE)`, since a
    release on a link loads it (`Fl_Help_View.cxx:3216-3220`). The next
    question is what to load;
  - the answer about what to load, kept till the next one, so it outlives
    `free_data()`'s questions about the old page's images;
  - each image's answer, asked of Ada once and kept for the view's life,
    so drawing and freeing are answered without Ada and with the same
    name, which FLTK releases (`:2788-2799, 2531`). A refused image is
    answered `""`, a name with no file, so FLTK draws its broken image;
  - `~My_Help_View` calls `value(0)` while the subclass still exists, and
    `Extra_Final` stops asking Ada before the C++ object goes.
  Ada's hook returns 1 or 0 and hands its answer to the shim, which copies
  it, so `Hilda` is gone. `Load` and `Set_Content` raise `Program_Error`
  when called while the callback is asked about an image: `format()` would
  go on reading the freed page (pofltk 90; Architecture decisions 1).
  Before the fix, with an image answer as long as the next page's name,
  `Load ("help_two.html")` after a page with two images raised
  `Load_Help_Error`, with FLTK's "Error" page shown, as load() opened the
  image's name. The images were asked about again at each draw, and the
  refused image killed the program. After it, all 14 checks pass on Xvfb
  and sway, and valgrind is clean. pofltk 89 (a link followed after the
  layout changed under a held button) is not part of this fix.
- **N9 and issue 52: done** (`test_table_children`; FLTKAda-BUGS.md 39).
  `Table.Extra_Final` now detaches the Ada widgets in the inner `Scroll`,
  through `Group`'s detaching loop, now the private `Remove_Ada_Children`.
  `Table` overrides `Remove (Place)`. The test found a third bug:
  `Table.Find` of a widget not there gave an index past the end, as
  `Fl_Table::find` counts the inner group's scrollbars. `Iterate`,
  `Has_Child (Cursor)` and `Child (Cursor)` dispatch through the cursor's
  container, so they already used `Table`'s. Before the fix, a table let
  go before its cells' buttons gave invalid reads under valgrind, and
  `Remove (1)` removed a scrollbar.
- **N10 and issue 34: done** (`test_buffer_life`; FLTKAda-BUGS.md 40).
  `Text_Buffer.Finalize` removes its modify and predelete hooks, through
  two new shim functions. Before the fix, an edit through a display after
  the Ada buffer was freed gave invalid reads in the predelete hook.
  Reading the code found a neighbour, still open: `Text_Display.Get_Buffer`
  keeps an access to the Ada buffer, which then dangles
  (FLTKAda-BUGS.md 41).
- **N11 and issue 56: done** (`test_browser_icons`; FLTKAda-BUGS.md 42).
  `Set_Icon` gives FLTK a copy (`Image.Copy`) that the browser owns, so
  the caller's image may go. The binding no longer keeps icons by line:
  `Get_Icon` and `Has_Icon` ask FLTK which image the line shows
  (`Fl_Browser::icon(line)`, Fl_Browser.cxx:922-925, through a new shim
  getter) and find the copy with that pointer, so the icon follows its
  line through `Insert`, `Move` and `Swap` with no bookkeeping. After
  `Set_Icon`, `Remove_Icon`, `Remove`, `Clear` and `Load` (both
  browsers'), copies no line shows any more are freed. Before the fix,
  icons stayed with the line number, and valgrind reported 162 invalid
  reads drawing freed images (in `fl_image_w`, `Fl_Browser::item_height`
  and `item_draw`).
- **N12: done** (`test_exceptions`, now in `tests_unit.gpr`'s `Main`;
  FLTKAda-BUGS.md 43). A new private package, `FLTK.Hook_Exceptions`,
  keeps the first saved occurrence; later ones are dropped and not
  counted. Every hook FLTK calls catches everything (77 handlers in 30
  bodies) and returns a harmless value, and 58 calls to `Reraise` follow
  the C calls that can run hooks. Where a body's own handler for
  `Constraint_Error` or `Assertion_Error` would otherwise catch the
  re-raised exception, the old statements go in a nested block after
  `Reraise`. `Run` is now `Fl::run`'s loop in Ada (`while Fl::wait ()`,
  Fl.cxx:651-654), so it can re-raise between waits. `Screen.Flush` and
  each window's `Flush` re-raise too. The fatal-error hook is left
  alone, and the image-line hooks stop calling the user's function after
  it raised once. Findings:
  - The pop-up menu's grab is FLTK's own `menuwindow`
    (Fl_Menu.cxx:1002), so `Events.Get_Grab` can't return it
    (FLTKAda-BUGS.md 44, open). The test uses a new `Probe.Grabbed`.
  - Several hooks' handlers for the binding's own checks also cover
    the user's code, and relabel the user's exception as
    `Internal_FLTK_Error` (FLTKAda-BUGS.md 45, open, from the code).
  - The GLUT case's "redraw paints red" check read 0 0 because the GLUT
    window covered the box on Xvfb, and `fl_read_image` reads the
    screen. The test destroys the GLUT window first.
  - A file-browser or `Get_Listing` sort comparator that raises returns
    0, so `qsort` may see an inconsistent comparator for the rest of that
    sort. The exception still comes out; the order is then unspecified.
    From the code.
  - Results: Xvfb, 67 ok (release and debug); headless sway, 61 ok and
    the menu case skipped; valgrind, no invalid accesses and vg-check.sh
    passes.
- **Found by the full valgrind run at the end of Phase 2**: a new
  `Menu_Item` left its label fields uninitialised (FLTKAda-BUGS.md 46,
  fixed).

### Phase 3: The display, and the window FLTK needs [done, 2026-11-03]

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

What was done. Three new unit tests cover it, each run on Xvfb and on a
headless sway, each seen to fail before its fix:

- `test_first_calls` runs itself once per case, so that each case is its
  program's first call. It checks that each run exits 0 and prints no X
  error.
- `test_wrong_state` covers the calls that need a window or a context.
- `test_print_font` covers issue 100, and `test_popup_early` issue 28.

- **Before the fixes, `test_first_calls`:**
  - **X11:** `Copy`, `Selection`, `Paste`, `Ready`, a key with no window
    shown, `DND_LEAVE` with no window shown, `Font_Descent` and text in
    a first `Draw` crashed (SIGSEGV, which GNAT reports as
    `Storage_Error`).
  - **Wayland:** `Copy`, `Disable_System_Input`, the key, `DND_LEAVE`,
    `Font_Descent` and the text crashed, and `Take_Focus` returned False.
  - **Neither crashed:** `Set_Box_Color`, `Clipboard_Contains`,
    `Enable_System_Input`, `GL_Window.Can_Do`, `GLUT.Get` and
    `Copy_Surface`. pofltk lists them, so they open the display anyway.
- **`FLTK.Static.Open_Display`: done.** It binds `fl_open_display`, which
  does nothing the second time (`Fl_Screen_Driver::open_display`, its
  `been_here`). The lazy path calls `fl_open_display()` in the shim
  functions for all the calls above that crash without a display, and
  for the ones pofltk lists that didn't crash here. The comment on
  `Open_Display`, `doc/fl_(fltk-static).html` and
  `doc/binding_architecture.md` §3.5 list them. If no display can be
  opened, FLTK exits: `Fl::fatal ("Can't open display: %s")` on X11
  (Fl_x.cxx:550), and "No Wayland connection" on Wayland
  (Fl_Wayland_Screen_Driver.cxx:1428).
- **A finding on GL windows, from the code:** on a hybrid build, making
  any window calls `attempt_wayland()`
  (fl_wayland_platform_init.cxx:38-64), which connects to Wayland. So a
  GL window made before the display is open still gets the Wayland GL
  driver (Fl_Wayland_Gl_Window_Driver.cxx:86), and pofltk's open in the
  constructor isn't needed. `GL_Window_Show` passed on sway before any
  fix. The static `Fl_Gl_Window_Driver::global()` (Fl_Gl_Window.cxx:545),
  made before any window is, is X11's: hence issue 109.
- **Issue 1: AFFECTED, done.** `ensure_font` (pofltk's) is in every text
  function in `c_fl_draw.cpp`: `Draw_Text`, `Width`, `Font_Height`,
  `Font_Descent`, `Measure`, `Get_Font`, `Get_Font_Size` and the rest. It
  sets FLTK's normal font when the current driver has no font descriptor
  and `fl_size()` is 0 or less. Only `Font_Height (Font, Size)`, which
  sets its own font, and `Draw_Symbol`, which draws no text, go without
  it.
- **Issues 3 and 53: AFFECTED, done.** With no window shown, the shim's
  `unshown_event` handles a key itself: it goes to the grab or focus
  widget and its parents, as `Fl::handle_` tries it first. `DND_LEAVE`
  is taken and does nothing. Both crashed through
  `Fl::first_window()` = 0 (Fl.cxx:1556-1557; `Fl_Input`'s cursor). A
  dispatch function the program set still sees the event first.
  - **A note on the test:** `FLTK.Widgets.Inputs.Input` binds `Fl_Input_`,
    the base class, which takes no focus. `Fl_Input` is
    `FLTK.Widgets.Inputs.Text`, so the tests use that.
- **Issue 4: AFFECTED (Wayland), done.** `Take_Focus` and `Set_Focus` open
  the display first.
- **Issue 49: AFFECTED, done.** `Copy` and `Selection` open the display.
  On X11, with no window shown, `Paste` does nothing unless this program
  owns what is pasted (`fl_i_own_selection`), as pofltk's guard does.
  FLTK would otherwise ask the X server with window 0, and print
  BadWindow.
- **Issue 131: AFFECTED, done.** `Ready`, `Enable_System_Input`,
  `Disable_System_Input` and `Set_Box_Color` open the display.
- **Issue 110: HANDLED here, guarded anyway.** `GL_Window.Can_Do` and
  `GLUT.Get (Display_Mode_Possible)` open the display.
  `GLUT_DISPLAY_MODE_POSSIBLE` is `Fl_Gl_Window::can_do (glut_mode)`
  (glut_compatibility.cxx:410).
- **Issue 138: HANDLED here, guarded anyway, done.** `Copy_Surface`'s
  `Forge.Create` opens the display. Its spec now says that finalizing it
  puts the drawing on the clipboard (Fl_Xlib_Copy_Surface_Driver.cxx:58-65,
  Fl_Wayland_Copy_Surface_Driver.cxx:36-39).
- **Issue 100: HANDLED, by issue 1's `ensure_font`.** No change to
  `start_job` or `start_page` was needed. `begin_page` pushes the
  PostScript surface (Fl_PostScript.cxx:1902), and
  `Fl_PostScript_Graphics_Driver::font` also sets the display driver's
  font (:191-194), whose Pango description `transformed_draw` uses
  unchecked (:1571). `ensure_font` sees no font on the PostScript driver
  and sets one. `test_print_font` passes on both back ends: text is the
  first call on a page, the size is then 14, and the file is written. A
  negative control, with `ensure_font` returning at once, crashed
  (`Storage_Error`). pofltk's SVG bug, where `ensure_font` reset the SVG
  surface's font on every call, can't happen here: FLTKAda binds no
  SVG, EPS or PDF surface yet (Phase 11). `ensure_font` already asks
  `fl_size()`, as pofltk's fixed version does. (Phase 11 bound them:
  `test_eps_surface` and `test_pdf_surface` draw text first with no font
  set, and `test_svg_surface` finds the font set in the file.)
- **Issue 28: AFFECTED (Wayland), done.** `Menu_Button.Popup`,
  `Menu.Popup` and `Menu.Pulldown` first call `wait_for_expose` on the
  window FLTK puts the menu over: the menu widget's top window, or
  `Fl::first_window()` if the widget is in none (Fl_Menu.cxx:987-996).
  `wait_for_expose` returns at once when that window is already there,
  and on X11. `test_popup_early` pops up a menu straight after `Show`,
  on each of two windows. Before the fix, it ended with "Fatal error no 1
  in Wayland protocol: xdg_surface" and exit 1 in three runs of three.
  After it, three of three passed. The three Ada bodies already call
  `Hook_Exceptions.Reraise` after the C call, which covers the event loop
  that `wait_for_expose` runs.
- **Issue 109: AFFECTED, done.** `OpenGL.Start` raises
  `FLTK.Unsupported_Error` on Wayland, where `gl_start` uses
  `Fl_Gl_Window_Driver::global()` and `Fl_Window::current()` unchecked
  (gl_start.cxx:58-87). It crashed on sway with any window current.
- **Issue 111: AFFECTED, done.** All of these raise `Program_Error`:
  - `Make_Current` on a window that isn't shown, for `Window`, `GL_Window`
    and `Glut_Window`. FLTK calls `fl_alert` and `Fl::fatal` there
    (Fl_X11_Window_Driver.cxx:401-405, Fl_Wayland_Window_Driver.cxx:344-349).
  - GL `Set_Font`, `Font_Height`, `Font_Descent`, `Width`, `Draw_Text` and
    `Measure` with no GL context. A context is either a shown GL window
    current (`Fl_Gl_Window::make_current` sets `current_`,
    Fl_Gl_Window.cxx:133) or a `Start` not yet finished.
  - `Start` with no shown window current, and `Finish` with no `Start`.
  - `GL_Window.Set_Mode` inside that window's `Draw`.

  `Fl_Window::current()` stays set after its window is hidden, and
  dangles after it is freed. So the shim only compares it with the shown
  windows, and `test_wrong_state` checks the calls again after the
  current window was finalized. Before the fixes, `Set_Font` and `Start`
  with no window crashed on X11. On sway, `Set_Font`, `Draw_Text` and
  `Start` crashed. `Font_Height`, `Width` and `Finish` happened not to
  crash, and are guarded anyway, as pofltk guards them.
  - **Deferred:** pofltk's ready checks for GLUT bitmap and stroke text
    (`FlGlut.Mod`). They go with issue 112, in Phase 13. Done there:
    `test_glut_fonts`.
- **Issue 124: AFFECTED, done.** pofltk's `on_window` and `on_surface`
  are ported to `c_fl_draw.cpp`.
  - `Overlay_Rect` and `Overlay_Clear` raise `Program_Error` unless a
    shown window is current and drawing goes to the screen.
  - `Scroll` by (0, 0) is allowed on a surface or a window.
  - On a surface, `Scroll` calls the callback for the whole area, since
    there are no pixels to move.
  - With neither, `Scroll` raises.

  Before the fix, `Overlay_Rect` and `Scroll (1, 0)` crashed on both back
  ends. `Overlay_Clear` and a `Scroll` by (0, 0) didn't, and are guarded
  anyway. In a `Draw`, all of them work.
  - **A finding about the test:** the `Scroll` callback must be at
    library level (`test/unit/scroll_areas.ads`). The binding calls it
    through its bare address, and GNAT's `'Unrestricted_Access` of a
    nested procedure is a trampoline on the stack, which crashed.
- **Issue 129: AFFECTED, done.** `Set_Grab` on a window that isn't shown
  raises `Program_Error`. On X11, `Fl::grab` grabs the pointer for
  `fl_xid (Fl::first_window ())` (Fl_X11_Screen_Driver.cxx:460), and it
  crashed with none. A new shim `fl_widget_forget`, called from
  `Widget`'s `Extra_Final` for every widget the binding frees, clears
  `Fl::grab` and `Fl::selection_owner` if they are that widget. FLTK's
  own `~Fl_Widget` doesn't clear them: its `fl_throw_focus` clears
  `pushed`, `belowmouse` and `focus` only (Fl_Widget.cxx:166-185,
  Fl.cxx:1205-1219). A negative control
  without the call gave "Invalid read of size 8" under valgrind, and
  failed "a finalized window's grab is cleared".
- **Results:** `test_first_calls`, `test_wrong_state` (33 checks),
  `test_print_font` and `test_popup_early` pass on Xvfb and on sway.

### Phase 4: Objects FLTK keeps after Ada frees them [done, 2026-11-03]

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

What was done. Each item has a unit test, run on Xvfb and on a headless
sway, and under valgrind. Each test was seen to fail before its fix.

- **Issue 27** (`test_menu_global`): the shim keeps its own global menu
  and handler. The handler does what FLTK's does (Fl_Menu_global.cxx:23-28):
  it skips the shortcut while a modal window is up, and otherwise sends it
  to the menu, with its window as `Fl::first_window`. `Menu.Extra_Final`
  clears the menu if it is the global one. Before the fix, a finalized
  global menu's shortcut raised `Storage_Error`. After it, all 6 checks
  pass.
- **Issue 35** (`test_highlight_data`): `Highlight_Data` copies the
  table into the Ada record and takes a reference on the style buffer;
  both are let go when another is given and in `Finalize`. A table that is
  empty or does not start at 'A' raises `Constraint_Error`. FLTK indexes
  the table from 'A' (Fl_Text_Display.cxx:2725-2731), which FLTKAda had
  ignored; that is FLTKAda-BUGS.md 47. Before the fix, a table changed
  after the call changed the layout, and freeing the style buffer then
  raised `Storage_Error` (valgrind: an invalid read in
  `Fl_Text_Buffer::byte_at`). After it, all 7 checks pass and valgrind is
  clean. `textdisplay-with-colors` and `texteditor-with-dynamic-colors`,
  whose tables start at 'A', still run.
- **Issues 41, 42 and 59** (`test_tree_remove`). Decided: the shim
  reaches `_lastselect` through pofltk's `Reach`, so it doesn't need to
  remove descendants last-first, as pofltk does. `fl_tree_forget` runs
  before every call that deletes items: `Remove`, `Clear`,
  `Clear_Children` and `Tree_Items.Replace`. It clears `_lastselect` and
  the callback item when either is among the items going, and counts the
  removal. `fl_tree_handle`, through which every `Handle` reaches
  `Fl_Tree::handle`, then does what pofltk's `Tr::handle` does. After an
  event in which items were removed, it clears `_lastselect` unless that
  is still in the tree. Before the fix, 5 of 9 checks failed:
  - a Shift-click after the last item clicked was removed with its
    parent, cleared from it or replaced (41);
  - `Callback_Item` after its item was removed in the callback, or after
    `Clear` (42).

  Valgrind found two invalid reads in the drag after an item was removed
  as it was pushed (59): Fl_Tree.cxx:531 and `Fl_Tree_Item::move`. After
  the fix, all 9 pass and valgrind is clean. With only the check after
  the event disabled, valgrind finds 3 invalid reads again.
- **Issue 58** (`test_tree_widgets`). Decided: an item's widget belongs
  to the Ada program, so when the item goes, `fl_tree_forget` takes the
  widget out of the tree rather than deleting it, as pofltk does. The
  other way round, `My_Tree::on_remove` clears the widget from its item
  when it leaves the tree, finalized or added to another group. This is
  pofltk's `Tr::on_remove`, but it walks the items rather than keeping a
  map. Before the fix, a removed item's button still took a click where
  it had been, and was still in the tree. Drawing an item whose widget had
  been finalized read freed memory (Fl_Tree_Item.cxx:1038 and 1049; 13
  invalid reads) and raised `Storage_Error`. After the fix, all 6 checks
  pass, on X11 and Wayland, and valgrind is clean.
- **Issue 78** (`test_tree_icons`). Decided: an item's user icon and
  deicon are copies the binding owns (`Image.Copy`), as for the Browser
  icons (FLTKAda-BUGS.md 42), held for the item's tree by a new private
  package, `FLTK.Tree_Icons`. A copy is freed once no item of its tree
  shows it (shim `fl_tree_shows_icon`, walking `first()`/`next()`, as
  pofltk's `drop_tree_icons` does), checked after an icon is set or
  cleared and after `Remove`, `Clear`, `Clear_Children` and `Replace`;
  the rest are freed when the tree is. A copy set on a custom item no tree
  has taken yet is kept until the tree goes, since the walk can't see the
  item. `Get_User_Icon` now finds the copy by the pointer FLTK shows,
  rather than by the item's address, which a later item could reuse.
  `Set_User_Icon`'s image is now `in`, so a temporary will do. The
  tree-wide icons are still not bound. Before the fix the test crashed
  with a segmentation fault. After it, all 6 checks pass on X11 and
  Wayland, and valgrind is clean. Negative controls: with every copy
  treated as unused, the custom item's check fails and valgrind finds 31
  invalid reads; without freeing at the tree's end, `vg-check.sh` fails on
  leaks allocated in `fltk.images.copy`.
- **Issue 51** (`test_pref_groups`). Decided as planned, after pofltk: the
  shim keeps no `Fl_Preferences` for a group, only its base (the database,
  or the memory group's own `Fl_Preferences`) and its path from the base,
  and opens a short-lived `Fl_Preferences(base, path)` for each call
  (shim class `Opened`). The Ada side checks `fl_pref_group_exists`
  (`group_exists(path)`, which searches below the base,
  Fl_Preferences.cxx:643, 1816) before every call on a group, through
  `Group_Ptr`, and raises `Preference_Error` ("the group was deleted"),
  since `Fl_Preferences(parent, path)` would make the group again
  (Fl_Preferences.cxx:484-495). The reference counting moved into the
  shim: every group holds one reference to its base, so `Root_Ptr` and
  `My_Root_Group` are gone, and a memory group's groups now keep it. A
  group deleted and later made again by its path is the new group, as in
  pofltk. Before the fix 7 of the 16 checks failed and valgrind found 43
  invalid reads, then the test died with `Storage_Error`. After it, all
  pass and valgrind is clean, and so is `preferences`. Negative control:
  with `fl_pref_group_exists` always true, 8 checks fail.
- **Issue 54** (`test_menu_item_labels`). Decided as planned, after
  pofltk: an item showing an image or a multi-label shows an `Item_Label`
  instead (body/c_fl_menuitem.cpp), a multi-label of the item's own whose
  first part is the image or the user's multi-label, with the item's name
  kept beside it. `Get_Label` gives the name, and `Get_Label_Kind` the kind
  of the first part. Before `Remove`, `Clear_Submenu`, `Set_Label` (FLTK's
  `replace`), `Clear` and finalization the shim gives the items FLTK frees
  their names as text (`plain_items`); during `Add`, `Insert`,
  `Find_Index` and `Item_Pathname` it swaps the names in (`Item_Names`);
  `Text` returns the name. Unlike pofltk, whose menus keep their item
  labels, each `Item_Label` belongs to one item, found in a set of live
  ones: `Use_Same_Items` and `Set_Items` copy it, as they copy texts
  (FLTKAda-BUGS.md 38), and a free-standing `Menu_Item` has one too.
  `Set_Image` and `Set_Multi_Label` no longer free the item's text. Giving
  such an item `Set_Label_Kind` of another kind shows its name; giving it
  `Image_Label` or `Multi_Label` changes nothing. Before the fix 3 of the
  checks failed (an item showing an image or a multi-label was not found
  by its path) and the test died with `Constraint_Error`. After it, all 20
  pass on X11 and Wayland, and valgrind is clean. Negative controls:
  without the names swapped in for `Find_Index`, the same 3 checks fail;
  without `plain_items` before `Remove` and `Clear_Submenu`, valgrind
  finds 3 mismatched `free()`s of an `Item_Label` in Fl_Menu_::remove
  (Fl_Menu_add.cxx:502) and the names leak. `vg-check.sh` judges only
  leaks, and these names are FLTK's allocations, so it passes that
  control; `make valgrind-headless` fails it through `--error-exitcode`.
- **Issue 61** (`test_window_shape`). Decided as planned, after pofltk:
  `fl_window_shape` gives FLTK a copy of the image made at its drawn size,
  `copy(w(), h())`, and of a shared image's `image()`, since a shared
  image is released, not deleted. Confirmed in FLTK's source: X11 keeps
  the pointer as `shape_` and, for a bitmap, `combine_mask` copies it
  again whenever the window's size changes (Fl_X11_Window_Driver.cxx:
  146-152, 301-302), and `shape_alpha_` reads w() by h() pixels of a
  data_w() by data_h() image. Only the driver's destructor frees, and
  only `effective_bitmap_` (:64-66); neither driver reads the old shape
  when given a new one (X11 :258-275, Wayland :266-290). Unlike pofltk,
  whose window record holds the copy, the shim keeps it in a map from
  window to copy, freed when the window is shaped again and from each
  window shim's `My_` destructor (all eight kinds), so a window FLTK
  deletes as a child frees it too. `Shape` raises `Constraint_Error` for
  an image with no data, and `Storage_Error` if the copy can't be made.
  Before the fix the checks passed but valgrind found 5002 invalid reads:
  `shape_alpha_` (:232, :238) past the end of a 10x10 RGBA image scaled
  to 100x100, and `combine_mask` (:301) reading a bitmap freed before its
  window was resized. After it, valgrind is clean on Xvfb, and on headless
  sway it finds no invalid reads (its 54 errors are Wayland's and
  libdecor's leaks, which `vg-check.sh` passes). Negative control: without
  the destructor in `My_Double_Window`, the copy leaks. At first valgrind
  named FLTK's `Fl_Bitmap::copy` as its allocator, which `vg-check.sh`
  passes, so the copy is now held by a `Shape_Copy` the shim allocates:
  the control then fails `vg-check.sh`, with 8 bytes lost in
  `fl_window_shape`.
- **FLTKAda-BUGS.md 48** (`test_image_data`), found while writing
  `test_window_shape`. Not on pofltk's list, since pofltk copies:
  `RGB_Image` and `Bitmap` `Create` gave FLTK the caller's array, which
  `Fl_RGB_Image` and `Fl_Bitmap` keep. Decided: the shim copies the data
  and sets `alloc_array`, as pofltk's `ofl_image_rgb` and `new_bitmap`
  do, and the length check is an explicit `Constraint_Error`, not `Pre`.
  `RGB_Image`'s `Pre` keeps only `Data'Length <= Get_Max_Size`, which
  guards no memory. No program in test/ or examples/ changed its array
  after `Create`, so none relied on the image seeing the change. Details
  and controls are in FLTKAda-BUGS.md.
- **Issue 62** (`test_anim_canvas`). Decided: as in pofltk, an animation
  forgets a canvas that goes, so either may go first. The shim keeps the
  set of animations that have a canvas. `fl_widget_forget`, which every
  widget's `Extra_Final` already calls, clears `canvas_` in those whose
  canvas is going. `canvas_` is private, so the shim reaches it with
  `Reach`, as for `Fl_Tree::_lastselect`. It doesn't call `canvas(0)`,
  which would set the freed widget's image. FLTK's timer then
  runs on with no canvas (Fl_Anim_GIF_Image.cxx:1195 checks for one).
  `Get_Canvas` returns null once FLTK has no canvas, rather than the Ada
  access, which may be dangling. Before the fix, finalizing a playing
  animation's canvas and running the timer for a second gave 129 invalid
  reads, and `Get_Canvas` still returned the freed canvas. After it,
  all 7 checks pass and there are no invalid reads, on X11 and Wayland.
  The timer keeps advancing frames. Negative control: without the
  call in `fl_widget_forget`, 126 errors, 17 of them invalid reads,
  and `Finalize` raised. An animation finalized with its timer pending
  was already safe, since `~Fl_Anim_GIF_Image` removes its timeout
  (:620). The test also found FLTKAda-BUGS.md 49: a canvas the animation
  left still returned it from `Get_Image`.
- **Issue 84** (`test_tiled_tile`). Decided: as in pofltk's `unpooled`,
  `new_fl_tiled_image` tiles a private copy of a shared image's inner
  image, scaled to the shared image's size, and the tiled image owns it
  (`alloc_image_`, protected, set through a derived class). Other tiles
  are kept as FLTK keeps them, since `examples/animgifimage` tiles a live
  animation. A copy of a tiled image that owns its tile gets its own copy
  of it too, since `Fl_Tiled_Image::copy` shares the tile (:83) and the
  original deletes it (:72). The shim returns 0 if a copy can't be made,
  and the binding raises `Storage_Error`. Before the fix, 4 checks failed:
  `Desaturate` turned the pool's image grey, tiling took a pool
  reference (2), and the tiled image's destructor deleted the pool's
  entry, which was then read (2854 errors, 41 invalid-read contexts).
  After it, all 7 checks pass with no invalid reads, on X11 and Wayland.
  Negative controls: without the shared-tile copy, the same 4 checks
  fail with the same errors. Without the copy's own tile, the check
  still passes, because the freed tile still holds its pixels, but
  valgrind reports 29 invalid reads, so `make valgrind-headless` catches
  it. The test also found FLTKAda-BUGS.md 50: `Tile` returned the tile
  from before the colours changed.
- **Issue 89** (`test_help_held`). Decided: as in pofltk, the shim's
  `My_Help_View` counts layout changes (`Set_Content`, `Load`, and its
  `resize` override, which `Resize`, `Set_Size` and a parent's resize all
  reach). A release after a change since the push is no longer a click
  (`Fl::event_is_click(0)`), so FLTK drops the link it kept
  (Fl_Help_View.cxx:3218-3223). Before the fix, 3 checks failed: a link
  held while the page was set, a page loaded, or the view resized was
  followed. Setting the page gave 14 invalid reads, all in `follow_link`
  (:2860-2895) from `handle` (:3220). After it, all 5 checks pass with no
  invalid reads, on X11 and Wayland, and `test_help_links` still passes.
  Negative control: without the `event_is_click(0)` call, the same 3
  checks fail with the same 14 invalid reads.
- **Issue 91** (`test_chooser_close`). Decided: as in pofltk, the shim's
  `My_File_Chooser` takes the chooser's callback and calls the Ada one
  through `Call`, which counts the calls under way. `free_fl_file_chooser`,
  called while one is under way or from the event loop
  (`fl_inside_callback`), hides the chooser, cuts it off from Ada (the
  callback, its data, the extra widget, the window's label) and leaves the
  delete to a timeout. The timeout waits while a call is still under way.
  The chooser's user data is kept beside it in the shim, since FLTK's
  `data_` now points the callback at the shim object. Before the fix,
  `fileNameCB` hid the window (Fl_File_Chooser2.cxx:823) after its
  callback (:820) had freed the chooser: valgrind showed 5 invalid reads,
  though all 5 checks passed. After it, all 5 checks pass with no invalid
  reads and no leak, on X11 and Wayland. `test_chooser_labels` still
  passes. Negative control: with every free immediate, the checks pass
  and valgrind shows 6 invalid reads, the first from `fileNameCB` (:820).
  So valgrind, not the checks, is what catches this bug.

  Found on the way: on Wayland, a synthetic Enter with no text never
  reaches an input's Enter handling. `Fl_Wayland_Screen_Driver::compose`
  returns 0 only for a control character, so for a key with empty text it
  returns 1, and `Fl_Input::handle_key` takes the key as typed text
  (Fl_Wayland_Screen_Driver.cxx:707-711, Fl_Input.cxx:358). A real Enter
  carries "\r". This was checked with a scratch C++ chooser under sway
  and Xvfb: with empty text the callback ran on X11 only, and with "\r" it
  ran on both. A test gives `FLTK.Probe.Modal_Key` the key's text, and
  its spec says so. This is a test pitfall, not a fault in FLTK, which
  never sends such an event.
- **Issue 92** (`test_chooser_extra`). Decided: the shim keeps each live
  `My_File_Chooser` in a set, with the extra widget it was given.
  `fl_widget_forget`, which every widget's `Extra_Final` calls before it
  frees the widget, calls `file_chooser_extra_gone`, and every chooser
  holding the widget calls `add_extra(0)` while the widget is still
  there. That shrinks the window by the widget's height plus 4 and clears
  `ext_group` (Fl_File_Chooser.cxx:487-493), so the next `Add_Extra` and
  the destructor (:330) don't read it, and `Eject_Extra` returns null.
  The `Modal_H` probe function was added for the test. Before the fix,
  finalizing the extra widget raised `Program_Error` from an invalid read
  in `Widgets.Extra_Final`: `Parent` took the chooser window's
  `user_data`, the `Fl_File_Chooser`, as an Ada group. That is
  FLTKAda-BUGS.md 51, left open in general. After the fix, all 6 checks
  pass with no invalid reads and no leak, on X11 and Wayland, and
  `test_chooser_close` and `test_chooser_labels` still pass. Negative
  controls: without the hook, the same `Program_Error`. With a hook that
  only takes the widget out of the window, 2 checks fail (the room stays,
  and `Eject_Extra` returns the freed widget), with 2 invalid reads, one
  in `add_extra` (:488).
- **Issue 112** (`test_glut_live`). Decided: as in pofltk, the shim
  keeps its own table of GLUT's windows and menus, and the Ada side
  checks every number against it before FLTK indexes its own tables
  unchecked (glut_compatibility.cxx:279 and the window and menu calls).
  - **Windows.** The shim watches each window with
    `Fl::watch_widget_pointer`, so a window deleted with its parent, or a
    finalized `Glut_Window`, drops out. A dead number raises
    `Constraint_Error`, and `Window_Exists` says which are live.
    `Destroy_Window` marks the window and those in it dead at once and
    deletes them from a timeout, so a display function can destroy its
    own window. `Hide_Window` while a GL window draws is put off the same
    way, through `gl_window_drawing`, now shared by `Gl_Window` and
    `Glut_Window`'s `draw`. Destroying a `Glut_Window` made by a Forge, or
    a window holding one, raises `Program_Error`: its Ada object owns it.
    The display and overlay functions are kept per window in the shim,
    and are skipped for a dead window.
  - **32 windows or menus.** FLTK gives the 32nd the 31st's number
    (:168, :308). `Create_Window`, `Create_Sub_Window`, `Create_Menu` and
    a `Glut_Window`'s Forge raise `FLTK.Unsupported_Error` instead.
  - **Menus.** The shim keeps each menu's labels (`std::deque` of
    `std::string`) and submenus, and its array size, mirroring `additem`
    (:331-346). `seal` terminates the array after every change, since
    `additem` sets only the new terminator's text. `glutRemoveMenuItem`'s
    copy past the end (:384) is padded. An item past the last raises
    `Constraint_Error`. A menu used as a submenu can't be destroyed or
    changed (`Program_Error`), since FLTK holds its array (:359); that
    also rules out a menu that holds itself. `Destroy_Menu` takes the menu
    off every window's buttons. `Attach_Menu` and a `Glut_Window`'s
    `Set_Menu` refuse an empty menu, which `domenu` (:298) would pop up
    unterminated. The texts that FLTKAda-BUGS.md 37 kept in
    `body/fltk-glut.adb` are now kept here.
  - **Queries.** `gl_int` starts from 0, so a query GL doesn't take gives
    0 rather than stack garbage (:430). `Window_Buffer_Size` adds the bit
    counts, since FLTK's asks `glutGet(GL_RGBA)` (:421). A query of 100 or
    more goes to GL. `Window_Parent` uses `dynamic_cast`, which fixes
    FLTKAda-BUGS.md 30. `Display_Mode_Possible` opens the display first.
  - **Overlays.** ~~`Establish_Overlay` and `Use_Layer` raise
    `Program_Error` for a window not shown.~~ Corrected 2026-11-05: the
    claim behind it, that `make_overlay_current` crashes on such a window,
    was wrong, and both now work on a hidden window (FLTKAda-BUGS.md 91).

  Before the fix, the test failed 10 checks. Every call with a dead
  number raised `Storage_Error` from FLTK's freed window, or nothing at
  all: `Set_Window`, `Post_Window_Redisplay`, `Create_Sub_Window`,
  `Destroy_Window` twice, `Set_Menu` and `Add_Menu_Entry` with no menu.
  After it, all 50 checks pass on X11 with no invalid reads and no leak.
  On sway 48 pass, and the pop-up menu checks are skipped, because the
  compositor closes pop-ups. Negative controls:
  - With `Check_Window` disabled, 8 checks fail, mostly with
    `Storage_Error`.
  - With FLTK's own `glutGet (GLUT_WINDOW_PARENT)`, the checks pass, but
    valgrind reports 2 invalid reads in `glutGet` (:400).

  The test first failed at the 31 windows. The test's own `Glut_Window`
  already held number 1, so the 31st raised `Unsupported_Error`, as it
  should. The test now makes 30 more.
- **Issue 23 (gaps) and issue 72** (`test_group_clear`). `Group.Clear`
  removed every child, including the ones FLTK made as members of the
  C++ object: a `Spinner`'s field and two buttons, and a
  `Color_Chooser`'s seven parts. It now removes only the children Ada
  added (`Remove_Ada_Children`), as `Finalize` already did, and keeps
  the ones recorded in `Internal` at `Extra_Init`. `Scroll` already kept
  its scrollbars. `Packed_Group.Clear` also clears the resizable, as
  `Fl_Pack::clear` does (FL/Fl_Pack.H:98). Without that the pack is left
  its own resizable, because `Fl_Group::remove` sets that when it takes
  out the resizable child (Fl_Group.cxx:591). Before the fix, 3 of 7
  checks failed: the spinner had 0 parts, the chooser had 0 parts, and
  the pack's resizable was not null.

  Issue 72: the triage's "Table only" isn't reproduced. Since Phase 2,
  `Widget.Extra_Final` takes a widget out of its parent before
  `Fl::delete_widget` queues it, and for a table that parent is the
  inner `Playing_Area`. So no group or table deletes a queued widget
  again. The test frees a box in a `Table` and one in a `Group` from a
  timeout, then deletes the table and the group before the queue runs.
  FLTK runs the queue at the start of the next wait
  (Fl_System_Driver.cxx:357). Both groups are empty, and valgrind is
  clean. All 8 checks pass on X11 and sway, with no invalid reads and no
  leak. Negative controls:
  - With the old `Group.Clear` and no `Clear_Resizable`, the 3 checks
    fail.
  - With `Extra_Final` not removing the widget, the 72 check fails, and
    the test raises `Storage_Error` with 3 invalid reads.

### Phase 5: Overruns from bad input [done, 2026-11-03]

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

What was done. Each item has a unit test, run on Xvfb and on a headless
sway, and under valgrind. Each test was seen to fail before its fix.

- **Issue 21** (`test_grid_range`): the `Set_Widget` functions return
  False, as their spec already said, for a row or column past the grid,
  and for a span that goes past its edge. The procedures then do
  nothing. Exceptions were not used, because the functions already
  report a refused cell. Before the fix, 5 of 12 checks failed, and
  valgrind found 8 invalid reads and writes. While testing, a second
  over-read turned up: a span that a smaller `Set_Layout` cuts through
  (FLTK-issues.md F5). The shim now cuts every span to fit before the
  grid shrinks. All 12 checks pass on X11 and sway, with no invalid reads
  and no leak. Negative control: with the cut disabled, the checks pass
  but valgrind finds 6 invalid reads in `Fl_Grid::layout ()`.
- **Issue 36** (`test_text_search`): with `Match_Case`, `Search_Forward`
  and `Search_Backward` now do the shim's own byte search through
  `byte_at`, ported from pofltk's `ofl_buffer_search`. It keeps FLTK's
  results for an empty string: found at the start, but not forward from
  the end. Without `Match_Case`, FLTK's search is still called. The test
  builds the buffer with its gap near the start, so that the text runs
  to the end of its memory. Before the fix the test hung at a backward
  search from past the end, a second FLTK problem (FLTK-issues.md F6),
  and valgrind found invalid reads in FLTK's `memcmp`
  (`Fl_Text_Buffer.cxx:1364`). The shim now clamps a backward search's
  start to the length. All 21 checks pass on X11 and sway, with no
  invalid reads and no leak. Negative control: with FLTK's search
  matching case again, but the clamp kept, the checks pass but valgrind
  finds 6 invalid reads, at `:1312` and `:1364`.
- **Issue 63** (`test_numeric_sort`, with the empty files in
  `test/unit/names/` copied from pofltk): `Numeric_Sort` and
  `Case_Numeric_Sort` are written in Ada, from pofltk's
  `numeric_compare`. `Get_Listing`, `File_Browser.Load` and
  `File_Chooser` already called them through Ada. Case is folded with
  FLTK's `fl_tolower`, not `Ada.Wide_Wide_Characters.Handling`, which
  the release build's `-gnatn` inlined with 168 style complaints about
  GNAT's own `s-utf_32.adb`. The test found that the shim's wrappers cut
  names to 255 bytes to fit a `dirent` (FLTKAda-BUGS.md 52), so
  `Alpha_Sort` and `Case_Alpha_Sort` are written in Ada too. Before the
  fix, 11 of 32 checks failed: "ab12z" came before "ab12" in each
  listing. Valgrind saw no invalid read, because the shim's copy sits in
  a full-sized `dirent` on the stack. All 43 checks pass on X11 and
  sway, with no invalid reads and no leak. Negative control: with the
  sort ending in `Equal` whenever a name runs out, 2 checks fail.
- **Issues 87 and 88** (`test_image_crafted`, with pofltk's crafted and
  sound files in `test/images/`). `body/c_fl_image_check.cpp` ports
  pofltk's `dib_ok`, `gif_ok` (here `gif_data_ok`), `lzw_ok` and the
  frame-fits check. The BMP, GIF and animated GIF constructors, file and
  memory, check first. A refused still image fails with `ERR_FORMAT`, set
  through a subclass that reaches the protected `Fl_Image::ld`, and
  `Create` raises `Format_Error`. A refused animation loads an empty GIF
  instead, so it isn't loaded and its `Fail_Code` is -3, as FLTK leaves
  it. `Frame_Count`, `Load` and `GIF.Is_Animated` refuse the same files.
  ICO isn't bound, so an ICO is checked only as a shared image.
  `Shared_Image` `Create` sniffs a GIF, BMP or ICO and checks it before
  calling `get`, and `Reload` leaves the image as it is when its file has
  gone bad. FLTK's own loading, in `Help_View` pages and the file
  chooser's preview, doesn't come through the shim and isn't covered.
  The test found two FLTKAda bugs: a refused GIF raised
  `Constraint_Error` (FLTKAda-BUGS.md 53), and a shared image of no file
  had no FLTK object (54). Every image constructor and copy in the shim
  now catches C++ exceptions and returns null, and the Ada side raises
  `Storage_Error` "no memory for ...". The `catch` was tested with a PNG
  over `int'Last` bytes, which overflows FLTK's `int` size
  (FLTK-issues.md F7). FLTKAda now caps `Max_Size` at `int'Last`, so that
  FLTK refuses such a file itself, and a shared image that FLTK's loader
  took and couldn't load raises `No_Image_Error`. Before the fix, the
  test crashed with `Storage_Error` at `Fl_BMP_Image.cxx:260`, the first
  crafted BMP. All 38 checks pass on X11 and sway, with no invalid reads
  and no leak. Negative controls: with `dib_ok` and `gif_data_ok`
  disabled, the crash at `:260`; with the GIF check alone disabled,
  valgrind finds 10 invalid reads and writes (`memmove`, and
  `lzw_decode` at `Fl_GIF_Image.cxx:345`), then `Storage_Error`; with the
  `Max_Size` cap disabled, 5 checks fail with `Storage_Error`.
- **Issue 81** (`test_image_crafted`, with pofltk's `rb.xbm`,
  `not-xbm.h`, `short.xbm` and `huge.xbm`). Decided: the shim reads the
  XBM itself, with pofltk's `parse_xbm` ported to
  `body/c_fl_image_check.cpp`. That means `<name>_width` and
  `<name>_height`, other `#define`s allowed, a `char` array, and every
  byte of the bits, with the byte count also kept within an `int`. It
  makes an empty `Fl_XBM_Image ("")`, which opens nothing
  (`Fl_XBM_Image.cxx:45`), and gives it the bits with `alloc_array` set,
  so `Fl_Bitmap` frees them. A refused file fails with `ERR_FORMAT`
  (`Format_Error`), and one that can't be read fails with
  `ERR_FILE_ACCESS` (`File_Access_Error`). `Shared_Image` `Create` refuses
  a file starting `#define` that doesn't parse, and after `get` and
  `Reload` it sets `alloc_array` on the `Fl_XBM_Image` that
  `Fl_Shared_Image::reload` made (`Fl_Shared_Image.cxx:297`), so shared
  XBMs no longer leak. A negative control used FLTK's loader for every
  readable file and left shared XBMs unowned. 6 checks failed:
  `not-xbm.h` loaded 1 wide, `short.xbm` 4 wide with a byte unset, and
  `huge.xbm` 100000000 wide. 4 blocks were definitely lost at
  `Fl_XBM_Image.cxx:77`. FLTK's own XBM loading, in `Help_View` and the
  file chooser's preview, isn't covered. Its log also showed a JPEG from
  memory leaking, which led to three FLTKAda bugs. A JPEG from memory was
  read past its end, because the shim didn't pass the length
  (FLTKAda-BUGS.md 55). A named PNG, JPEG or SVG from memory left a
  dangling entry in the shared pool, and an unnamed PNG or JPEG was put
  in it under `""` (56, FLTK-issues.md F8). `Shared_Image` `Create
  (From)` shared the image itself, unowned (57). New test
  `test_image_names`. All checks pass in both tests, 49 and 14, on X11
  and sway, with no invalid reads and nothing definitely lost.
- **Issues 120, 121 and 122** (new test `test_filenames`). The shim no
  longer calls `fl_filename_expand`, `fl_filename_isdir` or
  `fl_filename_match` as they are.
  - 120: pofltk's `expand` is ported to `body/c_fl_filename.cpp`. It
    works on a `std::string`, puts each value in once without rescanning
    it, and copies the result out cut short to `Max_Path_Length - 1`
    bytes, as FLTK cuts its own results. Before the fix, a value of
    6144 bytes aborted the test (status 134, "buffer overflow
    detected"). A negative control used FLTK's expand without that
    check, and `SELF='$SELF'` never ended: `timeout 20` killed it
    (rc 124). The empty value's `value[-1]` (`Fl_System_Driver.cxx:275`)
    reads the `=` before a `getenv` value, so no run can show it. The
    check that an empty value gives `x//b` passes either way.
  - 121: the shim calls `stat` itself. Decided: `Is_Directory` takes any
    `String`, not a `Path_String`. A `pragma Assertion_Policy` in the
    caller didn't stop GNAT checking the predicate, so the overrun can't
    be reached from a test built with `-gnata`. A release build doesn't
    check the predicate, though, and a name longer than `FL_PATH_MAX` can
    still name a directory. A negative control with `fl_filename_isdir`
    aborted on a name of 3004 bytes (status 134, "buffer overflow
    detected").
  - 122: the shim matches copies with 16 NULs after them. A negative
    control without the NULs failed the check that `"a"` matches `"[a"`.
    Valgrind found nothing, because a `std::string` has room after its
    NUL.

  All 61 checks pass on X11 and sway, with no invalid reads and vg=0.
- **Issue 130** (new test `test_free_font`, which must be the first in
  its process to use `Free_Font`). Confirmed first by a scratch C++
  program under Xvfb and valgrind. Before the table grows,
  `Fl::get_font (FL_FREE_FONT)` returns 0xffffffffffffffff and reading it
  crashes, and `get_font_name` returns garbage. A name of 150 bytes
  aborts in `strcpy_chk`. `get_font_name` of an empty slot crashes on
  NULL. With `Fl::set_font (FL_FREE_FONT, NULL)` first, the slot is empty
  and a box labelled in it draws. Decided:
  - The shim's `fl_static_grow_fonts` grows the table the first time a
    font from `FL_FREE_FONT` on is used. That covers `Font_Image`,
    `Font_Family_Image`, `Font_Sizes`, `Set_Font_Kind`, `Setup_Fonts`,
    and `FLTK.Draw`'s `Set_Font` and `Font_Height`. It sets the
    font to NULL, which is safe only while the slot is empty
    (`Fl_Cairo_Graphics_Driver.cxx:1157-1158`), so `Setup_Fonts` calls it
    before `Fl::set_fonts` fills the slot. FLTK calls neither function
    itself. A built-in font doesn't grow the table, because growing it
    opens the display (`Fl_Cairo_Graphics_Driver.cxx:1269`).
  - For an empty slot the shim gives `""`, and doesn't call
    `get_font_name`.
  - `Set_Font_Kind` cuts a name to 126 bytes, before a UTF-8 character
    that would cross that.
  - `Set_Font_Kind (Target, Source)` already copied the name (bug 33).
  - As in pofltk, a widget's font isn't checked. Drawing a box in
    `FL_FREE_FONT` before the table grew didn't crash the scratch program,
    but it reads past the table.

  Before the fix, the test read garbage for `Free_Font` and then died
  with `Storage_Error`. Negative controls: without the growth, the same;
  without the cut, it aborted (status 134, "buffer overflow detected").
  All 10 checks pass on X11 and sway, with no invalid reads and vg=0, and
  `test_font_kinds`, `test_font_sizes` and `test_print_font` still pass.
- **Issue 136** (new test `test_dashes`). `Set_Line_Style` passed any
  number of pairs of lengths 1 to 255 to `fl_line_style`, which on Cairo
  `strcpy`s them into `linedash_[256]`
  (`Fl_Cairo_Graphics_Driver.cxx:317-319`). Decided, as in pofltk:
  `Dash_Length` is now 1 to 127, so no length is negative as a signed
  `char`, and `Set_Line_Style` raises `Constraint_Error` on more than
  `Max_Dash_Gaps`, 127, pairs (254 chars and the NUL). Nothing in the
  tree used a length over 127. Before the fix the test aborted at 150
  pairs (status 134, "buffer overflow detected"). Negative control: with
  the range back at 255, a dash of 200 doesn't raise. All 8 checks pass
  on X11 and sway, with no invalid reads and vg=0; they check the dashes
  drawn, by the pixels, for one pair, a dash of 127 and 127 pairs.
- **Issues 96, 98 and 99** (new test `test_terminal_fit`). Decided, as
  in pofltk:
  - `My_Terminal::fit`, ported from pofltk's `Term::fit`, puts the cursor
    and the place `ESC[s` saved back on the screen. It reaches the private
    `escseq` by an explicit instantiation. The shim calls it after every
    size, margin, font, box and scrollbar setter, and from an override of
    `resize`.
  - `Set_Error_Char` raises `Constraint_Error` unless it is given one
    printable UTF-8 character of 1 to 4 bytes.
  - `Set_Text_Size (0)`, `Set_Display_Columns (0)`, and more than 2**24
    cells from a size setter or `Forge.Create` raise `Constraint_Error`.
    `Forge.Create` also refuses fewer than 1 row or column, or a negative
    history. FLTK makes that constructor's history 100 rows whatever it
    is given (`Fl_Terminal.cxx:3450`), so it counts at least 100.

  What FLTK 1.4.5 does here differs from pofltk's notes in places, from
  the test's runs and `Fl_Terminal.cxx`.
  - `refit_disp_to_screen` only ever enlarges the columns (:1338), so
    neither a narrower widget nor `display_columns (20)` brings them below
    what the width allows.
  - A resize, margins and a larger text size kept the cursor on the
    screen without `fit`.
  - What `fit` fixes is `Set_Display_Rows`, which left the cursor at row
    34 of 19, and a place saved before a shrink and restored after it, at
    row 9 of 2.
  - Those rows are inside the ring's block, so valgrind found no invalid
    writes. The test checks the cursor.

  Before the fix, 15 of 21 checks failed: nothing was refused, and the
  program died with `Storage_Error`. The recursion of a control error
  character is pofltk's finding (pofltk 98); the test doesn't try it.
  Negative control: with `fit` disabled, the `Set_Display_Rows` and saved
  place checks fail. All 21 checks pass on X11 and sway, with no invalid
  reads and vg=0.
- **Issue 101** (new test `test_ps_errors`). Decided, as in pofltk:
  - A PostScript job given a `File_Type` writes through a `Sink`, ported
    from pofltk: a stream of the shim's (`fopencookie`, or `funopen` off
    Linux) that tells Cairo every write worked and remembers one that
    failed. `End_Job` then raises the new `File_Write_Error`. The `Sink`
    writes to its own `dup` of the file's descriptor, so FLTK never sees
    the `File_Type`'s `FILE`, and the program can close it before or after
    `End_Job`.
  - `Rotate` and `Scale` raise `Constraint_Error` for a NaN or an
    infinity, and `Scale` for an X factor of 0, on `Paged_Device`,
    `Postscript_File_Device` and `Printer`. A Y factor of 0 is still the
    X factor, as FLTK documents it. `Untranslate` raises unless a
    `Translate` on the page is still to be undone. `Paged_Device` keeps
    the count, which `Start_Page` resets.
  - `Start_Job` with a `File_Type` raises `File_Open_Error` if the file
    isn't open. That was a `Pre`, which release builds don't check.

  Before the fix, `End_Job` to `/dev/full` wrote to the `FILE` it had
  just closed (69 invalid reads at `Fl_PostScript.cxx:1957`), and the
  `File_Type` closed it again, so the program died. An `Untranslate` with
  no `Translate` did the same. Negative controls:
  - The program's file given to FLTK instead of the `Sink`: the same 69
    invalid reads and the death.
  - No `Untranslate` check: Cairo refuses the drawing, and FLTK writes to
    the `Sink`'s stream after closing it (42 invalid reads). There is no
    double close, but the file is empty. So the `Sink` alone doesn't make
    a Cairo error from drawing safe; the checks do.
  - No scale or rotation checks: a scale of 0, of 0 across, of NaN, and a
    rotation of NaN are each a Cairo error here. `Printer.Scale (0.0)`
    with no job then died with `Storage_Error` (Issue 103's ground).

  pofltk lists drawing through `fl_scale (0)` as still uncovered. Here a
  scratch program's `FLTK.Draw.Scale (0.0)` on a page made no Cairo
  error: `End_Job` raised nothing and valgrind found nothing. If any
  other drawing does make one, `End_Job` raises `File_Write_Error`, but
  FLTK will have written to the closed stream first.

  Not covered: `Start_Job` without a file, which asks for one with FLTK's
  file chooser. FLTK opens and closes that file itself, so a write that
  fails there is still a Cairo error, and `end_job` closes the file
  twice. That is from FLTK's source (`Fl_PostScript.cxx:1956-1980`); the
  test can't answer the chooser, so it is untried.

  All 17 checks pass on X11 and sway, with no invalid reads and vg=0.
- **Issue 103** (new test `test_page_misuse`). Decided:
  - `Set_Origin`, `Rotate`, `Scale` and `Translate` raise `Page_Error`
    outside a page, on `Paged_Device`, `Postscript_File_Device` and
    `Printer`. `Paged_Device` keeps an `In_Page` flag, which `Start_Page`
    sets and `End_Page` and `End_Job` clear; they also zero the
    `Translate` count. Under Pango, `scale`, `rotate` and `origin` restore
    two Cairo states that `begin_page` saved, and `translate` saves two
    (`Fl_PostScript.cxx:1852-1887`, `Fl_Cairo_Graphics_Driver.cxx:615-631`).
    `Page_Error` was chosen over `Constraint_Error` because nothing is
    wrong with the values; the device isn't ready for them. The value
    checks from Issue 101 come first, so a NaN still raises
    `Constraint_Error` anywhere. `Untranslate` needs no page check: its
    count is 0 outside a page, so it raises `Constraint_Error` there.
  - Both `Start_Job`s with a `Format` raise `Constraint_Error` for
    `Media`. FLTK indexes `page_formats` (30 entries) with the format, and
    `MEDIA` is `0x1000` (`Fl_PostScript.cxx:1530-1543`,
    `Fl_Paged_Device.H:28, 76`).

  Before the fix, 28 of 29 checks failed. In a job, each of the four
  before the page, or after it, made a Cairo error (`Translate` didn't,
  but it raised nothing), so `End_Job` raised `File_Write_Error`, the
  file was empty, and FLTK wrote to the closed stream (41 invalid reads at
  `Fl_PostScript.cxx:1957`). With no job, `Scale` died with
  `Storage_Error`. `Start_Job` with `Media` raised nothing, and valgrind
  can't see an overrun of static data, so that check rests on FLTK's
  source. Negative control: with both checks disabled, the same 28
  failures, 41 invalid reads and `Storage_Error`.

  A second `Start_Job` before `End_Job` leaks the first job's Cairo
  surface (FLTK-issues.md F9). It is a leak, not a memory error, and
  FLTKAda doesn't refuse it yet.

  All 29 checks pass on X11 and sway, with no invalid reads and vg=0, and
  `test_ps_errors` still passes.
- **Issue 133** (new test `test_image_reentry`): each of the four
  `Draw_Image`s raises `Draw_Error` while an image-line function runs, as
  pofltk halts on every back end. The line hooks set a flag around the
  call to the function, and clear it if the function raises. The outer
  `Draw_Image` raises the `Draw_Error` once FLTK returns, as for any
  exception from a line function (N12). Other ways into `fl_draw_image`
  from a line function, such as drawing an `RGB_Image`, aren't checked,
  as in pofltk.

  This FLTK draws with Cairo, where nesting doesn't spoil FLTK's buffer,
  so the Xlib failure itself rests on pofltk's NetBSD and plain-X11
  runs. But the binding had its own: the line function is kept in a
  variable of the package, and a nested `Draw_Image` of the same kind
  replaced it. Before the fix, 18 of 36 checks failed: nothing raised,
  and the inner function ran 29 times (its 20 lines and 9 of the outer
  image's) while the outer one ran once. That finishes FLTKAda-BUGS.md
  22, whose line length was fixed in Phase 2 (N2). Negative control:
  with the check disabled, the same 18 failures.

  All 36 checks pass on X11 and sway, with no invalid reads and vg=0, and
  `test_image_lines` and `test_exceptions` still pass.
- **Issue 134** (new test `test_gl_text_width`): the shim draws GL text
  only if `gl_width` gives it a width, as pofltk's `draw_some` does, and
  the boxed `Draw_Text` gives `fl_draw` pofltk's `draw_line` in place of
  `gl_draw_invert`, so each line is checked. The test draws a line
  feed, a carriage return, a zero-width space and a soft hyphen, alone
  and as the middle line of a box, with each of the four `Draw_Text`s.
  The window must call `Ortho` first: otherwise the raster position is
  outside the view, and FLTK draws nothing (`gl_draw.cxx:516`), which at
  first hid the crash. Before the fix, the first one crashed in FLTK on
  both X11 and sway, which GNAT reported as `Storage_Error`, and 5 of 9
  checks failed. Negative control: with the width check disabled, the
  same 5 failures. Ordinary text has a width (13 for "gl" at 14 points),
  so it is drawn as before; the test doesn't read the pixels back.
  The GLUT bitmap fonts aren't bound yet; Phase 13 needs the same check.
  (Phase 13 added it, in `fl_glut_bitmap_draw`.)

  All 9 checks pass on X11 and sway, with no invalid reads and vg=0.
- **Issue 65** (new test `test_chart_labels`): `Add`, `Insert` and
  `Replace` cut a label longer than 18 bytes before the UTF-8 character
  that would cross the 18th byte, as pofltk's `entry_label` does, so
  FLTK's `strlcpy` gets whole characters. FLTK has no way to read a
  label back, so the test draws a pie chart into an `Image_Surface` and
  compares its pixels with a chart labelled as the cut should leave it,
  for a two-, three- and four-byte character, by each of the three. A
  first check makes sure the comparison sees a label's last character.
  Before the fix, 9 of 19 checks failed: each character across the 18th
  byte, by each way in. Negative control: with the cut disabled, the
  same 9 failures.

  All 19 checks pass on X11 and sway, with no invalid reads and vg=0.
- **Issue 127** (new test `test_read_outside`): the shim clips
  `Read_Image` to the window or surface drawn on, as pofltk does, reads
  only the part inside, and puts it in its place in the result, which is
  zeros elsewhere. pofltk returns a smaller image instead, but
  `Read_Image` returns a bare array whose size its `Post` gives, so the
  rectangle keeps its size. FLTK would have stretched what it read to
  the size asked for (`fl_read_image.cxx:75`). Nothing drawn on raises
  `Draw_Error`, which also fixes FLTKAda-BUGS.md 58. `fl_capture_window`,
  pofltk's other way in, isn't bound.

  Before the fix, on X11, 5 of 10 checks failed and valgrind found 3
  invalid writes (`Fl_X11_Screen_Driver.cxx:1055-1057`). On sway, 6
  failed, with 6 invalid reads (`Fl_Wayland_Screen_Driver.cxx:1758`).
  Negative control, with the clip disabled: on sway, 5 failures and 6
  invalid reads; on X11, FLTK returned `NULL` for one of the reads, and
  `Draw_Error` ended the draw (2 failures).

  All 11 checks pass on X11 and sway, with no invalid reads and vg=0.

- **The phase-end valgrind runs** found FLTKAda-BUGS.md 59:
  `Set_Line_Style` kept its last dash pattern on the heap until exit,
  which `test_dashes` showed as a block still reachable. No FLTK driver
  keeps the pointer, so the pattern is now built on the stack. The
  per-test runs had missed it because they left out
  `--show-leak-kinds=all`, which `make valgrind` passes; a single test's
  run should pass it too.

  After the fix, `make valgrind-headless` passed. `make valgrind-sway`
  failed once, on `test_wrong_state`: 2 invalid writes and 1 invalid read
  on the thread's own stack, in Rust's crossbeam-epoch, on thread
  `gly-rayon-0` of glycin, GNOME's image loader. No FLTK or FLTKAda
  frame was on the stack. Four reruns of that test under sway valgrind,
  with `make`'s flags, were clean, so it is intermittent and outside
  FLTKAda. It is noted here, not suppressed, in case it comes back.

### Phase 6: Wrong results [done, 2026-11-04]

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

What was done. Each item has a unit test, run on Xvfb and on a headless
sway, and under valgrind. Each test was seen to fail before its fix.

- **Issue 2** (new test `test_clip_box`): the shim zeroes `Clip_Box`'s
  outputs, makes an empty result 0 by 0, and returns whether the result
  differs from the box. FLTK 1.4.5 here is built with
  `FLTK_USE_CAIRO`, so windows on X11 draw with Cairo too; its
  `clip_box` (`Fl_Cairo_Graphics_Driver.cxx:693-726`) compares the box
  with the clip, and returns at `W < 0` before setting `H`. Xlib's
  (`Fl_Xlib_Graphics_Driver_rect.cxx:352-383`) is right, and gives
  `W = H = 0` for a box outside, which the shim's result matches. The
  test runs 7 boxes against a clip of (10, 10, 50, 50), on an image
  surface and in a window's `Draw`. Before the fix, 6 of 16 checks
  failed on X11 and on sway: a box inside said "changed", one around
  the clip didn't, and one outside left `H` at 50, from the stack.
  Negative control, zeroing the outputs but returning FLTK's result:
  the 4 "changed" checks failed. All 16 pass on X11 and sway, with
  vg=0.
- **Issue 8** (new test `test_defined_types`): the shim's
  `fl_define_box_and_label_types` calls pofltk's 14 `fl_define_FL_*`
  functions (`ofl_register`, `src/Fl.cpp:253-269`): 11 box families and
  the shadow, engraved and embossed labels. The plan said "on first use
  of a box or label setter"; it is done in `FLTK`'s elaboration
  instead, since the functions only fill tables
  (`fl_internal_boxtype`, `fl_boxtype.cxx:424-430`;
  `Fl::set_labeltype`, `fl_labeltype.cxx:75-78`) and need no display,
  and a kind can reach FLTK through more than one setter. Multi, Icon
  and Image labels are left undefined. Defined, FLTK casts the label
  text to an `Fl_Multi_Label`, `Fl_File_Icon` or `Fl_Image` pointer
  (`Fl_Multi_Label.cxx:28`, `Fl_File_Icon.cxx:425`, `Fl_Image.cxx:224`);
  undefined, they draw as `fl_no_label` (`fl_labeltype.cxx:58-69`).
  The test captures one box of each family and each label with
  `Probe.Capture`, and compares it with its stand-in. Before the fix all
  14 drew the same as their stand-in, on X11 and on sway. Negative
  control, without the GTK+ and embossed defines: exactly those 2
  checks failed. All 16 pass on X11 and sway, with vg=0. `bin/hello`'s
  shadow label, screenshot under Xvfb, shows its shadow.
- **Issue 26** (new test `test_menu_chosen`): the shim's `Keep_Chosen`,
  pofltk's `KeepValue`, notes the chosen item's text before `add`,
  `insert`, `remove` and `clear_submenu`, and finds it again after
  (through `Fl_Choice::value` for a choice, for its redraw). It is
  declared before `Item_Names`, so it is destroyed after the names are
  swapped back. `add` is covered too, since it calls `insert (-1, ...)`
  (`Fl_Menu_add.cxx:348-350`), which puts a path's item at the end of
  its submenu, before later items; FLTK keeps only the chosen item's
  offset (`Fl_Menu_add.cxx:419-423`). The test inserts and removes
  around a choice's value, 40 times over so the array grows, removes
  the value, and adds to and clears a submenu before it. Before the
  fix, 7 of 11 checks failed on X11 and sway; after 40 removes the
  offset lay past the array's end, and `Chosen_Index` read 0
  (`Fl_Menu_.cxx:366-369`). Negative control, without it in `remove`
  and `clear_submenu`: those 4 checks failed. All pass on X11 and sway,
  with vg=0.
- **Issue 38** (new test `test_browser_top`): the shim's
  `browser_update_top` calls the protected `find_item (0)`, which runs
  the private `update_top` first (`Fl_Browser_.cxx:582-583`), as
  pofltk's `Top::update` does. It is called before `topline`,
  `Fl_Browser::displayed`, `Fl_Browser_::displayed` and `top`, which
  FLTKAda makes public (`Top_Item`). Clicks need nothing, as pofltk
  says. The test checks a never-drawn browser's top line, its top item
  and what it shows, as new, after `Set_Top_Line (20)` and after
  `Make_Visible (40)`. Before the fix, `Get_Top_Line` raised
  Constraint_Error at once, on X11 and on sway: FLTK's `topline` was 0,
  and `Get_Top_Line` returned `Positive`. That is FLTKAda-BUGS.md 60:
  an empty browser's top line is 0 even with the fix, so
  `Get_Top_Line` now returns `Natural`, and the test checks an empty
  browser. Negative control, with `browser_update_top` doing nothing:
  8 of the 10 issue-38 checks failed (the two "doesn't show" checks
  pass when nothing shows). All 11 pass on X11 and sway, with vg=0.
- **Issue 45** (new test `test_pnm_maxval`): the shim's
  `pnm_scale_samples`, after `new Fl_PNM_Image`, reads the header again
  the way FLTK's constructor does (`Fl_PNM_Image.cxx:85-125`), and for
  a P5 or P6 with a maxval from 1 to 254 scales each sample by
  `255 * val / maxval`, clamped to 255, then uncaches. pofltk's
  `scale_pnm` does the same, without the clamp. FLTK's `fread` of these
  forms is at `Fl_PNM_Image.cxx:178-187`; the text forms are scaled
  there already, and the test checks a P3 isn't scaled twice. A shared
  image doesn't go through FLTKAda's constructor:
  `fl_register_images`' handler `fl_check_images` makes the
  `Fl_PNM_Image` (`fl_images_core.cxx:105-107`). So FLTKAda adds its
  own handler for P5 and P6, at elaboration, ahead of `fl_check_images`
  whoever calls `fl_register_images` first (FLTK does, in
  `Fl_Help_Dialog.cxx:207` and `Fl_File_Icon2.cxx:651`), since
  `Fl_Shared_Image::reload` tries handlers in the order they were added
  (`Fl_Shared_Image.cxx:297-304`). It does nothing until
  `Fl_Image::register_images_done` is set (`fl_images_core.cxx:63`), so
  a PNM still needs `Register_Images`, as before. pofltk has its own
  pool instead (`src/FlImages.cpp:765-800`). The files: pofltk's
  `rb.ppm` (P6, maxval 1), and new `levels.pgm` (P5, maxval 3, with a
  sample of 5) and `text.ppm` (P3, maxval 3). Before the fix, 3 of 6
  checks failed on X11 and sway: rb.ppm read as 1, 0, 0, levels.pgm as
  0 1 2 3 5, and the shared rb.ppm drew 16#010000#. Negative controls:
  without the handler, the shared check failed; without the scaling in
  the constructor and the `register_images_done` test, the two file
  checks and the "needs Register_Images" check failed. All 6 pass on
  X11 and sway, with vg=0. Not tested: a file cut short, whose unread
  samples FLTK leaves uninitialized and the scaling then reads.
- **Issue 57** (new test `test_parse_args`): the shim's
  `fl_static_args2` decides from the word `Fl::args` stopped at, as
  pofltk's `ofl_args` does: an option (a word starting with `-`, not `-`
  alone, not `--...`, Fl::arg's own test at `Fl_arg.cxx:141`) means
  unknown or missing its value, and `Parse_Args` raises Argument_Error.
  `Fl::args`' own result is wrong once `return_i` is set
  (`Fl_arg.cxx:141`, 281). The arguments are the process's own, so the
  test, run with none, runs itself with `-o rest` (parsed with a handler
  that takes `-o`, which stops at `rest`, then without it), with
  `-bogus` and with `-title Hello`, and passes on their exit statuses.
  Before the fix, `-o` unknown in the second call raised nothing, on
  X11 and sway. `make valgrind` doesn't trace the children, so each was
  run under valgrind by hand, which found FLTKAda-BUGS.md 61 (FLTK reads
  `argv[argc]`, which FLTKAda's argv didn't have) and, reading what
  `show (argc, argv)` does with the argv, 62 (a shown window's `-title`
  label pointed into an argv freed after the show; with 8 strings of its
  size made after, it read "World"). Now one argv, ending in a null,
  lasts the program's life. Negative control, `Parse_Arg` without its
  new range check: its check failed. All pass on X11 and sway, and each
  of the four runs has vg=0 on both. The two-argument `Parse_Args` is
  FLTK's `Fl::args (argc, argv)`, which prints the help for any word
  that stops it (`Fl_arg.cxx:365-367`), as documented; it is left as
  is.
- **Issue 60** (new test `test_chart_maxsize`): `Set_Maximum_Size (0)`
  sets the private `maxnumb` to 0 alone, reached through pofltk's
  `Reach` explicit instantiation (as `c_fl_tree.cpp` reaches
  `_lastselect`); other sizes still go through `maxsize`
  (`Fl_Chart.cxx:479-492`), which drops the oldest entries. Before the
  fix, 3 of 7 checks failed: the 3 entries were gone after the limit
  went back to 0, and the two checks of the size after them failed with
  them.
  The fix is one branch, so that run is its control. Passes on X11 and
  sway, with vg=0.
- **Issue 64** (new test `test_anim_copy`): FLTK's `copy` starts the
  copy when the original has a frame (`Fl_Anim_GIF_Image.cxx:764-765`),
  and `start` moves it on a frame (`next_frame`). The shim's copies
  stop a copy of a stopped animation and set it back to the original's
  frame. The test copies, sized and whole, an animation never started,
  one playing and one stopped after `Next`. Before the fix, 8 of 13
  checks failed: the copies of both stopped ones played, on another frame.
  Negative control, without setting the frame back: the 4 frame checks
  failed. Passes on X11 and sway, with vg=0.
- **Issue 76** (new test `test_clock_time`): the shim's `Set_Time` calls
  `value (v)` twice, as pofltk does. The first stores the seconds past
  midnight once the hands move (`Fl_Clock.cxx:125-146`); the second
  finds the hands there, and keeps `v`. Before the fix, 2 of 3 checks
  failed, the two whose hands moved; setting a time twice already read
  back. The fix is one call, so that run is its control. A running
  clock's `tick` (`:209-220`) calls `value` once a second, and isn't
  changed; the spec says so. Passes on X11 and sway, with vg=0.
- **Issue 83** (new test `test_shared_reload`): after `reload`, an
  entry not the original whose data size changed gets a copy of the
  reloaded image at its old size, put in through the protected
  `image_`, `alloc_image_` and `update`, named through a derived class
  (`Shared_Inside`). pofltk keeps its own pool; FLTKAda uses FLTK's, so
  it mends the entry instead. The test gets `rb.png` at 8 by 4 and 20
  by 10, reloads each, and finds both after each reload, and checks the
  reloaded entry draws the same two corner pixels. Before the fix, 3 of
  7 checks failed: each entry reloaded was no longer found, and after
  both, neither. Negative control, the copy made and dropped: the same
  3 failed. Passes on X11 and sway, with vg=0.
- **Issue 94** (new test `test_filename_relative`): `Relative`'s
  `Changed` is whether the result differs from the name, as pofltk's
  is, since FLTK returns 0 for the current directory, which it makes
  `.` (`filename_absolute.cxx:248-252`). Before the fix, 1 of 6 checks
  failed, `Changed` for the current directory. The fix is one line, so
  that run is its control. The spec says FLTK looks only at the text,
  from pofltk 94; that part was not tested here. Passes on X11 and
  sway, with vg=0.
- **N7, issue 6** (FLTKAda-BUGS.md 63; new test `test_window_label`):
  `Set_Label (This, Kind, Text)` now dispatches, so a window gets
  `Fl_Window::copy_label`, which sets the title too
  (`Fl_Window.cxx:159-162`). The test reads the title with a new probe,
  `FLTK.Probe.X11_Title`, which calls `XFetchName` through `dlsym`, so
  the probe needs no X11 library at link time; the probe is X11's,
  so on Wayland the test skips. Before
  the fix, 2 of 5 checks failed: the title stayed "Plain". The fix is
  one change, so that run is its control. Passes on X11, with vg=0 on
  both.
- **Issue 13** (FLTKAda-BUGS.md 27, now fixed; new test
  `test_spinner_colors`): `Spinner` overrides `Set_Colors`, which set
  the group's colors and not its field's (`Fl_Spinner.H:179-196`).
  `Set_Format` refuses a format that `snprintf` can't take with what
  `Fl_Spinner::update` passes, a double, or an int and then a double
  for a leading `%.*` (`Fl_Spinner.cxx:79-91`). It raises
  `Constraint_Error` and keeps the format before. The rules, in the
  spec: at most one conversion, `a A e E f F g G`, no length but `l`,
  `*` only as the leading `%.*`, width and precision at most 3 digits,
  and `%%`. The digit limit is FLTKAda's choice, to keep `snprintf`
  from huge widths; it is not FLTK's. Before the fix, 20 of 36 checks
  failed, and `%n` aborted the program from glibc's fortify check; that
  run is the control. Passes on X11 and sway, with vg=0.
  `test_spinner_format`'s formats are still taken.
- **Issue 128** (new test `test_restore_clip`): documented, not fixed.
  Cairo's `push_clip` keeps the clip in `clip_` and a `cairo_save`
  (`Fl_Cairo_Graphics_Driver.cxx:583-594`), and `restore_clip` resets
  Cairo's clip and applies only `rstack` (`:1456-1485`). Working
  around it would mean reaching the driver's private `Clip` chain, and
  the driver's header isn't installed. An Ada program has no use for
  `Restore_Clip`, which is for code that changes the native clip behind
  FLTK's back. It stays, for compatibility, and the spec and
  `doc/fl_draw.html` say to use `Push_Clip` and `Pop_Clip`. This FLTK
  is built with `FLTK_USE_CAIRO`, so X11 draws with Cairo too. The test
  draws into a capture, clipped to 20 by 20. Pushed, and pushed again
  after `Restore_Clip` and a pop, the outside stays white; after
  `Restore_Clip` it is red, on X11 and on sway. The test checks that,
  and skips where FLTK doesn't draw with Cairo, so a change in FLTK
  fails it. A new probe, `Uses_Cairo`, gives `FLTK_USE_CAIRO`, since
  `Has_Cairo` is `FLTK_HAVE_CAIRO`. vg=0 on both.
- **Tooltip text** (FLTKAda-BUGS.md 64; `test_kept_strings`, made
  deterministic): found by `make valgrind-sway`, not a pofltk issue.
  The shim freed the text FLTK held when the tooltip window's hide, in
  `enter_area`, cleared `widget_` (`Fl_Tooltip.cxx:252, 301, 305`,
  `Fl.cxx:1215-1217`; seen in gdb). It now decides with
  `Fl_Tooltip::enabled ()`. The test sets the hover delay to 0 so the
  timeout that reads the text runs; with the old shim it failed
  valgrind 6 runs of 6 on X11 and sway, and with the fix it passes 6
  of 6.

### Phase 7: Documentation-only pitfalls and portability [done, 2026-11-04]

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

What was done. Every spec comment has its `doc/*.html` note. Where a
test could show the behaviour without opening the user's browser or
waiting on an alert, there is one, run on Xvfb and on a headless sway,
and under valgrind. Each fix's test was seen to fail before it.

- **Issue 10** (new test `test_changed_callback`): documented. FLTK
  clears `changed` after a callback unless it is
  `Fl_Widget::default_callback` (`Fl_Widget.cxx:385-386`). The spec of
  `Has_Changed` says so, and that `Do_Callback` calls the Ada callback
  without clearing it. The test clicks a check button with a callback,
  which sees `changed` and finds it cleared after; one with no callback
  keeps it, and `Do_Callback` clears nothing. Passes on X11 and sway.
- **Issue 40** (new test `test_browser_load`): documented. The test
  writes its own directory. A `Textline_Browser` loading "a\nb\n" has 3
  lines, the last empty; `Load ("")` empties it and raises nothing.
  `File_Browser.Load` returns the directory's entries, 6 with `./` and
  `../`, while the `*.txt` filter lists 4 lines
  (`Fl_File_Browser.cxx:442-474`). New: the byte after each 1023 of a
  long line is dropped (FLTK-issues.md F10). Passes on X11 and sway.
- **Issue 43** (`test_tree_remove`, extended): documented. After
  `Clear`, `Root` is null (`Fl_Tree.cxx:934-940`), and `Add` makes a
  new root. The spec of `Clear` and `Root` says so.
- **Issue 44**: documented, from the source alone, since a window
  manager's icon can't be read back on Wayland. `Fl_Window_Driver::icons`
  is empty (`Fl_Window_Driver.H:181`); the X11, Windows and macOS
  drivers override it, Wayland's doesn't. The spec before `Set_Icon`
  says so.
- **Issue 47** (new test `test_xpm_color_names`): documented. An XPM
  with "red" and "#0000ff" draws red and blue on X11, and FLTK's gray
  (16#C0C0C0#) and blue on sway (`Fl_Screen_Driver.cxx:625-646`). The
  pixmap specs say to use `#rrggbb`.
- **Issue 50** (new test `test_selection_buffer`): documented. Pasting
  the selection buffer gives what was copied to it on X11, and nothing
  on sway (`fl_wayland_clipboard_dnd.cxx:617-618, 659-686`); the
  clipboard works on both. The spec of `Copy` says so.
- **Issue 79** (new test `test_menu_add_merge`): documented, and pofltk
  79 corrected. Adding a label already in the menu, `&` aside, returns
  the same item and gives it the new flags; a hidden item is added
  again. But a hidden *first* item is found: `Fl_Menu_Item::insert`
  compares the first item before it calls `next()`
  (`Fl_Menu_add.cxx:173-174, 189-190, 203-206`), and the test checks
  both. Writing the test found FLTKAda-BUGS.md 65: the one-string
  `Add`, FLTK's `add (const char *)`, couldn't be called. Decided by
  the user: it is renamed `Add_Items` (new test `test_menu_add_items`),
  rather than dropping the defaults of the other `Add`. Its test found
  FLTK-issues.md F11.
- **Issue 93** (new test `test_help_dialog_group`): the shim keeps
  `Fl_Group::current()` around `new Fl_Help_Dialog`, whose window
  leaves none (`Fl_Window.cxx:82`, `Fl_Help_Dialog.cxx:198`). Both
  `Forge.Create`s go through it. Before the fix both checks failed: no
  current group, and the box made after it in no group. The spec of
  `Help_View.Load` and `Help_Dialog.Load` says a URL opens the user's
  browser (`Fl_Help_View.cxx:3353-3361`); not tested, since the test
  would open one.
- **Issue 102**: documented, from the source. FLTKAda binds no PDF or
  EPS surface (until Phase 11, which see), so of pofltk's cases only
  `Fl_PostScript_File_Device::end_job`'s alert applies, given when
  `close_cmd_` is null (`Fl_PostScript.cxx:1980-1983`). For a job given
  a `File_Type` the binding's stream reports the write error itself
  (Phase 5, pofltk 101), and the shim never sets a close command. The
  spec of `End_Job` says which errors are still reported only by the
  alert.
- **Issue 113** (new test `test_gl_window_group`): documented. The
  plan's first half doesn't arise in FLTKAda: every group's `Forge`
  already ends the group (`Extra_Init`, `fltk-widgets-groups.adb`), so a
  `Window` and a `GL_Window` made inside `Begin_Current` both leave the
  outer window current. The test checks both. Under Wayland a
  single-buffered `Set_Mode` reads back `Double`, on X11 it doesn't
  (`Fl_Wayland_Gl_Window_Driver.cxx:37, 113, 301`). The spec of
  `Get_Mode` says so.
- **Issue 114** (new test `test_cairo_support`): `Cairo_Window` has
  `Is_Supported`, from `FLTK_HAVE_CAIRO` in the shim, and
  `Set_Cairo_Draw` raises `Unsupported_Error` without Cairo, since its
  callback would never be called (`Fl_Cairo_Window.H:26`). The
  save/restore note was already in the spec, and is now in
  `doc/fl_cairo_window.html`.
- **Issue 132**: documented, from the source. Nothing in FLTK 1.4.5
  sends `FL_SELECTIONCLEAR`; its one mention is a comment
  (`Fl.cxx:1630`). The comment on `Selection_Clear` in `Event_Kind` and
  the spec of `Selection` say so.
- **Issue 73** (new test `test_svg_support`): the shim names
  `Fl_SVG_Image` only `#ifdef FLTK_USE_SVG` (from `fl_config.h`, as
  `Fl_SVG_Image.cxx:19` tests it). Without it `SVG.Is_Supported` is
  False and each `Create` raises `Unsupported_Error`.
- **Issue 104** (new test `test_print_support`): the plan's guard on
  `FL_NO_PRINT_SUPPORT` was impossible: that macro is set only in
  `config.h`, which FLTK doesn't install. The shim names
  `Fl_PostScript_File_Device::file_chooser_title` with a weak
  reference instead, as pofltk does, and its address says whether this
  FLTK prints (`Fl_PostScript.cxx:18, 49`). `Postscript.Is_Supported`
  gives that; without it `Get_File_Chooser_Title` gives "" and
  `Set_File_Chooser_Title` raises `Unsupported_Error`. Such an FLTK's
  `Fl_Printer` strings are all null (`Fl_Printer.cxx:21, 49-67`), which
  the shim now gives as "". A scratch C++ program built with and
  without libfltk showed the weak address null without.
- **Controls for 73, 104 and 114.** This FLTK has SVG, printing and
  Cairo, so a run here checks only the supported case. The other was
  checked by putting in front of the shim's `fl_svg_image_available`,
  `fl_postscript_file_device_supported` or `fl_cairo_window_supported`
  one that gives 0, with `LD_PRELOAD`: each `Create`, the title setter
  and `Set_Cairo_Draw` raised `Unsupported_Error`, and the checks that
  this FLTK has the feature failed.

### Phase 8: Core statics [done, 2026-11-04]

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

What was done. Each item has a unit test, run on Xvfb and on a headless
sway, and under valgrind on both.

- **Shutdown, timestamps, colour, boxes and menus, callback reasons,
  selections, schemes and scaling** (new test `test_statics_core`, from
  pofltk's `TestStatics`). All in `FLTK.Static`, except scaling, in
  `FLTK.Screen`, and `Contrast`, `Lightness`, `Luminance`,
  `Contrast_Mode` and `Callback_Reason`, in `FLTK`.
  - `Timestamp` is private: `Fl_Timestamp` isn't the time of day
    (`Fl_Timeout.cxx`), so neither `Ada.Calendar` nor `Ada.Real_Time`
    fits. `Seconds_Since` a moment still to come is negative.
  - `set_abort` is the existing `FLTK.Errors.Current_Fatal`.
    `set_atclose` is `Set_Window_Close_Handler`.
  - An exception from a check, an idle handler, a contrast function or
    the close handler is raised again from `Run_Checks`, `Run_Idle` or
    the next event loop call, as the Phase 2 hooks are.
  - `Callback_Reason` is an integer type with named constants, since
    FLTK passes any value from `FL_REASON_USER` up.
  - `Add_Scheme_Name` raises `Constraint_Error` for a name FLTK would
    refuse (`Fl_Scheme.cxx:106-153`), and returns False for one already
    there.
  - `Set_Keyboard_Scaling (True)` works only if it was on when the
    display opened (`Fl_Screen_Driver.cxx:478, 611-614`); the spec says
    so.
  - Found FLTK-issues.md F12: Custom contrast with no function uses
    CIELAB at Custom's level, 0, and so returns Fore.
- **`set_abort`** (new test `test_fatal_handler`): found FLTKAda-BUGS.md
  66, a fatal handler that returned let FLTK go on and crash
  (`Fl_x.cxx:550-551`). The program now ends with status 1 when it
  returns, and a handler may raise instead.
- **Clipboard images, issue 48: AFFECTED on Wayland, done** (new test
  `test_paste_image`). `FLTK.Static.Paste_Image` asks for the image;
  the Paste event's `Handle` checks `FLTK.Events.Has_Clipboard_Image`
  and takes it with `FLTK.Images.RGB.Forge.Pasted`, which raises if
  there is none. When the outermost Paste `Handle` returns, the shim
  deletes an image not taken and clears FLTK's pointer. FLTK reads
  `Fl::e_clipboard_data` after `handle` returns on every path, and
  deletes it on all but the Wayland one for the program's own image
  (`Fl_x.cxx:707-711, 1501-1505`; `fl_wayland_clipboard_dnd.cxx:620-629,
  648-654`), so clearing it there is safe. A negative control, with the
  delete taken out: valgrind on sway reported the image leaked
  (`own_bmp_to_RGB`), and on X11 nothing, since FLTK deleted it. The
  test found FLTKAda-BUGS.md 67, `Clipboard_Text` always "" or an
  image read as text, and FLTK-issues.md F13, pasting the program's own
  text leaves `Fl::event_clipboard_type` as it was; `Clipboard_Kind`
  now says "text/plain" for it.
- **`FLTK.Draw`** (new test `test_draw_shapes`): `Rounded_Rect`,
  `Rounded_Rect_Fill`, `Draw_Check`, `Draw_Radio`, `Draw_Arrow` (with
  `Arrow_Kind` and `Orientation_Kind`, in `gen-constants.py`),
  `Focus_Rect`, `Frame2`, `Draw_Box_Focus`, `Load_Identity`,
  `Load_Matrix`, `Get_Antialias`/`Set_Antialias` and
  `Override_Scale`/`Restore_Scale`. Each shape is drawn by a box's
  `Draw`, captured, and checked pixel by pixel; `Frame2`'s check tells
  its side order (bottom, right, top, left, `fl_boxtype.cxx:136`) from
  `Frame`'s. `fl_draw_box_focus` draws only when `Fl::visible_focus()`
  is on (`fl_boxtype.cxx:483-484`), its default unless the user's FLTK
  options turn it off (`Fl.cxx:2060, 2090`), so the test turns it on.
  - **Issue 124: AFFECTED, done**, for antialias and, newly found, the
    scale overrides. A scratch C++ program with no window current
    crashed in `fl_antialias` (get and set) on X11 and sway, and in
    `fl_override_scale` when the screen's scale isn't 1: the Cairo
    driver's `cairo_` is null (`Fl_Cairo_Graphics_Driver.cxx:1493-1518`).
    At scale 1 `override_scale` didn't crash, nor did `load_identity`
    or `load_matrix`. The four calls use the issue 124 guard and raise
    `Program_Error` with nothing to draw on. The test checks that at
    scale 2, before any window is shown. A negative control, with the
    guards taken out: all four crashed on both back ends.
  - The same program crashed for every other drawing call with no
    window, `fl_rectf` included. As before, FLTKAda guards only the
    state calls, as pofltk does; drawing outside `Draw` or a surface is
    the program's mistake.
- **`Fl_Widget_Tracker`**, as `FLTK.Widget_Trackers` (new test
  `test_widget_trackers`, from pofltk's `TestTracker`). The §7.2 note
  was wrong to dismiss it, as pofltk's `Trackers` example shows: a
  callback that may free its own widget, or a call that may free a
  widget it was given, can't tell otherwise. The shim keeps the C++
  tracker on the heap, since FLTK watches the address of its pointer
  (`Fl.cxx:2157-2171`). FLTK clears a tracker in `~Fl_Widget`
  (`Fl_Widget.cxx:167`), but a widget freed in a callback is deleted
  only later (`Fl::delete_widget`), and its Ada object is gone at once.
  So `fl_widget_forget` now calls `Fl::clear_widget_pointer`, and a
  tracker says the widget is deleted as soon as its Ada object is
  finalized. FLTK's own trackers, such as the one in
  `Fl_Widget::do_callback` (`Fl_Widget.cxx:382-384`), then stop using
  the widget at once too. A negative control, without the clear: the
  check of a widget freed in a timeout inside `Wait` failed on both
  back ends. `Item` returns the Ada object the tracker was given, or
  null. The test found
  FLTKAda-BUGS.md 68: finalizing a widget declared without
  `Forge.Create` read through a null pointer.

### Phase 9: Offscreens, capture, and UTF-8 [done, 2026-11-04]

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

Decisions and findings:

- **The offscreen package is `FLTK.Draw.Offscreens`,** with the type
  `Offscreen`, since `FLTK.Draw.Offscreen` would name the package and
  the type alike. It is built on a high-resolution `Image_Surface`, as
  FLTK's `fl_create_offscreen` is (`Fl_Image_Surface.cxx:302-361`).
  `Begin_Drawing` and `End_Drawing` push and pop it. Beginning it twice,
  ending it when it isn't the surface drawn on, and `Rescale` while
  begun raise Program_Error. `Copy` raises only when the offscreen is
  itself the surface drawn on: that is the one case Cairo leaves
  undefined, and copying a begun offscreen buried under another is
  fine. Test: `test_offscreens`.
- **Surfaces freed while current or pushed** (FLTK-issues.md F15,
  FLTKAda-BUGS.md 70). Every surface's `Finalize` calls
  `Release_Current`. A surface that is current from a `Push_Current` is
  popped, and the original surface is made current if it still is. One
  buried under another can't be taken out of FLTK's stack, so the stack
  keeps a stand-in that owns the FLTK object, and the stand-in and the
  object are freed once the stack forgets it, the next time a surface
  is made current or popped. The test draws on such a stand-in after
  the Ada object is gone, then pops it.
- **`Image_Surface.Rescale` and `Mask`.** `Rescale` raises
  Program_Error while the surface is current or pushed (F16). The shim
  keeps the mask state in its `My_Image_Surface` subclass, cleared by
  `image()`, so the state lives with the FLTK object.
- **Capture returns the clipped part.** `Capture_Window` returns an
  image of the part of the rectangle inside the window. Unlike
  `Read_Image`, it returns an `RGB_Image`, which carries its own size, so
  pofltk's smaller result fits. Nothing inside, a hidden window, or one
  never made raises `Draw_Error`.
- **UTF-8 scope.** `FLTK.UTF8` binds `fl_nonspacing`, `fl_wcwidth_`,
  `fl_utf8test`, FLTK's case-folding of characters and strings,
  `fl_utf_strcasecmp`/`strncasecmp`, `fl_utf8locale`,
  `fl_utf8to_mb`/`fl_utf8from_mb`, and also
  `fl_utf8_next_composed_char`/`previous_composed_char`, which Ada
  lacks and which issue 115 is about. What `Ada.Strings.UTF_Encoding`
  and `Ada.Wide_Wide_Characters.Handling` do (encode, decode, length,
  `fl_utf8toa`/`froma`, `fl_utf8toUtf16`, …) isn't bound, and the spec
  says so. Test: `test_utf8`, which also runs in the C locale.

Verdicts:

- **Issue 115:** FIXED. The shim passes a copy with 16 zero bytes on each
  side, and keeps what comes back within the text. A lone `F0` steps to
  the end, "a" and a joiner gives the end, and `Previous_Composed` at
  the start or of a selector at the start gives the start. An index
  outside `Text'First .. Text'Last + 1` raises Constraint_Error.
  `fl_utf8strlen` isn't bound.
- **Issue 116:** FIXED. The shim gives the case functions a buffer of
  `4n + 4` and writes the terminator. pofltk says a bad byte becomes
  U+FFFD. That isn't so in FLTK's default build: `fl_utf8decode` reads
  0x80–0x9F as CP1252 (`ERRORS_TO_CP1252`, `fl_utf8.cxx:667`) and other
  bad bytes as Latin-1 (`ERRORS_TO_ISO8859_1`, 657). Both are up to 3
  bytes, as `test_utf8` shows: 2000 bytes of 0x80 uppercase to 6000,
  each U+20AC, and a lone 0xC9 lowercases to é.
- **Issue 117:** NOT BOUND. `fl_utf8toa` is Latin-1, which
  `Ada.Strings.UTF_Encoding` covers.
- **Issue 118:** FIXED. The shim asks each function for the size first,
  gives it a buffer of that, and in a non-UTF-8 locale measures
  `fl_utf8from_mb`'s result itself. `test_utf8` converts 2000 bytes each
  way, in the user's locale and in the C locale. `Is_UTF8_Locale`'s
  comment gives `fl_utf8locale`'s rule and its cache
  (`Fl_Unix_System_Driver.cxx:680-692`).
- **Issue 127,** the `fl_capture_window` half: FIXED, as above.
  `test_offscreens` captures a window partly outside on each side, with
  `Integer'Last` sizes, and five rectangles wholly outside.
- **Issue 137:** FIXED. `Mask` raises `FLTK.Unsupported_Error` for a mask
  that isn't depth 3, and Program_Error on a surface that is current, or
  masked with no `Get_Image` since. A mask set and not used is freed
  with the surface. `test_offscreens` checks the pixels of a mask and of
  an inverted one.
- **New:** FLTK-issues.md F14–F16, and FLTKAda-BUGS.md 69 and 70.
- **Results:** `test_offscreens` and `test_utf8` pass on X11 and sway,
  with no invalid reads, and `vg-check.sh` passes on both.

### Phase 10: Widgets and images [done, 2026-11-04]

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

Decisions and findings:

- **ICO files are read whole and decoded as data,** so that a file and
  the same bytes in memory load alike. The shim decodes a PNG entry from
  its offset itself, since `Fl_ICO_Image` reads one by its file's name
  (issue 82). `ICO_Count` and `Entries` read the directory. Test:
  `test_ico_image`.
- **Image handlers.** `Fl_Shared_Image::add_handler` takes a function
  with no data, and FLTK deletes the image a handler returns along with
  the pool's entry. So FLTK is given one handler, which asks the Ada
  list in order. The pool gets a copy at the image's size, and the
  handler keeps its own image. An exception a handler raises is raised
  again by the load that asked it. `Pool_Images` returns a plain array,
  each element with a reference of its own. Test: `test_image_handlers`.
- **`Write_PNG`** is in `FLTK.Images.RGB.PNG`. It raises No_Image_Error
  for an image with no pixels (F17), File_Access_Error for a file it
  can't open, and Unsupported_Error without libpng. `RGB_Image` now
  refuses a bad depth or line size (FLTKAda-BUGS.md 71).
  `Get_Data_W`/`Get_Data_H` are on `Image`. Test: `test_write_png`.
- **Shortcuts read back.** `Shortcut_Button` showed that no shortcut with
  a key could be read back from any widget (FLTKAda-BUGS.md 72). Test:
  `test_shortcut_button`.
- **Pointer labels.** A multi-label, a file icon and an image label are
  pointers in FLTK's `label`. The shim refuses to give text one of their
  kinds, `Get_Label` is "" for one, and `Set_Label` makes the label
  plain text first (FLTKAda-BUGS.md 73). `Set_Multi_Label` and
  `Set_Icon_Label` are not primitives of `Widget`. They live in
  `FLTK.Multi_Labels` and `FLTK.Images.File_Icons`. Test:
  `test_widget_multi_label`.
- **File icons.**
  - `Load` goes through `FLTK.Images.Shared`, as FLTK's own `load_image`
    does, where pofltk used a loader of its own. So BMP, GIF, ICO and SVG
    load only after `Register_Images`, and XPM and XBM load without it,
    as `test_file_icons` checks.
  - An SVG has no pixels until it is drawn or normalized
    (`Fl_SVG_Image.cxx:411-413`). Before `Load` normalized it, the shim
    read through a null array. A scratch C++ program under Xvfb showed
    the null array.
  - A file browser shows an icon only as the line's data, so `Add_File`,
    `Set_File_Icon` and `Get_File_Icon` take a `File_Browser`. The icon
    is not copied, so it must outlive the widgets and browsers that show
    it, as the spec says.
  - `Measure_Label` gave FLTK an uninitialized wrap width
    (FLTKAda-BUGS.md 74), found by the icon label's measure check.
  - Test: `test_file_icons`.

Verdicts:

- **Issue 55:** FIXED. `Set_Multi_Label` clears the copied label first,
  so FLTK never frees the multi-label. Without that, the negative control
  gave a mismatched free (`Fl_Widget.cxx:294`) and an invalid free.
- **Issue 82:** CONFIRMED and WORKED AROUND. The same bytes that load
  from the file give `fail()` -2 from memory in FLTK. `ICO_Image`
  decodes them, as above.
- **Issue 85:** FIXED. `Set_Icon_Label` sets the icon through the shim's
  label guards, so text replaces it as a `Normal_Label`, and
  `Set_Label_Kind` can't make FLTK read the text as an icon. The icon
  label measures as the icon: without `measure_icon`, the check that it
  measures as none fails.
- **Issue 86:** FIXED. A bad `.fti` leaves the icon empty and raises
  Format_Error. A file that can't be read raises File_Access_Error. An
  image with no pixels, an animated GIF without frames and an SVG before
  normalizing are refused or normalized in the shim, so FLTK never reads
  a null array.
- **Issue 87,** for the new `ICO_Image`: REFUSED, as Phase 5 refused
  it for BMP. A bitmap entry that FLTK would read past, like
  `colors.ico`, raises Format_Error from a file and from memory. The
  shim checks the entry's header before FLTK decodes it.
- **Issue 95:** FIXED, as above. A handler may remove itself, a handler
  added twice is asked once, and the header it is shown is at most
  `Max_Header` bytes.
- **New:** FLTK-issues.md F17, and FLTKAda-BUGS.md 71 to 74.
- **Results:** `test_shortcut_button`, `test_ico_image`,
  `test_image_handlers`, `test_write_png`, `test_widget_multi_label` and
  `test_file_icons` pass on X11 and sway. Valgrind finds no errors.

### Phase 11: File surfaces [done, 2026-11-04]

`FLTK.Devices.Surface.EPS`, `…Paged.PDF` and `…SVG`, with the choice
binding_architecture.md §7.3 already discusses (the `Widget_Surface`
wrinkle).

- Issue 102 applies to PDF: `end_job` reports errors only with an alert.
  Return an error status, and never alert.
- Port pofltk's `SaveAs` example, which writes PostScript, EPS, PDF and
  SVG.

Decisions and findings:

- **The `Widget_Surface` wrinkle:** option 1 of §7.3. `EPS` and `SVG`
  are children of `FLTK.Devices.Surface`, as `Copy` and `Image` are, and
  `PDF` is a child of `Paged`, since `Fl_PDF_File_Surface` is an
  `Fl_Paged_Device`. No `Widget_Surface` package: nothing it would hold
  is shared beyond what each already has.
- **Paged devices on FLTKAda's stack of surfaces** (FLTKAda-BUGS.md 75).
  `begin_page` pushes the device and `end_page` pops whatever is on top,
  for PostScript, printers and PDF alike. `Start_Page` and `End_Page`
  now keep FLTKAda's record of the stack in step, and refuse a page in
  a page and an end outside one. Found while designing the PDF surface.
- **A file of FLTKAda's.** EPS and SVG write through a `File_Sink`
  (`body/c_fl_file_sink.cpp`), the shim's own stream with a close
  function, so a failed write is a status and not FLTK's alert. EPS's
  destructor, which alerts (`Fl_PostScript.cxx:2051-2058`), never closes
  the file: `Finish` and `Finalize` call `close()` first.
- **PDF writes through a FIFO.** `Fl_PDF_File_Surface` opens its file
  itself, by name, and `end_job` reports a failed write only with
  `fl_alert` (`Fl_PostScript.cxx:1776-1792`). For a document the
  program names, `Start_Document` has FLTK write to a FIFO in a fresh
  directory under `$TMPDIR`, which a thread of the shim's copies to the
  file. The thread starts first, holding a write end so its read can't
  end early, and a pipe stops it if FLTK fails. The FIFO and its
  directory are removed at once, before any page. A full disk is then
  File_Write_Error from `End_Job`, and FLTK never sees an error. POSIX
  only, like the rest of the X11 and Wayland shim.
- **The file chooser path** (`Start_Job`, FLTK's format dialog then
  `Fl_Native_File_Chooser`): FLTK writes the file it was given, so a
  timer during `end_job` watches for a new modal window, as pofltk's
  shim does, hides it and makes `End_Job` raise File_Write_Error. A
  cancelled dialog raises User_Cancel_Error.
- **One document per surface.** A second `begin_document` works in
  FLTK but leaks the first name (FLTK-issues.md F20). `Start_Document`
  or `Start_Job` on a surface that has begun one raises Page_Error.
  Printer-style `Start_Job (Count)` raises Page_Error too: FLTK's
  returns 1 and does nothing ("don't use", `Fl_PostScript.cxx:1601`).
- **A PDF surface with no document can't be drawn on.** Its transform,
  page and print calls raise Program_Error until `Start_Document` or
  `Start_Job` succeeds, and after `End_Job`: FLTK's driver has no Cairo
  context then.
- **The PDF's page calls are virtual.** `c_fl_paged_device.cpp` calls
  `Fl_Paged_Device::` qualified, which skips `Fl_PDF_File_Surface`'s
  forwarding to its platform surface, so the PDF shim has its own.
  `Print_Widget` and the rest go through `Fl_Widget_Surface::draw`,
  whose calls are virtual (`Fl_Widget_Surface.cxx:43-85`), and work.
- **Support is found at run time.** A weak reference to
  `Fl_PDF_Pango_File_Surface::end_job` says FLTK has Pango, and the
  dialog texts, named weakly as the PostScript chooser title is, say it
  has print support (F21, pofltk 104). Only the supported case was run
  here.
- **SVG's open groups** (FLTK-issues.md F18). `close()` leaves a
  `translate`'s group open, and the file isn't XML. `SVG.Finish` closes
  them first, and `Untranslate` with none open raises Constraint_Error.
- **SaveAs** (`test/saveas.adb`): pofltk's example, with one addition.
  Given a format and a file name, it writes that file with no window, so
  it can be checked headless. Under Xvfb all four files are written and
  render with Ghostscript and rsvg-convert, the same picture as the
  window, and a missing directory or `/dev/full` exits 1 with the
  reason. All four are clean under valgrind.

Verdicts:

- **Issue 100:** HANDLED, by `ensure_font`, as for PostScript. The new
  checks draw text first, with no font set, on EPS and PDF, and the
  files are written. SVG keeps the font set (`test_svg_surface`), so
  pofltk's related bug doesn't arise.
- **Issue 102:** FIXED for PDF and EPS. A failed write raises
  File_Write_Error with the reason, and never alerts: `/dev/full` in
  `test_pdf_surface` gives "the PDF couldn't all be written", the
  copier's message, not the watch's. Finalizing an unfinished
  `/dev/full` surface doesn't hang.
- **Issue 103,** for PDF: as for PostScript. `Media` raises
  Constraint_Error, transforms outside a page raise Page_Error, and
  `Print_Widget` draws what is visible. The chooser's message,
  allocated with `new[]` under Pango, is freed with `delete[]`; the
  `strdup` path is FLTK's without Pango, where `Create` refuses first.
- **Issue 104:** HANDLED for PDF, by the weak dialog texts above; EPS
  uses the PostScript chooser title's test.
- **New:** FLTK-issues.md F18 to F21, and FLTKAda-BUGS.md 75.
- **Results:** `test_eps_surface`, `test_svg_surface`,
  `test_pdf_surface` and `test_page_finalize` pass on X11 and sway.
  Valgrind finds no errors.

### Phase 12: Method gaps in classes already bound [done, 2026-11-04]

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

Decisions and findings:

- **The methods.** Each group of the list above is bound and has a unit
  test: `test_ask_placement`, `test_undo_redo`, `test_layout_methods`,
  `test_widget_methods`, `test_tree_methods`, `test_terminal_cursor`,
  `test_text_buffer_methods`, `test_pixmap_data`, `test_shared_order`,
  `test_grid_cells`, `test_window_list`, `test_scheme_choice`,
  `test_resize_hook` and `test_hook_exceptions`. Each new check was seen
  to fail without its fix, unless it is noted below as not having been.
- **Issue 24** (`test_layout_methods`). Decided: `Set_Size_Range` and
  `Init_Size_Range` call `init_sizes` first, in the shim. Without that,
  `move_intersection` starts from the sizes `init_sizes` saved before
  the last move, and the next move puts the children back. With ranges
  set, FLTK saves the sizes after every move anyway, so this changes
  nothing else.
- **Issues 78 and 84, the tree's own icons** (`test_tree_methods`).
  Decided as for items' icons in Phase 4: the tree gets a copy of each
  icon, which `FLTK.Tree_Icons` holds while the tree shows it. FLTK also
  makes and deletes an inactive copy (`Fl_Tree_Prefs.cxx:63-90`), so a
  `Shared_Image` is copied as a plain image, and the pool's entry is
  left alone.
- **Issue 97** (`test_terminal_cursor`). Decided: `Restore_Cursor`
  restores the place itself, so a place saved at column 1 comes back.
  `ESC[u` still goes through FLTK, which can't be helped, and still
  misses it. The test checks both.
- **Issue 99, for the cursor moves** (`test_terminal_cursor`). FLTK's
  moves don't redraw, because `display_modified` is private. Decided,
  as in pofltk: the shim calls `append_ascii("")` after each one, which
  redraws as `redraw_style` says. At first `Cursor_Home`,
  `Set_Cursor_Row` and `Set_Cursor_Column` were left out of this, while
  pofltk's `ofl_terminal_cursor` and setters include them. They now
  redraw too. Before that, the test's three checks for them failed,
  with no draws. A count below 1 can't be given, since `Count` is
  `Positive`. FLTK would take it as 1.
- **F22 to F28** are new FLTK issues (FLTK-issues.md):
  - F22, on Wayland a GL window's swap interval is one setting for all
    windows. This is documented in the spec, on `Get_Swap_Interval`.
  - F23, `PER_WRITE` redraws once and then never again, and F24, the
    tabs stop at the first tab stop whatever the count. Both are worked
    around in the shim, and `test_terminal_cursor` checks both.
  - F25, an animated GIF that can't be opened is reported as a bad
    format. `Fail_Code` gives -2 for it.
  - F26, `insertfile` loses the end of a file that isn't UTF-8. The shim
    reads files itself (`test_text_buffer_methods`).
  - F27, `Fl_Grid::Cell`'s setters don't lay the grid out, and its span
    setters don't check (`test_grid_cells`).
  - F28, `Fl_Scheme_Choice`'s callback reads before its menu when
    nothing is chosen (`test_scheme_choice`).
- **FLTKAda bugs found and fixed:** 76 to 84 in FLTKAda-BUGS.md, with
  51 and 45. 45's hooks now check FLTK's values before calling the
  program's code. 81 is handlers that remove handlers, 82 is a
  dispatch function given a window FLTK made, 83 is a menu item's text
  taken as a pointer, and 84 is the awake functions' and
  `Draw_Pixmap`'s checks, which were `pragma Assert`s. 28 stays open:
  about 80 `pragma Assert`s on FLTK's results remain, unsorted.
- **Negative controls.** For each fix, the test was run against the old
  code, as FLTKAda-BUGS.md records under each entry. For
  `test_resize_hook`, 7 of its checks failed before the `Ada_Resizing`
  change, and all 10 pass after it.
- **Terminal `Clear_With`** is `Clear (This, Hue)`, an overload of
  `Clear`, as FLTK's `clear(Fl_Color)` is.
- **`GIF.Animated.Fail_Code` clamping** is moot. FLTK's codes are -1 to
  -3, and `Fail_Code` gives them as they are, with F25's -2 corrected.
  Bug 76 made the size functions return 0 for a failed image.
- **`Pixmaps` data access.** The data is given as lines, as FLTK holds
  it, with `Get_Line_Count` and `Get_Line`. The colors line of a
  pixmap FLTK has converted holds NUL, so lines are `String`, not
  C strings.
- **`Shared` compare.** `"<"` orders images as
  `Fl_Shared_Image::compare` orders the pool. A `Shared_Image` is
  limited, so a program sorts indexes (`test_shared_order`).
- **Text buffer 1-indexing.** Decided: positions stay byte offsets from
  0, as FLTK's and a text display's are, so a buffer's positions and a
  display's agree. File errors still raise `Storage_Error`, now saying why (80). The
  protected internals stay unbound, because they bypass undo and the
  modify callbacks.
- **`Grid` cells.** A cell is read with `Has_Cell`, `Get_Cell` (a
  `Cell_Info` record) and `Cell_Widget`. It is set with
  `Set_Cell_Alignment` and `Set_Cell_Minimum_Size`, which lay the grid
  out again (F27). `Fl_Grid::Cell` itself isn't bound, so its span
  setters, which can make layout read past the grid, can't be reached.
- **`Flex` protected methods** are left unbound. `init` would drop the
  fixed-size array without freeing it, `alloc_size` is only `size + 8`,
  and FLTK's `on_remove` already runs from `Remove`.
- **Windows FLTK made** (`test_window_list`). `Get_First_Window` and
  `Get_Next_Window` skip them, as pofltk's `ofl_first_window` does. This
  uses the shim's table of the widgets that have Ada objects, from 51's
  fix, so nothing is read from user data that isn't FLTKAda's.
- **`Choices.Schemes`.** A callback set replaces FLTK's, as in FLTK, and
  can call the new `Switch_Scheme` to switch as FLTK's does. FLTK calls
  its own `init_value` from `handle`, so an Ada `Init_Value` override is
  reached only from Ada.
- **`Resize` overrides** (`test_resize_hook`). Every widget's shim class
  now derives from the `Ada_Resizing` mixin, so FLTK's `resize` reaches
  an Ada override on any widget. The default calls FLTK's own `resize`,
  so an override that calls it runs once, whoever started the resize.
- **Hook exceptions and `Dispatch_Window`** (45, 82). A hook checks
  FLTK's values explicitly, then calls the program's code, with only a
  `when others` handler around it that saves the occurrence. The
  dispatch hook keeps the window FLTK gave while the dispatch function
  runs, so `Handle (Event, null)` can pass the event on to a window FLTK
  made. 44's API question, how to name such a window, stays open.
- **Pixmap checks.** 77's checks moved from `Pixmaps.Forge.Create` to
  `Pixmap_Marshal.Marshal_Data`, so `Draw.Draw_Pixmap` makes them too
  (84). The `Pre` on `Draw_Pixmap` stays as documentation.
- **Awake.** `Add_Awake_Handler`, `Awake` and `Get_Awake_Handler` raise
  `Tasking_Error` for FLTK's -1 (84). `test_statics_core` fills FLTK's
  ring of 1023 to check them.

### Phase 13: GLUT fonts [done, 2026-11-04]

- `FLTK.GLUT` bitmap and stroke fonts. Issue 135 applies, together with
  the issue 134 width check.
- Fix the GLUT `Incomplete APIs` items: `glut_window`/`glut_menu`, Ada
  objects for windows from `Create_Window`, and leaked menu and title
  strings.
- pofltk doesn't bind the `glutWire*`/`glutSolid*` models either. Leave
  them out.

What was done. Two new unit tests, `test_glut_fonts` (71 checks) and
`test_glut_window_of` (19 checks), pass on Xvfb and on a headless sway,
and are clean under valgrind (`vg-check.sh` 0). `test_glut_fonts` also
passes at `FLTK_SCALING_FACTOR` 1.5 and 2.

- **Fonts.** `FLTK.GLUT` has `Bitmap_Font` and `Stroke_Font` and the
  ten `glutBitmap*`/`glutStroke*` calls, as `Bitmap_Character`,
  `Bitmap_String`, `Bitmap_Width`, `Bitmap_Length`, `Bitmap_Height`,
  `Stroke_Character`, `Stroke_String`, `Stroke_Width`, `Stroke_Length`
  and `Stroke_Height`. Strings go to the shim with their lengths, so a
  NUL doesn't end them. The stroke calls drop NULs in a `std::string`,
  inside `try`/`catch`.
- **Issue 111: AFFECTED, done.** The bitmap subprograms and the two
  stroke draws raise `Program_Error` unless `fl_gl_ready` says a GL
  context is there; the stroke measures need none. Negative control:
  with the check taken out, the test's out-of-order checks fail. After a
  display function has run, the GLUT window is still current and shown,
  so text drawn then is legitimate. The test at first expected
  `Program_Error` there, which was the test's mistake.
- **Issue 134: AFFECTED, done.** `fl_glut_bitmap_draw` draws only text
  `gl_width` gives a width, as the GL `Draw_Text` does. Negative control:
  without it, a line feed crashed in FLTK, which GNAT reported as
  `Storage_Error`.
- **Issue 135: AFFECTED (bound in this phase), done.** Before the fix,
  `Bitmap_Character` of "A" in Times Roman 24 moved the raster position
  20 where its width is 17, and two "A"s moved it 40 where "AA" moved it
  36. The shim now moves the position to where it started plus
  `gl_width` times the scale, with `glBitmap (0, 0, 0, 0, dx, dy, 0)`.
  The scale is `pixels_per_unit()` in a GL window, and
  `Fl::screen_scale` of the window's screen otherwise. A scratch
  `gl_start` program at scale 2 in a plain window saw the position go
  from 20 to 300 for a length of 140: the width times the screen scale.
  Negative controls: without the move, the advance checks fail; without
  the scale, they fail at scale 2 only.
- **F29** (FLTK-issues.md): FLTK draws `glutBitmapCharacter`'s byte past
  127 as Latin-1, but 128 to 159 as CP1252. pofltk 135 calls the byte
  "bad UTF-8" without saying what is drawn. `Bitmap_Character` encodes
  the character as UTF-8. Negative control: without it, the 0x80 check
  fails (the position moved 13, the width of €, where `Bitmap_Width`
  gives 21), and the é check still passes.
- **`glut_window`** is `Glut_Window`'s new `Current_Window`, and
  `Window_Of` gives the object for any window number. A window
  `Create_Window` or `Create_Sub_Window` made gets an object the first
  time it is asked for: `Needs_Dealloc` False, its user data set
  directly, not by `Extra_Init`, which would end the window's group and
  set its label. Decided: the object is freed when `Window_Of` next
  gives a window with that number, or at exit by a sentinel, and not by
  `Destroy_Window`, because a program may still hold the reference.
  Freeing it never follows a pointer to a window that has gone: its
  `Void_Ptr` is cleared first, unless the window is still there with it
  as its object. `settle` also drops a destroyed window from the shim's
  table of Ada objects. That has no failure to show without it, so it
  has no control. Negative controls: without the sentinel, valgrind
  reports the objects (`vg-check.sh` 1); with `Void_Ptr` left, a stale
  object with an icon label reads freed memory in
  `Fl_Window::iconlabel`, and the test ends in `Program_Error`.
- **`glut_menu`** was already bound: it is `FLTK.GLUT.Get_Menu` and
  `Set_Menu` (glutGetMenu and glutSetMenu, `FL/glut.H:236-238`).
  `test_glut_window_of` checks that a window's `Get_Menu` is the menu
  attached to it.
- **Menu and title strings** were already fixed, as FLTKAda-BUGS.md 37,
  and moved into the shim for pofltk 112 in Phase 4
  (`test_glut_strings`). This phase's list above still named them; it
  was stale. Nothing more was needed.
- **No constants** go in `tools/gen-constants.py`: `Bitmap_Font` and
  `Stroke_Font` stand for addresses of FLTK's font objects, not values.

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

Decisions, as the phase goes:

- **`cairo_test`, `forms` and `rects` move to Phase 16** (2026-11-04).
  `cairo_test` draws with cairo's own calls, which FLTKAda doesn't bind
  until Phase 16's `FLTK.Cairo`, and Phase 16 already ports pofltk's
  `CairoTest`, so it is the same program. Writing it now would mean
  cairo imports private to a test program, which the binding would then
  replace. `forms` needs Phase 16's Forms classes (Open question 1
  decided for it), and `rects` needs `Fl_Rect`, also Phase 16.
- **`boxtype`** matches FLTK's C++ `boxtype` pixel for pixel
  (`compare -metric AE` 0 under one Xvfb), with no scheme and with
  `-s gtk+`. AGENTS.md's `xwd` isn't installed here; `import -window
  root` is.
- **`cube`** matches FLTK's C++ `cube` pixel for pixel (AE 0), and its
  statistics line is printed in the same form. The fixed-function OpenGL
  calls the GL demos need are imported in `test/gl1.ads`, private to the
  test programs, not a binding (Scope).
- **`device`** matches FLTK's C++ `device` pixel for pixel except the
  clock's second hand, which moved between the two screenshots. GO with
  `Fl_Image_Surface`, `fl_capture_window()` and
  `Fl_Image_Surface::mask()`, on each of the three targets, gives the same
  screen as the C++, apart from the clock. `Fl_Copy_Surface`,
  `Fl_Printer`, `Fl_PostScript_File_Device`, `Fl_PDF_File_Surface` and
  `Fl_SVG_File_Surface` open the same dialogs as the C++, and Escape
  leaves both programs running. Under valgrind, two GOs (the second frees
  the first one's closed copy window) and closing every window leave no
  invalid reads or writes, and `vg-check.sh` passes. Porting it found
  FLTKAda-BUGS.md 85: a `Printer` can't tell a cancelled job from a
  failed one, so `device` ignores `Page_Error`.
- **Every `new` in a test program is freed when `Run` returns**, so that
  `vg-check.sh` can be run on it. `boxtype` didn't free its buttons;
  valgrind showed the 48 lost from `fltk.widgets.buttons.forge.create`,
  and freeing them after `Run` cleared it.
- **`doublebuffer`** matches FLTK's C++ pixel for pixel (AE 0): both
  windows at the start, and each after a click on its slider, which
  changes only its own star.
- **`file_chooser`** matches FLTK's C++ pixel for pixel (AE 0): the
  start, the Directory toggle, the chooser with the Extra encodings group,
  a PDF's preview made by gs, and the files list and terminal after a
  pick. Both exit 0 from Close. Under valgrind, a pick leaves no invalid
  reads or writes, and `vg-check.sh` passes. The chooser keeps its
  Preview setting in FLTK's user preferences, so runs to be compared need
  their own `HOME` and `XDG_CONFIG_HOME`, or the first run changes what
  the second shows. Porting it found two FLTKAda bugs:
  - FLTKAda-BUGS.md 86: `Chooser_Kind` was an enumeration, so
    `Directory` reached FLTK as 3, `MULTI | CREATE`. It is now FLTK's bit
    mask, combined with `"+"`.
  - FLTKAda-BUGS.md 87: the F23 workaround cleared `Fl_Terminal`'s
    modified flag after every draw. A write that scrolled was drawn
    clipped to the scrollbar, and the rate-limited timer then found
    nothing to redraw, so the picked files never appeared. It now clears
    the flag after a draw only under `Per_Write`.
- **`Font_Kind` is FLTK's font number, an integer type** (2026-11-05,
  the user's choice of option 1 in FONT_KIND_ISSUE.md; FLTKAda-BUGS.md
  88). The enumeration named only the 17 built-in fonts, so the fonts
  `Setup_Fonts` added couldn't be used, which blocked `fonts`. The 17
  are now constants, so every call that names one is unchanged, and
  every program in the repository compiled as it was. FLTK doesn't check
  a font against its table (pofltk 130), so the shim keeps `font_end` as
  pofltk's does, and `FLTK.Static.Last_Font` reports it. The private
  `FLTK.To_C (Font_Kind)` raises `Constraint_Error` past it, and replaced
  every `Font_Kind'Pos`. Unlike pofltk, that checks the widget setters
  too. `Set_Font_Kind` takes a target up to `Max_Font`, 65535 as in
  pofltk. `Font_Family_Attributes` is new, for `get_font_name`'s
  attributes. The new test `test_font_numbers` (25 checks) passes on X11
  and sway with vg=0. `check-headless` and `check-sway` pass.
- **`fonts`** matches FLTK's C++ pixel for pixel (AE 0) in every state
  driven under Xvfb: the start; a system font picked after paging down;
  Monospace Bold at size 11, whose sample differs from the start (AE
  4370); the editor from F1; and the editor after a stroke, a gap, a lone
  dot, and `->` then `<-`. It differs from the C++ in three ways, none
  visible:
  - **Font sizes** are asked for when a font is picked, as pofltk does.
    The C++ asks for every font's sizes at the start.
  - **The editor** is made when the program starts, and shown on F1. The
    C++ makes it on the first F1.
  - **Each letter's strokes** are an `Ada.Containers.Vectors`, not a
    128-byte row. The C++'s 0 byte, which ends a row, is also the top
    left dot, so the C++ can't record that dot (FLTK-issues.md F30). The
    port leaves it out too, because the saved table is a C string per
    letter, which a 0 would end. Without that, the first stroke from the
    top left dot differed from the C++ by 951 pixels.

  F1 needed a function key, which `Keypress` didn't have (FLTKAda-BUGS.md
  89). Some names `Setup_Fonts` gives under Xvfb, such as "Latin Modern
  Mono Prop 10 Regular", fall back to Noto Sans in fontconfig. The C++
  draws them the same way.
- **`gl_overlay`** matches FLTK's C++ pixel for pixel (AE 0) under Xvfb:
  at the start, after a click on the Sides slider, and after one on the
  Overlay slider. Both print "Can do overlay = 0"; Xvfb's Mesa has no
  hardware overlay, so FLTK draws it in the front buffer. It needed
  `GL_Window.Draw_Overlay`, which wasn't bound (FLTKAda-BUGS.md 90).
- **`glut_test`** prints what FLTK's C++ prints, line for line, on Xvfb
  and on sway. Two things differ in the code, not the output: the menu
  it attaches has an entry, since `Attach_Menu` refuses an empty one,
  and with no current window it skips `Destroy_Window` and the ten
  per-window `*_Func` setters. Those raise `Program_Error` with no
  current window, where FLTK drops the callback (glut.H:258-314).
  Decided: they keep raising, like FLTK.GLUT's other calls in the wrong
  state, and the spec now says so. The overlay calls on a hidden window
  raised `Program_Error` too, which was FLTKAda's mistake
  (FLTKAda-BUGS.md 91). It ends by itself, so it is in the Makefile's
  `ONCE`.
- **`help_dialog`** gives the C++'s pixels (AE 0) under a private Xvfb.
  It was checked on FLTK's own page, at its top, `#Table` and `#Center`,
  and on FLTKAda's page, at its top, `#Lists` and `#Images`. Its animated
  GIF moves as the C++'s does. FLTK's `test/help_dialog.html` is under
  FLTK's licence, so `test/help_dialog.html` is FLTKAda's own page. It
  tries the same HTML, and `test/images/circles.gif` is its animated
  GIF. The C++ redraws `Fl::first_window()` to animate the GIF. FLTK
  made the help window, so it has no Ada object (FLTKAda-BUGS.md 51),
  and the port calls `FLTK.Screen.Redraw` instead, as pofltk does.
  Writing the page found F31: a `WIDTH=100%` table runs under the
  scrollbar. The page uses 90%. It runs on sway, and valgrind is clean.
- **`input_choice`** gives the C++'s pixels (AE 0) under a private Xvfb.
  That holds both as it starts and after the same clicks and keys sent
  to each with xdotool: the check button off and on, `ccc` from the
  Choice, an item from the Input_Choice's menu, and an edit of its
  input. Each callback's terminal line matches. The C++'s `in->value (0)`
  found FLTKAda-BUGS.md 92. Decided with the user 2026-11-05:
  `Input_Choice.Set_Item` takes a `Menus.Index` counting from 1, like
  `Has_Item` and `Item`, and raises for an item that doesn't exist (an
  incompatible change). Fixing it found bug 93, `Menu.Has_Item` counting
  the terminator. Decided with the user 2026-11-05: `Has_Item` is false
  for the terminators and iteration steps over them, while
  `Number_Of_Items` and `Index` still count FLTK's array (an
  incompatible change). Testing that found bug 96, reverse iteration
  raising at the start. The Choice callback prints
  `Chosen_Index - 1`, FLTK's number, so the terminal matches. It runs on
  sway, and valgrind is clean.
- **`mandelbrot`** gives the C++'s pixels (AE 0) under a private Xvfb.
  That holds as it starts, and after each of the same steps sent to
  both with xdotool: a zoom-in drag, Ctrl-M, a zoom-out click, a right
  click that opens the Julia window, values typed into the x and w
  inputs (`-` among them, which atof reads as 0), and a click on each
  slider. The coordinates and the Julia window's title are written with
  C's snprintf, imported with `Convention => C_Variadic_3`, since Ada's
  `Put` rounds halfway cases away from zero where printf rounds to even
  (%.2g of 0.125: 0.13 against 0.12). A scratch comparison of the two
  over many values found 12381 that differ. Float_Input's `Get_Value` raises
  Constraint_Error on a partial number such as `-`, so the callback uses 0, as
  atof does. The sliders' `box (FL_THIN_DOWN_BOX)` found FLTKAda-BUGS.md
  94, `Slider.Set_Box` setting the knob even through `Widget'Class`.
  ~~Left open; the port sets the frame with a view conversion.~~ Decided
  with the user 2026-11-05: the knob's pair is now `Get_Slider_Box` and
  `Set_Slider_Box`, and `Set_Box` sets the frame (an incompatible
  change). The port calls `Set_Box` and `Set_Slider_Box`, and still gives
  AE 0 at each of the steps above. It runs on sway,
  where the tiled window resizes the area and the picture is worked out
  again at the new size. Valgrind is clean, with both windows closed and
  everything freed.
- **`menubar`** gives the C++'s pixels (AE 0) under a private Xvfb, as
  it starts and after each of the same steps sent to both with xdotool.
  The steps opened each submenu that holds something new (File, Edit by
  its F2 shortcut, Checkbox, Radio, Font, International and Huge), the
  menu button, the choice and the pop-up. They also picked items from
  each, typed shortcuts (Alt+Z, Ctrl+A, Return, F1 with modifiers, F4,
  Ctrl+Return), and moved the line-spacing slider and opened a menu.
  Alt+Q ends both with status 0. As in pofltk, the items are added one
  by one. An item that shares its label is added under a unique one and
  renamed, and the Invisible submenu is filled before it is hidden.
  Huge is an ordinary submenu. The pop-up removes item 2, and the three
  menus choose item 1, as FLTK's table would. Its shortcuts on ß, Ä,
  ä, € and ㅈ, and on `'\r'`, found FLTKAda-BUGS.md 95: `Keypress` had
  no constructor for them. It was fixed with `Character_Key`, an
  addition. Their labels found FLTK-issues.md F32: X11 writes
  "EuroSign" and "Enter" where Wayland writes the characters. The macOS
  system menu bar and About item are left out, as pofltk leaves them
  out. On sway it tiles, and closing it runs the window callback.
  Valgrind is clean.
- **`offscreen`** gives the C++'s pixels (AE 0) under a private Xvfb,
  after 1, 10, 100, 300 and 302 lines (302 is past the clearing at
  301), after a short drag, after a long drag that hits the clamp, and
  after Ctrl-+ twice, which rescales the offscreen. Both use C's `rand`,
  imported, as the C++ does, and the comparison runs both with an
  LD_PRELOAD library that fixes `srand`'s seed and stops the process at
  the first `rand` of line N + 1. The C++ asks
  `Fl_Graphics_Driver::default_driver().scale()`, which isn't bound; the
  port reads the same value from `Draw.Override_Scale` and puts it back
  with `Restore_Scale`. pofltk looks up the scale of the screen at the
  window's position instead, and doing that here found FLTKAda-BUGS.md
  97: `Screen.Containing` counted from 0 and `Get_Scale` from 1.
  Decided with the user 2026-11-05: every `FLTK.Screen` number counts
  from 1 (an incompatible change). The offscreen is a limited object, so
  the box keeps an access to it, made by the first `Draw` and freed when
  `Run` returns. On sway it tiles and the box grows with the window.
  Valgrind is clean, with the window closed by Escape after a drag and
  a rescale.
- **`overlay`** gives the C++'s pixels (AE 0) under a private Xvfb at
  each of seven steps: the start, the keys a a a, c c, a click on
  "narrower", one on "taller", six on "shorter" (which take the height
  below 0; FLTK then draws nothing, Fl_Graphics_Driver.cxx:810 and
  Fl_Cairo_Graphics_Driver.cxx:155, in both), and
  b b b b. It does too with the arguments 3, abc, -1, 0 and 95, and the
  two print the same. The colour argument is read with C's `atoi`,
  imported, so that "abc" gives 0 and -1 a large unsigned colour as in
  the C++. `Fl::args` with a handler stops at an argument it doesn't
  know and says nothing, but `Static.Parse_Args` raises
  `Argument_Error`, so the port catches and ignores it. On sway it tiles
  and the rectangle stays centred. Valgrind is clean, with argument 3,
  after keys and a click, closed by Escape.
- **`pixmap_browser`** gives the C++'s pixels (AE 0) under a private
  Xvfb with no argument and with -a, -8, a directory, a missing file, a
  text file and a png, gif, jpg, xpm, xbm, svg and animated gif, and the
  two print the same. Through FLTK's file chooser too, at six steps:
  opening it, the previews of four files picked in turn (an animated
  gif, a png, an svg and a jpg), and a double click on an xpm, which both
  print. An animated gif shows the same four frames in the same order.
  It found FLTKAda-BUGS.md 98: `Set_Label ("")` left an empty label, so
  the image sat 10 pixels high; decided with the user 2026-11-06 that
  `""` means null (an incompatible change). Two differences are kept on
  purpose. A truncated png shows FLTK's empty-document symbol, where
  the C++ shows the 0-wide image `Fl_Shared_Image::get` returns, since
  `Shared.Forge.Create` raises `No_Image_Error`. And the C++ crashes on
  test/images/colors.bmp, pofltk 87, where FLTKAda refuses the file.
  "save as SVG" and "Print" were not driven: the native file chooser and
  the print dialog may reach the desktop through D-Bus, which a private
  Xvfb doesn't isolate. On sway it tiles and the image stays centred.
  Valgrind is clean, with an animated gif and the file chooser opened
  and closed, closed by Escape.
- **`symbols`** gives the C++'s pixels (AE 0) under a private Xvfb at
  eight steps: as it opens, then after each of seven clicks on the two
  sliders, which turn, grow and shrink the symbols (every step differs
  from the first). Creating the two sliders before the boxes, at
  elaboration, left about 15 pixels at the top-right corners of the
  sliders' frames dark where the C++'s are the window's grey, though
  `Get_Box`, the colours and the kind matched the C++'s. Creating them
  after the boxes, so that they are the window's last children as in the
  C++, made every step match; why the order changes those pixels was not
  looked into. The C++'s `step (1)` found FLTKAda-BUGS.md 99:
  `Set_Step_Bottom` sets the whole step and not its denominator, and
  `Set_Step_Top` the whole step too. Decided with the user 2026-11-06 to
  add `Set_Step (This, To)` for both and keep the old names as
  obsolescent; the port calls `Set_Step (1)`. On sway it tiles and the cells grow with the window.
  Valgrind is clean, after three clicks on the sliders, closed by Escape.

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
  `CairoDrawX` and `CairoTest` examples. `CairoTest` is FLTK's
  `cairo_test`, moved here from Phase 14.
- `Fl_Rect`, and pofltk's `Rects` example, moved here from Phase 14.
- FLTK's `forms` test, moved here from Phase 14, with the Forms
  examples.

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
