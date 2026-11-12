--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/minimum.cxx: a slider whose label is drawn outside it, to
--  show that FLTK redraws only what has changed.


with

    Ada.Command_Line,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Sliders;


function Minimum
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Ent renames FLTK.Widgets.Buttons.Enter;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Sld renames FLTK.Widgets.Valuators.Sliders;

    LF : constant Character := ASCII.LF;

    Window : Dbl.Double_Window :=
        Dbl.Forge.Create (400, 320, Ada.Command_Line.Command_Name);

    Text : Bx.Box := Bx.Forge.Create
       (Window, 10, 10, 300, 300,
        "MINIMUM UPDATE TEST" & LF &
        LF &
        "The slider on the right purposely" & LF &
        "draws outside its boundaries." & LF &
        "Moving it should leave old copies" & LF &
        "of the label.  These copies should" & LF &
        "*not* be erased by any actions" & LF &
        "other than hiding and showing" & LF &
        "of that portion of the window" & LF &
        "or changing the button that" & LF &
        "intersects them.");

    S : Sld.Slider := Sld.Forge.Create (Window, 320, 10, 20, 300, "Too_Big_Label");

    B1 : Btn.Button       := Btn.Forge.Create (Window,  20, 270, 100, 30, "Button");
    B2 : Ent.Enter_Button := Ent.Forge.Create (Window, 200, 270, 100, 30, "Button");

begin

    Text.Set_Box (FLTK.Engraved_Frame);
    Window.Set_Resizable (Text);
    S.Set_Alignment (FLTK.Align_Center);

    Window.Show_With_Args;

    return FLTK.Run;

end Minimum;
