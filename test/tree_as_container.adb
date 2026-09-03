

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


--  Ada port of FLTK's own examples/tree-as-container.cxx: most items
--  under "FLTK Widgets" hold a small composite widget (a Group of five
--  Inputs) in place of their label, rather than a Table as in
--  tree_of_tables.adb -- demonstrating that Tree_Items.Set_Widget takes
--  any FLTK.Widgets.Widget'Class, not just one bound widget type.
--
--  Uses FLTK.Widgets.Inputs.Text.Text_Input, not the plain
--  FLTK.Widgets.Inputs.Input -- Input wraps FLTK's abstract Fl_Input_
--  base class, which has no draw() of its own (only the concrete
--  Fl_Input subclass does), so a bare Input is invisible wherever it's
--  drawn, tree-embedded or not.
--
--  Each row's Group and Inputs must outlive the tree item they're
--  attached to (see FLTK.Tree_Items.Set_Widget), but the row count here
--  is only known at run time, and Ada arrays can't hold per-element
--  distinctly-constructed limited/controlled objects like Group/Input
--  directly. So each row is heap-allocated instead (via ordinary access
--  types, not Unchecked_Deallocation'd) -- every object a local access
--  type ever designates is finalized when that type's own scope ends,
--  i.e. when this function returns after the event loop exits, so nothing
--  leaks.
--
--  The original stress-tests scrolling performance with MAX_ROWS =
--  20000 (20000 Groups * 5 Inputs = 100000 widgets); reduced here to a
--  size that still demonstrates scrolling without a slow test run.


with

    Ada.Text_IO,
    FLTK.Tree_Items,
    FLTK.Widgets,
    FLTK.Widgets.Groups,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text;


function Tree_As_Container
    return Integer
is


    package TIO renames Ada.Text_IO;
    package TI  renames FLTK.Tree_Items;
    package Wdg renames FLTK.Widgets;
    package Grp renames FLTK.Widgets.Groups;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Inp renames FLTK.Widgets.Inputs.Text;

    Max_Rows     : constant := 200;
    Max_Fields   : constant := 5;
    Field_Width  : constant := 70;
    Field_Height : constant := 30;

    Colors : constant array (0 .. Max_Fields - 1) of FLTK.Color :=
       (16#ffffdd00#, 16#ffdddd00#, 16#ddffff00#, 16#ddffdd00#, 16#ddddff00#);

    type Group_Access is access Grp.Group;
    type Input_Access  is access Inp.Text_Input;
    type Field_Array   is array (0 .. Max_Fields - 1) of Input_Access;

    The_Window : Win.Window := Win.Forge.Create (450, 400, "Tree As FLTK Widget Container");

    The_Tree : Trs.Tree := Trs.Forge.Create (The_Window, 10, 10, 430, 380);

    Rows   : array (0 .. Max_Rows - 1) of Group_Access;
    Fields : array (0 .. Max_Rows - 1) of Field_Array;

    Ignore_Item : TI.Tree_Item;


    function Img
           (N : in Natural)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return S (2 .. S'Last);
    end Img;


begin


    The_Tree.Set_Show_Root (False);

    --  Regular text nodes, same as the original.
    Ignore_Item := The_Tree.Add ("Foo/Bar/001");
    Ignore_Item := The_Tree.Add ("Foo/Bar/002");
    Ignore_Item := The_Tree.Add ("Foo/Bla/Aaa");
    Ignore_Item := The_Tree.Add ("Foo/Bla/Bbb");

    --  "FLTK Widgets/<row>" items, each holding a Group of five Inputs.
    for T in 0 .. Max_Rows - 1 loop
        Rows (T) := new Grp.Group'
           (Grp.Forge.Create (The_Tree, 0, 0, Field_Width * Max_Fields, Field_Height));
        for C in 0 .. Max_Fields - 1 loop
            Fields (T) (C) := new Inp.Text_Input'
               (Inp.Forge.Create (Rows (T).all, C * Field_Width, 0, Field_Width, Field_Height));
            Fields (T) (C).Set_Background_Color (Colors (C));
            Fields (T) (C).Set_Value (Img (T) & "-" & Img (C));
        end loop;
        declare
            Item : constant TI.Tree_Item := The_Tree.Add ("FLTK Widgets/" & Img (T));
        begin
            TI.Set_Widget (Item, Rows (T).all);
        end;
    end loop;

    The_Window.Set_Resizable (The_Window);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Tree_As_Container;



