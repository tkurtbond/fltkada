

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


--  Exercises the FLTK.Widgets.Groups.Trees / FLTK.Tree_Items binding:
--  building a tree from slash-separated paths (with parent items created
--  automatically), walking it depth-first, opening every branch, multi-
--  selecting items, and reading back the current selection.


with

    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.Tree_Items,
    FLTK.Widgets,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;


function Tree_Binding
    return Integer
is


    package SF  renames Ada.Strings.Fixed;
    package TIO renames Ada.Text_IO;
    package TI  renames FLTK.Tree_Items;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;


    The_Window : Win.Window := Win.Forge.Create (320, 430, "Tree Test");

    The_Tree : Trs.Tree := Trs.Forge.Create (The_Window, 10, 10, 300, 330);

    Status : Bx.Box := Bx.Forge.Create (The_Window, 10, 350, 300, 25);

    Print_Button : Btn.Button :=
        Btn.Forge.Create (The_Window, 10, 385, 145, 30, "Print Tree");

    Select_Button : Btn.Button :=
        Btn.Forge.Create (The_Window, 165, 385, 145, 30, "Select All");


    procedure Print_Whole_Tree
           (Ignore : in out Wdg.Widget'Class)
    is
        Item : TI.Tree_Item := The_Tree.First;
    begin
        TIO.Put_Line ("--  Tree contents  --");
        while not TI.Is_Null (Item) loop
            TIO.Put_Line
               (SF."*" (TI.Depth (Item) * 4, ' ') & TI.Get_Label (Item));
            Item := TI.Next (Item);
        end loop;
    end Print_Whole_Tree;


    procedure Select_Everything
           (Ignore : in out Wdg.Widget'Class)
    is
        Changed : constant Natural := The_Tree.Select_All;
    begin
        TIO.Put_Line (Integer'Image (Changed) & " item(s) newly selected");
    end Select_Everything;


    procedure Show_Selection
           (Ignore : in out Wdg.Widget'Class)
    is
        Chosen : constant TI.Tree_Item_Array := The_Tree.Selected_Items;
        Count_Image : constant String := Integer'Image (Chosen'Length);
    begin
        Status.Set_Label (Count_Image (2 .. Count_Image'Last) & " item(s) selected");
        TIO.Put ("Selected:");
        for Item of Chosen loop
            TIO.Put (' ' & TI.Get_Label (Item));
        end loop;
        TIO.New_Line;
    end Show_Selection;


    Ignore_Item : TI.Tree_Item;


    procedure Open_All
    is
        Item : TI.Tree_Item := The_Tree.First;
    begin
        while not TI.Is_Null (Item) loop
            if TI.Has_Children (Item) then
                The_Tree.Open (Item);
            end if;
            Item := TI.Next (Item);
        end loop;
    end Open_All;


begin


    Ignore_Item := The_Tree.Add ("Flintstones/Fred");
    Ignore_Item := The_Tree.Add ("Flintstones/Wilma");
    Ignore_Item := The_Tree.Add ("Flintstones/Pebbles");
    Ignore_Item := The_Tree.Add ("Simpsons/Homer");
    Ignore_Item := The_Tree.Add ("Simpsons/Marge");
    Ignore_Item := The_Tree.Add ("Simpsons/Bart");
    Ignore_Item := The_Tree.Add ("Simpsons/Lisa");

    The_Tree.Set_Select_Mode (TI.Multi_Selection);
    The_Tree.Set_When (FLTK.When_Changed);
    The_Tree.Set_Callback (Show_Selection'Unrestricted_Access);

    Open_All;

    Status.Set_Box (FLTK.Down_Box);
    Status.Set_Label ("0 item(s) selected");

    Print_Button.Set_Callback (Print_Whole_Tree'Unrestricted_Access);
    Select_Button.Set_Callback (Select_Everything'Unrestricted_Access);

    Print_Whole_Tree (The_Tree);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Tree_Binding;


