

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/tree-custom-sort.cxx: a tree of 200 random
--  numbers, with buttons that bubble sort them forward or reverse.
--
--  Tree_Items' Child and Swap_Children count children from 1, not 0.  The
--  original passes the sort direction to one callback as user data; here
--  a generic is instantiated once per direction.


with

    Ada.Numerics.Float_Random,
    Ada.Strings.Fixed,
    FLTK.Static,
    FLTK.Tree_Items,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows.Double;


function Tree_Custom_Sort
    return Integer
is


    package FR  renames Ada.Numerics.Float_Random;
    package TI  renames FLTK.Tree_Items;
    package Btn renames FLTK.Widgets.Buttons;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;


    type Tree_Access is access Trs.Tree;

    G_Tree : Tree_Access;


    generic
        Dir : in Integer;   --  forward or reverse
    procedure My_Sort_Callback
           (Item : in out FLTK.Widgets.Widget'Class);

    procedure My_Sort_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        I : constant TI.Tree_Item := G_Tree.Root;
    begin
        --  Bubble sort
        for Ax in 1 .. TI.Number_Of_Children (I) loop
            for Bx in Ax + 1 .. TI.Number_Of_Children (I) loop
                declare
                    A : constant Long_Integer :=
                        Long_Integer'Value (TI.Get_Label (TI.Child (I, Ax)));
                    B : constant Long_Integer :=
                        Long_Integer'Value (TI.Get_Label (TI.Child (I, Bx)));
                begin
                    case Dir is
                    when 1 =>    --  fwd
                        if A > B then
                            TI.Swap_Children (I, Ax, Bx);
                        end if;
                    when -1 =>   --  rev
                        if A < B then
                            TI.Swap_Children (I, Ax, Bx);
                        end if;
                    when others =>
                        null;
                    end case;
                end;
            end loop;
        end loop;
        G_Tree.Redraw;
    end My_Sort_Callback;

    procedure Fwd_Callback is new My_Sort_Callback (1);
    procedure Rev_Callback is new My_Sort_Callback (-1);


    --  Randomize the random number generator
    Gen : FR.Generator;

    Ignore_Item : TI.Tree_Item;


begin


    FR.Reset (Gen);

    --  Create window with tree
    FLTK.Static.Set_Scheme ("gtk+");

    declare
        Win : DW.Double_Window := DW.Forge.Create (250, 600, "Numeric Sort Tree");

        Win_W : constant Integer := Win.Get_W;
        Win_H : constant Integer := Win.Get_H;
    begin
        G_Tree := new Trs.Tree'(Trs.Forge.Create (Win, 10, 10, Win_W - 20, Win_H - 60));
        G_Tree.Set_Show_Root (False);

        --  Add 200 random numbers to the tree
        for T in 1 .. 200 loop
            Ignore_Item := G_Tree.Add
               (Ada.Strings.Fixed.Trim
                   (Long_Integer'Image
                       (Long_Integer (Float'Truncation (FR.Random (Gen) * 1_000_000.0))),
                    Ada.Strings.Left));
        end loop;

        --  Add some sort buttons
        declare
            Fwd : Btn.Button := Btn.Forge.Create (Win, 10,      Win_H - 40, 80, 20, "Fwd");
            Rev : Btn.Button := Btn.Forge.Create (Win, 20 + 80, Win_H - 40, 80, 20, "Rev");
        begin
            Fwd.Set_Callback (Fwd_Callback'Unrestricted_Access);
            Rev.Set_Callback (Rev_Callback'Unrestricted_Access);

            Win.End_Current;
            Win.Set_Resizable (Win);
            Win.Show_With_Args;
            return FLTK.Run;
        end;
    end;


end Tree_Custom_Sort;
