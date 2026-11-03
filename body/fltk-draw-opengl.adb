

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Draw.OpenGL is


    ------------------------
    --  Functions From C  --
    ------------------------

    function fl_gl_start
        return Interfaces.C.int;
    pragma Import (C, fl_gl_start, "fl_gl_start");
    pragma Inline (fl_gl_start);

    function fl_gl_finish
        return Interfaces.C.int;
    pragma Import (C, fl_gl_finish, "fl_gl_finish");
    pragma Inline (fl_gl_finish);

    function fl_gl_ready
        return Interfaces.C.int;
    pragma Import (C, fl_gl_ready, "fl_gl_ready");
    pragma Inline (fl_gl_ready);




    procedure fl_gl_color
           (C : in Interfaces.C.unsigned);
    pragma Import (C, fl_gl_color, "fl_gl_color");
    pragma Inline (fl_gl_color);

    procedure fl_gl_rect
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_gl_rect, "fl_gl_rect");
    pragma Inline (fl_gl_rect);

    procedure fl_gl_rectf
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_gl_rectf, "fl_gl_rectf");
    pragma Inline (fl_gl_rectf);




    procedure fl_gl_font
           (F, S : in Interfaces.C.int);
    pragma Import (C, fl_gl_font, "fl_gl_font");
    pragma Inline (fl_gl_font);

    function fl_gl_height
        return Interfaces.C.int;
    pragma Import (C, fl_gl_height, "fl_gl_height");
    pragma Inline (fl_gl_height);

    function fl_gl_descent
        return Interfaces.C.int;
    pragma Import (C, fl_gl_descent, "fl_gl_descent");
    pragma Inline (fl_gl_descent);

    function fl_gl_width
           (Str : in Interfaces.C.char_array;
            N   : in Interfaces.C.int)
        return Interfaces.C.double;
    pragma Import (C, fl_gl_width, "fl_gl_width");
    pragma Inline (fl_gl_width);

    function fl_gl_width2
           (C : in Interfaces.C.unsigned_char)
        return Interfaces.C.double;
    pragma Import (C, fl_gl_width2, "fl_gl_width2");
    pragma Inline (fl_gl_width2);




    procedure fl_gl_draw
           (Str : in Interfaces.C.char_array;
            N   : in Interfaces.C.int);
    pragma Import (C, fl_gl_draw, "fl_gl_draw");
    pragma Inline (fl_gl_draw);

    procedure fl_gl_draw2
           (Str  : in Interfaces.C.char_array;
            N    : in Interfaces.C.int;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_gl_draw2, "fl_gl_draw2");
    pragma Inline (fl_gl_draw2);

    procedure fl_gl_draw3
           (Str  : in Interfaces.C.char_array;
            N    : in Interfaces.C.int;
            X, Y : in Interfaces.C.C_float);
    pragma Import (C, fl_gl_draw3, "fl_gl_draw3");
    pragma Inline (fl_gl_draw3);

    procedure fl_gl_draw4
           (Str        : in Interfaces.C.char_array;
            X, Y, W, H : in Interfaces.C.int;
            A          : in Interfaces.Unsigned_16);
    pragma Import (C, fl_gl_draw4, "fl_gl_draw4");
    pragma Inline (fl_gl_draw4);

    procedure fl_gl_measure
           (Str  : in     Interfaces.C.char_array;
            X, Y : in out Interfaces.C.int);
    pragma Import (C, fl_gl_measure, "fl_gl_measure");
    pragma Inline (fl_gl_measure);




    procedure fl_gl_set_texture_pile_height
           (M : in Interfaces.C.int);
    pragma Import (C, fl_gl_set_texture_pile_height, "fl_gl_set_texture_pile_height");
    pragma Inline (fl_gl_set_texture_pile_height);

    function fl_gl_get_texture_pile_height
        return Interfaces.C.int;
    pragma Import (C, fl_gl_get_texture_pile_height, "fl_gl_get_texture_pile_height");
    pragma Inline (fl_gl_get_texture_pile_height);

    procedure fl_gl_texture_reset;
    pragma Import (C, fl_gl_texture_reset, "fl_gl_texture_reset");
    pragma Inline (fl_gl_texture_reset);




    procedure fl_gl_draw_image
           (Buf        : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            D, L       : in Interfaces.C.int);
    pragma Import (C, fl_gl_draw_image, "fl_gl_draw_image");
    pragma Inline (fl_gl_draw_image);




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  FL/gl.h's text calls crash with no GL context (pofltk 111).

    procedure Check_Ready
           (Name : in String) is
    begin
        if fl_gl_ready = 0 then
            raise Program_Error with Name & " needs a GL context: a shown GL window "
                & "current, or Start";
        end if;
    end Check_Ready;




    --  Drawing into a Normal Window  --

    procedure Start is
    begin
        case fl_gl_start is
            when -1 =>
                raise Unsupported_Error with "OpenGL.Start does not work on Wayland";
            when 0 =>
                raise Program_Error with "OpenGL.Start needs a shown window to be current, "
                    & "and no Start without its Finish";
            when others =>
                null;
        end case;
    end Start;


    procedure Finish is
    begin
        if fl_gl_finish = 0 then
            raise Program_Error with "OpenGL.Finish without OpenGL.Start";
        end if;
    end Finish;




    --  Color, Rectangles  --

    procedure Set_Color
           (To : in Color) is
    begin
        fl_gl_color (Interfaces.C.unsigned (To));
    end Set_Color;


    procedure Rect
           (X, Y, W, H : in Integer) is
    begin
        fl_gl_rect
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Rect;


    procedure Rect_Fill
           (X, Y, W, H : in Integer) is
    begin
        fl_gl_rectf
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Rect_Fill;




    --  Fonts  --

    procedure Set_Font
           (Kind : in Font_Kind;
            Size : in Font_Size) is
    begin
        Check_Ready ("OpenGL.Set_Font");
        fl_gl_font (Font_Kind'Pos (Kind), Interfaces.C.int (Size));
    end Set_Font;


    function Font_Height
        return Integer is
    begin
        Check_Ready ("OpenGL.Font_Height");
        return Integer (fl_gl_height);
    end Font_Height;


    function Font_Descent
        return Integer is
    begin
        Check_Ready ("OpenGL.Font_Descent");
        return Integer (fl_gl_descent);
    end Font_Descent;


    function Width
           (Text : in String)
        return Long_Float is
    begin
        Check_Ready ("OpenGL.Width");
        return Long_Float (fl_gl_width (Interfaces.C.To_C (Text), Text'Length));
    end Width;


    function Width
           (Glyph : in Character)
        return Long_Float is
    begin
        Check_Ready ("OpenGL.Width");
        return Long_Float (fl_gl_width2 (Character'Pos (Glyph)));
    end Width;




    --  Text  --

    procedure Draw_Text
           (Text : in String) is
    begin
        Check_Ready ("OpenGL.Draw_Text");
        fl_gl_draw (Interfaces.C.To_C (Text), Text'Length);
    end Draw_Text;


    procedure Draw_Text
           (X, Y : in Integer;
            Text : in String) is
    begin
        Check_Ready ("OpenGL.Draw_Text");
        fl_gl_draw2
           (Interfaces.C.To_C (Text),
            Text'Length,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw_Text;


    procedure Draw_Text
           (X, Y : in Float;
            Text : in String) is
    begin
        Check_Ready ("OpenGL.Draw_Text");
        fl_gl_draw3
           (Interfaces.C.To_C (Text),
            Text'Length,
            Interfaces.C.C_float (X),
            Interfaces.C.C_float (Y));
    end Draw_Text;


    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment) is
    begin
        Check_Ready ("OpenGL.Draw_Text");
        fl_gl_draw4
           (Interfaces.C.To_C (Text),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.Unsigned_16 (Align));
    end Draw_Text;


    procedure Measure
           (Text : in     String;
            W, H :    out Natural)
    is
        Result_W, Result_H : Interfaces.C.int := 0;
    begin
        Check_Ready ("OpenGL.Measure");
        fl_gl_measure (Interfaces.C.To_C (Text), Result_W, Result_H);
        W := Natural (Result_W);
        H := Natural (Result_H);
    end Measure;




    --  Texture Pile  --

    function Get_Texture_Pile_Height
        return Positive is
    begin
        return Positive (fl_gl_get_texture_pile_height);
    end Get_Texture_Pile_Height;


    procedure Set_Texture_Pile_Height
           (Max : in Positive) is
    begin
        fl_gl_set_texture_pile_height (Interfaces.C.int (Max));
    end Set_Texture_Pile_Height;


    procedure Texture_Reset is
    begin
        fl_gl_texture_reset;
    end Texture_Reset;




    --  Images  --

    procedure Draw_Image
           (X, Y, W, H : in Integer;
            Data       : in Color_Component_Array;
            Depth      : in Positive := 3;
            Line_Size  : in Natural := 0) is
    begin
        fl_gl_draw_image
           ((if Data'Length > 0
             then Storage.To_Integer (Data (Data'First)'Address)
             else Null_Pointer),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Depth),
            Interfaces.C.int (Line_Size));
    end Draw_Image;


end FLTK.Draw.OpenGL;


