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
  `fl_size()`, as pofltk's fixed version does.
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
    (`FlGlut.Mod`). They go with issue 112, in Phase 13.
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
  - **Overlays.** `Establish_Overlay` and `Use_Layer` raise
    `Program_Error` for a window not shown.

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
