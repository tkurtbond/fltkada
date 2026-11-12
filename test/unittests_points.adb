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


package body Unittests_Points is


    package Bx renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;

    use FLTK, FLTK.Draw, Unittests_Common;


    Lut : constant array (0 .. 2) of Color := (Red_Color, Green_Color, Blue_Color);




    --  Test 3: a black frame round a white square, in a window of its own.
    type Native_Point_Test is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Native_Point_Test);

    procedure Draw
           (This : in out Native_Point_Test)
    is
        pragma Unreferenced (This);
    begin
        Set_Color (White_Color);
        Rect_Fill (0, 0, 10, 10);
        Set_Color (Black_Color);
        for I in 0 .. 9 loop
            Point (I, 0);
            Point (I, 9);
        end loop;
        for I in 0 .. 9 loop
            Point (0, I);
            Point (9, I);
        end loop;
    end Draw;




    --  Tests 1a to 4a, in an OpenGL window.
    type GL_Point_Test is new OGL.GL_Window with null record;

    overriding procedure Draw
           (This : in out GL_Point_Test);

    procedure Draw
           (This : in out GL_Point_Test)
    is
        A  : constant Integer := -24;
        B  : constant Integer := 5 - 9;
        XX : Integer;
        YY : Integer;
    begin
        This.Draw_Begin;
        This.Draw_Window;

        --  Test 1a: pixel size
        Set_Color (White_Color);
        Rect_Fill (A + 24, B + 9 - 5, 10, 10);
        Set_Color (Black_Color);
        for I in 0 .. 7 loop
            for J in 0 .. 7 loop
                if (I + J) mod 2 = 1 then
                    Point (A + I + 24 + 1, B + J + 9 - 5 + 1);
                end if;
            end loop;
        end loop;

        --  Test 2a: pixel color
        for N in 0 .. 2 loop
            YY := B + 9 - 5 + 24 + 16 * N;
            Set_Color (White_Color);
            Rect_Fill (A + 24, YY, 10, 10);
            Set_Color (Lut (N));
            for I in 0 .. 7 loop
                for J in 0 .. 7 loop
                    Point (A + I + 24 + 1, YY + J + 1);
                end loop;
            end loop;
        end loop;

        --  Test 3a: pixel alignment inside windows (the group draws the
        --  rest, outside this window)
        XX := A + 24;
        YY := B + 2 * 24 + 2 * 16 + 9 - 5;
        Set_Color (Red_Color);
        for I in 0 .. 9 loop
            Point (XX - 1, YY + I);
            Point (XX + 10, YY + I);
        end loop;
        Set_Color (Black_Color);
        for I in 0 .. 9 loop
            Point (XX + I, YY);
            Point (XX + I, YY + 9);
        end loop;
        for I in 0 .. 9 loop
            Point (XX, YY + I);
            Point (XX + 9, YY + I);
        end loop;
        Set_Color (White_Color);
        for I in 0 .. 7 loop
            for J in 0 .. 7 loop
                Point (XX + I + 1, YY + J + 1);
            end loop;
        end loop;

        --  Test 4a: check pixel clipping
        XX := A + 24;
        YY := B + 3 * 24 + 2 * 16 + 9 - 5;
        Push_Clip (XX + 1, YY + 1, 9, 9);
        Set_Color (Red_Color);
        for I in 0 .. 9 loop
            Point (XX + I, YY);
            Point (XX + I, YY + 9);
        end loop;
        for I in 0 .. 9 loop
            Point (XX, YY + I);
            Point (XX + 9, YY + I);
        end loop;
        Set_Color (Black_Color);
        for I in 1 .. 8 loop
            Point (XX + I, YY + 1);
            Point (XX + I, YY + 8);
        end loop;
        for I in 1 .. 8 loop
            Point (XX + 1, YY + I);
            Point (XX + 8, YY + I);
        end loop;
        Set_Color (White_Color);
        for I in 1 .. 6 loop
            for J in 1 .. 6 loop
                Point (XX + I + 1, YY + J + 1);
            end loop;
        end loop;
        Pop_Clip;

        This.Draw_End;
    end Draw;




    type Point_Test is new FLTK.Widgets.Groups.Group with null record;

    overriding procedure Draw
           (This : in out Point_Test);

    procedure Draw
           (This : in out Point_Test)
    is
        A  : constant Integer := This.Get_X + 16;
        B  : constant Integer := This.Get_Y + 34;
        XX : Integer;
        YY : Integer;
    begin
        FLTK.Widgets.Groups.Group (This).Draw;

        --  Test 1: pixel size
        Set_Color (White_Color);
        Rect_Fill (A + 24, B + 9 - 5, 10, 10);
        Set_Color (Black_Color);
        for I in 0 .. 7 loop
            for J in 0 .. 7 loop
                if (I + J) mod 2 = 1 then
                    Point (A + I + 24 + 1, B + J + 9 - 5 + 1);
                end if;
            end loop;
        end loop;

        --  Test 2: pixel color
        for N in 0 .. 2 loop
            YY := B + 9 - 5 + 24 + 16 * N;
            Set_Color (White_Color);
            Rect_Fill (A + 24, YY, 10, 10);
            Set_Color (Lut (N));
            for I in 0 .. 7 loop
                for J in 0 .. 7 loop
                    Point (A + I + 24 + 1, YY + J + 1);
                end loop;
            end loop;
        end loop;

        --  Test 3: pixel alignment inside windows (Native_Point_Test draws it)

        --  Test 4: check pixel clipping
        XX := A + 24;
        YY := B + 3 * 24 + 2 * 16 + 9 - 5;
        Push_Clip (XX, YY, 10, 10);
        Set_Color (Red_Color);
        for I in -1 .. 10 loop
            Point (XX + I, YY - 1);
            Point (XX + I, YY + 10);
        end loop;
        for I in -1 .. 10 loop
            Point (XX - 1, YY + I);
            Point (XX + 10, YY + I);
        end loop;
        Set_Color (Black_Color);
        for I in 0 .. 9 loop
            Point (XX + I, YY);
            Point (XX + I, YY + 9);
        end loop;
        for I in 0 .. 9 loop
            Point (XX, YY + I);
            Point (XX + 9, YY + I);
        end loop;
        Set_Color (White_Color);
        for I in 0 .. 7 loop
            for J in 0 .. 7 loop
                Point (XX + I + 1, YY + J + 1);
            end loop;
        end loop;
        Pop_Clip;

        --  Test 3a: pixel alignment inside the OpenGL window
        XX := A + 24 + 108;
        YY := B + 2 * 24 + 2 * 16 + 9 - 5;
        Set_Color (Black_Color);
        for I in -4 .. 13 loop
            Point (XX + I, YY);
            Point (XX + I, YY + 9);
        end loop;
    end Draw;




    type Point_Test_Access is access Point_Test;
    type Native_Point_Test_Access is access Native_Point_Test;
    type GL_Point_Test_Access is access GL_Point_Test;
    type Box_Access is access Bx.Box;


    function Create
        return Widget_Access
    is
        X : constant Integer := Test_Area_X;
        Y : constant Integer := Test_Area_Y;
        W : constant Integer := Test_Area_W;
        H : constant Integer := Test_Area_H;
        Page : constant Point_Test_Access := new Point_Test'
           (FLTK.Widgets.Groups.Forge.Create (X, Y, W, H) with null record);
        A : Integer := X + 16;
        B : constant Integer := Y + 34;
    begin
        Page.Begin_Current;
        Page.Set_Label ("Testing the fl_point call.");
        Page.Set_Alignment (Align_Inside + Align_Bottom + Align_Left + Align_Wrap);
        Page.Set_Box (Border_Box);
        Add_Heading (A, B - 24, "native");

        Add_Box (A, B, 18, "1",
           "Testing pixel size and antialiasing." & ASCII.LF & ASCII.LF &
           "This draws a checker board of black points on a white background." & ASCII.LF &
           ASCII.LF &
           "Black and white points should be the same size of one unit (1 pixel in regular " &
           "mode, 2x2 pixels in hidpi mode).If black points are smaller than white in hidpi " &
           "mode, point size must be increased." & ASCII.LF & ASCII.LF &
           "Points should not be blurry. Antialiasing should be switched of and the point " &
           "coordinates should be centered on the pixel(s)." & ASCII.LF & ASCII.LF &
           "If parts of the white border are missing, the size of fl_rect should be adjusted.");
        Add_Box (A, B + 24, 18, "2",
           "Testing pixels color." & ASCII.LF & ASCII.LF &
           "This draws three squares in red, green, and blue." & ASCII.LF & ASCII.LF &
           "If the order of colors is different, the byte order when writing into the pixel " &
           "buffer should be fixed.");
        Add_Box (A, B + 2 * 24 + 2 * 16, 18, "3",
           "Testing pixels alignment in windows." & ASCII.LF & ASCII.LF &
           "This draws a black frame around a white square." & ASCII.LF & ASCII.LF &
           "If parts of the black frame are clipped by the window and not visible, pixel " &
           "offsets must be adjusted.");
        declare
            Align_Test_Win : constant Native_Point_Test_Access := new Native_Point_Test'
               (Win.Forge.Create (A + 24, B + 2 * 24 + 2 * 16 + 9 - 5, 10, 10) with null record);
        begin
            Align_Test_Win.End_Current;
        end;
        Add_Box (A, B + 3 * 24 + 2 * 16, 18, "4",
           "Testing pixels clipping." & ASCII.LF & ASCII.LF &
           "This draws a black frame around a white square." & ASCII.LF & ASCII.LF &
           "If red pixels are visible or black pixels are missing, graphics clipping is " &
           "misaligned.");

        A := A + 100;
        Add_Heading (A, B - 24, "OpenGL");
        Add_Box (A, B, 26, "1a",
           "Testing pixel size and antialiasing." & ASCII.LF & ASCII.LF &
           "This draws a checker board of black points on a white background." & ASCII.LF &
           ASCII.LF &
           "Black and white points should be the same size of one unit (1 pixel in regular " &
           "mode, 2x2 pixels in hidpi mode).If black points are smaller than white in hidpi " &
           "mode, point size must be increased." & ASCII.LF & ASCII.LF &
           "Points should not be blurry. Antialiasing should be switched of and the point " &
           "coordinates should be centered on the pixel(s)." & ASCII.LF & ASCII.LF &
           "If parts of the white border are missing, the size of fl_rect should be adjusted.");
        Add_Box (A, B + 24, 26, "2a",
           "Testing pixels color." & ASCII.LF & ASCII.LF &
           "This draws three squares in red, green, and blue." & ASCII.LF & ASCII.LF &
           "If the order of colors is different, the color component order when writing " &
           "into the pixel buffer should be fixed.");
        Add_Box (A, B + 2 * 24 + 2 * 16, 26, "3a",
           "Testing pixels alignment in windows." & ASCII.LF & ASCII.LF &
           "This draws a black frame around a white square, extending to both sides." & ASCII.LF &
           ASCII.LF &
           "If parts of the black frame are clipped by the window and not visible, pixel " &
           "offsets must be adjusted horizontally." & ASCII.LF & ASCII.LF &
           "If the horizontal lines are misaligned, vertical pixel offset should be adjusted.");
        Add_Box (A, B + 3 * 24 + 2 * 16, 26, "4a",
           "Testing pixels clipping." & ASCII.LF & ASCII.LF &
           "This draws a black frame around a white square. The square is slightly smaller." &
           ASCII.LF & ASCII.LF &
           "If red pixels are visible or black pixels are missing, graphics clipping is " &
           "misaligned.");
        declare
            GL_Test_Win : constant GL_Point_Test_Access := new GL_Point_Test'
               (OGL.Forge.Create (A + 24 + 8, B + 9 - 5, 10, 4 * 24 + 2 * 16) with null record);
        begin
            GL_Test_Win.Set_Box (Flat_Box);
            GL_Test_Win.End_Current;
        end;

        declare
            T : constant Box_Access := new Bx.Box'(Bx.Forge.Create (X + W - 1, Y + H - 1, 1, 1));
        begin
            Page.Set_Resizable (T.all);
        end;
        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Points;
