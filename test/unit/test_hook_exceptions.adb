


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 45 and Phase 12's handler lists.  A Constraint_Error
--  or an Assertion_Error raised by the program's own dispatch function,
--  event handler, clipboard handler or table Draw_Cell reaches the
--  program as itself, not as Internal_FLTK_Error.  A handler may remove
--  itself while FLTK is calling the handlers (81).  And a dispatch
--  function given the window FLTK made for a pop-up menu, which has no
--  Ada object, passes the event on to it with Handle (Event, Win) (82).


with

    Ada.Assertions,
    Ada.Exceptions,
    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Buttons;

use

    Checks,
    FLTK;


procedure Test_Hook_Exceptions is

    package Evt renames FLTK.Events;
    package Prb renames FLTK.Probe;
    package Stc renames FLTK.Static;
    package Tab renames FLTK.Widgets.Groups.Tables;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Mnb renames FLTK.Widgets.Menus.Menu_Buttons;

    use type Ada.Exceptions.Exception_Id;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 200, "Test_Hook_Exceptions");
    Menu   : Mnb.Menu_Button := Mnb.Forge.Create (Window, 10, 10, 100, 30, "menu");

    type Raise_Kind is (Nothing, Constraint, Assertion);

    To_Raise : Raise_Kind := Nothing;

    procedure Raise_It is
    begin
        case To_Raise is
            when Nothing   => null;
            when Constraint => raise Constraint_Error with "mine";
            when Assertion  => raise Ada.Assertions.Assertion_Error with "mine";
        end case;
    end Raise_It;

    --  Checks that Action raises Expected with the message "mine".
    procedure Raises_Mine
           (Action   : not null access procedure;
            Expected : in Ada.Exceptions.Exception_Id;
            Label    : in String) is
    begin
        Action.all;
        Check (False, Label & ": nothing was raised");
    exception
        when E : others =>
            Check (Ada.Exceptions.Exception_Identity (E) = Expected
                    and Ada.Exceptions.Exception_Message (E) = "mine",
                Label & ": " & Ada.Exceptions.Exception_Name (E) & ": "
                & Ada.Exceptions.Exception_Message (E));
    end Raises_Mine;




    --  Dispatch  --

    Null_Windows, Dispatches : Natural := 0;
    Null_Events : array (Event_Kind) of Boolean := (others => False);

    function Events_Seen
        return String
    is
        function Next
               (From : in Event_Kind)
            return String is
        begin
            return (if Null_Events (From) then " " & Event_Kind'Image (From) else "")
                & (if From = Event_Kind'Last then "" else Next (Event_Kind'Succ (From)));
        end Next;
    begin
        return Next (Event_Kind'First);
    end Events_Seen;

    function Raising_Dispatch
           (Event : in     Event_Kind;
            Win   : access FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome is
    begin
        Raise_It;
        return Evt.Handle (Event, Win);
    end Raising_Dispatch;

    function Pass_On
           (Event : in     Event_Kind;
            Win   : access FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome is
    begin
        Dispatches := Dispatches + 1;
        if Win = null then
            Null_Windows := Null_Windows + 1;
            Null_Events (Event) := True;
        end if;
        return Evt.Handle (Event, Win);
    end Pass_On;

    --  A shortcut no widget takes, which reaches the handlers once.  A
    --  Keydown would reach them twice, the second time with the case of
    --  its text swapped (Fl.cxx:1536-1546).
    procedure Dispatch_Q is
        Ignore : Boolean;
    begin
        Ignore := Prb.Handle_Key (Window, Shortcut, Press ('q'), Text => "q");
    end Dispatch_Q;




    --  A table's cells  --

    type Raising_Table is new Tab.Table with null record;

    overriding procedure Draw_Cell
           (This        : in out Raising_Table;
            Context     : in     Tab.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0);

    overriding procedure Draw_Cell
           (This        : in out Raising_Table;
            Context     : in     Tab.Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0)
    is
        pragma Unreferenced (This, Row, Column, X, Y, W, H);
        use type Tab.Table_Context;
    begin
        if Context = Tab.Within_Cell then
            Raise_It;
        end if;
    end Draw_Cell;

    Table : Raising_Table :=
        (Tab.Forge.Create (Window, 10, 50, 180, 140) with null record);

    procedure Draw_Table is
    begin
        Table.Redraw;
        for N in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Draw_Table;




    --  Event handlers  --

    Self_Calls, Older_Calls : Natural := 0;

    function Raising_Handler
           (Event : in Event_Kind)
        return Event_Outcome
    is
        pragma Unreferenced (Event);
    begin
        Raise_It;
        return Not_Handled;
    end Raising_Handler;

    function Older_Handler
           (Event : in Event_Kind)
        return Event_Outcome
    is
        pragma Unreferenced (Event);
    begin
        Older_Calls := Older_Calls + 1;
        return Not_Handled;
    end Older_Handler;

    function Self_Removing_Handler
           (Event : in Event_Kind)
        return Event_Outcome
    is
        pragma Unreferenced (Event);
    begin
        Self_Calls := Self_Calls + 1;
        Evt.Remove_Handler (Self_Removing_Handler'Unrestricted_Access);
        return Not_Handled;
    end Self_Removing_Handler;




    --  Clipboard handlers  --

    Clip_Self_Calls, Clip_Older_Calls : Natural := 0;

    procedure Raising_Clip
           (Kind : in Stc.Buffer_Kind)
    is
        pragma Unreferenced (Kind);
    begin
        Raise_It;
    end Raising_Clip;

    procedure Older_Clip
           (Kind : in Stc.Buffer_Kind)
    is
        pragma Unreferenced (Kind);
    begin
        Clip_Older_Calls := Clip_Older_Calls + 1;
    end Older_Clip;

    procedure Self_Removing_Clip
           (Kind : in Stc.Buffer_Kind)
    is
        pragma Unreferenced (Kind);
    begin
        Clip_Self_Calls := Clip_Self_Calls + 1;
        Stc.Remove_Clipboard_Notify (Self_Removing_Clip'Unrestricted_Access);
    end Self_Removing_Clip;

    procedure Notice is
    begin
        Prb.Clipboard_Notice (1);
    end Notice;




    --  The pop-up menu  --

    Grab_Taken, Still_Up : Boolean := False;
    Tries : Natural := 0;

    --  If Escape_The_Menu didn't close it.
    procedure Close_Menu is
        Ignore : Boolean;
    begin
        if Prb.Grabbed then
            Still_Up := True;
            Evt.Set_Dispatch (null);
            Ignore := Prb.Handle_Key (Window, Keydown, Escape_Key);
        end if;
    end Close_Menu;

    --  Once the menu is shown, which under valgrind takes a while.
    procedure Escape_The_Menu is
    begin
        Tries := Tries + 1;
        if not Null_Events (Show) and Tries < 100 then
            Stc.Repeat_Timeout (0.1, Escape_The_Menu'Unrestricted_Access);
        else
            Grab_Taken := Prb.Grab_Key (Escape_Key);
            Stc.Add_Timeout (1.0, Close_Menu'Unrestricted_Access);
        end if;
    end Escape_The_Menu;

    procedure Pop_Up is
        Ignore : FLTK.Widgets.Menus.Extended_Index;
    begin
        Stc.Add_Timeout (0.1, Escape_The_Menu'Unrestricted_Access);
        Ignore := Menu.Popup (100, 100);
    end Pop_Up;

    procedure Pump is
    begin
        for N in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;


begin

    Menu.Add (Text => "one", Action => null);
    Menu.Add (Text => "two", Action => null);
    Table.Set_Rows (2);
    Table.Set_Columns (2);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;


    --  The program's own exceptions (45).
    Evt.Set_Dispatch (Raising_Dispatch'Unrestricted_Access);
    To_Raise := Constraint;
    Raises_Mine (Dispatch_Q'Access, Constraint_Error'Identity,
        "a dispatch function's Constraint_Error is its own (45)");
    To_Raise := Assertion;
    Raises_Mine (Dispatch_Q'Access, Ada.Assertions.Assertion_Error'Identity,
        "and so is its Assertion_Error");
    Evt.Set_Dispatch (null);

    Evt.Add_Handler (Raising_Handler'Unrestricted_Access);
    To_Raise := Constraint;
    Raises_Mine (Dispatch_Q'Access, Constraint_Error'Identity,
        "an event handler's Constraint_Error is its own (45)");
    Evt.Remove_Handler (Raising_Handler'Unrestricted_Access);

    Stc.Add_Clipboard_Notify (Raising_Clip'Unrestricted_Access);
    To_Raise := Assertion;
    Raises_Mine (Notice'Access, Ada.Assertions.Assertion_Error'Identity,
        "a clipboard handler's Assertion_Error is its own (45)");
    Stc.Remove_Clipboard_Notify (Raising_Clip'Unrestricted_Access);

    To_Raise := Constraint;
    Raises_Mine (Draw_Table'Access, Constraint_Error'Identity,
        "a table's Draw_Cell's Constraint_Error is its own (45)");
    To_Raise := Nothing;
    Draw_Table;


    --  Handlers that remove themselves.
    Evt.Add_Handler (Older_Handler'Unrestricted_Access);
    Evt.Add_Handler (Self_Removing_Handler'Unrestricted_Access);
    No_Raise (Dispatch_Q'Access, "an event handler can remove itself while handlers are called");
    Check (Self_Calls = 1 and Older_Calls = 1,
        "and the handler added before it is still called:" & Natural'Image (Self_Calls) &
        Natural'Image (Older_Calls));
    Dispatch_Q;
    Check (Self_Calls = 1 and Older_Calls = 2,
        "the next event doesn't reach the removed handler:" & Natural'Image (Self_Calls) &
        Natural'Image (Older_Calls));
    Evt.Remove_Handler (Older_Handler'Unrestricted_Access);

    Stc.Add_Clipboard_Notify (Self_Removing_Clip'Unrestricted_Access);
    Stc.Add_Clipboard_Notify (Older_Clip'Unrestricted_Access);
    No_Raise (Notice'Access, "a clipboard handler can remove itself while handlers are called");
    Check (Clip_Self_Calls = 1 and Clip_Older_Calls = 1,
        "and the one added after it is still called:" & Natural'Image (Clip_Self_Calls) &
        Natural'Image (Clip_Older_Calls));
    Notice;
    Check (Clip_Self_Calls = 1 and Clip_Older_Calls = 2,
        "the next notice doesn't reach the removed handler:" & Natural'Image (Clip_Self_Calls) &
        Natural'Image (Clip_Older_Calls));
    Stc.Remove_Clipboard_Notify (Older_Clip'Unrestricted_Access);


    --  A window FLTK made.  Pop-up menus close at once on a headless sway
    --  (AGENTS.md), so this needs X11.
    if Prb.On_Wayland then
        Skip ("a dispatch given a pop-up menu's window: needs X11");
    else
        Evt.Set_Dispatch (Pass_On'Unrestricted_Access);
        No_Raise (Pop_Up'Access, "a dispatch function can be given a pop-up menu's window");
        Check (Null_Windows > 0 and Null_Events (Show),
            "which it is given as null, Show among them:" & Natural'Image (Null_Windows) &
            " of" & Natural'Image (Dispatches) & ":" & Events_Seen);
        Check (Grab_Taken and not Still_Up,
            "and Handle (Event, null) there passes them on to it, so Escape closes it: " &
            Boolean'Image (Grab_Taken) & " " & Boolean'Image (Still_Up));
        Evt.Set_Dispatch (null);
        Pump;
    end if;

    Window.Hide;
    Summary;

end Test_Hook_Exceptions;
