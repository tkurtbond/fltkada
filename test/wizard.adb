--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/wizard.cxx: three panels in a wizard, with buttons that
--  go round them both ways.


with

    FLTK.Widgets.Buttons,
    System,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Wizards;

use type

    FLTK.Alignment;


function Wizard
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Wiz renames FLTK.Widgets.Groups.Wizards;

    use type System.Address;

    Window : Win.Window := Win.Forge.Create (300, 165, "Fl_Wizard test");

    The_Wizard : Wiz.Wizard := Wiz.Forge.Create (Window, 5, 5, 290, 100);

    P1 : Grp.Group := Grp.Forge.Create (The_Wizard, 5, 5, 290, 100, "Panel 1");
    P2 : Grp.Group := Grp.Forge.Create (The_Wizard, 5, 5, 290, 100, "Panel 2");
    P3 : Grp.Group := Grp.Forge.Create (The_Wizard, 5, 5, 290, 100, "Panel 3");

    Buttons : Grp.Group := Grp.Forge.Create (Window, 5, 110, 290, 50);

    Prev_Button : Btn.Button := Btn.Forge.Create (Buttons,  15, 120, 110, 30, "@< Prev Panel");
    Next_Button : Btn.Button := Btn.Forge.Create (Buttons, 175, 120, 110, 30, "Next Panel @>");

    --  FLTK's Panel.
    procedure Set_Up
           (Panel : in out Grp.Group;
            Color : in     FLTK.Color) is
    begin
        Panel.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center);
        Panel.Set_Box (FLTK.Engraved_Box);
        Panel.Set_Label_Color (Color);
        Panel.Set_Label_Size (20);
    end Set_Up;

    procedure Next_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if The_Wizard.Get_Visible.all'Address = P3'Address then
            The_Wizard.Set_Visible (P1);
        else
            The_Wizard.Next;
        end if;
    end Next_Callback;

    procedure Prev_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if The_Wizard.Get_Visible.all'Address = P1'Address then
            The_Wizard.Set_Visible (P3);
        else
            The_Wizard.Prev;
        end if;
    end Prev_Callback;

begin

    Set_Up (P1, FLTK.Red_Color);
    Set_Up (P2, FLTK.Magenta_Color);
    Set_Up (P3, FLTK.Blue_Color);
    The_Wizard.Set_Visible (P1);

    Buttons.Set_Box (FLTK.Engraved_Box);
    Prev_Button.Set_Callback (Prev_Callback'Unrestricted_Access);
    Prev_Button.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center + FLTK.Align_Left);
    Next_Button.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center + FLTK.Align_Right);
    Next_Button.Set_Callback (Next_Callback'Unrestricted_Access);

    Window.Show_With_Args;

    return FLTK.Run;

end Wizard;
