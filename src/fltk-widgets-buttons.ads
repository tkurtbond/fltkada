

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Widgets.Buttons is


    type Button is new Widget with private;

    type Button_Reference (Data : not null access Button'Class) is limited null record
        with Implicit_Dereference => Data;

    type State is (Off, On);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Button;

    end Forge;




    function Get_State
           (This : in Button)
        return State;

    procedure Set_State
           (This : in out Button;
            St   : in     State);

    procedure Set_Only
           (This : in out Button);




    function Get_Down_Box
           (This : in Button)
        return Box_Kind;

    procedure Set_Down_Box
           (This : in out Button;
            To   : in     Box_Kind);

    function Get_Shortcut
           (This : in Button)
        return Key_Combo;

    procedure Set_Shortcut
           (This : in out Button;
            Key  : in     Key_Combo);




    procedure Draw
           (This : in out Button);

    function Handle
           (This  : in out Button;
            Event : in     Event_Kind)
        return Event_Outcome;




    procedure Simulate_Key_Action
           (This : in out Button);


private


    type Button is new Widget with null record;

    overriding procedure Initialize
           (This : in out Button);

    overriding procedure Finalize
           (This : in out Button);

    procedure Extra_Init
           (This       : in out Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Button)
    with Inline;


    pragma Inline (Get_State);
    pragma Inline (Set_State);
    pragma Inline (Set_Only);

    pragma Inline (Get_Down_Box);
    pragma Inline (Set_Down_Box);
    pragma Inline (Get_Shortcut);
    pragma Inline (Set_Shortcut);

    pragma Inline (Draw);
    pragma Inline (Handle);

    pragma Inline (Simulate_Key_Action);


end FLTK.Widgets.Buttons;


