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
  Phase 2). What the hook's own code pushed and didn't pop before it
  raised is undone, latest first, before the exception is saved: a clip,
  a matrix, a current surface, a begun offscreen, a started page, or
  `OpenGL.Start`, which sets the display driver's scale to 1 until
  `gl_finish` (`src/gl_start.cxx:86, 93`). Left alone, each would have
  FLTK draw the rest of the window clipped, transformed, into the wrong
  surface or at the wrong scale (PLAN.md, "Architecture decisions", 7).
- **Confirmed**: `test/controls/n12.adb` (one case per hook, release
  and debug builds, under Xvfb and headless sway, and valgrind on X11),
  and `test/unit/test_exceptions.adb`, which checks the recovery FLTKAda
  promises. `test/unit/test_draw_state.adb` checks the undo: with it
  taken out, every case but the guards' fails. It failed until Phase 2, and now passes (FLTKAda-BUGS.md
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

### F10. `Fl_Browser::load` drops a byte where it splits a long line

- **What happens**: a line longer than 1023 bytes is split into lines of
  1023 bytes, as pofltk 40 says, but the byte that comes after each
  1023 is lost. A file of one 1030-byte line loads as lines of 1023 and
  6 bytes. Seen 2026-11-04.
- **Cause**: the loop reads a byte with `getc`, and when the buffer is
  full it ends the line and adds it without storing that byte
  (`Fl_Browser_load.cxx:43-50`).
- **Effect on FLTKAda**: none it can fix short of its own `Load`. The
  spec of `Textline.Load` says so.
- **Confirmed**: `test_browser_load`, on X11 and on sway.

### F11. `Fl_Menu_::add (const char *)` drops a byte where it cuts a long part

- **What happens**: a part of the text, between `|`s, longer than 1022
  bytes is cut into items of 1022 bytes, and the byte after each 1022 is
  lost. A part of 1030 bytes adds items of 1022 and 7 bytes. Seen
  2026-11-04.
- **Cause**: the copy into the 1024-byte `buf` stops at 1022 bytes, and
  after adding the item `if (*str) str++` skips the next byte as if it
  were a `|` (`Fl_Menu_add.cxx:451-457`).
- **Effect on FLTKAda**: none it can fix short of splitting the text
  itself. The spec of `Add_Items` says so. **Worked around** in Phase
  29 (2026-11-15): the shim now splits the text itself (`menu_parts`,
  `body/c_fl_menuitem.cpp`), for pofltk 173, and a long part is one item
  cut to 1023 bytes, as for `Add` (pofltk 172).
- **Confirmed**: `test_menu_add_items`, on X11 and on sway.

### F12. `FL_CONTRAST_CUSTOM` with no function uses CIELAB at level 0

- **What happens**: in Custom mode with no contrast function set,
  `fl_contrast` returns the foreground colour unchanged, even white on
  white. The docs say it falls back to CIELAB, but it doesn't contrast
  as CIELAB mode does. Seen 2026-11-04.
- **Cause**: the fallback falls through to `fl_contrast_cielab`
  (`fl_contrast.cxx:513-519`), which reads the threshold from
  `fl_contrast_level()`, the *current* mode's level (400, 202). Custom's
  level is 0 to start (37-43), and every pair of colours passes a
  threshold of 0 (410).
- **Effect on FLTKAda**: none to fix. The spec of
  `FLTK.Static.Set_Contrast_Function` says so: set a level in Custom
  mode to get CIELAB's behaviour.
- **Confirmed**: `test_statics_core`, on X11 and on sway: white on white
  gives white at Custom's level 0, and black after
  `Set_Contrast_Level (39)` in Custom mode.

### F13. Pasting the program's own text leaves `Fl::event_clipboard_type` as it was

- **What happens**: in the `FL_PASTE` of text this program copied,
  `Fl::event_clipboard_type()` is `""` if nothing else has been pasted,
  and `"image"` if an image was pasted before. A handler that tests the
  type to tell text from an image takes the text for an image. Seen
  2026-11-04.
- **Cause**: the quick paths for the program's own selection set
  `e_text` and `e_length` for text, but only set `e_clipboard_type` for
  an image (X11 `Fl_x.cxx:694-706`, Wayland
  `fl_wayland_clipboard_dnd.cxx:620-628`). The type starts as `""`
  (`Fl.cxx:68`), and nothing sets it back after a paste.
- **Effect on FLTKAda**: worked around. `FLTK.Events.Clipboard_Kind`
  reports `"text/plain"` for an empty type, and the widget Handle hook
  sets the type back to text when the outermost Paste Handle returns
  (`fl_event_end_paste`, `body/c_fl_event.cpp`).
- **Confirmed**: `test_paste_image`, on X11 and on sway. Without the
  workaround, its first text paste gave `""` and its text paste after an
  image gave `"image"`.

### F14. An `Fl_Image_Surface` narrower or lower than 1 crashes when read

- **What happens**: `Fl_Image_Surface (0, 5, 1)` is made without
  complaint, and can be drawn on, but `image()` crashes. On X11 it reads
  through null; on Wayland it divides by zero (SIGFPE). Seen 2026-11-04.
