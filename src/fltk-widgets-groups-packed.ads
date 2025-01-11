

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

    end Forge;




    function Get_Spacing
           (This : in Packed_Group)
        return Integer;

    procedure Set_Spacing
           (This : in out Packed_Group;
            To   : in     Integer);

    function Get_Pack_Type
           (This : in Packed_Group)
        return Pack_Kind;

    procedure Set_Pack_Type
           (This : in out Packed_Group;
            Kind : in     Pack_Kind);




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
    pragma Inline (Get_Pack_Type);
    pragma Inline (Set_Pack_Type);

    pragma Inline (Draw);


end FLTK.Widgets.Groups.Packed;


