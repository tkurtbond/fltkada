--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/glut_test.cxx: calls GLUT's functions twice, first with a
--  current window and then with none, prints what GLUT says, and exits.
--  It shows nothing and waits for nothing.  Three things differ, because
--  FLTK.GLUT refuses what FLTK lets pass: the menu it attaches is a real
--  one, and with no current window there is no window to destroy and no
--  window to give the per-window callbacks to.


with

    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.GLUT;

use

    FLTK.GLUT;


procedure GLUT_Test is

    procedure Show
           (Name  : in String;
            Value : in Integer) is
    begin
        Ada.Text_IO.Put_Line
            (Name & " = " & Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Left));
    end Show;

    function Image
           (Number : in Window_Number)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Window_Number'Image (Number), Ada.Strings.Left);
    end Image;


    --  Empty callbacks, for testing.

    procedure Display is null;

    procedure Reshape
           (W, H : in Integer) is null;

    procedure Keyboard
           (Key  : in Character;
            X, Y : in Integer) is null;

    procedure Mouse
           (Button : in Mouse_Button_Index;
            State  : in Button_State;
            X, Y   : in Integer) is null;

    procedure Motion
           (X, Y : in Integer) is null;

    procedure Passive_Motion
           (X, Y : in Integer) is null;

    procedure Enter_Or_Leave
           (State : in Entry_State) is null;

    procedure Visibility
           (State : in Visibility_State) is null;

    procedure Idle is null;

    procedure Timer
           (Value : in Integer) is null;

    procedure Menu_State_Changed
           (State : in Menu_State) is null;

    procedure Menu_Status
           (State : in Menu_State;
            X, Y  : in Integer) is null;

    procedure Special
           (Key  : in Special_Key;
            X, Y : in Integer) is null;

    procedure Overlay_Display is null;

    procedure Menu_Picked
           (Value : in Integer) is null;


    Win1, Win2, Current : Window_Number;
    Menu                : Menu_Number;

begin

    Init;

    --  Create 2 windows.
    Win1 := Create_Window ("Window 1");
    Win2 := Create_Window ("Window 2");
    Ada.Text_IO.Put_Line ("Window 1 created, number = " & Image (Win1));
    Ada.Text_IO.Put_Line ("Window 2 created, number = " & Image (Win2));

    Menu := Create_Menu (Menu_Picked'Unrestricted_Access);
    Add_Menu_Entry ("Item", 1);
    pragma Unreferenced (Menu);

    --  Run the tests twice, with (1) a valid and (2) no current window.
    for Pass in 1 .. 2 loop

        Current := Get_Window;
        Ada.Text_IO.Put_Line ("Window " & Image (Current) & " is current");

        Post_Redisplay;
        Set_Window_Title ("Non-existent");
        Set_Icon_Title ("Non-existent");
        Position_Window (10, 20);
        Reshape_Window (100, 200);
        Pop_Window;
        Iconify_Window;
        Show_Window;
        Hide_Window;
        Full_Screen;
        Set_Cursor (Info_Cursor);

        Establish_Overlay;
        Remove_Overlay;
        Use_Layer (Normal_Layer);
        Use_Layer (Overlay_Layer);
        Post_Overlay_Redisplay;
        Show_Overlay;
        Hide_Overlay;

        Attach_Menu (Left);
        Detach_Menu (Left);

        if Current /= No_Window then
            Display_Func (Display'Unrestricted_Access);
            Reshape_Func (Reshape'Unrestricted_Access);
            Keyboard_Func (Keyboard'Unrestricted_Access);
            Mouse_Func (Mouse'Unrestricted_Access);
            Motion_Func (Motion'Unrestricted_Access);
            Passive_Motion_Func (Passive_Motion'Unrestricted_Access);
            Entry_Func (Enter_Or_Leave'Unrestricted_Access);
            Visibility_Func (Visibility'Unrestricted_Access);
            Special_Func (Special'Unrestricted_Access);
            Overlay_Display_Func (Overlay_Display'Unrestricted_Access);
        end if;
        Idle_Func (Idle'Unrestricted_Access);
        Timer_Func (1000, Timer'Unrestricted_Access, 42);
        Menu_State_Func (Menu_State_Changed'Unrestricted_Access);
        Menu_Status_Func (Menu_Status'Unrestricted_Access);

        Swap_Buffers;

        Show ("GLUT_WINDOW_X", Get (Window_X));
        Show ("GLUT_WINDOW_Y", Get (Window_Y));
        Show ("GLUT_WINDOW_WIDTH", Get (Window_Width));
        Show ("GLUT_WINDOW_HEIGHT", Get (Window_Height));
        Show ("GLUT_WINDOW_PARENT", Get (Window_Parent));

        Show ("GLUT_OVERLAY_POSSIBLE", Layer_Get (Overlay_Possible));
        Show ("GLUT_NORMAL_DAMAGED", Layer_Get (Normal_Damaged));

        --  Destroying the current window leaves none current.
        Ada.Text_IO.Put_Line ("Destroy the current window (" & Image (Get_Window) & ")");
        Ada.Text_IO.New_Line;
        if Current /= No_Window then
            Destroy_Window (Current);
        end if;

    end loop;

    Ada.Text_IO.Put_Line ("All tests done, exiting.");

end GLUT_Test;
