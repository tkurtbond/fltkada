

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Menu_Items,
    Ada.Iterator_Interfaces;

limited with

    FLTK.Widgets.Groups;

private with

    Ada.Containers.Vectors,
    Interfaces.C.Strings,
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
    Item_Path_Max : constant Natural := Integer'Max (0, FLTK.Buffer_Size - 1);


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




    --  Menu Items  --

    --  Add and Add_Items look for the item first, comparing labels without
    --  their '&'s.  A label already in the (sub)menu is that item: its
    --  callback, shortcut and flags are replaced, and nothing is added.  The
    --  search skips hidden items, other than the first, so a hidden item's
    --  label adds a second item (Fl_Menu_add.cxx:79-91, 173-174, 189-190,
    --  203-206; pofltk 79).

    --  Add_Items splits Text at each '|' and adds each part as an item with
    --  no callback, and returns the last one's index, as FLTK's
    --  add (const char *) does.  A part's label ends at its first tab, and
    --  its shortcut is what follows its last tab, in the form Add's
    --  Shortcut takes ("^a", "#b", "+c", or a number).  FLTK's own splitting
    --  reads only a number there (pofltk 173), and cuts a part after 1022
    --  bytes into several items, dropping a byte at each cut
    --  (FLTK-issues.md F11), so the binding splits the text itself.  Like
    --  Add's, each part of a label between '/'s is cut to 1023 bytes, where
    --  a UTF-8 character starts (pofltk 172).
    --  It was named Add, and no call to it could compile, since the Add
    --  below takes the same two parameters (FLTKAda-BUGS.md 65).
    procedure Add_Items
           (This : in out Menu;
            Text : in     String);

    function Add_Items
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

    --  Add_Text and Insert_Text add an item at the top level that shows
    --  Text as it is:  no '/' submenus, no '_' divider, no '\' escapes, and
    --  '&' and '@' doubled in the label, which FLTK draws as one.  The item
    --  is added under a label no other item has, then given its text, so
    --  an item with the same text is another item, not replaced.  There is
    --  no shortcut.  After pofltk.
    procedure Add_Text
           (This   : in out Menu;
            Text   : in     String;
            Action : in     Widget_Callback := null;
            Flags  : in     Menu_Flag := Flag_Normal);

    function Add_Text
           (This   : in out Menu;
            Text   : in     String;
            Action : in     Widget_Callback := null;
            Flags  : in     Menu_Flag := Flag_Normal)
        return Index;

    procedure Insert_Text
           (This   : in out Menu;
            Place  : in     Index;
            Text   : in     String;
            Action : in     Widget_Callback := null;
            Flags  : in     Menu_Flag := Flag_Normal);

    function Insert_Text
           (This   : in out Menu;
            Place  : in     Index;
            Text   : in     String;
            Action : in     Widget_Callback := null;
            Flags  : in     Menu_Flag := Flag_Normal)
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




    --  Item Query  --

    --  True when there is an item at Place.  An index is a place in FLTK's
    --  array of items, where a terminator ends each submenu and the menu
    --  itself.  Has_Item is false for a terminator, and iteration steps over
    --  them, but Item and Number_Of_Items count them (FLTKAda-BUGS.md 93).
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

    --  FLTK's size (): the highest index, counting each submenu's terminator
    --  and the menu's own.  Not the number of items Has_Item is true for.
    function Number_Of_Items
           (This : in Menu)
        return Natural;




    --  Iteration  --

    package Menu_Iterators is
        new Ada.Iterator_Interfaces (Cursor, Has_Item);

    function Iterate
           (This : in Menu)
        return Menu_Iterators.Reversible_Iterator'Class;




    --  Selection  --

    function Chosen
           (This : in Menu)
        return FLTK.Menu_Items.Menu_Item_Reference;

    function Chosen_Label
           (This : in Menu)
        return String;

    --  Add, Insert, Remove and Clear_Submenu keep the same item chosen, at
    --  its new index, or none once it is removed (pofltk 26).
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




    --  Label, Shortcut, Flags  --

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

    --  The label with each "&&" and "@@" made one:  for an item given its
    --  label by Add_Text, Insert_Text or Set_Item_Text, the text given.
    function Get_Item_Text
           (This  : in Menu;
            Place : in Index)
        return String;

    --  Set_Label, with '&' and '@' doubled so that the item shows Text as
    --  it is.
    procedure Set_Item_Text
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

    --  Submenu is the menu's shape, not a setting:  a title keeps it and
    --  another item doesn't get it (FLTKAda-BUGS.md 106).
    procedure Set_Flags
           (This  : in out Menu;
            Place : in     Index;
            Flags : in     Menu_Flag);

    --  One flag of an item, Inactive or Value, through Get_Flags and
    --  Set_Flags, leaving the others as they are.  Set_Item_Checked changes
    --  only this item; Set_Only turns the rest of a radio group off.  After
    --  pofltk.
    function Is_Item_Active
           (This  : in Menu;
            Place : in Index)
        return Boolean;

    procedure Set_Item_Active
           (This  : in out Menu;
            Place : in     Index;
            To    : in     Boolean);

    function Is_Item_Checked
           (This  : in Menu;
            Place : in Index)
        return Boolean;

    procedure Set_Item_Checked
           (This  : in out Menu;
            Place : in     Index;
            To    : in     Boolean);




    --  Text Settings  --

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




    --  Miscellaneous  --

    function Get_Down_Box
           (This : in Menu)
        return Box_Kind;

    procedure Set_Down_Box
           (This : in out Menu;
            To   : in     Box_Kind);

    --  The box of the pop-up menus' windows.  No_Box, the default, means
    --  the menu's own box (Get_Box), or Flat_Box if that is No_Box too
    --  (Fl_Menu.cxx, menuwindow).
    function Get_Menu_Box
           (This : in Menu)
        return Box_Kind;

    procedure Set_Menu_Box
           (This : in out Menu;
            To   : in     Box_Kind);

    --  Unlike FLTK's global(), the menu may be finalized: its shortcuts then
    --  stop working (pofltk 27).
    procedure Make_Global
           (This : in out Menu);

    procedure Measure_Item
           (This : in     Menu;
            Item : in     Index;
            W, H :    out Integer);




    --  Menu Item Methods  --

    --  Popup and Pulldown wait for the menu's window, or the first window if
    --  the menu is in none, to be exposed first: under Wayland, a menu popped
    --  up over a window not yet on the screen ends the program.
    --
    --  They return the item the user picked, or No_Index, and do no more:  as
    --  in FLTK, they don't call the item's callback or change a toggle or
    --  radio item.  Picked does that (pofltk 150).  They raise Program_Error
    --  for a menu in no window when no window is shown, which leaves nothing
    --  to pop up over; FLTK would crash.
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




    --  Dimensions  --

    procedure Resize
           (This : in out Menu;
            W, H : in     Integer);




    --  Drawing  --

    procedure Draw_Item
           (This       : in out Menu;
            Item       : in     Index;
            X, Y, W, H : in     Integer;
            Selected   : in     Boolean := False);


