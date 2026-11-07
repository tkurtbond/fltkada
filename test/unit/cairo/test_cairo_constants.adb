

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Checks the Cairo library's constants against FLTK's, as
--  test_constants does the main library's.  The checks are in
--  FLTK.Test_Cairo_Constants, which tools/gen-constants.py writes; this
--  only runs them.


with

    Checks,
    FLTK.Test_Cairo_Constants;


procedure Test_Cairo_Constants is
begin
    FLTK.Test_Cairo_Constants;
    Checks.Summary;
end Test_Cairo_Constants;
