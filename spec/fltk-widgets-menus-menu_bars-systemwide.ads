

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Menu_Items;

limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Menus.Menu_Bars.Systemwide is


    type System_Menu_Bar is new Menu_Bar with private;

    type System_Menu_Bar_Reference (Data : not null access System_Menu_Bar'Class) is limited
        null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return System_Menu_Bar;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return System_Menu_Bar;

    end Forge;




    --  Menu Items  --

    procedure Add_Items
           (This : in out System_Menu_Bar;
            Text : in     String);

    function Add_Items
           (This : in out System_Menu_Bar;
            Text : in     String)
        return Index;

    procedure Add
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Add
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Add
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Add
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Insert
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Insert
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Insert
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal);

    function Insert
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Use_Same_Items
           (This  : in out System_Menu_Bar;
            Donor : in     Menu'Class);

    procedure Remove
           (This  : in out System_Menu_Bar;
            Place : in     Index);

    procedure Clear
           (This : in out System_Menu_Bar);

    procedure Clear_Submenu
           (This  : in out System_Menu_Bar;
            Place : in     Index);




    --  Item Query  --

    function Item
           (This  : in System_Menu_Bar;
            Place : in Index)
        return FLTK.Menu_Items.Menu_Item_Reference;




    --  Label, Shortcut, Flags  --

    procedure Set_Only
           (This : in out System_Menu_Bar;
            Item : in out FLTK.Menu_Items.Menu_Item);

    procedure Set_Label
           (This  : in out System_Menu_Bar;
            Place : in     Index;
            Text  : in     String);

    procedure Set_Shortcut
           (This  : in out System_Menu_Bar;
            Place : in     Index;
            Press : in     Key_Combo);

    function Get_Flags
           (This  : in System_Menu_Bar;
            Place : in Index)
        return Menu_Flag;

    procedure Set_Flags
           (This  : in out System_Menu_Bar;
            Place : in     Index;
            Flags : in     Menu_Flag);




    --  Global  --

    procedure Make_Global
           (This : in out System_Menu_Bar);

    procedure Update
           (This : in out System_Menu_Bar);




    --  Drawing  --

    procedure Draw
           (This : in out System_Menu_Bar);


private


    type System_Menu_Bar is new Menu_Bar with null record;

    overriding procedure Initialize
           (This : in out System_Menu_Bar);

    overriding procedure Finalize
           (This : in out System_Menu_Bar);

    procedure Extra_Init
           (This       : in out System_Menu_Bar;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out System_Menu_Bar)
    with Inline;


    pragma Inline (Item);

    pragma Inline (Set_Only);
    pragma Inline (Set_Label);
    pragma Inline (Set_Shortcut);
    pragma Inline (Get_Flags);
    pragma Inline (Set_Flags);

    pragma Inline (Make_Global);
    pragma Inline (Update);

    pragma Inline (Draw);


end FLTK.Widgets.Menus.Menu_Bars.Systemwide;


