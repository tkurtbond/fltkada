

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Checks the GLU library's constants against GLU's, as
--  test_constants does the main library's.  The checks are in
--  FLTK.Test_GLU_Constants, which tools/gen-constants.py writes; this
--  only runs them.


with

    Checks,
    FLTK.Test_GLU_Constants;


procedure Test_GLU_Constants is
begin
    FLTK.Test_GLU_Constants;
    Checks.Summary;
end Test_GLU_Constants;
