

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Buttons.Light.Radio is


    type Radio_Light_Button is new Light_Button with private;

    type Radio_Light_Button_Reference (Data : not null access Radio_Light_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Radio_Light_Button;

    end Forge;


private


    type Radio_Light_Button is new Light_Button with null record;

    overriding procedure Initialize
           (This : in out Radio_Light_Button);

    overriding procedure Finalize
           (This : in out Radio_Light_Button);

    procedure Extra_Init
           (This       : in out Radio_Light_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Radio_Light_Button)
    with Inline;


end FLTK.Widgets.Buttons.Light.Radio;


