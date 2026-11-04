

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  pofltk 13: Fl_Spinner's color and selection_color are its input
--  field's, and hide Fl_Widget's (Fl_Spinner.H:179-196), so Set_Colors,
--  which is Widget's, must set the field's too.  And FLTK passes the
--  format to snprintf with one double, or with an int and then a double
--  when it starts with "%.*" (Fl_Spinner.cxx:79-91), so any other format
--  is refused, and the one before is kept.


with

    Ada.Strings.Unbounded,
    Checks,
    FLTK.Widgets.Groups.Spinners;

use

    Checks;


procedure Test_Spinner_Colors is

    package Spn renames FLTK.Widgets.Groups.Spinners;
    package SU renames Ada.Strings.Unbounded;

    use type FLTK.Color;

    Spin : Spn.Spinner := Spn.Forge.Create (0, 0, 100, 25);
    Format : SU.Unbounded_String;

    procedure Set_It is
    begin
        Spin.Set_Format (SU.To_String (Format));
    end Set_It;

    procedure Good
           (Text : in String) is
    begin
        Format := SU.To_Unbounded_String (Text);
        No_Raise (Set_It'Access, "the format """ & Text & """ is taken");
        Check (Spin.Get_Format = Text, "and kept: """ & Spin.Get_Format & """");
    end Good;

    procedure Bad
           (Text : in String)
    is
        Before : constant String := Spin.Get_Format;
    begin
        Format := SU.To_Unbounded_String (Text);
        Raises (Set_It'Access, Constraint_Error'Identity,
            "the format """ & Text & """ raises Constraint_Error");
        Check (Spin.Get_Format = Before,
            "and the one before is kept: """ & Spin.Get_Format & """");
    end Bad;

begin

    Spn.Spinner'Class (Spin).Set_Colors (FLTK.Red_Color, FLTK.Green_Color);
    Check (Spin.Get_Background_Color = FLTK.Red_Color,
        "Set_Colors sets the field's background:" &
        FLTK.Color'Image (Spin.Get_Background_Color));
    Check (Spin.Get_Selection_Color = FLTK.Green_Color,
        "Set_Colors sets the field's selection color:" &
        FLTK.Color'Image (Spin.Get_Selection_Color));

    Good ("%g");
    Good ("%.3f");
    Good ("%.*f");
    Good ("%+08.2e units");
    Good ("100%% of %lg");
    Good ("plain text");
    Good ("%G");

    Bad ("%d");
    Bad ("%f and %f");
    Bad ("%*f");
    Bad ("%-.*f");
    Bad ("%.*d");
    Bad ("%Lf");
    Bad ("%9999f");
    Bad ("%.9999f");
    Bad ("%");
    Bad ("%n");
    Bad ("%s");

    Summary;

end Test_Spinner_Colors;
