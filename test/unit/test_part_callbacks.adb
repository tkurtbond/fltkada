


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 15 (FLTKAda-BUGS.md), N8 in PLAN.md, F2 in FLTK-issues.md:
--  Value_Input's input, and Input_Choice's input and menu button.  FLTK
--  gives each part a callback that finds the parent through the part's
--  callback data, which is its user_data (Fl_Value_Input.cxx:28, 120;
--  Fl_Input_Choice.cxx:206, 237, 266, 270).  The binding keeps the part's
--  Ada record in user_data, so those callbacks took an Ada record for the
--  C++ parent.  The test types into both inputs and picks a menu item by
--  its shortcut, so each part's FLTK callback runs, and checks what the
--  parent did with it.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Input_Choices,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Valuators.Value_Inputs;

use

    Checks,
    FLTK;


procedure Test_Part_Callbacks is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package VI  renames FLTK.Widgets.Valuators.Value_Inputs;
    package IC  renames FLTK.Widgets.Groups.Input_Choices;

    Value_Calls  : Natural := 0;
    Choice_Calls : Natural := 0;

    procedure Count_Value
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Value_Calls := Value_Calls + 1;
    end Count_Value;

    procedure Count_Choice
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Choice_Calls := Choice_Calls + 1;
    end Count_Choice;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 100, "Test_Part_Callbacks");

    Value : VI.Value_Input := VI.Forge.Create (Window, 10, 10, 100, 25);

    Choice : IC.Input_Choice := IC.Forge.Create (Window, 10, 50, 150, 25);

    Ignore_Done : Boolean;

begin

    Value.Set_Callback (Count_Value'Unrestricted_Access);
    Choice.Set_Callback (Count_Choice'Unrestricted_Access);
    Choice.Button_Menu.Add ("picked", Shortcut => Mod_Ctrl + 'p');

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;

    --  Value_Input: its input's callback sets the value from the text.
    if Value.Take_Focus then
        Value.Text_Field.Set_Value ("");
        Check (Prb.Key (Keydown, Press ('7'), Text => "7"), "a key reaches the Value_Input");
        Check (Value.Text_Field.Get_Value = "7",
            "the Value_Input's field has the key: """ & Value.Text_Field.Get_Value & """");
        Check (Value.Get_Value = 7.0,
            "the Value_Input's value follows its field:" & Long_Float'Image (Value.Get_Value));
        Check (Value_Calls = 1, "the Value_Input's callback ran:" & Natural'Image (Value_Calls));
    else
        Check (False, "the Value_Input takes the focus");
    end if;

    --  Input_Choice: its input's callback runs the Input_Choice's.
    if Choice.Text_Field.Take_Focus then
        Check (Prb.Key (Keydown, Press ('x'), Text => "x"), "a key reaches the Input_Choice");
        Check (Choice.Text_Field.Get_Value = "x",
            "the Input_Choice's field has the key: """ & Choice.Text_Field.Get_Value & """");
        Check (Choice_Calls = 1,
            "typing runs the Input_Choice's callback:" & Natural'Image (Choice_Calls));
    else
        Check (False, "the Input_Choice's field takes the focus");
    end if;

    --  Input_Choice: its menu's callback copies the item into the input.
    Check (Prb.Shortcut (Window, Press ('p'), Mod_Ctrl), "the item's shortcut is used");
    Check (Choice.Text_Field.Get_Value = "picked",
        "picking an item puts it in the field: """ & Choice.Text_Field.Get_Value & """");
    Check (Choice_Calls = 2,
        "picking an item runs the Input_Choice's callback:" & Natural'Image (Choice_Calls));

    for N in 1 .. 3 loop
        Ignore_Done := FLTK.Wait (0.02) < 0.0;
    end loop;
    Window.Hide;
    Summary;

end Test_Part_Callbacks;


