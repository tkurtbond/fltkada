--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/handle_events.cxx: writes each event a double-buffered
--  window gets to standard error, with where it happened and what it
--  carries.  The screen is written as FLTK numbers it, from 0, so that
--  the output is FLTK's.  Guided by pofltk's HandleEvents.Mod.


with

    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.Events,
    FLTK.Screen,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double;

function Handle_Events
    return Integer
is

    package Ev  renames FLTK.Events;
    package Btn renames FLTK.Widgets.Buttons;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    package Err renames Ada.Text_IO;


    --  N right-justified in Width columns, as printf's "%Nd".
    function Int
           (N     : in Integer;
            Width : in Natural := 0)
        return String
    is
        Image : constant String := Ada.Strings.Fixed.Trim (N'Image, Ada.Strings.Left);
    begin
        if Image'Length >= Width then
            return Image;
        else
            return (1 .. Width - Image'Length => ' ') & Image;
        end if;
    end Int;

    --  N in lower-case hexadecimal, as printf's "%x".
    function Hex
           (N : in Natural)
        return String
    is
        Digits_Of : constant String := "0123456789abcdef";
    begin
        if N >= 16 then
            return Hex (N / 16) & Digits_Of (N mod 16 + 1);
        else
            return (1 => Digits_Of (N + 1));
        end if;
    end Hex;

    --  S as printf's "%-18.18s".
    function Name
           (S : in String)
        return String is
    begin
        if S'Length >= 18 then
            return S (S'First .. S'First + 17);
        else
            return S & (1 .. 18 - S'Length => ' ');
        end if;
    end Name;

    --  The mouse buttons held, as Fl::event_buttons () >> 24 gives them:
    --  1 left, 2 middle, 4 right, 8 back, 16 forward.
    function Buttons
        return Natural
    is
        Left, Middle, Right, Back, Forward : Boolean;
    begin
        Ev.Mouse_Buttons (Left, Middle, Right, Back, Forward);
        return Boolean'Pos (Left) + 2 * Boolean'Pos (Middle) + 4 * Boolean'Pos (Right)
            + 8 * Boolean'Pos (Back) + 16 * Boolean'Pos (Forward);
    end Buttons;


    type App is new Dbl.Double_Window with record
        Event_Num : Natural := 0;  --  the last event's, from 1 to 999
    end record;

    overriding function Handle
           (This  : in out App;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    --  Writes the current event.
    procedure Print_Event
           (This  : in out App;
            Event : in     FLTK.Event_Kind)
    is
        Screen : constant Positive := This.Get_Screen_Num;
        Scale  : constant Integer :=
            Integer (Long_Float'Floor (Long_Float (FLTK.Screen.Get_Scale (Screen)) * 100.0 + 0.5));
    begin
        This.Event_Num := This.Event_Num + 1;
        Err.Put (Err.Standard_Error,
            "[" & Int (This.Event_Num, 3) & ", win(" & Int (This.Get_X) & ","
            & Int (This.Get_Y) & "," & Int (This.Get_W) & "," & Int (This.Get_H)
            & "), screen " & Int (Screen - 1) & ", scale " & Int (Scale, 3) & "%] "
            & Name (FLTK.Event_Name (Event)) & " at (" & Int (Ev.Mouse_X, 4) & ", "
            & Int (Ev.Mouse_Y, 4) & ")");
        This.Event_Num := This.Event_Num mod 999;
    end Print_Event;

    function Handle
           (This  : in out App;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Result : FLTK.Event_Outcome;
        Held   : Natural;
    begin
        Print_Event (This, Event);  --  common for all events
        Result := Dbl.Double_Window (This).Handle (Event);
        Held := Buttons;
        case Event is
            when FLTK.Push =>
                Err.Put (Err.Standard_Error, ", button "
                    & Int (FLTK.Mouse_Button'Pos (Ev.Last_Button)) & " down, buttons = 0x"
                    & Hex (Held));
                Result := FLTK.Handled;
            when FLTK.Release =>
                Err.Put (Err.Standard_Error, ", button "
                    & Int (FLTK.Mouse_Button'Pos (Ev.Last_Button)) & " up,   buttons = 0x"
                    & Hex (Held));
                Result := FLTK.Handled;
            when FLTK.Mouse_Wheel =>
                Err.Put (Err.Standard_Error, ", dx = " & Int (Ev.Mouse_DX)
                    & ", dy = " & Int (Ev.Mouse_DY));
                Result := FLTK.Handled;
            when FLTK.Enter | FLTK.Leave =>
                Result := FLTK.Handled;
            when FLTK.Move | FLTK.Drag =>
                Err.Put (Err.Standard_Error, ",          mouse buttons = 0x" & Hex (Held));
                Result := FLTK.Handled;
            when FLTK.Keydown =>
                declare
                    Text : constant String := Ev.Text;
                begin
                    if Text'Length > 0 and then Text (Text'First) in 'a' .. 'z' then
                        Err.Put (Err.Standard_Error, ", Text = '" & Text & "'");
                        Result := FLTK.Handled;
                    else  --  "ignore" everything else
                        Err.Put (Err.Standard_Error, ", ignored '" & Text & "'");
                    end if;
                end;
            when FLTK.Keyup =>
                Result := FLTK.Handled;
            when FLTK.Focus | FLTK.Unfocus =>
                Result := FLTK.Handled;
            when others =>
                null;
        end case;
        Err.New_Line (Err.Standard_Error);
        Err.Flush (Err.Standard_Error);
        return Result;
    end Handle;


    --  Closes the window.
    procedure Quit_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Item.Nearest_Window.Hide;
    end Quit_CB;


    Win  : App := (Dbl.Forge.Create (10, 10, 240, 240) with others => <>);
    Quit : Btn.Button := Btn.Forge.Create (Win, 90, 100, 60, 40, "Quit");

begin

    Quit.Set_Box (FLTK.Thin_Up_Box);
    Quit.Set_Callback (Quit_CB'Unrestricted_Access);
    Win.Set_Resizable (Win);
    Win.Show_With_Args;
    return FLTK.Run;

end Handle_Events;
