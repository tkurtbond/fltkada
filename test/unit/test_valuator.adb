


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Valuators:  values, bounds, steps, kinds and dragging, and the
--  positioner, spinner, progress bar and clocks, after pofltk's
--  test/TestValuators.Mod.  Mouse events are sent as from the window
--  system (FLTK.Probe), to a window never shown.  test_valuator_step,
--  test_slider_box, test_spinner_* and test_clock_* check more.


with

    Ada.Exceptions,
    Checks,
    FLTK.Events,
    FLTK.Probe,
    FLTK.Widgets.Clocks.Updated.Round,
    FLTK.Widgets.Groups.Spinners,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Positioners,
    FLTK.Widgets.Progress_Bars,
    FLTK.Widgets.Valuators.Adjusters,
    FLTK.Widgets.Valuators.Counters.Simple,
    FLTK.Widgets.Valuators.Dials.Fill,
    FLTK.Widgets.Valuators.Dials.Line,
    FLTK.Widgets.Valuators.Rollers,
    FLTK.Widgets.Valuators.Sliders.Fill,
    FLTK.Widgets.Valuators.Sliders.Horizontal,
    FLTK.Widgets.Valuators.Sliders.Horizontal_Fill,
    FLTK.Widgets.Valuators.Sliders.Horizontal_Nice,
    FLTK.Widgets.Valuators.Sliders.Nice,
    FLTK.Widgets.Valuators.Sliders.Scrollbars,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal,
    FLTK.Widgets.Valuators.Value_Inputs,
    FLTK.Widgets.Valuators.Value_Outputs,
    System;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Clocks.Time_Value,
    FLTK.Widgets.Groups.Spinners.Spinner_Kind,
    FLTK.Widgets.Valuators.Counters.Counter_Kind,
    FLTK.Widgets.Valuators.Dials.Dial_Kind,
    FLTK.Widgets.Valuators.Sliders.Slider_Kind,
    System.Address;


