

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Menus.Menu_Buttons is


    type Menu_Button is new Menu with private;

    type Menu_Button_Reference (Data : access Menu_Button'Class) is limited null record
        with Implicit_Dereference => Data;

    --  Signifies which mouse buttons cause the menu to appear
    type Popup_Buttons is (No_Popup, Popup1, Popup2, Popup12, Popup3, Popup13, Popup23, Popup123);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu_Button;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Menu_Button;

    end Forge;




    --  Popup  --

    function Get_Popup_Kind
           (This : in Menu_Button)
        return Popup_Buttons;

    procedure Set_Popup_Kind
           (This : in out Menu_Button;
            Kind : in     Popup_Buttons);

    --  Waits for the button's window to be exposed first: under Wayland, a
    --  menu popped up over a window not yet on the screen ends the program.
    --  Unlike Menus.Popup, it calls Picked on the item picked.  It raises
    --  Program_Error for a button in no window when no window is shown,
    --  which leaves nothing to pop up over; FLTK would crash (pofltk 150).
    function Popup
           (This : in out Menu_Button)
        return Extended_Index;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Menu_Button);

    function Handle
           (This  : in out Menu_Button;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Menu_Button is new Menu with null record;

    overriding procedure Initialize
           (This : in out Menu_Button);

    overriding procedure Finalize
           (This : in out Menu_Button);

    procedure Extra_Init
           (This       : in out Menu_Button;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Menu_Button)
    with Inline;


    pragma Inline (Get_Popup_Kind);
    pragma Inline (Set_Popup_Kind);
    pragma Inline (Popup);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Menus.Menu_Buttons;


