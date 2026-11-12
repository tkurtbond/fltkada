--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda bug 132: a browser's kind, FLTK's type () of FL_NORMAL_BROWSER,
--  FL_SELECT_BROWSER, FL_HOLD_BROWSER or FL_MULTI_BROWSER, could be set
--  only by choosing which type to create.  FLTK's test/browser changes it
--  on a running browser.  Only a multi browser keeps more than one line
--  selected (Fl_Browser_.cxx, select).


with

    Checks,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Browsers.Textline.Multi,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK.Widgets.Groups.Browsers;


procedure Test_Browser_Kind is

    package Txt renames FLTK.Widgets.Groups.Browsers.Textline;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (300, 300, "Browser kind");
    Plain  : Txt.Textline_Browser := Txt.Forge.Create (Window, 0, 0, 100, 300);
    Hold   : constant Txt.Hold.Hold_Browser := Txt.Hold.Forge.Create (Window, 100, 0, 100, 300);
    Multi  : constant Txt.Multi.Multi_Browser := Txt.Multi.Forge.Create (Window, 200, 0, 100, 300);

begin

    Window.End_Current;
    Check (Plain.Get_Kind = Normal_Kind, "a Textline_Browser is Normal_Kind");
    Check (Hold.Get_Kind = Hold_Kind, "a Hold_Browser is Hold_Kind");
    Check (Multi.Get_Kind = Multi_Kind, "a Multi_Browser is Multi_Kind");

    for Line in 1 .. 3 loop
        Plain.Add ("line" & Line'Image);
    end loop;

    Plain.Set_Select (Line => 1);
    Plain.Set_Select (Line => 2);
    Check (not Plain.Is_Selected (1) and Plain.Is_Selected (2),
        "a normal browser keeps one line selected");

    Plain.Set_Kind (Multi_Kind);
    Check (Plain.Get_Kind = Multi_Kind, "Set_Kind makes it Multi_Kind");
    Plain.Set_Select (Line => 3);
    Check (Plain.Is_Selected (2) and Plain.Is_Selected (3),
        "and then it keeps more than one line selected");

    Plain.Set_Kind (Select_Kind);
    Check (Plain.Get_Kind = Select_Kind, "Set_Kind makes it Select_Kind");

    Summary;

end Test_Browser_Kind;
