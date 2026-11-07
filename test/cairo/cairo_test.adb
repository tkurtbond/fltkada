

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/cairo_test.cxx, after pofltk's examples/CairoTest.Mod:  three
--  shiny buttons, each with a title, drawn with FLTK.Cairo.  FLTK's
--  program uses Fl_Cairo_Window, which only an FLTK built for it has.


with

    FLTK.Cairo,
    FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;


function Cairo_Test
    return Integer
is

    package Cai renames FLTK.Cairo;
    package CDW renames FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;


    Default_Width : constant Long_Float := 0.03;


    procedure Centered_Text
           (C                       : in Cai.Context;
            X0, Y0                  : in Long_Float;
            Rect_Width, Rect_Height : in Long_Float;
            Text                    : in String)
    is
        E    : Cai.Text_Extents;
        X, Y : Long_Float;
    begin
        Cai.Select_Font_Face (C, "Sans", Cai.Oblique_Slant, Cai.Bold_Weight);
        Cai.Set_Source_RGBA (C, 0.9, 0.9, 0.4, 0.6);
        E := Cai.Get_Text_Extents (C, Text);
        X := E.Width / 2.0 + E.X_Bearing;
        Y := E.Height / 2.0 + E.Y_Bearing;
        Cai.Move_To (C, X0 + Rect_Width / 2.0 - X, Y0 + Rect_Height / 2.0 - Y);
        Cai.Text_Path (C, Text);
        Cai.Fill_Preserve (C);
        Cai.Set_Source_RGBA (C, 0.0, 0.0, 0.0, 1.0);
        Cai.Set_Line_Width (C, 0.004);
        Cai.Stroke (C);
        Cai.Set_Line_Width (C, Default_Width);
    end Centered_Text;


    --  A button with a radial gradient, its corners rounded by curves.
    procedure Round_Button
           (C                       : in Cai.Context;
            X0, Y0                  : in Long_Float;
            Rect_Width, Rect_Height : in Long_Float;
            Radius                  : in Long_Float;
            R, G, B                 : in Long_Float)
    is
        X1 : constant Long_Float := X0 + Rect_Width;
        Y1 : constant Long_Float := Y0 + Rect_Height;
    begin
        if Rect_Width = 0.0 or Rect_Height = 0.0 then
            return;
        end if;
        if Rect_Width / 2.0 < Radius then
            if Rect_Height / 2.0 < Radius then
                Cai.Move_To (C, X0, (Y0 + Y1) / 2.0);
                Cai.Curve_To (C, X0, Y0, X0, Y0, (X0 + X1) / 2.0, Y0);
                Cai.Curve_To (C, X1, Y0, X1, Y0, X1, (Y0 + Y1) / 2.0);
                Cai.Curve_To (C, X1, Y1, X1, Y1, (X1 + X0) / 2.0, Y1);
                Cai.Curve_To (C, X0, Y1, X0, Y1, X0, (Y0 + Y1) / 2.0);
            else
                Cai.Move_To (C, X0, Y0 + Radius);
                Cai.Curve_To (C, X0, Y0, X0, Y0, (X0 + X1) / 2.0, Y0);
                Cai.Curve_To (C, X1, Y0, X1, Y0, X1, Y0 + Radius);
                Cai.Line_To (C, X1, Y1 - Radius);
                Cai.Curve_To (C, X1, Y1, X1, Y1, (X1 + X0) / 2.0, Y1);
                Cai.Curve_To (C, X0, Y1, X0, Y1, X0, Y1 - Radius);
            end if;
        elsif Rect_Height / 2.0 < Radius then
            Cai.Move_To (C, X0, (Y0 + Y1) / 2.0);
            Cai.Curve_To (C, X0, Y0, X0, Y0, X0 + Radius, Y0);
            Cai.Line_To (C, X1 - Radius, Y0);
            Cai.Curve_To (C, X1, Y0, X1, Y0, X1, (Y0 + Y1) / 2.0);
            Cai.Curve_To (C, X1, Y1, X1, Y1, X1 - Radius, Y1);
            Cai.Line_To (C, X0 + Radius, Y1);
            Cai.Curve_To (C, X0, Y1, X0, Y1, X0, (Y0 + Y1) / 2.0);
        else
            Cai.Move_To (C, X0, Y0 + Radius);
            Cai.Curve_To (C, X0, Y0, X0, Y0, X0 + Radius, Y0);
            Cai.Line_To (C, X1 - Radius, Y0);
            Cai.Curve_To (C, X1, Y0, X1, Y0, X1, Y0 + Radius);
            Cai.Line_To (C, X1, Y1 - Radius);
            Cai.Curve_To (C, X1, Y1, X1, Y1, X1 - Radius, Y1);
            Cai.Line_To (C, X0 + Radius, Y1);
            Cai.Curve_To (C, X0, Y1, X0, Y1, X0, Y1 - Radius);
        end if;
        Cai.Close_Path (C);

        declare
            P : Cai.Pattern := Cai.Forge.Create_Radial (0.25, 0.24, 0.11, 0.24, 0.14, 0.35);
        begin
            P.Set_Extend (Cai.Reflect_Extend);
            P.Add_Color_Stop_RGBA (1.0, R, G, B, 1.0);
            P.Add_Color_Stop_RGBA (0.0, 1.0, 1.0, 1.0, 1.0);
            Cai.Set_Source (C, P);
            Cai.Fill_Preserve (C);
        end;

        Cai.Set_Source_RGBA (C, 0.0, 0.0, 0.5, 0.3);
        Cai.Stroke (C);
        Cai.Set_Font_Size (C, 0.075);
        Centered_Text (C, X0, Y0, Rect_Width, Rect_Height, "FLTK loves Cairo!");
    end Round_Button;


    type Buttons_Window is new CDW.Cairo_Drawn_Window with null record;

    overriding procedure Draw_Cairo
           (This    : in out Buttons_Window;
            Context : in     Cai.Context) is
    begin
        Cai.Set_Line_Width (Context, Default_Width);
        Cai.Scale (Context, Long_Float (This.Get_W), Long_Float (This.Get_H));
        Round_Button (Context, 0.1, 0.1, 0.8, 0.2, 0.4, 1.0, 0.0, 0.0);
        Round_Button (Context, 0.1, 0.4, 0.8, 0.2, 0.4, 0.0, 1.0, 0.0);
        Round_Button (Context, 0.1, 0.7, 0.8, 0.2, 0.4, 0.0, 0.0, 1.0);
    end Draw_Cairo;


    Window : Buttons_Window :=
        (CDW.Forge.Create (350, 350, "FLTK loves Cairo") with null record);


begin


    Window.Set_Resizable (Window);
    Window.Set_Background_Color (FLTK.White_Color);
    Window.Show_With_Args;
    return FLTK.Run;


end Cairo_Test;


