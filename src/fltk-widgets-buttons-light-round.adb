

with

    Interfaces.C;


package body FLTK.Widgets.Buttons.Light.Round is


    procedure round_button_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, round_button_set_draw_hook, "round_button_set_draw_hook");
    pragma Inline (round_button_set_draw_hook);

    procedure round_button_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, round_button_set_handle_hook, "round_button_set_handle_hook");
    pragma Inline (round_button_set_handle_hook);




    function new_fl_round_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_round_button, "new_fl_round_button");
    pragma Inline (new_fl_round_button);

    procedure free_fl_round_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_round_button, "free_fl_round_button");
    pragma Inline (free_fl_round_button);




    procedure fl_round_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_round_button_draw, "fl_round_button_draw");
    pragma Inline (fl_round_button_draw);

    function fl_round_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_round_button_handle, "fl_round_button_handle");
    pragma Inline (fl_round_button_handle);




    procedure Finalize
           (This : in out Round_Button) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Round_Button'Class
        then
            free_fl_round_button (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Light_Button (This));
    end Finalize;




    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Round_Button is
        begin
            return This : Round_Button do
                This.Void_Ptr := new_fl_round_button
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                fl_widget_set_user_data
                       (This.Void_Ptr,
                        Storage.To_Integer (Widget_Convert.To_Address (This'Unchecked_Access)));
                round_button_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                round_button_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
                fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Round_Button) is
    begin
        fl_round_button_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Round_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_round_button_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Buttons.Light.Round;

