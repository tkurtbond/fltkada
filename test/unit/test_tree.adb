

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestTree and the first part of TestTreeItems:
--  items, paths, structure, open and close, selection by the program and
--  by the mouse, and items the program makes.  Removal is in
--  test_tree_remove, widgets in items in test_tree_widgets, icons in
--  test_tree_icons, margins in test_tree_margins.  pofltk's IsLive checks
--  have no counterpart, since a Tree_Item is a plain handle.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Tree_Items.Custom,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use

    Checks;

use type

    FLTK.Color,
    FLTK.Font_Size,
    FLTK.Tree_Items.Sort_Kind,
    FLTK.Tree_Items.Tree_Item,
    FLTK.Widgets.Groups.Trees.Reason_Kind;


procedure Test_Tree is

    package Prb renames FLTK.Probe;
    package TI  renames FLTK.Tree_Items;
    package TIC renames FLTK.Tree_Items.Custom;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Tree");
    Tree   : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 300, 300);

    Calls  : Natural := 0;
    Last   : TI.Tree_Item;
    Reason : Trs.Reason_Kind := Trs.No_Reason;

    procedure Called
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Calls := Calls + 1;
        Last := Tree.Callback_Item;
        Reason := Tree.Callback_Reason;
    end Called;

    --  An item that fills its label's place with red, and counts its draws.
    type Red_Item is new TIC.Custom_Item with record
        Draws : Natural := 0;
    end record;

    overriding function Draw_Item_Content
           (This   : in out Red_Item;
            Render : in     Boolean)
        return Integer
    is
        Item : constant TI.Tree_Item := This.Item;
    begin
        if Render then
            This.Draws := This.Draws + 1;
            FLTK.Draw.Rect_Fill
               (TI.Label_X (Item), TI.Label_Y (Item), TI.Label_W (Item), TI.Label_H (Item),
                FLTK.Red_Color);
        end if;
        return TI.Label_X (Item) + TI.Label_W (Item);
    end Draw_Item_Content;

    type Red_Access is access Red_Item;

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

    procedure Click
           (Item  : in TI.Tree_Item;
            State : in FLTK.Modifier := FLTK.Mod_None)
    is
        Y      : constant Integer := Middle (Item);
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, FLTK.Push, 60, Y, State => State);
        Ignore := Prb.Mouse (Window, FLTK.Release, 60, Y, State => State);
    end Click;

    function Labelled
           (Item  : in TI.Tree_Item;
            Label : in String)
        return Boolean is
    begin
        return not TI.Is_Null (Item) and then TI.Get_Label (Item) = Label;
    end Labelled;

    Red_RGB : constant Prb.RGB := Prb.To_RGB (255, 0, 0);

    Root, A, B, C, D, E, I, J : TI.Tree_Item;
    Count : Natural;
    Ignore_Item : TI.Tree_Item;

