

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images,
    FLTK.Widgets.Groups.Windows;


package FLTK.Draw is


    --------------------------
    --  Types and Constants --
    --------------------------

    type Line_Kind is
       (Solid_Line,
        Dash_Line,
        Dot_Line,
        Dashdot_Line,
        Dashdotdot_Line);

    type Cap_Kind is
       (Default_Cap,
        Flat_Cap,
        Round_Cap,
        Square_Cap);

    type Join_Kind is
       (Default_Join,
        Miter_Join,
        Round_Join,
        Bevel_Join);

    type Dash_Length is new Integer range 1 .. 255;

    type Dash_Gap is record
        Solid : Dash_Length;
        Blank : Dash_Length;
    end record;

    type Dash_Gap_Array is array (Positive range <>) of Dash_Gap;

    Empty_Dashes : constant Dash_Gap_Array (1 .. 0) := (others => (1, 1));

    type Image_Draw_Function is access procedure
           (X, Y : in     Natural;
            Data :    out Color_Component_Array);

    type Symbol_Draw_Function is access procedure
           (Hue : in Color);

    type Text_Draw_Function is access procedure
           (X, Y : in Integer;
            Text : in String);

    type Area_Draw_Function is access procedure
           (X, Y, W, H : in Integer);

    Draw_Error : exception;




    ------------------------
    --  No Documentation  --
    ------------------------

    procedure Reset_Spot;

    procedure Set_Spot
           (X, Y, W, H : in Integer;
            Font       : in Font_Kind;
            Size       : in Font_Size);

    procedure Set_Spot
           (X, Y, W, H : in Integer;
            Font       : in Font_Kind;
            Size       : in Font_Size;
            Pane       : in FLTK.Widgets.Groups.Windows.Window'Class);

    procedure Set_Status
           (X, Y, W, H : in Integer);




    ---------------
    --  Utility  --
    ---------------

    function Can_Do_Alpha_Blending
        return Boolean;

    function Shortcut_Label
           (Keys : in Key_Combo)
        return String;




    --------------------------
    --  Charset Conversion  --
    --------------------------

    function Latin1_To_Local
           (From : in String)
        return String;

    function Local_To_Latin1
           (From : in String)
        return String;

    function Mac_Roman_To_Local
           (From : in String)
        return String;

    function Local_To_Mac_Roman
           (From : in String)
        return String;




    ----------------
    --  Clipping  --
    ----------------

    function Clip_Box
           (X, Y, W, H     : in     Integer;
            BX, BY, BW, BH :    out Integer)
        return Boolean;

    function Clip_Intersects
           (X, Y, W, H : in Integer)
        return Boolean;

    procedure Pop_Clip;

    procedure Push_Clip
           (X, Y, W, H : in Integer);

    procedure Push_No_Clip;

    procedure Restore_Clip;




    ---------------
    --  Overlay  --
    ---------------

    procedure Overlay_Clear;

    procedure Overlay_Rect
           (X, Y, W, H : in Integer);




    ----------------
    --  Settings  --
    ----------------

    function Get_Color
        return Color;

    procedure Set_Color
           (To : in Color);

    procedure Set_Color
           (R, G, B : in Color_Component);

    procedure Set_Cursor
           (To : in Mouse_Cursor_Kind);

    procedure Set_Cursor
           (To   : in Mouse_Cursor_Kind;
            Fore : in Color;
            Back : in Color := White_Color);

    function Get_Font
        return Font_Kind;

    function Get_Font_Size
        return Font_Size;

    procedure Set_Font
           (Kind : in Font_Kind;
            Size : in Font_Size);

    function Font_Line_Spacing
        return Integer;

    function Font_Descent
        return Integer;

    function Font_Height
           (Kind : in Font_Kind;
            Size : in Font_Size)
        return Natural;

    procedure Set_Line_Style
           (Line   : in Line_Kind      := Solid_Line;
            Cap    : in Cap_Kind       := Default_Cap;
            Join   : in Join_Kind      := Default_Join;
            Width  : in Natural        := 0;
            Dashes : in Dash_Gap_Array := Empty_Dashes);




    -------------------------
    --  Matrix Operations  --
    -------------------------

    procedure Mult_Matrix
           (A, B, C, D, X, Y : in Long_Float);

    procedure Pop_Matrix;

    procedure Push_Matrix;

    procedure Rotate
           (Angle : in Long_Float);

    procedure Scale
           (Factor : in Long_Float);

    procedure Scale
           (Factor_X, Factor_Y : in Long_Float);

    function Transform_DX
           (X, Y : in Long_Float)
        return Long_Float;

    function Transform_DY
           (X, Y : in Long_Float)
        return Long_Float;

    function Transform_X
           (X, Y : in Long_Float)
        return Long_Float;

    function Transform_Y
           (X, Y : in Long_Float)
        return Long_Float;

    procedure Transformed_Vertex
           (XF, YF : in Long_Float);

    procedure Translate
           (X, Y : in Long_Float);

    procedure Vertex
           (X, Y : in Long_Float);




    ---------------------
    --  Image Drawing  --
    ---------------------

    procedure Draw_Image
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 3;
            Line_Data       : in Natural := 0;
            Flip_Horizontal : in Boolean := False;
            Flip_Vertical   : in Boolean := False);

    procedure Draw_Image
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 3);

    procedure Draw_Image_Mono
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 1;
            Line_Data       : in Natural := 0;
            Flip_Horizontal : Boolean := False;
            Flip_Vertical   : Boolean := False);

    procedure Draw_Image_Mono
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 1);

    function Read_Image
           (X, Y, W, H : in Integer;
            Alpha      : in Integer := 0)
        return Color_Component_Array
    with Post =>
           (if Alpha = 0
            then Read_Image'Result'Length = W * H * 3
            else Read_Image'Result'Length = W * H * 4);




    -----------------------
    --  Special Drawing  --
    -----------------------

    procedure Add_Symbol
           (Text     : in String;
            Callback : in Symbol_Draw_Function;
            Scalable : in Boolean);

    procedure Draw_Text
           (X, Y : in Integer;
            Text : in String)
    with Pre => Text'Length > 0;

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Picture    : in FLTK.Images.Image'Class;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Callback   : in Text_Draw_Function;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Callback   : in Text_Draw_Function;
            Picture    : in FLTK.Images.Image'Class;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y  : in Integer;
            Text  : in String;
            Angle : in Integer);

    procedure Draw_Text_Right_Left
           (X, Y : in Integer;
            Text : in String);

    procedure Draw_Box
           (X, Y, W, H : in Integer;
            Kind       : in Box_Kind;
            Hue        : in Color);

    procedure Draw_Symbol
           (X, Y, W, H : in Integer;
            Name       : in String;
            Hue        : in Color);

    procedure Measure
           (Text    : in     String;
            W, H    :    out Natural;
            Symbols : in     Boolean := True;
            Wrap    : in     Natural := 0);

    procedure Scroll
           (X, Y, W, H : in Integer;
            DX, DY     : in Integer;
            Callback   : in Area_Draw_Function);

    procedure Text_Extents
           (Text         : in     String;
            DX, DY, W, H :    out Integer);

    function Width
           (Text : in String)
        return Long_Float;

    function Width
           (Glyph : in Character)
        return Long_Float;

    function Width
           (Glyph : in Wide_Character)
        return Long_Float;

    function Width
           (Glyph : in Wide_Wide_Character)
        return Long_Float;




    ----------------------
    --  Manual Drawing  --
    ----------------------

    procedure Begin_Complex_Polygon;
    procedure Begin_Line;
    procedure Begin_Loop;
    procedure Begin_Points;
    procedure Begin_Polygon;

    procedure Arc
           (X, Y, R, Start, Finish : in Long_Float);

    procedure Arc
           (X, Y, W, H    : in Integer;
            Start, Finish : in Long_Float);

    --  As per 1.3.9 docs, currently a placeholder
    procedure Chord
           (X, Y, W, H     : in Integer;
            Angle1, Angle2 : in Long_Float);

    procedure Circle
           (X, Y, R : in Long_Float);

    procedure Curve
           (X0, Y0 : in Long_Float;
            X1, Y1 : in Long_Float;
            X2, Y2 : in Long_Float;
            X3, Y3 : in Long_Float);

    procedure Frame
           (X, Y, W, H               : in Integer;
            Top, Left, Bottom, Right : in Greyscale);

    procedure Gap;

    procedure Line
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer);

    procedure Line
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer);

    procedure Outline
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer);

    procedure Outline
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer;
            X3, Y3 : in Integer);

    procedure Pie
           (X, Y, W, H     : in Integer;
            Angle1, Angle2 : in Long_Float);

    procedure Point
           (X, Y : in Integer);

    procedure Polygon
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer);

    procedure Polygon
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer;
            X3, Y3 : in Integer);

    procedure Rect
           (X, Y, W, H : in Integer);

    procedure Rect
           (X, Y, W, H : in Integer;
            Hue        : in Color);

    procedure Rect_Fill
           (X, Y, W, H : in Integer);

    procedure Rect_Fill
           (X, Y, W, H : in Integer;
            Hue        : in Color);

    procedure Rect_Fill
           (X, Y, W, H : in Integer;
            R, G, B    : in Color_Component);

    procedure Ecks_Why_Line
           (X0, Y0, X1 : in Integer);

    procedure Ecks_Why_Line
           (X0, Y0, X1, Y2 : in Integer);

    procedure Ecks_Why_Line
           (X0, Y0, X1, Y2, X3 : in Integer);

    procedure Why_Ecks_Line
           (X0, Y0, Y1 : in Integer);

    procedure Why_Ecks_Line
           (X0, Y0, Y1, X2 : in Integer);

    procedure Why_Ecks_Line
           (X0, Y0, Y1, X2, Y3 : in Integer);

    procedure End_Complex_Polygon;
    procedure End_Line;
    procedure End_Loop;
    procedure End_Points;
    procedure End_Polygon;


