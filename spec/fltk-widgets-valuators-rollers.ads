

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Valuators.Rollers is


    type Roller is new Valuator with private;

    --  FLTK's FL_VERTICAL and FL_HORIZONTAL.
    type Roller_Kind is (Vertical_Roller, Horizontal_Roller);

    type Roller_Reference (Data : not null access Roller'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Roller;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Roller;

    end Forge;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Roller);

    function Handle
           (This  : in out Roller;
            Event : in     Event_Kind)
        return Event_Outcome;




    --  Roller Type  --

    function Get_Kind
           (This : in Roller)
        return Roller_Kind;

    procedure Set_Kind
           (This : in out Roller;
            To   : in     Roller_Kind);


private


    type Roller is new Valuator with null record;

    overriding procedure Initialize
           (This : in out Roller);

    overriding procedure Finalize
           (This : in out Roller);

    procedure Extra_Init
           (This       : in out Roller;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Roller)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);

    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);


end FLTK.Widgets.Valuators.Rollers;