- **Cause**: nothing checks the size. On X11 the driver's `image()`
  returns null, and `Fl_Image_Surface::image`
  calls `img->scale` on it (`Fl_Image_Surface.cxx:156`). On Wayland
  `cairo_format_stride_for_width` gives a stride of 0
  (`Fl_Wayland_Image_Surface_Driver.cxx:42`), which `image()` divides
  by (139).
- **Effect on FLTKAda**: `Image_Surface`'s and `Offscreen`'s
  `Forge.Create` raise Constraint_Error for a width or height below 1
  (FLTKAda-BUGS.md 69).
- **Confirmed**: a C++ program under valgrind, on Xvfb (invalid read at
  address 0, SIGSEGV) and on sway (SIGFPE), and `test_offscreens`.

### F15. Deleting a surface that is current or pushed leaves it in FLTK's stack

- **What happens**: deleting an `Fl_Image_Surface` remembered by
  `push_current` under another, then popping, makes the freed surface
  current, and drawing reads and writes freed memory: valgrind found 14
  invalid reads and an invalid write on X11, the same on sway. Seen
  2026-11-04.
- **Cause**: `~Fl_Surface_Device` clears `surface_` if it is the surface
  deleted, but not the stack (`Fl_Device.cxx:107-110`), and
  `pop_current` calls `set_current` on what the stack holds (156).
- **Effect on FLTKAda**: worked around. A surface freed while current
  from a `Push_Current` is popped first. One buried under another is
  replaced by a stand-in that keeps the FLTK object until the stack
  forgets it (FLTKAda-BUGS.md 70, PLAN.md Phase 9).
- **Confirmed**: a C++ program under valgrind on Xvfb and sway, and
  `test_offscreens`, which draws on a stand-in after freeing the Ada
  object, with no invalid reads.

### F16. `Fl_Image_Surface::rescale` while the surface is current crashes

- **What happens**: after `push_current (s)` and `s->rescale()`, drawing
  reads through a null Cairo context and the program dies of SIGSEGV,
  on X11 and on Wayland. Seen 2026-11-04.
- **Cause**: `rescale` deletes `platform_surface` and makes a new one
  (`Fl_Image_Surface.cxx:190-199`). The documentation says the surface
  must not be current (186), but nothing checks it.
- **Effect on FLTKAda**: `Image_Surface.Rescale` and `Offscreen.Rescale`
  raise Program_Error while the surface is current or pushed.
- **Confirmed**: a C++ program under valgrind on Xvfb and sway (invalid
  read at address 4 in `cairo_rectangle`), and `test_offscreens`.

### F17. `fl_write_png` of an image with no pixels aborts the program

- **What happens**: `fl_write_png` of an `Fl_RGB_Image` of width or
  height 0, or of an `Fl_PNG_Image` that failed to load, prints
  "libpng error: Invalid IHDR data" and the program dies of SIGABRT.
  Seen 2026-11-04.
- **Cause**: `fl_write_png` (`fl_write_png.cxx:120-175`) creates the
  libpng write struct with no error handler and no `setjmp`, so libpng's
  default error handler aborts when `png_set_IHDR` rejects the size. The
  reader, `Fl_PNG_Image.cxx:164`, has the `setjmp`. Nothing checks the
  depth or the line size either. They are only used to step through the
  data.
- **Effect on FLTKAda**: `Write_PNG` raises No_Image_Error for an image
  with no data, a size below 1 or no pixels, and never calls
  `fl_write_png` for it. `RGB_Image` refuses a bad depth or line size
  (FLTKAda-BUGS.md 71).
- **Confirmed**: a C++ program under Xvfb: width 0 and a failed load
  abort, and a 4x4 image writes. Under valgrind, depth 0 and a short
  line size read past the data at `fl_write_png.cxx:161`.
  `test_write_png` checks that `Write_PNG` raises.

### F18. `Fl_SVG_File_Surface::close` leaves a `translate` group unclosed

- **What happens**: after `translate` with no `untranslate`, `close()`
  writes an SVG whose groups don't match, which XML parsers refuse:
  xmllint reports "Opening and ending tag mismatch: g ... and svg".
  Seen 2026-11-04, on X11.
- **Cause**: `translate` opens a `<g>` and `untranslate` closes one
  (`Fl_SVG_File_Surface.cxx:378-386`), but `close()` writes only the
  `</g></g></svg>` that closes the two groups the constructor opened
  (370-376). Nothing counts the groups in between.
- **Effect on FLTKAda**: `SVG.Finish` undoes every `Translate` not yet
  undone first, and `Untranslate` with none to undo raises
  Constraint_Error, since the `</g>` it wrote would close one of the
  constructor's groups.
- **Confirmed**: a C++ program under Xvfb, whose file xmllint refuses.
  `test_svg_surface` checks that the binding's file, after two
  `Translate`s left open, closes as many groups as it opens.

### F19. The PDF surface's `begin_job` leaks the page size it reads

- **What happens**: each `Fl_PDF_File_Surface::begin_job` under X11 or
  Wayland loses a few bytes, the page size's name. Valgrind reports them
  definitely lost, from `Fl_Preferences::get`. Seen 2026-11-04.
