

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Widgets.Groups,
    Interfaces.C.Strings,
    System.Address_To_Access_Conversions;


package body FLTK.Widgets.Valuators is


    package Chk renames Ada.Assertions;

    package Valuator_Convert is new System.Address_To_Access_Conversions (Valuator'Class);




    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_valuator
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_valuator, "new_fl_valuator");
    pragma Inline (new_fl_valuator);

    procedure free_fl_valuator
           (V : in Storage.Integer_Address);
    pragma Import (C, free_fl_valuator, "free_fl_valuator");
    pragma Inline (free_fl_valuator);




    function fl_valuator_format
           (V : in     Storage.Integer_Address;
            B :    out Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_valuator_format, "fl_valuator_format");
    pragma Inline (fl_valuator_format);




    function fl_valuator_clamp
           (V : in Storage.Integer_Address;
            D : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_valuator_clamp, "fl_valuator_clamp");
    pragma Inline (fl_valuator_clamp);

    function fl_valuator_round
           (V : in Storage.Integer_Address;
            D : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_valuator_round, "fl_valuator_round");
    pragma Inline (fl_valuator_round);

    function fl_valuator_increment
           (V : in Storage.Integer_Address;
            D : in Interfaces.C.double;
            S : in Interfaces.C.int)
        return Interfaces.C.double;
    pragma Import (C, fl_valuator_increment, "fl_valuator_increment");
    pragma Inline (fl_valuator_increment);




    function fl_valuator_get_minimum
           (V : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_valuator_get_minimum, "fl_valuator_get_minimum");
    pragma Inline (fl_valuator_get_minimum);

    procedure fl_valuator_set_minimum
           (V : in Storage.Integer_Address;
            D : in Interfaces.C.double);
    pragma Import (C, fl_valuator_set_minimum, "fl_valuator_set_minimum");
    pragma Inline (fl_valuator_set_minimum);

    function fl_valuator_get_maximum
           (V : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_valuator_get_maximum, "fl_valuator_get_maximum");
    pragma Inline (fl_valuator_get_maximum);

    procedure fl_valuator_set_maximum
           (V : in Storage.Integer_Address;
            D : in Interfaces.C.double);
    pragma Import (C, fl_valuator_set_maximum, "fl_valuator_set_maximum");
    pragma Inline (fl_valuator_set_maximum);

    function fl_valuator_get_step
           (V : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_valuator_get_step, "fl_valuator_get_step");
    pragma Inline (fl_valuator_get_step);

    procedure fl_valuator_set_step_top
           (V : in Storage.Integer_Address;
            T : in Interfaces.C.double);
    pragma Import (C, fl_valuator_set_step_top, "fl_valuator_set_step_top");
    pragma Inline (fl_valuator_set_step_top);

    procedure fl_valuator_set_step_bottom
           (V : in Storage.Integer_Address;
            B : in Interfaces.C.int);
    pragma Import (C, fl_valuator_set_step_bottom, "fl_valuator_set_step_bottom");
    pragma Inline (fl_valuator_set_step_bottom);

    procedure fl_valuator_set_step
           (V : in Storage.Integer_Address;
            T : in Interfaces.C.double;
            B : in Interfaces.C.int);
    pragma Import (C, fl_valuator_set_step, "fl_valuator_set_step");
    pragma Inline (fl_valuator_set_step);

    function fl_valuator_get_value
           (V : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_valuator_get_value, "fl_valuator_get_value");
    pragma Inline (fl_valuator_get_value);

    procedure fl_valuator_set_value
           (V : in Storage.Integer_Address;
            D : in Interfaces.C.double);
    pragma Import (C, fl_valuator_set_value, "fl_valuator_set_value");
    pragma Inline (fl_valuator_set_value);

    procedure fl_valuator_bounds
           (V    : in Storage.Integer_Address;
            A, B : in Interfaces.C.double);
    pragma Import (C, fl_valuator_bounds, "fl_valuator_bounds");
    pragma Inline (fl_valuator_bounds);

    procedure fl_valuator_precision
           (V : in Storage.Integer_Address;
            D : in Interfaces.C.int);
    pragma Import (C, fl_valuator_precision, "fl_valuator_precision");
    pragma Inline (fl_valuator_precision);

    procedure fl_valuator_range
           (V    : in Storage.Integer_Address;
            A, B : in Interfaces.C.double);
    pragma Import (C, fl_valuator_range, "fl_valuator_range");
    pragma Inline (fl_valuator_range);




    procedure fl_valuator_value_damage
           (V : in Storage.Integer_Address);
    pragma Import (C, fl_valuator_value_damage, "fl_valuator_value_damage");
    pragma Inline (fl_valuator_value_damage);

    procedure fl_valuator_draw
           (V : in Storage.Integer_Address);
    pragma Import (C, fl_valuator_draw, "fl_valuator_draw");
    pragma Inline (fl_valuator_draw);

    function fl_valuator_handle
           (V : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_valuator_handle, "fl_valuator_handle");
    pragma Inline (fl_valuator_handle);




    ----------------------
    --  Callback Hooks  --
    ----------------------

    function Valuator_Format_Hook
           (Userdata : in Storage.Integer_Address;
            Buffer   : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int;
    pragma Export (C, Valuator_Format_Hook, "valuator_format_hook");

    function Valuator_Format_Hook
           (Userdata : in Storage.Integer_Address;
            Buffer   : in Interfaces.C.Strings.chars_ptr)
        return Interfaces.C.int
    is
        Ada_Obj : access Valuator'Class;
    begin
        pragma Assert (Userdata /= Null_Pointer);
        Ada_Obj := Valuator_Convert.To_Pointer (Storage.To_Address (Userdata));
        declare
            String_Result : String := Ada_Obj.Format;
        begin
            if String_Result'Length <= FLTK.Buffer_Size then
                Interfaces.C.Strings.Update (Buffer, 0, String_Result);
                return String_Result'Length;
            else
                Interfaces.C.Strings.Update (Buffer, 0, String_Result (1 .. Buffer_Size));
                return Interfaces.C.int (FLTK.Buffer_Size);
            end if;
        end;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Valuator::format callback hook was passed null userdata wrapper reference pointer";
    end Valuator_Format_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Valuator) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Valuator) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_valuator (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Valuator;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Valuator) is
    begin
        This.Draw_Ptr   := fl_valuator_draw'Address;
        This.Handle_Ptr := fl_valuator_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Valuator is
        begin
            return This : Valuator do
                This.Void_Ptr := new_fl_valuator
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
            return Valuator is
        begin
            return This : Valuator := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Format
           (This : in Valuator)
        return String
    is
        Buffer : Interfaces.C.char_array :=
            (1 .. Interfaces.C.size_t (FLTK.Buffer_Size) => Interfaces.C.To_C (Character'Val (0)));
        Result : Interfaces.C.int := fl_valuator_format (This.Void_Ptr, Buffer);
    begin
        return Interfaces.C.To_Ada (Buffer (1 .. Interfaces.C.size_t (Result)), False);
    end Format;




    function Clamp
           (This  : in Valuator;
            Input : in Long_Float)
        return Long_Float is
    begin
        return Long_Float (fl_valuator_clamp (This.Void_Ptr, Interfaces.C.double (Input)));
    end Clamp;


    function Round
           (This  : in Valuator;
            Input : in Long_Float)
        return Long_Float is
    begin
        return Long_Float (fl_valuator_round (This.Void_Ptr, Interfaces.C.double (Input)));
    end Round;


    function Increment
           (This  : in Valuator;
            Input : in Long_Float;
            Step  : in Integer)
        return Long_Float is
    begin
        return Long_Float (fl_valuator_increment
           (This.Void_Ptr,
            Interfaces.C.double (Input),
            Interfaces.C.int (Step)));
    end Increment;




    function Get_Minimum
           (This : in Valuator)
        return Long_Float is
    begin
        return Long_Float (fl_valuator_get_minimum (This.Void_Ptr));
    end Get_Minimum;


    procedure Set_Minimum
           (This : in out Valuator;
            To   : in     Long_Float) is
    begin
        fl_valuator_set_minimum (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Minimum;


    function Get_Maximum
           (This : in Valuator)
        return Long_Float is
    begin
        return Long_Float (fl_valuator_get_maximum (This.Void_Ptr));
    end Get_Maximum;


    procedure Set_Maximum
           (This : in out Valuator;
            To   : in     Long_Float) is
    begin
        fl_valuator_set_maximum (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Maximum;


    function Get_Step
           (This : in Valuator)
        return Long_Float is
    begin
        return Long_Float (fl_valuator_get_step (This.Void_Ptr));
    end Get_Step;


    procedure Set_Step_Top
           (This : in out Valuator;
            To   : in     Long_Float) is
    begin
        fl_valuator_set_step_top
           (This.Void_Ptr,
            Interfaces.C.double (To));
    end Set_Step_Top;


    procedure Set_Step_Bottom
           (This : in out Valuator;
            To   : in     Integer) is
    begin
        fl_valuator_set_step_bottom
           (This.Void_Ptr,
            Interfaces.C.int (To));
    end Set_Step_Bottom;


    procedure Set_Step
           (This   : in out Valuator;
            Top    : in     Long_Float;
            Bottom : in     Integer) is
    begin
        fl_valuator_set_step
           (This.Void_Ptr,
            Interfaces.C.double (Top),
            Interfaces.C.int (Bottom));
    end Set_Step;


    function Get_Value
           (This : in Valuator)
        return Long_Float is
    begin
        return Long_Float (fl_valuator_get_value (This.Void_Ptr));
    end Get_Value;


    procedure Set_Value
           (This : in out Valuator;
            To   : in     Long_Float) is
    begin
        fl_valuator_set_value (This.Void_Ptr, Interfaces.C.double (To));
    end Set_Value;


    procedure Set_Bounds
           (This     : in out Valuator;
            Min, Max : in     Long_Float) is
    begin
        fl_valuator_bounds
           (This.Void_Ptr,
            Interfaces.C.double (Min),
            Interfaces.C.double (Max));
    end Set_Bounds;


    procedure Set_Precision
           (This : in out Valuator;
            To   : in     Integer) is
    begin
        fl_valuator_precision (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Precision;


    procedure Set_Range
           (This     : in out Valuator;
            Min, Max : in     Long_Float) is
    begin
        fl_valuator_range
           (This.Void_Ptr,
            Interfaces.C.double (Min),
            Interfaces.C.double (Max));
    end Set_Range;




    procedure Value_Damage
           (This : in out Valuator) is
    begin
        fl_valuator_value_damage (This.Void_Ptr);
    end Value_Damage;


end FLTK.Widgets.Valuators;


