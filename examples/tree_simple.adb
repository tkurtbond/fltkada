

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/tree-simple.cxx: a simple Tree, whose
--  callback reports the full pathname of each item selected.


with

    Ada.Text_IO,
    FLTK.Static,
    FLTK.Tree_Items,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows.Double;


function Tree_Simple
    return Integer
is


    package TIO renames Ada.Text_IO;
    package TI  renames FLTK.Tree_Items;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;


    --  Tree's callback
    --    Invoked whenever an item's state changes.
    procedure Tree_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Tree     : Trs.Tree renames Trs.Tree (Item);
        The_Item : constant TI.Tree_Item := Tree.Callback_Item;
    begin
        if TI.Is_Null (The_Item) then
            return;
        end if;
        case Tree.Callback_Reason is
        when Trs.Selected =>
            TIO.Put_Line
               (TIO.Standard_Error,
                "TreeCallback: Item selected='" & TI.Get_Label (The_Item) &
                "', Full pathname='" & Tree.Item_Pathname (The_Item) & "'");
        when Trs.Deselected =>
            --  TIO.Put_Line
            --     (TIO.Standard_Error,
            --      "TreeCallback: Item '" & TI.Get_Label (The_Item) & "' deselected");
            null;
        when Trs.Opened =>
            --  TIO.Put_Line
            --     (TIO.Standard_Error,
            --      "TreeCallback: Item '" & TI.Get_Label (The_Item) & "' opened");
            null;
        when Trs.Closed =>
            --  TIO.Put_Line
            --     (TIO.Standard_Error,
            --      "TreeCallback: Item '" & TI.Get_Label (The_Item) & "' closed");
            null;
        when Trs.Reselected =>
            --  To enable this callback, use Fl_Tree's item_reselect_mode
            --  (FL_TREE_SELECTABLE_ALWAYS), which isn't bound yet.
            --  TIO.Put_Line
            --     (TIO.Standard_Error,
            --      "TreeCallback: Item '" & TI.Get_Label (The_Item) & "' reselected");
            null;
        when others =>
            null;
        end case;
    end Tree_Callback;


    Ignore_Item : TI.Tree_Item;


begin


    FLTK.Static.Set_Scheme ("gtk+");

    declare
        Win : DW.Double_Window := DW.Forge.Create (250, 400, "Simple Tree");

        Win_W : constant Integer := Win.Get_W;
        Win_H : constant Integer := Win.Get_H;

        --  Create the tree
        Tree : Trs.Tree := Trs.Forge.Create (Win, 10, 10, Win_W - 20, Win_H - 20);
    begin
        Tree.Set_Show_Root (False);                          --  don't show root of tree
        Tree.Set_Callback (Tree_Callback'Unrestricted_Access);   --  setup a callback for the tree

        --  Add some items
        Ignore_Item := Tree.Add ("Flintstones/Fred");
        Ignore_Item := Tree.Add ("Flintstones/Wilma");
        Ignore_Item := Tree.Add ("Flintstones/Pebbles");
        Ignore_Item := Tree.Add ("Simpsons/Homer");
        Ignore_Item := Tree.Add ("Simpsons/Marge");
        Ignore_Item := Tree.Add ("Simpsons/Bart");
        Ignore_Item := Tree.Add ("Simpsons/Lisa");
        Ignore_Item := Tree.Add ("Pathnames/\/bin");                --  front slashes
        Ignore_Item := Tree.Add ("Pathnames/\/usr\/sbin");
        Ignore_Item := Tree.Add ("Pathnames/C:\\Program Files");    --  backslashes
        Ignore_Item := Tree.Add ("Pathnames/C:\\Documents and Settings");

        --  Start with some items closed
        Tree.Close (Tree.Find ("Simpsons"));
        Tree.Close (Tree.Find ("Pathnames"));

        Win.End_Current;
        Win.Set_Resizable (Win);
        Win.Show_With_Args;
        return FLTK.Run;
    end;


end Tree_Simple;