- **Cause**: `Fl_PDF_Pango_File_Surface::begin_job` reads
  `PDF/page_size` with the `char *&` form of `Fl_Preferences::get`, which
  returns a `strdup`ed copy for the caller to free, and never frees it
  (`Fl_PostScript.cxx:1683`).
- **Effect on FLTKAda**: none it can fix: the string is FLTK's local.
  `PDF.Start_Job` loses the bytes once a call. `test/vg-check.sh` doesn't
  count it, since FLTK allocated it.
- **Confirmed**: `test_pdf_surface` under valgrind, which cancels the
  format dialog once.

### F20. A second document on one PDF surface leaks the first one's name

- **What happens**: `begin_document` on an `Fl_PDF_File_Surface` that has
  written a document works, and the second file is right, but the first
  name is lost. Seen 2026-11-04, on X11.
- **Cause**: `Fl_PDF_Pango_File_Surface::begin_document` sets
  `doc_fname = strdup (outfname)` without freeing the name already there
  (`Fl_PostScript.cxx:1753`). Only the destructor frees it (1598).
- **Effect on FLTKAda**: a `PDF_File_Surface` writes one document.
  `Start_Document` or `Start_Job` on one that has begun one raises
  Page_Error.
- **Confirmed**: a C++ program under valgrind on Xvfb, two documents on
  one surface: both files are written, and 6 bytes from the `strdup` at
  1753 are definitely lost.

### F21. Smaller pitfalls of `Fl_PDF_File_Surface`

- **`pdf_filename()` without Pango dereferences null.** It returns
  `*out_filename_` (`FL/Fl_PDF_File_Surface.H:84`), and the non-Pango
  `new_platform_pdf_surface_` sets `out_filename_` to null
  (`Fl_PostScript.cxx:1475-1478`).
- **`begin_document` keeps its `FILE` when Cairo fails.** It opens the
  file, and if `cairo_pdf_surface_create_for_stream` then fails it
  returns 2 without closing it (`Fl_PostScript.cxx:1721-1737`).
- **The dialog's texts are where `--disable-print` shows.** The four
  `format_dialog_*` statics don't exist in such an FLTK
  (`Fl_Device.cxx:169`, as pofltk 104 says), so naming one fails to
  link.
- **Effect on FLTKAda**: `PDF.Forge.Create` raises Unsupported_Error
  without Pango, so the binding never asks `pdf_filename()` there. The
  shim reads a document it names from a FIFO, through a thread that a
  pipe can stop, so a `FILE` FLTK keeps can't block it. It names the
  texts weakly, and `Is_Supported` is False without them.
- **Confirmed**: from FLTK's source; no FLTK without Pango or print
  support was built to show the first and third.

### F22. On Wayland a GL window's swap interval is one setting for all

- **What happens**: on Wayland, `Fl_Gl_Window::swap_interval()` reads
  the last interval set on any GL window, or 1 if none was, even for a
  window that isn't shown. On X11 a window not shown reads -1, and a
  shown one its own interval, if the driver can say.
- **Cause**: the Wayland driver keeps the interval in one static,
  `swap_interval_` (`src/drivers/Wayland/Fl_Wayland_Gl_Window_Driver.cxx:66`),
  sets it whenever `eglSwapInterval` succeeds, and returns it
  (`:461-472`). The X11 driver asks GLX about the window's own drawable,
  and returns -1 before the window has one
  (`src/drivers/X11/Fl_X11_Gl_Window_Driver.cxx:374-376`).
- **Effect on FLTKAda**: `GL_Window.Get_Swap_Interval` says so; nothing
  to work around.
- **Confirmed**: `test_widget_methods` (2026-11-04): an unshown window
  reads 1 under headless sway and -1 under Xvfb. Under Xvfb a shown
  window also reads -1, since its GLX driver can't report the interval;
  under sway, setting 0 and then 1 reads back 0 and 1.

### F23. `Fl_Terminal`'s `PER_WRITE` redraws once, and then never again

- **What happens**: under `PER_WRITE`, the first write after the style is
  set redraws the terminal and later writes don't. Neither does
  `RATE_LIMITED` after that, nor after the style is changed away from
  `RATE_LIMITED` while a write waits for the timer.
- **Cause**: `display_modified` redraws under `PER_WRITE` only while
  `redraw_modified_` is false, and starts `RATE_LIMITED`'s timer only
  while it is false, and sets it true either way
  (`src/Fl_Terminal.cxx:2964-2981`). Only the timer sets it false again
  (`:3365-3376`); `display_modified_clear` is never called, and
  `redraw_style()` removes the timer without clearing it (`:4053-4058`).
- **Effect on FLTKAda**: the shim reaches the private flag, as it does
  `escseq` (pofltk 96), and clears it after `Fl_Terminal::draw` and when
  `Set_Redraw_Style` changes the style; a change still waiting then is
  drawn, unless the new style is `No_Redraw`. It first cleared it after
  every draw; that was wrong under `RATE_LIMITED`, where a draw clipped to
  the scrollbar then cancelled the timer's redraw (FLTKAda-BUGS.md 87).
  It now clears it after a draw only under `PER_WRITE`.
