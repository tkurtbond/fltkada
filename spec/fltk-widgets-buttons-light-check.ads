

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Buttons.Light.Check is


    type Check_Button is new Light_Button with private;

    type Check_Button_Reference (Data : not null access Check_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Check_Button;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Check_Button;

    end Forge;


private


    type Check_Button is new Light_Button with null record;

    overriding procedure Initialize
           (This : in out Check_Button);

    overriding procedure Finalize
           (This : in out Check_Button);

    procedure Extra_Init
           (This       : in out Check_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Check_Button)
    with Inline;


end FLTK.Widgets.Buttons.Light.Check;


