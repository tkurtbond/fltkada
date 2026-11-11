

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestGlu and HaltGluClosed: GLU's view matrices,
--  read back from GL, and its quadrics, drawn in a GL window and read back
--  pixel by pixel; a closed quadric raising; and GLU called outside a GL
--  context doing nothing.  (pofltk's HaltGluPickMatrix, a viewport shorter
--  than four, can't happen here: a Viewport_Area is a record.)


with

    Ada.Exceptions,
    Checks,
    FLTK.GLU,
    FLTK.Widgets.Groups.Windows.OpenGL,
    Interfaces.C;

use

    Checks,
    FLTK;


procedure Test_GLU is

    package C renames Interfaces.C;
    package GL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package U renames FLTK.GLU;

    use type C.unsigned;
    use type C.unsigned_char;
    use type C.C_float;
    use type C.int;

    pragma Linker_Options ("-lGL");


    --  GL's own calls.
    Color_Buffer_Bit     : constant := 16#4000#;
    GL_RGB               : constant := 16#1907#;
    GL_Unsigned_Byte     : constant := 16#1401#;
    GL_No_Error          : constant := 0;
    GL_Modelview         : constant := 16#1700#;
    GL_Projection        : constant := 16#1701#;
    GL_Viewport          : constant := 16#0BA2#;
    GL_Modelview_Matrix  : constant := 16#0BA6#;
    GL_Projection_Matrix : constant := 16#0BA7#;

    type Pixel is array (1 .. 4) of C.unsigned_char with Convention => C;
    type Matrix is array (0 .. 15) of C.C_float with Convention => C;
    type Area is array (0 .. 3) of C.int with Convention => C;

    procedure Clear_Color (R, G, B, A : in C.C_float)
    with Import, Convention => C, External_Name => "glClearColor";

    procedure Clear (Mask : in C.unsigned)
    with Import, Convention => C, External_Name => "glClear";

    procedure Color_3f (R, G, B : in C.C_float)
    with Import, Convention => C, External_Name => "glColor3f";

    procedure Flush
    with Import, Convention => C, External_Name => "glFlush";

    procedure Viewport (X, Y, W, H : in C.int)
    with Import, Convention => C, External_Name => "glViewport";

    procedure Matrix_Mode (Mode : in C.unsigned)
    with Import, Convention => C, External_Name => "glMatrixMode";

    procedure Load_Identity
    with Import, Convention => C, External_Name => "glLoadIdentity";

    procedure Get_Float
           (Name : in     C.unsigned;
            Data :    out Matrix)
    with Import, Convention => C, External_Name => "glGetFloatv";

    procedure Get_Integer
           (Name : in     C.unsigned;
            Data :    out Area)
    with Import, Convention => C, External_Name => "glGetIntegerv";

    procedure Read_Pixels
           (X, Y, W, H   : in     C.int;
            Format, Kind : in     C.unsigned;
            Data         :    out Pixel)
    with Import, Convention => C, External_Name => "glReadPixels";

    function Get_Error return C.unsigned
    with Import, Convention => C, External_Name => "glGetError";


    --  Waits, of 0.02 s, for a window to draw; generous, for valgrind.
    Limit : constant := 500;

    --  A window whose first draw makes the checks.
    type View is new GL.GL_Window with record
        Draws : Natural := 0;
    end record;

    overriding procedure Draw
           (This : in out View);


    function Near
           (A : in C.C_float;
            B : in Long_Float)
        return Boolean is
    begin
        return abs (Long_Float (A) - B) < 0.0001;
    end Near;


    --  Whether the pixel at X, Y, of the window's pixels from the bottom
    --  left, is grey G.
    function Grey
           (X, Y : in Integer;
            G    : in C.unsigned_char)
        return Boolean
    is
        P : Pixel := (others => 1);
    begin
        Flush;
        Read_Pixels (C.int (X), C.int (Y), 1, 1, GL_RGB, GL_Unsigned_Byte, P);
        return P (1) = G and P (2) = G and P (3) = G;
    end Grey;


    procedure Black is
    begin
        Clear_Color (0.0, 0.0, 0.0, 1.0);
        Clear (Color_Buffer_Bit);
    end Black;


    procedure Identity is
    begin
        Matrix_Mode (GL_Projection);
        Load_Identity;
        Matrix_Mode (GL_Modelview);
        Load_Identity;
    end Identity;


    procedure Matrices
           (This : in out View)
    is
        M  : Matrix := (others => 7.0);
        VP : Area := (others => -1);
    begin
        Matrix_Mode (GL_Projection);
        Load_Identity;
        --  90 degrees: the focal length is 1.
        U.Perspective (90.0, 1.0, 1.0, 3.0);
        Get_Float (GL_Projection_Matrix, M);
        Check (Near (M (0), 1.0) and then Near (M (5), 1.0) and then Near (M (10), -2.0)
                and then Near (M (11), -1.0) and then Near (M (14), -3.0)
                and then Near (M (15), 0.0),
            "Perspective");
        Load_Identity;
        U.Ortho_2D (0.0, 2.0, 0.0, 4.0);
        Get_Float (GL_Projection_Matrix, M);
        Check (Near (M (0), 1.0) and then Near (M (5), 0.5) and then Near (M (10), -1.0)
                and then Near (M (12), -1.0) and then Near (M (13), -1.0),
            "Ortho_2D");
        Get_Integer (GL_Viewport, VP);
        Check (Integer (VP (2)) = This.Pixel_W, "the viewport");
        Load_Identity;
        --  The right half of the view, its centre at the view's three quarters.
        U.Pick_Matrix
           (Long_Float (VP (2) * 3 / 4), Long_Float (VP (3) / 2),
            Long_Float (VP (2) / 2), Long_Float (VP (3)),
            (Integer (VP (0)), Integer (VP (1)), Integer (VP (2)), Integer (VP (3))));
        Get_Float (GL_Projection_Matrix, M);
        Check (Near (M (0), 2.0) and then Near (M (5), 1.0) and then Near (M (12), -1.0)
                and then Near (M (13), 0.0),
            "Pick_Matrix");
        Matrix_Mode (GL_Modelview);
        Load_Identity;
        U.Look_At (0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
        Get_Float (GL_Modelview_Matrix, M);
        Check (Near (M (0), 1.0) and then Near (M (5), 1.0) and then Near (M (10), 1.0)
                and then Near (M (14), -5.0),
            "Look_At, along Z");
        Load_Identity;
        U.Look_At (5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
        Get_Float (GL_Modelview_Matrix, M);
        Check (Near (M (0), 0.0) and then Near (M (8), -1.0) and then Near (M (2), 1.0)
                and then Near (M (14), -5.0),
            "Look_At, along X");
        Identity;
    end Matrices;


    procedure Quadrics
           (This : in out View)
    is
        Mid  : constant Integer := This.Pixel_W / 2;
        Low  : constant Integer := This.Pixel_W / 4;
        High : constant Integer := This.Pixel_W * 3 / 4;
        Q    : U.Quadric := U.Forge.Create;
        Raised : Boolean := False;
    begin
        Check (not Q.Is_Closed, "a quadric");
        Color_3f (1.0, 1.0, 1.0);
        Black;
        Q.Sphere (0.5, 16, 8);
        Check (Grey (Mid, Mid, 255) and then Grey (1, 1, 0), "a sphere");
        Black;
        Q.Disk (0.25, 1.0, 16, 2);
        Check (Grey (Mid, Mid, 0) and then Grey (Low, Mid, 255), "a disk, with a hole");
        Black;
        --  From Y, clockwise, through 90 degrees: the top right quarter.
        Q.Partial_Disk (0.0, 1.0, 16, 1, 0.0, 90.0);
        Check (Grey (High, High, 255) and then Grey (Low, Low, 0) and then Grey (Low, High, 0),
            "a partial disk");
        Black;
        --  Along Z, seen end on: a ring, with no ends.
        Q.Cylinder (0.5, 0.5, 0.5, 16, 1);
        Check (Grey (Mid, Mid, 0), "a cylinder has no ends");
        Black;
        Q.Cylinder (0.0, 0.9, 0.5, 16, 1);
        Check (Grey (Mid, Mid, 255), "a cone, seen from its point");
        Black;
        Q.Set_Draw_Style (U.Point);
        Q.Disk (0.0, 1.0, 4, 1);
        Check (Grey (Low, Mid + 1, 0), "points");
        Q.Set_Draw_Style (U.Line);
        Q.Sphere (0.5, 4, 4);
        Q.Set_Draw_Style (U.Silhouette);
        Q.Disk (0.0, 0.5, 4, 4);
        Q.Set_Draw_Style (U.Fill);
        Q.Set_Normals (U.No_Normals);
        Q.Sphere (0.5, 4, 4);
        Q.Set_Normals (U.Flat_Normals);
        Q.Sphere (0.5, 4, 4);
        Q.Set_Normals (U.Smooth_Normals);
        Q.Set_Orientation (U.Inside);
        Q.Sphere (0.5, 4, 4);
        Q.Set_Orientation (U.Outside);
        Q.Set_Texture (True);
        Q.Sphere (0.5, 4, 4);
        Q.Set_Texture (False);
        Check (Get_Error = GL_No_Error, "the styles, without an error");
        Q.Close;
        Check (Q.Is_Closed, "closed");
        Q.Close;
        Check (Q.Is_Closed, "closed twice");
        begin
            Q.Sphere (0.5, 4, 4);
        exception
        when Program_Error =>
            Raised := True;
        end;
        Check (Raised, "a closed quadric raises (pofltk's HaltGluClosed)");
    end Quadrics;


    overriding procedure Draw
           (This : in out View) is
    begin
        This.Draws := This.Draws + 1;
        if This.Draws > 1 then
            return;
        end if;
        Viewport (0, 0, C.int (This.Pixel_W), C.int (This.Pixel_H));
        Identity;
        Matrices (This);
        Quadrics (This);
    end Draw;


    Ignore : Long_Float;

begin

    --  Outside a GL context.
    declare
        Q : U.Quadric := U.Forge.Create;
    begin
        U.Perspective (90.0, 1.0, 1.0, 3.0);
        Q.Sphere (0.5, 4, 4);
        Check (True, "GLU outside a GL context does nothing");
    end;

    declare
        Window : View := (GL.Forge.Create (40, 40) with others => <>);
    begin
        Window.Show;
        for K in 1 .. Limit loop
            exit when Window.Draws > 0;
            Ignore := Wait (0.02);
        end loop;
        Check (Window.Draws > 0, "the window draws");
        Window.Hide;
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GLU;
