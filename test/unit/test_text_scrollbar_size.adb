--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 139: a Text_Display had no scrollbar size of its own.
--  Set_Scrollbar_Width is FLTK's deprecated scrollbar_width, which sets
--  the global size for every widget.  Set_Scrollbar_Size sets the
--  display's own, as Fl_Text_Display::scrollbar_size does.


with

    Ada.Exceptions,
    Checks,
    FLTK.Static,
    FLTK.Widgets.Groups.Text_Displays;

use

    Checks;


procedure Test_Text_Scrollbar_Size is

    package Txt renames FLTK.Widgets.Groups.Text_Displays;

    One : Txt.Text_Display := Txt.Forge.Create (0, 0, 100, 100);
    Two : Txt.Text_Display := Txt.Forge.Create (0, 0, 100, 100);

    Global : constant Integer := FLTK.Static.Get_Default_Scrollbar_Size;

begin

    Check (One.Get_Scrollbar_Size = 0,
        "a new display uses the global size, " & Integer'Image (One.Get_Scrollbar_Size));

    One.Set_Scrollbar_Size (31);
    Check (One.Get_Scrollbar_Size = 31,
        "Set_Scrollbar_Size sets the display's own, "
        & Integer'Image (One.Get_Scrollbar_Size));
    Check (Two.Get_Scrollbar_Size = 0,
        "and not another's, " & Integer'Image (Two.Get_Scrollbar_Size));
    Check (FLTK.Static.Get_Default_Scrollbar_Size = Global,
        "nor the global one, " & Integer'Image (FLTK.Static.Get_Default_Scrollbar_Size));

    Two.Set_Scrollbar_Width (23);
    Check (FLTK.Static.Get_Default_Scrollbar_Size = 23,
        "Set_Scrollbar_Width sets the global size, as FLTK's scrollbar_width does, "
        & Integer'Image (FLTK.Static.Get_Default_Scrollbar_Size));
    Check (One.Get_Scrollbar_Size = 31,
        "and leaves a display's own, " & Integer'Image (One.Get_Scrollbar_Size));

    FLTK.Static.Set_Default_Scrollbar_Size (Global);

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Text_Scrollbar_Size;