private


    pragma Convention (C, Symbol_Draw_Function);


    pragma Inline (Reset_Spot);
    pragma Inline (Set_Spot);
    pragma Inline (Set_Status);


    pragma Inline (Can_Do_Alpha_Blending);
    pragma Inline (Shortcut_Label);


    pragma Inline (Latin1_To_Local);
    pragma Inline (Local_To_Latin1);
    pragma Inline (Mac_Roman_To_Local);
    pragma Inline (Local_To_Mac_Roman);


    pragma Inline (Clip_Intersects);
    pragma Inline (Pop_Clip);
    pragma Inline (Push_Clip);
    pragma Inline (Push_No_Clip);
    pragma Inline (Restore_Clip);


    pragma Inline (Overlay_Clear);
    pragma Inline (Overlay_Rect);


    pragma Inline (Get_Color);
    pragma Inline (Set_Color);
    pragma Inline (Get_Font);
    pragma Inline (Get_Font_Size);
    pragma Inline (Set_Font);
    pragma Inline (Font_Line_Spacing);
    pragma Inline (Font_Descent);
    pragma Inline (Font_Height);


    pragma Inline (Mult_Matrix);
    pragma Inline (Pop_Matrix);
    pragma Inline (Push_Matrix);
    pragma Inline (Rotate);
    pragma Inline (Scale);
    pragma Inline (Transform_DX);
    pragma Inline (Transform_DY);
    pragma Inline (Transform_X);
    pragma Inline (Transform_Y);
    pragma Inline (Transformed_Vertex);
    pragma Inline (Translate);
    pragma Inline (Vertex);


    pragma Inline (Add_Symbol);
    pragma Inline (Draw_Text);
    pragma Inline (Draw_Text_Right_Left);
    pragma Inline (Draw_Box);
    pragma Inline (Draw_Symbol);
    pragma Inline (Measure);
    pragma Inline (Scroll);
    pragma Inline (Text_Extents);
    pragma Inline (Width);


    pragma Inline (Begin_Complex_Polygon);
    pragma Inline (Begin_Line);
    pragma Inline (Begin_Loop);
    pragma Inline (Begin_Points);
    pragma Inline (Begin_Polygon);


    pragma Inline (Arc);
    pragma Inline (Chord);
    pragma Inline (Circle);
    pragma Inline (Curve);
    pragma Inline (Frame);
    pragma Inline (Gap);
    pragma Inline (Line);
    pragma Inline (Outline);
    pragma Inline (Pie);
    pragma Inline (Point);
    pragma Inline (Polygon);
    pragma Inline (Rect);
    pragma Inline (Rect_Fill);
    pragma Inline (Ecks_Why_Line);
    pragma Inline (Why_Ecks_Line);


    pragma Inline (End_Complex_Polygon);
    pragma Inline (End_Line);
    pragma Inline (End_Loop);
    pragma Inline (End_Points);
    pragma Inline (End_Polygon);


end FLTK.Draw;


