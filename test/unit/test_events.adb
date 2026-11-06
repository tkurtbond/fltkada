

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestEvents: Handle and Resize overrides, the
--  FLTK.Events queries, and the focus.  Events are sent to the window as
--  from the window system (FLTK.Probe), and FLTK delivers them to the
--  widgets as it would the user's; the window is never shown, until FLTK
--  shows it at the end.  pofltk's Set_Focus (NIL) has no counterpart, as
--  FLTKAda's Set_Focus takes a widget, and its check that every widget is
--  deleted none either: Ada finalizes them, and valgrind covers it.


with

    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    System;

use

    Checks,
    FLTK;


procedure Test_Events is

    package Bx renames FLTK.Widgets.Boxes;
    package Ev renames FLTK.Events;
    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;


    --  Records the last event it had, and what the queries said.
    type Pad_Box is new Bx.Box with record
        Events                  : Natural    := 0;
        Last, Current           : Event_Kind := No_Event;
        X, Y, X_Root, DY        : Integer    := 0;
        Button                  : Mouse_Button := No_Button;
        Clicks                  : Natural    := 0;
        Left, Middle, Right     : Boolean    := False;
        Shift, Ctrl             : Boolean    := False;
        Inside, Inside_Rect     : Boolean    := False;
        Key                     : Keypress   := Escape_Key;
        Text                    : String (1 .. 8) := (others => ' ');
        Length                  : Natural    := 0;
    end record;

    overriding function Handle
           (This  : in out Pad_Box;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle
           (This  : in out Pad_Box;
            Event : in     Event_Kind)
        return Event_Outcome
    is
        Back, Forward : Boolean;
    begin
        This.Events := This.Events + 1;
        This.Last := Event;
        This.Current := Ev.Last;
        case Event is
        when Push | Drag | Release =>
            This.X := Ev.Mouse_X;
            This.Y := Ev.Mouse_Y;
            This.X_Root := Ev.Mouse_X_Root;
            This.Button := Ev.Last_Button;
            This.Clicks := Ev.Get_Clicks;
            Ev.Mouse_Buttons (This.Left, This.Middle, This.Right, Back, Forward);
            This.Shift := Ev.Last_Modifier (Mod_Shift);
            This.Inside := Ev.Is_Inside (This);
            This.Inside_Rect := Ev.Is_Inside (This.Get_X, This.Get_Y, 5, 5);
            return Handled;
        when Enter | Leave | Move | Focus | Unfocus =>
            return Handled;
        when Mouse_Wheel =>
            This.DY := Ev.Mouse_DY;
            return Handled;
        when Keydown =>
            This.Key := Ev.Last_Key;
            This.Ctrl := Ev.Last_Modifier (Mod_Ctrl);
            This.Length := Ev.Text_Length;
            This.Text := (others => ' ');
            This.Text (1 .. Ev.Text'Length) := Ev.Text;
            return (if This.Key = Press ('a') then Handled else Not_Handled);
        when others =>
            return Bx.Box (This).Handle (Event);
        end case;
    end Handle;


    --  Counts its Resize calls, and resizes as FLTK would.
    type Sized_Box is new Bx.Box with record
        Resizes, Got_W : Natural := 0;
    end record;

    overriding procedure Resize
           (This       : in out Sized_Box;
            X, Y, W, H : in     Integer);

    procedure Resize
           (This       : in out Sized_Box;
            X, Y, W, H : in     Integer) is
    begin
        This.Resizes := This.Resizes + 1;
        This.Got_W := W;
        Bx.Box (This).Resize (X, Y, W, H);
    end Resize;


    --  Refuses to move or change size.
    type Fixed_Box is new Bx.Box with null record;

    overriding procedure Resize
           (This       : in out Fixed_Box;
            X, Y, W, H : in     Integer);

    procedure Resize
           (This       : in out Fixed_Box;
            X, Y, W, H : in     Integer)
    is
        pragma Unreferenced (This, X, Y, W, H);
    begin
        null;
    end Resize;


    function Same
           (Item   : access Wdg.Widget'Class;
            Wanted : in     Wdg.Widget'Class)
        return Boolean
    is
        use type System.Address;
    begin
        return Item /= null and then Item.all'Address = Wanted'Address;
    end Same;


    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Events");
    Pad    : Pad_Box := (Bx.Forge.Create (Window, 20, 30, 100, 80) with others => <>);
    Other  : constant Bx.Box := Bx.Forge.Create (Window, 150, 30, 100, 80);
    Sized  : Sized_Box := (Bx.Forge.Create (Window, 10, 150, 50, 20) with others => <>);
    Fixed  : Fixed_Box := (Bx.Forge.Create (Window, 100, 150, 50, 20) with null record);

    Used : Boolean;

begin

    --  The mouse.
    Used := Prb.Mouse (Window, Push, 50, 60, Left_Button);
    Check (Used and Pad.Last = Push and Pad.Current = Push,
        "Push reaches the Handle of the widget under the mouse, which uses it");
    Check (Pad.X = 50 and Pad.Y = 60 and Pad.X_Root = Window.Get_X + 50,
        "Mouse_X, Mouse_Y in the window's coordinates; Mouse_X_Root the screen's");
    Check (Pad.Button = Left_Button and Pad.Left and not Pad.Right and Pad.Clicks = 1
            and not Pad.Shift,
        "Last_Button, Mouse_Buttons and Get_Clicks of a single click");
    Check (Pad.Inside and not Pad.Inside_Rect, "Is_Inside of a widget and of a rectangle");
    Check (Same (Ev.Get_Pushed, Pad), "Get_Pushed is the widget that took the Push");
    Used := Prb.Mouse (Window, Drag, 200, 70, Left_Button);
    Check (Used and Pad.Last = Drag and Pad.X = 200 and not Pad.Inside,
        "Drag goes to the pushed widget, even outside it");
    Used := Prb.Mouse (Window, Release, 200, 70, Left_Button);
    Check (Used and Pad.Last = Release and Ev.Get_Pushed = null,
        "Release goes to it too, and ends the push");
    Used := Prb.Mouse (Window, Push, 50, 60, Right_Button, Mod_Shift, Clicks => 1);
    Check (Pad.Button = Right_Button and Pad.Clicks = 2 and Pad.Right and not Pad.Left
            and Pad.Shift,
        "a shifted right double click");
    Used := Prb.Mouse (Window, Release, 50, 60, Right_Button, Clicks => 1);

    --  Moving and the wheel.
    Used := Prb.Mouse (Window, Move, 60, 60, No_Button);
    Check (Same (Ev.Get_Below_Mouse, Pad), "Move: the widget under the mouse is Get_Below_Mouse");
    Used := Prb.Wheel (Window, 60, 60, 0, 3);
    Check (Used and Pad.Last = Mouse_Wheel and Pad.DY = 3,
        "Mouse_Wheel reaches it, with Mouse_DY");

    --  The keyboard.
    Check (Pad.Has_Visible_Focus and then Pad.Take_Focus and then Same (Ev.Get_Focus, Pad),
        "Take_Focus, when Handle uses Focus, gives the focus");
    Used := Prb.Key (Keydown, Press ('a'), Mod_Ctrl, "a");
    Check (Used and Pad.Key = Press ('a') and Pad.Text = "a       " and Pad.Length = 1
            and Pad.Ctrl,
        "Keydown reaches the focus, with Last_Key, Text, Text_Length and Last_Modifier");
    Used := Prb.Key (Keydown, Function_Key (2));
    Check (not Used and Pad.Key = Function_Key (2) and Pad.Length = 0
            and Pad.Text = "        ",
        "a key the focus doesn't use: F2, with no text");
    Ev.Set_Focus (Other);
    Check (Same (Ev.Get_Focus, Other) and Pad.Last = Unfocus,
        "Set_Focus moves it, unfocusing the pad");
    Pad.Set_Visible_Focus (False);
    Check (not Pad.Has_Visible_Focus and not Pad.Take_Focus,
        "a widget without visible focus doesn't take it");

    --  Resizing.
    Sized.Resize (80, 30);
    Check (Sized.Resizes = 1 and Sized.Got_W = 80 and Sized.Get_W = 80 and Sized.Get_H = 30,
        "Resize (W, H) calls the Resize override, whose parent call resizes");
    Sized.Reposition (5, 140);
    Check (Sized.Resizes = 2 and Sized.Get_X = 5 and Sized.Get_Y = 140, "so does Reposition");
    Window.Set_Resizable (Sized);
    Window.Resize (400, 200);
    Check (Sized.Resizes = 3 and Sized.Get_W = 180,
        "resizing the window resizes its resizable child, through the override");
    Fixed.Resize (0, 0, 10, 10);
    Fixed.Resize (99, 99);
    Check (Fixed.Get_X = 100 and Fixed.Get_W = 50,
        "a Resize override that doesn't call its parent's keeps the widget as it was");

    --  Last, since FLTK raises a window clicked in where no widget uses
    --  the click: it shows it, and makes it the pushed widget.
    Pad.Events := 0;
    Used := Prb.Mouse (Window, Push, Other.Get_X + 5, Other.Get_Y + 5, Left_Button);
    Check (Pad.Last /= Push and Same (Ev.Get_Pushed, Window),
        "a push on a plain box: the pad doesn't see it, and the window is pushed");
    Check (Used and Window.Is_Shown and Pad.Events = 1 and Pad.Last = Show,
        "FLTK shows the window, and the pad has Show");
    Window.Hide;

    Summary;

end Test_Events;
