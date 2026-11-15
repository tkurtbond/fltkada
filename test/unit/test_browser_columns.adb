


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A column width of -1 (PLAN.md, Phase 30):  a share of what the browser's
--  inside leaves after the other widths, worked out when the widths are
--  set, when the browser is resized, and as each line is drawn, so that a
--  scrollbar coming or going is allowed for.  After pofltk's
--  TestBrowsers.Mod.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Browsers.Textline.Choice,
    FLTK.Widgets.Groups.Browsers.Textline.File,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Browsers.Textline.Multi,
    FLTK.Widgets.Groups.Windows;

use

    Checks;

use type

    FLTK.Widgets.Groups.Browsers.Textline.Column_Widths;


procedure Test_Browser_Columns is

    Drawn : Boolean;

    package Prb renames FLTK.Probe;
    package Txl renames FLTK.Widgets.Groups.Browsers.Textline;
    package Cho renames FLTK.Widgets.Groups.Browsers.Textline.Choice;
    package Fil renames FLTK.Widgets.Groups.Browsers.Textline.File;
    package Hld renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Mlt renames FLTK.Widgets.Groups.Browsers.Textline.Multi;
    package Win renames FLTK.Widgets.Groups.Windows;

    function Image
           (Widths : in Txl.Column_Widths)
        return String is
    begin
        if Widths'Length = 0 then
            return "";
        else
            return Integer'Image (Widths (Widths'First)) &
                Image (Widths (Widths'First + 1 .. Widths'Last));
        end if;
    end Image;

    procedure Settle is
    begin
        for I in 1 .. 20 loop
            FLTK.Check;
        end loop;
    end Settle;

    Window : Win.Window := Win.Forge.Create (0, 0, 640, 480, "Test_Browser_Columns");
    Lines  : Txl.Textline_Browser := Txl.Forge.Create (Window, 0, 0, 300, 100);
    Hold   : Hld.Hold_Browser := Hld.Forge.Create (Window, 300, 0, 200, 100);
    Multi  : Mlt.Multi_Browser := Mlt.Forge.Create (Window, 0, 100, 200, 100);
    Choice : Cho.Choice_Browser := Cho.Forge.Create (Window, 200, 100, 200, 100);
    Files  : Fil.File_Browser := Fil.Forge.Create (Window, 400, 100, 200, 100);

    Inside, Wider, Narrower : Integer;

begin

    Window.End_Current;
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Settle;

    --  Fl_Browser_'s scrollbars are visible, and bbox allows for them, until
    --  its draw hides them (Fl_Browser_.cxx:340-370).  On X11 Settle has
    --  drawn it by now; on Wayland a draw waits for the compositor, so it is
    --  drawn here.
    Drawn := Prb.Capture (Lines);
    Prb.Release;
    Check (Drawn, "the browser drawn");

    --  A -1 alone is the whole inside.
    Lines.Set_Column_Widths ((1 => -1));
    Inside := Prb.Fitted_Widths (Lines) (1);
    Check (Inside > 250 and Inside <= 300,
        "a lone -1 is the browser's inside:" & Inside'Image);

    Lines.Set_Column_Widths ((100, -1));
    Check (Prb.Fitted_Widths (Lines) = (100, Inside - 100),
        "a -1 after a 100 is the rest:" & Image (Prb.Fitted_Widths (Lines)));
    Check (Lines.Get_Column_Widths = (100, -1),
        "Get_Column_Widths gives the widths as asked:" & Image (Lines.Get_Column_Widths));

    Lines.Set_Column_Widths ((-1, 50, -1));
    Check (Prb.Fitted_Widths (Lines) =
            ((Inside - 50) / 2, 50, Inside - 50 - (Inside - 50) / 2),
        "two -1s share the rest, the last taking the remainder:" &
        Image (Prb.Fitted_Widths (Lines)));

    Lines.Set_Column_Widths ((-1, -1, -1));
    Check (Prb.Fitted_Widths (Lines) =
            (Inside / 3, (Inside - Inside / 3) / 2,
             Inside - Inside / 3 - (Inside - Inside / 3) / 2),
        "three -1s:" & Image (Prb.Fitted_Widths (Lines)));

    Lines.Set_Column_Widths ((500, -1));
    Check (Prb.Fitted_Widths (Lines) = (500, 1),
        "a -1 with no room left is 1, since 0 would end the list:" &
        Image (Prb.Fitted_Widths (Lines)));

    Lines.Set_Column_Widths ((50, 0, -1));
    Check (Prb.Fitted_Widths (Lines) = (1 => 50),
        "a 0 still ends the list:" & Image (Prb.Fitted_Widths (Lines)));
    Check (Lines.Get_Column_Widths = (50, 0, -1),
        "and Get_Column_Widths still gives all of them:" & Image (Lines.Get_Column_Widths));

    --  A resize refits.
    Lines.Set_Column_Widths ((100, -1));
    Lines.Resize (0, 0, 400, 100);
    Wider := Prb.Fitted_Widths (Lines) (2);
    Check (Wider = Inside - 100 + 100,
        "a resize 100 wider widens the -1 by 100:" & Wider'Image);
    Lines.Resize (0, 0, 300, 100);
    Check (Prb.Fitted_Widths (Lines) = (100, Inside - 100),
        "and back:" & Image (Prb.Fitted_Widths (Lines)));

    --  A scrollbar, once the lines are drawn.
    for I in 1 .. 30 loop
        Lines.Add ("a" & ASCII.HT & "b");
    end loop;
    Drawn := Prb.Capture (Lines);
    Prb.Release;
    Narrower := Prb.Fitted_Widths (Lines) (2);
    Check (Narrower = Inside - 100 - FLTK.Static.Get_Default_Scrollbar_Size,
        "drawing with a scrollbar narrows the -1 by the scrollbar:" & Narrower'Image &
        " for" & Integer'Image (Inside - 100) & ", drawn " & Drawn'Image);

    --  Below -1 is an error.
    begin
        Lines.Set_Column_Widths ((10, -2));
        Check (False, "a width of -2 raises");
    exception
        when E : Constraint_Error =>
            Check (True, "a width of -2 raises: " & Ada.Exceptions.Exception_Message (E));
    end;

    --  Every Textline browser.
    Hold.Set_Column_Widths ((20, -1));
    Check (Prb.Fitted_Widths (Hold) (2) > 150, "a Hold_Browser fits:" &
        Image (Prb.Fitted_Widths (Hold)));
    Multi.Set_Column_Widths ((20, -1));
    Check (Prb.Fitted_Widths (Multi) (2) > 150, "a Multi_Browser fits:" &
        Image (Prb.Fitted_Widths (Multi)));
    Choice.Set_Column_Widths ((20, -1));
    Check (Prb.Fitted_Widths (Choice) (2) > 150, "a Choice_Browser fits:" &
        Image (Prb.Fitted_Widths (Choice)));
    Files.Set_Column_Widths ((20, -1));
    Check (Prb.Fitted_Widths (Files) (2) > 150, "a File_Browser fits:" &
        Image (Prb.Fitted_Widths (Files)));
    Files.Resize (400, 100, 240, 100);
    Check (Prb.Fitted_Widths (Files) (2) > 190, "and refits on a resize:" &
        Image (Prb.Fitted_Widths (Files)));

    Summary;

end Test_Browser_Columns;

