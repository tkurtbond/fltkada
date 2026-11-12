--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/line_style.cxx: a rectangle and a line drawn with the
--  colour, line style, cap, join, width and dash pattern the controls
--  set, moved by the Move slider, and optionally again as a one-pixel
--  black line.  FLTK's dash pattern is a C string of the four Dash
--  sliders' values, ending at the first zero; an odd number of lengths
--  repeats, under X11 and Cairo alike, so it is passed here as the pairs
--  of the pattern written out twice.  Guided by pofltk's LineStyle.Mod.


with

    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value;

use type

    FLTK.Alignment;


function Line_Style
    return Integer
is

    package FDR renames FLTK.Draw;
    package Bx  renames FLTK.Widgets.Boxes;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package VS  renames FLTK.Widgets.Valuators.Sliders.Value;


    type Test_Box is new Dbl.Double_Window with null record;

    overriding procedure Draw
           (This : in out Test_Box);


    Form : Dbl.Double_Window := Dbl.Forge.Create (500, 250, "fl_line_style() test");

    --  FLTK's sliders[0 .. 4]: R, G, B, Width, Move.
    Red    : VS.Value_Slider := VS.Forge.Create (Form, 280, 10, 180, 20, "R");
    Green  : VS.Value_Slider := VS.Forge.Create (Form, 280, 30, 180, 20, "G");
    Blue   : VS.Value_Slider := VS.Forge.Create (Form, 280, 50, 180, 20, "B");
    Style  : Chc.Choice := Chc.Forge.Create (Form, 280, 70, 180, 20, "Style");
    Cap    : Chc.Choice := Chc.Forge.Create (Form, 280, 90, 180, 20, "Cap");
    Join   : Chc.Choice := Chc.Forge.Create (Form, 280, 110, 180, 20, "Join");
    Width  : VS.Value_Slider := VS.Forge.Create (Form, 280, 130, 180, 20, "Width");
    Move   : VS.Value_Slider := VS.Forge.Create (Form, 280, 150, 180, 20, "Move");

    Draw_Line : Chk.Check_Button := Chk.Forge.Create (Form, 280, 170, 20, 20, "&Line");
    Note      : constant Bx.Box :=
        Bx.Forge.Create (Form, 305, 170, 160, 20, "add a 1-pixel black line");
    pragma Unreferenced (Note);

    --  FLTK's sliders[5 .. 8].
    Dash : array (1 .. 4) of Sld.Slider :=
       (Sld.Forge.Create (Form, 200, 210, 70, 20, "Dash"),
        Sld.Forge.Create (Form, 270, 210, 70, 20),
        Sld.Forge.Create (Form, 340, 210, 70, 20),
        Sld.Forge.Create (Form, 410, 210, 70, 20));

    Test : Test_Box := (Dbl.Forge.Create (Form, 0, 0, 200, 200) with null record);


    --  The dash pattern: the Dash sliders' lengths up to the first zero.
    function Dashes
        return FDR.Dash_Gap_Array
    is
        Lengths : array (1 .. 8) of FDR.Dash_Length;
        Count   : Natural := 0;
    begin
        for D of Dash loop
            exit when Integer (D.Get_Value) = 0;
            Count := Count + 1;
            Lengths (Count) := FDR.Dash_Length (Integer (D.Get_Value));
        end loop;
        if Count mod 2 = 1 then  --  an odd pattern repeats
            Lengths (Count + 1 .. 2 * Count) := Lengths (1 .. Count);
            Count := 2 * Count;
        end if;
        return Result : FDR.Dash_Gap_Array (1 .. Count / 2) do
            for I in Result'Range loop
                Result (I) := (Lengths (2 * I - 1), Lengths (2 * I));
            end loop;
        end return;
    end Dashes;


    procedure Draw
           (This : in out Test_Box)
    is
        M : Integer;
    begin
        Dbl.Double_Window (This).Draw;
        FDR.Set_Color
           (FLTK.Color_Component (Integer (Red.Get_Value)),
            FLTK.Color_Component (Integer (Green.Get_Value)),
            FLTK.Color_Component (Integer (Blue.Get_Value)));
        FDR.Set_Line_Style
           (Line   => FDR.Line_Kind'Val (Style.Chosen_Index - 1),
            Cap    => FDR.Cap_Kind'Val (Cap.Chosen_Index - 1),
            Join   => FDR.Join_Kind'Val (Join.Chosen_Index - 1),
            Width  => Integer (Width.Get_Value),
            Dashes => Dashes);

        --  draw the defined fl_rect and fl_vertex first and then
        --  the additional one-pixel line, if enabled
        for I in 0 .. (if Draw_Line.Is_On then 1 else 0) loop
            M := Integer (Move.Get_Value);
            FDR.Rect (M, M, This.Get_W - 20, This.Get_H - 20);
            FDR.Begin_Line;
            FDR.Vertex (Long_Float (M + 25), Long_Float (M + 25));
            FDR.Vertex (Long_Float (This.Get_W - 45 + M), Long_Float (This.Get_H - 45 + M));
            FDR.Vertex (Long_Float (This.Get_W - 50 + M), Long_Float (M + 25));
            FDR.Vertex (Long_Float (M + 25), Long_Float (This.Get_H / 2 - 10 + M));
            FDR.End_Line;
            --  you must reset the line type when done:
            FDR.Set_Line_Style (FDR.Solid_Line);
            FDR.Set_Color (FLTK.Black_Color);
        end loop;
    end Draw;


    procedure Do_Redraw
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Test.Redraw;
    end Do_Redraw;


    procedure Setup
           (Item     : in out Sld.Slider'Class;
            Min, Max : in     Long_Float;
            Left     : in     Boolean) is
    begin
        Item.Set_Bounds (Min, Max);
        Sld.Extra.Set_Kind (Sld.Slider (Item), Sld.Horizontal_Slider);
        if Left then
            Item.Set_Alignment (FLTK.Align_Left);
        end if;
        Item.Set_Callback (Do_Redraw'Unrestricted_Access);
        Item.Set_Step (1);
    end Setup;

begin

    Setup (Red, 0.0, 255.0, True);
    Setup (Green, 0.0, 255.0, True);
    Setup (Blue, 0.0, 255.0, True);

    Style.Add ("FL_SOLID");
    Style.Add ("FL_DASH");
    Style.Add ("FL_DOT");
    Style.Add ("FL_DASHDOT");
    Style.Add ("FL_DASHDOTDOT");
    Cap.Add ("default");
    Cap.Add ("FL_CAP_FLAT");
    Cap.Add ("FL_CAP_ROUND");
    Cap.Add ("FL_CAP_SQUARE");
    Join.Add ("default");
    Join.Add ("FL_JOIN_MITER");
    Join.Add ("FL_JOIN_ROUND");
    Join.Add ("FL_JOIN_BEVEL");

    Setup (Width, 0.0, 20.0, True);
    Setup (Move, -10.0, 20.0, True);
    Draw_Line.Set_Alignment (FLTK.Align_Left);
    Dash (1).Set_Alignment (FLTK.Align_Top_Left);
    for D of Dash loop
        Setup (D, 0.0, 40.0, False);
    end loop;

    Red.Set_Value (255.0);
    Green.Set_Value (100.0);
    Blue.Set_Value (100.0);
    Move.Set_Value (10.0);  --  move line coordinates
    Draw_Line.Set_State (FLTK.Widgets.Buttons.Off);
    Draw_Line.Set_Callback (Do_Redraw'Unrestricted_Access);
    Style.Set_Chosen (1);
    Style.Set_Callback (Do_Redraw'Unrestricted_Access);
    Cap.Set_Chosen (1);
    Cap.Set_Callback (Do_Redraw'Unrestricted_Access);
    Join.Set_Chosen (1);
    Join.Set_Callback (Do_Redraw'Unrestricted_Access);

    Test.End_Current;
    Form.Set_Resizable (Test);
    Form.End_Current;
    Form.Show_With_Args;

    return FLTK.Run;

end Line_Style;
