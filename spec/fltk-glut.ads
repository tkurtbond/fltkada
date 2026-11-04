

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Binding of the free functions in FL/glut.H, FLTK's emulation of the
--  GLUT library. The Fl_Glut_Window class itself is bound separately as
--  FLTK.Widgets.Groups.Windows.OpenGL.GLUT.

--  GLUT callbacks have no user data; like the C++ originals, the per-window
--  callbacks set here apply to the current window (see Get_Window), and the
--  Idle, Timer, Menu_State and Menu_Status callbacks are global.


with

    FLTK.Widgets.Groups.Windows.OpenGL,
    System;


package FLTK.GLUT is


    --  GLUT windows and menus are referred to by number, as in C. Zero
    --  means no window or menu.  FLTK indexes its tables by these numbers
    --  without checking them (pofltk 112), so every subprogram given a
    --  number that is not a live window or menu raises Constraint_Error.
    --  GLUT has 31 window numbers and 31 menu numbers to give: FLTK gives
    --  the 32nd the number the 31st has (glut_compatibility.cxx:168, 308),
    --  so making a 32nd raises FLTK.Unsupported_Error.  A
    --  Glut_Window from FLTK.Widgets.Groups.Windows.OpenGL.GLUT.Forge takes
    --  a window number too.

    type Window_Number is range 0 .. 32;
    subtype Valid_Window_Number is Window_Number range 1 .. Window_Number'Last;

    No_Window : constant Window_Number := 0;

    type Menu_Number is range 0 .. 32;
    subtype Valid_Menu_Number is Menu_Number range 1 .. Menu_Number'Last;

    No_Menu : constant Menu_Number := 0;


    --  GLUT_RGB, GLUT_RGBA and GLUT_SINGLE are all zero, so are the
    --  defaults here. GLUT_DOUBLE | GLUT_RGBA | FL_OPENGL3 is written
    --  (Double => True, OpenGL3 => True, others => False).
    subtype Display_Mode is FLTK.Widgets.Groups.Windows.OpenGL.Mode_Mask;


    --  The positions of these match GLUT_LEFT_BUTTON etc, and the 3 and 4
    --  that FLTK's GLUT passes for the mouse wheel
    type Mouse_Button_Index is (Left, Middle, Right, Wheel_Up, Wheel_Down);

    subtype Menu_Button is Mouse_Button_Index range Left .. Right;

    type Button_State is (Down, Up);

    type Entry_State is (Exited, Entered);

    type Visibility_State is (Not_Visible, Visible);

    type Menu_State is (Not_In_Use, In_Use);

    type Layer_Kind is (Normal_Layer, Overlay_Layer);


    --  Keys passed to a Special_Function: 1 .. 12 for the function keys,
    --  FLTK key codes for the rest.
    type Special_Key is new Integer;

    Key_F1        : constant Special_Key := 1;
    Key_F2        : constant Special_Key := 2;
    Key_F3        : constant Special_Key := 3;
    Key_F4        : constant Special_Key := 4;
    Key_F5        : constant Special_Key := 5;
    Key_F6        : constant Special_Key := 6;
    Key_F7        : constant Special_Key := 7;
    Key_F8        : constant Special_Key := 8;
    Key_F9        : constant Special_Key := 9;
    Key_F10       : constant Special_Key := 10;
    Key_F11       : constant Special_Key := 11;
    Key_F12       : constant Special_Key := 12;
    Key_Home      : constant Special_Key := 16#FF50#;
    Key_Left      : constant Special_Key := 16#FF51#;
    Key_Up        : constant Special_Key := 16#FF52#;
    Key_Right     : constant Special_Key := 16#FF53#;
    Key_Down      : constant Special_Key := 16#FF54#;
    Key_Page_Up   : constant Special_Key := 16#FF55#;
    Key_Page_Down : constant Special_Key := 16#FF56#;
    Key_End       : constant Special_Key := 16#FF57#;
    Key_Insert    : constant Special_Key := 16#FF63#;


    type Cursor_Kind is
       (Right_Arrow_Cursor,
        Left_Arrow_Cursor,
        Info_Cursor,
        Destroy_Cursor,
        Help_Cursor,
        Cycle_Cursor,
        Spray_Cursor,
        Wait_Cursor,
        Text_Cursor,
        Crosshair_Cursor,
        Up_Down_Cursor,
        Left_Right_Cursor,
        Top_Side_Cursor,
        Bottom_Side_Cursor,
        Left_Side_Cursor,
        Right_Side_Cursor,
        Top_Left_Corner_Cursor,
        Top_Right_Corner_Cursor,
        Bottom_Right_Corner_Cursor,
        Bottom_Left_Corner_Cursor,
        Inherit_Cursor,
        None_Cursor,
        Full_Crosshair_Cursor);


    --  Values for Get, the GLUT_* query constants
    type State_Query is
       (Return_Zero,
        Window_X,
        Window_Y,
        Window_Width,
        Window_Height,
        Window_Parent,
        Screen_Width,
        Screen_Height,
        Menu_Num_Items,
        Display_Mode_Possible,
        Init_Window_X,
        Init_Window_Y,
        Init_Window_Width,
        Init_Window_Height,
        Init_Display_Mode,
        Window_Buffer_Size,
        Version,
        Elapsed_Time,
        Window_Doublebuffer,
        Window_Stereo,
        Window_Colormap_Size,
        Window_Red_Size,
        Window_Green_Size,
        Window_Blue_Size,
        Window_Alpha_Size,
        Window_Depth_Size,
        Window_Stencil_Size,
        Window_Accum_Red_Size,
        Window_Accum_Green_Size,
        Window_Accum_Blue_Size,
        Window_Accum_Alpha_Size,
        Window_RGBA,
        Window_Num_Samples);

    --  Values for Device_Get
    type Device_Query is
       (Has_Keyboard,
        Has_Mouse,
        Has_Spaceball,
        Has_Dial_And_Button_Box,
        Has_Tablet,
        Num_Mouse_Buttons,
        Num_Spaceball_Buttons,
        Num_Button_Box_Buttons,
        Num_Dials,
        Num_Tablet_Buttons);

    --  Values for Layer_Get
    type Layer_Query is
       (Overlay_Possible,
        Transparent_Index,
        Normal_Damaged,
        Overlay_Damaged);


    type Display_Function is access procedure;

    type Reshape_Function is access procedure
           (W, H : in Integer);

    type Keyboard_Function is access procedure
           (Key  : in Character;
            X, Y : in Integer);

    type Mouse_Function is access procedure
           (Button : in Mouse_Button_Index;
            State  : in Button_State;
            X, Y   : in Integer);

    type Motion_Function is access procedure
           (X, Y : in Integer);

    type Entry_Function is access procedure
           (State : in Entry_State);

    type Visibility_Function is access procedure
           (State : in Visibility_State);

    type Special_Function is access procedure
           (Key  : in Special_Key;
            X, Y : in Integer);

    type Idle_Function is access procedure;

    type Timer_Function is access procedure
           (Value : in Integer);

    type Menu_Function is access procedure
           (Value : in Integer);

    type Menu_State_Function is access procedure
           (State : in Menu_State);

    type Menu_Status_Function is access procedure
           (State : in Menu_State;
            X, Y  : in Integer);




    --  Initialisation  --

    --  Passes the program's command line (from Ada.Command_Line) to glutInit
    procedure Init;

    procedure Init_Display_Mode
           (Mode : in Display_Mode);

    procedure Init_Window_Position
           (X, Y : in Integer);

    procedure Init_Window_Size
           (W, H : in Integer);

    procedure Main_Loop;




    --  Windows  --

    --  Create_Window and Create_Sub_Window raise FLTK.Unsupported_Error when
    --  the 31 window numbers are used, and Create_Sub_Window raises
    --  Constraint_Error for a Parent that is not a live window.
    function Create_Window
           (Title : in String)
        return Valid_Window_Number;

    function Create_Sub_Window
           (Parent     : in Valid_Window_Number;
            X, Y, W, H : in Integer)
        return Valid_Window_Number;

    --  The window and the windows in it are gone at once, as Window_Exists
    --  says, but FLTK deletes them from the event loop, so that a window can
    --  be destroyed in its own display or other callback.  Raises
    --  Program_Error for a Glut_Window made by a Forge, or one with such a
    --  window in it, which goes when the Ada object is finalized.
    procedure Destroy_Window
           (Number : in Valid_Window_Number);

    procedure Post_Redisplay;

    procedure Post_Window_Redisplay
           (Number : in Valid_Window_Number);

    procedure Swap_Buffers;

    function Get_Window
        return Window_Number;

    --  Whether Number is a window that exists: made, and neither destroyed
    --  nor finalized.
    function Window_Exists
           (Number : in Window_Number)
        return Boolean;

    procedure Set_Window
           (Number : in Valid_Window_Number);




    --  Current Window Operations  --

    procedure Set_Window_Title
           (Text : in String);

    procedure Set_Icon_Title
           (Text : in String);

    procedure Position_Window
           (X, Y : in Integer);

    procedure Reshape_Window
           (W, H : in Integer);

    procedure Pop_Window;

    procedure Push_Window;

    procedure Iconify_Window;

    procedure Show_Window;

    --  Hidden from the event loop if called while a window is drawn, since
    --  FLTK would hide a window in the middle of drawing it.
    procedure Hide_Window;

    procedure Full_Screen;

    procedure Set_Cursor
           (Kind : in Cursor_Kind);

    procedure Warp_Pointer
           (X, Y : in Integer);




    --  Overlays  --

    --  Establish_Overlay and Use_Layer raise Program_Error when the current
    --  window is not shown, since FLTK's overlay needs a shown window.
    procedure Establish_Overlay;

    procedure Remove_Overlay;

    procedure Use_Layer
           (Layer : in Layer_Kind);

    procedure Post_Overlay_Redisplay;

    procedure Show_Overlay;

    procedure Hide_Overlay;




    --  Menus  --

    --  Create_Menu raises FLTK.Unsupported_Error when the 31 menu numbers are
    --  used.  A menu used as a submenu can't be destroyed or changed, which
    --  also keeps menus from holding themselves; each such call raises
    --  Program_Error.  A submenu must be a live menu other than the current
    --  one, with an entry (Constraint_Error if it is dead, Program_Error
    --  otherwise).  Change_To_* and Remove_Menu_Item raise Constraint_Error
    --  for an Item past the menu's last.  Attach_Menu raises Program_Error
    --  for an empty menu, which FLTK would pop up as an unterminated array.
    --  The subprograms that work on the current menu raise Program_Error
    --  when there is none.
    function Create_Menu
           (Func : in not null Menu_Function)
        return Valid_Menu_Number;

    procedure Destroy_Menu
           (Number : in Valid_Menu_Number);

    function Get_Menu
        return Menu_Number;

    --  Whether Number is a menu that was made and not destroyed.
    function Menu_Exists
           (Number : in Menu_Number)
        return Boolean;

    procedure Set_Menu
           (Number : in Valid_Menu_Number);

    procedure Add_Menu_Entry
           (Label : in String;
            Value : in Integer);

    procedure Add_Sub_Menu
           (Label   : in String;
            Submenu : in Valid_Menu_Number);

    procedure Change_To_Menu_Entry
           (Item  : in Positive;
            Label : in String;
            Value : in Integer);

    procedure Change_To_Sub_Menu
           (Item    : in Positive;
            Label   : in String;
            Submenu : in Valid_Menu_Number);

    procedure Remove_Menu_Item
           (Item : in Positive);

    procedure Attach_Menu
           (Button : in Menu_Button);

    procedure Detach_Menu
           (Button : in Menu_Button);




    --  Callbacks For the Current Window  --

    procedure Display_Func
           (Func : in not null Display_Function);

    procedure Reshape_Func
           (Func : in not null Reshape_Function);

    procedure Keyboard_Func
           (Func : in Keyboard_Function);

    procedure Mouse_Func
           (Func : in Mouse_Function);

    procedure Motion_Func
           (Func : in Motion_Function);

    procedure Passive_Motion_Func
           (Func : in Motion_Function);

    procedure Entry_Func
           (Func : in Entry_Function);

    procedure Visibility_Func
           (Func : in Visibility_Function);

    procedure Special_Func
           (Func : in Special_Function);

    procedure Overlay_Display_Func
           (Func : in not null Display_Function);




    --  Global Callbacks  --

    procedure Idle_Func
           (Func : in Idle_Function);

    procedure Timer_Func
           (Milliseconds : in Natural;
            Func         : in not null Timer_Function;
            Value        : in Integer);

    procedure Menu_State_Func
           (Func : in Menu_State_Function);

    procedure Menu_Status_Func
           (Func : in Menu_Status_Function);




    --  State Queries  --

    --  Window_Parent is 0 for a window whose parent is not a GLUT window.
    --  A GL query, or the buffer size, with no current window is 0.
    function Get
           (Query : in State_Query)
        return Integer;

    function Device_Get
           (Query : in Device_Query)
        return Integer;

    function Layer_Get
           (Query : in Layer_Query)
        return Integer;

    function Get_Modifiers
        return Modifier;

    function Extension_Supported
           (Name : in String)
        return Boolean;

    function Get_Proc_Address
           (Name : in String)
        return System.Address;


