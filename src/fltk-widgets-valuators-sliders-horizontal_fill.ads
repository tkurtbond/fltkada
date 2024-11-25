

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Valuators.Sliders.Horizontal_Fill is


    type Horizontal_Fill_Slider is new Slider with private;

    type Horizontal_Fill_Slider_Reference (Data : not null access Horizontal_Fill_Slider'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Horizontal_Fill_Slider;

    end Forge;




    procedure Draw
           (This : in out Horizontal_Fill_Slider);

    function Handle
           (This  : in out Horizontal_Fill_Slider;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Horizontal_Fill_Slider is new Slider with null record;

    overriding procedure Finalize
           (This : in out Horizontal_Fill_Slider);

    procedure Extra_Init
           (This       : in out Horizontal_Fill_Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Horizontal_Fill_Slider)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Valuators.Sliders.Horizontal_Fill;

