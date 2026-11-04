


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 62: Fl_Anim_GIF_Image keeps its canvas
--  widget's pointer, and while it plays its timer sets the next frame and
--  redraws the canvas (Fl_Anim_GIF_Image.cxx:1195-1205).  Nothing tells it
--  the canvas is gone, so a canvas finalized first is used from freed
--  memory.  The test finalizes a playing animation's canvas and runs the
--  timer on, and finalizes animations whose timers are pending, with
--  their canvases cleared and not.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Anim_Canvas is

    package Anm renames FLTK.Images.Pixmaps.GIF.Animated;
    package Bxs renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Box_Access is access Bxs.Box;
    procedure Free is new Ada.Unchecked_Deallocation (Bxs.Box, Box_Access);

    File : constant String := "../images/anim.gif";

    Ignore_Done : Boolean;

    procedure Pump
           (Seconds : in Duration) is
    begin
        for N in 1 .. Integer (Seconds / 0.02) loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Anim_Canvas");

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    --  pofltk 62: the canvas goes while the animation plays.
    declare
        Canvas : Box_Access := new Bxs.Box'(Bxs.Forge.Create (Window, 10, 10, 100, 100));
        Anim   : Anm.Animated_GIF_Image := Anm.Forge.Create (File, Canvas.all);
        Before : Natural;
    begin
        Check (Anim.Frames > 1, "the animation has frames:" & Integer'Image (Anim.Frames));
        Anim.Start;
        Pump (0.5);
        Check (Anim.Is_Playing, "the animation plays");
        Free (Canvas);
        Check (Anim.Get_Canvas = null, "a finalized canvas is no longer the animation's");
        Before := Anim.Get_Frame;
        Pump (1.0);
        Check (Anim.Is_Playing and then Anim.Get_Frame /= Before,
            "the animation plays on without its canvas:" & Integer'Image (Before)
            & Integer'Image (Anim.Get_Frame));
    end;
    Pump (0.3);

    --  The animation goes first, its timer pending.
    declare
        Canvas : Bxs.Box := Bxs.Forge.Create (Window, 10, 10, 100, 100);
    begin
        declare
            Anim : Anm.Animated_GIF_Image := Anm.Forge.Create (File, Canvas);
        begin
            Anim.Start;
            Pump (0.3);
            Anim.Clear_Canvas;
        end;
        Pump (0.5);
        Check (Canvas.Get_Image = null, "a canvas cleared shows no image");
    end;

    --  The animation goes while its canvas shows it.
    declare
        Canvas : Bxs.Box := Bxs.Forge.Create (Window, 10, 10, 100, 100);
    begin
        declare
            Anim : Anm.Animated_GIF_Image := Anm.Forge.Create (File, Canvas);
        begin
            Anim.Start;
            Pump (0.3);
            Check (Canvas.Get_Image /= null, "a canvas shows its animation");
        end;
        Canvas.Redraw;
        Pump (0.3);
        Check (Canvas.Get_Image = null, "a canvas whose animation went shows no image");
    end;

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Anim_Canvas;


