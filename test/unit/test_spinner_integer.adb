--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A spinner's value as an Integer (PLAN.md, Phase 30):  rounded to the
--  nearest whole number, a half up.  Fl_Spinner::value doesn't round or
--  clamp what it is given, so an Int_Spin can hold 2.5.  After pofltk's
--  Spinner.IntValue.


with

    Checks,
    FLTK.Widgets.Groups.Spinners;

use

    Checks;


procedure Test_Spinner_Integer is

    package Spn renames FLTK.Widgets.Groups.Spinners;

    Spin : Spn.Spinner := Spn.Forge.Create (0, 0, 100, 25);

    Got : Integer;

    procedure Expect
           (Value  : in Long_Float;
            Wanted : in Integer) is
    begin
        Spin.Set_Value (Value);
        Check (Spin.Get_Integer_Value = Wanted,
            Value'Image & " gives" & Wanted'Image & ", got" & Spin.Get_Integer_Value'Image);
    end Expect;

begin

    Spin.Set_Kind (Spn.Int_Spin);
    Spin.Set_Range (-100.0, 100.0);

    Expect (7.0, 7);
    Expect (2.49, 2);
    Expect (2.5, 3);
    Expect (2.51, 3);
    Expect (-2.5, -2);
    Expect (-2.51, -3);
    Expect (0.0, 0);

    Spin.Set_Value (1.0E12);
    begin
        Got := Spin.Get_Integer_Value;
        Check (False, "a value past Integer raises Constraint_Error, not" & Got'Image);
    exception
        when Constraint_Error =>
            Check (True, "a value past Integer raises Constraint_Error");
    end;

    declare
        --  0.0, from the spinner, so that the compiler doesn't see it.
        Zero : constant Long_Float := Spin.Get_Value - 1.0E12;
        NaN  : constant Long_Float := Zero / Zero;
    begin
        Spin.Set_Value (NaN);
        Got := Spin.Get_Integer_Value;
        Check (False, "a NaN raises Constraint_Error, not" & Got'Image);
    exception
        when Constraint_Error =>
            Check (Spin.Get_Value /= Spin.Get_Value, "a NaN raises Constraint_Error");
    end;

    Summary;

end Test_Spinner_Integer;
