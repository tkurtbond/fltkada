--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 65: the one-string Add, FLTK's add (const char *), could
--  not be called, since every call was ambiguous with the Add whose other
--  parameters have defaults.  It is now Add_Items.  FLTK splits the text at
--  each '|' and returns the last item's index, and cuts a part after 1022
--  bytes, dropping the byte there (Fl_Menu_add.cxx:445-460).


with

    Checks,
    FLTK.Menu_Items,
    FLTK.Widgets.Menus.Choices;

use

    Checks;


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
    Check (Menu.Number_Of_Items = Count + 2
            and then Label (5)'Length = 1022 and then Label (6)'Length = 7,
        "a 1030-byte part is cut after 1022, the 1023rd byte dropped:" &
        Natural'Image (Menu.Number_Of_Items - Count) &
        Natural'Image (Label (5)'Length) &
        (if Menu.Number_Of_Items > 5 then Natural'Image (Label (6)'Length) else ""));

    Summary;

end Test_Menu_Add_Items;
