

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 37 (FLTKAda-BUGS.md): Spinner's format string.  FLTK keeps the pointer
--  (format_ = f, Fl_Spinner.H:84), so the binding keeps the copy, frees the
--  old one only after FLTK has the new one, and frees the last when the
--  Spinner goes, after giving FLTK its static "%g" back.  A leak, or a
--  read of a freed format, fails vg-check.sh or valgrind.


with

    Checks,
    FLTK.Widgets.Groups.Spinners,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Spinner_Format is

    package Spn renames FLTK.Widgets.Groups.Spinners;
    package Win renames FLTK.Widgets.Groups.Windows;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

begin

    declare
        Lone : Spn.Spinner := Spn.Forge.Create (0, 0, 100, 25);
    begin
        Check (Lone.Get_Format = "%g", "a new Spinner has FLTK's format");
        Lone.Set_Format ("%.1f");
        Lone.Set_Format ("%.3f");
        Lone.Set_Value (1.5);
        Check (Lone.Get_Format = "%.3f", "a Spinner keeps its last format");
    end;

    declare
        Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Spinner_Format");
        Inside : Spn.Spinner := Spn.Forge.Create (Window, 10, 10, 100, 25);
    begin
        Inside.Set_Format (Fresh ("%g units"));
        Inside.Set_Format (Fresh ("%.2f units"));
        Inside.Set_Value (2.25);
        Check (Inside.Get_Format = "%.2f units 2", "a Spinner in a window keeps its last format");
        Window.Show;
        for N in 1 .. 5 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end;

    Summary;

end Test_Spinner_Format;


