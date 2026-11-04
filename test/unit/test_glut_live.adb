

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 112: GLUT follows a window or menu number
--  without a look (windows[win], menus[n], glut_compatibility.cxx:272-288,
--  307-385), deletes a window at once even inside its own display
--  function, gives the 32nd window and menu the number the 31st has, and
--  points a submenu item at its submenu's array, which adding to the
--  submenu reallocates.  A dead number raises Constraint_Error, a full
--  table FLTK.Unsupported_Error, and a call in the wrong state
--  Program_Error.  Windows are destroyed and hidden when the program next
--  waits, so a display function can do either.  Valgrind checks the rest.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.GLUT,
    FLTK.Probe,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Windows.OpenGL.GLUT;

use

    Checks,
    FLTK;

use type

    FLTK.GLUT.Menu_Number,
    FLTK.GLUT.Mouse_Button_Index,
    FLTK.GLUT.Visibility_State,
    FLTK.GLUT.Window_Number;


procedure Test_GLUT_Live is

    package Glt renames FLTK.GLUT;
    package GW  renames FLTK.Widgets.Groups.Windows.OpenGL.GLUT;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;


    --  What the display and visibility functions do and hear

    type Display_Action is (Nothing, Destroy_Self, Hide_Self, Hide_And_Show);

    Action   : Display_Action := Nothing;
    Displays : Natural := 0;
    Hidings  : Natural := 0;

    procedure On_Display is
        Doing : constant Display_Action := Action;
    begin
        Displays := Displays + 1;
        Action := Nothing;
        case Doing is
        when Nothing =>
            null;
        when Destroy_Self =>
            Glt.Destroy_Window (Glt.Get_Window);
        when Hide_Self =>
            Glt.Hide_Window;
        when Hide_And_Show =>
            Glt.Hide_Window;
            Glt.Full_Screen;
            Glt.Show_Window;
        end case;
    end On_Display;

    procedure On_Visibility
           (State : in Glt.Visibility_State) is
    begin
        if State = Glt.Not_Visible then
            Hidings := Hidings + 1;
        end if;
    end On_Visibility;

    procedure Displayed_Window
           (Number : out Glt.Valid_Window_Number;
            Title  : in  String) is
    begin
        Number := Glt.Create_Window (Title);
        Glt.Display_Func (On_Display'Unrestricted_Access);
        Glt.Visibility_Func (On_Visibility'Unrestricted_Access);
        Pump (10);
    end Displayed_Window;


    --  What the menus and the mouse hear

    Picks  : Natural := 0;
    Picked : Integer := 0;

    procedure On_Menu
           (Value : in Integer) is
    begin
        Picks := Picks + 1;
        Picked := Value;
    end On_Menu;

    Pressed : Glt.Mouse_Button_Index := Glt.Wheel_Down;

    procedure On_Mouse
           (Button : in Glt.Mouse_Button_Index;
            State  : in Glt.Button_State;
            X, Y   : in Integer)
    is
        pragma Unreferenced (State, X, Y);
    begin
        Pressed := Button;
    end On_Mouse;

    G : GW.Glut_Window := GW.Forge.Create (200, 200, "Test_GLUT_Live");

    Pick_First : Boolean := True;

    --  Answers a pop-up menu: its first item, or none.
    procedure Answer
           (Value : in Integer)
    is
        pragma Unreferenced (Value);
        Ignore : Boolean;
    begin
        if Pick_First then
            Ignore := Prb.Handle_Key (G, Keydown, Down_Key);
            Ignore := Prb.Handle_Key (G, Keydown, Enter_Key, Text => (1 => ASCII.CR));
        else
            Ignore := Prb.Handle_Key (G, Keydown, Escape_Key, Text => (1 => ASCII.ESC));
        end if;
    end Answer;

    procedure Click is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (G, Push, 10, 10, Clicks => 1);
        Ignore := Prb.Mouse (G, Release, 10, 10, Clicks => 1);
    end Click;


    A, S, B, C : Glt.Valid_Window_Number;

    Sub, Top, Full, Empty : Glt.Valid_Menu_Number;

    --  The calls that must raise

    procedure Set_Window_7 is
    begin
        Glt.Set_Window (7);
    end Set_Window_7;

    procedure Set_Menu_5 is
    begin
        Glt.Set_Menu (5);
    end Set_Menu_5;

    procedure Post_Redisplay_7 is
    begin
        Glt.Post_Window_Redisplay (7);
    end Post_Redisplay_7;

    procedure Destroy_7 is
    begin
        Glt.Destroy_Window (7);
    end Destroy_7;

    procedure Sub_Window_Of_7 is
        Ignore : Glt.Valid_Window_Number;
    begin
        Ignore := Glt.Create_Sub_Window (7, 0, 0, 10, 10);
    end Sub_Window_Of_7;

    procedure Set_Window_A is
    begin
        Glt.Set_Window (A);
    end Set_Window_A;

    procedure Post_Redisplay_S is
    begin
        Glt.Post_Window_Redisplay (S);
    end Post_Redisplay_S;

    procedure Destroy_A is
    begin
        Glt.Destroy_Window (A);
    end Destroy_A;

    procedure Add_Entry is
    begin
        Glt.Add_Menu_Entry ("entry", 1);
    end Add_Entry;

    procedure Remove_First is
    begin
        Glt.Remove_Menu_Item (1);
    end Remove_First;

    procedure Add_Sub is
    begin
        Glt.Add_Sub_Menu ("sub", Sub);
    end Add_Sub;

    procedure Add_Top_To_Itself is
    begin
        Glt.Add_Sub_Menu ("itself", Top);
    end Add_Top_To_Itself;

    procedure Destroy_Sub is
    begin
        Glt.Destroy_Menu (Sub);
    end Destroy_Sub;

    procedure Change_99 is
    begin
        Glt.Change_To_Menu_Entry (99, "changed", 99);
    end Change_99;

    procedure Change_Sub_99 is
    begin
        Glt.Change_To_Sub_Menu (99, "changed", Sub);
    end Change_Sub_99;

    procedure Remove_99 is
    begin
        Glt.Remove_Menu_Item (99);
    end Remove_99;

    procedure Make_Menu is
        Ignore : Glt.Valid_Menu_Number;
    begin
        Ignore := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    end Make_Menu;

    procedure Make_Window is
        Ignore : Glt.Valid_Window_Number;
    begin
        Ignore := Glt.Create_Window ("one too many");
    end Make_Window;

    procedure Make_Glut_Window is
        Extra : constant GW.Glut_Window := GW.Forge.Create (10, 10);
    begin
        if Extra.Get_Number = 0 then
            Ignore_Done := False;
        end if;
    end Make_Glut_Window;

    procedure Attach_Left is
    begin
        Glt.Attach_Menu (Glt.Left);
    end Attach_Left;

    procedure Set_G_Menu_Empty is
    begin
        G.Set_Menu (Glt.Left, Empty);
    end Set_G_Menu_Empty;

    procedure Set_G_Menu_30 is
    begin
        G.Set_Menu (Glt.Left, 30);
    end Set_G_Menu_30;

begin

    Glt.Init;

    --  Numbers that were never made
    Raises (Set_Window_7'Access, Constraint_Error'Identity, "Set_Window of no window");
    Raises (Set_Menu_5'Access, Constraint_Error'Identity, "Set_Menu of no menu");
    Raises (Post_Redisplay_7'Access, Constraint_Error'Identity,
        "Post_Window_Redisplay of no window");
    Raises (Destroy_7'Access, Constraint_Error'Identity, "Destroy_Window of no window");
    Raises (Sub_Window_Of_7'Access, Constraint_Error'Identity,
        "Create_Sub_Window of no window");
    Raises (Add_Entry'Access, Program_Error'Identity, "Add_Menu_Entry with no menu");

    --  A window and its subwindow
    Displayed_Window (A, "a");
    S := Glt.Create_Sub_Window (A, 10, 10, 50, 50);
    Glt.Display_Func (On_Display'Unrestricted_Access);
    Pump (5);
    Check (Glt.Window_Exists (A) and then Glt.Window_Exists (S), "a window and a subwindow");
    Glt.Set_Window (S);
    Check (Glt.Get (Glt.Window_Parent) = Integer (A),
        "a subwindow's parent:" & Integer'Image (Glt.Get (Glt.Window_Parent)));

    --  Destroyed, with its subwindow
    Glt.Destroy_Window (A);
    Check (not Glt.Window_Exists (A) and then not Glt.Window_Exists (S),
        "a window destroyed is gone at once, with its subwindow");
    Check (Glt.Get_Window = Glt.No_Window, "a window destroyed isn't current");
    Pump (5);
    Raises (Set_Window_A'Access, Constraint_Error'Identity, "Set_Window of a window destroyed");
    Raises (Post_Redisplay_S'Access, Constraint_Error'Identity,
        "Post_Window_Redisplay of a subwindow destroyed");
    Raises (Destroy_A'Access, Constraint_Error'Identity, "Destroy_Window twice");

    --  A window destroying itself in its display function
    Displayed_Window (B, "b");
    Displays := 0;
    Action := Destroy_Self;
    Glt.Post_Redisplay;
    Pump (10);
    Check (Displays >= 1 and then Action = Nothing, "the display function ran");
    Check (not Glt.Window_Exists (B), "a window destroys itself in its display function");

    --  A window hiding in its display function
    Displayed_Window (C, "c");
    Hidings := 0;
    Action := Hide_Self;
    Glt.Post_Redisplay;
    Pump (10);
    Check (Action = Nothing and then Hidings = 1,
        "a window hides in its display function:" & Natural'Image (Hidings));
    Check (Glt.Window_Exists (C), "a window hidden still exists");

    --  Hidden, made full screen and shown again in its display function
    Glt.Set_Window (C);
    Glt.Show_Window;
    Pump (10);
    Hidings := 0;
    Action := Hide_And_Show;
    Glt.Post_Redisplay;
    Pump (10);
    Check (Action = Nothing and then Hidings = 0,
        "a window hidden and shown again in its display function stays:"
        & Natural'Image (Hidings));
    Glt.Destroy_Window (C);
    Pump (5);

    --  Queries with no window
    Check (Glt.Get_Window = Glt.No_Window, "no window is current");
    Check (Glt.Get (Glt.Window_Parent) = 0, "no window has no parent");
    Check (Glt.Get (Glt.Window_Doublebuffer) = 0,
        "a GL query with no window:" & Integer'Image (Glt.Get (Glt.Window_Doublebuffer)));
    Check (Glt.Get (Glt.Window_Buffer_Size) = 0,
        "the buffer size with no window:"
        & Integer'Image (Glt.Get (Glt.Window_Buffer_Size)));

    --  30 windows more than G, which make the 31 GLUT has numbers for, in a
    --  plain window
    declare
        type Glut_Access is access GW.Glut_Window;
        procedure Free is new Ada.Unchecked_Deallocation (GW.Glut_Window, Glut_Access);
        Outer : Win.Window := Win.Forge.Create (0, 0, 400, 100, "outer");
        Many  : array (1 .. 30) of Glut_Access;
        Numbered : Boolean := True;
    begin
        for N in Many'Range loop
            Many (N) := new GW.Glut_Window'(GW.Forge.Create (Outer, N * 12, 0, 10, 10));
            Numbered := Numbered and then Integer (Many (N).Get_Number) = N + 1;
        end loop;
        Check (Numbered and then Glt.Window_Exists (31), "30 windows more are numbered 2 to 31");
        Raises (Make_Glut_Window'Access, Unsupported_Error'Identity, "a 32nd Glut_Window");
        Raises (Make_Window'Access, Unsupported_Error'Identity, "a 32nd window");
        Glt.Set_Window (Many (1).Get_Number);
        Check (Glt.Get (Glt.Window_Parent) = 0,
            "a window in a plain window has no GLUT parent:"
            & Integer'Image (Glt.Get (Glt.Window_Parent)));
        declare
            procedure Destroy_Many_3 is
            begin
                Glt.Destroy_Window (Many (3).Get_Number);
            end Destroy_Many_3;
        begin
            Raises (Destroy_Many_3'Access, Program_Error'Identity,
                "Destroy_Window of a Glut_Window");
        end;
        Outer.Show;
        Pump (5);
        for N in Many'Range loop
            Free (Many (N));
        end loop;
        Check (not Glt.Window_Exists (5), "a Glut_Window finalized is gone");
    end;

    --  Submenus
    Sub := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    Top := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    Raises (Add_Sub'Access, Program_Error'Identity, "an empty submenu");
    Glt.Set_Menu (Sub);
    Glt.Add_Menu_Entry ("sub entry", 5);
    Glt.Set_Menu (Top);
    Glt.Add_Menu_Entry ("top entry", 1);
    Glt.Add_Sub_Menu ("sub", Sub);
    Raises (Add_Top_To_Itself'Access, Program_Error'Identity, "a menu as its own submenu");
    Glt.Set_Menu (Sub);
    Raises (Add_Entry'Access, Program_Error'Identity, "adding to a submenu in use");
    Raises (Remove_First'Access, Program_Error'Identity, "removing from a submenu in use");
    Raises (Destroy_Sub'Access, Program_Error'Identity, "destroying a submenu in use");
    Glt.Set_Menu (Top);
    Raises (Change_99'Access, Constraint_Error'Identity, "Change_To_Menu_Entry past the end");
    Raises (Change_Sub_99'Access, Constraint_Error'Identity, "Change_To_Sub_Menu past the end");
    Raises (Remove_99'Access, Constraint_Error'Identity, "Remove_Menu_Item past the end");
    Check (Glt.Get (Glt.Menu_Num_Items) = 2, "a menu keeps its items");

    --  Removing with the array just full reads past it
    Full := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    for N in 1 .. 9 loop
        Glt.Add_Menu_Entry ("item", N);
    end loop;
    Glt.Remove_Menu_Item (1);
    Check (Glt.Get (Glt.Menu_Num_Items) = 8, "an item removed from a full menu");
    Glt.Add_Menu_Entry ("item", 10);
    Glt.Remove_Menu_Item (9);
    Check (Glt.Get (Glt.Menu_Num_Items) = 8, "the last item removed from a full menu");
    Glt.Destroy_Menu (Full);
    Check (Glt.Get_Menu = Glt.No_Menu, "a menu destroyed isn't current");
    Check (not Glt.Menu_Exists (Full), "a menu destroyed is gone");

    --  31 menus
    declare
        Made : array (1 .. 29) of Glt.Valid_Menu_Number;
    begin
        for N in Made'Range loop
            Made (N) := Glt.Create_Menu (On_Menu'Unrestricted_Access);
        end loop;
        Raises (Make_Menu'Access, Unsupported_Error'Identity, "a 32nd menu");
        for N in Made'Range loop
            Glt.Destroy_Menu (Made (N));
        end loop;
    end;

    --  A window's menus
    G.Show;
    while not G.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (5);
    G.Make_Current;
    Empty := Glt.Create_Menu (On_Menu'Unrestricted_Access);
    Raises (Attach_Left'Access, Program_Error'Identity, "attaching an empty menu");
    Raises (Set_G_Menu_Empty'Access, Program_Error'Identity, "Set_Menu of an empty menu");
    Raises (Set_G_Menu_30'Access, Constraint_Error'Identity, "Set_Menu of no menu");
    Glt.Destroy_Menu (Empty);
    Glt.Set_Menu (Top);
    Attach_Left;
    Check (G.Get_Menu (Glt.Left) = Top, "a menu attached");

    --  As in Test_Menu_Popups: on X11 only, as the compositor closes them
    if Prb.On_Wayland then
        Skip ("GLUT's pop-up menus: under Wayland the compositor closes them");
    else
        Pick_First := True;
        Glt.Timer_Func (200, Answer'Unrestricted_Access, 0);
        Click;
        Check (Picks = 1 and then Picked = 1, "a menu pops up, and calls back:"
            & Natural'Image (Picks) & Integer'Image (Picked));
        Pick_First := False;
        Glt.Timer_Func (200, Answer'Unrestricted_Access, 0);
        Click;
        Check (Picks = 1, "or doesn't, closed");
    end if;

    --  The menu goes before the window
    Glt.Destroy_Menu (Top);
    Check (G.Get_Menu (Glt.Left) = Glt.No_Menu, "a menu destroyed is no window's");
    Glt.Destroy_Menu (Sub);
    G.Make_Current;
    Glt.Mouse_Func (On_Mouse'Unrestricted_Access);
    Click;
    Check (Pressed = Glt.Left, "a window's button after its menu goes");

    G.Hide;
    Pump (5);
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GLUT_Live;


