# Incompatible changes

The changes in FLTKAda that can stop a program written for upstream
FLTKAda from compiling, or make it behave differently. "Upstream" is
Jedidiah Barber's last commit, `2c15b31` (2025-04-14). Newest changes
come first in each list.

## Changes that can stop a program compiling

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
