

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Tiled is


    type Tiled_Group is new Group with private;

    type Tiled_Group_Reference (Data : not null access Tiled_Group'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Tiled_Group;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Tiled_Group;

    end Forge;




    --  Dimensions  --

    procedure Position
           (This         : in out Tiled_Group;
            Old_X, Old_Y : in     Integer;
            New_X, New_Y : in     Integer);

    procedure Resize
           (This       : in out Tiled_Group;
            X, Y, W, H : in     Integer);

    --  Size ranges: how small a child may be made by moving a border.  The
    --  first call gives every child the default minimum.  FLTK 1.4.5 keeps
    --  the maximums but doesn't use them.

    --  Sets the default minimum size and starts using ranges: the first
    --  call gives it to every child, later calls only to children added
    --  after them (Fl_Tile.cxx, init_size_range).  A 0 leaves that minimum
    --  as it was (at first, 4 pixels).
    procedure Init_Size_Range
           (This         : in out Tiled_Group;
            Min_W, Min_H : in     Natural := 0);

    --  Raises Constraint_Error if Place is not a child's index.
    procedure Set_Size_Range
           (This         : in out Tiled_Group;
            Place        : in     Index;
            Min_W, Min_H : in     Natural;
            Max_W, Max_H : in     Natural := Natural'Last);

    --  Raises Constraint_Error if Item is not a child.
    procedure Set_Size_Range
           (This         : in out Tiled_Group;
            Item         : in     Widget'Class;
            Min_W, Min_H : in     Natural;
            Max_W, Max_H : in     Natural := Natural'Last);




    --  Events  --

    function Handle
           (This  : in out Tiled_Group;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Tiled_Group is new Group with null record;

    overriding procedure Initialize
           (This : in out Tiled_Group);

    overriding procedure Finalize
           (This : in out Tiled_Group);

    procedure Extra_Init
           (This       : in out Tiled_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Tiled_Group)
    with Inline;


    pragma Inline (Position);
    pragma Inline (Resize);
    pragma Inline (Init_Size_Range);

    pragma Inline (Handle);


end FLTK.Widgets.Groups.Tiled;


