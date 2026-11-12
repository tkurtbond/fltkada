--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/CubeView.cxx, CubeViewUI.fl and CubeMain.cxx, FLUID's
--  tutorial program: a cube turned, moved and zoomed by rollers and
--  sliders.  The window is built as FLUID's CubeViewUI.cxx builds it.
--  Guided by pofltk's CubeView.Mod.


with

    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Groups.Windows.OpenGL,
    FLTK.Widgets.Valuators.Rollers,
    FLTK.Widgets.Valuators.Sliders.Value,
    GL1;

use

    GL1;

use type

    FLTK.Alignment,
    GL1.GLbitfield,
    GL1.GLdouble,
    GL1.GLfloat;


function Cube_View
    return Integer
is

    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package Rol renames FLTK.Widgets.Valuators.Rollers;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package VS  renames FLTK.Widgets.Valuators.Sliders.Value;


    Alpha : constant GLfloat := 0.5;

    type Vertex is array (1 .. 3) of GLfloat;

    --  A unit cube centred on the origin.
    Box_V : constant array (0 .. 7) of Vertex :=
       ((-0.5, -0.5, -0.5), (0.5, -0.5, -0.5), (0.5, 0.5, -0.5), (-0.5, 0.5, -0.5),
        (-0.5, -0.5, 0.5),  (0.5, -0.5, 0.5),  (0.5, 0.5, 0.5),  (-0.5, 0.5, 0.5));


    type View is new OGL.GL_Window with record
        Size     : Long_Float := 10.0;
        V_Angle  : Long_Float := 0.0;
        H_Angle  : Long_Float := 0.0;
        X_Shift  : Long_Float := 0.0;
        Y_Shift  : Long_Float := 0.0;
    end record;

    overriding procedure Draw
           (This : in out View);

    --  Draws a coloured cube.
    procedure Draw_Cube is

        procedure V (I : in Natural) is
        begin
            glVertex3f (Box_V (I) (1), Box_V (I) (2), Box_V (I) (3));
        end V;

        procedure Face
               (R, G, B    : in GLfloat;
                I, J, K, L : in Natural) is
        begin
            glColor4f (R, G, B, Alpha);
            V (I);  V (J);  V (K);  V (L);
        end Face;

        procedure Line
               (I, J : in Natural) is
        begin
            V (I);  V (J);
        end Line;

    begin
        glShadeModel (GL_FLAT);
        glBegin (GL_QUADS);
        Face (0.0, 0.0, 1.0, 0, 1, 2, 3);
        Face (1.0, 1.0, 0.0, 0, 4, 5, 1);
        Face (0.0, 1.0, 1.0, 2, 6, 7, 3);
        Face (1.0, 0.0, 0.0, 4, 5, 6, 7);
        Face (1.0, 0.0, 1.0, 0, 3, 7, 4);
        Face (0.0, 1.0, 0.0, 1, 5, 6, 2);
        glEnd;
        glColor3f (1.0, 1.0, 1.0);
        glBegin (GL_LINES);
        Line (0, 1);  Line (1, 2);  Line (2, 3);  Line (3, 0);
        Line (4, 5);  Line (5, 6);  Line (6, 7);  Line (7, 4);
        Line (0, 4);  Line (1, 5);  Line (2, 6);  Line (3, 7);
        glEnd;
    end Draw_Cube;

    procedure Draw
           (This : in out View) is
    begin
        if not This.Get_Valid then
            glLoadIdentity;
            glViewport (0, 0, GLsizei (This.Pixel_W), GLsizei (This.Pixel_H));
            glOrtho (-10.0, 10.0, -10.0, 10.0, -20_050.0, 10_000.0);
            glEnable (GL_BLEND);
            glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        end if;
        glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        glPushMatrix;
        glTranslatef (GLfloat (This.X_Shift), GLfloat (This.Y_Shift), 0.0);
        glRotatef (GLfloat (This.H_Angle), 0.0, 1.0, 0.0);
        glRotatef (GLfloat (This.V_Angle), 1.0, 0.0, 0.0);
        glScalef (GLfloat (This.Size), GLfloat (This.Size), GLfloat (This.Size));
        Draw_Cube;
        glPopMatrix;
    end Draw;


    Main_Window : Dbl.Double_Window := Dbl.Forge.Create (415, 405, "CubeView");
    O           : Grp.Group := Grp.Forge.Create (Main_Window, 5, 3, 374, 399);
    V_Change    : Grp.Group := Grp.Forge.Create (O, 5, 100, 37, 192);
    V_Rot       : Rol.Roller := Rol.Forge.Create (V_Change, 5, 100, 17, 186, "V Rot");
    Y_Pan       : Sld.Slider := Sld.Forge.Create (V_Change, 25, 100, 17, 186, "V Pan");
    H_Change    : Grp.Group := Grp.Forge.Create (O, 120, 362, 190, 40);
    X_Pan       : Sld.Slider := Sld.Forge.Create (H_Change, 122, 364, 186, 17, "H Pan");
    H_Rot       : Rol.Roller := Rol.Forge.Create (H_Change, 122, 383, 186, 17, "H Rotation");
    Main_View   : Grp.Group := Grp.Forge.Create (O, 46, 27, 333, 333);
    Cube        : View :=
        (OGL.Forge.Create (Main_View, 48, 29, 329, 329, "This is the cube_view") with others => <>);
    Zoom        : VS.Value_Slider := VS.Forge.Create (O, 106, 3, 227, 19, "Zoom");


    procedure V_Rot_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Cube.V_Angle := Rol.Roller (Item).Get_Value;
        Cube.Redraw;
    end V_Rot_CB;

    procedure Y_Pan_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Cube.Y_Shift := Sld.Slider (Item).Get_Value;
        Cube.Redraw;
    end Y_Pan_CB;

    procedure X_Pan_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Cube.X_Shift := Sld.Slider (Item).Get_Value;
        Cube.Redraw;
    end X_Pan_CB;

    procedure H_Rot_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Cube.H_Angle := Rol.Roller (Item).Get_Value;
        Cube.Redraw;
    end H_Rot_CB;

    procedure Zoom_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Cube.Size := VS.Value_Slider (Item).Get_Value;
        Cube.Redraw;
    end Zoom_CB;


