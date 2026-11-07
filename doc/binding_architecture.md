# FLTKAda Binding Architecture and Extension Guide

This document explains *how* the FLTKAda binding is put together — the
mechanics that let an FLTK C++ widget's virtual `draw()`/`handle()` end up
calling Ada code — and gives step-by-step recipes for adding bindings for
the parts of FLTK 1.4.5 that aren't covered yet.

It is a companion to three documents that already exist:

* `readme.md` — what the binding is, how to build it.
* `progress.txt` — the author's own hand-kept coverage checklist. Still
  mostly accurate (verified against the actual `body/`/`spec/` trees for
  this document — see §8), but predates several classes FLTK 1.4 added in
  later point releases; §8.2 below lists those.
* `doc/index.html` and `doc/<header>.html` — a generated-by-hand,
  page-per-C++-header map from each FLTK constructor/method/class to its
  Ada equivalent. Keep adding to this when you add a binding (§7.4).

Everything below was derived by reading the actual source (`spec/`,
`body/`, `proj/common.gpr`) and the local FLTK 1.4.5 reference at
`/home/tkb/Reference/Computer/GUI/FLTK/1.4.5/fltk-1.4.5/share/doc/fltk/html/`
(and its installed headers under `/usr/include/FL/`), not from memory of
FLTK in general — where the binding does something FLTK's own docs don't
mention, that's noted explicitly.


## 1. Overview: three layers

```
 Ada application code
        |
        v
 spec/fltk-*.ads / body/fltk-*.adb    (Ada binding: tagged types, Forge
        |         ^                    constructors, Wrapper/Finalization,
        |         |                    pragma Import/Export)
        v         |
 body/c_fl_*.h / c_fl_*.cpp           (C++ shim: flattened C API, "My_X"
        |         ^                    wrapper subclasses that thunk
        |         |                    virtual calls back into Ada)
        v         |
      FLTK (C++)                      (the real Fl_Box, Fl_Widget, ...)
```

Ada cannot call C++ directly (no stable ABI for classes, overloading,
templates, or exceptions), so every bound FLTK class gets a **C shim**
file pair, `body/c_fl_<name>.h`/`.cpp`, that:

* wraps each constructor/method the binding needs in a plain
  `extern "C"` function taking/returning only C types (ints, `char *`,
  and an opaque `void *` handle for the object itself);
* for classes with FLTK-invoked virtual methods (`draw()`, `handle()`),
  declares a small subclass (`class My_Box : public Fl_Box { ... }`)
  whose overrides call back into Ada (§3.5).

The Ada side then imports those `extern "C"` functions with
`pragma Import (C, ..., "the_c_name")` and wraps them in an idiomatic
tagged-type API. `doc/cpp_formatting_standard.md` and
`doc/ada_formatting_standard.md` describe the exact formatting
conventions for each side; this document is about the *design*, not the
formatting.


## 2. Anatomy of a bound widget: `Fl_Box` walkthrough

`Fl_Box` (a plain rectangle/label widget, no children, no special
behaviour) is the simplest possible widget binding and a good template
to copy from. Its four files:

* `body/c_fl_box.h`, `body/c_fl_box.cpp` — the C++ shim.
* `spec/fltk-widgets-boxes.ads`, `body/fltk-widgets-boxes.adb` — the Ada
  binding, in package `FLTK.Widgets.Boxes`.

### 2.1 The opaque handle and flattened C API

```c
// c_fl_box.h
typedef void* BOX;

extern "C" BOX new_fl_box(int x, int y, int w, int h, char * label);
extern "C" BOX new_fl_box2(int k, int x, int y, int w, int h, char * label);
extern "C" void free_fl_box(BOX b);

extern "C" void fl_box_draw(BOX n);
extern "C" int fl_box_handle(BOX n, int e);
```

`BOX` is just `void *` — a type-erased pointer to the underlying
`Fl_Box`/`My_Box` C++ object. Every bound class gets its own such
typedef (`WIDGET`, `MENUITEM`, `PREFS`, ...); see
`doc/cpp_formatting_standard.md` §5 for the naming convention
(`new_fl_<thing>` / `free_fl_<thing>` / `fl_<thing>_<action>`).

### 2.2 The subclass that thunks virtual calls into Ada

```c++
// c_fl_box.cpp
extern "C" void widget_draw_hook(void * ud);
extern "C" int widget_handle_hook(void * ud, int e);

class My_Box : public Fl_Box {
public:
    using Fl_Box::Fl_Box;
    friend void fl_box_draw(BOX n);
    friend int fl_box_handle(BOX n, int e);
    void draw();
    int handle(int e);
};

void My_Box::draw() {
    widget_draw_hook(this->user_data());
}
int My_Box::handle(int e) {
    return widget_handle_hook(this->user_data(), e);
}

void fl_box_draw(BOX n) {
    static_cast<My_Box*>(n)->Fl_Box::draw();      // calls Fl_Box's own draw(),
}                                                   // bypassing the override
int fl_box_handle(BOX n, int e) {
    return static_cast<My_Box*>(n)->Fl_Box::handle(e);
}
```

`widget_draw_hook`/`widget_handle_hook` are declared here but *defined
in Ada* (§2.5) — every widget's `My_X::draw()` calls the same two
hooks, generic across all widget types, using FLTK's own
`user_data()` field to find out *which* Ada object it's for.

