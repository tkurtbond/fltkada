


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Text:  buffers, displays, styles and editors, after pofltk's
--  test/TestText.Mod.  A buffer's lifetime is test_buffer_life's, undo
--  test_undo_redo's, searching past the text test_text_search's, style
--  tables test_highlight_data's and file errors and transcoding
--  test_text_buffer_methods'.  Run from test/unit:  files go in
--  test_text.dir, made and removed here.


with

    Ada.Directories,
    Ada.Exceptions,
    System,
    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;

use type

    System.Address,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors.Insert_Mode,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors.Tab_Navigation;


procedure Test_Text is

    package Dirs renames Ada.Directories;
    package Prb  renames FLTK.Probe;
    package TB   renames FLTK.Text_Buffers;
    package TD   renames FLTK.Widgets.Groups.Text_Displays;
    package TE   renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package Win  renames FLTK.Widgets.Groups.Windows;

    LF  : constant Character := ASCII.LF;
    Dir : constant String := "test_text.dir";
    Fil : constant String := Dir & "/saved.txt";

    Buffer : TB.Text_Buffer := TB.Forge.Create;
    Styles : TB.Text_Buffer := TB.Forge.Create;
    Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "Test_Text");
    Disp   : TD.Text_Display := TD.Forge.Create (Window, 0, 0, 200, 100);
    Disp2  : TD.Text_Display := TD.Forge.Create (Window, 200, 0, 200, 100);
    Editor : TE.Text_Editor := TE.Forge.Create (Window, 0, 100, 400, 100);

    Calls, Place, Inserted, Deleted : Natural := 0;

    procedure Modified
           (At_Place     : in TB.Position;
            Ins, Del     : in Natural;
            Ignore       : in Natural;
            Deleted_Text : in String)
    is
        pragma Unreferenced (Deleted_Text);
    begin
        Calls := Calls + 1;
        Place := At_Place;
        Inserted := Ins;
        Deleted := Del;
    end Modified;

    --  Whether Set_Linenumber_Format refuses Format.
    function Refused
           (Format : in String)
        return Boolean is
    begin
        Disp.Set_Linenumber_Format (Format);
        return False;
    exception
    when Constraint_Error =>
        return True;
    end Refused;

    Ok         : Boolean;
    I, J       : TB.Position;
    X, Y       : Integer;
    In_View    : Boolean;
    Out_Of_View : Boolean;

