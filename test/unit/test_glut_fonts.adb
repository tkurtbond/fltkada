


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 13: the GLUT bitmap and stroke fonts, ported from
--  pofltk's TestGlut and its HaltGlut* programs.  Text with no width draws
--  nothing, where FLTK's gl_draw crashes (pofltk 134).  Bitmap_Character
--  moves the raster position by the character's width, where FLTK moves
--  it by its texture's, a multiple of 4 (pofltk 135), and draws any
--  Latin-1 character, where FLTK draws 128 to 159 as CP1252 (F29).  The bitmap
--  subprograms and the stroke draws raise Program_Error without a GL
--  context.  The checks that need a context are made in the window's
--  display function.


with

    Ada.Exceptions,
    Checks,
    FLTK.GLUT,
    Interfaces.C;

use

    Checks;

use type

    Interfaces.C.C_float,
    Interfaces.C.double,
    Interfaces.C.int,
    Interfaces.C.unsigned,
    Interfaces.C.unsigned_char;


procedure Test_GLUT_Fonts is

    pragma Linker_Options ("-lGL");

    package Glt renames FLTK.GLUT;

    subtype GLfloat is Interfaces.C.C_float;
    subtype GLenum is Interfaces.C.unsigned;

    Width  : constant := 200;
    Height : constant := 100;

    GL_Color_Buffer_Bit    : constant GLenum := 16#4000#;
    GL_Current_Raster_Pos  : constant GLenum := 16#0B07#;
    GL_RGB                 : constant GLenum := 16#1907#;
    GL_Unsigned_Byte       : constant GLenum := 16#1401#;
    GL_Viewport            : constant GLenum := 16#0BA2#;

    type Raster is array (1 .. 4) of GLfloat with Convention => C;
    type Pixels is array (1 .. 3 * Width * Height) of Interfaces.C.unsigned_char
        with Convention => C;

    procedure Clear_Color (R, G, B, A : in GLfloat);
    pragma Import (C, Clear_Color, "glClearColor");
    procedure Clear (Mask : in GLenum);
    pragma Import (C, Clear, "glClear");
    procedure Color (R, G, B : in GLfloat);
    pragma Import (C, Color, "glColor3f");
    procedure Load_Identity;
    pragma Import (C, Load_Identity, "glLoadIdentity");
    procedure Ortho (L, R, B, T, N, F : in Interfaces.C.double);
    pragma Import (C, Ortho, "glOrtho");
    type Place is array (1 .. 4) of Interfaces.C.int with Convention => C;
    procedure Get_Integers (Name : in GLenum; Into : out Place);
    pragma Import (C, Get_Integers, "glGetIntegerv");

    --  The window's size in pixels, which FLTK's GLUT makes the viewport,
    --  and how many pixels a unit is: 2 with FLTK_SCALING_FACTOR=2.
    View            : Place;
    Pixels_Per_Unit : Float := 1.0;
    procedure Raster_Pos (X, Y : in GLfloat);
    pragma Import (C, Raster_Pos, "glRasterPos2f");
    procedure Translate (X, Y, Z : in GLfloat);
    pragma Import (C, Translate, "glTranslatef");
    procedure Scale (X, Y, Z : in GLfloat);
    pragma Import (C, Scale, "glScalef");
    procedure Get_Floats (Name : in GLenum; Into : out Raster);
    pragma Import (C, Get_Floats, "glGetFloatv");
    procedure Flush;
    pragma Import (C, Flush, "glFlush");
    procedure Read_Pixels
           (X, Y, W, H   : in     Interfaces.C.int;
            Format, Kind : in     GLenum;
            Into         :    out Pixels);
    pragma Import (C, Read_Pixels, "glReadPixels");
    function Get_Error return GLenum;
    pragma Import (C, Get_Error, "glGetError");

    Image : Pixels;

    --  How many pixels of the area are lit.
    function Lit return Natural is
        Count : Natural := 0;
    begin
        Flush;
        Read_Pixels (0, 0, Width, Height, GL_RGB, GL_Unsigned_Byte, Image);
        for I in 0 .. Width * Height - 1 loop
            if Image (3 * I + 1) > 100 then
                Count := Count + 1;
            end if;
        end loop;
        return Count;
    end Lit;

    function Raster_X return Float is
        Place : Raster;
    begin
        Get_Floats (GL_Current_Raster_Pos, Place);
        return Float (Place (1));
    end Raster_X;

    --  Clears the area, puts the raster position at 40, 50, and the
    --  modelview there, scaled for the stroke fonts.
    procedure Blank is
    begin
        Clear_Color (0.0, 0.0, 0.0, 1.0);
        Clear (GL_Color_Buffer_Bit);
        Color (1.0, 1.0, 1.0);
        Load_Identity;
        Ortho (0.0, Interfaces.C.double (View (3)), 0.0, Interfaces.C.double (View (4)), -1.0, 1.0);
        Raster_Pos (40.0, 50.0);
        Translate (40.0, 50.0, 0.0);
        Scale (0.25, 0.25, 1.0);
    end Blank;

    function Near
           (A, B  : in Float;
            Slack : in Float := 0.51)
        return Boolean is (abs (A - B) <= Slack);

    function Image_Of
           (X : in Float)
        return String is (Float'Image (X));

    --  Raster positions are in pixels, and FLTK's widths in units.
    function Units
           (Pixels : in Float)
        return Float is (Pixels / Pixels_Per_Unit);

    LF        : constant Character := Character'Val (10);
    NUL       : constant Character := Character'Val (0);
    E_Acute   : constant Character := Character'Val (16#E9#);
    C1_Control : constant Character := Character'Val (16#80#);
    Zero_Wide : constant String :=
        Character'Val (16#E2#) & Character'Val (16#80#) & Character'Val (16#8B#);

    Displays : Natural := 0;
    type String_Access is access String;
    Raised   : String_Access := null;

    procedure Bitmaps is
        F : constant Glt.Bitmap_Font := Glt.Times_Roman_24;
        One : Natural;
        X0, X1, X2, X3 : Float;
    begin
        for Font in Glt.Bitmap_Font loop
            Blank;
            Check (Glt.Bitmap_Height (Font) > 0, Font'Image & ": a height");
            Check (Glt.Bitmap_Width (Font, 'A') > 0, Font'Image & ": a character's width");
            Check (Glt.Bitmap_Length (Font, "AB") > Glt.Bitmap_Width (Font, 'A'),
                Font'Image & ": a string's length");
            Check (Glt.Bitmap_Length (Font, "") = 0, Font'Image & ": an empty string's");
            Glt.Bitmap_String (Font, "AB");
            Check (Lit > 0, Font'Image & ": Bitmap_String draws");
        end loop;
        Check (Glt.Bitmap_Height (F) > Glt.Bitmap_Height (Glt.Times_Roman_10), "its sizes differ");

        Blank;
        Glt.Bitmap_Character (F, 'A');
        One := Lit;
        Check (One > 0, "Bitmap_Character draws");
        Glt.Bitmap_Character (F, 'A');
        Check (Lit > One, "and moves on");

        --  pofltk 135: by the character's width, not its texture's.
        Blank;
        X0 := Raster_X;
        Glt.Bitmap_Character (F, 'A');
        X1 := Raster_X;
        Glt.Bitmap_Character (F, 'A');
        X2 := Raster_X;
        Check (Near (Units (X1 - X0), Float (Glt.Bitmap_Width (F, 'A'))),
            "Bitmap_Character moves by the character's width (pofltk 135):" &
            Image_Of (Units (X1 - X0)) & " for" & Natural'Image (Glt.Bitmap_Width (F, 'A')));
        Check (Near (Units (X2 - X0), Float (Glt.Bitmap_Length (F, "AA")), 1.01),
            "two of them as far as their string's length:" & Image_Of (Units (X2 - X0)) & " for" &
            Natural'Image (Glt.Bitmap_Length (F, "AA")));
        Blank;
        Glt.Bitmap_String (F, "AA");
        X3 := Raster_X;
        Check (Near (X3 - 40.0, X2 - X0, 0.01),
            "and as far as Bitmap_String of it:" & Image_Of (X3 - 40.0) & " and" &
            Image_Of (X2 - X0));
        Blank;
        Glt.Bitmap_String (F, "Hello, world");
        X3 := Raster_X;
        Check (Near (Units (X3 - 40.0), Float (Glt.Bitmap_Length (F, "Hello, world"))),
            "Bitmap_String moves by its length:" & Image_Of (Units (X3 - 40.0)) & " for" &
            Natural'Image (Glt.Bitmap_Length (F, "Hello, world")));

        --  pofltk 135: a Latin-1 character is drawn whole.
        Blank;
        Glt.Bitmap_Character (F, E_Acute);
        X1 := Raster_X;
        Check (Lit > 0, "Bitmap_Character draws a Latin-1 e acute (pofltk 135)");
        Check (Glt.Bitmap_Width (F, E_Acute) > 0
                and Near (Units (X1 - 40.0), Float (Glt.Bitmap_Width (F, E_Acute))),
            "and moves by its width:" & Image_Of (Units (X1 - 40.0)) & " for" &
            Natural'Image (Glt.Bitmap_Width (F, E_Acute)));

        --  One byte past 127 is not UTF-8, and FLTK reads it as Latin-1, but
        --  from 128 to 159 as Windows' CP1252 (fl_utf8.cxx:685): 128 as a
        --  euro sign, where Latin-1's is a control character.
        Blank;
        Glt.Bitmap_Character (F, C1_Control);
        X1 := Raster_X;
        Check (Near (Units (X1 - 40.0), Float (Glt.Bitmap_Width (F, C1_Control))),
            "Bitmap_Character draws a Latin-1 128, not a euro sign:" &
            Image_Of (Units (X1 - 40.0)) &
            " for" & Natural'Image (Glt.Bitmap_Width (F, C1_Control)));

        --  pofltk 134: text with no width, which FLTK can't draw.
        Blank;
        X0 := Raster_X;
        Glt.Bitmap_Character (F, NUL);
        Glt.Bitmap_Character (F, LF);
        Glt.Bitmap_String (F, (1 => LF));
        Glt.Bitmap_String (F, Zero_Wide);
        Glt.Bitmap_String (F, "");
        Check (Lit = 0 and Raster_X = X0, "text with no width draws nothing (pofltk 134)");
    end Bitmaps;

    procedure Strokes is
        One : Natural;
    begin
        Blank;
        Glt.Stroke_String (Glt.Roman, "AB");
        Check (Lit > 0, "Stroke_String draws");
        Blank;
        Glt.Stroke_Character (Glt.Mono_Roman, 'A');
        One := Lit;
        Check (One > 0, "Stroke_Character draws");
        Glt.Stroke_Character (Glt.Mono_Roman, 'A');
        Check (Lit > One, "and moves on");
        Blank;
        Glt.Stroke_Character (Glt.Roman, Character'Val (16#C8#));
        Glt.Stroke_Character (Glt.Roman, NUL);
        Glt.Stroke_String (Glt.Roman, "");
        Glt.Stroke_String (Glt.Roman, NUL & Character'Val (16#C8#));
        Check (Lit = 0, "a character no stroke font has draws nothing");
        Blank;
        Glt.Stroke_String (Glt.Roman, NUL & "A");
        Check (Lit > 0, "and the text after a NUL is drawn");
        Check (Get_Error = 0, "and GL has no complaint");
    end Strokes;

    procedure Display is
    begin
        Displays := Displays + 1;
        if Displays > 1 then
            return;
        end if;
        Get_Integers (GL_Viewport, View);
        Pixels_Per_Unit := Float (View (3)) / Float (Width);
        Check (View (3) >= Width and View (4) >= Height,
            "the viewport is the window:" & View (3)'Image & View (4)'Image);
        Bitmaps;
        Strokes;
    exception
    when Occurrence : others =>
        Raised := new String'(Ada.Exceptions.Exception_Information (Occurrence));
    end Display;

    procedure Measures is
    begin
        --  These need no GL context.
        Check (Glt.Stroke_Width (Glt.Mono_Roman, 'A') > 0, "a stroke character's width");
        Check (Glt.Stroke_Width (Glt.Mono_Roman, 'A') = Glt.Stroke_Width (Glt.Mono_Roman, 'i'),
            "the same for each in Mono_Roman");
        Check (Glt.Stroke_Width (Glt.Roman, 'i') < Glt.Stroke_Width (Glt.Roman, 'W'),
            "not in Roman");
        Check (Glt.Stroke_Width (Glt.Roman, Character'Val (16#C8#)) = 0
                and Glt.Stroke_Width (Glt.Roman, NUL) = 0,
            "a character the font hasn't has no width");
        Check (Glt.Stroke_Length (Glt.Roman, "") = 0, "an empty string has no length");
        Check (Glt.Stroke_Length (Glt.Mono_Roman, "AB") = 2 * Glt.Stroke_Width (Glt.Mono_Roman, 'A')
                or Glt.Stroke_Length (Glt.Mono_Roman, "AB") =
                    2 * Glt.Stroke_Width (Glt.Mono_Roman, 'A') - 1,
            "a string's length:" & Natural'Image (Glt.Stroke_Length (Glt.Mono_Roman, "AB")));
        Check (Glt.Stroke_Length (Glt.Mono_Roman, "AB" & LF & "ABCD" & LF & "A") =
                Glt.Stroke_Length (Glt.Mono_Roman, "ABCD"),
            "is its longest line's");
        Check (Glt.Stroke_Length (Glt.Mono_Roman, "A" & NUL & "B") =
                Glt.Stroke_Length (Glt.Mono_Roman, "AB"),
            "and a NUL neither ends it nor adds");
        Check (Glt.Stroke_Height (Glt.Roman) > 100.0,
            "a stroke font's height:" & Float'Image (Glt.Stroke_Height (Glt.Roman)));
    end Measures;

    --  Outside a display function there is no GL context.
    procedure Out_Of_Order is

        procedure Char is
        begin
            Glt.Bitmap_Character (Glt.Helvetica_12, 'A');
        end Char;

        procedure Text is
        begin
            Glt.Bitmap_String (Glt.Helvetica_12, "A");
        end Text;

        procedure Width_Of is
            Ignore : constant Natural := Glt.Bitmap_Width (Glt.Helvetica_12, 'A');
        begin
            null;
        end Width_Of;

        procedure Length_Of is
            Ignore : constant Natural := Glt.Bitmap_Length (Glt.Helvetica_12, "A");
        begin
            null;
        end Length_Of;

        procedure Height_Of is
            Ignore : constant Natural := Glt.Bitmap_Height (Glt.Helvetica_12);
        begin
            null;
        end Height_Of;

        procedure Stroke_Char is
        begin
            Glt.Stroke_Character (Glt.Roman, 'A');
        end Stroke_Char;

        procedure Stroke_Text is
        begin
            Glt.Stroke_String (Glt.Roman, "A");
        end Stroke_Text;

    begin
        Raises (Char'Unrestricted_Access, Program_Error'Identity,
            "Bitmap_Character with no GL context raises Program_Error");
        Raises (Text'Unrestricted_Access, Program_Error'Identity, "and Bitmap_String");
        Raises (Width_Of'Unrestricted_Access, Program_Error'Identity, "and Bitmap_Width");
        Raises (Length_Of'Unrestricted_Access, Program_Error'Identity, "and Bitmap_Length");
        Raises (Height_Of'Unrestricted_Access, Program_Error'Identity, "and Bitmap_Height");
        Raises (Stroke_Char'Unrestricted_Access, Program_Error'Identity, "and Stroke_Character");
        Raises (Stroke_Text'Unrestricted_Access, Program_Error'Identity, "and Stroke_String");
    end Out_Of_Order;

    Window : Glt.Valid_Window_Number;

begin

    Glt.Init;
    Measures;
    Out_Of_Order;

    Glt.Init_Window_Size (Width, Height);
    Window := Glt.Create_Window ("Test_GLUT_Fonts");
    Glt.Display_Func (Display'Unrestricted_Access);
    Glt.Show_Window;
    for N in 1 .. 500 loop
        exit when Displays > 0 or else FLTK.Wait (0.02) < 0.0;
    end loop;

    Check (Displays > 0, "the display function ran");
    Check (Raised = null, "nothing raised in it: " & (if Raised = null then "" else Raised.all));

    Glt.Destroy_Window (Window);
    for N in 1 .. 5 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;
    Summary;

end Test_GLUT_Fonts;
