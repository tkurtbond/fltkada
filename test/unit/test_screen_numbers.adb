--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 97: DPI, Get_Scale and Set_Scale numbered the screens
--  1 .. Count, but Containing returned FLTK's 0 .. Count - 1, and Work_Area
--  and Bounding_Rect took it.  So Get_Scale (Containing (X, Y)) raised on a
--  display of one screen.  Every screen number is now 1 .. Count.


with

    Ada.Exceptions,
    Checks,
    FLTK.Screen;

use

    Checks;


procedure Test_Screen_Numbers is

    package Scr renames FLTK.Screen;

    X, Y, W, H     : Integer;
    PX, PY, PW, PH : Integer;
    Horiz, Vert    : Float;
    Scale          : Float;

    function Raises
           (Number : in Integer;
            Which  : in Character)
        return Boolean is
    begin
        case Which is
        when 'W' => Scr.Work_Area (X, Y, W, H, Number);
        when 'B' => Scr.Bounding_Rect (X, Y, W, H, Number);
        when others => Scr.DPI (Horiz, Vert, Number);
        end case;
        return False;
    exception
    when Constraint_Error =>
        return True;
    end Raises;

begin

    Check (Scr.Count >= 1, "there is a screen," & Integer'Image (Scr.Count));

    Scr.Bounding_Rect (X, Y, W, H, 1);
    Check (W > 0 and H > 0, "screen 1 has a size," & Integer'Image (W) & Integer'Image (H));
    Check (Scr.Containing (X + W / 2, Y + H / 2) = 1, "screen 1 contains its centre,"
        & Integer'Image (Scr.Containing (X + W / 2, Y + H / 2)));
    Check (Scr.Containing (X + 1, Y + 1, 5, 5) = 1, "screen 1 contains a rectangle in it,"
        & Integer'Image (Scr.Containing (X + 1, Y + 1, 5, 5)));
    Check (Scr.Containing (-100_000, -100_000) = 1, "a point off every screen gives 1");
    Check (Scr.Containing (-100_000, -100_000, 5, 5) = 1, "a rectangle off every screen gives 1");

    Scr.Bounding_Rect (PX, PY, PW, PH, X + 1, Y + 1);
    Check (PX = X and PY = Y and PW = W and PH = H,
        "Bounding_Rect by a point in screen 1 is Bounding_Rect (1)");
    Scr.Work_Area (X, Y, W, H, 1);
    Scr.Work_Area (PX, PY, PW, PH, X + 1, Y + 1);
    Check (PX = X and PY = Y and PW = W and PH = H,
        "Work_Area by a point in screen 1 is Work_Area (1)");

    begin
        Scale := Scr.Get_Scale (Scr.Containing (10, 10));
        Check (Scale > 0.0, "Get_Scale (Containing (10, 10)) is positive");
    exception
    when Constraint_Error =>
        Check (False, "Get_Scale (Containing (10, 10)) raised");
    end;

    for Which of String'("WBD") loop
        Check (Raises (0, Which), Which & " raises for screen 0");
        Check (Raises (Scr.Count + 1, Which), Which & " raises for screen Count + 1");
        Check (not Raises (Scr.Count, Which), Which & " doesn't raise for screen Count");
    end loop;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Screen_Numbers;
