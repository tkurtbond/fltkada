

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestGlut: GLUT's state, device and layer
--  queries, the display, reshape and visibility functions, a window
--  reshaped, retitled and given a cursor, a subwindow and Set_Window,
--  a window hidden and destroyed, the calls that do nothing with no
--  current window, a Glut_Window's mouse, motion, wheel, entry, keyboard
--  and special keys, menus changed and their state, timers and the idle
--  function, and the stroke fonts' sizes.  Windows and menus by number,
--  destroyed as they draw, hidden, or 31 of them, are test_glut_live's;
--  the bitmap and stroke fonts drawn are test_glut_fonts's; the overlay
--  test_glut_overlay's, the strings GLUT keeps test_glut_strings's, and a
--  window's Ada object test_glut_window_of's.


with

    Ada.Exceptions,
    Checks,
    FLTK.Events,
    FLTK.GLUT,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.OpenGL.GLUT,
    Interfaces.C;

use

    Checks,
    FLTK;

use type

    FLTK.GLUT.Button_State,
    FLTK.GLUT.Entry_State,
    FLTK.GLUT.Menu_Number,
    FLTK.GLUT.Menu_State,
    FLTK.GLUT.Mouse_Button_Index,
    FLTK.GLUT.Special_Key,
    FLTK.GLUT.Visibility_State,
    FLTK.GLUT.Window_Number;


