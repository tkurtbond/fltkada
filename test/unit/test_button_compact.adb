--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 20:  Fl_Button::compact, after pofltk's CompactKeys in
--  test/TestButtons.Mod.  A compact key is drawn with its group's box,
--  clipped to the key, and a line where it meets another key.  Two keys
--  fill a group:  the right key's right edge is the group's, so it is
--  drawn as before, and its left edge is inside the group's box.


with

    Checks,
    FLTK.Probe,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Button_Compact is

    package Prb renames FLTK.Probe;
    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;

    W : constant := 30;
    H : constant := 20;

    type Image is array (0 .. W - 1, 0 .. H - 1) of Prb.RGB;

    Pad   : Win.Window := Win.Forge.Create (0, 0, 100, 60, "Test_Button_Compact");
    Keys  : Grp.Group := Grp.Forge.Create (Pad, 10, 10, 2 * W, H);
    Left  : Btn.Button := Btn.Forge.Create (Keys, 10, 10, W, H);
    Right : Btn.Button := Btn.Forge.Create (Keys, 10 + W, 10, W, H);

    Plain, Compact : Image;

    procedure Take
           (Into : out Image) is
    begin
        for X in Image'Range (1) loop
            for Y in Image'Range (2) loop
                Into (X, Y) := Prb.Pixel (X, Y);
            end loop;
        end loop;
        Prb.Release;
    end Take;

    function Differ
           (X : in Natural)
        return Boolean is
    begin
        for Y in Image'Range (2) loop
            if Plain (X, Y) /= Compact (X, Y) then
                return True;
            end if;
        end loop;
        return False;
    end Differ;

begin

    Keys.Set_Box (FLTK.Up_Box);
    Check (not Right.Is_Compact, "a button isn't compact to start with");
    Check (Prb.Capture (Right), "a plain key draws");
    Take (Plain);
    Left.Set_Compact (True);
    Right.Set_Compact (True);
    Check (Right.Is_Compact, "Set_Compact reads back");
    Check (Prb.Capture (Right), "a compact key draws");
    Take (Compact);
    Check (not Differ (W - 1), "a compact key's edge on its group's edge is drawn as before");
    Check (Differ (0), "a compact key's edge inside its group is the group's box");
    Right.Set_Compact (False);
    Check (not Right.Is_Compact, "and Set_Compact (False) turns it off");
    Summary;

end Test_Button_Compact;
