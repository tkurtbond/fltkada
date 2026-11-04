

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Buttons.Shortcut is


    --  A button that, clicked, waits for a key and shows it as its value.
    --  Its value is the key, not the button's own shortcut, which
    --  Get_Shortcut and Set_Shortcut still are.
    type Shortcut_Button is new Button with private;

    type Shortcut_Button_Reference (Data : not null access Shortcut_Button'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Shortcut_Button;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Shortcut_Button;

    end Forge;




    --  Value  --

    function Get_Value
           (This : in Shortcut_Button)
        return Key_Combo;

    procedure Set_Value
           (This : in out Shortcut_Button;
            To   : in     Key_Combo);




    --  Events  --

    function Handle
           (This  : in out Shortcut_Button;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Shortcut_Button is new Button with null record;

    overriding procedure Initialize
           (This : in out Shortcut_Button);

    overriding procedure Finalize
           (This : in out Shortcut_Button);

    procedure Extra_Init
           (This       : in out Shortcut_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Shortcut_Button)
    with Inline;


    pragma Inline (Get_Value);
    pragma Inline (Set_Value);

    pragma Inline (Handle);


end FLTK.Widgets.Buttons.Shortcut;


