


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Buttons:  values, kinds, radio groups, shortcuts and repeating, after
--  pofltk's test/TestButtons.Mod.  Clicks and keys are sent as from the
--  window system (FLTK.Probe), to a window never shown.  The shortcut
--  button is test_shortcut_button's.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Radio,
    FLTK.Widgets.Buttons.Light.Round.Radio,
    FLTK.Widgets.Buttons.Radio,
    FLTK.Widgets.Buttons.Repeat,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Button is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Ent renames FLTK.Widgets.Buttons.Enter;
    package Lgt renames FLTK.Widgets.Buttons.Light;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package RLt renames FLTK.Widgets.Buttons.Light.Radio;
    package Rnd renames FLTK.Widgets.Buttons.Light.Round;
    package RRd renames FLTK.Widgets.Buttons.Light.Round.Radio;
    package Rad renames FLTK.Widgets.Buttons.Radio;
    package Rep renames FLTK.Widgets.Buttons.Repeat;
    package Tgl renames FLTK.Widgets.Buttons.Toggle;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "Test_Button");
    Push   : Btn.Button := Btn.Forge.Create (Window, 10, 10, 80, 25, "push");
    Toggle : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 100, 10, 80, 25, "toggle");
    Check_B : constant Chk.Check_Button := Chk.Forge.Create (Window, 190, 10, 80, 25, "check");
    Light  : constant Lgt.Light_Button := Lgt.Forge.Create (Window, 280, 10, 80, 25, "light");
    Round  : constant Rnd.Round_Button := Rnd.Forge.Create (Window, 10, 40, 80, 25, "round");
    Ret    : Ent.Enter_Button := Ent.Forge.Create (Window, 100, 40, 80, 25, "return");
    Repeat : Rep.Repeat_Button := Rep.Forge.Create (Window, 190, 40, 80, 25, "repeat");
    Group  : Grp.Group := Grp.Forge.Create (Window, 10, 100, 380, 40);
    R1     : Rad.Radio_Button := Rad.Forge.Create (Group, 10, 100, 80, 25, "r1");
    R2     : RLt.Radio_Light_Button := RLt.Forge.Create (Group, 100, 100, 80, 25, "r2");
    R3     : constant RRd.Radio_Round_Button := RRd.Forge.Create (Group, 190, 100, 80, 25, "r3");

    Calls        : Natural := 0;
    Push_Calls   : Natural := 0;
    Push_Seen    : Boolean := True;
    Push_Changed : Boolean := False;
    Held         : Boolean := False;
    Before       : Natural;
    Done         : Boolean;
    Ignore       : Boolean;

    procedure Count
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Calls := Calls + 1;
    end Count;

    --  The push button's callback notes its value and whether it changed.
    procedure Push_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Push_Calls := Push_Calls + 1;
        Push_Seen := Btn.Button'Class (Item).Is_On;
        Push_Changed := Item.Has_Changed;
    end Push_CB;

    procedure Set_Done is
    begin
        Done := True;
    end Set_Done;

    --  Handles events for Seconds.
    procedure Wait_For
           (Seconds : in Long_Float) is
    begin
        Done := False;
        FLTK.Static.Add_Timeout (Seconds, Set_Done'Unrestricted_Access);
        while not Done loop
            exit when FLTK.Wait (1.0) < 0.0;
        end loop;
    end Wait_For;

    procedure Press
           (Item : in Wdg.Widget'Class) is
    begin
        Held := Prb.Mouse (Window, FLTK.Push, Item.Get_X + 5, Item.Get_Y + 5);
    end Press;

    procedure Release
           (Item : in Wdg.Widget'Class) is
    begin
        Held := Prb.Mouse (Window, FLTK.Release, Item.Get_X + 5, Item.Get_Y + 5);
    end Release;

    procedure Click
           (Item : in Wdg.Widget'Class) is
    begin
        Press (Item);
        Release (Item);
    end Click;

begin

    --  A push button.
    Push.Set_Callback (Push_CB'Unrestricted_Access);
    Check (not Push.Is_On and Push.Get_When = When_Release,
        "a push button starts off, calling back on release");
    Press (Push);
    Check (Held and Push.Is_On and Push_Calls = 0,
        "it is on while held, and hasn't called back");
    Release (Push);
    Check (not Push.Is_On and Push_Calls = 1 and not Push_Seen,
        "released over it:  one callback, which sees it off again");
    Check (Push_Changed and not Push.Has_Changed,
        "Has_Changed is True in the callback, and False once it returns");
    Push.Set_State (Btn.On);
    Check (Push.Is_On and Push_Calls = 1, "Set_State sets the value, without a callback");
    Push.Set_State (Btn.Off);

    --  Toggles.
    Toggle.Set_Callback (Count'Unrestricted_Access);
    Click (Toggle);
    Check (Toggle.Is_On and Calls = 1, "a toggle button:  one click turns it on");
    Click (Toggle);
    Check (not Toggle.Is_On and Calls = 2, "and one more off");
    Click (Check_B);
    Click (Light);
    Click (Round);
    Check (Check_B.Is_On and Light.Is_On and Round.Is_On,
        "check, light and round buttons each toggle when clicked");

    --  Radio groups.
    Click (R2);
    Check (not R1.Is_On and R2.Is_On and not R3.Is_On, "clicking a radio button turns it on");
    Click (R3);
    Check (not R1.Is_On and not R2.Is_On and R3.Is_On, "and its group's others off");
    Click (R3);
    Check (R3.Is_On, "clicking an on radio button leaves it on");
    R1.Set_Only;
    Check (R1.Is_On and not R2.Is_On and not R3.Is_On,
        "Set_Only is a click without the callback");
    R2.Set_State (Btn.On);
    Check (R1.Is_On and R2.Is_On, "Set_State on a radio button leaves the others");

    --  Shortcuts.
    Push.Set_Shortcut (Mod_Ctrl + 'x');
    Check (Push.Get_Shortcut = Mod_Ctrl + 'x', "a shortcut reads back");
    Before := Push_Calls;
    Check (Prb.Shortcut (Window, Press ('x'), Mod_Ctrl, "x") and Push_Calls = Before + 1,
        "typing the shortcut clicks the button");
    Check (not Prb.Shortcut (Window, Press ('x'), Mod_None, "x") and Push_Calls = Before + 1,
        "the key without Ctrl doesn't");
    Ret.Set_Callback (Count'Unrestricted_Access);
    Calls := 0;
    Check (Prb.Shortcut (Window, Enter_Key, Mod_None, (1 => ASCII.CR)) and Calls = 1,
        "Enter clicks a return button");
    Push.Set_Shortcut (No_Key);

    --  Other settings.
    Push.Set_Down_Box (Flat_Box);
    Check (Push.Get_Down_Box = Flat_Box, "the down box reads back");

    --  Repeating:  FLTK waits 0.5 s, then repeats every 0.1 s.  Up to 5 s,
    --  not 1, since valgrind is slow.
    Repeat.Set_Callback (Count'Unrestricted_Access);
    Calls := 0;
    Press (Repeat);
    for I in 1 .. 20 loop
        exit when Calls >= 3;
        Wait_For (0.25);
    end loop;
    Check (Calls >= 3, "a held repeat button calls back again and again");
    Repeat.Deactivate;
    Before := Calls;
    Wait_For (0.5);
    Check (Calls = Before and not Repeat.Is_Active,
        "deactivating it stops the repeating (FLTK's FL_DEACTIVATE, through Handle)");
    Release (Repeat);

    Ignore := FLTK.Check;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Button;