procedure Test_GLUT is

    package C   renames Interfaces.C;
    package Glt renames FLTK.GLUT;
    package GW  renames FLTK.Widgets.Groups.Windows.OpenGL.GLUT;
    package Prb renames FLTK.Probe;

    pragma Linker_Options ("-lGL");

    Color_Buffer_Bit : constant := 16#4000#;
    GL_RGB           : constant := 16#1907#;
    GL_Unsigned_Byte : constant := 16#1401#;

    type Pixel is array (1 .. 4) of C.unsigned_char with Convention => C;

    procedure Clear_Color (R, G, B, A : in C.C_float)
    with Import, Convention => C, External_Name => "glClearColor";

    procedure Clear (Mask : in C.unsigned)
    with Import, Convention => C, External_Name => "glClear";

    procedure Flush
    with Import, Convention => C, External_Name => "glFlush";

    procedure Viewport (X, Y, W, H : in C.int)
    with Import, Convention => C, External_Name => "glViewport";

    procedure Read_Pixels
           (X, Y, W, H   : in     C.int;
            Format, Kind : in     C.unsigned;
            Data         :    out Pixel)
    with Import, Convention => C, External_Name => "glReadPixels";


    --  Waits, of 0.02 s; generous, for valgrind.
    Limit : constant := 500;

    Ignore : Boolean;

    procedure Waits is
    begin
        Ignore := Wait (0.02) < 0.0;
    end Waits;


    --  What the callbacks heard.
    Draws, Red, Reshapes, Width, Height : Natural := 0;
    Visible, Invisible, Motions, Passive : Natural := 0;
    Key      : Character := ASCII.NUL;
    Special  : Glt.Special_Key := 0;
    Button   : Glt.Mouse_Button_Index := Glt.Middle;
    State    : Glt.Button_State := Glt.Up;
    Entered  : Glt.Entry_State := Glt.Exited;
    Entries  : Natural := 0;
    Idles    : Natural := 0;
    Timer    : Integer := 0;
    Picks    : Natural := 0;
    Picked   : Integer := 0;
    In_Menu  : Glt.Menu_State := Glt.In_Use;

    procedure Display is
        P : Pixel := (others => 0);
    begin
        Draws := Draws + 1;
        Clear_Color (1.0, 0.0, 0.0, 1.0);
        Clear (Color_Buffer_Bit);
        Flush;
        Read_Pixels (1, 1, 1, 1, GL_RGB, GL_Unsigned_Byte, P);
        Red := Natural (P (1));
        Glt.Swap_Buffers;
    end Display;

    procedure Reshape
           (W, H : in Integer) is
    begin
        Reshapes := Reshapes + 1;
        Width := W;
        Height := H;
        Viewport (0, 0, C.int (W), C.int (H));
    end Reshape;

    procedure Visibility
           (Seen : in Glt.Visibility_State) is
    begin
        if Seen = Glt.Visible then
            Visible := Visible + 1;
        else
            Invisible := Invisible + 1;
        end if;
    end Visibility;

    procedure Keyboard
           (Typed : in Character;
            X, Y  : in Integer)
    is
        pragma Unreferenced (X, Y);
    begin
        Key := Typed;
    end Keyboard;

    procedure Specially
           (Pressed : in Glt.Special_Key;
            X, Y    : in Integer)
    is
        pragma Unreferenced (X, Y);
    begin
        Special := Pressed;
    end Specially;

    procedure Mouse
           (Which : in Glt.Mouse_Button_Index;
            Now   : in Glt.Button_State;
            X, Y  : in Integer)
    is
        pragma Unreferenced (X, Y);
    begin
        Button := Which;
        State := Now;
    end Mouse;

    procedure Motion
           (X, Y : in Integer)
    is
        pragma Unreferenced (X, Y);
    begin
        Motions := Motions + 1;
    end Motion;

    procedure Passive_Motion
           (X, Y : in Integer)
    is
        pragma Unreferenced (X, Y);
    begin
        Passive := Passive + 1;
    end Passive_Motion;

    procedure Entering
           (Now : in Glt.Entry_State) is
    begin
        Entries := Entries + 1;
        Entered := Now;
    end Entering;

    procedure Idle is
    begin
        Idles := Idles + 1;
    end Idle;

    procedure Timed
           (Value : in Integer) is
    begin
        Timer := Value;
    end Timed;

    procedure On_Menu
           (Value : in Integer) is
    begin
        Picks := Picks + 1;
        Picked := Value;
    end On_Menu;

    procedure Menu_State
           (Now : in Glt.Menu_State) is
    begin
        In_Menu := Now;
    end Menu_State;

    procedure Wait_To_Draw is
        Before : constant Natural := Draws;
    begin
        for K in 1 .. Limit loop
            exit when Draws /= Before;
            Waits;
        end loop;
    end Wait_To_Draw;

    procedure No_Display_Func is
    begin
        Glt.Display_Func (Display'Unrestricted_Access);
    end No_Display_Func;


    --  FL_DOUBLE + FL_DEPTH (Enumerations.H), as GLUT gives it.
    Double_Depth : constant := 2 + 16;

    Mode : constant Glt.Display_Mode := (Double | Depth => True, others => False);

    N, N2 : Glt.Valid_Window_Number;

    G : GW.Glut_Window := GW.Forge.Create (100, 80, "Test_GLUT");

    Pick_First : Boolean := True;

    --  Answers a pop-up menu: its first item, or none.
    procedure Answer
           (Value : in Integer)
    is
        pragma Unreferenced (Value);
    begin
        if Pick_First then
            Ignore := Prb.Handle_Key (G, Keydown, Down_Key);
            Ignore := Prb.Handle_Key (G, Keydown, Enter_Key, Text => (1 => ASCII.CR));
        else
            Ignore := Prb.Handle_Key (G, Keydown, Escape_Key, Text => (1 => ASCII.ESC));
        end if;
    end Answer;

    Sub, M : Glt.Valid_Menu_Number;

    procedure Make_G_Current is
    begin
        G.Make_Current;
    end Make_G_Current;

begin

    Glt.Init;

    --  Windows.
    Glt.Init_Display_Mode (Mode);
    Glt.Init_Window_Size (100, 80);
    Check (Glt.Get (Glt.Init_Window_Width) = 100, "Get: the size for a new window");
    Check (Glt.Get (Glt.Init_Display_Mode) = Double_Depth,
        "Get: its mode:" & Glt.Get (Glt.Init_Display_Mode)'Image);
    Check (Glt.Get (Glt.Display_Mode_Possible) /= 0, "that mode can be had");
    Check (Glt.Get (Glt.Version) > 0, "Get: FLTK's GLUT version");
    Check (Glt.Device_Get (Glt.Has_Keyboard) /= 0, "a keyboard");
    Check (Glt.Device_Get (Glt.Num_Mouse_Buttons) = 3, "a mouse");

    N := Glt.Create_Window ("first");
    Check (Glt.Get_Window = N, "Create_Window's window is current");
    Check (Glt.Window_Exists (N), "and exists");
    declare
        Box : constant FLTK.Widgets.Boxes.Box := FLTK.Widgets.Boxes.Forge.Create (0, 0, 10, 10);
    begin
        Check (Box.Parent = null, "Create_Window leaves no group current");
    end;

    Glt.Display_Func (Display'Unrestricted_Access);
    Glt.Reshape_Func (Reshape'Unrestricted_Access);
    Glt.Visibility_Func (Visibility'Unrestricted_Access);
    Glt.Post_Redisplay;
    Wait_To_Draw;
    Check (Draws > 0, "the display function is called");
    Check (Red = 255, "and draws with GL:" & Red'Image);
    Check (Reshapes > 0 and Width = 100 and Height = 80, "the reshape function hears the size:"
        & Width'Image & Height'Image);
    Check (Glt.Get (Glt.Window_Width) = 100 and Glt.Get (Glt.Window_Height) = 80,
        "Get: its size");
    Check (Glt.Get (Glt.Window_Parent) = 0, "Get: no parent");
    Check (Glt.Get (Glt.Window_Doublebuffer) = 1, "Get: GL's answer");
    Check (Glt.Get (Glt.Window_Buffer_Size) > 0, "Get: its bits");
    Check (Glt.Layer_Get (Glt.Overlay_Possible) = 0, "Layer_Get");

    Glt.Reshape_Window (120, 90);
    Glt.Post_Redisplay;
    Wait_To_Draw;
    --  A tiling compositor gives it the size it likes.
    for K in 1 .. Limit loop
        exit when Width = Glt.Get (Glt.Window_Width);
        Waits;
    end loop;
    Check (Width = Glt.Get (Glt.Window_Width), "reshape hears the size:" & Width'Image);
    Check (Prb.On_Wayland or Width = 120, "the size asked for");
    Glt.Set_Window_Title ("second");
    Glt.Set_Icon_Title ("icon");
    Glt.Set_Icon_Title ("icon2");
    Glt.Set_Cursor (Glt.Info_Cursor);
    Glt.Pop_Window;
    Waits;

    N2 := Glt.Create_Sub_Window (N, 5, 5, 30, 30);
    Check (N2 /= N and Glt.Window_Exists (N2), "a subwindow");
    Check (Glt.Get (Glt.Window_Parent) = Integer (N), "its parent");
    Glt.Display_Func (Display'Unrestricted_Access);
    Glt.Set_Window (N);
    Check (Glt.Get_Window = N, "Set_Window");
    Glt.Post_Window_Redisplay (N2);
    Waits;

    Glt.Set_Window (N);     --  any event makes its window current
    Glt.Hide_Window;
    for K in 1 .. Limit loop
        exit when Invisible > 0;
        Waits;
    end loop;
    Check (Invisible > 0, "visibility hears it hidden");
    Glt.Show_Window;
    Waits;
    Glt.Set_Window (N);
    Glt.Establish_Overlay;
    Glt.Use_Layer (Glt.Normal_Layer);
    Glt.Remove_Overlay;

    Glt.Set_Window (N);
    Glt.Destroy_Window (N);
    Check (Glt.Get_Window = Glt.No_Window, "no window is current after the current one goes");
    Check (not Glt.Window_Exists (N) and not Glt.Window_Exists (N2),
        "it is gone at once, with its subwindow");
    Ignore := FLTK.Check;

    --  With no current window these do nothing.
    Glt.Post_Redisplay;
    Glt.Set_Window_Title ("none");
    Glt.Set_Icon_Title ("none");
    Glt.Reshape_Window (1, 1);
    Glt.Swap_Buffers;
    Glt.Establish_Overlay;
    Glt.Use_Layer (Glt.Overlay_Layer);
    Glt.Show_Window;
    Glt.Hide_Window;
    Glt.Full_Screen;
    Glt.Set_Cursor (Glt.Wait_Cursor);
    Check (True, "with no current window, the window calls do nothing");
    Raises (No_Display_Func'Unrestricted_Access, Program_Error'Identity,
        "and Display_Func raises Program_Error");

    --  Events, on a Glut_Window.
    Raises (Make_G_Current'Unrestricted_Access, Program_Error'Identity,
        "Make_Current before it is shown raises Program_Error (pofltk 111)");
    Glt.Set_Window (G.Get_Number);
    Check (Glt.Get_Window = G.Get_Number, "but Set_Window makes it current");
    Glt.Display_Func (Display'Unrestricted_Access);
    Glt.Keyboard_Func (Keyboard'Unrestricted_Access);
    Glt.Special_Func (Specially'Unrestricted_Access);
    Glt.Mouse_Func (Mouse'Unrestricted_Access);
    Glt.Motion_Func (Motion'Unrestricted_Access);
    Glt.Passive_Motion_Func (Passive_Motion'Unrestricted_Access);
    Glt.Entry_Func (Entering'Unrestricted_Access);
    G.Show;
    G.Wait_For_Expose;
    Draws := 0;
    G.Redraw;
    Wait_To_Draw;
    Check (Draws > 0, "a Glut_Window's display function");
    G.Make_Current;
    Glt.Hide_Window;
    Glt.Show_Window;
    Waits;
    Check (G.Is_Shown, "hidden and shown again");

    Ignore := Prb.Mouse (G, Push, 10, 11, Right_Button, Clicks => 1);
    Check (Button = Glt.Right and State = Glt.Down, "mouse: a push");
    Ignore := Prb.Mouse (G, Drag, 12, 11, Right_Button, Clicks => 1);
    Check (Motions = 1, "motion");
    Ignore := Prb.Mouse (G, Release, 12, 11, Right_Button, Clicks => 1);
    Check (State = Glt.Up, "mouse: a release");
    Ignore := Prb.Mouse (G, Move, 13, 11, No_Button);
    Check (Passive = 1, "passive motion");
    Ignore := Prb.Wheel (G, 13, 11, 0, 1);
    Check (Button = Glt.Wheel_Down, "the wheel is a fourth and fifth button");
    Ignore := Prb.Mouse (G, Enter, 13, 11, No_Button);
    Check (Entries = 1 and Entered = Glt.Entered, "entry: entered");
    Ignore := Prb.Mouse (G, Leave, 13, 11, No_Button);
    Check (Entries = 2 and Entered = Glt.Exited, "entry: left");

    FLTK.Events.Set_Focus (G);
    Ignore := Prb.Key (Keydown, Press ('q'), Text => "q");
    Check (Key = 'q', "keyboard");
    --  GLUT passes the first byte of the event's text; this text is one.
    Ignore := Prb.Key (Keydown, Character_Key (Wide_Character'Val (233)),
        Text => (1 => Character'Val (233)));
    Check (Character'Pos (Key) = 233, "keyboard: a byte above 127:" & Character'Pos (Key)'Image);
    Ignore := Prb.Key (Keydown, Function_Key (2));
    Check (Special = Glt.Key_F2, "special: F2");
    Ignore := Prb.Key (Keydown, Left_Key);
    Check (Special = Glt.Key_Left, "special: left");

    Glt.Keyboard_Func (null);
    Glt.Special_Func (null);
    Glt.Mouse_Func (null);
    Glt.Motion_Func (null);
    Glt.Passive_Motion_Func (null);
    Glt.Entry_Func (null);
    Button := Glt.Middle;
    Ignore := Prb.Mouse (G, Push, 10, 11, Left_Button, Clicks => 1);
    Ignore := Prb.Mouse (G, Release, 10, 11, Left_Button, Clicks => 1);
    Check (Button = Glt.Middle, "a callback set to null is not called");

    --  Menus.
    Check (Glt.Get_Menu = Glt.No_Menu, "no menu to start with");
    Check (Glt.Get (Glt.Menu_Num_Items) = 0, "and no items");
    Sub := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    Glt.Add_Menu_Entry ("one", 1);
    Glt.Add_Menu_Entry ("two", 2);
    M := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    Check (Glt.Get_Menu = M, "a menu made is current");
    Glt.Add_Menu_Entry ("top", 3);
    Glt.Add_Sub_Menu ("more", Sub);
    Check (Glt.Get (Glt.Menu_Num_Items) = 2, "it has what was added");
    Glt.Change_To_Menu_Entry (1, "changed", 4);
    Glt.Change_To_Sub_Menu (2, "again", Sub);
    Check (Glt.Get (Glt.Menu_Num_Items) = 2, "and as many, changed");
    Glt.Menu_State_Func (Menu_State'Unrestricted_Access);
    G.Make_Current;
    Glt.Attach_Menu (Glt.Left);

    --  As in Test_Menu_Popups: on X11 only, as the compositor closes them.
    if Prb.On_Wayland then
        Skip ("GLUT's pop-up menus: under Wayland the compositor closes them");
    else
        Pick_First := True;
        Glt.Timer_Func (200, Answer'Unrestricted_Access, 0);
        Ignore := Prb.Mouse (G, Push, 10, 10, Clicks => 1);
        Check (Picks = 1 and Picked = 4, "a changed menu pops up, and calls back:"
            & Picks'Image & Picked'Image);
        Check (In_Menu = Glt.Not_In_Use, "the menu state is heard");
        Ignore := Prb.Mouse (G, Release, 10, 10, Clicks => 1);
    end if;
    Glt.Menu_State_Func (null);
    Glt.Destroy_Menu (M);
    Glt.Destroy_Menu (Sub);

    --  Timers.
    Glt.Timer_Func (1, Timed'Unrestricted_Access, 42);
    for K in 1 .. Limit loop
        exit when Timer /= 0;
        Waits;
    end loop;
    Check (Timer = 42, "a timer, with its value");
    Glt.Idle_Func (Idle'Unrestricted_Access);
    for K in 1 .. Limit loop
        exit when Idles > 0;
        Waits;
    end loop;
    Glt.Idle_Func (null);
    Check (Idles > 0, "idle");
    Check (Glt.Get (Glt.Elapsed_Time) > 0, "elapsed time");

    --  The stroke fonts are data, and need no window.
    Check (Glt.Stroke_Width (Glt.Roman, 'A') = 80, "a stroke character's width");
    Check (Glt.Stroke_Width (Glt.Mono_Roman, 'A') = 105, "a monospaced one's");
    Check (Glt.Stroke_Length (Glt.Roman, "AB") = 164, "a string's length");
    Check (Glt.Stroke_Length (Glt.Mono_Roman, "AB") = 210, "a monospaced one's");
    Check (Glt.Stroke_Length (Glt.Roman, "AB" & ASCII.LF & "A") = 164, "its longest line");
    Check (Integer (Float'Floor (Glt.Stroke_Height (Glt.Roman))) = 152,
        "a stroke font's height");
    Check (Integer (Float'Floor (Glt.Stroke_Height (Glt.Mono_Roman))) = 152,
        "the other's");

    G.Hide;
    Waits;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GLUT;
