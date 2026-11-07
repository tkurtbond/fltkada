


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Widget, group and window properties, colours, screens and schemes, after
--  pofltk's test/TestWidget.Mod.  Each property set reads back as set,
--  through FLTK.


with

    Ada.Exceptions,
    Ada.Text_IO,
    Checks,
    FLTK.Filenames,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Single.Menu,
    System;

use

    Checks;


procedure Test_Widget is

    package Scr renames FLTK.Screen;
    package Sta renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Sgl renames FLTK.Widgets.Groups.Windows.Single;
    package Mnu renames FLTK.Widgets.Groups.Windows.Single.Menu;

    use type FLTK.Alignment;
    use type FLTK.Box_Kind;
    use type FLTK.Callback_Flag;
    use type FLTK.Color;
    use type FLTK.Color_Component;
    use type FLTK.Font_Kind;
    use type FLTK.Label_Kind;
    use type FLTK.Font_Size;
    use type System.Address;

    Window : Win.Window := Win.Forge.Create (300, 200, "Test_Widget");
    G      : Grp.Group := Grp.Forge.Create (Window, 10, 10, 200, 150, "g");
    A      : Bx.Box := Bx.Forge.Create (G, 20, 20, 50, 20, "a");
    B      : constant Bx.Box := Bx.Forge.Create (G, 20, 50, 50, 20, "b");
    C      : Bx.Box := Bx.Forge.Create (Window, 220, 20, 50, 20, "c");

    Ignore : Boolean;

    procedure Settle is
    begin
        for N in 1 .. 100 loop
            exit when Window.Is_Shown and then not Window.Is_Damaged;
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Settle;

    --  Whether a widget's parent is this group.
    function Parent_Is
           (Item  : in Wdg.Widget'Class;
            Group : in Grp.Group'Class)
        return Boolean is
    begin
        return Item.Parent /= null and then Item.Parent.all in Grp.Group'Class
            and then Item.Parent.all'Address = Group'Address;
    end Parent_Is;

    procedure Add_Upper_Case is
    begin
        Ignore := Sta.Add_Scheme_Name ("Upper Case");
    end Add_Upper_Case;

    procedure Add_Thirteen is
    begin
        Ignore := Sta.Add_Scheme_Name ("thirteenchars");
    end Add_Thirteen;

begin

    --  The label's look.
    A.Set_Box (FLTK.Round_Up_Box);
    A.Set_Label_Font (FLTK.Times_Bold_Italic);
    A.Set_Label_Size (24);
    A.Set_Label_Color (FLTK.Blue_Color);
    A.Set_Label_Kind (FLTK.Engraved_Label);
    Check (A.Get_Box = FLTK.Round_Up_Box and A.Get_Label_Font = FLTK.Times_Bold_Italic
        and A.Get_Label_Size = 24 and A.Get_Label_Color = FLTK.Blue_Color
        and A.Get_Label_Kind = FLTK.Engraved_Label,
        "box, label font, size, colour and kind read back");
    Check (B.Get_Box = FLTK.No_Box and B.Get_Label_Font = FLTK.Helvetica
        and B.Get_Label_Size = FLTK.Get_Normal_Size and B.Get_Label_Kind = FLTK.Normal_Label,
        "a box's defaults: no box, Helvetica, the normal size, a normal label");
    Check (FLTK.Get_Normal_Size = 14, "the normal size is 14 to start with");
    FLTK.Set_Normal_Size (20);
    declare
        D : constant Bx.Box := Bx.Forge.Create (20, 20, 10, 10);
    begin
        Check (FLTK.Get_Normal_Size = 20 and D.Get_Label_Size = 20,
            "Set_Normal_Size: a box made after it takes the size");
    end;
    FLTK.Set_Normal_Size (14);
    A.Set_Alignment (FLTK.Align_Top_Left + FLTK.Align_Inside + FLTK.Align_Wrap);
    Check (A.Get_Alignment = FLTK.Align_Top_Left + FLTK.Align_Inside + FLTK.Align_Wrap,
        "an alignment set reads back");
    A.Set_Background_Color (FLTK.RGB_Color (10, 20, 30));
    A.Set_Selection_Color (FLTK.Dark_Red_Color);
    Check (A.Get_Background_Color = FLTK.RGB_Color (10, 20, 30)
        and A.Get_Selection_Color = FLTK.Dark_Red_Color,
        "colour and selection colour, an RGB colour and an index");
    A.Set_When (FLTK.When_Release + FLTK.When_Changed);
    Check (A.Get_When = FLTK.When_Release + FLTK.When_Changed, "when reads back");

    --  Tooltips are copied.
    declare
        Tip : String := "tip";
    begin
        A.Set_Tooltip (Tip);
        Tip := "XXX";
        Check (A.Get_Tooltip = "tip" and Tip = "XXX", "a tooltip is copied");
    end;
    A.Set_Tooltip ("");
    Check (A.Get_Tooltip = "", "an empty tooltip removes it");

    --  Geometry.
    A.Reposition (30, 25);
    A.Resize (60, 22);
    Check (A.Get_X = 30 and A.Get_Y = 25 and A.Get_W = 60 and A.Get_H = 22,
        "Reposition and Resize (W, H)");
    A.Resize (20, 20, 50, 20);
    Check (A.Get_X = 20 and A.Get_W = 50, "Resize (X, Y, W, H)");

    --  Activation and visibility through the group.
    G.Deactivate;
    Check (not G.Is_Active and A.Is_Active and not A.Is_Tree_Active and C.Is_Tree_Active,
        "a deactivated group's child is active, but not in the tree");
    G.Activate;
    Check (A.Is_Tree_Active, "and active in the tree again once the group is activated");
    Check (Sta.Get_First_Window = null, "no window shown yet");
    Window.Show;
    Settle;
    Check (Window.Is_Shown and A.Is_Tree_Visible, "a shown window's box is visible in the tree");
    Check (Sta.Get_First_Window /= null, "a window is shown");
    G.Hide;
    Check (A.Is_Visible and not A.Is_Tree_Visible,
        "a hidden group's child: visible, not in the tree");
    G.Show;

    --  Parents and children.
    Check (Parent_Is (A, G) and Parent_Is (G, Window) and Window.Parent = null,
        "Parent finds each object");
    Check (G.Find (B) = 2 and G.Find (C) = Grp.No_Index and Window.Find (C) = 2, "Find");
    G.Remove (A);
    Check (G.Number_Of_Children = 1 and A.Parent = null, "Remove keeps the widget");
    G.Insert (A, 1);
    Check (G.Find (A) = 1 and G.Find (B) = 2 and Parent_Is (A, G), "Insert at 1");
    G.Add (C);
    Check (G.Find (C) = 3 and Window.Find (C) = Grp.No_Index and Parent_Is (C, G),
        "Add moves a widget from its group");
    Window.Set_Resizable (G);
    Check (Window.Get_Resizable /= null
        and then Window.Get_Resizable.all'Address = G'Address, "Resizable");
    Window.Clear_Resizable;
    Check (Window.Get_Resizable = null, "no resizable");

    --  FLTKAda's Clear takes the children out, and leaves them to Ada; pofltk's
    --  deletes them.
    G.Clear;
    Check (G.Number_Of_Children = 0 and A.Parent = null and B.Parent = null
        and C.Parent = null, "Clear takes the children out");

    --  A group resizes its children from the sizes it saved:  a child the
    --  program moved goes back, unless Reset_Sizes forgets them.
    declare
        D : Bx.Box := Bx.Forge.Create (20, 20, 10, 10);
    begin
        G.Add (D);
        G.Resize (10, 10, 400, 150);
        Check (D.Get_X = 30 and D.Get_W = 20, "a group scales its children");
        D.Resize (100, 20, 10, 10);
        G.Resize (10, 10, 200, 150);
        Check (D.Get_X = 20, "from the sizes it saved");
        D.Resize (100, 20, 10, 10);
        G.Reset_Sizes;
        G.Resize (10, 10, 400, 150);
        Check (D.Get_X = 190 and D.Get_W = 20, "Reset_Sizes:  from where they are");
        G.Resize (10, 10, 200, 150);
        G.Clear;
    end;

    --  Window modes.
    Window.Set_Non_Modal;
    Check (not Window.Is_Modal, "non-modal isn't modal");
    Window.Set_Modal;
    Check (Window.Is_Modal, "modal");

    --  A window's title is its label.
    Window.Set_Label ("retitled");
    Check (Window.Get_Label = "retitled", "a shown window's title");

    --  Colours.
    declare
        R, Gr, Bl : FLTK.Color_Component;
    begin
        Sta.Get_Color (FLTK.RGB_Color (1, 2, 3), R, Gr, Bl);
        Check (R = 1 and Gr = 2 and Bl = 3, "Get_Color of an RGB colour");
        Sta.Set_Color (FLTK.Free_Color, 200, 100, 50);
        Sta.Get_Color (FLTK.Free_Color, R, Gr, Bl);
        Check (R = 200 and Gr = 100 and Bl = 50, "Set_Color, and Get_Color of an index");
        Check (FLTK.Contrast (FLTK.Black_Color, FLTK.Black_Color) = FLTK.White_Color,
            "black on black contrasts to white");
        Sta.Get_Color (FLTK.Color_Average
            (FLTK.RGB_Color (200, 0, 0), FLTK.RGB_Color (0, 0, 100), 0.5), R, Gr, Bl);
        Check (R = 100 and Gr = 0 and Bl = 50, "Color_Average");
    end;

    --  Box borders, from FLTK's table of box kinds.
    Check (Sta.Get_Box_X_Offset (FLTK.No_Box) = 0 and Sta.Get_Box_Width_Offset (FLTK.No_Box) = 0,
        "no border for No_Box");
    Check (Sta.Get_Box_X_Offset (FLTK.Thin_Up_Box) = 1
        and Sta.Get_Box_Y_Offset (FLTK.Thin_Up_Box) = 1
        and Sta.Get_Box_Width_Offset (FLTK.Thin_Up_Box) = 2
        and Sta.Get_Box_Height_Offset (FLTK.Thin_Up_Box) = 2, "a thin up box's border");
    Check (Sta.Get_Box_X_Offset (FLTK.Engraved_Box) = 2
        and Sta.Get_Box_Height_Offset (FLTK.Engraved_Box) = 4, "an engraved box's");

    --  Screens, numbered from 1.  Their sizes are the display's, and printed.
    declare
        SX, SY, SW, SH, WX, WY, WW, WH : Integer;
    begin
        Check (Scr.Count >= 1, "Count");
        Scr.Bounding_Rect (SX, SY, SW, SH, 1);
        Scr.Work_Area (WX, WY, WW, WH, 1);
        Check (SW > 0 and SH > 0 and WX >= SX and WY >= SY
            and WX + WW <= SX + SW and WY + WH <= SY + SH,
            "a screen, and its work area inside it");
        Check (Scr.Get_X = WX and Scr.Get_Y = WY and Scr.Get_W = WW and Scr.Get_H = WH,
            "Get_X, Get_Y, Get_W, Get_H:  the main screen's work area");
        Check (Scr.Containing (SX + SW - 1, SY + SH - 1) = 1
            and Scr.Containing (SX - 10000, SY - 10000) = 1,
            "Containing:  1 on screen 1, and on none");
        Ada.Text_IO.Put_Line ("# screen 1:" & Integer'Image (SX) & "," & Integer'Image (SY)
            & Integer'Image (SW) & "x" & Integer'Image (SH) & ", work area"
            & Integer'Image (WW) & "x" & Integer'Image (WH));
    end;

    --  Open_URI:  only what starts no program.
    begin
        FLTK.Filenames.Open_URI ("foo:bar");
        Check (False, "Open_URI of a scheme FLTK doesn't open raises");
    exception
    when E : FLTK.Filenames.Open_URI_Error =>
        Check (Ada.Exceptions.Exception_Message (E)
            = "Error: URI scheme ""foo"" not supported.",
            "Open_URI of a scheme FLTK doesn't open raises, and says why: "
            & Ada.Exceptions.Exception_Message (E));
    end;

    --  Schemes.
    Sta.Set_Scheme ("gtk+");
    Check (Sta.Get_Scheme = "gtk+", "a scheme set reads back");
    Check (Sta.Scheme_Count >= 5, "FLTK has at least its five schemes");
    Check (Sta.Scheme_Name (1) = "base", "the first is base");
    declare
        N : constant Natural := Sta.Scheme_Count;
    begin
        Check (Sta.Add_Scheme_Name ("mine"), "a new scheme name");
        Check (Sta.Scheme_Count = N + 1, "counts");
        Check (Sta.Scheme_Name (N + 1) = "mine", "and is last");
        Check (not Sta.Add_Scheme_Name ("mine"), "a name already there isn't added");
        Raises (Add_Upper_Case'Access, Constraint_Error'Identity,
            "nor one with characters FLTK refuses:  it raises");
        Raises (Add_Thirteen'Access, Constraint_Error'Identity,
            "nor one over twelve bytes");
        Check (Sta.Scheme_Count = N + 1, "so none of those counted");
    end;

    --  The other windows.
    Window.Set_X_Class ("FLTKAda");
    Check (Window.Get_X_Class = "FLTKAda", "a window's class reads back");
    declare
        Single : constant Sgl.Single_Window := Sgl.Forge.Create (100, 80, "single");
    begin
        Check (Single.Get_W = 100 and Single.Get_H = 80, "a single window");
    end;
    declare
        Single : constant Sgl.Single_Window := Sgl.Forge.Create (10, 20, 100, 80, "single");
    begin
        Check (Single.Get_X = 10 and Single.Get_Y = 20, "placed");
    end;
    declare
        Menu : Mnu.Menu_Window := Mnu.Forge.Create (100, 80, "menu");
    begin
        Check (Menu.Get_H = 80, "a menu window");
        Menu.Show;
        for N in 1 .. 100 loop
            exit when Menu.Is_Shown;
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
        Check (Menu.Is_Shown, "shows");
        --  FLTK marks only its own pop-ups' windows as menu windows
        --  (Fl_Menu.cxx:117), not every Fl_Menu_Window (Fl_Menu_Window.cxx:33-43).
        Check (not Menu.Is_Menu_Window, "but isn't marked as a menu's");
        Menu.Hide;
    end;
    declare
        Menu : constant Mnu.Menu_Window := Mnu.Forge.Create (10, 20, 100, 80, "menu");
    begin
        Check (Menu.Get_X = 10, "placed");
    end;

    Window.Hide;
    Ignore := FLTK.Check;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Widget;



