

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 96, 98 and 99.  Fl_Terminal's size setters
--  and resize leave the cursor, and the place ESC[s saved, where they
--  were, on a screen that may now be smaller, and the next character is
--  written outside its row.  In FLTK 1.4.5 that happens after
--  Set_Display_Rows and to the saved place; a resize, margins and the text
--  size keep the cursor on, and the columns don't go below what the width
--  allows, but they are checked too.  The rows written to are inside the
--  ring's block, so valgrind doesn't see them; the test checks the cursor.
--  Fl_Terminal::error_char is copied into a
--  cell of 4 bytes unchecked, and a control character as the error
--  character recurses without end.  A text size of 0 divides by zero, and
--  more cells than FLTK can allocate throw through the shim.


with

    Ada.Exceptions,
    Ada.Strings.Fixed,
    Checks,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Terminal_Fit is

    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Win renames FLTK.Widgets.Groups.Windows;

    ESC : constant Character := Character'Val (27);

    E_Acute : constant String := Character'Val (16#C3#) & Character'Val (16#A9#);

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Window : Win.Window := Win.Forge.Create (0, 0, 600, 400, "Test_Terminal_Fit");

    Term : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 600, 400);

    function On_Screen
        return Boolean is
    begin
        return Term.Get_Cursor_Row < Term.Get_Display_Rows
            and then Term.Get_Cursor_Column < Term.Get_Display_Columns;
    end On_Screen;

    function Where
        return String is
    begin
        return " at" & Natural'Image (Term.Get_Cursor_Row) & ","
            & Natural'Image (Term.Get_Cursor_Column) & " of"
            & Natural'Image (Term.Get_Display_Rows) & " by"
            & Natural'Image (Term.Get_Display_Columns);
    end Where;

    procedure Write is
    begin
        Term.Append ((1 .. 200 => 'w'));
        Pump (2);
    end Write;

    procedure Start_Over is
    begin
        Term.Resize (0, 0, 600, 400);
        Term.Clear;
        Pump (2);
    end Start_Over;

    procedure Error_Five is
    begin
        Term.Set_Error_Char ("ABCDE");
    end Error_Five;

    procedure Error_None is
    begin
        Term.Set_Error_Char ("");
    end Error_None;

    procedure Error_Control is
    begin
        Term.Set_Error_Char ((1 => Character'Val (1)));
    end Error_Control;

    procedure Error_Two is
    begin
        Term.Set_Error_Char ("ab");
    end Error_Two;

    procedure Error_Cut is
    begin
        Term.Set_Error_Char ((1 => Character'Val (16#C3#)));
    end Error_Cut;

    procedure Size_Zero is
    begin
        Term.Set_Text_Size (0);
    end Size_Zero;

    procedure Columns_Zero is
    begin
        Term.Set_Display_Columns (0);
    end Columns_Zero;

    procedure Columns_Huge is
    begin
        Term.Set_Display_Columns (1_000_000);
    end Columns_Huge;

    procedure History_Huge is
    begin
        Term.Set_History_Rows (Natural'Last);
    end History_Huge;

    procedure Make_No_Columns is
        Other : constant Trm.Terminal := Trm.Forge.Create (0, 0, 100, 100, 10, 0, 10);
    begin
        pragma Unreferenced (Other);
    end Make_No_Columns;

    procedure Make_Huge is
        Other : constant Trm.Terminal :=
            Trm.Forge.Create (0, 0, 100, 100, 10_000, 10_000, 10);
    begin
        pragma Unreferenced (Other);
    end Make_Huge;

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (3);

    --  pofltk 96: fewer rows, fewer columns.  Each starts with the cursor
    --  at the bottom right.
    Start_Over;
    Term.Set_Cursor_Row (Term.Get_Display_Rows - 1);
    Term.Set_Cursor_Column (Term.Get_Display_Columns - 1);
    Term.Set_Display_Rows (3);
    Check (On_Screen, "fewer rows leave the cursor on the screen:" & Where);
    Write;
    Start_Over;
    Term.Set_Cursor_Row (Term.Get_Display_Rows - 1);
    Term.Set_Cursor_Column (Term.Get_Display_Columns - 1);
    Term.Resize (0, 0, 600, 100);
    Check (On_Screen, "a shorter widget leaves the cursor on the screen:" & Where);
    Write;
    Start_Over;
    Term.Set_Cursor_Row (Term.Get_Display_Rows - 1);
    Term.Set_Cursor_Column (Term.Get_Display_Columns - 1);
    Term.Resize (0, 0, 200, 400);
    Check (On_Screen, "a narrower widget leaves the cursor on the screen:" & Where);
    Write;
    Start_Over;
    Term.Set_Cursor_Row (Term.Get_Display_Rows - 1);
    Term.Set_Cursor_Column (Term.Get_Display_Columns - 1);
    Term.Set_Margin_Left (300);
    Term.Set_Margin_Bottom (250);
    Check (On_Screen, "margins leave the cursor on the screen:" & Where);
    Write;
    Term.Set_Margin_Left (3);
    Term.Set_Margin_Bottom (3);
    Start_Over;
    Term.Set_Cursor_Row (Term.Get_Display_Rows - 1);
    Term.Set_Cursor_Column (Term.Get_Display_Columns - 1);
    Term.Set_Text_Size (40);
    Check (On_Screen, "a larger text size leaves the cursor on the screen:" & Where);
    Write;
    Term.Set_Text_Size (14);

    --  The place ESC[s saved.
    Start_Over;
    Term.Set_Cursor_Row (9);
    Term.Set_Cursor_Column (39);
    Term.Append (ESC & "[s");
    Term.Resize (0, 0, 150, 60);
    Term.Append (ESC & "[u");
    Check (On_Screen, "a saved place is restored on the screen:" & Where);
    Write;

    --  pofltk 98: the error character.
    Start_Over;
    Raises (Error_Five'Access, Constraint_Error'Identity, "an error character of 5 bytes");
    Raises (Error_None'Access, Constraint_Error'Identity, "an empty error character");
    Raises (Error_Control'Access, Constraint_Error'Identity, "a control error character");
    Raises (Error_Two'Access, Constraint_Error'Identity, "two error characters");
    Raises (Error_Cut'Access, Constraint_Error'Identity, "a cut error character");
    Term.Set_Error_Char (E_Acute);
    Check (Term.Get_Error_Char = E_Acute, "an error character of 2 bytes is kept");
    Term.Set_Show_Unknown (True);
    Term.Append ("a" & Character'Val (16#80#) & "b");
    Pump (2);
    Check (Ada.Strings.Fixed.Index (Term.Get_Text, "a" & E_Acute & "b") > 0,
        "an unknown byte shows the error character");
    Term.Append ((1 => Character'Val (2)));
    Pump (2);
    Term.Set_Show_Unknown (False);

    --  pofltk 99: sizes.
    Raises (Size_Zero'Access, Constraint_Error'Identity, "a text size of 0");
    Check (Term.Get_Text_Size > 0, "the text size is kept");
    Raises (Columns_Zero'Access, Constraint_Error'Identity, "no columns");
    Raises (Columns_Huge'Access, Constraint_Error'Identity, "a million columns");
    Raises (History_Huge'Access, Constraint_Error'Identity, "a history too long");
    Check (Term.Get_Display_Columns > 0, "the columns are kept");
    Raises (Make_No_Columns'Access, Constraint_Error'Identity, "a terminal made with no columns");
    Raises (Make_Huge'Access, Constraint_Error'Identity, "a terminal made too large");
    Write;

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Terminal_Fit;


