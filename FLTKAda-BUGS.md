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

**Fix.** The buffer is `W * Depth` long, keeping the `Depth` its
`Draw_Image` was given (PLAN.md Phase 2, N2, `test_image_lines`). Each of
the four `Draw_Image`s now raises `Draw_Error` inside an image-line
function (PLAN.md Phase 5, Issue 133). Before that, `test_image_reentry`
showed the replacement: a `Draw_Image` with lines inside another's line
function ran the inner function 29 times, its own 20 lines and 9 of the
outer image's, and the outer function once.

**Status.** Fixed.


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

**Fix (Clear).** `Group.Clear` removes only the children Ada added, and
keeps the ones FLTK made (PLAN.md Phase 4, pofltk 23). It does this for
every group, so `Spinner` and `Color_Chooser` need no override of their
own. `test_group_clear` failed before the fix, with 0 parts left in each,
and passes after it.

**Fix (Set_Colors and the format).** `Spinner` overrides `Set_Colors`
with the field's `color` and `selection_color`, as its other color
setters already were (Fl_Spinner.H:179-196). `Set_Format` refuses, with
`Constraint_Error`, a format `snprintf` can't take with what
`Fl_Spinner::update` gives it: one double, or an int and then a double
when the format starts with `%.*` (Fl_Spinner.cxx:79-91). The format
before is kept. The spec says which formats are taken.
`test_spinner_colors` failed 20 of its 36 checks before the fix: both
colors, and every bad format but `%n` and `%s` was taken; `%n` then
aborted the program, from glibc's "%n in writable segments" check.
After it, all pass under Xvfb and on sway, with vg=0 (PLAN.md Phase 6),
2026-11-03.

**Status.** Fixed. (Was "Partly fixed": `Clear` in Phase 4, the rest
left for Phase 6.)


## 28. Guards written as Pre or predicates are off in release builds

**Expected symptom.** A check meant to keep bad values away from FLTK,
such as `FLTK.Filenames.Path_String`'s 2048-byte limit (pofltk 121), does
nothing unless the calling program is built with `-gnata`. The library's
own `Pre` and `pragma Assert` are never checked in a release build.

**Cause.** The release build has no `-gnata` (`proj/common.gpr:62`).

**Planned fix.** Write guards that prevent memory errors as explicit
checks that raise (PLAN.md, "Architecture decisions", 1).

**Status.** Open. Applies throughout the fix phases.

Phase 12, 2026-11-04: the awake functions and `Draw_Pixmap` checked
FLTK's result with `pragma Assert`, and now check it explicitly (84).
`Pixmaps.Forge.Create`'s and `Draw_Pixmap`'s checks on the data are
explicit too (77, 84). About 80 `pragma Assert`s remain in 27 bodies.
They check that FLTK's result is one FLTK documents, such as
`Result in -3 .. 2` in `fltk-asks.adb`, and they aren't checked in a
release build. They haven't been sorted into the ones that guard memory
and the ones that don't. `grep -n 'pragma Assert' body/*.adb` lists them.


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

**Fix.** With pofltk 112 (PLAN.md Phase 4), `fl_glut_get` answers
`Window_Parent` itself: it takes the parent with `dynamic_cast` and gives
0 when the parent isn't an `Fl_Glut_Window`. A `Glut_Window` may still
have any group as parent, as in C++.

**Verified.** 2026-11-03. `test_glut_live` checks that a `Glut_Window` in
a plain window has parent 0 and that a subwindow's parent is its GLUT
window, with no invalid reads on Xvfb and sway. Negative control: with
FLTK's own `glutGet` the check happens to pass, but valgrind reports 2
invalid reads in `glutGet` (`glut_compatibility.cxx:400`).

**Status.** Fixed.


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

**Later change.** For pofltk 112 (PLAN.md Phase 4) the GLUT texts moved
from `body/fltk-glut.adb` into the shim, `body/c_fl_glut.cpp`. It keeps
each menu's labels as `std::string`s in a `std::deque` beside the menu,
and each window's icon title, so they are freed with the menu or window
and at exit. `Menu_Texts`, `Icon_Titles` and the per-menu bookkeeping
above are gone. A `Change_To_*` past the end of the menu now raises
`Constraint_Error`, so no text is kept for it. `Init`'s argv is still
freed by the controller in `body/fltk-glut.adb`.
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
  is still pushed. That is documented at `Push_Clip`. (Superseded
  2026-11-06: the hook now undoes what it pushed, clips and the rest, as
  the exception leaves it. PLAN.md, "Architecture decisions", 7;
  `test/unit/test_draw_state.adb`.)

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

Since Phase 12 (51's fix), the shim knows which widgets have Ada
objects, so these no longer misread a widget FLTK made whose user data
isn't 0. They still give null for one in a release build and raise
`Internal_FLTK_Error` in a debug build. The API question remains.

Since Phase 12 (82), the dispatch function is given such a window as
null too, but `Handle (Event, null)` and `Handle_Dispatch` from it pass
the event on to the window FLTK gave. So a program can let FLTK handle
a pop-up menu's events without an Ada object for its window.

Since Phase 13, windows that FLTK.GLUT's `Create_Window` and
`Create_Sub_Window` make get an Ada object on demand, from `Glut_Window`'s
`Window_Of` and `Current_Window` (`test_glut_window_of`). That answers the
question for GLUT windows only, which a program names by number. A
pop-up menu's window has no number, so it isn't covered.


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

**Fix.** Phase 12, 2026-11-04. Each hook checks FLTK's values
explicitly before it calls the program's code, and saves an
`Internal_FLTK_Error` and returns if one is wrong. Where a conversion
could still fail, as with a table's context and cell, it is in an inner
block with its own `Constraint_Error` handler, and the program's code is
called after it. Only the `when others` handler, which saves whatever
was raised, covers the call. The hooks changed are the ones listed
above. `test_hook_exceptions` raises `Constraint_Error` or
`Assertion_Error` with the message "mine" from a dispatch function, an
event handler, a clipboard handler and a table's `Draw_Cell`, and checks
that the same exception arrives. With the old hooks, the first four
checks failed, each with `FLTK.INTERNAL_FLTK_ERROR` and a message about
FLTK's values, such as "Event_Dispatch hook received unexpected event
int value of 8". With a `when Constraint_Error` handler put back in the
table's hook, the `Draw_Cell` check failed with
`FLTK.INTERNAL_FLTK_ERROR`. The test passes on Xvfb and on sway, and
valgrind finds no invalid reads or writes and no FLTKAda leak.
`Args_Hook` was changed the same way, but isn't tested: the test would
have to parse its own command line.

**Status.** Fixed.


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


## 47. Highlight_Data ignored where the style table starts

**Symptom.** A style table whose first index is not 'A', such as
`('B' => ...)`, was used as if it started at 'A': text styled 'A' got
the 'B' entry, and text styled 'B' got whatever was clamped to the last
entry. Nothing was raised. An empty table made FLTK read the entry
before the table.

**Cause.** Both `Highlight_Data` bodies passed `Table'Address` and
`Table'Length` to `highlight_data`. FLTK indexes the table with
`style - 'A'`, clamped to `nStyles - 1` (Fl_Text_Display.cxx:2725-2731),
so the Ada array's own index was lost, and with `nStyles` 0 the clamp
gives -1. `Style_Index` runs from '~' up, so Ada allows both tables.

**Found.** Reading FLTK's source for pofltk 35 (Phase 4), 2026-11-03.

**Fix.** `Highlight_Data` raises Constraint_Error for an empty table or
one whose `'First` is not 'A'. It now also copies the table and keeps
the style buffer (pofltk 35).

**Verified.** `test_highlight_data`. With the 'A' guard disabled, the
check that a table starting at 'B' is refused fails, and the rest pass.
(The unfixed binding stopped earlier, with Storage_Error from pofltk 35.)
With the guard, all 7 checks pass on Xvfb and sway, and valgrind reports
no errors.


## 48. RGB_Image and Bitmap kept the caller's pixels

**Symptom.** An `RGB_Image` or `Bitmap` made from an array read the array
for as long as it lived: one made from an array that was then freed, or
from a temporary, read freed or dead memory, and `Set_Datum` and
`Overwrite` wrote into the caller's array, even a constant. Data too
short for the size was read past its end in a release build.

**Cause.** Both `Create`s passed FLTK the address of the caller's array,
and `Fl_RGB_Image(const uchar *, ...)` and `Fl_Bitmap(const uchar *, ...)`
keep that pointer, with `alloc_array` 0 (Fl_Image.cxx:374-384,
Fl_Bitmap.H:48-49). The spec asked for data that outlives the image. The
length was checked only by `Pre`, which release builds don't check
(PLAN.md, "Architecture decisions", 1).

**Found.** Writing `test_window_shape` for pofltk 61 (Phase 4),
2026-11-03. pofltk copies the pixels (`ofl_image_rgb`, `new_bitmap` in
src/FlImages.cpp).

**Fix.** The shim gives FLTK a copy, made with `new (std::nothrow)`, and
sets `alloc_array`, so the image frees it (Fl_Image.cxx:460,
Fl_Bitmap.cxx:104). `Create` raises `Constraint_Error` for data too short,
and `Storage_Error` if the copy can't be made.

**Verified.** `test_image_data`. Before the fix, 4 of its 8 checks failed
(a pixel set changed the caller's array, and none of the 3 short-data
`Create`s raised), and valgrind found 24 reads of the freed arrays. After
it, all 8 pass and valgrind is clean. Negative control: without
`alloc_array` set for an RGB image, its 3 copies leak, and `vg-check.sh`
fails.


## 49. An animation's canvas kept it as its image

**Symptom.** After `Clear_Canvas`, or `Set_Canvas` to another widget, the
canvas the animation left still returned the animation from `Get_Image`,
though FLTK showed no image in it; once the animation was finalized,
`Get_Image` returned a dangling access. An animation finalized while its
canvas showed it left FLTK's canvas drawing the freed animation.

**Cause.** `Fl_Anim_GIF_Image::canvas` sets the old canvas's image to 0
(Fl_Anim_GIF_Image.cxx:640-641), but the binding changed only FLTK's side,
not the widget's `Current_Image`. `~Fl_Anim_GIF_Image` leaves the canvas's
image alone (:619-623).

**Found.** Writing `test_anim_canvas` for pofltk 62 (Phase 4),
2026-11-03: its last check, that a cleared canvas shows no image, failed.

**Fix.** `Clear_Canvas` and `Set_Canvas` clear the old canvas's image on
the Ada side too, if the canvas is still there. When an animation is
finalized, `free_fl_anim_gif_image` clears its canvas's image if the
canvas shows it, and `Finalize` does the same on the Ada side.

**Verified.** `test_anim_canvas`. Before the fix, its check that a
cleared canvas shows no image failed. After it, that check and one that
a canvas whose animation was finalized shows no image both pass, on X11
and Wayland, and valgrind is clean. Negative control: without the
finalize side of the fix, in the shim and in `Finalize`, the second check
fails, and redrawing the canvas gives 103 valgrind errors, 70 of them
invalid reads of the freed animation.


## 50. A tiled image's Tile was the tile from before its colours changed

**Symptom.** After `Color_Average` or `Desaturate`, `Tile` returned the
image the tiled image was made from, not the changed tile it draws.

**Cause.** `Fl_Tiled_Image::color_average` and `desaturate` change the
tile, the first time, for a copy they own (Fl_Tiled_Image.cxx:94-98,
:111-115). The binding set the Ada tile's pointer just before calling
them, so it kept the old one.

**Found.** Writing `test_tiled_tile` for pofltk 84 (Phase 4),
2026-11-03.

**Fix.** `Color_Average` and `Desaturate` set the Ada tile's pointer
after the call, and `Tile` sets it again before returning it.

**Verified.** `test_tiled_tile` shows the tile in a box after
`Color_Average` with blue at 0.5. With the old body, the box showed the
red original (16711680); with the fix, the blend (8323199), on X11 and
Wayland.


## 51. Parent of a widget in a group FLTK made reads that group's user data as Ada

**Symptom.** Finalizing a `File_Chooser`'s extra widget while it was the
chooser's extra raised `Program_Error` ("finalize/adjust raised
exception"), after an invalid read in `FLTK.Widgets.Extra_Final`.

**Cause.** `Widgets.Parent` (`body/fltk-widgets.adb`) converts the
parent's `user_data` to an Ada group whenever it isn't null. A file
chooser's window is made by FLTK, and its `user_data` is the
`Fl_File_Chooser` (Fl_File_Chooser.cxx:114 reads it back), not an Ada
object. `Extra_Final` calls `Parent` and then `Remove` on what it got.
The same holds for any widget the program puts in a group FLTK made,
and for Bug 44's question in general: the binding can't tell an
Ada-made widget from a C++-made one.

**Found.** The negative control of `test_chooser_extra` for pofltk 92
(Phase 4), 2026-11-03: with the shim no longer taking a finalized extra
widget out of its chooser, the test raised `Program_Error` with one
invalid read in `fltk.widgets.extra_final`.

**Status.** Open, in general. The pofltk 92 fix takes the extra widget out
of the chooser's window before `Extra_Final` asks for its parent, so
finalizing it is safe. `Parent` called while the widget is the
chooser's extra still misreads. A fix needs a way to know an Ada-made
widget (for example, a shim-side mark on every `My_` class), which is
the same decision Bug 44 needs. (This was the status until Phase 12.)

**Fix.** Phase 12, 2026-11-04. The shim keeps a table of the widgets
with Ada objects (`body/c_fl_widget.cpp`): `fl_widget_set_user_data`,
which only `Widgets.Extra_Init` calls, puts each widget in with its Ada
object, and `fl_widget_forget` takes it out, with the parts FLTK made
that are still its children and go with it. `fl_widget_get_user_data`
gives the Ada object only for a widget in the table whose user data is
still that object, and 0 otherwise, so every lookup of a widget FLTK
made gives null instead of misreading its user data. `Parent` of the
chooser's extra is now null. `Group.Child` of a part FLTK made, such as
a terminal's scrollbar, now raises `Internal_FLTK_Error` in every build,
where it gave a reference to garbage. `Get_First_Window` and
`Get_Next_Window` skip the windows FLTK made, as pofltk does, and
`Get_Top_Modal` gives null for one. A part an Ada record wraps but that
isn't a child, such as a `Value_Input`'s input, stays in the table after
its C++ object goes; a widget FLTK makes later at the same address
would also need the same user data to be taken for it.

**Verified.** `test_window_list`: with a file chooser shown, the window
walk raised `Storage_Error` before the fix. After it, all 8 checks pass,
with no invalid reads under valgrind, and `test_chooser_extra` stays
clean. With the shim's skip taken out, the walk raises
`Internal_FLTK_Error` instead. `make check-headless` passes.


## 52. The sorts compared only a name's first 255 bytes

**Symptom.** `Alpha_Sort`, `Case_Alpha_Sort`, `Numeric_Sort` and
`Case_Numeric_Sort` found two names equal if they differed only after
their first 255 bytes.

**Cause.** The shim's `filename_alphasort` and the other three
(`body/c_fl_filename.cpp`) copied each name into a `struct dirent` with
`strncat (d_name, a, 255)`, to call FLTK's sort, which takes dirents.
The rest of the name was dropped.

**Found.** `test_numeric_sort` for pofltk 63 (PLAN.md Phase 5),
2026-11-03: two 301-byte names that differ in their last byte compared
`EQUAL` both ways.

**Fix.** The four sorts are written in Ada (`body/fltk-filenames.adb`),
which also fixes pofltk 63, and the shim's wrappers are gone. The
numeric sorts fold case with FLTK's `fl_tolower`; the alphabetic ones
compare bytes as `strcmp` and `strcasecmp` do.

**Status.** Fixed.


## 53. A failed GIF or XPM raised Constraint_Error

**Symptom.** `GIF_Image` and `XPM_Image` `Create` of a file that can't
be read, or isn't an image, raised `Constraint_Error` (a range check at
`body/fltk-images.adb:369`), not `File_Access_Error` or `Format_Error`.

