

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Valuators.Value_Outputs is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_value_output
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_value_output, "new_fl_value_output");
    pragma Inline (new_fl_value_output);

    procedure free_fl_value_output
           (A : in Storage.Integer_Address);
    pragma Import (C, free_fl_value_output, "free_fl_value_output");
    pragma Inline (free_fl_value_output);




    function fl_value_output_is_soft
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_output_is_soft, "fl_value_output_is_soft");
    pragma Inline (fl_value_output_is_soft);

    procedure fl_value_output_set_soft
           (A : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_value_output_set_soft, "fl_value_output_set_soft");
    pragma Inline (fl_value_output_set_soft);




    function fl_value_output_get_text_color
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_value_output_get_text_color, "fl_value_output_get_text_color");
    pragma Inline (fl_value_output_get_text_color);

    procedure fl_value_output_set_text_color
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_value_output_set_text_color, "fl_value_output_set_text_color");
    pragma Inline (fl_value_output_set_text_color);

    function fl_value_output_get_text_font
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_output_get_text_font, "fl_value_output_get_text_font");
    pragma Inline (fl_value_output_get_text_font);

    procedure fl_value_output_set_text_font
           (TD : in Storage.Integer_Address;
            F  : in Interfaces.C.int);
    pragma Import (C, fl_value_output_set_text_font, "fl_value_output_set_text_font");
    pragma Inline (fl_value_output_set_text_font);

    function fl_value_output_get_text_size
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_value_output_get_text_size, "fl_value_output_get_text_size");
    pragma Inline (fl_value_output_get_text_size);

    procedure fl_value_output_set_text_size
           (TD : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_value_output_set_text_size, "fl_value_output_set_text_size");
    pragma Inline (fl_value_output_set_text_size);




    procedure fl_value_output_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_value_output_draw, "fl_value_output_draw");
    pragma Inline (fl_value_output_draw);

    function fl_value_output_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_value_output_handle, "fl_value_output_handle");
    pragma Inline (fl_value_output_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Value_Output) is
    begin
        Extra_Final (Valuator (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Value_Output) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_value_output (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Value_Output;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Valuator (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Value_Output) is
    begin
        This.Draw_Ptr := fl_value_output_draw'Address;
        This.Handle_Ptr := fl_value_output_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Value_Output is
        begin
            return This : Value_Output do
                This.Void_Ptr := new_fl_value_output
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
            return Value_Output is
        begin
            return This : Value_Output := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Is_Soft
           (This : in Value_Output)
        return Boolean is
    begin
        return fl_value_output_is_soft (This.Void_Ptr) /= 0;
    end Is_Soft;


    procedure Set_Soft
           (This : in out Value_Output;
            To   : in     Boolean) is
    begin
        fl_value_output_set_soft (This.Void_Ptr, Boolean'Pos (To));
    end Set_Soft;




    function Get_Text_Color
           (This : in Value_Output)
        return Color is
    begin
        return Color (fl_value_output_get_text_color (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Value_Output;
            Col  : in     Color) is
    begin
        fl_value_output_set_text_color (This.Void_Ptr, Interfaces.C.unsigned (Col));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Value_Output)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_value_output_get_text_font (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Value_Output;
            Font : in     Font_Kind) is
    begin
        fl_value_output_set_text_font (This.Void_Ptr, Font_Kind'Pos (Font));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Value_Output)
        return Font_Size is
    begin
        return Font_Size (fl_value_output_get_text_size (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Value_Output;
            Size : in     Font_Size) is
    begin
        fl_value_output_set_text_size (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    procedure Draw
           (This : in out Value_Output) is
    begin
        Valuator (This).Draw;
    end Draw;


    function Handle
           (This  : in out Value_Output;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Valuator (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Valuators.Value_Outputs;


