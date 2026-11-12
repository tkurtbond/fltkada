--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.OpenGL;

use type

    FLTK.Alignment;


package body Unittests_Fast_Shapes is


    package Bx renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;

    use FLTK, FLTK.Draw, Unittests_Common;


    --  Shapes that the drawing matrix doesn't transform.
    procedure Draw_Fast_Shapes
    is
        A : constant Integer := 0;
        B : Integer := 0;
    begin
        --  1: draw a filled rectangle (fl_rectf)
        Set_Color (Green_Color);
        for I in 0 .. 40 loop
            Point (A + I, B);
            Point (A + I, B + 20);
        end loop;
        for I in 0 .. 20 loop
            Point (A, B + I);
            Point (A + 40, B + I);
        end loop;
        Set_Color (Red_Color);
        for I in 1 .. 39 loop
            Point (A + I, B + 1);
            Point (A + I, B + 19);
        end loop;
        for I in 1 .. 19 loop
            Point (A + 1, B + I);
            Point (A + 39, B + I);
        end loop;
        Set_Color (Black_Color);
        Rect_Fill (A + 1, B + 1, 39, 19);

        --  2: draw a one units wide frame
        B := B + 24;
        Set_Color (Green_Color);
        for I in 0 .. 40 loop
            Point (A + I, B);
            Point (A + I, B + 20);
        end loop;
        for I in 0 .. 20 loop
            Point (A, B + I);
            Point (A + 40, B + I);
        end loop;
        Set_Color (Green_Color);
        for I in 2 .. 38 loop
            Point (A + I, B + 2);
            Point (A + I, B + 18);
        end loop;
        for I in 2 .. 18 loop
            Point (A + 2, B + I);
            Point (A + 38, B + I);
        end loop;
        Set_Color (Red_Color);
        for I in 1 .. 39 loop
            Point (A + I, B + 1);
            Point (A + I, B + 19);
        end loop;
        for I in 1 .. 19 loop
            Point (A + 1, B + I);
            Point (A + 39, B + I);
        end loop;
        Set_Color (Black_Color);
        Rect (A + 1, B + 1, 39, 19);

        --  3: draw a three units wide frame
        B := B + 24;
        Set_Color (Green_Color);
        Rect (A, B, 41, 21);
        Rect (A + 4, B + 4, 33, 13);
        Set_Color (Red_Color);
        Rect (A + 1, B + 1, 39, 19);
        Rect (A + 3, B + 3, 35, 15);
        Set_Color (Black_Color);
        Set_Line_Style (Solid_Line, Width => 3);
        Rect (A + 2, B + 2, 37, 17);
        Set_Line_Style (Solid_Line, Width => 1);

        --  4: draw fl_xyline
        B := B + 24;
        Set_Color (Green_Color);
        Rect (A, B + 8, 41, 3);       --  single line
        Rect (A + 45, B, 41, 3);      --  horizontal, then vertical line
        Rect (A + 83, B, 3, 21);
        Rect (A + 90, B, 21, 3);      --  horizontal, vertical, horizontal line
        Rect (A + 109, B, 3, 21);
        Rect (A + 109, B + 18, 21, 3);
        Set_Color (Red_Color);
        Rect_Fill (A + 1, B + 9, 39, 1);      --  single line
        Rect_Fill (A + 46, B + 1, 39, 1);     --  two lines
        Rect_Fill (A + 84, B + 1, 1, 19);
        Rect_Fill (A + 91, B + 1, 20, 1);     --  three lines
        Rect_Fill (A + 110, B + 1, 1, 19);
        Rect_Fill (A + 110, B + 19, 19, 1);   --  three lines
        Set_Color (Black_Color);
        Ecks_Why_Line (A + 1, B + 9, A + 39);
        Ecks_Why_Line (A + 46, B + 1, A + 84, B + 19);
        Ecks_Why_Line (A + 91, B + 1, A + 110, B + 19, A + 128);
        B := B + 24;
        Set_Color (Green_Color);
        Rect (A, B + 7, 41, 5);       --  single line
        Rect (A + 45, B, 41, 5);      --  horizontal, then vertical line
        Rect (A + 81, B, 5, 21);
        Rect (A + 90, B, 22, 5);      --  horizontal, vertical, horizontal line
        Rect (A + 108, B, 5, 21);
        Rect (A + 108, B + 16, 22, 5);
        Set_Color (Red_Color);
        Rect_Fill (A + 1, B + 8, 39, 3);      --  single line
        Rect_Fill (A + 46, B + 1, 39, 3);     --  two lines
        Rect_Fill (A + 82, B + 1, 3, 19);
        Rect_Fill (A + 91, B + 1, 20, 3);     --  three lines
        Rect_Fill (A + 109, B + 1, 3, 19);
        Rect_Fill (A + 109, B + 17, 20, 3);   --  three lines
        Set_Color (Black_Color);
        Set_Line_Style (Solid_Line, Width => 3);
        Ecks_Why_Line (A + 1, B + 9, A + 39);
        Ecks_Why_Line (A + 46, B + 2, A + 83, B + 19);
        Ecks_Why_Line (A + 91, B + 2, A + 110, B + 18, A + 128);
        Set_Line_Style (Solid_Line, Width => 1);

        --  5: draw fl_yxline
        B := B + 24;
        Set_Color (Green_Color);
        Rect (A + 9, B, 3, 21);       --  single line
        Rect (A + 45, B, 3, 21);      --  horizontal, then vertical line
        Rect (A + 45, B + 18, 41, 3);
        Rect (A + 90, B, 3, 11);      --  horizontal, vertical, horizontal line
        Rect (A + 90, B + 9, 40, 3);
        Rect (A + 127, B + 9, 3, 12);
        Set_Color (Red_Color);
        Rect_Fill (A + 10, B + 1, 1, 19);     --  single line
        Rect_Fill (A + 46, B + 1, 1, 19);     --  two lines
        Rect_Fill (A + 46, B + 19, 39, 1);
        Rect_Fill (A + 91, B + 1, 1, 10);     --  three lines
        Rect_Fill (A + 91, B + 10, 38, 1);
        Rect_Fill (A + 128, B + 10, 1, 10);   --  three lines
        Set_Color (Black_Color);
        Why_Ecks_Line (A + 10, B + 1, B + 19);
        Why_Ecks_Line (A + 46, B + 1, B + 19, A + 84);
        Why_Ecks_Line (A + 91, B + 1, B + 10, A + 128, B + 19);
        B := B + 24;
        Set_Color (Green_Color);
        Rect (A + 8, B, 5, 21);       --  single line
        Rect (A + 45, B, 5, 21);      --  horizontal, then vertical line
        Rect (A + 45, B + 16, 41, 5);
        Rect (A + 90, B, 5, 11);      --  horizontal, vertical, horizontal line
        Rect (A + 90, B + 8, 40, 5);
        Rect (A + 125, B + 8, 5, 13);
        Set_Color (Red_Color);
        Rect_Fill (A + 9, B + 1, 3, 19);      --  single line
        Rect_Fill (A + 46, B + 1, 3, 19);     --  two lines
        Rect_Fill (A + 46, B + 17, 39, 3);
        Rect_Fill (A + 91, B + 1, 3, 10);     --  three lines
        Rect_Fill (A + 91, B + 9, 38, 3);
        Rect_Fill (A + 126, B + 9, 3, 11);    --  three lines
        Set_Color (Black_Color);
        Set_Line_Style (Solid_Line, Width => 3);
        Why_Ecks_Line (A + 10, B + 1, B + 19);
        Why_Ecks_Line (A + 47, B + 1, B + 18, A + 84);
        Why_Ecks_Line (A + 92, B + 1, B + 10, A + 127, B + 19);
        Set_Line_Style (Solid_Line, Width => 1);

        --  6: fast diagonal lines
        B := B + 24;
        Set_Color (Green_Color);
        Point (A, B);
        Point (A + 1, B);
        Point (A, B + 1);
        Point (A + 20, B + 20);
        Point (A + 19, B + 20);
        Point (A + 20, B + 19);
        Set_Color (Red_Color);
        Point (A + 1, B + 1);
        Point (A + 19, B + 19);
        Set_Color (Black_Color);
        Line (A + 1, B + 1, A + 19, B + 19);
        Set_Color (Green_Color);
        Point (A + 25 + 1, B);
        Point (A + 25, B + 1);
        Point (A + 25 + 4, B);
        Point (A + 25, B + 4);
        Point (A + 25 + 20, B + 19);
        Point (A + 25 + 19, B + 20);
        Point (A + 25 + 16, B + 20);
        Point (A + 25 + 20, B + 16);
        Set_Color (Red_Color);
        Point (A + 25 + 2, B + 2);
        Point (A + 25 + 18, B + 18);
        Set_Color (Black_Color);
        Set_Line_Style (Solid_Line, Width => 5);
        Line (A + 25 + 1, B + 1, A + 25 + 19, B + 19);
        Line (A + 50 + 1, B + 1, A + 50 + 20, B + 20, A + 50 + 39, B + 1);
        Set_Line_Style (Solid_Line, Width => 1);
    end Draw_Fast_Shapes;




    type GL_Rect_Test is new OGL.GL_Window with null record;

    overriding procedure Draw
           (This : in out GL_Rect_Test);

    procedure Draw
           (This : in out GL_Rect_Test) is
    begin
        This.Draw_Begin;
        Set_Color (This.Get_Background_Color);
        Rect_Fill (0, 0, This.Get_W, This.Get_H);
        Draw_Fast_Shapes;
        This.Draw_End;
    end Draw;


    type Native_Rect_Test is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Native_Rect_Test);

    procedure Draw
           (This : in out Native_Rect_Test) is
    begin
        Win.Window (This).Draw;
        Draw_Fast_Shapes;
    end Draw;




    type Group_Access is access FLTK.Widgets.Groups.Group;
    type Native_Rect_Test_Access is access Native_Rect_Test;
    type GL_Rect_Test_Access is access GL_Rect_Test;
    type Box_Access is access Bx.Box;


    function Create
        return Widget_Access
    is
        X : constant Integer := Test_Area_X;
        Y : constant Integer := Test_Area_Y;
        W : constant Integer := Test_Area_W;
        H : constant Integer := Test_Area_H;
        Page : constant Group_Access := new FLTK.Widgets.Groups.Group'
           (FLTK.Widgets.Groups.Forge.Create (X, Y, W, H));
        A : Integer := X + 16;
        B : Integer := Y + 34;
    begin
        Page.Begin_Current;
        Page.Set_Label
           ("Testing FLTK fast shape calls." & ASCII.LF &
            "These calls draw horizontal and vertical lines, frames, and rectangles." & ASCII.LF &
            ASCII.LF &
            "No red pixels should be visible. If you see bright red lines, or if parts of " &
            "the green frames are hidden, drawing alignment is off.");
        Page.Set_Alignment (Align_Inside + Align_Bottom + Align_Left + Align_Wrap);
        Page.Set_Box (Border_Box);

        Add_Heading (A, B - 24, "native");
        declare
            NR : constant Native_Rect_Test_Access := new Native_Rect_Test'
               (Win.Forge.Create (A + 23, B - 1, 200, 200) with null record);
        begin
            NR.Set_Box (Flat_Box);
            NR.End_Current;
        end;
        Add_Box (A, B, 18, "1",
           "Testing filled rectangle alignment." & ASCII.LF & ASCII.LF &
           "This draws a black rectangle, surrounded by a green frame." & ASCII.LF & ASCII.LF &
           "If green pixels are missing, filled rectangles draw too big (see fl_rectf)." &
           ASCII.LF & ASCII.LF &
           "If red pixels are showing, filled rectangles are drawn too small.");
        B := B + 24;
        Add_Box (A, B, 18, "2",
           "Testing rectangle frame alignment." & ASCII.LF & ASCII.LF &
           "This draws a black frame, surrounded on the inside and outside by a green frame." &
           ASCII.LF & ASCII.LF &
           "If green pixels are missing or red pixels are showing, rectangular frame " &
           "drawing schould be adjusted (see fl_rect)." & ASCII.LF & ASCII.LF &
           "If red pixels show in the corners of the frame in hidpi mode, line endings " &
           "should be adjusted.");
        B := B + 24;
        Add_Box (A, B, 18, "3",
           "Testing scaled frame alignment." & ASCII.LF & ASCII.LF &
           "This draws a 3 units wide black frame, surrounded on the inside and outside by " &
           "a green frame." & ASCII.LF & ASCII.LF &
           "If green pixels are missing or red pixels are showing, line width schould be " &
           "adjusted (see fl_line_style)." & ASCII.LF & ASCII.LF &
           "If red pixels show in the corners of the frame in hidpi mode, line endings " &
           "should be adjusted.");
        B := B + 24;
        Add_Box (A, B, 18, "4",
           "Testing fl_xyline." & ASCII.LF & ASCII.LF &
           "This draws 3 versions of fl_xyline surronded with a green outline." & ASCII.LF &
           ASCII.LF &
           "If green pixels are missing or red pixels are showing, fl_xyline must be adjusted.");
        B := B + 48;
        Add_Box (A, B, 18, "5",
           "Testing fl_yxline." & ASCII.LF & ASCII.LF &
           "This draws 3 versions of fl_yxline surronded with a green outline." & ASCII.LF &
           ASCII.LF &
           "If green pixels are missing or red pixels are showing, fl_yxline must be adjusted.");
        B := B + 48;
        Add_Box (A, B, 18, "6",
           "Testing fl_line(int...)." & ASCII.LF & ASCII.LF &
           "This draws 2 lines at differnet widths, and one connected line." & ASCII.LF &
           ASCII.LF &
           "Green and red pixels mark the beginning and end of single lines.The line caps " &
           "should be flat, the joints should be of type ""miter"".");

        A := X + 16 + 250;
        B := Y + 34;
        Add_Heading (A, B - 24, "OpenGL");
        --  The C++ never ends this window, so the boxes after it are its
        --  children, and as its Draw doesn't draw its children, they don't
        --  show.
        declare
            GLR : constant GL_Rect_Test_Access := new GL_Rect_Test'
               (OGL.Forge.Create (A + 31, B - 1, 200, 200) with null record);
        begin
            GLR.Set_Box (Flat_Box);
        end;
        Add_Box (A, B, 26, "1a",
           "Testing filled rectangle alignment." & ASCII.LF & ASCII.LF &
           "This draws a black rectangle, surrounded by a green frame." & ASCII.LF & ASCII.LF &
           "If green pixels are missing, filled rectangles draw too big (see fl_rectf)." &
           ASCII.LF & ASCII.LF &
           "If red pixels are showing, filled rectangles are drawn too small.");
        B := B + 24;
        Add_Box (A, B, 26, "2a",
           "Testing rectangle frame alignment." & ASCII.LF & ASCII.LF &
           "This draws a black frame, surrounded on the inside and outside by a green frame." &
           ASCII.LF & ASCII.LF &
           "If green pixels are missing or red pixels are showing, rectangular frame " &
           "drawing schould be adjusted (see fl_rect)." & ASCII.LF & ASCII.LF &
           "If red pixels show in the corners of the frame in hidpi mode, line endings " &
           "should be adjusted.");
        B := B + 24;
        Add_Box (A, B, 26, "3a",
           "Testing scaled frame alignment." & ASCII.LF & ASCII.LF &
           "This draws a 3 units wide black frame, surrounded on the inside and outside by " &
           "a green frame." & ASCII.LF & ASCII.LF &
           "If green pixels are missing or red pixels are showing, line width schould be " &
           "adjusted (see fl_line_style)." & ASCII.LF & ASCII.LF &
           "If red pixels show in the corners of the frame in hidpi mode, line endings " &
           "should be adjusted.");
        B := B + 24;
        Add_Box (A, B, 26, "4a",
           "Testing fl_xyline." & ASCII.LF & ASCII.LF &
           "This draws 3 versions of fl_xyline surronded with a green outline." & ASCII.LF &
           ASCII.LF &
           "If green pixels are missing or red pixels are showing, fl_xyline must be adjusted.");
        B := B + 48;
        Add_Box (A, B, 26, "5a",
           "Testing fl_yxline." & ASCII.LF & ASCII.LF &
           "This draws 3 versions of fl_yxline surronded with a green outline." & ASCII.LF &
           ASCII.LF &
           "If green pixels are missing or red pixels are showing, fl_yxline must be adjusted.");
        B := B + 48;
        Add_Box (A, B, 26, "6a",
           "Testing fl_line(int...)." & ASCII.LF & ASCII.LF &
           "This draws 2 lines at differnet widths, and one connected line." & ASCII.LF &
           ASCII.LF &
           "Green and red pixels mark the beginning and end of single lines.The line caps " &
           "should be flat, the joints should be of type ""miter"".");

        declare
            T : constant Box_Access := new Bx.Box'(Bx.Forge.Create (X + W - 1, Y + H - 1, 1, 1));
        begin
            Page.Set_Resizable (T.all);
        end;
        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Fast_Shapes;
