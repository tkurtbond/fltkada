


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Phase 12's window list: Get_First_Window and Get_Next_Window skip a
--  window FLTK made, such as a file chooser's, whose user data isn't an
--  Ada object, as pofltk's ofl_first_window does, and Get_Next_Window of
--  a window not shown is null.  Get_Top_Modal and a widget's Parent give
--  null for a window FLTK made (FLTKAda-BUGS.md 51), and Child of a part
--  FLTK made raises Internal_FLTK_Error.


with

    Checks,
    FLTK.File_Choosers,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Window_List is

    package FC  renames FLTK.File_Choosers;
    package Bxs renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type FLTK.Widgets.Groups.Group;

    procedure Settle is
    begin
        for N in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Settle;

    One     : Win.Window := Win.Forge.Create (0, 0, 100, 100, "one");
    Two     : Win.Window := Win.Forge.Create (120, 0, 100, 100, "two");
    Hidden  : constant Win.Window := Win.Forge.Create (240, 0, 100, 100, "hidden");
    Chooser : FC.File_Chooser := FC.Forge.Create ("Test_Window_List", "*", ".");
    Extra   : Bxs.Box := Bxs.Forge.Create (0, 0, 100, 20, "extra");
    Term    : constant FLTK.Widgets.Groups.Terminals.Terminal :=
        FLTK.Widgets.Groups.Terminals.Forge.Create (One, 0, 0, 100, 100);

    procedure Scrollbar is
        Ignore : constant String := Term.Child (1).Get_Label;
    begin
        null;
    end Scrollbar;

    Seen_One, Seen_Two, Seen_Other : Natural := 0;

    procedure Walk is
        Item : access Win.Window'Class := FLTK.Static.Get_First_Window;
    begin
        Seen_One := 0;
        Seen_Two := 0;
        Seen_Other := 0;
        while Item /= null loop
            if Item.Get_Label = "one" then
                Seen_One := Seen_One + 1;
            elsif Item.Get_Label = "two" then
                Seen_Two := Seen_Two + 1;
            else
                Seen_Other := Seen_Other + 1;
            end if;
            exit when Seen_One + Seen_Two + Seen_Other > 10;
            Item := FLTK.Static.Get_Next_Window (Item.all);
        end loop;
    end Walk;

begin

    One.Show;
    Two.Show;
    Settle;
    Walk;
    Check (Seen_One = 1 and Seen_Two = 1 and Seen_Other = 0,
        "the two windows shown are listed once each");

    Chooser.Add_Extra (Extra);
    Chooser.Show;
    while not Chooser.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Settle;
    --  The chooser's window is shown last, so it is first.
    Walk;
    Check (Seen_One = 1 and Seen_Two = 1 and Seen_Other = 0,
        "with a file chooser shown, its window, which FLTK made, is skipped:" &
        Natural'Image (Seen_One) & Natural'Image (Seen_Two) & Natural'Image (Seen_Other));
    Check (FLTK.Probe.Modal_H > 0, "the chooser's window is the top modal one");
    Check (FLTK.Static.Get_Top_Modal = null,
        "Get_Top_Modal of the chooser's window, which has no Ada object, is null");
    Check (Extra.Parent = null,
        "the extra widget's parent, the chooser's group, is not taken for Ada (51)");
    Check (FLTK.Static.Get_Next_Window (Hidden) = null,
        "Get_Next_Window of a window not shown is null");
    Raises (Scrollbar'Unrestricted_Access, FLTK.Internal_FLTK_Error'Identity,
        "Child of a part FLTK made, a terminal's scrollbar, raises Internal_FLTK_Error");

    Chooser.Hide;
    One.Hide;
    Two.Hide;
    Settle;
    Check (FLTK.Static.Get_First_Window = null, "and nothing once all are hidden");
    Summary;

end Test_Window_List;