procedure Test_Valuator is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Val renames FLTK.Widgets.Valuators;
    package Adj renames FLTK.Widgets.Valuators.Adjusters;
    package Cnt renames FLTK.Widgets.Valuators.Counters;
    package Dls renames FLTK.Widgets.Valuators.Dials;
    package Rol renames FLTK.Widgets.Valuators.Rollers;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Scr renames FLTK.Widgets.Valuators.Sliders.Scrollbars;
    package VSl renames FLTK.Widgets.Valuators.Sliders.Value;
    package VIn renames FLTK.Widgets.Valuators.Value_Inputs;
    package VOt renames FLTK.Widgets.Valuators.Value_Outputs;
    package Spn renames FLTK.Widgets.Groups.Spinners;
    package Pos renames FLTK.Widgets.Positioners;
    package Prg renames FLTK.Widgets.Progress_Bars;
    package Clk renames FLTK.Widgets.Clocks;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window   : Win.Window := Win.Forge.Create (0, 0, 500, 400, "Test_Valuator");
    Slider   : Sld.Slider := Sld.Forge.Create (Window, 10, 10, 200, 20);
    VSlider  : VSl.Value_Slider := VSl.Forge.Create (Window, 10, 40, 200, 20);
    Scroll   : Scr.Scrollbar := Scr.Forge.Create (Window, 10, 70, 200, 20);
    Counter  : Cnt.Counter := Cnt.Forge.Create (Window, 10, 100, 200, 25);
    Dial     : Dls.Dial := Dls.Forge.Create (Window, 250, 10, 60, 60);
    Roller   : constant Rol.Roller := Rol.Forge.Create (Window, 320, 10, 20, 100);
    Adjuster : constant Adj.Adjuster := Adj.Forge.Create (Window, 350, 10, 75, 25);
    VInput   : VIn.Value_Input := VIn.Forge.Create (Window, 10, 140, 100, 25);
    VOutput  : VOt.Value_Output := VOt.Forge.Create (Window, 120, 140, 100, 25);
    Spinner  : Spn.Spinner := Spn.Forge.Create (Window, 10, 180, 100, 25);
    Progress : Prg.Progress_Bar := Prg.Forge.Create (Window, 10, 220, 200, 20);

    Calls : Natural := 0;
    Used  : Boolean := False;

    procedure Count
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Calls := Calls + 1;
    end Count;

    procedure Mouse
           (Into  : in Win.Window'Class;
            Event : in Event_Kind;
            X, Y  : in Integer) is
    begin
        Used := Prb.Mouse (Into, Event, X, Y);
    end Mouse;

    procedure Click
           (Into : in Win.Window'Class;
            X, Y : in Integer) is
    begin
        Mouse (Into, Push, X, Y);
        Mouse (Into, Release, X, Y);
    end Click;

    procedure Type_Keys
           (Keys : in String) is
    begin
        for C of Keys loop
            Used := Prb.Key (Keydown, Press (C), Mod_None, (1 => C));
        end loop;
    end Type_Keys;

    --  The classes that are another's kind and box, each as FLTK's.
    procedure Check_Presets is
        Fill   : constant Sld.Fill.Fill_Slider := Sld.Fill.Forge.Create (0, 0, 20, 100);
        H      : constant Sld.Horizontal.Horizontal_Slider :=
            Sld.Horizontal.Forge.Create (0, 0, 100, 20);
        H_Fill : constant Sld.Horizontal_Fill.Horizontal_Fill_Slider :=
            Sld.Horizontal_Fill.Forge.Create (0, 0, 100, 20);
        Nice   : constant Sld.Nice.Nice_Slider := Sld.Nice.Forge.Create (0, 0, 20, 100);
        H_Nice : constant Sld.Horizontal_Nice.Horizontal_Nice_Slider :=
            Sld.Horizontal_Nice.Forge.Create (0, 0, 100, 20);
        H_Val  : constant VSl.Horizontal.Horizontal_Value_Slider :=
            VSl.Horizontal.Forge.Create (0, 0, 100, 20);
        F_Dial : constant Dls.Fill.Fill_Dial := Dls.Fill.Forge.Create (0, 0, 50, 50);
        L_Dial : constant Dls.Line.Line_Dial := Dls.Line.Forge.Create (0, 0, 50, 50);
        Simple : Cnt.Simple.Simple_Counter :=
            Cnt.Simple.Forge.Create (0, 0, 100, 25);
    begin
        Check (Fill.Get_Kind = Sld.Vertical_Fill_Slider, "Fill_Slider");
        Check (H.Get_Kind = Sld.Horizontal_Slider, "Horizontal_Slider");
        Check (H_Fill.Get_Kind = Sld.Horizontal_Fill_Slider, "Horizontal_Fill_Slider");
        Check (Nice.Get_Kind = Sld.Vertical_Nice_Slider and Nice.Get_Box = Flat_Box,
            "Nice_Slider:  FLTK's kind, and its flat box");
        Check (H_Nice.Get_Kind = Sld.Horizontal_Nice_Slider and H_Nice.Get_Box = Flat_Box,
            "Horizontal_Nice_Slider:  FLTK's kind, and its flat box");
        Check (H_Val.Get_Kind = Sld.Horizontal_Slider, "Horizontal_Value_Slider");
        Check (F_Dial.Get_Kind = Dls.Fill_Dial, "Fill_Dial");
        Check (L_Dial.Get_Kind = Dls.Line_Dial, "Line_Dial");
        Check (Simple.Get_Kind = Cnt.Simple_Counter, "Simple_Counter");
    end Check_Presets;

    procedure Check_Positioner is
        Pane : Win.Window := Win.Forge.Create (0, 0, 500, 400, "positioner");
        P    : Pos.Positioner := Pos.Forge.Create (Pane, 100, 100, 209, 109);
    begin
        Check (P.Get_Ecks = 0.5 and P.Get_Why = 0.5 and P.Get_Ecks_Minimum = 0.0
                and P.Get_Ecks_Maximum = 1.0 and P.Get_Why_Minimum = 0.0
                and P.Get_Why_Maximum = 1.0,
            "a positioner starts in the middle of 0 to 1");
        Check (P.Get_Box = Down_Box, "with a down box, not the no box FLTK's header says");
        P.Set_Coords (0.25, 0.75);
        Check (P.Get_Ecks = 0.25 and P.Get_Why = 0.75, "Set_Coords");
        P.Set_Ecks (0.125);
        P.Set_Why (0.625);
        Check (P.Get_Ecks = 0.125 and P.Get_Why = 0.625, "Set_Ecks and Set_Why");
        P.Set_Ecks_Bounds (0.0, 200.0);
        P.Set_Why_Bounds (100.0, 200.0);
        Check (P.Get_Ecks_Maximum = 200.0 and P.Get_Why_Minimum = 100.0
                and P.Get_Why_Maximum = 200.0,
            "the bounds read back");
        P.Set_Coords (0.0, 100.0);
        P.Set_Callback (Count'Unrestricted_Access);
        Calls := 0;
        --  FLTK maps x + 4 .. x + w - 5 to the bounds, and calls back as it
        --  changes.
        Click (Pane, 204, 154);
        Check (P.Get_Ecks = 100.0 and P.Get_Why = 150.0 and Calls > 0,
            "a click sets both values, and calls back");
        P.Set_Ecks_Step (30.0);
        P.Set_Why_Step (25.0);
        --  60 is on a step; 120 rounds up to 125.
        Click (Pane, 164, 124);
        Check (P.Get_Ecks = 60.0 and P.Get_Why = 125.0, "the values go to the steps");
    end Check_Positioner;

    procedure Check_Clocks is
        Pane    : Win.Window := Win.Forge.Create (0, 0, 500, 400, "clocks");
        Out_C   : Clk.Clock := Clk.Forge.Create (Pane, 10, 10, 100, 100);
        Rounded : constant Clk.Updated.Round.Round_Clock :=
            Clk.Updated.Round.Forge.Create (Pane, 230, 10, 100, 100);
        Square  : Prb.RGB;
        Ignore  : Boolean;
        use type Prb.RGB;
    begin
        Check (Rounded.Get_Box = No_Box, "a round clock has no box, unlike a square one");
        Out_C.Set_Time (13, 14, 15);
        Check (Out_C.Get_Hour = 13 and Out_C.Get_Minute = 14 and Out_C.Get_Second = 15,
            "Set_Time from hours, minutes and seconds");
        Check (Out_C.Get_Time = 13 * 3600 + 14 * 60 + 15,
            "sets the time to seconds past midnight");
        Out_C.Set_Time (Clk.Time_Value'Last);
        Check (Out_C.Get_Time = Clk.Time_Value'Last, "Set_Time keeps the last time FLTK can hold");
        Check (Out_C.Get_Second = 15, "and works it out (ULONG_MAX on 32 bits, 06:28:15 UTC)");
        Out_C.Set_Time (0);
        Check (Out_C.Get_Time = 0, "and the first");
        Check (Out_C.Has_Shadow, "a clock starts with a shadow");
        Out_C.Set_Shadow (False);
        Check (not Out_C.Has_Shadow, "Set_Shadow");
        --  A square face reaches the corners, a round one doesn't.
        Out_C.Set_Background_Color (White_Color);
        Ignore := Prb.Capture (Out_C);
        Square := Prb.Pixel (6, 6);
        Prb.Release;
        Clk.Extra.Set_Kind (Out_C, Clk.Round_Face);
        Ignore := Prb.Capture (Out_C);
        Check (Prb.Pixel (6, 6) /= Square, "Set_Kind changes the face");
        Prb.Release;
        --  A shown clock's timer ticks; it must go with the clock, and
        --  valgrind would see it run on one deleted.
        Pane.Show;
        Ignore := FLTK.Check;
    end Check_Clocks;

begin

    --  A valuator's numbers.
    Check (Slider.Get_Value = 0.0 and Slider.Get_Minimum = 0.0 and Slider.Get_Maximum = 1.0
            and Slider.Get_Step = 0.0 and Slider.Get_When = When_Changed,
        "a valuator starts at 0, from 0 to 1, with no step, calling back on change");
    Slider.Set_Bounds (0.0, 100.0);
    Slider.Set_Value (25.0);
    Check (Slider.Get_Value = 25.0 and Slider.Get_Maximum = 100.0, "Set_Bounds and Set_Value");
    Slider.Set_Value (250.0);
    Check (Slider.Get_Value = 250.0, "Set_Value doesn't clamp");
    Slider.Set_Step (5.0);
    Check (Slider.Round (12.0) = 10.0 and Slider.Clamp (250.0) = 100.0
            and Slider.Increment (11.0, 3) = 25.0 and Slider.Increment (95.0, 3) = 110.0,
        "Round, Clamp, and Increment, which rounds but doesn't clamp");
    Slider.Set_Precision (2);
    Slider.Set_Value (1.5);
    Check (Slider.Get_Step = 0.01 and Slider.Format = "1.50",
        "Set_Precision sets the step, and Format shows its digits: " & Slider.Format);

    --  Kinds.
    Check (Slider.Get_Kind = Sld.Vertical_Slider and Dial.Get_Kind = Dls.Normal_Dial
            and Counter.Get_Kind = Cnt.Normal_Counter,
        "each starts with its kind");
    Sld.Extra.Set_Kind (Slider, Sld.Horizontal_Slider);
    Check (Slider.Get_Kind = Sld.Horizontal_Slider, "Set_Kind");

    --  Dragging a horizontal slider.
    Slider.Set_Bounds (0.0, 100.0);
    Slider.Set_Step (0.0);
    Slider.Set_Value (50.0);
    Slider.Set_Callback (Count'Unrestricted_Access);
    Calls := 0;
    Mouse (Window, Push, 110, 20);
    Mouse (Window, Drag, 209, 20);
    Mouse (Window, Release, 209, 20);
    Check (Used and Slider.Get_Value = 100.0 and Calls > 0,
        "dragging the knob to the right end gives the maximum, with callbacks");
    Mouse (Window, Push, 110, 20);
    Mouse (Window, Drag, 10, 20);
    Mouse (Window, Release, 10, 20);
    Check (Slider.Get_Value = 0.0, "and to the left end the minimum");

    --  A slider's own bounds, which redraws it.
    Slider.Clear_Damage;
    Slider.Set_Bounds (0.0, 10.0);
    Check (Slider.Is_Damaged, "Set_Bounds of a slider asks for a redraw (Fl_Slider::bounds)");
    Slider.Set_Slide_Size (0.25);
    Slider.Set_Slider_Box (Up_Box);
    Check (abs (Slider.Get_Slide_Size - 0.25) < 1.0E-6 and Slider.Get_Slider_Box = Up_Box,
        "the knob's size and box read back");

    --  A scrollbar.
    Check (Scroll.Get_Line_Size = 16, "a scrollbar's line size starts at 16");
    Scroll.Set_All (10, 20, 0, 100);
    Check (Scroll.Get_Value = 10.0 and Scroll.Get_Minimum = 0.0 and Scroll.Get_Maximum = 80.0
            and abs (Scroll.Get_Slide_Size - 0.2) < 1.0E-6,
        "Set_All:  20 of 100 lines shown from 10");

    --  A counter's arrows:  << < value > >>.
    Counter.Set_Step (1.0);
    Counter.Set_Long_Step (10.0);
    Counter.Set_Value (0.0);
    Click (Window, Counter.Get_X + Counter.Get_W - 3, Counter.Get_Y + 10);
    Check (Counter.Get_Value = 10.0, "a counter's outer right arrow adds the long step");
    Click (Window, Counter.Get_X + 3, Counter.Get_Y + 10);
    Check (Counter.Get_Value = 0.0, "and its outer left arrow subtracts it");

    --  The others' settings.
    Check (Dial.Get_First_Angle = 45 and Dial.Get_Second_Angle = 315,
        "a dial's angles start at 45 and 315");
    Dial.Set_Angles (0, 360);
    Check (Dial.Get_First_Angle = 0 and Dial.Get_Second_Angle = 360, "Set_Angles");
    Check (Adjuster.Is_Soft and not VInput.Is_Soft and not VOutput.Is_Soft,
        "an adjuster starts soft, a value input or output not");
    VOutput.Set_Soft (True);
    Check (VOutput.Is_Soft, "Set_Soft");
    VInput.Set_Text_Size (20);
    VSlider.Set_Text_Color (Red_Color);
    Counter.Set_Text_Font (Courier);
    Check (VInput.Get_Text_Size = 20 and VSlider.Get_Text_Color = Red_Color
            and Counter.Get_Text_Font = Courier,
        "the text settings of a value input, value slider and counter");
    Check (Roller.Get_Value = 0.0, "a roller is a valuator");

    --  Typing into a value input:  its field is a widget FLTK made.
    VInput.Set_Bounds (0.0, 100.0);
    VInput.Set_Callback (Count'Unrestricted_Access);
    Calls := 0;
    Check (VInput.Take_Focus and then FLTK.Events.Get_Focus /= null
            and then FLTK.Events.Get_Focus.all'Address = VInput.Text_Field.Data.all'Address,
        "a value input passes the focus to its field");
    Type_Keys ("42");
    Check (VInput.Get_Value = 42.0 and Calls > 0,
        "typing into it sets its value, with callbacks");

    --  A spinner.
    Check (Spinner.Get_Value = 1.0 and Spinner.Get_Minimum = 1.0
            and Spinner.Get_Maximum = 100.0 and Spinner.Get_Step = 1.0
            and Spinner.Get_Kind = Spn.Int_Spin,
        "a spinner starts at 1, from 1 to 100 in steps of 1, whole");
    Spinner.Set_Kind (Spn.Float_Spin);
    Spinner.Set_Range (0.0, 1.0);
    Spinner.Set_Step (0.1);
    Spinner.Set_Value (0.5);
    Check (Spinner.Get_Kind = Spn.Float_Spin and Spinner.Get_Value = 0.5
            and Spinner.Get_Maximum = 1.0 and Spinner.Get_Step = 0.1,
        "its settings read back");
    Spinner.Set_Text_Size (18);
    Check (Spinner.Get_Text_Size = 18, "its text size, its field's");
    Check (Spinner.Number_Of_Children = 3, "it is a group of three widgets FLTK made");

    --  A progress bar.
    Check (Progress.Get_Value = 0.0 and Progress.Get_Minimum = 0.0
            and Progress.Get_Maximum = 100.0,
        "a progress bar starts at 0, from 0 to 100");
    Progress.Set_Minimum (0.0);
    Progress.Set_Maximum (10.0);
    Progress.Set_Value (2.5);
    Check (Progress.Get_Value = 2.5 and Progress.Get_Maximum = 10.0, "its value and bounds");

    Check_Presets;
    Check_Positioner;
    Check_Clocks;
    Used := FLTK.Check;
    Check (True, "a shown clock deleted, its timer with it");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Valuator;