**Cause.** `Raise_Fail_Errors` tested `Result = fl_image_err_no_image
and This.Is_Empty` first. With `and`, `Is_Empty` was evaluated whatever
the result, and it called `Get_W`, which converts the width to
`Natural`. A failed `Fl_Pixmap` is -1 wide (`Fl_Pixmap.H:58-64`).

**Found.** `test_image_crafted` for pofltk 88 (PLAN.md Phase 5),
2026-11-03: every refused GIF raised `Constraint_Error`. A scratch
program confirmed it for a GIF of no file.

**Fix.** `Raise_Fail_Errors` tests the file and format errors first, and
then the empty image with `and then`. `Is_Empty` reads the width and
height from FLTK as `int`, and takes 0 or less as empty.

**Status.** Fixed.


## 54. Shared_Image Create of an unreadable file returned an image with no FLTK object

**Symptom.** `Shared_Image` `Create (Filename, W, H)` of a file that
doesn't exist returned normally. The first call on the image, such as
`Get_W`, then crashed (Storage_Error, from a segmentation fault).

**Cause.** `Fl_Shared_Image::get` returns `NULL` when it can't load the
file (`Fl_Shared_Image.cxx:594-598`), and `Create` didn't check.

**Found.** `test_image_crafted` for pofltk 87 and 88 (PLAN.md Phase 5),
2026-11-03, with the null check removed: `Create ("/no/such.bmp")`
returned, and `Get_W` crashed.

**Fix.** `Create` raises `No_Image_Error` for a null image. It also
raises it for an image FLTK took and couldn't load, which `get` shares
0 wide (a PNG over `int'Last` bytes, for example). `Create (From)`
raises `Storage_Error` for a null.

**Status.** Fixed.


## 55. A JPEG from memory was read past its end

**Symptom.** `JPEG_Image` `Create (Name, Data)` of a JPEG cut short
read past the end of `Data`. Valgrind found 22 invalid reads in libjpeg
(`decode_mcu`, from `Fl_JPEG_Image.cxx:333`) for a 64 by 64 JPEG cut to
half, and 4 blocks of 72 bytes definitely lost.

**Cause.** The shim called `Fl_JPEG_Image (name, data)` without the
length. FLTK then uses its unprotected source, which hands libjpeg 4096
bytes at a time from wherever it has got to (`Fl_JPEG_Image.cxx:163-169`,
`304-305`), and mallocs the source and never frees it (`:193-194`).

**Found.** `test_image_crafted`, 2026-11-03, while checking the F7 JPEG
from memory, whose valgrind log had the leak.

**Fix.** The shim takes `Data'Length` and passes it, so FLTK uses
libjpeg's `jpeg_mem_src`. The cut JPEG is refused with `Format_Error`,
with no invalid reads and no leak. Negative control: with the length
dropped again, the 22 invalid reads and the leak are back.

**Status.** Fixed.

## 56. A PNG, JPEG or SVG from memory left the shared pool pointing at it

**Symptom.** After a `PNG_Image`, `JPEG_Image` or `SVG_Image` made from
memory with a name went, `Shared_Image` `Find` of the name still found
it, and using it read freed memory. A PNG or JPEG made with no name was
put in the pool under `""`, each one a new entry.

**Cause.** FLTK's issue F8 (FLTK-issues.md): the loader puts a named
image in the pool, by an entry that doesn't own it. The PNG and JPEG
shims passed Ada's default `""` on as a name. The SVG shim already
passed it as `NULL`.

**Found.** `test_image_names`, 2026-11-03: 10 of its checks failed, and
valgrind found 44 invalid reads, in `Fl_Shared_Image::desaturate` of an
entry whose image `fltk.images.rgb.png.finalize` had freed.

**Fix.** The PNG and JPEG shims pass an empty name as `NULL`, as SVG
did (`null_if_empty`, now in `c_fl_image_check.cpp`). The free
functions for the three call `delete_unless_pooled`. If the pool has an
entry for the image that doesn't own it, the entry is given the image
and its loader's reference is released, so the image goes when the last
`Shared_Image` found by its name does. Otherwise the image is deleted.
Negative control: with the image always deleted, 9 checks fail and the
44 invalid reads are back.

**Status.** Fixed.

## 57. A Shared_Image made from an RGB_Image shared that image, unowned

**Symptom.** `Shared_Image` `Create (From)` followed by the `From`
image going left the shared image pointing at freed memory.

**Cause.** The shim called `Fl_Shared_Image::get (rgb, 0)`, which
shares the image itself and doesn't own it
(`Fl_Shared_Image.cxx:629-635`).

**Found.** Reading FLTK's source for 56, 2026-11-03. pofltk shares a
copy that the pool owns (`FlImages.cpp:1633`).

**Fix.** The shim shares a copy, with `own_it` 1. `test_image_names`
frees the PNG first and then uses the shared image. Negative control:
with the image shared unowned again, valgrind finds 47 invalid reads.

**Status.** Fixed.

## 58. Read_Image returned an unset array when FLTK read nothing

**Symptom.** `FLTK.Draw.Read_Image` returned an array of whatever its
memory held when `fl_read_image` read nothing and returned `NULL`.

**Cause.** The result was checked with `pragma Assert`, which release
builds don't check (as in 28), so a `NULL` was let through.

**Found.** Testing pofltk 127, 2026-11-03. With the shim passing every
read straight to `fl_read_image`, as it did, a read outside any draw
gets `NULL` from FLTK, and so, on X11, does one of the test's reads
outside the window.

**Fix.** `Read_Image` raises `Draw_Error` for a `NULL` result, with an
explicit check, and `Internal_FLTK_Error` for one at another address.
The shim also returns `NULL` when nothing is drawn on, as it now has to
know the window's or surface's size to clip (pofltk 127).
`test_read_outside` checks that a read outside any draw raises.

**Status.** Fixed.

## 59. Set_Line_Style kept its last dash pattern until exit

**Symptom.** Valgrind reported 24 bytes still reachable at exit,
allocated in `FLTK.Draw.Set_Line_Style`. Run with
`--show-leak-kinds=all`, as `make valgrind-headless` does,
`test_dashes` failed `vg-check.sh` on X11 and on sway.

**Cause.** `Set_Line_Style` built the pattern on the heap and kept it
in a package variable, freeing it only at the next call, so the last
one was never freed. Nothing needed it kept: FLTK's Cairo and
PostScript drivers copy the pattern into `linedash_`
(Fl_Cairo_Graphics_Driver.cxx:317-319, Fl_PostScript.cxx:1016-1018),
SVG duplicates it (Fl_SVG_File_Surface.cxx:240), Xlib uses it at once
(Fl_Xlib_Graphics_Driver_line_style.cxx), and OpenGL ignores it.

**Found.** `make valgrind-headless` and `make valgrind-sway` at the end
of Phase 5, 2026-11-03. `test_dashes`, new in Phase 5, was the first
test to call `Set_Line_Style` under valgrind, and the per-test runs
then had left out still-reachable blocks.

**Fix.** The pattern is built on the stack. `test_dashes` passes
`vg-check.sh` on X11 and on sway.

**Status.** Fixed.

## 60. Get_Top_Line raised Constraint_Error for a browser with no top line

**Symptom.** `Textline_Browser.Get_Top_Line` raised Constraint_Error
(a range check at fltk-widgets-groups-browsers-textline.adb:795) on a
browser with no lines, and on one with lines that had never been drawn.

**Cause.** It returned `Positive`, but `Fl_Browser::topline ()` is
`lineno (top ())` (Fl_Browser.cxx:645-647), which is 0 when there is no
top item: always in an empty browser, and, before pofltk 38's fix, in a
browser not yet drawn.

**Found.** `test_browser_top`, written for pofltk 38 in Phase 6,
2026-11-03: its first check raised before the fix for 38, and its
empty-browser check raised after it.

**Fix.** `Get_Top_Line` returns `Natural`, 0 when the browser has no
lines. A caller that stores the result in a `Positive` still compiles.
`test_browser_top` checks it.

**Status.** Fixed.

## 61. FLTK read past the end of FLTKAda's argv

**Symptom.** Valgrind: an invalid read of 8 bytes at `Fl::arg`
(Fl_arg.cxx:177), "0 bytes after a block of size 16" allocated in
`fltk.static'Elab_Spec`, when `Parse_Args` met an option FLTK doesn't
know, last on the command line (`test_parse_args -bogus`). `Parse_Arg`
with an index past the arguments read past the array too.

**Cause.** `Args_Marshal.Create_Argv` made argv the program's name and
arguments, without the null pointer that ends C's argv (C11 5.1.2.2.1).
FLTK relies on it: `Fl::arg` reads `argv[i+1]` before it checks `i`
against `argc` (Fl_arg.cxx:177-178), for every option that isn't one of
the single-word ones. And `Parse_Arg` passed its index to `Fl::arg`,
which reads `argv[i]` unchecked (Fl_arg.cxx:132).

**Found.** `test_parse_args`, written for pofltk 57 in Phase 6,
2026-11-03, run under valgrind by hand: its child processes aren't
traced by `make valgrind`.

**Fix.** The argv ends in a null pointer, and argc doesn't count it.
`Parse_Arg` raises Constraint_Error for an index past the last
argument. `test_parse_args` checks both; with the fix valgrind finds
nothing. Index `Argument_Count + 1` now reads the null, so valgrind
can't show the second without the first fixed; the test checks the
exception.

**Status.** Fixed.

## 62. A window shown with Show_With_Args kept a freed title

**Symptom.** A window shown with `Show_With_Args` and the argument
`-title Hello`, before any `Parse_Args`, had a label in freed memory:
valgrind reported invalid reads in `Get_Label`, "inside a block of size
6 free'd", and with 8 strings of that size made after the show, the
label read "World".

**Cause.** `Args_Marshal.Dispatch` made a new argv for each
`show (argc, argv)` and freed it as soon as it returned. FLTK keeps
pointers into it: `-title` and `-name` (Fl_arg.cxx:195, 198), the first
then made the window's label with `label (title)`, which doesn't copy
(Fl_arg.cxx:313); and `-fg` and `-bg` as `fl_fg` and `fl_bg`
(Fl_arg.cxx:203-207), which every later `show (argc, argv)` reads
again through `get_system_colors` (Fl_arg.cxx:290,
Fl_Screen_Driver.cxx:210-211). `-name` is copied by `xclass`.

**Found.** `test_parse_args`, while fixing 61, 2026-11-03, reading
`Fl_Window::show (argc, argv)` (Fl_arg.cxx:287-330) to see what else
used the argv.

**Fix.** `Args_Marshal` keeps one argv for the program's life, as C's
is, made at elaboration and never freed; `Parse_Arg`, `Parse_Args`
and every `Show_With_Args` use it. It is a constrained array, so that
valgrind sees a pointer to the start of its block and calls it still
reachable, not possibly lost. `test_parse_args -title Hello` checks the
label's value.

**Status.** Fixed.

## 63. Set_Label with a kind didn't set a shown window's title

**Symptom.** `Set_Label (Win, Kind, "Kind")` on a shown window changed
the label but left the title the window manager shows as it was: under
Xvfb, `XFetchName` still gave the earlier title. `Set_Label (Win,
"Plain")` did set it.

**Cause.** The three-parameter `Widget.Set_Label` called the
two-parameter one statically, as `Widget`'s, so a window got
`Fl_Widget::copy_label`. `Fl_Window::copy_label` isn't virtual, and it
is the one that also sets the title (Fl_Window.cxx:159-162). pofltk 6;
PLAN.md's N7.

