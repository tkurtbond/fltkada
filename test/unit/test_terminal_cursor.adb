


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Phase 12's Terminal cursor moves, ported from pofltk's TestCursor.
--  FLTK's restore_cursor misses a place saved at column 1 (pofltk 97),
--  and its tabs stop at the first tab stop whatever the count (F24);
--  these must not.  The moves, Cursor_Home, Set_Cursor_Row and
--  Set_Cursor_Column don't redraw in FLTK (pofltk 99); here they must, as
--  Redraw_Style says, and FLTK's Per_Write must redraw more than once
--  (F23).


with

    Checks,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Terminal_Cursor is

    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Trm.Redraw_Style;

    ESC : constant Character := Character'Val (27);

    Draws : Natural := 0;

    type Counted is new Trm.Terminal with null record;

    overriding procedure Draw
           (This : in out Counted);

    overriding procedure Draw
           (This : in out Counted) is
    begin
        Draws := Draws + 1;
        Trm.Terminal (This).Draw;
    end Draw;

    Window : Win.Window := Win.Forge.Create (0, 0, 600, 400, "Test_Terminal_Cursor");

    Term : Counted := (Trm.Forge.Create (Window, 0, 0, 600, 400) with null record);

    procedure Settle is
    begin
        for N in 1 .. 5 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Settle;

    function At_Place
           (Row, Column : in Natural)
        return Boolean is
    begin
        return Term.Get_Cursor_Row = Row and Term.Get_Cursor_Column = Column;
    end At_Place;

    function Where
        return String is
    begin
        return " at" & Natural'Image (Term.Get_Cursor_Row) & ","
            & Natural'Image (Term.Get_Cursor_Column);
    end Where;

    procedure Place
           (Row, Column : in Natural) is
    begin
        Term.Set_Cursor_Row (Row);
        Term.Set_Cursor_Column (Column);
    end Place;

    procedure Moves is
        Last_Row    : constant Natural := Term.Get_Display_Rows - 1;
        Last_Column : constant Natural := Term.Get_Display_Columns - 1;
    begin
        Place (3, 10);
        Term.Cursor_Up;
        Term.Cursor_Left (2);
        Check (At_Place (2, 8), "up, left" & Where);
        Term.Cursor_Down (2);
        Term.Cursor_Right (3);
        Check (At_Place (4, 11), "down, right" & Where);
        Term.Cursor_End_Of_Line;
        Check (Term.Get_Cursor_Column = Last_Column, "end of the line" & Where);
        Term.Cursor_Start_Of_Line;
        Check (Term.Get_Cursor_Column = 0, "start of the line" & Where);
        Term.Set_Cursor_Column (4);
        Term.Cursor_CR;
        Check (At_Place (4, 0), "carriage return" & Where);
        Term.Set_Cursor_Column (4);
        Term.Cursor_CRLF (2);
        Check (At_Place (6, 0), "CRLF twice" & Where);
        Term.Cursor_Tab_Right;
        Check (Term.Get_Cursor_Column = 8, "a tab stop" & Where);
        Term.Cursor_Tab_Right (2);
        Check (Term.Get_Cursor_Column = 24, "two tab stops" & Where);
        Term.Cursor_Tab_Left;
        Check (Term.Get_Cursor_Column = 16, "a tab stop back" & Where);
        Term.Cursor_Tab_Left (5);
        Check (Term.Get_Cursor_Column = 0, "tabs back stop at the start" & Where);
        Term.Cursor_Home;
        Term.Cursor_Up;
        Check (At_Place (0, 0), "up stops at the top" & Where);
        Term.Cursor_Left (3);
        Check (At_Place (0, 0), "left stops at the start" & Where);

        --  Without Scroll, the edges stop the cursor.
        Place (Last_Row, Last_Column - 1);
        Term.Cursor_Down (5);
        Check (Term.Get_Cursor_Row = Last_Row, "down stops at the bottom" & Where);
        Term.Cursor_Right (5);
        Check (At_Place (Last_Row, Last_Column), "right stops at the end" & Where);

        --  With it, Right goes on to the next line, and Down scrolls.
        Term.Clear;
        Place (0, Last_Column);
        Term.Append ("A");
        Place (1, Last_Column);
        Term.Cursor_Right (3, Scroll => True);
        Check (At_Place (2, 2), "right with Scroll goes on to the next line" & Where);
        Place (Last_Row, 0);
        Term.Cursor_Down (1, Scroll => True);
        Check (Term.Get_Cursor_Row = Last_Row, "down with Scroll stays on the bottom row" & Where);
        Place (0, 0);
        Term.Append ("Z");
        Term.Cursor_Up (1, Scroll => True);
        Check (At_Place (0, 1), "up with Scroll stays on the top row" & Where);

        --  A huge count with Scroll ends.
        Place (0, 0);
        Term.Cursor_Right (Positive'Last, Scroll => True);
        Check (Term.Get_Cursor_Row = Last_Row, "a huge count to the right ends" & Where);
    end Moves;

    procedure Save_Restore is
    begin
        Term.Clear;
        Place (2, 5);
        Term.Save_Cursor;
        Term.Cursor_Home;
        Term.Restore_Cursor;
        Check (At_Place (2, 5), "restored" & Where);

        --  The place FLTK's restore_cursor misses (pofltk 97).
        Place (2, 1);
        Term.Save_Cursor;
        Term.Cursor_Home;
        Term.Restore_Cursor;
        Check (At_Place (2, 1), "restored to column 1 (pofltk 97)" & Where);

        --  ESC[u still misses it: FLTK's own, which can't be helped.
        Term.Cursor_Home;
        Term.Append (ESC & "[u");
        Check (At_Place (0, 0), "ESC[u from column 1 still does nothing" & Where);

        --  ESC[s saves where Restore_Cursor restores.
        Place (4, 7);
        Term.Append (ESC & "[s");
        Term.Cursor_Home;
        Term.Restore_Cursor;
        Check (At_Place (4, 7), "Restore_Cursor restores what ESC[s saved" & Where);
    end Save_Restore;

    procedure Redraws is

        function Drawn
               (Style : in Trm.Redraw_Style;
                Move  : not null access procedure)
            return Natural is
        begin
            Term.Set_Redraw_Style (Style);
            Settle;
            Draws := 0;
            Move.all;
            Settle;
            return Draws;
        end Drawn;

        procedure Right is
        begin
            Term.Cursor_Right;
        end Right;

        procedure Left is
        begin
            Term.Cursor_Left;
        end Left;

        procedure Write is
        begin
            Term.Append ("w");
        end Write;

        procedure Home is
        begin
            Term.Set_Cursor_Row (3);
            Term.Set_Cursor_Column (3);
            Settle;
            Draws := 0;
            Term.Cursor_Home;
        end Home;

        procedure Set_Row is
        begin
            Term.Set_Cursor_Row (2);
        end Set_Row;

        procedure Set_Column is
        begin
            Term.Set_Cursor_Column (5);
        end Set_Column;

        procedure Write_Then_Switch is
        begin
            Term.Append ("w");
            Term.Set_Redraw_Style (Trm.Per_Write);
        end Write_Then_Switch;

        N : Natural;
    begin
        N := Drawn (Trm.Per_Write, Right'Access);
        Check (N > 0, "a move redraws with Per_Write:" & Natural'Image (N));
        N := Drawn (Trm.Per_Write, Left'Access);
        Check (N > 0, "and the next one too (F23):" & Natural'Image (N));
        N := Drawn (Trm.Per_Write, Home'Access);
        Check (N > 0, "so does Cursor_Home (pofltk 99):" & Natural'Image (N));
        N := Drawn (Trm.Per_Write, Set_Row'Access);
        Check (N > 0, "and Set_Cursor_Row (pofltk 99):" & Natural'Image (N));
        N := Drawn (Trm.Per_Write, Set_Column'Access);
        Check (N > 0, "and Set_Cursor_Column (pofltk 99):" & Natural'Image (N));
        N := Drawn (Trm.Per_Write, Write'Access);
        Check (N > 0, "and a write after them (F23):" & Natural'Image (N));
        N := Drawn (Trm.Rate_Limited, Right'Access);
        Check (N > 0, "a move redraws with Rate_Limited after Per_Write (F23):" &
            Natural'Image (N));
        N := Drawn (Trm.Rate_Limited, Write_Then_Switch'Access);
        Check (N > 0, "a write pending when the style changes is drawn (F23):" &
            Natural'Image (N));
        N := Drawn (Trm.Per_Write, Write'Access);
        Check (N > 0, "and Per_Write redraws after it (F23):" & Natural'Image (N));
        N := Drawn (Trm.No_Redraw, Left'Access);
        Check (N = 0, "a move doesn't redraw with No_Redraw:" & Natural'Image (N));
        Term.Set_Redraw_Style (Trm.Rate_Limited);
    end Redraws;

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Settle;

    Moves;
    Save_Restore;
    Redraws;

    Window.Hide;
    Summary;

end Test_Terminal_Cursor;



