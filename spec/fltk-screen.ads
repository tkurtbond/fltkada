

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Screen is


    type Visual_Mode is (RGB, RGB_24bit, Double_Buffer, Double_RGB, Double_RGB_24bit);




    --  Environment  --

    procedure Set_Display_String
           (Value : in String);

    procedure Set_Visual_Mode
           (Value : in Visual_Mode);

    function Set_Visual_Mode
           (Value : in Visual_Mode)
        return Boolean;




    --  Basic Dimensions  --

    function Get_X
        return Integer;

    function Get_Y
        return Integer;

    function Get_W
        return Integer;

    function Get_H
        return Integer;




    --  Pixel Density  --

    function Count
        return Integer;

    --  Screen numbers in the range 1 .. Count
    procedure DPI
           (Horizontal, Vertical :    out Float;
            Screen_Number        : in     Integer := 1);




    --  Position Lookup  --

    function Containing
           (X, Y : in Integer)
        return Integer;

    function Containing
           (X, Y, W, H : in Integer)
        return Integer;




    --  Bounding Boxes  --

    procedure Work_Area
           (X, Y, W, H   :    out Integer;
            Pos_X, Pos_Y : in     Integer);

    procedure Work_Area
           (X, Y, W, H :    out Integer;
            Screen_Num : in     Integer);

    procedure Work_Area
           (X, Y, W, H : out Integer);

    procedure Bounding_Rect
           (X, Y, W, H   :    out Integer;
            Pos_X, Pos_Y : in     Integer);

    procedure Bounding_Rect
           (X, Y, W, H :    out Integer;
            Screen_Num : in     Integer);

    procedure Bounding_Rect
           (X, Y, W, H : out Integer);

    procedure Bounding_Rect
           (X, Y, W, H     :    out Integer;
            PX, PY, PW, PH : in     Integer);




    --  Drawing  --

    function Is_Damaged
        return Boolean;

    procedure Set_Damaged
           (To : in Boolean);

    procedure Flush;

    procedure Redraw;


private


    pragma Import (C, Redraw, "fl_screen_redraw");


    pragma Inline (Set_Display_String);
    pragma Inline (Set_Visual_Mode);

    pragma Inline (Get_X);
    pragma Inline (Get_Y);
    pragma Inline (Get_W);
    pragma Inline (Get_H);

    pragma Inline (Count);
    pragma Inline (DPI);

    pragma Inline (Containing);
    pragma Inline (Work_Area);
    pragma Inline (Bounding_Rect);

    pragma Inline (Is_Damaged);
    pragma Inline (Set_Damaged);
    pragma Inline (Flush);
    pragma Inline (Redraw);


end FLTK.Screen;


