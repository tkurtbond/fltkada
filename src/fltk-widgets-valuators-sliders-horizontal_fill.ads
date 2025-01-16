

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Valuators.Sliders.Horizontal_Fill is


    type Horizontal_Fill_Slider is new Slider with private;

    type Horizontal_Fill_Slider_Reference (Data : not null access Horizontal_Fill_Slider'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Horizontal_Fill_Slider;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Horizontal_Fill_Slider;

    end Forge;


private


    type Horizontal_Fill_Slider is new Slider with null record;

    overriding procedure Initialize
           (This : in out Horizontal_Fill_Slider);

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


end FLTK.Widgets.Valuators.Sliders.Horizontal_Fill;