begin

    Tree.Set_Callback (Called'Unrestricted_Access);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    --  Items and paths
    Root := Tree.Root;
    Check (Labelled (Root, "ROOT") and then TI.Is_Root (Root) and then TI.Depth (Root) = 0
            and then TI.Is_Null (TI.Parent (Root)) and then TI.Number_Of_Children (Root) = 0
            and then not TI.Has_Children (Root),
        "a tree starts with its root");
    B := Tree.Add ("a/b");
    A := Tree.Find ("a");
    Check (Labelled (A, "a") and then TI.Depth (A) = 1 and then TI.Parent (A) = Root
            and then TI.Parent (B) = A and then TI.Depth (B) = 2 and then TI.Has_Children (A),
        "Add makes the path's items");
    Check (Tree.Find ("a/b") = B and then A /= B and then TI.Is_Null (Tree.Find ("a/x"))
            and then TI.Is_Null (Tree.Find ("b")),
        "Find, and =");
    Check (Tree.Item_Pathname (B) = "ROOT/a/b", "Item_Pathname, with the root shown");
    Check (Tree.Item_Pathname (TI.No_Tree_Item) = "ROOT", "Item_Pathname of no item is the root's");
    Tree.Set_Show_Root (False);
    Check (not Tree.Get_Show_Root and then Tree.Item_Pathname (B) = "a/b", "and without");
    C := Tree.Add ("c");
    D := Tree.Add ("d");
    E := Tree.Add ("e");
    Check (TI.Number_Of_Children (Root) = 4 and then TI.Child (Root, 1) = A
            and then TI.Child (Root, 4) = E,
        "Number_Of_Children and Child, from 1");

    --  FLTKAda-BUGS.md 111: Child read past FLTK's array.
    begin
        I := TI.Child (Root, 5);
        Check (False, "Child past the last child raises Constraint_Error");
    exception
    when Constraint_Error =>
        Check (True, "Child past the last child raises Constraint_Error");
    end;

    TI.Swap_Children (Root, 1, 4);
    Check (TI.Child (Root, 1) = E and then TI.Child (Root, 4) = A and then TI.Child (Root, 2) = C
            and then TI.Next (Root) = E and then Tree.Last = B
            and then TI.Child (A, 1) = B and then TI.Parent (B) = A,
        "Swap_Children by place, the items keeping their children");
    TI.Swap_Children (Root, 4, 1);
    Check (TI.Child (Root, 1) = A and then TI.Child (Root, 4) = E, "and back");
    begin
        TI.Swap_Children (Root, 1, 5);
        Check (False, "Swap_Children past the last child raises Constraint_Error");
    exception
    when Constraint_Error =>
        Check (True, "Swap_Children past the last child raises Constraint_Error");
    end;
    Check (Tree.First = Root and then TI.Next (Root) = A and then TI.Next (A) = B
            and then TI.Next (B) = C and then Tree.Last = E and then TI.Is_Null (TI.Next (E))
            and then TI.Prev (C) = B and then TI.Is_Null (TI.Prev (Root)),
        "Next and Prev go down the tree, children after their parent");

    I := Tree.Add ("a/x");
    TI.Set_Label (I, "x/y");
    Check (Labelled (I, "x/y") and then TI.Number_Of_Children (A) = 2
            and then Tree.Item_Pathname (I) = "a/x\/y" and then Tree.Find ("a/x\/y") = I,
        "a label with a slash is escaped in paths");
    Tree.Remove (I);

    I := Tree.Insert (A, "first", 0);
    J := Tree.Insert_Above (B, "above");
    Check (Labelled (TI.Child (A, 1), "first") and then Labelled (TI.Child (A, 2), "above")
            and then TI.Child (A, 3) = B,
        "Insert and Insert_Above");
    Tree.Remove (I);
    Tree.Remove (J);
    I := Tree.Insert (A, "past", 99);
    Check (TI.Child (A, 2) = I, "Insert past the last place adds at the end, as FLTK clamps it");
    Tree.Remove (I);
    Check (TI.Is_Null (Tree.Insert_Above (Root, "x")), "Insert_Above of the root");
    TI.Set_Label (B, "B");
    Check (Labelled (B, "B") and then Tree.Find ("a/B") = B, "Set_Label");
    TI.Set_Label (B, "b");

    Tree.Set_Sort_Order (TI.Ascending);
    Check (Tree.Get_Sort_Order = TI.Ascending, "Get_Sort_Order");
    Ignore_Item := Tree.Add ("s/m");
    Ignore_Item := Tree.Add ("s/z");
    Ignore_Item := Tree.Add ("s/a");
    I := Tree.Find ("s");
    Check (Labelled (TI.Child (I, 1), "a") and then Labelled (TI.Child (I, 2), "m")
            and then Labelled (TI.Child (I, 3), "z"),
        "Set_Sort_Order sorts items as they are added");
    Tree.Remove (I);
    Tree.Set_Sort_Order (TI.No_Sort);

    Ignore_Item := Tree.Add ("a/k1");
    Ignore_Item := Tree.Add ("a/k2");
    Tree.Clear_Children (A);
    Check (TI.Number_Of_Children (A) = 0 and then TI.Is_Null (Tree.Find ("a/k1")),
        "Clear_Children");
    B := Tree.Add ("a/b");

    --  Open and close
    Check (TI.Is_Open (A) and then TI.Is_Tree_Visible (B), "items start open");
    Tree.Close (A);
    Check (not TI.Is_Open (A) and then not TI.Is_Tree_Visible (B) and then TI.Is_Tree_Visible (A),
        "Close hides the children");
    Check (TI.Is_Visible (B), "but leaves FLTK's visible flag, which is always set");
    Tree.Open (A);
    Check (TI.Is_Open (A) and then TI.Is_Tree_Visible (B), "Open");
    Tree.Open_Toggle (A);
    Check (not TI.Is_Open (A), "Open_Toggle");
    Tree.Open_Toggle (A);

    --  Selection by the program.  Unlike pofltk's Select, Select_Item and
    --  Deselect call back, as Fl_Tree::select and deselect do by default.
    Calls := 0;
    Tree.Select_Item (B);
    Tree.Select_Item (D);
    declare
        Chosen : constant TI.Tree_Item_Array := Tree.Selected_Items;
    begin
        Check (TI.Is_Selected (B) and then TI.Is_Selected (D)
                and then Chosen'Length = 2 and then Chosen (Chosen'First) = B
                and then Chosen (Chosen'Last) = D,
            "Select_Item and Selected_Items, whatever the mode");
    end;
    Check (Calls = 2 and then Last = D and then Reason = Trs.Selected,
        "Select_Item calls back");
    Tree.Select_Item (D);
    Check (Calls = 2, "but not for an item already selected");
    Tree.Deselect (B);
    Check (not TI.Is_Selected (B) and then Calls = 3 and then Last = B
            and then Reason = Trs.Deselected,
        "Deselect, which calls back");
    Calls := 0;
    Count := Tree.Select_All;
    Check (Count = 5 and then TI.Is_Selected (A) and then TI.Is_Selected (E)
            and then TI.Is_Selected (Root),
        "Select_All, the hidden root too, returns how many changed");
    Check (Calls = 5, "and calls back for each");
    Count := Tree.Deselect_All;
    Check (Count = 6 and then Tree.Selected_Items'Length = 0,
        "Deselect_All, the root too, returns how many changed");

    --  Select_Toggle and walking the selection, from pofltk's TestTree.
    --  Unlike pofltk's ToggleSelect, Select_Toggle calls back, as
    --  Fl_Tree::select_toggle does by default.
    Calls := 0;
    Tree.Select_Toggle (B);
    Tree.Select_Toggle (D);
    Check (TI.Is_Selected (B) and then TI.Is_Selected (D) and then Calls = 2 and then Last = D
            and then Reason = Trs.Selected,
        "Select_Toggle selects, and calls back");
    Check (Tree.First_Selected = B and then Tree.Last_Selected = D
            and then Tree.Next_Selected (B) = D and then TI.Is_Null (Tree.Next_Selected (D))
            and then Tree.Prev_Selected (D) = B and then TI.Is_Null (Tree.Prev_Selected (B)),
        "First_Selected, Last_Selected, Next_Selected, Prev_Selected");
    Check (Tree.Next_Selected (TI.No_Tree_Item) = B
            and then Tree.Prev_Selected (TI.No_Tree_Item) = D,
        "Next_Selected and Prev_Selected of no item start from the first and the last");
    Tree.Select_Toggle (B);
    Check (not TI.Is_Selected (B) and then Tree.First_Selected = D and then Calls = 3
            and then Last = B and then Reason = Trs.Deselected,
        "Select_Toggle deselects, and calls back");
    Count := Tree.Deselect_All;
    Check (TI.Is_Null (Tree.First_Selected) and then TI.Is_Null (Tree.Last_Selected),
        "First_Selected and Last_Selected with none selected");

    --  FLTKAda-BUGS.md 127: FLTK dereferenced a null item.
    declare
        procedure Expect
               (Label : in String;
                What  : not null access procedure)
        is
        begin
            What.all;
            Check (False, Label & " of No_Tree_Item raises Constraint_Error");
        exception
        when Constraint_Error =>
            Check (True, Label & " of No_Tree_Item raises Constraint_Error");
        end Expect;
        procedure Do_Open is
        begin
            Tree.Open (TI.No_Tree_Item);
        end Do_Open;
        procedure Do_Select is
        begin
            Tree.Select_Toggle (TI.No_Tree_Item);
        end Do_Select;
        procedure Do_Remove is
        begin
            Tree.Remove (TI.No_Tree_Item);
        end Do_Remove;
        procedure Do_Insert is
        begin
            Ignore_Item := Tree.Insert (TI.No_Tree_Item, "x", 0);
        end Do_Insert;
        procedure Do_Label is
        begin
            TI.Set_Label (TI.No_Tree_Item, "x");
        end Do_Label;
        procedure Do_Next is
        begin
            Ignore_Item := TI.Next (TI.No_Tree_Item);
        end Do_Next;
    begin
        Expect ("Tree.Open", Do_Open'Access);
        Expect ("Tree.Select_Toggle", Do_Select'Access);
        Expect ("Tree.Remove", Do_Remove'Access);
        Expect ("Tree.Insert", Do_Insert'Access);
        Expect ("Tree_Items.Set_Label", Do_Label'Access);
        Expect ("Tree_Items.Next", Do_Next'Access);
    end;

    TI.Deactivate (B);
    Check (not TI.Is_Active (B), "Deactivate");
    TI.Activate (B);
    Check (TI.Is_Active (B), "Activate");
    TI.Set_Label_FG_Color (B, FLTK.Red_Color);
    TI.Set_Label_Size (B, 20);
    Check (TI.Get_Label_FG_Color (B) = FLTK.Red_Color and then TI.Get_Label_Size (B) = 20,
        "an item's label color and size");
    TI.Set_Label_FG_Color (B, Tree.Get_Item_Label_Color);
    TI.Set_Label_Size (B, Tree.Get_Item_Label_Size);

    --  Selection by the mouse
    Lay_Out;
    Calls := 0;
    Click (B);
    Check (TI.Is_Selected (B) and then Calls = 1 and then Last = B
            and then Reason = Trs.Selected,
        "a click selects an item, and calls back with it");
    Click (C);
    Check (TI.Is_Selected (C) and then not TI.Is_Selected (B) and then Calls = 3,
        "a click deselects the other, calling back for each");
    Tree.Set_Select_Mode (TI.Multi_Selection);
    Click (B);
    Click (D, FLTK.Mod_Shift);
    Check (TI.Is_Selected (B) and then TI.Is_Selected (C) and then TI.Is_Selected (D)
            and then not TI.Is_Selected (E),
        "a Shift-click extends the selection");
    Count := Tree.Deselect_All;
    Tree.Set_Select_Mode (TI.Single_Selection);

    --  Items the program makes
    declare
        R : constant Red_Access := new Red_Item'(TIC.Forge.Create (Tree) with Draws => 0);
        R3 : constant Red_Access := new Red_Item'(TIC.Forge.Create (Tree) with Draws => 0);
        M, Two, Three : TI.Tree_Item;
        X, Y, W, H : Integer;
        OK : Boolean;
    begin
        TI.Set_Label (R.Item, "red");
        Check (Tree.Add ("m/red", R.Item) = R.Item and then Tree.Find ("m/red") = R.Item
                and then Labelled (R.Item, "red"),
            "Add of a program's item, its label kept");
        M := TI.Parent (R.Item);
        Check (Labelled (M, "m") and then TI.Number_Of_Children (M) = 1, "under the path's items");

        Two := Tree.Add ("m/two");
        Three := Tree.Add ("m/three");
        TI.Set_Label (R3.Item, "new");
        Check (TI.Replace (Two, R3.Item) = R3.Item and then Tree.Find ("m/new") = R3.Item
                and then TI.Child (M, 2) = R3.Item and then TI.Next (R3.Item) = Three
                and then TI.Is_Null (Tree.Find ("m/two")),
            "Replace puts the item in the old one's place");

        R.Draws := 0;
        OK := Prb.Capture (Tree);
        X := TI.Label_X (R.Item);
        Y := TI.Label_Y (R.Item);
        W := TI.Label_W (R.Item);
        H := TI.Label_H (R.Item);
        Check (OK and then R.Draws > 0 and then W > 0 and then H > 0
                and then Prb.Pixel (X + W / 2, Y + H / 2) = Red_RGB,
            "Draw_Item_Content draws the item, in its label's place");
        Check (TI.Label_W (Three) > 0
                and then Prb.Pixel (TI.Label_X (Three) + TI.Label_W (Three) / 2, Middle (Three))
                    /= Red_RGB,
            "and FLTK's items as FLTK does");
        Prb.Release;
        Check (R.Draw_Foreground_Color = Tree.Get_Item_Label_Color
                and then R.Draw_Background_Color = Tree.Get_Background_Color,
            "Draw_Foreground_Color and Draw_Background_Color: the label's, and the tree's");

        Calls := 0;
        Click (R.Item);
        Check (Calls = 1 and then Last = R.Item and then TI.Is_Selected (R.Item),
            "a click calls back with the program's item");
        Check (R.Draw_Background_Color = Tree.Get_Selection_Color,
            "Draw_Background_Color, selected: the tree's selection color");
    end;

    --  Scrolling to an item, from pofltk's TestTree: 40 more rows than
    --  the tree shows.  A tree lays its items out as it draws.
    declare
        Top_Pos, Middle_Pos : Integer;
    begin
        for N in 0 .. 39 loop
            Ignore_Item := Tree.Add ("many/" & Integer'Image (N) (2 .. Integer'Image (N)'Last));
        end loop;
        I := Tree.Find ("many/20");
        Lay_Out;
        Check (not Tree.Is_Displayed (I) and then Tree.Get_V_Position = 0,
            "Is_Displayed of an item below the tree's area");
        Tree.Show_Item (I);
        Lay_Out;
        Top_Pos := Tree.Get_V_Position;
        Check (Tree.Is_Displayed (I) and then Top_Pos > 0, "Show_Item scrolls to it");
        Tree.Show_Item (I);
        Lay_Out;
        Check (Tree.Get_V_Position = Top_Pos, "but not when it is displayed already");
        Tree.Show_Item_Middle (I);
        Lay_Out;
        Middle_Pos := Tree.Get_V_Position;
        Check (Tree.Is_Displayed (I) and then Top_Pos > Middle_Pos,
            "Show_Item_Middle scrolls less far than Show_Item_Top");
        Tree.Show_Item_Bottom (I);
        Lay_Out;
        Check (Tree.Is_Displayed (I) and then Middle_Pos > Tree.Get_V_Position
                and then Tree.Get_V_Position > 0,
            "Show_Item_Bottom less far still");
        Tree.Show_Item_Top (I);
        Lay_Out;
        Check (Tree.Get_V_Position = Top_Pos, "Show_Item_Top");
        Tree.Show_Item (I, 10);
        Lay_Out;
        Check (Tree.Get_V_Position = Top_Pos - 10, "Show_Item with an offset");
        --  First is the hidden root, and showing it at the top doesn't
        --  scroll back to 0 (it scrolled to 5 under Xvfb), so compare it
        --  with Show_Item_Top (First).
        Tree.Show_Item_Top (TI.No_Tree_Item);
        Lay_Out;
        Middle_Pos := Tree.Get_V_Position;
        Tree.Show_Item_Bottom (I);
        Lay_Out;
        Tree.Show_Item_Top (Tree.First);
        Lay_Out;
        Check (Middle_Pos < Top_Pos and then Tree.Get_V_Position = Middle_Pos,
            "Show_Item_Top of no item means the first");
        Check (Tree.Is_Displayed (TI.No_Tree_Item) = Tree.Is_Displayed (Tree.First),
            "and Is_Displayed");
    end;

    --  Clear
    Tree.Clear;
    Check (TI.Is_Null (Tree.Root) and then TI.Is_Null (Tree.Callback_Item),
        "Clear removes every item, the root too");
    I := Tree.Add ("again");
    Check (Labelled (Tree.Root, "ROOT") and then Labelled (I, "again"),
        "Add after Clear makes a root again");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tree;


