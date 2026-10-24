

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/tabs-simple.cxx: an Fl_Tabs holding two
--  groups of colored buttons.


with

    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Groups.Windows;


function Tabs_Simple
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Tab renames FLTK.Widgets.Groups.Tabbed;
    package Win renames FLTK.Widgets.Groups.Windows;


begin


    FLTK.Static.Set_Scheme ("gtk+");

    declare
        The_Window : Win.Window := Win.Forge.Create (500, 200, "Tabs Example");

        Tabs : Tab.Tabbed_Group := Tab.Forge.Create (The_Window, 10, 10, 500 - 20, 200 - 20);

        --  Aaa tab
        Aaa : Grp.Group := Grp.Forge.Create (Tabs, 10, 35, 500 - 20, 200 - 45, "Aaa");
        A1  : Btn.Button := Btn.Forge.Create (Aaa, 50,  60, 90, 25, "Button A1");
        A2  : Btn.Button := Btn.Forge.Create (Aaa, 50,  90, 90, 25, "Button A2");
        A3  : Btn.Button := Btn.Forge.Create (Aaa, 50, 120, 90, 25, "Button A3");

        --  Bbb tab
        Bbb : Grp.Group := Grp.Forge.Create (Tabs, 10, 35, 500 - 10, 200 - 35, "Bbb");
        B1  : Btn.Button := Btn.Forge.Create (Bbb,  50, 60, 90, 25, "Button B1");
        B2  : Btn.Button := Btn.Forge.Create (Bbb, 150, 60, 90, 25, "Button B2");
        B3  : Btn.Button := Btn.Forge.Create (Bbb, 250, 60, 90, 25, "Button B3");
        B4  : Btn.Button := Btn.Forge.Create (Bbb,  50, 90, 90, 25, "Button B4");
        B5  : Btn.Button := Btn.Forge.Create (Bbb, 150, 90, 90, 25, "Button B5");
        B6  : Btn.Button := Btn.Forge.Create (Bbb, 250, 90, 90, 25, "Button B6");
    begin
        A1.Set_Background_Color (FLTK.Color (88 + 1));
        A2.Set_Background_Color (FLTK.Color (88 + 2));
        A3.Set_Background_Color (FLTK.Color (88 + 3));

        B1.Set_Background_Color (FLTK.Color (88 + 1));
        B2.Set_Background_Color (FLTK.Color (88 + 3));
        B3.Set_Background_Color (FLTK.Color (88 + 5));
        B4.Set_Background_Color (FLTK.Color (88 + 2));
        B5.Set_Background_Color (FLTK.Color (88 + 4));
        B6.Set_Background_Color (FLTK.Color (88 + 6));

        The_Window.Show_With_Args;

        return FLTK.Run;
    end;


end Tabs_Simple;
