


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Browsers:  lines, selection by program and by mouse, files and check
--  boxes, after pofltk's test/TestBrowsers.Mod.  Loading text is
--  test_browser_load's, the top line before drawing test_browser_top's,
--  the order of a directory's names test_numeric_sort's and icons
--  test_browser_icons'.  Run from test/unit, for names/.


with

    Ada.Exceptions,
    Checks,
    FLTK.Filenames,
    FLTK.Probe,
    FLTK.Widgets.Groups.Browsers.Check,
    FLTK.Widgets.Groups.Browsers.Textline.File,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Browsers.Textline.Multi,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Groups.Browsers.Scrollbar_Mode,
    FLTK.Widgets.Groups.Browsers.Textline.Column_Widths,
    FLTK.Widgets.Groups.Browsers.Textline.File.File_Kind,
    FLTK.Widgets.Groups.Browsers.Textline.File.Icon_Size;


procedure Test_Browser is

    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Brw renames FLTK.Widgets.Groups.Browsers;
    package Chk renames FLTK.Widgets.Groups.Browsers.Check;
    package Txl renames FLTK.Widgets.Groups.Browsers.Textline;
    package Fil renames FLTK.Widgets.Groups.Browsers.Textline.File;
    package Hld renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Mlt renames FLTK.Widgets.Groups.Browsers.Textline.Multi;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "Test_Browser");
    Lines  : Txl.Textline_Browser := Txl.Forge.Create (0, 0, 100, 100);
    Hold   : Hld.Hold_Browser := Hld.Forge.Create (Window, 100, 0, 150, 200);
    Boxes  : Chk.Check_Browser := Chk.Forge.Create (Window, 0, 200, 150, 100);

    Calls : Natural := 0;
    Ok    : Boolean;

    procedure Count
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Calls := Calls + 1;
    end Count;

    function Is_Line
           (This : in Txl.Textline_Browser'Class;
            Line : in Positive;
            Text : in String)
        return Boolean is
    begin
        return This.Get_Line_Text (Line) = Text;
    end Is_Line;

    --  Line numbers are qualified as Positive:  a literal would fit an
    --  Item_Cursor too.

    function Selected
           (This : in Txl.Textline_Browser'Class;
            Line : in Positive)
        return Boolean is
    begin
        return This.Is_Selected (Line);
    end Selected;

    function Displayed
           (This : in Txl.Textline_Browser'Class;
            Line : in Positive)
        return Boolean is
    begin
        return This.Is_Displayed (Line);
    end Displayed;

    function Visible
           (This : in Txl.Textline_Browser'Class;
            Line : in Positive)
        return Boolean is
    begin
        return This.Is_Visible (Line);
    end Visible;

    --  The first x, from 3, at which line 1 of Lines, drawn, isn't white;
    --  -1 if none is.
    function Ink
        return Integer
    is
        White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);
    begin
        Ok := Prb.Capture (Lines);
        for X in 3 .. 150 loop
            for Y in 4 .. 16 loop
                if Prb.Pixel (X, Y) /= White then
                    Prb.Release;
                    return X;
                end if;
            end loop;
        end loop;
        Prb.Release;
        return -1;
    end Ink;

    --  Sets the column widths from an array that dies with this frame.
    procedure Set_Widths is
        Widths : constant Txl.Column_Widths := (1 => 40);
    begin
        Lines.Set_Column_Widths (Widths);
    end Set_Widths;

    --  Writes over the stack that Set_Widths used.
    procedure Clobber is
        Junk : Txl.Column_Widths (1 .. 64) := (others => 7);
        Sink : Integer := 0;
    begin
        for W of Junk loop
            Sink := Sink + W;
            W := Sink;
        end loop;
        Ok := Sink /= 0;
    end Clobber;

    procedure Click
           (X, Y  : in Integer;
            State : in Modifier := Mod_None) is
    begin
        Ok := Prb.Mouse (Window, Push, X, Y, State => State);
        Ok := Prb.Mouse (Window, Release, X, Y, State => State);
    end Click;

    I : Integer;

