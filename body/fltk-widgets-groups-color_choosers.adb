

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Color_Choosers is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_color_chooser
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_color_chooser, "new_fl_color_chooser");
    pragma Inline (new_fl_color_chooser);

    procedure free_fl_color_chooser
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_color_chooser, "free_fl_color_chooser");
    pragma Inline (free_fl_color_chooser);




    function fl_color_chooser_r
           (N : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_color_chooser_r, "fl_color_chooser_r");
    pragma Inline (fl_color_chooser_r);

    function fl_color_chooser_g
           (N : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_color_chooser_g, "fl_color_chooser_g");
    pragma Inline (fl_color_chooser_g);

    function fl_color_chooser_b
           (N : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_color_chooser_b, "fl_color_chooser_b");
    pragma Inline (fl_color_chooser_b);

    function fl_color_chooser_rgb
           (N       : in Storage.Integer_Address;
            R, G, B : in Interfaces.C.double)
        return Interfaces.C.int;
    pragma Import (C, fl_color_chooser_rgb, "fl_color_chooser_rgb");
    pragma Inline (fl_color_chooser_rgb);




    function fl_color_chooser_hue
           (N : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_color_chooser_hue, "fl_color_chooser_hue");
    pragma Inline (fl_color_chooser_hue);

    function fl_color_chooser_saturation
           (N : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_color_chooser_saturation, "fl_color_chooser_saturation");
    pragma Inline (fl_color_chooser_saturation);

    function fl_color_chooser_value
           (N : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_color_chooser_value, "fl_color_chooser_value");
    pragma Inline (fl_color_chooser_value);

    function fl_color_chooser_hsv
           (N       : in Storage.Integer_Address;
            H, S, V : in Interfaces.C.double)
        return Interfaces.C.int;
    pragma Import (C, fl_color_chooser_hsv, "fl_color_chooser_hsv");
    pragma Inline (fl_color_chooser_hsv);




    procedure fl_color_chooser_hsv2rgb
           (H, S, V : in     Interfaces.C.double;
            R, G, B :    out Interfaces.C.double);
    pragma Import (C, fl_color_chooser_hsv2rgb, "fl_color_chooser_hsv2rgb");
    pragma Inline (fl_color_chooser_hsv2rgb);

    procedure fl_color_chooser_rgb2hsv
           (R, G, B : in     Interfaces.C.double;
            H, S, V :    out Interfaces.C.double);
    pragma Import (C, fl_color_chooser_rgb2hsv, "fl_color_chooser_rgb2hsv");
    pragma Inline (fl_color_chooser_rgb2hsv);




    function fl_color_chooser_get_mode
           (N : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_color_chooser_get_mode, "fl_color_chooser_get_mode");
    pragma Inline (fl_color_chooser_get_mode);

    procedure fl_color_chooser_set_mode
           (N : in Storage.Integer_Address;
            M : in Interfaces.C.int);
    pragma Import (C, fl_color_chooser_set_mode, "fl_color_chooser_set_mode");
    pragma Inline (fl_color_chooser_set_mode);




    procedure fl_color_chooser_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_color_chooser_draw, "fl_color_chooser_draw");
    pragma Inline (fl_color_chooser_draw);

    function fl_color_chooser_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_color_chooser_handle, "fl_color_chooser_handle");
    pragma Inline (fl_color_chooser_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Color_Chooser) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Color_Chooser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_color_chooser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Color_Chooser;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Color_Chooser) is
    begin
        This.Draw_Ptr := fl_color_chooser_draw'Address;
        This.Handle_Ptr := fl_color_chooser_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Color_Chooser is
        begin
            return This : Color_Chooser do
                This.Void_Ptr := new_fl_color_chooser
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
            return Color_Chooser is
        begin
            return This : Color_Chooser := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_Red
           (This : in Color_Chooser)
        return Long_Float is
    begin
        return Long_Float (fl_color_chooser_r (This.Void_Ptr));
    end Get_Red;


    function Get_Green
           (This : in Color_Chooser)
        return Long_Float is
    begin
        return Long_Float (fl_color_chooser_g (This.Void_Ptr));
    end Get_Green;


    function Get_Blue
           (This : in Color_Chooser)
        return Long_Float is
    begin
        return Long_Float (fl_color_chooser_b (This.Void_Ptr));
    end Get_Blue;


    procedure Set_RGB
           (This    : in out Color_Chooser;
            R, G, B : in     Long_Float)
    is
        Result : Interfaces.C.int := fl_color_chooser_rgb
           (This.Void_Ptr,
            Interfaces.C.double (R),
            Interfaces.C.double (G),
            Interfaces.C.double (B));
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Color_Chooser::rgb returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Set_RGB;


    function Set_RGB
           (This    : in out Color_Chooser;
            R, G, B : in     Long_Float)
        return Boolean
    is
        Result : Interfaces.C.int := fl_color_chooser_rgb
           (This.Void_Ptr,
            Interfaces.C.double (R),
            Interfaces.C.double (G),
            Interfaces.C.double (B));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Color_Chooser::rgb returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Set_RGB;




    function Get_Hue
           (This : in Color_Chooser)
        return Long_Float is
    begin
        return Long_Float (fl_color_chooser_hue (This.Void_Ptr));
    end Get_Hue;


    function Get_Saturation
           (This : in Color_Chooser)
        return Long_Float is
    begin
        return Long_Float (fl_color_chooser_saturation (This.Void_Ptr));
    end Get_Saturation;


    function Get_Value
           (This : in Color_Chooser)
        return Long_Float is
    begin
        return Long_Float (fl_color_chooser_value (This.Void_Ptr));
    end Get_Value;


    procedure Set_HSV
           (This    : in out Color_Chooser;
            H, S, V : in     Long_Float)
    is
        Result : Interfaces.C.int := fl_color_chooser_hsv
           (This.Void_Ptr,
            Interfaces.C.double (H),
            Interfaces.C.double (S),
            Interfaces.C.double (V));
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Color_Chooser:hsv returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Set_HSV;


    function Set_HSV
           (This    : in out Color_Chooser;
            H, S, V : in     Long_Float)
        return Boolean
    is
        Result : Interfaces.C.int := fl_color_chooser_hsv
           (This.Void_Ptr,
            Interfaces.C.double (H),
            Interfaces.C.double (S),
            Interfaces.C.double (V));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Color_Chooser::hsv returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Set_HSV;




    procedure HSV_To_RGB
           (H, S, V : in     Long_Float;
            R, G, B :    out Long_Float) is
    begin
        fl_color_chooser_hsv2rgb
           (Interfaces.C.double (H),
            Interfaces.C.double (S),
            Interfaces.C.double (V),
            Interfaces.C.double (R),
            Interfaces.C.double (G),
            Interfaces.C.double (B));
    end HSV_To_RGB;


    procedure RGB_To_HSV
           (R, G, B : in     Long_Float;
            H, S, V :    out Long_Float) is
    begin
        fl_color_chooser_rgb2hsv
           (Interfaces.C.double (R),
            Interfaces.C.double (G),
            Interfaces.C.double (B),
            Interfaces.C.double (H),
            Interfaces.C.double (S),
            Interfaces.C.double (V));
    end RGB_To_HSV;




    function Get_Mode
           (This : in Color_Chooser)
        return Color_Mode is
    begin
        return Color_Mode'Val (fl_color_chooser_get_mode (This.Void_Ptr));
    end Get_Mode;


    procedure Set_Mode
           (This : in out Color_Chooser;
            To   : in     Color_Mode) is
    begin
        fl_color_chooser_set_mode (This.Void_Ptr, Color_Mode'Pos (To));
    end Set_Mode;


end FLTK.Widgets.Groups.Color_Choosers;


