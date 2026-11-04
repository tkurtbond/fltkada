--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 93: Fl_Help_Dialog's constructor ends its window, which leaves
--  the current group as the window's parent, none, whatever it was before
--  (Fl_Help_Dialog.cxx:198).  So a widget made after a Help_Dialog went
--  into no group.  The shim puts the current group back.


with

    Checks,
    FLTK.Help_Dialogs,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double;

use

    Checks,
    FLTK;


procedure Test_Help_Dialog_Group is

    package Box renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Grp renames FLTK.Widgets.Groups;
    package Hlp renames FLTK.Help_Dialogs;

    Window : Dbl.Double_Window := Dbl.Forge.Create (200, 100, "Group");

begin

    Window.Begin_Current;
    declare
        Dialog : Hlp.Help_Dialog := Hlp.Forge.Create;
        pragma Unreferenced (Dialog);
        After  : Box.Box := Box.Forge.Create (10, 10, 50, 20, "after");
    begin
        Check (Grp.Get_Current /= null
                and then Grp.Get_Current.all in Dbl.Double_Window'Class,
            "the window is still the current group after a Help_Dialog");
        Check (Window.Number_Of_Children = 1,
            "a box made after the Help_Dialog is the window's child:"
            & Natural'Image (Window.Number_Of_Children));
        Window.End_Current;
        Window.Remove (After);
    end;

    Summary;

end Test_Help_Dialog_Group;
