# FLTKAda bugs found while porting FLTK 1.4.5's examples

These bugs turned up while porting every program in FLTK 1.4.5's
`examples/` directory to Ada (see `examples/`). All of them are fixed. Each
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
