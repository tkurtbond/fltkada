

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestPreferences: entries, groups, and a file
--  written and read back.  Groups deleted while in use are
--  test_pref_groups's (pofltk 51).  pofltk's Close and its count of open
--  databases have no counterpart, as Ada finalizes them; nor has its
--  FileName, so the file is found in the directory instead.


with

    Ada.Characters.Latin_1,
    Ada.Directories,
    Ada.Exceptions,
    Ada.Strings.Fixed,
    Checks,
    FLTK.Environment,
    Interfaces;

use

    Checks,
    FLTK.Environment;


procedure Test_Preferences is

    package Dir renames Ada.Directories;

    use type Interfaces.Unsigned_8;

    --  Text FLTK escapes in its file: a newline, a backslash, quotes.
    Odd : constant String :=
        "one" & Ada.Characters.Latin_1.LF & "two \ ""three""";

    Where : constant String := Dir.Current_Directory & "/test_preferences.tmp";

    Ignore : Integer;

    procedure Delete_Missing is
        P : Pref_Group := Forge.In_Memory ("test_preferences_d");
    begin
        P.Delete_Entry ("missing");
    end Delete_Missing;

    procedure Get_Missing_Binary is
        Data : constant Binary_Data := Forge.In_Memory ("test_preferences_m").Get ("missing");
    begin
        Ignore := Data'Length;
    end Get_Missing_Binary;

    procedure Get_Missing is
    begin
        Ignore := Integer'(Forge.In_Memory ("test_preferences_m").Get ("missing"));
    end Get_Missing;

