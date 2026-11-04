

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 64: Fl_Anim_GIF_Image::copy starts the copy
--  whenever the original has a frame (Fl_Anim_GIF_Image.cxx:764-765),
--  which a stopped animation also has.  The test copies animations
--  stopped and playing, both ways, and checks the copy plays only when
--  the original does, on the original's frame when stopped.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.Pixmaps.GIF.Animated;

use

    Checks;


procedure Test_Anim_Copy is

    package Anm renames FLTK.Images.Pixmaps.GIF.Animated;

    File : constant String := "../images/anim.gif";

    Original : Anm.Animated_GIF_Image := Anm.Forge.Create (File, Anm.Flag_Dont_Start);

    procedure Copies
           (Playing : in Boolean;
            Name    : in String) is
    begin
        declare
            Sized : constant Anm.Animated_GIF_Image'Class := Original.Copy (20, 20);
            Whole : constant Anm.Animated_GIF_Image'Class := Original.Copy;
        begin
            Check (Sized.Is_Playing = Playing, Name & ": a sized copy plays as it does");
            Check (Whole.Is_Playing = Playing, Name & ": a whole copy plays as it does");
            if not Playing then
                Check (Sized.Get_Frame = Original.Get_Frame,
                    Name & ": a sized copy is on its frame");
                Check (Whole.Get_Frame = Original.Get_Frame,
                    Name & ": a whole copy is on its frame");
            end if;
        end;
    end Copies;

begin

    Check (Original.Is_Loaded and Original.Frames > 1, "the animation loads");
    Check (not Original.Is_Playing, "an animation made with Dont_Start is stopped");
    Copies (False, "never started");

    Original.Start;
    Check (Original.Is_Playing, "the animation plays once started");
    Copies (True, "playing");

    Original.Next;
    Original.Stop;
    Copies (False, "stopped");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Anim_Copy;
