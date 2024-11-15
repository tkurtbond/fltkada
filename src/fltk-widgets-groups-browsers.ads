

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Valuators.Sliders.Scrollbars,
    System;

private with

    Ada.Finalization,
    Ada.Unchecked_Conversion,
    Interfaces.C;


package FLTK.Widgets.Groups.Browsers is


    type Abstract_Browser is new Group with private;

    type Abstract_Browser_Reference (Data : not null access Abstract_Browser'Class) is
        limited null record with Implicit_Dereference => Data;

    type Item_Cursor is mod System.Memory_Size;

    No_Item : constant Item_Cursor;

    type Sort_Order is (Ascending, Descending);

    type Scrollbar_Mode is record
        Horizontal : Boolean := True;
        Vertical   : Boolean := True;
        Always_On  : Boolean := False;
    end record;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Abstract_Browser;

    end Forge;




    --  Access to the Browser's self contained scrollbars

    function H_Bar
           (This : in out Abstract_Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;

    function V_Bar
           (This : in out Abstract_Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;




    --  Item related settings

    function Set_Select
           (This         : in out Abstract_Browser;
            Item         : in     Item_Cursor;
            State        : in     Boolean := True;
            Do_Callbacks : in     Boolean := False)
        return Boolean;

    function Select_Only
           (This         : in out Abstract_Browser;
            Item         : in     Item_Cursor;
            Do_Callbacks : in     Boolean := False)
        return Boolean;

    function Current_Selection
           (This : in Abstract_Browser)
        return Item_Cursor;

    function Deselect
           (This         : in out Abstract_Browser;
            Do_Callbacks : in     Boolean := False)
        return Boolean;

    procedure Display
           (This : in out Abstract_Browser;
            Item : in     Item_Cursor);

    function Is_Displayed
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Boolean;

    function Find_Item
           (This  : in Abstract_Browser;
            Y_Pos : in Integer)
        return Item_Cursor;

    function Top_Item
           (This : in Abstract_Browser)
        return Item_Cursor;

    --  Not task safe due to internal issues with converting Ada Strings to char* in C.
    --  Unsure how much that matters since unsure how task safe FLTK is anyway.
    procedure Sort
           (This  : in out Abstract_Browser;
            Order : in     Sort_Order);




    --  Scrollbar related settings

    function Get_Scrollbar_Mode
           (This : in Abstract_Browser)
        return Scrollbar_Mode;

    procedure Set_Scrollbar_Mode
           (This : in out Abstract_Browser;
            Mode : in     Scrollbar_Mode);

    function Get_H_Position
           (This : in Abstract_Browser)
        return Integer;

    procedure Set_H_Position
           (This  : in out Abstract_Browser;
            Value : in     Integer);

    function Get_V_Position
           (This : in Abstract_Browser)
        return Integer;

    procedure Set_V_Position
           (This  : in out Abstract_Browser;
            Value : in     Integer);

    procedure Set_Vertical_Left
           (This : in out Abstract_Browser);

    procedure Set_Vertical_Right
           (This : in out Abstract_Browser);

    function Get_Scrollbar_Size
           (This : in Abstract_Browser)
        return Integer;

    procedure Set_Scrollbar_Size
           (This  : in out Abstract_Browser;
            Value : in     Integer);




    --  Text related settings

    function Get_Text_Color
           (This : in Abstract_Browser)
        return Color;

    procedure Set_Text_Color
           (This  : in out Abstract_Browser;
            Value : in     Color);

    function Get_Text_Font
           (This : in Abstract_Browser)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Abstract_Browser;
            Font : in     Font_Kind);

    function Get_Text_Size
           (This : in Abstract_Browser)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Abstract_Browser;
            Size : in     Font_Size);




    --  Graphical dimensions and redrawing

    procedure Resize
           (This       : in out Abstract_Browser;
            X, Y, W, H : in     Integer);

    procedure Bounding_Box
           (This       : in     Abstract_Browser;
            X, Y, W, H :    out Integer);

    function Left_Edge
           (This : in Abstract_Browser)
        return Integer;

    procedure Redraw_Line
           (This : in out Abstract_Browser;
            Item : in     Item_Cursor);

    procedure Redraw_List
           (This : in out Abstract_Browser);




    --  You may override these subprograms to change the behaviour of the widget
    --  even though these are called from within FLTK.

    function Full_List_Width
           (This : in Abstract_Browser)
        return Integer;

    function Full_List_Height
           (This : in Abstract_Browser)
        return Integer;

    function Average_Item_Height
           (This : in Abstract_Browser)
        return Integer;

    function Item_Quick_Height
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Integer;




    --  You MUST override these subprograms if deriving a type from Abstract_Browser
    --  or your program will crash, since they are called from within FLTK and do not
    --  have any implementations given. By default here they will raise an exception.

    function Item_Width
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_Height
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_First
           (This : in Abstract_Browser)
        return Item_Cursor;

    function Item_Last
           (This : in Abstract_Browser)
        return Item_Cursor;

    function Item_Next
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    function Item_Previous
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    function Item_At
           (This  : in Abstract_Browser;
            Index : in Positive)
        return Item_Cursor;

    procedure Item_Select
           (This  : in out Abstract_Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True);

    function Item_Selected
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Boolean;

    procedure Item_Swap
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor);

    function Item_Text
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return String;

    procedure Item_Draw
           (This       : in Abstract_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer);




    --  Cache invalidation

    procedure New_List
           (This : in out Abstract_Browser);

    procedure Inserting
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor);

    procedure Deleting
           (This : in out Abstract_Browser;
            Item : in     Item_Cursor);

    procedure Replacing
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor);

    procedure Swapping
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor);




    --  You may override these subprograms to change the behaviour of the widget
    --  even though these are called from within FLTK.

    procedure Draw
           (This : in out Abstract_Browser);

    function Handle
           (This  : in out Abstract_Browser;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Abstract_Browser is new Group with record
        Horizon : aliased Valuators.Sliders.Scrollbars.Scrollbar;
        Vertigo : aliased Valuators.Sliders.Scrollbars.Scrollbar;
    end record;

    overriding procedure Finalize
           (This : in out Abstract_Browser);

    procedure Extra_Init
           (This       : in out Abstract_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String);


    pragma Assert
       (Item_Cursor'Size = Storage.Integer_Address'Size,
        "Size of Browser Item_Cursor does not match Ada address values");

    function Address_To_Cursor is
        new Ada.Unchecked_Conversion (Storage.Integer_Address, Item_Cursor);
    function Cursor_To_Address is
        new Ada.Unchecked_Conversion (Item_Cursor, Storage.Integer_Address);

    No_Item : constant Item_Cursor := Address_To_Cursor (Null_Pointer);


    for Scrollbar_Mode use record
        Horizontal at 0 range 0 .. 0;
        Vertical   at 0 range 1 .. 1;
        Always_On  at 0 range 2 .. 2;
    end record;

    for Scrollbar_Mode'Size use Interfaces.C.unsigned_char'Size;

    function Mode_To_Uchar is
        new Ada.Unchecked_Conversion (Scrollbar_Mode, Interfaces.C.unsigned_char);
    function Uchar_To_Mode is
        new Ada.Unchecked_Conversion (Interfaces.C.unsigned_char, Scrollbar_Mode);


    pragma Inline (H_Bar);
    pragma Inline (V_Bar);

    pragma Inline (Current_Selection);
    pragma Inline (Display);
    pragma Inline (Find_Item);
    pragma Inline (Top_Item);
    pragma Inline (Sort);

    pragma Inline (Get_Scrollbar_Mode);
    pragma Inline (Set_Scrollbar_Mode);
    pragma Inline (Get_H_Position);
    pragma Inline (Set_H_Position);
    pragma Inline (Get_V_Position);
    pragma Inline (Set_V_Position);
    pragma Inline (Set_Vertical_Left);
    pragma Inline (Set_Vertical_Right);
    pragma Inline (Get_Scrollbar_Size);
    pragma Inline (Set_Scrollbar_Size);

    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Resize);
    pragma Inline (Bounding_Box);
    pragma Inline (Left_Edge);
    pragma Inline (Redraw_Line);
    pragma Inline (Redraw_List);

    pragma Inline (Full_List_Width);
    pragma Inline (Full_List_Height);
    pragma Inline (Average_Item_Height);
    pragma Inline (Item_Quick_Height);

    pragma Inline (New_List);
    pragma Inline (Inserting);
    pragma Inline (Deleting);
    pragma Inline (Replacing);
    pragma Inline (Swapping);

    pragma Inline (Draw);
    pragma Inline (Handle);


    --  Needed to ensure chars_ptr storage is properly cleaned up
    type Item_Text_Hook_Final_Controller is new Ada.Finalization.Controlled with null record;

    overriding procedure Finalize
           (This : in out Item_Text_Hook_Final_Controller);

    Cleanup : Item_Text_Hook_Final_Controller;


end FLTK.Widgets.Groups.Browsers;


