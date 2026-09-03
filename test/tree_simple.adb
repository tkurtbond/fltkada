

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


--  Ada port of FLTK's own examples/tree-simple.cxx: a plain two-family
--  tree plus a "Pathnames" branch demonstrating that Add still delegates
--  straight to Fl_Tree::add(), so backslash-escaped path components
--  (a literal '/' or '\' inside a label, rather than a path separator)
--  work exactly as in the C++ original.
--
--  FLTK.Widgets.Groups.Trees does not bind Fl_Tree::callback_item() or
--  callback_reason() (see doc/fl_tree.html), so unlike the original's
--  callback -- which reports only the one item whose state just changed
--  -- this reports the tree's whole current selection instead, the same
--  substitution test/tree.adb already uses.


with

    Ada.Text_IO,
    FLTK.Tree_Items,
    FLTK.Widgets,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;


function Tree_Simple
    return Integer
is


    package TIO renames Ada.Text_IO;
    package TI  renames FLTK.Tree_Items;
    package Wdg renames FLTK.Widgets;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;


    The_Window : Win.Window := Win.Forge.Create (250, 400, "Simple Tree");

    The_Tree : Trs.Tree := Trs.Forge.Create (The_Window, 10, 10, 230, 380);

    Ignore_Item : TI.Tree_Item;


    --  Reconstructs an item's full slash-separated pathname by walking
    --  up to (but not including) the tree's hidden root -- a stand-in
    --  for the unbound Fl_Tree::item_pathname().
    function Full_Path
           (Item : in TI.Tree_Item)
        return String
    is
    begin
        if TI.Is_Null (Item) or else TI.Is_Root (Item) then
            return "";
        end if;
        declare
            Above : constant String := Full_Path (TI.Parent (Item));
        begin
            if Above'Length = 0 then
                return TI.Get_Label (Item);
            else
                return Above & "/" & TI.Get_Label (Item);
            end if;
        end;
    end Full_Path;


    procedure Report_Selection
           (Ignore : in out Wdg.Widget'Class)
    is
        Chosen : constant TI.Tree_Item_Array := The_Tree.Selected_Items;
    begin
        for Item of Chosen loop
            TIO.Put_Line
               (TIO.Standard_Error,
                "TreeCallback: Item selected='" & TI.Get_Label (Item)
                & "', Full pathname='" & Full_Path (Item) & "'");
        end loop;
    end Report_Selection;


begin


    The_Tree.Set_Show_Root (False);
    The_Tree.Set_When (FLTK.When_Changed);
    The_Tree.Set_Callback (Report_Selection'Unrestricted_Access);

    Ignore_Item := The_Tree.Add ("Flintstones/Fred");
    Ignore_Item := The_Tree.Add ("Flintstones/Wilma");
    Ignore_Item := The_Tree.Add ("Flintstones/Pebbles");
    Ignore_Item := The_Tree.Add ("Simpsons/Homer");
    Ignore_Item := The_Tree.Add ("Simpsons/Marge");
    Ignore_Item := The_Tree.Add ("Simpsons/Bart");
    Ignore_Item := The_Tree.Add ("Simpsons/Lisa");
    Ignore_Item := The_Tree.Add ("Pathnames/\/bin");              --  front slashes
    Ignore_Item := The_Tree.Add ("Pathnames/\/usr\/sbin");
    Ignore_Item := The_Tree.Add ("Pathnames/C:\\Program Files");  --  backslashes
    Ignore_Item := The_Tree.Add ("Pathnames/C:\\Documents and Settings");

    The_Tree.Close (The_Tree.Find ("Simpsons"));
    The_Tree.Close (The_Tree.Find ("Pathnames"));

    The_Window.Set_Resizable (The_Window);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Tree_Simple;



