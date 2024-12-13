

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
    --  methods in C++ are also private which makes it nigh impossible to properly
    --  bind to Ada, so you can't use those either.
    --
    --  Find_Item is also private in C++ in 1.3 for whatever reason, so that might
    --  have unexpected behaviour.
    --
    --  So, uh, be aware of all that, I guess? Or wait until I get around to 1.4.
    --  Using the equivalent of the C++ public API should still work fine right now.


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
            State : in     Boolean);

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




    --  Item related stuff reimplemented for binding-related reasons.
    --  These subprograms are protected on the C++ side.

    function Current_Selection
           (This : in Check_Browser)
        return Item_Cursor;

    function Is_Displayed
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Boolean;

    function Find_Item
           (This  : in Check_Browser;
            Y_Pos : in Integer)
        return Item_Cursor;

    function Top_Item
           (This : in Check_Browser)
        return Item_Cursor;




    --  Graphical dimensions and redrawing reimplemented for binding-related reasons.
    --  These subprograms are protected on the C++ side.

    procedure Bounding_Box
           (This       : in     Check_Browser;
            X, Y, W, H :    out Integer);

    function Left_Edge
           (This : in Check_Browser)
        return Integer;

    procedure Redraw_Line
           (This : in out Check_Browser;
            Item : in     Item_Cursor);

    procedure Redraw_List
           (This : in out Check_Browser);




    --  Optional overrides reimplemented for binding-related reasons.
    --  These subprograms are protected on the C++ side.

    function Full_List_Width
           (This : in Check_Browser)
        return Integer;

    function Full_List_Height
           (This : in Check_Browser)
        return Integer;

    function Average_Item_Height
           (This : in Check_Browser)
        return Integer;

    function Item_Quick_Height
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Integer;




    --  These Item_* subprograms are disabled due to a bug in FLTK 1.3.
    --  Should be able to bind them properly when 1.4 comes around.

    --  function Item_Width
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Integer;

    --  function Item_Height
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Integer;

    --  function Item_First
    --         (This : in Check_Browser)
    --      return Item_Cursor;

    --  Item_Last missing in 1.3

    --  function Item_Next
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Item_Cursor;

    --  function Item_Previous
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Item_Cursor;

    --  Item_At missing in 1.3

    --  procedure Item_Select
    --         (This  : in out Check_Browser;
    --          Item  : in     Item_Cursor;
    --          State : in     Boolean := True);

    --  function Item_Selected
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Boolean;

    --  Item_Swap and Item_Text missing in 1.3

    --  procedure Item_Draw
    --         (This       : in Check_Browser;
    --          Item       : in Item_Cursor;
    --          X, Y, W, H : in Integer);




    --  Cache invalidation reimplemented for binding-related reasons.
    --  These subprograms are protected on the C++ side.

    procedure New_List
           (This : in out Check_Browser);

    procedure Inserting
           (This : in out Check_Browser;
            A, B : in     Item_Cursor);

    procedure Deleting
           (This : in out Check_Browser;
            Item : in     Item_Cursor);

    procedure Replacing
           (This : in out Check_Browser;
            A, B : in     Item_Cursor);

    procedure Swapping
           (This : in out Check_Browser;
            A, B : in     Item_Cursor);




    procedure Draw
           (This : in out Check_Browser);

    function Handle
           (This  : in out Check_Browser;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Check_Browser is new Browser with null record;

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

    pragma Inline (Current_Selection);
    pragma Inline (Find_Item);
    pragma Inline (Top_Item);

    pragma Inline (Bounding_Box);
    pragma Inline (Left_Edge);
    pragma Inline (Redraw_Line);
    pragma Inline (Redraw_List);

    pragma Inline (Full_List_Width);
    pragma Inline (Full_List_Height);
    pragma Inline (Average_Item_Height);
    pragma Inline (Item_Quick_Height);

    --  pragma Inline (Item_Width);
    --  pragma Inline (Item_Height);
    --  pragma Inline (Item_First);
    --  pragma Inline (Item_Next);
    --  pragma Inline (Item_Previous);
    --  pragma Inline (Item_Select);
    --  pragma Inline (Item_Selected);
    --  pragma Inline (Item_Draw);

    pragma Inline (New_List);
    pragma Inline (Inserting);
    pragma Inline (Deleting);
    pragma Inline (Replacing);
    pragma Inline (Swapping);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Browsers.Check;