`fl_box_draw`/`fl_box_handle`, by contrast, call `Fl_Box::draw()`
directly with an explicit scope qualifier — this deliberately
*bypasses* the virtual override and invokes Fl_Box's own default
drawing. This pair exists so Ada has a way to ask "draw/handle this the
way the underlying FLTK class normally would," independent of whatever
the user has overridden in Ada (§2.5 explains why that's needed).

### 2.3 `Wrapper`, `Void_Ptr`, and ownership

Every bound class in Ada ultimately derives from `FLTK.Wrapper`
(`spec/fltk.ads`):

```ada
type Wrapper is new Ada.Finalization.Limited_Controlled with private;
...
type Wrapper is new Ada.Finalization.Limited_Controlled with record
    Void_Ptr      : Storage.Integer_Address := Null_Pointer;
    Needs_Dealloc : Boolean                 := True;
end record;
```

`Void_Ptr` holds the C `BOX`/`WIDGET`/... handle, as an integer address
(Ada can't have a variable-typed `void*` field, so the C boundary always
marshals pointers through `System.Storage_Elements.Integer_Address`).
`Needs_Dealloc` exists because sometimes the Ada wrapper does *not* own
the underlying object — e.g. a `Widget_Reference`/`Group.Child` result
referring to a widget owned by its parent group.

Because `Wrapper` is `Limited_Controlled`, `Finalize` runs
automatically and each leaf type's `Finalize` calls the matching
`free_fl_<thing>`, guarded like this (see `fltk-widgets-boxes.adb`):

```ada
procedure Finalize (This : in out Box) is
begin
    Extra_Final (This);
    if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
        free_fl_box (This.Void_Ptr);
        This.Void_Ptr := Null_Pointer;
    end if;
end Finalize;
```

and on the C++ side (`doc/cpp_formatting_standard.md` §6), every
`free_fl_<thing>` checks `fl_inside_callback` first and calls
`fl_delete_widget` instead of `delete` when set, so a widget being
destroyed *as a side effect of FLTK deleting its parent group* (e.g.
during a callback) doesn't get double-freed.

### 2.4 Constructors: `Forge`, and the `Extra_Init`/`Initialize` split

Constructors live in a nested `Forge` package, not as primitive
operations on the type itself — this keeps `Create` out of the type's
dispatching operation set (so overriding `Draw`/`Handle` in a derived
type doesn't also require re-overriding every `Create`) and dodges the
name clash of every widget type wanting a function called `Create`.
Every leaf widget's `Forge` has (at least) two `Create` overloads: one
that just builds the widget, and one that also takes a
`Parent : in out Group'Class` and adds it — mirroring FLTK's
"added to the current group automatically" behaviour, but explicit.

```ada
package body Forge is
    function Create (X, Y, W, H : in Integer; Text : in String := "") return Box is
    begin
        return This : Box do
            This.Void_Ptr := new_fl_box (Interfaces.C.int (X), ..., Interfaces.C.To_C (Text));
            Extra_Init (This, X, Y, W, H, Text);
        end return;
    end Create;

    function Create (Parent : in out Group'Class; X, Y, W, H : in Integer;
                      Text : in String := "") return Box is
    begin
        return This : Box := Create (X, Y, W, H, Text) do
            Parent.Add (This);
        end return;
    end Create;
end Forge;
```

Construction is split across **two** hooks that run at different times
for a reason:

* `Initialize` — the `Ada.Finalization` callback, runs the instant the
  (still-empty) `Box` object comes into being, *before* `Void_Ptr` is
  even set. Its only job is to point the per-type function pointers:

  ```ada
  procedure Initialize (This : in out Box) is
  begin
      This.Draw_Ptr   := fl_box_draw'Address;
      This.Handle_Ptr := fl_box_handle'Address;
  end Initialize;
  ```

* `Extra_Init` — called explicitly from `Forge.Create` *after*
  `Void_Ptr` is set, once the real C++ object exists. It stores the
  Ada-object-back-reference into FLTK's `user_data()` field (so the
  hooks in §2.5 can find their way back from C++ into Ada) and sets the
  label:

  ```ada
  procedure Extra_Init (This : in out Widget; X, Y, W, H : in Integer; Text : in String) is
  begin
      fl_widget_set_user_data (This.Void_Ptr,
          Storage.To_Integer (Widget_Convert.To_Address (This'Unchecked_Access)));
      fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
  end Extra_Init;
  ```

  A derived type's own `Extra_Init` always calls its parent's first
  (`Extra_Init (Widget (This), ...)` in `Box`'s case) — this is a
  manually-written substitute for constructor chaining, since `Create`
  isn't a primitive operation that overrides/`Super`-style calls would
  apply to. `Extra_Final` is the same idea for teardown, called from
  `Finalize` before the underlying object is freed.

`Widget'Unchecked_Access` is safe to store as a raw address here
specifically *because* `Wrapper` is `Limited_Controlled` — the object
can't be copied or moved out from under that pointer.

### 2.5 The virtual-dispatch trampoline: `Draw_Ptr`/`Handle_Ptr`

This is the part that isn't obvious from reading either side of the
shim alone. `FLTK.Widgets.Widget`'s private record
(`spec/fltk-widgets.ads`) has:

```ada
type Widget is new Wrapper with record
    Callback       : Widget_Callback;
    ...
    Draw_Ptr       : System.Address;
    Handle_Ptr     : System.Address;
end record;

procedure Draw_Hook (U : in Storage.Integer_Address);
pragma Export (C, Draw_Hook, "widget_draw_hook");

function Handle_Hook (U : in Storage.Integer_Address; E : in Interfaces.C.int)
    return Interfaces.C.int;
pragma Export (C, Handle_Hook, "widget_handle_hook");
```

`pragma Export (C, ..., "widget_draw_hook")` is what makes
`extern "C" void widget_draw_hook(void * ud);`, declared in every
shim's `.cpp` file, resolve at link time — the *body* of that
function is Ada, in `fltk-widgets.adb`:

```ada
procedure Draw_Hook (U : in Storage.Integer_Address) is
    Ada_Widget : constant access Widget'Class :=
        Widget_Convert.To_Pointer (Storage.To_Address (U));
begin
    Ada_Widget.Draw;
end Draw_Hook;
```

`Widget_Convert` is a `System.Address_To_Access_Conversions
(Widget'Class)` instantiation, so `Widget_Convert.To_Pointer` recovers
the *tagged* Ada object from the raw address FLTK handed back via
`user_data()` (which `Extra_Init` set), and `Ada_Widget.Draw` is a
normal **dispatching** call — it runs whatever `Draw` the object's
actual (possibly user-derived) tag has, exactly as if it had been
called from Ada code directly.

So: every widget kind's `My_X::draw()` in C++ calls the *same* Ada
`Draw_Hook`, which dispatches on the Ada tag. If a user has overridden
`Draw` for their own derived type, that's what runs. If nobody has
overridden it, dispatch bottoms out at the leaf binding's own `Draw`
(e.g. `Box.Draw`, which just says `Widget (This).Draw;`), which
bottoms out at `Widget.Draw` itself:

```ada
procedure Draw (This : in out Widget) is
    procedure my_draw (V : in Storage.Integer_Address);
    for my_draw'Address use This.Draw_Ptr;
    pragma Import (Ada, my_draw);
begin
    my_draw (This.Void_Ptr);
end Draw;
```

This is the trick: `Draw_Ptr` was set by `Initialize` to
`fl_box_draw'Address` — the address of the *default-drawing*
trampoline from §2.2, which calls `Fl_Box::draw()` directly, bypassing
the virtual override. `Widget.Draw` declares a local procedure whose
`'Address` is overridden to that stored address and imports it with
`pragma Import (Ada, ...)`, then calls it — a standard Ada idiom for
"call through a stored subprogram address" that doesn't need an
access-to-subprogram type at all. Because `Draw_Ptr` is per-*type* (set
once, in `Initialize`, from a plain constant), every leaf widget
package needs its own tiny `fl_<thing>_draw`/`fl_<thing>_handle`
trampoline pair in the shim, purely so `Widget.Draw`/`Widget.Handle`
know how to produce that widget kind's default appearance/behaviour
when nothing overrides it.

`Handle` works identically via `Handle_Ptr`/`fl_box_handle`.

`resize()` is a third virtual routed back into Ada, so that an Ada
override of `Resize` is called when FLTK resizes the widget, as a
window or a group lays out its children. It works differently from
`Draw`/`Handle`, as pofltk's `W` template does (Phase 12). Every
widget's `My_X` derives from `Ada_Resizing<Fl_X>` (`c_fl_widget.h`)
instead of `Fl_X` directly, and inherits its constructors with
`using Ada_Resizing<Fl_X>::Ada_Resizing;`. `Ada_Resizing`'s `resize()`
calls `widget_resize_hook`, which `FLTK.Widgets` exports from
`Resize_Hook`. Before the Ada side has set `user_data()`, it calls
`base_resize()` instead, since FLTK can resize a widget before then.
`base_resize()` is `Fl_X::resize()`; `My_Help_View` and `My_Terminal`
override it to do their own bookkeeping as well. Each Ada `Resize`
default (`Widget`'s, and the overriding ones in `Box`, `Group`,
`Window`, `Table` and the others) calls its `fl_<thing>_resize`, which
calls `ada_default_resize`. That finds the `Ada_Resizer` by
`dynamic_cast` and calls `base_resize()`, not the virtual `resize()`,
which would come back to Ada. So an override that calls the default
runs once, whether FLTK or Ada started the resize. A widget FLTK made
has no `Ada_Resizer`, and gets the virtual `resize()`. The two-argument
`Resize` is FLTK's `size()`, which calls the virtual `resize()`, so it
reaches an override of the four-argument one.
`test/unit/test_resize_hook.adb` checks all of this. A new widget
binding needs nothing more than the `Ada_Resizing` base, and a
`fl_<thing>_resize` that calls `ada_default_resize` if its Ada package
overrides `Resize`.

### 2.6 Callbacks: not the same mechanism as `Draw`/`Handle`

FLTK's other big virtual-ish hook — the "when clicked/changed" callback
— is a *stored value*, not a dispatching override, and works
differently:

```ada
type Widget_Callback is access procedure (Item : in out Widget'Class);
...
procedure Set_Callback (This : in out Widget; Func : in Widget_Callback) is
begin
    if Func /= null then
        This.Callback := Func;
        fl_widget_set_callback (This.Void_Ptr, Storage.To_Integer (Callback_Hook'Address));
    end if;
end Set_Callback;

procedure Callback_Hook (W, U : in Storage.Integer_Address) is
    Ada_Widget : constant access Widget'Class := Widget_Convert.To_Pointer (Storage.To_Address (U));
begin
    Ada_Widget.Callback.all (Ada_Widget.all);
end Callback_Hook;
```

`Set_Callback` stores the caller's access-to-procedure value in the
`Callback` field and tells FLTK to always use the (also
`pragma Export`ed) `Callback_Hook` as its raw C callback. When FLTK
fires it, `Callback_Hook` recovers the Ada object the same way
`Draw_Hook` does, then calls the *stored* access value directly (no
dispatch involved — it's whatever closure/subprogram the caller passed
to `Set_Callback`).

**This distinction matters for extension work.** As `readme.md` notes:
overriding `Draw`/`Handle` changes behaviour, because FLTK itself calls
those via the dispatching hooks above. But something like `Push` on
`FLTK.Widgets.Groups.Tabbed` is normally called *from that widget's own
`Handle`* — a plain Ada primitive call, not routed through a C++
`My_X::method()` override — so overriding `Push` alone does **not**
change `Handle`'s behaviour; you have to override `Handle` too. When
adding a new binding, check whether a method is one FLTK's C++ calls
*into* your object (needs the hook-and-`Draw_Ptr`-style machinery) or
one your own Ada code calls on itself (a plain primitive is enough).


## 3. Everything that isn't a `Widget`

Several parts of FLTK don't need (all of) the machinery above.

### 3.1 Images (`FLTK.Images` and children)

`FLTK.Images.Image` is a `Wrapper` like `Widget`, with `Forge`/
`Extra_Init` following the same shape, but **no** `Draw_Ptr`/hook
machinery — FLTK doesn't call back into user code to draw an image the
way it does for widgets, so there's nothing to dispatch. Adding a new
image format (§7.2) is materially simpler than adding a widget.

### 3.2 `Labels` and `FLTK.Registry`

Most bound objects use FLTK's own `user_data()` slot to store their Ada
back-reference (§2.4). A widget FLTK made itself, such as a dialog's
window, a file chooser's window or a terminal's scrollbar, has user data
of its own or none, so the shim also keeps a table of the widgets
`fl_widget_set_user_data` gave an Ada object, and
`fl_widget_get_user_data` returns 0 for any other widget
(`body/c_fl_widget.cpp`, FLTKAda-BUGS.md 51). Code that turns a C++
widget into its Ada object must treat 0 as "a widget FLTK made", never
as a pointer. A few things FLTK exposes — labels in
particular — have no such slot built in. For those, the private
`FLTK.Registry` package keeps a side table:

```ada
-- body/fltk-registry.ads
type Label_Access is access all FLTK.Labels.Label'Class;
package Label_Backref_Maps is new Ada.Containers.Ordered_Maps
   (Key_Type => Storage.Integer_Address, Element_Type => Label_Access);
Label_Store : Label_Backref_Maps.Map;
```

keyed by the C object's own address. If you're binding something with
callback-ish behaviour but no spare pointer field to repurpose, this is
the pattern to reuse (add a similarly-named map to `FLTK.Registry`, or a
new private child package if it doesn't belong conceptually with
labels).

### 3.3 `Menu_Item`, `Text_Buffers`, `FLTK.Environment` (`Fl_Preferences`)

These all follow the plain `Wrapper`/`Forge`/`Extra_Init` shape (no
draw/handle dispatch) — `Menu_Item` has its own `Callback`/`Set_Callback`
pair exactly like `Widget`'s (§2.6), since FLTK menu items carry their
own callback independent of any widget.

Note the package name doesn't always match the class name:
`Fl_Preferences` is bound as `FLTK.Environment` (types `Database` and
`Pref_Group`) — check `doc/index.html` before assuming a 1:1 name
mapping when looking for something.

### 3.4 Devices and drawing surfaces (`FLTK.Devices.*`)

`Fl_Surface_Device` and its kin don't need the graphics-driver
machinery that widgets need (per `progress.txt`'s own notes,
reproduced in §9) — `Fl_Display_Device`/`Fl_Surface_Device` are handed
a driver by their constructor rather than owning one polymorphically.
`Fl_Copy_Surface`/`Fl_Printer`/`Fl_PostScript_File_Device` *do* need an
internal `Fl_Graphics_Driver'Class`, which is why `FLTK.Devices.Graphics`
is listed as only "Partially Done" and gates several of the To-Do items
in §8.

**Architectural note for extenders:** in FLTK 1.4.5, `Fl_Copy_Surface`,
`Fl_Image_Surface`, and `Fl_Paged_Device` all now derive from a common
`Fl_Widget_Surface` (itself deriving from `Fl_Surface_Device`) — a
class that doesn't exist in the current Ada binding's hierarchy at all.
`FLTK.Devices.Surface.Copy`, `.Image`, and `.Paged` are currently all
direct children of `FLTK.Devices.Surface`, matching FLTK's *older*
layout. See §8.3 for what this means for binding the new PDF/EPS/SVG
file surfaces. (That is §7.3; PLAN.md Phase 11 bound them as its
option 1, flat children of `FLTK.Devices.Surface` and `.Paged`.)

### 3.5 `FLTK.Static` — the free-function ("`Fl::`") API

Everything that isn't a method on some object — the event loop, global
colors and fonts, the clipboard, drag & drop, idle/check/timeout/file-
descriptor callbacks, schemes, box/label custom-draw-function
registration, library `Option`s — lives in `FLTK.Static`, matching
`Fl.H`. If what you're binding is a free function rather than a class
method (e.g. anything from `Fl::`), it belongs here, not in a new
package.

**The display.** FLTKAda opens the display both lazily and on request
(PLAN.md, decision 5). `FLTK.Static.Open_Display` binds
`fl_open_display`, for a program that wants to choose when the
connection is made, and so when FLTK exits if there is none. Nothing
calls it at elaboration, so a program that only uses `FLTK.Filenames` or
`FLTK.Environment` needs no display. Showing a window opens it, and so do
the shim functions for the calls FLTK 1.4.5 would crash in with no
display: `Ready`, the clipboard calls, `Enable_System_Input` and
`Disable_System_Input`, `Set_Box_Color`, `Take_Focus`, `Set_Focus`,
`GL_Window.Can_Do`, `GLUT.Get` and `Copy_Surface`'s constructor. Each
one calls `fl_open_display()` first, which does nothing once the display
is open. A new binding for a call that reaches the screen driver before
any window is shown should do the same; pofltk's `fltk-issues.md` says
which calls do.

**Calls that need a window.** Some calls crash FLTK unless a shown
window, a current window or a GL context is there: `Make_Current`,
`Set_Grab`, `Overlay_Rect`, `Overlay_Clear`, `Scroll`, `FLTK.Draw.OpenGL`'s
text and `Start`, and `GL_Window.Set_Mode` inside `Draw`. The shim checks,
and returns a status, and the Ada side raises `Program_Error` (decision
2). `FLTK.Draw.OpenGL.Start` raises `FLTK.Unsupported_Error` on Wayland,
where FLTK 1.4.5's `gl_start` always crashes. `Fl_Window::current()` stays set after its window is hidden and
dangles after it is deleted, so the shim only compares it with the shown
windows (`Fl::first_window()`/`next_window()`), and never follows it
until it is found there. `Widget`'s `Extra_Final` clears FLTK's grab and
selection owner if they are the widget being freed.


## 4. Supporting machinery worth knowing about before you extend

* **Flag/bitmask records.** Types like `Callback_Flag`, `Menu_Flag`,
  `Damage_Mask` are plain Ada records of `Boolean`s with an explicit
  `for ... use record ... end record` bit layout matching the C enum's
  bit positions, plus `"+"`/`"-"` operators for combining/removing
  flags (`fltk.ads`). Reuse this pattern for any new bitmask-style enum
  rather than inventing something else.
* **Platform-dependent constant tables.** `Cursor_Values` in `fltk.ads`
  is an `array (Mouse_Cursor_Kind) of Interfaces.C.int` mapping the Ada
  enum to FLTK's (not-contiguous, comment says "delightful magic
  numbers") C `Fl_Cursor` values — this is the pattern for any enum
  where the C side isn't a clean `0, 1, 2, ...` sequence you can
  `'Pos`/`'Val` your way through directly.
* **Ada 2012 iterators.** `FLTK.Widgets.Groups.Group` implements
  `Ada.Iterator_Interfaces.Reversible_Iterator`, plus
  `Default_Iterator`/`Variable_Indexing` aspects on the type itself, so
  `for W of My_Group loop ... end loop;` and `My_Group (I)` work. If
  you bind something else that's fundamentally a collection (unlikely,
  but e.g. a future `Fl_Tree` binding might want this for its items),
  this is the idiom to follow, not a hand-rolled `First`/`Next` pair
  with no `Ada.Iterator_Interfaces` involvement.
* **Registering closures as C function pointers.** `fltk-box_draw_marshal.ads`/
  `.adb` and `fltk-label_draw_marshal.ads`/`.adb` show the pattern for
  letting *Ada* code supply a custom box-drawing or label-drawing
  routine that FLTK calls as a raw C function pointer (used by
  `FLTK.Static.Set_Box_Draw_Function`/`Set_Label_Draw_Function`) — a
  small table of `Ada_Access_Array (Box_Kind)` mapping each kind to a
  registered Ada procedure, with a single C-importable trampoline per
  kind that looks itself up in that table and calls through. This is
  the pattern to copy if a future binding needs to hand FLTK an
  Ada-supplied callback for something that isn't a widget method
  (`Fl_Terminal`'s escape-sequence handling, if ever bound, is the kind
  of thing that would need this).


## 5. Project conventions new bindings must follow

* **Style**: `doc/ada_formatting_standard.md` and
  `doc/cpp_formatting_standard.md` describe the exact formatting; the
  editor setup in `ada-ts-mode-fltkada.el` and `cc-mode-fltkada.el`
  (wired into `.dir-locals.el`) reproduces most of it automatically,
  and `gnatpp`/GNAT style checks (`-gnaty...` in `proj/common.gpr`) are
  already enforced at compile time for the Ada side — see
  `doc/gnatpp_configuration.md` for the `gnatpp` config and its known
  gaps.
* **Compiler flags**: new C++ must compile clean under
  `-std=c++11 -Wall -Wextra -Wpedantic -Werror` (`proj/common.gpr`,
  `CPP_Common`) — no C++14-or-later features.
* **`doc/<header>.html`**: add a page for any newly-bound C++ header,
  in the same format as `doc/fl_box.html` (§2 above shows the format
  read back out), and link it from `doc/index.html`'s alphabetical
  list. This is the binding's primary "what maps to what" reference;
  keep it in sync.
* **`progress.txt`**: move the class from "To-Do" to "Done" (using the
  Ada package name, matching the existing list's convention) when you
  finish it, and add a note under "Incomplete APIs" if you leave
  something partial.
* **Tests**: `tests.gpr`/`tests_2022.gpr` list one `Main` per test
  program under `test/`, with a matching `Executable` entry in their
  `Builder` package. `tool/template.adb` is an unrelated code-generation
  helper (does template-variable substitution for repetitive codegen,
  e.g. static char get/set bindings) — not a widget-binding template;
  don't confuse the two.


## 6. How to add a new binding: three recipes

### 6.1 Recipe A — a new `Widget` subclass (most common case)

Worked from `Fl_Box` (§2); use it as the literal starting point for
anything that's "`Fl_Group`/`Fl_Widget` subclass with no unusual
constructor arguments."

1. **Find the parent's Ada package.** Check the class's C++ base class
   (`grep -m1 "^class.*: public" /usr/include/FL/Fl_<Name>.H`) and find
   which `FLTK.Widgets...` package binds that base — the new package is
   a child of it (e.g. a new `Fl_Button` subclass goes under
   `FLTK.Widgets.Buttons`).
2. **C++ shim** (`body/c_fl_<name>.h`/`.cpp`): opaque typedef,
   `new_fl_<name>[N]`/`free_fl_<name>` for each constructor overload you
   intend to bind, a `My_<Name> : public Ada_Resizing<Fl_<Name>>`
   subclass (which sends `resize()` to Ada, §2.5) overriding
   `draw()`/`handle()` to call `widget_draw_hook`/`widget_handle_hook`
   (copy verbatim — every widget's is identical), and
   `fl_<name>_draw`/`fl_<name>_handle` trampolines that call
   `Fl_<Name>::draw()`/`::handle()` explicitly. Add any other methods
   you're binding as plain `extern "C"` functions taking/returning the
   opaque handle and C primitive types.
3. **Ada spec** (`spec/fltk-widgets-...-<name>.ads`): `type <Name> is
   new <Parent> with private`; a `<Name>_Reference` with
   `Implicit_Dereference`; a `Forge` with `Create` overloads (plain, and
   `Parent : in out Group'Class`); `Draw`/`Handle` overrides if the
   widget has FLTK-side default-drawing behaviour distinct from its
   parent (it usually does, even if `Draw`'s body is just
   `Parent_Type (This).Draw;`); in the private part, `overriding
   Initialize`/`Finalize`, and `Extra_Init`/`Extra_Final` if there's
   any additional per-instance setup.
4. **Ada body**: import the shim's C functions with
   `pragma Import (C, ..., "...")`; `Initialize` sets `Draw_Ptr`/
   `Handle_Ptr` to the new `fl_<name>_draw'Address`/
   `fl_<name>_handle'Address`; `Extra_Init`/`Extra_Final` call the
   parent's version first/last respectively; `Forge.Create` allocates
   via `new_fl_<name>` then calls `Extra_Init`.
5. Wire the new source files into `fltkada.gpr`'s source list (it uses
   `Source_Dirs => ("body", "spec")`, so nothing to add there — just
   make sure the file names/package names line up so GNAT finds them).
6. Follow §6.4 for testing and documentation.

### 6.2 Recipe B — a new `Image` subclass

Simpler than a widget: no `Draw_Ptr`/hook machinery needed (§3.1).

1. Find the parent under `FLTK.Images...` the same way as 6.1 step 1
   (e.g. `Fl_SVG_Image : public Fl_RGB_Image` → new child of
   `FLTK.Images.RGB`, alongside the existing `.BMP`/`.JPEG`/`.PNG`/
   `.PNM` siblings).
2. C++ shim: opaque typedef, `new_fl_<name>`/`free_fl_<name>`, plus
   whatever format-specific methods/constructors exist. No `My_X`
   subclass or hooks needed unless the specific image class has a
   virtual method the binding needs to expose (check its header).
3. Ada spec/body: `type <Name> is new <Parent> with private`, `Forge`,
   `Extra_Init`/`Extra_Final` only if there's per-instance state beyond
   what the parent already handles.

### 6.3 Recipe C — a new non-widget, non-image class

Covers things like `FLTK.Environment` (`Fl_Preferences`),
`FLTK.Text_Buffers`, or a hypothetical new device/surface class.

1. Decide whether it's genuinely a new `Wrapper`-derived type (has its
   own allocate/free lifecycle) or free-standing data/free functions
   that belong in `FLTK.Static` (§3.5) or a small new package.
2. If it's a `Wrapper` type: same shim/spec/body shape as Recipe A
   minus the `Draw_Ptr`/hook machinery, unless the class has FLTK-
   invoked callbacks of its own (e.g. a menu item's own callback,
   §3.3) — in which case reuse the `Set_Callback`/`*_Hook` pattern from
   §2.6, or the closure-registration pattern from §4 if FLTK expects a
   raw function pointer rather than something with a `user_data`-style
   escape hatch.
3. If it has no natural owning slot for a back-reference (like
   `Labels`, §3.2): add a map to `FLTK.Registry` (or a sibling private
   package) rather than inventing a new back-reference mechanism.

### 6.4 Testing and documenting what you added

* Write a small `test/<name>.adb` exercising the new binding (see
  existing files under `test/` for the idiomatic shape — construct a
  window, add the widget, `FLTK.Run`), add it to `Main` and `Builder`
  in `tests.gpr`, and confirm it builds and runs with
  `gprbuild tests.gpr` (see `readme.md` for the general build
  instructions; `-Xbuild=debug` turns on `-gnata -gnato` assertions).
* Add `doc/<header>.html` (copy `doc/fl_box.html`'s structure) and link
  it from `doc/index.html`.
* Update `progress.txt`: move the package from To-Do to Done, or add a
  precise note under "Incomplete APIs" for anything left unfinished.


## 7. Coverage gap analysis: FLTK 1.4.5 vs. the current binding

`progress.txt`'s "Done" (Ada package names), "To-Do", and "Never" lists
were cross-checked against every `body/c_fl_*.h` file present and
against the full FLTK 1.4.5 class list (`classes.html` in the local
reference docs, and `/usr/include/FL/*.H`).

### 7.1 `progress.txt`'s existing To-Do list — still accurate

None of these have a `body/c_fl_*.h` shim yet, confirming
`progress.txt` is still correct about them (`Fl_Glut_Window`, `gl.h`
and `glut.H` were also on this list; they're now bound as
`FLTK.Widgets.Groups.Windows.OpenGL.GLUT`, `FLTK.Draw.OpenGL` and
`FLTK.GLUT`):

| Class | Notes |
|---|---|
| `Fl_GDI_Graphics_Driver`, `Fl_GDI_Printer_Graphics_Driver`, `Fl_Quartz_Graphics_Driver`, `Fl_Xlib_Graphics_Driver` | Platform-specific graphics drivers; gated on `FLTK.Devices.Graphics` (currently only "Partially Done"). |
| `Fl_Postscript_Graphics_Driver` | Internal driver used by the already-bound `Fl_PostScript_File_Device`. |

`Fl_Tree`, `Fl_Tree_Item`, `Fl_Tree_Item_Array`, and `Fl_Tree_Prefs` were
on this list as of the original writing of this document; they're now
bound (`FLTK.Tree_Items`, `FLTK.Widgets.Groups.Trees`), first on the
`experimental/fl-tree-binding` branch and now on main, deliberately covering a pragmatic
core of the API rather than full parity — see the "Incomplete APIs"
note for `FLTK.Tree_Items` in `progress.txt` for exactly what was left
out and why, and `test/tree.adb` for a working example. It's a useful
worked example of §6's recipes: `FLTK.Widgets.Groups.Trees` follows
Recipe A: (`Fl_Tree` needs the full `Draw_Ptr`/`Handle_Ptr` machinery,
being a real `Fl_Group` subclass), while `FLTK.Tree_Items` deliberately
does *not* follow the "everything is a `Wrapper`" shape from §2.3 —
`Fl_Tree_Item` objects are always owned by their tree and have no
FLTK-invoked virtual dispatch this binding supports, so `Tree_Item` is
just a thin, freely-copyable pointer-holding record instead. The one
exception is `draw_item_content()`, which is bound by a separate child
package, `FLTK.Tree_Items.Custom`: its `Custom_Item` *is* a `Wrapper`
whose shim subclass dispatches `draw_item_content()` into Ada, and its
`Item` function hands back the plain `Tree_Item` handle for use with
everything else (see `examples/tree_custom_draw_items.adb`).

The "Never" list (binary plugins, XForms legacy compatibility classes,
the two `Fl_*_Printer` classes FLTK's own docs say to avoid in favour of
`Fl_Printer`) is unchanged and still applies.

### 7.2 Classes FLTK added since `progress.txt` was last updated

None of these are mentioned anywhere in `progress.txt` (by class *or*
package name) and none have a shim under `body/`. Roughly in priority
order for an application-facing binding.

This list originally also had `Fl_Flex`, `Fl_Grid`, `Fl_Terminal`,
`Fl_Native_File_Chooser`, `Fl_Anim_GIF_Image`, `Fl_SVG_Image` and
`Fl_Scheme_Choice`. They were bound (as `FLTK.Widgets.Groups.Flex`,
`FLTK.Widgets.Groups.Grids`, `FLTK.Widgets.Groups.Terminals`,
`FLTK.Native_File_Choosers`, `FLTK.Images.Pixmaps.GIF.Animated`,
`FLTK.Images.RGB.SVG` and `FLTK.Widgets.Menus.Choices.Schemes`), along
with `Fl_Multi_Label` (`FLTK.Multi_Labels`), to port FLTK's own
`examples/` directory to Ada (see `examples/`). `Fl_Anim_GIF_Image`
needed no closure registration: FLTK's own timer redraws the canvas.

**Worth binding — user-facing widgets/images/utilities:**

| Class | Parent (C++) | Suggested Ada package | What it is |
|---|---|---|---|
| `Fl_Shortcut_Button` | `Fl_Button` | `FLTK.Widgets.Buttons.Shortcut` | ~~Button that records a key-combo typed into it; small, self-contained.~~ Now bound as `FLTK.Widgets.Buttons.Shortcut` (PLAN.md Phase 10). |
| `Fl_ICO_Image` | `Fl_BMP_Image` | `FLTK.Images.RGB.BMP.ICO` | ~~Windows `.ico` icon files.~~ Now bound as `FLTK.Images.RGB.BMP.ICO` (PLAN.md Phase 10). |
| `Fl_File_Icon` | (standalone) | `FLTK.Images.File_Icons` (or similar) | ~~Icon images used as labels/in file browsers; check whether the already-bound `FLTK.Widgets.Groups.Browsers.Textline.File` (`Fl_File_Browser`) already needs this to be useful.~~ Now bound as `FLTK.Images.File_Icons` (PLAN.md Phase 10). |
| `Fl_Scheme` | (standalone) | extend `FLTK.Static` or new `FLTK.Schemes` | New class-based scheme-registration API. `FLTK.Static` already binds the older string-based `Get_Scheme`/`Set_Scheme`/`Is_Scheme`/`Reload_Scheme` (`Fl::scheme()` etc.) — this is the newer, richer API layered on top, not a replacement. Its three public calls, `num_schemes`, `names` and `add_scheme_name`, are now bound in `FLTK.Static` as `Scheme_Count`, `Scheme_Name` and `Add_Scheme_Name` (PLAN.md Phase 8). |
| `Fl_EPS_File_Surface`, `Fl_PDF_File_Surface`, `Fl_SVG_File_Surface` | `Fl_Widget_Surface`/`Fl_Paged_Device` | `FLTK.Devices.Surface.EPS`/`.PDF`/`.SVG` (or `.Paged.PDF` for the `Fl_Paged_Device`-derived one) | New vector-output drawing surfaces, parallel to the already-bound `.Copy`/`.Image`/`.Paged.Postscript`/`.Paged.Printers`. See §7.3 for the hierarchy wrinkle. Now bound as `FLTK.Devices.Surface.EPS`, `.SVG` and `.Paged.PDF` (PLAN.md Phase 11). |

**Probably not worth binding — internal/superseded/no public header:**

| Class | Why |
|---|---|
| `Fl_Cairo_State` | FLTK's own docs say "For internal use only." |
| `Fl_Gl_Choice`, `Fl_Image_Reader`, `Fl_Mac_App_Menu` | No header installed under `/usr/include/FL/` on this system at all — private/internal implementation classes, not public API. |
| `Fl_Timeout` | FLTK's own docs call it "internal"; its *public* surface is the free functions already bound as `FLTK.Static.Add_Timeout`/`Has_Timeout`/`Remove_Timeout`/`Repeat_Timeout`. Nothing to add. |
| `Fl_Callback_User_Data` | A C++ idiom for typed callback data as an alternative to `void *`; the Ada binding already solves that problem more directly via `Widget_Callback`'s `Widget'Class` dispatch and Ada closures (§2.6). Not needed unless some specific unbound API *requires* passing one. |
| `Fl_Widget_Tracker` | ~~A C++ raw-pointer safe-deletion helper; `Wrapper`'s `Ada.Finalization`-based lifecycle (§2.3) already gives comparable safety in Ada's own idiom. Worth reconsidering only if a future binding needs to detect "did FLTK delete this out from under me during a callback" in a way `Needs_Dealloc` doesn't already cover.~~ Wrong: finalization frees a widget, but nothing tells other code holding an access to it that it is gone, such as a callback that may free its own widget (pofltk's `Trackers` example). Now bound as `FLTK.Widget_Trackers` (PLAN.md Phase 8). |
| `Fl_Rect` | A plain `(X, Y, W, H)` struct that exists in C++ mainly to support overloaded constructors/methods; Ada widget constructors already take `X, Y, W, H : in Integer` directly, so there's no overload-resolution problem for it to solve here. |

### 7.3 The `Fl_Widget_Surface` hierarchy wrinkle

As noted in §3.4, `Fl_Copy_Surface`, `Fl_Image_Surface`, and
`Fl_Paged_Device` all derive from `Fl_Widget_Surface` in 1.4.5, but the
current binding parents `FLTK.Devices.Surface.Copy`/`.Image`/`.Paged`
directly on `FLTK.Devices.Surface`, matching FLTK's pre-`Fl_Widget_Surface`
layout. `Fl_SVG_File_Surface` derives directly from `Fl_Widget_Surface`
(not from `Fl_Paged_Device`), so binding it raises the question
directly. Two options, in order of preference:

1. **Match existing precedent (recommended):** add
   `FLTK.Devices.Surface.SVG` (and `.EPS`) as direct children of
   `FLTK.Devices.Surface`, same as the existing three — `Fl_Widget_Surface`
   itself adds little beyond what `Fl_Surface_Device` already exposes
   through the existing binding, so there's little to lose by
   continuing to flatten it out.
2. **Introduce the intermediate class:** add a genuine
   `FLTK.Devices.Surface.Widget_Surface` package, and re-parent
   `.Copy`/`.Image`/`.Paged` under it. More faithful to upstream, but a
   larger, backwards-incompatible change to an area that's otherwise
   "Done" — only worth it if binding `Fl_Terminal` or something else
   later turns out to need code shared at exactly that level.

**Decided (PLAN.md Phase 11): option 1.** `FLTK.Devices.Surface.EPS` and
`.SVG` are children of `FLTK.Devices.Surface`, and `PDF` is
`FLTK.Devices.Surface.Paged.PDF`, since `Fl_PDF_File_Surface` is an
`Fl_Paged_Device`. EPS and SVG bind `Fl_Widget_Surface`'s `draw`,
`draw_decorated_window` and `print_window_part` themselves, as
`Draw_Widget`, `Draw_Decorated_Window` and `Print_Window_Part`; PDF has
`Paged`'s `Print_Widget` and the rest. Nothing else would have been
shared.

### 7.4 `FLTK.Devices.Graphics` — the actual blocker for several items

Several To-Do items in both §7.1 and the platform-driver items in
`progress.txt` are gated on `FLTK.Devices.Graphics`
(`Fl_Graphics_Driver`), listed as only "Partially Done" and under
"Incomplete APIs." Finishing that binding first
would unblock `Fl_GDI_*`, `Fl_Quartz_Graphics_Driver`,
`Fl_Xlib_Graphics_Driver`, and `Fl_Postscript_Graphics_Driver` — none of
which can be bound meaningfully on their own.


## 8. Known pitfalls (carried over from `progress.txt`, still relevant)

These are the author's own notes and remain true for anyone extending
the binding:

* `Fl_Wizard`'s `draw()` is private/protected in FLTK, which complicates
  the usual `fl_<name>_draw` trampoline pattern (§2.2) — check how
  `FLTK.Widgets.Groups.Wizards` worked around this before assuming
  Recipe A's shim pattern applies unmodified everywhere.
* A GNAT bug combining `type_invariant`, a derived type, and a `begin`
  section in a package body affects at least `dialogs.adb`-style code —
  watch for it if a new binding wants a type invariant.
* `Fl_Bitmap`/`Fl_XBM_Image` instances always report `ERR_NO_IMAGE` from
  `fail()`, regardless of actual state.
* `Fl_Positioner`'s C++ docs are thin on `value`/`xvalue`/`yvalue`
  setter semantics — verify behaviour empirically if extending that
  binding.
* `Fl_Menu_Item::test_shortcut`'s C++ implementation appears to use
  `FL_SUBMENU` (not `FL_SUBMENU_POINTER`) when assuming `user_data`
  points to another menu-item array — re-verify against the FLTK
  version in use before relying on this.
* `Fl_Table::callback`'s signature in the shipped headers doesn't match
  its Doxygen-documented signature (may only be visible when generating
  docs, not to the compiler) — double check before touching
  `FLTK.Widgets.Groups.Tables`.
* Several "Incomplete APIs" remain deliberately partial:
  see `progress.txt`.

### 8.1 Pitfalls found while bringing FLTKAda level with pofltk

PLAN.md has the details of each; FLTK-issues.md and pofltk's
`doc/fltk-issues.md` have the FLTK side.

* **A widget's parts may need their `user_data` (PLAN.md N8).**
  `Extra_Init` sets every wrapped widget's `user_data` to its Ada record
  (§2.3). Some composite widgets give their parts the parent as
  `user_data` instead, and the parts' FLTK callbacks cast it back:
  `Fl_Value_Input`'s and `Fl_Input_Choice`'s input and menu button did,
  so a keystroke in either crashed. Their shims now keep FLTK's callback
  for each part (`callback()` returns it) and install a thunk that calls
  it with `w->parent()`. `Fl_Spinner`, `Fl_Tree`, `Fl_Text_Display` and
  `Fl_Terminal` do the same with parts FLTKAda doesn't wrap yet; wrapping
  one needs the same thunk.
* **No exception may unwind through FLTK's frames (PLAN.md N12,
  FLTK-issues.md F3).** GNAT can unwind an Ada exception through C++
  frames, but FLTK keeps state across a hook call that only a normal
  return restores. Every Ada subprogram FLTK calls (a callback, an
  overridden `Draw` or `Handle`, a timeout, a comparator, a line
  function...) ends with `when Occurrence : others =>
  Hook_Exceptions.Save (Occurrence);` and returns a harmless value. Every
  Ada call into C that can run hooks is followed by
  `Hook_Exceptions.Reraise`. A new hook or a new hook-running call needs
  both (`spec/fltk-hook_exceptions.ads`). If the body has its own
  handler for `Constraint_Error` or `Assertion_Error`, put the old
  statements in a nested block after `Reraise`, so that handler doesn't
  relabel the user's exception (FLTKAda-BUGS.md 45). The hook's first
  declaration is `Mark : constant Hook_Exceptions.Mark :=
  Hook_Exceptions.Entry_Mark;`, and its handler passes it to `Save`, which
  undoes the clips, matrices, surfaces, pages and `OpenGL.Start` pushed
  since (PLAN.md, "Architecture decisions", 7). A new call that pushes
  drawing state FLTK keeps records it with `FLTK.Drawing_State.Remember`,
  and its pop calls `Forget`.
* **Find out whether FLTK keeps a pointer before binding it** (PLAN.md,
  "Architecture decisions", 4). Strings, images and arrays FLTK keeps
  must outlive the call: use FLTK's `copy_*` method, or keep the copy in
  the Ada record (freed in `Extra_Final`) or in the shim. An
  `Interfaces.C.To_C` temporary is right only for a pointer FLTK copies
  (N5: `File_Chooser`'s title was such a temporary, kept as the window
  label).
* **Remove what FLTK holds of an Ada object when it goes** (N10, N11).
  A callback registered with the record's address (a text buffer's
  modify callback) must be removed in `Finalize`, and an image FLTK
  draws (a browser line's icon) must be kept alive, and kept in step
  when FLTK's lines move.
* **A group's FLTK children aren't always its Ada children** (N9).
  `Fl_Table` puts cell widgets in an inner group, so `Extra_Final` must
  detach them there, or `~Fl_Scroll` deletes widgets Ada frees again.
* **Guards against memory errors are explicit raises** (PLAN.md,
  "Architecture decisions", 1). The release build has no `-gnata`, so a
  `Pre` or predicate guards nothing there.
* **No C++ exception may escape the shim.** Wrap image loaders and any
  `new` sized from a file in `try`/`catch`, and return an error code.
* **Check the arithmetic at the boundary** (N1, N2, N3): an `int *`
  indexed in bytes, a line buffer `W` long where FLTK writes
  `W * abs (Depth)`, a `maxbuf` of 0. Test such a binding against the
  actual values, not only that it doesn't crash.
