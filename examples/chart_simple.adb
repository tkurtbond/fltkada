

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/chart-simple.cxx: a sine wave plotted in
--  an Fl_Chart, with an Fl_Choice to switch between chart types.
--
--  The original stashes each item's chart type in the menu item's
--  argument(); here the chosen item's index is mapped onto Chart_Kind
--  instead, since the menu items are added in Chart_Kind order.


with

    Ada.Numerics.Long_Elementary_Functions,
    Ada.Strings.Fixed,
    FLTK.Widgets,
    FLTK.Widgets.Charts,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Choices;


function Chart_Simple
    return Integer
is


    package Chr renames FLTK.Widgets.Charts;
    package Cho renames FLTK.Widgets.Menus.Choices;
    package LEF renames Ada.Numerics.Long_Elementary_Functions;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;


    G_Win : Win.Window := Win.Forge.Create (1000, 510, "Chart Simple");

    G_Chart : Chr.Chart := Chr.Forge.Create (G_Win, 20, 20, 1000 - 40, 510 - 80, "Chart");

    G_Choice : Cho.Choice := Cho.Forge.Create (G_Win, 140, 470, 200, 25, "Chart Type: ");


    --  Same as C's "%.0lf", including its "-0" for small negative values.
    function Image
           (Value : in Long_Float)
        return String
    is
        Rounded : constant Long_Float := Long_Float'Rounding (Value);
        Text    : constant String :=
            Ada.Strings.Fixed.Trim (Integer'Image (Integer (Rounded)), Ada.Strings.Left);
    begin
        if Value < 0.0 and Rounded = 0.0 then
            return "-0";
        else
            return Text;
        end if;
    end Image;


    procedure Chart_Type_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        --  item picked, apply change
        G_Chart.Set_Kind (Chr.Chart_Kind'Val (G_Choice.Chosen_Index - 1));
        G_Chart.Redraw;
    end Chart_Type_CB;


    Start  : constant Long_Float := 1.5;
    Finish : constant Long_Float := Start + 15.1;
    T      : Long_Float := Start;


begin


    G_Chart.Set_Bounds (-125.0, 125.0);
    while T < Finish loop
        declare
            Val : constant Long_Float := LEF.Sin (T) * 125.0;
        begin
            G_Chart.Add
               (Val, Image (Val),
                (if Val < 0.0 then FLTK.Red_Color else FLTK.Green_Color));
        end;
        T := T + 0.5;
    end loop;

    G_Choice.Add ("FL_BAR_CHART",        Chart_Type_CB'Unrestricted_Access);
    G_Choice.Add ("FL_HORBAR_CHART",     Chart_Type_CB'Unrestricted_Access);
    G_Choice.Add ("FL_LINE_CHART",       Chart_Type_CB'Unrestricted_Access);
    G_Choice.Add ("FL_FILL_CHART",       Chart_Type_CB'Unrestricted_Access);
    G_Choice.Add ("FL_SPIKE_CHART",      Chart_Type_CB'Unrestricted_Access);
    G_Choice.Add ("FL_PIE_CHART",        Chart_Type_CB'Unrestricted_Access);
    G_Choice.Add ("FL_SPECIALPIE_CHART", Chart_Type_CB'Unrestricted_Access);
    G_Choice.Set_Chosen (Place => 1);

    G_Win.Set_Resizable (G_Win);
    G_Win.Show;

    return FLTK.Run;


end Chart_Simple;
