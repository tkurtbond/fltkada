

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 34 (FLTKAda-BUGS.md): a menu's Set_Label.  Fl_Menu_::replace copies
--  the text only when the menu owns its strings (alloc > 1,
--  Fl_Menu_add.cxx:472-480).  A menu sharing another's items, from
--  Use_Same_Items, got a private copy of the array that didn't own them
--  (alloc 1), and FLTK kept the pointer it was given.  Since the fix for
--  section 38, Use_Same_Items gives the menu its own copy of the items and
--  texts (alloc 2), so FLTK copies here too; the checks still hold.  Each
--  label is built at run time and the stacks are scribbled over, so a binding
--  that passed a temporary hands FLTK 'X's.  Relabelling and finalizing are
--  checked by valgrind.


with

    Checks,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide;

use

    Checks,
    FLTK;


procedure Test_Menu_Labels is

    package Win renames FLTK.Widgets.Groups.Windows;
    package Chs renames FLTK.Widgets.Menus.Choices;
    package SMB renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    function Expected
           (Base : in String)
        return String is
    begin
        return Base & Integer'Image (Serial);
    end Expected;

    function Filler
           (Length : in Positive)
        return String is
    begin
        return (1 .. Length => 'X');
    end Filler;

    procedure Scribble is
        Count : Natural := 0;
    begin
        for N in 1 .. 8 loop
            declare
                Junk : constant String := Filler (4096 * N);
            begin
                Count := Count + Junk'Length;
            end;
        end loop;
        pragma Assert (Count > 0);
    end Scribble;

    --  A menu's Get_Label (Place), which Owner.Get_Label (1) can't name
    --  apart from the widget's Get_Label indexed.
    function Item_Label
           (Menu  : in FLTK.Widgets.Menus.Menu'Class;
            Place : in Positive)
        return String is
    begin
        return FLTK.Widgets.Menus.Get_Label (Menu, Place);
    end Item_Label;

    --  A label as a message shows it, cut short if scribbled over.
    function Shown
           (Text : in String)
        return String is
    begin
        if Text'Length > 40 then
            return Text (Text'First .. Text'First + 39) & "...";
        else
            return Text;
        end if;
    end Shown;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 120, "Test_Menu_Labels");

    Owner : Chs.Choice := Chs.Forge.Create (Window, 10, 10, 130, 25);

    Sharer : Chs.Choice := Chs.Forge.Create (Window, 150, 10, 130, 25);

    Bar : SMB.System_Menu_Bar := SMB.Forge.Create (Window, 10, 50, 280, 25);

begin

    Owner.Add ("one", Shortcut => No_Key);
    Owner.Add ("two", Shortcut => No_Key);
    Owner.Add ("three", Shortcut => No_Key);

    --  A menu that owns its strings: FLTK copies the label.
    Owner.Set_Label (1, Fresh ("first"));
    Scribble;
    Check (Item_Label (Owner, 1) = Expected ("first"), "an owning menu's label is kept: "
        & Shown (Item_Label (Owner, 1)));

    --  A menu sharing another's items: FLTK keeps the pointer it is given.
    Sharer.Use_Same_Items (Owner);
    Sharer.Set_Label (2, Fresh ("second"));
    Scribble;
    Check (Item_Label (Sharer, 2) = Expected ("second"), "a sharing menu's label is kept: "
        & Shown (Item_Label (Sharer, 2)));
    Check (Item_Label (Owner, 2) = "two", "the donor's label is unchanged: "
        & Shown (Item_Label (Owner, 2)));

    --  Relabelling the same item frees the label it replaces.
    Sharer.Set_Label (2, Fresh ("again"));
    Scribble;
    Check (Item_Label (Sharer, 2) = Expected ("again"), "a relabelled item's label is kept: "
        & Shown (Item_Label (Sharer, 2)));
    Sharer.Set_Label (3, Fresh ("third"));
    Scribble;
    Check (Item_Label (Sharer, 3) = Expected ("third"), "a second item's label is kept: "
        & Shown (Item_Label (Sharer, 3)));

    --  The system menu bar, the same way.
    Bar.Use_Same_Items (Owner);
    Bar.Set_Label (1, Fresh ("bar"));
    Scribble;
    Check (Item_Label (Bar, 1) = Expected ("bar"), "a system menu bar's label is kept: "
        & Shown (Item_Label (Bar, 1)));

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Sharer.Set_Chosen (2);
    Pump (5);
    Window.Hide;
    Summary;

end Test_Menu_Labels;

