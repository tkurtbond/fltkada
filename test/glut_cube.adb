


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  The cube of FLTK's test/cube.cxx through GLUT, after pofltk's
--  examples/GlutCube.Mod:  a GLUT window beside FLTK's widgets.
--
--  A Glut_Window is a widget, so it sits in a window with others, and
--  GLUT's callbacks drive it:  a timer turns the cube, the left button
--  drags it, the right button is a GLUT menu, and "w" and "q" are keys.
--  The slider and the check button are FLTK's, and work on the same state.
--
--  pofltk makes the GLUT window current with MakeCurrent before it is
--  shown.  FLTKAda's Make_Current refuses a window not yet shown (pofltk
--  111), so this uses FLTK.GLUT.Set_Window, which only makes it GLUT's
--  current window until then.  And since the window is declared before
--  the program's statements run, its mode is set with Set_Mode rather than
--  FLTK.GLUT.Init_Display_Mode.


with

    FLTK.GLUT,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Windows.OpenGL.GLUT,
    FLTK.Widgets.Valuators.Sliders.Horizontal,
    GL1,
    Interfaces.C;

use

    GL1;

use type

    FLTK.GLUT.Button_State,
    FLTK.GLUT.Mouse_Button_Index,
    Interfaces.C.C_float,
    Interfaces.C.double,
    Interfaces.C.unsigned;


