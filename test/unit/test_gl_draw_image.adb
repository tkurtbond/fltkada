--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK.Draw.OpenGL.Draw_Image (FLTK-issues.md F40, FLTKAda-BUGS.md 28).
--  FLTK's gl_draw_image reads depths 1 and 2 as RGB, three bytes a pixel,
--  and leaves GL_UNPACK_ALIGNMENT at 4, so it reads past the end of the
--  data and draws the wrong colours.  The checks of what it drew show
--  both; valgrind shows the over-read.  The Pre that checked the data's
--  length was off in release builds.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw.OpenGL,
    FLTK.Widgets.Groups.Windows.OpenGL,
    Interfaces.C;

use

    Checks,
    FLTK;


procedure Test_GL_Draw_Image is

    package C renames Interfaces.C;
    package GD renames FLTK.Draw.OpenGL;
    package GL renames FLTK.Widgets.Groups.Windows.OpenGL;

    pragma Linker_Options ("-lGL");


    Color_Buffer_Bit : constant := 16#4000#;
    GL_RGB           : constant := 16#1907#;
    GL_Unsigned_Byte : constant := 16#1401#;

    type Pixel is array (1 .. 3) of C.unsigned_char with Convention => C;

    procedure Clear_Color (R, G, B, A : in C.C_float)
    with Import, Convention => C, External_Name => "glClearColor";

    procedure Clear (Mask : in C.unsigned)
    with Import, Convention => C, External_Name => "glClear";

    procedure Flush
    with Import, Convention => C, External_Name => "glFlush";

    procedure Pixel_Store (Name : in C.unsigned; Value : in C.int)
    with Import, Convention => C, External_Name => "glPixelStorei";

    GL_Pack_Alignment : constant := 16#0D05#;

    procedure Read_Pixels
           (X, Y, W, H   : in     C.int;
            Format, Kind : in     C.unsigned;
            Data         :    out Pixel)
    with Import, Convention => C, External_Name => "glReadPixels";


    --  Rows of the alignment image, each one colour, bottom row first.
    Rows : constant array (0 .. 3) of Pixel :=
       ((20, 100, 200), (60, 110, 160), (100, 120, 120), (140, 130, 80));

    function Aligned_Data
        return Color_Component_Array
    is
        Result : Color_Component_Array (1 .. 5 * 4 * 3);
        N      : Size_Type := 1;
    begin
        for R in Rows'Range loop
            for Col in 1 .. 5 loop
                for K in 1 .. 3 loop
                    Result (N) := Color_Component (Rows (R) (K));
                    N := N + 1;
                end loop;
            end loop;
        end loop;
        return Result;
    end Aligned_Data;

    type Seen is array (1 .. 7) of Pixel;

    type Canvas is new GL.GL_Window with record
        Draws            : Natural := 0;
        Got              : Seen := (others => (others => 0));
        Deep, Short      : Boolean := False;   --  raised for Depth 5, short data
        Line_Odd         : Boolean := False;   --  raised for a Line_Size not a multiple
        Line_Short       : Boolean := False;   --  raised for a Line_Size under W * Depth
        Empty_Ok         : Boolean := False;   --  W = 0 drew nothing, raising nothing
    end record;

    overriding procedure Draw
           (This : in out Canvas);

    overriding procedure Draw
           (This : in out Canvas)
    is
        procedure Read (X, Y : in Integer; P : out Pixel) is
        begin
            Read_Pixels (C.int (X), C.int (Y), 1, 1, GL_RGB, GL_Unsigned_Byte, P);
        end Read;
    begin
        This.Draws := This.Draws + 1;
        This.Ortho;
        Clear_Color (0.0, 0.0, 0.0, 1.0);
        Clear (Color_Buffer_Bit);
        Pixel_Store (GL_Pack_Alignment, 1);

        --  Grey, at depth 1.
        GD.Draw_Image (2, 2, 2, 1, (10, 250), Depth => 1);
        --  Grey and alpha, at depth 2.
        GD.Draw_Image (2, 6, 1, 1, (200, 255), Depth => 2);
        --  RGBA, at depth 4.
        GD.Draw_Image (2, 10, 1, 1, (1, 2, 3, 255), Depth => 4);
        --  Rows of 15 bytes, not a multiple of 4.
        GD.Draw_Image (10, 2, 5, 4, Aligned_Data);

        begin
            GD.Draw_Image (20, 20, 1, 1, (1, 2, 3, 4, 5), Depth => 5);
        exception
        when Constraint_Error =>
            This.Deep := True;
        end;
        begin
            GD.Draw_Image (20, 20, 2, 2, (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11), Depth => 3);
        exception
        when Constraint_Error =>
            This.Short := True;
        end;
        begin
            GD.Draw_Image (20, 20, 1, 2, (1 .. 8 => 0), Depth => 3, Line_Size => 4);
        exception
        when Constraint_Error =>
            This.Line_Odd := True;
        end;
        begin
            GD.Draw_Image (20, 20, 2, 2, (1 .. 12 => 0), Depth => 3, Line_Size => 3);
        exception
        when Constraint_Error =>
            This.Line_Short := True;
        end;
        GD.Draw_Image (20, 20, 0, 5, (1 .. 0 => 0));
        This.Empty_Ok := True;

        Flush;
        Read (2, 2, This.Got (1));
        Read (3, 2, This.Got (2));
        Read (2, 6, This.Got (3));
        Read (2, 10, This.Got (4));
        Read (10, 2, This.Got (5));
        Read (12, 4, This.Got (6));
        Read (14, 5, This.Got (7));
    end Draw;

    function Image
           (P : in Pixel)
        return String is
    begin
        return P (1)'Image & P (2)'Image & P (3)'Image;
    end Image;

    Limit  : constant := 500;
    Window : Canvas := (GL.Forge.Create (60, 40) with others => <>);
    Ignore : Long_Float;

begin

    Window.Show;
    for K in 1 .. Limit loop
        exit when Window.Draws > 0;
        Ignore := Wait (0.02);
    end loop;
    Check (Window.Draws > 0, "the window drew");

    Check (Window.Got (1) = (10, 10, 10) and Window.Got (2) = (250, 250, 250),
        "depth 1 is grey:" & Image (Window.Got (1)) & "," & Image (Window.Got (2)));
    Check (Window.Got (3) = (200, 200, 200),
        "depth 2 is grey and alpha:" & Image (Window.Got (3)));
    Check (Window.Got (4) = (1, 2, 3), "depth 4 is RGBA:" & Image (Window.Got (4)));
    Check (Window.Got (5) = Rows (0), "row 0 of 15-byte rows:" & Image (Window.Got (5)));
    Check (Window.Got (6) = Rows (2), "row 2 of 15-byte rows:" & Image (Window.Got (6)));
    Check (Window.Got (7) = Rows (3), "row 3 of 15-byte rows:" & Image (Window.Got (7)));

    Check (Window.Deep, "Depth 5 raises Constraint_Error");
    Check (Window.Short, "data shorter than W * H * Depth raises Constraint_Error");
    Check (Window.Line_Odd, "a Line_Size not a multiple of Depth raises Constraint_Error");
    Check (Window.Line_Short, "a Line_Size under W * Depth raises Constraint_Error");
    Check (Window.Empty_Ok, "an image with no width draws nothing");

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GL_Draw_Image;
