

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Counters.Simple is


    procedure simple_counter_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, simple_counter_set_draw_hook, "simple_counter_set_draw_hook");
    pragma Inline (simple_counter_set_draw_hook);

    procedure simple_counter_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, simple_counter_set_handle_hook, "simple_counter_set_handle_hook");
    pragma Inline (simple_counter_set_handle_hook);




    function new_fl_simple_counter
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_simple_counter, "new_fl_simple_counter");
    pragma Inline (new_fl_simple_counter);

    procedure free_fl_simple_counter
           (A : in Storage.Integer_Address);
    pragma Import (C, free_fl_simple_counter, "free_fl_simple_counter");
    pragma Inline (free_fl_simple_counter);




    procedure fl_simple_counter_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_simple_counter_draw, "fl_simple_counter_draw");
    pragma Inline (fl_simple_counter_draw);

    function fl_simple_counter_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_simple_counter_handle, "fl_simple_counter_handle");
    pragma Inline (fl_simple_counter_handle);




    procedure Extra_Final
           (This : in out Simple_Counter) is
    begin
        Extra_Final (Counter (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Simple_Counter) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_simple_counter (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Simple_Counter;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Counter (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Simple_Counter is
        begin
            return This : Simple_Counter do
                This.Void_Ptr := new_fl_simple_counter
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                simple_counter_set_draw_hook
                    (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                simple_counter_set_handle_hook
                    (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Simple_Counter) is
    begin
        fl_simple_counter_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Simple_Counter;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_simple_counter_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Valuators.Counters.Simple;

