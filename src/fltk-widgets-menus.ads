

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Menu_Items,
    Ada.Iterator_Interfaces;

limited with

    FLTK.Widgets.Groups;

private with

    Ada.Containers.Vectors,
    Ada.Finalization,
    Interfaces,
    System;


package FLTK.Widgets.Menus is


    type Menu is new Widget with private
        with Default_Iterator  => Iterate,
             Iterator_Element  => FLTK.Menu_Items.Menu_Item_Reference,
             Variable_Indexing => Item;

    type Menu_Reference (Data : not null access Menu'Class) is limited null record
        with Implicit_Dereference => Data;

    subtype Index is Positive;
    subtype Extended_Index is Natural;

    No_Index : constant Extended_Index := Extended_Index'First;

    type Cursor is private;


    --  If your menu item path names are longer than this,
    --  then calls to Item_Pathname will raise an exception.
    Item_Path_Max : constant Integer := 1023;


    No_Reference_Error : exception;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Menu;

    end Forge;




    procedure Add
           (This : in out Menu;
            Text : in     String);

    function Add
           (This : in out Menu;
            Text : in     String)
        return Index;

    procedure Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Set_Items
           (This  : in out Menu;
            Items : in     FLTK.Menu_Items.Menu_Item_Array);

    procedure Use_Same_Items
           (This  : in out Menu;
            Donor : in     Menu'Class);

    procedure Remove
           (This  : in out Menu;
            Place : in     Index);

    procedure Clear
           (This : in out Menu);

    procedure Clear_Submenu
           (This  : in out Menu;
            Place : in     Index);




    function Has_Item
           (This  : in Menu;
            Place : in Index)
        return Boolean;

    function Has_Item
           (Place : in Cursor)
        return Boolean;

    function Item
           (This  : in Menu;
            Place : in Index)
        return FLTK.Menu_Items.Menu_Item_Reference;

    function Item
           (This  : in Menu;
            Place : in Cursor)
        return FLTK.Menu_Items.Menu_Item_Reference;

    function Find_Item
           (This : in Menu;
            Name : in String)
        return FLTK.Menu_Items.Menu_Item_Reference;

    function Find_Item
           (This   : in Menu;
            Action : in Widget_Callback)
        return FLTK.Menu_Items.Menu_Item_Reference;

    function Find_Index
           (This : in Menu;
            Name : in String)
        return Extended_Index;

    function Find_Index
           (This : in Menu;
            Item : in FLTK.Menu_Items.Menu_Item)
        return Extended_Index;

    function Find_Index
           (This   : in Menu;
            Action : in Widget_Callback)
        return Extended_Index;

    function Item_Pathname
           (This : in Menu)
        return String;

    function Item_Pathname
           (This : in Menu;
            Item : in FLTK.Menu_Items.Menu_Item)
        return String;

    --  May not be what you expect due to submenu terminators
    function Number_Of_Items
           (This : in Menu)
        return Natural;




    package Menu_Iterators is
        new Ada.Iterator_Interfaces (Cursor, Has_Item);

    function Iterate
           (This : in Menu)
        return Menu_Iterators.Reversible_Iterator'Class;




    function Chosen
           (This : in Menu)
        return FLTK.Menu_Items.Menu_Item_Reference;

    function Chosen_Label
           (This : in Menu)
        return String;

    function Chosen_Index
           (This : in Menu)
        return Extended_Index;

    procedure Set_Chosen
           (This : in out Menu;
            Item : in     FLTK.Menu_Items.Menu_Item);

    function Set_Chosen
           (This : in out Menu;
            Item : in     FLTK.Menu_Items.Menu_Item)
        return Boolean;

    procedure Set_Chosen
           (This  : in out Menu;
            Place : in     Index);

    function Set_Chosen
           (This  : in out Menu;
            Place : in     Index)
        return Boolean;




    procedure Set_Only
           (This : in out Menu;
            Item : in out FLTK.Menu_Items.Menu_Item);

    function Get_Label
           (This  : in Menu;
            Place : in Index)
        return String;

    procedure Set_Label
           (This  : in out Menu;
            Place : in     Index;
            Text  : in     String);

    procedure Set_Shortcut
           (This  : in out Menu;
            Place : in     Index;
            Press : in     Key_Combo);

    function Get_Flags
           (This  : in Menu;
            Place : in Index)
        return Menu_Flag;

    procedure Set_Flags
           (This  : in out Menu;
            Place : in     Index;
            Flags : in     Menu_Flag);




    function Get_Text_Color
           (This : in Menu)
        return Color;

    procedure Set_Text_Color
           (This : in out Menu;
            To   : in     Color);

    function Get_Text_Font
           (This : in Menu)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Menu;
            To   : in     Font_Kind);

    function Get_Text_Size
           (This : in Menu)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Menu;
            To   : in     Font_Size);




    function Get_Down_Box
           (This : in Menu)
        return Box_Kind;

    procedure Set_Down_Box
           (This : in out Menu;
            To   : in     Box_Kind);

    procedure Make_Global
           (This : in out Menu);

    procedure Measure_Item
           (This : in     Menu;
            Item : in     Index;
            W, H :    out Integer);




    function Popup
           (This    : in Menu;
            X, Y    : in Integer;
            Title   : in String := "";
            Initial : in Extended_Index := No_Index)
        return Extended_Index;

    function Pulldown
           (This       : in Menu;
            X, Y, W, H : in Integer;
            Initial    : in Extended_Index := No_Index)
        return Extended_Index;

    procedure Picked
           (This : in out Menu;
            Item : in out FLTK.Menu_Items.Menu_Item);

    function Find_Shortcut
           (This        : in out Menu;
            Require_Alt : in     Boolean := False)
        return access FLTK.Menu_Items.Menu_Item'Class;

    function Find_Shortcut
           (This        : in out Menu;
            Place       :    out Extended_Index;
            Require_Alt : in     Boolean := False)
        return access FLTK.Menu_Items.Menu_Item'Class;

    function Test_Shortcut
           (This : in out Menu)
        return access FLTK.Menu_Items.Menu_Item'Class;




    procedure Resize
           (This : in out Menu;
            W, H : in     Integer);




    procedure Draw_Item
           (This       : in out Menu;
            Item       : in     Index;
            X, Y, W, H : in     Integer;
            Selected   : in     Boolean := False);