procedure Glut_Cube is


    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Glt renames FLTK.Widgets.Groups.Windows.OpenGL.GLUT;
    package HSl renames FLTK.Widgets.Valuators.Sliders.Horizontal;
    package Win renames FLTK.Widgets.Groups.Windows;


    Period    : constant := 40;   --  of the timer, in milliseconds
    Menu_Wire : constant := 1;
    Menu_Flat : constant := 2;
    Menu_Quit : constant := 3;

    type Corner is record
        X, Y, Z : GLfloat;
    end record;

    type Corner_Index is range 0 .. 7;

    Corners : constant array (Corner_Index) of Corner :=
       ((0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (1.0, 1.0, 0.0), (0.0, 1.0, 0.0),
        (0.0, 0.0, 1.0), (1.0, 0.0, 1.0), (1.0, 1.0, 1.0), (0.0, 1.0, 1.0));


    Form   : Win.Window := Win.Forge.Create (320, 390, "GLUT beside FLTK");
    Cube   : Glt.Glut_Window := Glt.Forge.Create (Form, 10, 10, 300, 300);
    Slider : HSl.Horizontal_Slider := HSl.Forge.Create (Form, 10, 320, 200, 25, "Speed");
    Wire   : Chk.Check_Button := Chk.Forge.Create (Form, 220, 320, 90, 25, "Wire");

    Turn, Tilt   : GLfloat := 0.0;
    Speed        : GLfloat := 2.0;
    Last_X       : Integer := 0;
    Last_Y       : Integer := 0;
    Dragging     : Boolean := False;
    Menu         : FLTK.GLUT.Valid_Menu_Number;




    --  Drawing  --

    procedure Face
           (R, G, B        : in GLubyte;
            V0, V1, V2, V3 : in Corner_Index;
            Lines          : in Boolean)
    is
        procedure V
               (I : in Corner_Index) is
        begin
            glVertex3f (Corners (I).X, Corners (I).Y, Corners (I).Z);
        end V;
    begin
        glBegin (if Lines then GL_LINE_LOOP else GL_POLYGON);
        glColor3ub (R, G, B);
        V (V0);
        V (V1);
        V (V2);
        V (V3);
        glEnd;
    end Face;

    procedure Display
    is
        Lines : constant Boolean := Wire.Is_On;
    begin
        glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        glPushMatrix;
        glRotatef (Tilt, 1.0, 0.0, 0.0);
        glRotatef (Turn, 0.0, 1.0, 0.0);
        glTranslatef (-0.5, -0.5, -0.5);
        Face (0, 0, 255, 0, 1, 2, 3, Lines);
        Face (0, 255, 255, 4, 5, 6, 7, Lines);
        Face (255, 0, 255, 0, 1, 5, 4, Lines);
        Face (255, 255, 0, 2, 3, 7, 6, Lines);
        Face (0, 255, 0, 0, 4, 7, 3, Lines);
        Face (255, 0, 0, 1, 2, 6, 5, Lines);
        glPopMatrix;
        FLTK.GLUT.Swap_Buffers;
    end Display;

    procedure Reshape
           (W, H : in Integer) is
    begin
        glViewport (0, 0, GLsizei (W), GLsizei (H));
        glLoadIdentity;
        glFrustum (-1.0, 1.0, -1.0, 1.0, 2.0, 100.0);
        glTranslatef (0.0, 0.0, -4.0);
        glClearColor (0.4, 0.4, 0.4, 0.0);
        glEnable (GL_DEPTH_TEST);
    end Reshape;




    --  GLUT Callbacks  --

    procedure Tick
           (Value : in Integer) is
    begin
        if not Dragging then
            Turn := Turn + Speed;
            FLTK.GLUT.Post_Window_Redisplay (Cube.Get_Number);
        end if;
        FLTK.GLUT.Timer_Func (Period, Tick'Unrestricted_Access, Value);
    end Tick;

    procedure Mouse
           (Button : in FLTK.GLUT.Mouse_Button_Index;
            State  : in FLTK.GLUT.Button_State;
            X, Y   : in Integer) is
    begin
        if Button = FLTK.GLUT.Left then
            Dragging := State = FLTK.GLUT.Down;
            Last_X := X;
            Last_Y := Y;
        end if;
    end Mouse;

    procedure Motion
           (X, Y : in Integer) is
    begin
        if Dragging then
            Turn := Turn + GLfloat (X - Last_X);
            Tilt := Tilt + GLfloat (Y - Last_Y);
            Last_X := X;
            Last_Y := Y;
            FLTK.GLUT.Post_Redisplay;
        end if;
    end Motion;

    procedure Set_Wire
           (On : in Boolean) is
    begin
        Wire.Set_State (if On then Btn.On else Btn.Off);
        FLTK.GLUT.Post_Window_Redisplay (Cube.Get_Number);
    end Set_Wire;

    procedure Keyboard
           (Key  : in Character;
            X, Y : in Integer)
    is
        pragma Unreferenced (X, Y);
    begin
        case Key is
            when 'w' =>
                Set_Wire (not Wire.Is_On);
            when 'q' =>
                Form.Hide;
            when others =>
                null;
        end case;
    end Keyboard;

    procedure Menu_Picked
           (Value : in Integer) is
    begin
        case Value is
            when Menu_Wire =>
                Set_Wire (True);
            when Menu_Flat =>
                Set_Wire (False);
            when Menu_Quit =>
                Form.Hide;
            when others =>
                null;
        end case;
    end Menu_Picked;




    --  FLTK Callbacks  --

    procedure Speed_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Speed := GLfloat (HSl.Horizontal_Slider (Item).Get_Value);
    end Speed_CB;

    procedure Wire_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        FLTK.GLUT.Post_Window_Redisplay (Cube.Get_Number);
    end Wire_CB;


begin

    FLTK.GLUT.Init;

    --  The window is made at its declaration, before Init_Display_Mode
    --  could give the mode it reads then (glut_compatibility.cxx:182), so
    --  the mode is set on the window instead.
    Cube.Set_Mode ((Double => True, Depth => True, others => False));
    FLTK.GLUT.Set_Window (Cube.Get_Number);
    FLTK.GLUT.Display_Func (Display'Unrestricted_Access);
    FLTK.GLUT.Reshape_Func (Reshape'Unrestricted_Access);
    FLTK.GLUT.Mouse_Func (Mouse'Unrestricted_Access);
    FLTK.GLUT.Motion_Func (Motion'Unrestricted_Access);
    FLTK.GLUT.Keyboard_Func (Keyboard'Unrestricted_Access);

    Menu := FLTK.GLUT.Create_Menu (Menu_Picked'Unrestricted_Access);
    FLTK.GLUT.Add_Menu_Entry ("Wire", Menu_Wire);
    FLTK.GLUT.Add_Menu_Entry ("Flat", Menu_Flat);
    FLTK.GLUT.Add_Menu_Entry ("Quit", Menu_Quit);
    FLTK.GLUT.Attach_Menu (FLTK.GLUT.Right);
    pragma Unreferenced (Menu);

    Slider.Set_Bounds (0.0, 10.0);
    Slider.Set_Value (Long_Float (Speed));
    Slider.Set_Callback (Speed_CB'Unrestricted_Access);
    Wire.Set_Callback (Wire_CB'Unrestricted_Access);

    Tilt := 30.0;
    Form.Set_Resizable (Cube);
    Form.Show_With_Args;
    FLTK.GLUT.Timer_Func (Period, Tick'Unrestricted_Access, 0);
    FLTK.GLUT.Main_Loop;

end Glut_Cube;


