


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  N9 in PLAN.md and pofltk 52: the widgets in a Table's cells.  An
--  Fl_Table's own children are its two scrollbars and an inner Fl_Scroll;
--  the widgets of its cells are the inner group's, and Fl_Table's child
--  methods hide Fl_Group's rather than override them (FL/Fl_Table.H:775-
--  867).  So a Table let go before the Ada widgets in its cells deleted
--  them in ~Fl_Group, and Ada freed them again; and Remove by place,
--  which only Group had, removed a scrollbar.


with

    Checks,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Tables;

use

    Checks,
    FLTK;


procedure Test_Table_Children is

    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Tab renames FLTK.Widgets.Groups.Tables;

    use type Grp.Extended_Index;

begin

    --  Remove by place, through Group'Class too.
    declare
        One   : Btn.Button := Btn.Forge.Create (0, 0, 10, 10, "one");
        Two   : Btn.Button := Btn.Forge.Create (0, 0, 10, 10, "two");
        Three : Btn.Button := Btn.Forge.Create (0, 0, 10, 10, "three");
        Cells : Tab.Table  := Tab.Forge.Create (0, 0, 200, 200);
        Any   : Grp.Group'Class renames Grp.Group'Class (Cells);
    begin
        Check (Cells.Number_Of_Children = 0, "a new table has no children:"
            & Natural'Image (Cells.Number_Of_Children));
        Any.Add (One);
        Any.Add (Two);
        Any.Add (Three);
        Check (Any.Number_Of_Children = 3, "three added:" & Natural'Image (Any.Number_Of_Children));
        Any.Remove (Grp.Index (1));
        Check (Any.Number_Of_Children = 2,
            "Remove by place removes one:" & Natural'Image (Any.Number_Of_Children));
        Check (Any.Find (One) = Grp.No_Index, "and the one it removes is the first");
        Check (Any.Find (Two) = 1, "and the second is now first");
        Any.Remove (Grp.Index (2));
        Check (Any.Number_Of_Children = 1 and Any.Find (Two) = 1,
            "Remove by place, of the last:" & Natural'Image (Any.Number_Of_Children));
    end;
    Check (True, "a Table whose children were removed by place");

    --  The table goes first, then the widgets in its cells.
    declare
        One   : Btn.Button := Btn.Forge.Create (0, 0, 10, 10, "one");
        Two   : Btn.Button := Btn.Forge.Create (0, 0, 10, 10, "two");
        Cells : Tab.Table  := Tab.Forge.Create (0, 0, 200, 200);
    begin
        Cells.Add (One);
        Cells.Add (Two);
        Check (Cells.Number_Of_Children = 2,
            "added to a table:" & Natural'Image (Cells.Number_Of_Children));
    end;
    Check (True, "a Table let go before its cells' widgets");

    --  The widgets go first, then the table.
    declare
        Cells : Tab.Table  := Tab.Forge.Create (0, 0, 200, 200);
        One   : constant Btn.Button := Btn.Forge.Create (Cells, 0, 0, 10, 10, "one");
        Two   : constant Btn.Button := Btn.Forge.Create (Cells, 0, 0, 10, 10, "two");
    begin
        Check (Cells.Number_Of_Children = 2,
            "made in a table:" & Natural'Image (Cells.Number_Of_Children));
        Check (Cells.Find (One) = 1 and Cells.Find (Two) = 2, "found in the table");
    end;
    Check (True, "a Table let go after its cells' widgets");

    Summary;

end Test_Table_Children;


