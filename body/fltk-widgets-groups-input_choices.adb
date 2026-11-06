

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Groups.Input_Choices is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_input_choice
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_input_choice, "new_fl_input_choice");
    pragma Inline (new_fl_input_choice);

    procedure free_fl_input_choice
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_input_choice, "free_fl_input_choice");
    pragma Inline (free_fl_input_choice);




    --  Attributes  --

    function fl_input_choice_input
           (N : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_input_choice_input, "fl_input_choice_input");
    pragma Inline (fl_input_choice_input);

    function fl_input_choice_menubutton
           (N : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_input_choice_menubutton, "fl_input_choice_menubutton");
    pragma Inline (fl_input_choice_menubutton);




    --  Menu Items  --

    procedure fl_input_choice_clear
           (N : in Storage.Integer_Address);
    pragma Import (C, fl_input_choice_clear, "fl_input_choice_clear");
    pragma Inline (fl_input_choice_clear);




    --  Settings  --

    function fl_input_choice_changed
           (N : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_choice_changed, "fl_input_choice_changed");
    pragma Inline (fl_input_choice_changed);

    procedure fl_input_choice_clear_changed
           (N : in Storage.Integer_Address);
    pragma Import (C, fl_input_choice_clear_changed, "fl_input_choice_clear_changed");
    pragma Inline (fl_input_choice_clear_changed);

    procedure fl_input_choice_set_changed
           (N : in Storage.Integer_Address);
    pragma Import (C, fl_input_choice_set_changed, "fl_input_choice_set_changed");
    pragma Inline (fl_input_choice_set_changed);

    function fl_input_choice_get_down_box
           (N : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_choice_get_down_box, "fl_input_choice_get_down_box");
    pragma Inline (fl_input_choice_get_down_box);

    procedure fl_input_choice_set_down_box
           (N : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_choice_set_down_box, "fl_input_choice_set_down_box");
    pragma Inline (fl_input_choice_set_down_box);

    function fl_input_choice_get_textcolor
           (N : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_input_choice_get_textcolor, "fl_input_choice_get_textcolor");
    pragma Inline (fl_input_choice_get_textcolor);

    procedure fl_input_choice_set_textcolor
           (N : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_input_choice_set_textcolor, "fl_input_choice_set_textcolor");
    pragma Inline (fl_input_choice_set_textcolor);

    function fl_input_choice_get_textfont
           (N : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_choice_get_textfont, "fl_input_choice_get_textfont");
    pragma Inline (fl_input_choice_get_textfont);

    procedure fl_input_choice_set_textfont
           (N : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_choice_set_textfont, "fl_input_choice_set_textfont");
    pragma Inline (fl_input_choice_set_textfont);

    function fl_input_choice_get_textsize
           (N : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_input_choice_get_textsize, "fl_input_choice_get_textsize");
    pragma Inline (fl_input_choice_get_textsize);

    procedure fl_input_choice_set_textsize
           (N : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_input_choice_set_textsize, "fl_input_choice_set_textsize");
    pragma Inline (fl_input_choice_set_textsize);

    function fl_input_choice_get_value
           (N : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_input_choice_get_value, "fl_input_choice_get_value");
    pragma Inline (fl_input_choice_get_value);

    procedure fl_input_choice_set_value
           (N : in Storage.Integer_Address;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_input_choice_set_value, "fl_input_choice_set_value");
    pragma Inline (fl_input_choice_set_value);

    function fl_input_choice_set_value2
           (N : in Storage.Integer_Address;
            T : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_choice_set_value2, "fl_input_choice_set_value2");
    pragma Inline (fl_input_choice_set_value2);




    --  Dimensions  --

    procedure fl_input_choice_resize
           (N          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_input_choice_resize, "fl_input_choice_resize");
    pragma Inline (fl_input_choice_resize);




    --  Drawing, Events  --

    procedure fl_input_choice_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_input_choice_draw, "fl_input_choice_draw");
    pragma Inline (fl_input_choice_draw);

    function fl_input_choice_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_input_choice_handle, "fl_input_choice_handle");
    pragma Inline (fl_input_choice_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Input_Choice) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Input_Choice) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_input_choice (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Translocation initiating...
    procedure fl_text_input_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_text_input_extra_init, "fl_text_input_extra_init");
    pragma Inline (fl_text_input_extra_init);


    --  Crossing the streams
    procedure fl_menu_button_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_menu_button_extra_init, "fl_menu_button_extra_init");
    pragma Inline (fl_menu_button_extra_init);


    procedure Extra_Init
           (This       : in out Input_Choice;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Wrapper (This.My_Input).Void_Ptr := fl_input_choice_input (This.Void_Ptr);
        Wrapper (This.My_Input).Needs_Dealloc := False;
        fl_text_input_extra_init
           (Storage.To_Integer (This.My_Input'Address),
            Interfaces.C.int (This.My_Input.Get_X),
            Interfaces.C.int (This.My_Input.Get_Y),
            Interfaces.C.int (This.My_Input.Get_W),
            Interfaces.C.int (This.My_Input.Get_H),
            Interfaces.C.To_C (This.My_Input.Get_Label));
        Wrapper (This.My_Menu_Button).Void_Ptr := fl_input_choice_menubutton (This.Void_Ptr);
        Wrapper (This.My_Menu_Button).Needs_Dealloc := False;
        fl_menu_button_extra_init
           (Storage.To_Integer (This.My_Menu_Button'Address),
            Interfaces.C.int (This.My_Menu_Button.Get_X),
            Interfaces.C.int (This.My_Menu_Button.Get_Y),
            Interfaces.C.int (This.My_Menu_Button.Get_W),
            Interfaces.C.int (This.My_Menu_Button.Get_H),
            Interfaces.C.To_C (This.My_Menu_Button.Get_Label));
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Input_Choice) is
    begin
        This.Draw_Ptr   := fl_input_choice_draw'Address;
        This.Handle_Ptr := fl_input_choice_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Input_Choice is
        begin
            return This : Input_Choice do
                This.Void_Ptr := new_fl_input_choice
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Input_Choice is
        begin
            return This : Input_Choice := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Attributes  --

    function Text_Field
           (This : in out Input_Choice)
        return FLTK.Widgets.Inputs.Text.Text_Input_Reference is
    begin
        return (Data => This.My_Input'Unchecked_Access);
    end Text_Field;


    function Button_Menu
           (This : in out Input_Choice)
        return FLTK.Widgets.Menus.Menu_Buttons.Menu_Button_Reference is
    begin
        return (Data => This.My_Menu_Button'Unchecked_Access);
    end Button_Menu;




    --  Menu Items  --

    function Has_Item
           (This  : in Input_Choice;
            Place : in FLTK.Widgets.Menus.Index)
        return Boolean is
    begin
        return This.My_Menu_Button.Has_Item (Place);
    end Has_Item;


    function Item
           (This  : in Input_Choice;
            Place : in FLTK.Widgets.Menus.Index)
        return FLTK.Menu_Items.Menu_Item_Reference is
    begin
        return This.My_Menu_Button.Item (Place);
    end Item;


    procedure Use_Same_Items
           (This  : in out Input_Choice;
            Donor : in     FLTK.Widgets.Menus.Menu'Class) is
    begin
        This.My_Menu_Button.Use_Same_Items (Donor);
    end Use_Same_Items;


    procedure Clear
           (This : in out Input_Choice) is
    begin
        fl_input_choice_clear (This.Void_Ptr);
    end Clear;




    --  Settings  --

    function Has_Changed
           (This : in Input_Choice)
        return Boolean is
    begin
        return fl_input_choice_changed (This.Void_Ptr) /= 0;
    end Has_Changed;


    procedure Clear_Changed
           (This : in out Input_Choice) is
    begin
        fl_input_choice_clear_changed (This.Void_Ptr);
    end Clear_Changed;


    procedure Set_Changed
           (This : in out Input_Choice;
            To   : in     Boolean) is
    begin
        if To then
            fl_input_choice_set_changed (This.Void_Ptr);
        end if;
    end Set_Changed;


    function Get_Down_Box
           (This : in Input_Choice)
        return Box_Kind is
    begin
        return Box_Kind'Val (fl_input_choice_get_down_box (This.Void_Ptr));
    end Get_Down_Box;


    procedure Set_Down_Box
           (This : in out Input_Choice;
            To   : in     Box_Kind) is
    begin
        fl_input_choice_set_down_box (This.Void_Ptr, Box_Kind'Pos (To));
    end Set_Down_Box;


    function Get_Text_Color
           (This : in Input_Choice)
        return Color is
    begin
        return Color (fl_input_choice_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Input_Choice;
            To   : in     Color) is
    begin
        fl_input_choice_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Input_Choice)
        return Font_Kind is
    begin
        return Font_Kind (fl_input_choice_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Input_Choice;
            To   : in     Font_Kind) is
    begin
        fl_input_choice_set_textfont (This.Void_Ptr, To_C (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Input_Choice)
        return Font_Size is
    begin
        return Font_Size (fl_input_choice_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Input_Choice;
            To   : in     Font_Size) is
    begin
        fl_input_choice_set_textsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Text_Size;


    function Get_Input
           (This : in Input_Choice)
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_input_choice_get_value (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            --  pointer to internal buffer so no free necessary
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Input;


    procedure Set_Input
           (This : in out Input_Choice;
            To   : in     String) is
    begin
        fl_input_choice_set_value (This.Void_Ptr, Interfaces.C.To_C (To));
    end Set_Input;


    procedure Set_Item
           (This  : in out Input_Choice;
            Place : in     FLTK.Widgets.Menus.Index) is
    begin
        if fl_input_choice_set_value2 (This.Void_Ptr, Interfaces.C.int (Place) - 1) = 0 then
            raise Constraint_Error with "Input_Choice has no item" & Integer'Image (Place);
        end if;
    end Set_Item;




    --  Dimensions  --

    procedure Resize
           (This       : in out Input_Choice;
            X, Y, W, H : in     Integer) is
    begin
        fl_input_choice_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


end FLTK.Widgets.Groups.Input_Choices;


