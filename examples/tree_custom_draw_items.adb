

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/tree-custom-draw-items.cxx: a Tree with
--  custom items that draw the date and time, put into the tree both by
--  Add and by Replace.
--
--  The original passes the time format around as a string; here it is
--  an enumeration, whose labels are the original's strings.


with

    Ada.Calendar.Formatting,
    Ada.Calendar.Time_Zones,
    Ada.Strings.Fixed,
    FLTK.Draw,
    FLTK.Static,
    FLTK.Tree_Items.Custom,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices.Schemes;

use type

    FLTK.Alignment;


function Tree_Custom_Draw_Items
    return Integer
is


    package Cal renames Ada.Calendar;
    package Fmt renames Ada.Calendar.Formatting;
    package FD  renames FLTK.Draw;
    package TI  renames FLTK.Tree_Items;
    package TIC renames FLTK.Tree_Items.Custom;
    package Trs renames FLTK.Widgets.Groups.Trees;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package Sch renames FLTK.Widgets.Menus.Choices.Schemes;


    type Tree_Access is access Trs.Tree;

    Tree : Tree_Access;


    --  printf's "%02d"
    function Image_2
           (Value : in Natural)
        return String
    is
        S : constant String := Ada.Strings.Fixed.Trim (Natural'Image (Value), Ada.Strings.Left);
    begin
        return (if S'Length < 2 then "0" & S else S);
    end Image_2;


    --  DERIVE CUSTOM TYPE FROM Custom_Item TO IMPLEMENT SHOWING THE TIME OF DAY
    --      This demonstrates that item content can be dynamic and highly customized.

    type Time_Format is (Local, GMT);

    function Label_Of
           (Format : in Time_Format)
        return String is
    begin
        return (case Format is when Local => "Local", when GMT => "GMT");
    end Label_Of;

    type My_Time_Item is new TIC.Custom_Item with record
        Format : Time_Format;
    end record;

    --  Handle custom drawing of the item
    --      Tree has already handled drawing everything to the left
    --      of the label area, including any 'user icon', collapse buttons,
    --      connector lines, etc.
    --
    --      All we're responsible for is drawing the 'label' area of the item
    --      and it's background. Tree gives us a hint as to what the
    --      foreground and background colors should be via
    --      Draw_Foreground_Color/Draw_Background_Color, and whether we're
    --      supposed to render anything or not.
    --
    --      The only other thing we must do is return the maximum X position
    --      of scrollable content, i.e. the right most X position of content
    --      that we want the user to be able to use the horizontal scrollbar
    --      to reach.
    overriding function Draw_Item_Content
           (This   : in out My_Time_Item;
            Render : in     Boolean)
        return Integer;


    function Create
           (Tree   : in out Trs.Tree;
            Format : in     Time_Format)
        return My_Time_Item is
    begin
        return This : constant My_Time_Item := (TIC.Forge.Create (Tree) with Format => Format) do
            TI.Set_Label (This.Item, Label_Of (Format));
        end return;
    end Create;


    overriding function Draw_Item_Content
           (This   : in out My_Time_Item;
            Render : in     Boolean)
        return Integer
    is
        Item : constant TI.Tree_Item := This.Item;
        Fg   : constant FLTK.Color := This.Draw_Foreground_Color;
        Bg   : constant FLTK.Color := This.Draw_Background_Color;
        --  Show the date and time as two small strings
        --  one on top of the other in a single item.
        --
        --  Our item's label dimensions
        X : Integer := TI.Label_X (Item);
        Y : constant Integer := TI.Label_Y (Item);
        W : constant Integer := TI.Label_W (Item);
        H : constant Integer := TI.Label_H (Item);
        Label : constant String := TI.Get_Label (Item);
        Select_Box : constant FLTK.Box_Kind := Tree.Get_Select_Box;
        --  Render the label
        DX : constant Integer := FLTK.Static.Get_Box_X_Offset (Select_Box) + 1;
        DW : constant Integer := FLTK.Static.Get_Box_Width_Offset (Select_Box) + 2;
        LW, LH, LW2, LH2 : Natural := 0;
        Now : constant Cal.Time := Cal.Clock;
        Zone : constant Cal.Time_Zones.Time_Offset :=
            (case This.Format is
             when Local => Cal.Time_Zones.UTC_Time_Offset (Now),
             when GMT   => 0);
        Year       : Cal.Year_Number;
        Month      : Cal.Month_Number;
        Day        : Cal.Day_Number;
        Hour       : Fmt.Hour_Number;
        Minute     : Fmt.Minute_Number;
        Second     : Fmt.Second_Number;
        Sub_Second : Fmt.Second_Duration;
    begin
        --  Render background
        if Render then
            if TI.Is_Selected (Item) then   --  Selected? Use Select_Box style
                FD.Draw_Box (X, Y, W, H, Select_Box, Bg);
            else                            --  Not Selected? use plain filled rectangle
                FD.Set_Color (Bg);
                FD.Rect_Fill (X, Y, W, H);
            end if;
        end if;
        if Render then
            FD.Set_Color (Fg);
            if Label /= "" then
                FD.Draw_Text (X + DX, Y, W - DW, H, Label, FLTK.Align_Left);
            end if;
        end if;
        if Label /= "" then
            FD.Measure (Label, LW, LH);
        end if;
        X := X + LW + 8;
        --  Draw some red/grn/blu boxes
        if Render then
            FD.Set_Color (FLTK.Red_Color);
            FD.Rect_Fill (X + 0,  Y + 2, 10, H - 4);
            FD.Set_Color (FLTK.Green_Color);
            FD.Rect_Fill (X + 10, Y + 2, 10, H - 4);
            FD.Set_Color (FLTK.Blue_Color);
            FD.Rect_Fill (X + 20, Y + 2, 10, H - 4);
        end if;
        X := X + 35;
        --  Render the date and time, one over the other
        FD.Set_Font (TI.Get_Label_Font (Item), 8);   --  small font
        FD.Set_Color (Fg);
        Fmt.Split (Now, Year, Month, Day, Hour, Minute, Second, Sub_Second, Zone);
        declare
            Date_Text : constant String :=
                "Date: " & Image_2 (Month) & "/" & Image_2 (Day) & "/" & Image_2 (Year mod 100);
            Time_Text : constant String :=
                "Time: " & Image_2 (Hour) & ":" & Image_2 (Minute) & ":" & Image_2 (Second);
        begin
            --  get box around text (including white space)
            FD.Measure (Date_Text, LW, LH);
            if Render then
                FD.Draw_Text (X, Y + 4, W, H, Date_Text, FLTK.Align_Left + FLTK.Align_Top);
            end if;
            if Render then
                FD.Draw_Text
                   (X, Y + H / 2, W, H / 2, Time_Text, FLTK.Align_Left + FLTK.Align_Top);
            end if;
            FD.Measure (Time_Text, LW2, LH2);
        end;
        X := X + Integer'Max (LW, LW2);
        return X;   --  return right most edge of what we've rendered
    end Draw_Item_Content;


    --  TIMER TO HANDLE DYNAMIC CONTENT IN THE TREE
    procedure Timer_CB is
    begin
        Tree.Redraw;   --  keeps time updated
        FLTK.Static.Repeat_Timeout (0.2, Timer_CB'Unrestricted_Access);
    end Timer_CB;


    type Time_Item_Access is access My_Time_Item;

    My_Item     : Time_Item_Access;
    Item        : TI.Tree_Item;
    Ignore_Item : TI.Tree_Item;


begin


    FLTK.Static.Set_Scheme ("gtk+");   --  default scheme: can be overridden by commandline

    declare
        Win : DW.Double_Window := DW.Forge.Create (350, 450, "Tree Custom Draw Items");

        Win_W : constant Integer := Win.Get_W;
        Win_H : constant Integer := Win.Get_H;
    begin
        --  Create the tree
        Tree := new Trs.Tree'(Trs.Forge.Create (Win, 0, 0, Win_W, Win_H - 50));
        Tree.Set_Show_Root (False);                    --  don't show root of tree
        Tree.Set_Select_Mode (TI.Multi_Selection);     --  multiselect

        --  Add some items
        Ignore_Item := Tree.Add ("Flintstones/Fred");
        Ignore_Item := Tree.Add ("Flintstones/Wilma");
        Ignore_Item := Tree.Add ("Flintstones/Pebbles");

        My_Item := new My_Time_Item'(Create (Tree.all, Local));   --  create custom item
        TI.Set_Label_Size (My_Item.Item, 20);
        Ignore_Item := Tree.Add ("Time Add Item/Local", My_Item.Item);

        My_Item := new My_Time_Item'(Create (Tree.all, GMT));     --  create custom item
        TI.Set_Label_Size (My_Item.Item, 20);
        Ignore_Item := Tree.Add ("Time Add Item/GMT", My_Item.Item);

        --  'Replace' approach
        Item := Tree.Add ("Time Replace Item/Local Time");
        --  Replace the 'Local' item with our own
        My_Item := new My_Time_Item'(Create (Tree.all, Local));   --  create custom item
        TI.Set_Label_Size (My_Item.Item, 20);
        Ignore_Item := TI.Replace (Item, My_Item.Item);   --  replace normal item with custom

        Item := Tree.Add ("Time Replace Item/GMT Time");
        --  Replace the 'GMT' item with our own
        My_Item := new My_Time_Item'(Create (Tree.all, GMT));     --  create custom item
        TI.Set_Label_Size (My_Item.Item, 20);
        Ignore_Item := TI.Replace (Item, My_Item.Item);   --  replace normal item with custom

        Ignore_Item := Tree.Add ("Superjail/Warden");
        Ignore_Item := Tree.Add ("Superjail/Jared");
        Ignore_Item := Tree.Add ("Superjail/Alice");
        Ignore_Item := Tree.Add ("Superjail/Jailbot");

        Tree.Show_Self;

        --  Start with some items closed
        Tree.Close (Tree.Find ("Superjail"));

        --  Optional: set a "special" selection color (light blue)
        Tree.Set_Selection_Color (16#cceeff00#);

        --  Optional: set a "special" box type for the selection box
        Tree.Set_Select_Box (FLTK.Thin_Up_Box);

        --  Create the scheme choice box
        declare
            Choice : Sch.Scheme_Choice := Sch.Forge.Create
               (Win, (Win_W - 130) / 2, Win_H - 40, 130, 30, "Scheme: ");
            pragma Unreferenced (Choice);
        begin
            --  Set up a timer to keep time in tree updated
            FLTK.Static.Add_Timeout (0.2, Timer_CB'Unrestricted_Access);

            Win.End_Current;
            Win.Set_Resizable (Tree.all);
            Win.Set_Size_Range (300, 350);
            Win.Show_With_Args;
            return FLTK.Run;
        end;
    end;


end Tree_Custom_Draw_Items;
