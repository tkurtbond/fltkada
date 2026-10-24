

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-remap-numpad-keyboard-keys.cxx:
--  Force number pad to type numbers even if NumLock off
--
--  This demonstrates several important things:
--
--     o How to use the global event dispatcher function Set_Dispatch
--
--     o How to remap keyboard events
--
--     o How to use Original_Last_Key to easily ensure the dual purpose
--       numeric keypad keys generate only numbers even if NumLock is off,
--       without affecting the dedicated Home/End/etc keys.
--
--  Use of Original_Last_Key ensures someone hitting e.g. the "7/Home" key
--  gets the keypad '7' key, and not Home_Key, while allowing the dedicated
--  "Home" key to still generate Home_Key.  This allows users to use the
--  "Home" and "End" keys to navigate the buffer, while "7/Home" and "1/End"
--  always type numbers.
--
--  The original was based on the fltk.general thread entitled
--  "keyboard mapping", Aug 2019.


with

    FLTK.Events,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;

use type

    FLTK.Event_Kind,
    FLTK.Widgets.Buttons.State;


function Howto_Remap_Numpad_Keyboard_Keys
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Win renames FLTK.Widgets.Groups.Windows;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package Txt renames FLTK.Widgets.Inputs.Text;


    type Check_Button_Access is access Chk.Check_Button;

    G_Check_Button : Check_Button_Access;


    --  Global event handler: FLTK calls this after event translation.  It's up
    --  to us to call Handle to actually deliver the event to the widgets.  If we
    --  don't and just return, the event will be dropped.  See docs for more.
    function My_Handler
           (Event  : in     FLTK.Event_Kind;
            Origin : access Win.Window'Class)
        return FLTK.Event_Outcome is
    begin
        --  Remapping disabled?  Early exit..
        if G_Check_Button.Get_State = Btn.Off then
            return FLTK.Events.Handle (Event, Origin);
        end if;
        --  Keyboard key pressed?  See if we should remap..
        if Event = FLTK.Keydown or else Event = FLTK.Keyup then
            declare
                --  Get FLTK keycode /before/ NumLock state is applied (see above)
                Key : constant FLTK.Keypress := FLTK.Events.Original_Last_Key;
            begin
                if FLTK.Is_Keypad (Key) then   --  keypad key pressed?
                    --  convert keypad keycode -> ascii
                    FLTK.Events.Set_Text ((1 => FLTK.Keypad_Character (Key)));
                    --  note: some input widgets require this too
                    FLTK.Events.Set_Last_Key (Key);
                end if;
            end;
        end if;
        return FLTK.Events.Handle (Event, Origin);   --  let FLTK deliver event to widgets
    end My_Handler;


    The_Window : DW.Double_Window := DW.Forge.Create (400, 150, "Keyboard Translation Test");

    Input : Txt.Text_Input := Txt.Forge.Create (The_Window, 100, 10, 200, 25, "Input:");


begin


    G_Check_Button := new Chk.Check_Button'(Chk.Forge.Create
        (The_Window, 100, 40, 280, 25, "Force numeric keypad to type numbers"));
    G_Check_Button.Set_Label_Size (12);
    G_Check_Button.Set_State (Btn.On);

    The_Window.End_Current;
    The_Window.Set_Resizable (The_Window);
    The_Window.Show_With_Args;
    The_Window.Set_Tooltip
       ("Turn NumLock OFF, then type into Input:" & ASCII.LF &
        "using numeric keypad to test translation");
    --  Set up our event handler to manage events
    FLTK.Events.Set_Dispatch (My_Handler'Unrestricted_Access);
    return FLTK.Run;


end Howto_Remap_Numpad_Keyboard_Keys;
