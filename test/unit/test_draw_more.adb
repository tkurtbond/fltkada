--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestDrawMore: FLTK.Draw beyond test_draw, and
--  FLTK.Draw.Offscreens.  As in test_draw, a box's Draw is captured
--  (FLTK.Probe) and its pixels checked, except for what needs a window
--  shown: Scroll on the display, the overlay and Capture_Window.
--
--  Where pofltk's check is of something FLTKAda doesn't have, it is left
--  out: a Frame of more than one line, Measure_Pixmap, the counted and
--  closed Offscreens, and the conversions into a buffer too short.  Where
--  pofltk returns FALSE, FLTKAda raises Draw_Error.


with

    Ada.Exceptions,
    Ada.Strings.Unbounded,
    Checks,
    Scroll_Areas,
    FLTK.Draw.Offscreens,
    FLTK.Images.Pixmaps,
    FLTK.Images.RGB,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Draw_More is

    package Bxs renames FLTK.Widgets.Boxes;
    package Drw renames FLTK.Draw;
    package Off renames FLTK.Draw.Offscreens;
    package Pix renames FLTK.Images.Pixmaps;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Prb.RGB;
    use type Ada.Exceptions.Exception_Id;


    Size : constant := 60;

    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);
    Black : constant Prb.RGB := Prb.To_RGB (0, 0, 0);
    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Green : constant Prb.RGB := Prb.To_RGB (0, 255, 0);
    Blue  : constant Prb.RGB := Prb.To_RGB (0, 0, 255);
    Gray  : constant Prb.RGB := Prb.To_RGB (128, 128, 128);

    --  A 2x2 image: red, green / blue, white.
    RGB_Data : constant Color_Component_Array (1 .. 12) :=
       (16#FF#, 0, 0,  0, 16#FF#, 0,
        0, 0, 16#FF#,  16#FF#, 16#FF#, 16#FF#);
    RGBA_Data : constant Color_Component_Array (1 .. 16) :=
       (16#FF#, 0, 0, 16#80#,  0, 16#FF#, 0, 16#80#,
        0, 0, 16#FF#, 16#80#,  16#FF#, 16#FF#, 16#FF#, 16#80#);
    Gray_Data : constant Color_Component_Array (1 .. 4) := (0, 16#FF#, 16#80#, 16#40#);

    --  Copies on the heap, where valgrind sees a read past either end.
    type Data_Access is access Color_Component_Array;
    Heap_RGB  : constant Data_Access := new Color_Component_Array'(RGB_Data);
    Heap_Gray : constant Data_Access := new Color_Component_Array'(Gray_Data);


    --  What the jobs and callbacks record.  They are here, not in the
    --  widgets, because FLTK calls Draw from Capture, whose parameter is in.
    type Job_Access is access procedure;
    Job : Job_Access;

    X0, Y0, DX0, DY0, X1, Y1, X2, Y2, X3 : Long_Float := -1.0;
    Scale_Was           : Float := 0.0;
    Smooth, Can_Smooth  : Boolean := False;
    Raised              : Ada.Exceptions.Exception_Id := Ada.Exceptions.Null_Id;
    Row_Calls           : Natural := 0;


    --  White all over, then the job.
    type Canvas is new Bxs.Box with null record;

    overriding procedure Draw
           (This : in out Canvas) is
    begin
        Drw.Set_Color (White_Color);
        Drw.Rect_Fill (0, 0, Size, Size);
        Job.all;
    end Draw;


    --  A symbol: all of its box, black.
    procedure Square
           (Hue : in Color);
    pragma Convention (C, Square);

    procedure Square
           (Hue : in Color)
    is
        pragma Unreferenced (Hue);
    begin
        Drw.Set_Color (Black_Color);
        Drw.Begin_Polygon;
        Drw.Vertex (-1.0, -1.0);
        Drw.Vertex (1.0, -1.0);
        Drw.Vertex (1.0, 1.0);
        Drw.Vertex (-1.0, 1.0);
        Drw.End_Polygon;
    end Square;


    --  Rows of 3 bytes a pixel, 2 wide: X red, Y green.
    procedure Rows
           (X, Y : in     Natural;
            Data :    out Color_Component_Array) is
    begin
        Row_Calls := Row_Calls + 1;
        for I in 0 .. Size_Type (Data'Length) / 3 - 1 loop
            Data (Data'First + I * 3) := Color_Component ((X + Natural (I)) * 255);
            Data (Data'First + I * 3 + 1) := Color_Component (Y * 255);
            Data (Data'First + I * 3 + 2) := 0;
        end loop;
    end Rows;

    --  Rows of 1 byte a pixel: gray X.
    procedure Gray_Rows
           (X, Y : in     Natural;
            Data :    out Color_Component_Array)
    is
        pragma Unreferenced (Y);
    begin
        for I in Data'Range loop
            Data (I) := Color_Component ((X + Natural (I - Data'First)) * 255);
        end loop;
    end Gray_Rows;


    --  The jobs.

    procedure Matrices is
    begin
        Drw.Push_Matrix;
        Drw.Load_Identity;
        Drw.Translate (10.0, 20.0);
        X0 := Drw.Transform_X (1.0, 2.0);
        Y0 := Drw.Transform_Y (1.0, 2.0);
        DX0 := Drw.Transform_DX (1.0, 2.0);
        DY0 := Drw.Transform_DY (1.0, 2.0);
        Drw.Mult_Matrix (2.0, 0.0, 0.0, 3.0, 0.0, 0.0);
        X1 := Drw.Transform_X (1.0, 2.0);
        Y1 := Drw.Transform_Y (1.0, 2.0);
        Drw.Load_Matrix (1.0, 0.0, 0.0, 1.0, 5.0, 6.0);
        X2 := Drw.Transform_X (0.0, 0.0);
        Y2 := Drw.Transform_Y (0.0, 0.0);
        --  A transformed vertex doesn't go through the matrix.
        Drw.Set_Color (Black_Color);
        Drw.Begin_Polygon;
        Drw.Transformed_Vertex (10.0, 10.0);
        Drw.Transformed_Vertex (20.0, 10.0);
        Drw.Transformed_Vertex (20.0, 20.0);
        Drw.Transformed_Vertex (10.0, 20.0);
        Drw.End_Polygon;
        Drw.Pop_Matrix;
        X3 := Drw.Transform_X (0.0, 0.0);
    end Matrices;

    procedure Scales is
    begin
        Scale_Was := Drw.Override_Scale;
        Drw.Set_Color (Black_Color);
        Drw.Rect_Fill (5, 5, 5, 5);
        Drw.Restore_Scale (Scale_Was);
    end Scales;

    procedure Shapes is
    begin
        Drw.Set_Color (Black_Color);
        Drw.Rounded_Rect_Fill (5, 5, 20, 20, 5);
        Drw.Rounded_Rect (30, 5, 20, 20, 5);
        Drw.Draw_Radio (30, 30, 12, Black_Color);
    end Shapes;

    --  Sizes no one should use: nothing to check but that they do no harm.
    procedure Odd_Shapes is
    begin
        Drw.Set_Color (Black_Color);
        Drw.Rounded_Rect (0, 0, 0, 0, 3);
        Drw.Rounded_Rect_Fill (0, 0, 3, 3, -2);
        Drw.Rounded_Rect_Fill (0, 0, -3, 3, 50);
        Drw.Draw_Radio (0, 0, 0, Black_Color);
        Drw.Draw_Radio (0, 0, -3, Black_Color);
    end Odd_Shapes;

    --  Lines 50 long, from Y 10 down: dashes 5 long and 5 apart, a dash 10
    --  and a gap 20, no pattern, the first pattern at width 3, and back to
    --  no pattern with one of Max_Dash_Gaps pairs drawn between.
    procedure Dashes is
        All_Of : Drw.Dash_Gap_Array (1 .. Drw.Max_Dash_Gaps);
    begin
        Drw.Set_Color (Black_Color);
        Drw.Set_Line_Style (Dashes => (1 => (5, 5)));
        Drw.Ecks_Why_Line (5, 10, 54);
        Drw.Set_Line_Style (Dashes => (1 => (10, 20)));
        Drw.Ecks_Why_Line (5, 20, 54);
        Drw.Set_Line_Style (Dashes => Drw.Empty_Dashes);
        Drw.Ecks_Why_Line (5, 30, 54);
        Drw.Set_Line_Style (Width => 3, Dashes => (1 => (5, 5)));
        Drw.Ecks_Why_Line (5, 40, 54);
        for I in All_Of'Range loop
            All_Of (I) := (Drw.Dash_Length (1 + (2 * I - 2) mod 127),
                Drw.Dash_Length (1 + (2 * I - 1) mod 127));
        end loop;
        Drw.Set_Line_Style (Dashes => All_Of);
        Drw.Set_Line_Style;
        Drw.Ecks_Why_Line (5, 50, 54);
    end Dashes;

    procedure Arrows is
        X : Integer := 0;
    begin
        for Kind in Drw.Arrow_Kind loop
            for Direction in Drw.Orientation_Kind loop
                Drw.Draw_Arrow (X, Drw.Arrow_Kind'Pos (Kind) * 2, 3, 3, Kind, Direction,
                    Black_Color);
            end loop;
            X := X + 3;
        end loop;
        Drw.Draw_Arrow (10, 10, 40, 40, Drw.Single_Arrow, Drw.Orient_Right, Black_Color);
    end Arrows;

    procedure Checked is
    begin
        Drw.Draw_Check (10, 10, 30, 30, Black_Color);
    end Checked;

    procedure Focused is
    begin
        Drw.Draw_Box_Focus (5, 5, 40, 40, Flat_Box, Black_Color, Red_Color);
    end Focused;

    procedure Frames is
    begin
        Drw.Frame (5, 5, 20, 20, 'A', 'A', 'A', 'A');
        Drw.Frame2 (30, 5, 20, 20, Bottom => 'A', Right => 'A', Top => 'X', Left => 'X');
    end Frames;

    procedure Symbols is
    begin
        Drw.Draw_Symbol (10, 10, 20, 20, "@tdmSquare", Red_Color);
    end Symbols;

    procedure Texts is
    begin
        Drw.Set_Font (Courier, 14);
        Drw.Set_Color (Black_Color);
        Drw.Draw_Text (20, 50, "MMM", 90);
    end Texts;

    procedure Right_To_Left is
    begin
        Drw.Set_Font (Courier, 14);
        Drw.Set_Color (Black_Color);
        Drw.Draw_Text_Right_Left (40, 30, "MMM");
    end Right_To_Left;

    --  The image jobs draw a 2x2 image at 5, 5, each way of laying it out.

    procedure Plain is
    begin
        Drw.Draw_Image (5, 5, 2, 2, RGB_Data);
    end Plain;

    procedure Mirrored is
    begin
        Drw.Draw_Image (5, 5, 2, 2, Heap_RGB.all, Flip_Horizontal => True);
    end Mirrored;

    procedure Bottom_Up is
    begin
        Drw.Draw_Image (5, 5, 2, 2, Heap_RGB.all, Flip_Vertical => True);
    end Bottom_Up;

    procedure Both_Ways is
    begin
        Drw.Draw_Image (5, 5, 2, 2, Heap_RGB.all,
            Flip_Horizontal => True, Flip_Vertical => True);
    end Both_Ways;

    procedure Mono_Mirrored is
    begin
        Drw.Draw_Image_Mono (5, 5, 2, 2, Heap_Gray.all, Flip_Horizontal => True);
    end Mono_Mirrored;

    procedure Mono_Bottom_Up is
    begin
        Drw.Draw_Image_Mono (5, 5, 2, 2, Heap_Gray.all, Flip_Vertical => True);
    end Mono_Bottom_Up;

    procedure Four_Bytes is
    begin
        Drw.Draw_Image (5, 5, 2, 2, RGBA_Data, Depth => 4);
    end Four_Bytes;

    procedure Grays is
    begin
        Drw.Draw_Image_Mono (5, 5, 2, 2, Gray_Data);
    end Grays;

    procedure Skipping is
    begin
        Drw.Draw_Image_Mono (5, 5, 2, 2, RGB_Data, Depth => 3);
    end Skipping;

    procedure No_Size is
    begin
        Raised := Ada.Exceptions.Null_Id;
        Drw.Draw_Image (0, 0, 0, 2, RGB_Data);
        Drw.Draw_Image (0, 0, 2, -1, RGB_Data);
        Drw.Draw_Image_Mono (0, 0, -2, 2, Gray_Data);
        Drw.Draw_Image (0, 0, 0, 0, RGB_Data (1 .. 0));
        Drw.Draw_Image (0, 0, 2, -1, Rows'Unrestricted_Access, 3);
        Drw.Draw_Image_Mono (0, 0, -2, 2, Gray_Rows'Unrestricted_Access, 1);
    exception
    when E : others =>
        Raised := Ada.Exceptions.Exception_Identity (E);
    end No_Size;

    procedure Too_Short is
    begin
        Raised := Ada.Exceptions.Null_Id;
        Drw.Draw_Image (5, 5, 2, 2, Heap_RGB (1 .. 11));
    exception
    when E : others =>
        Raised := Ada.Exceptions.Exception_Identity (E);
    end Too_Short;

    procedure Too_Short_Mono is
    begin
        Raised := Ada.Exceptions.Null_Id;
        Drw.Draw_Image_Mono (5, 5, 2, 2, Heap_Gray.all, Line_Size => 3);
    exception
    when E : others =>
        Raised := Ada.Exceptions.Exception_Identity (E);
    end Too_Short_Mono;

    procedure Lines is
    begin
        Drw.Draw_Image (5, 5, 2, 2, Rows'Unrestricted_Access, 3);
    end Lines;

    procedure Mono_Lines is
    begin
        Drw.Draw_Image_Mono (5, 5, 2, 2, Gray_Rows'Unrestricted_Access, 1);
    end Mono_Lines;

    procedure Pixmaps is
        use Pix;
        function "+" (S : String) return Ada.Strings.Unbounded.Unbounded_String
            renames Ada.Strings.Unbounded.To_Unbounded_String;
        Pixels : constant Pixmap_Data (1 .. 1, 1 .. 2) := (1 => "rb");
    begin
        Drw.Draw_Pixmap
           ((Width => 2, Height => 1, Colors => 2, Per_Pixel => 1),
            ((+"r", Colorful, +"#FF0000"), (+"b", Colorful, +"#0000FF")),
            Pixels, 5, 5, White_Color);
    end Pixmaps;

    Scroll_Off : aliased Off.Offscreen := Off.Forge.Create (20, 10);

    procedure Copied is
    begin
        Scroll_Off.Copy (5, 5, 10, 10, 10, 0);
    end Copied;

    procedure Scrolled is
    begin
        Drw.Scroll (5, 5, 10, 10, 2, 0, Scroll_Areas.Draw'Access);
    end Scrolled;

    procedure Unscrolled is
    begin
        Drw.Scroll (5, 5, 10, 10, 0, 0, Scroll_Areas.Draw'Access);
    end Unscrolled;

    procedure Smoothing is
    begin
        Smooth := Drw.Get_Antialias;
        Drw.Set_Antialias (False);
        Can_Smooth := Drw.Get_Antialias;
        Drw.Set_Antialias (True);
    end Smoothing;

    procedure Bare is
    begin
        null;
    end Bare;


    Window : Win.Window := Win.Forge.Create (0, 0, Size, Size, "Test_Draw_More");
    Board  : constant Canvas := (Bxs.Forge.Create (Window, 0, 0, Size, Size) with null record);


    function Run
           (This : in Job_Access)
        return Boolean is
    begin
        Job := This;
        return Prb.Capture (Board);
    end Run;

    --  The pixels not white in the capture.
    function Ink
        return Natural
    is
        N : Natural := 0;
    begin
        for Y in 0 .. Size - 1 loop
            for X in 0 .. Size - 1 loop
                if Prb.Pixel (X, Y) /= White then
                    N := N + 1;
                end if;
            end loop;
        end loop;
        return N;
    end Ink;

    --  How many separate runs of ink row Y has in the capture.
    function Runs
           (Y : in Integer)
        return Natural
    is
        N      : Natural := 0;
        Before : Boolean := False;
    begin
        for X in 0 .. Size - 1 loop
            if Prb.Pixel (X, Y) /= White then
                if not Before then
                    N := N + 1;
                end if;
                Before := True;
            else
                Before := False;
            end if;
        end loop;
        return N;
    end Runs;

    function Four
           (A, B, C, D : in Prb.RGB)
        return Boolean is
    begin
        return Prb.Pixel (5, 5) = A and Prb.Pixel (6, 5) = B and
            Prb.Pixel (5, 6) = C and Prb.Pixel (6, 6) = D;
    end Four;

    function Palette
           (Hue : in Color)
        return Prb.RGB
    is
        R, G, B : Color_Component;
    begin
        FLTK.Static.Get_Color (Hue, R, G, B);
        return Prb.To_RGB (Natural (R), Natural (G), Natural (B));
    end Palette;




    procedure Test_Shapes is
    begin
        Check (Run (Matrices'Unrestricted_Access), "capture matrices");
        Check (X0 = 11.0 and Y0 = 22.0, "Transform_X and Transform_Y after a translation");
        Check (DX0 = 1.0 and DY0 = 2.0, "Transform_DX and Transform_DY leave it out");
        Check (X1 = 12.0 and Y1 = 26.0, "Mult_Matrix goes before what was there");
        Check (X2 = 5.0 and Y2 = 6.0, "Load_Matrix replaces it");
        Check (X3 = 0.0, "Pop_Matrix takes back Load_Identity");
        Check (Prb.Pixel (15, 15) = Black and Prb.Pixel (25, 25) = White,
            "Transformed_Vertex goes round the matrix");
        Prb.Release;

        Check (Run (Scales'Unrestricted_Access), "capture an override of the scale");
        Check (Scale_Was > 0.0, "Override_Scale gives the scale");
        Check (Prb.Pixel (7, 7) = Black, "and a rectangle is drawn under it");
        Prb.Release;

        Check (Run (Shapes'Unrestricted_Access), "capture rounded rectangles and a radio");
        Check (Prb.Pixel (15, 15) = Black and Prb.Pixel (5, 5) /= Black,
            "Rounded_Rect_Fill fills all but its corners");
        Check (Prb.Pixel (40, 5) = Black and Prb.Pixel (40, 15) = White,
            "Rounded_Rect is only its line");
        Check (Prb.Pixel (36, 36) = Black and Prb.Pixel (30, 30) /= Black, "Draw_Radio");
        Prb.Release;
        Check (Run (Odd_Shapes'Unrestricted_Access), "capture shapes of no size or less");
        Prb.Release;

        Check (Run (Dashes'Unrestricted_Access), "capture dashed lines");
        Check (Runs (10) = 5, "Set_Line_Style's Dashes: its pattern");
        Check (Runs (20) = 2, "a dash and a gap");
        Check (Runs (30) = 1, "Empty_Dashes is a solid line");
        Check (Runs (40) = 5, "dashes don't grow with the width");
        Check (Runs (50) = 1, "the longest pattern, then a plain Set_Line_Style");
        Prb.Release;

        Check (Run (Arrows'Unrestricted_Access), "capture arrows of every kind and direction");
        Check (Ink > 10, "they draw");
        Prb.Release;
        Check (Run (Checked'Unrestricted_Access), "capture a check mark");
        Check (Ink > 10, "it draws");
        Prb.Release;
        Check (Run (Focused'Unrestricted_Access), "capture a box with a focus box");
        Check (Ink > 10, "Draw_Box_Focus draws its focus box");
        Check (Prb.Pixel (20, 20) = White, "and no box");
        Prb.Release;
        Check (Run (Frames'Unrestricted_Access), "capture frames");
        Check (Prb.Pixel (5, 10) = Black and Prb.Pixel (6, 10) = White, "Frame's lines");
        Check (Prb.Pixel (30, 10) = White, "Frame2's sides, in their order");
        Check (Prb.Pixel (40, 24) = Black, "Frame2's bottom");
        Prb.Release;
    end Test_Shapes;


    procedure Test_Symbols is
        procedure Add (Name : in String) is
        begin
            Drw.Add_Symbol (Name, Square'Unrestricted_Access, True);
        end Add;
        procedure Refused (Name, Label : in String) is
            procedure Try is
            begin
                Add (Name);
            end Try;
        begin
            Raises (Try'Access, Drw.Draw_Error'Identity, Label);
        end Refused;
        procedure Add_Minus is
        begin
            Add ("-a");
        end Add_Minus;
        procedure Draw_Accented is
        begin
            Drw.Draw_Symbol (0, 0, 5, 5, "@a" & Character'Val (16#C3#) & Character'Val (16#A9#),
                Black_Color);
        end Draw_Accented;
        Count : Natural := 0;
    begin
        Add ("tdmSquare");
        Check (Run (Symbols'Unrestricted_Access), "Add_Symbol, and capture it");
        Check (Prb.Pixel (20, 20) = Black, "its draw runs, in the box given");
        Check (Prb.Pixel (5, 5) = White, "and no further");
        Prb.Release;
        Refused ("", "no empty name: that is the default symbol");
        Refused ("#a", "nor # first");
        Refused ("$a", "nor $ first");
        Refused ("%a", "nor % first");
        Refused ("3a", "nor a digit first");
        Refused ("-3a", "nor - and a digit");
        Refused ("+3a", "nor + and a digit");
        Refused ("a@b", "nor an @");
        No_Raise (Add_Minus'Access, "but - alone is a name");
        Refused ("a" & Character'Val (16#C3#) & Character'Val (16#A9#), "nor a byte past ASCII");
        Raises (Draw_Accented'Access, Drw.Draw_Error'Identity, "and that isn't drawn");
        --  Last, as the table stays full.
        begin
            while Count < 200 loop
                Add ("tdm" & Character'Val (Character'Pos ('A') + Count / 26) &
                    Character'Val (Character'Pos ('A') + Count mod 26));
                Count := Count + 1;
            end loop;
        exception
        when Drw.Draw_Error =>
            null;
        end;
        Check (Count >= 55 and Count < 70, "the table holds some 60 more, then raises");
    end Test_Symbols;


    procedure Test_Text is
        DX, DY, W, H : Integer;
        Last         : Natural;
        Width        : Long_Float;
        LF           : constant Character := Character'Val (10);
        Text         : constant String := "ab" & LF & "cd";
    begin
        Drw.Set_Font (Courier, 14);
        Drw.Text_Extents ("MMM", DX, DY, W, H);
        Check (W > 0 and H > 0 and DY < 0, "Text_Extents: the ink rises from the baseline");
        Check (Run (Texts'Unrestricted_Access), "capture rotated text");
        Check (Ink > 10, "Draw_Text with an angle draws");
        Prb.Release;
        Check (Run (Right_To_Left'Unrestricted_Access), "capture text right to left");
        Check (Ink > 10, "Draw_Text_Right_Left draws");
        Prb.Release;

        declare
            To : constant String := Drw.Expand_Text (Text, 0.0, Width, Last, False);
        begin
            Check (To = "ab" and Last = 3 and Width > 0.0,
                "Expand_Text stops at a newline, and Last is it");
        end;
        declare
            To : constant String :=
                Drw.Expand_Text (Text (Last + 1 .. Text'Last), 0.0, Width, Last, False);
        begin
            Check (To = "cd" and Last = 5, "from where it is told, and Last is in Text");
        end;
        declare
            To : constant String := Drw.Expand_Text
               (Character'Val (9) & "a" & Character'Val (1), 0.0, Width, Last, False);
        begin
            Check (To = "        a^A" and Last = 3, "a tab, and a control character");
        end;
        declare
            To : constant String := Drw.Expand_Text
               ("MMM MMM MMM", Drw.Width ("MMM MMM") + 1.0, Width, Last, True);
        begin
            Check (To = "MMM MMM " or To = "MMM MMM", "wrap stops at a word that fits");
            Check (Last = 8, "and the next line starts after Last");
        end;
        declare
            To : constant String := Drw.Expand_Text ("a@@b", 0.0, Width, Last, False, True);
        begin
            Check (To = "a@b" and Last = 4, "symbols: @@ is one");
        end;
        declare
            To : constant String := Drw.Expand_Text ("a@b", 0.0, Width, Last, False, True);
        begin
            Check (To = "a" and Last = 1, "and it stops at any other @");
        end;
        declare
            To : constant String := Drw.Expand_Text ("@b", 0.0, Width, Last, False, True);
        begin
            Check (To = "" and Last = 0, "which at the start stays there");
        end;

        Check (Drw.Latin1_To_Local ("a" & Character'Val (16#E9#)) =
            "a" & Character'Val (16#E9#), "Latin1_To_Local is Latin-1");
        Check (Drw.Local_To_Latin1 ("a" & Character'Val (16#E9#)) =
            "a" & Character'Val (16#E9#), "and Local_To_Latin1");
        Check (Drw.Mac_Roman_To_Local (Character'Val (16#80#) & Character'Val (16#81#) & "z") =
            Character'Val (16#C4#) & Character'Val (16#C5#) & "z", "Mac_Roman_To_Local");
        Check (Drw.Local_To_Mac_Roman (Character'Val (16#C4#) & Character'Val (16#C5#) & "z") =
            Character'Val (16#80#) & Character'Val (16#81#) & "z", "Local_To_Mac_Roman");
    end Test_Text;


    procedure Test_Images is
    begin
        Check (Run (Plain'Unrestricted_Access) and Four (Red, Green, Blue, White), "Draw_Image");
        Prb.Release;
        Check (Run (Mirrored'Unrestricted_Access) and Four (Green, Red, White, Blue),
            "Flip_Horizontal runs right to left");
        Prb.Release;
        Check (Run (Bottom_Up'Unrestricted_Access) and Four (Blue, White, Red, Green),
            "Flip_Vertical runs bottom to top");
        Prb.Release;
        Check (Run (Both_Ways'Unrestricted_Access) and Four (White, Blue, Green, Red),
            "both at once");
        Prb.Release;
        Check (Run (Four_Bytes'Unrestricted_Access) and Four (Red, Green, Blue, White),
            "4 bytes, with its fourth ignored");
        Prb.Release;
        Check (Run (Grays'Unrestricted_Access) and
            Four (Black, White, Gray, Prb.To_RGB (64, 64, 64)), "Draw_Image_Mono");
        Prb.Release;
        Check (Run (Mono_Mirrored'Unrestricted_Access) and
            Four (White, Black, Prb.To_RGB (64, 64, 64), Gray), "and Flip_Horizontal");
        Prb.Release;
        Check (Run (Mono_Bottom_Up'Unrestricted_Access) and
            Four (Gray, Prb.To_RGB (64, 64, 64), Black, White), "and Flip_Vertical");
        Prb.Release;
        Check (Run (Skipping'Unrestricted_Access) and Four (White, Black, Black, White) and
            Ink = 2, "of a byte of each pixel");
        Prb.Release;
        Check (Run (No_Size'Unrestricted_Access) and Ink = 0 and
            Raised = Ada.Exceptions.Null_Id, "no size draws nothing, and raises nothing");
        Prb.Release;
        Check (Run (Too_Short'Unrestricted_Access) and Ink = 0 and
            Raised = Constraint_Error'Identity, "too little data raises Constraint_Error");
        Prb.Release;
        Check (Run (Too_Short_Mono'Unrestricted_Access) and Ink = 0 and
            Raised = Constraint_Error'Identity, "and with Draw_Image_Mono's Line_Size");
        Prb.Release;
        Row_Calls := 0;
        Check (Run (Lines'Unrestricted_Access) and Row_Calls = 2,
            "Draw_Image with a callback asks for each row");
        Check (Four (Black, Red, Green, Prb.To_RGB (255, 255, 0)), "and draws them");
        Prb.Release;
        Check (Run (Mono_Lines'Unrestricted_Access) and Four (Black, White, Black, White),
            "Draw_Image_Mono with a callback");
        Prb.Release;
        Check (Run (Pixmaps'Unrestricted_Access) and Prb.Pixel (5, 5) = Red and
            Prb.Pixel (6, 5) = Blue, "Draw_Pixmap");
        Prb.Release;
    end Test_Images;


    procedure Test_Offscreen is
        Inner : Off.Offscreen := Off.Forge.Create (5, 5);
    begin
        Check (Scroll_Off.Is_Valid and Scroll_Off.Get_W = 20 and Scroll_Off.Get_H = 10,
            "an Offscreen");
        Scroll_Off.Begin_Drawing;
        Drw.Set_Color (Red_Color);
        Drw.Rect_Fill (0, 0, 10, 10);
        Drw.Set_Color (Blue_Color);
        Drw.Rect_Fill (10, 0, 10, 10);
        declare
            Part_Of : constant Color_Component_Array := Drw.Read_Image (15, 5, 50, 50);
            Blue_Is : constant Prb.RGB := Palette (Blue_Color);
        begin
            Check (Part_Of'Length = 50 * 50 * 3, "Read_Image partly off a surface");
            Check (Prb.To_RGB (Natural (Part_Of (1)), Natural (Part_Of (2)),
                Natural (Part_Of (3))) = Blue_Is, "reads what is on it");
            Check (Part_Of (16) = 0 and Part_Of (17) = 0 and Part_Of (18) = 0 and
                Part_Of (5 * 50 * 3 + 1) = 0, "and zeros past it");
        end;
        declare
            None_Of : constant Color_Component_Array := Drw.Read_Image (20, 0, 5, 5);
        begin
            Check (None_Of'Length = 75 and (for all C of None_Of => C = 0),
                "and none of it, zeros");
        end;
        Scroll_Off.End_Drawing;

        Check (Run (Copied'Unrestricted_Access), "capture a copy of an Offscreen");
        Check (Prb.Pixel (10, 10) = Palette (Blue_Color), "Copy, from Source_X, Source_Y");
        Check (Prb.Pixel (16, 10) = White, "and no more than W, H");
        Prb.Release;
        Scroll_Off.Rescale;
        Check (Run (Copied'Unrestricted_Access) and Prb.Pixel (10, 10) /= White,
            "Rescale keeps the picture");
        Prb.Release;

        Scroll_Off.Begin_Drawing;
        Inner.Begin_Drawing;
        Check (Inner.Is_Drawing and Scroll_Off.Is_Drawing, "one begun inside another");
        Drw.Set_Color (Red_Color);
        Drw.Rect_Fill (0, 0, 5, 5);
        Inner.End_Drawing;
        Drw.Set_Color (Green_Color);
        Drw.Rect_Fill (0, 0, 5, 5);
        Scroll_Off.End_Drawing;
        Check (not Inner.Is_Drawing and not Scroll_Off.Is_Drawing, "and both ended");
        Check (Run (Copied'Unrestricted_Access), "capture it again");
        Check (Prb.Pixel (10, 10) = Palette (Blue_Color),
            "the outer one's drawing is its own");
        Prb.Release;
    end Test_Offscreen;


    procedure Test_Surface_Scroll is
    begin
        Scroll_Areas.Fill := True;
        Scroll_Areas.Hue := Black_Color;
        Scroll_Areas.Calls := 0;
        Check (Run (Scrolled'Unrestricted_Access), "capture a scroll");
        Check (Scroll_Areas.Calls = 1 and Scroll_Areas.Last (3) = 10 and
            Scroll_Areas.Last (4) = 10,
            "on a surface all of it is drawn");
        Check (Prb.Pixel (10, 10) = Black, "by the callback");
        Prb.Release;
        Scroll_Areas.Calls := 0;
        Check (Run (Unscrolled'Unrestricted_Access) and Scroll_Areas.Calls = 0,
            "no move, no call");
        Prb.Release;
        Check (Run (Smoothing'Unrestricted_Access), "capture the antialias setting");
        Check (Smooth or not Can_Smooth, "Set_Antialias (False) is kept, or there is none");
        Prb.Release;
        Check (Run (Bare'Unrestricted_Access) and Ink = 0,
            "and Set_Antialias (True) puts it back: nothing was drawn");
        Prb.Release;
    end Test_Surface_Scroll;


    --  Red on its left half, green on its right.
    type Halves is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Halves) is
    begin
        Drw.Set_Color (Red_Color);
        Drw.Rect_Fill (0, 0, This.Get_W / 2, This.Get_H);
        Drw.Set_Color (Green_Color);
        Drw.Rect_Fill (This.Get_W / 2, 0, This.Get_W - This.Get_W / 2, This.Get_H);
    end Draw;


    procedure Test_Shown is
        Shown : Halves := (Win.Forge.Create (0, 0, 100, 100, "Test_Draw_More") with null record);

        procedure Capture_Is_Refused (X, Y, W, H : in Integer; Label : in String) is
            procedure Try is
                Image : constant FLTK.Images.RGB.RGB_Image :=
                    Drw.Capture_Window (Shown, X, Y, W, H);
                pragma Unreferenced (Image);
            begin
                null;
            end Try;
        begin
            Raises (Try'Access, Drw.Draw_Error'Identity, Label);
        end Capture_Is_Refused;

        function Image_Pixel (Image : in FLTK.Images.RGB.RGB_Image; X, Y : in Natural)
            return Prb.RGB
        is
            D     : constant Size_Type := Size_Type (Image.Get_D);
            Place : constant Size_Type :=
                (Size_Type (Y) * Size_Type (Image.Get_W) + Size_Type (X)) * D + 1;
        begin
            return Prb.To_RGB (Natural (Image.Get_Datum (Place)),
                Natural (Image.Get_Datum (Place + 1)), Natural (Image.Get_Datum (Place + 2)));
        end Image_Pixel;
    begin
        Shown.Show;
        Shown.Wait_For_Expose;

        Drw.Set_Cursor (Wait_Mouse);
        Drw.Set_Cursor (Default_Mouse);
        declare
            OK : constant Boolean := Drw.Can_Do_Alpha_Blending;
            pragma Unreferenced (OK);
        begin
            null;
        end;

        Shown.Make_Current;
        Drw.Overlay_Rect (10, 10, 30, 30);
        Drw.Overlay_Rect (20, 20, 30, 30);
        Drw.Overlay_Clear;
        Check (True, "Overlay_Rect and Overlay_Clear, on a window made current");

        Scroll_Areas.Hue := Blue_Color;
        Scroll_Areas.Calls := 0;
        Drw.Scroll (0, 0, 100, 100, 10, 0, Scroll_Areas.Draw'Access);
        Check (Scroll_Areas.Calls >= 1 and Scroll_Areas.Last (3) <= 100,
            "Scroll calls for what it uncovers");
        Scroll_Areas.Calls := 0;
        Drw.Scroll (0, 0, 100, 100, 200, 0, Scroll_Areas.Draw'Access);
        Check (Scroll_Areas.Calls = 1 and Scroll_Areas.Last (3) = 100,
            "and for all of it past its size");
        Shown.Redraw;
        FLTK.Check;

        Drw.Set_Spot (10, 10, 50, 20, Helvetica, 14);
        Drw.Set_Status (0, 0, 10, 10);
        Drw.Reset_Spot;
        Check (True, "Set_Spot, Set_Status and Reset_Spot");

        declare
            Image : constant FLTK.Images.RGB.RGB_Image :=
                Drw.Capture_Window (Shown, 0, 0, 100, 100);
        begin
            Check (Image.Get_W = 100 and Image.Get_H = 100,
                "Capture_Window, of the size asked for");
            Check (Image_Pixel (Image, 10, 10) = Red, "of what it shows");
            Check (Image_Pixel (Image, 90, 90) = Green, "all over");
        end;
        declare
            Image : constant FLTK.Images.RGB.RGB_Image :=
                Drw.Capture_Window (Shown, 90, 90, 50, 50);
        begin
            Check (Image.Get_W = 10 and Image.Get_H = 10, "a rectangle partly outside it");
        end;
        declare
            Image : constant FLTK.Images.RGB.RGB_Image :=
                Drw.Capture_Window (Shown, -5, -6, 20, 20);
        begin
            Check (Image.Get_W = 15 and Image.Get_H = 14, "from above and left too");
        end;
        Capture_Is_Refused (100, 0, 5, 5, "right of it");
        Capture_Is_Refused (0, -5, 5, 5, "above it");
        declare
            Image : constant FLTK.Images.RGB.RGB_Image :=
                Drw.Capture_Window (Shown, 90, 90, Integer'Last, Integer'Last);
        begin
            Check (Image.Get_W = 10, "a size that overflows is cut");
        end;

        Shown.Make_Current;
        declare
            Part_Of : constant Color_Component_Array := Drw.Read_Image (90, 90, 50, 50);
        begin
            Check (Part_Of'Length = 50 * 50 * 3 and
                Prb.To_RGB (Natural (Part_Of (1)), Natural (Part_Of (2)),
                    Natural (Part_Of (3))) = Green and
                Part_Of (10 * 3 + 1) = 0, "Read_Image partly off a window");
        end;
        declare
            Part_Of : constant Color_Component_Array := Drw.Read_Image (-5, -6, 20, 20, 1);
            First   : constant Size_Type := (6 * 20 + 5) * 4 + 1;
        begin
            Check (Part_Of'Length = 20 * 20 * 4 and Part_Of (1) = 0 and
                Prb.To_RGB (Natural (Part_Of (First)), Natural (Part_Of (First + 1)),
                    Natural (Part_Of (First + 2))) = Red, "above and left too, with alpha");
        end;
        Capture_Is_Refused (0, 0, 0, 10, "no width");
        Capture_Is_Refused (0, 0, -3, 10, "a negative width");
        Capture_Is_Refused (0, 0, 10, 0, "no height");
        Shown.Hide;
        FLTK.Check;
        Capture_Is_Refused (0, 0, 10, 10, "a window hidden");
    end Test_Shown;


begin

    Test_Shapes;
    Test_Symbols;
    Test_Text;
    Test_Images;
    Test_Offscreen;
    Test_Surface_Scroll;
    Test_Shown;
    Summary;

end Test_Draw_More;
