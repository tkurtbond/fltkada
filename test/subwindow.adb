--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/subwindow.cxx: a window inside a window, each with a
--  toggle button, a box that turns red while the mouse is in it, two
--  inputs and a menu button.  Each window takes the focus when clicked,
--  and keeps the last character typed in it; the inner one shows a hand
--  cursor.  A right click anywhere pops up a menu.  FLTK's DEBUG and
--  DEBUG_POS code, off in its build, is left out.  Guided by pofltk's
--  Subwindow.Mod.


with

    FLTK.Events,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Menu_Buttons;

use type

    FLTK.Event_Kind,
    FLTK.Event_Outcome,
    FLTK.Keypress,
    FLTK.Mouse_Cursor_Kind;


function Subwindow
    return Integer
is

    package Ev  renames FLTK.Events;
    package Bx  renames FLTK.Widgets.Boxes;
    package Tgl renames FLTK.Widgets.Buttons.Toggle;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package MB  renames FLTK.Widgets.Menus.Menu_Buttons;


    type Enter_Exit is new Bx.Box with null record;

    overriding function Handle
           (This  : in out Enter_Exit;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    function Handle
           (This  : in out Enter_Exit;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        case Event is
            when FLTK.Enter =>
                This.Set_Background_Color (FLTK.Red_Color);
                This.Redraw;
                return FLTK.Handled;
            when FLTK.Leave =>
                This.Set_Background_Color (FLTK.Background_Color);  --  FL_GRAY
                This.Redraw;
                return FLTK.Handled;
            when others =>
                return FLTK.Not_Handled;
        end case;
    end Handle;

    function Make_Enter_Exit
           (Parent     : in out FLTK.Widgets.Groups.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String)
        return Enter_Exit is
    begin
        return (Bx.Forge.Create (Parent, FLTK.Border_Box, X, Y, W, H, Text) with null record);
    end Make_Enter_Exit;


    type Test_Window is new Win.Window with record
        Cx, Cy : Integer := 0;
        Key    : Character := ASCII.NUL;
        Crsr   : FLTK.Mouse_Cursor_Kind := FLTK.Default_Mouse;
    end record;

    overriding function Handle
           (This  : in out Test_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    function Handle
           (This  : in out Test_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        if This.Crsr /= FLTK.Default_Mouse then
            if Event = FLTK.Enter then
                This.Set_Cursor (This.Crsr);
            end if;
            if Event = FLTK.Leave then
                This.Set_Cursor (FLTK.Default_Mouse);
            end if;
        end if;
        if Win.Window (This).Handle (Event) = FLTK.Handled then
            return FLTK.Handled;
        end if;
        if Event = FLTK.Focus then
            return FLTK.Handled;
        end if;
        if Event = FLTK.Push then
            Ev.Set_Focus (This);
            return FLTK.Handled;
        end if;
        if Event = FLTK.Keydown and then Ev.Text_Length > 0
            and then Ev.Text (Ev.Text'First) /= ASCII.NUL
        then
            if Ev.Last_Key = FLTK.Escape_Key or Ev.Key_Command then
                return FLTK.Not_Handled;
            end if;
            This.Key := Ev.Text (Ev.Text'First);
            This.Cx := Ev.Mouse_X;
            This.Cy := Ev.Mouse_Y;
            This.Redraw;
            return FLTK.Handled;
        end if;
        return FLTK.Not_Handled;
    end Handle;


    Bigmess : constant String := "this|is|only|a test";


    Window : Test_Window := (Win.Forge.Create (400, 400, "outer") with others => <>);

    Outer_Toggle : Tgl.Toggle_Button := Tgl.Forge.Create (Window, 310, 310, 80, 80, "&outer");
    Outer_EE     : Enter_Exit := Make_Enter_Exit (Window, 10, 310, 80, 80, "enterexit");
    Outer_In1    : Inp.Text_Input := Inp.Forge.Create (Window, 160, 310, 140, 25, "input1:");
    Outer_In2    : Inp.Text_Input := Inp.Forge.Create (Window, 160, 340, 140, 25, "input2:");
    Menu1        : MB.Menu_Button := MB.Forge.Create (Window, 5, 150, 80, 25, "menu&1");

    Sub : Test_Window := (Win.Forge.Create (Window, 100, 100, 200, 200, "inner") with others => <>);

    Inner_Toggle : Tgl.Toggle_Button := Tgl.Forge.Create (Sub, 110, 110, 80, 80, "&inner");
    Inner_EE     : Enter_Exit := Make_Enter_Exit (Sub, 10, 110, 80, 80, "enterexit");
    Menu2        : MB.Menu_Button := MB.Forge.Create (Sub, 50, 20, 80, 25, "menu&2");
    Inner_In1    : Inp.Text_Input := Inp.Forge.Create (Sub, 55, 50, 140, 25, "input1:");
    Inner_In2    : Inp.Text_Input := Inp.Forge.Create (Sub, 55, 80, 140, 25, "input2:");

    Message : Bx.Box := Bx.Forge.Create (Window, FLTK.No_Box, 0, 0, 400, 100,
        "A child Fl_Window with children of its own may " &
        "be useful for imbedding controls into a GL or display " &
        "that needs a different visual.  There are bugs with the " &
        "origins being different between drawing and events, " &
        "which I hope I have solved.");

    Popup : MB.Menu_Button := MB.Forge.Create (Window, 0, 0, 400, 400);

    pragma Unreferenced (Outer_Toggle, Outer_EE, Outer_In1, Outer_In2, Inner_Toggle, Inner_EE,
        Inner_In1, Inner_In2);

begin

    Window.Set_Box (FLTK.Up_Box);
    Sub.Set_Box (FLTK.Down_Box);

    Menu1.Add_Items (Bigmess);
    Menu2.Add_Items (Bigmess);

    Sub.Set_Resizable (Sub);
    Window.Set_Resizable (Sub);
    Sub.End_Current;
    Sub.Crsr := FLTK.Hand_Mouse;

    Message.Set_Alignment (FLTK.Align_Wrap);

    Popup.Set_Popup_Kind (MB.Popup3);
    Popup.Add_Items ("This|is|a popup|menu");
    Popup.Add_Items (Bigmess);

    Window.End_Current;
    Window.Show_With_Args;

    return FLTK.Run;

end Subwindow;