**Found.** Reading the code against pofltk 6 (PLAN.md, "The issue
triage"); confirmed with `test_window_label`, 2026-11-03.

**Fix.** `Set_Label (This, Kind, Text)` dispatches, through
`Widget'Class (This)`, for both the kind and the text.
`test_window_label` reads the X11 title with `FLTK.Probe.X11_Title`
after each way of setting the label; before the fix, 2 of its 5 checks
failed.

**Status.** Fixed.


## 64. Enter_Area freed the tooltip text FLTK held

**Symptom.** Under valgrind, `test_kept_strings` sometimes failed with
invalid reads in `tooltip_timeout` (Fl_Tooltip.cxx:165) and
`fl_measure`, of a block the shim's `fl_tooltip_enter_area` had
allocated and freed. It showed in one `make valgrind-sway` run, and
three reruns were clean.

**Cause.** Section 16's fix keeps a copy of the text, and freed it
unless `Fl_Tooltip::current () == wid` afterwards, taking that to mean
FLTK hadn't taken the text. But `enter_area` sets `tip` and `widget_`
(:301), and when a tip was recently up it then hides the tooltip
window (:305). On X11 and on sway, the hide goes through
`Fl_Window_Driver::hide_common` and `fl_throw_focus` (Fl.cxx:1215-1217)
to `Fl_Tooltip::exit_`, which clears `widget_` and keeps `tip` (:252).
So the shim freed the text FLTK held, and the hover delay's
`tooltip_timeout` read it. The gdb backtrace showed that chain for the
test's "other tip". The bad free happened on every run; valgrind saw
the read only when the timeout (0.2 s by default) ran before the test
went on.

**Found.** `make valgrind-sway`, 2026-11-04; the cause by
instrumenting the shim and with gdb.

**Fix.** The shim decides with `Fl_Tooltip::enabled ()`. With a
non-empty text and tooltips enabled, FLTK takes it (:291-301): a fresh
copy can't be the pointer it holds, so the same-text test at :297
can't refuse it. FLTK also refuses any text while its own
`tooltip_timeout` runs (`recursion`, :162-163, 291), which the shim
can't see. That would take an `Enter_Area` from a hook that runs
inside it, and the comment in the shim says so. `test_kept_strings`
now sets the hover delay to 0, so its `Pump` runs the timeout: with
the old test the shim failed valgrind 6 runs of 6, 3 on X11 and 3 on
sway, and with the fix it passes 6 of 6.

**Status.** Fixed.


## 65. Menu's one-string Add can't be called

**Symptom.** `Add (This, Text)`, the procedure and the function in
`FLTK.Widgets.Menus`, can't be called. Every call, `M.Add ("a|b")`,
`Add (M, "a|b")` or `Add (This => M, Text => "a|b")`, is ambiguous with
the `Add` whose `Action`, `Shortcut` (a `Key_Combo`) and `Flags` all
have defaults, and doesn't compile.

**Cause.** The two have the same required parameters, `This` and
`Text`. So FLTK's `add (const char *)` (Fl_Menu_add.cxx:445-460), which
splits its text on `|` into several items and reads a shortcut after a
tab, can't be reached from Ada. A call with only the text has to name
`Flags` or another defaulted parameter, and then gets the other `Add`,
which makes one item.

**Found.** Writing `test_menu_add_merge` for pofltk 79, 2026-11-04;
confirmed with a scratch program checked with `gcc -c -gnatc`, which
reported "ambiguous call to "ADD"" for each form.

**Fix.** The one-string `Add`, the procedure and the function, is now
`Add_Items`, in `FLTK.Widgets.Menus` and in `System_Menu_Bar`, which
overrides it. Removing the defaults of the other `Add` instead would have
broken every caller that leaves them out. No caller could have used the
old name, since no call to it compiled. The new test
`test_menu_add_items` checks the split at `|`, the index returned, and
a part over 1022 bytes (FLTK-issues.md F11); passes on X11 and sway,
with vg=0.

**Status.** Fixed.

## 66. A fatal handler that returned crashed FLTK

**Symptom.** Setting `FLTK.Errors.Current_Fatal` to a procedure that
returns, then failing to open the display, ended the program with
"raised STORAGE_ERROR : s-intman.adb:136 explicit raise", a segfault,
after the handler had printed its message.

**Cause.** `Fl::fatal` must not return (Fl.H:557-559). The shim's
`fatal_hook_prep` called the Ada handler and returned, and FLTK went on
as if the display were open: `Fl_X11_Screen_Driver::open_display_platform`
returns after the `Fl::fatal` (Fl_x.cxx:550-551), and the next use of
`fl_display` crashes. A handler that raises was always fine: the
exception passes through FLTK's frames to the Ada handler that catches
it.

**Found.** Phase 8, binding `set_abort`, which is `Current_Fatal`;
2026-11-04, with two scratch programs, one returning and one raising,
run with `FLTK_BACKEND=x11` and `DISPLAY=:987`.

**Fix.** `fatal_hook_prep` calls `exit (1)` when the handler returns,
as FLTK's own fatal handler does. The comment on `Current_Fatal` says
so. The new test `test_fatal_handler` runs itself once with each kind
of handler: the returning one exits 1 with no exception, and the raising
one is caught. Without the fix its "doesn't crash" check fails. Passes
on X11 and sway.

**Status.** Fixed.

## 67. `FLTK.Events.Clipboard_Text` was always "", or read an image as text

**Symptom.** In a Paste event of text, `Clipboard_Text` returned `""`
instead of the text. In a Paste event of an image, it returned the bytes
of the `Fl_RGB_Image` object up to the first nul.

**Cause.** The shim returned `Fl::event_clipboard()` cast to
`const char *`. FLTK never stores text there: it is the pasted
`Fl_RGB_Image *` in an image paste (Fl.H:852-855), and the text is in
`Fl::event_text` (Fl_x.cxx:698-700). Outside an image paste the pointer
was null, so the result was `""`.

**Found.** Phase 8, binding pasted images (pofltk 48), 2026-11-04: the
new `test_paste_image` copied and pasted "hello, paste" and got `""`, on
X11 and on sway.

**Fix.** `fl_event_clipboard_text` returns `Fl::event_text` with
`Fl::event_length`, or `""` when the paste is an image. The spec of
`Clipboard_Text` says what it returns. `test_paste_image` checks the
text of a paste before and after an image paste, and that an image
paste gives `""`. Passes on X11 and sway.

**Status.** Fixed.

## 68. Finalizing a widget declared without `Forge.Create` read through null

**Symptom.** A widget object declared but never made, such as
`Blank : FLTK.Widgets.Boxes.Box;`, raised Program_Error ("finalize/adjust
raised exception") when it went out of scope. Valgrind showed an invalid
read at address 8 in `fl_widget_get_parent`, called from
`fltk.widgets.extra_final`.

**Cause.** `Extra_Final` for `Widget` guarded `fl_widget_forget` against a
null `Void_Ptr`, but then called `This.Parent`, which passes `Void_Ptr` to
`fl_widget_get_parent` whatever it is.

**Found.** Phase 8, testing `FLTK.Widget_Trackers`, 2026-11-04: the check
that tracking such a widget raises passed, but the run under valgrind
failed with the invalid read.

**Fix.** `Extra_Final` does nothing for a widget with no FLTK widget.
`test_widget_trackers` checks that one finalizes without raising; before
the fix it raised. Passes on X11 and sway, and valgrind is clean on both.

**Status.** Fixed.

## 69. `Image_Surface` accepted a size below 1

**Symptom.** `FLTK.Devices.Surface.Image.Forge.Create (0, 5)` made a
surface, and reading its image crashed: a null read on X11, SIGFPE on
Wayland.

**Cause.** `Create` passed the size straight to FLTK, which doesn't check
it (FLTK-issues.md F14).

**Found.** Phase 9, 2026-11-04, writing `FLTK.Draw.Offscreens`, whose
`Create` has the same rule.

**Fix.** `Create` raises Constraint_Error if W or H is below 1.
`test_offscreens` checks it for both packages. Passes on X11 and sway.

**Status.** Fixed.

## 70. Finalizing a surface that was current or pushed left FLTK pointing at it

**Symptom.** An `Image_Surface` finalized while current, or while
remembered by `Push_Current`, stayed in FLTK's surface stack, and the
next `Pop_Current` made the freed surface current, so drawing used freed
memory.

**Cause.** `Finalize` deleted the FLTK object whatever FLTK still kept,
and FLTK's destructor clears only the current surface, not the stack
(FLTK-issues.md F15).

**Found.** Phase 9, 2026-11-04, testing offscreens begun one inside
another.

**Fix.** Each surface's `Finalize` calls `Release_Current` first. That
pops the surface if it is current from a push, and makes the original
surface current if it still is. A surface buried under another is
replaced in the Ada stack by a stand-in that owns the FLTK object, freed
once FLTK's stack forgets it. `test_offscreens` frees an offscreen while
begun, and a surface buried under another, then draws and pops. Passes
on X11 and sway, and valgrind is clean on both.

**Status.** Fixed.

## 71. `RGB_Image` took a depth outside 1 to 4, and a line size shorter than a row

**Symptom.** `FLTK.Images.RGB.Forge.Create` made an image of depth 0 or
5, or with a non-zero line size less than the width times the depth.
FLTK then read past the pixels: a C++ program writing such images with
`fl_write_png` under valgrind gave invalid reads at
`fl_write_png.cxx:161`, for depth 0 and for a line size of 2 with width
4 and depth 3.

**Cause.** `Create` checked only that `Data` was long enough for the
size it computed from the line size, so a short line size made a short
buffer pass. FLTK's `Fl_RGB_Image` checks neither the depth nor the line
size, and its drawing and `fl_write_png` step through the data by both.

**Found.** Phase 10, 2026-11-04, writing `Write_PNG`.

**Fix.** `Create` raises Constraint_Error for a depth outside 1 .. 4 and
for a non-zero line size below width times depth, as the spec now says.
`test_write_png` checks depths 0 and 5 and a line size of 2. Passes on
X11 and sway.

**Status.** Fixed.

## 72. Reading back a shortcut with a key raised Constraint_Error

**Symptom.** `Get_Shortcut` of any widget, and `Get_Value` of a
`Shortcut_Button`, raised Constraint_Error for a shortcut such as
`Mod_Ctrl + 'w'`. Only `No_Key` and a bare mouse button read back.

**Cause.** `To_Ada` for a `Key_Combo` (`body/fltk.adb`) passed the whole
value to the `Mouse_Button` conversion, which raises for anything but
exactly a button's code. The key and modifier bits made every shortcut
with a key fail.

**Found.** Phase 10, 2026-11-04, testing `Shortcut_Button`.

**Fix.** The conversion is given only FLTK's mouse button bits,
`FL_BUTTONS` (16#1F00_0000#). `test_shortcut_button` reads back a
widget's own shortcut and one with a mouse button. Passes on X11 and
sway.

**Status.** Fixed.

## 73. A text label could be read as a pointer, and a pointer label as text

**Symptom.** `Set_Label_Kind` of `Multi_Label` or `Icon_Label` on a
widget with a text label made FLTK read the text as a multi-label:
valgrind gave an invalid read in `multi_labeltype`
(`Fl_Multi_Label.cxx:31`). And `Get_Label` of a widget showing a
multi-label, an icon or an image label read that pointer as text.

**Cause.** The shim passed both straight to FLTK, whose label is a
`const char *` that these label types use for a pointer to their object
(`Fl_Multi_Label.cxx:28`, `Fl_File_Icon.cxx:425`, `Fl_Image.cxx:224`).

**Found.** Phase 10, 2026-11-04, by control 2 of
`test_widget_multi_label`.

**Fix.** In `c_fl_widget.cpp` and `c_fl_window.cpp`, setting a label
type does nothing if the widget shows such a pointer or the type is one
of these. `Get_Label` gives "" for one, and `Set_Label` first makes the
label plain text, so FLTK doesn't free the pointer (pofltk 55).
`test_widget_multi_label` checks each case. Passes on X11 and sway, and
valgrind is clean on both.

**Status.** Fixed.

## 74. `Measure_Label` and `Labels.Measure` gave FLTK an uninitialized wrap width

**Symptom.** Valgrind reported "Conditional jump or move depends on
uninitialised value(s)" in `expand_text_` (`fl_draw.cxx:96`), from
`fl_measure` (521) and `fl_normal_measure` (`fl_labeltype.cxx:41`). A
label could be measured as if wrapped at whatever width the stack held.

**Cause.** The imports of `fl_widget_measure_label` and
`fl_label_measure` declared W and H as `out`, so the shim was given
uninitialized variables. FLTK reads W as the width to wrap the text at,
0 for none (`fl_draw.cxx:520-521`).

**Found.** Phase 10, 2026-11-04, adding a measure check to
`test_file_icons` under valgrind.

**Fix.** Both are `in out` and are given 0. `FLTK.Draw.Measure` and
the OpenGL `Measure` already did this. `test_file_icons` measures one
line of text against a longer one. Valgrind is clean on X11.

**Status.** Fixed.

## 75. A Paged device in a page wasn't on FLTKAda's stack of surfaces

**Symptom.** During a page, `Get_Current` wasn't the PostScript device
or printer. A device finalized in a page left FLTK's current surface
pointing at the freed device, so the next drawing used freed memory.
`End_Page` outside a page popped some other surface.

**Cause.** The `begin_page` of `Fl_PostScript_File_Device` pushes the
device on FLTK's stack of surfaces, and `end_page` pops it, whatever is
on top (`drivers/PostScript/Fl_PostScript.cxx:1902, 1942`). The WinAPI
and Cocoa printers do the same (`Fl_WinAPI_Printer_Driver.cxx:416, 466`,
`Fl_Cocoa_Printer_Driver.mm:326, 367`). FLTKAda's own record of the
stack, which `Get_Current` reads and `Finalize` uses to take a device
off the stack, didn't know about it.

**Found.** Phase 11, 2026-11-04, while designing the PDF surface, which
pushes in the same way. `test_page_finalize` failed two checks.

**Fix.** `FLTK.Devices.Surface` has private `Push_Bookkeep` and
`Pop_Bookkeep`, used by `Push_Current` and `Pop_Current` too. The
`Start_Page` and `End_Page` of `Postscript_File_Device` and `Printer`
call them. `Start_Page` in a page and `End_Page` outside one raise
`Page_Error` before calling FLTK. `test_page_finalize` checks all of
this.

**Status.** Fixed.


## 76. An image's size and line size could raise Constraint_Error

**Symptom.** For an `Animated_GIF_Image` made with no file, `Get_W`,
`Get_H`, `Get_Data_W` and `Get_Data_H` raised `Constraint_Error` (a
range check at `body/fltk-images.adb:393`). `Get_Line_Size` raised it
for any image that failed to load, such as an animation of a missing or
broken file, which `Create` doesn't refuse.

**Cause.** Each converted FLTK's `int` to `Natural`. An `Fl_Pixmap`
with no data is -1 wide (`Fl_Pixmap.H:58-64`; `measure` measures only
when there is data, `Fl_Pixmap.cxx:35-44`), and FLTK keeps a failed
image's error code, -1 to -3, in its line size (`Fl_Image.cxx:203-212`).
Bug 53 fixed `Is_Empty`, which reads the size, but not these.

**Found.** Phase 12, 2026-11-04, while checking `Fail_Code` (F25): a
scratch program printed the size of an animation never loaded and the
line size of one of no file, and both raised.

**Fix.** These five functions return 0 for a negative value. The spec
says so, and that `Fail_Code` gives the error. `test_image_crafted`
checks both cases, and raises `Constraint_Error` without the fix.

**Status.** Fixed.


## 77. Pixmaps.Forge.Create let FLTK read past the data it was given

**Symptom.** In a release build, `Pixmaps.Forge.Create` with a header
bigger than its data returned a pixmap, and drawing it read past the
end of the data. Valgrind found 3 invalid reads in `fl_convert_pixmap`
(`fl_draw_pixmap.cxx:168-171`) for a `(40, 40, 2, 1)` header with two
colors and 2 by 2 pixels. Separately, `Create` raised
`Constraint_Error` for pixel data whose second index didn't start at 1,
such as `Pixmap_Data (1 .. 2, 2 .. 4)`.

**Cause.** The only checks that the header matched the colors and pixels
were in `Pre`, which a release build doesn't check (PLAN.md,
Architecture decisions, 1). FLTK reads as many lines, and characters a
line, as the header says (`fl_draw_pixmap.cxx:103-171`). Nothing
stopped a size whose image FLTK sizes as an `int` either
(`Fl_Image.cxx:445`, `new uchar[data_w() * data_h() * d()]`).
`Marshal_Data` took each line's address at column 1, not
`Pixels'First (2)`.

**Found.** Phase 12, 2026-11-04, while binding the pixmap's data: the
`Pre` on `Create` guards memory. A scratch program against the release
build showed the invalid reads.

**Fix.** `Create` raises `Constraint_Error` when the colors or lines
aren't as many as the header says, the lines aren't `Width * Per_Pixel`
long, a color's name isn't `Per_Pixel` long, or `Width * Height * 4` is
over `int'Last`. `Marshal_Data` uses `Pixels'First (2)`.
`test_pixmap_data` checks each case. With the checks removed, its five
refusals raised nothing. With the old index, it raised
`Constraint_Error` at `fltk-pixmap_marshal.adb:69`.

**Status.** Fixed.

## 78. Text_Buffers.Next_Char and Prev_Char returned a Character

**Symptom.** `Next_Char` and `Prev_Char` returned `Character'Val` of the
place FLTK gave, so for `"a" & é & "b"` `Next_Char (1)` was the
character at position 3, not the place 3. A place over 255 raised
`Constraint_Error`.

**Cause.** FLTK's `next_char` and `prev_char` return the place of the
next or previous character, not a character (`Fl_Text_Buffer.H:738-744`),
and the binding converted it. `prev_char (0)` is -1, which a `Position`
can't hold.

**Found.** Phase 12, 2026-11-04, binding `Text_Buffer`'s missing
methods. A scratch program under Xvfb showed `Next_Char (299)` raising.

**Fix.** Both return a `Position`. `Prev_Char` calls `prev_char_clipped`,
which is 0 at 0, from no further than `Length`, since FLTK gives back
the place it's given past the end (FLTK-issues.md F6).
`test_text_buffer_methods` checks them.

**Status.** Fixed.

## 79. Text_Buffers.Get_Highlight gave what Set_Highlight last set

**Symptom.** After `Set_Highlight (2, 4)` and inserting 3 bytes at 0,
`Get_Highlight` still gave 2 and 4, where FLTK had moved the highlight
to 5 and 7. After `Unhighlight`, it still gave 2 and 4.

**Cause.** `Get_Highlight` returned two components of the Ada record
that only `Set_Highlight` set, not FLTK's `highlight_position`.

**Found.** Phase 12, 2026-11-04, binding `highlight()`. A scratch
program under Xvfb showed both stale values.

**Fix.** `Get_Highlight` returns `highlight_position`, 0 and 0 when
nothing is highlighted, and the record no longer keeps them.
`Has_Highlight` is new. `test_text_buffer_methods` checks both cases.

**Status.** Fixed.

## 80. A Text_Buffer file error gave the wrong reason

**Symptom.** `Load_File` of a missing file raised `Storage_Error` with
"Operation not permitted". A file that couldn't be read gave "No such
file or directory", whatever went wrong.

**Cause.** FLTK returns 1 for a file it can't open and 2 for one it
can't read or write (`Fl_Text_Buffer.cxx:2005-2064`), not an `errno`.
The binding passed those to `strerror`.

**Found.** Phase 12, 2026-11-04, while working around F26.

**Fix.** The shim returns `errno`, or `EIO` if it is 0, and the Ada
side still raises `Storage_Error` with `strerror`'s text.
`Buffer`, which FLTK reads nothing with when it is 0, is `Positive`.
`test_text_buffer_methods` checks a missing file, a directory that
doesn't exist and a directory read as a file. With FLTK's `loadfile`
and `savefile` in the shim, the three fail.

**Status.** Fixed.


## 81. A handler that removed a handler raised Program_Error

**Symptom.** An event handler (`Events.Add_Handler`) that called
`Events.Remove_Handler`, or a clipboard-notify handler that called
`Static.Remove_Clipboard_Notify`, raised `Program_Error`: "attempt to
tamper with cursors". The same was so for a system handler.
PROBLEMS-OUTSTANDING.md listed the clipboard case.

**Cause.** Each hook looped over the package's vector of handlers, and
`Ada.Containers.Vectors` doesn't allow the vector to change while it is
being looped over.

**Found.** Phase 12, 2026-11-04, writing `test_hook_exceptions` for 45.

**Fix.** Each hook loops over a copy of the vector. A handler removed
during the loop is still called for that event, and one added isn't.
The next event goes only to the handlers then listed.
`test_hook_exceptions` has an event handler and a clipboard handler
remove themselves. It checks that the other handlers are still called,
and that the removed one isn't called for the next event. With the old
event hook, it failed with "PROGRAM_ERROR :
FLTK.Events.Handler_Vectors.Implementation.TC_Check: attempt to tamper
with cursors". The system handlers aren't tested.

**Status.** Fixed.


## 82. A dispatch function given a window FLTK made couldn't pass it on

**Symptom.** While a pop-up menu was up, the function set with
`Events.Set_Dispatch` was given its window as null, because FLTK made
that window and it has no Ada object (44). `Handle (Event, null)` then
gave FLTK a null window. FLTK's `Fl::handle_` needs one, and the program
crashed: `test_hook_exceptions` got `STORAGE_ERROR :
s-intman.adb:136 explicit raise` in the release library. In a debug
build, the window's missing user data raised `Internal_FLTK_Error`
first, with "Window passed to Event_Dispatch hook did not have user_data
pointer back to Ada".

**Cause.** `Handle` passed its `Origin`'s FLTK object, or null if
`Origin` was null. Nothing kept the window FLTK had given the hook.

**Found.** Phase 12, 2026-11-04, writing `test_hook_exceptions` for 45.

**Fix.** `Dispatch_Hook` keeps the window FLTK gave while the dispatch
function runs, and `Handle` and `Handle_Dispatch` with a null `Origin`
pass it to FLTK. The window is restored afterwards, so a nested
dispatch is right. `test_hook_exceptions` sets a dispatch function that
calls `Handle (Event, Win)` and pops up a menu. It checks that the
function is given null, that `Show` is among those events, and that the
Escape the probe sends then closes the menu. With null passed as
before, it raised the `STORAGE_ERROR` above. Pop-up menus close at once
on a headless sway, so this part needs X11 and is skipped on sway.

**Status.** Fixed.


## 83. A Menu_Item's text could be drawn as an image or a multi-label

**Symptom.** A menu item given `Set_Label_Kind (Image_Label)`,
`Multi_Label` or `Icon_Label`, or `Set_Label (Kind, Text)` with one of
them, crashed when the menu was drawn. So did `Set_Label (Text)` on an
item that showed an image (`Set_Image`). Valgrind found invalid reads in
`Fl_Image::labeltype` (`Fl_Image.cxx:236`) from `Fl_Menu_Item::draw`
(`Fl_Menu.cxx:338`), or in `fl_measure` from `multi_measure`
(`Fl_Multi_Label.cxx:49-50`), then a segmentation fault. For
`Icon_Label` nothing went wrong, but only because nothing had
registered FLTK's icon label type.

**Cause.** For those kinds FLTK takes an item's label as a pointer to an
`Fl_Image` or an `Fl_Multi_Label`, not as text. 73 kept text and pointer
labels apart for widgets, and for a menu item's `Set_Image` and
`Set_Multi_Label`, but not for these three calls. FLTK registers its
image and multi-label drawing functions only when something first uses
them. Until then a wrong kind draws nothing, which hid the bug.

**Found.** Phase 12, 2026-11-04, checking PROBLEMS-OUTSTANDING.md's
"Menu_Item Set_Label with an image or multi-label kind is meaningless".
A scratch program that used an image and a multi-label first showed the
crashes under valgrind.

**Fix.** In the shim, `Set_Label_Kind` leaves a pointer kind as it is.
`Set_Label (Text)` frees an item's old text and makes a pointer kind
`Normal_Label`, and `Set_Label (Kind, Text)` does the same before it
sets the kind. The spec says so. `test_menu_item_labels` shows a menu
bar with an image item, a multi-label item, and eight items given the
calls above. It checks that the eight are plain text and the first two
keep their kinds. With the old shim it raised `STORAGE_ERROR`. It
passes on Xvfb and on sway, and valgrind finds no errors.

**Status.** Fixed.


## 84. The awake functions and Draw_Pixmap lost their checks in release

**Symptom.** In a release build, `Static.Get_Awake_Handler` with nothing
waiting returned an unset access value, where a debug build raised
`Tasking_Error`. `Add_Awake_Handler` and `Awake` raised nothing when
FLTK failed. `Draw.Draw_Pixmap` raised nothing when FLTK couldn't decode
the data, and drew data whose header didn't match it, reading past its
end as 77 did.

**Cause.** FLTK's results were checked with `pragma Assert`, and the
data with `Pre`, which a release build doesn't check (28).
`Fl::get_awake_handler_` returns -1 and doesn't set the function when
the ring is empty (`Fl_lock.cxx:106-107`). `fl_draw_pixmap` returns 0
for a `Per_Pixel` other than 1 or 2, before it draws anything
(`fl_draw_pixmap.cxx:64-68`, 187).

**Found.** Phase 12, 2026-11-04, removing the `when Assertion_Error`
handlers for 45.

**Fix.** The results are checked explicitly: -1 raises `Tasking_Error`,
and another non-zero result raises `Internal_FLTK_Error`. `Draw_Pixmap`
raises `Draw_Error` for a result of 0. `Pixmap_Marshal.Marshal_Data`,
which both `Pixmaps.Forge.Create` and `Draw_Pixmap` call, now makes 77's
checks. `test_statics_core` checks `Get_Awake_Handler` with nothing
waiting. It also fills FLTK's ring, which holds 1023 handlers
(`Fl_lock.cxx:66`, 85-91), and checks that `Add_Awake_Handler` and
`Awake` then raise `Tasking_Error`, and that `Get_Awake_Handler` gives
each handler back. Without the checks, the three failed with "raised
nothing". `test_pixmap_data` checks that `Draw_Pixmap` refuses a header
with too many lines or colors, and three characters a pixel. Without the
checks, both mismatches raised `STORAGE_ERROR` and valgrind found 4
invalid reads.

**Status.** Fixed.


## 85. A Printer's Start_Job can't tell a cancel from a failure

**Symptom.** `Printers.Start_Job`, both forms, raises `Page_Error`
whether the user cancelled the print dialog or the print command
couldn't be run, and the exception has no message. A program can't
ignore a cancel and report a failure, as FLTK's `test/device.cxx` does
with `fl_alert` and FLTK's message.

**Cause.** On X11 and Wayland, `Fl_Posix_Printer_Driver::begin_job`
returns 1 when the user clicks Cancel (`Fl_Posix_Printer_Driver.cxx:293`),
and 2 when `popen` of the print command fails, with "could not run
command: ..." in `*perr_message`, allocated with `new[]` (lines 366-372).
Printing to a file returns `Fl_PostScript_File_Device::begin_job`'s
result: 1 for a cancelled file chooser, 2 when the file can't be opened
(`Fl_PostScript.cxx:69`, 72). The shim's `fl_printer_start_job` and
`fl_printer_start_job2` pass no `perr_message`, and the Ada bodies raise
`Page_Error` for any result other than 0. The PostScript and PDF devices
already tell the two apart, with `User_Cancel_Error` and
`File_Open_Error` with FLTK's message.

**Found.** Phase 14, 2026-11-04, porting `test/device.cxx`. Its Ada port,
`test/device.adb`, ignores `Page_Error` for now, and says why. Found by
reading FLTK's source; not yet shown by a test, which would need
`FLTK.Probe.Modal` to answer the print dialog.

**Fix.** Not yet. The shim should pass `perr_message`, copy it and free
it with `delete[]`, and `Start_Job` should raise `User_Cancel_Error` for
1 and `Page_Error` with the message otherwise.

**Status.** Open.


## 86. A File_Chooser's kind was an enumeration, not FLTK's bit mask

**Symptom.** `Set_Kind (Directory)` made a chooser that could create
files and pick several, not one that picks directories, and no kind
could combine two of FLTK's, such as `MULTI | CREATE`.

**Cause.** FLTK's `Fl_File_Chooser` type is a bit mask: `SINGLE` 0,
`MULTI` 1, `CREATE` 2 and `DIRECTORY` 4 (Fl_File_Chooser.H:50-55), and
`Fl_File_Chooser::type` tests each bit (Fl_File_Chooser.cxx:422-436).
FLTKAda declared `type Chooser_Kind is (Single, Multi, Create,
Directory)` and passed `Chooser_Kind'Pos`, so `Directory` went to FLTK as
3. `Get_Kind` turned 3 back into `Directory`, so the round trip hid the
error, and it raised `Internal_FLTK_Error` for 4 or any combination.

**Found.** Phase 14, 2026-11-04, porting FLTK's test/file_chooser.cxx,
whose check buttons toggle the kind's bits one at a time.

**Test.** test/unit/test_chooser_kind.adb uses the New button, which
`Fl_File_Chooser::type` activates exactly when `CREATE` is in the kind
(Fl_File_Chooser.cxx:428-431). Against the old code:

```
ok   - Create: the New button is active
FAIL - Directory: the New button is inactive
ok   - Directory: Get_Kind gives it back
 1 check(s) failed.
```

**Fix.** `Chooser_Kind` is now a private flag set, like
`FLTK.Native_File_Choosers.Chooser_Option`: `"+"`, `"-"` and `Includes`,
with `Single`, `Multi`, `Create` and `Directory` as constants holding
FLTK's values. `Forge.Create` and `Set_Kind` pass the mask itself, and
`Get_Kind` checks the result with an explicit test instead of
`pragma Assert`. The test, extended to `Create + Directory`, passes.
The constants are not in tools/gen-constants.py, which can only check
visible constants; `Chooser_Option`'s aren't there either. The New
button check covers `Create` and `Directory` instead.

**Status.** Fixed.

## 87. A Terminal write that scrolled was sometimes never drawn

**Symptom.** In the port of FLTK's test/file_chooser.cxx, the lines a
pick appends to the Terminal ("Picked: 'a.c'" and so on) were in its
buffer but not on the screen until something else redrew it. FLTK's C++
`file_chooser`, driven the same way, shows them.

**Cause.** FLTKAda's workaround for F23 cleared `Fl_Terminal`'s private
`redraw_modified_` flag after every `Fl_Terminal::draw`, under every
redraw style. Under `RATE_LIMITED`, the default, a write only sets the
flag and starts a timer; the timer redraws the terminal if the flag is
still set (src/Fl_Terminal.cxx:2964-2972, 3365-3376). A write that
scrolls also changes the vertical scrollbar, and `set_scrollbar_params`
damages only the scrollbar's rectangle, so the next flush draws the
terminal clipped to that rectangle. The workaround then cleared the flag,
and the timer, finding it clear, stopped without redrawing. gdb on the
test below showed exactly that: one damage, 382,2 16x196 from
`set_scrollbar_params` under `cursor_down`, then a draw, then the timer
doing nothing. In file_chooser, gdb showed the C++ drawing twice after
the appends and FLTKAda once.

**Found.** Phase 14, 2026-11-04, comparing screenshots of the
file_chooser port with the C++ under one Xvfb.

**Test.** test/unit/test_terminal_expose.adb scrolls a terminal with
empty lines, writes a line that scrolls it again, and counts the pixels
in the text area that differ from the background. Against the old code:

```
ok   - the style is Rate_Limited
FAIL - a write that scrolls is shown: 281 -> 281
 1 check(s) failed.
```

**Fix.** `fl_terminal_draw` clears the flag only under `PER_WRITE`,
whose first write calls `redraw()` on the whole terminal, so that draw is
never clipped short. Under `RATE_LIMITED` the timer clears it, as FLTK
means it to. The test passes on X11 and sway (281 -> 941), and
test_terminal_cursor's F23 checks still pass. file_chooser's screen after
a pick now matches the C++ pixel for pixel (AE 0).

**Status.** Fixed.


## 88. Font_Kind could name only the 17 built-in fonts

**Symptom.** `FLTK.Static.Setup_Fonts` (`Fl::set_fonts`) added the
system's fonts, 1788 of them under Xvfb here, but a program couldn't
name, list, size, draw or label in any of them. `Set_Font_Kind` could
only replace one of the 17 built-in fonts, and the font getters would
have raised `Constraint_Error` on reading back a font set in C++.

**Cause.** FLTK's font (`Fl_Font`) is an `int`, and `Fl::set_fonts` and
`Fl::set_font` add fonts from `FL_FREE_FONT` (16) up, growing the table
(fl_set_font.cxx:45-68). FLTKAda declared `Font_Kind` as an enumeration
of `Helvetica` to `Zapf_Dingbats` and `Free_Font`, and passed
`Font_Kind'Pos` and read back with `Font_Kind'Val`, 33 and 23 times in
22 bodies. The getters' `Constraint_Error` is inferred from the range
checks, which both builds keep; it wasn't run. FONT_KIND_ISSUE.md has
the analysis and the options.

**Found.** Phase 14, 2026-11-05, porting FLTK's test/fonts.cxx, which
lists every font `Fl::set_fonts` finds.

**Test.** test/unit/test_font_numbers.adb sets up the system fonts and
names, sizes, measures and labels a box in font 17, reads it back, and
checks the attributes and the bounds below. Against the old code it
didn't compile: the old API has no way to name font 17.

**Fix.** `Font_Kind` is now `new Natural`, FLTK's font number, and the
built-in fonts are constants with FLTK's values, so every call that
names a font is unchanged. Because FLTK doesn't check a font against its
table (pofltk 130), the shim keeps `font_end`, as pofltk's does:
`Setup_Fonts` and `Set_Font_Kind` raise it, and it starts past
`Free_Font`, which `fl_static_grow_fonts` already made safe.
`FLTK.Static.Last_Font` returns it less one. Every font argument goes
through `FLTK.To_C`, which raises `Constraint_Error` on a font past
`Last_Font`; that covers the widget setters too, which pofltk leaves
unchecked. `Set_Font_Kind (Target, Name)` takes a `Target` up to
`Max_Font` (65535, pofltk's `MaxFont`), and the fonts in the gap are
empty. The names it keeps are now in an ordered map, not an array
indexed by `Font_Kind`. New: `Font_Family_Attributes`, the attributes
`Fl::get_font_name` gives, which fonts.cxx shows. tools/gen-constants.py
checks the constants. The test's 25 checks pass on X11 and sway, with
vg=0 and no invalid reads.

**Status.** Fixed.


## 89. Keypress had no function keys

**Symptom.** A program couldn't recognise F1, or any function key, nor
Pause, Print, Menu, Help, Num Lock, Caps Lock, the shift, control, meta
and alt keys themselves, or the ISO and JIS keyboards' extra keys.
`FLTK.Events.Last_Key` returned them, but there was no `Keypress` to
compare it with, and `Keypress` is private.

**Cause.** `spec/fltk.ads` declared 15 of FLTK's named keys (Enter to
Tab) and the keypad, but not `FL_F + n` or the 20 others in
Enumerations.H:487-525.

**Found.** Phase 14, 2026-11-05, porting FLTK's test/fonts.cxx, whose
main window opens its editor on F1.

**Test.** test/unit/test_function_keys.adb checks `Function_Key`,
`Is_Function_Key` and `Function_Number` for F1 to F35, and sends F1 to a
window whose `Handle` compares `Last_Key` with `Function_Key (1)`.
Against the old code it didn't compile. tools/gen-constants.py checks
the 20 new keys, F1, F12 and F35 against FLTK's values.

**Fix.** The 20 keys are constants, and `Function_Key (N)` is `FL_F + N`,
for `N` in `Function_Key_Number`, 1 to 35 (`FL_F_Last` is `FL_F + 35`).
`Is_Function_Key` and `Function_Number` go the other way, as
`Is_Keypad` and `Keypad_Character` do for the keypad. The test passes on
X11 and sway, and test_constants passes.

**Status.** Fixed.


## 90. GL_Window had no Draw_Overlay

**Symptom.** A program could call `Redraw_Overlay` on a `GL_Window`, but
couldn't draw the overlay, because there was nothing to override.
FLTK's test/gl_overlay.cxx draws its red outline that way.

**Cause.** `Fl_Gl_Window::draw_overlay` is virtual, and FLTK calls it
when it flushes a shown GL window after `redraw_overlay`
(Fl_Gl_Window.cxx:238, 275-285). The shim's `My_Gl_Window` passed
`draw` and `handle` to Ada, but not `draw_overlay`, and the Ada side had
no `Draw_Overlay`. pofltk passes it (`Overlaid<Fl_Gl_Window>`,
src/pofltk.h).

**Found.** Phase 14, 2026-11-05, porting FLTK's test/gl_overlay.cxx.

**Test.** test/unit/test_gl_overlay.adb overrides `Draw_Overlay` and
counts its calls: none before `Redraw_Overlay`, then one after each,
after `Draw`. A GL window that doesn't override it still draws. Against
the old code it didn't compile.

**Fix.** `My_Gl_Window::draw_overlay` calls
`gl_window_draw_overlay_hook`, which dispatches to `Draw_Overlay`, and
counts as drawing for the pofltk 111 guard, as `draw` does. The Ada
`Draw_Overlay` does nothing, as FLTK's does, so it need not be
overridden, unlike `Overlay_Window`'s. A GLUT window keeps FLTK's own,
which calls GLUT's overlay display function. The test passes on X11
and sway.

**Status.** Fixed.

## 91. GLUT's overlay calls refused a window not shown

**Symptom.** `FLTK.GLUT.Establish_Overlay`, and `Use_Layer` of
`Overlay_Layer`, raised `Program_Error` when the current window was
hidden. FLTK's test/glut_test.cxx calls `glutEstablishOverlay` right
after `glutHideWindow`, so its port stopped there.

**Cause.** The shim refused them, on the strength of a comment copied
from pofltk (src/gl/FlGlut.cpp:332): "make_overlay_current crashes on a
window not shown". Nothing backs that claim, and pofltk's issue list
doesn't have it. `Fl_Gl_Window::make_overlay_current` is
`make_overlay` and then the driver's `make_overlay_current`
(Fl_Gl_Overlay.cxx:69-72), and on X11 and Wayland that is just
`glDrawBuffer(GL_FRONT)` (Fl_X11_Gl_Window_Driver.cxx:230,
Fl_Wayland_Gl_Window_Driver.cxx:255). `glutCreateWindow` always shows
the window (glut_compatibility.cxx:247-250), so the only GLUT window not
shown is a hidden one. A scratch C++ program called both on a hidden
GLUT window, and on an `Fl_Glut_Window` never shown, made `glut_window`
by hand. It ran to the end on Xvfb and on sway, with no errors under
valgrind.

**Found.** Phase 14, 2026-11-05, porting FLTK's test/glut_test.cxx.

**Test.** test/unit/test_glut_overlay.adb makes the overlay calls on a
GLUT window that is shown, hidden, shown again, and with no current
window. Against the old code the hidden case failed with
`Program_Error`.

**Fix.** The shim calls `glutEstablishOverlay` and `glutUseLayer`
directly, and the Ada side no longer raises. The test passes on X11 and
sway, with no invalid reads or leaks. FLTK.GLUT is new since upstream,
so this isn't an incompatible change. pofltk's copy of the guard skips
the call silently instead, which is the same mistake, but harmless.

**Status.** Fixed.

## 92. `Input_Choice.Set_Item` read past the menu, and counted from 0

**Symptom.** `Input_Choice.Set_Item (-1)` was an invalid read under
valgrind, at Fl_Input_Choice.cxx:288. `Set_Item (5)` on three items read
past them, and `Set_Item` on an input choice with no items raised
`Storage_Error`, from a null pointer. `Set_Item` also counted from 0,
where `Has_Item` and `Item` in the same package, and `Choice.Set_Chosen`,
count from 1, so `Set_Item (1)` chose the second item.

**Cause.** `Set_Item (Num : Integer)` passed `Num` straight to
`Fl_Input_Choice::value (int)`, which calls `menu_->value (i)`, which
checks the range, and then `inp_->value (menu_->text (i))`
(Fl_Input_Choice.cxx:286-289). `Fl_Menu_::text (int)` is
`menu_[i].text`, with no check (Fl_Menu_.H:214). The menu's terminators
are inside `size ()` but have no text, so a number in range can still
clear the input.

**Found.** Phase 14, 2026-11-05, porting FLTK's test/input_choice.cxx,
which calls `in->value (0)`. pofltk checks the number first
(src/FlInputs.Mod, `SetValueIndex`).

**Test.** test/unit/test_input_choice_item.adb sets the first and last
of three items, then item 4, the terminator, and item 1 of no items.
Against the old code, 7 of its checks failed, the last with
`Storage_Error`.

**Fix.** Decided with the user: `Set_Item (Place : Menus.Index)` counts
from 1, like the rest of the package. The shim's
`fl_input_choice_set_value2` now returns 0, and calls nothing, unless
the item exists and has text, and `Set_Item` then raises
`Constraint_Error`. The test passes on X11 and sway, with no valgrind
errors. This is an incompatible change.

**Status.** Fixed.

## 93. `Menu.Has_Item` counts the terminator

**Symptom.** On a `Choice` with three items, `Number_Of_Items` is 4 and
`Has_Item (4)` is True, though item 4 is the terminator that ends the
menu, with no text. On one with no items both are 0 and False. Checked
with a scratch program under Xvfb, 2026-11-05. `Choice.Set_Chosen (4)`
refuses it and returns False, so it isn't a memory error there.

**Cause.** `Number_Of_Items` is `Fl_Menu_::size ()`, which counts the
last terminator, and those of any submenus (Fl_Menu.cxx:58-70).
`Has_Item` is `Place in 1 .. Number_Of_Items`
(body/fltk-widgets-menus.adb:854-860). The spec warns only that
`Number_Of_Items` "may not be what you expect due to submenu
terminators".

**Found.** Phase 14, 2026-11-05, fixing bug 92: a first fix that used
`Has_Item` didn't refuse `Set_Item (4)` of three items.

**Status.** ~~Open. Changing what `Has_Item` and `Number_Of_Items` count
would change every menu, so it wants a decision of its own.~~ Decided
with the user 2026-11-05, and fixed. `Set_Item` doesn't depend on it
(bug 92).

**Iteration.** The menu iterator is `Ada.Iterator_Interfaces (Cursor,
Has_Item)`, and `Next` added 1, so a `for` loop over a menu visited each
terminator too: one with `sub/a` and `sub/b` gave the labels
`one,sub,a,b,,two,` and then the menu's terminator.

**Fixed.** `Has_Item` is true only where FLTK's entry has text, which is
how FLTK tells a terminator (`Fl_Menu_Item::next`, Fl_Menu.cxx:87-104),
through the new shim function `fl_menu_is_item`. The cursors' `First`,
`Next`, `Last` and `Previous` step over the terminators. A submenu's
title is an item. `Number_Of_Items` and `Item` are unchanged: an index
is still a place in FLTK's array, and `Number_Of_Items` is the highest
one. `Input_Choice.Has_Item` forwards to the menu's, so it changes too.
test/unit/test_menu_has_item.adb checks each place in a menu with a
submenu, iteration both ways, an empty menu, and an `Input_Choice`.

## 94. `Slider.Set_Box` sets the knob, even through `Widget'Class`

**Symptom.** A slider's frame box can't be set with `Set_Box` in the
usual way. A slider's own `Set_Box` and `Get_Box` set and get the box of
the knob, FLTK's `Fl_Slider::slider (Fl_Boxtype)`. They override
`Widget.Set_Box` and `Widget.Get_Box`, so a dispatching call does the
same: `Set_Box (Thin_Down_Box)` on a horizontal slider held as a
`Widget'Class` leaves its frame `Down_Box` and changes the knob from
`No_Box` to `Thin_Down_Box`. Code that sets the box of each child of a
group sets a slider's knob. The frame can be set only with a view
conversion, `Widgets.Widget (S).Set_Box`. Checked with a scratch program
under Xvfb, 2026-11-05.

**Cause.** spec/fltk-widgets-valuators-sliders.ads:65-71 declares
`Get_Box` and `Set_Box` for `Slider` with the same profile as Widget's,
and body/fltk-widgets-valuators-sliders.adb:279 calls
`fl_slider_set_slider`. They come from upstream FLTKAda.

**Found.** Phase 14, 2026-11-05, porting test/mandelbrot.cxx, whose
sliders set both: `box (FL_THIN_DOWN_BOX)` and `slider (FL_UP_BOX)`.
test/mandelbrot.adb uses the view conversion for the frame.

**Status.** ~~Open. Renaming the knob's pair (to `Get_Slider_Box` and
`Set_Slider_Box`, say) would change what every program that uses them
does, so it wants the user's decision.~~ Decided with the user
2026-11-05, and fixed.

**Fixed.** The knob's pair is now `Get_Slider_Box` and `Set_Slider_Box`.
`Slider` no longer overrides `Get_Box` and `Set_Box`, so on a slider and
everything derived from it, `Value_Slider` and `Scrollbar` among them,
they set and get the frame, as FLTK's `box ()` does. A program that
called `Set_Box` for the knob still compiles, but now sets the frame.
test/unit/test_slider_box.adb checks a `Slider`, a `Value_Slider` and a
`Scrollbar`: before the fix a dispatching `Set_Box` left each frame as it
was (`Down_Box`, `Down_Box` and `Flat_Box`). test/mandelbrot.adb calls
`Set_Box` and `Set_Slider_Box`, and still gives the C++'s pixels.

## 95. A `Keypress` can't be a non-ASCII character or a control character

**Symptom.** A shortcut on a key that types a-umlaut, the Euro sign,
Hangul cieuc or CR can't be written. FLTK's test/menubar.cxx has all of
them: `0xe4`, `FL_COMMAND+0x20ac`, `0x3148` and `'\r'`. `Press` takes
only a `Pressable_Key`, `Character` 32 .. 126, and the named keys are
FLTK's codes from 0xff00 up.

**Cause.** `Keypress` is private (spec/fltk.ads), and nothing else
makes one. It comes from upstream FLTKAda.

**Found.** Phase 14, 2026-11-05, porting test/menubar.cxx.

**Fixed.** `Character_Key (Item : Wide_Character) return Keypress`
gives the key by its code point. It is an addition, so nothing that
compiled before changes. test/unit/test_character_keys.adb checks that a
menu's shortcuts on all four are picked, given the character as the
window system's text, and checks their labels.

## 96. Reverse iteration over a menu raises `Constraint_Error`

**Symptom.** `for Place in reverse Menu.Iterate loop` raises
`Constraint_Error` (a range check at body/fltk-widgets-menus.adb:867)
when it steps past the first item, after visiting them all. Seen in
test/unit/test_menu_has_item.adb under Xvfb, 2026-11-05, before the fix.

**Cause.** `Previous` of the cursor at item 1 makes one at index 0,
which its `Index'Base` component allows. `Has_Item (Cursor)` passed that
to `Has_Item (Menu, Index)`, and `Index` is `Positive`. It comes from
upstream FLTKAda.

**Found.** Phase 14, 2026-11-05, testing the fix for bug 93.

**Fixed.** `Has_Item (Cursor)` is false for an index outside `Index`.
test/unit/test_menu_has_item.adb iterates both ways, over a menu with
items and over an empty one.

## 97. `FLTK.Screen` numbers screens from 1 in some calls and from 0 in others

**Symptom.** `Get_Scale (Containing (X, Y))` raises `Constraint_Error`
on a display of one screen. `Containing (10, 10)` and
`Containing (10, 10, 5, 5)` return 0 there, while `Count` is 1, and
`Get_Scale` takes 1 .. `Count`. `Work_Area (X, Y, W, H, Screen_Num)`
gives 640 by 480 for both 0 and 1 under Xvfb, since FLTK clamps a number
out of range, so a wrong number goes unnoticed. Seen in a scratch program
under Xvfb, 2026-11-05, and in test/unit/test_screen_numbers.adb before
the fix.

**Cause.** body/fltk-screen.adb passed `Screen_Number - 1` to FLTK in
`DPI`, `Get_Scale` and `Set_Scale`, but passed FLTK's own numbers
through unchanged in `Containing` and in the `Screen_Num` forms of
`Work_Area` and `Bounding_Rect`. Upstream FLTKAda had `DPI` counting
from 1 and the others from 0 (d5fd390); Phase 8 added `Get_Scale` and
`Set_Scale` counting from 1. `DPI` didn't check its number either.

**Found.** Phase 14, 2026-11-05, porting test/offscreen.cxx, which
needs the scale of the screen a window is on.

**Fixed.** Every screen number in `FLTK.Screen` is 1 .. `Count`, the
user's choice: `Containing` returns FLTK's number plus 1, and `DPI`,
`Work_Area` and `Bounding_Rect` raise `Constraint_Error` for a number
outside 1 .. `Count`, as `Get_Scale` and `Set_Scale` do.
test/unit/test_screen_numbers.adb checks each, under X11 and Wayland.

## 98. `Set_Label ("")` gives a widget an empty label, not a null one

**Symptom.** A box with an image and `Set_Label ("")` draws the image
10 pixels higher than one made by `Forge.Create` with the label `""`
(rows 35 and 45 of a 100-pixel box with a 10-pixel image, centred).
test/pixmap_browser.adb, which clears the label after setting the image
as the C++ does with `label (NULL)`, differed from FLTK's C++ by the
image's position. Seen under Xvfb, 2026-11-06, and in
test/unit/test_label_null.adb before the fix.

**Cause.** `Extra_Init` stores an empty label as null
(body/fltk-widgets.adb), but `Set_Label` passed `Interfaces.C.To_C ("")`,
an empty string. FLTK counts a non-null string as at least one line of
text and a null one as none (fl_draw.cxx:254-263), and centres the image
and the lines together (fl_draw.cxx:290). It comes from upstream FLTKAda.

**Found.** Phase 14, 2026-11-06, porting test/pixmap_browser.cxx.

**Fixed.** The user chose that `""` means null. `Set_Label ("")` clears
the label, through FLTK's `copy_label (NULL)` (Fl_Widget.cxx:306-311),
and `Get_Label` still gives `""`. A window's `Set_Label` has its own body
and is unchanged. test/unit/test_label_null.adb checks the image's row
after `Create` with `""`, after `Set_Label ("")`, and after another
label then `""`. examples/draggable_group.adb, whose C++ passes `""`,
clears a box with no image, where both draw nothing.


## 99. `Set_Step_Top` and `Set_Step_Bottom` each set the whole step

**Symptom.** The names say that `Set_Step_Top` sets the numerator of the
step and `Set_Step_Bottom` the denominator, as `Set_Step (Top, Bottom)`
sets both. They don't. `Set_Step_Bottom (4)` makes the step 4, not 1/4,
and `Set_Step_Top (0.25)` makes it 0.25, whatever the denominator was.
Seen with a scratch program under Xvfb, 2026-11-06: `Get_Step` gave
4.0 and 0.25. `Set_Step (1.0, 4)` gave 0.25, as it should.

**Cause.** `fl_valuator_set_step_bottom` calls `Fl_Valuator::step (int)`
and `fl_valuator_set_step_top` calls `step (double)`
(body/c_fl_valuator.cpp). FLTK's `step (int a)` sets A = a and B = 1
(Fl_Valuator.H:106), and `step (double s)` finds the A/B nearest s
(Fl_Valuator.cxx). Each sets the step, A/B, as a whole. A counter's
`Set_Step_Top` (body/c_fl_counter.cpp) calls `Fl_Counter::step (double)`,
which is the same. The behaviour is FLTK's; only the names are wrong.
It comes from upstream FLTKAda. The programs that use them, test/arc,
curve, cursor, menubar, doublebuffer and mandelbrot, all pass 1 or 1.0,
where the step comes out right either way.

**Found.** Phase 14, 2026-11-06, porting test/symbols.cxx, whose
`step (1)` looked like a call for `Set_Step_Bottom`.

**Fixed.** The user chose to add names and keep the old ones.
`Set_Step (This, To)`, with a `Long_Float` or an `Integer`, is FLTK's
`step (double)` or `step (int)`, beside `Set_Step (This, Top, Bottom)`.
A counter inherits them; `Fl_Counter::step (double)` only calls
`Fl_Valuator::step (double)` (Fl_Counter.H:85). `Set_Step_Top` and
`Set_Step_Bottom` stay, call `Set_Step`, and have the `Obsolescent`
aspect and comments saying what they really do. Checked with a scratch
program, 2026-11-06: GNAT warns of the aspect only with `-gnatwj`, and
not on a call through a derived type, such as a `Slider`, so the
comments are what most users will see. The six test programs that used
the old names, and test/symbols.adb, now call `Set_Step`.
test/unit/test_valuator_step.adb checks the step each name gives, old
and new, and that a counter's `Set_Step` leaves its long step alone.


## 100. A shared image made a second time is never released

**Symptom.** `FLTK.Images.Shared.Forge.Create` of an image already in
the pool took two references, and `Finalize` gave back one. An image
made twice stayed in the pool until the program ended, and
`Reference_Count` was too high. Three buttons showing one image at
64x32 gave a count of 5, not 3, plus one for the `Find` that asked.
Seen in test/icons.adb, against pofltk's Icons, and with a scratch
program under Xvfb, 2026-11-06.

**Cause.** `fl_shared_image_get` (body/c_fl_shared_image.cpp) called
`Fl_Shared_Image::find` only to ask whether the image was in the pool,
and kept the reference `find` takes when it finds it
(Fl_Shared_Image.cxx:517, 533). The code was added in Phase 5
(af60997), when the shim began checking files before FLTK reads them.
It isn't in upstream FLTKAda.

**Found.** Phase 14, 2026-11-06, porting pofltk's Icons.

**Fixed.** The shim releases the reference `find` gives it.
test/unit/test_shared_references.adb checks the count after each
`Create` and after each `Finalize`, for the file and for a size of it,
and that both leave the pool.


## 101. `Copy` on an `Image'Class` gives an empty image

**Symptom.** `Pic.Copy (W, H)` or `Pic.Copy`, with `Pic` an
`Image'Class` holding a bitmap, pixmap, RGB, SVG, shared, tiled or
animated GIF image, gave a plain `Image` with no data, which FLTK draws
as a crossed box. Its tag was `FLTK.Images.Image`, and copied to a size
it was empty. Seen in test/icons.adb, whose enlarged XBM, bitmap and
ICO images were crossed boxes, with their labels black, not blue. A
scratch program under Xvfb, 2026-11-06, gave depth 0 and that tag for a
copied XBM.

**Cause.** Each of those seven types declares `Copy` returning its own
class, such as `Bitmap'Class`. That isn't the profile of `Image`'s
`Copy`, which returns `Image'Class`, so it is a new function, not an
override. A call on an `Image'Class` dispatched to `Image`'s `Copy`,
which calls `Fl_Image::copy` with dispatch turned off
(body/c_fl_image.cpp). It comes from upstream FLTKAda. A call on the
specific type, such as `Bitmap'Class'(B.Copy)`, was always right.

**Found.** Phase 14, 2026-11-06, porting pofltk's Icons.

**Fixed.** The user chose to keep the typed `Copy` functions and add
overrides. Each of the seven types also overrides both forms of
`Image`'s `Copy`, with the same body as its own. The overload set is
unchanged, as the program saw the inherited `Image'Class` form
already, so no call that compiled before stops compiling.
`Animated_GIF_Image` has its own overrides, or it would inherit
`Pixmap`'s and copy as a still pixmap. The types below these, such as
PNG or XBM, copy as their parent does, as FLTK's do.
test/unit/test_image_copy_dispatch.adb copies one of each through
`Image'Class` and checks the copy's type, size and data.


## 102. `Help_View.Load` raises for a page the link callback answered

**Symptom.** A link callback can answer a page itself: it sets the
view's content and returns `""`, so FLTK loads nothing. A link clicked
in the view does that well. But `Load` of such a name raised
`Load_Help_Error`, with the page shown. test/help_pages.adb, ported
from pofltk's HelpPages, raised at its first `Load ("page:home")`.
A callback that answered by calling `Load` of a file got the same.

**Cause.** `Fl_Help_View::load` returns -1 when the link function
returns NULL, at once and leaving the view alone
(Fl_Help_View.cxx:3411-3412), and `Load` raises on -1. FLTK can't tell a
refusal from a page answered another way. pofltk's `ofl_help_load`
counts a page set during the load a success. It comes from upstream
FLTKAda, whose `Load` raised on -1 too.

**Found.** Phase 14, 2026-11-06, porting pofltk's HelpPages.

**Fixed.** The user chose pofltk's behaviour. The shim notes a
`Set_Content` or a successful `Load` made while `load()` runs, and
`fl_help_view_load` then returns 0. A refusal that sets nothing still
raises. A nested `Load` keeps the outer load's note.
test/unit/test_help_pages_load.adb checks a page set, a page loaded, and
refusals before and after each.


## 103. A `Clock` can't be made round

**Symptom.** A `Clock` shows a time it is given, but it could only be
square. FLTK's `Fl_Clock_Output` is drawn round when its `type()` is
`FL_ROUND_CLOCK`, and FLTKAda bound no way to set it.
`Round_Clock` is round, but it is an `Updated` clock, which runs.
test/positions.adb, ported from pofltk's Positions, needs a round
clock that shows the positioner's time.

**Cause.** Upstream FLTKAda bound `Fl_Widget::type()` only for the
widgets whose kinds it named, such as `Dial`, and never for the clock.

**Found.** Phase 14, 2026-11-06, porting pofltk's Positions.

**Fixed.** `Clock_Kind` is `(Square_Face, Round_Face)`, FLTK's
`FL_SQUARE_CLOCK` and `FL_ROUND_CLOCK`, and tools/gen-constants.py
checks both. `Get_Kind` is a primitive, and `Set_Kind` is in a nested
`Extra` package, as `Dial`'s is, so that the clocks derived from
`Clock` don't inherit it. test/unit/test_clock_kind.adb checks that a
clock starts square, can be made round and square again, and that a
`Round_Clock` is round.


## 104. A widget freed in a callback goes on being drawn

**Symptom.** A widget freed inside a callback leaves its group, and
FLTK deletes it later, but its window isn't redrawn, so the window goes
on showing it until something else redraws that part.
test/trackers.adb, ported from pofltk's Trackers, frees its button on
the third click, and the button stayed on the screen.

**Cause.** `Fl::delete_widget` hides a widget it queues, and
`Fl_Widget::hide` redraws the widget's group (FLTK 1.4.5,
Fl.cxx:1827, Fl_Widget.cxx:263-267). `Widget`'s `Extra_Final` takes the
widget out of its group first, and only then does `free_fl_widget`
call `Fl::delete_widget`, so there was no group to redraw. Upstream
FLTKAda (2c15b31) removed the widget first too.

