--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 113: Fl_Gl_Window::init calls end() (Fl_Gl_Window.cxx:343), so
--  unlike another window a GL window is not left the current group.  In
--  FLTKAda that makes no difference: every group's Forge ends the group
--  (Extra_Init in fltk-widgets-groups.adb), so after either kind of window
--  is made inside Outer.Begin_Current, Outer is current again.  And under
--  Wayland, whose EGL
--  draws double-buffered alone, FLTK adds Double to every mode
--  (Fl_Wayland_Gl_Window_Driver.cxx:37, 113, 301).


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Windows.OpenGL;

use

    Checks;


procedure Test_GL_Window_Group is

    package Box renames FLTK.Widgets.Boxes;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;
    package GL renames FLTK.Widgets.Groups.Windows.OpenGL;

    Wayland : constant Boolean := Prb.On_Wayland;

begin

    declare
        Outer : Win.Window := Win.Forge.Create (200, 100, "outer");
    begin
        Outer.Begin_Current;
        declare
            Inner : constant Win.Window := Win.Forge.Create (Outer, 0, 0, 50, 50);
            After : Box.Box := Box.Forge.Create (0, 0, 9, 9);
        begin
            Check (Inner.Number_Of_Children = 0 and Outer.Number_Of_Children = 2,
                "a widget made after a window goes into its parent:" &
                Natural'Image (Inner.Number_Of_Children) &
                Natural'Image (Outer.Number_Of_Children));
            Outer.End_Current;
            Outer.Remove (After);
        end;
    end;

    declare
        Outer : Win.Window := Win.Forge.Create (200, 100, "outer");
    begin
        Outer.Begin_Current;
        declare
            Inner : GL.GL_Window := GL.Forge.Create (Outer, 0, 0, 50, 50);
            After : Box.Box := Box.Forge.Create (0, 0, 9, 9);
        begin
            Check (Inner.Number_Of_Children = 0 and Outer.Number_Of_Children = 2,
                "a widget made after a GL window goes into its parent:" &
                Natural'Image (Inner.Number_Of_Children) &
                Natural'Image (Outer.Number_Of_Children));
            Outer.End_Current;
            Outer.Remove (After);

            Inner.Set_Mode ((others => False));
            Check (Inner.Get_Mode.Double = Wayland,
                "a single-buffered mode reads back Double only on Wayland: " &
                Boolean'Image (Inner.Get_Mode.Double));
        end;
    end;

    Summary;

end Test_GL_Window_Group;
