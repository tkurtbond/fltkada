--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 26: Fl_Menu_ keeps the chosen item as a pointer
--  into its array, and insert, remove and clear_submenu move the items after
--  the change without moving it (Fl_Menu_add.cxx:419-423).  So the chosen
--  item became whichever item took its place.  Add with a submenu path
--  inserts too, at the end of the submenu.  The chosen item must stay the
--  same item, or be none once it is removed.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Menus.Choices;

use

    Checks,
    FLTK;


procedure Test_Menu_Chosen is

    package Mns renames FLTK.Widgets.Menus;
    package Chs renames FLTK.Widgets.Menus.Choices;

    procedure Expect
           (Item  : in Chs.Choice;
            Label : in String;
            Place : in Mns.Extended_Index;
            Doing : in String) is
    begin
        if Place = Mns.No_Index then
            Check (Item.Chosen_Index = Mns.No_Index, Doing & ": none chosen, not"
                & Integer'Image (Item.Chosen_Index));
        else
            Check (Item.Chosen_Index = Place and then Item.Chosen_Label = Label,
                Doing & ": " & Label & " chosen, at" & Integer'Image (Place) & ", not"
                & Integer'Image (Item.Chosen_Index));
        end if;
    end Expect;

begin

    --  Top-level items.
    declare
        Item : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    begin
        Item.Add ("A", Shortcut => No_Key);
        Item.Add ("B", Shortcut => No_Key);
        Item.Set_Chosen (2);
        Expect (Item, "B", 2, "set");

        Item.Insert (1, "Z");
        Expect (Item, "B", 3, "insert before");

        Item.Insert (4, "C");
        Expect (Item, "B", 3, "insert after");

        --  Enough inserts that FLTK grows the array.
        for N in 1 .. 40 loop
            Item.Insert (1, "Y" & Integer'Image (N));
        end loop;
        Expect (Item, "B", 43, "40 inserts before");

        for N in 1 .. 40 loop
            Item.Remove (1);
        end loop;
        Expect (Item, "B", 3, "40 removes before");

        Item.Remove (1);
        Expect (Item, "B", 2, "remove before");

        Item.Remove (3);
        Expect (Item, "B", 2, "remove after");

        Item.Remove (2);
        Expect (Item, "", Mns.No_Index, "remove it");
    end;

    --  Submenus: A, Sub, X, end of Sub, B.
    declare
        Item : Chs.Choice := Chs.Forge.Create (0, 0, 100, 25);
    begin
        Item.Add ("A", Shortcut => No_Key);
        Item.Add ("Sub/X", Shortcut => No_Key);
        Item.Add ("B", Shortcut => No_Key);
        Item.Set_Chosen (5);
        Expect (Item, "B", 5, "set in a menu with a submenu");

        Item.Add ("Sub/Y", Shortcut => No_Key);
        Expect (Item, "B", 6, "add to a submenu before");

        Item.Clear_Submenu (2);
        Expect (Item, "B", 4, "clear a submenu before");
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Menu_Chosen;
