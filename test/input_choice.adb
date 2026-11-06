--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/input_choice.cxx: an Input_Choice beside a Choice, in a
--  group that a check button activates and deactivates, with a scheme
--  choice and a terminal that the callbacks print to.  The menus count
--  their items from 1, so Set_Item (1) and Set_Chosen (2) are the C++'s
--  value (0) and value (1).  The Choice callback prints FLTK's number,
--  counting from 0, so the terminal shows what the C++ shows.


with

    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Input_Choices,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices.Schemes;

use type

    FLTK.Widgets.Buttons.State;


function Input_Choice
    return Integer
is

    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Grp renames FLTK.Widgets.Groups;
    package Ich renames FLTK.Widgets.Groups.Input_Choices;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package Sch renames FLTK.Widgets.Menus.Choices.Schemes;

    Terminal_Height : constant := 150;

    Win : Dbl.Double_Window := Dbl.Forge.Create (300, 200 + Terminal_Height);

    TTY : Trm.Terminal := Trm.Forge.Create (Win, 0, 200, Win.Get_W, Terminal_Height);

    --  This group can be activated and deactivated.
    Active_Group : Grp.Group := Grp.Forge.Create (Win, 0, 0, 300, 120);

    --  All the choices are aligned, for easier visual comparison.
    Input  : Ich.Input_Choice := Ich.Forge.Create
        (Active_Group, 180, 40, 100, 25, "Fl_Input_Choice:");
    Choice : Chc.Choice := Chc.Forge.Create (Active_Group, 180, 70, 100, 25, "Fl_Choice:");

    --  Interactive control of the scheme.
    Scheme : Sch.Scheme_Choice := Sch.Forge.Create (Win, 180, 120, 100, 25, "Choose scheme:");

    Active : Chk.Check_Button := Chk.Forge.Create
        (Win, 50, 160, 160, 30, "Activate/deactivate");

    procedure Active_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Active.Get_State = FLTK.Widgets.Buttons.On then
            Active_Group.Activate;
            TTY.Print ("activate group" & ASCII.LF);
        else
            Active_Group.Deactivate;
            TTY.Print ("deactivate group" & ASCII.LF);
        end if;
        Active_Group.Redraw;
        if Item.Has_Changed then
            TTY.Print ("Callback: changed() is set" & ASCII.LF);
            Item.Clear_Changed;
        end if;
    end Active_CB;

    procedure Input_Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        TTY.Print ("Fl_Input_Choice value='" & Input.Get_Input & "'" & ASCII.LF);
    end Input_Choice_CB;

    procedure Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Number : constant String := Integer'Image (Choice.Chosen_Index - 1);
    begin
        TTY.Print ("Fl_Choice       value='" & Number (Number'First + 1 .. Number'Last)
            & "'" & ASCII.LF);
    end Choice_CB;

begin

    Input.Set_Callback (Input_Choice_CB'Unrestricted_Access);
    Input.Button_Menu.Add ("one");
    Input.Button_Menu.Add ("two");
    Input.Button_Menu.Add ("three");
    Input.Set_Item (1);

    Choice.Set_Callback (Choice_CB'Unrestricted_Access);
    Choice.Add ("aaa");
    Choice.Add ("bbb");
    Choice.Add ("ccc");
    Choice.Set_Chosen (2);

    Scheme.Set_Visible_Focus (False);

    Active.Set_Callback (Active_CB'Unrestricted_Access);
    Active.Set_State (FLTK.Widgets.Buttons.On);

    Win.Set_Resizable (Win);
    Win.Set_Size_Range (200, 160);
    Win.Show_With_Args;
    return FLTK.Run;

end Input_Choice;
