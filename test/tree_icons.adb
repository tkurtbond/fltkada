


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A tree's icons and margins, after pofltk's examples/TreeIcons.Mod.
--
--  The tree has icons of its own, for an open item, a closed one and
--  every item, and one item has icons for itself, active and inactive.
--  The sliders set the gaps around them.  The check buttons go back to
--  FLTK's own icons, and make the item inactive.


with

    FLTK.Images.RGB,
    FLTK.Tree_Items,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


function Tree_Icons
    return Integer
is


    package RGB renames FLTK.Images.RGB;
    package TI  renames FLTK.Tree_Items;
    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    use type FLTK.Color_Component;
    use type FLTK.Size_Type;


    Size : constant := 12;

    --  A square of one colour, with a darker border; or, if Diamond, only
    --  the diamond inside it, on the tree's own background.
    function Icon
           (R, G, B : in FLTK.Color_Component;
            Diamond : in Boolean := False)
        return RGB.RGB_Image
    is
        Bits : FLTK.Color_Component_Array (1 .. 4 * Size * Size);
        N    : FLTK.Size_Type := 1;
    begin
        for Y in 0 .. Size - 1 loop
            for X in 0 .. Size - 1 loop
                if Diamond and then abs (2 * X + 1 - Size) + abs (2 * Y + 1 - Size) > Size then
                    Bits (N .. N + 3) := (0, 0, 0, 0);
                elsif X = 0 or Y = 0 or X = Size - 1 or Y = Size - 1 then
                    Bits (N .. N + 3) := (R / 2, G / 2, B / 2, 255);
                else
                    Bits (N .. N + 3) := (R, G, B, 255);
                end if;
                N := N + 4;
            end loop;
        end loop;
        return RGB.Forge.Create (Bits, Size, Size, Depth => 4);
    end Icon;


    Window : Win.Window := Win.Forge.Create (470, 340, "TreeIcons");
    Tree   : Trs.Tree := Trs.Forge.Create (Window, 10, 10, 260, 320);

    Open_Icon  : constant RGB.RGB_Image := Icon (70, 170, 70);
    Close_Icon : constant RGB.RGB_Image := Icon (190, 70, 70);
    User_Icon  : constant RGB.RGB_Image := Icon (90, 120, 200);
    Star_Icon  : constant RGB.RGB_Image := Icon (240, 190, 40, Diamond => True);
    Star_Gray  : constant RGB.RGB_Image := Icon (170, 170, 170, Diamond => True);

    Special : TI.Tree_Item;


    --  A slider from 0 to 30, labelled above, starting at Value.
    function Slider
           (Y     : in Integer;
            Value : in Integer;
            Text  : in String)
        return HVS.Horizontal_Value_Slider is
    begin
        return This : HVS.Horizontal_Value_Slider :=
            HVS.Forge.Create (Window, 290, Y, 160, 20, Text)
        do
            This.Set_Alignment (FLTK.Align_Top);
            This.Set_Bounds (0.0, 30.0);
            This.Set_Step (1);
            This.Set_Value (Long_Float (Value));
        end return;
    end Slider;


    Bottom       : HVS.Horizontal_Value_Slider :=
        Slider (30, Tree.Get_Margin_Bottom, "Margin below the tree");
    Child_Bottom : HVS.Horizontal_Value_Slider :=
        Slider (80, Tree.Get_Open_Child_Margin_Bottom, "Margin below open children");
    Icon_Left    : HVS.Horizontal_Value_Slider :=
        Slider (130, Tree.Get_User_Icon_Margin_Left, "Margin left of the user icon");
    Label_Left   : HVS.Horizontal_Value_Slider :=
        Slider (180, Tree.Get_Label_Margin_Left, "Margin left of the label");

    Custom : Chk.Check_Button :=
        Chk.Forge.Create (Window, 290, 220, 160, 25, "The tree's own icons");
    Active : Chk.Check_Button :=
        Chk.Forge.Create (Window, 290, 250, 160, 25, "Item is active");


    procedure Margins
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Tree.Set_Margin_Bottom (Integer (Bottom.Get_Value));
        Tree.Set_Open_Child_Margin_Bottom (Integer (Child_Bottom.Get_Value));
        Tree.Set_User_Icon_Margin_Left (Integer (Icon_Left.Get_Value));
        Tree.Set_Label_Margin_Left (Integer (Label_Left.Get_Value));
        Tree.Redraw;
    end Margins;


    procedure Active_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        if Active.Is_On then
            TI.Activate (Special);
        else
            TI.Deactivate (Special);
        end if;
        Tree.Redraw;
    end Active_CB;


    --  The tree's icons, or FLTK's own; a tree's user icon shows on every
    --  item with none of its own.
    procedure Custom_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        if Custom.Is_On then
            Tree.Set_Open_Icon (Open_Icon);
            Tree.Set_Close_Icon (Close_Icon);
            Tree.Set_User_Icon (User_Icon);
        else
            Tree.Clear_Open_Icon;
            Tree.Clear_Close_Icon;
            Tree.Clear_User_Icon;
        end if;
        Tree.Redraw;
    end Custom_CB;


    Ignore : TI.Tree_Item;


begin


    Ignore  := Tree.Add ("Fruit/Apple");
    Ignore  := Tree.Add ("Fruit/Pear");
    Special := Tree.Add ("Fruit/This item has its own icon");
    Ignore  := Tree.Add ("Fruit/Plum");
    Ignore  := Tree.Add ("Vegetables/Beet");
    Ignore  := Tree.Add ("Vegetables/Leek/Giant");
    Ignore  := Tree.Add ("Vegetables/Leek/Musselburgh");
    Ignore  := Tree.Add ("Nuts/Almond");

    TI.Set_User_Icon (Special, Star_Icon);
    TI.Set_User_Deicon (Special, Star_Gray);

    Bottom.Set_Callback (Margins'Unrestricted_Access);
    Child_Bottom.Set_Callback (Margins'Unrestricted_Access);
    Icon_Left.Set_Callback (Margins'Unrestricted_Access);
    Label_Left.Set_Callback (Margins'Unrestricted_Access);

    Custom.Set_State (Btn.On);
    Custom.Set_Callback (Custom_CB'Unrestricted_Access);
    Active.Set_State (Btn.On);
    Active.Set_Callback (Active_CB'Unrestricted_Access);

    Custom_CB (Custom);
    Window.Show_With_Args;

    return FLTK.Run;


end Tree_Icons;