begin

    Main_Window.Set_Box (FLTK.Up_Box);
    Main_Window.Set_Label_Size (12);

    V_Rot.Set_Label_Kind (FLTK.No_Label);
    V_Rot.Set_Label_Size (12);
    V_Rot.Set_Bounds (-180.0, 180.0);
    V_Rot.Set_Step (1);
    V_Rot.Set_Callback (V_Rot_CB'Unrestricted_Access);
    V_Rot.Set_Alignment (FLTK.Align_Wrap);

    Sld.Extra.Set_Kind (Y_Pan, Sld.Vertical_Nice_Slider);
    Y_Pan.Set_Selection_Color (FLTK.Dark_Blue_Color);
    Y_Pan.Set_Label_Kind (FLTK.No_Label);
    Y_Pan.Set_Label_Size (12);
    Y_Pan.Set_Bounds (-25.0, 25.0);
    Y_Pan.Set_Step (0.1);
    Y_Pan.Set_Callback (Y_Pan_CB'Unrestricted_Access);
    Y_Pan.Set_Alignment (FLTK.Align_Center);

    Sld.Extra.Set_Kind (X_Pan, Sld.Horizontal_Nice_Slider);
    X_Pan.Set_Selection_Color (FLTK.Dark_Blue_Color);
    X_Pan.Set_Label_Kind (FLTK.No_Label);
    X_Pan.Set_Label_Size (12);
    X_Pan.Set_Bounds (25.0, -25.0);
    X_Pan.Set_Step (0.1);
    X_Pan.Set_Callback (X_Pan_CB'Unrestricted_Access);
    X_Pan.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);

    H_Rot.Set_Kind (Rol.Horizontal_Roller);
    H_Rot.Set_Label_Kind (FLTK.No_Label);
    H_Rot.Set_Label_Size (12);
    H_Rot.Set_Bounds (-180.0, 180.0);
    H_Rot.Set_Step (1);
    H_Rot.Set_Callback (H_Rot_CB'Unrestricted_Access);
    H_Rot.Set_Alignment (FLTK.Align_Right);

    Main_View.Set_Box (FLTK.Down_Box);
    FLTK.Static.Set_Use_High_Res_GL (True);
    Cube.Set_Box (FLTK.No_Box);
    Cube.Set_Background_Color (FLTK.Background_Color);
    Cube.Set_Selection_Color (FLTK.Background_Color);
    Cube.Set_Label_Kind (FLTK.Normal_Label);
    Cube.Set_Label_Font (FLTK.Helvetica);
    Cube.Set_Label_Size (14);
    Cube.Set_Label_Color (FLTK.Foreground_Color);
    Cube.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);
    Cube.Set_When (FLTK.When_Release);
    Main_View.Set_Resizable (Cube);
    O.Set_Resizable (Main_View);

    Sld.Extra.Set_Kind (Sld.Slider (Zoom), Sld.Horizontal_Nice_Slider);
    Zoom.Set_Selection_Color (FLTK.Dark_Blue_Color);
    Zoom.Set_Label_Font (FLTK.Helvetica_Bold);
    Zoom.Set_Label_Size (12);
    Zoom.Set_Bounds (1.0, 50.0);
    Zoom.Set_Step (0.1);
    Zoom.Set_Value (10.0);
    Zoom.Set_Text_Font (FLTK.Helvetica_Bold);
    Zoom.Set_Callback (Zoom_CB'Unrestricted_Access);
    Zoom.Set_Alignment (FLTK.Align_Left);

    Main_Window.Set_Resizable (Main_Window);

    FLTK.Screen.Set_Visual_Mode (FLTK.Screen.Double_Buffer);
    Main_Window.Show_With_Args;
    return FLTK.Run;

end Cube_View;
