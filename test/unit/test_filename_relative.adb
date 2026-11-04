

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 94: fl_filename_relative makes the current
--  directory ".", and returns 0, which its documentation says is no
--  change.  Relative's Changed now says whether the result differs from
--  the name.


with

    Ada.Directories,
    Ada.Exceptions,
    Checks,
    FLTK.Filenames;

use

    Checks;


procedure Test_Filename_Relative is

    package Fnm renames FLTK.Filenames;

    Here : constant String := Ada.Directories.Current_Directory;

    procedure Try
           (Name, Want : in String;
            Changes    : in Boolean;
            Message    : in String)
    is
        Changed : Boolean;
        Result  : constant String := Fnm.Relative (Name, Changed);
    begin
        Check (Result = Want, Message & ": """ & Result & """");
        Check (Changed = Changes, Message & ": Changed is " & Boolean'Image (Changed));
    end Try;

begin

    Try (Here, ".", True, "the current directory");
    Try (Here & "/x", "x", True, "a file in the current directory");
    Try ("x/y", "x/y", False, "a relative name");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Filename_Relative;
