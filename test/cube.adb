


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/cube.cxx: two spinning cubes in GL windows, one wire and one
--  flat.  A timer redraws both; the sliders set how fast they spin and how
--  big they are.  "Stats / Exit", closing the window, and File/Quit print
--  the frame rate and offer to exit, go on, or reset the count.  The left
--  GL window has an FLTK button in it, which its Draw draws over the scene.
--  A grid gives the GL windows the extra room when the window grows.


with

    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Draw.OpenGL,
    FLTK.Static,
    FLTK.Widgets.Buttons.Light.Radio,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows.OpenGL,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide,
    FLTK.Widgets.Valuators.Sliders,
    GL1,
    Interfaces.C;

use

    GL1;

use type

    FLTK.Asks.Choice_Result,
    FLTK.Event_Kind,
    FLTK.Key_Combo,
    Interfaces.C.C_float,
    Interfaces.C.double,
    Interfaces.C.unsigned;


function Cube
    return Integer
is


    package Btn renames FLTK.Widgets.Buttons;
    package Rad renames FLTK.Widgets.Buttons.Light.Radio;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package SMB renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;


    FPS       : constant Long_Float := 25.0;  --  whatever the speed slider says
    Delay_For : constant Long_Float := 1.0 / FPS;
    Menubar_H : constant := 25;
    Margin    : constant := 20;               --  around the widgets
    Gap       : constant := 20;               --  between them

    Form_W : constant := 800 + 2 * Margin + 2 * Gap;
    Form_H : constant := 350 + Menubar_H + 2 * Margin;

    --  Frames drawn, from -2 so that the first two aren't timed.
    Count : Integer := -2;
    Start : FLTK.Static.Timestamp := FLTK.Static.Now;




    --  The Cube  --

    type Corner is array (1 .. 3) of GLfloat;

    Corners : constant array (0 .. 7) of Corner :=
       ((0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (1.0, 1.0, 0.0), (0.0, 1.0, 0.0),
        (0.0, 0.0, 1.0), (1.0, 0.0, 1.0), (1.0, 1.0, 1.0), (0.0, 1.0, 1.0));

    procedure Face
           (R, G, B        : in GLubyte;
            V0, V1, V2, V3 : in Natural;
            Wire           : in Boolean)
    is
        procedure V (N : in Natural) is
        begin
            glVertex3f (Corners (N) (1), Corners (N) (2), Corners (N) (3));
        end V;
    begin
        glBegin (if Wire then GL_LINE_LOOP else GL_POLYGON);
        glColor3ub (R, G, B);
        V (V0);  V (V1);  V (V2);  V (V3);
        glEnd;
    end Face;

    procedure Draw_Cube
           (Wire : in Boolean) is
    begin
        Face (0,   0,   255, 0, 1, 2, 3, Wire);
        Face (0,   255, 255, 4, 5, 6, 7, Wire);
        Face (255, 0,   255, 0, 1, 5, 4, Wire);
        Face (255, 255, 0,   2, 3, 7, 6, Wire);
        Face (0,   255, 0,   0, 4, 7, 3, Wire);
        Face (255, 0,   0,   1, 2, 6, 5, Wire);
    end Draw_Cube;


    type Cube_Box is new OGL.GL_Window with record
        Last_Time : Long_Float := 0.0;
        Size      : Long_Float := 2.0;
        Speed     : Long_Float := 2.0;
        Wire      : Boolean    := False;
    end record;

    overriding procedure Draw
           (This : in out Cube_Box);

    overriding function Handle
           (This  : in out Cube_Box;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    procedure Draw
           (This : in out Cube_Box) is
    begin
        This.Last_Time := This.Last_Time + This.Speed;
        if not This.Get_Valid then
            glLoadIdentity;
            glViewport (0, 0, GLsizei (This.Pixel_W), GLsizei (This.Pixel_H));
            glEnable (GL_DEPTH_TEST);
            glFrustum (-1.0, 1.0, -1.0, 1.0, 2.0, 10_000.0);
            glTranslatef (0.0, 0.0, -10.0);
            glClearColor (0.4, 0.4, 0.4, 0.0);
        end if;
        glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        glPushMatrix;
        glRotatef (GLfloat (This.Last_Time * 1.6), 0.0, 0.0, 1.0);
        glRotatef (GLfloat (This.Last_Time * 4.2), 1.0, 0.0, 0.0);
        glRotatef (GLfloat (This.Last_Time * 2.3), 0.0, 1.0, 0.0);
        glTranslatef (-1.0, 1.2, -1.5);
        glScalef (GLfloat (This.Size), GLfloat (This.Size), GLfloat (This.Size));
        Draw_Cube (This.Wire);
        glPopMatrix;
        FLTK.Draw.OpenGL.Set_Color (FLTK.Background_Color);  --  FL_GRAY
        glDisable (GL_DEPTH_TEST);
        FLTK.Draw.OpenGL.Set_Font (FLTK.Helvetica_Bold, 16);
        FLTK.Draw.OpenGL.Draw_Text
           (-4.5, -4.5, (if This.Wire then "Cube: wire" else "Cube: flat"));
        glEnable (GL_DEPTH_TEST);
        --  The FLTK widgets in the window, over the scene.
        OGL.GL_Window (This).Draw;
    end Draw;

    function Handle
           (This  : in out Cube_Box;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        case Event is
            when FLTK.Enter => This.Set_Cursor (FLTK.Crosshair_Mouse);
            when FLTK.Leave => This.Set_Cursor (FLTK.Default_Mouse);
            when others     => null;
        end case;
        return OGL.GL_Window (This).Handle (Event);
    end Handle;

    function Create_Cube
           (Parent : in out Grd.Grid)
        return Cube_Box is
    begin
        return This : Cube_Box :=
           (OGL.Forge.Create (Parent, 0, 0, 350, 350) with others => <>)
        do
            This.Set_Box (FLTK.Down_Frame);
        end return;
    end Create_Cube;




    --  The Form  --

    Form : Win.Window := Win.Forge.Create (Form_W, Form_H, "Cube Demo");

    Menubar : SMB.System_Menu_Bar :=
        SMB.Forge.Create (Form, 0, 0, Form_W, Menubar_H);

    Grid : Grd.Grid := Grd.Forge.Create (Form, 0, Menubar_H, Form_W, 350 + 2 * Margin);

    Left_Cube  : Cube_Box := Create_Cube (Grid);
    Wire       : Rad.Radio_Light_Button := Rad.Forge.Create (Grid, 0, 0, 100, 25, "Wire");
    Flat       : Rad.Radio_Light_Button := Rad.Forge.Create (Grid, 0, 0, 100, 25, "Flat");
    Speed      : Sld.Slider :=
        Sld.Forge.Create (Grid, Sld.Vertical_Slider, 0, 0, 40, 90, "Speed");
    Size       : Sld.Slider :=
        Sld.Forge.Create (Grid, Sld.Vertical_Slider, 0, 0, 40, 90, "Size");
    Exit_Button : Btn.Button := Btn.Forge.Create (Grid, 0, 0, 100, 25, "Stats / E&xit");
    Right_Cube : Cube_Box := Create_Cube (Grid);

    --  On the left GL window, which draws it over the scene.
    Info : Btn.Button := Btn.Forge.Create (Left_Cube, 10, 10, 120, 30, "FLTK over GL");




    --  Callbacks  --

    --  V, as C's "%Width.Placesf" writes it.
    function Fixed
           (V             : in Long_Float;
            Width, Places : in Natural)
        return String
    is
        package LF_IO is new Ada.Text_IO.Float_IO (Long_Float);
        Buffer : String (1 .. 40);
    begin
        LF_IO.Put (Buffer, V, Aft => Places, Exp => 0);
        declare
            Text : constant String := Ada.Strings.Fixed.Trim (Buffer, Ada.Strings.Left);
        begin
            return (1 .. Width - Text'Length => ' ') & Text;
        end;
    end Fixed;

    function Padded
           (N     : in Integer;
            Width : in Natural)
        return String
    is
        Text : constant String := Ada.Strings.Fixed.Trim (N'Image, Ada.Strings.Left);
    begin
        return (1 .. Width - Text'Length => ' ') & Text;
    end Padded;

    procedure Stats is
        Runtime : constant Long_Float := FLTK.Static.Seconds_Since (Start);
        Line : constant String :=
            "Count =" & Padded (Count, 5) &
            ", time = " & Fixed (Runtime, 7, 3) &
            " sec, fps = " & Fixed (Long_Float (Count) / Runtime, 5, 2) &
            ", requested: " & Fixed (FPS, 5, 2);
    begin
        Ada.Text_IO.Put_Line (Line);
        Ada.Text_IO.Flush;
        case FLTK.Asks.Choice (Line, "E&xit", "&Continue", "&Reset") is
            when FLTK.Asks.First =>
                FLTK.Static.Hide_All_Windows;
            when FLTK.Asks.Third =>
                Count := -2;
                Ada.Text_IO.Put_Line ("*** RESET ***");
                Ada.Text_IO.Flush;
            when FLTK.Asks.Second =>
                null;
        end case;
    end Stats;

    procedure Exit_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Stats;
    end Exit_CB;

    procedure Show_Info
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        FLTK.Asks.Message_Box
           ("This is an example of using FLTK widgets inside OpenGL windows." &
            ASCII.LF &
            "Multiple widgets can be added to Fl_Gl_Windows. They will be" &
            ASCII.LF &
            "rendered as overlays over the scene.");
    end Show_Info;

    procedure Tick is
    begin
        Count := Count + 1;
        if Count = 0 then
            Start := FLTK.Static.Now;
        end if;
        Left_Cube.Redraw;
        Right_Cube.Redraw;
        FLTK.Static.Repeat_Timeout (Delay_For, Tick'Unrestricted_Access);
    end Tick;

    procedure Speed_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Left_Cube.Speed  := Sld.Slider (Item).Get_Value;
        Right_Cube.Speed := Left_Cube.Speed;
    end Speed_CB;

    procedure Size_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Left_Cube.Size  := Sld.Slider (Item).Get_Value;
        Right_Cube.Size := Left_Cube.Size;
    end Size_CB;

    procedure Flat_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Left_Cube.Wire  := not Btn.Button'Class (Item).Is_On;
        Right_Cube.Wire := Btn.Button'Class (Item).Is_On;
    end Flat_CB;

    procedure Wire_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Left_Cube.Wire  := Btn.Button'Class (Item).Is_On;
        Right_Cube.Wire := not Btn.Button'Class (Item).Is_On;
    end Wire_CB;

    procedure Print_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Printer : Prn.Printer := Prn.Forge.Create;
    begin
        Printer.Start_Job (1);
        Printer.Start_Page;
        Printer.Scale (0.5, 0.5);
        Printer.Print_Widget (Form);
        Printer.End_Page;
        Printer.End_Job;
    exception
        --  Cancelled, or no printer.
        when Prn.User_Cancel_Error | FLTK.Devices.Surface.Paged.Page_Error => null;
    end Print_CB;


begin


    FLTK.Static.Set_Use_High_Res_GL (True);
    FLTK.Static.Set_Color (FLTK.Free_Color, 255, 255, 0, 75);

    Form.Set_Callback (Exit_CB'Unrestricted_Access);
    Menubar.Add ("File/Print window", Print_CB'Unrestricted_Access, FLTK.Mod_Command + 'p');
    Menubar.Add ("File/Quit",         Exit_CB'Unrestricted_Access,  FLTK.Mod_Command + 'q');

    Grid.Set_Layout (4, 4, Margin, Gap);
    Grid.Set_Box (FLTK.Flat_Box);
    --  The GL windows' columns take the extra width, the sliders' row the
    --  extra height.
    Grid.Set_Column_Weight ((50, 0, 0, 50));
    Grid.Set_Row_Weight ((0, 0, 50, 0));
    Grid.Set_Row_Gap (1, 0);   --  none below the wire button
    Grid.Set_Row_Gap (3, 50);  --  room for the sliders' labels

    Exit_Button.Set_Callback (Exit_CB'Unrestricted_Access);
    Exit_Button.Set_Tooltip
        ("Display statistics (fps) and" & ASCII.LF & "choose to exit or continue" & ASCII.LF);

    Grid.Set_Widget (Left_Cube,   1, 1, 4, 1);
    Grid.Set_Widget (Wire,        1, 2, 1, 2);
    Grid.Set_Widget (Flat,        2, 2, 1, 2);
    Grid.Set_Widget (Speed,       3, 2, 1, 1, Grd.Grid_Vertical);
    Grid.Set_Widget (Size,        3, 3, 1, 1, Grd.Grid_Vertical);
    Grid.Set_Widget (Exit_Button, 4, 2, 1, 2);
    Grid.Set_Widget (Right_Cube,  1, 4, 4, 1);

    Info.Set_Background_Color (FLTK.Free_Color);
    Info.Set_Box (FLTK.Border_Box);
    Info.Set_Callback (Show_Info'Unrestricted_Access);

    Form.Set_Resizable (Grid);
    Form.Set_Size_Range (Form.Get_W, Form.Get_H);

    Speed.Set_Bounds (6.0, 0.0);
    Speed.Set_Value (2.0);
    Speed.Set_Callback (Speed_CB'Unrestricted_Access);

    Size.Set_Bounds (4.0, 0.2);
    Size.Set_Value (2.0);
    Size.Set_Callback (Size_CB'Unrestricted_Access);

    Flat.Set_State (Btn.On);
    Flat.Set_Callback (Flat_CB'Unrestricted_Access);
    Wire.Set_State (Btn.Off);
    Wire.Set_Callback (Wire_CB'Unrestricted_Access);

    Form.Show_With_Args;
    Left_Cube.Show;
    Right_Cube.Show;

    Left_Cube.Wire   := Wire.Is_On;
    Right_Cube.Wire  := not Wire.Is_On;
    Left_Cube.Size   := Size.Get_Value;
    Right_Cube.Size  := Size.Get_Value;
    Left_Cube.Speed  := Speed.Get_Value;
    Right_Cube.Speed := Speed.Get_Value;
    Left_Cube.Redraw;
    Right_Cube.Redraw;

    Form.Wait_For_Expose;
    FLTK.Static.Add_Timeout (0.1, Tick'Unrestricted_Access);
    return FLTK.Run;


end Cube;

