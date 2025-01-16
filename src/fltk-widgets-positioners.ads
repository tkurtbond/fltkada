

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Positioners is


    type Positioner is new Widget with private;

    type Positioner_Reference (Data : not null access Positioner'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Positioner;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Positioner;

    end Forge;




    procedure Get_Coords
           (This : in     Positioner;
            X, Y :    out Long_Float);

    procedure Set_Coords
           (This : in out Positioner;
            X, Y : in     Long_Float);

    function Set_Coords
           (This : in out Positioner;
            X, Y : in     Long_Float)
        return Boolean;




    procedure Set_Ecks_Bounds
           (This      : in out Positioner;
            Low, High : in     Long_Float);

    procedure Set_Ecks_Step
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Get_Ecks_Minimum
           (This : in Positioner)
        return Long_Float;

    procedure Set_Ecks_Minimum
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Get_Ecks_Maximum
           (This : in Positioner)
        return Long_Float;

    procedure Set_Ecks_Maximum
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Get_Ecks
           (This : in Positioner)
        return Long_Float;

    procedure Set_Ecks
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Set_Ecks
           (This  : in out Positioner;
            Value : in     Long_Float)
        return Boolean;




    procedure Set_Why_Bounds
           (This      : in out Positioner;
            Low, High : in     Long_Float);

    procedure Set_Why_Step
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Get_Why_Minimum
           (This : in Positioner)
        return Long_Float;

    procedure Set_Why_Minimum
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Get_Why_Maximum
           (This : in Positioner)
        return Long_Float;

    procedure Set_Why_Maximum
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Get_Why
           (This : in Positioner)
        return Long_Float;

    procedure Set_Why
           (This  : in out Positioner;
            Value : in     Long_Float);

    function Set_Why
           (This  : in out Positioner;
            Value : in     Long_Float)
        return Boolean;




    procedure Draw
           (This : in out Positioner);

    procedure Draw
           (This       : in out Positioner;
            X, Y, W, H : in     Integer);

    function Handle
           (This  : in out Positioner;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle
           (This       : in out Positioner;
            Event      : in     Event_Kind;
            X, Y, W, H : in     Integer)
        return Event_Outcome;


private


    type Positioner is new Widget with null record;

    overriding procedure Initialize
           (This : in out Positioner);

    overriding procedure Finalize
           (This : in out Positioner);

    procedure Extra_Init
           (This       : in out Positioner;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Positioner)
    with Inline;


    pragma Inline (Get_Coords);
    pragma Inline (Set_Coords);

    pragma Inline (Set_Ecks_Bounds);
    pragma Inline (Set_Ecks_Step);
    pragma Inline (Get_Ecks_Minimum);
    pragma Inline (Set_Ecks_Minimum);
    pragma Inline (Get_Ecks_Maximum);
    pragma Inline (Set_Ecks_Maximum);
    pragma Inline (Get_Ecks);
    pragma Inline (Set_Ecks);

    pragma Inline (Set_Why_Bounds);
    pragma Inline (Set_Why_Step);
    pragma Inline (Get_Why_Minimum);
    pragma Inline (Set_Why_Minimum);
    pragma Inline (Get_Why_Maximum);
    pragma Inline (Set_Why_Maximum);
    pragma Inline (Get_Why);
    pragma Inline (Set_Why);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Positioners;


