

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Valuators.Sliders.Horizontal is


    type Horizontal_Slider is new Slider with private;

    type Horizontal_Slider_Reference (Data : not null access Horizontal_Slider'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Horizontal_Slider;

    end Forge;


private


    type Horizontal_Slider is new Slider with null record;

    overriding procedure Initialize
           (This : in out Horizontal_Slider);

    overriding procedure Finalize
           (This : in out Horizontal_Slider);

    procedure Extra_Init
           (This       : in out Horizontal_Slider;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Horizontal_Slider)
    with Inline;


end FLTK.Widgets.Valuators.Sliders.Horizontal;


