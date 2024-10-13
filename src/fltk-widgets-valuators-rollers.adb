

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Rollers is


    procedure roller_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, roller_set_draw_hook, "roller_set_draw_hook");
    pragma Inline (roller_set_draw_hook);

    procedure roller_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, roller_set_handle_hook, "roller_set_handle_hook");
    pragma Inline (roller_set_handle_hook);




    function new_fl_roller
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_roller, "new_fl_roller");
    pragma Inline (new_fl_roller);

    procedure free_fl_roller
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_roller, "free_fl_roller");
    pragma Inline (free_fl_roller);




    procedure fl_roller_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_roller_draw, "fl_roller_draw");
    pragma Inline (fl_roller_draw);

    function fl_roller_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_roller_handle, "fl_roller_handle");
    pragma Inline (fl_roller_handle);




    procedure Finalize
           (This : in out Roller) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Roller'Class
        then
            free_fl_roller (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Valuator (This));
    end Finalize;




    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Roller is
        begin
            return This : Roller do
                This.Void_Ptr := new_fl_roller
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                fl_widget_set_user_data
                       (This.Void_Ptr,
                        Storage.To_Integer (Widget_Convert.To_Address (This'Unchecked_Access)));
                roller_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                roller_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
                fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Roller) is
    begin
        fl_roller_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Roller;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_roller_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Valuators.Rollers;

