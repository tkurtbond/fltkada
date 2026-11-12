--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/animated.cxx: 48 frames of RGBA images, a fading sphere
--  and a moving blob over a black box, drawn 24 times a second through a
--  clip that hides the box.  C's conversions to uchar and int truncate,
--  and a uchar product wraps, so the port truncates and wraps too; C
--  compares the float fill with the double 0.9, so the port compares in
--  Long_Float.  Guided by pofltk's Animated.Mod.  (FLTKAda's earlier
--  program rounded, scaled the sphere's edge by a real factor, and left
--  out part of the title.)


pragma Ada_2022;


with

    FLTK.Draw,
    FLTK.Images.RGB,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Size_Type;


function Animated
    return Integer
is

    package FDR renames FLTK.Draw;
    package RGB renames FLTK.Images.RGB;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    Dim    : constant := 256;
    Frames : constant := 48;

    subtype Frame_Number is Natural range 0 .. Frames - 1;

    subtype Image_Data is FLTK.Color_Component_Array (1 .. Dim * Dim * 4);


    --  C's conversion of a float to an integer type.
    function Trunc
           (Value : in Float)
        return Integer is
    begin
        return Integer (Float'Truncation (Value));
    end Trunc;


    --  FLTK's make_images, for frame I.
    function Make_Image
           (I : in Frame_Number)
        return RGB.RGB_Image
    is
        Data : Image_Data := [others => 0];

        procedure Set
               (X, Y, Channel : in Integer;
                Value         : in Integer) is
        begin
            Data (FLTK.Size_Type (Y * Dim * 4 + X * 4 + Channel + 1)) :=
                FLTK.Color_Component (Value mod 256);
        end Set;

        Sphere_W : constant := 60;
        Sphere_X : constant := (Dim - Sphere_W) / 2;
        Max_Dist : constant := (Sphere_W / 2) * (Sphere_W / 2);

        Alpha, My_Alpha        : Integer;
        Dist_X, Dist_Y, Dist   : Float;
        Fill                   : Float;
        Pos                    : Float;
        X_Offset               : Integer;
        Y_Offset               : constant := 2 * Dim / 3;
        W                      : constant := Dim / 4;
    begin
        --  First a black box, 10x10 pixels in the top-left corner
        for X in 0 .. 9 loop
            for Y in 0 .. 9 loop
                Set (X, Y, 3, 255);
            end loop;
        end loop;

        --  A fading sphere
        if I < Frames / 2 then
            Alpha := Trunc (255.0 * (Float (I) / (Float (Frames) / 2.0)));
        else
            Alpha := Trunc
                (255.0 * (Float ((Frames / 2) - (I - Frames / 2)) / (Float (Frames) / 2.0)))
                mod 256;
        end if;

        for X in Sphere_X .. Sphere_X + Sphere_W - 1 loop
            for Y in 20 .. 20 + Sphere_W - 1 loop
                Dist_X := Float (X) - (Float (Sphere_X) + Float (Sphere_W) / 2.0);
                Dist_Y := Float (Y) - (20.0 + Float (Sphere_W) / 2.0);
                Dist := Dist_X * Dist_X + Dist_Y * Dist_Y;

                if Dist <= Float (Max_Dist) then
                    Fill := Dist / Float (Max_Dist);
                    My_Alpha := Alpha;
                    if Long_Float (Fill) > 0.9 then
                        My_Alpha := My_Alpha * Trunc ((1.0 - Fill) * 10.0) mod 256;
                    end if;
                    Set (X, Y, 0, Trunc (Fill * 255.0));
                    Set (X, Y, 1, Trunc (Fill * 255.0));
                    Set (X, Y, 2, Trunc (Fill * 255.0));
                    Set (X, Y, 3, My_Alpha);
                end if;
            end loop;
        end loop;

        --  A moving blob
        Pos := (Float (I) / Float (Frames)) * 2.0 - 0.5;
        X_Offset := Trunc (Pos * Float (Dim));

        for X in -W .. W - 1 loop
            if X + X_Offset >= 0 and X + X_Offset < Dim then
                for Y in Y_Offset - W .. Y_Offset + W - 1 loop
                    Set (X + X_Offset, Y, 2, abs (Y - Y_Offset));
                    Set (X + X_Offset, Y, 3, 127);
                end loop;
            end if;
        end loop;

        return RGB.Forge.Create (Data, Dim, Dim, 4);
    end Make_Image;


    Img : constant array (Frame_Number) of RGB.RGB_Image :=
        [for I in Frame_Number => Make_Image (I)];

    Current_Frame : Frame_Number := 0;


    type Window is new Dbl.Double_Window with null record;

    overriding procedure Draw
           (This : in out Window) is
    begin
        Dbl.Double_Window (This).Draw;

        --  Test both cx/cy offset and clipping. Both borders should have a
        --  5-pixel edge, and the upper-left black box should not be visible.
        FDR.Push_Clip (5, 5, This.Get_W - 5, This.Get_H - 5);
        Img (Current_Frame).Draw (0, 0, Dim, Dim, 5, 5);
        FDR.Pop_Clip;
    end Draw;


    Win : Window :=
       (Dbl.Forge.Create (Dim, Dim, "Alpha rendering benchmark, watch CPU use")
        with null record);


    procedure CB is
    begin
        Win.Redraw;
        FLTK.Static.Repeat_Timeout (1.0 / 24.0, CB'Unrestricted_Access);
        Current_Frame := (Current_Frame + 1) mod Frames;
    end CB;

begin

    Win.Set_Background_Color (FLTK.RGB_Color (142, 0, 0));
    Win.End_Current;
    Win.Show_With_Args;

    FLTK.Static.Add_Timeout (1.0 / 24.0, CB'Unrestricted_Access);

    return FLTK.Run;

end Animated;
