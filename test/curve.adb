

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Curve drawing test program functionality duplicated in Ada


pragma Ada_2022;


with

    FLTK.Draw,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


function Curve
    return Integer
is


    package FDR renames FLTK.Draw;
    package Tog renames FLTK.Widgets.Buttons.Toggle;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;
    package HV  renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


    --  More convenient to have these all as floats instead of integers
    Arg_Values : array (Positive range <>) of aliased Long_Float :=
        (20.0, 20.0,   50.0, 200.0,   100.0, 20.0,   200.0, 200.0,   0.0);

    Points : Boolean := False;


    type Drawing_Widget is new FLTK.Widgets.Widget with null record;

    procedure Draw
           (This : in out Drawing_Widget) is
    begin
        FDR.Push_Clip (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        FDR.Set_Color (FLTK.Dark3_Color);
        FDR.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        FDR.Push_Matrix;
        if Arg_Values (9) > 0.001 then
            FDR.Translate
               (Long_Float (This.Get_X) + Long_Float (This.Get_W) / 2.0,
                Long_Float (This.Get_Y) + Long_Float (This.Get_H) / 2.0);
            FDR.Rotate (Arg_Values (9));
            FDR.Translate
               (-1.0 * (Long_Float (This.Get_X) + Long_Float (This.Get_W) / 2.0),
                -1.0 * (Long_Float (This.Get_Y) + Long_Float (This.Get_H) / 2.0));
        end if;
        FDR.Translate (Long_Float (This.Get_X), Long_Float (This.Get_Y));
        if not Points then
            FDR.Set_Color (FLTK.White_Color);
            FDR.Begin_Complex_Polygon;
            FDR.Curve
               (Arg_Values (1), Arg_Values (2), Arg_Values (3), Arg_Values (4),
                Arg_Values (5), Arg_Values (6), Arg_Values (7), Arg_Values (8));
            FDR.End_Complex_Polygon;
        end if;
        FDR.Set_Color (FLTK.Black_Color);
        FDR.Begin_Line;
        FDR.Vertex (Arg_Values (1), Arg_Values (2));
        FDR.Vertex (Arg_Values (3), Arg_Values (4));
        FDR.Vertex (Arg_Values (5), Arg_Values (6));
        FDR.Vertex (Arg_Values (7), Arg_Values (8));
        FDR.End_Line;
        FDR.Set_Color ((if Points then FLTK.White_Color else FLTK.Red_Color));
        if Points then FDR.Begin_Points; else FDR.Begin_Line; end if;
        FDR.Curve
           (Arg_Values (1), Arg_Values (2), Arg_Values (3), Arg_Values (4),
            Arg_Values (5), Arg_Values (6), Arg_Values (7), Arg_Values (8));
        if Points then FDR.End_Points; else FDR.End_Line; end if;
        FDR.Pop_Matrix;
        FDR.Pop_Clip;
    end Draw;


    The_Window : WD.Double_Window := WD.Forge.Create (300, 555, "Curve Testing");

    The_Drawing : Drawing_Widget :=
       (FLTK.Widgets.Forge.Create (The_Window, 10, 10, 280, 280)
        with null record);

    The_Toggle : Tog.Toggle_Button := Tog.Forge.Create (The_Window, 50, 525, 50, 25, "points");


    type My_Slider is new HV.Horizontal_Value_Slider with record
        Index : Integer range Arg_Values'Range;
    end record;

    X0_Str     : aliased constant String := "X0";
    Y0_Str     : aliased constant String := "Y0";
    X1_Str     : aliased constant String := "X1";
    Y1_Str     : aliased constant String := "Y1";
    X2_Str     : aliased constant String := "X2";
    Y2_Str     : aliased constant String := "Y2";
    X3_Str     : aliased constant String := "X3";
    Y3_Str     : aliased constant String := "Y3";
    Rotate_Str : aliased constant String := "rotate";

    --  A straight up array of strings is not possible because of the different lengths
    Slider_Labels : constant array (Positive range <>) of access constant String :=
        (X0_Str'Access, Y0_Str'Access,   X1_Str'Access, Y1_Str'Access,
         X2_Str'Access, Y2_Str'Access,   X3_Str'Access, Y3_Str'Access,   Rotate_Str'Access);

    --  This syntax requires Ada 2022, but it allows all overt heap usage to be avoided
    Sliders : array (Positive range <>) of My_Slider :=
       (for Place in Slider_Labels'Range =>
       (HV.Forge.Create (The_Window, 50, 275 + Place * 25, 240, 25, Slider_Labels (Place).all)
        with Index => Place));


    procedure Slider_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Slide : My_Slider renames My_Slider (Item);
    begin
        Arg_Values (Slide.Index) := Slide.Get_Value;
        The_Drawing.Redraw;
    end Slider_Callback;


    procedure Points_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Toggle : Tog.Toggle_Button renames Tog.Toggle_Button (Item);
    begin
        Points := Toggle.Is_On;
        The_Drawing.Redraw;
    end Points_Callback;


begin


    for Place in Sliders'Range loop
        Sliders (Place).Set_Minimum (0.0);
        if Place = 9 then
            Sliders (Place).Set_Maximum (360.0);
        else
            Sliders (Place).Set_Maximum (280.0);
        end if;
        Sliders (Place).Set_Step (1);
        Sliders (Place).Set_Value (Arg_Values (Place));
        Sliders (Place).Set_Alignment (FLTK.Align_Left);
        Sliders (Place).Set_Callback (Slider_Callback'Unrestricted_Access);
    end loop;

    The_Toggle.Set_Callback (Points_Callback'Unrestricted_Access);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Curve;


