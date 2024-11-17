

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Valuators.Dials.Line is


    procedure line_dial_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, line_dial_set_draw_hook, "line_dial_set_draw_hook");
    pragma Inline (line_dial_set_draw_hook);

    procedure line_dial_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, line_dial_set_handle_hook, "line_dial_set_handle_hook");
    pragma Inline (line_dial_set_handle_hook);




    function new_fl_line_dial
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_line_dial, "new_fl_line_dial");
    pragma Inline (new_fl_line_dial);

    procedure free_fl_line_dial
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_line_dial, "free_fl_line_dial");
    pragma Inline (free_fl_line_dial);




    procedure fl_line_dial_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_line_dial_draw, "fl_line_dial_draw");
    pragma Inline (fl_line_dial_draw);

    function fl_line_dial_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_line_dial_handle, "fl_line_dial_handle");
    pragma Inline (fl_line_dial_handle);




    procedure Extra_Final
           (This : in out Line_Dial) is
    begin
        Extra_Final (Dial (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Line_Dial) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_line_dial (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Line_Dial;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Dial (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Line_Dial is
        begin
            return This : Line_Dial do
                This.Void_Ptr := new_fl_line_dial
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                line_dial_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                line_dial_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Line_Dial) is
    begin
        fl_line_dial_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Line_Dial;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_line_dial_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Valuators.Dials.Line;

