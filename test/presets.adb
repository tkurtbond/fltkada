


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Each class of slider, dial and counter, moving together, after pofltk's
--  examples/Presets.Mod.
--
--  Each runs from 0 to 100 and starts at 40.  Moving one sets the others
--  to its value.  Setting a value doesn't call a valuator's callback, so
--  the others don't answer in turn.


with

    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Valuators.Counters.Simple,
    FLTK.Widgets.Valuators.Dials.Fill,
    FLTK.Widgets.Valuators.Dials.Line,
    FLTK.Widgets.Valuators.Sliders.Fill,
    FLTK.Widgets.Valuators.Sliders.Horizontal,
    FLTK.Widgets.Valuators.Sliders.Horizontal_Fill,
    FLTK.Widgets.Valuators.Sliders.Horizontal_Nice,
    FLTK.Widgets.Valuators.Sliders.Nice,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


function Presets
    return Integer
is


    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Val renames FLTK.Widgets.Valuators;
    package Cnt renames FLTK.Widgets.Valuators.Counters.Simple;
    package FD  renames FLTK.Widgets.Valuators.Dials.Fill;
    package LD  renames FLTK.Widgets.Valuators.Dials.Line;
    package FS  renames FLTK.Widgets.Valuators.Sliders.Fill;
    package HS  renames FLTK.Widgets.Valuators.Sliders.Horizontal;
    package HFS renames FLTK.Widgets.Valuators.Sliders.Horizontal_Fill;
    package HNS renames FLTK.Widgets.Valuators.Sliders.Horizontal_Nice;
    package NS  renames FLTK.Widgets.Valuators.Sliders.Nice;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


    Window : Win.Window := Win.Forge.Create (340, 330, "Presets");

    Fill      : aliased FS.Fill_Slider := FS.Forge.Create (Window, 20, 20, 25, 180, "fill");
    Nice      : aliased NS.Nice_Slider := NS.Forge.Create (Window, 70, 20, 25, 180, "nice");
    Hor       : aliased HS.Horizontal_Slider :=
        HS.Forge.Create (Window, 120, 20, 200, 25, "hor");
    Hor_Fill  : aliased HFS.Horizontal_Fill_Slider :=
        HFS.Forge.Create (Window, 120, 70, 200, 25, "hor fill");
    Hor_Nice  : aliased HNS.Horizontal_Nice_Slider :=
        HNS.Forge.Create (Window, 120, 120, 200, 25, "hor nice");
    Hor_Value : aliased HVS.Horizontal_Value_Slider :=
        HVS.Forge.Create (Window, 120, 170, 200, 25, "hor value");
    Fill_Dial : aliased FD.Fill_Dial := FD.Forge.Create (Window, 20, 230, 60, 60, "fill dial");
    Line_Dial : aliased LD.Line_Dial := LD.Forge.Create (Window, 100, 230, 60, 60, "line dial");
    Counter   : aliased Cnt.Simple_Counter :=
        Cnt.Forge.Create (Window, 180, 245, 140, 25, "simple counter");

    type Valuator_Access is access all Val.Valuator'Class;

    All_Of_Them : constant array (Positive range <>) of Valuator_Access :=
       (Fill'Access, Nice'Access, Hor'Access, Hor_Fill'Access, Hor_Nice'Access,
        Hor_Value'Access, Fill_Dial'Access, Line_Dial'Access, Counter'Access);


    procedure Moved
           (Item : in out Wdg.Widget'Class)
    is
        Value : constant Long_Float := Val.Valuator'Class (Item).Get_Value;
    begin
        for Each of All_Of_Them loop
            Each.Set_Value (Value);
        end loop;
    end Moved;


begin


    for Each of All_Of_Them loop
        Each.Set_Bounds (0.0, 100.0);
        Each.Set_Value (40.0);
        Each.Set_Callback (Moved'Unrestricted_Access);
    end loop;

    Window.Show;

    return FLTK.Run;


end Presets;


