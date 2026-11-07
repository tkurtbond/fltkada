

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_Timer:  a widget that counts down a time, showing it or not, and
--  calls back as the time runs out.  A timer starts stopped with no time;
--  setting a time starts it.  A shown timer blinks once it runs out.


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Forms.Timers is


    type Timer is new Widget with private;

    type Timer_Reference (Data : not null access Timer'Class) is limited null record
        with Implicit_Dereference => Data;

    --  A normal timer shows nothing until it runs out, and a value timer
    --  shows its time.  A hidden timer isn't visible.
    type Timer_Kind is (Normal_Timer, Value_Timer, Hidden_Timer);




    package Forge is

        function Create
               (Kind       : in Timer_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Timer;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                Kind       : in     Timer_Kind;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Timer;

    end Forge;




    --  Time  --

    --  The time left, in seconds.
    function Get_Value
           (This : in Timer)
        return Long_Float;

    --  Starts the timer with this time.
    procedure Set_Value
           (This  : in out Timer;
            Value : in     Long_Float);

    --  Whether a value timer shows the time gone rather than the time left.
    --  It starts showing the time left, though FLTK's header has its
    --  direction the other way around (pofltk 107).
    function Counts_Up
           (This : in Timer)
        return Boolean;

    procedure Set_Counts_Up
           (This  : in out Timer;
            Value : in     Boolean);

    function Is_Suspended
           (This : in Timer)
        return Boolean;

    procedure Set_Suspended
           (This  : in out Timer;
            Value : in     Boolean);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Timer);

    function Handle
           (This  : in out Timer;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Timer is new Widget with null record;

    overriding procedure Initialize
           (This : in out Timer);

    overriding procedure Finalize
           (This : in out Timer);

    procedure Extra_Init
           (This       : in out Timer;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Timer)
    with Inline;


    pragma Inline (Get_Value);
    pragma Inline (Set_Value);
    pragma Inline (Counts_Up);
    pragma Inline (Set_Counts_Up);
    pragma Inline (Is_Suspended);
    pragma Inline (Set_Suspended);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Forms.Timers;


