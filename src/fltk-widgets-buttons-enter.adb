

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Buttons.Enter is


    procedure return_button_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, return_button_set_draw_hook, "return_button_set_draw_hook");
    pragma Inline (return_button_set_draw_hook);

    procedure return_button_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, return_button_set_handle_hook, "return_button_set_handle_hook");
    pragma Inline (return_button_set_handle_hook);




    function new_fl_return_button
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_return_button, "new_fl_return_button");
    pragma Inline (new_fl_return_button);

    procedure free_fl_return_button
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_return_button, "free_fl_return_button");
    pragma Inline (free_fl_return_button);




    procedure fl_return_button_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_return_button_draw, "fl_return_button_draw");
    pragma Inline (fl_return_button_draw);

    function fl_return_button_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_return_button_handle, "fl_return_button_handle");
    pragma Inline (fl_return_button_handle);




    procedure Extra_Final
           (This : in out Enter_Button) is
    begin
        Extra_Final (Button (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Enter_Button) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_return_button (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Enter_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Button (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Enter_Button is
        begin
            return This : Enter_Button do
                This.Void_Ptr := new_fl_return_button
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                return_button_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                return_button_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Enter_Button) is
    begin
        fl_return_button_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Enter_Button;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_return_button_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Buttons.Enter;