**Found.** Phase 14, 2026-11-06, porting pofltk's Trackers.

**Fixed.** `fl_widget_forget`, which `Extra_Final` calls while the
widget is still in its group, hides it when the shim will queue it
(`fl_inside_callback`), as `Fl::delete_widget` would. A widget freed
outside a callback is deleted at once, and FLTK's plain `delete` hides
nothing, so that is unchanged. `Handle` was already sent `FL_HIDE`
during `Finalize`, by `Fl::delete_widget`'s own `hide`; it is now sent a
few calls earlier. test/unit/test_callback_free.adb frees a button in a
callback run by FLTK and checks that its window is damaged; without the
fix it fails. test/trackers.adb then gives pofltk's pixels.


## 105. A tree's margins and an item's activation can't be set

**Symptom.** Of `Fl_Tree`'s margins FLTKAda bound only the left one and
the widget margin, and it could tell whether a tree item was active but
not make it active or inactive. test/tree_icons.adb, ported from
pofltk's TreeIcons, sets the margin below the tree, below an open
item's children, and left of the user icon and of the label, and
deactivates an item to show its deicon.

**Cause.** Upstream FLTKAda bound about 60% of `Fl_Tree` and
`Fl_Tree_Item` (progress.txt), and these were left out.

**Found.** Phase 14, 2026-11-06, porting pofltk's TreeIcons.

