

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Alpha rendering benchmark test program functionality duplicated in Ada


pragma Ada_2022;


with

    FLTK.Draw,
    FLTK.Images.RGB,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows.Double;


function Animated
    return Integer
is


    package FDR renames FLTK.Draw;
    package RGB renames FLTK.Images.RGB;
    package Stc renames FLTK.Static;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;


    Frames    : constant Integer := 48;
    Channels  : constant Integer := 4;
    Dimension : constant Integer := 256;


    subtype Image_Data is FLTK.Color_Component_Array (1 .. Dimension ** 2 * Channels);
    type Image_Data_Array is array (Positive range <>) of Image_Data;


    procedure Black_Box_Corner
           (Store : in out Image_Data) is
    begin
        for X in Integer range 0 .. 9 loop
            for Y in Integer range 0 .. 9 loop
                Store (Y * Dimension * Channels + X * Channels + 4) := 255;
            end loop;
        end loop;
    end Black_Box_Corner;


    procedure Fading_Sphere
           (Store : in out Image_Data;
            Place : in     Integer)
    is
        Sphere_W : constant Integer := 60;
        Sphere_X : constant Integer := (Dimension - Sphere_W) / 2;
        Max_Dist : constant Integer := (Sphere_W / 2) ** 2;
        Dist_X, Dist_Y, Dist, Fill : Float;
        Alpha, My_Alpha, Grey : FLTK.Color_Component;
    begin
        if Place - 1 < Frames / 2 then
            Alpha := FLTK.Color_Component
                (255.0 * (Float (Place - 1) / (Float (Frames) / 2.0)));
        else
            Alpha := FLTK.Color_Component
                (Integer (255.0 * (Float (Frames - Place + 1) / (Float (Frames) / 2.0))) mod 256);
        end if;

        for X in Integer range Sphere_X .. Sphere_X + Sphere_W - 1 loop
            for Y in Integer range 20 .. 20 + Sphere_W - 1 loop
                Dist_X := Float (X) - (Float (Sphere_X) + Float (Sphere_W) / 2.0);
                Dist_Y := Float (Y) - (20.0 + Float (Sphere_W) / 2.0);
                Dist := Dist_X ** 2 + Dist_Y ** 2;

                if Dist <= Float (Max_Dist) then
                    Fill := Dist / Float (Max_Dist);
                    Grey := FLTK.Color_Component (Fill * 255.0);
                    My_Alpha := Alpha;

                    if Fill > 0.9 then
                        My_Alpha := FLTK.Color_Component (Float (My_Alpha) * (1.0 - Fill) * 10.0);
                    end if;

                    Store (Y * Dimension * Channels + X * Channels + 1) := Grey;
                    Store (Y * Dimension * Channels + X * Channels + 2) := Grey;
                    Store (Y * Dimension * Channels + X * Channels + 3) := Grey;
                    Store (Y * Dimension * Channels + X * Channels + 4) := My_Alpha;
                end if;
            end loop;
        end loop;
    end Fading_Sphere;


    procedure Moving_Blob
           (Store : in out Image_Data;
            Place : in     Integer)
    is
        Position : constant Float := 2.0 * Float (Place - 1) / Float (Frames) - 0.5;
        X_Offset : constant Integer := Integer (Position * Float (Dimension));
        Y_Offset : constant Integer := 2 * Dimension / 3;
        W : constant Integer := Dimension / 4;
        Grey : FLTK.Color_Component;
    begin
        for X in Integer range (-W) .. W - 1 loop
            if (X + X_Offset >= 0) and (X + X_Offset < Dimension) then
                for Y in Integer range Y_Offset - W .. Y_Offset + W - 1 loop
                    Grey := FLTK.Color_Component (abs (Y - Y_Offset));
                    Store (Y * Dimension * Channels + (X + X_Offset) * Channels + 3) := Grey;
                    Store (Y * Dimension * Channels + (X + X_Offset) * Channels + 4) := 127;
                end loop;
            end if;
        end loop;
    end Moving_Blob;


    function Make_Image_Data
        return Image_Data_Array is
    begin
        return Pict_Data : Image_Data_Array (1 .. Frames) := (others => (others => 0)) do
            for Index in Pict_Data'Range loop
                Black_Box_Corner (Pict_Data (Index));
                Fading_Sphere    (Pict_Data (Index), Index);
                Moving_Blob      (Pict_Data (Index), Index);
            end loop;
        end return;
    end Make_Image_Data;


    Frame_Image_Data : constant Image_Data_Array := Make_Image_Data;

    --  This syntax requires Ada 2022, but it allows all overt heap usage to be avoided
    Frame_Images : constant array (Positive range <>) of RGB.RGB_Image :=
       (for Index in Frame_Image_Data'Range =>
        RGB.Forge.Create (Frame_Image_Data (Index), Dimension, Dimension, Channels));


    Current_Frame : Integer range 1 .. Frames := 1;


    type My_Window is new WD.Double_Window with null record;

    procedure Draw
           (This : in out My_Window) is
    begin
        WD.Double_Window (This).Draw;
        FDR.Push_Clip (5, 5, This.Get_W - 5, This.Get_H - 5);
        Frame_Images (Current_Frame).Draw (0, 0, Dimension, Dimension, 5, 5);
        FDR.Pop_Clip;
    end Draw;

    The_Window : My_Window :=
       (WD.Forge.Create (Dimension, Dimension, "Alpha rendering benchmark")
        with null record);


    procedure Frame_Update is
    begin
        The_Window.Redraw;
        Stc.Repeat_Timeout (1.0 / 24.0, Frame_Update'Unrestricted_Access);
        Current_Frame := Current_Frame mod Frames + 1;
    end Frame_Update;


begin


    The_Window.Set_Background_Color (FLTK.RGB_Color (142, 0, 0));
    The_Window.Show_With_Args;

    Stc.Add_Timeout (1.0 / 24.0, Frame_Update'Unrestricted_Access);

    return FLTK.Run;


end Animated;


