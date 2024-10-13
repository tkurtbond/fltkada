

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Clocks.Updated is


    procedure clock_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, clock_set_draw_hook, "clock_set_draw_hook");
    pragma Inline (clock_set_draw_hook);

    procedure clock_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, clock_set_handle_hook, "clock_set_handle_hook");
    pragma Inline (clock_set_handle_hook);




    function new_fl_clock
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_clock, "new_fl_clock");
    pragma Inline (new_fl_clock);

    function new_fl_clock2
           (K          : in Interfaces.C.unsigned_char;
            X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_clock2, "new_fl_clock2");
    pragma Inline (new_fl_clock2);

    procedure free_fl_clock
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_clock, "free_fl_clock");
    pragma Inline (free_fl_clock);




    procedure fl_clock_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_clock_draw, "fl_clock_draw");
    pragma Inline (fl_clock_draw);

    procedure fl_clock_draw2
           (C          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_clock_draw2, "fl_clock_draw2");
    pragma Inline (fl_clock_draw2);

    function fl_clock_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_clock_handle, "fl_clock_handle");
    pragma Inline (fl_clock_handle);




    procedure Finalize
           (This : in out Updated_Clock) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Updated_Clock'Class
        then
            free_fl_clock (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Clock (This));
    end Finalize;




    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Updated_Clock is
        begin
            return This : Updated_Clock do
                This.Void_Ptr := new_fl_clock
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                fl_widget_set_user_data
                       (This.Void_Ptr,
                        Storage.To_Integer (Widget_Convert.To_Address (This'Unchecked_Access)));
                clock_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                clock_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
                fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
            end return;
        end Create;


        function Create
               (Kind       : in Box_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Updated_Clock is
        begin
            return This : Updated_Clock do
                This.Void_Ptr := new_fl_clock2
                       (Box_Kind'Pos (Kind),
                        Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                fl_widget_set_user_data
                       (This.Void_Ptr,
                        Storage.To_Integer (Widget_Convert.To_Address (This'Unchecked_Access)));
                clock_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                clock_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
                fl_widget_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Updated_Clock) is
    begin
        fl_clock_draw (This.Void_Ptr);
    end Draw;


    procedure Draw
           (This       : in out Clock;
            X, Y, W, H : in     Integer) is
    begin
        fl_clock_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw;


    function Handle
           (This  : in out Updated_Clock;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_clock_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Clocks.Updated;

