

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Inputs.Integer is


    procedure int_input_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, int_input_set_draw_hook, "int_input_set_draw_hook");
    pragma Inline (int_input_set_draw_hook);

    procedure int_input_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, int_input_set_handle_hook, "int_input_set_handle_hook");
    pragma Inline (int_input_set_handle_hook);




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




    procedure Finalize
           (This : in out Integer_Input) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Integer_Input'Class
        then
            free_fl_int_input (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Input (This));
    end Finalize;




    procedure Extra_Init
           (This       : in out Integer_Input;
            X, Y, W, H : in     Standard.Integer;
            Text       : in     String) is
    begin
        Extra_Init (Input (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Standard.Integer;
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
                int_input_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                int_input_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    function Get_Value
           (This : in Integer_Input)
        return Standard.Integer
    is
        Ptr : Interfaces.C.Strings.chars_ptr := fl_input_get_value (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr or else
            Interfaces.C.Strings.Value (Ptr) = ""
        then
            return 0;
        else
            return Standard.Integer'Value (Interfaces.C.Strings.Value (Ptr));
        end if;
    end Get_Value;




    procedure Draw
           (This : in out Integer_Input) is
    begin
        fl_int_input_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Integer_Input;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_int_input_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Inputs.Integer;

