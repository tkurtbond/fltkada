


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 35: Fl_Text_Display::highlight_data keeps the
--  style buffer and the style table it is given, as pointers
--  (Fl_Text_Display.cxx:445-447), and with no styles it reads entry -1 of
--  the table.  It indexes the table from 'A', whatever the Ada array's
--  first index.  The test changes and frees the table and the style
--  buffer after Highlight_Data, and checks that the display still lays the
--  text out with the styles it was given: its text is wider at size 40
--  than at 10.  Also checks Clear_Highlight_Data, which turns the styles
--  off, as highlight_data (NULL, NULL, 0, ...) does in FLTK's
--  test/editor.cxx (PLAN.md, Phase 25).


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Highlight_Data is

    package TB  renames FLTK.Text_Buffers;
    package TD  renames FLTK.Widgets.Groups.Text_Displays;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Table_Access is access TD.Styles.Style_Array;
    type Buffer_Access is access TB.Text_Buffer;

    procedure Free is new Ada.Unchecked_Deallocation (TD.Styles.Style_Array, Table_Access);
    procedure Free is new Ada.Unchecked_Deallocation (TB.Text_Buffer, Buffer_Access);

    function Sized
           (Size : in FLTK.Font_Size)
        return TD.Styles.Style_Entry is
       (Hue => FLTK.Black_Color, Font => FLTK.Helvetica, Size => Size, others => <>);

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 100, "Test_Highlight_Data");
    Disp   : TD.Text_Display := TD.Forge.Create (Window, 0, 0, 300, 100);
    Text   : TB.Text_Buffer := TB.Forge.Create;

    --  Where the display puts the end of the first line.
    function Line_End return Integer is
        X, Y : Integer;
        Vert : Boolean;
    begin
        Disp.Redraw;
        FLTK.Check;
        Disp.Position_To_XY (4, X, Y, Vert);
        return X;
    end Line_End;

    Empty   : constant TD.Styles.Style_Array (TD.Styles.Style_Index'Last .. 'A') :=
        (others => Sized (10));
    From_B  : constant TD.Styles.Style_Array := ('B' => Sized (40));

    Styles  : Buffer_Access := new TB.Text_Buffer'(TB.Forge.Create);
    Table   : Table_Access := new TD.Styles.Style_Array'('A' => Sized (40));
    Small   : constant TD.Styles.Style_Array := ('A' => Sized (10));

    Plain_End, Small_End, Large_End : Integer;

    procedure Highlight_Empty is
    begin
        Disp.Highlight_Data (Styles.all, Empty);
    end Highlight_Empty;

    procedure Highlight_From_B is
    begin
        Disp.Highlight_Data (Styles.all, From_B);
    end Highlight_From_B;

begin

    Text.Set_Entire_Text ("wwww" & ASCII.LF);
    Styles.Set_Entire_Text ("AAAA" & ASCII.LF);
    Disp.Set_Buffer (Text);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    --  The first layout, just after the window is shown, puts the end
    --  further left than the next does (44 pixels against 49), in a C++
    --  program doing the same as well.
    Plain_End := Line_End;
    Plain_End := Line_End;
    Disp.Highlight_Data (Styles.all, Small);
    Small_End := Line_End;
    Disp.Highlight_Data (Styles.all, Table.all);
    Large_End := Line_End;
    Check (Large_End > Small_End,
        "size 40 is wider than size 10:" & Integer'Image (Large_End) & Integer'Image (Small_End));

    --  The table is copied.
    Table ('A') := Sized (10);
    Check (Line_End = Large_End, "a table changed after Highlight_Data is not used");
    Free (Table);
    Check (Line_End = Large_End, "a table freed after Highlight_Data is not used");

    --  pofltk 35: an empty table, or one FLTK would read from the wrong
    --  index, is refused, and the styles given before are kept.
    Raises (Highlight_Empty'Access, Constraint_Error'Identity,
        "an empty style table raises Constraint_Error");
    Raises (Highlight_From_B'Access, Constraint_Error'Identity,
        "a style table not starting at 'A' raises Constraint_Error");
    Check (Line_End = Large_End, "a refused table leaves the styles as they were");

    --  The style buffer is kept.
    Free (Styles);
    Check (Line_End = Large_End, "the style buffer is kept after its Ada buffer goes");

    --  Turning the styles off lays the text out as it was at first, and
    --  they can be turned on again.
    Disp.Clear_Highlight_Data;
    Check (Line_End = Plain_End, "Clear_Highlight_Data turns the styles off");
    Disp.Clear_Highlight_Data;
    Check (Line_End = Plain_End, "and can be called again");
    declare
        Again : TB.Text_Buffer := TB.Forge.Create;
    begin
        Again.Set_Entire_Text ("AAAA" & ASCII.LF);
        Disp.Highlight_Data (Again, ('A' => Sized (40)));
        Check (Line_End = Large_End, "Highlight_Data after Clear_Highlight_Data styles the text");
    end;

    Summary;

exception
when E : others =>
    Check (False, Ada.Exceptions.Exception_Information (E));
    Summary;
end Test_Highlight_Data;


