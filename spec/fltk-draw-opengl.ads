

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Binding of FL/gl.h, FLTK's helper functions for drawing FLTK-style
--  things (colors, rectangles, text, images) inside an OpenGL window.


package FLTK.Draw.OpenGL is


    --  Drawing into a Normal Window  --

    --  Start raises Unsupported_Error on Wayland, where FLTK 1.4.5's gl_start
    --  crashes (pofltk 109), and Program_Error unless a shown window is
    --  current, as in its Draw, or if Start has run without Finish.  Finish
    --  raises Program_Error without a Start.
    procedure Start;

    procedure Finish;




    --  Color, Rectangles  --

    procedure Set_Color
           (To : in Color);

    procedure Rect
           (X, Y, W, H : in Integer);

    procedure Rect_Fill
           (X, Y, W, H : in Integer);




    --  Fonts  --

    --  The font and text subprograms raise Program_Error with no GL context:
    --  they need a shown GL_Window current, as in its Draw or after its
    --  Make_Current, or Start (pofltk 111).
    procedure Set_Font
           (Kind : in Font_Kind;
            Size : in Font_Size);

    function Font_Height
        return Integer;

    function Font_Descent
        return Integer;

    function Width
           (Text : in String)
        return Long_Float;

    function Width
           (Glyph : in Character)
        return Long_Float;




    --  Text  --

    procedure Draw_Text
           (Text : in String);

    procedure Draw_Text
           (X, Y : in Integer;
            Text : in String);

    procedure Draw_Text
           (X, Y : in Float;
            Text : in String);

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment);

    procedure Measure
           (Text : in     String;
            W, H :    out Natural);




    --  Texture Pile  --

    function Get_Texture_Pile_Height
        return Positive;

    procedure Set_Texture_Pile_Height
           (Max : in Positive);

    procedure Texture_Reset;




    --  Images  --

    procedure Draw_Image
           (X, Y, W, H : in Integer;
            Data       : in Color_Component_Array;
            Depth      : in Positive := 3;
            Line_Size  : in Natural := 0)
    with Pre => (if Line_Size = 0
        then Data'Length >= Size_Type (W) * Size_Type (H) * Size_Type (Depth)
        else Data'Length >= Size_Type (Line_Size) * Size_Type (H));


private


    pragma Inline (Start);
    pragma Inline (Finish);

    pragma Inline (Set_Color);
    pragma Inline (Rect);
    pragma Inline (Rect_Fill);

    pragma Inline (Set_Font);
    pragma Inline (Font_Height);
    pragma Inline (Font_Descent);
    pragma Inline (Width);

    pragma Inline (Draw_Text);
    pragma Inline (Measure);

    pragma Inline (Get_Texture_Pile_Height);
    pragma Inline (Set_Texture_Pile_Height);
    pragma Inline (Texture_Reset);

    pragma Inline (Draw_Image);


end FLTK.Draw.OpenGL;


