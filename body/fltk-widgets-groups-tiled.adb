

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Tiled is


    ------------------------
    --  Functions From C  --
    ------------------------

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

    procedure fl_tile_resize
           (T          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_tile_resize, "fl_tile_resize");
    pragma Inline (fl_tile_resize);




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




    -------------------
    --  Destructors  --
    -------------------

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
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Tiled_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Tiled_Group) is
    begin
        This.Draw_Ptr := fl_tile_draw'Address;
        This.Handle_Ptr := fl_tile_handle'Address;
    end Initialize;


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
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Tiled_Group is
        begin
            return This : Tiled_Group := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

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


    procedure Resize
           (This       : in out Tiled_Group;
            X, Y, W, H : in     Integer) is
    begin
        fl_tile_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    function Handle
           (This  : in out Tiled_Group;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Tiled;


