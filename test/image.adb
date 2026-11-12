--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/image.cxx: an RGBA image, its colours fading from three
--  corners and its alpha growing from the centre, on a button, with
--  toggles for the label's alignment and the button's being inactive.
--  FLTK's -v option, an X visual by number, is left out.  Guided by
--  pofltk's Image.Mod.


with

    Ada.Numerics.Long_Elementary_Functions,
    FLTK.Images.RGB,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment,
    FLTK.Size_Type;


function Image
    return Integer
is

    package LEF renames Ada.Numerics.Long_Elementary_Functions;
    package RGB renames FLTK.Images.RGB;
    package Btn renames FLTK.Widgets.Buttons;
    package Tgl renames FLTK.Widgets.Buttons.Toggle;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    Width  : constant := 100;
    Height : constant := 100;


    --  C's conversion of a double to an integer type.
    function Trunc
           (Value : in Long_Float)
        return Integer is
    begin
        return Integer (Long_Float'Truncation (Value));
    end Trunc;


    --  FLTK's make_image.
    function Make_Image
        return FLTK.Color_Component_Array
    is
        Data : FLTK.Color_Component_Array (1 .. 4 * Width * Height);
        P    : FLTK.Size_Type := Data'First;

        procedure Put
               (Value : in Integer) is
        begin
            Data (P) := FLTK.Color_Component (Value);
            P := P + 1;
        end Put;

        X, Y  : Long_Float;
        Alpha : Integer;
    begin
        for J in 0 .. Height - 1 loop
            Y := Long_Float (J) / Long_Float (Height - 1);
            for I in 0 .. Width - 1 loop
                X := Long_Float (I) / Long_Float (Width - 1);
                Put (Trunc (255.0 * ((1.0 - X) * (1.0 - Y))));  --  red in upper-left
                Put (Trunc (255.0 * ((1.0 - X) * Y)));          --  green in lower-left
                Put (Trunc (255.0 * (X * Y)));                  --  blue in lower-right
                X := X - 0.5;
                Y := Y - 0.5;
                Alpha := Trunc (255.0 * LEF.Sqrt (X * X + Y * Y));
                if Alpha < 255 then  --  alpha transparency
                    Put (Alpha);
                else
                    Put (255);
                end if;
                Y := Y + 0.5;
            end loop;
        end loop;
        return Data;
    end Make_Image;


    Count : Natural;

begin

    begin
        FLTK.Static.Parse_Args (Count);
    exception
        when FLTK.Static.Argument_Error =>
            null;
    end;
    FLTK.Screen.Set_Visual_Mode (FLTK.Screen.RGB);

    declare

        Window : Dbl.Double_Window := Dbl.Forge.Create (400, 400);
        B      : Btn.Button := Btn.Forge.Create (Window, 140, 160, 120, 120, "Image w/Alpha");

        Img   : RGB.RGB_Image := RGB.Forge.Create (Make_Image, Width, Height, 4);
        Dergb : RGB.RGB_Image'Class := Img.Copy;

        Leftb   : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 25, 50, 50, 25, "left");
        Rightb  : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 75, 50, 50, 25, "right");
        Topb    : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 125, 50, 50, 25, "top");
        Bottomb : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 175, 50, 50, 25, "bottom");
        Insideb : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 225, 50, 50, 25, "inside");
        Overb   : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 25, 75, 100, 25, "text over");
        Inactb  : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 125, 75, 100, 25, "inactive");


        procedure Button_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            I : FLTK.Alignment := FLTK.Align_Center;
        begin
            if Leftb.Is_On then I := I + FLTK.Align_Left; end if;
            if Rightb.Is_On then I := I + FLTK.Align_Right; end if;
            if Topb.Is_On then I := I + FLTK.Align_Top; end if;
            if Bottomb.Is_On then I := I + FLTK.Align_Bottom; end if;
            if Insideb.Is_On then I := I + FLTK.Align_Inside; end if;
            if Overb.Is_On then I := I + FLTK.Align_Text_Over_Image; end if;
            B.Set_Alignment (I);
            if Inactb.Is_On then
                B.Deactivate;
            else
                B.Activate;
            end if;
            Window.Redraw;
        end Button_CB;

    begin

        Window.Set_Background_Color (FLTK.White_Color);

        Dergb.Inactive;
        B.Set_Image (Img);
        B.Set_Inactive_Image (Dergb);

        Leftb.Set_Callback (Button_CB'Unrestricted_Access);
        Rightb.Set_Callback (Button_CB'Unrestricted_Access);
        Topb.Set_Callback (Button_CB'Unrestricted_Access);
        Bottomb.Set_Callback (Button_CB'Unrestricted_Access);
        Insideb.Set_Callback (Button_CB'Unrestricted_Access);
        Overb.Set_Callback (Button_CB'Unrestricted_Access);
        Inactb.Set_Callback (Button_CB'Unrestricted_Access);

        Window.Set_Resizable (Window);
        Window.End_Current;
        Window.Show_With_Args;

        return FLTK.Run;

    end;

end Image;
