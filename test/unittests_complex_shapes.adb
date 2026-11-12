--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.OpenGL,
    FLTK.Widgets.Positioners,
    FLTK.Widgets.Valuators.Dials,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Alignment;


package body Unittests_Complex_Shapes is


    package Bx renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package Pos renames FLTK.Widgets.Positioners;
    package Dl renames FLTK.Widgets.Valuators.Dials;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    use FLTK, FLTK.Draw, Unittests_Common;


    type Slider_Access is access HVS.Horizontal_Value_Slider;
    type Dial_Access is access Dl.Dial;
    type Positioner_Access is access Pos.Positioner;
    type Native_Access is access all Win.Window'Class;
    type GL_Access is access all OGL.GL_Window'Class;

    --  The C++ keeps these in the page, and the test windows find them
    --  through their parent.  There is only one page.
    Scale    : Slider_Access;
    Rotate   : Dial_Access;
    Position : Positioner_Access;
    Native_Test_Window : Native_Access;
    GL_Test_Window     : GL_Access;


    procedure Set_Transformation is
    begin
        Translate (Position.Get_Ecks, Position.Get_Why);
        FLTK.Draw.Rotate (-Rotate.Get_Value);
        FLTK.Draw.Scale (Scale.Get_Value, Scale.Get_Value);
    end Set_Transformation;


    procedure Update_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Native_Test_Window.Redraw;
        GL_Test_Window.Redraw;
    end Update_CB;


    procedure V
           (X, Y : in Integer) is
    begin
        Vertex (Long_Float (X), Long_Float (Y));
    end V;


    procedure Convex_Shape
           (W, H : in Integer) is
    begin
        V (-W / 2, -H);
        V (W / 2, -H);
        V (W, 0);
        V (W, H);
        V (0, H);
        V (-W, H / 2);
        V (-W, -H / 2);
    end Convex_Shape;


    procedure Complex_Shape
           (W, H : in Integer) is
    begin
        V (-W / 2, -H);
        V (0, -H / 2);
        V (W / 2, -H);
        V (W, 0);
        V (W, H);
        V (0, H);
        V (-W, H / 2);
        V (-W / 2, 0);
        V (-W, -H / 2);
    end Complex_Shape;


    procedure Two_Complex_Shapes
           (W, H : in Integer) is
    begin
        V (-W / 2, -H);
        V (W / 2, -H);
        V (W, 0);
        V (W, H - 3);
        Gap;
        V (W - 3, H);
        V (0, H);
        V (-W, H / 2);
        V (-W, -H / 2);
    end Two_Complex_Shapes;


    procedure Complex_Shape_With_Hole
           (W, H : in Integer)
    is
        W2 : constant Integer := W / 3;
        H2 : constant Integer := H / 3;
    begin
        --  clockwise
        V (-W / 2, -H);
        V (W / 2, -H);
        V (W, 0);
        V (W, H);
        V (0, H);
        V (-W, H / 2);
        V (-W, -H / 2);
        Gap;
        --  counterclockwise
        V (-W2, -H2);
        V (-W2, H2);
        V (W2, H2);
        V (W2, -H2);
    end Complex_Shape_With_Hole;


    procedure Draw_Complex
    is
        A  : constant Integer := 0;
        B  : Integer := 0;
        DX : constant Integer := 20;
        DY : constant Integer := 20;
        W  : constant Integer := 10;
        H  : constant Integer := 10;
        W2 : constant Integer := W / 3;
        H2 : constant Integer := H / 3;

        procedure Start
               (Offset : in Integer) is
        begin
            Push_Matrix;
            Translate (Long_Float (A + DX + Offset), Long_Float (B + DY));
            Set_Transformation;
        end Start;
    begin
        --  1: draw a random shape
        Set_Color (Black_Color);
        --  points
        Start (0);
        Begin_Points;
        Convex_Shape (W, H);
        End_Points;
        Pop_Matrix;
        --  lines
        Start (50);
        Begin_Line;
        Convex_Shape (W, H);
        End_Line;
        Pop_Matrix;
        --  line loop
        Start (100);
        Begin_Loop;
        Convex_Shape (W, H);
        End_Loop;
        Pop_Matrix;
        --  polygon
        Start (150);
        Begin_Polygon;
        Convex_Shape (W, H);
        End_Polygon;
        Pop_Matrix;

        --  2: draw a complex shape
        B := B + 44;
        --  convex polygon drawn in complex mode
        Start (0);
        Set_Color (Dark2_Color);
        Begin_Complex_Polygon;
        Convex_Shape (W, H);
        End_Complex_Polygon;
        Set_Color (Blue_Color);
        Begin_Loop;
        Convex_Shape (W, H);
        End_Loop;
        Pop_Matrix;
        --  non-convex polygon drawn in complex mode
        Start (50);
        Set_Color (Dark2_Color);
        Begin_Complex_Polygon;
        Complex_Shape (W, H);
        End_Complex_Polygon;
        Set_Color (Blue_Color);
        Begin_Loop;
        Complex_Shape (W, H);
        End_Loop;
        Pop_Matrix;
        --  two part polygon with gap
        Start (100);
        Set_Color (Dark2_Color);
        Begin_Complex_Polygon;
        Two_Complex_Shapes (W, H);
        End_Complex_Polygon;
        Set_Color (Blue_Color);
        Begin_Loop;
        V (-W / 2, -H);
        V (W / 2, -H);
        V (W, 0);
        V (W, H - 3);
        End_Loop;
        Begin_Loop;
        V (W - 3, H);
        V (0, H);
        V (-W, H / 2);
        V (-W, -H / 2);
        End_Loop;
        Pop_Matrix;
        --  polygon with a hole
        Start (150);
        Set_Color (Dark2_Color);
        Begin_Complex_Polygon;
        Complex_Shape_With_Hole (W, H);
        End_Complex_Polygon;
        Set_Color (Blue_Color);
        Begin_Loop;
        V (-W / 2, -H);
        V (W / 2, -H);
        V (W, 0);
        V (W, H);
        V (0, H);
        V (-W, H / 2);
        V (-W, -H / 2);
        End_Loop;
        Begin_Loop;
        V (-W2, -H2);
        V (-W2, H2);
        V (W2, H2);
        V (W2, -H2);
        End_Loop;
        Pop_Matrix;

        --  3: draw polygons with arcs
        B := B + 44;
        --  a rectangle with a camel hump
        Start (0);
        Set_Color (Dark2_Color);
        Begin_Complex_Polygon;
        V (-W, 0);
        Arc (0.0, 0.0, Long_Float (W - 3), 180.0, 0.0);
        V (W, 0);
        V (W, H);
        V (-W, H);
        End_Complex_Polygon;
        Set_Color (Blue_Color);
        Begin_Loop;
        V (-W, 0);
        Arc (0.0, 0.0, Long_Float (W - 3), 180.0, 0.0);
        V (W, 0);
        V (W, H);
        V (-W, H);
        End_Loop;
        Pop_Matrix;
        --  a rectangle with a camel dip
        Start (50);
        Set_Color (Dark2_Color);
        Begin_Complex_Polygon;
        V (-W, 0);
        Arc (0.0, 0.0, Long_Float (W - 3), 180.0, 360.0);
        V (W, 0);
        V (W, H);
        V (-W, H);
        End_Complex_Polygon;
        Set_Color (Blue_Color);
        Begin_Loop;
        V (-W, 0);
        Arc (0.0, 0.0, Long_Float (W - 3), 180.0, 360.0);
        V (W, 0);
        V (W, H);
        V (-W, H);
        End_Loop;
        Pop_Matrix;
        --  a rectangle with a bezier curve top
        Start (100);
        Set_Color (Dark2_Color);
        Begin_Complex_Polygon;
        V (-W, 0);
        Curve (Long_Float (-W + 3), 0.0, 0.0, Long_Float (-H), 0.0, Long_Float (H),
               Long_Float (W - 3), 0.0);
        V (W, 0);
        V (W, H);
        V (-W, H);
        End_Complex_Polygon;
        Set_Color (Blue_Color);
        Begin_Loop;
        V (-W, 0);
        Curve (Long_Float (-W + 3), 0.0, 0.0, Long_Float (-H), 0.0, Long_Float (H),
               Long_Float (W - 3), 0.0);
        V (W, 0);
        V (W, H);
        V (-W, H);
        End_Loop;
        Pop_Matrix;
    end Draw_Complex;




    type GL_Complex_Shapes_Test is new OGL.GL_Window with null record;

    overriding procedure Draw
           (This : in out GL_Complex_Shapes_Test);

    procedure Draw
           (This : in out GL_Complex_Shapes_Test) is
    begin
        This.Draw_Begin;
        This.Draw_Window;
        Draw_Complex;
        This.Draw_End;
    end Draw;


    type Native_Complex_Shapes_Test is new Win.Window with null record;

    overriding procedure Draw
           (This : in out Native_Complex_Shapes_Test);

    procedure Draw
           (This : in out Native_Complex_Shapes_Test) is
    begin
        Win.Window (This).Draw;
        Draw_Complex;
    end Draw;




    type Group_Access is access FLTK.Widgets.Groups.Group;
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
        Page.Set_Label ("Testing complex shape drawing.");
        Page.Set_Alignment (Align_Inside + Align_Bottom + Align_Left + Align_Wrap);
        Page.Set_Box (Border_Box);

        Add_Heading (A, B - 24, "native");
        Native_Test_Window := new Native_Complex_Shapes_Test'
           (Win.Forge.Create (A + 23, B - 1, 200, 200) with null record);
        Native_Test_Window.Set_Box (Flat_Box);
        Native_Test_Window.End_Current;
        Add_Box (A, B, 18, "1",
           "Testing complex drawing with transformations." & ASCII.LF & ASCII.LF &
           "Draw a point pattern, an open line, a closed line, and a covenx polygon." & ASCII.LF &
           ASCII.LF &
           "Use the controls at the bottom right to scale, rotate, and move the patterns.");
        B := B + 44;
        Add_Box (A, B, 18, "2",
           "Testing complex polygons." & ASCII.LF & ASCII.LF &
           "Draw polygons at different leves of complexity. All polygons should be within " &
           "the blue boundaries" & ASCII.LF & ASCII.LF & "1: a convex polygon" & ASCII.LF &
           "2: a non-convex polygon" & ASCII.LF & "3: two polygons in a single operation" &
           ASCII.LF & "4: a polygon with a square hole in it");
        B := B + 44;
        Add_Box (A, B, 18, "3",
           "Testing complex polygons with arcs." & ASCII.LF & ASCII.LF &
           "Draw polygons with an arc section. All polygons should be within the blue " &
           "boundaries" & ASCII.LF & ASCII.LF & "1: a polygon with a camel hump" & ASCII.LF &
           "2: a polygon with a camel dip");

        A := X + 16 + 250;
        B := Y + 34;
        Add_Heading (A, B - 24, "OpenGL");
        GL_Test_Window := new GL_Complex_Shapes_Test'
           (OGL.Forge.Create (A + 31, B - 1, 200, 200) with null record);
        GL_Test_Window.Set_Box (Flat_Box);
        GL_Test_Window.End_Current;
        Add_Box (A, B, 26, "1a",
           "Testing complex drawing with transformations." & ASCII.LF & ASCII.LF &
           "Draw a point pattern, an open line, a closed line, and a convex polygon." & ASCII.LF &
           ASCII.LF &
           "Use the controls at the bottom right to scale, rotate, and move the patterns.");
        B := B + 44;
        Add_Box (A, B, 28, "2a",
           "Testing complex polygons." & ASCII.LF & ASCII.LF &
           "Draw polygons at different leves of complexity. All polygons should be within " &
           "the blue boundaries" & ASCII.LF & ASCII.LF & "1: a convex polygon" & ASCII.LF &
           "2: a non-convex polygon" & ASCII.LF & "3: two polygons in a single operation" &
           ASCII.LF & "4: a polygon with a square hole in it");
        B := B + 44;
        Add_Box (A, B, 28, "3a",
           "Testing complex polygons with arcs." & ASCII.LF & ASCII.LF &
           "Draw polygons with an arc section. All polygons should be within the blue " &
           "boundaries" & ASCII.LF & ASCII.LF & "1: a polygon with a camel hump" & ASCII.LF &
           "2: a polygon with a camel dip");

        A := Test_Area_X + Test_Area_W - 250;
        B := Test_Area_Y + Test_Area_H - 50;

        Scale := new HVS.Horizontal_Value_Slider'
           (HVS.Forge.Create (A, B + 10, 120, 20, "Scale:"));
        Scale.Set_Alignment (Align_Top_Left);
        Scale.Set_Range (0.8, 1.2);
        Scale.Set_Value (1.0);
        Scale.Set_Callback (Update_CB'Access);

        Rotate := new Dl.Dial'(Dl.Forge.Create (A + 140, B, 40, 40, "Rotate:"));
        Rotate.Set_Alignment (Align_Top_Left);
        Rotate.Set_Angles (0, 360);
        Rotate.Set_Range (-180.0, 180.0);
        Rotate.Set_Value (0.0);
        Rotate.Set_Callback (Update_CB'Access);

        Position := new Pos.Positioner'(Pos.Forge.Create (A + 200, B, 40, 40, "Offset:"));
        Position.Set_Alignment (Align_Top_Left);
        Position.Set_Ecks_Bounds (-10.0, 10.0);
        Position.Set_Why_Bounds (-10.0, 10.0);
        Position.Set_Coords (0.0, 0.0);
        Position.Set_Callback (Update_CB'Access);

        declare
            T : constant Box_Access := new Bx.Box'(Bx.Forge.Create (A - 1, B - 1, 1, 1));
        begin
            Page.Set_Resizable (T.all);
        end;
        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Complex_Shapes;
