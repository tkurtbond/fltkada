

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widget_Callback_Conversions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Menu_Items is


    package Callback_Convert renames FLTK.Widget_Callback_Conversions;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_menu_item
           (T    : in Interfaces.C.char_array;
            C    : in Storage.Integer_Address;
            S, F : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_menu_item, "new_fl_menu_item");
    pragma Inline (new_fl_menu_item);

    procedure free_fl_menu_item
           (MI : in Storage.Integer_Address);
    pragma Import (C, free_fl_menu_item, "free_fl_menu_item");
    pragma Inline (free_fl_menu_item);




    --  Callback  --

    function fl_menu_item_get_user_data
           (MI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_item_get_user_data, "fl_menu_item_get_user_data");
    pragma Inline (fl_menu_item_get_user_data);

    procedure fl_menu_item_set_callback
           (MI, C : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_set_callback, "fl_menu_item_set_callback");
    pragma Inline (fl_menu_item_set_callback);

    procedure fl_menu_item_do_callback
           (MI, W : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_do_callback, "fl_menu_item_do_callback");
    pragma Inline (fl_menu_item_do_callback);




    --  Settings  --

    function fl_menu_item_checkbox
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_checkbox, "fl_menu_item_checkbox");
    pragma Inline (fl_menu_item_checkbox);

    function fl_menu_item_radio
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_radio, "fl_menu_item_radio");
    pragma Inline (fl_menu_item_radio);

    function fl_menu_item_submenu
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_submenu, "fl_menu_item_submenu");
    pragma Inline (fl_menu_item_submenu);

    function fl_menu_item_value
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_value, "fl_menu_item_value");
    pragma Inline (fl_menu_item_value);

    procedure fl_menu_item_set
           (MI : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_set, "fl_menu_item_set");
    pragma Inline (fl_menu_item_set);

    procedure fl_menu_item_clear
           (MI : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_clear, "fl_menu_item_clear");
    pragma Inline (fl_menu_item_clear);

    procedure fl_menu_item_setonly
           (MI : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_setonly, "fl_menu_item_setonly");
    pragma Inline (fl_menu_item_setonly);




    --  Label  --

    function fl_menu_item_get_label
           (MI : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_menu_item_get_label, "fl_menu_item_get_label");
    pragma Inline (fl_menu_item_get_label);

    procedure fl_menu_item_set_label
           (MI : in Storage.Integer_Address;
            T  : in Interfaces.C.char_array);
    pragma Import (C, fl_menu_item_set_label, "fl_menu_item_set_label");
    pragma Inline (fl_menu_item_set_label);

    procedure fl_menu_item_set_label2
           (MI : in Storage.Integer_Address;
            K  : in Interfaces.C.int;
            T  : in Interfaces.C.char_array);
    pragma Import (C, fl_menu_item_set_label2, "fl_menu_item_set_label2");
    pragma Inline (fl_menu_item_set_label2);

    function fl_menu_item_get_labelcolor
           (MI : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_menu_item_get_labelcolor, "fl_menu_item_get_labelcolor");
    pragma Inline (fl_menu_item_get_labelcolor);

    procedure fl_menu_item_set_labelcolor
           (MI : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_menu_item_set_labelcolor, "fl_menu_item_set_labelcolor");
    pragma Inline (fl_menu_item_set_labelcolor);

    function fl_menu_item_get_labelfont
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_get_labelfont, "fl_menu_item_get_labelfont");
    pragma Inline (fl_menu_item_get_labelfont);

    procedure fl_menu_item_set_labelfont
           (MI : in Storage.Integer_Address;
            F  : in Interfaces.C.int);
    pragma Import (C, fl_menu_item_set_labelfont, "fl_menu_item_set_labelfont");
    pragma Inline (fl_menu_item_set_labelfont);

    function fl_menu_item_get_labelsize
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_get_labelsize, "fl_menu_item_get_labelsize");
    pragma Inline (fl_menu_item_get_labelsize);

    procedure fl_menu_item_set_labelsize
           (MI : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_menu_item_set_labelsize, "fl_menu_item_set_labelsize");
    pragma Inline (fl_menu_item_set_labelsize);

    function fl_menu_item_get_labeltype
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_get_labeltype, "fl_menu_item_get_labeltype");
    pragma Inline (fl_menu_item_get_labeltype);

    procedure fl_menu_item_set_labeltype
           (MI : in Storage.Integer_Address;
            T  : in Interfaces.C.int);
    pragma Import (C, fl_menu_item_set_labeltype, "fl_menu_item_set_labeltype");
    pragma Inline (fl_menu_item_set_labeltype);




    --  Shortcut and Flags  --

    function fl_menu_item_get_shortcut
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_get_shortcut, "fl_menu_item_get_shortcut");
    pragma Inline (fl_menu_item_get_shortcut);

    procedure fl_menu_item_set_shortcut
           (MI : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_menu_item_set_shortcut, "fl_menu_item_set_shortcut");
    pragma Inline (fl_menu_item_set_shortcut);

    function fl_menu_item_get_flags
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_get_flags, "fl_menu_item_get_flags");
    pragma Inline (fl_menu_item_get_flags);

    procedure fl_menu_item_set_flags
           (MI : in Storage.Integer_Address;
            F  : in Interfaces.C.int);
    pragma Import (C, fl_menu_item_set_flags, "fl_menu_item_set_flags");
    pragma Inline (fl_menu_item_set_flags);




    --  Image  --

    procedure fl_menu_item_image
           (MI, I : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_image, "fl_menu_item_image");
    pragma Inline (fl_menu_item_image);




    --  Activity and Visibility  --

    procedure fl_menu_item_activate
           (MI : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_activate, "fl_menu_item_activate");
    pragma Inline (fl_menu_item_activate);

    procedure fl_menu_item_deactivate
           (MI : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_deactivate, "fl_menu_item_deactivate");
    pragma Inline (fl_menu_item_deactivate);

    procedure fl_menu_item_show
           (MI : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_show, "fl_menu_item_show");
    pragma Inline (fl_menu_item_show);

    procedure fl_menu_item_hide
           (MI : in Storage.Integer_Address);
    pragma Import (C, fl_menu_item_hide, "fl_menu_item_hide");
    pragma Inline (fl_menu_item_hide);

    function fl_menu_item_active
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_active, "fl_menu_item_active");
    pragma Inline (fl_menu_item_active);

    function fl_menu_item_visible
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_visible, "fl_menu_item_visible");
    pragma Inline (fl_menu_item_visible);

    function fl_menu_item_activevisible
           (MI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_item_activevisible, "fl_menu_item_activevisible");
    pragma Inline (fl_menu_item_activevisible);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Menu_Item) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_menu_item (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Text        : in String;
                Action      : in FLTK.Widgets.Widget_Callback := null;
                Shortcut    : in Key_Combo := No_Key;
                Flags       : in Menu_Flag := Flag_Normal)
            return Menu_Item is
        begin
            return This : Menu_Item do
                This.Void_Ptr := new_fl_menu_item
                   (Interfaces.C.To_C (Text),
                    Callback_Convert.To_Address (Action),
                    Interfaces.C.int (To_C (Shortcut)),
                    MFlag_To_Cint (Flags));
            end return;
        end Create;

        pragma Inline (Create);

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Callback  --

    function Get_Callback
           (This : in Menu_Item)
        return FLTK.Widgets.Widget_Callback is
    begin
        return Callback_Convert.To_Access (fl_menu_item_get_user_data (This.Void_Ptr));
    end Get_Callback;


    procedure Set_Callback
           (This : in out Menu_Item;
            Func : in     FLTK.Widgets.Widget_Callback) is
    begin
        --  Coordinating callback vs userdata is done in C++
        fl_menu_item_set_callback
           (This.Void_Ptr,
            Callback_Convert.To_Address (Func));
    end Set_Callback;


    procedure Do_Callback
           (This   : in out Menu_Item;
            Widget : in out FLTK.Widgets.Widget'Class) is
    begin
        fl_menu_item_do_callback (This.Void_Ptr, Wrapper (Widget).Void_Ptr);
    end Do_Callback;




    --  Settings  --

    function Has_Checkbox
           (This : in Menu_Item)
        return Boolean is
    begin
        return fl_menu_item_checkbox (This.Void_Ptr) /= 0;
    end Has_Checkbox;


    function Is_Radio
           (This : in Menu_Item)
        return Boolean is
    begin
        return fl_menu_item_radio (This.Void_Ptr) /= 0;
    end Is_Radio;


    function Is_Submenu
           (This : in Menu_Item)
        return Boolean is
    begin
        return fl_menu_item_submenu (This.Void_Ptr) /= 0;
    end Is_Submenu;


    function Get_State
           (This : in Menu_Item)
        return Boolean is
    begin
        return fl_menu_item_value (This.Void_Ptr) /= 0;
    end Get_State;


    procedure Set_State
           (This : in out Menu_Item;
            To   : in     Boolean) is
    begin
        if To then
            fl_menu_item_set (This.Void_Ptr);
        else
            fl_menu_item_clear (This.Void_Ptr);
        end if;
    end Set_State;


    procedure Set
           (This : in out Menu_Item) is
    begin
        fl_menu_item_set (This.Void_Ptr);
    end Set;


    procedure Clear
           (This : in out Menu_Item) is
    begin
        fl_menu_item_clear (This.Void_Ptr);
    end Clear;


    procedure Set_Only
           (This : in out Menu_Item) is
    begin
        fl_menu_item_setonly (This.Void_Ptr);
    end Set_Only;




    --  Label  --

    function Get_Label
           (This : in Menu_Item)
        return String
    is
        Ptr : Interfaces.C.Strings.chars_ptr := fl_menu_item_get_label (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Label;


    procedure Set_Label
           (This : in out Menu_Item;
            Text : in     String) is
    begin
        fl_menu_item_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Set_Label;


    procedure Set_Label
           (This : in out Menu_Item;
            Kind : in     Label_Kind;
            Text : in     String) is
    begin
        fl_menu_item_set_label2 (This.Void_Ptr, Label_Kind'Pos (Kind), Interfaces.C.To_C (Text));
    end Set_Label;


    function Get_Label_Color
           (This : in Menu_Item)
        return Color is
    begin
        return Color (fl_menu_item_get_labelcolor (This.Void_Ptr));
    end Get_Label_Color;


    procedure Set_Label_Color
           (This : in out Menu_Item;
            To   : in     Color) is
    begin
        fl_menu_item_set_labelcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Label_Color;


    function Get_Label_Font
           (This : in Menu_Item)
        return Font_Kind
    is
        Result : Interfaces.C.int := fl_menu_item_get_labelfont (This.Void_Ptr);
    begin
        return Font_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Menu_Item::labelfont returned unexpected Font value of " &
        Interfaces.C.int'Image (Result);
    end Get_Label_Font;


    procedure Set_Label_Font
           (This : in out Menu_Item;
            To   : in     Font_Kind) is
    begin
        fl_menu_item_set_labelfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Label_Font;


    function Get_Label_Size
           (This : in Menu_Item)
        return Font_Size
    is
        Result : Interfaces.C.int := fl_menu_item_get_labelsize (This.Void_Ptr);
    begin
        return Font_Size (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Menu_Item::labelsize returned unexpected Size value of " &
        Interfaces.C.int'Image (Result);
    end Get_Label_Size;


    procedure Set_Label_Size
           (This : in out Menu_Item;
            To   : in     Font_Size) is
    begin
        fl_menu_item_set_labelsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Label_Size;


    function Get_Label_Kind
           (This : in Menu_Item)
        return Label_Kind
    is
        Result : Interfaces.C.int := fl_menu_item_get_labeltype (This.Void_Ptr);
    begin
        return Label_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Menu_Item::labeltype returned unexpected Kind value of " &
        Interfaces.C.int'Image (Result);
    end Get_Label_Kind;


    procedure Set_Label_Kind
           (This : in out Menu_Item;
            To   : in     Label_Kind) is
    begin
        fl_menu_item_set_labeltype (This.Void_Ptr, Label_Kind'Pos (To));
    end Set_Label_Kind;




    --  Shortcut and Flags  --

    function Get_Shortcut
           (This : in Menu_Item)
        return Key_Combo is
    begin
        return To_Ada (Interfaces.C.unsigned (fl_menu_item_get_shortcut (This.Void_Ptr)));
    end Get_Shortcut;


    procedure Set_Shortcut
           (This : in out Menu_Item;
            To   : in     Key_Combo) is
    begin
        fl_menu_item_set_shortcut (This.Void_Ptr, Interfaces.C.int (To_C (To)));
    end Set_Shortcut;


    function Get_Flags
           (This : in Menu_Item)
        return Menu_Flag is
    begin
        return Cint_To_MFlag (fl_menu_item_get_flags (This.Void_Ptr));
    end Get_Flags;


    procedure Set_Flags
           (This : in out Menu_Item;
            To   : in     Menu_Flag) is
    begin
        fl_menu_item_set_flags (This.Void_Ptr, MFlag_To_Cint (To));
    end Set_Flags;




    --  Image  --

    function Get_Image
           (This : in Menu_Item)
        return access FLTK.Images.Image'Class is
    begin
        return This.Current_Image;
    end Get_Image;


    procedure Set_Image
           (This : in out Menu_Item;
            Pict : in out FLTK.Images.Image'Class) is
    begin
        fl_menu_item_image (This.Void_Ptr, Wrapper (Pict).Void_Ptr);
        This.Current_Image := Pict'Unchecked_Access;
    end Set_Image;




    --  Activity and Visibility  --

    procedure Activate
           (This : in out Menu_Item) is
    begin
        fl_menu_item_activate (This.Void_Ptr);
    end Activate;


    procedure Deactivate
           (This : in out Menu_Item) is
    begin
        fl_menu_item_deactivate (This.Void_Ptr);
    end Deactivate;


    procedure Show
           (This : in out Menu_Item) is
    begin
        fl_menu_item_show (This.Void_Ptr);
    end Show;


    procedure Hide
           (This : in out Menu_Item) is
    begin
        fl_menu_item_hide (This.Void_Ptr);
    end Hide;


    function Is_Active
           (This : in Menu_Item)
        return Boolean is
    begin
        return fl_menu_item_active (This.Void_Ptr) /= 0;
    end Is_Active;


    function Is_Visible
           (This : in Menu_Item)
        return Boolean is
    begin
        return fl_menu_item_visible (This.Void_Ptr) /= 0;
    end Is_Visible;


    function Is_Active_And_Visible
           (This : in Menu_Item)
        return Boolean is
    begin
        return fl_menu_item_activevisible (This.Void_Ptr) /= 0;
    end Is_Active_And_Visible;


end FLTK.Menu_Items;