private


    --  I'm not very happy with using a Vector of dynamically allocated
    --  Menu_Item wrappers like this, but I kinda painted myself into a
    --  corner with use of Limited_Controlled and the way the Add method
    --  works for Menus.

    type Item_Access is access FLTK.Menu_Items.Menu_Item;

    package Item_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Item_Access);

    type Menu is new Widget with record
        My_Items     : Item_Vectors.Vector;
        My_Find      : aliased FLTK.Menu_Items.Menu_Item;
        My_Pick      : aliased FLTK.Menu_Items.Menu_Item;
        Get_Item_Ptr : System.Address;
        Value_Ptr    : System.Address;
    end record;

    overriding procedure Initialize
           (This : in out Menu);

    overriding procedure Finalize
           (This : in out Menu);

    procedure Extra_Init
           (This       : in out Menu;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Menu);


    --  Used internally after every time the number of menu items is meddled with
    procedure Adjust_Item_Store
           (This : in out Menu);


    type Cursor is record
        My_Container : access Menu;
        My_Index     : Index'Base := Index'First;
    end record;

    type Iterator is new Menu_Iterators.Reversible_Iterator with record
        My_Container : access Menu;
    end record;

    overriding function First
           (Object : in Iterator)
        return Cursor;

    overriding function Next
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor;

    overriding function Last
           (Object : in Iterator)
        return Cursor;

    overriding function Previous
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor;


    pragma Inline (Has_Item);
    pragma Inline (Item);
    pragma Inline (Find_Item);
    pragma Inline (Find_Index);
    pragma Inline (Number_Of_Items);

    pragma Inline (Iterate);

    pragma Inline (Chosen);
    pragma Inline (Chosen_Label);
    pragma Inline (Chosen_Index);
    pragma Inline (Set_Chosen);

    pragma Inline (Set_Only);
    pragma Inline (Get_Label);
    pragma Inline (Set_Label);
    pragma Inline (Set_Shortcut);
    pragma Inline (Get_Flags);
    pragma Inline (Set_Flags);

    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Get_Down_Box);
    pragma Inline (Set_Down_Box);
    pragma Inline (Make_Global);
    pragma Inline (Measure_Item);

    pragma Inline (Popup);
    pragma Inline (Pulldown);
    pragma Inline (Picked);
    pragma Inline (Test_Shortcut);

    pragma Inline (Resize);

    pragma Inline (Draw_Item);


    type Menu_Final_Controller is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out Menu_Final_Controller);

    Cleanup : Menu_Final_Controller;


end FLTK.Widgets.Menus;


