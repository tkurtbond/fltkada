


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 110:  the shim guarded some calls with
--  "#if FLTK_ABI_VERSION >= ...", a macro FLTK 1.4 doesn't define, so each
--  setter did nothing and each getter gave 0 or garbage.  This checks that
--  each setter is now seen by its getter, and that a scroll's scrollbars
--  are worked out.  Fl_Sys_Menu_Bar::update, guarded too, has no effect
--  that can be seen off macOS, so it isn't checked here.


with

    Ada.Exceptions,
    Checks,
    FLTK.Static,
    FLTK.Tooltips,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Groups.Scrolls.Region,
    FLTK.Widgets.Groups.Tables.Tab_Navigation,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors.Tab_Navigation;


procedure Test_ABI_Guards is

    package Box renames FLTK.Widgets.Boxes;
    package Scr renames FLTK.Widgets.Groups.Scrolls;
    package Tab renames FLTK.Widgets.Groups.Tables;
    package TE  renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package Tip renames FLTK.Tooltips;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "Test_ABI_Guards");
    Editor : TE.Text_Editor := TE.Forge.Create (Window, 0, 0, 200, 100);
    Table  : Tab.Table := Tab.Forge.Create (Window, 200, 0, 200, 100);
    Scroll : Scr.Scroll := Scr.Forge.Create (Window, 0, 100, 100, 100);
    Wide   : constant Box.Box := Box.Forge.Create (Scroll, 0, 100, 300, 50);

    Info : Scr.Scroll_Info;

begin

    Check (Editor.Get_Tab_Mode = TE.Insert_Char, "an editor types Tab to start with");
    Editor.Set_Tab_Mode (TE.Widget_Focus);
    Check (Editor.Get_Tab_Mode = TE.Widget_Focus, "Text_Editor.Set_Tab_Mode");
    Editor.Set_Tab_Mode (TE.Insert_Char);
    Check (Editor.Get_Tab_Mode = TE.Insert_Char, "and back");

    Check (Table.Get_Tab_Mode = Tab.Widget_Focus, "a table moves the focus on Tab to start with");
    Table.Set_Tab_Mode (Tab.Navigate_Cells);
    Check (Table.Get_Tab_Mode = Tab.Navigate_Cells, "Table.Set_Tab_Mode");
    Check (Table.Get_Scrollbar_Size = 0, "a table uses Fl's scrollbar size to start with");
    Table.Set_Scrollbar_Size (25);
    Check (Table.Get_Scrollbar_Size = 25, "Table.Set_Scrollbar_Size");

    Tip.Set_Margin_Height (7);
    Tip.Set_Margin_Width (9);
    Tip.Set_Wrap_Width (123);
    Check (Tip.Get_Margin_Height = 7 and Tip.Get_Margin_Width = 9 and Tip.Get_Wrap_Width = 123,
        "Tooltips.Set_Margin_Height, Set_Margin_Width, Set_Wrap_Width");

    Scroll.Recalculate_Scrollbars (Info);
    Check (Info.H_Needed and not Info.V_Needed
            and Info.Scroll_Size = FLTK.Static.Get_Default_Scrollbar_Size
            and Info.H_Data.Total = Wide.Get_W
            and Info.Child_Box = (0, 100, 300, 50),
        "Scroll.Recalculate_Scrollbars");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_ABI_Guards;



