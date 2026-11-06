


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/doublebuffer.cxx: the same star, drawn slowly enough to
--  see, in a window that draws on the screen and in one that draws off it
--  and then copies.  Move a slider to see the difference.


with

    Ada.Numerics.Long_Elementary_Functions,
    FLTK.Draw,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Groups.Windows.Single,
    FLTK.Widgets.Valuators.Sliders.Horizontal;


function Doublebuffer
    return Integer
is


    package Drw renames FLTK.Draw;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Sgl renames FLTK.Widgets.Groups.Windows.Single;
    package Hor renames FLTK.Widgets.Valuators.Sliders.Horizontal;


    --  On purpose, every line between N points round a circle: slow.
    procedure Star
           (W, H, N : in Integer)
    is
        use Ada.Numerics, Ada.Numerics.Long_Elementary_Functions;
        procedure Point
               (I : in Integer)
        is
            A : constant Long_Float := 2.0 * Pi * Long_Float (I) / Long_Float (N) + 0.1;
        begin
            Drw.Vertex (Cos (A), Sin (A));
        end Point;
    begin
        Drw.Push_Matrix;
        Drw.Translate (Long_Float (W / 2), Long_Float (H / 2));
        Drw.Scale (Long_Float (W / 2), Long_Float (H / 2));
        for I in 0 .. N - 1 loop
            for J in I + 1 .. N - 1 loop
                Drw.Begin_Line;
                Point (I);
                Point (J);
                Drw.End_Line;
            end loop;
        end loop;
        Drw.Pop_Matrix;
    end Star;


    procedure Bad_Draw
           (W, H, Sides : in Integer) is
    begin
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Rect_Fill (0, 0, W, H);
        Drw.Set_Color (FLTK.White_Color);
        Star (W, H, Sides);
    end Bad_Draw;


    type Single_Blink is new Sgl.Single_Window with record
        Sides : Integer := 20;
    end record;

    type Double_Blink is new Dbl.Double_Window with record
        Sides : Integer := 20;
    end record;

    overriding procedure Draw
           (This : in out Single_Blink);

    overriding procedure Draw
           (This : in out Double_Blink);

    procedure Draw
           (This : in out Single_Blink) is
    begin
        Bad_Draw (This.Get_W, This.Get_H, This.Sides);
        This.Draw_Child (This.Child (1).Data.all);
    end Draw;

    procedure Draw
           (This : in out Double_Blink) is
    begin
        Bad_Draw (This.Get_W, This.Get_H, This.Sides);
        This.Draw_Child (This.Child (1).Data.all);
    end Draw;


    W01 : Win.Window := Win.Forge.Create (420, 420, "Fl_Single_Window");
    W1  : Single_Blink :=
       (Sgl.Forge.Create (W01, 10, 10, 400, 400, "Fl_Single_Window") with Sides => 20);
    Slider0 : Hor.Horizontal_Slider := Hor.Forge.Create (W1, 20, 370, 360, 25);

    W02 : Win.Window := Win.Forge.Create (420, 420, "Fl_Double_Window");
    W2  : Double_Blink :=
       (Dbl.Forge.Create (W02, 10, 10, 400, 400, "Fl_Double_Window") with Sides => 20);
    Slider1 : Hor.Horizontal_Slider := Hor.Forge.Create (W2, 20, 370, 360, 25);


    procedure Slider0_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        W1.Sides := Integer (Hor.Horizontal_Slider (Item).Get_Value);
        W1.Redraw;
    end Slider0_CB;

    procedure Slider1_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        W2.Sides := Integer (Hor.Horizontal_Slider (Item).Get_Value);
        W2.Redraw;
    end Slider1_CB;


begin


    W01.Set_Box (FLTK.Flat_Box);
    W1.Set_Box (FLTK.Flat_Box);
    W1.Set_Background_Color (FLTK.Black_Color);
    W1.Set_Resizable (W1);
    Slider0.Set_Range (2.0, 30.0);
    Slider0.Set_Step (1.0);
    Slider0.Set_Value (20.0);
    Slider0.Set_Callback (Slider0_CB'Unrestricted_Access);

    W02.Set_Box (FLTK.Flat_Box);
    W2.Set_Box (FLTK.Flat_Box);
    W2.Set_Background_Color (FLTK.Black_Color);
    W2.Set_Resizable (W2);
    Slider1.Set_Range (2.0, 30.0);
    Slider1.Set_Step (1.0);
    Slider1.Set_Value (20.0);
    Slider1.Set_Callback (Slider1_CB'Unrestricted_Access);

    W01.Show_With_Args;
    W1.Show;
    W02.Show;
    W2.Show;
    return FLTK.Run;


end Doublebuffer;


