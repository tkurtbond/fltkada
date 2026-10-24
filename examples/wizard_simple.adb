

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/wizard-simple.cxx: a three page Fl_Wizard
--  with Next/Back/Finish buttons.


with

    FLTK.Widgets,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Wizards,
    FLTK.Widgets.Inputs.Text.Outputs.Multiline;


function Wizard_Simple
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package MLO renames FLTK.Widgets.Inputs.Text.Outputs.Multiline;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Wiz renames FLTK.Widgets.Groups.Wizards;


    G_Win : Win.Window := Win.Forge.Create (400, 300, "Example Wizard");

    G_Wiz : Wiz.Wizard := Wiz.Forge.Create (G_Win, 0, 0, 400, 300);


    procedure Back_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        G_Wiz.Prev;
    end Back_CB;


    procedure Next_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        G_Wiz.Next;
    end Next_CB;


    procedure Done_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Item.Nearest_Window.Hide;
    end Done_CB;


    --  First page
    G1     : Grp.Group := Grp.Forge.Create (G_Wiz, 0, 0, 400, 300);
    Next_1 : Btn.Button := Btn.Forge.Create (G1, 290, 265, 100, 25, "Next @->");
    Out_1  : MLO.Multiline_Output :=
        MLO.Forge.Create (G1, 10, 30, 400 - 20, 300 - 80, "Welcome");

    --  Second page
    G2     : Grp.Group := Grp.Forge.Create (G_Wiz, 0, 0, 400, 300);
    Next_2 : Btn.Button := Btn.Forge.Create (G2, 290, 265, 100, 25, "Next @->");
    Back_2 : Btn.Button := Btn.Forge.Create (G2, 180, 265, 100, 25, "@<- Back");
    Out_2  : MLO.Multiline_Output :=
        MLO.Forge.Create (G2, 10, 30, 400 - 20, 300 - 80, "Terms And Conditions");

    --  Last page
    G3     : Grp.Group := Grp.Forge.Create (G_Wiz, 0, 0, 400, 300);
    Done_3 : Btn.Button := Btn.Forge.Create (G3, 290, 265, 100, 25, "Finish");
    Back_3 : Btn.Button := Btn.Forge.Create (G3, 180, 265, 100, 25, "@<- Back");
    Out_3  : MLO.Multiline_Output :=
        MLO.Forge.Create (G3, 10, 30, 400 - 20, 300 - 80, "Finish");


    procedure Setup
           (Output : in out MLO.Multiline_Output;
            Text   : in     String) is
    begin
        Output.Set_Label_Size (20);
        Output.Set_Alignment (FLTK.Align_Top_Left);
        Output.Set_Value (Text);
    end Setup;


begin


    Next_1.Set_Callback (Next_CB'Unrestricted_Access);
    Setup (Out_1, "This is First page");

    Next_2.Set_Callback (Next_CB'Unrestricted_Access);
    Back_2.Set_Callback (Back_CB'Unrestricted_Access);
    Setup (Out_2, "This is the Second page");

    Done_3.Set_Callback (Done_CB'Unrestricted_Access);
    Back_3.Set_Callback (Back_CB'Unrestricted_Access);
    Setup (Out_3, "This is the Last page");

    G_Win.Show_With_Args;

    return FLTK.Run;


end Wizard_Simple;
