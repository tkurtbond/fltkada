

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/menubar-add.cxx: a menu bar built with Add,
--  with shortcuts, dividers, radio and toggle items.
--
--  Where the original's find_item returns a null pointer for a missing
--  item, Find_Item raises No_Reference_Error, so the complaint is printed
--  from an exception handler.


with

    Ada.Text_IO,
    FLTK.Filenames,
    FLTK.Menu_Items,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Bars,
    GNAT.OS_Lib;

use type

    FLTK.Menu_Flag;


function Menubar_Add
    return Integer
is


    package TIO renames Ada.Text_IO;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Mn  renames FLTK.Widgets.Menus;
    package MB  renames FLTK.Widgets.Menus.Menu_Bars;


    --  This callback is invoked whenever the user clicks an item in the menu bar
    procedure My_Menu_Callback
           (W : in out FLTK.Widgets.Widget'Class)
    is
        Bar   : Mn.Menu'Class renames Mn.Menu'Class (W);   --  Get the menubar widget
        Item  : FLTK.Menu_Items.Menu_Item'Class renames
            Bar.Chosen.Data.all;                              --  Get the menu item that was picked
        IPath : constant String := Bar.Item_Pathname;      --  Get full pathname of picked item
        Label : constant String := Item.Get_Label;
        Flags : constant FLTK.Menu_Flag := Item.Get_Flags;
    begin
        TIO.Put (TIO.Standard_Error, "callback: You picked '" & Label & "'");   --  Print item
        TIO.Put (TIO.Standard_Error, ", item_pathname() is '" & IPath & "'");   --  ..and path

        if Flags.Radio or Flags.Toggle then   --  Toggle or radio item?
            TIO.Put   --  Print item's value
               (TIO.Standard_Error, ", value is " & (if Item.Get_State then "on" else "off"));
        end if;
        TIO.New_Line (TIO.Standard_Error);
        if Label = "Google" then
            FLTK.Filenames.Open_URI ("http://google.com/");
        end if;
        if Label = "&Quit" then
            GNAT.OS_Lib.OS_Exit (0);
        end if;
    end My_Menu_Callback;


    CB : constant FLTK.Widgets.Widget_Callback := My_Menu_Callback'Unrestricted_Access;

    type Window_Access is access Win.Window;
    type Menu_Bar_Access is access MB.Menu_Bar;

    The_Window : Window_Access;
    Menu       : Menu_Bar_Access;


begin


    FLTK.Static.Set_Scheme ("gtk+");
    --  Create window
    The_Window := new Win.Window'(Win.Forge.Create (400, 200, "menubar-simple"));
    --  Create menubar, items..
    Menu := new MB.Menu_Bar'(MB.Forge.Create (The_Window.all, 0, 0, 400, 25));
    Menu.Add ("&File/&Open",    CB, "^o");
    Menu.Add ("&File/&Save",    CB, "^s", FLTK.Flag_Divider);
    Menu.Add ("&File/&Quit",    CB, "^q");
    Menu.Add ("&Edit/&Copy",    CB, "^c");
    Menu.Add ("&Edit/&Paste",   CB, "^v", FLTK.Flag_Divider);
    Menu.Add ("&Edit/Radio 1",  CB, Flags => FLTK.Flag_Radio);
    Menu.Add ("&Edit/Radio 2",  CB, Flags => FLTK.Flag_Radio + FLTK.Flag_Divider);
    Menu.Add ("&Edit/Toggle 1", CB, Flags => FLTK.Flag_Toggle);                     --  Default: off
    Menu.Add ("&Edit/Toggle 2", CB, Flags => FLTK.Flag_Toggle);                     --  Default: off
    Menu.Add ("&Edit/Toggle 3", CB, Flags => FLTK.Flag_Toggle + FLTK.Flag_Value);   --  Default: on
    Menu.Add ("&Help/Google",   CB);

    --  Example: show how we can dynamically change the state of item Toggle #2 (turn it 'on')
    begin
        Menu.Find_Item ("&Edit/Toggle 2").Set;   --  Find item, turn it on
    exception
        when Mn.No_Reference_Error =>   --  (optional) Not found? complain!
            TIO.Put_Line (TIO.Standard_Error, "'Toggle 2' item not found?!");
    end;

    The_Window.End_Current;
    The_Window.Show;
    return FLTK.Run;


end Menubar_Add;
