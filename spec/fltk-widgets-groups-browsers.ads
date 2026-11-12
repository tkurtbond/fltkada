

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Valuators.Sliders.Scrollbars,
    System;

private with

    Ada.Unchecked_Conversion,
    Interfaces.C.Strings;


package FLTK.Widgets.Groups.Browsers is


    type Browser is new Group with private;

    type Browser_Reference (Data : not null access Browser'Class) is
        limited null record with Implicit_Dereference => Data;

    type Item_Cursor is mod System.Memory_Size;

    No_Item : constant Item_Cursor;

    type Sort_Order is (Ascending, Descending);

    --  FLTK's FL_NORMAL_BROWSER, FL_SELECT_BROWSER, FL_HOLD_BROWSER
    --  and FL_MULTI_BROWSER.
    --  (Not Hold_Browser and Multi_Browser, the types in Textline.Hold
    --  and Textline.Multi.)
    type Browser_Kind is (Normal_Kind, Select_Kind, Hold_Kind, Multi_Kind);

    type Scrollbar_Mode is record
        Horizontal : Boolean := True;
        Vertical   : Boolean := True;
        Always_On  : Boolean := False;
    end record;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Browser;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Browser;

    end Forge;




    --  Attributes  --

    function H_Bar
           (This : in out Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;

    function V_Bar
           (This : in out Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference;

    function Get_Kind
           (This : in Browser)
        return Browser_Kind;

    procedure Set_Kind
           (This : in out Browser;
            To   : in     Browser_Kind);




    --  Items  --

    function Set_Select
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            State        : in     Boolean := True;
            Do_Callbacks : in     Boolean := False)
        return Boolean;

    procedure Set_Select
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            State        : in     Boolean := True;
            Do_Callbacks : in     Boolean := False);

    function Select_Only
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            Do_Callbacks : in     Boolean := False)
        return Boolean;

    procedure Select_Only
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            Do_Callbacks : in     Boolean := False);

    function Current_Selection
           (This : in Browser)
        return Item_Cursor;

    function Deselect
           (This         : in out Browser;
            Do_Callbacks : in     Boolean := False)
        return Boolean;

    procedure Deselect
           (This         : in out Browser;
            Do_Callbacks : in     Boolean := False);

    procedure Display
           (This : in out Browser;
            Item : in     Item_Cursor);

    function Is_Displayed
           (This : in Browser;
            Item : in Item_Cursor)
        return Boolean;

    function Find_Item
           (This  : in Browser;
            Y_Pos : in Integer)
        return Item_Cursor;

    --  Is_Displayed and Top_Item are up to date before the browser is first
    --  drawn, and after it scrolls (pofltk 38).
    function Top_Item
           (This : in Browser)
        return Item_Cursor;

    --  Not task safe due to internal issues with converting Ada Strings to char* in C.
    --  Unsure how much that matters since unsure how task safe FLTK is anyway.
    --  Ignore_Case compares the items as FLTK's fl_utf_strcasecmp does
    --  (FL_SORT_CASEINSENSITIVE), so "a" comes before "B"; otherwise they
    --  are compared byte by byte, and "B" comes first.
    procedure Sort
           (This        : in out Browser;
            Order       : in     Sort_Order;
            Ignore_Case : in     Boolean := False);




    --  Scrollbar Settings  --

    function Get_Scrollbar_Mode
           (This : in Browser)
        return Scrollbar_Mode;

    procedure Set_Scrollbar_Mode
           (This : in out Browser;
            Mode : in     Scrollbar_Mode);

    function Get_H_Position
           (This : in Browser)
        return Integer;

    procedure Set_H_Position
           (This  : in out Browser;
            Value : in     Integer);

    function Get_V_Position
           (This : in Browser)
        return Integer;

    procedure Set_V_Position
           (This  : in out Browser;
            Value : in     Integer);

    procedure Set_Vertical_Left
           (This : in out Browser);

    procedure Set_Vertical_Right
           (This : in out Browser);

    function Get_Scrollbar_Size
           (This : in Browser)
        return Integer;

    procedure Set_Scrollbar_Size
           (This  : in out Browser;
            Value : in     Integer);

    --  Pixels added below each line.  Set_Line_Spacing measures a
    --  Textline_Browser's lines again, which FLTK's linespacing doesn't,
    --  so the browser scrolls as far after it as before (pofltk 159).
    function Get_Line_Spacing
           (This : in Browser)
        return Natural;

    procedure Set_Line_Spacing
           (This  : in out Browser;
            Value : in     Natural);




    --  Text Settings  --

    function Get_Text_Color
           (This : in Browser)
        return Color;

    procedure Set_Text_Color
           (This  : in out Browser;
            Value : in     Color);

    function Get_Text_Font
           (This : in Browser)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Browser;
            Font : in     Font_Kind);

    function Get_Text_Size
           (This : in Browser)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Browser;
            Size : in     Font_Size);




    --  Dimensions, Redrawing  --

    procedure Resize
           (This       : in out Browser;
            X, Y, W, H : in     Integer);

    procedure Bounding_Box
           (This       : in     Browser;
            X, Y, W, H :    out Integer);

    function Left_Edge
           (This : in Browser)
        return Integer;

    procedure Redraw_Line
           (This : in out Browser;
            Item : in     Item_Cursor);

    procedure Redraw_List
           (This : in out Browser);




    --  Optional Overrides  --

    --  You may override these subprograms to change the behaviour of the widget
    --  even though these are called from within FLTK.

    function Full_List_Width
           (This : in Browser)
        return Integer;

    function Full_List_Height
           (This : in Browser)
        return Integer;

    function Average_Item_Height
           (This : in Browser)
        return Integer;

    function Item_Quick_Height
           (This : in Browser;
            Item : in Item_Cursor)
        return Integer;




    --  Mandatory Overrides  --

    --  You MUST override these subprograms if deriving a type from Browser or your
    --  program will crash, since they are called from within FLTK and do not have
    --  any implementations given. By default here they will raise an exception.

    function Item_Width
           (This : in Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_Height
           (This : in Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_First
           (This : in Browser)
        return Item_Cursor;

    function Item_Last
           (This : in Browser)
        return Item_Cursor;

    function Item_Next
           (This : in Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    function Item_Previous
           (This : in Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    function Item_At
           (This  : in Browser;
            Index : in Positive)
        return Item_Cursor;

    procedure Item_Select
           (This  : in out Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True);

    function Item_Selected
           (This : in Browser;
            Item : in Item_Cursor)
        return Boolean;

    procedure Item_Swap
           (This : in out Browser;
            A, B : in     Item_Cursor);

    function Item_Text
           (This : in Browser;
            Item : in Item_Cursor)
        return String;

    procedure Item_Draw
           (This       : in Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer);




    --  Cache Invalidation  --

    procedure New_List
           (This : in out Browser);

    procedure Inserting
           (This : in out Browser;
            A, B : in     Item_Cursor);

    procedure Deleting
           (This : in out Browser;
            Item : in     Item_Cursor);

    procedure Replacing
           (This : in out Browser;
            A, B : in     Item_Cursor);

    procedure Swapping
           (This : in out Browser;
            A, B : in     Item_Cursor);


private


    type Wide_High_Fun is
       (Full_List_Width_Ptr,     Full_List_Height_Ptr,
        Average_Item_Height_Ptr, Item_Quick_Height_Ptr);
    type Wide_High_Fun_Ptr_Array is array (Wide_High_Fun) of System.Address;


    type Browser is new Group with record
        Horizon        : aliased Valuators.Sliders.Scrollbars.Scrollbar;
        Vertigo        : aliased Valuators.Sliders.Scrollbars.Scrollbar;
        Text_Store     : Interfaces.C.Strings.chars_ptr_array (1 .. 2);
        Current        : Interfaces.C.size_t := 1;
        Wide_High_Ptrs : Wide_High_Fun_Ptr_Array;
    end record;

    overriding procedure Initialize
           (This : in out Browser);

    overriding procedure Finalize
           (This : in out Browser);

    procedure Extra_Init
           (This       : in out Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Browser);


    --  A pragma Assert until FLTKAda-BUGS.md 28, which release builds
    --  didn't check.
    pragma Compile_Time_Error
       (Item_Cursor'Size /= Storage.Integer_Address'Size,
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
    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);

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
    pragma Inline (Get_Line_Spacing);
    pragma Inline (Set_Line_Spacing);

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


end FLTK.Widgets.Groups.Browsers;


