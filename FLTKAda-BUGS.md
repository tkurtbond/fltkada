# FLTKAda bugs found while porting FLTK 1.4.5's examples

Sections 1 to 14 are fixed bugs. Sections 15 to 30 are **open**: they
were found on 2026-11-03 by reading FLTKAda's code against pofltk's
`doc/fltk-issues.md` (see PLAN.md, "The issue triage"). They have not yet
been confirmed by running anything. Sections 31 and 32 were found by
`test_constants` (PLAN.md, Phase 0) and are fixed. Section 16 is fixed
(PLAN.md, Phase 2). The kept-pointer audit found sections 33 to 38
(PLAN.md, Phase 2), and all six are fixed. Sections 43 to 45 came from
N12 (PLAN.md, Phase 2): 43 is fixed, 44 and 45 are open. Section 46
was found by valgrind in Phase 2 and is fixed. When one is fixed,
replace its "Status" with "Fix" and "Verified", as in sections 1 to
14. When one turns out not to be a bug, say so in its section rather
than deleting it.
Numbers like "pofltk 16" refer to `~/Repos/Oberon/pofltk/doc/fltk-issues.md`.
Numbers like "F1" refer to `FLTK-issues.md` here.

Sections 1 to 14 turned up while porting every program in FLTK 1.4.5's
`examples/` directory to Ada (see `examples/`). Each
port was checked by building the original C++ program next to the Ada port
and running both under the same private Xvfb display:

- screenshots were compared with `compare -metric AE`, aiming for 0
  differing pixels;
- stdout and stderr were diffed;
- valgrind, strace or gdb were used where those were relevant.

Sections 9 to 12 and 14 turned up later, in a program using the binding
(ova_cg_ada).
Section 13 is a bug in FLTK itself, which the binding works around.


## 1. Text_Editor: every key binding with a modifier was dead

**Symptom.** In an `FLTK.Widgets.Groups.Text_Displays.Text_Editors.Text_Editor`,
no key combination using Shift, Ctrl, Alt or Meta did anything. That
includes shift-selection, Ctrl+C/V/X/Z/A and Ctrl+Home/End.

**Cause.** The binding removes FLTK's C++ key bindings and sends every key
through `default_key_function_`, so that the Ada key-binding table is the one
that applies. But `Fl_Text_Editor::handle_key` only calls
`default_key_function_` when no modifier is held, so modified keys never
reached Ada. Also, `Key_Func_Hook`'s modifier mask included NumLock and
CapsLock, so even keys without a modifier failed to match while NumLock was
on.

**Fix.**
- `fl_text_editor_handle` in `body/c_fl_text_editor.cpp` now calls
  `default_key_function_` itself for an unhandled `FL_KEYBOARD` event that
  has modifiers.
- `Key_Func_Hook` in `body/fltk-widgets-groups-text_displays-text_editors.adb`
  masks the state down to Shift/Ctrl/Alt/Meta, and uses `Default_Func` only
  when no modifier is held, as the C++ code does.

**Verified.** In texteditor-with-dynamic-colors, a typing, selecting,
cutting and pasting session gives AE 0 against C++.


## 2. Widgets got an empty label `""` instead of no label (NULL)

**Symptom.** Three different effects:
- In table-simple, the cell text was 14pt instead of 16pt.
- In howto-simple-svg and animgifimage, an image on an unlabelled Box was
  drawn offset.
- Message and ask dialogs (`FLTK.Asks`) lost their "i", "?" or "!" icon
  letter.

**Cause.** `Widget.Extra_Init` in `body/fltk-widgets.adb` always called
`copy_label (Text)`. So every widget created without a label got the label
`""` rather than NULL, and that included the C++-owned widgets the binding
wraps, such as Table's scrollbars and the `fl_message_icon()` template box.
FLTK treats a `""` label differently from NULL:
- `Fl_Label::draw` calls `fl_font` even for `""`. This reset the font set in
  Table's `Start_Page` before the cells were drawn.
- `Fl_Widget::draw_label` positions an image differently when there is a
  label.
- The elaboration of `body/fltk-asks.adb` calls `fl_box_extra_init` on
  `fl_message_icon()`. `Fl_Message` copies the template's label into each
  dialog's icon, so each dialog copied `""` instead of the icon letter.

**Fix.** When `Text` is empty, `Extra_Init` sets the label to NULL.

**Verified.** table-simple, howto-flex-simple (including its dialog),
howto-simple-svg and animgifimage-simple give AE 0. A regression run over
every port also gave AE 0.


## 3. Windows created with a parent and a position were invisible

**Symptom.** A subwindow created with
`Forge.Create (Parent, X, Y, W, H, Text)` never appeared. This was found by
opengl3test, whose GL panel is such a subwindow.

**Cause.** `Fl_Window (x, y, w, h)` calls `clear_visible ()` when it is
constructed with no current group. Under a current group a C++ subwindow
stays visible. The binding constructs the window first and only then calls
`Parent.Add`, so the window was always built without a parent and stayed
invisible.

**Fix.** In all eight window bodies (`body/fltk-widgets-groups-windows*.adb`),
this overload now calls `This.Set_Visible` after `Parent.Add`. The `(W, H)`
overloads are unchanged, since FLTK always calls `clear_visible` for them.


## 4. `handle()` results other than 0 or 1 raised Internal_FLTK_Error

**Symptom.** Internal_FLTK_Error was raised from event handling. howto-remap-numpad-keyboard-keys
hit this, because `Fl_Input::handle` returns 2 for some keys.

**Cause.** Every conversion of a C++ `handle()` result to Ada used
`Event_Outcome'Val`, which only accepts 0 and 1.

**Fix.** Any nonzero result now means `Handled`. The conversion was changed
in:
- `fltk-events`
- `fltk-widgets`
- the text editor's `Handle_Key`
- positioners
- dials
- sliders


## 5. Every program polled the clipboard twice a second, forever

**Symptom.** Every FLTKAda program woke up twice a second, even when idle.
In howto-drag-and-drop, the Ada port logged twice as many `FL_DND_DRAG`
events as the C++ program, because each wakeup inside `Fl::dnd()`'s loop
delivered an extra event.

**Cause.** The elaboration of `FLTK.Static` registered its
`Clipboard_Notify_Hook` with `Fl::add_clipboard_notify`, before the display
was open. On X11, FLTK then can't tell whether XFixes is available. It falls
back to a self-rearming 0.5 s `clipboard_timeout`, which never stops.

**Found with** strace, which showed the `pselect6` timeouts, and gdb, which
showed `Fl::add_timeout` being called from `adainit`.

**Fix.** In `body/fltk-static.adb`, the hook is now registered when the first
Ada clipboard handler is added, and removed when the last one is removed.


## 6. Menu_Item labels dangled

**Symptom.** A menu item's label was a dangling pointer once the Ada string
it came from had gone. For menu-owned items, `Fl_Menu_::clear` would then
`free()` that pointer, which pointed into the Ada stack.

**Cause.** `Forge.Create`, `Set_Label` and `Set_Label (Kind, ...)` stored
FLTK pointers to Ada temporaries.

**Fix.** The shim, `body/c_fl_menuitem.cpp`, now `strdup`s text labels. It
frees the previous text label, unless the label type is an image or multi
label, in:
- `set_label`
- `set_label2`
- `image`
- `multi_label`
- `free_fl_menu_item`

This also fixes the leak that the C++ example avoids by hand before calling
`item->image ()`.

**Verified.** howto-menu-with-images: valgrind reports 0 errors and 0 bytes
definitely lost. All scenarios give AE 0 against C++.


## 7. Text_Displays Style_Entry had the wrong layout

**Symptom.** Style tables passed to a Text_Display were read wrongly by
FLTK.

**Cause.** `FLTK.Widgets.Groups.Text_Displays.Styles.Style_Entry` didn't
match `Fl_Text_Display::Style_Table_Entry`. Hue was at byte 4, and the record
was 16 bytes long instead of 20.

**Fix.** The layout now matches the C++ struct. The `attr` and `bgcolor`
fields were added as `Back_Mode`, `Lines` and `Background`.


