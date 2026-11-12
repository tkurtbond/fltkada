--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/unittest_terminal.cxx.


with

    Unittests_Common;


package Unittests_Terminal is


    function Create
        return Unittests_Common.Widget_Access;


end Unittests_Terminal;
