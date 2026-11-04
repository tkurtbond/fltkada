--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 133: an image drawn from the line function of
--  another.  On Xlib, fl_draw_image keeps its XImage and buffer in statics
--  (Fl_Xlib_Graphics_Driver_image.cxx, innards), so the inner image spoils
--  the outer one, and a larger one frees the buffer the outer one is
--  writing to.  The binding keeps the line function in a variable of the
--  package, so on any back end the inner Draw_Image's function replaced the
--  outer's.  Each of the four Draw_Images raises Draw_Error in a line
--  function, which the outer Draw_Image raises once FLTK returns.


with

    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Image_Reentry is

    package Prb renames FLTK.Probe;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    Image_W : constant := 40;
    Image_H : constant := 10;

    type Nesting is (None, Colour_Lines, Mono_Lines, Colour_Data, Mono_Data);

    Inner      : Nesting := None;
    Outer_Mono : Boolean := False;
    Lines      : Natural := 0;
    Inner_Ran  : Natural := 0;

    Small : constant Color_Component_Array (1 .. 20 * 20 * 3) := (others => 16#80#);

    procedure Inner_Line
           (X, Y : in     Natural;
            Data :    out Color_Component_Array)
    is
        pragma Unreferenced (X, Y);
    begin
        Inner_Ran := Inner_Ran + 1;
        Data := (others => 0);
    end Inner_Line;

    procedure Outer_Line
           (X, Y : in     Natural;
            Data :    out Color_Component_Array)
    is
        pragma Unreferenced (X);
    begin
        Lines := Lines + 1;
        --  Red for colour, dark grey for mono.
        for I in Data'Range loop
            Data (I) := (if Outer_Mono then 16#40#
                         elsif (I - Data'First) mod 3 = 0 then 16#FF# else 0);
        end loop;
        if Y = 0 then
            case Inner is
                when None => null;
                when Colour_Lines =>
                    FLTK.Draw.Draw_Image (0, 0, 20, 20, Inner_Line'Unrestricted_Access, 3);
                when Mono_Lines =>
                    FLTK.Draw.Draw_Image_Mono (0, 0, 20, 20, Inner_Line'Unrestricted_Access, 1);
                when Colour_Data =>
                    FLTK.Draw.Draw_Image (0, 0, 20, 20, Small, 3);
                when Mono_Data =>
                    FLTK.Draw.Draw_Image_Mono (0, 0, 20, 20, Small, 1);
            end case;
        end if;
    end Outer_Line;


    Raised : Boolean := False;

    type Line_Box is new Bx.Box with null record;

    overriding procedure Draw
           (This : in out Line_Box);

    overriding procedure Draw
           (This : in out Line_Box) is
    begin
        if Outer_Mono then
            FLTK.Draw.Draw_Image_Mono
               (This.Get_X, This.Get_Y, Image_W, Image_H, Outer_Line'Unrestricted_Access, 1);
        else
            FLTK.Draw.Draw_Image
               (This.Get_X, This.Get_Y, Image_W, Image_H, Outer_Line'Unrestricted_Access, 3);
        end if;
    exception
    when FLTK.Draw.Draw_Error =>
        Raised := True;
    end Draw;


    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Image_Reentry");

    The_Box : constant Line_Box :=
       (Bx.Forge.Create (Window, Flat_Box, 10, 10, Image_W, Image_H) with null record);

    procedure Try
           (Mono  : in Boolean;
            Which : in Nesting;
            What  : in String) is
    begin
        Outer_Mono := Mono;
        Inner := Which;
        Lines := 0;
        Inner_Ran := 0;
        Raised := False;
        if not Prb.Capture (The_Box) then
            Check (False, What & ": the capture is the box's size");
            return;
        end if;
        if Which = None then
            Check (not Raised, What & ": nothing raised");
            Check (Lines = Image_H, What & ": one call a line:" & Natural'Image (Lines));
            Check (Prb.Pixel (Image_W - 1, Image_H - 1) =
                   (if Mono then Prb.To_RGB (16#40#, 16#40#, 16#40#) else Prb.To_RGB (255, 0, 0)),
                What & ": the image is drawn");
        else
            Check (Raised, What & " raises Draw_Error");
            Check (Inner_Ran = 0, What & ": the inner line function never ran:"
                & Natural'Image (Inner_Ran));
            Check (Lines = 1, What & ": the outer line function stops after it:"
                & Natural'Image (Lines));
        end if;
        Prb.Release;
    end Try;

begin

    for Mono in Boolean loop
        declare
            Outer : constant String := (if Mono then "in a mono line, " else "in a colour line, ");
        begin
            Try (Mono, None, Outer & "no nesting");
            Try (Mono, Colour_Lines, Outer & "Draw_Image with lines");
            Try (Mono, Mono_Lines, Outer & "Draw_Image_Mono with lines");
            Try (Mono, Colour_Data, Outer & "Draw_Image with data");
            Try (Mono, Mono_Data, Outer & "Draw_Image_Mono with data");
            Try (Mono, None, Outer & "no nesting after them");
        end;
    end loop;

    Summary;

end Test_Image_Reentry;
