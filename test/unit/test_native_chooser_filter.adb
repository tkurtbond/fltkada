--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Native_File_Chooser's Add_Filter (PLAN.md, Phase 30):  a name and a
--  pattern added after the filters already given, with a tab or a line feed
--  in either refused.  And Set_Filter's lines named, so that FLTK keeps
--  them all (F41).  The chooser is never shown.  After pofltk's
--  TestDialogs.Mod.


with

    Ada.Exceptions,
    Checks,
    FLTK.Native_File_Choosers;

use

    Checks;


procedure Test_Native_Chooser_Filter is

    package NFC renames FLTK.Native_File_Choosers;

    Chooser : NFC.Native_File_Chooser := NFC.Forge.Create (NFC.Browse_File);

    HT : constant Character := ASCII.HT;
    LF : constant Character := ASCII.LF;

    procedure Refused
           (Name, Pattern, What : in String) is
    begin
        Chooser.Add_Filter (Name, Pattern);
        Check (False, What & " is refused");
    exception
        when E : Constraint_Error =>
            Check (Chooser.Get_Filter = "YAML" & HT & "*.{yaml,yml}" & LF & "*.txt" & HT & "*.txt",
                What & " is refused, the filters as they were: " &
                Ada.Exceptions.Exception_Message (E));
    end Refused;

begin

    Chooser.Add_Filter ("YAML", "*.{yaml,yml}");
    Check (Chooser.Get_Filter = "YAML" & HT & "*.{yaml,yml}" and then Chooser.Filter_Count = 1,
        "the first filter is the name, a tab and the pattern: " & Chooser.Get_Filter);

    Chooser.Add_Filter ("", "*.txt");
    Check (Chooser.Get_Filter = "YAML" & HT & "*.{yaml,yml}" & LF & "*.txt" & HT & "*.txt"
            and then Chooser.Filter_Count = 2,
        "a filter with no name is named by its pattern, after a line feed:" &
        Chooser.Filter_Count'Image);

    Refused ("A" & HT & "B", "*.a", "a tab in the name");
    Refused ("A", "*.a" & LF & "*.b", "a line feed in the pattern");
    Refused ("A" & LF, "*.a", "a line feed in the name");
    Refused ("A", HT & "*.a", "a tab in the pattern");

    --  FLTK drops a filter with no name before one with a name (F41), so
    --  Set_Filter names its lines.
    Chooser.Set_Filter ("*.c" & LF & "Headers" & HT & "*.h" & LF & LF & "*.cc");
    Check (Chooser.Get_Filter = "*.c" & HT & "*.c" & LF & "Headers" & HT & "*.h" & LF & LF &
            "*.cc" & HT & "*.cc"
            and then Chooser.Filter_Count = 3,
        "Set_Filter names a line with no name: " & Chooser.Get_Filter &
        Chooser.Filter_Count'Image);

    Chooser.Set_Filter ("*.c" & LF & "*.cc");
    Check (Chooser.Filter_Count = 2, "two filters with no names are two");
    Chooser.Add_Filter ("Headers", "*.h");
    Check (Chooser.Get_Filter = "*.c" & HT & "*.c" & LF & "*.cc" & HT & "*.cc" & LF &
            "Headers" & HT & "*.h"
            and then Chooser.Filter_Count = 3,
        "after Set_Filter's: " & Chooser.Get_Filter & Chooser.Filter_Count'Image);

    Chooser.Set_Filter ("");
    Chooser.Add_Filter ("", "*");
    Check (Chooser.Get_Filter = "*" & HT & "*" and then Chooser.Filter_Count = 1,
        "after the filters are cleared: " & Chooser.Get_Filter);

    Summary;

end Test_Native_Chooser_Filter;
