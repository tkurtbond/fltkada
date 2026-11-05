# FLTKAda: outstanding problems

Known problems and gaps in FLTKAda that are **not** fixed. Most of them were
found while porting FLTK 1.4.5's `examples/` directory. The bugs that were
fixed during that work are in `FLTKAda-BUGS.md`. `progress.txt` is still the
checklist of what is bound; this file explains the problems in more detail.


## Problems found during the porting

### ~~Menu.Add (Text) is ambiguous~~

Fixed in Phase 7 as FLTKAda-BUGS.md 65: the one-string overload is now
`Add_Items`, so `Add (Text)` has only one meaning. Checked again in
Phase 12 with a scratch compile of `C.Add ("a")`, `I := C.Add ("d")` and
`C.Add ("f", Shortcut => "^a")`. The status until then:

A call to `Add (Text)` with only one argument matches both
`Add (This, Text)` and the overload whose other parameters all have defaults,
`Add (This, Text, Action := null, Shortcut := No_Key, Flags := ...)`. GNAT
rejects it as ambiguous, so callers must write `Add (Text, null)`. The ports
in `examples/` do this, for example in howto-browser-with-icons.

### ~~Removing a clipboard handler from inside a handler raises Program_Error~~

Fixed in Phase 12 as FLTKAda-BUGS.md 81: each hook loops over a copy of
its handlers. The event handlers had the same problem, as this entry
guessed, and so did the system handlers. `test_hook_exceptions` checks
the event and clipboard cases. The status until then:

If a clipboard notify handler calls `Remove_Clipboard_Notify`, it raises
Program_Error. This is because the handler vector is being iterated with
`for Call of`, and the vector's tamper check forbids changing it during the
loop. The other handler vectors in `FLTK.Events` probably have the same
problem.

### ~~Dispatch_Hook's error message is misleading~~

Fixed in Phase 12 as FLTKAda-BUGS.md 45, in `Dispatch_Hook` and the
other hooks that did the same: FLTK's values are checked before the
user's code is called, and the user's exception arrives as itself.
`test_hook_exceptions` checks it. The status until then:

`Dispatch_Hook` handles Constraint_Error by reporting an unexpected event
value. It does this for *any* Constraint_Error raised in the user's dispatch
function, so a bug in user code is reported as an FLTK event problem.

### ~~Menu_Item Set_Label with an image or multi-label kind is meaningless~~

Fixed in Phase 12 as FLTKAda-BUGS.md 83. It was worse than meaningless:
drawing such an item crashed once FLTK's image or multi-label drawing
had been used. `Set_Label` and `Set_Label_Kind` now keep text from being
taken as a pointer: the text is shown as a normal label. A precondition
would have been off in release builds (28). The status until then:

`Set_Label (Kind => Image_Label or Multi_Label, Text)` passes `Text` as the
label, but for those label types FLTK treats the label as a pointer to an
`Fl_Image` or an `Fl_Multi_Label`. Use `Set_Image` or `Set_Multi_Label`
instead. A precondition that rejects these kinds might be worth adding.

### Multi_Labels can only be used on menu items

`FLTK.Multi_Labels` binds `Fl_Multi_Label`, but only `Menu_Item.Set_Multi_Label`
uses it. `Fl_Multi_Label::label (Fl_Widget *)` is not bound yet, so a widget
can't be given a multi label.

Within a Multi_Label:
- the text parts are owned by the Ada object;
- images and chained Multi_Labels are not owned, and must outlive it.

### ~~FLTK only calls Resize overrides for some widgets~~

Fixed in Phase 12: every widget's shim class now derives from
`Ada_Resizing`, so FLTK calls an Ada `Resize` override on any widget
(`doc/binding_architecture.md` §2.5, `test/unit/test_resize_hook.adb`).
What follows was the status until then.

The new `widget_resize_hook` lets FLTK call an Ada `Resize` override, but so
far only these use it:
- `FLTK.Widgets.Boxes.Box`
- `Tables.Table`
- `Table_Row`

For any other widget type, FLTK never calls an Ada override of `Resize`.
Adding the hook to another widget means giving its `My_X` shim class a
`resize` override; see `doc/binding_architecture.md` §2.5.

### Group.Child on a Terminal returns unwrapped scrollbars

The children of an `Fl_Terminal` include its internal scrollbars. Their
`user_data` is the C++ terminal pointer, not an Ada wrapper, so
`Group.Child` on a `Terminals.Terminal` returns objects that are not valid
Ada objects.

### Window lists are unsafe with C++-created windows

`FLTK.Widgets.Groups.Windows.Get_First_Window` and `Get_Next_Window` assume
every window has an Ada object. That isn't true of windows FLTK creates
itself, such as the file chooser's.

