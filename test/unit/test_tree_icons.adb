


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 78: Fl_Tree_Item::usericon and userdeicon
--  keep the image's pointer, and never copy or delete it
--  (Fl_Tree_Item.H:420-450), and the item reads it to lay itself out and
--  draw (Fl_Tree_Item.cxx:828, 1016, 1099-1103).  An image that goes before
--  its item does is read from freed memory.  The binding also looked the
--  Ada image up by the item's address, which a later item can reuse.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.RGB,
    FLTK.Probe,
    FLTK.Tree_Items.Custom,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Tree_Icons is

    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package TI  renames FLTK.Tree_Items;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Tree_Icons");
    Tree   : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 300, 300);

    Small : constant Color_Component_Array (1 .. 8 * 8 * 3) := (others => 200);
    Large : constant Color_Component_Array (1 .. 30 * 30 * 3) := (others => 50);

    procedure Lay_Out is
        Ignore : Boolean;
    begin
        Ignore := Prb.Capture (Tree);
        Prb.Release;
    end Lay_Out;

    function Icon_W
           (Item : in TI.Tree_Item)
        return Integer is
    begin
        if TI.Get_User_Icon (Item) = null then
            return 0;
        else
            return TI.Get_User_Icon (Item).Get_W;
        end if;
    end Icon_W;

    function Deicon_W
           (Item : in TI.Tree_Item)
        return Integer is
    begin
        if TI.Get_User_Deicon (Item) = null then
            return 0;
        else
            return TI.Get_User_Deicon (Item).Get_W;
        end if;
    end Deicon_W;

    B : TI.Tree_Item := Tree.Add ("b");
    C : constant TI.Tree_Item := Tree.Add ("c");

begin

    Tree.Set_Show_Root (False);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Lay_Out;

    --  The images go before the tree draws them.
    declare
        Eight  : constant RGB.RGB_Image := RGB.Forge.Create (Small, 8, 8);
        Thirty : constant RGB.RGB_Image := RGB.Forge.Create (Large, 30, 30);
    begin
        TI.Set_User_Icon (B, Thirty);
        TI.Set_User_Deicon (B, Eight);
        TI.Set_User_Icon (C, Eight);
    end;
    Lay_Out;
    Check (Icon_W (B) = 30 and then Deicon_W (B) = 8 and then Icon_W (C) = 8,
        "icons whose images are gone:" & Integer'Image (Icon_W (B))
        & Integer'Image (Deicon_W (B)) & Integer'Image (Icon_W (C)));
    Check (TI.Label_H (B) >= 30,
        "an item is as tall as its icon:" & Integer'Image (TI.Label_H (B)));

    --  An icon replaced, and cleared.
    declare
        Twelve : constant RGB.RGB_Image := RGB.Forge.Create (Large, 12, 12);
    begin
        TI.Set_User_Icon (B, Twelve);
    end;
    Lay_Out;
    Check (Icon_W (B) = 12, "an icon replaced:" & Integer'Image (Icon_W (B)));
    TI.Clear_User_Icon (C);
    Lay_Out;
    Check (not TI.Has_User_Icon (C) and then Icon_W (C) = 0, "an icon cleared");

    --  An item removed with its icons, and one added after it.
    Tree.Remove (B);
    Lay_Out;
    B := Tree.Add ("b2");
    Lay_Out;
    Check (Icon_W (B) = 0 and then Deicon_W (B) = 0,
        "an item added after one removed has no icons");

    --  A custom item's icon, set before the tree takes the item, is kept
    --  while another icon is set.
    declare
        Custom : constant FLTK.Tree_Items.Custom.Custom_Item :=
            FLTK.Tree_Items.Custom.Forge.Create (Tree);
        Ten    : constant RGB.RGB_Image := RGB.Forge.Create (Large, 10, 10);
        Added  : TI.Tree_Item;
    begin
        TI.Set_User_Icon (Custom.Item, Ten);
        TI.Set_User_Icon (C, Ten);
        Added := Tree.Add ("custom", Custom.Item);
        Lay_Out;
        Check (Icon_W (Added) = 10,
            "a custom item's icon set before a tree took it:" & Integer'Image (Icon_W (Added)));
    end;

    --  A tree that goes with its items' icons.
    declare
        Other  : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 100, 100);
        Twelve : constant RGB.RGB_Image := RGB.Forge.Create (Large, 12, 12);
    begin
        TI.Set_User_Icon (Other.Add ("x"), Twelve);
    end;
    Lay_Out;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tree_Icons;


