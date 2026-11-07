

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Unchecked_Deallocation,
    FLTK.Hook_Exceptions,
    FLTK.Widgets.Groups,
    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Menus.Menu_Bars.Systemwide is


    package Chk renames Ada.Assertions;

    procedure Free_Item is new Ada.Unchecked_Deallocation
        (Object => FLTK.Menu_Items.Menu_Item, Name => Item_Access);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_sys_menu_bar
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_sys_menu_bar, "new_fl_sys_menu_bar");
    pragma Inline (new_fl_sys_menu_bar);

    procedure free_fl_sys_menu_bar
           (M : in Storage.Integer_Address);
    pragma Import (C, free_fl_sys_menu_bar, "free_fl_sys_menu_bar");
    pragma Inline (free_fl_sys_menu_bar);




    --  Menu Items  --

    function fl_sys_menu_bar_add
           (M : in Storage.Integer_Address;
            T : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_add, "fl_sys_menu_bar_add");
    pragma Inline (fl_sys_menu_bar_add);

    function fl_sys_menu_bar_add2
           (M : in Storage.Integer_Address;
            T : in Interfaces.C.char_array;
            S : in Interfaces.C.int;
            U : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_add2, "fl_sys_menu_bar_add2");
    pragma Inline (fl_sys_menu_bar_add2);

    function fl_sys_menu_bar_add3
           (M    : in Storage.Integer_Address;
            T, S : in Interfaces.C.char_array;
            U    : in Storage.Integer_Address;
            F    : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_add3, "fl_sys_menu_bar_add3");
    pragma Inline (fl_sys_menu_bar_add3);

    function fl_sys_menu_bar_insert
           (M : in Storage.Integer_Address;
            P : in Interfaces.C.int;
            T : in Interfaces.C.char_array;
            S : in Interfaces.C.int;
            U : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_insert, "fl_sys_menu_bar_insert");
    pragma Inline (fl_sys_menu_bar_insert);

    function fl_sys_menu_bar_insert2
           (M    : in Storage.Integer_Address;
            P    : in Interfaces.C.int;
            T, S : in Interfaces.C.char_array;
            U    : in Storage.Integer_Address;
            F    : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_insert2, "fl_sys_menu_bar_insert2");
    pragma Inline (fl_sys_menu_bar_insert2);

    function fl_sys_menu_bar_set_menu
           (M, D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_set_menu, "fl_sys_menu_bar_set_menu");
    pragma Inline (fl_sys_menu_bar_set_menu);

    procedure fl_sys_menu_bar_remove
           (M : in Storage.Integer_Address;
            P : in Interfaces.C.int);
    pragma Import (C, fl_sys_menu_bar_remove, "fl_sys_menu_bar_remove");
    pragma Inline (fl_sys_menu_bar_remove);

    procedure fl_sys_menu_bar_clear
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_sys_menu_bar_clear, "fl_sys_menu_bar_clear");
    pragma Inline (fl_sys_menu_bar_clear);

    function fl_sys_menu_bar_clear_submenu
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_clear_submenu, "fl_sys_menu_bar_clear_submenu");
    pragma Inline (fl_sys_menu_bar_clear_submenu);




    --  Item Query  --

    function fl_sys_menu_bar_get_item
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_sys_menu_bar_get_item, "fl_sys_menu_bar_get_item");
    pragma Inline (fl_sys_menu_bar_get_item);




    --  Label, Shortcut, Flags  --

    procedure fl_sys_menu_bar_setonly
           (M, I : in Storage.Integer_Address);
    pragma Import (C, fl_sys_menu_bar_setonly, "fl_sys_menu_bar_setonly");
    pragma Inline (fl_sys_menu_bar_setonly);

    function fl_sys_menu_bar_replace
           (M : in     Storage.Integer_Address;
            I : in     Interfaces.C.int;
            T : in     Interfaces.C.Strings.chars_ptr;
            O :    out Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_replace, "fl_sys_menu_bar_replace");
    pragma Inline (fl_sys_menu_bar_replace);

    procedure fl_sys_menu_bar_shortcut
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int;
            S : in Interfaces.C.int);
    pragma Import (C, fl_sys_menu_bar_shortcut, "fl_sys_menu_bar_shortcut");
    pragma Inline (fl_sys_menu_bar_shortcut);

    function fl_sys_menu_bar_get_mode
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_get_mode, "fl_sys_menu_bar_get_mode");
    pragma Inline (fl_sys_menu_bar_get_mode);

    procedure fl_sys_menu_bar_set_mode
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int;
            F : in Interfaces.C.int);
    pragma Import (C, fl_sys_menu_bar_set_mode, "fl_sys_menu_bar_set_mode");
    pragma Inline (fl_sys_menu_bar_set_mode);




    --  Global  --

    procedure fl_sys_menu_bar_global
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_sys_menu_bar_global, "fl_sys_menu_bar_global");
    pragma Inline (fl_sys_menu_bar_global);

    procedure fl_sys_menu_bar_update
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_sys_menu_bar_update, "fl_sys_menu_bar_update");
    pragma Inline (fl_sys_menu_bar_update);




    --  macOS Only  --

    procedure fl_sys_menu_bar_about
           (CB : in Storage.Integer_Address);
    pragma Import (C, fl_sys_menu_bar_about, "fl_sys_menu_bar_about");
    pragma Inline (fl_sys_menu_bar_about);

    function fl_sys_menu_bar_get_window_menu_style
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_get_window_menu_style,
        "fl_sys_menu_bar_get_window_menu_style");
    pragma Inline (fl_sys_menu_bar_get_window_menu_style);

    procedure fl_sys_menu_bar_set_window_menu_style
           (S : in Interfaces.C.int);
    pragma Import (C, fl_sys_menu_bar_set_window_menu_style,
        "fl_sys_menu_bar_set_window_menu_style");
    pragma Inline (fl_sys_menu_bar_set_window_menu_style);

    procedure fl_sys_menu_bar_create_window_menu;
    pragma Import (C, fl_sys_menu_bar_create_window_menu,
        "fl_sys_menu_bar_create_window_menu");
    pragma Inline (fl_sys_menu_bar_create_window_menu);




    ---------------------
    --  Callback Hook  --
    ---------------------

    About_Func : About_Callback := null;

    procedure About_Callback_Hook
           (Widget_Ptr, User_Data : in Storage.Integer_Address);

    pragma Convention (C, About_Callback_Hook);

    procedure About_Callback_Hook
           (Widget_Ptr, User_Data : in Storage.Integer_Address)
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        pragma Unreferenced (Widget_Ptr, User_Data);
    begin
        if About_Func /= null then
            About_Func.all;
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end About_Callback_Hook;




    --  Drawing, Events  --

    procedure fl_sys_menu_bar_draw
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_sys_menu_bar_draw, "fl_sys_menu_bar_draw");
    pragma Inline (fl_sys_menu_bar_draw);

    function fl_sys_menu_bar_handle
           (M : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_sys_menu_bar_handle, "fl_sys_menu_bar_handle");
    pragma Inline (fl_sys_menu_bar_handle);




    --  Initialize  --

    function fl_menu_value
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_value, "fl_menu_value");
    pragma Inline (fl_menu_value);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out System_Menu_Bar) is
    begin
        Extra_Final (Menu_Bar (This));
    end Extra_Final;


    procedure Finalize
           (This : in out System_Menu_Bar) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_sys_menu_bar (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out System_Menu_Bar;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Menu_Bar (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out System_Menu_Bar) is
    begin
        This.Draw_Ptr     := fl_sys_menu_bar_draw'Address;
        This.Handle_Ptr   := fl_sys_menu_bar_handle'Address;
        This.Get_Item_Ptr := fl_sys_menu_bar_get_item'Address;
        This.Value_Ptr    := fl_menu_value'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return System_Menu_Bar is
        begin
            return This : System_Menu_Bar do
                This.Void_Ptr := new_fl_sys_menu_bar
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
            return System_Menu_Bar is
        begin
            return This : System_Menu_Bar := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Menu Items  --

    procedure Add_Items
           (This : in out System_Menu_Bar;
            Text : in     String)
    is
        Ignore : constant Interfaces.C.int := fl_sys_menu_bar_add
            (This.Void_Ptr, Interfaces.C.To_C (Text));
    begin
        This.Adjust_Item_Store;
    end Add_Items;


    function Add_Items
           (This : in out System_Menu_Bar;
            Text : in     String)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_sys_menu_bar_add
            (This.Void_Ptr, Interfaces.C.To_C (Text));
    begin
        This.Adjust_Item_Store;
        return Index (Added_Spot + 1);
    end Add_Items;


    procedure Add
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_sys_menu_bar_add2
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (To_C (Shortcut)),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
    end Add;


    function Add
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_sys_menu_bar_add2
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
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_sys_menu_bar_add3
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.To_C (Shortcut),
            Callback_Convert.To_Address (Action),
            MFlag_To_Cint (Flags));
    begin
        This.Adjust_Item_Store;
    end Add;


    function Add
           (This     : in out System_Menu_Bar;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_sys_menu_bar_add3
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
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_sys_menu_bar_insert
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
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     Key_Combo := No_Key;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_sys_menu_bar_insert
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
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
    is
        Ignore : constant Interfaces.C.int := fl_sys_menu_bar_insert2
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
           (This     : in out System_Menu_Bar;
            Place    : in     Index;
            Text     : in     String;
            Action   : in     Widget_Callback := null;
            Shortcut : in     String;
            Flags    : in     Menu_Flag := Flag_Normal)
        return Index
    is
        Added_Spot : constant Interfaces.C.int := fl_sys_menu_bar_insert2
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


    procedure Use_Same_Items
           (This  : in out System_Menu_Bar;
            Donor : in     Menu'Class) is
    begin
        --  The shim gives this menu its own copy of the donor's items and
        --  texts, since the donor frees its own (FLTKAda-BUGS.md 38)
        if fl_sys_menu_bar_set_menu (This.Void_Ptr, Donor.Void_Ptr) /= 0 then
            raise Storage_Error with "Fl_Menu_Item array could not be allocated";
        end if;
        This.Adjust_Item_Store;
    end Use_Same_Items;


    procedure Remove
           (This  : in out System_Menu_Bar;
            Place : in     Index) is
    begin
        fl_sys_menu_bar_remove (This.Void_Ptr, Interfaces.C.int (Place) - 1);
        This.Adjust_Item_Store;
    end Remove;


    procedure Clear
           (This : in out System_Menu_Bar) is
    begin
        for Item of This.My_Items loop
            Free_Item (Item);
        end loop;
        This.My_Items.Clear;
        fl_sys_menu_bar_clear (This.Void_Ptr);
    end Clear;


    procedure Clear_Submenu
           (This  : in out System_Menu_Bar;
            Place : in     Index)
    is
        Result : constant Interfaces.C.int := fl_sys_menu_bar_clear_submenu
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
        "Call to Fl_Sys_Menu_Bar::clear_submenu returned unexpected int result of " &
        Interfaces.C.int'Image (Result);
    end Clear_Submenu;




    --  Item Query  --

    function Item
           (This  : in System_Menu_Bar;
            Place : in Index)
        return FLTK.Menu_Items.Menu_Item_Reference is
    begin
        return Menu_Bar (This).Item (Place);
    end Item;




    --  Label, Shortcut, Flags  --

    procedure Set_Only
           (This : in out System_Menu_Bar;
            Item : in out FLTK.Menu_Items.Menu_Item) is
    begin
        fl_sys_menu_bar_setonly (This.Void_Ptr, Wrapper (Item).Void_Ptr);
    end Set_Only;


    procedure Set_Label
           (This  : in out System_Menu_Bar;
            Place : in     Index;
            Text  : in     String)
    is
        Copy : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.New_String (Text);
        Old  : Interfaces.C.Strings.chars_ptr;
        Kept : constant Boolean := fl_sys_menu_bar_replace
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Copy, Old) /= 0;
    begin
        This.Note_Label (Old, Copy, Kept);
    end Set_Label;


    procedure Set_Shortcut
           (This  : in out System_Menu_Bar;
            Place : in     Index;
            Press : in     Key_Combo) is
    begin
        fl_sys_menu_bar_shortcut
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            Interfaces.C.int (To_C (Press)));
    end Set_Shortcut;


    function Get_Flags
           (This  : in System_Menu_Bar;
            Place : in Index)
        return Menu_Flag is
    begin
        return Cint_To_MFlag
            (fl_sys_menu_bar_get_mode (This.Void_Ptr, Interfaces.C.int (Place) - 1));
    end Get_Flags;


    procedure Set_Flags
           (This  : in out System_Menu_Bar;
            Place : in     Index;
            Flags : in     Menu_Flag) is
    begin
        fl_sys_menu_bar_set_mode
           (This.Void_Ptr,
            Interfaces.C.int (Place) - 1,
            MFlag_To_Cint (Flags));
    end Set_Flags;




    --  Global  --

    procedure Make_Global
           (This : in out System_Menu_Bar) is
    begin
        fl_sys_menu_bar_global (This.Void_Ptr);
    end Make_Global;


    procedure Update
           (This : in out System_Menu_Bar) is
    begin
        fl_sys_menu_bar_update (This.Void_Ptr);
    end Update;





    --  macOS Only  --

    procedure Set_About_Callback
           (Func : in About_Callback) is
    begin
        About_Func := Func;
        fl_sys_menu_bar_about (Storage.To_Integer (About_Callback_Hook'Address));
    end Set_About_Callback;


    function Get_Window_Menu_Style
        return Window_Menu_Style_Kind
    is
        Result : constant Interfaces.C.int := fl_sys_menu_bar_get_window_menu_style;
    begin
        return Window_Menu_Style_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Sys_Menu_Bar::window_menu_style returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Window_Menu_Style;


    procedure Set_Window_Menu_Style
           (To : in Window_Menu_Style_Kind) is
    begin
        fl_sys_menu_bar_set_window_menu_style (Window_Menu_Style_Kind'Pos (To));
    end Set_Window_Menu_Style;


    procedure Create_Window_Menu is
    begin
        fl_sys_menu_bar_create_window_menu;
    end Create_Window_Menu;




    --  Drawing  --

    procedure Draw
           (This : in out System_Menu_Bar) is
    begin
        Menu_Bar (This).Draw;
    end Draw;


end FLTK.Widgets.Menus.Menu_Bars.Systemwide;


