--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 47: an XPM colour given by name is read only on X11.  Fl_Pixmap
--  reads colours with fl_parse_color.  The X11 screen driver asks the X
--  server, which knows the names; every other one uses
--  Fl_Screen_Driver::parse_color, which reads hexadecimal alone
--  (Fl_Screen_Driver.cxx:625-646), so on Wayland "red" is FLTK's gray.
--  "#rrggbb" works on both.


with

    Ada.Strings.Unbounded,
    Checks,
    FLTK.Images.Pixmaps,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_XPM_Color_Names is

    package Pix renames FLTK.Images.Pixmaps;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    function "+"
           (Item : in String)
        return Ada.Strings.Unbounded.Unbounded_String
        renames Ada.Strings.Unbounded.To_Unbounded_String;

    --  The left half "red", by name; the right half blue, in hexadecimal.
    Pixels : constant Pix.Pixmap_Data (1 .. 10, 1 .. 20) :=
        (others => (1 .. 10 => 'r', 11 .. 20 => 'b'));
    Image  : Pix.Pixmap := Pix.Forge.Create
       ((Width => 20, Height => 10, Colors => 2, Per_Pixel => 1),
        ((+"r", Pix.Colorful, +"red"), (+"b", Pix.Colorful, +"#0000ff")),
        Pixels);

    Window : Win.Window := Win.Forge.Create (100, 50, "XPM names");
    Box    : FLTK.Widgets.Boxes.Box := FLTK.Widgets.Boxes.Forge.Create (Window, 0, 0, 100, 50);

    Red    : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Blue   : constant Prb.RGB := Prb.To_RGB (0, 0, 255);
    Gray   : constant Prb.RGB := Prb.To_RGB (16#C0#, 16#C0#, 16#C0#);
    Left, Right : Prb.RGB;

begin

    Window.End_Current;
    Box.Set_Image (Image);
    Window.Show;
    for I in 1 .. 10 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;

    Left  := Prb.Shown_Pixel (Window, 45, 25);
    Right := Prb.Shown_Pixel (Window, 55, 25);
    Check (Right = Blue, "#0000ff is blue:" & Prb.RGB'Image (Right));
    if Prb.On_Wayland then
        Check (Left = Gray, "on Wayland ""red"" is FLTK's gray:" & Prb.RGB'Image (Left));
    else
        Check (Left = Red, "on X11 ""red"" is red:" & Prb.RGB'Image (Left));
    end if;

    Summary;

end Test_XPM_Color_Names;
