--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  N12 experiment: raise an Ada exception in each kind of hook FLTK calls,
--  catch it around Wait, and see whether FLTK still works (PLAN.md,
--  Phase 0, the N12 experiment).  Usage: n12 CASE [N], where CASE is one
--  of callback, draw, clip, clip12, redraw, image, handle, timeout, idle,
--  glut, menu or modal.  clip12 raises inside Push_Clip N times (default
--  70); redraw is the no-exception control, redrawing N times.  The menu
--  case crashes: FLTK-issues.md F3.

with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO;
with FLTK.Asks;
with FLTK.Draw;
with FLTK.Events;
with FLTK.GLUT;
with FLTK.Probe;
with FLTK.Static;
with FLTK.Widgets.Boxes;
with FLTK.Widgets.Buttons;
with FLTK.Widgets.Groups.Windows;
with FLTK.Widgets.Menus.Menu_Buttons;

use FLTK;

procedure N12 is

    package IO  renames Ada.Text_IO;
    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;

    Boom : exception;

    Which : constant String := Ada.Command_Line.Argument (1);
    Limit : constant Natural :=
        (if Ada.Command_Line.Argument_Count > 1
         then Natural'Value (Ada.Command_Line.Argument (2))
         else 70);

    procedure Say (S : String) is
    begin
        IO.Put_Line (Which & ": " & S);
    end Say;

    type Mode_Kind is (Quiet, Raise_Draw, Clip_Then_Raise, Raise_Handle, Image_Line);

    Draws, Handles, Lines, Presses, Idles, Timeouts : Natural := 0;

    type Raise_Box is new Bx.Box with record
        Mode : Mode_Kind := Quiet;
    end record;

    overriding procedure Draw (This : in out Raise_Box);
    overriding function Handle
           (This  : in out Raise_Box;
            Event : in     Event_Kind)
        return Event_Outcome;

    procedure Line
           (X, Y : in     Natural;
            Data :    out FLTK.Color_Component_Array) is
    begin
        Lines := Lines + 1;
        if Y = 3 then
            raise Boom with "image line";
        end if;
        Data := (others => 0);
    end Line;

    overriding procedure Draw (This : in out Raise_Box) is
    begin
        Draws := Draws + 1;
        case This.Mode is
            when Raise_Draw =>
                raise Boom with "draw";
            when Clip_Then_Raise =>
                FLTK.Draw.Push_Clip (This.Get_X, This.Get_Y, 1, 1);
                raise Boom with "draw inside push_clip";
            when Image_Line =>
                FLTK.Draw.Draw_Image (This.Get_X, This.Get_Y, 20, 20, Line'Unrestricted_Access);
            when others =>
                Bx.Box (This).Draw;
        end case;
    end Draw;

    overriding function Handle
           (This  : in out Raise_Box;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        if Event = Push then
            Handles := Handles + 1;
            if This.Mode = Raise_Handle then
                raise Boom with "handle";
            end if;
        end if;
        return Bx.Box (This).Handle (Event);
    end Handle;

    procedure Count_Press (Ignore : in out Wdg.Widget'Class) is
    begin
        Presses := Presses + 1;
    end Count_Press;

    Raise_In_Callback : Boolean := False;

    procedure Press_Raises (Ignore : in out Wdg.Widget'Class) is
    begin
        Presses := Presses + 1;
        if Raise_In_Callback then
            raise Boom with "callback";
        end if;
    end Press_Raises;

    Raise_In_Idle : Boolean := True;

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

    procedure Display_Raises is
    begin
        Draws := Draws + 1;
        raise Boom with "glut display";
    end Display_Raises;

    Caught : Natural := 0;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "N12");

    The_Box : Raise_Box :=
       (Bx.Forge.Create (Window, Flat_Box, 10, 10, 60, 40) with Mode => Quiet);

    Button : Btn.Button := Btn.Forge.Create (Window, 100, 10, 80, 30, "Press");

    Menu : Wdg.Menus.Menu_Buttons.Menu_Button :=
        Wdg.Menus.Menu_Buttons.Forge.Create (Window, 100, 60, 80, 30, "Menu");

    Red : constant Prb.RGB := Prb.To_RGB (255, 0, 0);

    procedure Show_Window is
    begin
        Window.Show;
        while not Window.Is_Shown loop
            exit when FLTK.Wait < 0;
        end loop;
        FLTK.Check;
    end Show_Window;

    procedure Report_State is
        use type Wdg.Widget'Class;
    begin
        Say ("caught" & Caught'Image & "; pushed set: "
             & Boolean'Image (FLTK.Events.Get_Pushed /= null)
             & "; grab set: " & Boolean'Image (FLTK.Events.Get_Grab /= null)
             & "; modal shown: " & Boolean'Image (Prb.Modal));
    end Report_State;

    --  A press and release on the plain button still runs its callback.
    procedure Check_Button is
        Before : constant Natural := Presses;
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Push, 140, 25);
        Ignore := Prb.Mouse (Window, Release, 140, 25);
        Say ("later button press runs callback: " & Boolean'Image (Presses = Before + 1));
    end Check_Button;

    --  A redraw of the box paints it red again.
    procedure Check_Redraw is
    begin
        The_Box.Mode := Quiet;
        Window.Redraw;
        for I in 1 .. 5 loop
            FLTK.Check;
        end loop;
        Say ("box pixel after redraw is red: "
             & Boolean'Image (Prb.Shown_Pixel (Window, 40, 30) = Red)
             & "; corner red: "
             & Boolean'Image (Prb.Shown_Pixel (Window, 65, 45) = Red)
             & "; centre" & Prb.RGB'Image (Prb.Shown_Pixel (Window, 40, 30))
             & "; 10,10" & Prb.RGB'Image (Prb.Shown_Pixel (Window, 10, 10)));
    end Check_Redraw;

begin

    The_Box.Set_Background_Color (RGB_Red_Color);
    Button.Set_Callback (Count_Press'Unrestricted_Access);
    Menu.Add (Text => "one", Action => null);
    Menu.Add (Text => "two", Action => null);

    if Which = "callback" then
        Show_Window;
        Button.Set_Callback (Press_Raises'Unrestricted_Access);
        Raise_In_Callback := True;
        begin
            Button.Do_Callback;
        exception
            when Boom => Caught := Caught + 1;
        end;
        declare
            Ignore : Boolean;
        begin
            Ignore := Prb.Mouse (Window, Push, 140, 25);
            Ignore := Prb.Mouse (Window, Release, 140, 25);
        exception
            when Boom => Caught := Caught + 1;
        end;
        Raise_In_Callback := False;
        Report_State;
        Check_Button;
        Check_Redraw;

    elsif Which = "draw" or Which = "clip" or Which = "image"
        or Which = "clip12" or Which = "redraw"
    then
        The_Box.Mode := (if Which = "draw" then Raise_Draw
                         elsif Which = "redraw" then Quiet
                         elsif Which = "clip" or Which = "clip12" then Clip_Then_Raise
                         else Image_Line);
        Window.Show;
        for I in 1 .. (if Which = "clip12" or Which = "redraw" then 100 else 20) loop
            begin
                if (Which = "clip12" and Caught < Limit)
                    or (Which = "redraw" and I < Limit)
                then
                    The_Box.Redraw;
                end if;
                exit when FLTK.Wait (0.05) < 0.0;
            exception
                when E : Boom =>
                    Caught := Caught + 1;
                    if Caught = 1 then
                        Say ("caught: " & Ada.Exceptions.Exception_Message (E));
                    end if;
            end;
        end loop;
        Say ("draws" & Draws'Image & ", image lines" & Lines'Image
             & " in 20 waits with no further redraw");
        Report_State;
        Check_Redraw;
        Check_Button;

    elsif Which = "handle" then
        Show_Window;
        The_Box.Mode := Raise_Handle;
        declare
            Ignore : Boolean;
        begin
            Ignore := Prb.Mouse (Window, Push, 30, 30);
        exception
            when Boom => Caught := Caught + 1;
        end;
        Report_State;
        declare
            Ignore : Boolean;
        begin
            Ignore := Prb.Mouse (Window, Release, 30, 30);
        exception
            when Boom => Caught := Caught + 1;
        end;
        The_Box.Mode := Quiet;
        Report_State;
        Check_Button;
        Check_Redraw;

    elsif Which = "timeout" then
        Show_Window;
        FLTK.Static.Add_Timeout (0.01, Timeout_Raises'Unrestricted_Access);
        for I in 1 .. 10 loop
            begin
                exit when FLTK.Wait (0.05) < 0.0;
            exception
                when Boom => Caught := Caught + 1;
            end;
        end loop;
        Say ("raising timeout ran" & Timeouts'Image & " times; still registered: "
             & Boolean'Image (FLTK.Static.Has_Timeout (Timeout_Raises'Unrestricted_Access)));
        Timeouts := 0;
        FLTK.Static.Add_Timeout (0.01, Timeout_Counts'Unrestricted_Access);
        for I in 1 .. 10 loop
            exit when FLTK.Wait (0.05) < 0.0;
        end loop;
        Say ("a later timeout ran" & Timeouts'Image & " times");
        Report_State;
        Check_Button;

    elsif Which = "idle" then
        Show_Window;
        FLTK.Static.Add_Idle (Idle'Unrestricted_Access);
        for I in 1 .. 10 loop
            begin
                exit when FLTK.Wait (0.01) < 0.0;
            exception
                when Boom => Caught := Caught + 1;
            end;
        end loop;
        Say ("idle ran" & Idles'Image & " times in 10 waits; registered: "
             & Boolean'Image (FLTK.Static.Has_Idle (Idle'Unrestricted_Access)));
        Report_State;
        Check_Button;

    elsif Which = "glut" then
        FLTK.GLUT.Init;
        FLTK.GLUT.Init_Window_Size (100, 100);
        declare
            Ignore : constant FLTK.GLUT.Valid_Window_Number :=
                FLTK.GLUT.Create_Window ("N12 GLUT");
        begin
            FLTK.GLUT.Display_Func (Display_Raises'Unrestricted_Access);
        end;
        for I in 1 .. 20 loop
            begin
                exit when FLTK.Wait (0.05) < 0.0;
            exception
                when E : Boom =>
                    Caught := Caught + 1;
                    if Caught = 1 then
                        Say ("caught: " & Ada.Exceptions.Exception_Message (E));
                    end if;
            end;
        end loop;
        Say ("display ran" & Draws'Image & " times in 20 waits");
        Report_State;

    elsif Which = "menu" then
        Show_Window;
        FLTK.Static.Add_Timeout (0.3, Timeout_Raises'Unrestricted_Access);
        declare
            Picked : Wdg.Menus.Extended_Index;
        begin
            Picked := Menu.Popup (100, 100);
            Say ("popup returned" & Picked'Image);
        exception
            when Boom => Caught := Caught + 1;
        end;
        Report_State;
        Check_Button;
        Check_Redraw;

    elsif Which = "modal" then
        Show_Window;
        FLTK.Static.Add_Timeout (0.3, Timeout_Raises'Unrestricted_Access);
        declare
            Result : FLTK.Asks.Choice_Result;
        begin
            Result := FLTK.Asks.Choice ("N12 modal", "OK");
            Say ("choice returned " & Result'Image);
        exception
            when Boom => Caught := Caught + 1;
        end;
        Report_State;
        Check_Button;
        Check_Redraw;

    else
        Say ("unknown case");
    end if;

end N12;
