

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  N2 (PLAN.md): Draw_Image and Draw_Image_Mono with a line callback.  FLTK
--  gives the callback a line of W pixels of Depth bytes each (Xlib:
--  Fl_Xlib_Graphics_Driver_image.cxx:558-563; Cairo:
--  Fl_Cairo_Graphics_Driver.cxx:651-653), but the binding handed the Ada
--  callback only W bytes of it.  The rest of the line was never written,
--  so the right of a colour image came out of whatever was in FLTK's
--  buffer.  The test fills every byte it is given and checks the pixels
--  at both ends of the image, and that each line held W * Depth bytes.
--  The mono image has Depth 2, grey and a byte FLTK skips (Xlib) or makes
--  opaque (Cairo, Fl_Cairo_Graphics_Driver.cxx:654-656): Cairo draws a mono
--  image of Depth 3 or 4 as a colour one (:677-680), Xlib as grey.


with

    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Image_Lines is

    package Prb renames FLTK.Probe;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    Image_W : constant := 40;
    Image_H : constant := 10;

    type Mode_Kind is (Colour, Mono);

    Lengths_Right : Boolean := True;
    Lines         : Natural := 0;
    Want_Depth    : Positive := 3;
    Want_Mono     : Boolean := False;

    procedure Line
           (X, Y : in     Natural;
            Data :    out Color_Component_Array)
    is
        pragma Unreferenced (X, Y);
    begin
        Lines := Lines + 1;
        if Data'Length /= Image_W * Want_Depth then
            Lengths_Right := False;
        end if;
        --  Red for colour (R, G, B, R, ...), dark grey for mono.
        for I in Data'Range loop
            Data (I) := (if Want_Mono then 16#40#
                         elsif (I - Data'First) mod 3 = 0 then 16#FF# else 0);
        end loop;
    end Line;


    type Line_Box is new Bx.Box with record
        Mode : Mode_Kind := Colour;
    end record;

    overriding procedure Draw
           (This : in out Line_Box);

    overriding procedure Draw
           (This : in out Line_Box) is
    begin
        case This.Mode is
            when Colour =>
                FLTK.Draw.Draw_Image
                   (This.Get_X, This.Get_Y, Image_W, Image_H, Line'Unrestricted_Access, 3);
            when Mono =>
                FLTK.Draw.Draw_Image_Mono
                   (This.Get_X, This.Get_Y, Image_W, Image_H, Line'Unrestricted_Access, 2);
        end case;
    end Draw;


    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Image_Lines");

    The_Box : Line_Box :=
       (Bx.Forge.Create (Window, Flat_Box, 10, 10, Image_W, Image_H) with others => <>);

    procedure Try
           (Mode  : in Mode_Kind;
            Depth : in Positive;
            Want  : in Prb.RGB;
            What  : in String) is
    begin
        The_Box.Mode := Mode;
        Want_Depth := Depth;
        Want_Mono := Mode = Mono;
        Lines := 0;
        Lengths_Right := True;
        if not Prb.Capture (The_Box) then
            Check (False, What & ": the capture is the box's size");
            return;
        end if;
        Check (Lines = Image_H, What & ": one call a line:" & Natural'Image (Lines));
        Check (Lengths_Right, What & ": each line holds W * Depth bytes");
        Check (Prb.Pixel (0, 0) = Want, What & ": the left of the image");
        Check (Prb.Pixel (Image_W - 1, Image_H - 1) = Want, What & ": the right of the image");
        Prb.Release;
    end Try;

begin

    Try (Colour, 3, Prb.To_RGB (255, 0, 0), "a colour image");
    Try (Mono, 2, Prb.To_RGB (16#40#, 16#40#, 16#40#), "a mono image");

    Summary;

end Test_Image_Lines;


