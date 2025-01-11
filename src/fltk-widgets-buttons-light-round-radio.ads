

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Buttons.Light.Round.Radio is


    type Radio_Round_Button is new Round_Button with private;

    type Radio_Round_Button_Reference (Data : not null access Radio_Round_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Radio_Round_Button;

    end Forge;


private


    type Radio_Round_Button is new Round_Button with null record;

    overriding procedure Initialize
           (This : in out Radio_Round_Button);

    overriding procedure Finalize
           (This : in out Radio_Round_Button);

    procedure Extra_Init
           (This       : in out Radio_Round_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Radio_Round_Button)
    with Inline;


end FLTK.Widgets.Buttons.Light.Round.Radio;


