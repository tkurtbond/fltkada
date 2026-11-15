--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  An item's active and checked state (PLAN.md, Phase 30):  Set_Item_Active
--  and Set_Item_Checked change their one flag and leave the rest.  After
--  pofltk's TestMenus.Mod.


with

    Checks,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide;

use

    Checks;


procedure Test_Menu_Item_State is

    package Chs renames FLTK.Widgets.Menus.Choices;
    package Sys renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;

    use type FLTK.Menu_Flag;

    Menu : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Bar  : Sys.System_Menu_Bar := Sys.Forge.Create (0, 0, 100, 25);

    Toggle : constant FLTK.Menu_Flag := FLTK.Flag_Toggle + FLTK.Flag_Divider;

begin

    Menu.Add ("plain");
    Menu.Add ("toggle", Flags => Toggle);
    Menu.Add ("radio", Flags => FLTK.Flag_Radio + FLTK.Flag_Value);

    Check (Menu.Is_Item_Active (1) and then not Menu.Is_Item_Checked (1),
        "a plain item is active and not checked");
    Check (Menu.Is_Item_Checked (3), "an item added with Value is checked");

    Menu.Set_Item_Active (2, False);
    Check (not Menu.Is_Item_Active (2) and then Menu.Get_Flags (2) = Toggle + FLTK.Flag_Inactive,
        "Set_Item_Active (False) sets Inactive and leaves Toggle and Divider");
    Menu.Set_Item_Checked (2, True);
    Check (Menu.Is_Item_Checked (2)
            and then Menu.Get_Flags (2) = Toggle + FLTK.Flag_Inactive + FLTK.Flag_Value,
        "Set_Item_Checked (True) sets Value and leaves the rest");
    Menu.Set_Item_Active (2, True);
    Menu.Set_Item_Checked (2, False);
    Check (Menu.Get_Flags (2) = Toggle, "and both undo, leaving Toggle and Divider");

    Menu.Set_Item_Active (2, True);
    Check (Menu.Get_Flags (2) = Toggle, "setting a flag it has already changes nothing");

    Menu.Set_Item_Checked (3, False);
    Check (Menu.Get_Flags (3) = FLTK.Flag_Radio, "a radio item unchecked stays a radio item");
    Check (Menu.Get_Flags (1) = FLTK.Flag_Normal, "and the other items are untouched");

    Bar.Add ("File/Open");
    Bar.Add ("File/Auto", Flags => FLTK.Flag_Toggle);
    Bar.Set_Item_Checked (3, True);
    Bar.Set_Item_Active (2, False);
    Check (Bar.Is_Item_Checked (3) and then not Bar.Is_Item_Active (2)
            and then Bar.Get_Flags (3) = FLTK.Flag_Toggle + FLTK.Flag_Value
            and then Bar.Is_Item_Active (1),
        "a System_Menu_Bar too");

    Summary;

end Test_Menu_Item_State;
