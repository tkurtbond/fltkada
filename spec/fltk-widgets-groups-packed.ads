

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Groups.Packed is


    type Packed_Group is new Group with private;

    type Packed_Group_Reference (Data : not null access Packed_Group'Class) is
        limited null record with Implicit_Dereference => Data;

    type Pack_Kind is (Vertical_Pack, Horizontal_Pack);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Packed_Group;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Packed_Group;

    end Forge;




    --  Contents Modification  --

    --  Also leaves the pack no resizable, as Fl_Pack::clear does.
    procedure Clear
           (This : in out Packed_Group);




    --  Settings  --

    function Get_Spacing
           (This : in Packed_Group)
        return Integer;

    procedure Set_Spacing
           (This : in out Packed_Group;
            To   : in     Integer);

    function Get_Kind
           (This : in Packed_Group)
        return Pack_Kind;

    procedure Set_Kind
           (This : in out Packed_Group;
            Kind : in     Pack_Kind);




    --  Drawing  --

    procedure Draw
           (This : in out Packed_Group);


private


    type Packed_Group is new Group with null record;

    overriding procedure Initialize
           (This : in out Packed_Group);

    overriding procedure Finalize
           (This : in out Packed_Group);

    procedure Extra_Init
           (This       : in out Packed_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Packed_Group)
    with Inline;


    pragma Inline (Get_Spacing);
    pragma Inline (Set_Spacing);
    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);

    pragma Inline (Draw);


end FLTK.Widgets.Groups.Packed;


