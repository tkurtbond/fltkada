

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 38 (FLTKAda-BUGS.md): Menu.Set_Items and Use_Same_Items.  Set_Items
--  passed an array of item pointers where Fl_Menu_::copy expects an array of
--  Fl_Menu_Item structs (Fl_Menu_.cxx:535-546).  And copy() would share the
--  items' texts, which each Ada Menu_Item frees when it goes.
--  Use_Same_Items shared the donor's array and texts (Fl_Menu_.cxx:522-526),
--  which the donor frees when it relabels an item, outgrows the array
--  (Fl_Menu_add.cxx:55-60) or is deleted.  The test sets menus' items, lets
--  the source go, scribbles over the heap with strings of the same size, and
--  reads the labels back.  It then adds to the menus, relabels items, and
--  sets new items, which valgrind checks.


with

    Ada.Strings.Unbounded,
    Checks,
    FLTK.Menu_Items,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide,
    Interfaces.C.Strings;

use

    Ada.Strings.Unbounded,
    Checks,
    FLTK;


procedure Test_Menu_Items is

    package MI  renames FLTK.Menu_Items;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Chs renames FLTK.Widgets.Menus.Choices;
    package SMB renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;
    package ICS renames Interfaces.C.Strings;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    Junk      : array (1 .. 256) of ICS.chars_ptr := (others => ICS.Null_Ptr);
    Junk_Next : Positive := Junk'First;

    --  Takes back freed blocks of Length + 1 bytes and fills them with 'X's.
    procedure Scribble
           (Length : in Positive) is
    begin
        for N in 1 .. 32 loop
            ICS.Free (Junk (Junk_Next));
            Junk (Junk_Next) := ICS.New_String ((1 .. Length => 'X'));
            Junk_Next := (if Junk_Next = Junk'Last then Junk'First else Junk_Next + 1);
        end loop;
    end Scribble;

    function Item_Label
           (Menu  : in FLTK.Widgets.Menus.Menu'Class;
            Place : in Positive)
        return String is
    begin
        return FLTK.Widgets.Menus.Get_Label (Menu, Place);
    end Item_Label;

    Names : constant array (1 .. 3) of Unbounded_String :=
       (To_Unbounded_String (Fresh ("alpha")),
        To_Unbounded_String (Fresh ("beta")),
        To_Unbounded_String (Fresh ("gamma")));

    Ignore_Done : Boolean;

    procedure Check_Labels
           (Menu : in FLTK.Widgets.Menus.Menu'Class;
            What : in String) is
    begin
        for Place in Names'Range loop
            Check (Menu.Number_Of_Items > Place
                    and then Item_Label (Menu, Place) = To_String (Names (Place)),
                What & " keeps the label of item" & Integer'Image (Place));
        end loop;
    end Check_Labels;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 80, "Test_Menu_Items");

    Built : Chs.Choice := Chs.Forge.Create (Window, 10, 10, 130, 25);

    Given : Chs.Choice := Chs.Forge.Create (Window, 150, 10, 130, 25);

    Taker : Chs.Choice := Chs.Forge.Create (Window, 10, 45, 130, 25);

    Bar : SMB.System_Menu_Bar := SMB.Forge.Create (Window, 150, 45, 130, 25);

begin

    for Name of Names loop
        Built.Add (To_String (Name), Shortcut => No_Key);
    end loop;

    declare
        Items : constant MI.Menu_Item_Array :=
           (MI.Forge.Create (To_String (Names (1))),
            MI.Forge.Create (To_String (Names (2))),
            MI.Forge.Create (To_String (Names (3))));
    begin
        Given.Set_Items (Items);
    end;
    for Name of Names loop
        Scribble (Length (Name));
    end loop;

    Check (Given.Number_Of_Items = Built.Number_Of_Items,
        "a menu given items has as many as one they were added to:"
        & Natural'Image (Given.Number_Of_Items) & " and"
        & Natural'Image (Built.Number_Of_Items));
    for Place in Names'Range loop
        Check (Given.Number_Of_Items > Place
                and then Item_Label (Given, Place) = To_String (Names (Place)),
            "item" & Integer'Image (Place) & " keeps its label after its Menu_Item goes");
    end loop;

    --  The menu owns its items now: it can grow, and relabelling copies.
    Given.Add (Fresh ("delta"), Shortcut => No_Key);
    Check (Given.Number_Of_Items = Built.Number_Of_Items + 1, "a menu given items can grow");
    Given.Set_Label (2, Fresh ("relabelled"));
    Check (Item_Label (Given, 2) = "relabelled" & Integer'Image (Serial),
        "a menu given items can be relabelled");

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Given.Set_Chosen (1);
    for N in 1 .. 5 loop
        Ignore_Done := FLTK.Wait (0.02) < 0.0;
    end loop;

    --  New items replace the old, which the menu frees.
    declare
        Items : constant MI.Menu_Item_Array := (1 => MI.Forge.Create (Fresh ("only")));
    begin
        Given.Set_Items (Items);
    end;
    Check (Given.Number_Of_Items = Built.Number_Of_Items - 2, "new items replace the old");

    --  Menus that took a donor's items keep them after the donor relabels an
    --  item, outgrows its array and goes.
    declare
        Donor : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    begin
        for Name of Names loop
            Donor.Add (To_String (Name), Shortcut => No_Key);
        end loop;
        Taker.Use_Same_Items (Donor);
        Bar.Use_Same_Items (Donor);
        Donor.Set_Label (1, Fresh ("donor relabelled"));
        for N in 1 .. 20 loop
            Donor.Add (Fresh ("filler"), Shortcut => No_Key);
        end loop;
    end;
    for Name of Names loop
        Scribble (Length (Name));
    end loop;
    Check (Taker.Number_Of_Items = Built.Number_Of_Items,
        "a menu sharing a donor's items has as many:"
        & Natural'Image (Taker.Number_Of_Items));
    Check_Labels (Taker, "a menu sharing a donor's items");
    Check (Bar.Number_Of_Items = Built.Number_Of_Items,
        "a System_Menu_Bar sharing a donor's items has as many:"
        & Natural'Image (Bar.Number_Of_Items));
    Check_Labels (Bar, "a System_Menu_Bar sharing a donor's items");

    Taker.Add (Fresh ("added"), Shortcut => No_Key);
    Taker.Set_Label (3, Fresh ("taker relabelled"));
    Check (Item_Label (Taker, 3) = "taker relabelled" & Integer'Image (Serial),
        "a menu sharing a donor's items can be relabelled");
    Bar.Set_Label (2, Fresh ("bar relabelled"));
    Check (Item_Label (Bar, 2) = "bar relabelled" & Integer'Image (Serial),
        "a System_Menu_Bar sharing a donor's items can be relabelled");
    for N in 1 .. 5 loop
        Ignore_Done := FLTK.Wait (0.02) < 0.0;
    end loop;
    Window.Hide;

    for J of Junk loop
        ICS.Free (J);
    end loop;
    Summary;

end Test_Menu_Items;


