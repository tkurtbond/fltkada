

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Phase 12's single-widget methods: a clock's shadow, a help view's
--  selection and Copy, and a GL window's swap interval.


with

    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Clocks,
    FLTK.Widgets.Groups.Help_Views,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Groups.Windows.OpenGL,
    FLTK.Widgets.Inputs.Text;

use

    Checks;

procedure Test_Widget_Methods is

    package Prb renames FLTK.Probe;
    package Clk renames FLTK.Widgets.Clocks;
    package Hlp renames FLTK.Widgets.Groups.Help_Views;
    package Win renames FLTK.Widgets.Groups.Windows;
    package GL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package Txt renames FLTK.Widgets.Inputs.Text;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Widget_Methods");

    procedure Settle is
    begin
        for N in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Settle;

    procedure Clock_Shadow is
        Clock  : Clk.Clock := Clk.Forge.Create (Window, 0, 0, 100, 100);
        Before : array (0 .. 99, 0 .. 99) of Prb.RGB;
        Differ : Natural := 0;
    begin
        Clock.Set_Time (3, 0, 0);
        Check (Clock.Has_Shadow, "a clock's hands have shadows by default");
        Check (Prb.Capture (Clock), "capture of the clock");
        for Y in Before'Range (2) loop
            for X in Before'Range (1) loop
                Before (X, Y) := Prb.Pixel (X, Y);
            end loop;
        end loop;
        Prb.Release;
        Clock.Set_Shadow (False);
        Check (not Clock.Has_Shadow, "Set_Shadow (False), Has_Shadow");
        Check (Prb.Capture (Clock), "capture of the clock without shadows");
        for Y in Before'Range (2) loop
            for X in Before'Range (1) loop
                if Prb.Pixel (X, Y) /= Before (X, Y) then
                    Differ := Differ + 1;
                end if;
            end loop;
        end loop;
        Prb.Release;
        Check (Differ > 0,
            "a clock without shadows is drawn differently:" & Natural'Image (Differ) &
            " pixels");
    end Clock_Shadow;

    procedure Help_Selection is
        View  : Hlp.Help_View := Hlp.Forge.Create (Window, 0, 100, 200, 100);
        Other : Hlp.Help_View := Hlp.Forge.Create (Window, 0, 200, 100, 50);
        Input : constant Txt.Text_Input := Txt.Forge.Create (Window, 200, 0, 100, 30);
    begin
        View.Set_Content ("<p>Some <b>bold</b> text</p>");
        Other.Set_Content ("<p>Other</p>");
        Check (not View.Has_Selection, "a new help view has no selection");
        Check (not View.Copy, "Copy with nothing selected is False");
        View.Select_All;
        Check (View.Has_Selection, "Select_All selects");
        Check (View.Copy (Hlp.Cut_Paste_Board), "Copy with text selected is True");
        Settle;
        FLTK.Static.Paste (Input, FLTK.Static.Clipboard);
        Settle;
        --  FLTK turns <p> into a line feed (Fl_Help_View.cxx, end_selection).
        Check (Input.Get_Value = ASCII.LF & "Some bold text",
            "Copy puts the text, without its tags, on the clipboard:" &
            Integer'Image (Input.Get_Value'Length) & " characters");
        Other.Select_All;
        Check (Other.Has_Selection and not View.Has_Selection,
            "selecting in another view clears this one's selection");
        Other.Clear_Selection;
        Check (not Other.Has_Selection, "Clear_Selection");
    end Help_Selection;

    procedure Swap is
        Glw    : GL.GL_Window := GL.Forge.Create (0, 0, 100, 100, "swap");
        Before : constant GL.Swap_Interval := Glw.Get_Swap_Interval;
    begin
        --  On Wayland, the one setting for all GL windows (F22).
        Check (Before = (if Prb.On_Wayland then 1 else GL.Unknown_Interval),
            "a GL window not shown reads Unknown_Interval, or 1 on Wayland:" &
            Integer'Image (Before));
        Glw.Show;
        Settle;
        Glw.Set_Swap_Interval (0);
        Check (Glw.Get_Swap_Interval in GL.Unknown_Interval | 0,
            "Set_Swap_Interval (0): " & Integer'Image (Glw.Get_Swap_Interval));
        Glw.Set_Swap_Interval (1);
        Check (Glw.Get_Swap_Interval in GL.Unknown_Interval | 1,
            "Set_Swap_Interval (1): " & Integer'Image (Glw.Get_Swap_Interval));
        Glw.Hide;
    end Swap;

begin

    Window.Show;
    Settle;

    Clock_Shadow;
    Help_Selection;
    Swap;

    Window.Hide;
    Summary;

end Test_Widget_Methods;