- **Confirmed**: a scratch C++ program under Xvfb (2026-11-04): three
  appends under `PER_WRITE` drew 1, 0 and 0 times, and an append under
  `RATE_LIMITED` after them 0 times. `test_terminal_cursor`, whose
  redraw checks fail without the workaround.

### F24. `Fl_Terminal`'s tabs stop at the first tab stop, whatever the count

- **What happens**: `cursor_tab_right(2)` from column 0 stops at column 8,
  not 16, and `cursor_tab_left(2)` from 24 stops at 16, not 8. `ESC[2I`
  and `ESC[2Z`, which call them, do the same.
- **Cause**: both loop over the count, but return as soon as they find a
  tab stop (`src/Fl_Terminal.cxx:2533-2555`).
- **Effect on FLTKAda**: `Cursor_Tab_Right` and `Cursor_Tab_Left` call
  FLTK once per tab, at most a line's width of times. `ESC[#I` and
  `ESC[#Z` in a program's text can't be helped.
- **Confirmed**: a scratch C++ program under Xvfb (2026-11-04), which
  also showed `ESC[2I` stopping at 8; `test_terminal_cursor`, whose tab
  checks fail without the workaround.

### F25. `Fl_Anim_GIF_Image` reports a file it can't open as a bad format

- **What happens**: an `Fl_Anim_GIF_Image` of a file that doesn't exist
  has `fail()` -3, `ERR_FORMAT`, where an `Fl_GIF_Image` of the same
  file has -2, `ERR_FILE_ACCESS`. A program can't tell a missing file
  from a broken one.
- **Cause**: `load()` sets `ld(ERR_FORMAT)` whenever the frames aren't
  valid, whatever went wrong (`src/Fl_Anim_GIF_Image.cxx:1072-1076`).
- **Effect on FLTKAda**: after a construction or `Load` that fails, the
  shim tries to open the file itself, and sets -2 if it can't
  (`mark_access` in `body/c_fl_anim_gif_image.cpp`). `Fail_Code` now
  returns FLTK's `fail()`, so an animation never loaded gives -1, not 0.
- **Confirmed**: a scratch C++ program under Xvfb (2026-11-04): -2 for
  `Fl_GIF_Image`, -3 for `Fl_Anim_GIF_Image`, -1 for an empty one;
  `test_image_crafted`, whose two F25 checks fail without the workaround.

### F26. `Fl_Text_Buffer::insertfile` loses the end of a file that isn't UTF-8

- **What happens**: `loadfile` of the five bytes `caf\xE9\n`, Latin-1,
  gives the buffer `caf`. The `é` and the line feed are lost, and
  `input_file_was_transcoded` stays false, so there is no warning. The
  same letter followed by more text is read and transcoded.
- **Cause**: `utf8_input_filter` takes `0xE9` as the start of a
  three-byte sequence. With fewer bytes than that left in the file, it
  stops (`src/Fl_Text_Buffer.cxx:1971-1977`) and returns what it has.
  The next call stops there again and returns 0, which `insertfile`
  takes for the end of the file (`:2020-2032`). Any file whose last
  three bytes hold a byte that begins a longer sequence loses them.
- **Effect on FLTKAda**: the shim reads files itself, with the same
  loop, except that at the end of the file it decodes what is left as
  `fl_utf8decode` does, a bad byte as CP1252. It sets
  `input_file_was_transcoded` and calls `transcoding_warning_action` as
  FLTK does. `Load_File`, `Append_File` and `Insert_File` use it.
- **Confirmed**: a scratch program under Xvfb (2026-11-04): `caf\xE9\n`
  loaded as 3 bytes, with no warning; `caf\xE9 au lait\n` and
  `caf\xE9\n\n\n\n` loaded whole, with FLTK's alert.
  `test_text_buffer_methods`, whose four F26 checks fail with FLTK's
  `loadfile` in the shim.

### F27. `Fl_Grid::Cell`'s setters don't lay the grid out, and its span setters don't check

- **What happens**: `cell->align(FL_GRID_TOP_LEFT)` on a shown grid
  leaves the widget where it was, stretched across its cell, until
  something calls `need_layout(1)` or resizes the grid; so does
  `minimum_size(w, h)`. `cell->rowspan(5)` in a 2 by 2 grid is
  accepted, and the next `layout()` reads past the grid's row array.
  Found 2026-11-04.
