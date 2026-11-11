

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestTerminal: settings, output, UTF-8, escape
--  sequences, the history, sizes, drawing, selecting, a subclass, and a
--  terminal deleted with a redraw pending.  The cursor's moves and the
--  place ESC[s saves are test_terminal_cursor's; drawing at the redraw
--  rate test_terminal_expose's; the cursor kept on a smaller screen, the
--  error character's checks and the size limits test_terminal_fit's.
--  pofltk's count of open widgets has no counterpart.


with

    Ada.Strings.Fixed,
    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Terminal is

    package Prb renames FLTK.Probe;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Prb.RGB;
    use type Trm.Redraw_Style;
    use type Trm.Scrollbar_Style;
    use type Trm.Text_Attributes;
    use type Trm.Output_Translation;

    ESC : constant Character := Character'Val (27);
    LF  : constant Character := Character'Val (10);
    CR  : constant Character := Character'Val (13);

    Euro : constant String :=
        Character'Val (16#E2#) & Character'Val (16#82#) & Character'Val (16#AC#);

    Ignore : Boolean;

    procedure CSI
           (Term     : in out Trm.Terminal'Class;
            Sequence : in     String) is
    begin
        Term.Append (ESC & "[" & Sequence);
    end CSI;

    --  Line N, from 0, of Term's text, the lines below the cursor too.
    function Line
           (Term : in Trm.Terminal'Class;
            N    : in Natural)
        return String
    is
        Text  : constant String := Term.Get_Text (Lines_Below_Cursor => True);
        First : Positive := Text'First;
        Last  : Natural;
    begin
        for K in 1 .. N loop
            Last := Ada.Strings.Fixed.Index (Text (First .. Text'Last), (1 => LF));
            if Last = 0 then
                return "<no line" & Natural'Image (N) & ">";
            end if;
            First := Last + 1;
        end loop;
        Last := Ada.Strings.Fixed.Index (Text (First .. Text'Last), (1 => LF));
        if Last = 0 then
            Last := Text'Last + 1;
        end if;
        return Text (First .. Last - 1);
    end Line;

    function Where
           (Term : in Trm.Terminal'Class)
        return String is
    begin
        return " at" & Natural'Image (Term.Get_Cursor_Row) & ","
            & Natural'Image (Term.Get_Cursor_Column);
    end Where;


    procedure Test_Settings is
        Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "settings");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
    begin
        Check (Term.Get_ANSI and not Term.Get_Show_Unknown,
            "ANSI on, unknown characters not shown");
        Check (Term.Get_Redraw_Style = Trm.Rate_Limited, "rate limited");
        Check (Term.Get_History_Rows = 100 and Term.Get_History_Use = 0,
            "100 rows of history, none used");
        Check (Term.Get_Box = Down_Frame, "a down frame");
        Check (Term.Get_Output_Translate = Trm.Translate_LF_To_CRLF, "a line feed is both");
        Check (Term.Get_Hscrollbar_Style = Trm.Scrollbar_Auto, "a scrollbar as needed");
        Term.Set_Hscrollbar_Style (Trm.Scrollbar_On);
        Check (Term.Get_Hscrollbar_Style = Trm.Scrollbar_On, "Set_Hscrollbar_Style");
        Term.Set_Hscrollbar_Style (Trm.Scrollbar_Off);
        Term.Set_Scrollbar_Size (30);
        Check (Term.Get_Scrollbar_Size = 30 and Term.Get_Scrollbar_Actual_Size = 30,
            "Set_Scrollbar_Size");
        Term.Set_Scrollbar_Size (0);
        Check (Term.Get_Scrollbar_Size = 0
                and Term.Get_Scrollbar_Actual_Size = FLTK.Static.Get_Default_Scrollbar_Size,
            "0 is FLTK's scrollbar size");
        Term.Set_Margin_Left (5);
        Term.Set_Margin_Right (6);
        Term.Set_Margin_Top (7);
        Term.Set_Margin_Bottom (8);
        Check (Term.Get_Margin_Left = 5 and Term.Get_Margin_Right = 6
                and Term.Get_Margin_Top = 7 and Term.Get_Margin_Bottom = 8,
            "margins");
        Term.Set_Text_Font (Courier);
        Check (Term.Get_Text_Font = Courier, "Set_Text_Font");
        Term.Set_Text_Size (20);
        Check (Term.Get_Text_Size = 20, "Set_Text_Size");
        Term.Set_Box (Flat_Box);
        Check (Term.Get_Box = Flat_Box, "Set_Box");
        Term.Set_Text_Fore_Color (Red_Color);
        Term.Set_Text_Back_Color (Blue_Color);
        Check (Term.Get_Text_Fore_Color = Red_Color and Term.Get_Text_Back_Color = Blue_Color,
            "text colors");
        Term.Set_Text_Fore_Color_Default (Green_Color);
        Term.Set_Text_Back_Color_Default (Yellow_Color);
        Check (Term.Get_Text_Fore_Color_Default = Green_Color
                and Term.Get_Text_Back_Color_Default = Yellow_Color,
            "default colors");
        Term.Set_Text_Color (Cyan_Color);
        Check (Term.Get_Text_Fore_Color = Cyan_Color
                and Term.Get_Text_Fore_Color_Default = Cyan_Color,
            "Set_Text_Color sets both");
        Check (Term.Get_Text_Color = Cyan_Color, "Get_Text_Color");
        Term.Set_Selection_Fore_Color (Red_Color);
        Term.Set_Selection_Back_Color (Blue_Color);
        Check (Term.Get_Selection_Fore_Color = Red_Color
                and Term.Get_Selection_Back_Color = Blue_Color,
            "selection colors");
        Term.Set_Cursor_Fore_Color (Green_Color);
        Term.Set_Cursor_Back_Color (Yellow_Color);
        Check (Term.Get_Cursor_Fore_Color = Green_Color
                and Term.Get_Cursor_Back_Color = Yellow_Color,
            "cursor colors");
        Term.Set_Text_Fore_Color_Xterm (1);
        Check (Term.Get_Text_Fore_Color /= Cyan_Color, "an xterm foreground color");
        Term.Set_Text_Back_Color_Xterm (4);
        Check (Term.Get_Text_Back_Color /= Blue_Color, "an xterm background color");
        Term.Set_Text_Attrib (Trm.Attrib_Bold + Trm.Attrib_Inverse);
        Check (Term.Get_Text_Attrib = Trm.Attrib_Bold + Trm.Attrib_Inverse, "attributes");
        Check (Term.Get_Text_Attrib - Trm.Attrib_Bold = Trm.Attrib_Inverse, "less one");
        Term.Set_Text_Attrib (Trm.Attrib_Normal);
        Check (Term.Get_Text_Attrib = Trm.Attrib_Normal, "none");
        Term.Set_Redraw_Style (Trm.Per_Write);
        Check (Term.Get_Redraw_Style = Trm.Per_Write, "Set_Redraw_Style");
        Term.Set_Redraw_Rate (0.25);
        Check (Term.Get_Redraw_Rate = 0.25, "Set_Redraw_Rate");
        Term.Set_ANSI (False);
        Check (not Term.Get_ANSI, "ANSI off");
        Term.Set_Show_Unknown (True);
        Check (Term.Get_Show_Unknown, "unknown characters shown");
        Check (Term.Get_Error_Char /= "", "an error character to start with");
    end Test_Settings;


    --  A widget made after a terminal goes in the current group, not the
    --  terminal: Fl_Terminal ends its own group.
    procedure Test_Group is
        Window : Win.Window := Win.Forge.Create (0, 0, 200, 200, "group");
    begin
        Window.Begin_Current;
        declare
            Term : constant Trm.Terminal := Trm.Forge.Create (0, 0, 200, 100, "log");
            Box  : constant FLTK.Widgets.Boxes.Box :=
                FLTK.Widgets.Boxes.Forge.Create (0, 100, 200, 100);
        begin
            Window.End_Current;
            Check (Window.Number_Of_Children = 2 and Window.Contains (Term)
                    and Window.Contains (Box),
                "the next widget is the window's, as the terminal is");
        end;
    end Test_Group;


    procedure Test_Output is
        Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "output");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
    begin
        Check (Term.Get_Text = (1 => LF) or Term.Get_Text = "",
            "an empty terminal is one empty line:" & Natural'Image (Term.Get_Text'Length));
        Term.Append ("hello");
        Term.Append ((1 => LF));
        Term.Append ("world");
        Check (Line (Term, 0) = "hello" and Line (Term, 1) = "world", "two lines");
        Check (Term.Get_Text'Length = 12,
            "the text up to the cursor:" & Natural'Image (Term.Get_Text'Length));
        Check (Term.Get_Cursor_Row = 1 and Term.Get_Cursor_Column = 5,
            "the cursor after them" & Where (Term));
        Check (Term.Get_Text (Lines_Below_Cursor => True)'Length = 10 + Term.Get_Display_Rows,
            "below, every row of the screen");
        Term.Clear;
        Term.Append_UTF8 ("a");
        Term.Append_ASCII ("b");
        Term.Print_Char ("c");
        Term.Print_Char ('d');
        Term.Print ("e");
        Check (Term.Get_History_Use > 0, "Clear moves the screen to the history");
        Term.Clear_History;
        Check (Term.Get_History_Use = 0, "Clear_History");
        Check (Line (Term, 0) = "abcde", "each of the ways to write: " & Line (Term, 0));
        Term.Clear_Screen (Scroll_To_History => False);
        Check (Term.Get_History_Use = 0, "Clear_Screen, not to the history");
        Check (Term.Get_Cursor_Row = 0 and Term.Get_Cursor_Column = 5,
            "and the cursor stays" & Where (Term));
        Term.Append ("z");
        Term.Clear_Screen_Home;
        Check (Term.Get_History_Use > 0, "Clear_Screen_Home, to the history");
        Check (Term.Get_Cursor_Row = 0 and Term.Get_Cursor_Column = 0,
            "and the cursor is home" & Where (Term));
        Term.Reset_Terminal;
        Check (Term.Get_History_Use = 0, "Reset_Terminal clears the history");
        Term.Clear (Red_Color);
        Check (Term.Get_Text_Back_Color /= Red_Color, "Clear (Hue) leaves the text's color");

        Term.Reset_Terminal;
        Term.Set_Output_Translate (Trm.Translate_Off);
        Check (Term.Get_Output_Translate = Trm.Translate_Off, "no translation");
        Term.Append ("a" & LF & "b");
        Check (Line (Term, 1) = " b", "a line feed only goes down: " & Line (Term, 1));
        Term.Reset_Terminal;
        Term.Set_Output_Translate (Trm.Translate_CR_To_LF + Trm.Translate_LF_To_CRLF);
        Check (Term.Get_Output_Translate = Trm.Translate_CR_To_LF + Trm.Translate_LF_To_CRLF,
            "two translations");
        Term.Set_Output_Translate (Trm.Translate_CR_To_LF);
        Term.Append ("c" & CR & "d");
        Check (Line (Term, 1) = " d", "a carriage return goes down: " & Line (Term, 1));
        Term.Reset_Terminal;
        Term.Set_Output_Translate (Trm.Translate_LF_To_CRLF);
        Term.Plot_Char ("x", 2, 3);
        Term.Plot_Char ('y', 2, 4);
        Check (Line (Term, 2) = "   xy", "plotted: " & Line (Term, 2));
        Check (Term.Get_Cursor_Row = 0 and Term.Get_Cursor_Column = 0,
            "the cursor stays" & Where (Term));
        Term.Plot_Char ("", 2, 5);
        Check (Line (Term, 2) = "   xy", "nothing to plot");
        Term.Print_Char ("");
        Check (Term.Get_Cursor_Column = 0, "nothing to print");
    end Test_Output;


    procedure Test_UTF8 is
        Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "utf8");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
    begin
        Term.Append (Euro);
        Check (Line (Term, 0) = Euro, "a character of three bytes");
        Check (Term.Get_Cursor_Column = 1, "in one cell");
        Term.Reset_Terminal;
        Term.Append (Euro (1 .. 2));
        Check (Term.Get_Cursor_Column = 0, "a cut character waits");
        Term.Append (Euro (3 .. 3) & "!");
        Check (Line (Term, 0) = Euro & "!", "for the rest of it");
        Term.Reset_Terminal;
        Term.Set_Show_Unknown (True);
        Term.Set_Error_Char ("#");
        Check (Term.Get_Error_Char = "#", "Set_Error_Char");
        --  16#FF# would wait for its rest, as the start of a long character.
        Term.Append ("a" & Character'Val (16#80#) & "b");
        Check (Line (Term, 0) = "a#b", "shows for a bad byte: " & Line (Term, 0));
        Term.Reset_Terminal;
        Term.Set_Show_Unknown (True);
        declare
            Error : String := Euro;
        begin
            Term.Set_Error_Char (Error);
            Error (1) := '?';
            Check (Error (1) = '?', "the caller's copy changed");
        end;
        Check (Term.Get_Error_Char = Euro, "of three bytes, copied");
        Term.Append ((1 => Character'Val (2)));
        Check (Line (Term, 0) = Euro, "shows for a control character");
        Term.Reset_Terminal;
        Term.Print_Char ((1 => Character'Val (16#F0#)));
        Check (Line (Term, 0) = Euro, "and for a cut one");
        Term.Plot_Char ((1 => Character'Val (16#F0#)), 1, 0);
        Check (Line (Term, 1) = Euro, "plotted too");
    end Test_UTF8;


    procedure Test_Escapes is
        Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "escapes");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
        Fore   : constant Color := Term.Get_Text_Fore_Color;
        Back   : constant Color := Term.Get_Text_Back_Color;
    begin
        CSI (Term, "31;42m");
        Term.Append ("red");
        Check (Line (Term, 0) = "red", "the sequence is not in the text");
        Check (Term.Get_Text_Fore_Color /= Fore and Term.Get_Text_Back_Color /= Back, "colors");
        CSI (Term, "0m");
        Check (Term.Get_Text_Fore_Color = Fore and Term.Get_Text_Back_Color = Back, "and back");
        CSI (Term, "1m");
        Check (Term.Get_Text_Attrib.Bold, "bold");
        CSI (Term, "0m");
        Check (Term.Get_Text_Attrib = Trm.Attrib_Normal, "and normal");
        CSI (Term, "3;5H");
        Check (Term.Get_Cursor_Row = 2 and Term.Get_Cursor_Column = 4,
            "the cursor moved" & Where (Term));
        CSI (Term, "2J");
        Check (Line (Term, Term.Get_History_Use) = "", "the screen cleared");
        Term.Set_ANSI (False);
        CSI (Term, "1;1H");
        Check (Term.Get_Cursor_Row = 2 and Term.Get_Cursor_Column /= 0,
            "not read with ANSI off" & Where (Term));
    end Test_Escapes;


    procedure Test_History is
        Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "history");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
        First  : Natural;
    begin
        Term.Set_History_Rows (50);
        Check (Term.Get_History_Rows = 50, "Set_History_Rows");
        for K in 0 .. 199 loop
            Term.Append (Ada.Strings.Fixed.Trim (Natural'Image (K), Ada.Strings.Left) & LF);
        end loop;
        Check (Term.Get_History_Use = 50,
            "the history fills:" & Natural'Image (Term.Get_History_Use));
        First := 200 - 50 - Term.Get_Display_Rows + 1;
        Check (Line (Term, 0) = Ada.Strings.Fixed.Trim (Natural'Image (First), Ada.Strings.Left),
            "with the last lines: " & Line (Term, 0));
        Term.Set_History_Rows (0);
        Check (Term.Get_History_Rows = 0 and Term.Get_History_Use = 0, "no history");
    end Test_History;


    procedure Test_Sizes is
        Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "sizes");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
        Rows, Columns : Natural;
    begin
        Term.Set_Text_Font (Courier);
        Ignore := Prb.Capture (Term);
        Prb.Release;
        Rows := Term.Get_Display_Rows;
        Columns := Term.Get_Display_Columns;
        Check (Rows > 2 and Columns > 10, "rows and columns fit its size");
        Term.Set_Display_Columns (Columns + 50);
        Check (Term.Get_Display_Columns = Columns + 50, "more columns stay");
        Term.Set_Display_Rows (5);
        Check (Term.Get_Display_Rows > 0, "the rows are something");
        Term.Resize (0, 0, 400, 200);
        Check (Term.Get_Display_Rows < Rows, "a shorter widget has fewer rows");
        Check (Term.Get_Display_Columns = Columns + 50, "and keeps its columns");
        Term.Set_Text_Size (Term.Get_Text_Size * 2);
        Term.Set_History_Rows (0);
        Rows := Term.Get_Display_Rows;
        Term.Resize (0, 0, 400, 400);
        Check (Term.Get_Display_Rows > Rows, "a taller widget has more");
        Term.Set_History_Lines (30);
        Check (Term.Get_History_Lines = 30 and Term.Get_History_Rows = 30,
            "Set_History_Lines is Set_History_Rows");
    end Test_Sizes;


    procedure Test_Drawing is
        Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "drawing");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 200, 100);
        Before : Prb.RGB;
        Differs : Boolean := False;
    begin
        Term.Set_Text_Font (Courier);
        Check (Prb.Capture (Term), "drawn");
        Before := Prb.Pixel (10, 10);
        Prb.Release;
        CSI (Term, "41m");
        Term.Append ("        ");
        Ignore := Prb.Capture (Term);
        Check (Prb.Pixel (10, 10) /= Before, "a background color shows");
        Prb.Release;
        Term.Reset_Terminal;
        Term.Append ("xxxxxxxxxx");
        Ignore := Prb.Capture (Term);
        for Y in 4 .. 19 loop
            for X in 4 .. 59 loop
                Differs := Differs or Prb.Pixel (X, Y) /= Before;
            end loop;
        end loop;
        Prb.Release;
        Check (Differs, "text shows");
    end Test_Drawing;


    procedure Test_Selection is
        Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "selection");
        Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
        Row1, Col1, Row2, Col2 : Integer;
        Selected : Boolean;
    begin
        Term.Set_Text_Font (Courier);
        Term.Append ("selected");
        Ignore := Prb.Capture (Term);
        Prb.Release;
        Check (Term.Selection_Text = "" and Term.Selection_Text_Length = 0
                and not Term.Get_Selection (Row1, Col1, Row2, Col2),
            "nothing selected");
        Ignore := Prb.Mouse (Window, Push, 8, 12);
        --  The first drag starts the selection where the button went down, and
        --  the next ones extend it (Fl_Terminal::handle_selection).
        Ignore := Prb.Mouse (Window, Drag, 20, 12);
        Ignore := Prb.Mouse (Window, Drag, 300, 12);
        Ignore := Prb.Mouse (Window, Release, 300, 12);
        Check (Ada.Strings.Fixed.Index (Term.Selection_Text, "lec") > 0,
            "the mouse selects text: """ & Term.Selection_Text & """");
        Check (Term.Selection_Text_Length = Term.Selection_Text'Length,
            "Selection_Text_Length:" & Natural'Image (Term.Selection_Text_Length));
        Selected := Term.Get_Selection (Row1, Col1, Row2, Col2);
        Check (Selected and Row1 = Row2 and Col1 = 0 and Col2 > 7,
            "Get_Selection:" & Integer'Image (Row1) & Integer'Image (Col1)
                & Integer'Image (Row2) & Integer'Image (Col2));
    end Test_Selection;


    --  FLTK's ring:  the history and the screen, and their cells.
    procedure Test_Ring is
    begin
        declare
            Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "ring");
            Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
            Rows, Off : Natural;
            Raised    : Boolean := False;
            Flags     : Trm.Style_Flags;
        begin
            Term.Set_History_Rows (5);
            Rows := Term.Ring_Rows;
            Check (Rows = Term.Get_History_Rows + Term.Get_Display_Rows,
                "the ring is the history and the screen");
            Check (Term.Ring_Columns = Term.Get_Display_Columns, "as wide as the screen");
            Off := Term.Ring_Offset;
            Check (Term.History_Start = Off, "the history starts at the offset");
            Check (Term.History_End = (Off + 4) mod Rows, "and has its rows");
            Check (Term.Display_Start = (Off + 5) mod Rows, "the screen follows it");
            Check (Term.Display_End = (Off + Rows - 1) mod Rows, "to the ring's end");
            Term.Set_Text_Fore_Color (Red_Color);
            Term.Set_Text_Back_Color (Blue_Color);
            Term.Set_Text_Attrib (Trm.Attrib_Bold);
            Term.Append ("a");
            Term.Set_Text_Attrib (Trm.Attrib_Normal);
            Term.Set_Text_Fore_Color (Green_Color);
            Term.Append (Character'Val (16#C3#) & Character'Val (16#A9#));
            Check (Term.Cell_Text (Term.Display_Start, 0) = "a"
                    and Term.Cell_Attributes (Term.Display_Start, 0) = Trm.Attrib_Bold
                    and Term.Cell_Fore_Color (Term.Display_Start, 0) = Red_Color
                    and Term.Cell_Back_Color (Term.Display_Start, 0) = Blue_Color,
                "a cell's character, attributes and colors");
            Check (Term.Cell_Text (Term.Display_Start, 1)
                        = Character'Val (16#C3#) & Character'Val (16#A9#)
                    and Term.Cell_Attributes (Term.Display_Start, 1) = Trm.Attrib_Normal
                    and Term.Cell_Fore_Color (Term.Display_Start, 1) = Green_Color,
                "a UTF-8 character");
            Check (Term.Cell_Text (Term.Display_Start, 2) = " ", "an empty cell is a space");
            Flags := Term.Get_Style_Flags;
            Check (not Flags.Xterm_Fore and not Flags.Xterm_Back, "no xterm colors");
            Term.Set_Text_Fore_Color_Xterm (1);
            Flags := Term.Get_Style_Flags;
            Check (Flags.Xterm_Fore and not Flags.Xterm_Back, "an xterm foreground");
            Term.Set_Text_Back_Color_Xterm (2);
            Flags := Term.Get_Style_Flags;
            Check (Flags.Xterm_Fore and Flags.Xterm_Back, "and background");
            for K in 1 .. Term.Get_Display_Rows loop
                Term.Append ((1 => LF));
            end loop;
            Check (Term.Ring_Offset /= Off, "scrolling turns the ring");
            Check (Term.History_Start = Term.Ring_Offset, "and the history moves with it");
            begin
                Ignore := Term.Cell_Text (Term.Ring_Rows, 0) = "";
            exception
            when Constraint_Error =>
                Raised := True;
            end;
            Check (Raised, "a cell past the ring's last row raises (pofltk's HaltTerminalCell)");
            Raised := False;
            begin
                Ignore := Term.Cell_Fore_Color (0, Term.Ring_Columns) = Red_Color;
            exception
            when Constraint_Error =>
                Raised := True;
            end;
            Check (Raised, "and one past its last column");
        end;

        --  A selection in the history scrolled back to:  its rows count
        --  back from the screen's top.
        declare
            Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "ring");
            Term   : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 400, 300);
            Row1, Col1, Row2, Col2 : Integer;
            Selected : Boolean;
            Count    : Natural := 0;
        begin
            Term.Set_Text_Font (Courier);
            Term.Set_History_Rows (20);
            --  lines until the screen starts at the ring's row 0, with history
            loop
                Term.Append ("line" & LF);
                Count := Count + 1;
                exit when Count > 1000
                    or (Term.Get_History_Use >= 10 and Term.Display_Start = 0);
            end loop;
            Check (Term.Display_Start = 0, "the screen at the ring's start");
            Ignore := Prb.Capture (Term);
            Prb.Release;
            Ignore := Prb.Wheel (Window, 100, 100, 0, -3);
            Ignore := Prb.Capture (Term);
            Prb.Release;
            Ignore := Prb.Mouse (Window, Push, 8, 12);
            Ignore := Prb.Mouse (Window, Drag, 20, 12);
            Ignore := Prb.Mouse (Window, Drag, 30, 12);
            Ignore := Prb.Mouse (Window, Release, 30, 12);
            Selected := Term.Get_Selection (Row1, Col1, Row2, Col2);
            Check (Selected and Row1 < Term.Display_Start and Row1 = Row2,
                "a row of the history comes before the screen's:" & Row1'Image);
            Check (Row1 < 0, "and may be below 0");
        end;
    end Test_Ring;


    --  A terminal that counts what is sent to it.
    type Counted is new Trm.Terminal with record
        Draws, Pushes, Resizes : Natural := 0;
    end record;

    overriding procedure Draw
           (This : in out Counted);

    overriding function Handle
           (This  : in out Counted;
            Event : in     Event_Kind)
        return Event_Outcome;

    overriding procedure Resize
           (This       : in out Counted;
            X, Y, W, H : in     Integer);

    overriding procedure Draw
           (This : in out Counted) is
    begin
        This.Draws := This.Draws + 1;
        Trm.Terminal (This).Draw;
    end Draw;

    overriding function Handle
           (This  : in out Counted;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        if Event = Push then
            This.Pushes := This.Pushes + 1;
        end if;
        return Trm.Terminal (This).Handle (Event);
    end Handle;

    overriding procedure Resize
           (This       : in out Counted;
            X, Y, W, H : in     Integer) is
    begin
        This.Resizes := This.Resizes + 1;
        Trm.Terminal (This).Resize (X, Y, W, H);
    end Resize;

    procedure Test_Subclass is
        Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "subclass");
        Term   : Counted :=
            (Trm.Forge.Create (Window, 0, 0, 200, 100) with Draws | Pushes | Resizes => 0);
    begin
        Ignore := Prb.Capture (Term);
        Prb.Release;
        Check (Term.Draws = 1, "Draw is the program's:" & Natural'Image (Term.Draws));
        Ignore := Prb.Mouse (Window, Push, 50, 50);
        Ignore := Prb.Mouse (Window, Release, 50, 50);
        Check (Term.Pushes = 1, "and Handle");
        Term.Resize (0, 0, 150, 80);
        Check (Term.Resizes = 1, "and Resize");
        Window.Set_Resizable (Term);
        Window.Resize (0, 0, 300, 200);
        Check (Term.Resizes = 2 and Term.Get_W = 250,
            "called by FLTK too:" & Natural'Image (Term.Resizes) & Integer'Image (Term.Get_W));
    end Test_Subclass;


    --  A redraw on FLTK's timer is pending when the terminal goes.
    procedure Test_Pending is
        Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "pending");
    begin
        Window.Show;
        declare
            Term : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 200, 100);
        begin
            Term.Set_Redraw_Rate (0.01);
            Term.Append ("pending");
        end;
        for K in 1 .. 5 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
        Check (Window.Number_Of_Children = 0, "deleted with a redraw waiting");
    end Test_Pending;

begin

    Test_Settings;
    Test_Group;
    Test_Output;
    Test_UTF8;
    Test_Escapes;
    Test_History;
    Test_Sizes;
    Test_Drawing;
    Test_Selection;
    Test_Ring;
    Test_Subclass;
    Test_Pending;

    Summary;

end Test_Terminal;
