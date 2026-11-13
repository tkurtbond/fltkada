

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  N12 (PLAN.md): an Ada exception raised in a hook FLTK calls.  Each case
--  raises Boom in one kind of hook, checks that Boom reaches the Ada code
--  around the FLTK call that ran the hook, and then checks that FLTK still
--  works.  This is the behaviour PLAN.md's N12 decision asks for: each hook
--  catches the exception, FLTK finishes what it was doing, and the binding
--  raises it again once FLTK returns to Ada (FLTK.Hook_Exceptions).
--
--  Before that was done, several checks failed and the menu case crashed:
--  the popup's grab was left dangling, and the next event crashed.  The
--  menu case still runs last.


with

    Ada.Exceptions,
    Checks,
    FLTK.Asks,
    FLTK.Draw,
    FLTK.Events,
    FLTK.GLUT,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Buttons;

use

    Checks,
    FLTK;


procedure Test_Exceptions is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Mnb renames FLTK.Widgets.Menus.Menu_Buttons;

    Boom : exception;

    Boom_Id : constant Ada.Exceptions.Exception_Id := Boom'Identity;

    type Mode_Kind is (Quiet, Raise_Draw, Image_Line);

    Draws, Lines, Presses, Idles, Timeouts, Displays : Natural := 0;




    --  A box whose Draw and Handle can raise  --

    type Raise_Box is new Bx.Box with record
        Mode         : Mode_Kind := Quiet;
        Raise_Handle : Boolean   := False;
    end record;

    overriding procedure Draw
           (This : in out Raise_Box);

    overriding function Handle
           (This  : in out Raise_Box;
            Event : in     Event_Kind)
        return Event_Outcome;


    procedure Line
           (X, Y : in     Natural;
            Data :    out Color_Component_Array) is
    begin
        Lines := Lines + 1;
        if Y = 3 then
            raise Boom with "image line";
        end if;
        Data := (others => 0);
    end Line;


    overriding procedure Draw
           (This : in out Raise_Box) is
    begin
        Draws := Draws + 1;
        case This.Mode is
            when Raise_Draw =>
                raise Boom with "draw";
            when Image_Line =>
                FLTK.Draw.Draw_Image
                   (This.Get_X, This.Get_Y, 20, 20, Line'Unrestricted_Access);
            when Quiet =>
                Bx.Box (This).Draw;
        end case;
    end Draw;


    overriding function Handle
           (This  : in out Raise_Box;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        if Event = Push and This.Raise_Handle then
            raise Boom with "handle";
        end if;
        return Bx.Box (This).Handle (Event);
    end Handle;




    --  Hooks  --

    Raise_In_Callback : Boolean := False;
    Raise_In_Idle     : Boolean := False;
    Raise_In_Display  : Boolean := False;

    procedure Press
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Presses := Presses + 1;
        if Raise_In_Callback then
            raise Boom with "callback";
        end if;
    end Press;

    procedure Ignore_Close
           (Ignore : in out Wdg.Widget'Class) is
    begin
        null;
    end Ignore_Close;

    procedure Idle is
    begin
        Idles := Idles + 1;
        if Raise_In_Idle then
            Raise_In_Idle := False;
            raise Boom with "idle";
        end if;
    end Idle;

    procedure Timeout_Raises is
    begin
        Timeouts := Timeouts + 1;
        raise Boom with "timeout";
    end Timeout_Raises;

    procedure Timeout_Counts is
    begin
        Timeouts := Timeouts + 1;
    end Timeout_Counts;

    procedure Display is
    begin
        Displays := Displays + 1;
        if Raise_In_Display then
            Raise_In_Display := False;
            raise Boom with "glut display";
        end if;
    end Display;




    --  The window  --

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Exceptions");

    The_Box : Raise_Box :=
       (Bx.Forge.Create (Window, Flat_Box, 10, 10, 60, 40) with others => <>);

    Button : Btn.Button := Btn.Forge.Create (Window, 100, 10, 80, 30, "Press");

    Menu : Mnb.Menu_Button := Mnb.Forge.Create (Window, 100, 60, 80, 30, "Menu");

    Red : constant Prb.RGB := Prb.To_RGB (255, 0, 0);


    procedure Pump
           (Times : in Positive := 10) is
    begin
        for I in 1 .. Times loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    procedure Pump_10 is
    begin
        Pump (10);
    end Pump_10;

    procedure Click
           (X, Y : in Integer)
    is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Push, X, Y);
        Ignore := Prb.Mouse (Window, Release, X, Y);
    end Click;

    procedure Click_Button is
    begin
        Click (140, 25);
    end Click_Button;

    procedure Push_Box is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Push, 30, 30);
    end Push_Box;

    procedure Do_Button_Callback is
    begin
        Button.Do_Callback;
    end Do_Button_Callback;

    --  FLTK still works: nothing pushed or grabbed, no dialog up, the button
    --  runs its callback, and a redraw paints the box red.
    procedure Check_Still_Works
           (After : in String)
    is
        use type Wdg.Widget'Class;
        Before : constant Natural := Presses;
    begin
        Check (not Prb.Grabbed, After & ": no grab is left");
        Check (FLTK.Events.Get_Pushed = null, After & ": no widget is left pushed");
        Check (not Prb.Modal, After & ": no dialog is left up");
        Click_Button;
        Check (Presses = Before + 1, After & ": a later button press runs its callback");
        The_Box.Mode := Quiet;
        Window.Redraw;
        Pump (5);
        Check (Prb.Shown_Pixel (Window, 40, 30) = Red and Prb.Shown_Pixel (Window, 10, 10) = Red,
            After & ": a redraw paints the box red:"
            & Prb.RGB'Image (Prb.Shown_Pixel (Window, 10, 10))
            & Prb.RGB'Image (Prb.Shown_Pixel (Window, 40, 30)));
    end Check_Still_Works;


    --  Modal and menu cases: Timeout_Raises runs inside FLTK's own loop, and
    --  this one ends the dialog or menu if catching left it up.

    procedure Close_Dialog is
        Ignore : Boolean;
    begin
        Ignore := Prb.Modal_Key (Escape_Key);
    end Close_Dialog;

    --  Prb.Grabbed, not FLTK.Events.Get_Grab: the grab is the menu's own
    --  window, which FLTK made, and Get_Grab gives null for it
    --  (FLTKAda-BUGS.md 44; FLTK.Events.Has_Grab would do too).
    procedure Close_Menu is
        Ignore : Boolean;
    begin
        if Prb.Grabbed then
            Ignore := Prb.Handle_Key (Window, Keydown, Escape_Key);
        end if;
    end Close_Menu;

    procedure Ask is
        Ignore : FLTK.Asks.Choice_Result;
    begin
        FLTK.Static.Add_Timeout (0.2, Timeout_Raises'Unrestricted_Access);
        FLTK.Static.Add_Timeout (0.4, Close_Dialog'Unrestricted_Access);
        Ignore := FLTK.Asks.Choice ("Test_Exceptions", "OK");
    end Ask;

    procedure Pop_Up is
        Ignore : Wdg.Menus.Extended_Index;
    begin
        FLTK.Static.Add_Timeout (0.2, Timeout_Raises'Unrestricted_Access);
        FLTK.Static.Add_Timeout (0.4, Close_Menu'Unrestricted_Access);
        Ignore := Menu.Popup (100, 100);
    end Pop_Up;


begin

    The_Box.Set_Background_Color (RGB_Red_Color);
    Button.Set_Callback (Press'Unrestricted_Access);
    Window.Set_Callback (Ignore_Close'Unrestricted_Access);
    Menu.Add (Text => "one", Action => null);
    Menu.Add (Text => "two", Action => null);

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;


    --  A widget callback, from Do_Callback and from a button release.
    Raise_In_Callback := True;
    Raises (Do_Button_Callback'Access, Boom_Id, "a callback's exception reaches Do_Callback");
    Raises (Click_Button'Access, Boom_Id, "a callback's exception reaches the release");
    Raise_In_Callback := False;
    Check_Still_Works ("after a callback raised");


    --  An overridden Handle.
    The_Box.Raise_Handle := True;
    Raises (Push_Box'Access, Boom_Id, "Handle's exception reaches the push");
    The_Box.Raise_Handle := False;
    declare
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Release, 30, 30);
    end;
    Check_Still_Works ("after Handle raised");


    --  A timeout.
    FLTK.Static.Add_Timeout (0.01, Timeout_Raises'Unrestricted_Access);
    Raises (Pump_10'Access, Boom_Id, "a timeout's exception reaches Wait");
    Check (not FLTK.Static.Has_Timeout (Timeout_Raises'Unrestricted_Access),
        "a timeout that raised is not run again");
    Timeouts := 0;
    FLTK.Static.Add_Timeout (0.01, Timeout_Counts'Unrestricted_Access);
    Pump;
    Check (Timeouts = 1, "a later timeout runs:" & Timeouts'Image);
    Check_Still_Works ("after a timeout raised");


    --  An idle.  FLTK's Fl::run_idle sets a static in_idle flag around the
    --  call, so an exception that unwinds through it stops every idle.
    Raise_In_Idle := True;
    FLTK.Static.Add_Idle (Idle'Unrestricted_Access);
    Raises (Pump_10'Access, Boom_Id, "an idle's exception reaches Wait");
    Idles := 0;
    Pump;
    Check (Idles > 0, "an idle runs again after one raised:" & Idles'Image);
    FLTK.Static.Remove_Idle (Idle'Unrestricted_Access);
    Check_Still_Works ("after an idle raised");


    --  A timeout inside a modal dialog's loop.
    Raises (Ask'Access, Boom_Id, "a timeout's exception inside a dialog reaches Choice");
    Pump (25);
    Check_Still_Works ("after a timeout raised in a dialog");


    --  An overridden Draw.
    The_Box.Mode := Raise_Draw;
    The_Box.Redraw;
    Raises (Pump_10'Access, Boom_Id, "Draw's exception reaches Wait");
    Check_Still_Works ("after Draw raised");


    --  An image-line hook, called by Draw_Image within Draw.
    Lines := 0;
    The_Box.Mode := Image_Line;
    The_Box.Redraw;
    Raises (Pump_10'Access, Boom_Id, "an image-line hook's exception reaches Wait");
    Check (Lines = 4, "the image lines before the raise were asked for:" & Lines'Image);
    Check_Still_Works ("after an image-line hook raised");


    --  An overridden Draw, in a new window's first frame.
    declare
        Second : Win.Window := Win.Forge.Create (0, 0, 100, 80, "Test_Exceptions 2");
        Its_Box : Raise_Box :=
           (Bx.Forge.Create (Second, Flat_Box, 0, 0, 100, 80) with Mode => Raise_Draw,
                                                                  Raise_Handle => False);
        procedure Show_Second is
        begin
            Second.Show;
            Pump (25);
        end Show_Second;
    begin
        Its_Box.Set_Background_Color (RGB_Red_Color);
        Raises (Show_Second'Access, Boom_Id, "Draw's exception in a first frame reaches Wait");
        Its_Box.Mode := Quiet;
        Second.Redraw;
        Pump (5);
        Check (Prb.Shown_Pixel (Second, 50, 40) = Red,
            "a window whose first frame raised is redrawn:"
            & Prb.RGB'Image (Prb.Shown_Pixel (Second, 50, 40)));
        Second.Hide;
        Pump (5);
    end;
    Check_Still_Works ("after a first frame raised");


    --  A GLUT display callback.  FLTK's Fl_Glut_Window::draw sets a static
    --  indraw flag around it, and glutSwapBuffers does nothing while it is
    --  set.
    FLTK.GLUT.Init;
    FLTK.GLUT.Init_Window_Size (100, 100);
    --  The GLUT window goes before Check_Still_Works: on Xvfb, it covers the
    --  test's window, and fl_read_image reads what is on the screen.
    declare
        GLUT_Window : constant FLTK.GLUT.Valid_Window_Number :=
            FLTK.GLUT.Create_Window ("Test_Exceptions GLUT");
    begin
        FLTK.GLUT.Display_Func (Display'Unrestricted_Access);
        Raise_In_Display := True;
        Raises (Pump_10'Access, Boom_Id, "a GLUT display callback's exception reaches Wait");
        Displays := 0;
        FLTK.GLUT.Post_Redisplay;
        Pump;
        Check (Displays > 0, "the GLUT window is displayed again:" & Displays'Image);
        FLTK.GLUT.Destroy_Window (GLUT_Window);
        Pump (5);
    end;
    Check_Still_Works ("after a GLUT display callback raised");


    --  A timeout inside a pop-up menu's loop.  Pop-up menus close at once
    --  on a headless sway (AGENTS.md), so this needs X11.
    if Prb.On_Wayland then
        Skip ("a timeout's exception inside a pop-up menu: needs X11");
    else
        Raises (Pop_Up'Access, Boom_Id, "a timeout's exception inside a menu reaches Popup");
        Pump (25);
        Check_Still_Works ("after a timeout raised in a menu");
    end if;

    Window.Hide;
    Summary;

end Test_Exceptions;
