--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 92: Input_Choice.Set_Item passed its number to FLTK's
--  Fl_Input_Choice::value (int), which reads menu_->text (i) with no range
--  check (Fl_Input_Choice.cxx:286-289, Fl_Menu_.H:214), and counted from
--  0 where Has_Item and Item count from 1.  Set_Item now counts from 1 and
--  raises Constraint_Error for an item that doesn't exist, or that is the
--  terminator, which Has_Item counted then (Fl_Menu_::size; bug 93).


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Groups.Input_Choices;

use

    Checks;


procedure Test_Input_Choice_Item is

    package IC renames FLTK.Widgets.Groups.Input_Choices;

    function Filled
        return IC.Input_Choice is
    begin
        return Item : IC.Input_Choice := IC.Forge.Create (0, 0, 100, 25) do
            Item.Button_Menu.Add ("one");
            Item.Button_Menu.Add ("two");
            Item.Button_Menu.Add ("three");
        end return;
    end Filled;

    Full  : IC.Input_Choice := Filled;
    Empty : IC.Input_Choice := IC.Forge.Create (0, 0, 100, 25);

    procedure Past_The_End is
    begin
        Full.Set_Item (4);
    end Past_The_End;

    procedure In_None is
    begin
        Empty.Set_Item (1);
    end In_None;

begin

    Full.Set_Item (1);
    Check (Full.Get_Input = "one", "Set_Item (1) shows the first item, '"
        & Full.Get_Input & "'");
    Check (Full.Button_Menu.Chosen_Index = 1, "and chooses it, item"
        & Integer'Image (Full.Button_Menu.Chosen_Index));

    Full.Set_Item (3);
    Check (Full.Get_Input = "three", "Set_Item (3) shows the last item, '"
        & Full.Get_Input & "'");
    Check (Full.Button_Menu.Chosen_Index = 3, "and chooses it, item"
        & Integer'Image (Full.Button_Menu.Chosen_Index));

    Raises (Past_The_End'Access, Constraint_Error'Identity,
        "Set_Item (4) of three items");
    Check (Full.Get_Input = "three", "and leaves the input alone, '"
        & Full.Get_Input & "'");

    Raises (In_None'Access, Constraint_Error'Identity, "Set_Item (1) of no items");
    Check (Empty.Get_Input = "", "and leaves the input empty, '" & Empty.Get_Input & "'");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Input_Choice_Item;
