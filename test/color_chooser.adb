

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Color chooser test program functionality reproduced in Ada


with

    FLTK.Asks,
    FLTK.Draw,
    FLTK.Images.RGB,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Color_Choosers,
    FLTK.Widgets.Groups.Windows;

use type

    FLTK.Color,
    FLTK.Asks.Confirm_Result;


function Color_Chooser
    return Integer
is


    package Ask renames FLTK.Asks;
    package FD  renames FLTK.Draw;
    package Img renames FLTK.Images.RGB;
    package Stc renames FLTK.Static;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package CC  renames FLTK.Widgets.Groups.Color_Choosers;
    package Win renames FLTK.Widgets.Groups.Windows;


    function Make_Image_Data
           (W, H : in Positive)
        return FLTK.Color_Component_Array
    is
        X_Frac, Y_Frac : Long_Float;
        Offset : Integer;
    begin
        return Data : FLTK.Color_Component_Array (1 .. W * H * 3) do
            for Y in 0 .. H - 1 loop
                Y_Frac := Long_Float (Y) / Long_Float (H - 1);
                for X in 0 .. W - 1 loop
                    X_Frac := Long_Float (X) / Long_Float (W - 1);
                    Offset := 3 * (Y * W + X);
                    Data (Offset + 1) :=
                        FLTK.Color_Component (255.0 * (1.0 - X_Frac) * (1.0 - Y_Frac));
                    Data (Offset + 2) :=
                        FLTK.Color_Component (255.0 * (1.0 - X_Frac) * Y_Frac);
                    Data (Offset + 3) :=
                        FLTK.Color_Component (255.0 * X_Frac * Y_Frac);
                end loop;
            end loop;
        end return;
    end Make_Image_Data;


    Image_Width, Image_Height : constant Natural := 100;

    The_Image_Data : FLTK.Color_Component_Array := Make_Image_Data (Image_Width, Image_Height);


    type Pens is new Bx.Box with null record;

    procedure Draw
           (This : in out Pens) is
    begin
        for Offset in 0 .. 3 * 8 - 1 loop
            FD.Set_Color (FLTK.Grey0_Color + FLTK.Color (Offset));
            FD.Line
               (This.Get_X + Offset, This.Get_Y,
                This.Get_X + Offset, This.Get_Y + This.Get_H);
        end loop;
    end Draw;


    The_Window : Win.Window := Win.Forge.Create (400, 400);

    The_Box  : Bx.Box := Bx.Forge.Create
        (The_Window, 30, 30, 340, 340);
    Hint_Box : Bx.Box := Bx.Forge.Create
        (The_Window, 40, 40, 320,  30, "Pick background color with buttons:");

    Button_One : Btn.Button := Btn.Forge.Create
        (The_Window, 120,  80, 180, 30, "fl_show_colormap()");
    Button_Two : Btn.Button := Btn.Forge.Create
        (The_Window, 120, 120, 180, 30, "fl_color_chooser()");

    Image_Box : Bx.Box := Bx.Forge.Create (The_Window, 160, 190, Image_Width, Image_Height);
    The_Image : Img.RGB_Image := Img.Forge.Create (The_Image_Data, Image_Width, Image_Height);

    Box_B : Bx.Box := Bx.Forge.Create (The_Window, 160, 310, 120, 30, "Example of fl_draw_image()");

    My_Pens : Pens :=
       (Bx.Forge.Create (The_Window, 60, 180, 3 * 8, 120, "lines")
        with null record);

    My_Color : FLTK.Color := FLTK.Background_Color;


    procedure Callback_One
           (This : in out FLTK.Widgets.Widget'Class) is
    begin
        My_Color := Ask.Show_Colormap (My_Color);
        The_Box.Set_Background_Color (My_Color);
        Hint_Box.Set_Label_Color (FLTK.Contrast (FLTK.Black_Color, My_Color));
        The_Box.Parent.Redraw;
    end Callback_One;


    procedure Callback_Two
           (This : in out FLTK.Widgets.Widget'Class)
    is
        R, G, B : FLTK.Color_Component;
    begin
        Stc.Get_Color (My_Color, R, G, B);
        if Ask.Color_Chooser ("New color:", R, G, B, CC.HSV) = Ask.Cancel then
            return;
        end if;
        My_Color := FLTK.Free_Color;
        Stc.Set_Color (FLTK.Free_Color, R, G, B);
        The_Box.Set_Background_Color (FLTK.Free_Color);
        Hint_Box.Set_Label_Color (FLTK.Contrast (FLTK.Black_Color, FLTK.Free_Color));
        The_Box.Parent.Redraw;
    end Callback_Two;


begin


    Stc.Set_Color (FLTK.Free_Color, 145, 159, 170);
    My_Color := FLTK.Free_Color;

    The_Box.Set_Box (FLTK.Thin_Down_Box);
    The_Box.Set_Background_Color (My_Color);

    Hint_Box.Set_Alignment (FLTK.Align_Inside);

    Button_One.Set_Callback (Callback_One'Unrestricted_Access);
    Button_Two.Set_Callback (Callback_Two'Unrestricted_Access);

    Image_Box.Set_Image (The_Image);

    My_Pens.Set_Alignment (FLTK.Align_Top);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Color_Chooser;


