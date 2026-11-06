--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 103: a Clock had no way to set Fl_Clock_Output::type,
--  so a clock showing a time it was given could only be square.


with

    Ada.Exceptions,
    Checks,
    FLTK.Widgets.Clocks.Updated.Round;

use

    Checks;


procedure Test_Clock_Kind is

    package Clk renames FLTK.Widgets.Clocks;
    package Rnd renames FLTK.Widgets.Clocks.Updated.Round;

    use type Clk.Clock_Kind;

    The_Clock : Clk.Clock := Clk.Forge.Create (0, 0, 100, 100);
    Rounded   : constant Rnd.Round_Clock := Rnd.Forge.Create (0, 0, 100, 100);

begin

    Check (The_Clock.Get_Kind = Clk.Square_Face, "a clock starts square");
    Clk.Extra.Set_Kind (The_Clock, Clk.Round_Face);
    Check (The_Clock.Get_Kind = Clk.Round_Face, "a clock made round is round");
    Clk.Extra.Set_Kind (The_Clock, Clk.Square_Face);
    Check (The_Clock.Get_Kind = Clk.Square_Face, "and square again");
    Check (Rounded.Get_Kind = Clk.Round_Face, "a Round_Clock is round");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Clock_Kind;
