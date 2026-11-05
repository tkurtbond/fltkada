

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Phase 12's layout and menu methods: Tile size ranges (pofltk 24),
--  Tabs alignment and overflow, a menu's Menu_Box, and the system menu
--  bar's macOS-only statics, which do nothing elsewhere.


with

    Checks,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Groups.Tiled,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Groups.Tabbed.Overflow_Kind;


procedure Test_Layout_Methods is

    package Wdg renames FLTK.Widgets;
    package Grp renames FLTK.Widgets.Groups;
    package Tab renames FLTK.Widgets.Groups.Tabbed;
    package Til renames FLTK.Widgets.Groups.Tiled;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Sys renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;

    use type Sys.Window_Menu_Style_Kind;

    Window : Win.Window := Win.Forge.Create (0, 0, 400, 300, "Test_Layout_Methods");

    About_Count : Natural := 0;

    procedure About is
    begin
        About_Count := About_Count + 1;
    end About;

    function At_Place
           (Item       : in Wdg.Widget'Class;
            X, Y, W, H : in Integer)
        return Boolean is
    begin
        return Item.Get_X = X and Item.Get_Y = Y and Item.Get_W = W and Item.Get_H = H;
    end At_Place;

    procedure Tile_Ranges is
        Tile  : Til.Tiled_Group := Til.Forge.Create (Window, 0, 200, 300, 100);
        Left  : constant Wdg.Boxes.Box := Wdg.Boxes.Forge.Create
           (Tile, Down_Box, 0, 200, 150, 100);
        Right : constant Wdg.Boxes.Box := Wdg.Boxes.Forge.Create
           (Tile, Down_Box, 150, 200, 150, 100);
        Stray : constant Wdg.Boxes.Box := Wdg.Boxes.Forge.Create (Down_Box, 0, 0, 10, 10);

        procedure Bad_Place is
        begin
            Tile.Set_Size_Range (3, 10, 10);
        end Bad_Place;

        procedure Not_A_Child is
        begin
            Tile.Set_Size_Range (Stray, 10, 10);
        end Not_A_Child;
    begin
        Tile.Position (150, 200, 100, 200);
        Check (At_Place (Left, 0, 200, 100, 100) and At_Place (Right, 100, 200, 200, 100),
            "Position moves a tile's border, resizing both sides");
        Tile.Set_Size_Range (Left, 80, 50);
        Tile.Position (100, 200, 20, 200);
        Check (Left.Get_W = 80,
            "a size range set after a move stops the next one (pofltk 24):" &
            Integer'Image (Left.Get_W));
        Tile.Set_Size_Range (2, 120, 50);
        Tile.Position (80, 200, 250, 200);
        Check (Right.Get_W = 120,
            "a size range set by index stops a move:" & Integer'Image (Right.Get_W));
        Raises (Bad_Place'Access, Constraint_Error'Identity,
            "Set_Size_Range with no such child raises Constraint_Error");
        Raises (Not_A_Child'Access, Constraint_Error'Identity,
            "Set_Size_Range with a widget not in the tile raises Constraint_Error");
    end Tile_Ranges;

    procedure Tile_Default_Range is
        Tile  : Til.Tiled_Group := Til.Forge.Create (Window, 0, 200, 300, 100);
        Left  : constant Wdg.Boxes.Box := Wdg.Boxes.Forge.Create
           (Tile, Down_Box, 0, 200, 150, 100);
        Right : constant Wdg.Boxes.Box := Wdg.Boxes.Forge.Create
           (Tile, Down_Box, 150, 200, 150, 100);
    begin
        Tile.Position (150, 200, 100, 200);
        Tile.Init_Size_Range (60, 20);
        Tile.Position (100, 200, 10, 200);
        Check (Left.Get_W = 60 and Right.Get_W = 240,
            "Init_Size_Range after a move gives every child the minimum:" &
            Integer'Image (Left.Get_W));
    end Tile_Default_Range;

    procedure Tab_Methods is
        Tabs : Tab.Tabbed_Group := Tab.Forge.Create (Window, 0, 0, 100, 100);
        A    : constant Grp.Group := Grp.Forge.Create (Tabs, 0, 25, 100, 75, "A long label");
        B    : constant Grp.Group := Grp.Forge.Create (Tabs, 0, 25, 100, 75, "B long label");
        C    : constant Grp.Group := Grp.Forge.Create (Tabs, 0, 25, 100, 75, "C long label");
        D    : constant Grp.Group := Grp.Forge.Create (Tabs, 0, 25, 100, 75, "D long label");
        E    : constant Grp.Group := Grp.Forge.Create (Tabs, 0, 25, 100, 75, "E long label");
        pragma Unreferenced (A, B, C, D, E);

        --  The label of the tab at the tab bar's right edge.
        function Right_Tab
            return String
        is
            Item : constant access Wdg.Widget'Class := Tabs.Get_Which (95, 5);
        begin
            return (if Item = null then "" else Item.Get_Label);
        end Right_Tab;
    begin
        Check (Tabs.Get_Tab_Alignment = Align_Center, "a tab's label is centred by default");
        Tabs.Set_Tab_Alignment (Align_Left);
        Check (Tabs.Get_Tab_Alignment = Align_Left, "Set_Tab_Alignment, Get_Tab_Alignment");

        --  Compressed, the five tabs fit in 100 pixels, so the last is at
        --  the right edge.  Clipped, they keep their width, so an earlier
        --  one is there.
        Check (Right_Tab = "E long label",
            "compressed tabs put the last tab at the right edge: " & Right_Tab);
        Tabs.Handle_Overflow (Tab.Clip_Overflow);
        Check (Right_Tab /= "E long label" and Right_Tab /= "",
            "clipped tabs put an earlier tab at the right edge: " & Right_Tab);
        Tabs.Handle_Overflow (Tab.Compress_Overflow);
        Check (Right_Tab = "E long label",
            "Handle_Overflow (Compress_Overflow) compresses them again: " & Right_Tab);
    end Tab_Methods;

    procedure Menu_Methods is
        Bar : Sys.System_Menu_Bar := Sys.Forge.Create (0, 0, 100, 25);
    begin
        Check (Bar.Get_Menu_Box = No_Box, "a menu's Menu_Box is No_Box by default");
        Bar.Set_Menu_Box (Thin_Up_Box);
        Check (Bar.Get_Menu_Box = Thin_Up_Box, "Set_Menu_Box, Get_Menu_Box");

        --  Without macOS's driver, these do nothing (Fl_Sys_Menu_Bar.cxx).
        Check (Sys.Get_Window_Menu_Style = Sys.No_Window_Menu,
            "Get_Window_Menu_Style is No_Window_Menu off macOS");
        Sys.Set_Window_Menu_Style (Sys.Tabbing_Mode_Preferred);
        Check (Sys.Get_Window_Menu_Style = Sys.No_Window_Menu,
            "Set_Window_Menu_Style does nothing off macOS");
        Sys.Set_About_Callback (About'Unrestricted_Access);
        Sys.Create_Window_Menu;
        Sys.Set_About_Callback (null);
        Check (About_Count = 0, "Set_About_Callback and Create_Window_Menu run nothing");
    end Menu_Methods;

begin

    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    FLTK.Check;

    Tile_Ranges;
    Tile_Default_Range;
    Tab_Methods;
    Menu_Methods;

    Window.Hide;
    Summary;

end Test_Layout_Methods;


