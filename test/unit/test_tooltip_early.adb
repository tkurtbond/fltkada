--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 19:  a tooltip shown just after its window's Show,
--  before the window is on the screen, ends the program under Wayland as
--  a menu does (pofltk 28): "Fatal error no 1 in Wayland protocol:
--  xdg_surface".  Enter_Area here comes straight after Show, with no delay.
--
--  Phase 20, from pofltk's TestTooltips:  FLTK shows no tip in a window not
--  shown (Fl_Tooltip.cxx's top_win_iconified_), and an empty text hides
--  the tip.


with

    Checks,
    FLTK.Probe,
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

    FLTK.Tooltips.Enter_Area (Item, 0, 0, 40, 40, "not shown");
    Ignore := FLTK.Wait (0.02);
    Check (FLTK.Probe.Shown_Windows = 0, "no tip in a window not shown");

    Window.Show;
    FLTK.Tooltips.Enter_Area (Item, 0, 0, 40, 40, "tip");
    for N in 1 .. 20 loop
        Ignore := FLTK.Wait (0.02);
    end loop;
    Check (Window.Is_Shown, "a tooltip straight after Show, and the program goes on");
    Check (FLTK.Probe.Shown_Windows = 2, "the tip is shown:"
        & Natural'Image (FLTK.Probe.Shown_Windows));

    FLTK.Tooltips.Enter_Area (Item, 0, 0, 0, 0, "");
    Ignore := FLTK.Wait (0.02);
    Check (FLTK.Probe.Shown_Windows = 1, "an empty text hides it:"
        & Natural'Image (FLTK.Probe.Shown_Windows));
    Window.Hide;
    Summary;

end Test_Tooltip_Early;
