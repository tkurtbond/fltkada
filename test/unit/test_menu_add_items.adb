--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 65: the one-string Add, FLTK's add (const char *), could
--  not be called, since every call was ambiguous with the Add whose other
--  parameters have defaults.  It is now Add_Items.  FLTK splits the text at
--  each '|' and returns the last item's index.
--
--  FLTK's add (const char *) cut a part after 1022 bytes into several items,
--  dropping the byte at each cut (F11), and read a shortcut from the tab
--  before it, so "^a" gave none (pofltk 173; Fl_Menu_add.cxx:445-460).  The
--  shim now splits the text itself: a part's label ends at its first tab,
--  is cut as Add cuts a label (pofltk 172), and its shortcut follows the
--  last tab.


with

    Checks,
    FLTK.Menu_Items,
    FLTK.Widgets.Menus.Choices;

use

    Checks;

use type

    FLTK.Key_Combo;


procedure Test_Menu_Add_Items is

    package Chs renames FLTK.Widgets.Menus.Choices;

    Menu  : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Last  : Natural;
    Count : Natural;

    function Label
           (Place : in Positive)
        return String is
    begin
        return FLTK.Menu_Items.Get_Label (Menu.Item (Place).Data.all);
    end Label;

begin

    --  Number_Of_Items is FLTK's size (), which counts the end marker that
    --  the first item added brings.
    Last := Menu.Add_Items ("One|Two|Three");
    Check (Menu.Number_Of_Items = 3 + 1,
        "Add_Items adds an item for each part:" &
        Natural'Image (Menu.Number_Of_Items - 1));
    Check (Last = 3, "and returns the last one's index:" & Natural'Image (Last));
    Check (Label (1) = "One" and Label (2) = "Two" and Label (3) = "Three",
        "in order: " & Label (1) & " " & Label (2) & " " & Label (3));

    Menu.Add_Items ("Four");
    Check (Menu.Number_Of_Items = 4 + 1 and Label (4) = "Four",
        "the procedure adds one item with no '|'");

    Count := Menu.Number_Of_Items;
    Menu.Add_Items ((1 .. 1030 => 'x'));
    Check (Menu.Number_Of_Items = Count + 1 and then Label (5) = (1 .. 1023 => 'x'),
        "a 1030-byte part is one item, cut to 1023 bytes:" &
        Natural'Image (Menu.Number_Of_Items - Count) &
        Natural'Image (Label (5)'Length));

    Count := Menu.Number_Of_Items;
    Last := Menu.Add_Items
        ("Six" & ASCII.HT & "^a|Seven" & ASCII.HT & "0x62|Eight" & ASCII.HT &
         "#b" & ASCII.HT & "+c|Nine");
    Check (Menu.Number_Of_Items = Count + 4 and Last = 9,
        "parts with shortcuts add an item each:" &
        Natural'Image (Menu.Number_Of_Items - Count) & Natural'Image (Last));
    Check (Label (6) = "Six" and Label (7) = "Seven" and Label (8) = "Eight",
        "a label ends at its first tab: " & Label (6) & " " & Label (7) & " " & Label (8));
    Check (Menu.Item (6).Data.Get_Shortcut = FLTK.Mod_Ctrl + 'a',
        "^a after a tab is Ctrl+A (pofltk 173)");
    Check (Menu.Item (7).Data.Get_Shortcut = FLTK.Press ('b'),
        "a number after a tab is still read");
    Check (Menu.Item (8).Data.Get_Shortcut = FLTK.Mod_Shift + 'c',
        "the shortcut follows the last tab");
    Check (Menu.Item (9).Data.Get_Shortcut = FLTK.No_Key,
        "a part with no tab has no shortcut");

    Summary;

end Test_Menu_Add_Items;