**Fixed.** `Trees` has `Get_`/`Set_Margin_Top`, `_Margin_Bottom`,
`_Open_Child_Margin_Bottom`, `_User_Icon_Margin_Left`,
`_Label_Margin_Left` and `_Connector_Width`, as pofltk has, and
`Tree_Items` has `Activate` and `Deactivate`. Neither redraws the tree,
as FLTK's don't. test/unit/test_tree_margins.adb checks FLTK's starting
values (Fl_Tree_Prefs.cxx:96-116), then that each margin moves an item's
label where FLTK draws it by as much as it changed (the bottom margin,
which only changes how far the tree scrolls, is read back), and that
`Deactivate` and `Activate` change the item and its widget and no other
item.


## 106. `Set_Flags` could change a menu's shape

**Symptom.** `Menus.Set_Flags (Menu, Place, Flags)` set the item's
flags to exactly `Flags`. Setting them on a submenu's title without
`Flag_Submenu` made the title a plain item, so a later `Clear_Submenu`
of it raised `No_Reference_Error`, and its items became items of the
level above. Setting `Flag_Submenu` on a plain item made the items after
it its submenu: in a menu of eight entries ("File/Open", "File/Save",
"Edit/Copy"), `Set_Flags (2, Flag_Submenu)` made `Number_Of_Items` 9, one
past the array's last terminator, and `Find_Index ("Edit/Copy")` found
nothing. `System_Menu_Bar.Set_Flags` and `Menu_Item.Set_Flags` on an
item in a menu did the same.

