

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Tiled is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

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




    --  Dimensions  --

    procedure fl_tile_size_range
           (T                         : in Storage.Integer_Address;
            I, MinW, MinH, MaxW, MaxH : in Interfaces.C.int);
    pragma Import (C, fl_tile_size_range, "fl_tile_size_range");
    pragma Inline (fl_tile_size_range);

    procedure fl_tile_init_size_range
           (T          : in Storage.Integer_Address;
            MinW, MinH : in Interfaces.C.int);
    pragma Import (C, fl_tile_init_size_range, "fl_tile_init_size_range");
    pragma Inline (fl_tile_init_size_range);

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




    --  Drawing, Events  --

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

    --  Dimensions  --

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


    procedure Init_Size_Range
           (This         : in out Tiled_Group;
            Min_W, Min_H : in     Natural := 0) is
    begin
        fl_tile_init_size_range
           (This.Void_Ptr, Interfaces.C.int (Min_W), Interfaces.C.int (Min_H));
    end Init_Size_Range;


    procedure Set_Size_Range
           (This         : in out Tiled_Group;
            Place        : in     Index;
            Min_W, Min_H : in     Natural;
            Max_W, Max_H : in     Natural := Natural'Last) is
    begin
        if Place > This.Number_Of_Children then
            raise Constraint_Error with "Set_Size_Range given index" & Index'Image (Place)
                & " of" & Natural'Image (This.Number_Of_Children) & " children";
        end if;
        fl_tile_size_range
           (This.Void_Ptr,
            Interfaces.C.int (Place - 1),
            Interfaces.C.int (Min_W), Interfaces.C.int (Min_H),
            Interfaces.C.int (Max_W), Interfaces.C.int (Max_H));
    end Set_Size_Range;


    procedure Set_Size_Range
           (This         : in out Tiled_Group;
            Item         : in     Widget'Class;
            Min_W, Min_H : in     Natural;
            Max_W, Max_H : in     Natural := Natural'Last)
    is
        Place : constant Extended_Index := This.Find (Item);
    begin
        if Place = No_Index then
            raise Constraint_Error with "Set_Size_Range given a widget not in the tile";
        end if;
        This.Set_Size_Range (Place, Min_W, Min_H, Max_W, Max_H);
    end Set_Size_Range;




    --  Events  --

    function Handle
           (This  : in out Tiled_Group;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Tiled;


