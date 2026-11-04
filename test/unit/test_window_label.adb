

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, N7 and pofltk 6: Fl_Window::copy_label, which also
--  sets a shown window's title (Fl_Window.cxx:159-162), isn't virtual.
--  Widget's Set_Label (This, Kind, Text) called Set_Label without
--  dispatching, so a window got Fl_Widget::copy_label and kept its old
--  title.  The title is read from the X server, so this runs on X11 only.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Window_Label is

    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 100, 100, "Start");

    procedure Titled
           (Want, Message : in String)
    is
        Ignore : Boolean;
    begin
        Ignore := FLTK.Check;
        declare
            Title : constant String := Prb.X11_Title (Window);
        begin
            Check (Title = Want, Message & ": """ & Title & """");
        end;
    end Titled;

begin

    if Prb.On_Wayland then
        Skip ("a window's title is read from the X server");
        Summary;
        return;
    end if;

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    Titled ("Start", "a shown window has its title");
    Window.Set_Label ("Plain");
    Titled ("Plain", "Set_Label sets the title");
    Window.Set_Label (Normal_Label, "Kind");
    Titled ("Kind", "Set_Label with a kind sets the title");
    Check (Window.Get_Label = "Kind", "and the label");
    FLTK.Widgets.Widget'Class (Window).Set_Label (Normal_Label, "Class");
    Titled ("Class", "Set_Label with a kind on a Widget'Class sets the title");

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Window_Label;
