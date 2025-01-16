

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Buttons.Toggle is


    type Toggle_Button is new Button with private;

    type Toggle_Button_Reference (Data : not null access Toggle_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Toggle_Button;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Toggle_Button;

    end Forge;


private


    type Toggle_Button is new Button with null record;

    overriding procedure Initialize
           (This : in out Toggle_Button);

    overriding procedure Finalize
           (This : in out Toggle_Button);

    procedure Extra_Init
           (This       : in out Toggle_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Toggle_Button)
    with Inline;


end FLTK.Widgets.Buttons.Toggle;


