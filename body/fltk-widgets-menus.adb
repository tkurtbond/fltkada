

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Unchecked_Deallocation,
    FLTK.Widgets.Groups,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Menus is


    package Chk renames Ada.Assertions;

    procedure Free_Item is new Ada.Unchecked_Deallocation
        (Object => FLTK.Menu_Items.Menu_Item, Name => Item_Access);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function null_fl_menu_item
        return Storage.Integer_Address;
    pragma Import (C, null_fl_menu_item, "null_fl_menu_item");
    pragma Inline (null_fl_menu_item);

    procedure free_fl_menu_item
           (MI : in Storage.Integer_Address);
    pragma Import (C, free_fl_menu_item, "free_fl_menu_item");
    pragma Inline (free_fl_menu_item);

    function new_fl_menu
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_menu, "new_fl_menu");
    pragma Inline (new_fl_menu);

    procedure free_fl_menu
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_menu, "free_fl_menu");
    pragma Inline (free_fl_menu);




    --  Menu Items  --

    function fl_menu_add
           (M : in Storage.Integer_Address;
            T : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_add, "fl_menu_add");
    pragma Inline (fl_menu_add);

    function fl_menu_add2
           (M : in Storage.Integer_Address;
            T : in Interfaces.C.char_array;
            S : in Interfaces.C.int;
            U : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_add2, "fl_menu_add2");
    pragma Inline (fl_menu_add2);

    function fl_menu_add3
           (M    : in Storage.Integer_Address;
            T, S : in Interfaces.C.char_array;
            U    : in Storage.Integer_Address;
            F    : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_add3, "fl_menu_add3");
    pragma Inline (fl_menu_add3);

    function fl_menu_insert
           (M : in Storage.Integer_Address;
            P : in Interfaces.C.int;
            T : in Interfaces.C.char_array;
            S : in Interfaces.C.int;
            U : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_insert, "fl_menu_insert");
    pragma Inline (fl_menu_insert);

    function fl_menu_insert2
           (M    : in Storage.Integer_Address;
            P    : in Interfaces.C.int;
            T, S : in Interfaces.C.char_array;
            U    : in Storage.Integer_Address;
            F    : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_insert2, "fl_menu_insert2");
    pragma Inline (fl_menu_insert2);

    procedure fl_menu_copy
           (M, I : in Storage.Integer_Address);
    pragma Import (C, fl_menu_copy, "fl_menu_copy");
    pragma Inline (fl_menu_copy);

    procedure fl_menu_set_menu
           (M, D : in Storage.Integer_Address);
    pragma Import (C, fl_menu_set_menu, "fl_menu_set_menu");
    pragma Inline (fl_menu_set_menu);

    procedure fl_menu_remove
           (M : in Storage.Integer_Address;
            P : in Interfaces.C.int);
    pragma Import (C, fl_menu_remove, "fl_menu_remove");
    pragma Inline (fl_menu_remove);

    procedure fl_menu_clear
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_clear, "fl_menu_clear");
    pragma Inline (fl_menu_clear);

    function fl_menu_clear_submenu
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_clear_submenu, "fl_menu_clear_submenu");
    pragma Inline (fl_menu_clear_submenu);




    --  Item Query  --

    function fl_menu_get_item
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_get_item, "fl_menu_get_item");
    pragma Inline (fl_menu_get_item);

    function fl_menu_find_index
           (M : in Storage.Integer_Address;
            T : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_find_index, "fl_menu_find_index");
    pragma Inline (fl_menu_find_index);

    function fl_menu_find_index2
           (M, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_find_index2, "fl_menu_find_index2");
    pragma Inline (fl_menu_find_index2);

    function fl_menu_find_index3
           (M, C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_find_index3, "fl_menu_find_index3");
    --  No inline

    function fl_menu_item_pathname
           (M : in     Storage.Integer_Address;
            B :    out Interfaces.C.char_array;
            L : in     Interfaces.C.int;
            I : in     Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_pathname, "fl_menu_item_pathname");
    pragma Inline (fl_menu_item_pathname);

    function fl_menu_size
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_size, "fl_menu_size");
    pragma Inline (fl_menu_size);




    --  Selection  --

    function fl_menu_text
           (M : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_menu_text, "fl_menu_text");
    pragma Inline (fl_menu_text);

    function fl_menu_value
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_value, "fl_menu_value");
    pragma Inline (fl_menu_value);

    function fl_menu_set_value
           (M, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_set_value, "fl_menu_set_value");
    pragma Inline (fl_menu_set_value);

    function fl_menu_set_value2
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_set_value2, "fl_menu_set_value2");
    pragma Inline (fl_menu_set_value2);




    --  Label, Shortcut, Flags  --

    procedure fl_menu_setonly
           (M, I : in Storage.Integer_Address);
    pragma Import (C, fl_menu_setonly, "fl_menu_setonly");
    pragma Inline (fl_menu_setonly);

    function fl_menu_text2
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_menu_text2, "fl_menu_text2");
    pragma Inline (fl_menu_text2);

    procedure fl_menu_replace
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_menu_replace, "fl_menu_replace");
    pragma Inline (fl_menu_replace);

    procedure fl_menu_shortcut
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int;
            S : in Interfaces.C.int);
    pragma Import (C, fl_menu_shortcut, "fl_menu_shortcut");
    pragma Inline (fl_menu_shortcut);

    function fl_menu_get_mode
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_get_mode, "fl_menu_get_mode");
    pragma Inline (fl_menu_get_mode);

    procedure fl_menu_set_mode
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int;
            F : in Interfaces.C.int);
    pragma Import (C, fl_menu_set_mode, "fl_menu_set_mode");
    pragma Inline (fl_menu_set_mode);




    --  Text Settings  --

    function fl_menu_get_textcolor
           (M : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_menu_get_textcolor, "fl_menu_get_textcolor");
    pragma Inline (fl_menu_get_textcolor);

    procedure fl_menu_set_textcolor
           (M : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_menu_set_textcolor, "fl_menu_set_textcolor");
    pragma Inline (fl_menu_set_textcolor);

    function fl_menu_get_textfont
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_get_textfont, "fl_menu_get_textfont");
    pragma Inline (fl_menu_get_textfont);

    procedure fl_menu_set_textfont
           (M : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_menu_set_textfont, "fl_menu_set_textfont");
    pragma Inline (fl_menu_set_textfont);

    function fl_menu_get_textsize
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_get_textsize, "fl_menu_get_textsize");
    pragma Inline (fl_menu_get_textsize);

    procedure fl_menu_set_textsize
           (M : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_menu_set_textsize, "fl_menu_set_textsize");
    pragma Inline (fl_menu_set_textsize);




    --  Miscellaneous  --

    function fl_menu_get_down_box
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_get_down_box, "fl_menu_get_down_box");
    pragma Inline (fl_menu_get_down_box);

    procedure fl_menu_set_down_box
           (M : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_menu_set_down_box, "fl_menu_set_down_box");
    pragma Inline (fl_menu_set_down_box);

    procedure fl_menu_global
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_global, "fl_menu_global");
    pragma Inline (fl_menu_global);

    function fl_menu_measure
           (M : in     Storage.Integer_Address;
            I : in     Interfaces.C.int;
            H :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_measure, "fl_menu_measure");
    pragma Inline (fl_menu_measure);




    --  Menu Item Methods  --

    function fl_menu_popup
           (M    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int;
            T    : in Interfaces.C.Strings.chars_ptr;
            N    : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_popup, "fl_menu_popup");
    --  No inline

    function fl_menu_pulldown
           (M          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            N          : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_pulldown, "fl_menu_pulldown");
    --  No inline

    function fl_menu_picked
           (M, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_picked, "fl_menu_picked");
    pragma Inline (fl_menu_picked);

    function fl_menu_find_shortcut
           (M, I : in Storage.Integer_Address;
            A    : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_find_shortcut, "fl_menu_find_shortcut");
    pragma Inline (fl_menu_find_shortcut);

    function fl_menu_test_shortcut
           (M : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_test_shortcut, "fl_menu_test_shortcut");
    pragma Inline (fl_menu_test_shortcut);




    --  Dimensions  --

    procedure fl_menu_size2
           (M    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int);
    pragma Import (C, fl_menu_size2, "fl_menu_size2");
    pragma Inline (fl_menu_size2);




    --  Drawing, Events  --

    procedure fl_menu_draw_item
           (M          : in Storage.Integer_Address;
            I          : in Interfaces.C.int;
            X, Y, W, H : in Interfaces.C.int;
            S          : in Interfaces.C.int);
    pragma Import (C, fl_menu_draw_item, "fl_menu_draw_item");
    pragma Inline (fl_menu_draw_item);

    procedure fl_menu_draw
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_menu_draw, "fl_menu_draw");
    pragma Inline (fl_menu_draw);

    function fl_menu_handle
           (M : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_handle, "fl_menu_handle");
    pragma Inline (fl_menu_handle);




    ------------------------
    --  Internal Utility  --
    ------------------------

    procedure Adjust_Item_Store
           (This : in out Menu)
    is
        Target : constant Natural := This.Number_Of_Items;
    begin
        while Natural (This.My_Items.Length) > Target loop
            Free_Item (This.My_Items.Reference (This.My_Items.Last_Index));
            This.My_Items.Delete_Last;
        end loop;
        while Natural (This.My_Items.Length) < Target loop
            This.My_Items.Append (new FLTK.Menu_Items.Menu_Item);
            Wrapper (This.My_Items.Last_Element.all).Needs_Dealloc := False;
        end loop;
    end Adjust_Item_Store;


    --  Needed for setting a whole array of Menu_Items at once
    Null_Item : Storage.Integer_Address := null_fl_menu_item;




    ----------------------
    --  Callback Hooks  --
    ----------------------

    procedure Item_Hook
           (C_Obj, User_Data : in Storage.Integer_Address);
    pragma Export (C, Item_Hook, "menu_item_callback_hook");

    --  Used for Add and Insert, the userdata parameter is the actual callback we want
    procedure Item_Hook
           (C_Obj, User_Data : in Storage.Integer_Address)
    is
        Ada_Ptr : constant Storage.Integer_Address := fl_widget_get_user_data (C_Obj);
        Ada_Widget : access Widget'Class;
        Action : constant Widget_Callback := Callback_Convert.To_Access (User_Data);
    begin
        pragma Assert (Ada_Ptr /= Null_Pointer);
        Ada_Widget := Widget_Convert.To_Pointer (Storage.To_Address (Ada_Ptr));
        Action.all (Ada_Widget.all);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Callback in Fl_Menu_ was supplied Widget pointer with no user data";
    end Item_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Menu) is
    begin
        for Item of This.My_Items loop
            Free_Item (Item);
        end loop;
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Menu) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_menu (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;


    procedure Finalize
           (This : in out Menu_Final_Controller) is
    begin
        if Null_Item /= Null_Pointer then
            free_fl_menu_item (Null_Item);
            Null_Item := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Menu;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Menu) is
    begin
        This.Draw_Ptr     := fl_menu_draw'Address;
        This.Handle_Ptr   := fl_menu_handle'Address;
        This.Get_Item_Ptr := fl_menu_get_item'Address;
        This.Value_Ptr    := fl_menu_value'Address;
        Wrapper (This.My_Find).Needs_Dealloc := False;
        Wrapper (This.My_Pick).Needs_Dealloc := False;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu is
        begin
            return This : Menu do
                This.Void_Ptr := new_fl_menu
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Menu is
        begin
            return This : Menu := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Menu Items  --

    procedure Add
           (This : in out Menu;
            Text : in     String)
    is
        Ignore : constant Interfaces.C.int := fl_menu_add (This.Void_Ptr, Interfaces.C.To_C (Text));
    begin
        This.Adjust_Item_Store;
    end Add;


    function Add
           (This : in out Menu;
            Text : in     String)
        return Index
    is
        Added_Spot : constant Interfaces.C.int :=
            fl_menu_add (This.Void_Ptr, Interfaces.C.To_C (Text));
    begin
        This.Adjust_Item_Store;
        return Index (Added_Spot + 1);
    end Add;


    procedure Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_menu_add2
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (To_C (Shortcut)),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
    end Add;


    function Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_menu_add2
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (To_C (Shortcut)),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
        return Index (Added_Spot + 1);
    end Add;


    procedure Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_menu_add3
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.To_C (Shortcut),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
    end Add;


    function Add
           (This     : in out Menu;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_menu_add3
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.To_C (Shortcut),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
        return Index (Added_Spot + 1);
    end Add;


    procedure Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_menu_insert
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (To_C (Shortcut)),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
    end Insert;


    function Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_menu_insert
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (To_C (Shortcut)),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
        return Index (Added_Spot + 1);
    end Insert;


    procedure Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_menu_insert2
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Interfaces.C.To_C (Text),
            Interfaces.C.To_C (Shortcut),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
    end Insert;


    function Insert
           (This     : in out Menu;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_menu_insert2
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Interfaces.C.To_C (Text),
            Interfaces.C.To_C (Shortcut),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
        return Index (Added_Spot + 1);
    end Insert;


    procedure Set_Items
           (This  : in out Menu;
            Items : in     FLTK.Menu_Items.Menu_Item_Array)
    is
        Pointers : aliased array
            (Items'First .. Integer'Max (Items'First, Items'Last + 1)) of Storage.Integer_Address;
        pragma Convention (C, Pointers);
    begin
        for Place in Pointers'First .. Pointers'Last - 1 loop
            Pointers (Place) := Wrapper (Items (Place)).Void_Ptr;
        end loop;
        Pointers (Pointers'Last) := Null_Item;
        fl_menu_copy (This.Void_Ptr, Storage.To_Integer (Pointers (Pointers'First)'Address));
        This.Adjust_Item_Store;
    end Set_Items;


    procedure Use_Same_Items
           (This  : in out Menu;
            Donor : in     Menu'Class) is
    begin
        --  Donor menu() pointer will be obtained in C++
        fl_menu_set_menu (This.Void_Ptr, Donor.Void_Ptr);
        This.Adjust_Item_Store;
    end Use_Same_Items;


    procedure Remove
           (This  : in out Menu;
            Place : in     Index) is
    begin
        fl_menu_remove (This.Void_Ptr, Interfaces.C.int (Place) - 1);
        This.Adjust_Item_Store;
    end Remove;


    procedure Clear
           (This : in out Menu) is
    begin
        for Item of This.My_Items loop
            Free_Item (Item);
        end loop;
        This.My_Items.Clear;
        fl_menu_clear (This.Void_Ptr);
    end Clear;


    procedure Clear_Submenu
           (This  : in out Menu;
            Place : in     Index)
    is
        Result : constant Interfaces.C.int := fl_menu_clear_submenu
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1);
    begin
        if Result = -1 then
            raise No_Reference_Error;
        else
            pragma Assert (Result = 0);
            This.Adjust_Item_Store;
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Call to Fl_Menu_::clear_submenu returned unexpected int result of " &
        Interfaces.C.int'Image (Result);
    end Clear_Submenu;




    --  Item Query  --

    function Has_Item
           (This  : in Menu;
            Place : in Index)
        return Boolean is
    begin
        return Place in 1 .. This.Number_Of_Items;
    end Has_Item;


    function Has_Item
           (Place : in Cursor)
        return Boolean is
    begin
        return Place.My_Container.Has_Item (Place.My_Index);
    end Has_Item;


    function Item
           (This  : in Menu;
            Place : in Index)
        return FLTK.Menu_Items.Menu_Item_Reference
    is
        function my_get_item
               (M : in Storage.Integer_Address;
                P : in Interfaces.C.int)
            return Storage.Integer_Address;
        for my_get_item'Address use This.Get_Item_Ptr;
        pragma Import (Ada, my_get_item);
    begin
        Wrapper (This.My_Items (Place).all).Void_Ptr :=
            my_get_item (This.Void_Ptr, Interfaces.C.int (Place) - 1);
        return (Data => This.My_Items (Place).all'Unchecked_Access);
    end Item;


    function Item
           (This  : in Menu;
            Place : in Cursor)
        return FLTK.Menu_Items.Menu_Item_Reference is
    begin
        return This.Item (Place.My_Index);
    end Item;


    function Find_Item
           (This : in Menu;
            Name : in String)
        return FLTK.Menu_Items.Menu_Item_Reference
    is
        Place : constant Extended_Index := This.Find_Index (Name);
    begin
        if Place = No_Index then
            raise No_Reference_Error;
        end if;
        return This.Item (Place);
    end Find_Item;


    function Find_Item
           (This   : in Menu;
            Action : in Widget_Callback)
        return FLTK.Menu_Items.Menu_Item_Reference
    is
        Place : constant Extended_Index := This.Find_Index (Action);
    begin
        if Place = No_Index then
            raise No_Reference_Error;
        end if;
        return This.Item (Place);
    end Find_Item;


    function Find_Index
           (This : in Menu;
            Name : in String)
        return Extended_Index
    is
        Result : constant Interfaces.C.int :=
            fl_menu_find_index (This.Void_Ptr, Interfaces.C.To_C (Name));
    begin
        return Extended_Index (Result + 1);
    end Find_Index;


    function Find_Index
           (This : in Menu;
            Item : in FLTK.Menu_Items.Menu_Item)
        return Extended_Index
    is
        Result : constant Interfaces.C.int :=
            fl_menu_find_index2 (This.Void_Ptr, Wrapper (Item).Void_Ptr);
    begin
        return Extended_Index (Result + 1);
    end Find_Index;


    function Find_Index
           (This   : in Menu;
            Action : in Widget_Callback)
        return Extended_Index
    is
        Result : Interfaces.C.int;
    begin
        --  Don't worry, callbacks actually being stored in userdata is
        --  taken into account on the C++ side.
        Result := fl_menu_find_index3 (This.Void_Ptr, Callback_Convert.To_Address (Action));
        return Extended_Index (Result + 1);
    end Find_Index;


    function Item_Pathname
           (This : in Menu)
        return String
    is
        Buffer : Interfaces.C.char_array :=
            (0 .. Interfaces.C.size_t (Item_Path_Max) => Interfaces.C.nul);
        Result : constant Interfaces.C.int := fl_menu_item_pathname
           (This.Void_Ptr,
            Buffer,
            Interfaces.C.int (Item_Path_Max),
            Null_Pointer);
    begin
        case Result is
        when -1 => raise No_Reference_Error;
        when -2 => raise Internal_FLTK_Error with "Item_Pathname buffer of " &
            Integer'Image (Item_Path_Max) & " was not long enough";
        when others =>
            pragma Assert (Result = 0);
            return Interfaces.C.To_Ada (Buffer);
        end case;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Call to Fl_Menu_::item_pathname returned unexpected int result of " &
        Interfaces.C.int'Image (Result);
    end Item_Pathname;


    function Item_Pathname
           (This : in Menu;
            Item : in FLTK.Menu_Items.Menu_Item)
        return String
    is
        Buffer : Interfaces.C.char_array :=
            (0 .. Interfaces.C.size_t (Item_Path_Max) => Interfaces.C.nul);
        Result : constant Interfaces.C.int := fl_menu_item_pathname
           (This.Void_Ptr,
            Buffer,
            Interfaces.C.int (Item_Path_Max),
            Wrapper (Item).Void_Ptr);
    begin
        case Result is
        when -1 => raise No_Reference_Error;
        when -2 => raise Internal_FLTK_Error with "Item_Pathname buffer of " &
            Integer'Image (Item_Path_Max) & " was not long enough";
        when others =>
            pragma Assert (Result = 0);
            return Interfaces.C.To_Ada (Buffer);
        end case;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Call to Fl_Menu_::item_pathname returned unexpected int result of " &
        Interfaces.C.int'Image (Result);
    end Item_Pathname;


    function Number_Of_Items
           (This : in Menu)
        return Natural is
    begin
        return Natural (fl_menu_size (This.Void_Ptr));
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Call to Fl_Menu_::size returned unexpected negative result";
    end Number_Of_Items;




    --  Iteration  --

    function Iterate
           (This : in Menu)
        return Menu_Iterators.Reversible_Iterator'Class is
    begin
        return It : constant Iterator := (My_Container => This'Unrestricted_Access);
    end Iterate;


    function First
           (Object : in Iterator)
        return Cursor is
    begin
        return Cu : constant Cursor :=
           (My_Container => Object.My_Container,
            My_Index     => 1);
    end First;


    function Next
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor is
    begin
        return Cu : constant Cursor :=
           (My_Container => Place.My_Container,
            My_Index     => Place.My_Index + 1);
    end Next;


    function Last
           (Object : in Iterator)
        return Cursor is
    begin
        return Cu : constant Cursor :=
           (My_Container => Object.My_Container,
            My_Index     => Object.My_Container.Number_Of_Items);
    end Last;


    function Previous
           (Object : in Iterator;
            Place  : in Cursor)
        return Cursor is
    begin
        return Cu : constant Cursor :=
           (My_Container => Place.My_Container,
            My_Index     => Place.My_Index - 1);
    end Previous;




    --  Selection  --

    function Chosen
           (This : in Menu)
        return FLTK.Menu_Items.Menu_Item_Reference
    is
        Place : constant Extended_Index := This.Chosen_Index;
    begin
        if Place = No_Index then
            raise No_Reference_Error;
        end if;
        return This.Item (Place);
    end Chosen;


    function Chosen_Label
           (This : in Menu)
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_menu_text (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Chosen_Label;


    function Chosen_Index
           (This : in Menu)
        return Extended_Index
    is
        function my_value
               (M : in Storage.Integer_Address)
            return Interfaces.C.int;
        for my_value'Address use This.Value_Ptr;
        pragma Import (Ada, my_value);
    begin
        return Extended_Index (my_value (This.Void_Ptr) + 1);
    end Chosen_Index;


    procedure Set_Chosen
           (This : in out Menu;
            Item : in     FLTK.Menu_Items.Menu_Item)
    is
        Ignore : Interfaces.C.int;
    begin
        Ignore := fl_menu_set_value (This.Void_Ptr, Wrapper (Item).Void_Ptr);
    end Set_Chosen;


    function Set_Chosen
           (This : in out Menu;
            Item : in     FLTK.Menu_Items.Menu_Item)
        return Boolean is
    begin
        return fl_menu_set_value (This.Void_Ptr, Wrapper (Item).Void_Ptr) /= 0;
    end Set_Chosen;


    procedure Set_Chosen
           (This  : in out Menu;
            Place : in     Index)
    is
        Ignore : Interfaces.C.int;
    begin
        Ignore := fl_menu_set_value2 (This.Void_Ptr, Interfaces.C.int (Place) - 1);
    end Set_Chosen;


    function Set_Chosen
           (This  : in out Menu;
            Place : in     Index)
        return Boolean is
    begin
        return fl_menu_set_value2 (This.Void_Ptr, Interfaces.C.int (Place) - 1) /= 0;
    end Set_Chosen;




    --  Label, Shortcut, Flags  --

    procedure Set_Only
           (This : in out Menu;
            Item : in out FLTK.Menu_Items.Menu_Item) is
    begin
        fl_menu_setonly (This.Void_Ptr, Wrapper (Item).Void_Ptr);
    end Set_Only;


    function Get_Label
           (This  : in Menu;
            Place : in Index)
        return String
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_menu_text2
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1);
    begin
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Get_Label;


    procedure Set_Label
           (This  : in out Menu;
            Place : in     Index;
            Text  : in     String) is
    begin
        fl_menu_replace
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Interfaces.C.To_C (Text));
    end Set_Label;


    procedure Set_Shortcut
           (This  : in out Menu;
            Place : in     Index;
            Press : in     Key_Combo) is
    begin
        fl_menu_shortcut
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Interfaces.C.int (To_C (Press)));
    end Set_Shortcut;


    function Get_Flags
           (This  : in Menu;
            Place : in Index)
        return Menu_Flag is
    begin
        return Cint_To_MFlag (fl_menu_get_mode (This.Void_Ptr, Interfaces.C.int (Place) - 1));
    end Get_Flags;


    procedure Set_Flags
           (This  : in out Menu;
            Place : in     Index;
            Flags : in     Menu_Flag) is
    begin
        fl_menu_set_mode
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            MFlag_To_Cint (Flags));
    end Set_Flags;




    --  Text Settings  --

    function Get_Text_Color
           (This : in Menu)
        return Color is
    begin
        return Color (fl_menu_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Menu;
            To   : in     Color) is
    begin
        fl_menu_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Menu)
        return Font_Kind
    is
        Result : constant Interfaces.C.int := fl_menu_get_textfont (This.Void_Ptr);
    begin
        return Font_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Menu_::textfont returned unexpected Font value of " &
        Interfaces.C.int'Image (Result);
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Menu;
            To   : in     Font_Kind) is
    begin
        fl_menu_set_textfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Menu)
        return Font_Size
    is
        Result : constant Interfaces.C.int := fl_menu_get_textsize (This.Void_Ptr);
    begin
        return Font_Size (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Menu_::textsize returned unexpected Size value of " &
        Interfaces.C.int'Image (Result);
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Menu;
            To   : in     Font_Size) is
    begin
        fl_menu_set_textsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Text_Size;




    --  Miscellaneous  --

    function Get_Down_Box
           (This : in Menu)
        return Box_Kind
    is
        Result : constant Interfaces.C.int := fl_menu_get_down_box (This.Void_Ptr);
    begin
        return Box_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Menu_::down_box returned unexpected Box value of " &
        Interfaces.C.int'Image (Result);
    end Get_Down_Box;


    procedure Set_Down_Box
           (This : in out Menu;
            To   : in     Box_Kind) is
    begin
        fl_menu_set_down_box (This.Void_Ptr, Box_Kind'Pos (To));
    end Set_Down_Box;


    procedure Make_Global
           (This : in out Menu) is
    begin
        fl_menu_global (This.Void_Ptr);
    end Make_Global;


    procedure Measure_Item
           (This : in     Menu;
            Item : in     Index;
            W, H :    out Integer) is
    begin
        W := Integer (fl_menu_measure
           (This.Void_Ptr,
            Interfaces.C.int (Item) - 1,
            Interfaces.C.int (H)));
    end Measure_Item;




    --  Menu Item Methods  --

    function Popup
           (This    : in Menu;
            X, Y    : in Integer;
            Title   : in String := "";
            Initial : in Extended_Index := No_Index)
        return Extended_Index
    is
        C_Title : aliased Interfaces.C.char_array := Interfaces.C.To_C (Title);
        Ptr : constant Storage.Integer_Address := fl_menu_popup
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            (if Title = ""
            then Interfaces.C.Strings.Null_Ptr
            else Interfaces.C.Strings.To_Chars_Ptr (C_Title'Unchecked_Access)),
            Interfaces.C.int (Initial) - 1);
    begin
        return Extended_Index (fl_menu_find_index2 (This.Void_Ptr, Ptr) + 1);
    end Popup;


    function Pulldown
           (This       : in Menu;
            X, Y, W, H : in Integer;
            Initial    : in Extended_Index := No_Index)
        return Extended_Index
    is
        Ptr : constant Storage.Integer_Address := fl_menu_pulldown
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Initial) - 1);
    begin
        return Extended_Index (fl_menu_find_index2 (This.Void_Ptr, Ptr) + 1);
    end Pulldown;


    procedure Picked
           (This : in out Menu;
            Item : in out FLTK.Menu_Items.Menu_Item)
    is
        Ignore : Storage.Integer_Address := fl_menu_picked
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr);
    begin
        null;
    end Picked;


    function Find_Shortcut
           (This        : in out Menu;
            Require_Alt : in     Boolean := False)
        return access FLTK.Menu_Items.Menu_Item'Class
    is
        Tentative_Result : constant Storage.Integer_Address := fl_menu_find_shortcut
           (This.Void_Ptr,
            Null_Pointer,
            Boolean'Pos (Require_Alt));
    begin
        if Tentative_Result = Null_Pointer then
            return null;
        else
            Wrapper (This.My_Find).Void_Ptr := Tentative_Result;
            return This.My_Find'Unchecked_Access;
        end if;
    end Find_Shortcut;


    function Find_Shortcut
           (This        : in out Menu;
            Place       :    out Extended_Index;
            Require_Alt : in     Boolean := False)
        return access FLTK.Menu_Items.Menu_Item'Class
    is
        C_Place : Interfaces.C.int;
        Tentative_Result : constant Storage.Integer_Address := fl_menu_find_shortcut
           (This.Void_Ptr,
            Storage.To_Integer (C_Place'Address),
            Boolean'Pos (Require_Alt));
    begin
        if Tentative_Result = Null_Pointer then
            Place := No_Index;
            return null;
        else
            Wrapper (This.My_Find).Void_Ptr := Tentative_Result;
            Place := Index (C_Place + 1);
            return This.My_Find'Unchecked_Access;
        end if;
    end Find_Shortcut;


    function Test_Shortcut
           (This : in out Menu)
        return access FLTK.Menu_Items.Menu_Item'Class
    is
        Tentative_Pick : constant Storage.Integer_Address := fl_menu_test_shortcut (This.Void_Ptr);
    begin
        if Tentative_Pick = Null_Pointer then
            return null;
        else
            Wrapper (This.My_Pick).Void_Ptr := Tentative_Pick;
            return This.My_Pick'Unchecked_Access;
        end if;
    end Test_Shortcut;




    --  Dimensions  --

    procedure Resize
           (This : in out Menu;
            W, H : in     Integer) is
    begin
        fl_menu_size2
           (This.Void_Ptr,
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Drawing  --

    procedure Draw_Item
           (This       : in out Menu;
            Item       : in     Index;
            X, Y, W, H : in     Integer;
            Selected   : in     Boolean := False) is
    begin
        fl_menu_draw_item
           (This.Void_Ptr,
            Interfaces.C.int (Item) - 1,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Boolean'Pos (Selected));
    end Draw_Item;


end FLTK.Widgets.Menus;


