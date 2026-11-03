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
