

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/tree-as-container.cxx: a Tree whose items
--  under "FLTK Widgets" each hold a small composite widget, a Group of
--  five Inputs, in place of their label.  It stress-tests scrolling with
--  20000 rows (100000 Inputs).
--
--  Uses Text_Input, since FLTK.Widgets.Inputs.Input binds the abstract
--  Fl_Input_ base class.  Each row is allocated through a local access
--  type, so every row is finalized when the function returns.


with

    Ada.Strings.Fixed,
    FLTK.Tree_Items,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;


function Tree_As_Container
    return Integer
is


    package TI  renames FLTK.Tree_Items;
    package Grp renames FLTK.Widgets.Groups;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;


    Max_Rows     : constant := 20000;
    Max_Fields   : constant := 5;
    Field_Width  : constant := 70;
    Field_Height : constant := 30;


    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Left);
    end Image;


    type Input_Access is access Inp.Text_Input;

    type Field_Array is array (0 .. Max_Fields - 1) of Input_Access;

    type My_Data is new Grp.Group with record
        Fields : Field_Array;
    end record;


    function Create
           (X, Y, W, H : in Integer)
        return My_Data
    is
        Colors : constant array (0 .. Max_Fields - 1) of FLTK.Color :=
           (16#ffffdd00#, 16#ffdddd00#, 16#ddffff00#, 16#ddffdd00#, 16#ddddff00#);
    begin
        return This : My_Data := (Grp.Forge.Create (X, Y, W, H) with others => <>) do
            for T in This.Fields'Range loop
                This.Fields (T) := new Inp.Text_Input'
                   (Inp.Forge.Create (This, X + T * Field_Width, Y, Field_Width, H));
                This.Fields (T).Set_Background_Color (Colors (T));
            end loop;
        end return;
    end Create;


    procedure Set_Data
           (This : in out My_Data;
            Col  : in     Integer;
            Val  : in     String) is
    begin
        if Col in This.Fields'Range then
            This.Fields (Col).Set_Value (Val);
        end if;
    end Set_Data;


    type My_Data_Access is access My_Data;

    Ignore_Item : TI.Tree_Item;


begin


    declare
        Win : DW.Double_Window :=
            DW.Forge.Create (450, 400, "Tree As FLTK Widget Container");

        Win_W : constant Integer := Win.Get_W;
        Win_H : constant Integer := Win.Get_H;

        --  Create the tree
        Tree : Trs.Tree := Trs.Forge.Create (Win, 10, 10, Win_W - 20, Win_H - 20);
    begin
        Tree.Set_Show_Root (False);   --  don't show root of tree

        --  Add some regular text nodes
        Ignore_Item := Tree.Add ("Foo/Bar/001");
        Ignore_Item := Tree.Add ("Foo/Bar/002");
        Ignore_Item := Tree.Add ("Foo/Bla/Aaa");
        Ignore_Item := Tree.Add ("Foo/Bla/Bbb");

        --  Add items to the 'Data' node
        for T in 0 .. Max_Rows - 1 loop
            declare
                --  Add item to tree
                Item : constant TI.Tree_Item := Tree.Add ("FLTK Widgets/" & Image (T));
                Data : My_Data_Access;
            begin
                --  Reconfigure item to be an FLTK widget (My_Data)
                Tree.Begin_Current;
                Data := new My_Data'(Create (0, 0, Field_Width * Max_Fields, Field_Height));
                TI.Set_Widget (Item, Data.all);
                --  Initialize widget data
                for C in 0 .. Max_Fields - 1 loop
                    Set_Data (Data.all, C, Image (T) & "-" & Image (C));
                end loop;
                Tree.End_Current;
            end;
        end loop;

        Win.End_Current;
        Win.Set_Resizable (Win);
        Win.Show_With_Args;
        return FLTK.Run;
    end;


end Tree_As_Container;
