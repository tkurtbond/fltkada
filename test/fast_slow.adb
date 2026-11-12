--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/fast_slow.fl: a slider whose callback sets one slider at
--  once, on every move, and another only when the mouse is released.
--  Ported from the C++ that FLUID writes from it.


with

    FLTK.Events,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Sliders;

use type

    FLTK.Alignment,
    FLTK.Callback_Flag;


function Fast_Slow
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Sld renames FLTK.Widgets.Valuators.Sliders;


    W : Dbl.Double_Window := Dbl.Forge.Create (318, 443);

    Control : Sld.Slider := Sld.Forge.Create (W,  90, 200, 30, 200, "move" & ASCII.LF & "this");
    Fast    : Sld.Slider := Sld.Forge.Create (W, 140, 200, 30, 200, "fast" & ASCII.LF & "redraw");
    Slow    : Sld.Slider := Sld.Forge.Create (W, 190, 200, 30, 200, "slow" & ASCII.LF & "redraw");

    Text : Bx.Box := Bx.Forge.Create
       (W, 10, 10, 300, 180,
        "The left slider has changed( FL_WHEN_CHANGED | FL_WHEN_RELEASE | FL_WHEN_NOT_" &
        "CHANGED) so it produces a callback on both drag and release mouse events." &
        ASCII.LF & "The" &
        " middle slider (representing a widget with low overhead) is changed on every m" &
        "ouse movement." & ASCII.LF &
        "The right slider (representing a widget with high overhead) is" &
        " only updated when the mouse is released, by checking if Fl::pushed() is zero.");


    procedure Control_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Fast.Set_Value (Control.Get_Value);
        if FLTK.Events.Get_Pushed = null then
            Slow.Set_Value (Control.Get_Value);
        end if;
    end Control_Callback;


begin

    Control.Set_Callback (Control_Callback'Unrestricted_Access);
    Control.Set_When (FLTK.When_Changed + FLTK.When_Release + FLTK.When_Interact);
    Fast.Set_Output_Only (True);
    Slow.Set_Output_Only (True);

    Text.Set_Box (FLTK.Down_Box);
    Text.Set_Background_Color (53);
    Text.Set_Selection_Color (FLTK.Dark1_Color);
    Text.Set_Label_Font (FLTK.Courier);
    Text.Set_Label_Size (12);
    Text.Set_Alignment (FLTK.Align_Wrap + FLTK.Align_Left + FLTK.Align_Inside);

    W.Set_Resizable (W);
    W.Show_With_Args;

    return FLTK.Run;

end Fast_Slow;
