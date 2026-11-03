# FLTK issues found while working on FLTKAda

This file records problems in FLTK 1.4 found while working on FLTKAda that
pofltk's list (`~/Repos/Oberon/pofltk/doc/fltk-issues.md`) doesn't already
have. There are two kinds:

- **Bugs**, which crash or contradict FLTK's documentation.
- **Pitfalls**, which are FLTK working as intended in a way a binding must
  allow for.

For an issue pofltk already lists, don't copy it here. Cite its number
instead ("pofltk 54"); PLAN.md has FLTKAda's verdict on each of them.
Bugs in FLTKAda's own code go in `FLTKAda-BUGS.md`.

Record each new issue in pofltk's form:

- **What happens**: the FLTK version and back end (Wayland, X11) it was
  seen on, and the date.
- **Cause**: the source file and function, if found.
- **Effect on FLTKAda**: the workaround, and where it lives.
- **Confirmed**: the test or scratch program that showed it, or "from
  FLTK's source" if no program has shown it yet.

Entries are numbered F1, F2, … and keep their numbers, since code
comments may cite them.

Unless an entry says otherwise, the version is FLTK 1.4.5 (sources in
`/usr/local/sw/src/lang/C++/fltk/fltk-1.4.5/`), on Fedora 44, x86_64.

## Pitfalls

### F1. `Fl_Help_View::load` asks the link function again before using its answer

- **What happens**: a link function that reuses one buffer for its
  answers (the natural way to return a `const char *` from a binding)
  makes `load` open a file whose name has been freed or overwritten. This
  happens when the page being replaced has an `<IMG>`. Found 2026-11-03,
  on any back end.
- **Cause**: `Fl_Help_View::load` sets `localname` from the link
  function (`src/Fl_Help_View.cxx:3408`), then calls `free_data()`
  (`:3415`). For each image on the old page, `free_data` calls
  `get_image` (`:2531`), which calls the link function again (`:2788-2799`).
  Only after that does `load` use `localname`, in `fl_fopen`
  (`:3427-3431`). The documentation doesn't say the link function can be
  re-entered between returning an answer and that answer being used.
- **Effect on FLTKAda**: `Help_View`'s link hook frees its single buffer,
  `Hilda`, on each call (FLTKAda-BUGS.md 17). The planned fix keeps every
  answer for the life of the view, as pofltk's shim does to avoid asking
  twice about an image (pofltk 90).
- **Confirmed**: from FLTK's source (2026-11-03). Not yet shown by a
  program; PLAN.md Phase 2 adds the test.

### F2. `Fl_Value_Input` and `Fl_Input_Choice` find themselves through their parts' `user_data`

- **What happens**: if a program or binding sets `user_data` on
  `Fl_Value_Input::input`, or on `Fl_Input_Choice`'s `input()` or
  `menubutton()`, the parent's internal callbacks cast that data to the
  parent's class and use it. Found 2026-11-03.
- **Cause**: the parts' callbacks are installed with the parent as their
  data: `input.callback(input_cb, this)` (`src/Fl_Value_Input.cxx:120`,
  used at `:28`), and `inp_->callback(inp_cb, (void*)this)` and
  `menu_->callback(menu_cb, (void*)this)` (`src/Fl_Input_Choice.cxx:266,
  270`, used at `:206, 237`). An `Fl_Widget`'s callback data *is* its
  `user_data`, and both parts are public, so anything that labels a widget
  through `user_data` breaks the parent.
- **Effect on FLTKAda**: FLTKAda stores the Ada record's address in every
  wrapped widget's `user_data`, including these parts
  (FLTKAda-BUGS.md 15). The fix must restore the parent pointer, or
  replace the parts' callbacks as `Table` does for its scrollbars. The
  same applies to any other FLTK composite whose parts' callbacks take the
  parent as data. That is worth an audit: grep FLTK's `src/` for
  `callback(.*, this)` and `(void\*)this)`.
- **Confirmed**: from FLTK's source (2026-11-03). Not yet shown by a
  program; PLAN.md Phase 2 adds the test.

### F3. An exception that unwinds through FLTK leaves FLTK's state half-updated

