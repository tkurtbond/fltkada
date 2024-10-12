

with

    Interfaces.C.Strings;


package body FLTK.Widgets.Inputs.Multiline is


    procedure multiline_input_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, multiline_input_set_draw_hook, "multiline_input_set_draw_hook");
    pragma Inline (multiline_input_set_draw_hook);

    procedure multiline_input_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, multiline_input_set_handle_hook, "multiline_input_set_handle_hook");
    pragma Inline (multiline_input_set_handle_hook);




    function new_fl_multiline_input
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_multiline_input, "new_fl_multiline_input");
    pragma Inline (new_fl_multiline_input);

    procedure free_fl_multiline_input
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_multiline_input, "free_fl_multiline_input");
    pragma Inline (free_fl_multiline_input);




    procedure fl_multiline_input_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_multiline_input_draw, "fl_multiline_input_draw");
    pragma Inline (fl_multiline_input_draw);

    function fl_multiline_input_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_multiline_input_handle, "fl_multiline_input_handle");
    pragma Inline (fl_multiline_input_handle);




    procedure Finalize
           (This : in out Multiline_Input) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Multiline_Input'Class
        then
            free_fl_multiline_input (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Input (This));
    end Finalize;




    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Multiline_Input is
        begin
            return This : Multiline_Input do
                This.Void_Ptr := new_fl_multiline_input
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                fl_widget_set_user_data
                       (This.Void_Ptr,
                        Storage.To_Integer (Widget_Convert.To_Address (This'Unchecked_Access)));
                multiline_input_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                multiline_input_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
                fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Multiline_Input) is
    begin
        fl_multiline_input_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Multiline_Input;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_multiline_input_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Inputs.Multiline;

