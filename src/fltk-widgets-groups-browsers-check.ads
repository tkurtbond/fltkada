

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Browsers.Check is


    --  Since the FLTK 1.3 implementation doesn't provide the following key functions:
    --
    --    item_at / Item_At
    --    item_last / Item_Last
    --    item_swap / Item_Swap
    --    item_text / Item_Text
    --
    --  You can't use Sort on a Check_Browser unless you want a crash. The item_*
    --  methods in C++ are also private which means with the way they had to be bound,
    --  if you override those subprograms in Ada the behaviour in FLTK will not change.
    --
    --  These problems are fixed in 1.4 so they will go away once I get there.


    type Check_Browser is new Browser with private;

    type Check_Browser_Reference (Data : not null access Check_Browser'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Check_Browser;

    end Forge;




    --  Adding and removing

    procedure Add
           (This    : in out Check_Browser;
            Text    : in     String;
            Checked : in     Boolean := False);

    procedure Remove
           (This  : in out Check_Browser;
            Index : in     Positive);

    procedure Clear
           (This : in out Check_Browser);

    function Number_Of_Items
           (This : in Check_Browser)
        return Natural;




    --  Checking and unchecking

    procedure Check_All
           (This : in out Check_Browser);

    procedure Check_None
           (This : in out Check_Browser);

    function Is_Checked
           (This  : in Check_Browser;
            Index : in Positive)
        return Boolean;

    procedure Set_Checked
           (This  : in out Check_Browser;
            Index : in     Positive;
            State : in     Boolean := True);

    function Number_Checked
           (This : in Check_Browser)
        return Natural;




    --  Text and selection

    --  Don't confuse this with the missing Item_Cursor version
    function Item_Text
           (This  : in Check_Browser;
            Index : in Positive)
        return String;

    function Selected_Index
           (This : in Check_Browser)
        return Positive;




    --  As mentioned at the start, due to issues with FLTK 1.3 if you override
    --  these subprograms the behaviour in FLTK will not change. Should be able
    --  to bind them properly once 1.4 comes around.

    function Item_Width
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_Height
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_First
           (This : in Check_Browser)
        return Item_Cursor;

    --  Item_Last missing in 1.3

    function Item_Next
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    function Item_Previous
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    --  Item_At missing in 1.3

    procedure Item_Select
           (This  : in out Check_Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True);

    function Item_Selected
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Boolean;

    --  Item_Swap and Item_Text missing in 1.3

    procedure Item_Draw
           (This       : in Check_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer);


private


    type Check_Browser is new Browser with null record;

    overriding procedure Initialize
           (This : in out Check_Browser);

    overriding procedure Finalize
           (This : in out Check_Browser);

    procedure Extra_Init
           (This       : in out Check_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Check_Browser);


    pragma Inline (Add);
    pragma Inline (Remove);
    pragma Inline (Clear);
    pragma Inline (Number_Of_Items);

    pragma Inline (Check_All);
    pragma Inline (Check_None);
    pragma Inline (Is_Checked);
    pragma Inline (Set_Checked);
    pragma Inline (Number_Checked);

    pragma Inline (Item_Text);
    pragma Inline (Selected_Index);

    pragma Inline (Item_Width);
    pragma Inline (Item_Height);
    pragma Inline (Item_First);
    pragma Inline (Item_Next);
    pragma Inline (Item_Previous);
    pragma Inline (Item_Select);
    pragma Inline (Item_Selected);
    pragma Inline (Item_Draw);


end FLTK.Widgets.Groups.Browsers.Check;


