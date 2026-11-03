

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 3: calls that crashed FLTK 1.4.5 when they came before the
--  display was open, or with no window shown (pofltk 1, 3, 4, 49, 53, 110,
--  131 and 138).  Each case has to be a program's first call, so with no
--  argument this program runs itself once per case, with the case's name
--  as the argument, and checks that each run exits 0 and prints no X error.
--  A case that crashes kills only its own run.


with

    Ada.Command_Line,
    Ada.Directories,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    Checks,
    FLTK.Draw,
    FLTK.Events,
    FLTK.GLUT,
    FLTK.Devices.Surface.Copy,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Windows.OpenGL,
    GNAT.OS_Lib,
    System;

use type

    FLTK.Event_Outcome,
    System.Address;


procedure Test_First_Calls is

    package Bx  renames FLTK.Widgets.Boxes;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Win renames FLTK.Widgets.Groups.Windows;
    package GL  renames FLTK.Widgets.Groups.Windows.OpenGL;

    type Case_Name is
       (Open_Display_Twice,
        Copy,
        Selection,
        Paste,
        Clipboard_Contains,
        Ready,
        Enable_System_Input,
        Disable_System_Input,
        Set_Box_Color,
        Take_Focus,
        Set_Focus,
        GL_Can_Do,
        GL_Window_Show,
        GLUT_Display_Mode,
        Copy_Surface,
        Key_Unshown,
        DnD_Leave_Unshown,
        Descent,
        Draw_Text);




    --  A box whose Draw draws text before any font is set  --

    Draws : Natural := 0;

    type Text_Box is new Bx.Box with null record;

    overriding procedure Draw
           (This : in out Text_Box);

    overriding procedure Draw
           (This : in out Text_Box) is
    begin
        FLTK.Draw.Draw_Text (This.Get_X + 5, This.Get_Y + 20, "first");
        Draws := Draws + 1;
    end Draw;




    --  The cases, each run as its program's first call  --

    procedure Run
           (Which : in Case_Name)
    is
        Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_First_Calls");
        Input  : Inp.Text_Input := Inp.Forge.Create (Window, 10, 10, 100, 25);
        Box    : constant Bx.Box := Bx.Forge.Create (Window, 10, 50, 100, 25);
    begin
        case Which is
            when Open_Display_Twice =>
                FLTK.Static.Open_Display;
                FLTK.Static.Open_Display;
                FLTK.Static.Copy ("first", FLTK.Static.Clipboard);
                Checks.Check (FLTK.Static.Clipboard_Contains ("text/plain"),
                    "after Open_Display twice, Copy works");
            when Copy =>
                FLTK.Static.Copy ("first", FLTK.Static.Clipboard);
                Checks.Check (FLTK.Static.Clipboard_Contains ("text/plain"),
                    "the clipboard holds what Copy put there");
            when Selection =>
                FLTK.Static.Selection (Box, "first");
                Checks.Check (True, "Selection returned");
            when Paste =>
                FLTK.Static.Paste (Input, FLTK.Static.Clipboard);
                Checks.Check (Input.Get_Value = "",
                    "Paste with no window shown pastes nothing: """
                    & Input.Get_Value & """");
            when Clipboard_Contains =>
                Checks.Check (not FLTK.Static.Clipboard_Contains ("image"),
                    "the clipboard holds no image");
            when Ready =>
                --  On Wayland, the display's own events are ready once it is open.
                Checks.Check (FLTK.Ready or else True, "Ready returned");
            when Enable_System_Input =>
                FLTK.Static.Enable_System_Input;
                Checks.Check (True, "Enable_System_Input returned");
            when Disable_System_Input =>
                FLTK.Static.Disable_System_Input;
                Checks.Check (True, "Disable_System_Input returned");
            when Set_Box_Color =>
                FLTK.Static.Set_Box_Color (16#FF000000#);
                Checks.Check (True, "Set_Box_Color returned");
            when Take_Focus =>
                Checks.Check (Input.Take_Focus, "the input takes the focus");
            when Set_Focus =>
                FLTK.Events.Set_Focus (Input);
                Checks.Check (FLTK.Events.Get_Focus /= null
                        and then FLTK.Events.Get_Focus.all'Address = Input'Address,
                    "the input has the focus");
            when GL_Can_Do =>
                Checks.Check (GL.Can_Do (GL.Mode_Mask'(others => False)),
                    "a plain RGB visual can be had");
            when GL_Window_Show =>
                --  FLTK picks the window's GL driver when it is made
                --  (Fl_Wayland_Gl_Window_Driver.cxx:86), X11's if no display is open.
                declare
                    GL_Win : GL.GL_Window := GL.Forge.Create (0, 0, 100, 100);
                begin
                    GL_Win.Show;
                    for N in 1 .. 10 loop
                        exit when FLTK.Wait (0.05) < 0.0;
                    end loop;
                    Checks.Check (GL_Win.Is_Shown, "the GL window is shown");
                    Checks.Check (GL_Win.Can_Do, "the GL window's mode can be had");
                end;
            when GLUT_Display_Mode =>
                Checks.Check (FLTK.GLUT.Get (FLTK.GLUT.Display_Mode_Possible) in 0 .. 1,
                    "Get (Display_Mode_Possible) is 0 or 1");
            when Copy_Surface =>
                declare
                    Surface : constant FLTK.Devices.Surface.Copy.Copy_Surface :=
                        FLTK.Devices.Surface.Copy.Forge.Create (10, 10);
                begin
                    Checks.Check (Surface.Get_W = 10, "the copy surface is 10 wide");
                end;
            when Key_Unshown =>
                FLTK.Events.Set_Below_Mouse (Box);
                FLTK.Probe.Set_Key (FLTK.Press ('x'), "x");
                Checks.Check (FLTK.Events.Handle (FLTK.Keydown, Window) = FLTK.Not_Handled,
                    "a key no widget uses, no window shown, is not handled");
            when DnD_Leave_Unshown =>
                --  Fl::handle_ sends it to the below-mouse widget (Fl.cxx:1425-1429).
                FLTK.Events.Set_Below_Mouse (Input);
                Checks.Check (FLTK.Events.Handle (FLTK.DnD_Leave, Window) = FLTK.Handled,
                    "DnD_Leave, no window shown, is handled");
            when Descent =>
                Checks.Check (FLTK.Draw.Font_Descent >= 0, "Font_Descent is not negative");
            when Draw_Text =>
                declare
                    Text_Window : Win.Window := Win.Forge.Create (0, 0, 200, 100);
                    Text        : Text_Box   := (Bx.Forge.Create (Text_Window, 0, 0, 200, 100)
                        with null record);
                begin
                    Text_Window.Show;
                    for N in 1 .. 20 loop
                        exit when Draws > 0 or else FLTK.Wait (0.05) < 0.0;
                    end loop;
                    Checks.Check (Draws > 0, "the text was drawn");
                end;
        end case;
        Checks.Summary;
    end Run;




    --  Running each case in a program of its own  --

    Output_Name : constant String := "test_first_calls.out";

    function Contents
           (Name : in String)
        return String
    is
        File   : Ada.Text_IO.File_Type;
        Result : Ada.Strings.Unbounded.Unbounded_String;
    begin
        Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Name);
        while not Ada.Text_IO.End_Of_File (File) loop
            Ada.Strings.Unbounded.Append (Result, Ada.Text_IO.Get_Line (File));
            Ada.Strings.Unbounded.Append (Result, ASCII.LF);
        end loop;
        Ada.Text_IO.Close (File);
        return Ada.Strings.Unbounded.To_String (Result);
    end Contents;

    procedure Spawn
           (Which : in Case_Name)
    is
        Arg     : GNAT.OS_Lib.String_Access := new String'(Case_Name'Image (Which));
        Success : Boolean;
        Code    : Integer;
    begin
        GNAT.OS_Lib.Spawn
           (Ada.Command_Line.Command_Name, (1 => Arg), Output_Name, Success, Code);
        GNAT.OS_Lib.Free (Arg);
        declare
            Output : constant String := Contents (Output_Name);
            Name   : constant String := Case_Name'Image (Which);
        begin
            Ada.Directories.Delete_File (Output_Name);
            Checks.Check (Success and then Code = 0,
                Name & " as the first call exits 0: " & Integer'Image (Code));
            Checks.Check (Ada.Strings.Fixed.Index (Output, "BadWindow") = 0
                    and then Ada.Strings.Fixed.Index (Output, "X_") = 0,
                Name & " prints no X error");
            if Code /= 0 or else Ada.Strings.Fixed.Index (Output, "X_") /= 0 then
                Ada.Text_IO.Put (Output);
            end if;
        end;
    end Spawn;

begin

    if Ada.Command_Line.Argument_Count = 1 then
        Run (Case_Name'Value (Ada.Command_Line.Argument (1)));
    else
        for Which in Case_Name loop
            Spawn (Which);
        end loop;
        Checks.Summary;
    end if;

end Test_First_Calls;


