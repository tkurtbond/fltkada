--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/editor.cxx, built as FLTK builds it, at tutorial chapter
--  10: the simple text editor of the Programmer's Guide.  It has a File
--  menu (New, Open, Save, Save as, Quit), an Edit menu (Undo, Redo, Cut,
--  Copy, Paste, Delete), a Find menu (Find, Find Next, a non-modal Find and
--  Replace dialog, Replace Next) and a Window menu that toggles line
--  numbers, word wrap, a second editor on the same buffer in a tile, and
--  C/C++ syntax highlighting.  The title shows the file's name, with a
--  star while the text is changed.  A file named on the command line is
--  loaded.  Guided by pofltk's Editor.Mod.
--
--  Left out: fl_open_callback, which only does anything on macOS, and the
--  TESTING_ATTRIBUTES style table, off in FLTK's build.
--
--  FLTK's unfinished-style callback, style_unfinished_cb, does nothing,
--  so Highlight_Data is given none.


with

    Ada.Command_Line,
    Ada.Exceptions,
    Ada.Strings.Unbounded,
    FLTK.Asks,
    FLTK.Events,
    FLTK.Filenames,
    FLTK.Native_File_Choosers,
    FLTK.Static,
    FLTK.Text_Buffers,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Flex,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    FLTK.Widgets.Groups.Tiled,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Menu_Bars,
    System;

use type

    Ada.Strings.Unbounded.Unbounded_String,
    FLTK.Asks.Choice_Result,
    FLTK.Asks.Confirm_Result,
    FLTK.Modifier,
    FLTK.Native_File_Choosers.Show_Result,
    System.Address;


function Editor
    return Integer
