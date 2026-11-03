--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Checks FLTKAda's constants in spec/fltk.ads against FLTK's
--  (PLAN.md, Phase 0).  The checks are in FLTK.Test_Constants, which
--  tools/gen-constants.py writes; this only runs them.


with

    Checks,
    FLTK.Test_Constants;


procedure Test_Constants is
begin
    FLTK.Test_Constants;
    Checks.Summary;
end Test_Constants;