### Tiled.Tile is a non-owning view

`FLTK.Images.Tiled.Tile` returns a view of the tiled image that does not own
it, so it becomes invalid if the tiled image is finalized.


## Incomplete APIs added during the porting

### FLTK.GLUT and Windows.OpenGL.GLUT

These parts of GLUT are not bound:
- the bitmap and stroke fonts;
- the geometric models (`glutWire*` and `glutSolid*`);
- the `glut_window` and `glut_menu` globals.

Other problems:
- Windows made by `Create_Window` and `Create_Sub_Window` have no Ada
  object.
- FLTK keeps menu labels and the icon title without copying them, so their
  C strings are never freed.

### FLTK.Widgets.Menus.Choices.Schemes

- `init_value` can be called, but not overridden from Ada.
- Setting a callback replaces the built-in scheme-switching callback, because
  `scheme_cb_` is not bound.

### FLTK.Widgets.Groups.Grids

These are not bound:
- `Fl_Grid::Cell`, and `cell (row, col)` and `cell (widget)`;
- the protected members `draw_grid` (virtual), `init`, `add_cell`,
  `remove_cell` and `on_remove`.

### FLTK.Widgets.Groups.Flex

The protected members `init`, `alloc_size` and `on_remove` are not bound.

### FLTK.Widgets.Groups.Terminals

- The nested helper classes are not bound: `Utf8Char`, `RingBuffer`,
  `CharStyle`, `Cursor`, `EscapeSeq`, `Margin` and `Selection`.
- These protected internals are not bound:
  - the `u8c_*` row and character accessors;
  - scrolling, inserting and deleting rows and characters, and the
    `clear_*` operations (the cursor moves are bound as the public
    `Cursor_*` procedures);
  - `handle_unknown_char`, `draw_row*` and `draw_buff`;
  - selection handling.
- `printf` and `vprintf` are replaced by `Print`, which takes a string
  already formatted in Ada.
- `color ()` is not overridden, because `Fl_Terminal`'s version only passes
  through to the inherited one.

### FLTK.Tree_Items and FLTK.Widgets.Groups.Trees

These are deliberately scoped to the commonly used part of the API. The full
list of what is and isn't bound is in `progress.txt`. The main gaps are:
- creating a standalone `Fl_Tree_Item`;
- the low-level child-array operations;
- `item_draw_callback`;
- the path-string overloads of open, close and select;
- the `docallback` parameter;
- `Fl_Tree_Prefs` as an object of its own.


## Problems from before the porting (from progress.txt)

- **Fl_Wizard:** `draw ()` is protected in FLTK, so it can't be bound
  directly.
- **GNAT:** a compiler bug with `Type_Invariant` combined with a derived type
  and a package `begin` section; see `dialogs.adb`.
- **Fl_Bitmap and Fl_XBM_Image:** instances always have `fail ()` return
  `ERR_NO_IMAGE`.
- **Fl_Positioner:** FLTK's own documentation for the `value`, `xvalue` and
  `yvalue` setters is poor.
- **Fl_Menu_Item::test_shortcut:** FLTK's code appears to use `FL_SUBMENU`
  to mean that the user data points to another menu item array, where
  `FL_SUBMENU_POINTER` is meant. This should be checked against current FLTK.
- **Fl_Table::callback:** FLTK declares it with the wrong signature. This is
  still unfixed in 1.4, but is probably only visible in the Doxygen
  documentation.


## Testing environment quirk

Under Xvfb, arrow keys sent with `xdotool` don't move the keyboard cursor in
the table-with-keynav and table-spreadsheet-with-keyboard-nav ports. The
original C++ programs behave exactly the same way, so this comes from the
test environment, not the binding. These keys were not verified
automatically.

## Valgrind reports FLTK's font caches as lost

A program that draws text loses about 390 KB "definitely" under
`valgrind --leak-check=full`, plus about 500 KB indirectly. All of it is
fontconfig's and pango's font caches, allocated when FLTK first draws a
label, and none of it is the binding's: a C++ FLTK program that shows a
window with a labelled box and deletes it loses the same 393,728 bytes in
the same four records as the same program in Ada, and with no label it
loses nothing. libfltkada appears in those stacks only as the caller of
FLTK's drawing (`widget_draw_hook`). Valgrind's ERROR SUMMARY counts each
definitely or possibly lost record as an error (9 here); there are no
memory errors.

So to check a program for the binding's own leaks, look for definitely
lost records whose stacks don't go through fontconfig (`Fc*`) or pango
(`pango_*`). The figures are from FLTK 1.4.5 under Xvfb; other versions
of the font libraries will lose other amounts.
