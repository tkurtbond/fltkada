

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Screen is


    type Visual_Mode is (RGB, RGB_24bit, Double_Buffer, Double_RGB, Double_RGB_24bit);

    --  Whether the program can scale its windows (Fl::screen_scaling_supported):
    --  not at all, by one factor for every screen, or by one per screen.
    type Scaling_Kind is (No_Scaling, Systemwide_Scaling, Per_Screen_Scaling);




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




    --  Scaling  --

    function Scaling_Support
        return Scaling_Kind;

    --  The factor FLTK scales the program's windows by on a screen, 1.0
    --  where scaling isn't supported (Fl.cxx:2364-2366).  A screen number
    --  outside 1 .. Count raises Constraint_Error; FLTK would return 1.0.
    function Get_Scale
           (Screen_Number : in Integer := 1)
        return Float;

    --  Scales the windows on a screen, or on every screen when Scaling_Support
    --  is Systemwide_Scaling.  This opens the display.  FLTK does nothing
    --  where scaling isn't supported (Fl.cxx:2387-2389).  A screen number
    --  outside 1 .. Count raises Constraint_Error; FLTK would ignore it.
    procedure Set_Scale
           (Factor        : in Float;
            Screen_Number : in Integer := 1);

    --  Whether ctrl-+, ctrl-- and ctrl-0 rescale the program's windows; on
    --  by default.  Turning it off works at any time.  Turning it back on
    --  works only if it was on when the display opened, since FLTK installs
    --  its key handler then (Fl_Screen_Driver.cxx:478, 611-614).  FLTK's
    --  documentation reserves values other than 0 (Fl.cxx:2420-2422); this
    --  passes 1, the default (Fl_Screen_Driver.cxx:97).
    procedure Set_Keyboard_Scaling
           (To : in Boolean);




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


