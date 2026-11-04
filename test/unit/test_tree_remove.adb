


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 41, 42 and 59: Fl_Tree keeps pointers to
--  items it deletes.  Fl_Tree::remove forgets the item it is given as the
--  last one clicked (_lastselect), but not its descendants, and
--  Fl_Tree_Item::replace and clear_children forget neither
--  (Fl_Tree.cxx:917-948).  Nothing clears callback_item.  And a push that
--  calls back makes the item pushed the last one clicked after the
--  callback has run, so a drag then moves an item the callback removed
--  (Fl_Tree.cxx:416-417, 523-539).


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Tree_Items.Custom,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use

    Checks;

use type

    FLTK.Widgets.Groups.Trees.Reason_Kind;


procedure Test_Tree_Remove is

    package Prb renames FLTK.Probe;
    package TI  renames FLTK.Tree_Items;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Tree_Remove");
    Tree   : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 300, 300);

    Remove_In_Callback : Boolean := False;
    Gone_In_Callback   : Boolean := False;

    procedure Called
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        if Remove_In_Callback and then Tree.Callback_Reason = Trs.Selected then
            Tree.Remove (Tree.Callback_Item);
            Gone_In_Callback := TI.Is_Null (Tree.Callback_Item);
        end if;
    end Called;

    --  Draws the tree, so that its items know where they are.
    procedure Lay_Out is
        Ignore : Boolean;
    begin
        Ignore := Prb.Capture (Tree);
        Prb.Release;
    end Lay_Out;

    function Middle
           (Item : in TI.Tree_Item)
        return Integer is
    begin
        return TI.Label_Y (Item) + TI.Label_H (Item) / 2;
    end Middle;

    procedure Mouse
           (Event : in FLTK.Event_Kind;
            Y     : in Integer;
            State : in FLTK.Modifier := FLTK.Mod_None)
    is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, Event, 60, Y, State => State);
    end Mouse;

    procedure Click
           (Item  : in TI.Tree_Item;
            State : in FLTK.Modifier := FLTK.Mod_None)
    is
        Y : constant Integer := Middle (Item);
    begin
        Mouse (FLTK.Push, Y, State);
        Mouse (FLTK.Release, Y, State);
    end Click;

    function Selected
           (Path : in String)
        return Boolean is
    begin
        return TI.Is_Selected (Tree.Find (Path));
    end Selected;

    Ignore : Natural;
    A, B, C, D, E : TI.Tree_Item;

begin

    Tree.Set_Callback (Called'Unrestricted_Access);
    Tree.Set_Show_Root (False);
    B := Tree.Add ("a/b");
    C := Tree.Add ("c");
    D := Tree.Add ("d");
    E := Tree.Add ("e");
    A := Tree.Find ("a");
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Lay_Out;

    --  The selection extended from the last item clicked.
    Tree.Set_Select_Mode (TI.Multi_Selection);
    Click (B);
    Click (D, FLTK.Mod_Shift);
    Check (Selected ("a/b") and then Selected ("c") and then Selected ("d")
            and then not Selected ("e"),
        "a Shift-click extends the selection from the last item clicked");

    --  pofltk 41: the last item clicked, b, removed with its parent.
    Click (B);
    Tree.Remove (A);
    Ignore := Tree.Deselect_All;
    Lay_Out;
    Click (C, FLTK.Mod_Shift);
    Check (Selected ("c") and then not Selected ("d") and then not Selected ("e"),
        "a Shift-click after the last item clicked was removed with its parent selects one item");

    --  The same with the item cleared from its parent, and replaced.
    A := Tree.Add ("a2/b2");
    Lay_Out;
    Click (A);
    Tree.Clear_Children (Tree.Find ("a2"));
    Ignore := Tree.Deselect_All;
    Lay_Out;
    Click (C, FLTK.Mod_Shift);
    Check (Selected ("c") and then not Selected ("d") and then not Selected ("e"),
        "a Shift-click after the last item clicked was cleared selects one item");
    Tree.Remove (Tree.Find ("a2"));

    declare
        New_Item : constant FLTK.Tree_Items.Custom.Custom_Item :=
            FLTK.Tree_Items.Custom.Forge.Create (Tree);
        Old_Item : constant TI.Tree_Item := Tree.Add ("old");
    begin
        TI.Set_Label (New_Item.Item, "new");
        Lay_Out;
        Click (Old_Item);
        Check (not TI.Is_Null (TI.Replace (Old_Item, New_Item.Item)), "an item is replaced");
        Ignore := Tree.Deselect_All;
        Lay_Out;
        Click (C, FLTK.Mod_Shift);
        Check (Selected ("c") and then not Selected ("d") and then not Selected ("e")
                and then not Selected ("new"),
            "a Shift-click after the last item clicked was replaced selects one item");
        Tree.Remove (Tree.Find ("new"));
    end;

    --  pofltk 42: an item removed in the tree's callback.
    Tree.Set_Select_Mode (TI.Single_Selection);
    Ignore := Tree.Deselect_All;
    Lay_Out;
    Remove_In_Callback := True;
    Click (D);
    Check (Gone_In_Callback, "an item removed in the callback is no longer Callback_Item");
    Check (TI.Number_Of_Children (Tree.Root) = 2, "the item was removed in its own callback");

    --  pofltk 59: the same as the item is pushed, in a draggable tree, and
    --  then a drag onto c.  FLTK would make e the last item clicked, and
    --  move it, from freed memory, which valgrind sees.
    Tree.Set_Select_Mode (TI.Single_Draggable_Selection);
    Ignore := Tree.Deselect_All;
    Lay_Out;
    declare
        To : constant Integer := Middle (C);
    begin
        Mouse (FLTK.Push, Middle (E));
        Mouse (FLTK.Drag, To);
        Mouse (FLTK.Release, To);
    end;
    Remove_In_Callback := False;
    Check (TI.Number_Of_Children (Tree.Root) = 1
            and then TI.Get_Label (TI.Child (Tree.Root, 1)) = "c",
        "an item removed in its callback as it is pushed, and a drag");

    --  pofltk 42: Clear, outside the callback, leaves no callback item.
    Click (C);
    Tree.Clear;
    Check (TI.Is_Null (Tree.Callback_Item), "after Clear there is no Callback_Item");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tree_Remove;


