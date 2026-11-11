--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 19:  a tooltip shown just after its window's Show,
--  before the window is on the screen, ends the program under Wayland as
--  a menu does (pofltk 28): "Fatal error no 1 in Wayland protocol:
--  xdg_surface".  Enter_Area here comes straight after Show, with no delay.


with

    Checks,
    FLTK.Tooltips,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Tooltip_Early is

    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Tooltip_Early");
    Item   : constant FLTK.Widgets.Boxes.Box :=
        FLTK.Widgets.Boxes.Forge.Create (Window, 10, 10, 80, 40, "Tip");

    Ignore : Long_Float;

begin

    FLTK.Tooltips.Set_Enabled (True);
    FLTK.Tooltips.Set_Delay (0.0);

    Window.Show;
    FLTK.Tooltips.Enter_Area (Item, 0, 0, 40, 40, "tip");
    for N in 1 .. 20 loop
        Ignore := FLTK.Wait (0.02);
    end loop;
    Check (Window.Is_Shown, "a tooltip straight after Show, and the program goes on");

    FLTK.Tooltips.Enter_Area (Item, 0, 0, 0, 0, "");
    Window.Hide;
    Summary;

end Test_Tooltip_Early;
