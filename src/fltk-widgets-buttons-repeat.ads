

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Buttons.Repeat is


    type Repeat_Button is new Button with private;

    type Repeat_Button_Reference (Data : not null access Repeat_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Repeat_Button;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Repeat_Button;

    end Forge;




    procedure Deactivate
           (This : in out Repeat_Button);




    function Handle
           (This  : in out Repeat_Button;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Repeat_Button is new Button with null record;

    overriding procedure Initialize
           (This : in out Repeat_Button);

    overriding procedure Finalize
           (This : in out Repeat_Button);

    procedure Extra_Init
           (This       : in out Repeat_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Repeat_Button)
    with Inline;


    pragma Inline (Deactivate);

    pragma Inline (Handle);


end FLTK.Widgets.Buttons.Repeat;


