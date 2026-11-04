--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 57: Fl::args returns 0 for an option nobody
--  knows only until a call has stopped at a word that isn't an option.
--  After that it returns the option's index, as if it were such a word,
--  and Parse_Args raised nothing.  The arguments are the process's own, so
--  run with none, the test runs itself twice: with "-o rest", parsed
--  first with a handler that takes -o, which stops at "rest", then without
--  it, when -o is unknown; and with "-bogus", unknown in the first call.
--  Valgrind, run on the children by hand, checks FLTKAda-BUGS.md 61: FLTK
--  reads argv[argc], which FLTKAda's argv didn't have, and Parse_Arg read
--  past the arguments.  And FLTKAda-BUGS.md 62: with "-title Hello", a
--  window shown with Show_With_Args has FLTK's pointer to the title as its
--  label (Fl_arg.cxx:313), and FLTKAda freed that argv after the show.


with

    Ada.Command_Line,
    Ada.Exceptions,
    Checks,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows.Single,
    GNAT.OS_Lib,
    Interfaces.C.Strings;

use

    Checks;


procedure Test_Parse_Args is

    package ACom renames Ada.Command_Line;
    package Stc  renames FLTK.Static;
    package Sgl  renames FLTK.Widgets.Groups.Windows.Single;

    function Take_O
           (Index : in Positive)
        return Natural is
    begin
        return (if ACom.Argument (Index) = "-o" then 1 else 0);
    end Take_O;

    Count : Natural := 99;

    procedure Past_The_End is
        Result : constant Natural := Stc.Parse_Arg (ACom.Argument_Count + 1);
        pragma Unreferenced (Result);
    begin
        null;
    end Past_The_End;

    procedure With_O is
    begin
        Stc.Parse_Args (Count, Take_O'Unrestricted_Access);
    end With_O;

    procedure Without_O is
    begin
        Stc.Parse_Args (Count);
    end Without_O;

    procedure Run
           (Words : in String)
    is
        Args : GNAT.OS_Lib.Argument_List_Access :=
            GNAT.OS_Lib.Argument_String_To_List (Words);
        Code : constant Integer := GNAT.OS_Lib.Spawn (ACom.Command_Name, Args.all);
    begin
        GNAT.OS_Lib.Free (Args);
        Check (Code = 0, "run with """ & Words & """, exit status" & Integer'Image (Code));
    end Run;

begin

    if ACom.Argument_Count = 0 then
        Run ("-o rest");
        Run ("-bogus");
        Run ("-title Hello");
    elsif ACom.Argument (1) = "-title" then
        declare
            Win   : Sgl.Single_Window := Sgl.Forge.Create (100, 100);
            Other : array (1 .. 8) of Interfaces.C.Strings.chars_ptr;
        begin
            Win.Show_With_Args;
            --  Strings of the title's size, which may take its freed block.
            for P of Other loop
                P := Interfaces.C.Strings.New_String ("World");
            end loop;
            Check (Win.Get_Label = "Hello", "-title: the window's label is """
                & Win.Get_Label & """, not ""Hello""");
            Win.Hide;
            for P of Other loop
                Interfaces.C.Strings.Free (P);
            end loop;
        end;
    elsif ACom.Argument (1) = "-o" then
        No_Raise (With_O'Access, "-o rest: with the handler, nothing is unknown");
        Check (Count = 1, "-o rest: with the handler, 1 argument is parsed, not"
            & Natural'Image (Count));
        Raises (Without_O'Access, Stc.Argument_Error'Identity,
            "-o rest: without the handler, -o is unknown");
        No_Raise (With_O'Access, "-o rest: with the handler again, nothing is unknown");
    else
        Raises (Without_O'Access, Stc.Argument_Error'Identity,
            ACom.Argument (1) & ": unknown in the first call");
        Raises (Past_The_End'Access, Constraint_Error'Identity,
            ACom.Argument (1) & ": Parse_Arg past the last argument");
    end if;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Parse_Args;
