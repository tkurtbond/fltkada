

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Shared ok/FAIL reporting for the unit tests in test/unit.  Each test
--  calls Check once per check and Summary at the very end.  Each check
--  prints one line:
--
--     ok   - <label>
--     FAIL - <label>
--     skip - <label>     (this FLTK, or this back end, lacks the feature)
--
--  Summary then prints "All checks passed." or "<N> check(s) failed.",
--  and sets the exit status to failure if anything failed.  make check
--  totals the skips.  (From pofltk's test/Check.Mod.)


with

    Ada.Exceptions;


package Checks is


    procedure Check
           (OK    : in Boolean;
            Label : in String);

    procedure Skip
           (Label : in String);

    --  Checks that Action raises Expected.  Any other exception, or none,
    --  fails, and the line says what happened instead.
    procedure Raises
           (Action   : not null access procedure;
            Expected : in Ada.Exceptions.Exception_Id;
            Label    : in String);

    --  Checks that Action raises nothing.
    procedure No_Raise
           (Action : not null access procedure;
            Label  : in String);

    function Failures
        return Natural;

    procedure Summary;


end Checks;