## 8. Table Callback_Row, Callback_Column and Get_Selection raised on -1

**Symptom.** Constraint errors (Internal_FLTK_Error) in the table-spreadsheet
ports:
- when clicking the dead zone of a table;
- when clicking a header.

**Cause.** These functions returned `Positive`, but FLTK uses -1 to mean
"none":
- for the callback row or column on `CONTEXT_TABLE` (`Fl_Table.cxx:872`,
  `:1171`);
- for the selection and current row or column after a header click
  (`Fl_Table.cxx:883`).

**Fix.** They now return `Natural`, with 0 meaning none. The spec comments
and `doc/fl_table.html` say so.


## 9. Preferences: Forge.Root crashed

**Symptom.** `Forge.Root` of a database gave a group whose first use raised
Storage_Error (a segmentation fault in libfltk).

**Cause.** `new_fl_pref_group_copy` made the group with `new
Fl_Preferences(e)`, `e` being a `void *`. Fl_Preferences' `ID` is `void *`,
so that is the `Fl_Preferences(ID)` constructor, which takes the database
for a group's ID, not the copy constructor. A plain copy would not do
either: the copy shares the database's root node, and `~Fl_Preferences`
deletes the root node when its node has no parent, so the group and the
database would both delete it.

**Fix.** The group is a `My_Root_Group`, copied from the database, whose
destructor forgets its node before `~Fl_Preferences` runs; the database
still owns and deletes the root node.

**Verified.** `test/preferences.adb` sets, reads back, and frees the group
both before and after its database, and reads the file from a second
database; it passes with no errors or leaks under `valgrind --leak-check=full`.


## 10. Textline_Browser: Set_Column_Widths raised Constraint_Error

**Symptom.** Every call of `Set_Column_Widths` raised Constraint_Error
(an index check in `body/fltk-widgets-groups-browsers-textline.adb`).

**Cause.** The binding keeps its own copy of the widths, one longer than
`Widths` for the terminating 0, and the copying loop ran over the copy's
range instead of `Widths`', so it read one past the end of `Widths`.

**Fix.** The loop runs over `Widths'Range`, so `Widths` may also start at
an index other than 1.

**Verified.** `test/column_widths.adb` sets three widths, then one, then
two from an array indexed 5 .. 6, and reads each back; before the fix its
first call raised.


## 11. Groups leaked the children FLTK made itself

**Symptom.** Freeing a Text_Display (or Text_Editor) lost its two
scrollbars, 184 bytes each, under valgrind; so did a Tree, and a Table its
scrollbars and inner group, and an Input_Choice its input and menu button.

**Cause.** `Group.Extra_Final` took every child out of the group before the
C++ destructor ran, so that `~Fl_Group` would not delete children that
their Ada objects delete. But that also took out the children the C++
constructor made with `new`, which only `~Fl_Group` deletes. (Browser,
Scroll, Spinner and the rest keep theirs as C++ members, which take
themselves out of the group when they are destroyed, so they did not
leak.)

**Fix.** `Group.Extra_Init` records the children the group already has
when it is made, which are FLTK's, and `Extra_Final` takes out every child
but those, leaving them for the C++ destructor. `Group.Clear` is
unchanged.

**Verified.** `test/group_children.adb` frees a Text_Display alone and with
a Box added to it (the Box outlives it, in no group), and a Tree whose Box
was freed first; under `valgrind --leak-check=full` it lost six scrollbars
before the fix and nothing after. Creating and freeing each composite group
(the browsers, Color_Chooser, Help_View, Input_Choice, Scroll, Spinner,
Terminal, Text_Display, Text_Editor, Tree, Row_Table) shows no errors and
no leaks from the binding; what Terminal still loses is fontconfig's and
pango's, allocated by FLTK's font code.


## 12. Preferences: Flush gave no result

**Symptom.** A preferences file that could not be written went unnoticed:
`Flush` was a procedure, and the C binding dropped the result of
`Fl_Preferences::flush`.

**Fix.** `fl_preferences_flush` returns that result, and `Flush` raises
`Preference_Error` when it is -1 (the file could not be written), as the
package's other operations do on failure; 0 (written) and 1 (nothing to
write) return normally.

**Verified.** `test/preferences.adb` flushes a database whose file is under
`/proc`, where no directory can be made; it raises Preference_Error, and
the check fails when `Flush` ignores the result.


## 13. FLTK's own bug: glut.H and libfltk_gl disagree on glutExtensionSupported

FLTK 1.4.5's `FL/glut.H` declares `glutExtensionSupported (char *)`, but the
library defines and exports `glutExtensionSupported (const char *)`. Because
these are C++ functions, the two declarations are mangled differently, and
a call compiled against the header doesn't link. `body/c_fl_glut.cpp`
declares the `const char *` version itself to work around this.


## 14. The installed shared library refused -Xlibrary_type=dynamic

**Symptom.** After `make install-dynamic install-static`, a project that
withs the installed `fltkada.gpr` could not ask for the shared library
with `-Xlibrary_type=dynamic`, the value `fltkada.gpr` and readme.md use
for it; only `relocatable` and `static` were accepted.

**Cause.** gprinstall makes the installed project's build variable a type
whose values are the `--build-name`s, and `install-dynamic` installed the
shared library as `--build-name=relocatable`.

