


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Phase 12's tree methods: item label colours, the tree's scroll
--  positions and scrollbar size, and its own open, close and user icons.
--  Fl_Tree keeps the icons' pointers (pofltk 78), and makes and deletes an
--  inactive copy of each (Fl_Tree_Prefs.cxx:63-90), which for a shared
--  image would be the pool's own entry (pofltk 84).


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.RGB,
    FLTK.Images.Shared,
    FLTK.Probe,
    FLTK.Tree_Items,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Tree_Methods is

    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package Shr renames FLTK.Images.Shared;
    package TI  renames FLTK.Tree_Items;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Bxs renames FLTK.Widgets.Boxes;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 300, "Test_Tree_Methods");

    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Green : constant Prb.RGB := Prb.To_RGB (0, 255, 0);
    Blue  : constant Prb.RGB := Prb.To_RGB (0, 0, 255);

    --  Pixels of one colour, Side by Side.
    function Square
           (R, G, B : in Color_Component;
            Side    : in Positive)
        return Color_Component_Array
    is
        Result : Color_Component_Array (1 .. Size_Type (Side * Side * 3));
    begin
        for N in 0 .. Size_Type (Side * Side - 1) loop
            Result (N * 3 + 1) := R;
            Result (N * 3 + 2) := G;
            Result (N * 3 + 3) := B;
        end loop;
        return Result;
    end Square;

    --  How many pixels of Item, as drawn now, are Hue, in the rectangle
    --  X, Y, W, H from its top left, or all of it.
    function Count
           (Item       : in FLTK.Widgets.Widget'Class;
            Hue        : in Prb.RGB;
            X, Y, W, H : in Integer := -1)
        return Natural
    is
        Result : Natural := 0;
        Left   : constant Integer := (if X < 0 then 0 else X);
        Top    : constant Integer := (if Y < 0 then 0 else Y);
        Width  : constant Integer := (if W < 0 then Item.Get_W else W);
        Height : constant Integer := (if H < 0 then Item.Get_H else H);
    begin
        if Prb.Capture (Item) then
            for J in Top .. Top + Height - 1 loop
                for I in Left .. Left + Width - 1 loop
                    if Prb.Pixel (I, J) = Hue then
                        Result := Result + 1;
                    end if;
                end loop;
            end loop;
        end if;
        Prb.Release;
        return Result;
    end Count;

    function Width_Of
           (Icon : access FLTK.Images.Image'Class)
        return Integer is
    begin
        return (if Icon = null then 0 else Icon.Get_W);
    end Width_Of;

    procedure Colours is
        Tree : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 200, 100);
        A, B : TI.Tree_Item;
    begin
        Tree.Set_Show_Root (False);
        Check (Tree.Get_Item_Label_BG_Color = TI.Transparent_Background,
            "a tree's new items have no label background by default");
        A := Tree.Add ("a");
        Check (TI.Get_Label_FG_Color (A) = Tree.Get_Item_Label_Color
                and TI.Get_Label_BG_Color (A) = TI.Transparent_Background,
            "a new item takes the tree's label colours");
        Tree.Set_Item_Label_Color (Red_Color);
        Tree.Set_Item_Label_BG_Color (Yellow_Color);
        Check (Tree.Get_Item_Label_BG_Color = Yellow_Color,
            "Set_Item_Label_BG_Color, Get_Item_Label_BG_Color");
        B := Tree.Add ("b");
        Check (TI.Get_Label_FG_Color (B) = Red_Color
                and TI.Get_Label_BG_Color (B) = Yellow_Color,
            "an item added later takes the tree's new label colours");
        Check (TI.Get_Label_BG_Color (A) = TI.Transparent_Background,
            "an item added earlier keeps its own");
        TI.Set_Label_FG_Color (A, Green_Color);
        TI.Set_Label_BG_Color (A, Blue_Color);
        Check (Count (Tree, Blue) > 0, "the tree is drawn with the new colours");
        Check (TI.Get_Label_FG_Color (A) = Green_Color
                and TI.Get_Label_BG_Color (A) = Blue_Color,
            "Set_Label_FG_Color, Set_Label_BG_Color");
        declare
            Blues : constant Natural := Count
               (Tree, Blue, TI.Label_X (A), TI.Label_Y (A), TI.Label_W (A), TI.Label_H (A));
        begin
            Check (Blues > TI.Label_W (A) * TI.Label_H (A) / 2,
                "an item's label is drawn on its background colour:" & Natural'Image (Blues));
        end;
        TI.Set_Label_BG_Color (A, TI.Transparent_Background);
        Check (Count (Tree, Blue) = 0,
            "Transparent_Background draws the label on the tree's background");
    end Colours;

    procedure Scrolling is
        Tree : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 100, 60);
        Most : Integer;
        Item : TI.Tree_Item;
        pragma Unreferenced (Item);
    begin
        for N in 1 .. 30 loop
            Item := Tree.Add ("item" & Integer'Image (N) & " with a label longer than the tree");
        end loop;
        Tree.Set_V_Position (40);
        Check (Tree.Get_V_Position in 0 .. 1,
            "before the tree is drawn, it scrolls no further than 1:" &
            Integer'Image (Tree.Get_V_Position));
        Check (Count (Tree, Red) >= 0, "the tree is drawn");
        Tree.Set_V_Position (40);
        Check (Tree.Get_V_Position = 40,
            "Set_V_Position, Get_V_Position:" & Integer'Image (Tree.Get_V_Position));
        Tree.Set_V_Position (100_000);
        Most := Tree.Get_V_Position;
        Check (Most > 40 and Most < 100_000,
            "Set_V_Position past the end goes to the end:" & Integer'Image (Most));
        Tree.Set_V_Position (-5);
        Check (Tree.Get_V_Position = 0, "Set_V_Position before the start goes to the start");
        Tree.Set_H_Position (10);
        Check (Tree.Get_H_Position = 10,
            "Set_H_Position, Get_H_Position:" & Integer'Image (Tree.Get_H_Position));
        Check (Tree.Get_Scrollbar_Size = 0, "a tree's scrollbar size is 0, the global, by default");
        Tree.Set_Scrollbar_Size (30);
        Check (Tree.Get_Scrollbar_Size = 30, "Set_Scrollbar_Size, Get_Scrollbar_Size");
    end Scrolling;

    procedure Icons is
        Tree   : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 200, 100);
        Parent : constant TI.Tree_Item := Tree.Add ("p");
        Child  : constant TI.Tree_Item := Tree.Add ("p/c");
        Lone   : constant TI.Tree_Item := Tree.Add ("l");
    begin
        Tree.Set_Show_Root (False);
        Check (Tree.Get_Open_Icon = null and Tree.Get_Close_Icon = null
                and Tree.Get_User_Icon = null,
            "a tree has no icons of its own by default");

        --  The images go before the tree draws them.
        declare
            Reds   : constant RGB.RGB_Image := RGB.Forge.Create (Square (255, 0, 0, 9), 9, 9);
            Greens : constant RGB.RGB_Image := RGB.Forge.Create (Square (0, 255, 0, 9), 9, 9);
            Blues  : constant RGB.RGB_Image := RGB.Forge.Create (Square (0, 0, 255, 10), 10, 10);
        begin
            Tree.Set_Open_Icon (Reds);
            Tree.Set_Close_Icon (Greens);
            Tree.Set_User_Icon (Blues);
        end;
        Check (Width_Of (Tree.Get_Open_Icon) = 9 and Width_Of (Tree.Get_Close_Icon) = 9
                and Width_Of (Tree.Get_User_Icon) = 10,
            "Get_Open_Icon, Get_Close_Icon and Get_User_Icon return the tree's copies");
        Check (Count (Tree, Green) >= 81,
            "an open item shows the close icon, after its image went:" &
            Natural'Image (Count (Tree, Green)));
        Check (Count (Tree, Blue) >= 300,
            "items without a user icon of their own show the tree's, all three:" &
            Natural'Image (Count (Tree, Blue)));
        Tree.Close (Parent);
        Check (Count (Tree, Red) >= 81 and Count (Tree, Green) = 0,
            "a closed item shows the open icon");

        --  An item's icon set and cleared leaves the tree's alone.
        declare
            Small : constant RGB.RGB_Image := RGB.Forge.Create (Square (0, 0, 0, 4), 4, 4);
        begin
            TI.Set_User_Icon (Lone, Small);
            TI.Clear_User_Icon (Lone);
        end;
        Check (Width_Of (Tree.Get_Open_Icon) = 9 and Width_Of (Tree.Get_Close_Icon) = 9
                and Width_Of (Tree.Get_User_Icon) = 10,
            "an item's icon cleared leaves the tree's icons");
        Check (Count (Tree, Red) >= 81, "and the tree still draws them");
        Tree.Open (Parent);

        declare
            Bigger : constant RGB.RGB_Image := RGB.Forge.Create (Square (0, 255, 0, 12), 12, 12);
        begin
            Tree.Set_Close_Icon (Bigger);
        end;
        Check (Width_Of (Tree.Get_Close_Icon) = 12 and Count (Tree, Green) >= 144,
            "an icon replaced:" & Integer'Image (Width_Of (Tree.Get_Close_Icon)));
        Tree.Clear_Close_Icon;
        Tree.Clear_User_Icon;
        Check (Tree.Get_Close_Icon = null and Tree.Get_User_Icon = null
                and Count (Tree, Green) = 0 and Count (Tree, Blue) = 0,
            "Clear_Close_Icon, Clear_User_Icon");
        pragma Unreferenced (Child);
    end Icons;

    procedure Shared_Icons is
        Pixels : constant RGB.RGB_Image := RGB.Forge.Create (Square (255, 0, 0, 8), 8, 8);
        Pooled : Shr.Shared_Image := Shr.Forge.Create (Pixels);
        Shows  : Bxs.Box := Bxs.Forge.Create (Window, 210, 0, 40, 40);
        Images : Natural;
    begin
        Shows.Set_Image (Pooled);
        Check (Count (Shows, Red) = 64, "a shared image shows red");
        Images := Shr.Number_Of_Images;
        declare
            Tree : Trs.Tree := Trs.Forge.Create (Window, 0, 0, 200, 100);
        begin
            Tree.Set_Open_Icon (Pooled);
            Tree.Set_User_Icon (Pooled);
            Check (Count (Shows, Red) = 64,
                "a tree's icon leaves its shared image's colours alone");
            Check (Pooled.Reference_Count = 1,
                "a tree's icon takes no reference to a shared image:" &
                Integer'Image (Pooled.Reference_Count));
            Check (Tree.Get_Open_Icon /= null
                    and then Tree.Get_Open_Icon.all not in Shr.Shared_Image'Class
                    and then Width_Of (Tree.Get_Open_Icon) = 8,
                "a shared image is copied as a plain image");
        end;
        Check (Count (Shows, Red) = 64 and Shr.Number_Of_Images = Images
                and Pooled.Reference_Count = 1,
            "a tree that goes leaves the pool as it was:" & Natural'Image (Shr.Number_Of_Images)
            & Integer'Image (Pooled.Reference_Count));
    end Shared_Icons;

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;

    Colours;
    Scrolling;
    Icons;
    Shared_Icons;

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tree_Methods;
