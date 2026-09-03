

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


--  Ada port of FLTK's own examples/tree-custom-sort.cxx: 200 random
--  numbers as top-level tree items, bubble-sorted forward or reverse by
--  a pair of buttons.
--
--  The original swaps by child *index*
--  (Fl_Tree_Item::swap_children(int,int)); only the item-pair overload
--  (Tree_Items.Swap_Children) is bound, so this swaps Child(Root, Ax)
--  and Child(Root, Bx) instead -- same effect, different call shape.


with

    Ada.Numerics.Discrete_Random,
    Ada.Text_IO,
    FLTK.Tree_Items,
    FLTK.Widgets,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;


function Tree_Custom_Sort
    return Integer
is


    package TIO renames Ada.Text_IO;
    package TI  renames FLTK.Tree_Items;
    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;

    subtype Random_Range is Integer range 0 .. 999_999;
    package Random_Numbers is new Ada.Numerics.Discrete_Random (Random_Range);

    Gen : Random_Numbers.Generator;

    The_Window : Win.Window := Win.Forge.Create (250, 600, "Numeric Sort Tree");

    The_Tree : Trs.Tree := Trs.Forge.Create (The_Window, 10, 10, 230, 540);

    Fwd_Button : Btn.Button :=
        Btn.Forge.Create (The_Window, 10,      560, 80, 20, "Fwd");

    Rev_Button : Btn.Button :=
        Btn.Forge.Create (The_Window, 20 + 80, 560, 80, 20, "Rev");

    Ignore_Item : TI.Tree_Item;


    function Img
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        if N < 0 then
            return S;
        else
            return S (2 .. S'Last);
        end if;
    end Img;


    --  Bubble sort, matching the original's algorithm exactly.
    procedure Resort
           (Dir : in Integer)
    is
        Root_Item : constant TI.Tree_Item := The_Tree.Root;
        N         : constant Natural      := TI.Number_Of_Children (Root_Item);
    begin
        for Ax in 1 .. N loop
            for Bx in Ax + 1 .. N loop
                declare
                    A : constant Integer := Integer'Value (TI.Get_Label (TI.Child (Root_Item, Ax)));
                    B : constant Integer := Integer'Value (TI.Get_Label (TI.Child (Root_Item, Bx)));
                    Swap : constant Boolean :=
                       (if Dir = 1 then A > B else A < B);
                begin
                    if Swap
                        and then not TI.Swap_Children
                           (Root_Item, TI.Child (Root_Item, Ax), TI.Child (Root_Item, Bx))
                    then
                        TIO.Put_Line ("Swap_Children failed unexpectedly");
                    end if;
                end;
            end loop;
        end loop;
        The_Tree.Redraw;
    end Resort;


    procedure Sort_Forward
           (Ignore : in out Wdg.Widget'Class)
    is
    begin
        Resort (1);
    end Sort_Forward;


    procedure Sort_Reverse
           (Ignore : in out Wdg.Widget'Class)
    is
    begin
        Resort (-1);
    end Sort_Reverse;


begin


    The_Tree.Set_Show_Root (False);

    Random_Numbers.Reset (Gen);
    for T in 1 .. 200 loop
        Ignore_Item := The_Tree.Add (Img (Random_Numbers.Random (Gen)));
    end loop;

    Fwd_Button.Set_Callback (Sort_Forward'Unrestricted_Access);
    Rev_Button.Set_Callback (Sort_Reverse'Unrestricted_Access);

    The_Window.Set_Resizable (The_Window);

    The_Window.Show_With_Args;

    return FLTK.Run;


end Tree_Custom_Sort;



