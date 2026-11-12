--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  The test registry of FLTK's test/unittests.cxx: tests grouped into
--  suites, run all at once (the --core switch) or one at a time (the
--  "Core Functionality" page), with output in the style of GoogleTest.


with

    FLTK.Widgets.Groups.Terminals;


package Unittests_Suite is


    type Test_Call is access function
        return Boolean;

    --  Add a test to the suite called Suite, making the suite if it is
    --  new.  Suites and tests run in the order they were added.
    procedure Add
           (Suite : in String;
            Name  : in String;
            Call  : in Test_Call);

    --  Whether the output has ANSI colour sequences in it (the default).
    procedure Set_Color
           (Value : in Boolean);

    --  Where the output goes: a terminal widget, or with null, the standard
    --  output.
    type Terminal_Access is access all FLTK.Widgets.Groups.Terminals.Terminal'Class;

    procedure Set_Terminal
           (Value : in Terminal_Access);

    --  Run every test and return the number that failed.
    function Run_All_Tests
        return Natural;

    --  Run the next test, printing the suite's heading and the prolog and
    --  epilog when they are due.  False once everything has run.
    function Run_Next_Test
        return Boolean;

    procedure Print
           (Text : in String);

    --  If Actual differs from Expected, log the difference and return
    --  False, as EXPECT_STREQ does.
    function Expect_Equal
           (Actual        : in String;
            Expected      : in String;
            Actual_Text   : in String;
            Expected_Text : in String;
            File          : in String;
            Line          : in Positive)
        return Boolean;


end Unittests_Suite;
