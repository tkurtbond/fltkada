--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A browser's Find_Line (PLAN.md, Phase 30):  the first line, from a line on,
--  whose text is the text given, format characters and all, or 0.  After
--  pofltk's TestBrowsers.Mod.


with

    Checks,
    FLTK.Widgets.Groups.Browsers.Textline.Hold;

use

    Checks;


procedure Test_Browser_Find is

    package Hld renames FLTK.Widgets.Groups.Browsers.Textline.Hold;

    Browser : Hld.Hold_Browser := Hld.Forge.Create (0, 0, 200, 100);

    Found : Natural;

begin

    Browser.Add ("alpha");
    Browser.Add ("@bbeta");
    Browser.Add ("");
    Browser.Add ("alpha");
    Browser.Add ("alphabet");

    Check (Browser.Find_Line ("alpha") = 1, "the first line with the text");
    Check (Browser.Find_Line ("alpha", From => 2) = 4,
        "from a line on:" & Browser.Find_Line ("alpha", 2)'Img);
    Check (Browser.Find_Line ("alpha", From => 4) = 4, "the From line itself");
    Check (Browser.Find_Line ("alpha", From => 5) = 0, "none after it");
    Check (Browser.Find_Line ("beta") = 0 and then Browser.Find_Line ("@bbeta") = 2,
        "the whole text, format characters and all");
    Check (Browser.Find_Line ("") = 3, "an empty line");
    Check (Browser.Find_Line ("alph") = 0, "not a part of a line");
    Check (Browser.Find_Line ("alpha", From => 99) = 0, "From past the last line");
    Check (Browser.Find_Line ("alpha" & ASCII.NUL & "bet") = 0, "never a text with a NUL");

    declare
        --  0, from the browser so that the compiler doesn't see it.
        Zero : constant Natural := Browser.Number_Of_Lines - 5;
    begin
        Found := Browser.Find_Line ("alpha", From => Zero);
        Check (False, "From 0 raises Constraint_Error, not" & Found'Img);
    exception
        when Constraint_Error =>
            Check (True, "From 0 raises Constraint_Error");
    end;

    Browser.Clear;
    Check (Browser.Find_Line ("alpha") = 0, "an empty browser");

    Summary;

end Test_Browser_Find;
