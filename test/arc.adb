

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Arc drawing test program functionality duplicated in Ada


pragma Ada_2022;


with

    FLTK.Draw,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


function Arc
    return Integer
is


    package FDR renames FLTK.Draw;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;
    package HV  renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


    --  More convenient to have these all as floats instead of integers
    Arg_Values : array (Positive range <>) of aliased Long_Float :=
        (140.0, 140.0, 50.0, 0.0, 360.0, 0.0);


    type Drawing_Widget is new FLTK.Widgets.Widget with null record;

    procedure Draw
           (This : in out Drawing_Widget) is
    begin
        FDR.Push_Clip (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        FDR.Set_Color (FLTK.Dark3_Color);
        FDR.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        FDR.Push_Matrix;
        if Arg_Values (6) > 0.001 then
            FDR.Translate
               (Long_Float (This.Get_X) + Long_Float (This.Get_W) / 2.0,
                Long_Float (This.Get_Y) + Long_Float (This.Get_H) / 2.0);
            FDR.Rotate (Arg_Values (6));
            FDR.Translate
               (-1.0 * (Long_Float (This.Get_X) + Long_Float (This.Get_W) / 2.0),
                -1.0 * (Long_Float (This.Get_Y) + Long_Float (This.Get_H) / 2.0));
        end if;
        FDR.Set_Color (FLTK.White_Color);
        FDR.Translate (Long_Float (This.Get_X), Long_Float (This.Get_Y));
        FDR.Begin_Complex_Polygon;
        FDR.Arc (Arg_Values (1), Arg_Values (2), Arg_Values (3), Arg_Values (4), Arg_Values (5));
        FDR.Gap;
        FDR.Arc (140.0, 140.0, 20.0, 0.0, -360.0);
        FDR.End_Complex_Polygon;
        FDR.Set_Color (FLTK.Red_Color);
        FDR.Begin_Line;
        FDR.Arc (Arg_Values (1), Arg_Values (2), Arg_Values (3), Arg_Values (4), Arg_Values (5));
        FDR.End_Line;
        FDR.Pop_Matrix;
        FDR.Pop_Clip;
    end Draw;


    The_Window : WD.Double_Window := WD.Forge.Create (300, 460, "Arc Testing");

    The_Drawing : Drawing_Widget :=
       (FLTK.Widgets.Forge.Create (The_Window, 10, 10, 280, 280)
        with null record);


    type My_Slider is new HV.Horizontal_Value_Slider with record
        Index : Integer range Arg_Values'Range;
    end record;

    X_Str      : aliased constant String := "X";
    Y_Str      : aliased constant String := "Y";
    R_Str      : aliased constant String := "R";
    Start_Str  : aliased constant String := "start";
    End_Str    : aliased constant String := "end";
    Rotate_Str : aliased constant String := "rotate";

    --  A straight up array of strings is not possible because of the different lengths
    Slider_Labels : constant array (Positive range <>) of access constant String :=
       (X_Str'Access,     Y_Str'Access,   R_Str'Access,
        Start_Str'Access, End_Str'Access, Rotate_Str'Access);

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


begin


    for Place in Sliders'Range loop
        if Place <= 3 then
            Sliders (Place).Set_Minimum (0.0);
            Sliders (Place).Set_Maximum (300.0);
        elsif Place = 6 then
            Sliders (Place).Set_Minimum (0.0);
            Sliders (Place).Set_Maximum (360.0);
        else
            Sliders (Place).Set_Minimum (-360.0);
            Sliders (Place).Set_Maximum (360.0);
        end if;
        Sliders (Place).Set_Step (1);
        Sliders (Place).Set_Value (Arg_Values (Place));
        Sliders (Place).Set_Alignment (FLTK.Align_Left);
        Sliders (Place).Set_Callback (Slider_Callback'Unrestricted_Access);
    end loop;

    The_Window.Show_With_Args;

    return FLTK.Run;


end Arc;


