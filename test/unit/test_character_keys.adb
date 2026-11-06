--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 95: a Keypress could be made only from a Character in
--  32 .. 126 or from one of FLTK's named keys, so a shortcut couldn't be
--  a-umlaut, the Euro sign or CR, as FLTK's test/menubar.cxx's are.
--  Character_Key gives the key for any character, by its code point.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Bars;

use

    Checks,
    FLTK;


procedure Test_Character_Keys is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Bar renames FLTK.Widgets.Menus.Menu_Bars;

    A_Umlaut : constant Keypress := Character_Key (Wide_Character'Val (16#E4#));
    Euro     : constant Keypress := Character_Key (Wide_Character'Val (16#20AC#));
    Cieuc    : constant Keypress := Character_Key (Wide_Character'Val (16#3148#));
    CR       : constant Keypress := Character_Key (Wide_Character'Val (13));

    --  UTF-8, as the window system gives the text of each key.
    A_Umlaut_Text : constant String := Character'Val (16#C3#) & Character'Val (16#A4#);
    Euro_Text     : constant String :=
        Character'Val (16#E2#) & Character'Val (16#82#) & Character'Val (16#AC#);
    Cieuc_Text    : constant String :=
        Character'Val (16#E3#) & Character'Val (16#85#) & Character'Val (16#88#);

    Last_Pick : Natural := 0;

    procedure Pick_1 (Ignore : in out Wdg.Widget'Class) is
    begin
        Last_Pick := 1;
    end Pick_1;

    procedure Pick_2 (Ignore : in out Wdg.Widget'Class) is
    begin
        Last_Pick := 2;
    end Pick_2;

    procedure Pick_3 (Ignore : in out Wdg.Widget'Class) is
    begin
        Last_Pick := 3;
    end Pick_3;

    procedure Pick_4 (Ignore : in out Wdg.Widget'Class) is
    begin
        Last_Pick := 4;
    end Pick_4;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Character_Keys");
    Menu   : Bar.Menu_Bar := Bar.Forge.Create (Window, 0, 0, 200, 25);

    function Picks
           (Code  : in Keypress;
            State : in Modifier;
            Text  : in String)
        return Natural is
    begin
        Last_Pick := 0;
        if not Prb.Shortcut (Window, Code, State, Text) then
            return 0;
        end if;
        return Last_Pick;
    end Picks;

begin

    Check (Character_Key ('a') = Press ('a'), "Character_Key ('a') is Press ('a')");
    Check (Character_Key (Wide_Character'Val (16#FF0D#)) = Enter_Key,
        "Character_Key (16#FF0D#) is Enter_Key");
    Check (CR /= Enter_Key, "CR isn't Enter_Key");

    --  FLTK's X11 driver names the key as Xlib does, its other drivers
    --  give the character itself (FLTK-issues.md F32).
    if Prb.On_Wayland then
        Check (Draw.Shortcut_Label (Press (Euro)) = Euro_Text,
            "the Euro sign's label is itself, '" & Draw.Shortcut_Label (Press (Euro)) & "'");
        Check (Draw.Shortcut_Label (Press (CR)) = "" & ASCII.CR,
            "CR's label is itself, '" & Draw.Shortcut_Label (Press (CR)) & "'");
    else
        Check (Draw.Shortcut_Label (Press (Euro)) = "EuroSign",
            "the Euro sign's label is Xlib's name, '"
            & Draw.Shortcut_Label (Press (Euro)) & "'");
        Check (Draw.Shortcut_Label (Press (CR)) = "Enter",
            "CR's label is 'Enter', '" & Draw.Shortcut_Label (Press (CR)) & "'");
    end if;
    Check (Draw.Shortcut_Label (Press (Cieuc)) = Cieuc_Text,
        "Hangul cieuc's label is itself, '" & Draw.Shortcut_Label (Press (Cieuc)) & "'");

    Menu.Add ("first/a-umlaut", Pick_1'Unrestricted_Access, Mod_Alt + A_Umlaut);
    Menu.Add ("first/euro", Pick_2'Unrestricted_Access, Mod_Command + Euro);
    Menu.Add ("first/cieuc", Pick_3'Unrestricted_Access, Press (Cieuc));
    Menu.Add ("first/cr", Pick_4'Unrestricted_Access, Press (CR));

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;

    --  Each is offered as the window system gives it: a key code FLTK
    --  doesn't know, and the character as text.
    Check (Picks (Press ('a'), Mod_Alt, A_Umlaut_Text) = 1, "Alt+a-umlaut picks its item");
    Check (Picks (Press ('e'), Mod_Command, Euro_Text) = 2, "Command+Euro picks its item");
    Check (Picks (Press ('w'), Mod_None, Cieuc_Text) = 3, "cieuc picks its item");
    Check (Picks (Enter_Key, Mod_None, "" & ASCII.CR) = 4, "CR picks its item");
    Check (Picks (Press ('a'), Mod_Alt, "a") = 0, "Alt+a picks nothing");

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Character_Keys;