**Cause.** `Fl_Menu_::mode (i, fl)` sets `menu_[i].flags = fl` (Fl_Menu_.H:157), and
`FL_SUBMENU` is what `Fl_Menu_Item::next` and `size` read to find where
a submenu ends. The shim passed the flags straight through. pofltk's
`ofl_menu_set_flags` keeps `FL_SUBMENU` and `FL_SUBMENU_POINTER`.

**Found.** Phase 14, 2026-11-06, porting pofltk's TestMenus, whose
"SetItemFlags keeps Submenu" check failed. The `Number_Of_Items` and
`Find_Index` effects were seen with a scratch program run headless.
Valgrind reported no invalid read in that program.

**Fixed.** `fl_menu_set_mode`, `fl_sys_menu_bar_set_mode` and
`fl_menu_item_set_flags` keep the item's `FL_SUBMENU` and
`FL_SUBMENU_POINTER` and set the rest. `Menu_Item.Set_Flags` does this
only for an item in a menu (one FLTKAda didn't allocate), so an item
made with `Menu_Items.Forge.Create` for `Set_Items` can still be made a
title. test/unit/test_menu.adb checks all three, and that a free item
can still be made a title.


## 107. `Check_Browser.Selected_Index` raised when nothing was selected

**Symptom.** `Check_Browser.Selected_Index` raised `Constraint_Error`
for a check browser with no item selected, such as a new one or one
just cleared.

**Cause.** It returned `Positive`, converting
`Fl_Check_Browser::value ()` (Fl_Check_Browser.H:103), which is 0 when
no item is selected. `Textline_Browser.Selected_Index` returns
`Natural`.

**Found.** Phase 14, 2026-11-06, by test/unit/test_browser.adb, which
asks for it after `Clear`.

**Fixed.** It returns `Natural`. test_browser checks that it gives 0
after `Clear`, and the item's number after a click.


## 108. `File_Browser.Load` couldn't be called as a procedure with its default sort

**Symptom.** `Files.Load ("dir");`, for a `File_Browser`, doesn't
compile: GNAT reports an ambiguous call to `Load`. One must write
`Files.Load (Dir => "dir");` or pass `Sort`. The function form,
`Count := Files.Load ("dir");`, is not ambiguous.

**Cause.** `File_Browser` inherits `Textline_Browser`'s
`procedure Load (This; File : String)`, which loads a text file, and
declares `procedure Load (This; Dir : String; Sort := Numeric_Sort'Access)`.
With `Sort` left out, both match. In C++, `Fl_File_Browser::load
(directory, sort = fl_numericsort)` (Fl_File_Browser.H:74) hides
`Fl_Browser::load`, so the question doesn't arise.

**Found.** Phase 14, 2026-11-06, writing test/unit/test_browser.adb
(GNAT's error message).

**Fixed** (the user's choice, 2026-11-06, of three: this; renaming the
directory `Load`; or leaving it and documenting `Dir =>`).
`File_Browser` overrides the inherited `Load (This; Dir : String)`,
its parameter renamed `Dir`, to list the directory with
`Numeric_Sort`, and `Sort` has no default on the other procedure. The
function keeps its default, since a function call was never ambiguous.
So `Files.Load ("dir")`, `Files.Load (Dir => "dir")` and
`Files.Load ("dir", Sort)` all compile and list the directory. Unlike
C++, where `load` isn't virtual, a dispatching call through
`Textline_Browser'Class` on a file browser lists the directory too,
rather than reading it as a text file. A call naming `File =>` on a
`File_Browser` no longer compiles. test_browser checks the plain call,
the call with a sort, and the class-wide call; every program still
builds.


## 109. `Text_Display.Position_To_XY` gave `Vert_Out` the wrong way round

**Symptom.** `Position_To_XY` set `Vert_Out` to True for a position
shown in the display, and to False for one scrolled out of view.

**Cause.** `Fl_Text_Display::position_to_xy` returns 0 when the
position is vertically out of view, setting X and Y to 0
(Fl_Text_Display.cxx:1098, 1105-1109). The binding set
`Vert_Out := ... /= 0`.

**Found.** Phase 14, 2026-11-06, reading the body while porting pofltk's
TestText, and confirmed under Xvfb by test/unit/test_text.adb: for the
first line of a 20-line buffer in a 100-pixel display `Vert_Out` was
True, for the last False with X and Y 0.

**Fixed.** `Vert_Out := ... = 0`, and the spec says what it means.
test_text checks both lines, and uses the X and Y it gives for a
visible position to find a style's background.


## 110. The shim's `FLTK_ABI_VERSION` guards made some calls do nothing

**Symptom.** `Text_Editor.Set_Tab_Mode`, `Table.Set_Tab_Mode`,
`Table.Set_Scrollbar_Size`, `Tooltips.Set_Margin_Height`,
`Set_Margin_Width` and `Set_Wrap_Width`, and
`System_Menu_Bar.Update` did nothing. `Text_Editor.Get_Tab_Mode` and
`Table.Get_Tab_Mode` always gave the first literal,
`Table.Get_Scrollbar_Size` always 0, and `Scroll.Recalculate_Scrollbars`
left its result unset.

**Cause.** In body/c_fl_text_editor.cpp, c_fl_table.cpp,
c_fl_tooltip.cpp, c_fl_sys_menu_bar.cpp and c_fl_scroll.cpp each of
these calls was inside `#if FLTK_ABI_VERSION >= 103xx`, with an `#else`
that did nothing. FLTK 1.3 called the macro `FLTK_ABI_VERSION`; FLTK
1.4 calls it `FL_ABI_VERSION` (FL/Enumerations.H:149) and doesn't define
the old name, so the preprocessor took it as 0 and compiled the `#else`.
All these methods are always there in 1.4. `Fl_Scroll::recalc_scrollbars`
and `ScrollInfo` are protected, so the unused branch didn't even compile.

**Found.** Phase 14, 2026-11-06: test/unit/test_text.adb's
`Set_Tab_Mode` check failed.

**Fixed.** The guards and their `#else` branches are gone, and
`Friend_Scroll` makes `recalc_scrollbars` and `ScrollInfo` visible, as
it does `bbox`. test/unit/test_abi_guards.adb checks each setter by its
getter and a scroll's scrollbars. It fails five checks when built
against the old shim files. `Fl_Sys_Menu_Bar::update` has no effect to
see off macOS, so it isn't checked. The two `FL_ABI_VERSION >= 10303`
guards in c_fl_help_view.cpp use the right name, and are kept.
examples/table_spreadsheet.adb calls `Set_Tab_Mode (Navigate_Cells)`,
as table-spreadsheet.cxx calls `tab_cell_nav (1)`; until now the call
did nothing there.

## 111. `Tree_Items.Child` read past FLTK's array

**Symptom.** `Tree_Items.Child (Item, Place)` with `Place` past the
last child returned whatever pointer lay beyond the children, which
any later use of the handle followed.

**Cause.** `Fl_Tree_Item::child (int)` is `return _children[index]`
(src/Fl_Tree_Item.cxx:170-172, FL/Fl_Tree_Item.H:208), and
`Fl_Tree_Item_Array::operator[]` doesn't check its index
(FL/Fl_Tree_Item_Array.H:60-62). The binding passed `Place - 1`
straight through. `Swap_Children` by place already checked, and
`Deparent` and `Reparent` are checked by FLTK, which returns an error.

**Found.** Phase 14, 2026-11-06: test/unit/test_tree.adb's check that
`Child (Root, 5)` of four children raises failed.

**Fixed.** `Child` raises `Constraint_Error` when `Place` is past
`Number_Of_Children`. test_tree checks it.


## 112. A table's row heights and column widths took any row or column

**Symptom.** `Table.Set_Row_Height` with a row past `Get_Rows` made FLTK
write past its array (FLTK-issues.md F33). `Set_Column_Width` with a
column past `Get_Columns` grew FLTK's array of widths without adding
columns. `Get_Row_Height` and `Get_Column_Width` with either raised
`Internal_FLTK_Error`, "unexpected int value of 0", since FLTK gives 0
and the binding converted it to `Positive`.

**Cause.** The four passed `Row - 1` or `Column - 1` to FLTK unchecked.
FLTK's setters grow their arrays for an index past the end
(src/Fl_Table.cxx:232-273), and its getters give 0 for one
(`row_height (int)` and `col_width (int)` in FL/Fl_Table.H). pofltk checks the row or column first (CheckRow,
CheckCol in FlTable.Mod).

**Found.** Phase 14, 2026-11-06, writing test/unit/test_table.adb, while
reading the table body for its checks.

**Fixed.** All four raise `Range_Error`, the package's exception for a
row or column out of range, when the row is past `Get_Rows` or the
column past `Get_Columns`. test_table checks each; with the old body
its first check raised `Internal_FLTK_Error`.

## 113. `Table.Bounding_Region` gave uninitialised values for most contexts

**Symptom.** `Bounding_Region` with `Within_Cell`, `No_Context`,
`Start_Page`, `End_Page` or `Row_Column_Resize` printed
"Fl_Table::get_bounds(): context 16 unimplemented" (or the context's
number) on standard error and returned whatever was in its four `out`
integers.

**Cause.** `Fl_Table::get_bounds` handles only `CONTEXT_COL_HEADER`,
`CONTEXT_ROW_HEADER` and `CONTEXT_TABLE` (FLTKAda's `Dead_Zone`, which
gives the region inside the cells' box); for any other context it prints
the message and returns without setting its arguments
(src/Fl_Table.cxx:325-354).

**Found.** Phase 14, 2026-11-06: test/unit/test_table.adb, porting
pofltk's checks of the cells' area with `Within_Cell`, got the message
and wrong values.

**Fixed.** `Bounding_Region` raises `Constraint_Error` for a context
other than `Row_Header`, `Column_Header` and `Dead_Zone`, and the spec
says which region each gives. test_table checks the three regions and
the exception.

## 114. `Scroll.Set_Kind` set the wrong kind of scrollbars

**Symptom.** `Set_Kind (Vertical)` gave a scroll a horizontal
scrollbar, and `Get_Kind` then returned `Horizontal`; `Set_Kind
(Horizontal)` gave it no scrollbars at all, and `Get_Kind` then raised
`Internal_FLTK_Error` ("Fl_Scroll::type returned unexpected unsigned
char value of 0"). Each kind was off by one.

**Cause.** FLTK's scroll types count from 1 (`HORIZONTAL` = 1 to
`BOTH_ALWAYS` = 7, FL/Fl_Scroll.H). `Get_Kind` subtracted 1 from FLTK's
value, but `Set_Kind` passed `Scroll_Kind'Pos (Mode)` without adding it.

**Found.** Phase 14, 2026-11-06: test/unit/test_layout.adb, porting
pofltk's TestLayout. Nothing in test/ or examples/ called `Set_Kind`.

**Fixed.** `Set_Kind` passes `Scroll_Kind'Pos (Mode) + 1`. test_layout
checks that `Set_Kind` and `Get_Kind` agree for `Vertical` and
`Horizontal`, and that a vertical scroll, drawn, shows only its vertical
scrollbar; those checks failed before the fix.


## 115. `Data_Size` of a scaled image was its drawn size

**Symptom.** After `Scale`, an RGB image's or a bitmap's `Data_Size`
was the size it is drawn at, not the size of its pixel data, and
`Get_Datum`, `Set_Datum`, `Slice`, `Overwrite` and `All_Data`, which
overlay an array of `Data_Size` elements on FLTK's data, read and wrote
past it. A 4x2 RGB image scaled to 8x4 gave `Data_Size` 96 instead of
24, and `All_Data` read 72 bytes past the data (valgrind: invalid
reads). An 8x2 bitmap scaled to 64x64 gave 512 instead of 2.

**Cause.** `Data_Size` in fltk-images-rgb.adb and fltk-images-bitmaps.adb
used `Get_W` and `Get_H`, FLTK's `w()` and `h()`, which `scale()`
changes. The data's size is `data_w()` by `data_h()`.

**Found.** Phase 14, 2026-11-06: writing test/unit/test_images.adb, and
confirmed with scratch programs under valgrind.

**Fixed.** Both use `Get_Data_W` and `Get_Data_H`. test_images checks
`Data_Size` and `All_Data'Length` of a scaled RGB image and `Data_Size`
and `Get_Datum` of a scaled bitmap; those checks failed before the fix.

## 116. The pixel data of an SVG image not yet drawn

**Symptom.** `Get_Datum`, `All_Data` and the other data operations on
an `SVG_Image` that hadn't been drawn, resized or normalized raised
`Storage_Error` (a segmentation fault reading address 0).

**Cause.** `Fl_SVG_Image` rasterizes only in `draw()`, `resize()` or
`normalize()` (FL/Fl_SVG_Image.H, src/Fl_SVG_Image.cxx), and until then
its `array` is null. The data operations overlaid an array on
`fl_rgb_image_data`, FLTK's `array`, without checking it.

**Found.** Phase 14, 2026-11-06: test/unit/test_images.adb, whose
first check of an SVG file read its pixels.

**Fixed.** `fl_rgb_image_data` calls FLTK's virtual `normalize()`
first, which rasterizes an SVG image and does nothing to other RGB
images. `Data_Size` calls it before reading the sizes, since
rasterizing can set them, and raises `No_Image_Error` if there is still
no data. test_images checks the pixels of SVG images made from a file,
from text and from bytes, none of them drawn first.

## 117. Flipped images drew the wrong pixels, and read before their data

**Symptom.** `FLTK.Draw.Draw_Image` and `Draw_Image_Mono` with
`Flip_Horizontal` or `Flip_Vertical` didn't draw the image mirrored or
upside down. A 2x2 image flipped either way drew pixels from outside its
data. A 2x8 image flipped vertically read before the start of its data
(valgrind: invalid reads in FLTK's `draw_image_cb`). The checks that
the data is long enough were a `Pre`, which release builds don't check,
so too little data was read past too.

**Cause.** FLTK reads pixel (x, y) at `buf + x * D + y * L`. With `D`
or `L` negative, `buf` must point at the last pixel of the first row or
the first pixel of the last row. The binding negated the depth or the
line size but always passed the first byte of the data. The `Pre`
also asked for `Line_Size * H` bytes where `(H - 1) * Line_Size + W *
Depth` is enough.

**Found.** Phase 14, 2026-11-06: test/unit/test_draw_more.adb, porting
pofltk's TestDrawMore, whose flip checks failed; confirmed with valgrind
and a 2x8 image.

**Fixed.** Both move the start to the far end of the row or the last
row as they flip, and raise `Constraint_Error` when the data is
shorter than `(H - 1) * Stride + W * Depth`, an explicit check in place
of the `Pre`. A width or height below 1 draws nothing (FLTK-issues.md
F34). test_draw_more checks each flip, both, and the mono forms, by
their pixels, and the too-short data; those checks failed before the
fix.

## 118. Preferences: Binary_Data entries counted bytes in pointers

**Symptom.** `FLTK.Environment.Set` of a `Binary_Data` of 3 bytes
stored nothing, and `Get` read it back as no bytes. A `Get` with a
default ignored the default when the entry was missing and returned
no bytes.

**Cause.** Every `Binary_Data` call divided its length by the size of
a pointer before passing it to FLTK, and multiplied `Value_Size` by
it to find how many bytes it got. FLTK's `set (key, data, dsize)` and
`get (key, data, default, defaultSize, maxSize)` take sizes in bytes,
and FLTK keeps the data as hexadecimal text, two characters a byte
(Fl_Preferences.cxx, `set` and `decodeHex`), so `Value_Size` is twice
the number of bytes. So 3 bytes stored as 0 (3 / 8), 16 as 2, and a
`Get` without a limit read eight times as many bytes as FLTK's
`decodeHex` returned, past the end of its buffer (from the source; not
run under valgrind before the fix). The form with a default took its
length from `Value_Size` of the missing entry, which is 0.

**Found.** Phase 14, 2026-11-06: test/unit/test_preferences.adb,
porting pofltk's TestPreferences; its 3-byte check failed.

**Fixed.** The sizes are passed in bytes, the length read back is
`Value_Size / 2`, and a missing entry gives the default, cut to
`Max_Length` in the limited form. test_preferences checks 3 and 16
bytes, the hexadecimal text FLTK keeps, the limit, the default and a
file read back, and passes under valgrind.

## 119. Preferences: Get of a String with Max_Length gave one character fewer

**Symptom.** `Get (Key, Default, Max_Length => 3)` of `"hello"` gave
`"he"`, and of a missing entry the whole default, however long.

**Cause.** FLTK's `get (key, text, default, maxSize)` counts the
trailing nul in `maxSize` (Fl_Preferences.cxx, `strlcpy (text, v,
maxSize)`); the binding passed `Max_Length`. When the default was used
it returned `Default` itself, not limited.

**Found.** Phase 14, 2026-11-06: test/unit/test_preferences.adb.

**Fixed.** It passes `Max_Length + 1`, the size of its buffer, and
cuts a default to `Max_Length`. test_preferences checks both; they
failed before the fix.


## 120. Help_View: Current_Directory and Current_File raised with no file

**Symptom.** `Current_Directory` or `Current_File` of a help view with
no file loaded, or a file named without a directory, raised
`Interfaces.C.Strings.Dereference_Error`.

**Cause.** FLTK's `directory()` and `filename()` return NULL when the
name is empty (Fl_Help_View.H:299-303), and the binding passed it to
`Interfaces.C.Strings.Value` unchecked. `load()` leaves the directory
empty for a name with no `/` (Fl_Help_View.cxx:3378-3385).

**Found.** Phase 14, 2026-11-06: test/unit/test_help.adb.

**Fixed.** Both give "" for NULL. test_help checks a new view, a name
with no directory and one with; it raised before the fix.


## 121. A PostScript device finalized in a job left its file empty

**Symptom.** A `Postscript_File_Device` finalized after `Start_Job` and
before `End_Job` left its file empty, with nothing written, and Cairo's
surface and context were never freed. A PDF surface and an EPS surface
finalized unfinished write their files.

**Cause.** Under Pango, a job's PostScript is written when `end_job`
finishes Cairo's surface (Fl_PostScript.cxx:1946-1953).
`~Fl_PostScript_File_Device` only deletes its driver (:101-104), and
`~Fl_PostScript_Graphics_Driver` only frees the file name (:165-167),
so a job not ended is never finished. The binding's `Finalize` freed
the device without ending it.

**Found.** Phase 14, 2026-11-06: test/unit/test_print.adb, porting
pofltk's TestPrint, whose `Close` ends the page and the job.

**Fixed.** The shim remembers a job that `start_job` started, and the
destructor ends it, as the PDF surface's does. `Finalize` first ends an
open page, as the PDF surface's does. Errors are ignored, as `Finalize`
can't raise. test_print checks that the file of a device finalized in a
translated page is PostScript and ends with `%%EOF`; before the fix it
was empty.


## 122. Normal_Size was a constant

**Symptom.** `FLTK.Normal_Size` was `constant Font_Size := 14`, so a
program couldn't change the size FLTK gives a new widget's label and
text, as a C++ program does by assigning `FL_NORMAL_SIZE`.

**Cause.** `FL_NORMAL_SIZE` is a variable, `extern Fl_Fontsize`
(FL/Enumerations.H), 14 to start with. The binding copied its value.

**Found.** Phase 14, 2026-11-06: test/unit/test_widget.adb, porting
pofltk's TestWidgets, which sets it. The user called the constant a bug.

**Fixed.** `Get_Normal_Size` and `Set_Normal_Size` read and set FLTK's
variable; `Labels`' default size is `Get_Normal_Size`. test_widget
checks that it starts at 14 and that a box made after
`Set_Normal_Size (20)` has label size 20.


## 123. End_Job in a page left the device current

**Symptom.** `End_Job` of a `Postscript_File_Device` or a `Printer`
called between `Start_Page` and `End_Page` left the device the current
surface, so later drawing, including the program's windows, went to the
ended job. The page and its surface stayed in the drawing-state log
(PLAN.md, Architecture decisions, 7) until the device was finalized.

**Cause.** FLTK's `begin_page` pushes the device as the current surface,
and `end_page` pops it (Fl_Paged_Device.cxx:43-100).
`Fl_PostScript_File_Device::end_job` (Fl_PostScript.cxx:1946-1985)
finishes Cairo's surface and closes the file, but doesn't pop it. On
Linux, `Fl_Printer::end_job` calls the `Fl_PostScript_Printer`'s, which
is the same function (Fl_Printer.cxx:212-214). The binding's `End_Job`
set `In_Page` to False without popping its own record of the surface
or forgetting the page. A PDF surface's `End_Job` already raised
`Page_Error` in a page.

**Found.** 2026-11-06, while writing test/unit/test_draw_state.adb,
by reading the binding's `End_Job` and FLTK's `end_job`.

**Fixed.** `End_Job` in a page calls `End_Page` first, as `Finalize`
already did. If that raises `Page_Error`, the job is not ended.
test/unit/test_page_misuse.adb ends a job inside a page and checks
that the device isn't current and the screen is, and that the file has
the page and ends with `%%EOF`. Before the fix, the two checks of the
current surface failed. The `Printer` fix is the same code, unrun:
starting a printer's job opens the print dialog, which the tests don't
drive.
