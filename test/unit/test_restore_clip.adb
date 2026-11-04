

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  PLAN.md, Phase 6, pofltk 128.  Cairo's restore_clip resets Cairo's
--  clip and applies only the region stack, not a clip pushed with
--  push_clip, which Cairo holds in its own saved state
--  (Fl_Cairo_Graphics_Driver.cxx:583-594, 1456-1485).  So after
--  Restore_Clip, drawing goes outside the pushed clip until Pop_Clip.
--  FLTKAda documents this rather than working around it; this test
--  checks what the spec says, so that if FLTK changes, it fails.


with

    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Restore_Clip is

    package Drw renames FLTK.Draw;
    package Prb renames FLTK.Probe;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Mode_Kind is (Pushed, Restored, Popped);

    type Clip_Box is new Bx.Box with record
        Mode : Mode_Kind := Pushed;
    end record;

    overriding procedure Draw
           (This : in out Clip_Box);

    --  Fills the box white, then, clipped to its top left 20 by 20, fills
    --  it all red.  Restored calls Restore_Clip before the red fill;
    --  Popped calls it and then pops and pushes the clip again.
    overriding procedure Draw
           (This : in out Clip_Box)
    is
        X : constant Integer := This.Get_X;
        Y : constant Integer := This.Get_Y;
    begin
        Drw.Set_Color (White_Color);
        Drw.Rect_Fill (X, Y, This.Get_W, This.Get_H);
        Drw.Push_Clip (X, Y, 20, 20);
        if This.Mode /= Pushed then
            Drw.Restore_Clip;
        end if;
        if This.Mode = Popped then
            Drw.Pop_Clip;
            Drw.Push_Clip (X, Y, 20, 20);
        end if;
        Drw.Set_Color (Red_Color);
        Drw.Rect_Fill (X, Y, This.Get_W, This.Get_H);
        Drw.Pop_Clip;
    end Draw;

    Window : Win.Window := Win.Forge.Create (0, 0, 100, 100, "Test_Restore_Clip");

    The_Box : Clip_Box :=
       (Bx.Forge.Create (Window, Flat_Box, 0, 0, 60, 60) with others => <>);

    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);

    procedure Try
           (Mode         : in Mode_Kind;
            Outside_Want : in Prb.RGB;
            What         : in String) is
    begin
        The_Box.Mode := Mode;
        if Prb.Capture (The_Box) then
            Check (Prb.Pixel (10, 10) = Red,
                Mode_Kind'Image (Mode) & ": inside the clip is red");
            Check (Prb.Pixel (40, 40) = Outside_Want,
                Mode_Kind'Image (Mode) & ": outside the clip is " & What & ":"
                & Prb.RGB'Image (Prb.Pixel (40, 40)));
            Prb.Release;
        else
            Check (False, Mode_Kind'Image (Mode) & ": the capture is the box's size");
        end if;
    end Try;

begin

    Try (Pushed, White, "white");
    Try (Popped, White, "white, once the clip is pushed again");
    if Prb.Uses_Cairo or else Prb.On_Wayland then
        Try (Restored, Red, "red, as Cairo's restore_clip drops the pushed clip");
    else
        Skip ("Restore_Clip after Push_Clip, which drops the clip only on Cairo");
    end if;

    Summary;

end Test_Restore_Clip;
