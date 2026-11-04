

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images,
    FLTK.Multi_Labels,
    FLTK.Widgets;


package FLTK.Menu_Items is


    type Menu_Item is new Wrapper with private;

    type Menu_Item_Reference (Data : not null access Menu_Item'Class) is limited null record
        with Implicit_Dereference => Data;

    type Menu_Item_Array is array (Positive range <>) of Menu_Item;




    package Forge is

        --  Usually you don't bother with this and just add items
        --  to Menus directly using the Add/Insert subprograms in that package.

        function Create
               (Text        : in String;
                Action      : in FLTK.Widgets.Widget_Callback := null;
                Shortcut    : in Key_Combo := No_Key;
                Flags       : in Menu_Flag := Flag_Normal)
            return Menu_Item;

    end Forge;




    --  Callback  --

    function Get_Callback
           (This : in Menu_Item)
        return FLTK.Widgets.Widget_Callback;

    procedure Set_Callback
           (This : in out Menu_Item;
            Func : in     FLTK.Widgets.Widget_Callback);

    procedure Do_Callback
           (This   : in out Menu_Item;
            Widget : in out FLTK.Widgets.Widget'Class);




    --  Settings  --

    function Has_Checkbox
           (This : in Menu_Item)
        return Boolean;

    function Is_Radio
           (This : in Menu_Item)
        return Boolean;

    function Is_Submenu
           (This : in Menu_Item)
        return Boolean;

    function Get_State
           (This : in Menu_Item)
        return Boolean;

    procedure Set_State
           (This : in out Menu_Item;
            To   : in     Boolean);

    procedure Set
           (This : in out Menu_Item);

    procedure Clear
           (This : in out Menu_Item);

    procedure Set_Only
           (This : in out Menu_Item);




    --  Label  --

    function Get_Label
           (This : in Menu_Item)
        return String;

    procedure Set_Label
           (This : in out Menu_Item;
            Text : in     String);

    procedure Set_Label
           (This : in out Menu_Item;
            Kind : in     Label_Kind;
            Text : in     String);

    function Get_Label_Color
           (This : in Menu_Item)
        return Color;

    procedure Set_Label_Color
           (This : in out Menu_Item;
            To   : in     Color);

    function Get_Label_Font
           (This : in Menu_Item)
        return Font_Kind;

    procedure Set_Label_Font
           (This : in out Menu_Item;
            To   : in     Font_Kind);

    function Get_Label_Size
           (This : in Menu_Item)
        return Font_Size;

    procedure Set_Label_Size
           (This : in out Menu_Item;
            To   : in     Font_Size);

    function Get_Label_Kind
           (This : in Menu_Item)
        return Label_Kind;

    procedure Set_Label_Kind
           (This : in out Menu_Item;
            To   : in     Label_Kind);




    --  Shortcut and Flags  --

    function Get_Shortcut
           (This : in Menu_Item)
        return Key_Combo;

    procedure Set_Shortcut
           (This : in out Menu_Item;
            To   : in     Key_Combo);

    function Get_Flags
           (This : in Menu_Item)
        return Menu_Flag;

    procedure Set_Flags
           (This : in out Menu_Item;
            To   : in     Menu_Flag);




    --  Image  --

    function Get_Image
           (This : in Menu_Item)
        return access FLTK.Images.Image'Class;

    --  The item shows the image in place of its text, and keeps the text as
    --  its name, which Get_Label returns and a menu's paths use.  The image
    --  is not copied, so it must last as long as the item shows it.
    procedure Set_Image
           (This : in out Menu_Item;
            Pict : in out FLTK.Images.Image'Class);

    --  Replaces the label with one that can combine text and images.  The
    --  Multi_Label is not copied, so it must last as long as the item does.
    --  The item keeps its name, as with Set_Image.
    procedure Set_Multi_Label
           (This  : in out Menu_Item;
            Label : in out FLTK.Multi_Labels.Multi_Label'Class);




    --  Activity and Visibility  --

    procedure Activate
           (This : in out Menu_Item);

    procedure Deactivate
           (This : in out Menu_Item);

    procedure Show
           (This : in out Menu_Item);

    procedure Hide
           (This : in out Menu_Item);

    function Is_Active
           (This : in Menu_Item)
        return Boolean;

    function Is_Visible
           (This : in Menu_Item)
        return Boolean;

    function Is_Active_And_Visible
           (This : in Menu_Item)
        return Boolean;


private


    type Menu_Item is new Wrapper with record
        Current_Image : access FLTK.Images.Image'Class;
    end record;

    overriding procedure Finalize
           (This : in out Menu_Item);


    pragma Inline (Get_Callback);
    pragma Inline (Set_Callback);
    pragma Inline (Do_Callback);

    pragma Inline (Has_Checkbox);
    pragma Inline (Is_Radio);
    pragma Inline (Get_State);
    pragma Inline (Set_State);
    pragma Inline (Set_Only);

    pragma Inline (Get_Label);
    pragma Inline (Set_Label);
    pragma Inline (Get_Label_Color);
    pragma Inline (Set_Label_Color);
    pragma Inline (Get_Label_Font);
    pragma Inline (Set_Label_Font);
    pragma Inline (Get_Label_Size);
    pragma Inline (Set_Label_Size);
    pragma Inline (Get_Label_Kind);
    pragma Inline (Set_Label_Kind);

    pragma Inline (Get_Shortcut);
    pragma Inline (Set_Shortcut);
    pragma Inline (Get_Flags);
    pragma Inline (Set_Flags);

    pragma Inline (Get_Image);
    pragma Inline (Set_Image);
    pragma Inline (Set_Multi_Label);

    pragma Inline (Activate);
    pragma Inline (Deactivate);
    pragma Inline (Show);
    pragma Inline (Hide);
    pragma Inline (Is_Active);
    pragma Inline (Is_Visible);
    pragma Inline (Is_Active_And_Visible);


end FLTK.Menu_Items;


