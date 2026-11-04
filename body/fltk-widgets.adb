

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings,
    FLTK.Widgets.Groups.Windows;

use type

    Interfaces.C.int,
    Interfaces.C.unsigned,
    Interfaces.C.unsigned_char,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets is


    package Chk renames Ada.Assertions;


    package Group_Convert is new
        System.Address_To_Access_Conversions (FLTK.Widgets.Groups.Group'Class);

    package Window_Convert is new
        System.Address_To_Access_Conversions (FLTK.Widgets.Groups.Windows.Window'Class);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_widget
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_widget, "new_fl_widget");
    pragma Inline (new_fl_widget);

    procedure free_fl_widget
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_widget, "free_fl_widget");
    pragma Inline (free_fl_widget);

    procedure fl_widget_forget
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_widget_forget, "fl_widget_forget");
    pragma Inline (fl_widget_forget);




    --  Activity  --

    procedure fl_widget_activate
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_activate, "fl_widget_activate");
    pragma Inline (fl_widget_activate);

    procedure fl_widget_deactivate
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_deactivate, "fl_widget_deactivate");
    pragma Inline (fl_widget_deactivate);

    function fl_widget_active
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_active, "fl_widget_active");
    pragma Inline (fl_widget_active);

    function fl_widget_active_r
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_active_r, "fl_widget_active_r");
    pragma Inline (fl_widget_active_r);

    procedure fl_widget_set_active
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_active, "fl_widget_set_active");
    pragma Inline (fl_widget_set_active);

    procedure fl_widget_clear_active
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_clear_active, "fl_widget_clear_active");
    pragma Inline (fl_widget_clear_active);




    --  Changed and Output  --

    function fl_widget_changed
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_widget_changed, "fl_widget_changed");
    pragma Inline (fl_widget_changed);

    procedure fl_widget_set_changed
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_changed, "fl_widget_set_changed");
    pragma Inline (fl_widget_set_changed);

    procedure fl_widget_clear_changed
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_clear_changed, "fl_widget_clear_changed");
    pragma Inline (fl_widget_clear_changed);

    function fl_widget_output
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_output, "fl_widget_output");
    pragma Inline (fl_widget_output);

    procedure fl_widget_set_output
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_output, "fl_widget_set_output");
    pragma Inline (fl_widget_set_output);

    procedure fl_widget_clear_output
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_clear_output, "fl_widget_clear_output");
    pragma Inline (fl_widget_clear_output);




    --  Visibility  --

    function fl_widget_visible
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_visible, "fl_widget_visible");
    pragma Inline (fl_widget_visible);

    function fl_widget_visible_r
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_visible_r, "fl_widget_visible_r");
    pragma Inline (fl_widget_visible_r);

    procedure fl_widget_set_visible
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_visible, "fl_widget_set_visible");
    pragma Inline (fl_widget_set_visible);

    procedure fl_widget_clear_visible
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_clear_visible, "fl_widget_clear_visible");
    pragma Inline (fl_widget_clear_visible);

    procedure fl_widget_show
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_show, "fl_widget_show");
    pragma Inline (fl_widget_show);

    procedure fl_widget_hide
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_hide, "fl_widget_hide");
    pragma Inline (fl_widget_hide);




    --  Focus  --

    function fl_widget_get_visible_focus
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_visible_focus, "fl_widget_get_visible_focus");
    pragma Inline (fl_widget_get_visible_focus);

    procedure fl_widget_set_visible_focus2
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_visible_focus2, "fl_widget_set_visible_focus2");
    pragma Inline (fl_widget_set_visible_focus2);

    procedure fl_widget_set_visible_focus
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_widget_set_visible_focus, "fl_widget_set_visible_focus");
    pragma Inline (fl_widget_set_visible_focus);

    procedure fl_widget_clear_visible_focus
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_clear_visible_focus, "fl_widget_clear_visible_focus");
    pragma Inline (fl_widget_clear_visible_focus);

    function fl_widget_take_focus
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_take_focus, "fl_widget_take_focus");
    pragma Inline (fl_widget_take_focus);

    function fl_widget_takesevents
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_takesevents, "fl_widget_takesevents");
    pragma Inline (fl_widget_takesevents);




    --  Colors  --

    function fl_widget_get_color
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_widget_get_color, "fl_widget_get_color");
    pragma Inline (fl_widget_get_color);

    procedure fl_widget_set_color
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_set_color, "fl_widget_set_color");
    pragma Inline (fl_widget_set_color);

    function fl_widget_get_selection_color
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_widget_get_selection_color, "fl_widget_get_selection_color");
    pragma Inline (fl_widget_get_selection_color);

    procedure fl_widget_set_selection_color
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_set_selection_color, "fl_widget_set_selection_color");
    pragma Inline (fl_widget_set_selection_color);

    procedure fl_widget_set_colors
           (W    : in Storage.Integer_Address;
            B, S : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_set_colors, "fl_widget_set_colors");
    pragma Inline (fl_widget_set_colors);




    --  Relatives  --

    function fl_widget_get_parent
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_get_parent, "fl_widget_get_parent");
    pragma Inline (fl_widget_get_parent);

    function fl_widget_contains
           (W, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_contains, "fl_widget_contains");
    pragma Inline (fl_widget_contains);

    function fl_widget_inside
           (W, P : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_inside, "fl_widget_inside");
    pragma Inline (fl_widget_inside);

    function fl_widget_window
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_window, "fl_widget_window");
    pragma Inline (fl_widget_window);

    function fl_widget_top_window
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_top_window, "fl_widget_top_window");
    pragma Inline (fl_widget_top_window);

    function fl_widget_top_window_offset
           (W    : in     Storage.Integer_Address;
            X, Y :    out Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_top_window_offset, "fl_widget_top_window_offset");
    pragma Inline (fl_widget_top_window_offset);




    --  Alignment, Box, Tooltip  --

    function fl_widget_get_align
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_widget_get_align, "fl_widget_get_align");
    pragma Inline (fl_widget_get_align);

    procedure fl_widget_set_align
           (W : in Storage.Integer_Address;
            A : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_set_align, "fl_widget_set_align");
    pragma Inline (fl_widget_set_align);

    function fl_widget_get_box
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_box, "fl_widget_get_box");
    pragma Inline (fl_widget_get_box);

    procedure fl_widget_set_box
           (W : in Storage.Integer_Address;
            B : in Interfaces.C.int);
    pragma Import (C, fl_widget_set_box, "fl_widget_set_box");
    pragma Inline (fl_widget_set_box);

    function fl_widget_tooltip
           (W : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_widget_tooltip, "fl_widget_tooltip");
    pragma Inline (fl_widget_tooltip);

    procedure fl_widget_copy_tooltip
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_widget_copy_tooltip, "fl_widget_copy_tooltip");
    pragma Inline (fl_widget_copy_tooltip);




    --  Labels  --

    function fl_widget_get_label
           (W : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_widget_get_label, "fl_widget_get_label");
    pragma Inline (fl_widget_get_label);

    procedure fl_widget_clear_label
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_widget_clear_label, "fl_widget_set_label");
    pragma Inline (fl_widget_clear_label);

    function fl_widget_get_labelcolor
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_widget_get_labelcolor, "fl_widget_get_labelcolor");
    pragma Inline (fl_widget_get_labelcolor);

    procedure fl_widget_set_labelcolor
           (W : in Storage.Integer_Address;
            V : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_set_labelcolor, "fl_widget_set_labelcolor");
    pragma Inline (fl_widget_set_labelcolor);

    function fl_widget_get_labelfont
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_labelfont, "fl_widget_get_labelfont");
    pragma Inline (fl_widget_get_labelfont);

    procedure fl_widget_set_labelfont
           (W : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_widget_set_labelfont, "fl_widget_set_labelfont");
    pragma Inline (fl_widget_set_labelfont);

    function fl_widget_get_labelsize
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_labelsize, "fl_widget_get_labelsize");
    pragma Inline (fl_widget_get_labelsize);

    procedure fl_widget_set_labelsize
           (W : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_widget_set_labelsize, "fl_widget_set_labelsize");
    pragma Inline (fl_widget_set_labelsize);

    function fl_widget_get_labeltype
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_labeltype, "fl_widget_get_labeltype");
    pragma Inline (fl_widget_get_labeltype);

    procedure fl_widget_set_labeltype
           (W : in Storage.Integer_Address;
            L : in Interfaces.C.int);
    pragma Import (C, fl_widget_set_labeltype, "fl_widget_set_labeltype");
    pragma Inline (fl_widget_set_labeltype);

    procedure fl_widget_measure_label
           (W    : in     Storage.Integer_Address;
            D, H : in out Interfaces.C.int);
    pragma Import (C, fl_widget_measure_label, "fl_widget_measure_label");
    pragma Inline (fl_widget_measure_label);




    --  Callbacks  --

    procedure fl_widget_set_callback
           (W, C : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_callback, "fl_widget_set_callback");
    pragma Inline (fl_widget_set_callback);

    procedure fl_widget_default_callback
           (W, U : in Storage.Integer_Address);
    pragma Import (C, fl_widget_default_callback, "fl_widget_default_callback");
    pragma Inline (fl_widget_default_callback);

    function fl_widget_get_when
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_get_when, "fl_widget_get_when");
    pragma Inline (fl_widget_get_when);

    procedure fl_widget_set_when
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_when, "fl_widget_set_when");
    pragma Inline (fl_widget_set_when);




    --  Dimensions  --

    function fl_widget_get_x
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_x, "fl_widget_get_x");
    pragma Inline (fl_widget_get_x);

    function fl_widget_get_y
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_y, "fl_widget_get_y");
    pragma Inline (fl_widget_get_y);

    function fl_widget_get_w
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_w, "fl_widget_get_w");
    pragma Inline (fl_widget_get_w);

    function fl_widget_get_h
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_get_h, "fl_widget_get_h");
    pragma Inline (fl_widget_get_h);

    procedure fl_widget_size
           (W    : in Storage.Integer_Address;
            D, H : in Interfaces.C.int);
    pragma Import (C, fl_widget_size, "fl_widget_size");
    pragma Inline (fl_widget_size);

    procedure fl_widget_resize
           (O          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_widget_resize, "fl_widget_resize");
    pragma Inline (fl_widget_resize);

    procedure fl_widget_position
           (W    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_widget_position, "fl_widget_position");
    pragma Inline (fl_widget_position);




    --  Images  --

    procedure fl_widget_set_image
           (W, I : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_image, "fl_widget_set_image");
    pragma Inline (fl_widget_set_image);

    procedure fl_widget_set_deimage
           (W, I : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_deimage, "fl_widget_set_deimage");
    pragma Inline (fl_widget_set_deimage);




    --  Damage, Drawing, Events  --

    function fl_widget_damage
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_damage, "fl_widget_damage");
    pragma Inline (fl_widget_damage);

    procedure fl_widget_set_damage
           (W : in Storage.Integer_Address;
            M : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_damage, "fl_widget_set_damage");
    pragma Inline (fl_widget_set_damage);

    procedure fl_widget_set_damage2
           (W          : in Storage.Integer_Address;
            M          : in Interfaces.C.unsigned_char;
            X, Y, D, H : in Interfaces.C.int);
    pragma Import (C, fl_widget_set_damage2, "fl_widget_set_damage2");
    pragma Inline (fl_widget_set_damage2);

    procedure fl_widget_clear_damage
           (W : in Storage.Integer_Address;
            M : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_clear_damage, "fl_widget_clear_damage");
    pragma Inline (fl_widget_clear_damage);

    procedure fl_widget_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_draw, "fl_widget_draw");
    pragma Inline (fl_widget_draw);

    procedure fl_widget_draw_label
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_draw_label, "fl_widget_draw_label");
    pragma Inline (fl_widget_draw_label);

    procedure fl_widget_draw_label2
           (O          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_widget_draw_label2, "fl_widget_draw_label2");
    pragma Inline (fl_widget_draw_label2);

    procedure fl_widget_draw_label3
           (W          : in Storage.Integer_Address;
            X, Y, D, H : in Interfaces.C.int;
            A          : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_draw_label3, "fl_widget_draw_label3");
    pragma Inline (fl_widget_draw_label3);

    procedure fl_widget_draw_backdrop
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_draw_backdrop, "fl_widget_draw_backdrop");
    pragma Inline (fl_widget_draw_backdrop);

    procedure fl_widget_draw_box
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_draw_box, "fl_widget_draw_box");
    pragma Inline (fl_widget_draw_box);

    procedure fl_widget_draw_box2
           (W : in Storage.Integer_Address;
            K : in Interfaces.C.int;
            H : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_draw_box2, "fl_widget_draw_box2");
    pragma Inline (fl_widget_draw_box2);

    procedure fl_widget_draw_box3
           (O             : in Storage.Integer_Address;
            K, X, Y, W, H : in Interfaces.C.int;
            C             : in Interfaces.C.unsigned);
    pragma Import (C, fl_widget_draw_box3, "fl_widget_draw_box3");
    pragma Inline (fl_widget_draw_box3);

    procedure fl_widget_draw_focus
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_draw_focus, "fl_widget_draw_focus");
    pragma Inline (fl_widget_draw_focus);

    procedure fl_widget_draw_focus2
           (O             : in Storage.Integer_Address;
            K, X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_widget_draw_focus2, "fl_widget_draw_focus2");
    pragma Inline (fl_widget_draw_focus2);

    procedure fl_widget_redraw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_redraw, "fl_widget_redraw");
    pragma Inline (fl_widget_redraw);

    procedure fl_widget_redraw_label
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_widget_redraw_label, "fl_widget_redraw_label");
    pragma Inline (fl_widget_redraw_label);

    function fl_widget_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_handle, "fl_widget_handle");
    pragma Inline (fl_widget_handle);




    --  Miscellaneous  --

    function fl_widget_use_accents_menu
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_widget_use_accents_menu, "fl_widget_use_accents_menu");
    pragma Inline (fl_widget_use_accents_menu);




    procedure fl_event_end_paste;
    pragma Import (C, fl_event_end_paste, "fl_event_end_paste");
    pragma Inline (fl_event_end_paste);




    ----------------------
    --  Exported Hooks  --
    ----------------------

    procedure Callback_Hook
           (W, U : in Storage.Integer_Address)
    is
        Ada_Widget : constant access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (U));
    begin
        Ada_Widget.Callback.all (Ada_Widget.all);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Callback_Hook;


    procedure Draw_Hook
           (U : in Storage.Integer_Address)
    is
        Ada_Widget : constant access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (U));
    begin
        Ada_Widget.Draw;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Draw_Hook;


    --  How many Handles of a Paste event are running.  As the outermost
    --  returns, a pasted image not taken is deleted (pofltk 48), and the
    --  clipboard type is set back to text (FLTK-issues.md F13; c_fl_event.cpp).
    Paste_Depth : Natural := 0;

    function Handle_Hook
           (U : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int
    is
        Ada_Widget : constant access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (U));
        Is_Paste   : constant Boolean := E = Event_Kind'Pos (Paste);
        Result     : Event_Outcome := Not_Handled;
    begin
        if Is_Paste then
            Paste_Depth := Paste_Depth + 1;
        end if;
        begin
            Result := Ada_Widget.Handle (Event_Kind'Val (E));
        exception
        when Occurrence : others =>
            Hook_Exceptions.Save (Occurrence);
            Result := Not_Handled;
        end;
        if Is_Paste then
            Paste_Depth := Paste_Depth - 1;
            if Paste_Depth = 0 then
                fl_event_end_paste;
            end if;
        end if;
        return Event_Outcome'Pos (Result);
    end Handle_Hook;


    procedure Resize_Hook
           (U          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int)
    is
        Ada_Widget : constant access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (U));
    begin
        Ada_Widget.Resize (Integer (X), Integer (Y), Integer (W), Integer (H));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Resize_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Widget)
    is
        Maybe_Parent : access FLTK.Widgets.Groups.Group'Class;
    begin
        --  A widget declared without Forge.Create has no FLTK widget, nor a
        --  parent to ask for (FLTKAda-BUGS.md 68).
        if This.Needs_Dealloc and This.Void_Ptr /= Null_Pointer then
            --  FLTK would keep a grab or selection naming it (pofltk 129).
            fl_widget_forget (This.Void_Ptr);
            Maybe_Parent := This.Parent;
            if Maybe_Parent /= null then
                Maybe_Parent.Remove (This);
            end if;
        end if;
    end Extra_Final;


    procedure Finalize
           (This : in out Widget) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_widget (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Widget;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        fl_widget_set_user_data
           (This.Void_Ptr,
            Storage.To_Integer (Widget_Convert.To_Address (This'Unchecked_Access)));
        --  An empty label is stored as null, as C++ code that leaves out the
        --  label would get, since FLTK treats the two differently in places
        --  such as Fl_Label::draw setting the font and Fl_Message's icon
        if Text = "" then
            fl_widget_clear_label (This.Void_Ptr, Interfaces.C.Strings.Null_Ptr);
        else
            fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
        end if;
    end Extra_Init;


    procedure Initialize
           (This : in out Widget) is
    begin
        This.Draw_Ptr   := fl_widget_draw'Address;
        This.Handle_Ptr := fl_widget_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Widget is
        begin
            return This : Widget do
                This.Void_Ptr := new_fl_widget
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Widget is
        begin
            return This : Widget := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Activity  --

    procedure Activate
           (This : in out Widget) is
    begin
        fl_widget_activate (This.Void_Ptr);
    end Activate;


    procedure Deactivate
           (This : in out Widget) is
    begin
        fl_widget_deactivate (This.Void_Ptr);
    end Deactivate;


    function Is_Active
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_active (This.Void_Ptr) /= 0;
    end Is_Active;


    function Is_Tree_Active
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_active_r (This.Void_Ptr) /= 0;
    end Is_Tree_Active;


    procedure Set_Active
           (This : in out Widget) is
    begin
        fl_widget_set_active (This.Void_Ptr);
    end Set_Active;


    procedure Set_Active
           (This : in out Widget;
            To   : in     Boolean) is
    begin
        if To then
            fl_widget_set_active (This.Void_Ptr);
        else
            fl_widget_clear_active (This.Void_Ptr);
        end if;
    end Set_Active;


    procedure Clear_Active
           (This : in out Widget) is
    begin
        fl_widget_clear_active (This.Void_Ptr);
    end Clear_Active;




    --  Changed and Output  --

    function Has_Changed
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_changed (This.Void_Ptr) /= 0;
    end Has_Changed;


    procedure Set_Changed
           (This : in out Widget) is
    begin
        fl_widget_set_changed (This.Void_Ptr);
    end Set_Changed;


    procedure Set_Changed
           (This : in out Widget;
            To   : in     Boolean) is
    begin
        if To then
            fl_widget_set_changed (This.Void_Ptr);
        else
            fl_widget_clear_changed (This.Void_Ptr);
        end if;
    end Set_Changed;


    procedure Clear_Changed
           (This : in out Widget) is
    begin
        fl_widget_clear_changed (This.Void_Ptr);
    end Clear_Changed;


    function Is_Output_Only
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_output (This.Void_Ptr) /= 0;
    end Is_Output_Only;


    procedure Set_Output_Only
           (This : in out Widget) is
    begin
        fl_widget_set_output (This.Void_Ptr);
    end Set_Output_Only;


    procedure Set_Output_Only
           (This : in out Widget;
            To   : in     Boolean) is
    begin
        if To then
            fl_widget_set_output (This.Void_Ptr);
        else
            fl_widget_clear_output (This.Void_Ptr);
        end if;
    end Set_Output_Only;


    procedure Clear_Output_Only
           (This : in out Widget) is
    begin
        fl_widget_clear_output (This.Void_Ptr);
    end Clear_Output_Only;




    --  Visibility  --

    function Is_Visible
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_visible (This.Void_Ptr) /= 0;
    end Is_Visible;


    function Is_Tree_Visible
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_visible_r (This.Void_Ptr) /= 0;
    end Is_Tree_Visible;


    procedure Set_Visible
           (This : in out Widget) is
    begin
        fl_widget_set_visible (This.Void_Ptr);
    end Set_Visible;


    procedure Set_Visible
           (This : in out Widget;
            To   : in     Boolean) is
    begin
        if To then
            fl_widget_set_visible (This.Void_Ptr);
        else
            fl_widget_clear_visible (This.Void_Ptr);
        end if;
    end Set_Visible;


    procedure Clear_Visible
           (This : in out Widget) is
    begin
        fl_widget_clear_visible (This.Void_Ptr);
    end Clear_Visible;


    procedure Show
           (This : in out Widget) is
    begin
        fl_widget_show (This.Void_Ptr);
    end Show;


    procedure Hide
           (This : in out Widget) is
    begin
        fl_widget_hide (This.Void_Ptr);
    end Hide;




    --  Focus  --

    function Has_Visible_Focus
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_get_visible_focus (This.Void_Ptr) /= 0;
    end Has_Visible_Focus;


    procedure Set_Visible_Focus
           (This : in out Widget) is
    begin
        fl_widget_set_visible_focus2 (This.Void_Ptr);
    end Set_Visible_Focus;


    procedure Set_Visible_Focus
           (This : in out Widget;
            To   : in     Boolean) is
    begin
        fl_widget_set_visible_focus (This.Void_Ptr, Boolean'Pos (To));
    end Set_Visible_Focus;


    procedure Clear_Visible_Focus
           (This : in out Widget) is
    begin
        fl_widget_clear_visible_focus (This.Void_Ptr);
    end Clear_Visible_Focus;


    function Take_Focus
           (This : in out Widget)
        return Boolean is
    begin
        return fl_widget_take_focus (This.Void_Ptr) /= 0;
    end Take_Focus;


    function Takes_Events
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_takesevents (This.Void_Ptr) /= 0;
    end Takes_Events;




    --  Colors  --

    function Get_Background_Color
           (This : in Widget)
        return Color is
    begin
        return Color (fl_widget_get_color (This.Void_Ptr));
    end Get_Background_Color;


    procedure Set_Background_Color
           (This : in out Widget;
            To   : in     Color) is
    begin
        fl_widget_set_color (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Background_Color;


    function Get_Selection_Color
           (This : in Widget)
        return Color is
    begin
        return Color (fl_widget_get_selection_color (This.Void_Ptr));
    end Get_Selection_Color;


    procedure Set_Selection_Color
           (This : in out Widget;
            To   : in     Color) is
    begin
        fl_widget_set_selection_color (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Selection_Color;


    procedure Set_Colors
           (This      : in out Widget;
            Back, Sel : in     Color) is
    begin
        fl_widget_set_colors
           (This.Void_Ptr,
            Interfaces.C.unsigned (Back),
            Interfaces.C.unsigned (Sel));
    end Set_Colors;




    --  Relatives  --

    function Parent
           (This : in Widget)
        return access FLTK.Widgets.Groups.Group'Class
    is
        Parent_Ptr : Storage.Integer_Address := fl_widget_get_parent (This.Void_Ptr);
        Actual_Parent : access FLTK.Widgets.Groups.Group'Class;
    begin
        if Parent_Ptr /= Null_Pointer then
            Parent_Ptr := fl_widget_get_user_data (Parent_Ptr);
            --  Can't assert user data being not null here because fl_ask is a bitch,
            --  so have to fall back on saying that if it's null then you get nothing.
            --  Any widget created by users of this binding will have appropriate back
            --  reference to the corresponding Ada object in the user data anyway.
            Actual_Parent := Group_Convert.To_Pointer (Storage.To_Address (Parent_Ptr));
        end if;
        return Actual_Parent;
    end Parent;


    function Contains
           (This : in Widget;
            Item : in Widget'Class)
        return Boolean is
    begin
        return fl_widget_contains (This.Void_Ptr, Item.Void_Ptr) /= 0;
    end Contains;


    function Inside
           (This   : in Widget;
            Parent : in Widget'Class)
        return Boolean is
    begin
        return fl_widget_inside (This.Void_Ptr, Parent.Void_Ptr) /= 0;
    end Inside;


    function Nearest_Window
           (This : in Widget)
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Window_Ptr : Storage.Integer_Address := fl_widget_window (This.Void_Ptr);
        Actual_Window : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if Window_Ptr /= Null_Pointer then
            Window_Ptr := fl_widget_get_user_data (Window_Ptr);
            pragma Assert (Window_Ptr /= Null_Pointer);
            Actual_Window := Window_Convert.To_Pointer (Storage.To_Address (Window_Ptr));
        end if;
        return Actual_Window;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl_Widget::window has no user_data reference back to Ada";
    end Nearest_Window;


    function Top_Window
           (This : in Widget)
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Window_Ptr : Storage.Integer_Address := fl_widget_top_window (This.Void_Ptr);
        Actual_Window : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if Window_Ptr /= Null_Pointer then
            Window_Ptr := fl_widget_get_user_data (Window_Ptr);
            pragma Assert (Window_Ptr /= Null_Pointer);
            Actual_Window := Window_Convert.To_Pointer (Storage.To_Address (Window_Ptr));
        end if;
        return Actual_Window;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl_Widget::top_window has no user_data reference back to Ada";
    end Top_Window;


    function Top_Window_Offset
           (This               : in     Widget;
            Offset_X, Offset_Y :    out Integer)
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Window_Ptr : Storage.Integer_Address := fl_widget_top_window_offset
           (This.Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
        Actual_Window : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if Window_Ptr /= Null_Pointer then
            Window_Ptr := fl_widget_get_user_data (Window_Ptr);
            pragma Assert (Window_Ptr /= Null_Pointer);
            Actual_Window := Window_Convert.To_Pointer (Storage.To_Address (Window_Ptr));
        end if;
        return Actual_Window;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl_Widget::top_window_offset has no user_data reference back to Ada";
    end Top_Window_Offset;




    --  Alignment, Box, Tooltip  --

    function Get_Alignment
           (This : in Widget)
        return Alignment is
    begin
        return Alignment (fl_widget_get_align (This.Void_Ptr));
    end Get_Alignment;


    procedure Set_Alignment
           (This      : in out Widget;
            New_Align : in     Alignment) is
    begin
        fl_widget_set_align (This.Void_Ptr, Interfaces.C.unsigned (New_Align));
    end Set_Alignment;


    function Get_Box
           (This : in Widget)
        return Box_Kind
    is
        Result : constant Interfaces.C.int := fl_widget_get_box (This.Void_Ptr);
    begin
        return Box_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Widget::box returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Box;


    procedure Set_Box
           (This : in out Widget;
            Box  : in     Box_Kind) is
    begin
        fl_widget_set_box (This.Void_Ptr, Box_Kind'Pos (Box));
    end Set_Box;


    function Get_Tooltip
           (This : in Widget)
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_widget_tooltip (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            --  no need for dealloc
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Tooltip;


    procedure Set_Tooltip
           (This : in out Widget;
            Text : in     String) is
    begin
        fl_widget_copy_tooltip (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Set_Tooltip;




    --  Labels  --

    function Get_Label
           (This : in Widget)
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_widget_get_label (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Label;


    procedure Set_Label
           (This : in out Widget;
            Text : in     String) is
    begin
        fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Set_Label;


    procedure Set_Label
           (This : in out Widget;
            Kind : in     Label_Kind;
            Text : in     String) is
    begin
        --  Dispatching, so a window gets Fl_Window::copy_label, which isn't
        --  virtual and also sets the title (Fl_Window.cxx:159-162).  pofltk 6.
        Widget'Class (This).Set_Label_Kind (Kind);
        Widget'Class (This).Set_Label (Text);
    end Set_Label;


    function Get_Label_Color
           (This : in Widget)
        return Color is
    begin
        return Color (fl_widget_get_labelcolor (This.Void_Ptr));
    end Get_Label_Color;


    procedure Set_Label_Color
           (This  : in out Widget;
            Value : in     Color) is
    begin
        fl_widget_set_labelcolor (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Label_Color;


    function Get_Label_Font
           (This : in Widget)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_widget_get_labelfont (This.Void_Ptr));
    end Get_Label_Font;


    procedure Set_Label_Font
           (This : in out Widget;
            Font : in     Font_Kind) is
    begin
        fl_widget_set_labelfont (This.Void_Ptr, Font_Kind'Pos (Font));
    end Set_Label_Font;


    function Get_Label_Size
           (This : in Widget)
        return Font_Size is
    begin
        return Font_Size (fl_widget_get_labelsize (This.Void_Ptr));
    end Get_Label_Size;


    procedure Set_Label_Size
           (This : in out Widget;
            Size : in     Font_Size) is
    begin
        fl_widget_set_labelsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Label_Size;


    function Get_Label_Kind
           (This : in Widget)
        return Label_Kind
    is
        Result : constant Interfaces.C.int := fl_widget_get_labeltype (This.Void_Ptr);
    begin
        return Label_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Widget::labeltype returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Label_Kind;


    procedure Set_Label_Kind
           (This  : in out Widget;
            Label : in     Label_Kind) is
    begin
        fl_widget_set_labeltype (This.Void_Ptr, Label_Kind'Pos (Label));
    end Set_Label_Kind;


    --  FLTK reads W as the width to wrap the text at, 0 for none
    --  (fl_draw.cxx:520-521), so it is given 0, not what W held.
    procedure Measure_Label
           (This : in     Widget;
            W, H :    out Integer)
    is
        Result_W, Result_H : Interfaces.C.int := 0;
    begin
        fl_widget_measure_label (This.Void_Ptr, Result_W, Result_H);
        W := Integer (Result_W);
        H := Integer (Result_H);
    end Measure_Label;




    --  Callbacks  --

    function Get_Callback
           (This : in Widget)
        return Widget_Callback is
    begin
        return This.Callback;
    end Get_Callback;


    procedure Set_Callback
           (This : in out Widget;
            Func : in     Widget_Callback) is
    begin
        if Func /= null then
            This.Callback := Func;
            fl_widget_set_callback (This.Void_Ptr, Storage.To_Integer (Callback_Hook'Address));
        end if;
    end Set_Callback;


    procedure Do_Callback
           (This : in out Widget) is
    begin
        if This.Callback /= null then
            This.Callback.all (This);
        end if;
    end Do_Callback;


    procedure Do_Callback
           (This  : in     Widget;
            Using : in out Widget) is
    begin
        if This.Callback /= null then
            This.Callback.all (Using);
        end if;
    end Do_Callback;


    procedure Default_Callback
           (This : in out Widget'Class) is
    begin
        fl_widget_default_callback
           (This.Void_Ptr,
            fl_widget_get_user_data (This.Void_Ptr));
    end Default_Callback;


    function Get_When
           (This : in Widget)
        return Callback_Flag is
    begin
        return UChar_To_Flag (fl_widget_get_when (This.Void_Ptr));
    end Get_When;


    procedure Set_When
           (This : in out Widget;
            To   : in     Callback_Flag) is
    begin
        fl_widget_set_when (This.Void_Ptr, Flag_To_UChar (To));
    end Set_When;




    --  Dimensions  --

    function Get_X
           (This : in Widget)
        return Integer is
    begin
        return Integer (fl_widget_get_x (This.Void_Ptr));
    end Get_X;


    function Get_Y
           (This : in Widget)
        return Integer is
    begin
        return Integer (fl_widget_get_y (This.Void_Ptr));
    end Get_Y;


    function Get_W
           (This : in Widget)
        return Integer is
    begin
        return Integer (fl_widget_get_w (This.Void_Ptr));
    end Get_W;


    function Get_H
           (This : in Widget)
        return Integer is
    begin
        return Integer (fl_widget_get_h (This.Void_Ptr));
    end Get_H;


    procedure Resize
           (This : in out Widget;
            W, H : in     Integer) is
    begin
        fl_widget_size
           (This.Void_Ptr,
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


    procedure Resize
           (This       : in out Widget;
            X, Y, W, H : in     Integer) is
    begin
        fl_widget_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


    procedure Reposition
           (This : in out Widget;
            X, Y : in     Integer) is
    begin
        fl_widget_position
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Reposition;




    --  Images  --

    function Get_Image
           (This : in Widget)
        return access FLTK.Images.Image'Class is
    begin
        return This.Current_Image;
    end Get_Image;


    procedure Set_Image
           (This : in out Widget;
            Pic  : in out FLTK.Images.Image'Class) is
    begin
        This.Current_Image := Pic'Unchecked_Access;
        fl_widget_set_image
               (This.Void_Ptr,
                Wrapper (Pic).Void_Ptr);
    end Set_Image;


    procedure Clear_Image
           (This : in out Widget) is
    begin
        This.Current_Image := null;
        fl_widget_set_image (This.Void_Ptr, Null_Pointer);
    end Clear_Image;


    function Get_Inactive_Image
           (This : in Widget)
        return access FLTK.Images.Image'Class is
    begin
        return This.Inactive_Image;
    end Get_Inactive_Image;


    procedure Set_Inactive_Image
           (This : in out Widget;
            Pic  : in out FLTK.Images.Image'Class) is
    begin
        This.Inactive_Image := Pic'Unchecked_Access;
        fl_widget_set_deimage
           (This.Void_Ptr,
            Wrapper (Pic).Void_Ptr);
    end Set_Inactive_Image;




    --  Damage, Drawing, Events  --

    function Is_Damaged
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_damage (This.Void_Ptr) /= 0;
    end Is_Damaged;


    function Get_Damage
           (This : in Widget)
        return Damage_Mask is
    begin
        return UChar_To_Mask (fl_widget_damage (This.Void_Ptr));
    end Get_Damage;


    procedure Set_Damage
           (This : in out Widget;
            Mask : in     Damage_Mask) is
    begin
        fl_widget_set_damage (This.Void_Ptr, Mask_To_UChar (Mask));
    end Set_Damage;


    procedure Set_Damage
           (This       : in out Widget;
            Mask       : in     Damage_Mask;
            X, Y, W, H : in     Integer) is
    begin
        fl_widget_set_damage2
           (This.Void_Ptr,
            Mask_To_UChar (Mask),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Set_Damage;


    procedure Clear_Damage
           (This : in out Widget;
            Mask : in     Damage_Mask := Damage_None) is
    begin
        fl_widget_clear_damage (This.Void_Ptr, Mask_To_UChar (Mask));
    end Clear_Damage;


    procedure Draw
           (This : in out Widget)
    is
        procedure my_draw
               (V : in Storage.Integer_Address);
        for my_draw'Address use This.Draw_Ptr;
        pragma Import (Ada, my_draw);
    begin
        my_draw (This.Void_Ptr);
    end Draw;


    procedure Draw_Label
           (This : in out Widget) is
    begin
        fl_widget_draw_label (This.Void_Ptr);
    end Draw_Label;


    procedure Draw_Label
           (This       : in out Widget;
            X, Y, W, H : in     Integer) is
    begin
        fl_widget_draw_label2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw_Label;


    procedure Draw_Label
           (This       : in out Widget;
            X, Y, W, H : in     Integer;
            Align      : in     Alignment) is
    begin
        fl_widget_draw_label3
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Align));
    end Draw_Label;


    procedure Draw_Backdrop
           (This : in out Widget) is
    begin
        fl_widget_draw_backdrop (This.Void_Ptr);
    end Draw_Backdrop;


    procedure Draw_Box
           (This : in out Widget) is
    begin
        fl_widget_draw_box (This.Void_Ptr);
    end Draw_Box;


    procedure Draw_Box
           (This : in out Widget;
            Kind : in     Box_Kind;
            Hue  : in     Color) is
    begin
        fl_widget_draw_box2
           (This.Void_Ptr,
            Box_Kind'Pos (Kind),
            Interfaces.C.unsigned (Hue));
    end Draw_Box;


    procedure Draw_Box
           (This       : in out Widget;
            Kind       : in     Box_Kind;
            X, Y, W, H : in     Integer;
            Hue        : in     Color) is
    begin
        fl_widget_draw_box3
           (This.Void_Ptr,
            Box_Kind'Pos (Kind),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Hue));
    end Draw_Box;


    procedure Draw_Focus
           (This : in out Widget) is
    begin
        fl_widget_draw_focus (This.Void_Ptr);
    end Draw_Focus;


    procedure Draw_Focus
           (This       : in out Widget;
            Kind       : in     Box_Kind;
            X, Y, W, H : in     Integer) is
    begin
        fl_widget_draw_focus2
           (This.Void_Ptr,
            Box_Kind'Pos (Kind),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw_Focus;


    procedure Redraw
           (This : in out Widget) is
    begin
        fl_widget_redraw (This.Void_Ptr);
    end Redraw;


    procedure Redraw_Label
           (This : in out Widget) is
    begin
        fl_widget_redraw_label (This.Void_Ptr);
    end Redraw_Label;


    function Handle
           (This  : in out Widget;
            Event : in     Event_Kind)
        return Event_Outcome
    is
        function my_handle
               (V : in Storage.Integer_Address;
                E : in Interfaces.C.int)
            return Interfaces.C.int;
        for my_handle'Address use This.Handle_Ptr;
        pragma Import (Ada, my_handle);

        Result : constant Interfaces.C.int := my_handle (This.Void_Ptr, Event_Kind'Pos (Event));
    begin
        return (if Result = 0 then Not_Handled else Handled);
    end Handle;




    --  Miscellaneous  --

    function Uses_Accents_Menu
           (This : in Widget)
        return Boolean is
    begin
        return fl_widget_use_accents_menu (This.Void_Ptr) /= 0;
    end Uses_Accents_Menu;


    function Address_Of
           (This : in Widget'Class)
        return System.Address is
    begin
        return Storage.To_Address (This.Void_Ptr);
    end Address_Of;


    function Widget_At
           (Addr : in System.Address)
        return access Widget'Class
    is
        User_Data : constant Storage.Integer_Address :=
            fl_widget_get_user_data (Storage.To_Integer (Addr));
    begin
        if User_Data = Null_Pointer then
            return null;
        else
            return Widget_Convert.To_Pointer (Storage.To_Address (User_Data));
        end if;
    end Widget_At;


end FLTK.Widgets;


