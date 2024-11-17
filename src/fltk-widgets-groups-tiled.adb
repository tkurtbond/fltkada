

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Tiled is


    procedure tile_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, tile_set_draw_hook, "tile_set_draw_hook");
    pragma Inline (tile_set_draw_hook);

    procedure tile_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, tile_set_handle_hook, "tile_set_handle_hook");
    pragma Inline (tile_set_handle_hook);




    function new_fl_tile
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_tile, "new_fl_tile");
    pragma Inline (new_fl_tile);

    procedure free_fl_tile
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_tile, "free_fl_tile");
    pragma Inline (free_fl_tile);




    procedure fl_tile_position
           (T              : in Storage.Integer_Address;
            OX, OY, NX, NY : in Interfaces.C.int);
    pragma Import (C, fl_tile_position, "fl_tile_position");
    pragma Inline (fl_tile_position);




    procedure fl_tile_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_tile_draw, "fl_tile_draw");
    pragma Inline (fl_tile_draw);

    function fl_tile_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_tile_handle, "fl_tile_handle");
    pragma Inline (fl_tile_handle);




    procedure Extra_Final
           (This : in out Tiled_Group) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Tiled_Group) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_tile (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Tiled_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Tiled_Group is
        begin
            return This : Tiled_Group do
                This.Void_Ptr := new_fl_tile
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                tile_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                tile_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Position
           (This         : in out Tiled_Group;
            Old_X, Old_Y : in     Integer;
            New_X, New_Y : in     Integer) is
    begin
        fl_tile_position
           (This.Void_Ptr,
            Interfaces.C.int (Old_X), Interfaces.C.int (Old_Y),
            Interfaces.C.int (New_X), Interfaces.C.int (New_Y));
    end Position;




    procedure Draw
           (This : in out Tiled_Group) is
    begin
        fl_tile_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Tiled_Group;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_tile_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Tiled;

