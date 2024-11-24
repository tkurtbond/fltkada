

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Inputs.Outputs is


    procedure output_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, output_set_draw_hook, "output_set_draw_hook");
    pragma Inline (output_set_draw_hook);

    procedure output_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, output_set_handle_hook, "output_set_handle_hook");
    pragma Inline (output_set_handle_hook);




    function new_fl_output
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_output, "new_fl_output");
    pragma Inline (new_fl_output);

    procedure free_fl_output
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_output, "free_fl_output");
    pragma Inline (free_fl_output);




    procedure fl_output_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_output_draw, "fl_output_draw");
    pragma Inline (fl_output_draw);

    function fl_output_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_output_handle, "fl_output_handle");
    pragma Inline (fl_output_handle);




    procedure Extra_Final
           (This : in out Output) is
    begin
        Extra_Final (Input (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Output) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_output (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Output;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Input (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Output is
        begin
            return This : Output do
                This.Void_Ptr := new_fl_output
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                output_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                output_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Output) is
    begin
        fl_output_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Output;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_output_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Inputs.Outputs;

