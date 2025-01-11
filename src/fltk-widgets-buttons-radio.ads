

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Buttons.Radio is


    type Radio_Button is new Button with private;

    type Radio_Button_Reference (Data : not null access Radio_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Radio_Button;

    end Forge;


private


    type Radio_Button is new Button with null record;

    overriding procedure Initialize
           (This : in out Radio_Button);

    overriding procedure Finalize
           (This : in out Radio_Button);

    procedure Extra_Init
           (This       : in out Radio_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Radio_Button)
    with Inline;


end FLTK.Widgets.Buttons.Radio;


