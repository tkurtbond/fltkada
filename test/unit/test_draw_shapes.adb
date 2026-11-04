--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK.Draw's calls added in PLAN.md Phase 8: rounded rectangles, check
--  marks, radio buttons, arrows, focus frames, Frame2, the antialias and
--  scale overrides, and Load_Identity/Load_Matrix.  Each shape is drawn by
--  a box's Draw, captured, and checked pixel by pixel.  Get_Antialias,
--  Set_Antialias, Override_Scale and Restore_Scale crash FLTK with nothing
--  to draw on (pofltk 124; Override_Scale only when the scale isn't 1), so
--  they must raise Program_Error then, and work in a Draw.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Draw_Shapes is

    package Drw renames FLTK.Draw;
    package Prb renames FLTK.Probe;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Shape_Kind is
       (Rounded, Rounded_Fill, Check_Mark, Radio, Arrow_Right, Arrow_Left,
        Focus, Frame_1, Frame_2, Box_Focus, Matrix, Settings);

    type Shape_Box is new Bx.Box with record
        Shape        : Shape_Kind := Rounded;
        Settings_Ran : Boolean    := False;
        Raised       : Boolean    := False;
        AA_Off       : Boolean    := True;
        AA_On        : Boolean    := False;
        Scale        : Float      := -1.0;
    end record;

    overriding procedure Draw
           (This : in out Shape_Box);

    overriding procedure Draw
           (This : in out Shape_Box)
    is
        X : constant Integer := This.Get_X;
        Y : constant Integer := This.Get_Y;
    begin
        Drw.Set_Color (White_Color);
        Drw.Rect_Fill (X, Y, This.Get_W, This.Get_H);
        Drw.Set_Color (Black_Color);
        case This.Shape is
            when Rounded =>
                Drw.Rounded_Rect (X, Y, 40, 40, 10);
            when Rounded_Fill =>
                Drw.Rounded_Rect_Fill (X, Y, 40, 40, 10);
            when Check_Mark =>
                Drw.Draw_Check (X, Y, 40, 40, Black_Color);
            when Radio =>
                Drw.Draw_Radio (X, Y, 20, Black_Color);
            when Arrow_Right =>
                Drw.Draw_Arrow (X, Y, 40, 40, Drw.Single_Arrow, Drw.Orient_Right, Black_Color);
            when Arrow_Left =>
                Drw.Draw_Arrow (X, Y, 40, 40, Drw.Single_Arrow, Drw.Orient_Left, Black_Color);
            when Focus =>
                Drw.Focus_Rect (X, Y, 40, 40);
            when Frame_1 =>
                Drw.Frame (X, Y, 40, 40, Top => 'A', Left => 'X', Bottom => 'X', Right => 'X');
            when Frame_2 =>
                Drw.Frame2 (X, Y, 40, 40, Bottom => 'A', Right => 'X', Top => 'X', Left => 'X');
            when Box_Focus =>
                Drw.Draw_Box_Focus (X, Y, 40, 40, Up_Box, Black_Color, White_Color);
            when Matrix =>
                Drw.Push_Matrix;
                Drw.Load_Matrix (1.0, 0.0, 0.0, 1.0, Long_Float (X + 20), Long_Float (Y));
                Drw.Begin_Polygon;
                Drw.Vertex (0.0, 0.0);
                Drw.Vertex (10.0, 0.0);
                Drw.Vertex (10.0, 10.0);
                Drw.Vertex (0.0, 10.0);
                Drw.End_Polygon;
                Drw.Load_Identity;
                Drw.Begin_Polygon;
                Drw.Vertex (Long_Float (X), Long_Float (Y + 20));
                Drw.Vertex (Long_Float (X + 10), Long_Float (Y + 20));
                Drw.Vertex (Long_Float (X + 10), Long_Float (Y + 30));
                Drw.Vertex (Long_Float (X), Long_Float (Y + 30));
                Drw.End_Polygon;
                Drw.Pop_Matrix;
            when Settings =>
                This.Settings_Ran := True;
                begin
                    Drw.Set_Antialias (False);
                    This.AA_Off := Drw.Get_Antialias;
                    Drw.Set_Antialias (True);
                    This.AA_On := Drw.Get_Antialias;
                    This.Scale := Drw.Override_Scale;
                    Drw.Restore_Scale (This.Scale);
                exception
                when Program_Error =>
                    This.Raised := True;
                end;
        end case;
    end Draw;

    Window  : Win.Window := Win.Forge.Create (0, 0, 60, 40, "Test_Draw_Shapes");
    The_Box : Shape_Box :=
       (Bx.Forge.Create (Window, Flat_Box, 0, 0, 60, 40) with others => <>);

    Black : constant Prb.RGB := Prb.To_RGB (0, 0, 0);
    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);

    function Dark
           (X, Y : in Integer)
        return Boolean is
    begin
        return Prb.Pixel (X, Y) /= White;
    end Dark;

    function Dark_Count
        return Natural
    is
        N : Natural := 0;
    begin
        for X in 0 .. 59 loop
            for Y in 0 .. 39 loop
                if Dark (X, Y) then
                    N := N + 1;
                end if;
            end loop;
        end loop;
        return N;
    end Dark_Count;

    --  How many pixels of column X are dark.
    function Column
           (X : in Integer)
        return Natural
    is
        N : Natural := 0;
    begin
        for Y in 0 .. 39 loop
            if Dark (X, Y) then
                N := N + 1;
            end if;
        end loop;
        return N;
    end Column;

    --  The first and last columns with a dark pixel, and their heights.
    procedure Ends
           (First_H, Last_H : out Natural)
    is
        First, Last : Integer := -1;
    begin
        for X in 0 .. 59 loop
            if Column (X) > 0 then
                if First < 0 then
                    First := X;
                end if;
                Last := X;
            end if;
        end loop;
        First_H := (if First < 0 then 0 else Column (First));
        Last_H  := (if Last < 0 then 0 else Column (Last));
    end Ends;

    procedure Draw_As
           (Shape : in Shape_Kind) is
    begin
        The_Box.Shape := Shape;
        Check (Prb.Capture (The_Box), Shape_Kind'Image (Shape) & ": the capture is the box's size");
    end Draw_As;

    procedure Get_AA is
        AA : constant Boolean := Drw.Get_Antialias;
        pragma Unreferenced (AA);
    begin
        null;
    end Get_AA;

    procedure Set_AA is
    begin
        Drw.Set_Antialias (True);
    end Set_AA;

    procedure Override is
        S : constant Float := Drw.Override_Scale;
        pragma Unreferenced (S);
    begin
        null;
    end Override;

    procedure Restore is
    begin
        Drw.Restore_Scale (2.0);
    end Restore;

    First_H, Last_H : Natural;
    Waited          : Long_Float;
    pragma Unreferenced (Waited);

begin

    --  Nothing to draw on: no window has been current yet.  At scale 2,
    --  FLTK's Override_Scale would crash.  --

    FLTK.Static.Open_Display;
    if FLTK.Screen."=" (FLTK.Screen.Scaling_Support, FLTK.Screen.No_Scaling) then
        Skip ("scale 2 with nothing to draw on: scaling isn't supported");
    else
        FLTK.Screen.Set_Scale (2.0);
    end if;
    Raises (Get_AA'Access, Program_Error'Identity, "Get_Antialias with nothing to draw on raises");
    Raises (Set_AA'Access, Program_Error'Identity, "Set_Antialias with nothing to draw on raises");
    Raises (Override'Access, Program_Error'Identity,
        "Override_Scale with nothing to draw on raises");
    Raises (Restore'Access, Program_Error'Identity,
        "Restore_Scale with nothing to draw on raises");
    if FLTK.Screen."/=" (FLTK.Screen.Scaling_Support, FLTK.Screen.No_Scaling) then
        FLTK.Screen.Set_Scale (1.0);
    end if;

    --  Shapes  --

    Draw_As (Rounded);
    Check (Dark (20, 0) and Dark (0, 20) and Dark (39, 20) and Dark (20, 39),
        "Rounded_Rect draws its sides");
    Check (not Dark (20, 20), "Rounded_Rect leaves the inside");
    Check (not Dark (0, 0), "Rounded_Rect rounds the corner");
    Prb.Release;

    Draw_As (Rounded_Fill);
    Check (Prb.Pixel (20, 20) = Black, "Rounded_Rect_Fill fills the inside");
    Check (not Dark (0, 0) and not Dark (39, 39), "Rounded_Rect_Fill rounds the corners");
    Check (not Dark (50, 20), "Rounded_Rect_Fill keeps to its width");
    Prb.Release;

    Draw_As (Check_Mark);
    Check (Dark_Count > 20, "Draw_Check draws a mark");
    Check (not Dark (0, 0) and not Dark (50, 20), "Draw_Check keeps to its box");
    Prb.Release;

    Draw_As (Radio);
    Check (Dark_Count > 10, "Draw_Radio draws");
    Check (not Dark (30, 30), "Draw_Radio keeps to its diameter");
    Prb.Release;

    Draw_As (Arrow_Right);
    Ends (First_H, Last_H);
    Check (First_H > Last_H, "an arrow to the right is wide at its left: "
        & Natural'Image (First_H) & " >" & Natural'Image (Last_H));
    Prb.Release;

    Draw_As (Arrow_Left);
    Ends (First_H, Last_H);
    Check (First_H < Last_H, "an arrow to the left is wide at its right: "
        & Natural'Image (First_H) & " <" & Natural'Image (Last_H));
    Prb.Release;

    Draw_As (Focus);
    Check (Column (0) > 5 and Column (39) > 5, "Focus_Rect draws both sides");
    Check (Column (0) < 40, "Focus_Rect is dotted");
    Check (not Dark (20, 20), "Focus_Rect leaves the inside");
    Prb.Release;

    Draw_As (Frame_1);
    Check (Prb.Pixel (20, 0) = Black and Prb.Pixel (20, 39) = White,
        "Frame draws Top at the top");
    Prb.Release;

    Draw_As (Frame_2);
    Check (Prb.Pixel (20, 39) = Black and Prb.Pixel (20, 0) = White,
        "Frame2 draws Bottom at the bottom");
    Check (Prb.Pixel (39, 20) = White and Prb.Pixel (0, 20) = White,
        "Frame2 draws Right and Left as given");
    Prb.Release;

    --  It draws nothing unless visible focus is on (fl_boxtype.cxx:483-484),
    --  which the user's FLTK options can turn off (Fl.cxx:2060, 2090).
    FLTK.Static.Set_Option (FLTK.Static.Visible_Focus, True);
    Draw_As (Box_Focus);
    Check (Dark_Count > 10, "Draw_Box_Focus draws a focus frame");
    Check (not Dark (20, 20), "Draw_Box_Focus leaves the inside");
    Prb.Release;

    Draw_As (Matrix);
    Check (Prb.Pixel (25, 5) = Black and not Dark (5, 5),
        "Load_Matrix moves the polygon 20 right");
    Check (Prb.Pixel (5, 25) = Black and not Dark (25, 25),
        "Load_Identity puts the next polygon back");
    Prb.Release;

    --  On a surface, and in a shown window's Draw  --

    Draw_As (Settings);
    Check (The_Box.Settings_Ran and not The_Box.Raised,
        "on a surface, the antialias and scale calls work");
    Check (not The_Box.AA_Off, "after Set_Antialias (False), Get_Antialias is False");
    Prb.Release;

    The_Box.Settings_Ran := False;
    The_Box.AA_Off := True;
    The_Box.Scale := -1.0;
    Window.Show;
    for I in 1 .. 500 loop
        exit when The_Box.Settings_Ran;
        Waited := FLTK.Wait (0.01);
    end loop;
    Check (The_Box.Settings_Ran, "the shown window draws the box");
    Check (not The_Box.Raised, "in a window's Draw, the antialias and scale calls work");
    Check (abs (The_Box.Scale - FLTK.Screen.Get_Scale) < 0.001,
        "Override_Scale returns the screen's scale," & Float'Image (The_Box.Scale));
    Check (not The_Box.AA_Off, "in a window, after Set_Antialias (False), Get_Antialias is False");
    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, "unexpected " & Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Draw_Shapes;