**Fix.** `install-dynamic` (and the readme's example) uses
`--build-name=dynamic`, so the installed `fltkada.gpr` has
`type BUILD_KIND is ("dynamic", "static")`, defaulting to `dynamic`.

**Verified.** Installed with `make install-dynamic install-static
GPRINSTALL=...` into `/usr/local/sw/versions/ada`, next to arg_parser and
libfyaml_ada, whose files it left unchanged: a program withing all three
builds and runs with no `-X` and with `-Xlibrary_type=dynamic`, both
loading `lib/fltkada.dynamic/libfltkada.so`, and with
`-Xlibrary_type=static`, linking no `libfltkada.so`;
`-Xlibrary_type=relocatable` is refused.


# Open bugs (found 2026-11-03, not yet confirmed by a run)

"Checked" below means the code was re-read by hand after the triage agent
reported it; the rest are the agent's reading only. PLAN.md gives the phase
each is fixed in.


## 15. Value_Input and Input_Choice probably crash on the first key or menu pick

**Expected symptom.** Typing into a `Value_Input`, or picking an item from
an `Input_Choice`'s menu, crashes or corrupts memory. Neither widget is
used by any program in `test/` or `examples/`, which would explain why
nobody has seen it.

**Cause.** Both wrap the parts FLTK made: the inner `Fl_Input`, and
`Input_Choice`'s menu button. Wrapping runs `Widget.Extra_Init`, which
stores the Ada record's address in the part's `user_data`
(`body/fltk-widgets.adb:690-692`). But FLTK's own callbacks for those parts
use `user_data` to find the C++ parent: `Fl_Value_Input::input_cb`
(`src/Fl_Value_Input.cxx:28`, set at `:120` with `input.callback(input_cb,
this)`), and `Fl_Input_Choice::inp_cb`/`menu_cb`
(`src/Fl_Input_Choice.cxx:206, 237`, set at `:266, 270`). They would cast
an Ada record to `Fl_Value_Input*` or `Fl_Input_Choice*`. `Table` avoids
this for its scrollbars by replacing their callbacks
(`body/fltk-widgets-groups-tables.adb:801, 812`). See also F2 in
`FLTK-issues.md`.

**Planned fix.** After wrapping, put the C++ parent back in the part's
`user_data`. Find the Ada wrapper some other way, for example through
the parent, or route the part's callback through Ada as `Table` does.
Test: `Probe.Key` into a `Value_Input`, and `Probe.Mouse` on an
`Input_Choice` menu.

**Fix.** Each constructor in the shim (`body/c_fl_value_input.cpp`,
`body/c_fl_input_choice.cpp`) keeps FLTK's callback for the part and
installs a thunk that calls it with the part's `parent()` as the data.
`user_data` stays the Ada record. The fix is in the shim, not Ada,
because only C++ can call FLTK's private static callbacks, through the
pointer `callback()` returns.

**Confirmed.** `test/unit/test_part_callbacks.adb`, 2026-11-03. The
symptom was as expected: before the fix, typing "7" into a `Value_Input`
left its value 0 and its callback unrun, and typing into an
`Input_Choice` raised `Storage_Error`. After it, all ten checks pass on
Xvfb and sway, and valgrind is clean. The test picks the menu item by its
shortcut rather than with `Probe.Mouse`, which would open a pop-up.

**Status.** Fixed.


## 16. Strings FLTK keeps were passed as temporaries

**Expected symptom.** A label, tooltip, filter or symbol name shows
garbage later, or valgrind reports reads of freed memory.

**Cause.** These pass `Interfaces.C.To_C (...)`, a temporary that is gone
once the call returns, to an FLTK function that keeps the pointer:
- `Window.Set_Icon_Label` and `Set_Labels` → `Fl_Window::iconlabel`
  (pofltk 5).
- `Tooltips.Enter_Area` → `Fl_Tooltip::enter_area`
  (`body/fltk-tooltips.adb:241-247`; checked) (pofltk 75).
- `File_Browser.Set_Filter` → `Fl_File_Browser::filter` (pofltk 37).
- `File_Choosers.Forge.Create` title → `window->label(title)`
  (`src/Fl_File_Chooser.cxx:269`; checked).
- `Asks.File_Chooser` and `Dir_Chooser` titles → the static chooser's
  label (pofltk 30).
- `Draw.Add_Symbol` → `fl_add_symbol` keeps the name, and every later
  `@` symbol lookup `strcmp`s against it (`body/fltk-draw.adb:1208-1216`;
  checked) (pofltk 123).

**Planned fix.** Use FLTK's `copy_*` method where one exists. Otherwise
keep a copy, either in the Ada record (freed in `Extra_Final`) or in a
`static std::string` in the shim. Then audit every other `To_C`/
`New_String` passed to the shim for the same problem (PLAN.md Phase 2).

**Fix.** Each string is now kept for as long as FLTK may read it.
- **Window icon label**: in the record (`My_Icon_Label`). It is replaced
  only after FLTK holds the new copy. `Extra_Final` gives FLTK a null
  pointer before freeing the copy.
- **File_Browser filter** (`My_Filter`): kept the same way.
- **File_Chooser title**: in the existing `My_Label`.
- **Tooltip text**: in the shim. The old copy is freed only once FLTK
  holds the new one, never on an empty text (FLTK-issues.md F4).
- **Ask chooser title**: in one static `std::string` in the shim.
- **Symbol names**: in a static `std::set<std::string>` in the shim.

`Add_Symbol` now raises `Draw_Error` for a name a label could never use:
- an empty one;
- one holding an `@` or a byte outside ASCII;
- one starting `#`, `$`, `%` or a digit;
- one starting `-` or `+` then 1 to 9.

`Draw_Symbol` refuses a name outside ASCII, since FLTK's hash goes
negative for one (pofltk 123).

**Test.** `test/unit/test_kept_strings.adb`. It builds each string at run
time, scribbles over the stacks, and reads the value back from FLTK.
Against the old binding, 15 checks fail. Every value came back as `X`s,
or as `5hooser 5` for the chooser title, the refusals raised nothing, and
the symbol was never drawn. Two of the cases can't fail that way and
rest on valgrind and FLTK's source:
- the tooltip, whose window is private;
- the ask choosers' title, which FLTK keeps only after the dialog
  closes.

**Verified.** 2026-11-03. The test passes under Xvfb and on headless sway,
and valgrind finds no invalid accesses and no FLTKAda leaks. `make
check-headless`, `check-sway` and `valgrind-headless` pass.

**Status.** Fixed. The audit of every other `To_C`/`New_String` passed to
the shim found the bugs in sections 33 to 38 (PLAN.md, Phase 2).


## 17. Help_View: the link hook frees its answer while FLTK still uses it

**Expected symptom.** With a link callback set, loading a page after a page
that had an `<IMG>` opens a file whose name is freed memory. A link callback
that returns `""` for an image crashes.

**Cause.** The link hook keeps one buffer, `Hilda`, and frees it on
every call (`body/fltk-widgets-groups-help_views.adb:265`; checked).
`Fl_Help_View::load` gets `localname` from the link function, then calls
`free_data()`. That calls `get_image` for each image, which calls the link
function again, which frees `Hilda`. Only then does `load` call
`fl_fopen(localname)` (`src/Fl_Help_View.cxx:3408-3431`, `:2531`;
checked). See F1. Separately, the hook maps `""` to NULL, and FLTK's
`format()` dereferences a NULL image name (pofltk 90).

**Planned fix.** Keep every answer for the life of the view, as pofltk
does with a cache, freed in `Extra_Final`. Return `""`, not NULL, for an
image (pofltk's `in_image` flag).

**Status.** Open. PLAN.md Phase 2.


## 18. Table: widgets added to cells are freed twice

**Expected symptom.** When a `Table` is finalized before an Ada widget
added to it, the widget is deleted by FLTK and then again by Ada.

**Cause.** `Table.Extra_Final` calls `Group.Extra_Final`. That walks the
`Fl_Table`'s real children, which are only its scrollbars and inner
`Fl_Scroll`, so Ada children added to the cells are never detached.
`~Fl_Scroll` then deletes them. Also, `Group.Remove (Place)` isn't
overridden, so on a `Table` it removes one of the table's own parts
(pofltk 52).

**Planned fix.** Detach cell children in `Table.Extra_Final`, and override
`Remove (Place)`. Test as `test/group_children.adb` does, under valgrind.

**Status.** Open. PLAN.md Phase 2.


## 19. Text_Buffer: its callbacks outlive the Ada buffer

**Expected symptom.** If an Ada `Text_Buffer` is finalized while a display
still holds the C++ buffer, the next edit calls into a freed Ada record.

**Cause.** `Text_Buffer.Finalize` (`body/fltk-text_buffers.adb:569-576`)
never removes the modify and predelete callbacks it registered with
`This'Address` (`:596-603`). The C++ buffer itself is reference-counted
and survives (pofltk 34).

**Planned fix.** Remove both callbacks in `Finalize`.

**Status.** Open. PLAN.md Phase 2.


## 20. Textline_Browser: icons aren't kept alive, and the icon list drifts

**Expected symptom.** A browser line's icon is drawn from a freed image
after the Ada image is finalized. `Has_Icon` and `Get_Icon` report the
wrong lines after lines are inserted, removed, moved or swapped.

**Cause.** `Set_Icon` (`body/fltk-widgets-browsers-textline.adb:991-1006`)
stores only the C++ pointer, in a wrapper that doesn't own it. The `Icons`
vector is never shifted by `Insert`, `Remove`, `Move`, `Swap`, `Clear` or
`Load` (pofltk 56).

**Planned fix.** Hold a reference to each icon image, and keep `Icons` in
step with the lines, or look the icon up from FLTK's line.

**Status.** Open. PLAN.md Phase 2.


## 21. Font_Sizes reads the wrong entries

**Expected symptom.** `FLTK.Static.Font_Sizes` returns wrong sizes and
reads past the end of FLTK's array.

**Cause.** `fl_static_font_size_array_get` (`body/c_fl_static.cpp:226-228`;
checked) returns `*(a+((i-1)*sizeof(int)))`. Pointer arithmetic on an
`int*` already scales by `sizeof(int)`, so this reads entry `4*(i-1)`.

**Planned fix.** `return a[i-1];`.

**Status.** Open; checked. PLAN.md Phase 2.


## 22. Draw_Image's line callback sees only part of the line

**Expected symptom.** An Ada `Image_Draw_Function` for a colour image
(depth 3 or 4) can fill only the first third or quarter of each line.

**Cause.** `Draw_Image_Hook` (`body/fltk-draw.adb:1045-1056`; checked, and
the mono hook near `:1123`) overlays a buffer of `W` components. FLTK's
line buffer holds `W * abs (Depth)` bytes.

**Planned fix.** Pass the depth to the hook (or keep it beside
`Image_Func_Ptr`), and size the buffer `W * abs (Depth)`. While there,
refuse re-entry: a nested `Draw_Image` from the callback replaces the
single global `Image_Func_Ptr` (pofltk 133).

**Status.** Open; checked. PLAN.md Phase 2.


## 23. Expand_Text always fails

**Expected symptom.** `FLTK.Draw.Expand_Text` raises `Dereference_Error`
(or reads garbage) for any text that isn't empty.

**Cause.** `Expand_Text` (`body/fltk-draw.adb:1485-1502`; checked) passes
`maxbuf = 0` and expects FLTK to return the buffer it allocated in
`Buffer`. The shim takes `char *&buf` (`body/c_fl_draw.cpp:287`), but
`fl_expand_text` takes `buf` by value and passes it to the internal
`expand_text_ (…, char *&buf, …)`, so the allocation never reaches the
caller (pofltk 125).

**Planned fix.** Have the shim allocate a buffer large enough
(`strlen + 4` plus a margin) and pass its size as `maxbuf`.

**Status.** Open; checked. PLAN.md Phase 2.


## 24. Local_To_Mac_Roman and Mac_Roman_To_Local write to NULL and over-read

**Expected symptom.** The first non-empty call crashes. Later calls return
text with trailing garbage, and `Local_To_Mac_Roman` converts only the
first byte.

**Cause.** Both pass `n = -1` (`body/fltk-draw.adb:690-704`,
`body/c_fl_draw.cpp:49, 53`) and read the result with `Value (ptr)`, but
FLTK's result isn't NUL-terminated. FLTK's own part is pofltk 126.

**Planned fix.** As pofltk does: call with `n = 0` first, convert a byte
at a time, and return `Value (ptr, len)`.

**Status.** Open. PLAN.md Phase 2.


## 25. Shadow, engraved, embossed and round box and label types draw as plain

**Expected symptom.** `test/hello.adb` asks for `Shadow_Label` and gets an
ordinary label. Round, oval, plastic and gtk boxes draw as placeholders.

**Cause.** In C++, `FL_SHADOW_LABEL`, `FL_ROUND_UP_BOX` and so on are
macros that call `fl_define_FL_*()` before yielding the value, which
installs the drawing function on first use. FLTKAda passes the raw
enumeration value (`fl_widget_set_box`, `fl_widget_set_labeltype` in
`body/c_fl_widget.cpp`, and menu item label kinds), so nothing installs
them. Only `c_fl_multi_label.cpp` defines its label type (pofltk 8).

**Planned fix.** Call the `fl_define_FL_*` functions once in the shim
before any box or label type is set. Test with `Probe.Capture`.

**Status.** Open. PLAN.md Phase 6.


## 26. Set_Label with a label kind doesn't dispatch

**Expected symptom.** `Set_Label (Some_Window, Kind, Text)` on a window
already shown doesn't change its title.

**Cause.** `Widget.Set_Label (This, Kind, Text)` (`body/fltk-widgets.adb:1231-1238`)
calls `This.Set_Label (Text)` statically, so a `Window` reaches
`Fl_Widget::copy_label` instead of `Fl_Window::copy_label`, which is
FLTKAda's override (pofltk 6).

**Planned fix.** `Widget'Class (This).Set_Label (Text)`.

**Status.** Open. PLAN.md Phase 6.


## 27. Spinner and Color_Chooser: inherited operations reach the wrong widget

**Expected symptom.**
- `Set_Colors` on a `Spinner` colours the group, not its field.
- `Clear` on a `Spinner` or `Color_Chooser` removes the parts FLTK made,
  leaving a dead widget.

**Cause.** Neither overrides the inherited operation (pofltk 13, 23).
`Spinner`'s format string also goes to `snprintf` as a format.

**Planned fix.** Override them, and validate the format.

**Status.** Open. PLAN.md Phases 4 and 6.


## 28. Guards written as Pre or predicates are off in release builds

**Expected symptom.** A check meant to keep bad values away from FLTK,
such as `FLTK.Filenames.Path_String`'s 2048-byte limit (pofltk 121), does
nothing unless the calling program is built with `-gnata`. The library's
own `Pre` and `pragma Assert` are never checked in a release build.

**Cause.** The release build has no `-gnata` (`proj/common.gpr:62`).

**Planned fix.** Write guards that prevent memory errors as explicit
checks that raise (PLAN.md, "Architecture decisions", 1).

**Status.** Open. Applies throughout the fix phases.


## 29. Exceptions raised in callbacks cross FLTK's C++ frames

**Expected symptom.** Unknown. An exception from an Ada callback, or from
a draw or handle override, unwinds through FLTK's C++ frames, or
terminates the program, or leaves FLTK half-way through an event.

**Cause.** `Callback_Hook` (`body/fltk-widgets.adb:605-612`) and the other
hooks called from C++ have no exception handler.

**Planned fix.** Decide after an experiment, which PLAN.md Phase 0 runs
(Open question 2, decided 2026-11-03). Phase 2 implements the choice.

**Status.** Open.


## 30. GLUT: a Glut_Window with a parent that isn't a GLUT window

**Expected symptom.** `GLUT.Get (Window_Parent)` misreads memory for a
`Glut_Window` made with `Forge.Create (Parent => ...)` whose parent isn't
an `Fl_Glut_Window`.

**Cause.** The Ada `Forge.Create` accepts any `Group` as parent
(`spec/fltk-widgets-groups-windows-opengl-glut.ads:35`), but `glutGet`
casts the parent to `Fl_Glut_Window`. Related GLUT liveness problems are
pofltk 112.

**Planned fix.** Require a `Glut_Window` parent, or make `Get` refuse
otherwise.

**Status.** Open. PLAN.md Phase 4.


## 31. Box_Kind lacks FLTK 1.4's Oxy box types, so Free_Box is wrong

**Symptom.** `Box_Kind'Pos (Free_Box)` is 56, but FLTK 1.4.5's
`FL_FREE_BOXTYPE` is 68. Found by `test_constants` on its first run
(2026-11-03), which prints
`FAIL - Box_Kind'Pos (Free_Box) = FL_FREE_BOXTYPE: FLTKAda has 56, FLTK 68`.

**Cause.** FLTK 1.4 added twelve box types for the "oxy" scheme,
`_FL_OXY_UP_BOX` (56) to `_FL_OXY_BUTTON_DOWN_BOX` (67), between the
Gleam ones and `FL_FREE_BOXTYPE` (`FL/Enumerations.H`). `Box_Kind` in
`spec/fltk.ads` still ends `Gleam_Round_Down_Box, Free_Box`. Effects,
from FLTK's source and FLTKAda's:

- Ada code can't name the Oxy boxes.
- `Free_Box` is FLTK's `_FL_OXY_UP_BOX`. So `Set_Box_Draw_Function` for
  `Free_Box` (`body/fltk-box_draw_marshal.adb`) overwrites
  `fl_box_table[56]`, one of FLTK's own box types, instead of a free one
  (`Fl::set_boxtype`, `src/fl_boxtype.cxx`).
- A widget given an Oxy box from C++ makes `Box_Kind'Val` raise
  `Constraint_Error` in every getter that converts a box. There are 15
  such conversions, in 9 bodies, among them `Get_Box` and
  `Filled`/`Frame`/`Down`.

**Fix.** `Box_Kind` has the twelve, `Oxy_Up_Box` to
`Oxy_Button_Down_Box`, before `Free_Box`. `body/fltk-box_draw_marshal.adb`
has their draw and hook instances and `case` arms. `gen-constants.py`
checks each one.

**Verified.** 2026-11-03. `test_constants` passes, including
`Free_Box = FL_FREE_BOXTYPE = 68`. `make check-headless`, `check-sway`,
`valgrind-headless` and `smoke-headless` pass.


## 32. Event_Kind lacks FL_ZOOM_GESTURE and FL_ZOOM_EVENT

**Symptom.** A program with an Ada global handler (`FLTK.Events.Add_Handler`)
gets `Internal_FLTK_Error` when the user zooms. FLTK's zoom shortcut,
Ctrl with + or -, sends `Fl::handle (FL_ZOOM_EVENT, NULL)`
(`src/Fl_Screen_Driver.cxx:574`). `Event_Handler_Hook`
(`body/fltk-events.adb:423`) converts 27 with `Event_Kind'Val`, which
raises `Constraint_Error`, and the hook turns that into
`Internal_FLTK_Error`. `test_constants` prints
`FAIL - Event_Kind'Pos (Event_Kind'Last) = FL_ZOOM_EVENT: FLTKAda has 25, FLTK 27`.

**Cause.** FLTK 1.4 added `FL_ZOOM_GESTURE` (26, sent on macOS,
`src/Fl_cocoa.mm:1046`) and `FL_ZOOM_EVENT` (27) to `Fl_Event`.
`Event_Kind` ends at `Fullscreen` (25). The same `'Val` is in the
dispatch hook (`body/fltk-events.adb:476`), in `Widget.Handle`'s hook
(`body/fltk-widgets.adb:633`) and in `FLTK.Events`' current-event getter
(`body/fltk-events.adb:831`).

**Confirmed.** A scratch program, run under Xvfb on 2026-11-03, adds an
Ada handler and calls `Fl::handle (FL_ZOOM_EVENT, 0)` from C++. The
handler is never called. `Internal_FLTK_Error` ("Event_Handler hook
received unexpected event int value of 27") reaches the Ada handler
around the C++ call. The C++ line after `Fl::handle` never runs, so the
exception unwound through FLTK's frames. That is one data point for the
N12 experiment (section 29).

**Fix.** `Event_Kind` ends `Fullscreen, Zoom_Gesture, Zoom_Event`.
Still open: the hooks fail on an event number from a later FLTK. That
goes with N12 (section 29), and `test_constants`' `Event_Kind'Last`
check fails first when FLTK adds one.

**Verified.** 2026-11-03. `test_constants` passes. Run again, the scratch
program's handler is called once, and `Fl::handle` returns 0 to the C++
line after it. The same four `make` targets pass.


## 33. Set_Font_Kind frees the old font name before FLTK is done with it

**Expected symptom.** valgrind reports a read of freed memory in
`Fl::set_font`, and fonts change unpredictably.

**Cause.** There are two overloads.
- **`Set_Font_Kind (Target, Source : String)`**
  (`body/fltk-static.adb:1186-1193`) frees `Font_Overrides (Target)` and
  then calls `Fl::set_font`. `Fl::set_font` compares the new name with
  the old one, which has already been freed (`src/fl_set_font.cxx:45-67`).
- **`Set_Font_Kind (Target, Source : Font_Kind)`** makes both entries
  share one name pointer. A later string `Set_Font_Kind` of `Source` then
  frees the name that `Target` still uses (pofltk 130).

**Found.** By the kept-pointer audit, 2026-11-03.

**Fix.** The string overload frees the old copy only after `Fl::set_font`
holds the new one. The `Font_Kind` overload gives the target its own copy
of the source's name (`Font_Image (Source)`). The shim's
`fl_static_set_font` is now unused.

**Test.** `test/unit/test_font_kinds.adb`. After each change, the test
scribbles over the heap with strings of the same size. Against the old
binding:
- the copied kind reads `Mono 4`, the source's *new* name, where
  `Monospace 3` was expected;
- valgrind reports 18 invalid reads, all in `strcmp` from
  `Fl_Cairo_Graphics_Driver::font_name`.

**Verified.** 2026-11-03. All five checks pass under Xvfb, and valgrind
reports no invalid reads and no FLTKAda leaks.

**Status.** Fixed.


## 34. Menu Set_Label on a menu whose items FLTK didn't copy

**Expected symptom.** A menu item shows garbage after `Set_Label`.

**Cause.** `Menus.Set_Label (Place, Text)` and the System_Menu_Bar one
pass a `To_C` temporary to `Fl_Menu_::replace`. That copies the text only
when `alloc > 1` (`src/Fl_Menu_add.cxx:472-480`, checked). After
`Set_Items` (`copy()`, alloc 1) or `Use_Same_Items` (`menu(m)`, alloc 0),
FLTK keeps the temporary (pofltk 5, 26).

**Found.** By the kept-pointer audit, 2026-11-03.

**Fix.** Each `Set_Label` passes a `New_String` copy. The shim's
`fl_menu_replace` and `fl_sys_menu_bar_replace` return two things: whether
FLTK kept the pointer (`menu()[i].text == t` after `replace`), and the
text it replaced. The menu's record keeps the copies FLTK holds
(`My_Labels`), and frees one once its item is relabelled. `Extra_Final`
points any item still using a kept label at a static `""`, using
`fl_menu_forget_text`, before it frees the label. The shim also checks
the index now: `replace` checks it, but the old code would have read past
the array to find the replaced text.

**Test.** `test/unit/test_menu_labels.adb`. Before the fix, four checks
failed: every label of a menu sharing another's items came back as `X`s,
on a `Choice` and on a `System_Menu_Bar`.

**Verified.** 2026-11-03. All six checks pass under Xvfb and on headless
sway. Valgrind reports no invalid accesses and no FLTKAda leaks, so the
relabelled copies are freed.

**Still open.** `Use_Same_Items` and `copy()` share the donor's text
pointers. When the donor menu owns its strings and is deleted, its
`clear()` frees them (`src/Fl_Menu_.cxx:563-580`). A menu that took its
items, or a private copy of them, then shows freed text. This is from
FLTK's source; no program has checked it. It belongs with section 38.
(Fixed there, 2026-11-03: both now give the menu its own copy of the
items and texts, and `test_menu_items` checked it, so a sharing menu no
longer reaches the path where FLTK keeps the label.)

**Status.** Fixed, with the item sharing fixed in section 38.


## 35. File_Chooser label setters free a label existing choosers still show

**Expected symptom.** An existing `File_Chooser` shows garbage, or
valgrind reports freed reads, after a static label setter runs.

**Cause.** These setters free the old string and then set the new one:
- `Set_Show_Label`, `Set_Favorites_Label`, `Set_Preview_Label`;
- `Set_Hidden_Label`, `Set_Filename_Label`, `Set_Save_Label`;
- `Set_Manage_Favorites_Label`, `Set_New_Directory_Tooltip`.

They are at `body/fltk-file_choosers.adb:721-933`. An existing chooser's
widgets were given the old pointer by FLTK's constructor, for example
`showChoice->label(show_label)` (`src/Fl_File_Chooser.cxx:181`, checked).
pofltk doesn't list this.

**Found.** By the kept-pointer audit, 2026-11-03.

**Fix.** These eight setters now set the new copy first. Then they put
the old one on a list, which the package's final controller frees. A
chooser can't be counted on to go away sooner. The ask functions'
chooser is a static that FLTK never deletes (`src/fl_file_dir.cxx:23`),
and it keeps the labels it was built with. The other six setters free
the old copy after the new one is set. FLTK reads those labels only
during a call:
- `add_favorites_label`, `all_files_label`, `custom_filter_label` and
  `filesystems_label` are copied by a menu `add`;
- `existing_file_label`, `new_directory_label` and `custom_filter_label`
  are passed to `fl_alert`, `fl_input` or `strcmp`.

This was checked in `Fl_File_Chooser2.cxx`. The list is a plain linked
list, not a container. The body's objects are finalized before the
spec's `Cleanup`, so a container would already be empty when `Cleanup`
runs.

**Test.** `test/unit/test_chooser_labels.adb` sets every label and makes
a chooser. Then it sets them all again and scribbles over the heap with
strings of the same size. Last, it shows the chooser and looks for the
first labels with `FLTK.Probe.Has_Label`. That function searches every
window's widgets for a label or tooltip. Against the old binding:
- the show, favorites, filename and tooltip checks fail;
- valgrind reports 135 errors, 13 of them invalid reads.

The preview and hidden labels happened to survive the scribbling. The
save and manage-favorites labels are in the favorites window, which the
test doesn't open, so for them the fix rests on valgrind and on FLTK's
source.

**Verified.** 2026-11-03. All six checks pass under Xvfb and on sway.
Valgrind reports no invalid reads, and `vg-check.sh` passes: what's left
is fontconfig's and Pango's leaks.

**Status.** Fixed.


## 36. Printer dialog label setters free strings the kept panel still shows

**Expected symptom.** The second print dialog shows garbage after a
static setter such as `Set_Dialog_Title` runs.

**Cause.** The `fl_printer_set_*` setters
(`body/fltk-devices-surface-paged-printers.adb:429-717`) free the old
string. FLTK builds the print panel once from those pointers
(`src/print_panel.cxx:249`) and keeps it
(`src/drivers/Posix/Fl_Posix_Printer_Driver.cxx:282`). pofltk doesn't
list this.

**Found.** By the kept-pointer audit, 2026-11-03.

**Fix.** These are the setters for labels that become a constructor label
of the panel or of its properties panel. There are eighteen; every
setter but `Set_Dialog_Print_To_File` is one. Each now sets the new copy
first and puts the old one on a list, which the final controller frees,
as in §35. `dialog_print_to_file` is copied by
`print_choice->add` (`print_panel.cxx:530`), so its setter frees the old
copy after the new one is set. GTK's dialog reads `dialog_title` only
during the call (`Fl_Posix_Printer_Driver.cxx:133`).

**Test.** `test/unit/test_printer_labels.adb`. It turns off
`OPTION_PRINTER_USES_GTK` through the test-only
`FLTK.Probe.Set_Printer_Uses_GTK`, since FLTKAda's `Option` type lacks
it. It sets every label and starts a job, which builds the panel, and a
timeout cancels the job with `Close_Modal`. Then it sets the labels
again, scribbles over the heap, starts a second job, and looks for the
first labels with `Has_Label`. Against the old binding:
- all twelve of the panel's checks fail;
- valgrind reports 270 errors, 22 of them invalid reads.

The six property labels are in the properties panel, which isn't shown.
For them the fix rests on valgrind and on FLTK's source.

**Verified.** 2026-11-03. All fourteen checks pass under Xvfb and on
sway. Valgrind reports no errors at all.

**Status.** Fixed.


## 37. Leaks of strings FLTK keeps for good

**Cause.** FLTK keeps the pointer, so FLTKAda's copy must stay alive, but
nothing ever frees it, even at exit or when the widget goes.
- **GLUT `Set_Icon_Title`, `Add_Menu_Entry`, `Add_Sub_Menu` and
  `Change_To_*`** (`body/fltk-glut.adb:855, 1013-1041`). GLUT keeps
  `i->text = label` and never frees it (pofltk 112).
- **`Spinner.Set_Format`**: `Format_Str` is never freed in `Finalize`
  (`body/fltk-widgets-groups-spinners.adb:233-241, 494-501`) (pofltk 13).

**Found.** By the kept-pointer audit, 2026-11-03.

**Fix.** `body/fltk-glut.adb` keeps every text it gives GLUT and frees
each once GLUT has let go of it:
- **Menu texts.** `Menu_Texts` holds one vector per menu, one text per
  item, in item order.
  - `Add_*` appends to the current menu's vector.
  - `Change_To_*` replaces the item's text and frees the old one.
  - `Remove_Menu_Item` deletes the item and frees its text, following
    `glutRemoveMenuItem`'s shift (`glut_compatibility.cxx:382-387`).
  - `Destroy_Menu` frees the menu's texts, since `glutDestroyMenu`
    deletes its items (`:322-328`).
  - A `Change_To_*` past the end of the menu, which GLUT writes past its
    array (pofltk 112, PLAN.md Phase 4), keeps its text until exit.
- **Icon titles.** `Icon_Titles` holds each window's last title. A new
  title frees the old one, once GLUT has the new one. The title is freed
  at once when there's no current window, because `glutSetIconTitle` then
  ignores it (`FL/glut.H:139-140`). It is also freed:
  - by `Destroy_Window`;
  - when `Create_Window` or `Create_Sub_Window` reuses the number. GLUT
    reuses only a number whose window is gone, which covers subwindows
    deleted along with their parent.
- **At exit.** A controller in the body, declared after the vectors so
  it is finalized before them, frees what is left. That includes `Init`'s
  copy of argv. `glutInit` keeps the strings (`initargv`, `:204-206`) and
  takes FLTK's own options out of argv (`:207-211`), so `Init` records
  every string it made, not just what argv holds afterwards.

`Spinner.Set_Format` now frees the old copy after FLTK has the new one.
`Extra_Final` gives FLTK a static `"%g"`, Fl_Spinner's own default
(`Fl_Spinner.cxx:116`), and then frees the copy. It does this only for a
Spinner the object owns (`Needs_Dealloc`), because one it doesn't own may
outlive it.

**Test.** There are two:
- `test/unit/test_glut_strings.adb` adds, changes and removes menu items,
  sets icon titles before and after the window is shown, and destroys
  the window and the menus;
- `test/unit/test_spinner_format.adb` sets the format of a lone Spinner
  and of one in a window twice each.

GLUT has no way to read a menu's texts back, so both rest on valgrind.
Against the old binding, `vg-check.sh` reports the lost menu texts and
icon titles, and the two lost formats.

That needed a fix to `test/vg-check.sh` first. It took the allocator to
be the first frame after `malloc` and `__gnat_malloc`, and for a string
made with `New_String` that frame is `interfaces.c.strings.new_string`,
in GNAT's runtime. So every FLTKAda leak through `New_String` passed,
including all of this section's. vg-check.sh now skips GNAT's runtime
frames too (PLAN.md, Phase 0, negative controls).

**Verified.** 2026-11-03. Both tests pass under Xvfb and on sway. Under
valgrind there are no invalid reads, and vg-check.sh finds no FLTKAda
leak.

**Status.** Fixed.


## 38. Menus.Set_Items and Static.Clipboard_Contains pass the wrong thing

These are not lifetime bugs. The audit found them on the way.
- **`Menus.Set_Items`** (`body/fltk-widgets-menus.adb:750-764`) passes an
  array of item *pointers* to `fl_menu_copy`, which treats it as an array
  of `Fl_Menu_Item` structs. Even passing structs, `copy()` would share
  text that `free_fl_menu_item` frees (`body/c_fl_menuitem.cpp:30-62`).
- **`Static.Clipboard_Contains`** (`body/fltk-static.adb:1362-1366`) passes
  `To_C (Kind)`, but FLTK compares the pointer with
  `Fl::clipboard_plain_text` and `Fl::clipboard_image`. So the answer is
  always False on Wayland (`src/drivers/Wayland/fl_wayland_clipboard_dnd.cxx:51`),
  and on X11 when this program owns the selection (`src/Fl_x.cxx:724`).

- **`Menus.Use_Same_Items`**, and `System_Menu_Bar`'s, which
  `Input_Choice`'s calls, set the menu to the donor's own array with
  `menu(m)` (alloc 0, `src/Fl_Menu_.cxx:522-526`). The donor frees that
  array when it is deleted or when `add()` outgrows it
  (`src/Fl_Menu_add.cxx:55-60`), and frees a text when it relabels the
  item (`src/Fl_Menu_add.cxx:475-480`). This is the item sharing left open
  in section 34.

**Found.** By the kept-pointer audit, 2026-11-03. `Use_Same_Items` by
section 34.

**Fix.**
- The shim's new `fl_menu_set_items` takes the item pointers and a
  count. It copies the items, up to where `Fl_Menu_Item::size` would stop
  and with terminators for any submenu left open, and `strdup`s their
  texts, except image and multi labels, which `clear()` doesn't free
  either. It installs the copy with `menu()` and sets `alloc` to 2, as if
  the items had been added, so `clear()` frees the array and the texts.
  `alloc` is protected and has no setter, so the shim reaches it through
  a pointer to member formed in a class derived from `Fl_Menu_`. It
  returns an error when out of memory, and the Ada side raises
  `Storage_Error`. `fl_menu_copy` and the null item it needed are gone.
- `fl_menu_set_menu` and `fl_sys_menu_bar_set_menu` give the menu the
  same kind of copy of the donor's items. So `Use_Same_Items` no longer
  shares: later changes to either menu don't show in the other (PLAN.md,
  Phase 2). `Fl_Sys_Menu_Bar::menu` hides `Fl_Menu_::menu`, but off macOS
  its driver only calls `Fl_Menu_Bar::menu` (`src/Fl_Sys_Menu_Bar_Driver.H:42`),
  and the shim calls `update()` after. macOS is not checked.
- `fl_static_clipboard_contains` replaces a kind whose text is
  `Fl::clipboard_plain_text`'s or `Fl::clipboard_image`'s with FLTK's
  own pointer.

**Test.**
- `test/unit/test_menu_items.adb` sets a `Choice`'s items from
  `Menu_Item`s that are then finalized, and gives a `Choice` and a
  `System_Menu_Bar` a donor's items. The donor relabels an item, adds 20
  more and goes. The heap is scribbled over, and the labels and counts are
  read back. Then the menus grow and relabel. Before the fix, `Set_Items`
  gave a menu of 18 items instead of 4, with garbage labels, and then
  `STORAGE_ERROR`. With only `Use_Same_Items` unfixed, the sharing menu
  had 8 items, then `STORAGE_ERROR`, and valgrind reported 50 invalid
  reads in the donor's freed array.
- `test/unit/test_clipboard_kinds.adb` copies text to the clipboard and
  asks whether it holds `"text/plain"`, `"image"` and an unknown kind.
  Before the fix, the first check failed under Xvfb and on sway.

**Verified.** 2026-11-03. Both tests pass under Xvfb and on headless
sway. Under valgrind they have no invalid reads, and `vg-check.sh`
passes them.

**Status.** Fixed.

## 39. Table's cell widgets freed twice, and Remove by place and Find wrong

**Symptom.**
- A `Table` finalized before the Ada widgets in its cells deleted them,
  and Ada then freed them again (PLAN.md N9).
- `Remove (Place)` on a `Table` removed one of its scrollbars or its
  inner `Fl_Scroll`, which then leaked.
- `Find` of a widget not in the table returned an index two past the
  last child instead of `No_Index`.

**Cause.** An `Fl_Table`'s own children are its two scrollbars and an
inner `Fl_Scroll`; the cell widgets are the inner group's. `Fl_Table`'s
child methods forward to it, but hide `Fl_Group`'s instead of overriding
them (`FL/Fl_Table.H:775-880`, pofltk 52).
- `Table.Extra_Final` only ran `Group`'s, which walks the `Fl_Table`'s
  own children, all three made by FLTK. The cell widgets stayed in the
  inner group, and `~Fl_Group` deleted them.
- `Table` didn't override `Remove (Place)`, so `Group`'s called
  `Fl_Group::remove (int)` on the `Fl_Table` (`fl_group_remove2`).
- `Fl_Table::find` returns the inner group's `find`, which is that group's
  child count when not found. That is two more than `Fl_Table::children`
  (`FL/Fl_Table.H:870`), and `Table.Find` compared it with `=`.

**Found.** N9 in the issue triage; `Find` by its test, 2026-11-03.

**Fix.** `Group`'s detaching loop is now the private
`Remove_Ada_Children`, and `Table.Extra_Final` runs it on the inner
`Scroll` (`Playing_Area`) before `Group`'s. `Table` overrides
`Remove (Place)` to remove its `Place`th cell widget; like
`Fl_Group::remove (int)`, a place out of range removes nothing.
`Table.Find` treats any result from the table's count up as not found.

**Test.** `test/unit/test_table_children.adb` removes by place through
`Group'Class`, lets a table go before the widgets in its cells, and lets
widgets made in a table go before it. Before the fix, the four checks of
`Remove` failed, and valgrind reported invalid reads in
`fl_widget_get_parent` and `free_fl_button` as the buttons were
finalized after the table, and two blocks lost from `Fl_Table`'s
constructor (`Fl_Table.cxx:169, 178`), the scrollbar and inner group
`Remove` took out. With only `Find` unfixed, its check failed.

**Verified.** 2026-11-03. All 12 checks pass under Xvfb and on headless
sway, valgrind reports no errors, and `vg-check.sh` passes it.

**Status.** Fixed.

## 40. A Text_Buffer let go while a display holds it is called back

**Symptom.** After an Ada `Text_Buffer` is finalized while a
`Text_Display` still holds its C++ buffer, any edit through the display
calls the Ada buffer's modify and predelete hooks with the freed
record's address (PLAN.md N10).

**Cause.** The C++ buffer is reference counted (`body/c_fl_text_buffer.cpp`),
so it lives on in the display. `Forge.Create` gave it the two hooks with
`This'Address` as their data, and `Finalize` never removed them.

**Found.** N10 in the issue triage (pofltk 34).

**Fix.** `Text_Buffer.Finalize` removes both hooks
(`fl_text_buffer_remove_modify_callback`,
`fl_text_buffer_remove_predelete_callback`, new in the shim) before it
lets go of the C++ buffer.

**Test.** `test/unit/test_buffer_life.adb` edits through a display a
buffer allocated on the heap, frees the Ada buffer, and edits again.
Before the fix, valgrind reported invalid reads in
`predelete_callback_hook`, from `Fl_Text_Buffer::insert`.

**Verified.** 2026-11-03. All five checks pass under Xvfb and on headless
sway, valgrind reports no errors, and `vg-check.sh` passes it.

**Status.** Fixed. `Text_Display.Get_Buffer` still returns the freed
record in this case; that is 41.

## 41. Text_Display.Get_Buffer after its Ada buffer is gone

**Symptom.** `Get_Buffer` returns a reference to the Ada `Text_Buffer`
last given to `Set_Buffer`, even after that record has been finalized
and freed, while the display still shows the C++ buffer.

**Cause.** `Set_Buffer` keeps `Buff'Unchecked_Access`
(`body/fltk-widgets-groups-text_displays.adb:949`), and nothing clears it
when the buffer goes.

**Found.** By reading, while fixing 40, 2026-11-03. Not yet shown by a
test.

**Status.** Open. A fix would have the buffer know its displays, or have
`Get_Buffer` raise once the buffer is gone.

## 42. Browser icons that dangle and don't follow their lines

**Symptom.** A `Textline_Browser` line whose icon's image had been
finalized drew freed memory. After `Insert`, `Remove`, `Move`, `Swap`,
`Clear` or `Load`, `Get_Icon` and `Has_Icon` answered for the line that
used to have that number, and an image was freed while another line still
showed it (PLAN.md N11).

**Cause.** `Fl_Browser::icon(line, img)` keeps the plain pointer and
never deletes it (Fl_Browser.cxx:892-913). `Set_Icon` passed the
caller's image and kept only an access to it in `Icons`, a vector indexed
by line number that nothing but `Set_Icon` and `Remove_Icon` changed.

**Found.** N11 in the issue triage (pofltk 56).

**Fix.** `Set_Icon` gives FLTK a copy (`Image.Copy`) that the browser
owns. `Has_Icon` and `Get_Icon` ask FLTK which image the line shows,
through a new `fl_browser_get_icon` (`Fl_Browser::icon(line)`,
Fl_Browser.cxx:922-925), and look for the copy with that pointer; so an
icon follows its line however lines move. A private `Drop_Icons` frees
the copies no line shows; `Set_Icon`, `Remove_Icon`, `Remove`, `Clear`
and both browsers' `Load` call it. `Get_Icon` of a line with no icon
raises `Constraint_Error`.

**Test.** `test/unit/test_browser_icons.adb` sets icons from images that
go out of scope, draws, and checks each line's icon width after each
kind of line change, a replaced icon, a removed one, `Clear`, and an
icon from a temporary. Before the fix five checks failed and valgrind
reported 162 errors, invalid reads in `fl_image_w`,
`Fl_Browser::item_height` and `Fl_Browser::item_draw`.

**Verified.** 2026-11-03. All ten checks pass under Xvfb and on headless
sway; valgrind reports no invalid reads or writes, only fontconfig and
Pango leaks, and `vg-check.sh` passes it.

**Status.** Fixed.


## 43. An exception raised in a hook unwinds through FLTK

**Symptom.** An exception raised in Ada code that FLTK calls, such as a
callback, an overridden `Draw` or `Handle`, a timeout, an idle, a GLUT
callback or an image-line function, unwound through FLTK's C++ frames.
FLTK then skipped whatever it would have done after the call returned.
Idles never ran again. A window that raised in `Draw` wasn't redrawn. A
timeout raised while a pop-up menu was up left `Fl::grab` pointing at the
menu's dead stack frame, and the next event read freed stack. The details
for each hook are in FLTK-issues.md F3.

**Cause.** No hook had a handler, and FLTK isn't exception-safe. A few
hooks had handlers, but only for the binding's own `Constraint_Error` and
`Assertion_Error`.

**Found.** N12 in the issue triage, then the N12 experiment
(`test/controls/n12.adb`, PLAN.md Phase 0).

**Fix.** PLAN.md's N12 decision, option (a) with a deferred re-raise, in
a new private package, `FLTK.Hook_Exceptions`:
- Every hook FLTK calls, 77 handlers in 30 bodies, ends with
  `when Occurrence : others => Hook_Exceptions.Save (Occurrence)`. A
  function hook then returns a harmless value: `Not_Handled` for
  `Handle`, 0, a null pointer, or an empty string. The hooks that already
  had handlers keep them, and save an `Internal_FLTK_Error` instead of
  raising it.
- `Save` keeps only the first occurrence. Later ones are dropped until it
  is raised again.
- `Hook_Exceptions.Reraise` raises the kept occurrence once control is
  back in Ada. There are 58 calls: in `Wait`, `Check`, `Run`,
  `Screen.Flush`, each window's `Flush`, the menu `Popup`, `Pulldown`,
  `Picked` and `Test_Shortcut`, `Menu_Item.Do_Callback`,
  `Table.Do_Callback`, `Events.Handle` and `Handle_Dispatch`, every dialog
  in `FLTK.Asks`, `Native_File_Chooser.Show`, `Filenames.Get_Listing`,
  `File_Browser.Load`, the `Draw_Image` and `Draw_Text` overloads that
  take a function, `Draw.Scroll`, and the `FLTK.Probe` calls that send
  events or capture. In functions whose body has a handler for the
  binding's own checks, `Reraise` comes before that handler's scope, so
  the handler can't relabel the user's exception.
- `Run` is now Fl::run's own loop in Ada (Fl.cxx:651-654): it re-raises
  after each `fl_wait`, so the exception doesn't wait for the last window
  to close.
- The image-line hooks stop calling the user's function once it raises,
  and give FLTK zero lines for the rest of the image.
- `Fatal_Hook` is left alone, since FLTK's fatal handler must not return.
- A clip that the user's own `Draw` pushed and didn't pop before raising
  is still pushed. That is documented at `Push_Clip`.

**Test.** `test/unit/test_exceptions.adb`, now in `tests_unit.gpr`. For
each kind of hook, it checks that the exception reaches the Ada call
that ran the hook, and that FLTK still works afterwards: no grab, no
pushed widget, no dialog up, a button press runs its callback, and a
redraw paints. Before the fix, the idle, GLUT and (on Wayland)
first-frame cases failed, and the menu case crashed.

Two changes to the test:
- The GLUT window is destroyed before its `Check_Still_Works`. On Xvfb,
  it covered the test's window, and `fl_read_image` read the GLUT
  window's black pixels.
- It uses a new `FLTK.Probe.Grabbed` (`Fl::grab() != 0`) in place of
  `Events.Get_Grab`, which can't see a menu's grab (44). With Get_Grab,
  `Close_Menu` never sent its Escape, and the menu case hung in
  `Fl_Menu_Item::pulldown`.

**Verified.** 2026-11-03.
- Xvfb: all 67 checks pass, release and debug builds. Valgrind shows no
  invalid reads or writes, and `vg-check.sh` passes it.
- Headless sway: 61 checks pass. The menu case is skipped, since it
  needs X11.

**Status.** Fixed.


## 44. Events.Get_Grab can't return a window FLTK made itself

**Symptom.** While a pop-up menu is up, `FLTK.Events.Get_Grab` gives
null in a release build, as if nothing had the grab. In a debug build
(`-gnata`) it raises `Internal_FLTK_Error`.

**Cause.** `Fl_Menu_Item::pulldown` grabs its own `menuwindow`
(Fl_Menu.cxx:1002). FLTK constructs that window itself, so its
`user_data` is 0, and no Ada object stands for it. `Get_Grab` reads
`user_data` as the Ada window, and its `pragma Assert` on null is
checked only with `-gnata`. This is from the code. The release-build
null was seen indirectly: `test_exceptions`' menu case hung because
its `Close_Menu`, which was guarded by `Get_Grab /= null`, never sent
Escape.

**Found.** N12's test (43), 2026-11-03.

**Status.** Open. A fix needs an API decision. Possibilities are a
`Has_Grab` function, or a `Get_Grab` that says "a window FLTKAda didn't
make" instead of answering null. The same question applies to
`Get_Pushed`, `Get_Focus` and `Get_Below_Mouse`, which can return parts
of widgets FLTK made, and to `Dispatch_Hook`'s window.


## 45. Hooks that relabel the user's exception as Internal_FLTK_Error

**Symptom.** A `Constraint_Error` raised in a table's `Draw_Cell`, an
event handler added with `Events.Add_Handler`, an event dispatch
function, or a command-line argument handler (`FLTK.Static`'s
`Args_Hook`) reaches the program as `Internal_FLTK_Error` with a message
about unexpected values from FLTK. So does an `Assertion_Error` from a
user's failed `pragma Assert` there, or in the other hooks that have an
`Assertion_Error` handler: the box and label draw marshals, a tree item's
draw, the help view's link hook, the text editor's key hook, the Cairo
window's draw, a menu item's callback, a valuator's `Format`, and a
clipboard-notify handler.

**Cause.** These hooks' `when Constraint_Error` and
`when Chk.Assertion_Error` handlers were written for the binding's own
conversions and checks, but they cover the call to the user's code too.
This was already so before 43. 43 kept the handlers, which now save an
`Internal_FLTK_Error` instead of raising it. This is from the code, not
seen in a run.

**Found.** Writing 43, 2026-11-03.

**Status.** Open. The fix is to cover only the conversions with these
handlers, and to call the user's code outside them.


## 46. A new Menu_Item's label fields are uninitialised

**Symptom.** Valgrind reports "Conditional jump or move depends on
uninitialised value(s)" in `Fl_Menu_Item::draw` (Fl_Menu.cxx:289-291),
`Fl_Menu_::clear` (Fl_Menu_.cxx:579), and the shim's
`free_fl_menu_item` and `copy_items`. Each value was allocated in
`new_fl_menu_item`, called from `Menu_Items.Forge.Create`. A label's
type, font, size and colour are whatever the heap held. FLTK decides
from `labeltype_` whether the label text is an image or a string, so a
garbage label type can make FLTK, or the shim, treat the text as the
wrong kind of object.

**Cause.** `new_fl_menu_item` and `null_fl_menu_item` in
`body/c_fl_menuitem.cpp` used `new Fl_Menu_Item`. `Fl_Menu_Item` is a
plain struct with no constructor, so that leaves `labeltype_`,
`labelfont_`, `labelsize_` and `labelcolor_` unset. FLTK's own menus
are static arrays, which C++ zeroes.

**Found.** `make valgrind-headless`, running `test_menu_items`
(Phase 2), 2026-11-03.

**Fix.** Both functions use `new Fl_Menu_Item()`, which zeroes every
field. That gives a normal label, font 0, and the menu's text size and
colour, as in a static array (Fl_Menu.cxx:270, where a `labelsize_` of
0 means the menu's text size).

**Verified.** `test_menu_items` under valgrind: 20 errors from 11
contexts before the fix and 0 after. All 17 checks pass in both runs.
