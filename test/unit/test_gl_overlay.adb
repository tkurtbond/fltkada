--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 90: GL_Window had Redraw_Overlay but no Draw_Overlay,
--  so a program couldn't draw the overlay that Redraw_Overlay asks for, as
--  FLTK's test/gl_overlay.cxx does.  FLTK calls draw_overlay when it
--  flushes a shown GL window after redraw_overlay, after draw, on X11 and
--  Wayland alike (Fl_Gl_Window.cxx:238, 275-285; Fl_Gl_Overlay.cxx:56).
--  Fl_Gl_Window::draw_overlay does nothing (Fl_Gl_Window.cxx:376), so a GL
--  window that doesn't override Draw_Overlay must still draw.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Groups.Windows.OpenGL;

use

    Checks,
    FLTK;


procedure Test_GL_Overlay is

    package GL renames FLTK.Widgets.Groups.Windows.OpenGL;

    type Overlay_GL is new GL.GL_Window with record
        Draws, Overlays    : Natural := 0;
        Overlay_After_Draw : Boolean := True;
    end record;

    overriding procedure Draw
           (This : in out Overlay_GL);

    overriding procedure Draw_Overlay
           (This : in out Overlay_GL);

    procedure Draw
           (This : in out Overlay_GL) is
    begin
        This.Draws := This.Draws + 1;
    end Draw;

    procedure Draw_Overlay
           (This : in out Overlay_GL) is
    begin
        if This.Draws = 0 then
            This.Overlay_After_Draw := False;
        end if;
        This.Overlays := This.Overlays + 1;
    end Draw_Overlay;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    procedure Show_Now
           (Window : in out GL.GL_Window'Class) is
    begin
        Window.Show;
        while not Window.Is_Shown loop
            exit when FLTK.Wait < 0;
        end loop;
        Pump (10);
    end Show_Now;

    Window : Overlay_GL :=
       (GL.Forge.Create (0, 0, 100, 100, "Test_GL_Overlay")
        with Draws => 0, Overlays => 0, Overlay_After_Draw => True);

    Plain : GL.GL_Window := GL.Forge.Create (120, 0, 100, 100, "plain");

begin

    Show_Now (Window);
    Check (Window.Draws > 0, "the GL window is drawn:" & Natural'Image (Window.Draws));
    Check (Window.Overlays = 0, "but not its overlay, before Redraw_Overlay:"
        & Natural'Image (Window.Overlays));

    Window.Redraw_Overlay;
    Pump (10);
    Check (Window.Overlays > 0, "Redraw_Overlay calls the override of Draw_Overlay:"
        & Natural'Image (Window.Overlays));
    Check (Window.Overlay_After_Draw, "after Draw");

    declare
        Before : constant Natural := Window.Overlays;
    begin
        Window.Redraw_Overlay;
        Pump (10);
        Check (Window.Overlays > Before, "and again on the next Redraw_Overlay:"
            & Natural'Image (Window.Overlays));
    end;

    --  FLTK's own draw_overlay does nothing, and so does GL_Window's.
    Show_Now (Plain);
    Plain.Redraw_Overlay;
    Pump (10);
    Check (True, "a GL window that doesn't override Draw_Overlay draws its overlay as nothing");

    Plain.Hide;
    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GL_Overlay;
