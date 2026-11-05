--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Phase 8's core statics: shutdown, timestamps, contrast and colour
--  parsing, box and menu settings, callback reasons, the selection owner,
--  schemes and screen scaling.  (From pofltk's test/TestStatics.Mod.)


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    System;

use

    Checks,
    FLTK;


procedure Test_Statics_Core is

    package Btn renames FLTK.Widgets.Buttons;
    package Prb renames FLTK.Probe;
    package Sta renames FLTK.Static;
    package Win renames FLTK.Widgets.Groups.Windows;

    Checked, Idled : Natural := 0;

    procedure Count_Check is
    begin
        Checked := Checked + 1;
    end Count_Check;

    procedure Count_Idle is
    begin
        Idled := Idled + 1;
    end Count_Idle;

    Boom : exception;

    procedure Raise_Check is
    begin
        raise Boom;
    end Raise_Check;

    procedure Run_Checks_Action is
    begin
        Sta.Run_Checks;
    end Run_Checks_Action;

    procedure Show_It
           (W : in out Win.Window'Class)
    is
        Ignore : Boolean;
    begin
        W.Show;
        for I in 1 .. 100 loop
            exit when W.Is_Shown;
            Ignore := FLTK.Wait (0.02) = 0.0;
        end loop;
    end Show_It;


    procedure Get_Awake_Action is
        Ignore : constant Sta.Awake_Handler := Sta.Get_Awake_Handler;
    begin
        null;
    end Get_Awake_Action;

    procedure Add_Awake_Action is
    begin
        Sta.Add_Awake_Handler (Count_Idle'Unrestricted_Access);
    end Add_Awake_Action;

    procedure Awake_Action is
    begin
        Sta.Awake (Count_Idle'Unrestricted_Access);
    end Awake_Action;

    procedure Test_Loop is
    begin
        Sta.Add_Check (Count_Check'Unrestricted_Access);
        Sta.Run_Checks;
        Check (Checked = 1, "Run_Checks runs a check:" & Natural'Image (Checked));
        Sta.Remove_Check (Count_Check'Unrestricted_Access);
        Sta.Run_Checks;
        Check (Checked = 1, "and not one removed");

        Sta.Add_Check (Raise_Check'Unrestricted_Access);
        Raises (Run_Checks_Action'Access, Boom'Identity,
                "an exception from a check is raised from Run_Checks");
        Sta.Remove_Check (Raise_Check'Unrestricted_Access);

        Sta.Add_Idle (Count_Idle'Unrestricted_Access);
        Sta.Run_Idle;
        Check (Idled = 1, "Run_Idle runs an idle handler:" & Natural'Image (Idled));
        Sta.Remove_Idle (Count_Idle'Unrestricted_Access);

        Check (not Sta.Get_Program_Should_Quit, "nothing asked to quit");
        Sta.Set_Program_Should_Quit (True);
        Check (Sta.Get_Program_Should_Quit, "Set_Program_Should_Quit");
        Sta.Set_Program_Should_Quit (False);
        Check (not Sta.Get_Program_Should_Quit, "and back");

        Raises (Get_Awake_Action'Access, Tasking_Error'Identity,
                "Get_Awake_Handler with nothing waiting raises Tasking_Error (FLTKAda-BUGS.md 84)");

        --  FLTK's ring holds 1023 (Fl_lock.cxx:66, 85-91).
        for N in 1 .. 1023 loop
            Sta.Add_Awake_Handler (Count_Idle'Unrestricted_Access);
        end loop;
        Raises (Add_Awake_Action'Access, Tasking_Error'Identity,
                "Add_Awake_Handler with the ring full raises Tasking_Error (84)");
        Raises (Awake_Action'Access, Tasking_Error'Identity, "and so does Awake (84)");
        declare
            use type Sta.Awake_Handler;
            Same : Natural := 0;
        begin
            for N in 1 .. 1023 loop
                if Sta.Get_Awake_Handler = Count_Idle'Unrestricted_Access then
                    Same := Same + 1;
                end if;
            end loop;
            Check (Same = 1023, "Get_Awake_Handler gives back each one:" & Natural'Image (Same));
        end;
        Raises (Get_Awake_Action'Access, Tasking_Error'Identity, "and then nothing is waiting");
    end Test_Loop;


    procedure Test_Time is
        A : constant Sta.Timestamp := Sta.Now;
        B : constant Sta.Timestamp := Sta.Now (1.5);
        D : Long_Float;
        T : Long_Integer;
    begin
        D := Sta.Seconds_Between (A, B);
        Check (D >= 1.5 and D < 5.0, "Seconds_Between a moment and one 1.5s on:" & D'Image);
        D := Sta.Seconds_Between (B, A);
        Check (D <= -1.5 and D > -5.0, "the difference has a sign:" & D'Image);
        T := Sta.Ticks_Between (A, B);
        Check (T >= 90 and T < 300, "Ticks_Between, in 60ths:" & T'Image);
        D := Sta.Seconds_Since (A);
        Check (D >= 0.0 and D < 60.0, "Seconds_Since:" & D'Image);
        T := Sta.Ticks_Since (A);
        Check (T >= 0 and T < 3600, "Ticks_Since:" & T'Image);
        D := Sta.Seconds_Since (B);
        Check (D < 0.0, "Seconds_Since a moment still to come is negative:" & D'Image);
    end Test_Time;


    Custom_Calls : Natural := 0;
    Custom_Args  : Boolean := False;

    function My_Contrast
           (Fore, Back    : in Color;
            Context, Size : in Integer)
        return Color is
    begin
        Custom_Calls := Custom_Calls + 1;
        Custom_Args := Fore = Red_Color and Back = White_Color
            and Context = 7 and Size = 14;
        return Dark_Red_Color;
    end My_Contrast;

    function Raising_Contrast
           (Fore, Back    : in Color;
            Context, Size : in Integer)
        return Color is
    begin
        raise Boom;
        return Fore;
    end Raising_Contrast;

    procedure Pump is
        Ignore : Boolean;
    begin
        Ignore := FLTK.Check;
    end Pump;


    procedure Test_Contrast is
        R, G, B : Color_Component := 1;
        X       : Long_Float;
        C       : Color;
    begin
        Check (Sta.Get_Contrast_Mode = CIELAB_Contrast, "CIELAB is the default contrast");
        Check (Sta.Get_Contrast_Level = 39, "CIELAB's level starts at 39");
        Sta.Set_Contrast_Level (77);
        Check (Sta.Get_Contrast_Level = 77, "Set_Contrast_Level");
        Sta.Set_Contrast_Mode (Legacy_Contrast);
        Check (Sta.Get_Contrast_Level = 50, "Legacy keeps a level of its own, 50");
        Sta.Set_Contrast_Mode (CIELAB_Contrast);
        Check (Sta.Get_Contrast_Level = 77, "and CIELAB kept its");
        Sta.Set_Contrast_Level (39);

        Sta.Set_Contrast_Mode (No_Contrast);
        Check (Sta.Get_Contrast_Mode = No_Contrast, "Set_Contrast_Mode");
        Check (Contrast (White_Color, White_Color) = White_Color,
               "No_Contrast leaves the colour");

        Sta.Set_Contrast_Mode (Custom_Contrast);
        Sta.Set_Contrast_Function (My_Contrast'Unrestricted_Access);
        C := Contrast (Red_Color, White_Color, 7, 14);
        Check (Custom_Calls = 1 and Custom_Args and C = Dark_Red_Color,
               "a contrast function has fore, back, context and size");

        Sta.Set_Contrast_Function (Raising_Contrast'Unrestricted_Access);
        C := Contrast (Red_Color, White_Color);
        Check (C = Red_Color, "a contrast function that raises gives Fore");
        Raises (Pump'Access, Boom'Identity,
                "and the exception is raised from the next event loop call");

        Sta.Set_Contrast_Function (null);
        C := Contrast (White_Color, White_Color);
        Check (C = White_Color,
               "Custom with no function is CIELAB at Custom's level, 0 (F12):" & C'Image);
        Sta.Set_Contrast_Level (39);
        C := Contrast (White_Color, White_Color);
        Check (C = Black_Color, "and at level 39 gives black on white:" & C'Image);
        Sta.Set_Contrast_Mode (CIELAB_Contrast);
        Check (Contrast (White_Color, White_Color) = Black_Color, "CIELAB gives black on white");

        X := Lightness (White_Color);
        Check (X > 99.9 and X < 100.1, "Lightness of white:" & X'Image);
        X := Lightness (Black_Color);
        Check (X > -0.01 and X < 0.01, "Lightness of black:" & X'Image);
        X := Luminance (White_Color);
        Check (X > 0.99 and X < 1.01, "Luminance of white:" & X'Image);

        Check (Sta.Parse_Color ("#ff8000", R, G, B) and then (R = 255 and G = 128 and B = 0),
               "Parse_Color of a number");
        R := 1;
        G := 2;
        B := 3;
        Check (not Sta.Parse_Color ("#ffgg00", R, G, B) and then (R = 1 and G = 2 and B = 3),
               "Parse_Color refuses bad digits, and changes nothing");
        Check (not Sta.Parse_Color ("", R, G, B), "Parse_Color of nothing");
        Check (not Sta.Parse_Color ("#f", R, G, B), "Parse_Color of too little");
        if Prb.On_Wayland then
            Check (not Sta.Parse_Color ("red", R, G, B), "Wayland reads no names");
        else
            Check (Sta.Parse_Color ("red", R, G, B) and then (R = 255 and G = 0 and B = 0),
                   "X11 reads a name");
        end if;
    end Test_Contrast;


    procedure Test_Boxes is
        Old_Radius : constant Integer := Sta.Get_Box_Border_Radius_Max;
        Old_Shadow : constant Integer := Sta.Get_Box_Shadow_Width;
        Old_Space  : constant Integer := Sta.Get_Menu_Line_Spacing;
    begin
        Sta.Set_Box_Border_Radius_Max (20);
        Check (Sta.Get_Box_Border_Radius_Max = 20, "Set_Box_Border_Radius_Max");
        Sta.Set_Box_Border_Radius_Max (1);
        Check (Sta.Get_Box_Border_Radius_Max = 5, "a radius has a minimum, 5");
        Sta.Set_Box_Border_Radius_Max (Old_Radius);
        Sta.Set_Box_Shadow_Width (6);
        Check (Sta.Get_Box_Shadow_Width = 6, "Set_Box_Shadow_Width");
        Sta.Set_Box_Shadow_Width (0);
        Check (Sta.Get_Box_Shadow_Width = 1, "a shadow has a minimum, 1");
        Sta.Set_Box_Shadow_Width (Old_Shadow);
        Check (Old_Space = 4, "menu line spacing starts at 4:" & Old_Space'Image);
        Sta.Set_Menu_Line_Spacing (9);
        Check (Sta.Get_Menu_Line_Spacing = 9, "Set_Menu_Line_Spacing");
        Sta.Set_Menu_Line_Spacing (Old_Space);
    end Test_Boxes;


    procedure Test_Schemes is
        Ignore : Boolean;
        procedure Too_Long is
        begin
            Ignore := Sta.Add_Scheme_Name ("abcdefghijklm");
        end Too_Long;
        procedure Bad_Char is
        begin
            Ignore := Sta.Add_Scheme_Name ("Capital");
        end Bad_Char;
        procedure Past_End is
            Ignore : constant String := Sta.Scheme_Name (Sta.Scheme_Count + 1);
        begin
            null;
        end Past_End;
        N : constant Natural := Sta.Scheme_Count;
    begin
        Check (N = 5, "five schemes built in:" & N'Image);
        Check (Sta.Scheme_Name (1) = "base" and Sta.Scheme_Name (5) = "oxy",
               "Scheme_Name: " & Sta.Scheme_Name (1) & " .. " & Sta.Scheme_Name (N));
        Check (Sta.Add_Scheme_Name ("fltkada"), "Add_Scheme_Name");
        Check (Sta.Scheme_Count = N + 1 and then Sta.Scheme_Name (N + 1) = "fltkada",
               "and it is in the list");
        Check (not Sta.Add_Scheme_Name ("fltkada"), "a name already there");
        Raises (Too_Long'Access, Constraint_Error'Identity, "a name too long");
        Raises (Bad_Char'Access, Constraint_Error'Identity, "a name with a capital");
        Raises (Past_End'Access, Constraint_Error'Identity, "Scheme_Name past the end");
    end Test_Schemes;


    procedure Test_Scaling is
        S : Float;
        procedure Bad_Screen is
        begin
            S := FLTK.Screen.Get_Scale (FLTK.Screen.Count + 1);
        end Bad_Screen;
        K : constant FLTK.Screen.Scaling_Kind := FLTK.Screen.Scaling_Support;
    begin
        S := FLTK.Screen.Get_Scale;
        Check (S > 0.0, "Get_Scale:" & S'Image);
        FLTK.Screen.Set_Scale (S);
        Check (FLTK.Screen.Get_Scale = S, "Set_Scale to what it was");
        if FLTK.Screen."=" (K, FLTK.Screen.No_Scaling) then
            FLTK.Screen.Set_Scale (2.0);
            Check (FLTK.Screen.Get_Scale = S, "with no scaling, Set_Scale does nothing");
        else
            FLTK.Screen.Set_Scale (1.5);
            Check (FLTK.Screen.Get_Scale = 1.5, "Set_Scale, " & K'Image);
            FLTK.Screen.Set_Scale (S);
        end if;
        Raises (Bad_Screen'Access, Constraint_Error'Identity, "Get_Scale of a screen not there");
        FLTK.Screen.Set_Keyboard_Scaling (True);
    end Test_Scaling;


    Window : Win.Window := Win.Forge.Create (200, 100, "Statics");
    Button : Btn.Button := Btn.Forge.Create (Window, 10, 10, 80, 30, "press");
    Other  : constant Btn.Button := Btn.Forge.Create (Window, 100, 10, 80, 30, "other");

    Reason_Seen : Callback_Reason := Reason_User;

    procedure Note_Reason
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Reason_Seen := Sta.Get_Callback_Reason;
    end Note_Reason;

    Closing : Natural := 0;

    procedure Close_Told
           (Item : in out Win.Window'Class)
    is
        pragma Unreferenced (Item);
    begin
        Closing := Closing + 1;
    end Close_Told;

    procedure Close_Raises
           (Item : in out Win.Window'Class) is
    begin
        raise Boom;
    end Close_Raises;

    procedure Close_Action is
        Ignore : Boolean;
    begin
        Ignore := Prb.Close_Modal;
        Ignore := FLTK.Check;
    end Close_Action;


    function Same
           (Owner : access FLTK.Widgets.Widget'Class;
            Item  : in     FLTK.Widgets.Widget'Class)
        return Boolean
    is
        use type System.Address;
    begin
        return Owner /= null and then Owner.all'Address = Item'Address;
    end Same;


    procedure Test_Widgets is
        Ignore : Boolean;
        Second : Win.Window := Win.Forge.Create (100, 50, "second");
    begin
        Second.End_Current;
        Button.Set_Callback (Note_Reason'Unrestricted_Access);
        Show_It (Window);

        Check (Sta.Get_Callback_Reason = Reason_Unknown, "no reason yet");
        Ignore := Prb.Mouse (Window, Push, 30, 25);
        Ignore := Prb.Mouse (Window, Release, 30, 25);
        Check (Reason_Seen = Reason_Released,
               "a button's callback on release says so:" & Reason_Seen'Image);

        Check (Sta.Get_Selection_Owner = null, "no selection owner");
        Sta.Selection (Button, "text");
        Check (Same (Sta.Get_Selection_Owner, Button), "Selection sets the owner");
        Sta.Set_Selection_Owner (Other);
        Check (Same (Sta.Get_Selection_Owner, Other), "Set_Selection_Owner");
        Sta.Clear_Selection_Owner;
        Check (Sta.Get_Selection_Owner = null, "Clear_Selection_Owner");
        declare
            Gone : constant Btn.Button := Btn.Forge.Create (10, 60, 20, 20, "gone");
        begin
            Sta.Set_Selection_Owner (Gone);
        end;
        Check (Sta.Get_Selection_Owner = null, "an owner deleted lets go");
        Sta.Set_Selection_To_Clipboard (True);
        Check (Sta.Get_Selection_To_Clipboard, "Set_Selection_To_Clipboard");
        Sta.Set_Selection_To_Clipboard (False);
        Check (not Sta.Get_Selection_To_Clipboard, "and back");

        Second.Set_Modal;
        Show_It (Second);
        Sta.Set_Window_Close_Handler (Close_Told'Unrestricted_Access);
        Ignore := Prb.Close_Modal;
        Check (Closing = 1 and Second.Is_Shown,
               "the close handler is told, and the window stays");
        Sta.Set_Window_Close_Handler (Close_Raises'Unrestricted_Access);
        Raises (Close_Action'Access, Boom'Identity,
                "an exception from the close handler is raised again");
        Sta.Set_Window_Close_Handler (null);
        Ignore := Prb.Close_Modal;
        Check (Closing = 1 and not Second.Is_Shown, "FLTK's own again hides it");

        Show_It (Second);
        Sta.Hide_All_Windows;
        Check (not Window.Is_Shown and not Second.Is_Shown, "Hide_All_Windows");
    end Test_Widgets;

begin

    Window.End_Current;
    Test_Loop;
    Test_Time;
    Test_Contrast;
    Test_Boxes;
    Test_Schemes;
    Test_Scaling;
    Test_Widgets;
    Summary;

exception
    when Occurrence : others =>
        Check (False, "unexpected " & Ada.Exceptions.Exception_Information (Occurrence));
        Summary;
end Test_Statics_Core;
