

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images;

private with

    Ada.Containers.Vectors,
    Interfaces.C,
    System;


package FLTK.Widgets.Groups.Browsers.Textline is


    type Textline_Browser is new Browser with private;

    type Textline_Browser_Reference (Data : not null access Textline_Browser'Class) is
        limited null record with Implicit_Dereference => Data;

    type Line_Position is (Top, Bottom, Middle);

    type Column_Widths is array (Positive range <>) of Integer;


    Browser_Load_Error : exception;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Textline_Browser;

    end Forge;




    --  Directly manipulating lines

    procedure Add
           (This : in out Textline_Browser;
            Text : in     String);

    procedure Insert
           (This  : in out Textline_Browser;
            Above : in     Positive;
            Text  : in     String);

    --  To destination calculated after From line is removed.
    --  Also, note that To/From ordering is opposite from C++
    procedure Move
           (This     : in out Textline_Browser;
            From, To : in     Positive);

    procedure Swap
           (This : in out Textline_Browser;
            A, B : in     Positive);

    procedure Remove
           (This : in out Textline_Browser;
            Line : in     Positive);

    procedure Clear
           (This : in out Textline_Browser);

    function Number_Of_Lines
           (This : in Textline_Browser)
        return Natural;




    --  Loading text and text size

    procedure Load
           (This : in out Textline_Browser;
            File : in     String);

    function Get_Line_Text
           (This : in Textline_Browser;
            Line : in Positive)
        return String;

    procedure Set_Line_Text
           (This : in out Textline_Browser;
            Line : in     Positive;
            Text : in     String);

    function Get_Text_Size
           (This : in Textline_Browser)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Textline_Browser;
            Size : in     Font_Size);




    --  Columns and formatting

    function Get_Column_Character
           (This : in Textline_Browser)
        return Character;

    procedure Set_Column_Character
           (This  : in out Textline_Browser;
            Value : in     Character);

    function Get_Column_Widths
           (This : in Textline_Browser)
        return Column_Widths;

    --  An internal copy is kept of Widths, unlike the C++ version
    procedure Set_Column_Widths
           (This   : in out Textline_Browser;
            Widths : in     Column_Widths);

    function Get_Format_Character
           (This : in Textline_Browser)
        return Character;

    procedure Set_Format_Character
           (This  : in out Textline_Browser;
            Value : in     Character);




    --  Line positioning

    function Get_Top_Line
           (This : in Textline_Browser)
        return Positive;

    procedure Set_Top_Line
           (This : in out Textline_Browser;
            Line : in     Positive);

    procedure Set_Middle_Line
           (This : in out Textline_Browser;
            Line : in     Positive);

    procedure Set_Bottom_Line
           (This : in out Textline_Browser;
            Line : in     Positive);

    procedure Set_Line_Position
           (This  : in out Textline_Browser;
            Line  : in     Positive;
            Place : in     Line_Position);




    --  Line selection

    function Set_Select
           (This  : in out Textline_Browser;
            Line  : in     Positive;
            State : in     Boolean := True)
        return Boolean;

    procedure Set_Select
           (This  : in out Textline_Browser;
            Line  : in     Positive;
            State : in     Boolean := True);

    function Is_Selected
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean;

    function Selected_Index
           (This : in Textline_Browser)
        return Natural;




    --  Visibility, showing, hiding

    function Is_Visible
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean;

    procedure Make_Visible
           (This : in out Textline_Browser;
            Line : in     Positive);

    function Is_Displayed
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean;

    procedure Show_Line
           (This : in out Textline_Browser;
            Line : in     Positive);

    procedure Hide_Line
           (This : in out Textline_Browser;
            Line : in     Positive);

    procedure Show
           (This : in out Textline_Browser);

    procedure Hide
           (This : in out Textline_Browser);




    --  Resizing

    procedure Resize
           (This : in out Textline_Browser;
            W, H : in     Integer);




    --  Icons for specific lines

    function Has_Icon
           (This : in Textline_Browser;
            Line : in Positive)
        return Boolean;

    function Get_Icon
           (This : in Textline_Browser;
            Line : in Positive)
        return FLTK.Images.Image_Reference;

    procedure Set_Icon
           (This : in out Textline_Browser;
            Line : in     Positive;
            Icon : in     FLTK.Images.Image'Class);

    procedure Remove_Icon
           (This : in out Textline_Browser;
            Line : in     Positive);




    --  List dimensions

    function Full_List_Height
           (This : in Textline_Browser)
        return Integer;

    function Average_Item_Height
           (This : in Textline_Browser)
        return Integer;




    --  Item implementation

    function Item_Width
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_Height
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_First
           (This : in Textline_Browser)
        return Item_Cursor;

    function Item_Last
           (This : in Textline_Browser)
        return Item_Cursor;

    function Item_Next
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    function Item_Previous
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Item_Cursor;

    function Item_At
           (This  : in Textline_Browser;
            Index : in Positive)
        return Item_Cursor;

    procedure Item_Select
           (This  : in out Textline_Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True);

    function Item_Selected
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Boolean;

    procedure Item_Swap
           (This : in out Textline_Browser;
            A, B : in     Item_Cursor);

    function Item_Text
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return String;

    procedure Item_Draw
           (This       : in Textline_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer);




    function Line_Number
           (This : in Textline_Browser;
            Item : in Item_Cursor)
        return Natural;


private


    type C_Col_Widths is array (Positive range <>) of aliased Interfaces.C.int
    with Convention => C;

    type C_Col_Widths_Access is access C_Col_Widths;


    type Image_Access is access FLTK.Images.Image'Class;

    package Image_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Image_Access);


    type Item_Override_Fun is
       (Item_Width_Ptr,    Item_Height_Ptr,
        Item_First_Ptr,    Item_Last_Ptr,
        Item_Next_Ptr,     Item_Previous_Ptr,
        Item_At_Ptr,       Item_Select_Ptr,
        Item_Selected_Ptr, Item_Swap_Ptr,
        Item_Text_Ptr,     Item_Draw_Ptr);
    type Item_Override_Fun_Ptr_Array is array (Item_Override_Fun) of System.Address;


    type Textline_Browser is new Browser with record
        Columns            : C_Col_Widths_Access;
        Icons              : Image_Vectors.Vector;
        Item_Override_Ptrs : Item_Override_Fun_Ptr_Array;
    end record;

    overriding procedure Initialize
           (This : in out Textline_Browser);

    overriding procedure Finalize
           (This : in out Textline_Browser);

    procedure Extra_Init
           (This       : in out Textline_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Textline_Browser);


    pragma Inline (Add);
    pragma Inline (Insert);
    pragma Inline (Move);
    pragma Inline (Swap);
    pragma Inline (Remove);
    pragma Inline (Clear);
    pragma Inline (Number_Of_Lines);

    pragma Inline (Set_Line_Text);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Get_Column_Character);
    pragma Inline (Set_Column_Character);
    pragma Inline (Get_Format_Character);
    pragma Inline (Set_Format_Character);

    pragma Inline (Get_Top_Line);
    pragma Inline (Set_Top_Line);
    pragma Inline (Set_Middle_Line);
    pragma Inline (Set_Bottom_Line);
    pragma Inline (Set_Line_Position);

    pragma Inline (Selected_Index);

    pragma Inline (Is_Visible);
    pragma Inline (Make_Visible);
    pragma Inline (Show_Line);
    pragma Inline (Hide_Line);
    pragma Inline (Show);
    pragma Inline (Hide);

    pragma Inline (Has_Icon);
    pragma Inline (Get_Icon);

    pragma Inline (Full_List_Height);
    pragma Inline (Average_Item_Height);

    pragma Inline (Item_Width);
    pragma Inline (Item_Height);
    pragma Inline (Item_First);
    pragma Inline (Item_Last);
    pragma Inline (Item_Next);
    pragma Inline (Item_Previous);
    pragma Inline (Item_At);
    pragma Inline (Item_Select);
    pragma Inline (Item_Swap);
    pragma Inline (Item_Text);
    pragma Inline (Item_Draw);

    pragma Inline (Line_Number);


end FLTK.Widgets.Groups.Browsers.Textline;


