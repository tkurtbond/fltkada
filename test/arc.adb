

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Arc drawing test program functionality duplicated in Ada


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


    --  Trying out some stack allocation for this one

    Slider_One   : aliased My_Slider :=
       (HV.Forge.Create (The_Window, 50, 300, 240, 25, "X")
        with Index => 1);

    Slider_Two   : aliased My_Slider :=
       (HV.Forge.Create (The_Window, 50, 325, 240, 25, "Y")
        with Index => 2);

    Slider_Three : aliased My_Slider :=
       (HV.Forge.Create (The_Window, 50, 350, 240, 25, "R")
        with Index => 3);

    Slider_Four  : aliased My_Slider :=
       (HV.Forge.Create (The_Window, 50, 375, 240, 25, "start")
        with Index => 4);

    Slider_Five  : aliased My_Slider :=
       (HV.Forge.Create (The_Window, 50, 400, 240, 25, "end")
        with Index => 5);

    Slider_Six   : aliased My_Slider :=
       (HV.Forge.Create (The_Window, 50, 425, 240, 25, "rotate")
        with Index => 6);


    type Slider_Access is access all My_Slider;

    Sliders : array (Positive range <>) of Slider_Access :=
        (Slider_One'Access,  Slider_Two'Access,  Slider_Three'Access,
         Slider_Four'Access, Slider_Five'Access, Slider_Six'Access);


    procedure Slider_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Slide : My_Slider renames My_Slider (Item);
    begin
        Arg_Values (Slide.Index) := Slide.Get_Value;
        The_Drawing.Redraw;
    end Slider_Callback;


begin


    for Place in Integer range 1 .. 6 loop
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
        Sliders (Place).Set_Step_Bottom (1);
        Sliders (Place).Set_Value (Arg_Values (Place));
        Sliders (Place).Set_Alignment (FLTK.Align_Left);
        Sliders (Place).Set_Callback (Slider_Callback'Unrestricted_Access);
    end loop;

    The_Window.Show_With_Args;

    return FLTK.Run;


end Arc;


