--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  PLAN.md, Phase 25: a database's file.  Floating point is written and
--  read in the C locale whatever LC_NUMERIC says, as FLTK's C_LOCALE
--  flag makes it (Fl_Preferences.cxx:773-836); FLTK's own programs set
--  it.  Without the flag, a program that sets LC_NUMERIC to German
--  writes 1.5 as "1,5".


with

    Ada.Directories,
    Ada.Exceptions,
    Ada.Strings.Fixed,
    Ada.Text_IO,
    Checks,
    FLTK.Environment,
    Interfaces.C.Strings;

use

    Checks,
    FLTK.Environment;


procedure Test_Pref_Files is

    package Dir renames Ada.Directories;

    use type Interfaces.C.Strings.chars_ptr;

    --  glibc's LC_NUMERIC.
    LC_Numeric : constant Interfaces.C.int := 1;

    function setlocale
           (Category : in Interfaces.C.int;
            Locale   : in Interfaces.C.char_array)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, setlocale, "setlocale");

    Where : constant String := Dir.Current_Directory & "/test_pref_files.tmp";

    --  The whole of a file, its lines joined.
    function Contents
           (Name : in String)
        return String
    is
        File   : Ada.Text_IO.File_Type;
        Result : String (1 .. 4096);
        Last   : Natural := 0;
    begin
        Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Name);
        while not Ada.Text_IO.End_Of_File (File) loop
            declare
                Line : constant String := Ada.Text_IO.Get_Line (File);
            begin
                Result (Last + 1 .. Last + Line'Length + 1) := Line & '|';
                Last := Last + Line'Length + 1;
            end;
        end loop;
        Ada.Text_IO.Close (File);
        return Result (1 .. Last);
    end Contents;

    function Has
           (Text, Part : in String)
        return Boolean is
    begin
        return Ada.Strings.Fixed.Index (Text, Part) > 0;
    end Has;

begin

    if Dir.Exists (Where) then
        Dir.Delete_Tree (Where);
    end if;
    Dir.Create_Directory (Where);

    if setlocale (LC_Numeric, Interfaces.C.To_C ("de_DE.utf8")) = Interfaces.C.Strings.Null_Ptr
    then
        Ada.Text_IO.Put_Line ("skipped: no de_DE.utf8 locale");
    else
        declare
            DB : constant Database := Forge.From_Filesystem (Where, "fltkada", "locale");
        begin
            declare
                R : Pref_Group'Class := Forge.Root (DB);
            begin
                R.Set ("x", Long_Float'(1.5));
                R.Set ("f", Float'(2.5));
            end;
            DB.Flush;
            declare
                Text : constant String := Contents (Where & "/locale.prefs");
            begin
                Check (Has (Text, "x:1.5") and Has (Text, "f:2.5"),
                    "a German LC_NUMERIC still writes a point: " & Text);
            end;
            declare
                R : constant Pref_Group'Class := Forge.Root (DB);
            begin
                Check (R.Get ("x", Long_Float'(0.0)) = 1.5 and R.Get ("f", Float'(0.0)) = 2.5,
                    "and reads it back");
            end;
        end;
        if setlocale (LC_Numeric, Interfaces.C.To_C ("C")) = Interfaces.C.Strings.Null_Ptr then
            Check (False, "LC_NUMERIC can be put back");
        end if;
    end if;

    --  A file of any name, and the names FLTK gives.
    declare
        Name : constant String := Where & "/whole.data";
    begin
        declare
            DB : constant Database := Forge.From_File (Name);
        begin
            declare
                R : Pref_Group'Class := Forge.Root (DB);
            begin
                R.Set ("s", "here");
            end;
            DB.Flush;
            Check (File_Name (DB) = Name, "From_File's File_Name is the name given");
        end;
        Check (Has (Contents (Name), "s:here"), "From_File writes the file of that name");
        declare
            DB : constant Database := Forge.From_File (Name);
        begin
            Check (String'(Forge.Root (DB).Get ("s", "")) = "here", "and reads it");
        end;
    end;
    declare
        DB : constant Database := Forge.From_Filesystem (Where, "fltkada", "named");
    begin
        Check (File_Name (DB) = Where & "/named.prefs",
            "From_Filesystem's File_Name is Directory/Application.prefs");
    end;
    declare
        Long : constant String := Where & "/" & (1 .. 1500 => 'n') & ".prefs";
    begin
        Check (File_Name (Forge.From_File (Long)) = Long,
            "a name longer than FL_PATH_MAX is given whole");
    end;
    declare
        Name : constant String := File_Name (User, "fltkada", "test_pref_files");
        Tail : constant String := "/fltkada/test_pref_files.prefs";
    begin
        Check (Name'Length > Tail'Length
                and then Name (Name'Last - Tail'Length + 1 .. Name'Last) = Tail,
            "the static File_Name ends Vendor/Application.prefs: " & Name);
    end;

    Dir.Delete_Tree (Where);

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Pref_Files;
