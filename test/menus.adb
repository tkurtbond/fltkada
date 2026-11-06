


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A menu bar, a choice and FLTK's common dialogs, after pofltk's
--  examples/Menus.Mod.
--
--  File/Open asks for a file and names it on the box, relative to the
--  current directory.  Edit/Color asks for the box's colour, and the
--  choice sets the size of the box's label.  The items' actions are given
--  to Add with their shortcuts.  The choice's items have none, so the
--  choice's own callback reads which is chosen.


with

    FLTK.Asks,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Color_Choosers,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars;


function Menus
    return Integer
is


    package Ask renames FLTK.Asks;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Clr renames FLTK.Widgets.Groups.Color_Choosers;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Cho renames FLTK.Widgets.Menus.Choices;
    package Bar renames FLTK.Widgets.Menus.Menu_Bars;

    use type Ask.Choice_Result;
    use type Ask.Confirm_Result;
    use type FLTK.Font_Size;
    use type FLTK.Modifier;


    Window : Win.Window := Win.Forge.Create (400, 250, "Menus");
    Menu   : Bar.Menu_Bar := Bar.Forge.Create (Window, 0, 0, 400, 25);
    Size   : Cho.Choice := Cho.Forge.Create (Window, 60, 40, 100, 25, "Size");
    Box    : Bx.Box := Bx.Forge.Create (Window, 20, 80, 360, 150, "Pick a file");

    --  The box's colour, which Color_CB starts the chooser from.
    R, G, B : Ask.RGB_Int := 255;


    procedure Open_CB
           (Ignore : in out Wdg.Widget'Class)
    is
        Path : constant String := Ask.File_Chooser ("Open", "*.adb", "", Relative => True);
    begin
        --  "" if cancelled.
        if Path /= "" then
            Box.Set_Label (Path);
        end if;
    end Open_CB;


    procedure Color_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        if Ask.Color_Chooser ("Box color", R, G, B, Clr.Byte) = Ask.Confirm then
            Box.Set_Background_Color (FLTK.RGB_Color (R, G, B));
            Box.Redraw;
        end if;
    end Color_CB;


    procedure Quit_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        if Ask.Choice ("Quit?", "No", "Yes") = Ask.Second then
            Window.Hide;
        end if;
    end Quit_CB;


    procedure About_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Ask.Message_Box ("Menus: an FLTKAda example.");
    end About_CB;


    --  Small, Medium and Large are 12, 18 and 24.
    procedure Size_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Box.Set_Label_Size (12 + 6 * FLTK.Font_Size (Size.Chosen_Index - 1));
        Box.Redraw;
    end Size_CB;


begin


    Menu.Add ("&File/&Open...", Open_CB'Unrestricted_Access, FLTK.Mod_Command + 'o',
        FLTK.Flag_Divider);
    Menu.Add ("&File/&Quit", Quit_CB'Unrestricted_Access, FLTK.Mod_Command + 'q');
    Menu.Add ("&Edit/&Color...", Color_CB'Unrestricted_Access);
    Menu.Add ("&Help/&About", About_CB'Unrestricted_Access);

    Size.Add ("Small");
    Size.Add ("Medium");
    Size.Add ("Large");
    Size.Set_Chosen (1);
    Size.Set_Callback (Size_CB'Unrestricted_Access);

    Box.Set_Box (FLTK.Down_Box);
    Box.Set_Background_Color (FLTK.White_Color);

    Window.Set_Resizable (Box);
    Window.Show;

    return FLTK.Run;


end Menus;


