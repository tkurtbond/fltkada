

--  Released into the public domain


--  A textline browser's column widths: set, read back, set again with
--  a different count, and set from an array that doesn't start at 1.


with

    Ada.Command_Line,
    Ada.Text_IO,
    FLTK.Widgets.Groups.Browsers.Textline;

use

    FLTK.Widgets.Groups.Browsers.Textline;


procedure Column_Widths is

    Failed : Boolean := False;

    Browser : Textline_Browser := Forge.Create (0, 0, 200, 100);

    procedure Check
           (Label    : in String;
            Expected : in FLTK.Widgets.Groups.Browsers.Textline.Column_Widths)
    is
        Got : constant FLTK.Widgets.Groups.Browsers.Textline.Column_Widths :=
            Browser.Get_Column_Widths;
    begin
        if Got = Expected then
            Ada.Text_IO.Put_Line ("ok   - " & Label);
        else
            Ada.Text_IO.Put_Line ("FAIL - " & Label);
            Failed := True;
        end if;
    end Check;

    Offset : constant FLTK.Widgets.Groups.Browsers.Textline.Column_Widths (5 .. 6) :=
        (40, 60);

begin

    Browser.Set_Column_Widths ((10, 20, 30));
    Check ("three widths read back", (10, 20, 30));

    Browser.Set_Column_Widths ((1 => 50));
    Check ("one width replaces three", (1 => 50));

    Browser.Set_Column_Widths (Offset);
    Check ("widths from an array starting at 5", (40, 60));

    if Failed then
        Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
    end if;

end Column_Widths;