begin

    --  Lines.
    Check (Lines.Number_Of_Lines = 0, "a browser starts empty");
    Lines.Add ("one");
    Lines.Add ("two");
    Lines.Add ("three");
    Lines.Insert (1, "zero");
    Lines.Insert (5, "four");
    Check (Lines.Number_Of_Lines = 5 and Is_Line (Lines, 1, "zero")
            and Is_Line (Lines, 3, "two") and Is_Line (Lines, 5, "four"),
        "Add, and Insert before a line or after the last");
    Lines.Remove (1);
    Check (Lines.Number_Of_Lines = 4 and Is_Line (Lines, 1, "one"), "Remove");
    Lines.Move (From => 4, To => 1);
    Check (Is_Line (Lines, 1, "four") and Is_Line (Lines, 2, "one") and Is_Line (Lines, 4, "three"),
        "Move (From, To):  line 4 to line 1");
    Lines.Move (From => 1, To => 4);
    Check (Is_Line (Lines, 1, "one") and Is_Line (Lines, 4, "four"),
        "and line 1 back to the end, counted after the removal");
    Lines.Swap (1, 4);
    Check (Is_Line (Lines, 1, "four") and Is_Line (Lines, 4, "one"), "Swap");
    Lines.Set_Line_Text (2, "TWO");
    Check (Is_Line (Lines, 2, "TWO"), "Set_Line_Text");
    Lines.Sort (Brw.Ascending);
    Check (Is_Line (Lines, 1, "TWO") and Is_Line (Lines, 2, "four") and Is_Line (Lines, 4, "three"),
        "Sort, by bytes");
    Lines.Sort (Brw.Descending);
    Check (Is_Line (Lines, 1, "three") and Is_Line (Lines, 4, "TWO"), "Sort, descending");
    Lines.Sort (Brw.Ascending, Ignore_Case => True);
    Check (Is_Line (Lines, 1, "four") and Is_Line (Lines, 2, "one") and Is_Line (Lines, 3, "three")
            and Is_Line (Lines, 4, "TWO"),
        "Sort, ignoring case");
    Lines.Sort (Brw.Descending, Ignore_Case => True);
    Check (Is_Line (Lines, 1, "TWO") and Is_Line (Lines, 4, "four"), "and descending");

    --  Selection.
    Check (Lines.Selected_Index = 0, "no line selected");
    Check (Lines.Set_Select (Positive'(2)) and Selected (Lines, 2) and Lines.Selected_Index = 2,
        "Set_Select");
    Check (not Lines.Set_Select (Positive'(2)), "Set_Select returns False when nothing changed");
    Check (Lines.Deselect and not Selected (Lines, 2) and not Lines.Deselect, "Deselect");

    --  Hiding a line.
    Lines.Hide_Line (2);
    Check (not Visible (Lines, 2) and Visible (Lines, 1) and Lines.Number_Of_Lines = 4,
        "Hide_Line");
    Lines.Show_Line (2);
    Check (Visible (Lines, 2), "Show_Line");

    --  Columns.
    Check (Lines.Get_Format_Character = '@' and Lines.Get_Column_Character = ASCII.HT,
        "the format and column characters");
    Lines.Set_Column_Character ('|');
    Check (Lines.Get_Column_Character = '|', "Set_Column_Character");
    Lines.Clear;
    Lines.Add ("|W");
    I := Ink;
    Check (I > 0 and I < 10, "with no column widths, the column character is drawn:" & I'Image);
    Set_Widths;
    Clobber;
    I := Ink;
    Check (I >= 40 and I < 50, "the column widths, copied:  the second column at 40:" & I'Image);
    Check (Lines.Get_Column_Widths = (1 => 40), "Get_Column_Widths");

    --  Text and scrollbars.
    Lines.Set_Text_Size (20);
    Check (Lines.Get_Text_Size = 20, "Set_Text_Size");
    Lines.Set_Scrollbar_Mode ((Horizontal => False, Vertical => True, Always_On => False));
    Check (Lines.Get_Scrollbar_Mode = (Horizontal => False, Vertical => True, Always_On => False),
        "Set_Scrollbar_Mode");

    --  Scrolling.
    Lines.Set_Text_Size (14);
    Lines.Clear;
    for N in 1 .. 50 loop
        Lines.Add ("line");
    end loop;
    Lines.Set_Top_Line (20);
    Check (Lines.Get_Top_Line = 20 and Displayed (Lines, 20) and not Displayed (Lines, 1),
        "Set_Top_Line");
    Lines.Make_Visible (1);
    Check (Displayed (Lines, 1), "Make_Visible");

    --  A hold browser, clicked.
    Hold.Set_Callback (Count'Unrestricted_Access);
    Hold.Add ("a");
    Hold.Add ("b");
    Hold.Add ("c");
    Click (110, 10);
    Check (Hold.Selected_Index = 0, "a browser never drawn selects nothing when clicked (FLTK)");
    Ok := Prb.Capture (Hold);
    Prb.Release;
    Check (Ok, "the hold browser drawn, by a capture");
    Calls := 0;
    Click (110, 32);
    Check (Hold.Selected_Index = 2 and Selected (Hold, 2) and Calls = 1,
        "a click selects a line and calls back");
    Click (110, 52);
    Check (Hold.Selected_Index = 3 and not Selected (Hold, 2) and Calls = 2,
        "and deselects the last");
    Click (110, 52);
    Check (Hold.Selected_Index = 3 and Calls = 3,
        "When_Release_Always:  called back with no change");
    Click (110, 150);
    Check (Hold.Selected_Index = 0 and not Selected (Hold, 3), "a click below the lines deselects");

    --  A multi browser.
    declare
        Multi : Mlt.Multi_Browser := Mlt.Forge.Create (Window, 250, 0, 150, 100);
    begin
        Multi.Add ("a");
        Multi.Add ("b");
        Multi.Add ("c");
        Ok := Prb.Capture (Multi);
        Prb.Release;
        Click (260, 12);
        Click (260, 52, Mod_Ctrl);
        Check (Selected (Multi, 1) and not Selected (Multi, 2) and Selected (Multi, 3)
                and Multi.Selected_Index = 3,
            "a multi browser:  Ctrl-click adds a line");
        Click (260, 32);
        Check (not Selected (Multi, 1) and Selected (Multi, 2) and not Selected (Multi, 3),
            "a click selects one line");
        Check (Multi.Set_Select (Positive'(1)) and Selected (Multi, 2),
            "Set_Select keeps the others in a multi browser");
        Check (Hold.Set_Select (Positive'(1)) and not Selected (Hold, 3)
                and Hold.Selected_Index = 1,
            "not in a hold browser");
    end;
    Check (Window.Number_Of_Children = 2,
        "a multi browser leaves its window when it goes");

    --  A file browser.
    declare
        Files : Fil.File_Browser := Fil.Forge.Create (Window, 250, 0, 150, 100);

        procedure Set_Filter is
            Filter : constant String := "a1*";
        begin
            Files.Set_Filter (Filter);
        end Set_Filter;

        procedure Load_Class_Wide
               (This : in out Txl.Textline_Browser'Class) is
        begin
            This.Load ("names");
        end Load_Class_Wide;

        All_Dirs  : Boolean := True;
        Has_Names : Boolean := False;
    begin
        Check (Files.Get_File_Kind = Fil.Files, "a file browser lists files");
        Check (Files.Get_Filter = "*", "with the filter *");
        Set_Filter;
        Clobber;
        Check (Files.Get_Filter = "a1*", "Set_Filter, copied");
        Files.Load (Dir => "names");
        Check (Files.Number_Of_Lines = 4 and Is_Line (Files, 1, "../")
                and Is_Line (Files, 2, "a1yb") and Is_Line (Files, 3, "a1za")
                and Is_Line (Files, 4, "a10"),
            "Load:  ../, then the files matching, in Numeric_Sort's order");
        Files.Clear;
        Files.Load ("names");
        Check (Files.Number_Of_Lines = 4 and Is_Line (Files, 4, "a10"),
            "Load (""names"") lists it too, as in C++ (FLTKAda-BUGS.md 108)");
        Files.Clear;
        Files.Load ("names", FLTK.Filenames.Numeric_Sort'Access);
        Check (Files.Number_Of_Lines = 4 and Is_Line (Files, 4, "a10"), "or with a sort given");
        Files.Clear;
        Load_Class_Wide (Files);
        Check (Files.Number_Of_Lines = 4 and Is_Line (Files, 4, "a10"),
            "and through Textline_Browser'Class");
        Files.Set_File_Kind (Fil.Directories);
        Check (Files.Get_File_Kind = Fil.Directories, "Set_File_Kind");
        Files.Load (Dir => ".");
        for L in 1 .. Files.Number_Of_Lines loop
            declare
                Name : constant String := Files.Get_Line_Text (L);
            begin
                All_Dirs := All_Dirs and Name (Name'Last) = '/';
                Has_Names := Has_Names or Name = "names/";
            end;
        end loop;
        --  test/unit has other directories besides names/, such as cairo/
        Check (All_Dirs and Is_Line (Files, 1, "../") and Has_Names,
            "or the directories alone");
        Files.Set_File_Kind (Fil.Files);
        begin
            Files.Load (Dir => "no such directory");
            Check (False, "a missing directory raises");
        exception
        when Txl.Browser_Load_Error =>
            Check (Files.Number_Of_Lines = 0, "a missing directory raises, and leaves no lines");
        end;
        Files.Set_Text_Size (20);
        Check (Files.Get_Text_Size = 20 and Files.Get_Icon_Size = 30,
            "Set_Text_Size sizes the icons too");
        Files.Set_Icon_Size (16);
        Check (Files.Get_Icon_Size = 16, "Set_Icon_Size");
    end;

    --  A check browser.
    Boxes.Set_Callback (Count'Unrestricted_Access);
    Boxes.Add ("a");
    Boxes.Add ("b", Checked => True);
    Boxes.Add ("c");
    Check (Boxes.Number_Of_Items = 3 and Boxes.Number_Checked = 1 and Boxes.Is_Checked (2)
            and Boxes.Item_Text (Positive'(2)) = "b",
        "a check browser's items, checked or not");
    Boxes.Set_Checked (1);
    Check (Boxes.Is_Checked (1) and Boxes.Number_Checked = 2, "Set_Checked");
    Boxes.Check_None;
    Check (Boxes.Number_Checked = 0, "Check_None");
    Boxes.Check_All;
    Check (Boxes.Number_Checked = 3, "Check_All");
    Boxes.Remove (1);
    Check (Boxes.Number_Of_Items = 2 and Boxes.Item_Text (Positive'(1)) = "b", "Remove");
    Boxes.Check_None;
    Ok := Prb.Capture (Boxes);
    Prb.Release;
    Calls := 0;
    Click (10, 226);
    Check (Boxes.Is_Checked (2) and not Boxes.Is_Checked (1) and Boxes.Selected_Index = 2
            and Calls = 0,
        "a click checks an item, not calling back (FLTK's When_Never)");
    Boxes.Set_When (When_Changed);
    Click (10, 226);
    Check (not Boxes.Is_Checked (2) and Calls = 1, "a second unchecks it; When_Changed calls back");
    Click (10, 210);
    Check (Boxes.Is_Checked (1) and Boxes.Selected_Index = 1 and Calls = 2, "another item");
    Boxes.Clear;
    Check (Boxes.Number_Of_Items = 0, "Clear");
    begin
        I := Boxes.Selected_Index;
        Check (I = 0, "Selected_Index with nothing selected is 0");
    exception
    when Occurrence : others =>
        Check (False, "Selected_Index with nothing selected raises "
            & Ada.Exceptions.Exception_Name (Occurrence));
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Browser;