begin

    --  Entries, in memory.
    declare
        P : Pref_Group := Forge.In_Memory ("test_preferences");
    begin
        Check (P.Number_Of_Entries = 0 and P.Number_Of_Groups = 0, "empty to start with");
        P.Set ("n", -42);
        P.Set ("x", Long_Float'(0.5));
        P.Set ("s", "hello");
        P.Set ("b", Binary_Data'(1, 0, 255));
        P.Set ("b16", Binary_Data'(1 .. 16 => 7));
        Check (P.Get ("n", 0) = -42 and P.Get ("x", Long_Float'(0.0)) = 0.5,
            "Set and Get of an Integer and a Long_Float");
        Check (String'(P.Get ("s", "")) = "hello" and P.Value_Size ("s") = 5,
            "of a String, with its Value_Size");
        Check (Binary_Data'(P.Get ("b", Binary_Data'(1 .. 0 => 0))) = (1, 0, 255)
                and String'(P.Get ("b", "")) = "0100ff",
            "of Binary_Data, kept as hexadecimal text");
        Check (Binary_Data'(P.Get ("b16")) = (1 .. 16 => 7)
                and Binary_Data'(P.Get ("b16", (1, 2))) = (1 .. 16 => 7),
            "16 bytes, with and without a default");
        Check (Binary_Data'(P.Get ("b16", (1, 2), 4)) = (1 .. 4 => 7)
                and Binary_Data'(P.Get ("b", (1, 2), 8)) = (1, 0, 255),
            "binary data limited by Max_Length, and not");
        Check (Binary_Data'(P.Get ("missing", (1, 2))) = (1, 2)
                and Binary_Data'(P.Get ("missing", (1, 2, 3), 2)) = (1, 2)
                and Binary_Data'(P.Get ("missing", (1, 2, 3), 5)) = (1, 2, 3),
            "a missing binary entry gives the default, limited by Max_Length");
        Raises (Get_Missing_Binary'Access, Preference_Error'Identity,
            "and without a default raises");
        Check (P.Get ("missing", 7) = 7 and P.Get ("missing", Long_Float'(1.5)) = 1.5
                and String'(P.Get ("missing", "dflt")) = "dflt",
            "a missing entry gives the default");
        Raises (Get_Missing'Access, Preference_Error'Identity,
            "a missing entry without a default raises");
        Check (String'(P.Get ("s", "", 3)) = "hel" and String'(P.Get ("s", "", 9)) = "hello"
                and String'(P.Get ("missing", "dflt", 2)) = "df",
            "text limited by Max_Length: " & P.Get ("s", "", 3));
        P.Set ("n", 3);
        Check (P.Get ("n", 0) = 3 and P.Number_Of_Entries = 5, "Set replaces");
        Check (P.Entry_Key (1) = "n" and P.Entry_Key (4) = "b", "Entry_Key");
        Check (P.Key_Exists ("x") and not P.Key_Exists ("y"), "Key_Exists");
        P.Delete_Entry ("x");
        Check (not P.Key_Exists ("x") and P.Number_Of_Entries = 4, "Delete_Entry");
        Raises (Delete_Missing'Access, Preference_Error'Identity,
            "Delete_Entry of an entry there isn't raises");

        --  Groups.
        declare
            A  : Pref_Group'Class := Forge.By_Name (P, "a");
            BC : constant Pref_Group'Class := Forge.By_Name (P, "b/c");
        begin
            Check (A.At_Name = "a" and BC.At_Name = "c",
                "a group's name: " & A.At_Name & ", " & BC.At_Name);
            Check (P.Number_Of_Groups = 2 and P.Group_Exists ("b") and P.Group_Exists ("b/c")
                    and not P.Group_Exists ("c"),
                "a path makes the groups along it; Group_Exists");
            Check (P.Group_Name (2) = "b", "Group_Name");
            declare
                B : constant Pref_Group'Class := Forge.By_Name (P, "b");
                Q : Pref_Group'Class := Forge.By_Name (Pref_Group (B), "c");
            begin
                Check (B.Number_Of_Groups = 1 and B.Group_Exists ("c"),
                    "an existing group, opened again");
                Check (Q.At_Path = BC.At_Path, "a group's group: " & Q.At_Path);
                Q.Set ("k", 9);
                Check (BC.Get ("k", 0) = 9 and P.Get ("k", 0) = 0 and A.Number_Of_Entries = 0,
                    "two objects, one group, apart from the rest");
            end;
            A.Set ("t", "in a");
            P.Delete_All_Entries;
            Check (P.Number_Of_Entries = 0 and P.Number_Of_Groups = 2
                    and String'(A.Get ("t", "")) = "in a",
                "Delete_All_Entries leaves the groups");
        end;
        P.Delete_All_Groups;
        Check (P.Number_Of_Groups = 0, "Delete_All_Groups");
        P.Set ("n", 1);
        declare
            A : constant Pref_Group'Class := Forge.By_Name (P, "a");
            pragma Unreferenced (A);
        begin
            P.Clear;
            Check (P.Number_Of_Groups = 0 and P.Number_Of_Entries = 0, "Clear");
        end;
    end;

    --  A file, written and read back.
    if Dir.Exists (Where) then
        Dir.Delete_Tree (Where);
    end if;
    Dir.Create_Directory (Where);
    declare
        D : constant Database := Forge.From_Filesystem (Where, "org.example", "fltkada-test");
        P : Pref_Group'Class := Forge.Root (D);
    begin
        P.Set ("n", 12);
        P.Set ("x", Long_Float'(0.25));
        P.Set ("odd", Odd);
        P.Set ("b", Binary_Data'(16#DE#, 16#AD#));
        declare
            A : Pref_Group'Class := Forge.By_Name (Pref_Group (P), "a/b");
        begin
            A.Set ("t", "deep");
        end;
        Flush (D);
        Check (Dir.Exists (Where & "/fltkada-test.prefs"),
            "Flush writes Directory/Application.prefs");
        Check (Ada.Strings.Fixed.Index (Userdata_Path (D), Where) = 1,
            "Userdata_Path is in the directory: " & Userdata_Path (D));
    end;
    declare
        D : constant Database := Forge.From_Filesystem (Where, "org.example", "fltkada-test");
        P : constant Pref_Group'Class := Forge.Root (D);
        A : constant Pref_Group'Class := Forge.By_Name (Pref_Group (P), "a/b");
    begin
        Check (P.Get ("n", 0) = 12 and P.Get ("x", Long_Float'(0.0)) = 0.25,
            "numbers read back from the file");
        Check (String'(P.Get ("odd", "")) = Odd and P.Value_Size ("odd") >= Odd'Length,
            "text FLTK escapes, read back: " & P.Get ("odd", ""));
        Check (Binary_Data'(P.Get ("b", Binary_Data'(1 .. 0 => 0))) = (16#DE#, 16#AD#),
            "binary data read back");
        Check (String'(A.Get ("t", "")) = "deep", "a group read back");
    end;
    Dir.Delete_Tree (Where);

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Preferences;