private


    for State_Query use
       (Return_Zero             => 0,
        Window_X                => 1,
        Window_Y                => 2,
        Window_Width            => 3,
        Window_Height           => 4,
        Window_Parent           => 5,
        Screen_Width            => 6,
        Screen_Height           => 7,
        Menu_Num_Items          => 8,
        Display_Mode_Possible   => 9,
        Init_Window_X           => 10,
        Init_Window_Y           => 11,
        Init_Window_Width       => 12,
        Init_Window_Height      => 13,
        Init_Display_Mode       => 14,
        Window_Buffer_Size      => 15,
        Version                 => 16,
        Elapsed_Time            => 17,
        Window_Doublebuffer     => 16#0C32#,
        Window_Stereo           => 16#0C33#,
        Window_Colormap_Size    => 16#0D51#,
        Window_Red_Size         => 16#0D52#,
        Window_Green_Size       => 16#0D53#,
        Window_Blue_Size        => 16#0D54#,
        Window_Alpha_Size       => 16#0D55#,
        Window_Depth_Size       => 16#0D56#,
        Window_Stencil_Size     => 16#0D57#,
        Window_Accum_Red_Size   => 16#0D58#,
        Window_Accum_Green_Size => 16#0D59#,
        Window_Accum_Blue_Size  => 16#0D5A#,
        Window_Accum_Alpha_Size => 16#0D5B#,
        Window_RGBA             => 16#1908#,
        Window_Num_Samples      => 16#80A9#);

    for Device_Query use
       (Has_Keyboard            => 600,
        Has_Mouse               => 601,
        Has_Spaceball           => 602,
        Has_Dial_And_Button_Box => 603,
        Has_Tablet              => 604,
        Num_Mouse_Buttons       => 605,
        Num_Spaceball_Buttons   => 606,
        Num_Button_Box_Buttons  => 607,
        Num_Dials               => 608,
        Num_Tablet_Buttons      => 609);

    for Layer_Query use
       (Overlay_Possible  => 800,
        Transparent_Index => 803,
        Normal_Damaged    => 804,
        Overlay_Damaged   => 805);


    pragma Inline (Init_Display_Mode);
    pragma Inline (Init_Window_Position);
    pragma Inline (Init_Window_Size);
    pragma Inline (Main_Loop);

    pragma Inline (Create_Sub_Window);
    pragma Inline (Post_Redisplay);
    pragma Inline (Post_Window_Redisplay);
    pragma Inline (Swap_Buffers);
    pragma Inline (Get_Window);
    pragma Inline (Set_Window);

    pragma Inline (Set_Window_Title);
    pragma Inline (Position_Window);
    pragma Inline (Reshape_Window);
    pragma Inline (Pop_Window);
    pragma Inline (Push_Window);
    pragma Inline (Iconify_Window);
    pragma Inline (Show_Window);
    pragma Inline (Hide_Window);
    pragma Inline (Full_Screen);
    pragma Inline (Set_Cursor);
    pragma Inline (Warp_Pointer);

    pragma Inline (Establish_Overlay);
    pragma Inline (Remove_Overlay);
    pragma Inline (Use_Layer);
    pragma Inline (Post_Overlay_Redisplay);
    pragma Inline (Show_Overlay);
    pragma Inline (Hide_Overlay);

    pragma Inline (Get_Menu);
    pragma Inline (Set_Menu);
    pragma Inline (Remove_Menu_Item);
    pragma Inline (Attach_Menu);
    pragma Inline (Detach_Menu);

    pragma Inline (Get);
    pragma Inline (Device_Get);
    pragma Inline (Layer_Get);
    pragma Inline (Get_Modifiers);
    pragma Inline (Extension_Supported);
    pragma Inline (Get_Proc_Address);


end FLTK.GLUT;


