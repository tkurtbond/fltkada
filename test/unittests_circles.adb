--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Ada.Numerics.Long_Elementary_Functions,
    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.OpenGL;

use type

    FLTK.Alignment;


package body Unittests_Circles is


    package Bx renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;

    use FLTK, FLTK.Draw, Unittests_Common;


    --  The C++'s arc(): the points of an arc, which mark where FLTK's arcs
    --  and pies should and shouldn't reach.
    procedure Point_Arc
           (XI, YI, W, H : in Integer;
            A1, A2       : in Long_Float)
    is
        use Ada.Numerics, Ada.Numerics.Long_Elementary_Functions;
        RX   : constant Long_Float := Long_Float (W) / 2.0;
        RY   : constant Long_Float := Long_Float (H) / 2.0;
        X    : constant Long_Float := Long_Float (XI) + RX + 0.5;
        Y    : constant Long_Float := Long_Float (YI) + RY + 0.5;
        Circ : constant Long_Float := Pi * 0.5 * (RX + RY);
        Segs : Integer;
        Ang  : Long_Float;
        Stop : Long_Float;
        Step : Long_Float;
    begin
        if A2 <= A1 then
            return;
        end if;
        Segs := Integer (Long_Float'Truncation (Circ * (A2 - A1) / 100.0));
        if Segs < 3 then
            Segs := 3;
        end if;
        Ang := A1 / 180.0 * Pi;
        Stop := A2 / 180.0 * Pi;
        Step := (Stop - Ang) / Long_Float (Segs);
        Point (Integer (Long_Float'Truncation (X + Cos (Ang) * RX)),
               Integer (Long_Float'Truncation (Y - Sin (Ang) * RY)));
        for I in reverse 1 .. Segs loop
            Ang := Ang + Step;
            Point (Integer (Long_Float'Truncation (X + Cos (Ang) * RX)),
                   Integer (Long_Float'Truncation (Y - Sin (Ang) * RY)));
        end loop;
    end Point_Arc;


    procedure Draw_Circles
    is
        A : constant Integer := 0;
        B : Integer := 0;
        W : constant Integer := 40;
        H : constant Integer := 40;
    begin
        --  1: draw a circle and a filled circle
        Set_Color (Red_Color);
        Point_Arc (A + 1, B + 1, W - 2, H - 2, 0.0, 360.0);
        Set_Color (Green_Color);
        Point_Arc (A, B, W, H, 0.0, 360.0);
        Point_Arc (A + 2, B + 2, W - 4, H - 4, 0.0, 360.0);
        Set_Color (Black_Color);
        Arc (A + 1, B + 1, W - 1, H - 1, 0.0, 360.0);
        Set_Color (Red_Color);
        Point_Arc (A + 1 + 50, B + 1, W - 2, H - 2, 0.0, 360.0);
        Set_Color (Green_Color);
        Point_Arc (A + 50, B, W, H, 0.0, 360.0);
        Set_Color (Black_Color);
        Pie (A + 1 + 50, B + 1, W - 1, H - 1, 0.0, 360.0);
        B := B + 44;

        --  2: draw arcs and pies
        Set_Color (Red_Color);
        Point_Arc (A + 1, B + 1, W - 2, H - 2, 45.0, 315.0);
        Set_Color (Green_Color);
        Point_Arc (A, B, W, H, 45.0, 315.0);
        Point_Arc (A + 2, B + 2, W - 4, H - 4, 45.0, 315.0);
        Set_Color (Black_Color);
        Arc (A + 1, B + 1, W - 1, H - 1, 45.0, 315.0);
        Set_Color (Red_Color);
        Point_Arc (A + 1 + 50, B + 1, W - 2, H - 2, 45.0, 315.0);
        Line (A + 50 + 20, B + 20, A + 50 + 20 + 14, B + 20 - 14);
        Line (A + 50 + 20, B + 20, A + 50 + 20 + 14, B + 20 + 14);
        Set_Color (Green_Color);
        Point_Arc (A + 50, B, W, H, 45.0, 315.0);
        Line (A + 50 + 21, B + 20, A + 50 + 21 + 14, B + 20 - 14);
        Line (A + 50 + 21, B + 20, A + 50 + 21 + 14, B + 20 + 14);
        Set_Color (Black_Color);
        Pie (A + 1 + 50, B + 1, W - 1, H - 1, 45.0, 315.0);
    end Draw_Circles;




    type GL_Circle_Test is new OGL.GL_Window with null record;

    overriding procedure Draw
           (This : in out GL_Circle_Test);

    procedure Draw
           (This : in out GL_Circle_Test) is
    begin
        This.Draw_Begin;
        This.Draw_Window;
        Draw_Circles;
        This.Draw_End;
    end Draw;


    type Native_Circle_Test is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Native_Circle_Test);

    procedure Draw
           (This : in out Native_Circle_Test) is
    begin
        Win.Window (This).Draw;
        Draw_Circles;
    end Draw;




    type Group_Access is access FLTK.Widgets.Groups.Group;
    type Native_Circle_Test_Access is access Native_Circle_Test;
    type GL_Circle_Test_Access is access GL_Circle_Test;
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
           ("Testing fast circle, arc, and pie drawing" & ASCII.LF & ASCII.LF &
            "No red lines should be visible. The green outlines should not be overwritten " &
            "by circle drawings.");
        Page.Set_Alignment (Align_Inside + Align_Bottom + Align_Left + Align_Wrap);
        Page.Set_Box (Border_Box);

        Add_Heading (A, B - 24, "native");
        declare
            NR : constant Native_Circle_Test_Access := new Native_Circle_Test'
               (Win.Forge.Create (A + 23, B - 1, 200, 200) with null record);
        begin
            NR.Set_Box (Flat_Box);
            NR.End_Current;
        end;
        Add_Box (A, B, 18, "1",
           "Testing circle alignment." & ASCII.LF & ASCII.LF &
           "This draws a black circle and a black disc, surrounded by a green frame." & ASCII.LF &
           ASCII.LF &
           "If green pixels are missing, circle drawing must be adjusted (see fl_arc, fl_pie)." &
           ASCII.LF & ASCII.LF & "If red pixels are showing, line width or aligment may be off.");
        B := B + 44;
        Add_Box (A, B, 18, "2",
           "Testing arc and pie drawing." & ASCII.LF & ASCII.LF &
           "This draws a black frame, surrounded on the inside and outside by a green frame." &
           ASCII.LF & ASCII.LF &
           "If green pixels are missing or red pixels are showing, rectangular frame " &
           "drawing schould be adjusted (see fl_rect)." & ASCII.LF & ASCII.LF &
           "If red pixels show in the corners of the frame in hidpi mode, line endings " &
           "should be adjusted.");

        A := X + 16 + 250;
        B := Y + 34;
        Add_Heading (A, B - 24, "OpenGL");
        --  As in the C++, this window isn't ended, so the boxes after it are
        --  its children.  Its Draw_Window draws them.
        declare
            GLR : constant GL_Circle_Test_Access := new GL_Circle_Test'
               (OGL.Forge.Create (A + 31, B - 1, 200, 200) with null record);
        begin
            GLR.Set_Box (Flat_Box);
        end;
        Add_Box (A, B, 26, "1a",
           "Testing circle alignment." & ASCII.LF & ASCII.LF &
           "This draws a black circle and a black disc, surrounded by a green frame." & ASCII.LF &
           ASCII.LF &
           "If green pixels are missing, circle drawing must be adjusted (see fl_arc, fl_pie)." &
           ASCII.LF & ASCII.LF & "If red pixels are showing, line width or aligment may be off.");
        B := B + 44;
        Add_Box (A, B, 26, "2a",
           "Testing arc and pie drawing." & ASCII.LF & ASCII.LF &
           "This draws a black frame, surrounded on the inside and outside by a green frame." &
           ASCII.LF & ASCII.LF &
           "If green pixels are missing or red pixels are showing, rectangular frame " &
           "drawing schould be adjusted (see fl_rect)." & ASCII.LF & ASCII.LF &
           "If red pixels show in the corners of the frame in hidpi mode, line endings " &
           "should be adjusted.");

        declare
            T : constant Box_Access := new Bx.Box'(Bx.Forge.Create (X + W - 1, Y + H - 1, 1, 1));
        begin
            Page.Set_Resizable (T.all);
        end;
        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Circles;
