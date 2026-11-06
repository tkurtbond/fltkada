--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 87: under Rate_Limited, a write is drawn by FLTK's
--  timer, which redraws while the terminal is marked modified.  A write
--  that scrolls changes the scrollbar, which damages only the scrollbar's
--  part of the window, and the terminal is drawn clipped to it.  That draw
--  must not take the mark away, or the write is never drawn.  The
--  workaround for F23 cleared the mark after every draw.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double;

use

    Checks;


procedure Test_Terminal_Expose is

    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    use type Trm.Redraw_Style;

    Window : Dbl.Double_Window := Dbl.Forge.Create (0, 0, 400, 200, "Test_Terminal_Expose");

    Term : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 200);

    procedure Settle is
    begin
        for N in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Settle;

    --  The pixels of the text area, right of the cursor in column 0, that
    --  differ from the background
    function Ink
        return Natural
    is
        Background : constant FLTK.Probe.RGB := FLTK.Probe.Shown_Pixel (Window, 60, 40);
        Count      : Natural := 0;
    begin
        for Y in 5 .. 195 loop
            for X in 20 .. 300 loop
                if FLTK.Probe.Shown_Pixel (Window, X, Y) /= Background then
                    Count := Count + 1;
                end if;
            end loop;
        end loop;
        return Count;
    end Ink;

    Before, After : Natural;

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Settle;
    Check (Term.Get_Redraw_Style = Trm.Rate_Limited, "the style is Rate_Limited");

    Term.Append ((1 .. 40 => ASCII.LF));
    Settle;
    Before := Ink;
    Term.Append ("MMMMMMMMMMMM" & ASCII.LF);
    FLTK.Check;
    Settle;
    After := Ink;

    Check (After > Before, "a write that scrolls is shown:" & Natural'Image (Before) & " ->" &
        Natural'Image (After));

    Window.Hide;
    Summary;

end Test_Terminal_Expose;
