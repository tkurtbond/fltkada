--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 135: Keypress was 16 bits, and Events.Last_Key took
--  Fl::event_key mod 65536, so X11's XF86 keysyms, such as 16#1008FF02#
--  for XF86MonBrightnessUp, came out as other keys: 16#FF02#.  Found by
--  the port of FLTK's test/keyboard.cxx.  Also checks Key_Number and
--  Numbered_Key, added for that port, and that a shortcut, which keeps
--  only 16 bits of key, still decodes and refuses a wider key.


with

    Ada.Exceptions,
    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Widgets.Buttons;

use

    Checks,
    FLTK;


procedure Test_Key_Numbers is

    package Btn renames FLTK.Widgets.Buttons;

    Brightness_Up : constant Natural := 16#1008_FF02#;

    Button : Btn.Button := Btn.Forge.Create (0, 0, 80, 25, "button");

begin

    Check (Key_Number (Escape_Key) = 16#FF1B#, "Escape is FL_Escape");
    Check (Key_Number (Press ('a')) = 97, "'a' is 97");
    Check (Key_Number (Volume_Down_Key) = 16#EF11#, "Volume_Down is FL_Volume_Down");
    Check (Numbered_Key (16#FF1B#) = Escape_Key, "Numbered_Key is Key_Number's inverse");
    Check (Key_Number (Numbered_Key (Brightness_Up)) = Brightness_Up,
        "a keysym past 16#FFFF# keeps its number");

    FLTK.Probe.Set_Key (Numbered_Key (Brightness_Up));
    Check (Key_Number (FLTK.Events.Last_Key) = Brightness_Up,
        "Last_Key gives XF86MonBrightnessUp's whole keysym, not 16#FF02#");
    Check (FLTK.Events.Last_Key /= Numbered_Key (16#FF02#), "nor the key 16#FF02#");

    FLTK.Probe.Set_Key (Escape_Key);
    Check (FLTK.Events.Last_Key = Escape_Key, "Last_Key still gives Escape");

    Button.Set_Shortcut (Mod_Ctrl + Mod_Shift + Escape_Key);
    Check (Button.Get_Shortcut = Mod_Ctrl + Mod_Shift + Escape_Key,
        "a shortcut with modifiers decodes to its key and modifiers");
    Button.Set_Shortcut (Mod_Alt + Left_Button);
    Check (Button.Get_Shortcut = Mod_Alt + Left_Button, "and a mouse button shortcut too");

    begin
        Button.Set_Shortcut (Mod_Ctrl + Numbered_Key (Brightness_Up));
        Check (False, "a shortcut of a key past 16#FFFF# raises");
    exception
    when Constraint_Error =>
        Check (True, "a shortcut of a key past 16#FFFF# raises");
    end;
    Check (Button.Get_Shortcut = Mod_Alt + Left_Button, "and leaves the shortcut as it was");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Key_Numbers;
