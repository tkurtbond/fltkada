--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 79: how a menu's Add finds an item already there.  It looks
--  with Fl_Menu_Item::next, which skips items that aren't visible, and
--  compares labels ignoring '&' (Fl_Menu_add.cxx:79-91, 173-174, 189-190).
--  A label added again is the same item: its callback, shortcut and flags
--  are replaced and no item is added (:203-206).  A hidden item isn't
--  found, so adding its label again adds a second one, unless it is the
--  first item, which the search tests before it calls next.


with

    Checks,
    FLTK.Menu_Items,
    FLTK.Widgets.Menus.Choices;

use

    Checks,
    FLTK;


procedure Test_Menu_Add_Merge is

    package Chs renames FLTK.Widgets.Menus.Choices;

    Menu  : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    First, Again, Count : Natural;

begin

    Menu.Add ("New", Flags => Flag_Normal);
    First := Menu.Add ("Open", Flags => Flag_Normal);
    Count := Menu.Number_Of_Items;

    Again := Menu.Add ("&Open", Flags => Flag_Inactive);
    Check (Again = First and Menu.Number_Of_Items = Count,
        "adding ""&Open"" after ""Open"" adds no item:" &
        Natural'Image (First) & Natural'Image (Again) &
        Natural'Image (Count) & Natural'Image (Menu.Number_Of_Items));
    Check (not FLTK.Menu_Items.Is_Active (Menu.Item (First)),
        "and replaces the item's flags");

    Menu.Item (First).Hide;
    Check (not FLTK.Menu_Items.Is_Visible (Menu.Item (First)), "the item is hidden");
    Again := Menu.Add ("Open", Flags => Flag_Normal);
    Check (Again /= First and Menu.Number_Of_Items = Count + 1,
        "adding the label of a hidden item adds a second one:" &
        Natural'Image (Again) & Natural'Image (Menu.Number_Of_Items));

    --  But the search tests the first item before it calls next, so a
    --  hidden first item is still found.
    Menu.Item (1).Hide;
    Count := Menu.Number_Of_Items;
    Again := Menu.Add ("New", Flags => Flag_Normal);
    Check (Again = 1 and Menu.Number_Of_Items = Count,
        "a hidden first item is found all the same:" &
        Natural'Image (Again) & Natural'Image (Menu.Number_Of_Items));

    Summary;

end Test_Menu_Add_Merge;
