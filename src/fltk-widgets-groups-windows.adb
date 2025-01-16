

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Command_Line,
    Interfaces.C.Strings,
    FLTK.Images.RGB,
    FLTK.Show_Argv;

use type

    Interfaces.C.int,
    Interfaces.C.unsigned,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Groups.Windows is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_window, "new_fl_window");
    pragma Inline (new_fl_window);

    function new_fl_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_window2, "new_fl_window2");
    pragma Inline (new_fl_window2);

    procedure free_fl_window
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_window, "free_fl_window");
    pragma Inline (free_fl_window);




    procedure fl_window_show
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_show, "fl_window_show");
    pragma Inline (fl_window_show);

    procedure fl_window_show2
           (W : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_window_show2, "fl_window_show2");
    pragma Inline (fl_window_show2);

    procedure fl_window_hide
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_hide, "fl_window_hide");
    pragma Inline (fl_window_hide);

    function fl_window_shown
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_window_shown, "fl_window_shown");
    pragma Inline (fl_window_shown);

    procedure fl_window_wait_for_expose
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_wait_for_expose, "fl_window_wait_for_expose");
    pragma Inline (fl_window_wait_for_expose);

    procedure fl_window_iconize
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_iconize, "fl_window_iconize");
    pragma Inline (fl_window_iconize);

    procedure fl_window_make_current
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_make_current, "fl_window_make_current");
    pragma Inline (fl_window_make_current);

    procedure fl_window_free_position
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_free_position, "fl_window_free_position");
    pragma Inline (fl_window_free_position);




    function fl_window_fullscreen_active
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_window_fullscreen_active, "fl_window_fullscreen_active");
    pragma Inline (fl_window_fullscreen_active);

    procedure fl_window_fullscreen
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_fullscreen, "fl_window_fullscreen");
    pragma Inline (fl_window_fullscreen);

    procedure fl_window_fullscreen_off
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_fullscreen_off, "fl_window_fullscreen_off");
    pragma Inline (fl_window_fullscreen_off);

    procedure fl_window_fullscreen_off2
           (N          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_window_fullscreen_off2, "fl_window_fullscreen_off2");
    pragma Inline (fl_window_fullscreen_off2);

    procedure fl_window_fullscreen_screens
           (W : in Storage.Integer_Address;
            T, B, L, R : in Interfaces.C.int);
    pragma Import (C, fl_window_fullscreen_screens, "fl_window_fullscreen_screens");
    pragma Inline (fl_window_fullscreen_screens);




    procedure fl_window_set_icon
           (W, P : in Storage.Integer_Address);
    pragma Import (C, fl_window_set_icon, "fl_window_set_icon");
    pragma Inline (fl_window_set_icon);

    procedure fl_window_default_icon
           (P : in Storage.Integer_Address);
    pragma Import (C, fl_window_default_icon, "fl_window_default_icon");
    pragma Inline (fl_window_default_icon);

    function fl_window_get_iconlabel
           (W : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_window_get_iconlabel, "fl_window_get_iconlabel");
    pragma Inline (fl_window_get_iconlabel);

    procedure fl_window_set_iconlabel
           (W : in Storage.Integer_Address;
            S : in Interfaces.C.char_array);
    pragma Import (C, fl_window_set_iconlabel, "fl_window_set_iconlabel");
    pragma Inline (fl_window_set_iconlabel);

    procedure fl_window_set_cursor
           (W : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_window_set_cursor, "fl_window_set_cursor");
    pragma Inline (fl_window_set_cursor);

    procedure fl_window_set_cursor2
           (W, P : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_window_set_cursor2, "fl_window_set_cursor2");
    pragma Inline (fl_window_set_cursor2);

    procedure fl_window_set_default_cursor
           (W : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_window_set_default_cursor, "fl_window_set_default_cursor");
    pragma Inline (fl_window_set_default_cursor);




    function fl_window_get_border
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_window_get_border, "fl_window_get_border");
    pragma Inline (fl_window_get_border);

    procedure fl_window_set_border
           (W : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_window_set_border, "fl_window_set_border");
    pragma Inline (fl_window_set_border);

    function fl_window_get_override
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_window_get_override, "fl_window_get_override");
    pragma Inline (fl_window_get_override);

    procedure fl_window_set_override
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_set_override, "fl_window_set_override");
    pragma Inline (fl_window_set_override);

    function fl_window_modal
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_window_modal, "fl_window_modal");
    pragma Inline (fl_window_modal);

    function fl_window_non_modal
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_window_non_modal, "fl_window_non_modal");
    pragma Inline (fl_window_non_modal);

    procedure fl_window_clear_modal_states
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_clear_modal_states, "fl_window_clear_modal_states");
    pragma Inline (fl_window_clear_modal_states);

    procedure fl_window_set_modal
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_set_modal, "fl_window_set_modal");
    pragma Inline (fl_window_set_modal);

    procedure fl_window_set_non_modal
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_set_non_modal, "fl_window_set_non_modal");
    pragma Inline (fl_window_set_non_modal);




    function fl_window_get_label
           (W : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_window_get_label, "fl_window_get_label");
    pragma Inline (fl_window_get_label);

    procedure fl_window_set_label
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_window_set_label, "fl_window_set_label");
    pragma Inline (fl_window_set_label);

    procedure fl_window_hotspot
           (W       : in Storage.Integer_Address;
            X, Y, S : in Interfaces.C.int);
    pragma Import (C, fl_window_hotspot, "fl_window_hotspot");
    pragma Inline (fl_window_hotspot);

    procedure fl_window_hotspot2
           (W, I : in Storage.Integer_Address;
            S    : in Interfaces.C.int);
    pragma Import (C, fl_window_hotspot2, "fl_window_hotspot2");
    pragma Inline (fl_window_hotspot2);

    procedure fl_window_size_range
           (W                         : in Storage.Integer_Address;
            LW, LH, HW, HH, DW, DH, A : in Interfaces.C.int);
    pragma Import (C, fl_window_size_range, "fl_window_size_range");
    pragma Inline (fl_window_size_range);

    procedure fl_window_shape
           (W, P : in Storage.Integer_Address);
    pragma Import (C, fl_window_shape, "fl_window_shape");
    pragma Inline (fl_window_shape);




    function fl_window_get_x_root
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_window_get_x_root, "fl_window_get_x_root");
    pragma Inline (fl_window_get_x_root);

    function fl_window_get_y_root
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_window_get_y_root, "fl_window_get_y_root");
    pragma Inline (fl_window_get_y_root);

    function fl_window_get_decorated_w
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_window_get_decorated_w, "fl_window_get_decorated_w");
    pragma Inline (fl_window_get_decorated_w);

    function fl_window_get_decorated_h
           (W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_window_get_decorated_h, "fl_window_get_decorated_h");
    pragma Inline (fl_window_get_decorated_h);




    procedure fl_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_window_draw, "fl_window_draw");
    pragma Inline (fl_window_draw);

    function fl_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_window_handle, "fl_window_handle");
    pragma Inline (fl_window_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Window) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Window) is
    begin
        This.Draw_Ptr   := fl_window_draw'Address;
        This.Handle_Ptr := fl_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Window is
        begin
            return This : Window do
                This.Void_Ptr := new_fl_window
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Window is
        begin
            return This : Window := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Window is
        begin
            return This : Window do
                This.Void_Ptr := new_fl_window2
                       (Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Window is
        begin
            return This : Window := Create (W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Show
           (This : in out Window) is
    begin
        fl_window_show (This.Void_Ptr);
    end Show;


    procedure Show_With_Args
           (This : in out Window) is
    begin
        FLTK.Show_Argv.Dispatch (fl_window_show2'Access, This.Void_Ptr);
    end Show_With_Args;


    procedure Hide
           (This : in out Window) is
    begin
        fl_window_hide (This.Void_Ptr);
    end Hide;


    function Is_Shown
           (This : in Window)
        return Boolean is
    begin
        return fl_window_shown (This.Void_Ptr) /= 0;
    end Is_Shown;


    procedure Wait_For_Expose
           (This : in out Window) is
    begin
        fl_window_wait_for_expose (This.Void_Ptr);
    end Wait_For_Expose;


    procedure Iconify
           (This : in out Window) is
    begin
        fl_window_iconize (This.Void_Ptr);
    end Iconify;


    procedure Make_Current
           (This : in out Window) is
    begin
        fl_window_make_current (This.Void_Ptr);
        Last_Current := This'Unchecked_Access;
    end Make_Current;


    function Last_Made_Current
        return access Window'Class is
    begin
        return Last_Current;
    end Last_Made_Current;


    procedure Free_Position
           (This : in out Window) is
    begin
        fl_window_free_position (This.Void_Ptr);
    end Free_Position;




    function Is_Fullscreen
           (This : in Window)
        return Boolean is
    begin
        return fl_window_fullscreen_active (This.Void_Ptr) /= 0;
    end Is_Fullscreen;


    procedure Fullscreen_On
           (This : in out Window) is
    begin
        fl_window_fullscreen (This.Void_Ptr);
    end Fullscreen_On;


    procedure Fullscreen_Off
           (This : in out Window) is
    begin
        fl_window_fullscreen_off (This.Void_Ptr);
    end Fullscreen_Off;


    procedure Fullscreen_Off
           (This       : in out Window;
            X, Y, W, H : in     Integer) is
    begin
        fl_window_fullscreen_off2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Fullscreen_Off;


    procedure Fullscreen_Screens
           (This                     : in out Window;
            Top, Bottom, Left, Right : in     Natural) is
    begin
        fl_window_fullscreen_screens
           (This.Void_Ptr,
            Interfaces.C.int (Top),
            Interfaces.C.int (Bottom),
            Interfaces.C.int (Left),
            Interfaces.C.int (Right));
    end Fullscreen_Screens;




    procedure Set_Icon
           (This : in out Window;
            Pic  : in out FLTK.Images.RGB.RGB_Image'Class) is
    begin
        fl_window_set_icon
               (This.Void_Ptr,
                Wrapper (Pic).Void_Ptr);
    end Set_Icon;


    procedure Set_Default_Icon
           (Pic : in out FLTK.Images.RGB.RGB_Image'Class) is
    begin
        fl_window_default_icon (Wrapper (Pic).Void_Ptr);
    end Set_Default_Icon;


    function Get_Icon_Label
           (This : in Window)
        return String
    is
        Ptr : Interfaces.C.Strings.chars_ptr := fl_window_get_iconlabel (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            --  pointer to internal buffer only, so no Free required
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Icon_Label;


    procedure Set_Icon_Label
           (This : in out Window;
            To   : in     String) is
    begin
        fl_window_set_iconlabel (This.Void_Ptr, Interfaces.C.To_C (To));
    end Set_Icon_Label;


    procedure Set_Cursor
           (This : in out Window;
            To   : in     Mouse_Cursor_Kind) is
    begin
        fl_window_set_cursor (This.Void_Ptr, Cursor_Values (To));
    end Set_Cursor;


    procedure Set_Cursor
           (This         : in out Window;
            Pic          : in out FLTK.Images.RGB.RGB_Image'Class;
            Hot_X, Hot_Y : in     Integer) is
    begin
        fl_window_set_cursor2
           (This.Void_Ptr,
            Wrapper (Pic).Void_Ptr,
            Interfaces.C.int (Hot_X),
            Interfaces.C.int (Hot_Y));
    end Set_Cursor;


    procedure Set_Default_Cursor
           (This : in out Window;
            To   : in     Mouse_Cursor_Kind) is
    begin
        fl_window_set_default_cursor (This.Void_Ptr, Cursor_Values (To));
    end Set_Default_Cursor;




    function Get_Border_State
           (This : in Window)
        return Border_State is
    begin
        return Border_State'Val (fl_window_get_border (This.Void_Ptr));
    end Get_Border_State;


    procedure Set_Border_State
           (This : in out Window;
            To   : in     Border_State) is
    begin
        fl_window_set_border (This.Void_Ptr, Border_State'Pos (To));
    end Set_Border_State;


    function Is_Override
           (This : in Window)
        return Boolean is
    begin
        return fl_window_get_override (This.Void_Ptr) /= 0;
    end Is_Override;


    procedure Set_Override
           (This : in out Window) is
    begin
        fl_window_set_override (This.Void_Ptr);
    end Set_Override;


    function Get_Modal_State
           (This : in Window)
        return Modal_State is
    begin
        if fl_window_modal (This.Void_Ptr) /= 0 then
            return Modal;
        elsif fl_window_non_modal (This.Void_Ptr) /= 0 then
            return Non_Modal;
        else
            return Normal;
        end if;
    end Get_Modal_State;


    procedure Set_Modal_State
           (This : in out Window;
            To   : in     Modal_State) is
    begin
        case To is
            when Normal =>
                fl_window_clear_modal_states (This.Void_Ptr);
            when Non_Modal =>
                fl_window_set_non_modal (This.Void_Ptr);
            when Modal =>
                fl_window_set_modal (This.Void_Ptr);
        end case;
    end Set_Modal_State;




    function Get_Label
           (This : in Window)
        return String
    is
        Ptr : Interfaces.C.Strings.chars_ptr := fl_window_get_label (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            --  pointer to internal buffer only, so no Free required
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Label;


    procedure Set_Label
           (This : in out Window;
            Text : in     String) is
    begin
        fl_window_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Set_Label;


    procedure Hotspot
           (This      : in out Window;
            X, Y      : in     Integer;
            Offscreen : in     Boolean := False) is
    begin
        fl_window_hotspot
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Boolean'Pos (Offscreen));
    end Hotspot;


    procedure Hotspot
           (This      : in out Window;
            Item      : in     Widget'Class;
            Offscreen : in     Boolean := False) is
    begin
        fl_window_hotspot2
           (This.Void_Ptr,
            Item.Void_Ptr,
            Boolean'Pos (Offscreen));
    end Hotspot;


    procedure Set_Size_Range
           (This                           : in out Window;
            Min_W, Min_H                   : in     Integer;
            Max_W, Max_H, Incre_W, Incre_H : in     Integer := 0;
            Keep_Aspect                    : in     Boolean := False) is
    begin
        fl_window_size_range
               (This.Void_Ptr,
                Interfaces.C.int (Min_W),
                Interfaces.C.int (Min_H),
                Interfaces.C.int (Max_W),
                Interfaces.C.int (Max_H),
                Interfaces.C.int (Incre_W),
                Interfaces.C.int (Incre_H),
                Boolean'Pos (Keep_Aspect));
    end Set_Size_Range;


    procedure Shape
           (This : in out Window;
            Pic  : in out FLTK.Images.Image'Class) is
    begin
        fl_window_shape (This.Void_Ptr, Wrapper (Pic).Void_Ptr);
    end Shape;




    function Get_X_Root
           (This : in Window)
        return Integer is
    begin
        return Integer (fl_window_get_x_root (This.Void_Ptr));
    end Get_X_Root;


    function Get_Y_Root
           (This : in Window)
        return Integer is
    begin
        return Integer (fl_window_get_y_root (This.Void_Ptr));
    end Get_Y_Root;


    function Get_Decorated_W
           (This : in Window)
        return Integer is
    begin
        return Integer (fl_window_get_decorated_w (This.Void_Ptr));
    end Get_Decorated_W;


    function Get_Decorated_H
           (This : in Window)
        return Integer is
    begin
        return Integer (fl_window_get_decorated_h (This.Void_Ptr));
    end Get_Decorated_H;




    procedure Draw
           (This : in out Window) is
    begin
        Group (This).Draw;
    end Draw;


    function Handle
           (This  : in out Window;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Windows;


