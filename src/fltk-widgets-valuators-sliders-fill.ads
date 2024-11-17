

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Valuators.Sliders.Fill is


    type Fill_Slider is new Slider with private;

    type Fill_Slider_Reference (Data : not null access Fill_Slider'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Fill_Slider;

    end Forge;




    procedure Draw
           (This : in out Fill_Slider);

    function Handle
           (This  : in out Fill_Slider;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Fill_Slider is new Slider with null record;

    overriding procedure Finalize
           (This : in out Fill_Slider);

    procedure Extra_Init
           (This       : in out Fill_Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Fill_Slider)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Valuators.Sliders.Fill;

