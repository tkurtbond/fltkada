--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 91: Establish_Overlay and Use_Layer (Overlay_Layer)
--  raised Program_Error for a GLUT window not shown, on the claim that
--  make_overlay_current crashes on one.  It doesn't: on X11 and Wayland it
--  is glDrawBuffer (GL_FRONT) (Fl_X11_Gl_Window_Driver.cxx:230,
--  Fl_Wayland_Gl_Window_Driver.cxx:255), and FLTK's test/glut_test.cxx
--  calls glutEstablishOverlay right after glutHideWindow.  A C++ program
--  calling both on a hidden window and on one never shown ran clean on
--  Xvfb and sway, with no errors under valgrind.


with

    Ada.Exceptions,
    Checks,
    FLTK.GLUT;

use

    Checks,
    FLTK;

use type

    FLTK.GLUT.Window_Number;


procedure Test_GLUT_Overlay is

    package Glt renames FLTK.GLUT;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    procedure Overlay_Calls
           (What : in String) is
    begin
        Glt.Establish_Overlay;
        Glt.Use_Layer (Glt.Overlay_Layer);
        Glt.Use_Layer (Glt.Normal_Layer);
        Glt.Post_Overlay_Redisplay;
        Glt.Show_Overlay;
        Glt.Hide_Overlay;
        Glt.Remove_Overlay;
        Check (True, "the overlay calls on " & What);
    exception
    when Occurrence : others =>
        Check (False, "the overlay calls on " & What & ": "
            & Ada.Exceptions.Exception_Information (Occurrence));
    end Overlay_Calls;

    Window : Glt.Window_Number;

begin

    Glt.Init;
    Window := Glt.Create_Window ("Test_GLUT_Overlay");
    Pump (10);
    Overlay_Calls ("a shown window");

    Glt.Hide_Window;
    Pump (10);
    Check (Glt.Get_Window = Window, "the hidden window is still current");
    Overlay_Calls ("a hidden window");

    Glt.Show_Window;
    Pump (10);
    Overlay_Calls ("the window shown again");

    Glt.Destroy_Window (Window);
    Pump (5);
    Check (Glt.Get_Window = Glt.No_Window, "no window is current");
    Overlay_Calls ("no current window");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GLUT_Overlay;
