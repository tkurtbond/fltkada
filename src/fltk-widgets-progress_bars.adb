

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Progress_Bars is


    procedure progress_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, progress_set_draw_hook, "progress_set_draw_hook");
    pragma Inline (progress_set_draw_hook);

    procedure progress_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, progress_set_handle_hook, "progress_set_handle_hook");
    pragma Inline (progress_set_handle_hook);




    function new_fl_progress
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_progress, "new_fl_progress");
    pragma Inline (new_fl_progress);

    procedure free_fl_progress
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_progress, "free_fl_progress");
    pragma Inline (free_fl_progress);




    function fl_progress_get_minimum
           (P : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_progress_get_minimum, "fl_progress_get_minimum");
    pragma Inline (fl_progress_get_minimum);

    procedure fl_progress_set_minimum
           (P : in Storage.Integer_Address;
            T : in Interfaces.C.C_float);
    pragma Import (C, fl_progress_set_minimum, "fl_progress_set_minimum");
    pragma Inline (fl_progress_set_minimum);

    function fl_progress_get_maximum
           (P : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_progress_get_maximum, "fl_progress_get_maximum");
    pragma Inline (fl_progress_get_maximum);

    procedure fl_progress_set_maximum
           (P : in Storage.Integer_Address;
            T : in Interfaces.C.C_float);
    pragma Import (C, fl_progress_set_maximum, "fl_progress_set_maximum");
    pragma Inline (fl_progress_set_maximum);

    function fl_progress_get_value
           (P : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_progress_get_value, "fl_progress_get_value");
    pragma Inline (fl_progress_get_value);

    procedure fl_progress_set_value
           (P : in Storage.Integer_Address;
            T : in Interfaces.C.C_float);
    pragma Import (C, fl_progress_set_value, "fl_progress_set_value");
    pragma Inline (fl_progress_set_value);




    procedure fl_progress_draw
           (P : in Storage.Integer_Address);
    pragma Import (C, fl_progress_draw, "fl_progress_draw");
    pragma Inline (fl_progress_draw);

    function fl_progress_handle
           (P : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_progress_handle, "fl_progress_handle");
    pragma Inline (fl_progress_handle);




    procedure Extra_Final
           (This : in out Progress_Bar) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Progress_Bar) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_progress (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Progress_Bar;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Progress_Bar is
        begin
            return This : Progress_Bar do
                This.Void_Ptr := new_fl_progress
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                progress_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                progress_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;





    function Get_Minimum
           (This : in Progress_Bar)
        return Float is
    begin
        return Float (fl_progress_get_minimum (This.Void_Ptr));
    end Get_Minimum;


    procedure Set_Minimum
           (This : in out Progress_Bar;
            To   : in     Float) is
    begin
        fl_progress_set_minimum (This.Void_Ptr, Interfaces.C.C_float (To));
    end Set_Minimum;


    function Get_Maximum
           (This : in Progress_Bar)
        return Float is
    begin
        return Float (fl_progress_get_maximum (This.Void_Ptr));
    end Get_Maximum;


    procedure Set_Maximum
           (This : in out Progress_Bar;
            To   : in     Float) is
    begin
        fl_progress_set_maximum (This.Void_Ptr, Interfaces.C.C_float (To));
    end Set_Maximum;


    function Get_Value
           (This : in Progress_Bar)
        return Float is
    begin
        return Float (fl_progress_get_value (This.Void_Ptr));
    end Get_Value;


    procedure Set_Value
           (This : in out Progress_Bar;
            To   : in     Float) is
    begin
        fl_progress_set_value (This.Void_Ptr, Interfaces.C.C_float (To));
    end Set_Value;




    procedure Draw
           (This : in out Progress_Bar) is
    begin
        fl_progress_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Progress_Bar;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_progress_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Progress_Bars;

