

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Buttons.Light.Check is


    procedure check_button_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, check_button_set_draw_hook, "check_button_set_draw_hook");
    pragma Inline (check_button_set_draw_hook);

    procedure check_button_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, check_button_set_handle_hook, "check_button_set_handle_hook");
    pragma Inline (check_button_set_handle_hook);




    function new_fl_check_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_check_button, "new_fl_check_button");
    pragma Inline (new_fl_check_button);

    procedure free_fl_check_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_check_button, "free_fl_check_button");
    pragma Inline (free_fl_check_button);




    procedure fl_check_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_check_button_draw, "fl_check_button_draw");
    pragma Inline (fl_check_button_draw);

    function fl_check_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_check_button_handle, "fl_check_button_handle");
    pragma Inline (fl_check_button_handle);




    procedure Extra_Final
           (This : in out Check_Button) is
    begin
        Extra_Final (Light_Button (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Check_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_check_button (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Check_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Light_Button (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Check_Button is
        begin
            return This : Check_Button do
                This.Void_Ptr := new_fl_check_button
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                check_button_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                check_button_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Check_Button) is
    begin
        fl_check_button_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Check_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_check_button_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Buttons.Light.Check;

