

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.unsigned_char,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Groups.Spinners is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_spinner
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_spinner, "new_fl_spinner");
    pragma Inline (new_fl_spinner);

    procedure free_fl_spinner
           (W : in Storage.Integer_Address);
    pragma Import (C, free_fl_spinner, "free_fl_spinner");
    pragma Inline (free_fl_spinner);




    --  Settings  --

    function fl_spinner_get_color
           (S : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_spinner_get_color, "fl_spinner_get_color");
    pragma Inline (fl_spinner_get_color);

    procedure fl_spinner_set_color
           (S : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_spinner_set_color, "fl_spinner_set_color");
    pragma Inline (fl_spinner_set_color);

    function fl_spinner_get_selection_color
           (S : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_spinner_get_selection_color, "fl_spinner_get_selection_color");
    pragma Inline (fl_spinner_get_selection_color);

    procedure fl_spinner_set_selection_color
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_spinner_set_selection_color, "fl_spinner_set_selection_color");
    pragma Inline (fl_spinner_set_selection_color);

    function fl_spinner_get_textcolor
           (S : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_spinner_get_textcolor, "fl_spinner_get_textcolor");
    pragma Inline (fl_spinner_get_textcolor);

    procedure fl_spinner_set_textcolor
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned);
    pragma Import (C, fl_spinner_set_textcolor, "fl_spinner_set_textcolor");
    pragma Inline (fl_spinner_set_textcolor);

    function fl_spinner_get_textfont
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_spinner_get_textfont, "fl_spinner_get_textfont");
    pragma Inline (fl_spinner_get_textfont);

    procedure fl_spinner_set_textfont
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_spinner_set_textfont, "fl_spinner_set_textfont");
    pragma Inline (fl_spinner_set_textfont);

    function fl_spinner_get_textsize
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_spinner_get_textsize, "fl_spinner_get_textsize");
    pragma Inline (fl_spinner_get_textsize);

    procedure fl_spinner_set_textsize
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_spinner_set_textsize, "fl_spinner_set_textsize");
    pragma Inline (fl_spinner_set_textsize);




    --  Values  --

    function fl_spinner_get_minimum
           (S : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_spinner_get_minimum, "fl_spinner_get_minimum");
    pragma Inline (fl_spinner_get_minimum);

    procedure fl_spinner_set_minimum
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_spinner_set_minimum, "fl_spinner_set_minimum");
    pragma Inline (fl_spinner_set_minimum);

    function fl_spinner_get_maximum
           (S : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_spinner_get_maximum, "fl_spinner_get_maximum");
    pragma Inline (fl_spinner_get_maximum);

    procedure fl_spinner_set_maximum
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_spinner_set_maximum, "fl_spinner_set_maximum");
    pragma Inline (fl_spinner_set_maximum);

    procedure fl_spinner_range
           (S    : in Storage.Integer_Address;
            A, B : in Interfaces.C.double);
    pragma Import (C, fl_spinner_range, "fl_spinner_range");
    pragma Inline (fl_spinner_range);

    function fl_spinner_get_step
           (S : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_spinner_get_step, "fl_spinner_get_step");
    pragma Inline (fl_spinner_get_step);

    procedure fl_spinner_set_step
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_spinner_set_step, "fl_spinner_set_step");
    pragma Inline (fl_spinner_set_step);

    function fl_spinner_get_value
           (S : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_spinner_get_value, "fl_spinner_get_value");
    pragma Inline (fl_spinner_get_value);

    procedure fl_spinner_set_value
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_spinner_set_value, "fl_spinner_set_value");
    pragma Inline (fl_spinner_set_value);




    --  Formatting  --

    function fl_spinner_get_format
           (S : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_spinner_get_format, "fl_spinner_get_format");
    pragma Inline (fl_spinner_get_format);

    procedure fl_spinner_set_format
           (S : in Storage.Integer_Address;
            F : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_spinner_set_format, "fl_spinner_set_format");
    pragma Inline (fl_spinner_set_format);

    function fl_spinner_get_type
           (S : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_spinner_get_type, "fl_spinner_get_type");
    pragma Inline (fl_spinner_get_type);

    procedure fl_spinner_set_type
           (S : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_spinner_set_type, "fl_spinner_set_type");
    pragma Inline (fl_spinner_set_type);




    --  Dimensions  --

    procedure fl_spinner_resize
           (S          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_spinner_resize, "fl_spinner_resize");
    pragma Inline (fl_spinner_resize);




    --  Drawing, Events  --

    procedure fl_spinner_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_spinner_draw, "fl_spinner_draw");
    pragma Inline (fl_spinner_draw);

    function fl_spinner_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_spinner_handle, "fl_spinner_handle");
    pragma Inline (fl_spinner_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Spinner) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Spinner) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_spinner (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Spinner;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Spinner) is
    begin
        This.Draw_Ptr   := fl_spinner_draw'Address;
        This.Handle_Ptr := fl_spinner_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Spinner is
        begin
            return This : Spinner do
                This.Void_Ptr := new_fl_spinner
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
            return Spinner is
        begin
            return This : Spinner := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Settings  --

    function Get_Background_Color
           (This : in Spinner)
        return Color is
    begin
        return Color (fl_spinner_get_color (This.Void_Ptr));
    end Get_Background_Color;


    procedure Set_Background_Color
           (This : in out Spinner;
            To   : in     Color) is
    begin
        fl_spinner_set_color (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Background_Color;


    function Get_Selection_Color
           (This : in Spinner)
        return Color is
    begin
        return Color (fl_spinner_get_selection_color (This.Void_Ptr));
    end Get_Selection_Color;


    procedure Set_Selection_Color
           (This : in out Spinner;
            To   : in     Color) is
    begin
        fl_spinner_set_selection_color (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Selection_Color;


    function Get_Text_Color
           (This : in Spinner)
        return Color is
    begin
        return Color (fl_spinner_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Spinner;
            To   : in     Color) is
    begin
        fl_spinner_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Spinner)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_spinner_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Spinner;
            To   : in     Font_Kind) is
    begin
        fl_spinner_set_textfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Spinner)
        return Font_Size is
    begin
        return Font_Size (fl_spinner_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Spinner;
            To   : in     Font_Size) is
    begin
        fl_spinner_set_textsize (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Text_Size;




    --  Values  --

    function Get_Minimum
           (This : in Spinner)
        return Long_Float is
    begin
        return Long_Float (fl_spinner_get_minimum (This.Void_Ptr));
    end Get_Minimum;


    procedure Set_Minimum
           (This : in out Spinner;
            To   : in     Long_Float) is
    begin
        fl_spinner_set_minimum (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Minimum;


    function Get_Maximum
           (This : in Spinner)
        return Long_Float is
    begin
        return Long_Float (fl_spinner_get_maximum (This.Void_Ptr));
    end Get_Maximum;


    procedure Set_Maximum
           (This : in out Spinner;
            To   : in     Long_Float) is
    begin
        fl_spinner_set_maximum (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Maximum;


    procedure Get_Range
           (This     : in     Spinner;
            Min, Max :    out Long_Float) is
    begin
        Min := Long_Float (fl_spinner_get_minimum (This.Void_Ptr));
        Max := Long_Float (fl_spinner_get_maximum (This.Void_Ptr));
    end Get_Range;


    procedure Set_Range
           (This     : in out Spinner;
            Min, Max : in     Long_Float) is
    begin
        fl_spinner_range
           (This.Void_Ptr,
            Interfaces.C.double (Min),
            Interfaces.C.double (Max));
    end Set_Range;


    function Get_Step
           (This : in Spinner)
        return Long_Float is
    begin
        return Long_Float (fl_spinner_get_step (This.Void_Ptr));
    end Get_Step;


    procedure Set_Step
           (This : in out Spinner;
            To   : in     Long_Float) is
    begin
        fl_spinner_set_step (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Step;


    function Get_Value
           (This : in Spinner)
        return Long_Float is
    begin
        return Long_Float (fl_spinner_get_value (This.Void_Ptr));
    end Get_Value;


    procedure Set_Value
           (This : in out Spinner;
            To   : in     Long_Float) is
    begin
        fl_spinner_set_value (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Value;




    --  Formatting  --

    function Get_Format
           (This : in Spinner)
        return String
    is
        Result : Interfaces.C.Strings.chars_ptr := fl_spinner_get_format (This.Void_Ptr);
    begin
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Get_Format;


    procedure Set_Format
           (This : in out Spinner;
            To   : in     String) is
    begin
        Interfaces.C.Strings.Free (This.Format_Str);
        This.Format_Str := Interfaces.C.Strings.New_String (To);
        fl_spinner_set_format (This.Void_Ptr, This.Format_Str);
    end Set_Format;


    function Get_Kind
           (This : in Spinner)
        return Spinner_Kind
    is
        Result : Interfaces.C.unsigned_char := fl_spinner_get_type (This.Void_Ptr);
    begin
        return Spinner_Kind'Val (Result - 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Spinner::type returned unexpected unsigned char value of " &
        Interfaces.C.unsigned_char'Image (Result);
    end Get_Kind;


    procedure Set_Kind
           (This : in out Spinner;
            To   : in     Spinner_Kind) is
    begin
        fl_spinner_set_type (This.Void_Ptr, Spinner_Kind'Pos (To) + 1);
    end Set_Kind;




    --  Dimensions  --

    procedure Resize
           (This       : in out Spinner;
            X, Y, W, H : in     Integer) is
    begin
        fl_spinner_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Events  --

    function Handle
           (This  : in out Spinner;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Spinners;


