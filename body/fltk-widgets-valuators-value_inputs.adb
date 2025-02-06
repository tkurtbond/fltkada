

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Valuators.Value_Inputs is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_value_input
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_value_input, "new_fl_value_input");
    pragma Inline (new_fl_value_input);

    procedure free_fl_value_input
           (A : in Storage.Integer_Address);
    pragma Import (C, free_fl_value_input, "free_fl_value_input");
    pragma Inline (free_fl_value_input);




    --  Attributes  --

    function fl_value_input_get_input
           (V : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_value_input_get_input, "fl_value_input_get_input");
    pragma Inline (fl_value_input_get_input);




    --  Cursors  --

    function fl_value_input_get_cursor_color
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_value_input_get_cursor_color, "fl_value_input_get_cursor_color");
    pragma Inline (fl_value_input_get_cursor_color);

    procedure fl_value_input_set_cursor_color
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_value_input_set_cursor_color, "fl_value_input_set_cursor_color");
    pragma Inline (fl_value_input_set_cursor_color);




    --  Shortcut  --

    function fl_value_input_get_shortcut
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_input_get_shortcut, "fl_value_input_get_shortcut");
    pragma Inline (fl_value_input_get_shortcut);

    procedure fl_value_input_set_shortcut
           (B : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_value_input_set_shortcut, "fl_value_input_set_shortcut");
    pragma Inline (fl_value_input_set_shortcut);




    --  Allow Outside Range  --

    function fl_value_input_is_soft
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_input_is_soft, "fl_value_input_is_soft");
    pragma Inline (fl_value_input_is_soft);

    procedure fl_value_input_set_soft
           (A : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_value_input_set_soft, "fl_value_input_set_soft");
    pragma Inline (fl_value_input_set_soft);




    --  Text Settings  --

    function fl_value_input_get_text_color
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_value_input_get_text_color, "fl_value_input_get_text_color");
    pragma Inline (fl_value_input_get_text_color);

    procedure fl_value_input_set_text_color
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_value_input_set_text_color, "fl_value_input_set_text_color");
    pragma Inline (fl_value_input_set_text_color);

    function fl_value_input_get_text_font
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_input_get_text_font, "fl_value_input_get_text_font");
    pragma Inline (fl_value_input_get_text_font);

    procedure fl_value_input_set_text_font
           (TD : in Storage.Integer_Address;
            F  : in Interfaces.C.int);
    pragma Import (C, fl_value_input_set_text_font, "fl_value_input_set_text_font");
    pragma Inline (fl_value_input_set_text_font);

    function fl_value_input_get_text_size
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_input_get_text_size, "fl_value_input_get_text_size");
    pragma Inline (fl_value_input_get_text_size);

    procedure fl_value_input_set_text_size
           (TD : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_value_input_set_text_size, "fl_value_input_set_text_size");
    pragma Inline (fl_value_input_set_text_size);




    --  Dimensions  --

    procedure fl_value_input_resize
           (TD         : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_value_input_resize, "fl_value_input_resize");
    pragma Inline (fl_value_input_resize);




    --  Drawing, Events  --

    procedure fl_value_input_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_value_input_draw, "fl_value_input_draw");
    pragma Inline (fl_value_input_draw);

    function fl_value_input_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_value_input_handle, "fl_value_input_handle");
    pragma Inline (fl_value_input_handle);




    -------------------
    --  Destructors  --
    -------------------

    --  Making a long distance telephone call
    procedure fl_text_input_extra_final
           (Ada_Obj : in Storage.Integer_Address);
    pragma Import (C, fl_text_input_extra_final, "fl_text_input_extra_final");
    pragma Inline (fl_text_input_extra_final);


    procedure Extra_Final
           (This : in out Value_Input) is
    begin
        fl_text_input_extra_final (Storage.To_Integer (This.My_Input'Address));
        Extra_Final (Valuator (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Value_Input) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_value_input (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Black magic, don't try this at home kids
    procedure fl_text_input_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_text_input_extra_init, "fl_text_input_extra_init");
    pragma Inline (fl_text_input_extra_init);


    procedure Extra_Init
           (This       : in out Value_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Wrapper (This.My_Input).Void_Ptr := fl_value_input_get_input (This.Void_Ptr);
        Wrapper (This.My_Input).Needs_Dealloc := False;
        fl_text_input_extra_init
           (Storage.To_Integer (This.My_Input'Address),
            Interfaces.C.int (This.My_Input.Get_X),
            Interfaces.C.int (This.My_Input.Get_Y),
            Interfaces.C.int (This.My_Input.Get_W),
            Interfaces.C.int (This.My_Input.Get_H),
            Interfaces.C.To_C (This.My_Input.Get_Label));
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Value_Input) is
    begin
        This.Draw_Ptr   := fl_value_input_draw'Address;
        This.Handle_Ptr := fl_value_input_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Value_Input is
        begin
            return This : Value_Input do
                This.Void_Ptr := new_fl_value_input
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
            return Value_Input is
        begin
            return This : Value_Input := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Attributes  --

    function Text_Field
           (This : in out Value_Input)
        return FLTK.Widgets.Inputs.Text.Text_Input_Reference is
    begin
        return (Data => This.My_Input'Unchecked_Access);
    end Text_Field;




    --  Cursors  --

    function Get_Cursor_Color
           (This : in Value_Input)
        return Color is
    begin
        return Color (fl_value_input_get_cursor_color (This.Void_Ptr));
    end Get_Cursor_Color;


    procedure Set_Cursor_Color
           (This : in out Value_Input;
            Col  : in     Color) is
    begin
        fl_value_input_set_cursor_color (This.Void_Ptr, Interfaces.C.unsigned (Col));
    end Set_Cursor_Color;




    --  Shortcut  --

    function Get_Shortcut
           (This : in Value_Input)
        return Key_Combo is
    begin
        return To_Ada (fl_value_input_get_shortcut (This.Void_Ptr));
    end Get_Shortcut;


    procedure Set_Shortcut
           (This : in out Value_Input;
            Key  : in     Key_Combo) is
    begin
        fl_value_input_set_shortcut (This.Void_Ptr, Interfaces.C.int (To_C (Key)));
    end Set_Shortcut;




    --  Allow Outside Range  --

    function Is_Soft
           (This : in Value_Input)
        return Boolean is
    begin
        return fl_value_input_is_soft (This.Void_Ptr) /= 0;
    end Is_Soft;


    procedure Set_Soft
           (This : in out Value_Input;
            To   : in     Boolean) is
    begin
        fl_value_input_set_soft (This.Void_Ptr, Boolean'Pos (To));
    end Set_Soft;




    --  Text Settings  --

    function Get_Text_Color
           (This : in Value_Input)
        return Color is
    begin
        return Color (fl_value_input_get_text_color (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Value_Input;
            Col  : in     Color) is
    begin
        fl_value_input_set_text_color (This.Void_Ptr, Interfaces.C.unsigned (Col));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Value_Input)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_value_input_get_text_font (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Value_Input;
            Font : in     Font_Kind) is
    begin
        fl_value_input_set_text_font (This.Void_Ptr, Font_Kind'Pos (Font));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Value_Input)
        return Font_Size is
    begin
        return Font_Size (fl_value_input_get_text_size (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Value_Input;
            Size : in     Font_Size) is
    begin
        fl_value_input_set_text_size (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    --  Dimensions  --

    procedure Resize
           (This       : in out Value_Input;
            X, Y, W, H : in     Integer) is
    begin
        fl_value_input_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Value_Input) is
    begin
        Valuator (This).Draw;
    end Draw;


    function Handle
           (This  : in out Value_Input;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Valuator (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Valuators.Value_Inputs;


