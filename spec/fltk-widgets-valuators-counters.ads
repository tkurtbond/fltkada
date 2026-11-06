

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Valuators.Counters is


    type Counter is new Valuator with private;

    type Counter_Reference (Data : not null access Counter'Class) is
        limited null record with Implicit_Dereference => Data;

    type Counter_Kind is (Normal_Counter, Simple_Counter);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Counter;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Counter;

    end Forge;




    --  Button Steps  --

    function Get_Step
           (This : in Counter)
        return Long_Float;

    --  Set the step for the single arrows with Set_Step (This, To), from
    --  Valuator.  This is the same, and the name is wrong: it sets the
    --  whole step (FLTKAda-BUGS.md 99).
    procedure Set_Step_Top
           (This : in out Counter;
            To   : in     Long_Float)
    with Obsolescent => "use Set_Step";

    function Get_Long_Step
           (This : in Counter)
        return Long_Float;

    procedure Set_Long_Step
           (This : in out Counter;
            To   : in     Long_Float);

    procedure Set_Step_Both
           (This        : in out Counter;
            Short, Long : in     Long_Float);




    --  Text Settings  --

    function Get_Text_Color
           (This : in Counter)
        return Color;

    procedure Set_Text_Color
           (This : in out Counter;
            To   : in     Color);

    function Get_Text_Font
           (This : in Counter)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Counter;
            To   : in     Font_Kind);

    function Get_Text_Size
           (This : in Counter)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Counter;
            To   : in     Font_Size);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Counter);

    function Handle
           (This  : in out Counter;
            Event : in     Event_Kind)
        return Event_Outcome;




    --  Counter Type  --

    function Get_Kind
           (This : in out Counter)
        return Counter_Kind;

    package Extra is

        procedure Set_Kind
               (This  : in out Counter;
                Value : in     Counter_Kind);

    end Extra;


private


    type Counter is new Valuator with record
        --  Needed because Fl_Counter doesn't have
        --  a way to retrieve this value otherwise.
        Long_Step : Long_Float := 1.0;
    end record;

    overriding procedure Initialize
           (This : in out Counter);

    overriding procedure Finalize
           (This : in out Counter);

    procedure Extra_Init
           (This       : in out Counter;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Counter)
    with Inline;


    pragma Inline (Get_Step);
    pragma Inline (Set_Step);
    pragma Inline (Get_Long_Step);
    pragma Inline (Set_Long_Step);

    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Draw);
    pragma Inline (Handle);

    pragma Inline (Get_Kind);


end FLTK.Widgets.Valuators.Counters;