- **What happens**: FLTK 1.4.5 is built with `-fexceptions`, so an
  exception raised in a hook FLTK calls (an Ada exception under GNAT's
  zero-cost model, or a C++ one) unwinds through FLTK's frames to the
  caller of `Fl::wait`, and C++ destructors run on the way. But FLTK's
  code isn't exception-safe: whatever it would have done after the hook
  returned is skipped. Seen on X11 and Wayland, 2026-11-03. By hook:
  - **Widget callback, `handle()`, timeout, modal dialog**: FLTK
    recovers. A timeout that raised is not run again, and later timeouts
    run. A `handle()` that raised on `FL_PUSH` leaves `Fl::pushed` set to
    the window until the release, as an unhandled push does anyway.
  - **Idle**: no idle callback ever runs again.
  - **Timeout raising during a pop-up menu** (X11): `Fl::grab` is left
    pointing at the menu window, which lived in a frame that no longer
    exists. The next use of the grab reads freed stack.
  - **`draw()`**: the window stays damaged but isn't redrawn until
    something else damages it. If the `draw()` pushed a clip
    (`fl_push_clip`) before raising, the clip stays pushed: after two
    such raises a later full redraw no longer paints the whole window.
    On Wayland, a window whose *first* frame raised is never drawn again
    (a later frame that raises recovers).
  - **`fl_draw_image` line callback**: as `draw()`, and the image buffer
    is leaked.
  - **GLUT display callback**: on X11 the GLUT window is redisplayed, but
    ordinary windows then redraw black. On Wayland the GLUT window is
    never displayed again.
- **Cause**, from FLTK's source:
  - idle: `Fl::run_idle` sets its static `in_idle` before the call, and
    the reset after it is skipped (`src/Fl.cxx:612–619`), so every later
    `run_idle` returns at once;
  - timeout: `Fl_Timeout::do_timeouts` calls `make_current`, which pushes
    the timeout on the `current_timeout` stack and the `release()` after
    the call is skipped (`src/Fl_Timeout.cxx:537–541`), so the entry stays
    on that stack, harmlessly in the test;
  - menu: `Fl_Menu_Item::pulldown` grabs its stack-allocated menu window
    (`src/Fl_Menu.cxx:1001–1002`) and the `Fl::grab(0)` at `:1155` is
    skipped;
  - draw: `Fl::flush` clears `Fl::damage_` first, and the window's
    `clear_damage()` after `draw()` is skipped. On Wayland,
    `Fl_Wayland_Window_Driver::flush` skips `in_flush_ = false` and
    `buffer_commit` (`src/drivers/Wayland/Fl_Wayland_Window_Driver.cxx:418–421`);
    which one stops later frames isn't checked;
  - image: `Fl_Cairo_Graphics_Driver::draw_image` allocates
    `new uchar[iw*D*ih]` (`src/drivers/Cairo/Fl_Cairo_Graphics_Driver.cxx:651`)
    and frees it after the line loop;
  - GLUT: `Fl_Glut_Window::draw`'s static `indraw` stays 1
    (`src/glut_compatibility.cxx:55–65`), so `glutSwapBuffers` outside
    the display callback then does nothing. Why plain X11 windows draw
    black afterwards isn't traced. It isn't an unpopped
    `Fl_Surface_Device` from `Fl_Gl_Window::draw_begin`: a GLUT window
    with no children never calls it.
- **Effect on FLTKAda**: no hook may let an exception escape into FLTK.
  Each one catches it, saves the occurrence, returns normally, and the
  binding re-raises it when control comes back to Ada (PLAN.md N12,
  Phase 2). A clip the user's own `Draw` pushed is still the user's to
  pop.
- **Confirmed**: `test/controls/n12.adb` (one case per hook, release
  and debug builds, under Xvfb and headless sway, and valgrind on X11),
  and `test/unit/test_exceptions.adb`, which checks the recovery FLTKAda
  promises and so fails until Phase 2. In the menu case valgrind shows
  invalid reads in `Fl::grab()`'s callers and `Fl_Tooltip::current`,
  then `Storage_Error` (release) or "terminate called without an active
  exception" and a segfault (debug). The image case loses 1,200 bytes
  allocated in `draw_image`. The other cases show no invalid accesses.
