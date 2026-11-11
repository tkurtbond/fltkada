


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 149, after pofltk's TestWidget:  full screen, a window's fixed
--  size, and iconify.  A window shown with no resizable widget gets a size
--  range of its own size (Fl_Window.cxx:797), and Fullscreen_On of it does
--  nothing (Fl_Window_fullscreen.cxx:39) until Set_Size_Range.
--  Fullscreen_Own_Screen gives back FLTK's -1, the window's own screen.
--  Iconify of a window not shown shows it; of a shown one, X11 needs a
--  window manager, so that check runs on Wayland only.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Window_Fullscreen is

    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 150, "Full");

    function Settled
           (Want : in Boolean)
        return Boolean is
    begin
        for N in 1 .. 100 loop
            exit when Window.Is_Fullscreen = Want;
            exit when FLTK.Wait (0.01) < 0.0;
        end loop;
        return Window.Is_Fullscreen = Want;
    end Settled;

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    Window.Fullscreen_On;
    Check (not Window.Is_Fullscreen, "Fullscreen_On of a window of fixed size does nothing");
    Window.Set_Size_Range (100, 100);
    Window.Fullscreen_Screens (0, 0, 0, 0);
    Window.Fullscreen_On;
    Check (Settled (True), "full screen, on screen 0's edges");
    Window.Fullscreen_Own_Screen;
    Check (Window.Is_Fullscreen, "Fullscreen_Own_Screen leaves it full screen");
    Window.Fullscreen_Off;
    Check (Settled (False), "and off");

    declare
        Other : Win.Window := Win.Forge.Create (0, 0, 100, 80, "Other");
        Ignore : Boolean;
    begin
        Other.Iconify;
        Ignore := FLTK.Check;
        Check (Other.Is_Shown, "Iconify of a window not shown shows it, minimized");
        Other.Hide;
    end;

    if Prb.On_Wayland then
        Window.Iconify;
        for N in 1 .. 200 loop
            exit when not Window.Is_Visible;
            exit when FLTK.Wait (0.01) < 0.0;
        end loop;
        Check (not Window.Is_Visible, "Iconify hides a shown window");
    else
        Skip ("Iconify hides a shown window: X11 needs a window manager");
    end if;

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Window_Fullscreen;
