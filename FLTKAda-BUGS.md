# FLTKAda bugs found while porting FLTK 1.4.5's examples

Sections 1 to 14 are fixed bugs. Sections 15 to 30 are **open**: they
were found on 2026-11-03 by reading FLTKAda's code against pofltk's
`doc/fltk-issues.md` (see PLAN.md, "The issue triage"). They have not yet
been confirmed by running anything. Sections 31 and 32 were found by
`test_constants` (PLAN.md, Phase 0) and are fixed. When one is fixed, replace its
"Status" with "Fix" and "Verified", as in sections 1 to 14. When one
turns out not to be a bug, say so in its section rather than deleting it.
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

**Status.** Open; FLTK side checked. PLAN.md Phase 2.


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

**Status.** Open. PLAN.md Phase 2.


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
