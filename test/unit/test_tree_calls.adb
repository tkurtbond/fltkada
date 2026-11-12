--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  PLAN.md, Phase 25: the Fl_Tree calls FLTK's test/tree.fl makes that
--  FLTKAda lacked.  The docallback argument of open, close, open_toggle,
--  select, deselect, select_toggle, select_all and deselect_all; the
--  path forms of open, close, select and deselect; select_all and
--  deselect_all from an item; Fl_Tree_Item's open and close; add
--  (parent, name); item_reselect_mode; and load (prefs).


with

    Ada.Exceptions,
    Checks,
    FLTK.Environment,
    FLTK.Probe,
    FLTK.Tree_Items,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use

    Checks;

use type

    FLTK.Tree_Items.Reselect_Kind,
    FLTK.Tree_Items.Tree_Item,
    FLTK.Widgets.Groups.Trees.Reason_Kind;


procedure Test_Tree_Calls is

    package Env renames FLTK.Environment;
    package Prb renames FLTK.Probe;
    package TI  renames FLTK.Tree_Items;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Tree_Calls");
    Tree   : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 300, 300);

    Calls       : Natural := 0;
    Last_Reason : Trs.Reason_Kind := Trs.No_Reason;

    procedure Called
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Calls := Calls + 1;
        Last_Reason := Tree.Callback_Reason;
    end Called;

    --  How many calls Action makes.
    function Calls_From
           (Action : not null access procedure)
        return Natural is
    begin
        Calls := 0;
        Action.all;
        return Calls;
    end Calls_From;

    Root : TI.Tree_Item;

    procedure Close_Off is
    begin
        Tree.Close (Root, Do_Callback => False);
    end Close_Off;

    procedure Open_Off is
    begin
        Tree.Open (Root, Do_Callback => False);
    end Open_Off;

    procedure Toggle_Off is
    begin
        Tree.Open_Toggle (Root, Do_Callback => False);
    end Toggle_Off;

    procedure Select_Off is
    begin
        Tree.Select_Item (Root, Do_Callback => False);
    end Select_Off;

    procedure Deselect_Off is
    begin
        Tree.Deselect (Root, Do_Callback => False);
    end Deselect_Off;

    procedure Sel_Toggle_Off is
    begin
        Tree.Select_Toggle (Root, Do_Callback => False);
    end Sel_Toggle_Off;

    procedure Close_On is
    begin
        Tree.Close (Root, Do_Callback => True);
    end Close_On;

    procedure Open_Default is
    begin
        Tree.Open (Root);
    end Open_Default;

    procedure Select_Default is
    begin
        Tree.Select_Item (Root);
    end Select_Default;


    procedure Path_Close_Off is
    begin
        Tree.Close ("ROOT", Do_Callback => False);
    end Path_Close_Off;

    procedure Path_Open_Off is
    begin
        Tree.Open ("ROOT", Do_Callback => False);
    end Path_Open_Off;

    procedure Path_Close is
    begin
        Tree.Close ("ROOT");
    end Path_Close;

    procedure Path_Open is
    begin
        Tree.Open ("ROOT");
    end Path_Open;

    procedure Path_Select_Off is
    begin
        Tree.Select_Item ("ROOT", Do_Callback => False);
    end Path_Select_Off;

    procedure Path_Desel_Off is
    begin
        Tree.Deselect ("ROOT", Do_Callback => False);
    end Path_Desel_Off;

    procedure Path_Select is
    begin
        Tree.Select_Item ("ROOT");
    end Path_Select;

    procedure Path_Deselect is
    begin
        Tree.Deselect ("ROOT");
    end Path_Deselect;

    procedure Open_Missing is
    begin
        Tree.Open ("no/such");
    end Open_Missing;

    procedure Select_Missing is
    begin
        Tree.Select_Item ("no/such");
    end Select_Missing;


    Count : Natural;

    procedure All_Off is
    begin
        Count := Tree.Select_All (Do_Callback => False);
    end All_Off;

    function Selected
           (Path : in String)
        return Boolean is
    begin
        return TI.Is_Selected (Tree.Find (Path));
    end Selected;

    procedure Click
           (Item : in TI.Tree_Item)
    is
        Y : constant Integer := TI.Label_Y (Item) + TI.Label_H (Item) / 2;
        Ignore : Boolean;
    begin
        Ignore := Prb.Mouse (Window, FLTK.Push, TI.Label_X (Item) + 5, Y);
        Ignore := Prb.Mouse (Window, FLTK.Release, TI.Label_X (Item) + 5, Y);
    end Click;

    procedure Lay_Out is
        Ignore : Boolean;
    begin
        Ignore := Prb.Capture (Tree);
        Prb.Release;
    end Lay_Out;

    --  Every item's path, for a failure message.
    function All_Paths return String is
        Item : TI.Tree_Item := Tree.First;
        Result : String (1 .. 1000);
        Last : Natural := 0;
    begin
        while not TI.Is_Null (Item) loop
            declare
                Path : constant String := Tree.Item_Pathname (Item) & "|";
            begin
                exit when Last + Path'Length > Result'Last;
                Result (Last + 1 .. Last + Path'Length) := Path;
                Last := Last + Path'Length;
            end;
            Item := TI.Next (Item);
        end loop;
        return Result (1 .. Last);
    end All_Paths;

    A, B, Added : TI.Tree_Item;

begin

    Tree.Set_Callback (Called'Unrestricted_Access);
    Tree.Set_Root_Label ("ROOT");
    A := Tree.Add ("a/a1");
    A := Tree.Add ("a/a2");
    B := Tree.Add ("b/b1");
    A := Tree.Find ("a");
    B := Tree.Find ("b");
    Root := Tree.Root;
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    --  docallback, item forms.
    Check (Calls_From (Close_Off'Access) = 0 and not TI.Is_Open (Root),
        "Close with no callback closes and doesn't call back");
    Check (Calls_From (Open_Off'Access) = 0 and TI.Is_Open (Root), "Open likewise");
    Check (Calls_From (Toggle_Off'Access) = 0 and not TI.Is_Open (Root), "Open_Toggle likewise");
    Check (Calls_From (Open_Default'Access) = 1 and Last_Reason = Trs.Opened,
        "Open calls back by default");
    Check (Calls_From (Close_On'Access) = 1 and Last_Reason = Trs.Closed,
        "Close with Do_Callback True calls back");
    Open_Off;
    Check (Calls_From (Select_Off'Access) = 0 and TI.Is_Selected (Root),
        "Select_Item with no callback selects and doesn't call back");
    Check (Calls_From (Deselect_Off'Access) = 0 and not TI.Is_Selected (Root),
        "Deselect likewise");
    Check (Calls_From (Sel_Toggle_Off'Access) = 0 and TI.Is_Selected (Root),
        "Select_Toggle likewise");
    Deselect_Off;
    Check (Calls_From (Select_Default'Access) = 1 and Last_Reason = Trs.Selected,
        "Select_Item calls back by default");
    Deselect_Off;

    --  Path forms.
    Check (Calls_From (Path_Close_Off'Access) = 0 and not TI.Is_Open (Root),
        "Close by path, no callback");
    Check (Calls_From (Path_Open_Off'Access) = 0 and TI.Is_Open (Root),
        "Open by path, no callback");
    Check (Calls_From (Path_Close'Access) = 1 and not TI.Is_Open (Root),
        "Close by path calls back");
    Check (Calls_From (Path_Open'Access) = 1 and TI.Is_Open (Root), "Open by path calls back");
    Check (Calls_From (Path_Select_Off'Access) = 0 and TI.Is_Selected (Root),
        "Select_Item by path, no callback");
    Check (Calls_From (Path_Desel_Off'Access) = 0 and not TI.Is_Selected (Root),
        "Deselect by path, no callback");
    Check (Calls_From (Path_Select'Access) = 1 and TI.Is_Selected (Root),
        "Select_Item by path calls back");
    Check (Calls_From (Path_Deselect'Access) = 1 and not TI.Is_Selected (Root),
        "Deselect by path calls back");
    Raises (Open_Missing'Access, Constraint_Error'Identity, "Open of a missing path raises");
    Raises (Select_Missing'Access, Constraint_Error'Identity, "Select_Item of one raises");

    --  Select_All and Deselect_All, from an item and not.
    Count := Tree.Select_All (A);
    Check (Count = 3 and Selected ("a") and Selected ("a/a2") and not Selected ("b")
            and not TI.Is_Selected (Root),
        "Select_All from an item selects it and its descendants alone:" & Count'Image);
    Count := Tree.Deselect_All (A, Do_Callback => False);
    Check (Count = 3 and not Selected ("a/a1"), "Deselect_All from an item");
    Check (Calls_From (All_Off'Access) = 0 and Count = 6, "Select_All with no callback");
    Count := Tree.Deselect_All;
    Check (Count = 6, "Deselect_All of the whole tree");

    --  An item's own Open and Close, which never call back.
    Calls := 0;
    TI.Close (B);
    Check (not TI.Is_Open (B) and Calls = 0, "Tree_Items.Close");
    TI.Open (B);
    Check (TI.Is_Open (B) and Calls = 0, "Tree_Items.Open");

    --  Add under a parent.
    Added := Tree.Add (B, "b2");
    Check (TI.Parent (Added) = B and TI.Get_Label (Added) = "b2"
            and TI.Number_Of_Children (B) = 2,
        "Add (Parent, Name) appends a child");

    --  Reselecting.
    Check (Tree.Get_Item_Reselect_Mode = TI.Selectable_Once, "Selectable_Once by default");
    Lay_Out;
    Click (A);
    Click (A);
    Check (Last_Reason = Trs.Selected, "a second click on an item doesn't reselect it");
    Tree.Set_Item_Reselect_Mode (TI.Selectable_Always);
    Check (Tree.Get_Item_Reselect_Mode = TI.Selectable_Always, "Set_Item_Reselect_Mode");
    Click (A);
    Check (Last_Reason = Trs.Reselected, "with Selectable_Always it does");

    --  Load.  Fl_Tree::load puts each item at the group's own path, which
    --  for a memory group is its name and for a database's root is empty,
    --  as a C++ program doing the same shows.
    declare
        P : Env.Pref_Group := Env.Forge.In_Memory ("test_tree_calls");
    begin
        P.Set ("k", "v");
        declare
            G : Env.Pref_Group'Class := Env.Forge.By_Name (P, "g");
        begin
            G.Set ("n", 5);
        end;
        Tree.Clear;
        Tree.Load (P);
        Check (not TI.Is_Null (Tree.Find ("test_tree_calls/g/n = 5"))
                and not TI.Is_Null (Tree.Find ("test_tree_calls/k = v")),
            "Load adds a group's entries and its groups' as items: " & All_Paths);
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tree_Calls;
