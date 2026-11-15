--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Literal menu labels (PLAN.md, Phase 30):  Add_Text, Insert_Text and
--  Set_Item_Text show the text as it is, with no '/' submenus, no '_'
--  divider, no '\' escapes, and '&' and '@' doubled so that FLTK draws them
--  as themselves; Get_Item_Text gives the text back.  After pofltk's
--  TestMenus.Mod.


with

    Checks,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide;

use

    Checks;


procedure Test_Menu_Text is

    package Chs renames FLTK.Widgets.Menus.Choices;
    package Sys renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;

    use type FLTK.Menu_Flag;

    Odd : constant String := "AC/DC & Friends @ 5_\t";

    Menu : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Bar  : Sys.System_Menu_Bar := Sys.Forge.Create (0, 0, 100, 25);

    Place : FLTK.Widgets.Menus.Index;

begin

    Place := Menu.Add_Text (Odd);
    Check (Place = 1 and then Menu.Number_Of_Items = 2,
        "Add_Text adds one item, with no submenu:" & Menu.Number_Of_Items'Image);
    Check (Menu.Get_Label (Place => 1) = "AC/DC && Friends @@ 5_\t",
        "its label has '&' and '@' doubled, and nothing else changed: " &
        Menu.Get_Label (Place => 1));
    Check (Menu.Get_Item_Text (1) = Odd,
        "Get_Item_Text gives the text back: " & Menu.Get_Item_Text (1));

    Menu.Add_Text ("_lead");
    Check (Menu.Get_Label (Place => 2) = "_lead" and then not Menu.Get_Flags (2).Divider,
        "a leading '_' is kept, and makes no divider: " & Menu.Get_Label (Place => 2));

    Menu.Add_Text (Odd);
    Check (Menu.Number_Of_Items = 4 and then Menu.Get_Item_Text (3) = Odd,
        "the same text again is another item:" & Menu.Number_Of_Items'Image);

    Menu.Add ((1 => ASCII.SOH));
    Menu.Add_Text ("after");
    Menu.Add_Text ("after");
    Check (Menu.Number_Of_Items = 7 and then Menu.Get_Label (Place => 5) = "after"
            and then Menu.Get_Label (Place => 6) = "after",
        "even with an item labelled SOH:" & Menu.Number_Of_Items'Image);

    Place := Menu.Insert_Text (1, "first & @", Flags => FLTK.Flag_Inactive);
    Check (Place = 1 and then Menu.Get_Item_Text (1) = "first & @"
            and then Menu.Get_Item_Text (2) = Odd,
        "Insert_Text inserts before item 1: " & Menu.Get_Item_Text (1));
    Check (Menu.Get_Flags (1) = FLTK.Flag_Inactive, "with its flags");

    Menu.Set_Item_Text (2, "x&y/z\@");
    Check (Menu.Get_Label (Place => 2) = "x&&y/z\@@" and then Menu.Get_Item_Text (2) = "x&y/z\@",
        "Set_Item_Text: " & Menu.Get_Label (Place => 2));

    Menu.Set_Label (3, "a&&&b@@@c");
    Check (Menu.Get_Item_Text (3) = "a&&b@@c",
        "Get_Item_Text makes each doubled '&' and '@' one: " & Menu.Get_Item_Text (3));

    Menu.Set_Item_Text (3, "");
    Check (Menu.Get_Item_Text (3) = "", "an empty text");

    Bar.Add_Text ("File/Open");
    Bar.Insert_Text (1, "A&B");
    Check (Bar.Number_Of_Items = 3 and then Bar.Get_Item_Text (1) = "A&B"
            and then Bar.Get_Item_Text (2) = "File/Open",
        "a System_Menu_Bar too:" & Bar.Number_Of_Items'Image);

    Summary;

end Test_Menu_Text;
