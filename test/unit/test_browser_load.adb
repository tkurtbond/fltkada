--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 40: what the browsers' Load does.  Fl_Browser::load adds a line
--  at each newline and one at the end of the file, so a file ending in a
--  newline ends with an empty line; it ends a line every 1023 bytes,
--  dropping the byte where it does; and given "" it only clears the
--  browser (Fl_Browser_load.cxx:38-52).  Fl_File_Browser::load returns
--  the number of the directory's entries, with those the filter hides,
--  not of the lines it lists (Fl_File_Browser.cxx:442-474).


with

    Ada.Directories,
    Ada.Streams.Stream_IO,
    Checks,
    FLTK.Widgets.Groups.Browsers.Textline.File;

use

    Checks;


procedure Test_Browser_Load is

    package Dirs renames Ada.Directories;
    package SIO renames Ada.Streams.Stream_IO;
    package TB renames FLTK.Widgets.Groups.Browsers.Textline;
    package FB renames FLTK.Widgets.Groups.Browsers.Textline.File;

    Dir : constant String := "test_browser_load.dir";

    procedure Write
           (Name, Text : in String)
    is
        File : SIO.File_Type;
    begin
        SIO.Create (File, SIO.Out_File, Dir & "/" & Name);
        String'Write (SIO.Stream (File), Text);
        SIO.Close (File);
    end Write;

    LF : constant Character := Character'Val (10);

    Lines : TB.Textline_Browser := TB.Forge.Create (0, 0, 100, 100);
    Files : FB.File_Browser := FB.Forge.Create (0, 0, 100, 100);
    Count : Natural;

begin

    if Dirs.Exists (Dir) then
        Dirs.Delete_Tree (Dir);
    end if;
    Dirs.Create_Directory (Dir);
    Write ("two.txt", "a" & LF & "b" & LF);
    Write ("long.txt", (1 .. 1030 => 'x'));
    Write ("other.dat", "");
    Dirs.Create_Directory (Dir & "/sub");

    Lines.Load (Dir & "/two.txt");
    Check (Lines.Number_Of_Lines = 3,
        "a file ending in a newline gives an empty last line:" &
        Integer'Image (Lines.Number_Of_Lines));
    Check (Lines.Number_Of_Lines = 3 and then Lines.Get_Line_Text (3) = "",
        "and that line is empty");

    Lines.Load (Dir & "/long.txt");
    Check (Lines.Number_Of_Lines = 2
        and then Lines.Get_Line_Text (1)'Length = 1023
        and then Lines.Get_Line_Text (2)'Length = 6,
        "a 1030-byte line is split at 1023, the 1024th byte dropped");

    Lines.Load ("");
    Check (Lines.Number_Of_Lines = 0, "Load ("""") clears the browser and raises nothing");

    Files.Set_Filter ("*.txt");
    Count := Files.Load (Dir);
    Check (Files.Number_Of_Lines = 4,
        "the file browser lists ../, sub/ and the two .txt files:" &
        Integer'Image (Files.Number_Of_Lines));
    Check (Count = 6,
        "Load returns the entries, with ./ and the one the filter hides:" &
        Natural'Image (Count));

    Dirs.Delete_Tree (Dir);
    Summary;

end Test_Browser_Load;
