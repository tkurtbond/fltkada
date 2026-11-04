

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 63: fl_numericsort and fl_casenumericsort
--  never compare the character after a run of digits, so "a1za" came
--  before "a1yb", and after a run of digits that ends a name they read past
--  its end, so "ab12z" came before "ab12" (numericsort.c).  Numeric_Sort is
--  the default sort of Get_Listing, File_Browser.Load and File_Chooser.
--  names/ holds empty files whose names each sort orders differently.


with

    Ada.Exceptions,
    Ada.Strings.Unbounded,
    Checks,
    FLTK.Filenames,
    FLTK.Widgets.Groups.Browsers.Textline.File,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK.Filenames;


procedure Test_Numeric_Sort is

    package FB  renames FLTK.Widgets.Groups.Browsers.Textline.File;
    package UB  renames Ada.Strings.Unbounded;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type UB.Unbounded_String;

    procedure Compares
           (X, Y : in String;
            Want : in Comparison;
            Sort : in Compare_Function := Numeric_Sort'Access)
    is
        Got  : constant Comparison := Sort (X, Y);
        Back : constant Comparison := Sort (Y, X);
        Opposite : constant array (Comparison) of Comparison :=
            (Lesser => Greater, Equal => Equal, Greater => Lesser);
    begin
        Check (Got = Want and then Back = Opposite (Want),
            X (X'First .. X'First + Integer'Min (X'Length, 20) - 1) & " to "
            & Y (Y'First .. Y'First + Integer'Min (Y'Length, 20) - 1) & ": "
            & Comparison'Image (Got) & " and " & Comparison'Image (Back));
    end Compares;

    --  A listing's names, separated by spaces.
    function Names
           (List : in File_List)
        return String
    is
        Result : UB.Unbounded_String;
    begin
        for N in 1 .. List.Length loop
            if N > 1 then
                UB.Append (Result, " ");
            end if;
            UB.Append (Result, List.Item (N));
        end loop;
        return UB.To_String (Result);
    end Names;

    function Lines
           (Browser : in FB.File_Browser)
        return String
    is
        Result : UB.Unbounded_String;
    begin
        for N in 1 .. Browser.Number_Of_Lines loop
            if N > 1 then
                UB.Append (Result, " ");
            end if;
            UB.Append (Result, Browser.Get_Line_Text (N));
        end loop;
        return UB.To_String (Result);
    end Lines;

    Long : constant String (1 .. 300) := (others => 'x');

    Numeric : constant String := "../ B1 a1yb a1za a2 a10 ab12 ab12y ab12z";
    Case_Numeric : constant String := "../ a1yb a1za a2 a10 ab12 ab12y ab12z B1";

begin

    --  pofltk 63.
    Compares ("a1yb", "a1za", Lesser);
    Compares ("ab12", "ab12z", Lesser);
    Compares ("ab12y", "ab12z", Lesser);
    Compares ("a2", "a10", Lesser);
    Compares ("ab12", "ab12", Equal);

    --  The examples in FLTK's documentation of fl_numericsort.
    Compares ("1zzz.txt", "2xxx.txt", Lesser);
    Compares ("2xxx.txt", "19uuu.txt", Lesser);
    Compares ("19uuu.txt", "100aaa.txt", Lesser);
    Compares ("100aaa.txt", "file1z.txt", Lesser);
    Compares ("file1z.txt", "file5a.txt", Lesser);
    Compares ("file5a.txt", "file5z.txt", Lesser);
    Compares ("file5z.txt", "file30z.txt", Lesser);
    Compares ("file30z.txt", "file200a.txt", Lesser);
    Compares ("temp+5.txt", "temp-5.txt", Lesser);
    Compares ("temp-5.txt", "temp-100.txt", Lesser);

    --  Leading zeros, case, and names longer than a dirent's.
    Compares ("a01", "a1", Equal);
    Compares ("a007b", "a7c", Lesser);
    Compares ("", "a", Lesser);
    Compares ("", "", Equal);
    Compares ("B1", "a1", Lesser);
    Compares ("B1", "a1", Greater, Case_Numeric_Sort'Access);
    Compares ("ABC", "abc", Equal, Case_Numeric_Sort'Access);
    Compares ("Ab2", "aB10", Lesser, Case_Numeric_Sort'Access);
    Compares ("É1", "é1", Lesser);
    Compares ("É1", "é1", Equal, Case_Numeric_Sort'Access);
    Compares ("é", "z", Greater);
    Compares (Long & "a", Long & "b", Lesser);
    Compares (Long & "1", Long & "a", Lesser);

    --  The alphabetic sorts, by bytes as strcmp and strcasecmp compare.
    Compares ("B1", "a1", Lesser, Alpha_Sort'Access);
    Compares ("a10", "a2", Lesser, Alpha_Sort'Access);
    Compares ("ab", "abc", Lesser, Alpha_Sort'Access);
    Compares ("abc", "abc", Equal, Alpha_Sort'Access);
    Compares ("B1", "a1", Greater, Case_Alpha_Sort'Access);
    Compares ("ABC", "abc", Equal, Case_Alpha_Sort'Access);
    Compares ("É", "é", Lesser, Case_Alpha_Sort'Access);
    Compares ("é", "z", Greater, Alpha_Sort'Access);
    Compares (Long & "a", Long & "b", Lesser, Alpha_Sort'Access);
    Compares (Long & "A", Long & "b", Lesser, Case_Alpha_Sort'Access);

    --  A listing.
    declare
        List : constant File_List := Get_Listing ("names");
    begin
        Check (Names (List) = "./ " & Numeric, "Get_Listing: " & Names (List));
    end;
    declare
        List : constant File_List := Get_Listing ("names", Alpha_Sort'Access);
    begin
        Check (Names (List) = "./ ../ B1 a10 a1yb a1za a2 ab12 ab12y ab12z",
            "Get_Listing, by bytes: " & Names (List));
    end;
    declare
        List : constant File_List := Get_Listing ("names", Case_Numeric_Sort'Access);
    begin
        Check (Names (List) = "./ " & Case_Numeric, "Get_Listing, case ignored: " & Names (List));
    end;

    --  A file browser.
    declare
        Window  : Win.Window := Win.Forge.Create (0, 0, 200, 300, "Test_Numeric_Sort");
        Browser : FB.File_Browser := FB.Forge.Create (Window, 0, 0, 200, 300);
        Count   : Natural;
    begin
        Count := Browser.Load ("names");
        Check (Lines (Browser) = Numeric,
            "File_Browser.Load:" & Natural'Image (Count) & " " & Lines (Browser));
        Count := Browser.Load ("names", Case_Numeric_Sort'Access);
        Check (Lines (Browser) = Case_Numeric,
            "File_Browser.Load, case ignored:" & Natural'Image (Count) & " " & Lines (Browser));
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Numeric_Sort;


