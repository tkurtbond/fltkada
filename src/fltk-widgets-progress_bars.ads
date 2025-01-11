

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Progress_Bars is


    type Progress_Bar is new Widget with private;

    type Progress_Bar_Reference (Data : not null access Progress_Bar'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Progress_Bar;

    end Forge;




    function Get_Minimum
           (This : in Progress_Bar)
        return Float;

    procedure Set_Minimum
           (This : in out Progress_Bar;
            To   : in     Float);

    function Get_Maximum
           (This : in Progress_Bar)
        return Float;

    procedure Set_Maximum
           (This : in out Progress_Bar;
            To   : in     Float);

    function Get_Value
           (This : in Progress_Bar)
        return Float;

    procedure Set_Value
           (This : in out Progress_Bar;
            To   : in     Float);




    procedure Draw
           (This : in out Progress_Bar);


private


    type Progress_Bar is new Widget with null record;

    overriding procedure Initialize
           (This : in out Progress_Bar);

    overriding procedure Finalize
           (This : in out Progress_Bar);

    procedure Extra_Init
           (This       : in out Progress_Bar;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Progress_Bar)
    with Inline;


    pragma Inline (Get_Minimum);
    pragma Inline (Set_Minimum);
    pragma Inline (Get_Maximum);
    pragma Inline (Set_Maximum);
    pragma Inline (Get_Value);
    pragma Inline (Set_Value);

    pragma Inline (Draw);


end FLTK.Widgets.Progress_Bars;


