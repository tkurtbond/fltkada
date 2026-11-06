

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Hook_Exceptions,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Screen is


    ------------------------
    --  Constants From C  --
    ------------------------

    fl_enum_mode_rgb : constant Interfaces.C.int;
    pragma Import (C, fl_enum_mode_rgb, "fl_enum_mode_rgb");

    fl_enum_mode_rgb8 : constant Interfaces.C.int;
    pragma Import (C, fl_enum_mode_rgb8, "fl_enum_mode_rgb8");

    fl_enum_mode_double : constant Interfaces.C.int;
    pragma Import (C, fl_enum_mode_double, "fl_enum_mode_double");

    fl_enum_mode_index : constant Interfaces.C.int;
    pragma Import (C, fl_enum_mode_index, "fl_enum_mode_index");




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Environment  --

    procedure fl_screen_display
           (V : in Interfaces.C.char_array);
    pragma Import (C, fl_screen_display, "fl_screen_display");
    pragma Inline (fl_screen_display);

    function fl_screen_visual
           (F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_screen_visual, "fl_screen_visual");
    pragma Inline (fl_screen_visual);




    --  Basic Dimensions  --

    function fl_screen_x
        return Interfaces.C.int;
    pragma Import (C, fl_screen_x, "fl_screen_x");
    pragma Inline (fl_screen_x);

    function fl_screen_y
        return Interfaces.C.int;
    pragma Import (C, fl_screen_y, "fl_screen_y");
    pragma Inline (fl_screen_y);

    function fl_screen_w
        return Interfaces.C.int;
    pragma Import (C, fl_screen_w, "fl_screen_w");
    pragma Inline (fl_screen_w);

    function fl_screen_h
        return Interfaces.C.int;
    pragma Import (C, fl_screen_h, "fl_screen_h");
    pragma Inline (fl_screen_h);




    --  Pixel Density  --

    function fl_screen_count
        return Interfaces.C.int;
    pragma Import (C, fl_screen_count, "fl_screen_count");
    pragma Inline (fl_screen_count);

    procedure fl_screen_dpi
           (H, V :    out Interfaces.C.C_float;
            N    : in     Interfaces.C.int);
    pragma Import (C, fl_screen_dpi, "fl_screen_dpi");
    pragma Inline (fl_screen_dpi);




    --  Scaling  --

    function fl_screen_scaling_supported
        return Interfaces.C.int;
    pragma Import (C, fl_screen_scaling_supported, "fl_screen_scaling_supported");
    pragma Inline (fl_screen_scaling_supported);

    function fl_screen_get_scale
           (N : in Interfaces.C.int)
        return Interfaces.C.C_float;
    pragma Import (C, fl_screen_get_scale, "fl_screen_get_scale");
    pragma Inline (fl_screen_get_scale);

    procedure fl_screen_set_scale
           (N : in Interfaces.C.int;
            F : in Interfaces.C.C_float);
    pragma Import (C, fl_screen_set_scale, "fl_screen_set_scale");
    pragma Inline (fl_screen_set_scale);

    procedure fl_screen_keyboard_scaling
           (V : in Interfaces.C.int);
    pragma Import (C, fl_screen_keyboard_scaling, "fl_screen_keyboard_scaling");
    pragma Inline (fl_screen_keyboard_scaling);




    --  Position Lookup  --

    function fl_screen_num
           (X, Y : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_screen_num, "fl_screen_num");
    pragma Inline (fl_screen_num);

    function fl_screen_num2
           (X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_screen_num2, "fl_screen_num2");
    pragma Inline (fl_screen_num2);




    --  Bounding Boxes  --

    procedure fl_screen_work_area
           (X, Y, W, H :    out Interfaces.C.int;
            PX, PY     : in     Interfaces.C.int);
    pragma Import (C, fl_screen_work_area, "fl_screen_work_area");
    pragma Inline (fl_screen_work_area);

    procedure fl_screen_work_area2
           (X, Y, W, H :    out Interfaces.C.int;
            N          : in     Interfaces.C.int);
    pragma Import (C, fl_screen_work_area2, "fl_screen_work_area2");
    pragma Inline (fl_screen_work_area2);

    procedure fl_screen_work_area3
           (X, Y, W, H : out Interfaces.C.int);
    pragma Import (C, fl_screen_work_area3, "fl_screen_work_area3");
    pragma Inline (fl_screen_work_area3);

    procedure fl_screen_xywh
           (X, Y, W, H :    out Interfaces.C.int;
            PX, PY     : in     Interfaces.C.int);
    pragma Import (C, fl_screen_xywh, "fl_screen_xywh");
    pragma Inline (fl_screen_xywh);

    procedure fl_screen_xywh2
           (X, Y, W, H :    out Interfaces.C.int;
            N          : in     Interfaces.C.int);
    pragma Import (C, fl_screen_xywh2, "fl_screen_xywh2");
    pragma Inline (fl_screen_xywh2);

    procedure fl_screen_xywh3
           (X, Y, W, H : out Interfaces.C.int);
    pragma Import (C, fl_screen_xywh3, "fl_screen_xywh3");
    pragma Inline (fl_screen_xywh3);

    procedure fl_screen_xywh4
           (X, Y, W, H     :    out Interfaces.C.int;
            PX, PY, PW, PH : in     Interfaces.C.int);
    pragma Import (C, fl_screen_xywh4, "fl_screen_xywh4");
    pragma Inline (fl_screen_xywh4);




    --  Drawing  --

    function fl_screen_get_damage
        return Interfaces.C.int;
    pragma Import (C, fl_screen_get_damage, "fl_screen_get_damage");
    pragma Inline (fl_screen_get_damage);

    procedure fl_screen_set_damage
           (V : in Interfaces.C.int);
    pragma Import (C, fl_screen_set_damage, "fl_screen_set_damage");
    pragma Inline (fl_screen_set_damage);

    procedure fl_screen_flush;
    pragma Import (C, fl_screen_flush, "fl_screen_flush");
    pragma Inline (fl_screen_flush);




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Environment  --

    procedure Set_Display_String
           (Value : in String) is
    begin
        fl_screen_display (Interfaces.C.To_C (Value));
    end Set_Display_String;


    procedure Set_Visual_Mode
           (Value : in Visual_Mode)
    is
        Ignore : Boolean := Set_Visual_Mode (Value);
    begin
        null;
    end Set_Visual_Mode;


    function Set_Visual_Mode
           (Value : in Visual_Mode)
        return Boolean is
    begin
        return fl_screen_visual
           ((case Value is
            when RGB              => fl_enum_mode_rgb,
            when RGB_24bit        => fl_enum_mode_rgb8,
            when Double_Buffer    => fl_enum_mode_double + fl_enum_mode_index,
            when Double_RGB       => fl_enum_mode_double + fl_enum_mode_rgb,
            when Double_RGB_24bit => fl_enum_mode_double + fl_enum_mode_rgb8)) /= 0;
    end Set_Visual_Mode;




    --  Basic Dimensions  --

    function Get_X return Integer is
    begin
        return Integer (fl_screen_x);
    end Get_X;


    function Get_Y return Integer is
    begin
        return Integer (fl_screen_y);
    end Get_Y;


    function Get_W return Integer is
    begin
        return Integer (fl_screen_w);
    end Get_W;


    function Get_H return Integer is
    begin
        return Integer (fl_screen_h);
    end Get_H;




    --  Pixel Density  --

    function Count return Integer is
    begin
        return Integer (fl_screen_count);
    end Count;


    procedure Check_Screen
           (Screen_Number : in Integer) is
    begin
        if Screen_Number not in 1 .. Count then
            raise Constraint_Error with
                "screen" & Integer'Image (Screen_Number) & " of" & Integer'Image (Count);
        end if;
    end Check_Screen;


    procedure DPI
           (Horizontal, Vertical :    out Float;
            Screen_Number        : in     Integer := 1) is
    begin
        Check_Screen (Screen_Number);
        fl_screen_dpi
           (Interfaces.C.C_float (Horizontal),
            Interfaces.C.C_float (Vertical),
            Interfaces.C.int (Screen_Number) - 1);
    end DPI;




    --  Scaling  --

    function Scaling_Support
        return Scaling_Kind
    is
        Result : constant Interfaces.C.int := fl_screen_scaling_supported;
    begin
        return Scaling_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::screen_scaling_supported returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Scaling_Support;


    function Get_Scale
           (Screen_Number : in Integer := 1)
        return Float is
    begin
        Check_Screen (Screen_Number);
        return Float (fl_screen_get_scale (Interfaces.C.int (Screen_Number) - 1));
    end Get_Scale;


    procedure Set_Scale
           (Factor        : in Float;
            Screen_Number : in Integer := 1) is
    begin
        Check_Screen (Screen_Number);
        fl_screen_set_scale (Interfaces.C.int (Screen_Number) - 1, Interfaces.C.C_float (Factor));
    end Set_Scale;


    procedure Set_Keyboard_Scaling
           (To : in Boolean) is
    begin
        fl_screen_keyboard_scaling (Boolean'Pos (To));
    end Set_Keyboard_Scaling;




    --  Position Lookup  --

    function Containing
           (X, Y : in Integer)
        return Integer is
    begin
        return Integer (fl_screen_num
           (Interfaces.C.int (X),
            Interfaces.C.int (Y))) + 1;
    end Containing;


    function Containing
           (X, Y, W, H : in Integer)
        return Integer is
    begin
        return Integer (fl_screen_num2
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H))) + 1;
    end Containing;




    --  Bounding Boxes  --

    procedure Work_Area
           (X, Y, W, H   :    out Integer;
            Pos_X, Pos_Y : in     Integer) is
    begin
        fl_screen_work_area
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Pos_X),
            Interfaces.C.int (Pos_Y));
    end Work_Area;


    procedure Work_Area
           (X, Y, W, H :    out Integer;
            Screen_Num : in     Integer) is
    begin
        Check_Screen (Screen_Num);
        fl_screen_work_area2
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Screen_Num) - 1);
    end Work_Area;


    procedure Work_Area
           (X, Y, W, H : out Integer) is
    begin
        fl_screen_work_area3
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Work_Area;


    procedure Bounding_Rect
           (X, Y, W, H   :    out Integer;
            Pos_X, Pos_Y : in     Integer) is
    begin
        fl_screen_xywh
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Pos_X),
            Interfaces.C.int (Pos_Y));
    end Bounding_Rect;


    procedure Bounding_Rect
           (X, Y, W, H :    out Integer;
            Screen_Num : in     Integer) is
    begin
        Check_Screen (Screen_Num);
        fl_screen_xywh2
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Screen_Num) - 1);
    end Bounding_Rect;


    procedure Bounding_Rect
           (X, Y, W, H : out Integer) is
    begin
        fl_screen_xywh3
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Bounding_Rect;


    procedure Bounding_Rect
           (X, Y, W, H     :    out Integer;
            PX, PY, PW, PH : in     Integer) is
    begin
        fl_screen_xywh4
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (PX),
            Interfaces.C.int (PY),
            Interfaces.C.int (PW),
            Interfaces.C.int (PH));
    end Bounding_Rect;




    --  Drawing  --

    function Is_Damaged
        return Boolean is
    begin
        return fl_screen_get_damage /= 0;
    end Is_Damaged;


    procedure Set_Damaged
           (To : in Boolean) is
    begin
        fl_screen_set_damage (Boolean'Pos (To));
    end Set_Damaged;


    procedure Flush is
    begin
        fl_screen_flush;
        Hook_Exceptions.Reraise;
    end Flush;


end FLTK.Screen;