- **Cause**: `Fl_Grid::Cell::align`, `minimum_size`, `rowspan` and
  `colspan` (`FL/Fl_Grid.H`) only set the field, where `Fl_Grid::widget`
  calls `need_layout(1)`. Nothing checks a span against the grid's edge
  (FLTKAda's `Set_Widget` does, pofltk 21), and `layout()` adds up the
  rows and columns a span covers (`src/Fl_Grid.cxx:470-478`).
- **Effect on FLTKAda**: a cell is never handed to Ada, since FLTK frees
  it. `Get_Cell` copies it. `Set_Cell_Alignment` and
  `Set_Cell_Minimum_Size` call `need_layout(1)` after the setter. The
  span setters aren't bound; `Set_Widget` sets spans.
- **Confirmed**: a C++ program under Xvfb and valgrind: after `align`
  the box stayed 110 by 110, and became 20 by 20 only after
  `need_layout(1)`; after `rowspan(5)` and `layout()`, invalid reads of
  4 and 2 bytes at `Fl_Grid.cxx:476-477`, just after the block
  `layout(2, 2)` allocated. `test_grid_cells`, whose two F27 checks
  fail with `need_layout(1)` taken out of the shim.

### F28. `Fl_Scheme_Choice`'s callback reads before its menu when nothing is chosen

- **What happens**: `do_callback()` on a scheme choice whose `value()`
  is -1 reads the menu item before the first. Found 2026-11-04.
- **Cause**: `Fl_Scheme_Choice::scheme_cb_` takes
  `c->text(c->value())` (`src/Fl_Scheme_Choice.cxx:90`), and
  `Fl_Menu_::text(i)` is `menu_[i].text`, unchecked (`FL/Fl_Menu_.H:214`).
  A pick always sets a value first, so FLTK itself only gets there when
  a program calls the callback with nothing chosen.
- **Effect on FLTKAda**: `scheme_cb_` is reached from Ada only through
  `Switch_Scheme`, which does nothing unless the choice's value is an
  item.
- **Confirmed**: a C++ program under Xvfb and valgrind: `value(-1)`
  then `do_callback()` gave an invalid read of 8 bytes at
  `Fl_Scheme_Choice.cxx:90`; the scheme stayed "plastic", by luck of what
  was there. `test_scheme_choice` is clean under valgrind, and with the
  check taken out of the shim, valgrind shows the same invalid read,
  though all 6 checks still pass.

### F29. `glutBitmapCharacter` reads a byte past 127 as Latin-1 or CP1252

- **What happens**: pofltk 135 says a character past 127 reaches
  `gl_draw` as "one byte of bad UTF-8". FLTK draws that byte anyway.
  0xA0 to 0xFF draw as Latin-1, so é (0xE9) draws as é. But 0x80 to 0x9F
  draw as CP1252, so 0x80 draws €, 13 wide, where
  `glutBitmapWidth(0x80)` measures U+0080, which is 21 wide. Found
  2026-11-04.
- **Cause**: `fl_utf8decode` (`src/fl_utf8.cxx:700-735`) is built with
  `ERRORS_TO_CP1252` set (`:667-668`). It returns a lone byte from
  0xA0 up as its own code, and one from 0x80 to 0x9F through the
  `cp1252` table (`:685`). `glutBitmapCharacter` (`src/glut_font.cxx:37-41`)
  passes `gl_draw` the one byte, but `glutBitmapWidth` passes the
  number to `gl_width(uchar)`.
- **Effect on FLTKAda**: `FLTK.GLUT.Bitmap_Character` encodes a
  character past 127 as UTF-8 before it draws it, so it draws the
  Latin-1 character that `Bitmap_Width` measures, whatever the byte.
- **Confirmed**: by `test_glut_fonts` under Xvfb. Its 0x80 check fails
  with the UTF-8 encoding taken out of `Bitmap_Character`, because the
  raster position moved 13, not 21. Its é check still passes without
  the encoding.

### F30. `test/fonts.cxx`'s editor can't record the top left dot

- **What happens**: in the vector font editor that F1 opens, a click on
  the top left dot adds nothing. A stroke begun there starts at the
  second dot clicked. Found 2026-11-05, porting `fonts`.
- **Cause**: each letter's strokes are a row of `vec[255][128]`, ended
  by a 0 byte (`test/fonts.cxx:103`, read by `LetterBox::draw` at
  `:122-128`). A dot is stored as `i*8+j`, column then row
  (`create_editor`, `:245`), so the top left dot is 0, and `add_point_cb`
  (`:151-157`) writes it as the end of the row. By reading the source,
  also: `add_point_cb` doesn't stop at the row's 128 bytes, and `->`
  past character 254 indexes `vec[255]`, past the array.
- **Effect on FLTKAda**: only on `test/fonts.adb`. It keeps each letter's
  strokes in a vector, which could hold the dot. It leaves the dot out
  anyway, because `save_cb`'s table is a C string per letter, which a 0
  would end.
- **Confirmed**: under Xvfb, driven with xdotool. A stroke begun at the
  top left dot differed from the C++ by 951 pixels, the missing left
  edge, until the port left the dot out (AE 0). Begun at the next dot
  along, the two matched before the change.
- **Fixed in FLTKAda's port** (2026-11-11, PLAN.md Phase 18, following
  pofltk's fix): `test/fonts.adb` no longer copies the bug. It records
  and draws the top left dot, and Save leaves the dot out of FLTK's
  table and says so in an alert. So the port now differs from the C++
  on purpose, by the stroke the C++ loses. Confirmed under Xvfb, driven
  with xdotool: after clicking the top left dot and the one below it,
  the pixel between them is blue (0,0,255); built from the previous
  `fonts.adb`, it was the background grey (192,192,192). The effect
  paragraph above describes the port before this fix.

### F31. `Fl_Help_View` lays a `WIDTH=100%` table out under its scrollbar

- **What happens**: a table with `WIDTH=100%` is as wide whether or not
  the page needs a vertical scrollbar. When it does, the scrollbar
  covers the table's right end, and the text of a right-aligned last
  cell is clipped ("Right" shows as "Rig"). Found 2026-11-05, porting
  `help_dialog`.
- **Cause**: in part. `format` sets the document width once, as
  `w() - scrollsize - Fl::box_dw(b)` (`src/Fl_Help_View.cxx:1255`),
  whether the scrollbar will show or not, and `get_length` makes a
  percentage of `hsize_ - scrollsize` (`:2834-2835`). The scrollbar is
  shown or hidden only after the layout (`:2005-2031`), and nothing lays
  the table out again for the narrower view. Why the table then reaches
  about 8 pixels past the scrollbar's left edge, when the scrollbar's
  width is taken off twice, wasn't traced.
- **Effect on FLTKAda**: none on the binding. FLTKAda's
  `test/help_dialog.html` uses `WIDTH=90%`.
- **Confirmed**: with FLTK's own `test/help_dialog` (C++) under Xvfb,
  in a 530x300 window at 0,0, with a page holding only a bordered
  `WIDTH=100%` table, and the same page with 60 paragraphs after it.
  In both, the table's right border is at x 511. In the long one the
  scrollbar starts at x 503 and covers it. FLTKAda's port gives the same
  pixels (AE 0).

### F32. A shortcut's label depends on the backend

- **What happens**: `fl_shortcut_label` gives a different label for the
  same shortcut under X11 and under Wayland. `FL_COMMAND+0x20ac` is
  "Ctrl+EuroSign" under X11 and "Ctrl+€" under Wayland; `'\r'` is
  "Enter" under X11, and under Wayland a carriage return, which shows as
  nothing. Found 2026-11-05, porting `menubar`.
- **Cause**: the label's key name comes from the screen driver.
  `Fl_X11_Screen_Driver::shortcut_add_key_name` writes "Enter" for
  `FL_Enter` and `'\r'`, the character itself for 33 to 0xff, and
  otherwise `XKeysymToString (key)`, which is "EuroSign" for 0x20ac
  (`src/drivers/X11/Fl_X11_Screen_Driver.cxx:137-155`). The default,
  which the Wayland driver doesn't override, looks the key up in
  `key_table` and otherwise encodes `fl_toupper (key)` as UTF-8
  (`src/fl_shortcut.cxx:381-416`), and the table has `FL_Enter` but not
  `'\r'`.
- **Effect on FLTKAda**: none on the binding. `FLTK.Draw.Shortcut_Label`
  gives what FLTK gives. test/unit/test_character_keys.adb expects each
  backend's label.
- **Confirmed**: a C++ program printing `fl_shortcut_label` for each of
  menubar.cxx's international shortcuts, run under Xvfb and on a headless
  sway. The two runs differ only in these two labels.

### F33. `Fl_Table::row_height` past the last row writes past its array

- **What happens**: `row_height (row, h)` with `row` at or past
  `rows ()` writes one `int` past the end of the row heights. Found
  2026-11-06, writing FLTKAda's table unit test.
- **Cause**: to grow the array it calls `_rowheights->size (row)`, or
  `resize (row, height)` with `FLTK_USE_STD`, which makes `row`
  elements, numbered 0 to `row - 1`, and then writes
  `(*_rowheights)[row]` (src/Fl_Table.cxx:232-252).
  `Fl_Int_Vector::operator[]` doesn't check its index
  (src/Fl_Int_Vector.H:124-127). `col_width` grows its array to
  `col + 1` and is right (src/Fl_Table.cxx:263-273).
- **Effect on FLTKAda**: `Table.Set_Row_Height` passed any row through.
  It now raises `Range_Error` for a row past `Get_Rows`, as pofltk's
  SetRowHeight halts (FLTKAda-BUGS.md 112).
- **Confirmed**: a C++ program that calls `rows (5)`, then
  `row_height (5, 20)` and `row_height (9, 30)`, run under valgrind on
  Xvfb: "Invalid write of size 4" at `Fl_Table::row_height`
  (Fl_Table.cxx:248) for each, into the block `Fl_Int_Vector::size`
  had just reallocated. `row_height (5)` then gave 30.

### F34. `fl_draw_image` with a negative width or height throws

- **What happens**: `fl_draw_image` and `fl_draw_image_mono`, both the
  forms with data and those with a line callback, throw
  `std::bad_alloc` when the width or height is negative, on the Cairo
  drawing FLTK uses on X11 and Wayland alike. Found 2026-11-06, writing
  FLTKAda's second draw unit test.
- **Cause**: `Fl_Cairo_Graphics_Driver::draw_image` allocates
  `new uchar[iw * D * ih]` without checking the sizes
  (src/drivers/Cairo/Fl_Cairo_Graphics_Driver.cxx:651); the data forms
  reach it through `draw_image_cb` (line 745).
- **Effect on FLTKAda**: the exception reached Ada as
  `System.Exceptions.Foreign_Exception`, which the shim must never let
  through. `FLTK.Draw.Draw_Image` and `Draw_Image_Mono`, all four, now
  draw nothing for a width or height below 1, as pofltk's do.
- **Confirmed**: a C++ program drawing into an `Fl_Image_Surface` with
  height -1, then width -2, caught `std::bad_alloc` from each of the
  three calls it tried, under Xvfb and on a headless sway.
  test/unit/test_draw_more.adb raised `Foreign_Exception` before the
  fix.

### F35. `Fl_Text_Editor::tab_nav (1)` twice needs `tab_nav (0)` twice

- **What happens**: each `tab_nav (1)` adds a Tab binding, and each
  `tab_nav (0)` removes one. After two `tab_nav (1)` calls, one
  `tab_nav (0)` leaves Tab moving the focus, and `tab_nav ()` still
  gives 1. Found 2026-11-11 by reading the source, planning Phase 19.
- **Cause**: `tab_nav (val)` is `add_key_binding (FL_Tab, 0, kf_ignore)`
  or `remove_key_binding (FL_Tab, 0)` (src/Fl_Text_Editor.cxx:824-829).
  `add_key_binding` always puts a new binding at the head of the list
  (:212-220), and `remove_key_binding` removes the first one that
  matches (:195-203). It is close to pofltk 148, which is about a
  program's own bindings.
- **Effect on FLTKAda**: `Set_Tab_Mode` calls `tab_nav (val)` only when
  `tab_nav ()` differs, so it can be called any number of times.
- **Confirmed**: test/unit/test_text.adb, on Xvfb: `Set_Tab_Mode
  (Widget_Focus)` twice, then `Set_Tab_Mode (Insert_Char)`. Before the
  fix, when the shim called `tab_nav` straight through, `Get_Tab_Mode`
  was still `Widget_Focus` and Tab typed nothing. After it, Tab types a
  tab.

### F36. GLUT's round shapes have no limit on their counts

- **What happens**: `glutSolidSphere (1.0, 268435456, 4)` tries to
  allocate gigabytes. Found 2026-11-11, binding GLUT's shapes in
  Phase 20.
- **Cause**: `fghCircleTable` (src/freeglut_geometry.cxx:121-158)
  `calloc`s two tables of `abs (n) + 1` doubles for each count, with
  nothing to limit `n`, and the sphere asks for `stacks * 2`, which
  can overflow an `int`. When `calloc` fails, it frees the table it
  did get and returns, leaving both pointers as they were: the shape
  that called it (`glutSolidSphere` at :181-200, and the others) then
  reads through a null or freed pointer, and frees it again at the end.
  A count of 0 or below makes a degenerate shape but no error.
- **Effect on FLTKAda**: the counts of `FLTK.GLUT`'s spheres, cones and
  tori are `Shape_Count`, 1 .. 65_536, as pofltk's `MaxCount` limits
  them, so the tables stay small and a count out of range raises
  `Constraint_Error`.
- **Confirmed**: by reading the source, and a scratch C++ program under
  Xvfb. Slices of 0 and of -3 drew with no GL error. Slices of
  268,435,456 ran out of memory: under a 300 MB cgroup limit the kernel
  killed it, and under a 1.5 GB `ulimit -v` it aborted with an uncaught
  `std::bad_alloc`, from a part not traced. The failed-`calloc` path
  itself is seen only in the source. test/unit/test_glut_shapes.adb
  checks that counts of 0 and 65_537 raise.

### F37. `fl_color_chooser` shows a zero component as "0" unless given a mode

- **What happens**: `fl_color_chooser` with no mode (cmode -1), for a
  colour such as FL_SELECTION_COLOR (0, 0, 128), shows its R and G
  fields as "0" and its B field as "0.502". Given a mode, even RGB,
  all three have three decimals: "0.000". Found 2026-11-11, porting
  test/input.cxx in Phase 21.
- **Cause**: the `Fl_Color_Chooser` constructor calls `set_valuators`
  (src/Fl_Color_Chooser.cxx:571) while every value is 0, so each
  `Fl_Value_Input` keeps the text it was made with. `rgb (r, g, b)`
  then calls `set_valuators` again (:143), which sets each step to
  1/1000 and each value, but `Fl_Valuator::value` redraws the text only
  when the value changes, so a component that is still 0 keeps "0".
  `mode (m)` runs `mode_cb` (:451-458), which first sets every value to
  -1 "to force them to redraw even if value is the same".
- **Effect on FLTKAda**: `FLTK.Asks.Color_Chooser` always passes a
  mode, RGB by default, so its fields always have three decimals. A
  port of a C++ program that calls `fl_color_chooser` without a mode
  differs from it there, and only there.
- **Confirmed**: test/input.adb against FLTK's test/input, on Xvfb,
  choosing selection_color: the G field was "0" in the C++ and "0.000"
  in the Ada. Built with `fl_color_chooser (0, r, g, b, 0)`, the C++
  matched the Ada at AE 0.

### F38. `Fl_Table` with a filled table box paints over cells it doesn't redraw

- **What happens**: a table whose `table_box` is a filled box, such
  as `FL_UP_BOX`, and which has no child widgets, sometimes shows the
  box over every cell except a few rows. Found 2026-11-12, porting
  test/table.cxx in Phase 25: with Table Box set to Up Box and Type
  to SelectSingle, a drag down the rows left only rows 12 to 17
  drawn.
- **Cause**: with no children, the table's inner `Fl_Scroll` is hidden
  (src/Fl_Table.cxx:181, FL/Fl_Table.H:775-781). `Fl_Table::draw`
  then draws `table->box()` over the whole table area whenever the
  damage includes `FL_DAMAGE_CHILD` (src/Fl_Table.cxx:1327-1331), but
  when it lacks `FL_DAMAGE_ALL` it redraws only the cells from
  `_redraw_toprow` to `_redraw_botrow` and `_redraw_leftcol` to
  `_redraw_rightcol` (:1336-1344). A frame box draws no fill and so
  erases nothing. Which damage bits a redraw gets depends on how the
  events and the redraws fall, so the same input can give either
  picture.
- **Effect on FLTKAda**: none in the binding. The port's comparison
  drives that drag in separate down, move and up steps, for which
  both builds draw the same partial table.
- **Confirmed**: under Xvfb with `xdotool`, FLTK's test/table and the
  Ada port. Driven by one `xdotool` drag command, the C++ build showed
  only rows 12 to 17 and the Ada port every cell; driven in separate
  steps, both showed the same partial table, AE 0. Builds of both
  that printed each draw and event drew every cell. The cause is from
  reading the source.

### F39. `test/sudoku.cxx`'s `new_game` writes before `grid_values_`

- **What happens**: when `new_game` can't place a number, it starts
  again, but first goes on placing the rest of that box's numbers in
  rows -3 to -1 of `grid_values_`, the 27 bytes before it. Found
  2026-11-12, porting `sudoku` in Phase 27; pofltk's `Sudoku.Mod`
  describes the same fault in its header comment, but pofltk's issue
  list doesn't have it.
- **Cause**: on `count == 20`, `new_game` sets `k = 9` and `j = -3`
  (test/sudoku.cxx:1168-1172) to restart the outer loops, but the `t`
  loop around it (:1143) carries on to 9 with `j` at -3, so `m = j +
  (rand () % 3)` is -3 to -1, and `grid_values_[m][n]` is read and set
  outside the array. Before it, in `Sudoku` (:174-177), are the end of
  the `Fl_Double_Window` base, `menubar_`, `grid_` and `seed_`, so what
  is read there, which decides how many random numbers are taken and
  so which game is dealt, depends on the pointers' bytes. A number is
  written only where the byte is 0, such as a pointer's high bytes, so
  the writes can change `menubar_`, `grid_` and `seed_`. Most seeds reach the restart.
- **Effect on FLTKAda**: only on `test/sudoku.adb`. To deal the C++'s
  games, it keeps 27 bytes of its own in front of the grid, as they
  are on x86-64 when no pointer byte is 1 to 9, as pofltk's port does.
- **Confirmed**: the cause from reading the source. Under Xvfb, driven
  with xdotool, the port dealt the same puzzles as FLTK's build in all
  eight new games of three runs, including one after earlier games had
  written into those bytes. That the C++ result can change with its
  heap addresses is from the source; every C++ run here dealt the same.

### F40. `gl_draw_image` reads past its data

- **What happens**: `gl_draw_image` with depth 1 or 2, or with rows
  whose length in bytes isn't a multiple of 4, reads past the end of
  data that holds exactly `w * h * d` bytes, and draws the wrong
  colours: grey is drawn as RGB, and such rows are drawn askew. FLTK's
  manual says nothing of either. Found 2026-11-12, sorting
  FLTKAda-BUGS.md 28. pofltk's list doesn't have it, and pofltk's
  `FlGl.DrawImage` has the same fault: it checks
  `w * h * d <= LEN(data)` and documents depth 1 as grey.
- **Cause**: `gl_draw_image` (src/gl_draw.cxx:236-244) passes
  `d < 4 ? GL_RGB : GL_RGBA` to `glDrawPixels`, so depths 1 and 2 are
  read at three bytes a pixel. It sets `GL_UNPACK_ROW_LENGTH` but not
  `GL_UNPACK_ALIGNMENT`, whose default of 4 makes GL take each row as
  padded to a multiple of 4 bytes.
- **Effect on FLTKAda**: `FLTK.Draw.OpenGL.Draw_Image`'s shim no
  longer calls `gl_draw_image`. It does what it does with a format
  for each depth (`GL_LUMINANCE`, `GL_LUMINANCE_ALPHA`, `GL_RGB`,
  `GL_RGBA`) and an alignment of 1, and restores the unpack state it
  changes.
- **Confirmed**: a scratch C++ program drew a malloc'd `w * 10 * d`
  bytes with `gl_draw_image` under Xvfb and valgrind. Depth 3 at width
  8 and depth 4 at width 10 were clean; depths 1 and 2 at width 8 had
  107 invalid reads each, and depth 3 at width 10 had 12, all in
  Mesa's `glDrawPixels`. `test/unit/test_gl_draw_image.adb` reads back
  what FLTKAda's `Draw_Image` draws for each case.
