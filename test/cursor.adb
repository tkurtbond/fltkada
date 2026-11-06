

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Cursor test program functionality reproduced in Ada


with

    FLTK.Draw,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Callback_Flag;


function Cursor
    return Integer
is


    package FD renames FLTK.Draw;
    package WD renames FLTK.Widgets.Groups.Windows.Double;
    package MC renames FLTK.Widgets.Menus.Choices;
    package HV renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


    The_Cursor : FLTK.Mouse_Cursor_Kind := FLTK.Default_Mouse;

    Cursor_Index_Low : constant Long_Float :=
        Long_Float (FLTK.Mouse_Cursor_Kind'Pos (FLTK.Mouse_Cursor_Kind'First));
    Cursor_Index_High : constant Long_Float :=
        Long_Float (FLTK.Mouse_Cursor_Kind'Pos (FLTK.Mouse_Cursor_Kind'Last));


    The_Window : WD.Double_Window := WD.Forge.Create (400, 300);

    The_Choices : MC.Choice := MC.Forge.Create
        (The_Window, 80, 100, 200, 25, "Cursor:");

    The_Slider : HV.Horizontal_Value_Slider := HV.Forge.Create
        (The_Window, 80, 180, 310, 30, "Cursor:");


    procedure Choice_Callback
           (This : in out FLTK.Widgets.Widget'Class)
    is
        My_Choice : MC.Choice renames MC.Choice (This);
    begin
        The_Cursor := FLTK.Mouse_Cursor_Kind'Val (My_Choice.Chosen_Index - 1);
        The_Slider.Set_Value (Long_Float (FLTK.Mouse_Cursor_Kind'Pos (The_Cursor)));
        FD.Set_Cursor (The_Cursor);
    end Choice_Callback;


    procedure Slider_Callback
           (This : in out FLTK.Widgets.Widget'Class)
    is
        My_Slider : HV.Horizontal_Value_Slider renames HV.Horizontal_Value_Slider (This);
    begin
        The_Cursor := FLTK.Mouse_Cursor_Kind'Val (Integer (My_Slider.Get_Value));
        The_Choices.Set_Chosen (FLTK.Mouse_Cursor_Kind'Pos (The_Cursor) + 1);
        FD.Set_Cursor (The_Cursor);
    end Slider_Callback;


begin


    The_Choices.Add ("FL_CURSOR_DEFAULT", Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_ARROW",   Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_CROSS",   Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_WAIT",    Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_INSERT",  Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_HAND",    Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_HELP",    Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_MOVE",    Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_NS",      Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_WE",      Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_NWSE",    Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_NESW",    Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_N",       Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_NE",      Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_E",       Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_SE",      Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_S",       Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_SW",      Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_W",       Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_NW",      Choice_Callback'Unrestricted_Access);
    The_Choices.Add ("FL_CURSOR_NONE",    Choice_Callback'Unrestricted_Access);

    The_Choices.Set_Callback (Choice_Callback'Unrestricted_Access);
    The_Choices.Set_When (FLTK.When_Release + FLTK.When_Interact);
    The_Choices.Set_Chosen (1);

    The_Slider.Set_Alignment (FLTK.Align_Left);
    The_Slider.Set_Step (1);
    The_Slider.Set_Precision (0);
    The_Slider.Set_Bounds (Cursor_Index_Low, Cursor_Index_High);
    The_Slider.Set_Value (Cursor_Index_Low);
    The_Slider.Set_Callback (Slider_Callback'Unrestricted_Access);

    The_Window.Set_Resizable (The_Window);
    The_Window.Show_With_Args;

    return FLTK.Run;


end Cursor;


