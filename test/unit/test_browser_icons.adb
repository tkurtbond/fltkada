


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  N11 in PLAN.md and pofltk 56: a browser line's icon.  FLTK keeps the
--  Fl_Image * it is given and never deletes it (Fl_Browser.cxx:892-913),
--  so the image must outlive every line that shows it.  The binding kept
--  only the pointer, in a vector indexed by line that Insert, Remove, Move,
--  Swap, Clear and Load didn't change, so an icon went with the wrong line,
--  and a line drew an image already freed.


with

    Checks,
    FLTK.Images.RGB,
    FLTK.Probe,
    FLTK.Widgets.Groups.Browsers.Textline;

use

    Checks,
    FLTK;


procedure Test_Browser_Icons is

    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package TLB renames FLTK.Widgets.Groups.Browsers.Textline;

    Lines : TLB.Textline_Browser := TLB.Forge.Create (0, 0, 200, 150);

    Small : constant Color_Component_Array (1 .. 8 * 8 * 3) := (others => 200);
    Large : constant Color_Component_Array (1 .. 12 * 12 * 3) := (others => 50);

    function Icon_W
           (Line : in Positive)
        return Integer is
    begin
        if Lines.Has_Icon (Line) then
            return Lines.Get_Icon (Line).Get_W;
        else
            return 0;
        end if;
    end Icon_W;

    function Widths
        return String is
    begin
        return Integer'Image (Icon_W (1)) & Integer'Image (Icon_W (2))
            & Integer'Image (Icon_W (3)) & Integer'Image (Icon_W (4));
    end Widths;

    Ignore : Boolean;

begin

    Lines.Add ("one");
    Lines.Add ("two");
    Lines.Add ("three");

    --  The images go before the browser draws them.
    declare
        Eight  : constant RGB.RGB_Image := RGB.Forge.Create (Small, 8, 8);
        Twelve : constant RGB.RGB_Image := RGB.Forge.Create (Large, 12, 12);
    begin
        Lines.Set_Icon (1, Eight);
        Lines.Set_Icon (3, Twelve);
    end;
    Check (Widths = " 8 0 12 0", "icons set:" & Widths);
    Check (Prb.Capture (Lines), "a browser whose icons' images are gone draws");

    Lines.Insert (1, "zero");
    Check (Widths = " 0 8 0 12", "a line inserted above, they move down:" & Widths);

    Lines.Swap (2, 4);
    Check (Widths = " 0 12 0 8", "swapped lines swap their icons:" & Widths);

    Lines.Move (From => 2, To => 1);
    Check (Widths = " 12 0 0 8", "a moved line takes its icon:" & Widths);

    Lines.Remove (1);
    Check (Widths = " 0 0 8 0", "a line removed takes its icon:" & Widths);

    declare
        Ten : constant RGB.RGB_Image := RGB.Forge.Create (Large, 10, 10);
    begin
        Lines.Set_Icon (3, Ten);
        Lines.Set_Icon (1, Ten);
    end;
    Check (Widths = " 10 0 10 0", "an icon replaced:" & Widths);
    Lines.Remove_Icon (3);
    Check (Widths = " 10 0 0 0", "an icon removed:" & Widths);
    Ignore := Prb.Capture (Lines);

    Lines.Clear;
    Lines.Add ("again");
    Check (not Lines.Has_Icon (1), "a line added after Clear has no icon");

    Lines.Set_Icon (1, RGB.Forge.Create (Small, 8, 8));
    Check (Widths = " 8 0 0 0", "an icon from a temporary:" & Widths);
    Ignore := Prb.Capture (Lines);
    Prb.Release;

    Summary;

end Test_Browser_Icons;


