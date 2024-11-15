

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Valuators.Sliders.Nice is


    type Nice_Slider is new Slider with private;

    type Nice_Slider_Reference (Data : not null access Nice_Slider'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Nice_Slider;

    end Forge;




    procedure Draw
           (This : in out Nice_Slider);

    function Handle
           (This  : in out Nice_Slider;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Nice_Slider is new Slider with null record;

    overriding procedure Finalize
           (This : in out Nice_Slider);

    procedure Extra_Init
           (This       : in out Nice_Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Valuators.Sliders.Nice;

