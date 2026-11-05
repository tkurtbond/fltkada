

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Clocks is


    type Clock is new Widget with private;

    type Clock_Reference (Data : not null access Clock'Class) is limited null record
        with Implicit_Dereference => Data;

    subtype Hour is Integer range 0 .. 23;
    subtype Minute is Integer range 0 .. 59;
    subtype Second is Integer range 0 .. 60;

    type Time_Value is mod 2 ** 32;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Clock;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Clock;

    end Forge;




    --  Individual Values  --

    function Get_Hour
           (This : in Clock)
        return Hour;

    function Get_Minute
           (This : in Clock)
        return Minute;

    function Get_Second
           (This : in Clock)
        return Second;




    --  Full Value  --

    --  Get_Time gives back the time Set_Time set (pofltk 76).  A running
    --  clock's own tick sets the time with FLTK's value, once a second, so
    --  its Get_Time is then the seconds past midnight, local time.
    function Get_Time
           (This : in Clock)
        return Time_Value;

    procedure Set_Time
           (This : in out Clock;
            To   : in     Time_Value);

    procedure Set_Time
           (This    : in out Clock;
            Hours   : in     Hour;
            Minutes : in     Minute;
            Seconds : in     Second);




    --  Drawing  --

    --  Whether the hands are drawn with shadows.  The default is True.
    function Has_Shadow
           (This : in Clock)
        return Boolean;

    procedure Set_Shadow
           (This : in out Clock;
            To   : in     Boolean);

    procedure Draw
           (This : in out Clock);

    procedure Draw
           (This       : in out Clock;
            X, Y, W, H : in     Integer);


private


    type Clock is new Widget with null record;

    overriding procedure Initialize
           (This : in out Clock);

    overriding procedure Finalize
           (This : in out Clock);

    procedure Extra_Init
           (This       : in out Clock;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Clock)
    with Inline;


    pragma Inline (Get_Hour);
    pragma Inline (Get_Minute);
    pragma Inline (Get_Second);

    pragma Inline (Get_Time);
    pragma Inline (Set_Time);

    pragma Inline (Has_Shadow);
    pragma Inline (Set_Shadow);

    pragma Inline (Draw);


end FLTK.Widgets.Clocks;


