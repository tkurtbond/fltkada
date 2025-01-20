

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Valuators.Dials is


    type Dial is new Valuator with private;

    type Dial_Reference (Data : not null access Dial'Class) is limited null record
        with Implicit_Dereference => Data;

    type Dial_Kind is (Normal_Dial, Line_Dial, Fill_Dial);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Dial;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Dial;

    end Forge;




    function Get_First_Angle
           (This : in Dial)
        return Short_Integer;

    procedure Set_First_Angle
           (This : in out Dial;
            To   : in     Short_Integer);

    function Get_Second_Angle
           (This : in Dial)
        return Short_Integer;

    procedure Set_Second_Angle
           (This : in out Dial;
            To   : in     Short_Integer);

    procedure Set_Angles
           (This     : in out Dial;
            One, Two : in     Short_Integer);




    procedure Draw
           (This : in out Dial);

    procedure Draw
           (This       : in out Dial;
            X, Y, W, H : in     Integer);

    function Handle
           (This  : in out Dial;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle
           (This       : in out Dial;
            Event      : in     Event_Kind;
            X, Y, W, H : in     Integer)
        return Event_Outcome;




    function Get_Kind
           (This : in Dial)
        return Dial_Kind;

    package Extra is

        procedure Set_Kind
               (This : in out Dial;
                To   : in     Dial_Kind);

    end Extra;


private


    type Dial is new Valuator with null record;

    overriding procedure Initialize
           (This : in out Dial);

    overriding procedure Finalize
           (This : in out Dial);

    procedure Extra_Init
           (This       : in out Dial;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Dial)
    with Inline;


    pragma Inline (Get_First_Angle);
    pragma Inline (Set_First_Angle);
    pragma Inline (Get_Second_Angle);
    pragma Inline (Set_Second_Angle);
    pragma Inline (Set_Angles);

    pragma Inline (Draw);
    pragma Inline (Handle);

    pragma Inline (Get_Kind);


end FLTK.Widgets.Valuators.Dials;


