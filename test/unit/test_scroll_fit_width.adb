--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A scroll whose children fill its width (PLAN.md, Phase 30):  with
--  Set_Fit_Width, each child other than the scrollbars is made as wide as
--  reaches the right of the scroll's inside, inside the vertical scrollbar
--  when that shows, after every resize and before every draw.  After
--  pofltk's TestLayout.Mod.


with

    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Scroll_Fit_Width is

    package Prb renames FLTK.Probe;
    package Bxs renames FLTK.Widgets.Boxes;
    package Scr renames FLTK.Widgets.Groups.Scrolls;
    package Win renames FLTK.Widgets.Groups.Windows;

    function Placed
           (Item       : in FLTK.Widgets.Widget'Class;
            X, Y, W, H : in Integer)
        return Boolean is
    begin
        return Item.Get_X = X and Item.Get_Y = Y and Item.Get_W = W and Item.Get_H = H;
    end Placed;

    function Image
           (Item : in FLTK.Widgets.Widget'Class)
        return String is
    begin
        return Item.Get_X'Image & Item.Get_Y'Image & Item.Get_W'Image & Item.Get_H'Image;
    end Image;

    procedure Draw
           (Item : in FLTK.Widgets.Widget'Class)
    is
        Ignore : constant Boolean := Prb.Capture (Item);
    begin
        Prb.Release;
    end Draw;

    Window : Win.Window := Win.Forge.Create (0, 0, 600, 600, "Test_Scroll_Fit_Width");
    Scroll : Scr.Scroll := Scr.Forge.Create (Window, 300, 0, 100, 100);
    A      : Bxs.Box := Bxs.Forge.Create (Scroll, 300, 0, 50, 40);
    B      : Bxs.Box := Bxs.Forge.Create (Scroll, 310, 40, 30, 40);

    Bar : constant Integer := FLTK.Static.Get_Default_Scrollbar_Size;

begin

    Scroll.End_Current;
    Window.End_Current;

    Check (not Scroll.Is_Fitting_Width, "not fitting to start with");

    Scroll.Set_Fit_Width (True);
    Check (Scroll.Is_Fitting_Width, "Set_Fit_Width");
    Check (Placed (A, 300, 0, 100, 40) and Placed (B, 310, 40, 90, 40),
        "each child reaches the right edge:" & Image (A) & " /" & Image (B));

    declare
        C : Bxs.Box := Bxs.Forge.Create (Scroll, 300, 80, 20, 40);
    begin
        Draw (Scroll);
        Check (Placed (A, 300, 0, 100 - Bar, 40) and Placed (B, 310, 40, 90 - Bar, 40)
                and Placed (C, 300, 80, 100 - Bar, 40),
            "a child added, drawn: they reach the vertical scrollbar it brings:" &
            Image (A) & " /" & Image (C));

        Scroll.Resize (300, 0, 150, 100);
        Check (Placed (A, 300, 0, 150 - Bar, 40) and Placed (C, 300, 80, 150 - Bar, 40),
            "and follow a resize:" & Image (A) & " /" & Image (C));
    end;

    Draw (Scroll);
    Check (Placed (A, 300, 0, 150, 40) and Placed (B, 310, 40, 140, 40),
        "and the scrollbar's going:" & Image (A) & " /" & Image (B));

    Scroll.Set_Kind (Scr.Both_Always);
    Draw (Scroll);
    Check (Placed (A, 300, 0, 150 - Bar, 40), "and one always shown:" & Image (A));

    Scroll.Set_Fit_Width (False);
    Scroll.Set_Kind (Scr.Both);
    Scroll.Resize (300, 0, 100, 100);
    Draw (Scroll);
    Check (not Scroll.Is_Fitting_Width and Placed (A, 300, 0, 150 - Bar, 40),
        "Set_Fit_Width False leaves them alone:" & Image (A));

    Summary;

end Test_Scroll_Fit_Width;
