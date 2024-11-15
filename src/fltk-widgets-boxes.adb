

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Boxes is


    procedure box_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, box_set_draw_hook, "box_set_draw_hook");
    pragma Inline (box_set_draw_hook);

    procedure box_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, box_set_handle_hook, "box_set_handle_hook");
    pragma Inline (box_set_handle_hook);




    function new_fl_box
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_box, "new_fl_box");
    pragma Inline (new_fl_box);

    procedure free_fl_box
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_box, "free_fl_box");
    pragma Inline (free_fl_box);




    procedure fl_box_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_box_draw, "fl_box_draw");
    pragma Inline (fl_box_draw);

    function fl_box_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_box_handle, "fl_box_handle");
    pragma Inline (fl_box_handle);




    procedure Finalize
           (This : in out Box) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Box'Class
        then
            if This.Needs_Dealloc then
                free_fl_box (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Widget (This));
    end Finalize;




    procedure Extra_Init
           (This       : in out Box;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Box is
        begin
            return This : Box do
                This.Void_Ptr := new_fl_box
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                box_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                box_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Draw
           (This : in out Box) is
    begin
        fl_box_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Box;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_box_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Boxes;

