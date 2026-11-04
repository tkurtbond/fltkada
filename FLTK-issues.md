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
- **Confirmed**: from FLTK's source (2026-11-03), and by
  `test/unit/test_part_callbacks.adb`, which failed before FLTKAda's fix
  (`Storage_Error` on typing into an `Input_Choice`). The audit found no
  other wrapped part affected (PLAN.md, N8).

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
  promises. It failed until Phase 2, and now passes (FLTKAda-BUGS.md
  43). In the menu case valgrind shows
  invalid reads in `Fl::grab()`'s callers and `Fl_Tooltip::current`,
  then `Storage_Error` (release) or "terminate called without an active
  exception" and a segfault (debug). The image case loses 1,200 bytes
  allocated in `draw_image`. The other cases show no invalid accesses.

### F4. `Fl_Tooltip::enter_area` keeps its old text after an empty one

- **What happens**: `Fl_Tooltip::enter_area` with an empty or null text,
  or with tooltips disabled, hides the tip but leaves FLTK's `tip`
  pointing at the last text it was given. FLTK can read that text again
  later. In `test_kept_strings` the read came from `tooltip_timeout`, and
  `Fl_TooltipBox::layout` measured the old text while a dir chooser was
  up. So a binding that keeps the tooltip's text can't free its copy on
  an empty text. pofltk's `ofl_tooltip_enter_area` does free it there
  (pofltk 75). Seen 2026-11-03, X11 under Xvfb.
- **Cause**: `Fl_Tooltip.cxx:290-293` returns through `exit_(0)` without
  touching `tip`. Only line 301 sets it, together with `widget_`. If
  `widget_` is already null, `exit_` returns at once (line 251), without
  removing a pending `tooltip_timeout`.
- **Effect on FLTKAda**: `fl_tooltip_enter_area` (`body/c_fl_tooltip.cpp`)
  frees its old copy only once `Fl_Tooltip::current()` is the widget it
  passed, which is when FLTK took the new text. An empty text keeps the
  copy, and a static destructor frees the last copy at exit.
- **Confirmed**: `test/unit/test_kept_strings.adb` under valgrind, with the
  shim freeing on an empty text the way pofltk does. There were 15
  invalid reads of the freed 12-byte copy, in `tooltip_timeout`
  (`Fl_Tooltip.cxx:165`) and `fl_measure`. With the fix there are none.
  The source shows why; I haven't traced which call left `widget_` null
  with the timeout armed.

### F5. `Fl_Grid::layout (rows, cols)` keeps spans that no longer fit

- **What happens**: a cell spanning rows or columns keeps its span when
  `layout (rows, cols)` makes the grid smaller. The next
  `Fl_Grid::layout ()`, which drawing and resizing call, then reads the
  sizes and gaps of rows and columns past the end of the grid's arrays.
  A cell the cut hides, in a column or row beyond the new size, keeps its
  span too, and over-reads in the same way once the grid is made larger
  again. pofltk checks a span only when it is placed (pofltk 21). Seen
  2026-11-03, X11 under Xvfb.
- **Cause**: `Fl_Grid::layout (int, int, int, int)` (`Fl_Grid.cxx:177-235`)
  copies the old rows with their cells, and the old columns, into arrays
  of the new size. It never looks at a cell's `rowspan_` or `colspan_`.
  `Fl_Grid::layout ()` adds up `Cols_[c + i + 1]` and `Rows_[r + i + 1]`
  for every column and row a cell spans (`Fl_Grid.cxx:470-478`).
- **Effect on FLTKAda**: before `layout (rows, cols)` makes the grid
  smaller, `fl_grid_set_layout` (`body/c_fl_grid.cpp`) cuts every cell's
  span to fit, including the cells the cut hides. A cell outside the new
  size gets a span of 1. The spans stay cut if the grid grows again.
- **Confirmed**: a scratch C++ program put a box in a 3 by 3 grid with
  a span of 3 by 3, cut the grid to 1 by 1, and called `layout ()`.
  Valgrind found 4 invalid reads in `Fl_Grid::layout ()`
  (`Fl_Grid.cxx:471-477`), just past the blocks that `layout (1, 1)`
  allocated. `test/unit/test_grid_range.adb` gives 6 invalid reads, at
  `:472` and `:477`, with the shim's cut disabled, and none with it. Its
  value checks pass either way, because the bytes read happened to be
  harmless.

### F6. `Fl_Text_Buffer::search_backward` never returns from past the end

- **What happens**: `search_backward` with a start past `length ()`
  loops forever, matching case or not. Seen 2026-11-03.
- **Cause**: `Fl_Text_Buffer::prev_char_clipped` (`Fl_Text_Buffer.cxx:2072-2091`)
  reads back through `byte_at`, which gives `'\0'` past the end. The
  string it builds is then empty, and it returns the position it was
  given. `prev_char` (`:2102-2106`) passes that on, and
  `search_backward` (`:1342-1392`) steps with `prev_char` until the
  position is below 0. `findchar_backward` clamps its start to the
  length first (`:1838-1839`), and so does not loop.
- **Effect on FLTKAda**: `fl_text_buffer_search_backward`
  (`body/c_fl_text_buffer.cpp`) clamps the start to `length ()`, and
  its own search, matching case, starts no later than the last place
  the string fits. `Prev_Char` itself still returns a position past the
  end unchanged, as FLTK does.
