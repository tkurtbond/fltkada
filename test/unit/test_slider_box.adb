--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 94: a Slider's Get_Box and Set_Box were FLTK's
--  Fl_Slider::slider (), the box of the part that slides, and overrode
--  Widget's, so even a dispatching Set_Box set the knob and left the frame.
--  They are now Get_Slider_Box and Set_Slider_Box, and Set_Box sets the
--  frame, as on every widget and as box () does in C++.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Valuators.Sliders.Scrollbars,
    FLTK.Widgets.Valuators.Sliders.Value;

use

    Checks;

use type

    FLTK.Box_Kind;


procedure Test_Slider_Box is

    package Wdg renames FLTK.Widgets;
    package Sld renames FLTK.Widgets.Valuators.Sliders;

    Slider : aliased Sld.Slider := Sld.Forge.Create (0, 0, 100, 20);
    Valued : aliased Sld.Value.Value_Slider := Sld.Value.Forge.Create (0, 0, 100, 20);
    Scroll : aliased Sld.Scrollbars.Scrollbar := Sld.Scrollbars.Forge.Create (0, 0, 100, 20);

    procedure Frame
           (Name : in     String;
            Item : in out Sld.Slider'Class)
    is
        Knob : constant FLTK.Box_Kind := Item.Get_Slider_Box;
    begin
        Item.Set_Box (FLTK.Thin_Down_Box);
        Check (Wdg.Widget (Item).Get_Box = FLTK.Thin_Down_Box,
            Name & ": a dispatching Set_Box sets the frame, "
            & FLTK.Box_Kind'Image (Wdg.Widget (Item).Get_Box));
        Check (Item.Get_Box = FLTK.Thin_Down_Box,
            Name & ": and a dispatching Get_Box gets it, "
            & FLTK.Box_Kind'Image (Item.Get_Box));
        Check (Item.Get_Slider_Box = Knob,
            Name & ": and leaves the knob, "
            & FLTK.Box_Kind'Image (Item.Get_Slider_Box));

        Item.Set_Slider_Box (FLTK.Up_Box);
        Check (Item.Get_Slider_Box = FLTK.Up_Box,
            Name & ": Set_Slider_Box sets the knob, "
            & FLTK.Box_Kind'Image (Item.Get_Slider_Box));
        Check (Item.Get_Box = FLTK.Thin_Down_Box,
            Name & ": and leaves the frame, " & FLTK.Box_Kind'Image (Item.Get_Box));

        Item.Set_Box (FLTK.Flat_Box);
        Check (Wdg.Widget'Class (Item).Get_Box = FLTK.Flat_Box,
            Name & ": the frame is the widget's, "
            & FLTK.Box_Kind'Image (Wdg.Widget'Class (Item).Get_Box));
    end Frame;

begin

    Frame ("Slider", Slider);
    Frame ("Value_Slider", Valued);
    Frame ("Scrollbar", Scroll);

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Slider_Box;
