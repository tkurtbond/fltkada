--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/unittest_core.cxx: the core tests, and the page that runs
--  them one by one into a terminal.


with

    Unittests_Common;


package Unittests_Core is


    --  Add the core tests to the suites.
    procedure Register;

    function Create
        return Unittests_Common.Widget_Access;


end Unittests_Core;
