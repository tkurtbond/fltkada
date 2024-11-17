

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Inputs.Secret is


    procedure secret_input_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, secret_input_set_draw_hook, "secret_input_set_draw_hook");
    pragma Inline (secret_input_set_draw_hook);

    procedure secret_input_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, secret_input_set_handle_hook, "secret_input_set_handle_hook");
    pragma Inline (secret_input_set_handle_hook);




    function new_fl_secret_input
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_secret_input, "new_fl_secret_input");
    pragma Inline (new_fl_secret_input);

    procedure free_fl_secret_input
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_secret_input, "free_fl_secret_input");
    pragma Inline (free_fl_secret_input);




    procedure fl_secret_input_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_secret_input_draw, "fl_secret_input_draw");
    pragma Inline (fl_secret_input_draw);

    function fl_secret_input_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_secret_input_handle, "fl_secret_input_handle");
    pragma Inline (fl_secret_input_handle);




    procedure Extra_Final
           (This : in out Secret_Input) is
    begin
        Extra_Final (Input (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Secret_Input) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_secret_input (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Secret_Input;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Input (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Secret_Input is
        begin
            return This : Secret_Input do
                This.Void_Ptr := new_fl_secret_input
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                secret_input_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                secret_input_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Secret_Input) is
    begin
        fl_secret_input_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Secret_Input;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_secret_input_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Inputs.Secret;

