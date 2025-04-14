

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;


package body FLTK.Widgets.Menus.Menu_Buttons is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_menu_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_menu_button, "new_fl_menu_button");
    pragma Inline (new_fl_menu_button);

    procedure free_fl_menu_button
           (M : in Storage.Integer_Address);
    pragma Import (C, free_fl_menu_button, "free_fl_menu_button");
    pragma Inline (free_fl_menu_button);




    --  Popup  --

    function fl_menu_button_popup
           (M : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_button_popup, "fl_menu_button_popup");
    pragma Inline (fl_menu_button_popup);

    function fl_menu_find_index2
           (M, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_find_index2, "fl_menu_find_index2");
    pragma Inline (fl_menu_find_index2);




    --  Drawing, Events  --

    procedure fl_menu_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_menu_button_draw, "fl_menu_button_draw");
    pragma Inline (fl_menu_button_draw);

    function fl_menu_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_button_handle, "fl_menu_button_handle");
    pragma Inline (fl_menu_button_handle);




    --  Initialize  --

    function fl_menu_get_item
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_get_item, "fl_menu_get_item");
    pragma Inline (fl_menu_get_item);

    function fl_menu_value
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_value, "fl_menu_value");
    pragma Inline (fl_menu_value);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Menu_Button) is
    begin
        Extra_Final (Menu (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Menu_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_menu_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Long distance telephone call receival
    procedure menu_button_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr);
    pragma Export (C, menu_button_extra_init_hook, "menu_button_extra_init_hook");

    procedure menu_button_extra_init_hook
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.Strings.chars_ptr)
    is
        My_Menu_Button : Menu_Button;
        for My_Menu_Button'Address use Storage.To_Address (Ada_Obj);
        pragma Import (Ada, My_Menu_Button);
    begin
        Extra_Init
           (My_Menu_Button,
            Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Interfaces.C.Strings.Value (C_Str));
    end menu_button_extra_init_hook;


    procedure Extra_Init
           (This       : in out Menu_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Menu (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Menu_Button) is
    begin
        This.Draw_Ptr     := fl_menu_button_draw'Address;
        This.Handle_Ptr   := fl_menu_button_handle'Address;
        This.Get_Item_Ptr := fl_menu_get_item'Address;
        This.Value_Ptr    := fl_menu_value'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu_Button is
        begin
            return This : Menu_Button do
                This.Void_Ptr := new_fl_menu_button
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
            return Menu_Button is
        begin
            return This : Menu_Button := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Popup  --

    function Get_Popup_Kind
           (This : in Menu_Button)
        return Popup_Buttons
    is
        Result : constant Interfaces.C.unsigned_char := fl_widget_get_type (This.Void_Ptr);
    begin
        return Popup_Buttons'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Menu_Button::type returned unexpected Popup_Buttons value of " &
        Interfaces.C.unsigned_char'Image (Result);
    end Get_Popup_Kind;


    procedure Set_Popup_Kind
           (This : in out Menu_Button;
            Kind : in     Popup_Buttons) is
    begin
        fl_widget_set_type (This.Void_Ptr, Popup_Buttons'Pos (Kind));
    end Set_Popup_Kind;


    function Popup
           (This : in out Menu_Button)
        return Extended_Index
    is
        use type Interfaces.C.int;
        Ptr : constant Storage.Integer_Address := fl_menu_button_popup (This.Void_Ptr);
    begin
        return Extended_Index (fl_menu_find_index2 (This.Void_Ptr, Ptr) + 1);
    end Popup;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Menu_Button) is
    begin
        Menu (This).Draw;
    end Draw;


    function Handle
           (This  : in out Menu_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Menu (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Menus.Menu_Buttons;


