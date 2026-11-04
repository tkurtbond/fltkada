

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 23: some groups are made of children FLTK
--  makes, which are members of the C++ object: an Fl_Spinner's field and
--  buttons, an Fl_Color_Chooser's parts, an Fl_Scroll's scrollbars.  Clear
--  must leave them, or the group is left without its parts
--  (FLTKAda-BUGS.md 27).  Fl_Pack::clear also sets the pack's resizable to
--  none (FL/Fl_Pack.H:98); Fl_Group::remove makes it the pack itself
--  (Fl_Group.cxx:591).  And pofltk 72: a widget finalized inside a
--  callback is queued by Fl::delete_widget, so a group or table deleted
--  before the queue runs would delete it too, unless it has left its group.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Color_Choosers,
    FLTK.Widgets.Groups.Packed,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Static,
    FLTK.Widgets.Groups.Spinners,
    FLTK.Widgets.Groups.Tables,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Group_Clear is

    package Prb renames FLTK.Probe;
    package Bxs renames FLTK.Widgets.Boxes;
    package CC  renames FLTK.Widgets.Groups.Color_Choosers;
    package Pck renames FLTK.Widgets.Groups.Packed;
    package Scr renames FLTK.Widgets.Groups.Scrolls;
    package Spn renames FLTK.Widgets.Groups.Spinners;
    package Tab renames FLTK.Widgets.Groups.Tables;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window  : Win.Window := Win.Forge.Create (0, 0, 600, 400, "Test_Group_Clear");
    Spinner : Spn.Spinner := Spn.Forge.Create (Window, 10, 10, 100, 25);
    Chooser : CC.Color_Chooser := CC.Forge.Create (Window, 10, 50, 200, 100);
    Pack    : Pck.Packed_Group := Pck.Forge.Create (Window, 250, 10, 100, 200);
    Scroll  : Scr.Scroll := Scr.Forge.Create (Window, 400, 10, 100, 100);

    Spinner_Parts : constant Natural := Spinner.Number_Of_Children;
    Chooser_Parts : constant Natural := Chooser.Number_Of_Children;

    Extra   : Bxs.Box := Bxs.Forge.Create (0, 0, 10, 10);
    Other   : Bxs.Box := Bxs.Forge.Create (0, 0, 10, 10);
    P1      : constant Bxs.Box := Bxs.Forge.Create (Pack, 0, 0, 100, 25);
    P2      : constant Bxs.Box := Bxs.Forge.Create (Pack, 0, 0, 100, 30);
    Content : constant Bxs.Box := Bxs.Forge.Create (Scroll, 400, 10, 300, 300);

    Ignore : Boolean;

    type Box_Access is access Bxs.Box;
    procedure Free is new Ada.Unchecked_Deallocation (Bxs.Box, Box_Access);

    In_Table : Box_Access;
    In_Group : Box_Access;
    Freed    : Boolean := False;

    procedure Free_Them is
    begin
        Free (In_Table);
        Free (In_Group);
        Freed := True;
    end Free_Them;

begin

    Check (Spinner_Parts = 3, "a spinner has three parts:" & Natural'Image (Spinner_Parts));
    Check (Chooser_Parts > 0, "a colour chooser has parts:" & Natural'Image (Chooser_Parts));

    --  The spinner and chooser keep their parts, and lose what Ada added.
    Spinner.Add (Extra);
    Spinner.Clear;
    Check (Spinner.Number_Of_Children = Spinner_Parts and then Extra.Parent = null,
        "Clear leaves a spinner's own parts:" & Natural'Image (Spinner.Number_Of_Children));
    Spinner.Set_Value (4.0);
    Check (Spinner.Get_Value = 4.0, "a spinner cleared still has a value");

    Chooser.Add (Other);
    Chooser.Clear;
    Check (Chooser.Number_Of_Children = Chooser_Parts and then Other.Parent = null,
        "Clear leaves a colour chooser's own parts:"
        & Natural'Image (Chooser.Number_Of_Children));

    --  A pack cleared has no resizable, as Fl_Pack::clear leaves it.
    Pack.Set_Resizable (P2);
    Pack.Clear;
    Check (Pack.Number_Of_Children = 0 and then P1.Parent = null,
        "Clear takes a pack's children out");
    Check (Pack.Get_Resizable = null, "Clear leaves a pack no resizable");

    --  A scroll keeps its scrollbars.
    Scroll.Clear;
    Check (Scroll.Number_Of_Children = 2 and then Content.Parent = null,
        "Clear leaves a scroll its scrollbars:" & Natural'Image (Scroll.Number_Of_Children));

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Check (Prb.Capture (Spinner) and then Prb.Capture (Chooser) and then Prb.Capture (Scroll),
        "the groups cleared still draw");
    Prb.Release;
    Ignore := FLTK.Check;

    --  pofltk 72: widgets finalized inside a callback, then their table
    --  and group deleted before FLTK's queue runs.
    declare
        Cells : Tab.Table := Tab.Forge.Create (0, 0, 200, 200);
        Plain : FLTK.Widgets.Groups.Group := FLTK.Widgets.Groups.Forge.Create (0, 0, 200, 200);
    begin
        In_Table := new Bxs.Box'(Bxs.Forge.Create (0, 0, 10, 10));
        In_Group := new Bxs.Box'(Bxs.Forge.Create (0, 0, 10, 10));
        Cells.Add (In_Table.all);
        Plain.Add (In_Group.all);
        FLTK.Static.Add_Timeout (0.0, Free_Them'Unrestricted_Access);
        while not Freed loop
            exit when FLTK.Wait (0.1) < 0.0;
        end loop;
        Check (Freed and then Cells.Number_Of_Children = 0
            and then Plain.Number_Of_Children = 0,
            "widgets finalized in a callback leave their table and group");
        Cells.Clear;
    end;
    Ignore := FLTK.Check;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Group_Clear;


