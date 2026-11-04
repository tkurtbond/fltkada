


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 58: an item's widget is a child of the tree,
--  which the tree draws only through its item but which Fl_Group::handle
--  still sends events to.  ~Fl_Tree_Item forgets the widget and leaves it
--  in the tree (Fl_Tree_Item.cxx:97), where it still takes clicks.  The
--  other way round, a widget finalized, or added to another group, stays
--  its item's widget, and the tree draws it from freed memory.


with

    Ada.Exceptions,
    Checks,
    FLTK.Probe,
    FLTK.Tree_Items,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Tree_Widgets is

    package Prb renames FLTK.Probe;
    package TI  renames FLTK.Tree_Items;
    package Btn renames FLTK.Widgets.Buttons;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Tree_Widgets");
    Tree   : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 300, 300);

    Presses : Natural := 0;

    procedure Pressed
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Presses := Presses + 1;
    end Pressed;

    procedure Lay_Out is
        Ignore : Boolean;
    begin
        Ignore := Prb.Capture (Tree);
        Prb.Release;
    end Lay_Out;

    procedure Click
           (X, Y : in Integer)
    is
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, FLTK.Push, X, Y);
        Ignore := Prb.Mouse (Window, FLTK.Release, X, Y, Clicks => 1);
    end Click;

    B : constant TI.Tree_Item := Tree.Add ("b");
    C : constant TI.Tree_Item := Tree.Add ("c");
    D : constant TI.Tree_Item := Tree.Add ("d");

    Button : Btn.Button := Btn.Forge.Create (Tree, 0, 0, 80, 20, "button");
    Moved  : Btn.Button := Btn.Forge.Create (Tree, 0, 0, 80, 20, "moved");

begin

    Tree.Set_Show_Root (False);
    Button.Set_Callback (Pressed'Unrestricted_Access);
    TI.Set_Widget (B, Button);
    TI.Set_Widget (D, Moved);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Lay_Out;

    declare
        X : constant Integer := Button.Get_X + 10;
        Y : constant Integer := Button.Get_Y + 10;
    begin
        Click (X, Y);
        Check (Presses = 1, "an item's widget takes a click");

        --  pofltk 58: the item goes, and its widget with it.
        Tree.Remove (B);
        Lay_Out;
        Click (X, Y);
        Check (Presses = 1, "a removed item's widget takes no click where it was");
        Check (Button.Parent = null, "a removed item's widget is no longer in the tree");
    end;

    --  The widget goes first.
    declare
        Gone : Btn.Button := Btn.Forge.Create (Tree, 0, 0, 80, 20, "gone");
    begin
        TI.Set_Widget (C, Gone);
        Lay_Out;
        Check (TI.Has_Widget (C), "an item shows a widget");
    end;
    Lay_Out;
    Check (not TI.Has_Widget (C), "an item whose widget was finalized has none");

    --  The widget is added to another group.
    Window.Add (Moved);
    Lay_Out;
    Check (not TI.Has_Widget (D), "an item whose widget moved to another group has none");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tree_Widgets;


