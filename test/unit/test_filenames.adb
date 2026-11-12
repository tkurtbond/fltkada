

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 120 to 122.  fl_filename_expand aborts when a
--  value doesn't fit, never ends when a value names itself, and reads
--  value[-1] for an empty value (Fl_System_Driver.cxx:247-289).
--  fl_filename_isdir copies a name ending in a slash into fn[FL_PATH_MAX]
--  (filename_isdir.cxx:62-76), and fl_filename_match goes past the end of
--  a pattern with a bracket left open (filename_match.cxx).


with

    Ada.Environment_Variables,
    Ada.Exceptions,
    Ada.IO_Exceptions,
    Checks,
    FLTK.Filenames;

use

    Checks;


procedure Test_Filenames is

    package Env renames Ada.Environment_Variables;
    package Fnm renames FLTK.Filenames;

    Changed : Boolean;

    procedure List_Missing is
        List : constant Fnm.File_List := Fnm.Get_Listing ("/tmp/no-such-directory/");
    begin
        Check (False, "listed a missing directory:" & Natural'Image (List.Length));
    end List_Missing;

    procedure List_File is
        List : constant Fnm.File_List := Fnm.Get_Listing ("/etc/passwd");
    begin
        Check (False, "listed a file:" & Natural'Image (List.Length));
    end List_File;

begin

    Env.Set ("HOME", "/home/someone");
    Env.Set ("TEST_FILENAMES_ABS", "/abs/");
    Env.Set ("TEST_FILENAMES_REL", "rel");
    Env.Set ("TEST_FILENAMES_EMPTY", "");

    Check (Fnm.Expand ("~/a") = "/home/someone/a", "~ is HOME: " & Fnm.Expand ("~/a"));
    Check (Fnm.Expand ("x/$TEST_FILENAMES_ABS/b") = "/abs/b",
        "a value starting with a slash ends all before it, and loses a trailing one: "
        & Fnm.Expand ("x/$TEST_FILENAMES_ABS/b"));
    Check (Fnm.Expand ("x/$TEST_FILENAMES_REL/b", Changed) = "x/rel/b" and then Changed,
        "a relative value goes in place: " & Fnm.Expand ("x/$TEST_FILENAMES_REL/b"));
    Check (Fnm.Expand ("x/$TEST_FILENAMES_UNSET/b", Changed) = "x/$TEST_FILENAMES_UNSET/b"
        and then not Changed, "an unset variable is left");
    Check (Fnm.Expand ("x/$TEST_FILENAMES_EMPTY/b") = "x//b",
        "an empty value: " & Fnm.Expand ("x/$TEST_FILENAMES_EMPTY/b"));

    --  pofltk 120: a value too long for the buffer is cut short.
    Env.Set ("TEST_FILENAMES_LONG", (1 .. 3 * Fnm.Max_Path_Length => 'x'));
    declare
        Long : constant String := Fnm.Expand ("$TEST_FILENAMES_LONG");
    begin
        Check (Long = (1 .. Fnm.Max_Path_Length - 1 => 'x'),
            "a value too long is cut short:" & Integer'Image (Long'Length));
    end;

    --  pofltk 120: a value naming itself goes in once.
    Env.Set ("TEST_FILENAMES_SELF", "$TEST_FILENAMES_SELF");
    Check (Fnm.Expand ("a/$TEST_FILENAMES_SELF/b") = "a/$TEST_FILENAMES_SELF/b",
        "a value naming itself goes in once");

    --  pofltk 121: a long name ending in a slash.
    Check (Fnm.Is_Directory ("/tmp" & (1 .. 3000 => '/')), "a long name ending in a slash");
    Check (Fnm.Is_Directory ("/tmp/"), "a name ending in a slash");
    Check (not Fnm.Is_Directory ("/tmp/no-such-directory/"), "no such directory");

    --  pofltk 122: a bracket or brace left open.
    for N in 1 .. 50 loop
        Check (Fnm.Match ("a", "[a") and then Fnm.Match ("b", "[a-") = False
            and then not Fnm.Match ("a", "{b") and then not Fnm.Match ("a", "{[b"),
            "a bracket or brace left open:" & Integer'Image (N));
        exit when Failures > 0;
    end loop;
    Check (Fnm.Match ("ab.c", "*.[ch]") and then not Fnm.Match ("ab.o", "*.[ch]")
        and then Fnm.Match ("x.ads", "*.{adb,ads}"), "patterns that are closed");

    --  FLTKAda-BUGS.md 124: a directory that can't be listed.
    Raises (List_Missing'Access, Ada.IO_Exceptions.Name_Error'Identity,
        "Get_Listing of a missing directory");
    Raises (List_File'Access, Ada.IO_Exceptions.Name_Error'Identity,
        "Get_Listing of a file");

    --  FLTKAda-BUGS.md 138: Set_Extension raised Constraint_Error for
    --  every name.
    Check (Fnm.Set_Extension ("/a/b.cxx", ".menu") = "/a/b.menu",
        "Set_Extension replaces an extension: " & Fnm.Set_Extension ("/a/b.cxx", ".menu"));
    Check (Fnm.Set_Extension ("/a.d/demo", ".menu") = "/a.d/demo.menu",
        "Set_Extension adds one: " & Fnm.Set_Extension ("/a.d/demo", ".menu"));
    Check (Fnm.Set_Extension ("b.tar.gz", "") = "b.tar",
        "Set_Extension removes one: " & Fnm.Set_Extension ("b.tar.gz", ""));

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Filenames;