begin

    --  Text.
    Check (Buffer.Length = 0 and Buffer.Get_Entire_Text = "", "a new buffer is empty");
    Buffer.Set_Entire_Text ("one two");
    Buffer.Append_Text (" three");
    Buffer.Insert_Text (0, "zero ");
    Check (Buffer.Get_Entire_Text = "zero one two three" and Buffer.Length = 18,
        "Set_Entire_Text, Append_Text, Insert_Text");
    Check (Buffer.Text_At (5, 8) = "one", "Text_At");
    Buffer.Remove_Text (0, 5);
    Buffer.Replace_Text (0, 3, "1");
    Check (Buffer.Get_Entire_Text = "1 two three", "Remove_Text, Replace_Text");
    Buffer.Set_Entire_Text ("caf" & Character'Val (16#C3#) & Character'Val (16#A9#) & "!");
    Check (Buffer.Length = 6 and Buffer.Character_At (3) = Character'Val (16#E9#)
            and Buffer.Byte_At (3) = Character'Val (16#C3#) and Buffer.Next_Char (3) = 5
            and Buffer.Prev_Char (5) = 3 and Buffer.UTF8_Align (4) = 3,
        "UTF-8:  Character_At, Byte_At, Next_Char, Prev_Char, UTF8_Align");
    Check (Buffer.Get_Tab_Width = 8, "tab stops every 8 columns to start with");

    --  The three selections.
    Buffer.Set_Entire_Text ("one two three four");
    Check (not Buffer.Has_Selection and not Buffer.Has_Secondary_Selection
            and not Buffer.Has_Highlight,
        "no selection to start with");
    Buffer.Set_Selection (4, 7);
    Buffer.Set_Secondary_Selection (8, 13);
    Buffer.Set_Highlight (14, 18);
    Check (Buffer.Get_Selection (I, J) and I = 4 and J = 7 and Buffer.Selection_Text = "two",
        "the primary selection");
    Check (Buffer.Get_Secondary_Selection (I, J) and I = 8 and J = 13
            and Buffer.Secondary_Selection_Text = "three",
        "the secondary selection");
    Buffer.Get_Highlight (I, J);
    Check (Buffer.Has_Highlight and I = 14 and J = 18 and Buffer.Get_Highlighted_Text = "four",
        "the highlight");
    Buffer.Replace_Text (0, 3, "first");
    Ok := Buffer.Get_Selection (I, J);
    Check (Ok and I = 6, "the selections move with the text");
    Ok := Buffer.Get_Secondary_Selection (I, J);
    Check (Ok and I = 10, "the secondary too");
    Buffer.Get_Highlight (I, J);
    Check (I = 16, "and the highlight");
    Buffer.Replace_Secondary_Selection ("3");
    Check (Buffer.Get_Entire_Text = "first two 3 four" and not Buffer.Has_Secondary_Selection,
        "Replace_Secondary_Selection");
    Buffer.Set_Secondary_Selection (6, 9);
    Buffer.Remove_Secondary_Selection;
    Check (Buffer.Get_Entire_Text = "first  3 four" and not Buffer.Has_Secondary_Selection,
        "Remove_Secondary_Selection");
    Buffer.Set_Secondary_Selection (0, 5);
    Buffer.Secondary_Unselect;
    Buffer.Unhighlight;
    Check (not Buffer.Has_Secondary_Selection and not Buffer.Has_Highlight,
        "Secondary_Unselect and Unhighlight");
    Buffer.Unselect;
    Check (not Buffer.Has_Selection, "Unselect");

    --  Lines, words and searching.
    Buffer.Set_Entire_Text ("first line" & LF & "second line" & LF & "third");
    Buffer.Set_Selection (6, 10);
    Buffer.Replace_Selection ("row");
    Check (Buffer.Line_Text (0) = "first row", "Replace_Selection; Line_Text");
    Check (Buffer.Line_Start (13) = 10 and Buffer.Line_End (13) = 21
            and Buffer.Count_Lines (0, Buffer.Length) = 2 and Buffer.Skip_Lines (0, 2) = 22
            and Buffer.Rewind_Lines (25, 1) = 10,
        "Line_Start, Line_End, Count_Lines, Skip_Lines, Rewind_Lines");
    Check (Buffer.Word_Start (13) = 10 and Buffer.Word_End (13) = 16, "Word_Start, Word_End");
    Check (Buffer.Search_Forward (0, "LINE", I) and I = 17, "Search_Forward, ignoring case");
    Ok := Buffer.Search_Forward (0, "LINE", I, Match_Case => True);
    Check (not Ok, "or matching it");
    Check (Buffer.Search_Backward (Buffer.Length, "r", I, Match_Case => True) and I = 25,
        "Search_Backward");
    Check (Buffer.Search_Forward (0, "third", I, True) and I = 22, "a match at the very end");
    Ok := Buffer.Search_Forward (23, "third", I, True);
    Check (not Ok, "none past it");
    Check (Buffer.Search_Backward (Buffer.Length, "third", I, True) and I = 22,
        "a match at the end, backward");
    Ok := Buffer.Search_Forward (0, "thirdd", I, True);
    Check (not Ok, "none running off the end");
    Check (Buffer.Findchar_Forward (0, 'w', I) and I = 8, "Findchar_Forward");
    Check (Buffer.Findchar_Backward (Buffer.Length, 's', I) and I = 10, "Findchar_Backward");

    --  Files.
    if Dirs.Exists (Dir) then
        Dirs.Delete_Tree (Dir);
    end if;
    Dirs.Create_Directory (Dir);
    Buffer.Set_Entire_Text ("saved" & LF);
    Buffer.Save_File (Fil);
    Buffer.Set_Entire_Text ("");
    Buffer.Load_File (Fil);
    Check (Buffer.Get_Entire_Text = "saved" & LF, "Save_File, Load_File");
    Buffer.Append_File (Fil);
    Buffer.Insert_File (Fil, 0);
    Check (Buffer.Length = 18, "Append_File, Insert_File");
    Buffer.Output_File (Fil, 0, 3);
    Buffer.Load_File (Fil);
    Check (Buffer.Get_Entire_Text = "sav", "Output_File");
    begin
        Buffer.Load_File (Dir & "/no such file");
        Check (False, "a file that isn't there raises");
    exception
    when Storage_Error =>
        Check (True, "a file that isn't there raises Storage_Error");
    end;
    Dirs.Delete_Tree (Dir);

    --  Told of each change.
    Buffer.Set_Entire_Text ("abc");
    Buffer.Add_Modify_Details_Callback (Modified'Unrestricted_Access);
    Buffer.Insert_Text (1, "XY");
    Check (Calls = 1 and Place = 1 and Inserted = 2 and Deleted = 0,
        "a modify callback after each change");
    Buffer.Remove_Text (0, 4);
    Check (Calls = 2 and Place = 0 and Inserted = 0 and Deleted = 4, "a removal");
    Buffer.Remove_Modify_Details_Callback (Modified'Unrestricted_Access);
    Buffer.Insert_Text (0, "Q");
    Check (Calls = 2, "and none once it is removed");

    --  Displays.
    Check (Prb.Capture (Disp), "a display without a buffer draws");
    Prb.Release;
    Check (Disp.Get_Linenumber_Width = 0
            and Disp.Get_Scrollbar_Width = FLTK.Static.Get_Default_Scrollbar_Size,
        "no line numbers, and Fl's scrollbar size, to start with");

    --  FLTK passes the line number format to snprintf with one int (pofltk
    --  153).  HaltLineNumberFormat's "%d %s" is the first.
    Check (Refused ("%d %s") and Refused ("%s") and Refused ("%n") and Refused ("%d%d")
            and Refused ("%ld") and Refused ("%f") and Refused ("%") and Refused ("%*d")
            and Refused ("%1234d") and Refused ("a" & ASCII.NUL & "%d"),
        "Set_Linenumber_Format refuses a format snprintf can't take with one int");
    Check (Disp.Get_Linenumber_Format = "%d", "and leaves the format as it was");
    Check (not Refused ("%%%-05d%%") and Disp.Get_Linenumber_Format = "%%%-05d%%"
            and not Refused ("%+.3i") and not Refused ("%#o") and not Refused ("% x")
            and not Refused ("%X:") and not Refused ("%u") and not Refused ("no number")
            and not Refused (""),
        "and takes %% and one d, i, o, u, x or X, with flags, width and precision");
    Disp.Set_Linenumber_Format ("%d");
    Check (Editor.Get_Insert_Mode = TE.After and Editor.Get_Tab_Mode = TE.Insert_Char,
        "an editor inserts (After), and Tab is typed, to start with");
    Buffer.Set_Entire_Text ("hello" & LF & "world");
    Disp.Set_Buffer (Buffer);
    Disp.Set_Insert_Position (2);
    Disp.Insert_Text ("XX");
    Check (Buffer.Get_Entire_Text = "heXXllo" & LF & "world" and Disp.Get_Insert_Position = 4,
        "Insert_Text types at the cursor");
    Check (Disp.Get_Buffer.Data.all'Address = Buffer'Address, "Get_Buffer");

    --  Move_Down keeps the cursor's x, so in a proportional font where it
    --  lands depends on the font's widths.  Courier makes it column 4.
    Disp.Set_Text_Font (Courier);
    Ok := Disp.Move_Down;
    I := Disp.Get_Insert_Position;
    Ok := Disp.Move_Right;
    J := Disp.Get_Insert_Position;
    Disp.Set_Text_Font (Helvetica);
    Check (I = 12 and J = 13 and Disp.Line_Start (J) = 8 and Disp.Line_End (1) = 7,
        "moving the cursor, and lines");
    Check (not Disp.Move_Down, "Move_Down is False at the last line");
    Disp.Set_Wrap_Mode (TD.Column, 3);
    Check (Prb.Capture (Disp) and Disp.Count_Lines (0, Buffer.Length) > 1, "wrapping");
    Prb.Release;
    --  "heXXllo" wraps two to a row in Courier, so "world" is the fifth row.
    --  A display lays out its rows only when it is drawn itself.
    Disp.Set_Text_Font (Courier);
    Ok := Prb.Capture (Disp);
    Prb.Release;
    Check (Disp.Wrapped_Row (0) = 0 and Disp.Wrapped_Row (3) = 0 and Disp.Wrapped_Row (4) = 1
            and Disp.Wrapped_Column (0, 1) = 1 and Disp.Wrapped_Column (1, 1) = 3
            and Disp.Wrapped_Column (3, 1) = 7 and Disp.Wrapped_Column (4, 1) = 1,
        "Wrapped_Row and Wrapped_Column:  the buffer's line and column of a row's");
    --  Every row, and past the last:  FLTK reads one past its rows' starts
    --  (pofltk 151), which valgrind sees.
    for R in 0 .. 20 loop
        I := Disp.Wrapped_Row (R);
        I := Disp.Wrapped_Column (R, 1);
    end loop;
    Check (Disp.Wrapped_Row (99) = 99 and Disp.Wrapped_Column (99, 2) = 2,
        "a row off the screen is itself");
    Disp.Set_Text_Font (Helvetica);
    Disp.Set_Wrap_Mode (TD.None);

    --  Position_To_XY:  a line out of view.
    Buffer.Set_Entire_Text ("");
    for N in 1 .. 20 loop
        Buffer.Append_Text ("line" & LF);
    end loop;
    Ok := Prb.Capture (Disp);
    Prb.Release;
    Disp.Position_To_XY (0, X, Y, Out_Of_View);
    In_View := not Out_Of_View;
    Disp.Position_To_XY (95, X, Y, Out_Of_View);
    Check (In_View and Out_Of_View,
        "Position_To_XY:  Vert_Out is False for line 1, True for line 20 of a short display");

    --  Styles:  A has a red background.
    Buffer.Set_Entire_Text ("XXXXXXXX");
    Styles.Set_Entire_Text ("AAAABBBB");
    Disp2.Set_Buffer (Buffer);
    Disp2.Highlight_Data
       (Styles,
        ('A' => (Hue => Black_Color, Font => Courier, Size => 14,
                 Back_Mode => TD.Styles.Background_Fill, Lines => TD.Styles.No_Line,
                 Background => Red_Color),
         'B' => (Hue => Black_Color, Font => Courier, Size => 14, others => <>)));
    Ok := Prb.Capture (Disp2);
    Disp2.Position_To_XY (1, X, Y, Out_Of_View);
    Check (Ok and not Out_Of_View
            and Prb.Pixel (X - Disp2.Get_X + 1, Y - Disp2.Get_Y + 2) = Prb.To_RGB (255, 0, 0),
        "style A's background is drawn");
    Disp2.Position_To_XY (6, X, Y, Out_Of_View);
    Check (Prb.Pixel (X - Disp2.Get_X + 1, Y - Disp2.Get_Y + 2) = Prb.To_RGB (255, 255, 255),
        "style B's isn't");
    Prb.Release;

    --  An editor.
    Buffer.Set_Entire_Text ("");
    Editor.Set_Buffer (Buffer);
    Ok := Editor.Take_Focus;
    Ok := Prb.Key (Keydown, Press ('a'), Mod_None, "a");
    Ok := Prb.Key (Keydown, Press ('b'), Mod_None, "b");
    Ok := Prb.Key (Keydown, Backspace_Key, Mod_None, (1 => ASCII.BS));
    Ok := Prb.Key (Keydown, Press ('c'), Mod_None, "c");
    Check (Buffer.Get_Entire_Text = "ac" and Editor.Get_Insert_Position = 2,
        "typing in an editor");
    Editor.Set_Insert_Mode (TE.Before);
    Check (Editor.Get_Insert_Mode = TE.Before, "Set_Insert_Mode");
    Editor.Set_Insert_Position (0);
    Ok := Prb.Key (Keydown, Press ('z'), Mod_None, "z");
    Check (Buffer.Get_Entire_Text = "zc", "typing over (Before)");
    Editor.Set_Tab_Mode (TE.Widget_Focus);
    Check (Editor.Get_Tab_Mode = TE.Widget_Focus, "Set_Tab_Mode");
    --  F35:  FLTK adds a Tab binding each time, and takes one away.
    Editor.Set_Tab_Mode (TE.Widget_Focus);
    Editor.Set_Tab_Mode (TE.Insert_Char);
    Check (Editor.Get_Tab_Mode = TE.Insert_Char,
        "Set_Tab_Mode (Widget_Focus) twice, then Insert_Char once, inserts");
    Editor.Set_Insert_Position (0);
    Ok := Prb.Key (Keydown, Tab_Key, Mod_None, (1 => ASCII.HT));
    Check (Buffer.Get_Entire_Text = ASCII.HT & "zc", "and Tab types a tab");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Text;



