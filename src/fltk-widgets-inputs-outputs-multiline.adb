

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Inputs.Outputs.Multiline is


    procedure multiline_output_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, multiline_output_set_draw_hook, "multiline_output_set_draw_hook");
    pragma Inline (multiline_output_set_draw_hook);

    procedure multiline_output_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, multiline_output_set_handle_hook, "multiline_output_set_handle_hook");
    pragma Inline (multiline_output_set_handle_hook);




    function new_fl_multiline_output
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_multiline_output, "new_fl_multiline_output");
    pragma Inline (new_fl_multiline_output);

    procedure free_fl_multiline_output
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_multiline_output, "free_fl_multiline_output");
    pragma Inline (free_fl_multiline_output);




    procedure fl_multiline_output_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_multiline_output_draw, "fl_multiline_output_draw");
    pragma Inline (fl_multiline_output_draw);

    function fl_multiline_output_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_multiline_output_handle, "fl_multiline_output_handle");
    pragma Inline (fl_multiline_output_handle);




    procedure Extra_Final
           (This : in out Multiline_Output) is
    begin
        Extra_Final (Output (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Multiline_Output) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_multiline_output (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Multiline_Output;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Output (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Multiline_Output is
        begin
            return This : Multiline_Output do
                This.Void_Ptr := new_fl_multiline_output
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                multiline_output_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                multiline_output_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Multiline_Output) is
    begin
        fl_multiline_output_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Multiline_Output;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_multiline_output_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Inputs.Outputs.Multiline;

