


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Phase 12's Text_Buffer methods: Next_Char and Prev_Char give places
--  (FLTKAda-BUGS.md 78), Is_Word_Separator and Estimate_Lines work, the
--  highlight is FLTK's (79), a file's errors say why (80), and a file that
--  isn't UTF-8 is read whole (FLTK-issues.md F26), with Was_Transcoded and
--  FLTK's warning.  Run from test/unit.


with

    Ada.Directories,
    Ada.Exceptions,
    Ada.Streams.Stream_IO,
    Checks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Text_Buffers;

use

    Checks;


procedure Test_Text_Buffer_Methods is

    package Dirs renames Ada.Directories;
    package SIO renames Ada.Streams.Stream_IO;
    package Prb renames FLTK.Probe;
    package TB renames FLTK.Text_Buffers;

    Dir : constant String := "test_text_buffer_methods.dir";

    LF       : constant Character := Character'Val (10);
    E_Latin  : constant Character := Character'Val (16#E9#);
    E_UTF8   : constant String := Character'Val (16#C3#) & Character'Val (16#A9#);
    Euro_1252 : constant Character := Character'Val (16#80#);
    Euro_UTF8 : constant String :=
        Character'Val (16#E2#) & Character'Val (16#82#) & Character'Val (16#AC#);

    procedure Write
           (Name, Text : in String)
    is
        File : SIO.File_Type;
    begin
        SIO.Create (File, SIO.Out_File, Dir & "/" & Name);
        String'Write (SIO.Stream (File), Text);
        SIO.Close (File);
    end Write;

    function Read
           (Name : in String)
        return String
    is
        File : SIO.File_Type;
    begin
        SIO.Open (File, SIO.In_File, Dir & "/" & Name);
        declare
            Text : String (1 .. Natural (SIO.Size (File)));
        begin
            String'Read (SIO.Stream (File), Text);
            SIO.Close (File);
            return Text;
        end;
    end Read;

    Buffer : TB.Text_Buffer := TB.Forge.Create;

    procedure Places is
        Long : constant String (1 .. 300) := (others => 'x');
    begin
        Buffer.Set_Entire_Text ("a" & E_UTF8 & "b");
        Check (Buffer.Next_Char (0) = 1 and Buffer.Next_Char (1) = 3,
            "Next_Char steps over a two-byte character:" &
            Natural'Image (Buffer.Next_Char (1)));
        Check (Buffer.Prev_Char (3) = 1 and Buffer.Prev_Char (1) = 0,
            "Prev_Char steps back over it:" & Natural'Image (Buffer.Prev_Char (3)));
        Check (Buffer.Next_Char (4) = 4 and Buffer.Prev_Char (0) = 0,
            "Next_Char at the end is the end, Prev_Char at the start the start");
        Check (Buffer.Prev_Char (10) = 3,
            "Prev_Char from past the end is the last character's:" &
            Natural'Image (Buffer.Prev_Char (10)));
        Buffer.Set_Entire_Text (Long);
        Check (Buffer.Next_Char (299) = 300 and Buffer.Prev_Char (300) = 299,
            "and both past 255 (FLTKAda-BUGS.md 78)");
    end Places;

    procedure Words_And_Lines is
        NBSP : constant String := Character'Val (16#C2#) & Character'Val (16#A0#);
    begin
        Buffer.Set_Entire_Text ("a_" & E_UTF8 & " b" & NBSP & "c");
        Check (not Buffer.Is_Word_Separator (0) and not Buffer.Is_Word_Separator (1)
                and not Buffer.Is_Word_Separator (2),
            "a letter, an underscore and an accented letter are in a word");
        Check (Buffer.Is_Word_Separator (4) and Buffer.Is_Word_Separator (6),
            "a space and a no-break space separate words");
        Check (Buffer.Is_Word_Separator (Buffer.Length),
            "and the end is a separator");
        Buffer.Set_Entire_Text ("ab" & LF & "cdefgh" & LF);
        Check (Buffer.Estimate_Lines (0, Buffer.Length, 100) = 2,
            "Estimate_Lines counts the line feeds:" &
            Natural'Image (Buffer.Estimate_Lines (0, Buffer.Length, 100)));
        Check (Buffer.Estimate_Lines (0, Buffer.Length, 4) = 3,
            "and a break in a line longer than Line_Length:" &
            Natural'Image (Buffer.Estimate_Lines (0, Buffer.Length, 4)));
        Check (Buffer.Estimate_Lines (3, Buffer.Length, 100) = 1,
            "from Start:" & Natural'Image (Buffer.Estimate_Lines (3, Buffer.Length, 100)));
    end Words_And_Lines;

    procedure Highlight is
        Start, Finish : TB.Position;
    begin
        Buffer.Set_Entire_Text ("abcdef");
        Buffer.Get_Highlight (Start, Finish);
        Check (not Buffer.Has_Highlight and Start = 0 and Finish = 0,
            "nothing highlighted at first, at 0 and 0");
        Buffer.Set_Highlight (2, 4);
        Buffer.Get_Highlight (Start, Finish);
        Check (Buffer.Has_Highlight and Start = 2 and Finish = 4, "Set_Highlight, Get_Highlight");
        Buffer.Insert_Text (0, "XYZ");
        Buffer.Get_Highlight (Start, Finish);
        Check (Start = 5 and Finish = 7 and Buffer.Get_Highlighted_Text = "cd",
            "the highlight moves with the text (FLTKAda-BUGS.md 79):" &
            Natural'Image (Start) & Natural'Image (Finish));
        Buffer.Unhighlight;
        Buffer.Get_Highlight (Start, Finish);
        Check (not Buffer.Has_Highlight and Start = 0 and Finish = 0,
            "and Unhighlight clears it:" & Natural'Image (Start) & Natural'Image (Finish));
    end Highlight;

    Alerted : Boolean := False;
    Said    : Boolean := False;

    procedure Answer is
        Ignore : Boolean;
    begin
        Alerted := Prb.Modal;
        Said := Prb.Has_Label (TB.File_Encoding_Warning);
        Ignore := Prb.Close_Modal;
    end Answer;

    procedure Files is

        procedure Load_Missing is
        begin
            Buffer.Load_File (Dir & "/no-such.txt");
        end Load_Missing;

        Failure : Ada.Exceptions.Exception_Occurrence;
    begin
        Write ("utf8.txt", "caf" & E_UTF8 & LF);
        Write ("latin1.txt", "caf" & E_Latin & LF);
        Write ("latin1-end.txt", "caf" & E_Latin);
        Write ("cp1252.txt", "5 " & Euro_1252 & " " & E_Latin & " " & E_Latin & LF);

        Check (Buffer.Has_Transcoding_Warning, "FLTK warns of a file that isn't UTF-8 by default");
        Buffer.Set_Transcoding_Warning (False);
        Check (not Buffer.Has_Transcoding_Warning, "Set_Transcoding_Warning (False)");

        Buffer.Load_File (Dir & "/utf8.txt");
        Check (Buffer.Get_Entire_Text = "caf" & E_UTF8 & LF and not Buffer.Was_Transcoded,
            "a UTF-8 file is read as it is");
        Buffer.Load_File (Dir & "/latin1.txt");
        Check (Buffer.Get_Entire_Text = "caf" & E_UTF8 & LF,
            "a Latin-1 file ending in an accented letter and a line feed is read whole (F26):" &
            Natural'Image (Buffer.Length) & " bytes");
        Check (Buffer.Was_Transcoded, "and Was_Transcoded is True");
        Buffer.Load_File (Dir & "/latin1-end.txt");
        Check (Buffer.Get_Entire_Text = "caf" & E_UTF8,
            "and one ending in the accented letter (F26):" &
            Natural'Image (Buffer.Length) & " bytes");
        Buffer.Load_File (Dir & "/cp1252.txt", Buffer => 3);
        Check (Buffer.Get_Entire_Text = "5 " & Euro_UTF8 & " " & E_UTF8 & " " & E_UTF8 & LF,
            "a CP1252 file read three bytes at a time:" & Natural'Image (Buffer.Length) &
            " bytes");
        Buffer.Load_File (Dir & "/utf8.txt", Buffer => 4);
        Check (Buffer.Get_Entire_Text = "caf" & E_UTF8 & LF and not Buffer.Was_Transcoded,
            "a UTF-8 character split between reads is kept");

        Buffer.Set_Entire_Text ("<>");
        Buffer.Insert_File (Dir & "/utf8.txt", 1);
        Check (Buffer.Get_Entire_Text = "<caf" & E_UTF8 & LF & ">", "Insert_File");
        Buffer.Append_File (Dir & "/latin1-end.txt");
        Check (Buffer.Get_Entire_Text = "<caf" & E_UTF8 & LF & ">caf" & E_UTF8, "Append_File");

        Buffer.Set_Entire_Text ("abc" & E_UTF8 & "def");
        Buffer.Save_File (Dir & "/saved.txt", Buffer => 2);
        Check (Read ("saved.txt") = "abc" & E_UTF8 & "def", "Save_File");
        Buffer.Output_File (Dir & "/part.txt", 1, 5);
        Check (Read ("part.txt") = "bc" & E_UTF8, "Output_File");

        --  The reason, where FLTK's 1 and 2 were given to strerror.
        Raises (Load_Missing'Unrestricted_Access, Storage_Error'Identity,
            "a missing file raises Storage_Error");
        begin
            Buffer.Load_File (Dir & "/no-such.txt");
        exception
            when E : Storage_Error =>
                Ada.Exceptions.Save_Occurrence (Failure, E);
        end;
        Check (Ada.Exceptions.Exception_Message (Failure) = "No such file or directory",
            "saying why (FLTKAda-BUGS.md 80): " & Ada.Exceptions.Exception_Message (Failure));
        begin
            Buffer.Save_File (Dir & "/no-such-dir/out.txt");
        exception
            when E : Storage_Error =>
                Ada.Exceptions.Save_Occurrence (Failure, E);
        end;
        Check (Ada.Exceptions.Exception_Message (Failure) = "No such file or directory",
            "and so does a file that can't be written: " &
            Ada.Exceptions.Exception_Message (Failure));
        begin
            Buffer.Load_File (Dir);
        exception
            when E : Storage_Error =>
                Ada.Exceptions.Save_Occurrence (Failure, E);
        end;
        Check (Ada.Exceptions.Exception_Message (Failure) = "Is a directory",
            "and a directory: " & Ada.Exceptions.Exception_Message (Failure));

        --  FLTK's warning, before the load returns.
        Buffer.Set_Transcoding_Warning (True);
        Check (Buffer.Has_Transcoding_Warning, "Set_Transcoding_Warning (True)");
        FLTK.Static.Add_Timeout (0.2, Answer'Unrestricted_Access);
        Buffer.Load_File (Dir & "/latin1.txt");
        Check (Alerted and Said, "a file that isn't UTF-8 alerts, with File_Encoding_Warning");
        Check (Buffer.Get_Entire_Text = "caf" & E_UTF8 & LF, "and is read");
    end Files;

begin

    if Dirs.Exists (Dir) then
        Dirs.Delete_Tree (Dir);
    end if;
    Dirs.Create_Directory (Dir);

    Places;
    Words_And_Lines;
    Highlight;
    Files;

    Dirs.Delete_Tree (Dir);
    Summary;

end Test_Text_Buffer_Methods;



