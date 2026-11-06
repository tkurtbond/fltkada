


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 105:  a tree's margins and connector width, and an
--  item's activation, bound for pofltk's TreeIcons.  Each margin is
--  checked by where FLTK then draws an item's label, which Fl_Tree_Item
--  works out as it draws (Fl_Tree_Item.cxx); the bottom margin, which only
--  changes how far the tree scrolls, by reading it back.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.RGB,
    FLTK.Tree_Items,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Tree_Margins is

    package RGB renames FLTK.Images.RGB;
    package TI  renames FLTK.Tree_Items;
    package Btn renames FLTK.Widgets.Buttons;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Tree_Margins");
    Tree   : Trs.Tree := Trs.Forge.Create (Window, 10, 10, 280, 280);

    A  : constant TI.Tree_Item := Tree.Add ("A");
    A1 : constant TI.Tree_Item := Tree.Add ("A/a1");
    B  : constant TI.Tree_Item := Tree.Add ("B");
    C  : constant TI.Tree_Item := Tree.Add ("C");

    Push : Btn.Button := Btn.Forge.Create (0, 0, 60, 20, "push");

    Icon : constant RGB.RGB_Image :=
        RGB.Forge.Create ((1 .. 12 * 12 * 3 => 128), 12, 12);

    Ignore      : Boolean;
    Ignore_Time : Long_Float;

    --  Redraws the tree, and waits until FLTK has drawn it.
    procedure Drawn is
    begin
        Tree.Redraw;
        for Tries in 1 .. 100 loop
            exit when not Window.Is_Damaged;
            Ignore_Time := FLTK.Wait (0.02);
        end loop;
        Check (not Window.Is_Damaged, "the tree is drawn");
    end Drawn;

    X, Y : Integer;

begin

    Tree.Set_User_Icon (Icon);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Drawn;

    --  FLTK's own values (Fl_Tree_Prefs.cxx:96-116).
    Check (Tree.Get_Margin_Top = 3, "margin top is 3:" & Integer'Image (Tree.Get_Margin_Top));
    Check (Tree.Get_Margin_Bottom = 20,
        "margin bottom is 20:" & Integer'Image (Tree.Get_Margin_Bottom));
    Check (Tree.Get_Open_Child_Margin_Bottom = 0,
        "open child margin bottom is 0:" & Integer'Image (Tree.Get_Open_Child_Margin_Bottom));
    Check (Tree.Get_User_Icon_Margin_Left = 3,
        "user icon margin left is 3:" & Integer'Image (Tree.Get_User_Icon_Margin_Left));
    Check (Tree.Get_Label_Margin_Left = 3,
        "label margin left is 3:" & Integer'Image (Tree.Get_Label_Margin_Left));
    Check (Tree.Get_Connector_Width = 17,
        "connector width is 17:" & Integer'Image (Tree.Get_Connector_Width));

    X := TI.Label_X (A1);
    Tree.Set_Label_Margin_Left (13);
    Drawn;
    Check (Tree.Get_Label_Margin_Left = 13, "label margin left set");
    Check (TI.Label_X (A1) = X + 10,
        "a label moves right with its margin:" & Integer'Image (TI.Label_X (A1) - X));

    X := TI.Label_X (A1);
    Tree.Set_User_Icon_Margin_Left (8);
    Drawn;
    Check (Tree.Get_User_Icon_Margin_Left = 8, "user icon margin left set");
    Check (TI.Label_X (A1) = X + 5,
        "a label moves right with its icon's margin:" & Integer'Image (TI.Label_X (A1) - X));

    X := TI.Label_X (A1);
    Tree.Set_Connector_Width (27);
    Drawn;
    Check (Tree.Get_Connector_Width = 27, "connector width set");
    Check (TI.Label_X (A1) > X,
        "a child moves right with the connector width:" & Integer'Image (TI.Label_X (A1) - X));

    Y := TI.Label_Y (A);
    Tree.Set_Margin_Top (10);
    Drawn;
    Check (Tree.Get_Margin_Top = 10, "margin top set");
    Check (TI.Label_Y (A) = Y + 7, "the items move down with the top margin:"
        & Integer'Image (TI.Label_Y (A) - Y));

    Y := TI.Label_Y (B);
    X := TI.Label_Y (C);
    Tree.Set_Open_Child_Margin_Bottom (6);
    Drawn;
    Check (Tree.Get_Open_Child_Margin_Bottom = 6, "open child margin bottom set");
    Check (TI.Label_Y (B) = Y + 6, "the item after an open item's children moves down:"
        & Integer'Image (TI.Label_Y (B) - Y));
    Check (TI.Label_Y (C) = X + 6,
        "and only by the one margin:" & Integer'Image (TI.Label_Y (C) - X));

    Tree.Set_Margin_Bottom (40);
    Check (Tree.Get_Margin_Bottom = 40, "margin bottom set");

    --  Activation, with the item's widget.
    TI.Set_Widget (B, Push);
    Check (TI.Is_Active (B) and then Push.Is_Active, "an item starts active");
    TI.Deactivate (B);
    Check (not TI.Is_Active (B), "Deactivate makes an item inactive");
    Check (not Push.Is_Active, "and its widget");
    Check (TI.Is_Active (A), "and no other item");
    TI.Activate (B);
    Check (TI.Is_Active (B) and then Push.Is_Active, "Activate makes them active again");
    Drawn;

    Window.Hide;
    Ignore := FLTK.Check;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tree_Margins;


