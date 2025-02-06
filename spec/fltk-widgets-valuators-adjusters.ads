

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Valuators.Adjusters is


    type Adjuster is new Valuator with private;

    type Adjuster_Reference (Data : not null access Adjuster'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Adjuster;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Adjuster;

    end Forge;




    --  Allow Outside Range  --

    function Is_Soft
           (This : in Adjuster)
        return Boolean;

    procedure Set_Soft
           (This : in out Adjuster;
            To   : in     Boolean);




    --  Drawing, Events  --

    procedure Value_Damage
           (This : in out Adjuster);

    procedure Draw
           (This : in out Adjuster);

    function Handle
           (This  : in out Adjuster;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Adjuster is new Valuator with null record;

    overriding procedure Initialize
           (This : in out Adjuster);

    overriding procedure Finalize
           (This : in out Adjuster);

    procedure Extra_Init
           (This       : in out Adjuster;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Adjuster)
    with Inline;


    pragma Inline (Is_Soft);
    pragma Inline (Set_Soft);

    pragma Inline (Value_Damage);
    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Valuators.Adjusters;


