

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Buttons.Light.Round is


    type Round_Button is new Light_Button with private;

    type Round_Button_Reference (Data : not null access Round_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Round_Button;

    end Forge;


private


    type Round_Button is new Light_Button with null record;

    overriding procedure Initialize
           (This : in out Round_Button);

    overriding procedure Finalize
           (This : in out Round_Button);

    procedure Extra_Init
           (This       : in out Round_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Round_Button)
    with Inline;


end FLTK.Widgets.Buttons.Light.Round;


