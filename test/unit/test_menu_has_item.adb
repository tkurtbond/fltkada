--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 93: Has_Item was Place in 1 .. Number_Of_Items, and
--  Number_Of_Items is FLTK's Fl_Menu_::size (), which counts the menu's
--  terminator and each submenu's (Fl_Menu.cxx:58-70).  So Has_Item was true
--  for the terminators, and iterating over a menu visited them.  Has_Item is
--  now true only for an item, and the iterator steps over the terminators.


with

    Ada.Exceptions,
    Ada.Strings.Unbounded,
    Checks,
    FLTK.Menu_Items,
    FLTK.Widgets.Groups.Input_Choices,
    FLTK.Widgets.Menus.Choices;

use

    Ada.Strings.Unbounded,
    Checks;


procedure Test_Menu_Has_Item is

    package IC renames FLTK.Widgets.Groups.Input_Choices;
    package Chs renames FLTK.Widgets.Menus.Choices;

    Menu   : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Empty  : constant Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    Input  : IC.Input_Choice := IC.Forge.Create (0, 0, 100, 25);
    Seen   : Unbounded_String;

    function Label
           (Item : in FLTK.Menu_Items.Menu_Item_Reference)
        return String is
    begin
        return FLTK.Menu_Items.Get_Label (Item.Data.all);
    end Label;

begin

    --  one (1), sub (2), a (3), b (4), sub's terminator (5), two (6), and
    --  the menu's terminator (7).
    Menu.Add ("one");
    Menu.Add ("sub/a");
    Menu.Add ("sub/b");
    Menu.Add ("two");
    Check (Menu.Number_Of_Items = 7, "Number_Of_Items counts the terminators,"
        & Natural'Image (Menu.Number_Of_Items));

    for Place in 1 .. 4 loop
        Check (Menu.Has_Item (Place), "Has_Item (" & Integer'Image (Place) & " )");
    end loop;
    Check (not Menu.Has_Item (5), "not Has_Item for the submenu's terminator");
    Check (Menu.Has_Item (6), "Has_Item for the item after the submenu");
    Check (not Menu.Has_Item (7), "not Has_Item for the menu's terminator");
    Check (not Menu.Has_Item (8), "not Has_Item past the end");

    for Place in Menu.Iterate loop
        Append (Seen, Label (Menu.Item (Place)) & ",");
    end loop;
    Check (To_String (Seen) = "one,sub,a,b,two,",
        "iteration visits only the items, '" & To_String (Seen) & "'");

    Seen := Null_Unbounded_String;
    for Item of Menu loop
        Append (Seen, Label (Item) & ",");
    end loop;
    Check (To_String (Seen) = "one,sub,a,b,two,",
        "for ... of visits only the items, '" & To_String (Seen) & "'");

    Seen := Null_Unbounded_String;
    for Place in reverse Menu.Iterate loop
        Append (Seen, Label (Menu.Item (Place)) & ",");
    end loop;
    Check (To_String (Seen) = "two,b,a,sub,one,",
        "reverse iteration visits only the items, '" & To_String (Seen) & "'");

    Check (not Empty.Has_Item (1), "an empty menu has no item 1");
    for Place in Empty.Iterate loop
        Check (False, "iteration over an empty menu visits nothing");
    end loop;
    for Place in reverse Empty.Iterate loop
        Check (False, "reverse iteration over an empty menu visits nothing");
    end loop;

    Input.Button_Menu.Add ("one");
    Input.Button_Menu.Add ("two");
    Input.Button_Menu.Add ("three");
    Check (Input.Has_Item (3), "an Input_Choice of three has item 3");
    Check (not Input.Has_Item (4), "but not item 4, its terminator");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Menu_Has_Item;
