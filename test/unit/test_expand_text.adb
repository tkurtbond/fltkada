

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  N3 (PLAN.md): Expand_Text.  fl_expand_text takes its buffer by value,
--  and with maxbuf 0 it writes to a static buffer of its own (fl_draw.cxx:
--  72-74), which the binding never saw: every non-empty result raised
--  Dereference_Error.  And Last assumed Text started at 1.  The binding now
--  passes a buffer big enough for any text.  The cases are the expansions
--  fl_draw.cxx:133-151 makes: a tab to the next multiple of 8 characters, a
--  control character to ^X, and with Symbols, "@@" to "@" and a stop at a
--  symbol (pofltk 125).


with

    Checks,
    FLTK.Draw,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Expand_Text is

    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Expand_Text");

    Width : Long_Float;
    Last  : Natural;

    procedure Expect
           (Text    : in String;
            Result  : in String;
            Want    : in Natural;
            What    : in String;
            Symbols : in Boolean := False)
    is
        Got : constant String := FLTK.Draw.Expand_Text
           (Text, 1000.0, Width, Last, Wrap => False, Symbols => Symbols);
    begin
        Check (Got = Result, What & ": """ & Got & """");
        Check (Last = Want, What & " stops at" & Natural'Image (Last)
            & ", not" & Natural'Image (Want));
    end Expect;

    Tabbed : constant String (5 .. 9) := "ab" & ASCII.HT & "c" & ASCII.SOH;

    Lines : constant String (21 .. 27) := "one" & ASCII.LF & "two";

    Symbol : constant String (31 .. 38) := "a@@b@->c";

begin

    Window.Show;
    for N in 1 .. 5 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;
    FLTK.Draw.Set_Font (Helvetica, 14);

    Expect (Tabbed, "ab      c^A", Tabbed'Last, "a tab and a control character");
    Check (Width > 0.0, "the expanded text has a width");
    Expect (Lines, "one", Lines'First + 3, "a line ends at the line feed");
    Expect (Symbol, "a@b", Symbol'First + 3, "symbols stop at @-", Symbols => True);
    Expect (Symbol (31 .. 34), "a@@b", 34, "without symbols, @@ stays");
    Expect ((1 .. 40 => ASCII.HT), (1 .. 320 => ' '), 40, "forty tabs");
    Expect ("", "", 0, "empty text");

    Summary;

end Test_Expand_Text;


