# Incompatible changes

The changes in FLTKAda that can stop a program written for upstream
FLTKAda from compiling, or make it behave differently. "Upstream" is
Jedidiah Barber's last commit, `2c15b31` (2025-04-14). Newest changes
come first in each list.

## Changes that can stop a program compiling

- **`Trees.Open`, `Close`, `Open_Toggle`, `Select_Item`, `Deselect`
  and `Select_Toggle` have a new last parameter, `Do_Callback`,
  defaulting to `True`**, FLTK's `docallback`, and **`Select_All` and
  `Deselect_All` have two, `Item` and `Do_Callback`**, defaulting to
  the whole tree and `True`. Calls compile as before, but an
  `overriding` declaration of one, or an access to one, must add the
  parameters.
  [PLAN.md, Phase 25](PLAN.md#phase-25-large-programs-done-2026-11-12).
- **A table's row heights and column widths are `Natural`**, not
  `Positive`: `Get_Row_Height` and `Get_Column_Width` return it, and
  the four setters take it. A caller that keeps a result in a
  `Positive` still compiles, but raises `Constraint_Error` for a row
  or column of size 0.
  [FLTKAda-BUGS.md 136](FLTKAda-BUGS.md#136-a-tables-rows-and-columns-couldnt-be-0-high-or-wide).
- **`Static.Option` has five new literals at its end**:
  `FNFC_Uses_Zenity`, `FNFC_Uses_KDialog`, `Printer_Uses_GTK`,
  `Show_Scaling` and `Simple_Zoom_Shortcut`, FLTK 1.4's other options.
  A `case` over `Option` without `others` needs the new arms.
  [PLAN.md, Phase 24](PLAN.md#phase-24-events-and-keys-done-2026-11-12).
- **`Scrolls.Scroll_Kind` begins with a new literal, `Neither`**, FLTK's
  type 0, so the other literals' `'Pos` is one more, and a `case` over
  `Scroll_Kind` without `others` needs the new arm.
  [FLTKAda-BUGS.md 133](FLTKAda-BUGS.md#133-a-scroll-couldnt-be-set-to-show-no-scrollbars).
- **`Callback_Flag` has a fifth component, `Closed`**, for FLTK's
  `FL_WHEN_CLOSED`, with the constant `When_Closed`. An aggregate of the
  record that names all four old components, or gives them by position,
  no longer compiles; one with `others` does.
  [FLTKAda-BUGS.md 130](FLTKAda-BUGS.md#130-no-fl_when_closed-so-no-closable-tab).
- **`Widgets.Measure_Label` has a third parameter, `Wrap`, defaulting
  to 0**, FLTK's wrap width. Calls compile as before, but an
  `overriding` declaration of it, or an access to it, must add the
  parameter.
  [PLAN.md, Phase 20](PLAN.md#phase-20-api-that-pofltks-ports-needed-done-2026-11-11).
- **`FLTK.Version` returns a `Long_Float`**, not a `Version_Number`. As
  a `Version_Number` it was always 1 for FLTK 1.x; it is now 1.0405 for
  FLTK 1.4.5. Use `API_Version` for a `Version_Number`.
  [FLTKAda-BUGS.md 126](FLTKAda-BUGS.md#126-version-gave-1).
- **`FLTK.Normal_Size` is gone.** It was a constant; FLTK's
  `FL_NORMAL_SIZE` is a variable. Use `Get_Normal_Size` and
  `Set_Normal_Size`.
  [FLTKAda-BUGS.md 122](FLTKAda-BUGS.md#122-normal_size-was-a-constant).
- **`Browsers.Sort` has a third parameter, `Ignore_Case`, defaulting to
  False**, and **`Counters.Get_Kind` takes its `This` as `in`**, not
  `in out`. Calls compile as before, but a type of the program's own
  that overrides either with the old profile no longer overrides it.
  [PLAN.md, Phase 14](PLAN.md#phase-14-examples-and-test-ports-done-2026-11-06),
  the unit tests for widgets and browsers.

- **`File_Browser`'s `Load` procedure with a `Sort` has no default for
  it, and the one-argument `Load` lists a directory.** `File_Browser`
  overrides the `Load (File)` it inherits from `Textline_Browser` with
  `Load (Dir)`, as C++'s `Fl_File_Browser::load` hides `Fl_Browser::load`.
  `Load ("dir")`, `Load (Dir => "dir")` and `Load ("dir", Sort)` all
  compile; `Load (File => ...)` on a file browser does not. A dispatching
  call through `Textline_Browser'Class` on a file browser now lists the
  directory instead of reading it as a text file.
  [FLTKAda-BUGS.md 108](FLTKAda-BUGS.md#108-file_browserload-couldnt-be-called-as-a-procedure-with-its-default-sort).
- **`Valuators.Set_Step_Top` and `Set_Step_Bottom`, and
  `Counters.Set_Step_Top`, are obsolescent.** They still work, and do
  what they did; `Set_Step (This, To)` is the new name for both, with a
  `Long_Float` or an `Integer`. GNAT warns of a call to them only with
  `-gnatwj`, and only on a `Valuator` or `Counter` object, not on a
  type derived from one, so this stops a compile only with `-gnatwe` too.
  A type of the program's own, derived from `Valuator`, that declares its
  own `Set_Step (This, To)` now overrides FLTKAda's.
  [FLTKAda-BUGS.md 99](FLTKAda-BUGS.md#99-set_step_top-and-set_step_bottom-each-set-the-whole-step).

- **`Input_Choice.Set_Item` takes a `Menus.Index`, counting from 1**, as
  `Has_Item` and `Item` do, not an `Integer` counting from 0. Its
  parameter is `Place`, not `Num`. A call with a literal still compiles,
  but chooses the item before the one it used to (`Set_Item (1)` is now
  the first). It raises `Constraint_Error` for an item that doesn't exist.
  [FLTKAda-BUGS.md 92](FLTKAda-BUGS.md#92-input_choiceset_item-read-past-the-menu-and-counted-from-0).
- **`Font_Kind` is an integer type** (`new Natural`), not an enumeration.
  It can now name any font FLTK has, not only the 17 built-in ones. The
  built-in names are constants, so calls that name a font still compile.
  `'Succ`, `'Pos`, `'Image`, `case` without `others`, and arrays indexed
  by `Font_Kind` do not.
  [FLTKAda-BUGS.md 88](FLTKAda-BUGS.md#88-font_kind-could-name-only-the-17-built-in-fonts),
  [FONT_KIND_ISSUE.md](FONT_KIND_ISSUE.md).
- **`File_Choosers.Chooser_Kind` is a private bit mask**, as FLTK's is,
  so kinds combine with `"+"`, as in `Multi + Create`. `Single`, `Multi`,
  `Create` and `Directory` are now constants, not enumeration literals, so
  `case` and the enumeration attributes no longer compile on them.
  [FLTKAda-BUGS.md 86](FLTKAda-BUGS.md#86-a-file_choosers-kind-was-an-enumeration-not-fltks-bit-mask).
- **`Text_Buffers.Next_Char` and `Prev_Char` return a `Position`**, as
  FLTK's do, not a `Character`.
  [FLTKAda-BUGS.md 78](FLTKAda-BUGS.md#78-text_buffersnext_char-and-prev_char-returned-a-character).
- **`Menus.Add (This, Text)` with one string is now `Add_Items`**, in
  `Menu` and in `System_Menu_Bar`. No call to the old name could compile,
  since the other `Add` takes the same two parameters.
  [FLTKAda-BUGS.md 65](FLTKAda-BUGS.md#65-menus-one-string-add-cant-be-called).
- **`Text_Displays.Styles.Style_Entry` has three more components**,
  `Back_Mode`, `Lines` and `Background`, and the layout of FLTK's
  struct. The new components have defaults, but a positional aggregate
  of three no longer compiles.
  [FLTKAda-BUGS.md 7](FLTKAda-BUGS.md#7-text_displays-style_entry-had-the-wrong-layout).
- **`Box_Kind` has FLTK 1.4's twelve Oxy box types**, `Oxy_Up_Box` to
  `Oxy_Button_Down_Box`, inserted before `Free_Box`. `Free_Box`'s position
  changes, and a `case` without `others` needs the new arms.
  [FLTKAda-BUGS.md 31](FLTKAda-BUGS.md#31-box_kind-lacks-fltk-14s-oxy-box-types-so-free_box-is-wrong).
- **`Event_Kind` ends with `Zoom_Gesture` and `Zoom_Event`**, so a
  `case` without `others` needs the new arms.
  [FLTKAda-BUGS.md 32](FLTKAda-BUGS.md#32-event_kind-lacks-fl_zoom_gesture-and-fl_zoom_event).
- **`FLTK.Contrast` takes two more parameters, `Context` and `Size`.**
  Both default to 0, so calls are unchanged, but a renaming or an
  `'Access` with the old profile no longer matches.
  [PLAN.md, Phase 8](PLAN.md#phase-8-core-statics-done-2026-11-04).

## Changes that can make a program behave differently

- **`Draw.OpenGL.Draw_Image` draws depth 1 as grey and depth 2 as grey
  and alpha, and draws rows of any length straight**, where FLTK's
  `gl_draw_image` drew depths 1 and 2 as RGB and rows not a multiple of
  4 bytes askew, reading past the data either way. It raises
  `Constraint_Error` for a `Depth` over 4, a `Line_Size` under
  `W * Depth` or not a multiple of `Depth`, and data too short, and
  draws nothing for an image with no width or height.
  [FLTKAda-BUGS.md 28](FLTKAda-BUGS.md#28-guards-written-as-pre-or-predicates-are-off-in-release-builds),
  [FLTK-issues.md F40](FLTK-issues.md#f40-gl_draw_image-reads-past-its-data).
- **`Filenames.Item`, `Environment.Entry_Key` and `Group_Name`, and
  `Animated_GIF.Frame_Image` raise `Constraint_Error` for an index past
  the last** in a release build, as their `Pre` did in a debug build.
  Before, a release build read outside FLTK's arrays, or for
  `Frame_Image` gave an image with no FLTK object.
  [FLTKAda-BUGS.md 28](FLTKAda-BUGS.md#28-guards-written-as-pre-or-predicates-are-off-in-release-builds).
- **`Static.Default_Window_Close` of a widget with no FLTK object
  raises `Program_Error`.** Before, a release build passed null to
  FLTK, and a debug build raised `Internal_FLTK_Error`.
  [FLTKAda-BUGS.md 28](FLTKAda-BUGS.md#28-guards-written-as-pre-or-predicates-are-off-in-release-builds).
- **Every preferences database is opened with FLTK's `C_LOCALE`
  flag**, so floating point is written with a point and read the same
  way whatever `LC_NUMERIC` says. A file written before by a program
  with a decimal comma, such as one in a German locale, has its
  floating point read up to the comma.
  [PLAN.md, Phase 25](PLAN.md#phase-25-large-programs-done-2026-11-12).
- **A text editor binds Ctrl+Shift+Z to the new `KF_Redo`**, as FLTK
  does. Before, that key did nothing.
  [PLAN.md, Phase 25](PLAN.md#phase-25-large-programs-done-2026-11-12).
- **`Events.Last_Key` and `Original_Last_Key` give a key past
  16#FFFF# whole**, such as X11's XF86MonBrightnessUp, 16#1008FF02#.
  Before, they gave its low 16 bits, which is another key. A shortcut
  (`Set_Shortcut`, a menu item's) of such a key now raises
  `Constraint_Error`, since `Fl_Shortcut` can't hold it; before, its
  high bits became modifiers.
  [FLTKAda-BUGS.md 135](FLTKAda-BUGS.md#135-keys-past-16ffff-came-out-as-other-keys).
- **`Color_Choosers.Set_RGB` and `Set_HSV` set the color they are
  given.** Before, they set one made of whatever was in the integer
  registers.
  [FLTKAda-BUGS.md 134](FLTKAda-BUGS.md#134-color_choosers-set_rgb-and-set_hsv-set-nonsense).
- **A text editor's newest binding of a key wins**, and
  `Remove_Key_Binding` of a key removes only that newest binding, as in
  FLTK. Before, the oldest won, so a program's own binding of a key the
  defaults bind (Ctrl+a, Ctrl+c, …) was never called, and the removal
  took every binding of the key.
  [FLTKAda-BUGS.md 128](FLTKAda-BUGS.md#128-a-text-editors-oldest-key-binding-won).
- **`Tooltips.Enter_Area` with a text, tooltips enabled, waits for the
  widget's window to be exposed** if it is shown and not yet on the
  screen (on X11, mapped), running the event loop until then. Before,
  a tooltip there ended the program on Wayland.
  [PLAN.md, Phase 19](PLAN.md#phase-19-fixes-for-pofltk-147-to-159-done-2026-11-11).
- **`Text_Editors.Set_Tab_Mode (Insert_Char)` always makes Tab type a
  tab**, however many times `Widget_Focus` was set before. Before, it
  undid only one of them.
  [FLTK-issues.md F35](FLTK-issues.md#f35-fl_text_editortab_nav-1-twice-needs-tab_nav-0-twice).
- **`Environment.Userdata_Path` raises `Preference_Error`** when the
  directory couldn't be made. Before, it returned the name, as FLTK
  does.
  [PLAN.md, Phase 19](PLAN.md#phase-19-fixes-for-pofltk-147-to-159-done-2026-11-11).
- **`Inputs.Index` raises `Constraint_Error`** for a position outside
  `0 .. Size`, where FLTK read outside the text. Its `Constraint_Error`
  for a character past U+00FF now says so; `Wide_Wide_Index` gives one.
  [FLTKAda-BUGS.md 125](FLTKAda-BUGS.md#125-inputsindex-of-a-character-past-u00ff).
- **`Text_Displays.Set_Linenumber_Format` raises `Constraint_Error`**
  for a format other than `%%` and at most one `d i o u x X`
  conversion (with flags, width and precision). FLTK passes it to
  `snprintf` with one `int`.
  [PLAN.md, Phase 19](PLAN.md#phase-19-fixes-for-pofltk-147-to-159-done-2026-11-11).
- **`Menus.Popup`, `Menus.Pulldown` and `Menu_Buttons.Popup` raise
  `Program_Error`** for a menu in no window when no window is shown.
  Before, FLTK crashed there.
  [PLAN.md, Phase 19](PLAN.md#phase-19-fixes-for-pofltk-147-to-159-done-2026-11-11).
- **`Filenames.Get_Listing` raises `Ada.IO_Exceptions.Name_Error`** for
  a directory it can't list. Before, it returned a list whose `Length`
  raised `Constraint_Error`.
  [FLTKAda-BUGS.md 124](FLTKAda-BUGS.md#124-get_listing-of-a-directory-that-cant-be-listed).
- **A callback, `Draw` or other hook that raises has what it pushed
  undone** as the exception leaves it: clips (`Push_Clip`,
  `Push_No_Clip`), matrices, current surfaces, begun offscreens,
  started pages and `OpenGL.Start`. Before, they stayed pushed, and FLTK
  drew the rest of the window with them. A program that popped them in
  its own handler before re-raising still works.
  [PLAN.md, Architecture decisions, 7](PLAN.md#architecture-decisions).
- **A `Postscript_File_Device` finalized in a job ends the job**, and
  its page if one is open, as a PDF surface does. The file is then
  complete. Before, nothing was written to it.
  [FLTKAda-BUGS.md 121](FLTKAda-BUGS.md#121-a-postscript-device-finalized-in-a-job-left-its-file-empty).
- **`End_Job` of a `Postscript_File_Device` or a `Printer` in a page
  ends the page first.** The device stops being the surface drawn on,
  and drawing goes back to where it went before the page. Before, the
  device stayed current, and later drawing went to the ended job. If
  ending the page raises `Page_Error`, the job is not ended.
  [FLTKAda-BUGS.md 123](FLTKAda-BUGS.md#123-end_job-in-a-page-left-the-device-current).
- **`Text_Display.Position_To_XY` gives `Vert_Out` the right way
  round:** True when the position is out of view, False when it is
  shown. Before, it was the opposite.
  [FLTKAda-BUGS.md 109](FLTKAda-BUGS.md#109-text_displayposition_to_xy-gave-vert_out-the-wrong-way-round).
- **Some setters that did nothing now work:** `Text_Editor.Set_Tab_Mode`,
  `Table.Set_Tab_Mode`, `Table.Set_Scrollbar_Size`, the three
  `Tooltips` margin and wrap setters, and `System_Menu_Bar.Update`. Their
  getters, and `Scroll.Recalculate_Scrollbars`, now give FLTK's values.
  [FLTKAda-BUGS.md 110](FLTKAda-BUGS.md#110-the-shims-fltk_abi_version-guards-made-some-calls-do-nothing).
- **`Tree_Items.Child` raises `Constraint_Error` for a place past the
  last child.** Before, it read past FLTK's array and returned a bad
  handle.
  [FLTKAda-BUGS.md 111](FLTKAda-BUGS.md#111-tree_itemschild-read-past-fltks-array).
- **`Table.Get_Row_Height`, `Set_Row_Height`, `Get_Column_Width` and
  `Set_Column_Width` raise `Range_Error` for a row past `Get_Rows` or a
  column past `Get_Columns`.** Before, the getters raised
  `Internal_FLTK_Error`, `Set_Column_Width` grew FLTK's widths silently,
  and `Set_Row_Height` wrote past FLTK's array.
  [FLTKAda-BUGS.md 112](FLTKAda-BUGS.md#112-a-tables-row-heights-and-column-widths-took-any-row-or-column).
- **`Table.Bounding_Region` raises `Constraint_Error` for a context
  other than `Row_Header`, `Column_Header` and `Dead_Zone`.** Before,
  it printed a message from FLTK and returned uninitialised values.
  [FLTKAda-BUGS.md 113](FLTKAda-BUGS.md#113-tablebounding_region-gave-uninitialised-values-for-most-contexts).
- **`Scroll.Set_Kind` sets the kind it is given.** Before, it set the
  next one down, so `Vertical` gave a horizontal scrollbar and
  `Horizontal` none. A program that compensated will now get the wrong
  scrollbars.
  [FLTKAda-BUGS.md 114](FLTKAda-BUGS.md#114-scrollset_kind-set-the-wrong-kind-of-scrollbars).
- **`Environment` stores and reads `Binary_Data` by the byte.** Before,
  its length was divided by the size of a pointer, so short data was
  stored as nothing and longer data cut short; a preferences file
  written by the old binding holds those shortened values. A `Get` of a
  missing entry now gives its default.
  [FLTKAda-BUGS.md 118](FLTKAda-BUGS.md#118-preferences-binary_data-entries-counted-bytes-in-pointers).
- **`Environment.Get` of a `String` with `Max_Length` gives up to
  `Max_Length` characters**, one more than before, and cuts a default
  to that length too.
  [FLTKAda-BUGS.md 119](FLTKAda-BUGS.md#119-preferences-get-of-a-string-with-max_length-gave-one-character-fewer).
- **`Help_Views.Current_Directory` and `Current_File` give "" when there
  is none**, where they raised `Interfaces.C.Strings.Dereference_Error`.
  [FLTKAda-BUGS.md 120](FLTKAda-BUGS.md#120-help_view-current_directory-and-current_file-raised-with-no-file).
- **`Draw.Draw_Image` and `Draw_Image_Mono` flip correctly, raise
  `Constraint_Error` for too little data, and draw nothing for a width
  or height below 1.** Before, a flipped image drew the wrong pixels,
  too little data raised `Assertion_Error` only in a build with
  assertions, and a negative size raised `Foreign_Exception`. The data
  now needs `(H - 1) * Line_Size + W * Depth` bytes, a little less than
  the old check's `Line_Size * H`.
  [FLTKAda-BUGS.md 117](FLTKAda-BUGS.md#117-flipped-images-drew-the-wrong-pixels-and-read-before-their-data),
  [FLTK-issues.md F34](FLTK-issues.md#f34-fl_draw_image-with-a-negative-width-or-height-throws).
- **`Data_Size` of an RGB image or bitmap is the size of its data**,
  `Get_Data_W` by `Get_Data_H`, not the size it is drawn at, which
  `Scale` changes. `All_Data` of a scaled image is shorter accordingly.
  [FLTKAda-BUGS.md 115](FLTKAda-BUGS.md#115-data_size-of-a-scaled-image-was-its-drawn-size).
- **The pixel data of an SVG image rasterizes it**, if it hasn't been
  drawn, and `Data_Size` raises `No_Image_Error` if an RGB image has no
  data. Before, reading an undrawn SVG's data crashed.
  [FLTKAda-BUGS.md 116](FLTKAda-BUGS.md#116-the-pixel-data-of-an-svg-image-not-yet-drawn).
- **`Check_Browser.Selected_Index` returns `Natural`, and 0 when no
  item is selected.** Before, it returned `Positive` and raised
  `Constraint_Error` then. A call still compiles; an `'Access` with the
  old profile no longer matches.
  [FLTKAda-BUGS.md 107](FLTKAda-BUGS.md#107-check_browserselected_index-raised-when-nothing-was-selected).
- **`Set_Flags` leaves `Submenu` as it was on an item in a menu.**
  `Menus.Set_Flags`, `System_Menu_Bar.Set_Flags`, and `Menu_Item.Set_Flags`
  on an item in a menu no longer take a title's `Submenu` flag away, or
  give it to another item. An item not yet in a menu still sets it.
  [FLTKAda-BUGS.md 106](FLTKAda-BUGS.md#106-set_flags-could-change-a-menus-shape).
- **A widget freed in a callback run by FLTK is hidden at once**, and
  its window redrawn without it. Before, the window went on showing it.
  [FLTKAda-BUGS.md 104](FLTKAda-BUGS.md#104-a-widget-freed-in-a-callback-goes-on-being-drawn).
- **`Help_View.Load` no longer raises when the link callback answers the
  page itself**, by `Set_Content` or `Load`, and refuses the name.
  Before, it raised `Load_Help_Error` with the page shown. A refusal
  that sets nothing still raises.
  [FLTKAda-BUGS.md 102](FLTKAda-BUGS.md#102-help_viewload-raises-for-a-page-the-link-callback-answered).
- **`Copy` on an `Image'Class` copies the image.** Each kind of image
  overrides `Image`'s `Copy`, so a dispatching call gives a bitmap,
  pixmap, RGB image and so on, with the data. Before, it gave an empty
  `Image`. A type of the program's own, derived from one of these, that
  declares a `Copy` returning `Image'Class` now overrides FLTKAda's.
  [FLTKAda-BUGS.md 101](FLTKAda-BUGS.md#101-copy-on-an-imageclass-gives-an-empty-image).
- **`Set_Label ("")` leaves a widget with no label**, as `Forge.Create`
  with `""` does, not with an empty one. FLTK puts an image with an
  empty label above where it puts one with none, so an image in such a
  widget now sits lower, centred. A window's `Set_Label` is unchanged.
  [FLTKAda-BUGS.md 98](FLTKAda-BUGS.md#98-set_label--gives-a-widget-an-empty-label-not-a-null-one).
- **`FLTK.Screen` numbers every screen 1 .. `Count`.** `Containing`
  returns one more than it did, and the `Screen_Num` forms of
  `Work_Area` and `Bounding_Rect` take 1 for the first screen, not 0.
  These three, and `DPI`, raise `Constraint_Error` for a number outside
  1 .. `Count`. `DPI` counted from 1 already.
  [FLTKAda-BUGS.md 97](FLTKAda-BUGS.md#97-fltkscreen-numbers-screens-from-1-in-some-calls-and-from-0-in-others).
- **A slider's `Set_Box` and `Get_Box` are the frame's, and the knob's
  box is `Set_Slider_Box` and `Get_Slider_Box`.** This holds for every
  slider, `Value_Slider` and `Scrollbar` among them. A call to `Set_Box`
  meant for the knob still compiles, but now sets the frame.
  [FLTKAda-BUGS.md 94](FLTKAda-BUGS.md#94-sliderset_box-sets-the-knob-even-through-widgetclass).

- **`Menu.Has_Item` is false for a terminator**, the textless entry
  that ends a submenu or the menu, and iterating over a menu steps over
  them. `Input_Choice.Has_Item` follows. `Number_Of_Items` and `Item`
  still count them, so `Has_Item (Number_Of_Items)` is now False.
  [FLTKAda-BUGS.md 93](FLTKAda-BUGS.md#93-menuhas_item-counts-the-terminator).

- **An exception raised in a callback or an overridden `Draw` or
  `Handle` no longer unwinds through FLTK's C++.** FLTKAda saves the
  exception and raises it again once control is back in Ada: in `Wait`,
  `Check`, `Run`, a dialog, a menu `Popup`, and the like.
  [FLTKAda-BUGS.md 43](FLTKAda-BUGS.md#43-an-exception-raised-in-a-hook-unwinds-through-fltk),
  [PLAN.md, Architecture decisions](PLAN.md#architecture-decisions).
- **Guards that were `Pre` aspects are now explicit checks**, which
  raise in release builds too. The exception is `Constraint_Error` or a
  package's own exception, not `Assertion_Error`. For example, `RGB_Image`
  and `Bitmap` `Create` raise `Constraint_Error` for data that is too
  short, and PostScript's `Start_Job` raises `File_Open_Error` for a file
  that isn't open.
  [PLAN.md, Architecture decisions](PLAN.md#architecture-decisions), 1;
  [Phase 5](PLAN.md#phase-5-overruns-from-bad-input-done-2026-11-03).
- **Results that could be "none" are now `Natural`, with 0 for none.**
  These are `Tables.Callback_Row`, `Callback_Column`, `Get_Selection`'s
  `out` parameters, and `Textline.Get_Top_Line`. They used to raise. A
  caller that stores one in a `Positive` still compiles, but raises
  `Constraint_Error` on a 0.
  [FLTKAda-BUGS.md 8](FLTKAda-BUGS.md#8-table-callback_row-callback_column-and-get_selection-raised-on--1),
  [60](FLTKAda-BUGS.md#60-get_top_line-raised-constraint_error-for-a-browser-with-no-top-line).
- **`Draw.Dash_Length` is 1 to 127**, not 1 to 255. FLTK passes each
  length as a signed `char`, so longer dashes were drawn wrongly.
  [PLAN.md, Phase 5](PLAN.md#phase-5-overruns-from-bad-input-done-2026-11-03) (pofltk 136).
- **The `Buffer` argument of `Text_Buffer`'s file operations is
  `Positive`**, not `Natural`. With a buffer of 0, FLTK read nothing.
  [FLTKAda-BUGS.md 80](FLTKAda-BUGS.md#80-a-text_buffer-file-error-gave-the-wrong-reason).
- **`Text_Buffers.Get_Highlight` returns what FLTK highlights**, which
  is 0 and 0 when nothing is highlighted. Before, it returned whatever
  `Set_Highlight` last set.
  [FLTKAda-BUGS.md 79](FLTKAda-BUGS.md#79-text_buffersget_highlight-gave-what-set_highlight-last-set).
- **A widget FLTK made itself is no longer given an Ada object.**
  `Parent` of such a widget, `Get_Top_Modal`, `Get_First_Window` and
  `Get_Next_Window` give null for it or skip it. `Group.Child` of one
  raises `Internal_FLTK_Error`.
  [FLTKAda-BUGS.md 51](FLTKAda-BUGS.md#51-parent-of-a-widget-in-a-group-fltk-made-reads-that-groups-user-data-as-ada).
- **`Highlight_Data` raises `Constraint_Error`** for a style table that
  is empty or doesn't start at `'A'`. It also copies the table.
  [FLTKAda-BUGS.md 47](FLTKAda-BUGS.md#47-highlight_data-ignored-where-the-style-table-starts).
- **A browser's `Set_Icon` keeps a copy of the image, and the icon
  follows its line** when lines are inserted, moved or swapped.
  `Get_Icon` of a line with no icon raises `Constraint_Error`.
  [FLTKAda-BUGS.md 42](FLTKAda-BUGS.md#42-browser-icons-that-dangle-and-dont-follow-their-lines).
- **`Menus.Use_Same_Items` copies the donor's items**, as `Set_Items`
  does, so later changes to one menu no longer show in the other.
  [FLTKAda-BUGS.md 38](FLTKAda-BUGS.md#38-menusset_items-and-staticclipboard_contains-pass-the-wrong-thing),
  [PLAN.md, Phase 2](PLAN.md#phase-2-fltkadas-own-memory-safety-bugs-done-2026-11-03).
- **`Group.Clear` removes only the children Ada added**, and keeps the
  ones FLTK made, such as a `Spinner`'s input and buttons.
  [FLTKAda-BUGS.md 27](FLTKAda-BUGS.md#27-spinner-and-color_chooser-inherited-operations-reach-the-wrong-widget).
- **`Environment.Flush` raises `Preference_Error`** when the file can't
  be written. Before, the failure was ignored.
  [FLTKAda-BUGS.md 12](FLTKAda-BUGS.md#12-preferences-flush-gave-no-result).