is

    package SU  renames Ada.Strings.Unbounded;
    package Ask renames FLTK.Asks;
    package TB  renames FLTK.Text_Buffers;
    package Btn renames FLTK.Widgets.Buttons;
    package Flx renames FLTK.Widgets.Groups.Flex;
    package TD  renames FLTK.Widgets.Groups.Text_Displays;
    package TE  renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;
    package Til renames FLTK.Widgets.Groups.Tiled;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Mnu renames FLTK.Widgets.Menus;
    package NFC renames FLTK.Native_File_Choosers;
    package MB  renames FLTK.Widgets.Menus.Menu_Bars;
    package Sty renames FLTK.Widgets.Groups.Text_Displays.Styles;

    use type Sty.Style_Index;


    TS : constant := 14;  --  the editor's default text size

    Style_Table : constant Sty.Style_Array :=
       ('A' => (FLTK.Black_Color,      FLTK.Courier,          TS, others => <>),  --  plain
        'B' => (FLTK.Dark_Green_Color, FLTK.Helvetica_Italic, TS, others => <>),  --  line comments
        'C' => (FLTK.Dark_Green_Color, FLTK.Helvetica_Italic, TS, others => <>),  --  block comments
        'D' => (FLTK.Blue_Color,       FLTK.Courier,          TS, others => <>),  --  strings
        'E' => (FLTK.Dark_Red_Color,   FLTK.Courier,          TS, others => <>),  --  directives
        'F' => (FLTK.Dark_Red_Color,   FLTK.Courier_Bold,     TS, others => <>),  --  types
        'G' => (FLTK.Blue_Color,       FLTK.Courier_Bold,     TS, others => <>)); --  keywords

    type Word_List is array (Positive range <>) of SU.Unbounded_String;

    function "+" (S : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;

    Code_Keywords : constant Word_List :=
       (+"and", +"and_eq", +"asm", +"bitand", +"bitor", +"break", +"case", +"catch",
        +"compl", +"continue", +"default", +"delete", +"do", +"else", +"false", +"for",
        +"goto", +"if", +"new", +"not", +"not_eq", +"operator", +"or", +"or_eq",
        +"return", +"switch", +"template", +"this", +"throw", +"true", +"try", +"while",
        +"xor", +"xor_eq");

    Code_Types : constant Word_List :=
       (+"auto", +"bool", +"char", +"class", +"const", +"const_cast", +"double",
        +"dynamic_cast", +"enum", +"explicit", +"extern", +"float", +"friend", +"inline",
        +"int", +"long", +"mutable", +"namespace", +"private", +"protected", +"public",
        +"register", +"short", +"signed", +"sizeof", +"static", +"static_cast", +"struct",
        +"template", +"typedef", +"typename", +"union", +"unsigned", +"virtual", +"void",
        +"volatile");


    App_Window : Dbl.Double_Window := Dbl.Forge.Create (640, 480, "FLTK Editor");

    App_Menu_Bar : MB.Menu_Bar := MB.Forge.Create (App_Window, 0, 0, 640, 25);

    App_Tile : Til.Tiled_Group := Til.Forge.Create (App_Window, 0, 25, 640, 455);

    App_Editor : aliased TE.Text_Editor := TE.Forge.Create (App_Tile, 0, 25, 640, 455);

    App_Split_Editor : aliased TE.Text_Editor := TE.Forge.Create (App_Tile, 0, 480, 640, 0);

    App_Text_Buffer  : TB.Text_Buffer := TB.Forge.Create;
    App_Style_Buffer : TB.Text_Buffer := TB.Forge.Create;

    Replace_Dialog : Dbl.Double_Window := Dbl.Forge.Create (430, 110, "Find and Replace");

    Find_Text_Input : Inp.Text_Input :=
        Inp.Forge.Create (Replace_Dialog, 100, 10, 320, 25, "Find:");

    Replace_Text_Input : Inp.Text_Input :=
        Inp.Forge.Create (Replace_Dialog, 100, 40, 320, 25, "Replace:");

    Button_Field : Flx.Flex_Group :=
        Flx.Forge.Create (Replace_Dialog, 100, 70, 430 - 100, 40, Flx.Horizontal_Flex);

    Find_Next_Button : Btn.Button := Btn.Forge.Create (Button_Field, 0, 0, 0, 0, "Next");

    Replace_And_Find_Button : Btn.Button :=
        Btn.Forge.Create (Button_Field, 0, 0, 0, 0, "Replace");

    Close_Button : Btn.Button := Btn.Forge.Create (Button_Field, 0, 0, 0, 0, "Close");

    Text_Changed      : Boolean := False;
    App_Filename      : SU.Unbounded_String;
    Last_Find_Text    : SU.Unbounded_String;
    Last_Replace_Text : SU.Unbounded_String;




    --  Chapter 2: the title and the changed flag  --

    procedure Update_Title is
    begin
        if App_Filename /= SU.Null_Unbounded_String then
            declare
                Name : constant String := FLTK.Filenames.Base_Name (SU.To_String (App_Filename));
            begin
                if Text_Changed then
                    App_Window.Set_Label (Name & " *");
                else
                    App_Window.Set_Label (Name);
                end if;
            end;
        else
            App_Window.Set_Label ("FLTK Editor");
        end if;
    end Update_Title;


    procedure Set_Changed
           (Value : in Boolean) is
    begin
        if Value /= Text_Changed then
            Text_Changed := Value;
            Update_Title;
        end if;
    end Set_Changed;


    procedure Set_Filename
           (Name : in String) is
    begin
        App_Filename := SU.To_Unbounded_String (Name);
        Update_Title;
    end Set_Filename;




    --  Chapter 3: the editor  --

    procedure Text_Changed_Callback
           (Place, Inserted, Deleted, Restyled : in Natural;
            Deleted_Text                       : in String)
    is
        pragma Unreferenced (Place, Restyled, Deleted_Text);
    begin
        if Inserted /= 0 or Deleted /= 0 then
            Set_Changed (True);
        end if;
    end Text_Changed_Callback;


    procedure Menu_New_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Text_Changed then
            if Ask.Choice
                  ("Changes in your text have not been saved." & ASCII.LF &
                       "Do you want to start a new text anyway?",
                   "New", "Cancel") = Ask.Second
            then
                return;
            end if;
        end if;
        App_Text_Buffer.Set_Entire_Text ("");
        Set_Filename ("");
        Set_Changed (False);
    end Menu_New_Callback;








    --  Chapter 4: files  --

    procedure Save_File
           (Name : in String) is
    begin
        App_Text_Buffer.Save_File (Name);
        Set_Filename (Name);
        Set_Changed (False);
    exception
    when E : Storage_Error =>
        Ask.Alert ("Failed to save file" & ASCII.LF & Name & ASCII.LF &
            Ada.Exceptions.Exception_Message (E));
    end Save_File;


    --  Fills in the chooser's file and directory from the current name.
    procedure Preset
           (Chooser : in out NFC.Native_File_Chooser)
    is
        Full : constant String := SU.To_String (App_Filename);
    begin
        if Full /= "" then
            declare
                Name : constant String := FLTK.Filenames.Base_Name (Full);
            begin
                Chooser.Set_Preset_File (Name);
                Chooser.Set_Directory (Full (Full'First .. Full'Last - Name'Length));
            end;
        end if;
    end Preset;


    procedure Menu_Save_As_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        File_Chooser : NFC.Native_File_Chooser := NFC.Forge.Create;
    begin
        File_Chooser.Set_Title ("Save File As...");
        File_Chooser.Set_Kind (NFC.Browse_Save_File);
        Preset (File_Chooser);
        if File_Chooser.Show = NFC.Picked then
            Save_File (File_Chooser.Get_Filename);
        end if;
    end Menu_Save_As_Callback;


    procedure Menu_Save_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if App_Filename = SU.Null_Unbounded_String then
            Menu_Save_As_Callback (Item);
        else
            Save_File (SU.To_String (App_Filename));
        end if;
    end Menu_Save_Callback;


    procedure Menu_Quit_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Text_Changed then
            case Ask.Choice
                ("The current file has not been saved." & ASCII.LF &
                     "Would you like to save it now?",
                 "Cancel", "Save", "Don't Save")
            is
            when Ask.First =>
                return;
            when Ask.Second =>
                Menu_Save_Callback (Item);
                return;
            when Ask.Third =>
                null;
            end case;
        end if;
        FLTK.Static.Hide_All_Windows;
    end Menu_Quit_Callback;


    procedure Load
           (Name : in String) is
    begin
        App_Text_Buffer.Load_File (Name);
        Set_Filename (Name);
        Set_Changed (False);
    exception
    when E : Storage_Error =>
        Ask.Alert ("Failed to load file" & ASCII.LF & Name & ASCII.LF &
            Ada.Exceptions.Exception_Message (E));
    end Load;


    procedure Menu_Open_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Text_Changed then
            case Ask.Choice
                ("The current file has not been saved." & ASCII.LF &
                     "Would you like to save it now?",
                 "Cancel", "Save", "Don't Save")
            is
            when Ask.First =>
                return;
            when Ask.Second =>
                Menu_Save_Callback (Item);
            when Ask.Third =>
                null;
            end case;
        end if;
        declare
            File_Chooser : NFC.Native_File_Chooser := NFC.Forge.Create;
        begin
            File_Chooser.Set_Title ("Open File...");
            File_Chooser.Set_Kind (NFC.Browse_File);
            Preset (File_Chooser);
            if File_Chooser.Show = NFC.Picked then
                Load (File_Chooser.Get_Filename);
            end if;
        end;
    end Menu_Open_Callback;


    function Args_Handler
           (Index : in Positive)
        return Natural
    is
        Arg : constant String := Ada.Command_Line.Argument (Index);
    begin
        if Arg'Length = 0 or else Arg (Arg'First) /= '-' then
            Load (Arg);
            return 1;
        end if;
        return 0;
    end Args_Handler;




    --  Chapter 5: cut, copy and paste  --

    --  The editor with the focus, if it is one of the two.
    function Focused_Editor
        return access TE.Text_Editor
    is
        Focus : constant access FLTK.Widgets.Widget'Class := FLTK.Events.Get_Focus;
    begin
        if Focus /= null then
            if Focus.all'Address = App_Editor'Address then
                return App_Editor'Unchecked_Access;
            elsif Focus.all'Address = App_Split_Editor'Address then
                return App_Split_Editor'Unchecked_Access;
            end if;
        end if;
        return null;
    end Focused_Editor;


    procedure Menu_Undo_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        E : constant access TE.Text_Editor := Focused_Editor;
    begin
        if E /= null then
            TE.KF_Undo (E.all);
        end if;
    end Menu_Undo_Callback;


    procedure Menu_Redo_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        E : constant access TE.Text_Editor := Focused_Editor;
    begin
        if E /= null then
            TE.KF_Redo (E.all);
        end if;
    end Menu_Redo_Callback;


    procedure Menu_Cut_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        E : constant access TE.Text_Editor := Focused_Editor;
    begin
        if E /= null then
            TE.KF_Cut (E.all);
        end if;
    end Menu_Cut_Callback;


    procedure Menu_Copy_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        E : constant access TE.Text_Editor := Focused_Editor;
    begin
        if E /= null then
            TE.KF_Copy (E.all);
        end if;
    end Menu_Copy_Callback;


    procedure Menu_Paste_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        E : constant access TE.Text_Editor := Focused_Editor;
    begin
        if E /= null then
            TE.KF_Paste (E.all);
        end if;
    end Menu_Paste_Callback;


    procedure Menu_Delete_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        E : constant access TE.Text_Editor := Focused_Editor;
    begin
        if E /= null then
            TE.KF_Delete (E.all);
        end if;
    end Menu_Delete_Callback;




    --  Chapter 6: find  --

    --  The split editor if it has the focus, else the main one.
    function Search_Editor
        return access TE.Text_Editor
    is
        E : constant access TE.Text_Editor := Focused_Editor;
    begin
        if E /= null and then E.all'Address = App_Split_Editor'Address then
            return E;
        end if;
        return App_Editor'Unchecked_Access;
    end Search_Editor;


    function Find_Next
           (Needle : in String)
        return Boolean
    is
        E     : constant access TE.Text_Editor := Search_Editor;
        Place : TB.Position := E.Get_Insert_Position;
    begin
        if App_Text_Buffer.Search_Forward (Place, Needle, Place) then
            App_Text_Buffer.Set_Selection (Place, Place + Needle'Length);
            E.Set_Insert_Position (Place + Needle'Length);
            E.Show_Insert_Position;
            return True;
        else
            Ask.Alert ("No further occurrences of '" & Needle & "' found!");
            return False;
        end if;
    end Find_Next;


    procedure Find_Next
           (Needle : in String)
    is
        Ignore : constant Boolean := Find_Next (Needle);
    begin
        null;
    end Find_Next;


    procedure Menu_Find_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Answer : SU.Unbounded_String := Last_Find_Text;
    begin
        if Ask.Text_Input ("Find in text:", Answer) = Ask.Confirm then
            Last_Find_Text := Answer;
            Find_Next (SU.To_String (Answer));
        end if;
    end Menu_Find_Callback;


    procedure Menu_Find_Next_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Last_Find_Text /= SU.Null_Unbounded_String then
            Find_Next (SU.To_String (Last_Find_Text));
        else
            Menu_Find_Callback (Item);
        end if;
    end Menu_Find_Next_Callback;




    --  Chapter 7: replace  --

    procedure Replace_Selection
           (New_Text : in String)
    is
        E             : constant access TE.Text_Editor := Search_Editor;
        Start, Finish : TB.Position;
    begin
        if App_Text_Buffer.Get_Selection (Start, Finish) then
            App_Text_Buffer.Remove_Selection;
            App_Text_Buffer.Insert_Text (Start, New_Text);
            App_Text_Buffer.Set_Selection (Start, Start + New_Text'Length);
            E.Set_Insert_Position (Start + New_Text'Length);
            E.Show_Insert_Position;
        end if;
    end Replace_Selection;


    --  Replace_Dialog::show
    procedure Show_Replace_Dialog is
    begin
        Find_Text_Input.Set_Value (SU.To_String (Last_Find_Text));
        Replace_Text_Input.Set_Value (SU.To_String (Last_Replace_Text));
        Replace_Dialog.Show;
    end Show_Replace_Dialog;


    procedure Find_Next_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Last_Find_Text := SU.To_Unbounded_String (Find_Text_Input.Get_Value);
        Last_Replace_Text := SU.To_Unbounded_String (Replace_Text_Input.Get_Value);
        if Last_Find_Text /= SU.Null_Unbounded_String then
            Find_Next (SU.To_String (Last_Find_Text));
        end if;
    end Find_Next_Callback;


    procedure Replace_And_Find_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Replace_Selection (Replace_Text_Input.Get_Value);
        Find_Next_Callback (Item);
    end Replace_And_Find_Callback;


    procedure Close_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Replace_Dialog.Hide;
    end Close_Callback;


    procedure Menu_Replace_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Show_Replace_Dialog;
    end Menu_Replace_Callback;


    procedure Menu_Replace_Next_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Last_Find_Text = SU.Null_Unbounded_String then
            Menu_Replace_Callback (Item);
        else
            Replace_Selection (SU.To_String (Last_Replace_Text));
            Find_Next (SU.To_String (Last_Find_Text));
        end if;
    end Menu_Replace_Next_Callback;




    --  Chapter 8: line numbers and word wrap  --

    function Item_Value
           (Item : in FLTK.Widgets.Widget'Class)
        return Boolean is
    begin
        return Mnu.Menu'Class (Item).Chosen.Data.Get_State;
    end Item_Value;


    procedure Menu_Linenumbers_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Width : constant Natural := (if Item_Value (Item) then 40 else 0);
    begin
        App_Editor.Set_Linenumber_Width (Width);
        App_Editor.Redraw;
        App_Split_Editor.Set_Linenumber_Width (Width);
        App_Split_Editor.Redraw;
    end Menu_Linenumbers_Callback;


    procedure Menu_Wordwrap_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Mode : constant TD.Wrap_Mode := (if Item_Value (Item) then TD.Bounds else TD.None);
    begin
        App_Editor.Set_Wrap_Mode (Mode, 0);
        App_Editor.Redraw;
        App_Split_Editor.Set_Wrap_Mode (Mode, 0);
        App_Split_Editor.Redraw;
    end Menu_Wordwrap_Callback;




    --  Chapter 9: the split editor  --

    procedure Menu_Split_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Item_Value (Item) then
            declare
                H_Split : constant Integer := App_Tile.Get_H / 2;
            begin
                App_Editor.Resize (App_Tile.Get_W, H_Split);
                App_Split_Editor.Resize
                   (App_Tile.Get_X, App_Tile.Get_Y + H_Split,
                    App_Tile.Get_W, App_Tile.Get_H - H_Split);
                App_Split_Editor.Show;
            end;
        else
            App_Editor.Resize (App_Tile.Get_W, App_Tile.Get_H);
            App_Split_Editor.Resize
               (App_Tile.Get_X, App_Tile.Get_Y + App_Tile.Get_H, App_Tile.Get_W, 0);
            App_Split_Editor.Hide;
        end if;
        App_Tile.Set_Resizable (App_Editor);
        App_Tile.Reset_Sizes;
        App_Tile.Redraw;
    end Menu_Split_Callback;




    --  Chapter 10: syntax highlighting  --

    --  style_parse: works out the styles of Text into Style, which comes
    --  in holding the old ones and is the same length.  C's text is ended
    --  by a NUL, which the look-ahead here gives past Text's end.
    procedure Style_Parse
           (Text  : in     String;
            Style : in out String)
    is
        NUL : constant Character := ASCII.NUL;

        function At_Pos (K : in Integer) return Character is
            (if K <= Text'Last then Text (K) else NUL);

        function Is_Lower (C : in Character) return Boolean is (C in 'a' .. 'z');

        function Is_Word (C : in Character) return Boolean is (Is_Lower (C) or C = '_');

        function Is_Alnum (C : in Character) return Boolean is
            (C in 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9');

        function Starts
               (K      : in Integer;
                Prefix : in String)
            return Boolean is
        begin
            for J in Prefix'Range loop
                if At_Pos (K + J - Prefix'First) /= Prefix (J) then
                    return False;
                end if;
            end loop;
            return True;
        end Starts;

        function Listed
               (Word : in String;
                List : in Word_List)
            return Boolean is
        begin
            for W of List loop
                if SU.To_String (W) = Word then
                    return True;
                end if;
            end loop;
            return False;
        end Listed;

        --  The longest word looked up, as with FLTK's 255-byte buffer.
        Max_Word : constant := 254;

        Current : Character;
        Col     : Natural := 0;
        Last    : Boolean := False;
        I       : Integer := Text'First;
        S       : Integer := Style'First;

        procedure Put
               (C : in Character) is
        begin
            Style (S) := C;
            S := S + 1;
        end Put;

        procedure Put_Word
               (C    : in Character;
                Upto : in Integer) is
        begin
            while I < Upto loop
                Put (C);
                I := I + 1;
                Col := Col + 1;
            end loop;
            I := I - 1;
            Last := True;
        end Put_Word;

    begin
        if Text'Length = 0 then
            return;
        end if;
        Current := Style (Style'First);
        while I <= Text'Last loop
            if Current in 'B' | 'F' | 'G' then
                Current := 'A';
            end if;
            if Current = 'A' then
                --  Check for directives, comments, strings, and keywords...
                if Col = 0 and Text (I) = '#' then
                    Current := 'E';
                elsif Starts (I, "//") then
                    Current := 'B';
                    while I <= Text'Last and then Text (I) /= ASCII.LF loop
                        Put ('B');
                        I := I + 1;
                    end loop;
                    exit when I > Text'Last;
                elsif Starts (I, "/*") then
                    Current := 'C';
                elsif Starts (I, "\""") then
                    --  Quoted quote...
                    Put (Current);
                    Put (Current);
                    I := I + 1;
                    Col := Col + 2;
                    goto Next_Char;
                elsif Text (I) = '"' then
                    Current := 'D';
                elsif not Last and Is_Word (Text (I)) then
                    --  Might be a keyword...
                    declare
                        Temp : Integer := I;
                    begin
                        while Is_Word (At_Pos (Temp)) and Temp - I < Max_Word loop
                            Temp := Temp + 1;
                        end loop;
                        if not Is_Word (At_Pos (Temp)) then
                            if Listed (Text (I .. Temp - 1), Code_Types) then
                                Put_Word ('F', Temp);
                                goto Next_Char;
                            elsif Listed (Text (I .. Temp - 1), Code_Keywords) then
                                Put_Word ('G', Temp);
                                goto Next_Char;
                            end if;
                        end if;
                    end;
                end if;
            elsif Current = 'C' and Starts (I, "*/") then
                --  Close a C comment...
                Put (Current);
                Put (Current);
                I := I + 1;
                Current := 'A';
                Col := Col + 2;
                goto Next_Char;
            elsif Current = 'D' then
                --  Continuing in string...
                if Starts (I, "\""") then
                    --  Quoted end quote...
                    Put (Current);
                    Put (Current);
                    I := I + 1;
                    Col := Col + 2;
                    goto Next_Char;
                elsif Text (I) = '"' then
                    --  End quote...
                    Put (Current);
                    Col := Col + 1;
                    Current := 'A';
                    goto Next_Char;
                end if;
            end if;

            --  Copy style info...
            if Current = 'A' and (Text (I) = '{' or Text (I) = '}') then
                Put ('G');
            else
                Put (Current);
            end if;
            Col := Col + 1;

            Last := Is_Alnum (Text (I)) or Text (I) = '_' or Text (I) = '.';

            if Text (I) = ASCII.LF then
                --  Reset column and possibly reset the style
                Col := 0;
                if Current in 'B' | 'E' then
                    Current := 'A';
                end if;
            end if;

            <<Next_Char>>
            I := I + 1;
        end loop;
    end Style_Parse;


    --  style_init
    procedure Style_Init is
        Text  : constant String := App_Text_Buffer.Get_Entire_Text;
        Style : String (Text'Range) := (others => 'A');
    begin
        Style_Parse (Text, Style);
        App_Style_Buffer.Set_Entire_Text (Style);
    end Style_Init;


    --  style_update
    procedure Style_Update
           (Place, Inserted, Deleted, Restyled : in Natural;
            Deleted_Text                       : in String)
    is
        pragma Unreferenced (Restyled, Deleted_Text);
        Start, Finish : TB.Position;
        Last          : Character;
    begin
        --  If this is just a selection change, just unselect the style buffer...
        if Inserted = 0 and Deleted = 0 then
            App_Style_Buffer.Unselect;
            return;
        end if;

        --  Track changes in the text buffer...
        if Inserted > 0 then
            --  Insert characters into the style buffer...
            App_Style_Buffer.Replace_Text
               (Place, Place + Deleted, String'(1 .. Inserted => 'A'));
        else
            --  Just delete characters in the style buffer...
            App_Style_Buffer.Remove_Text (Place, Place + Deleted);
        end if;

        --  Select the area that was just updated to avoid unnecessary
        --  callbacks.  FLTK's select would be given an end before the start
        --  when more is deleted than inserted; it takes the two the other
        --  way round, which Set_Selection can do but for a negative end.
        App_Style_Buffer.Set_Selection
           (Place, Integer'Max (0, Place + Inserted - Deleted));

        --  Re-parse the changed region; we do this by parsing from the
        --  beginning of the line of the changed region to the end of the
        --  line of the changed region...  Then we check the last style
        --  character and keep updating if we have a multi-line comment
        --  character...
        Start := App_Text_Buffer.Line_Start (Place);
        Finish := App_Text_Buffer.Line_End (Place + Inserted);
        declare
            Text  : constant String := App_Text_Buffer.Text_At (Start, Finish);
            Style : String := App_Style_Buffer.Text_At (Start, Finish);
        begin
            Last := (if Start = Finish then ASCII.NUL else Style (Style'Last));
            Style_Parse (Text, Style);
            App_Style_Buffer.Replace_Text (Start, Finish, Style);
            App_Editor.Redisplay_Range (Start, Finish);
            if Start /= Finish and then Last = Style (Style'Last) then
                return;
            end if;
        end;

        --  Either the user deleted some text, or the last character on the
        --  line changed styles, so reparse the remainder of the buffer...
        Finish := App_Text_Buffer.Length;
        declare
            Text  : constant String := App_Text_Buffer.Text_At (Start, Finish);
            Style : String := App_Style_Buffer.Text_At (Start, Finish);
        begin
            Style_Parse (Text, Style);
            App_Style_Buffer.Replace_Text (Start, Finish, Style);
            App_Editor.Redisplay_Range (Start, Finish);
        end;
    end Style_Update;


    procedure Menu_Syntaxhighlight_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Item_Value (Item) then
            Style_Init;
            App_Editor.Highlight_Data (App_Style_Buffer, Style_Table);
            App_Text_Buffer.Add_Modify_Details_Callback (Style_Update'Unrestricted_Access);
        else
            App_Text_Buffer.Remove_Modify_Details_Callback (Style_Update'Unrestricted_Access);
            App_Editor.Clear_Highlight_Data;
        end if;
        App_Editor.Redraw;
        if Item_Value (Item) then
            App_Split_Editor.Highlight_Data (App_Style_Buffer, Style_Table);
        else
            App_Split_Editor.Clear_Highlight_Data;
        end if;
        App_Split_Editor.Redraw;
    end Menu_Syntaxhighlight_Callback;




    Ix    : Mnu.Extended_Index;
    Count : Natural;

begin
    --  Chapter 1
    App_Window.Set_X_Class ("fl_editor");

    --  Chapter 2
    App_Menu_Bar.Add
       ("File/Quit Editor", Menu_Quit_Callback'Unrestricted_Access, FLTK.Mod_Command + 'q');
    App_Window.Set_Callback (Menu_Quit_Callback'Unrestricted_Access);

    --  Chapter 3
    App_Text_Buffer.Add_Modify_Details_Callback (Text_Changed_Callback'Unrestricted_Access);
    App_Editor.Set_Buffer (App_Text_Buffer);
    App_Editor.Set_Text_Font (FLTK.Courier);
    Ix := App_Menu_Bar.Find_Index (Menu_Quit_Callback'Unrestricted_Access);
    App_Menu_Bar.Insert
       (Ix, "New", Menu_New_Callback'Unrestricted_Access, FLTK.Mod_Command + 'n');

    --  Chapter 4
    Ix := App_Menu_Bar.Find_Index (Menu_Quit_Callback'Unrestricted_Access);
    App_Menu_Bar.Insert
       (Ix, "Open", Menu_Open_Callback'Unrestricted_Access, FLTK.Mod_Command + 'o',
        FLTK.Flag_Divider);
    App_Menu_Bar.Insert
       (Ix + 1, "Save", Menu_Save_Callback'Unrestricted_Access, FLTK.Mod_Command + 's');
    App_Menu_Bar.Insert
       (Ix + 2, "Save as...", Menu_Save_As_Callback'Unrestricted_Access,
        FLTK.Mod_Command + 'S', FLTK.Flag_Divider);

    --  Chapter 5
    App_Menu_Bar.Add
       ("Edit/Undo", Menu_Undo_Callback'Unrestricted_Access, FLTK.Mod_Command + 'z');
    App_Menu_Bar.Add
       ("Edit/Redo", Menu_Redo_Callback'Unrestricted_Access, FLTK.Mod_Command + 'Z',
        FLTK.Flag_Divider);
    App_Menu_Bar.Add
       ("Edit/Cut", Menu_Cut_Callback'Unrestricted_Access, FLTK.Mod_Command + 'x');
    App_Menu_Bar.Add
       ("Edit/Copy", Menu_Copy_Callback'Unrestricted_Access, FLTK.Mod_Command + 'c');
    App_Menu_Bar.Add
       ("Edit/Paste", Menu_Paste_Callback'Unrestricted_Access, FLTK.Mod_Command + 'v');
    App_Menu_Bar.Add ("Edit/Delete", Menu_Delete_Callback'Unrestricted_Access);

    --  Chapter 6
    App_Menu_Bar.Add
       ("Find/Find...", Menu_Find_Callback'Unrestricted_Access, FLTK.Mod_Command + 'f');
    App_Menu_Bar.Add
       ("Find/Find Next", Menu_Find_Next_Callback'Unrestricted_Access,
        FLTK.Mod_Command + 'g', FLTK.Flag_Divider);

    --  Chapter 7
    Button_Field.Set_Margin (0, 5, 10, 10);
    Button_Field.Set_Gap (10);
    Find_Next_Button.Set_Callback (Find_Next_Callback'Unrestricted_Access);
    Replace_And_Find_Button.Set_Callback (Replace_And_Find_Callback'Unrestricted_Access);
    Close_Button.Set_Callback (Close_Callback'Unrestricted_Access);
    Replace_Dialog.Set_Non_Modal;
    App_Menu_Bar.Add
       ("Find/Replace...", Menu_Replace_Callback'Unrestricted_Access,
        FLTK.Mod_Command + 'r');
    App_Menu_Bar.Add
       ("Find/Replace Next", Menu_Replace_Next_Callback'Unrestricted_Access,
        FLTK.Mod_Command + 't');

    --  Chapter 8
    App_Menu_Bar.Add
       ("Window/Line Numbers", Menu_Linenumbers_Callback'Unrestricted_Access,
        FLTK.Mod_Command + 'l', FLTK.Flag_Toggle);
    App_Menu_Bar.Add
       ("Window/Word Wrap", Menu_Wordwrap_Callback'Unrestricted_Access,
        FLTK.No_Key, FLTK.Flag_Toggle);

    --  Chapter 9
    App_Split_Editor.Set_Buffer (App_Text_Buffer);
    App_Split_Editor.Set_Text_Font (FLTK.Courier);
    App_Split_Editor.Hide;
    App_Tile.Set_Size_Range (App_Editor, 25, 25);
    App_Tile.Set_Size_Range (App_Split_Editor, 25, 25);
    App_Tile.Reset_Sizes;
    App_Window.Set_Resizable (App_Tile);
    App_Tile.Set_Resizable (App_Editor);
    App_Menu_Bar.Add
       ("Window/Split", Menu_Split_Callback'Unrestricted_Access,
        FLTK.Mod_Command + 'i', FLTK.Flag_Toggle);

    --  Chapter 10
    App_Menu_Bar.Add
       ("Window/Syntax Highlighting", Menu_Syntaxhighlight_Callback'Unrestricted_Access,
        FLTK.No_Key, FLTK.Flag_Toggle);

    --  Chapter 4's command line.  FLTK's Fl::args returns 0 for an option
    --  it doesn't know, which editor.cxx ignores; here that raises.
    begin
        FLTK.Static.Parse_Args (Count, Args_Handler'Unrestricted_Access);
    exception
    when FLTK.Static.Argument_Error =>
        null;
    end;
    App_Window.Show_With_Args;
    return FLTK.Run;
end Editor;
