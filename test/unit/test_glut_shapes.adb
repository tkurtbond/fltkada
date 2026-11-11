

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestGl Shapes and HaltGlutShape: GLUT's solid
--  and wire shapes, drawn in a GL window and read back at its centre,
--  each drawn without a GL error, a count out of range raising, and a
--  shape outside a GL context raising.


with

    Ada.Exceptions,
    Checks,
    FLTK.GLUT,
    FLTK.Widgets.Groups.Windows.OpenGL,
    Interfaces.C;

use

    Checks,
    FLTK;


procedure Test_GLUT_Shapes is

    package C renames Interfaces.C;
    package GL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package G renames FLTK.GLUT;

    use type C.unsigned;
    use type C.unsigned_char;

    pragma Linker_Options ("-lGL");


    --  GL's own calls.
    Color_Buffer_Bit : constant := 16#4000#;
    GL_RGB           : constant := 16#1907#;
    GL_Unsigned_Byte : constant := 16#1401#;
    GL_No_Error      : constant := 0;

    type Pixel is array (1 .. 4) of C.unsigned_char with Convention => C;

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

    procedure Read_Pixels
           (X, Y, W, H   : in     C.int;
            Format, Kind : in     C.unsigned;
            Data         :    out Pixel)
    with Import, Convention => C, External_Name => "glReadPixels";

    function Get_Error return C.unsigned
    with Import, Convention => C, External_Name => "glGetError";


    --  Waits, of 0.02 s, for a window to draw; generous, for valgrind.
    Limit : constant := 500;

    type Shape is (Solid_Cube, Wire_Cube, Sphere, Torus);

    type Centres is array (Shape) of Pixel;

    type Shapes is new GL.GL_Window with record
        Draws          : Natural := 0;
        Centre         : Centres := (others => (others => 0));
        Error          : C.unsigned := 1;
        Zero, Too_Many : Boolean := False;    --  raised at a count out of range
    end record;

    overriding procedure Draw
           (This : in out Shapes);

    --  N, hidden from the compiler, which would warn of a constant out of range.
    function Count
           (N : in Integer)
        return Integer is
    begin
        return N;
    end Count;
    pragma No_Inline (Count);

    procedure Black is
    begin
        Clear_Color (0.0, 0.0, 0.0, 1.0);
        Clear (Color_Buffer_Bit);
    end Black;

    overriding procedure Draw
           (This : in out Shapes)
    is
        procedure Read
               (Item : in Shape) is
        begin
            Flush;
            Read_Pixels (C.int (This.Pixel_W / 2), C.int (This.Pixel_H / 2),
                1, 1, GL_RGB, GL_Unsigned_Byte, This.Centre (Item));
        end Read;
    begin
        This.Draws := This.Draws + 1;
        if This.Draws > 1 then
            return;
        end if;
        Viewport (0, 0, C.int (This.Pixel_W), C.int (This.Pixel_H));
        Black;
        Color_3f (1.0, 1.0, 1.0);
        G.Solid_Cube (1.0);
        Read (Solid_Cube);
        Black;
        G.Wire_Cube (1.0);
        Read (Wire_Cube);
        G.Solid_Sphere (0.5, 8, 8);
        Read (Sphere);
        Black;
        G.Solid_Torus (0.1, 0.5, 8, 8);
        Read (Torus);
        G.Solid_Cone (0.5, 0.5, 8, 1);
        G.Wire_Cone (0.5, 0.5, 1, 1);
        G.Wire_Sphere (0.5, 1, 1);
        G.Wire_Torus (0.1, 0.5, 1, 1);
        G.Solid_Teapot (0.5);
        G.Wire_Teapot (0.5);
        G.Solid_Tetrahedron;
        G.Wire_Tetrahedron;
        G.Solid_Octahedron;
        G.Wire_Octahedron;
        G.Solid_Dodecahedron;
        G.Wire_Dodecahedron;
        G.Solid_Icosahedron;
        G.Wire_Icosahedron;
        This.Error := Get_Error;
        begin
            G.Solid_Sphere (1.0, Count (0), 8);
        exception
        when Constraint_Error =>
            This.Zero := True;
        end;
        begin
            G.Wire_Torus (0.1, 0.5, 8, Count (G.Shape_Count'Last + 1));
        exception
        when Constraint_Error =>
            This.Too_Many := True;
        end;
    end Draw;

    function Is_RGB
           (P       : in Pixel;
            R, G, B : in C.unsigned_char)
        return Boolean is
    begin
        return P (1) = R and P (2) = G and P (3) = B;
    end Is_RGB;

    procedure Cube is
    begin
        G.Solid_Cube (1.0);
    end Cube;

    Ignore : Long_Float;

begin

    Raises (Cube'Access, Program_Error'Identity, "a shape outside a GL context raises");

    declare
        Window : Shapes := (GL.Forge.Create (64, 64) with others => <>);
    begin
        Window.Show;
        for K in 1 .. Limit loop
            exit when Window.Draws > 0;
            Ignore := Wait (0.02);
        end loop;
        Check (Window.Draws > 0, "the window draws");
        Check (Is_RGB (Window.Centre (Solid_Cube), 255, 255, 255), "a solid cube");
        Check (Is_RGB (Window.Centre (Wire_Cube), 0, 0, 0), "a wire cube is only edges");
        Check (Is_RGB (Window.Centre (Sphere), 255, 255, 255), "a sphere");
        Check (Is_RGB (Window.Centre (Torus), 0, 0, 0), "a torus has a hole");
        Check (Window.Error = GL_No_Error, "GLUT's shapes, without an error");
        Check (Window.Zero, "a count of 0 raises (pofltk's HaltGlutShape)");
        Check (Window.Too_Many, "a count past Shape_Count'Last raises");
        Window.Hide;
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GLUT_Shapes;