private


    --  Raises Program_Error when a pop-up of This would have no window to
    --  pop up over (pofltk 150).  Name names the call in the message.
    procedure Check_Popup_Parent
           (This : in Menu'Class;
            Name : in String);


    --  I'm not very happy with using a Vector of dynamically allocated
    --  Menu_Item wrappers like this, but I kinda painted myself into a
    --  corner with use of Limited_Controlled and the way the Add method
    --  works for Menus.

    type Item_Access is access FLTK.Menu_Items.Menu_Item;

    package Item_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Item_Access);

    package Label_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Interfaces.C.Strings.chars_ptr,
        "="          => Interfaces.C.Strings."=");

    --  My_Labels holds the labels from Set_Label that FLTK keeps without
    --  copying them, which it does when the menu doesn't own its strings.
    type Menu is new Widget with record
        My_Items     : Item_Vectors.Vector;
        My_Labels    : Label_Vectors.Vector;
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


    --  Used by Set_Label after FLTK's replace: keeps Text if FLTK kept it,
    --  frees it otherwise, and frees Old, the label replaced, if it was kept.
    procedure Note_Label
           (This : in out Menu;
            Old  : in     Interfaces.C.Strings.chars_ptr;
            Text : in out Interfaces.C.Strings.chars_ptr;
            Kept : in     Boolean);


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
    pragma Inline (Get_Menu_Box);
    pragma Inline (Set_Menu_Box);
    pragma Inline (Make_Global);
    pragma Inline (Measure_Item);

    pragma Inline (Popup);
    pragma Inline (Pulldown);
    pragma Inline (Picked);
    pragma Inline (Test_Shortcut);

    pragma Inline (Resize);

    pragma Inline (Draw_Item);


end FLTK.Widgets.Menus;


