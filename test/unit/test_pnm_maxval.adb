--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 45: Fl_PNM_Image reads the samples of a binary
--  PNM (P5, P6) whose maxval is under 255 as they are, where it scales the
--  text forms to 0 .. 255.  rb.ppm is pofltk's: a P6 of red and blue with
--  maxval 1.  levels.pgm is a P5 with maxval 3 and one sample, 5, over it.
--  text.ppm is a P3 with maxval 3, which FLTK scales already and which
--  must not be scaled twice.  A shared image goes through FLTK's handlers,
--  not Fl_PNM_Image's constructor alone, so it is checked as well.


with

    Ada.Exceptions,
    Ada.Strings.Unbounded,
    Checks,
    FLTK.Images.RGB.PNM,
    FLTK.Images.Shared,
    FLTK.Probe,
    FLTK.Widgets.Boxes;

use

    Checks,
    FLTK;


procedure Test_PNM_Maxval is

    package PNM renames FLTK.Images.RGB.PNM;
    package Shr renames FLTK.Images.Shared;
    package Prb renames FLTK.Probe;
    package Bxs renames FLTK.Widgets.Boxes;

    Dir : constant String := "../images/";

    function Image_Of
           (Name : in String)
        return String
    is
        Pic  : constant PNM.PNM_Image := PNM.Forge.Create (Dir & Name);
        Data : constant Color_Component_Array := Pic.All_Data;
        Text : Ada.Strings.Unbounded.Unbounded_String;
    begin
        for Sample of Data loop
            Ada.Strings.Unbounded.Append (Text, Color_Component'Image (Sample));
        end loop;
        return Ada.Strings.Unbounded.To_String (Text);
    end Image_Of;

    procedure Expect
           (Name, Want : in String)
    is
        Got : constant String := Image_Of (Name);
    begin
        Check (Got = Want, Name & " reads as" & Got & ", not" & Want);
    end Expect;

begin

    Expect ("rb.ppm", " 255 0 0 255 0 0 0 0 255 0 0 255"
        & " 255 0 0 255 0 0 0 0 255 0 0 255");
    Expect ("levels.pgm", " 0 85 170 255 255");
    Expect ("text.ppm", " 85 170 255");

    --  Without Register_Images, a shared image has no handler for a PNM,
    --  as before.
    begin
        declare
            Pic : constant Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.ppm", 0, 0);
            pragma Unreferenced (Pic);
        begin
            Check (False, "a shared PNM loads without Register_Images");
        end;
    exception
    when FLTK.Images.No_Image_Error =>
        Check (True, "a shared PNM needs Register_Images");
    end;

    Shr.Register_Images;
    declare
        Pic  : Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.ppm", 0, 0);
        Item : Bxs.Box := Bxs.Forge.Create (No_Box, 0, 0, 4, 2);
    begin
        Item.Set_Image (Pic);
        Check (Prb.Capture (Item), "the shared image's box is captured");
        Check (Prb.Pixel (0, 0) = Prb.To_RGB (255, 0, 0)
            and Prb.Pixel (3, 1) = Prb.To_RGB (0, 0, 255),
            "a shared P6 with maxval 1 draws red and blue, not"
            & Prb.RGB'Image (Prb.Pixel (0, 0)) & " and"
            & Prb.RGB'Image (Prb.Pixel (3, 1)));
        Prb.Release;
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_PNM_Maxval;
