

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Buttons is


    type Button is new Widget with private;

    type Button_Reference (Data : not null access Button'Class) is limited null record
        with Implicit_Dereference => Data;

    type State is (Off, On);

    --  How a button behaves when pushed (Fl_Button::type).  A normal button
    --  is on only while held down; a toggle button changes state at each
    --  push; a radio button turns on, and turns off the other radio buttons
    --  in its group.  A hidden button, kept for Forms, is not drawn.  The
    --  Toggle_Button and Radio_Button types set their kind themselves.
    type Button_Kind is (Normal_Kind, Toggle_Kind, Hidden_Kind, Radio_Kind);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Button;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Button;

    end Forge;




    --  State  --

    function Is_On
           (This : in Button)
        return Boolean;

    function Get_State
           (This : in Button)
        return State;

    procedure Set_State
           (This : in out Button;
            St   : in     State);

    procedure Set_Only
           (This : in out Button);




    --  Settings  --

    function Get_Kind
           (This : in Button)
        return Button_Kind;

    procedure Set_Kind
           (This : in out Button;
            To   : in     Button_Kind);

    function Get_Down_Box
           (This : in Button)
        return Box_Kind;

    procedure Set_Down_Box
           (This : in out Button;
            To   : in     Box_Kind);

    --  A compact button, a key in a keypad, is drawn with its parent's
    --  box, clipped to the button, and a divider where it meets another
    --  key (Fl_Button::compact).
    function Is_Compact
           (This : in Button)
        return Boolean;

    procedure Set_Compact
           (This : in out Button;
            To   : in     Boolean);

    function Get_Shortcut
           (This : in Button)
        return Key_Combo;

    procedure Set_Shortcut
           (This : in out Button;
            Key  : in     Key_Combo);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Button);

    function Handle
           (This  : in out Button;
            Event : in     Event_Kind)
        return Event_Outcome;




    --  Miscellaneous  --

    procedure Simulate_Key_Action
           (This : in out Button);


private


    type Button is new Widget with null record;

    for Button_Kind use
       (Normal_Kind => 0,       --  FL_NORMAL_BUTTON
        Toggle_Kind => 1,       --  FL_TOGGLE_BUTTON
        Hidden_Kind => 3,       --  FL_HIDDEN_BUTTON
        Radio_Kind  => 102);    --  FL_RADIO_BUTTON

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


    pragma Inline (Is_On);
    pragma Inline (Get_State);
    pragma Inline (Set_State);
    pragma Inline (Set_Only);

    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);
    pragma Inline (Get_Down_Box);
    pragma Inline (Set_Down_Box);
    pragma Inline (Is_Compact);
    pragma Inline (Set_Compact);
    pragma Inline (Get_Shortcut);
    pragma Inline (Set_Shortcut);

    pragma Inline (Draw);
    pragma Inline (Handle);

    pragma Inline (Simulate_Key_Action);


end FLTK.Widgets.Buttons;


