

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C.Strings;

use type

    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Inputs.Text.Whole_Number is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_int_input
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_int_input, "new_fl_int_input");
    pragma Inline (new_fl_int_input);

    procedure free_fl_int_input
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_int_input, "free_fl_int_input");
    pragma Inline (free_fl_int_input);




    --  Drawing, Events  --

    procedure fl_int_input_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_int_input_draw, "fl_int_input_draw");
    pragma Inline (fl_int_input_draw);

    function fl_int_input_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_int_input_handle, "fl_int_input_handle");
    pragma Inline (fl_int_input_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Integer_Input) is
    begin
        Extra_Final (Input (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Integer_Input) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_int_input (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Integer_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Input (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Integer_Input) is
    begin
        This.Draw_Ptr := fl_int_input_draw'Address;
        This.Handle_Ptr := fl_int_input_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Integer_Input is
        begin
            return This : Integer_Input do
                This.Void_Ptr := new_fl_int_input
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
            return Integer_Input is
        begin
            return This : Integer_Input := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Text Field  --

    function Get_Value
           (This : in Integer_Input)
        return Long_Integer
    is
        Ptr : Interfaces.C.Strings.chars_ptr := fl_input_get_value (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr or else
            Interfaces.C.Strings.Value (Ptr) = ""
        then
            return 0;
        else
            return Long_Integer'Value (Interfaces.C.Strings.Value (Ptr));
        end if;
    end Get_Value;


end FLTK.Widgets.Inputs.Text.Whole_Number;