- **Confirmed**: a scratch C++ program on a 3-character buffer:
  `prev_char (4)`, `(5)` and `(6)` return 4, 5 and 6, and
  `search_backward (20, "a", ...)` timed out, with `matchCase` 0 and 1.
  `word_start`, `line_start`, `rewind_lines` and `findchar_backward`
  return from 20. `test/unit/test_text_search.adb` hung at its first
  backward search from past the end before the clamp.


### F7. The PNG, JPEG and PNM loaders size the image as an `int`

- **What happens**: a PNG or JPEG whose header claims more than
  `INT_MAX` bytes of image makes `new` throw out of the constructor.
  Through `extern "C"` the C++ exception reached Ada as
  `SYSTEM.EXCEPTIONS.FOREIGN_EXCEPTION`, after unwinding through
  libpng's C frames. Seen 2026-11-03.
- **Cause**: each loader checks the size against `max_size ()` as a
  `size_t` (`Fl_PNG_Image.cxx:217`, `Fl_JPEG_Image.cxx:323`,
  `Fl_PNM_Image.cxx:133`), then allocates `new uchar[w() * h() * d()]`, an
  `int` product (`:218`, `:324`, `:139`). `max_size` is unlimited by
  default (`Fl_Image.cxx:335`), so the check passes and the product
  overflows. `Fl_BMP_Image.cxx:280-285` and `Fl_ICO_Image.cxx:193` have
  the same shape.
- **Effect on FLTKAda**: the root package's elaboration
  (`body/fltk.adb`) sets `max_size` to `int'Last` if it is larger, so the
  check refuses the file with `ERR_FORMAT`, and `Create` raises
  `Format_Error`. `RGB.Set_Max_Size` raises `Constraint_Error` for a
  value over `int'Last`. Every image constructor and copy in the shim also
  catches C++ exceptions and returns null, which raises `Storage_Error`.
- **Confirmed**: `test/images/huge.png` (65535 by 65535 RGBA) and
  `huge.jpg` (an 8 by 8 JPEG with its frame header changed to 65500 by
  65500), in `test_image_crafted`. A scratch program with HEAD's PNG
  shim got `FOREIGN_EXCEPTION` for `huge.png`. That wasn't tried for the
  JPEG. With the shim's `catch` but without the cap, both files, from a
  file and from memory, raise `Storage_Error`. With the cap, FLTK prints
  "too large or contains errors" and both raise `Format_Error`.

### F8. An image read from memory with a name joins the shared pool, unowned

- **What happens**: `Fl_PNG_Image`, `Fl_JPEG_Image` or `Fl_SVG_Image`
  made from memory with a non-null name is put in the shared image pool
  under that name. When the image is deleted, the pool's entry is left
  pointing at it, and `Fl_Shared_Image::find` of the name returns an
  entry whose image is freed. Seen 2026-11-03.
- **Cause**: each loader does `new Fl_Shared_Image (name, this)` and
  `add ()` (`Fl_PNG_Image.cxx:239-242`, `Fl_JPEG_Image.cxx:341-344`,
  `Fl_SVG_Image.cxx:299-302`). That constructor sets `alloc_image_` to 0
  (`Fl_Shared_Image.cxx:133-146`), so the entry never deletes the image,
  and the image's destructor doesn't take itself out of the pool
  (`Fl_Image.cxx:458-461`). The entry's reference is never released
  either, so the entry lasts for the rest of the program.
- **Effect on FLTKAda**: an empty `Name` is passed as `NULL`. For a
  named image, the free function looks for an entry for it that doesn't
  own it. If there is one, the entry is given the image and its
  reference is released, so the image lasts while a `Shared_Image` found
  by its name does (FLTKAda-BUGS.md 56).
- **Confirmed**: `test_image_names` under valgrind. Before the fix, 44
  invalid reads in `Fl_Shared_Image::desaturate` of an entry for a freed
  PNG, and the pool grew by 2 for one unnamed PNG and one unnamed JPEG.
  After it, none, and the pool is as it was once the images go.

### F9. A second `begin_job` leaks the first job's Cairo surface

- **What happens**: under Pango, `Fl_PostScript_File_Device::begin_job`
  on a device whose job hasn't ended makes a new Cairo surface and
  context, and the first job's are never freed. Seen 2026-11-03.
- **Cause**: `start_postscript` sets `cairo_` from
  `init_cairo_postscript` without looking at the one it replaces
  (`Fl_PostScript.cxx:1537`). Only `end_job` destroys it.
- **Effect on FLTKAda**: a leak of about 10 KB a time, not a memory
  error. The shim's own stream for the first job is closed when the
  second starts, and the leaked surface never writes to it again.
  FLTKAda doesn't refuse a second `Start_Job` yet. pofltk 103 tried a
  second job after the first ended, which is clean.
- **Confirmed**: a scratch program calling `Start_Job` twice on one
  `Postscript_File_Device`, under valgrind on Xvfb: 10,622 bytes
  definitely lost from `_cairo_ps_surface_create_for_stream_internal`
  through `start_postscript`, no invalid reads, and the file was written.
