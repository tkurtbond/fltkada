


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Menus:  items, picking, shortcuts, changing and removing items, a
--  choice, a menu button popped up and a system menu bar, after pofltk's
--  test/TestMenus.Mod.  Indexes are FLTKAda's, one more than FLTK's.
--  Global menus are test_menu_global's, a scheme choice
--  test_scheme_choice's.  The pop-up is checked on X11 alone:  Wayland
--  closes a pop-up menu of a window no user clicked (pofltk 29).


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Menu_Items,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide,
    FLTK.Widgets.Menus.Menu_Buttons,
    System;

use

    Checks,
    FLTK;

use type

    FLTK.Widgets.Menus.Menu_Buttons.Popup_Buttons,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide.Window_Menu_Style_Kind,
    FLTK.Widgets.Widget_Callback,
    System.Address;


procedure Test_Menu is

    package MI  renames FLTK.Menu_Items;
    package Prb renames FLTK.Probe;
    package Wdg renames FLTK.Widgets;
    package Mnu renames FLTK.Widgets.Menus;
    package Bar renames FLTK.Widgets.Menus.Menu_Bars;
    package Chs renames FLTK.Widgets.Menus.Choices;
    package MBt renames FLTK.Widgets.Menus.Menu_Buttons;
    package SMB renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;
    package Win renames FLTK.Widgets.Groups.Windows;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Menu");
    Menu   : Bar.Menu_Bar := Bar.Forge.Create (Window, 0, 0, 300, 25);
    Choice : Chs.Choice := Chs.Forge.Create (Window, 50, 50, 100, 25, "Size");
    Button : MBt.Menu_Button := MBt.Forge.Create (Window, 50, 100, 100, 25, "Pop");
    Toggler : MBt.Menu_Button := MBt.Forge.Create (Window, 50, 150, 100, 25, "Tog");

    Opened, Quitted, Bar_Calls, Cleared, Abouts : Natural := 0;
    Last : System.Address := System.Null_Address;
    Pick_Popup : Boolean;
    Ok : Boolean;

    File : constant Mnu.Index := 1;
    Open, Save, Quit, Copy, Grid, Small, Large, Danger, N, I : Mnu.Index;

    procedure Open_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Opened := Opened + 1;
        Last := Item'Address;
    end Open_CB;

    procedure Quit_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Quitted := Quitted + 1;
    end Quit_CB;

    procedure Bar_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Bar_Calls := Bar_Calls + 1;
    end Bar_CB;

    procedure Clear_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Mnu.Menu'Class (Item).Clear;
        Cleared := Cleared + 1;
    end Clear_CB;

    procedure About_CB is
    begin
        Abouts := Abouts + 1;
    end About_CB;

    --  Answers a pop-up menu:  Down and Enter to pick its first item, or
    --  Escape to close it.
    procedure Answer is
    begin
        if Pick_Popup then
            Ok := Prb.Handle_Key (Window, Keydown, Down_Key);
            Ok := Prb.Handle_Key (Window, Keydown, Enter_Key, Mod_None, (1 => ASCII.CR));
        else
            Ok := Prb.Handle_Key (Window, Keydown, Escape_Key, Mod_None, (1 => ASCII.ESC));
        end if;
    end Answer;

    --  Picks the item at Place, as the user would.
    procedure Pick
           (Menu  : in out Mnu.Menu'Class;
            Place : in     Mnu.Index) is
    begin
        Menu.Picked (MI.Menu_Item (Menu.Item (Place).Data.all));
    end Pick;

    function Is_On
           (Menu  : in Mnu.Menu'Class;
            Place : in Mnu.Index)
        return Boolean is
    begin
        return Menu.Get_Flags (Place).Value;
    end Is_On;

begin

    Menu.Set_Callback (Bar_CB'Unrestricted_Access);
    Check (Menu.Number_Of_Items = 0, "a menu starts empty");
    Open := Menu.Add ("&File/&Open", Open_CB'Unrestricted_Access, Mod_Ctrl + 'o');
    Save := Menu.Add ("File/_Save");
    Quit := Menu.Add ("File/Quit", Quit_CB'Unrestricted_Access, Mod_Ctrl + 'q');
    Copy := Menu.Add ("Edit/Copy");
    Grid := Menu.Add ("View/Grid", Flags => Flag_Toggle);
    Small := Menu.Add ("View/Small", Flags => Flag_Radio);
    Large := Menu.Add ("View/Large", Flags => Flag_Radio);
    Check (Open = 2 and Save = 3 and Quit = 4 and Copy = 7 and Grid = 10 and Large = 12
            and Menu.Number_Of_Items = 14,
        "items, their submenus and the ends, in FLTK's array");
    Check (Menu.Has_Item (File) and Menu.Has_Item (Quit + 2) and not Menu.Has_Item (Quit + 1)
            and not Menu.Has_Item (14) and not Menu.Has_Item (15),
        "titles are items, the ends aren't");
    Check (Menu.Get_Label (File) = "&File" and Menu.Get_Label (Open) = "&Open"
            and Menu.Get_Label (Save) = "Save",
        "Get_Label, without the path or a leading _");
    Check (Menu.Get_Flags (File).Submenu and Menu.Get_Flags (Save).Divider,
        "a title is a submenu; _ is a divider");
    Check (Menu.Find_Index ("&File/&Open") = Open and Menu.Find_Index ("File/Open") = Mnu.No_Index
            and Menu.Find_Index ("View/Large") = Large,
        "Find_Index takes the path as written, with &");
    Check (Menu.Item_Pathname (MI.Menu_Item (Menu.Item (Open).Data.all)) = "&File/&Open",
        "Item_Pathname");
    N := Menu.Add ("File/Quit", Quit_CB'Unrestricted_Access, Mod_Ctrl + 'x');
    Check (N = Quit and Menu.Number_Of_Items = 14
            and Menu.Item (Quit).Get_Shortcut = Mod_Ctrl + 'x',
        "adding a path that is there changes that item");
    Check (Menu.Chosen_Index = Mnu.No_Index, "no item is chosen to start with");

    --  Picking.
    Pick (Menu, Open);
    Check (Opened = 1 and Last = Menu'Address and Menu.Chosen_Index = Open,
        "Picked calls the item's callback with the menu");
    Pick (Menu, Copy);
    Check (Bar_Calls = 1 and Opened = 1 and Menu.Chosen_Index = Copy,
        "an item without one calls the menu's");
    Ok := Prb.Shortcut (Window, Press ('o'), Mod_Ctrl, "o");
    Check (Ok and Opened = 2, "an item's shortcut picks it");
    Ok := Prb.Shortcut (Window, Press ('x'), Mod_Ctrl, "x");
    Check (Ok and Quitted = 1, "a shortcut changed by Add");
    Pick (Menu, Grid);
    Check (Is_On (Menu, Grid) and Menu.Item (Grid).Get_State,
        "picking a toggle item turns it on");
    Menu.Item (Grid).Set_Label_Kind (Shadow_Label);
    Menu.Item (Grid).Set_Label_Font (Courier);
    Menu.Item (Grid).Set_Label_Size (20);
    Menu.Item (Grid).Set_Label_Color (Red_Color);
    Check (Menu.Item (Grid).Get_Label_Kind = Shadow_Label
            and Menu.Item (Grid).Get_Label_Font = Courier
            and Menu.Item (Grid).Get_Label_Size = 20
            and Menu.Item (Grid).Get_Label_Color = Red_Color,
        "an item's look reads back");
    FLTK.Static.Set_Menu_Line_Spacing (7);
    Check (FLTK.Static.Get_Menu_Line_Spacing = 7, "Menu_Line_Spacing reads back");
    FLTK.Static.Set_Menu_Line_Spacing (4);
    Check (FLTK.Draw.Shortcut_Label (Mod_Ctrl + 's') = "Ctrl+S", "Shortcut_Label");
    Pick (Menu, Grid);
    Check (not Is_On (Menu, Grid), "and off");
    Pick (Menu, Large);
    Check (Is_On (Menu, Large) and not Is_On (Menu, Small), "picking a radio item turns it on");
    Pick (Menu, Small);
    Check (Is_On (Menu, Small) and not Is_On (Menu, Large), "and the others of its group off");
    Menu.Set_Only (MI.Menu_Item (Menu.Item (Large).Data.all));
    Check (Is_On (Menu, Large) and not Is_On (Menu, Small) and Bar_Calls = 5,
        "Set_Only, without calling back");

    --  Changing items.
    Menu.Set_Label (Save, "Save/As");
    Check (Menu.Get_Label (Save) = "Save/As" and Menu.Number_Of_Items = 14,
        "Set_Label takes a slash as it is");
    Menu.Set_Flags (File, Flag_Inactive);
    Check (Menu.Get_Flags (File) = Flag_Inactive + Flag_Submenu, "Set_Flags keeps Submenu");
    Menu.Set_Flags (Open, Flag_Submenu);
    Check (Menu.Get_Flags (Open) = Flag_Normal and Menu.Number_Of_Items = 14
            and Menu.Find_Index ("Edit/Copy") = Copy,
        "and can't set it, which would change how FLTK reads the items (bug 106)");
    Menu.Set_Flags (File, Flag_Normal);
    Menu.Item (File).Set_Flags (Flag_Normal);
    Menu.Item (Open).Set_Flags (Flag_Submenu + Flag_Inactive);
    Check (Menu.Get_Flags (File) = Flag_Submenu and Menu.Get_Flags (Open) = Flag_Inactive,
        "so does an item's Set_Flags, in a menu");
    Menu.Item (Open).Set_Flags (Flag_Normal);
    declare
        Free : MI.Menu_Item := MI.Forge.Create ("free");
    begin
        Free.Set_Flags (Flag_Submenu);
        Check (Free.Get_Flags.Submenu, "but an item in no menu yet sets it");
    end;
    Menu.Set_Shortcut (Save, Mod_Ctrl + Mod_Shift + 's');
    Check (Menu.Item (Save).Get_Shortcut = Mod_Ctrl + Mod_Shift + 's', "Set_Shortcut");
    Check (Menu.Item (Open).Get_Callback = Open_CB'Unrestricted_Access
            and Menu.Item (Save).Get_Callback = null,
        "an item's Get_Callback");
    Menu.Item (Save).Set_Callback (Quit_CB'Unrestricted_Access);
    Pick (Menu, Save);
    Check (Quitted = 2, "Set_Callback");
    Menu.Item (Save).Set_Callback (null);
    Pick (Menu, Save);
    Check (Quitted = 2 and Bar_Calls = 6, "and to none");

    --  Removing.
    Menu.Clear_Submenu (File);
    Check (Menu.Number_Of_Items = 11 and Menu.Get_Label (File) = "&File"
            and Menu.Find_Index ("&File/&Open") = Mnu.No_Index
            and Menu.Chosen_Index = Mnu.No_Index,
        "Clear_Submenu keeps the title, and the value if it isn't one of them");
    Large := Menu.Find_Index ("View/Large");
    Pick (Menu, Large);
    Menu.Remove (File);
    Check (Large = 9 and Menu.Number_Of_Items = 9 and Menu.Chosen_Index = 7
            and Menu.Get_Label (7) = "Large",
        "Remove of a submenu's title removes it all; the value follows its item");
    Danger := Menu.Add ("Danger", Clear_CB'Unrestricted_Access);
    Pick (Menu, Danger);
    Check (Cleared = 1 and Menu.Number_Of_Items = 0 and Menu.Chosen_Index = Mnu.No_Index,
        "a menu cleared in its own callback");

    --  A choice.
    Choice.Add ("A");
    Choice.Add ("B");
    Choice.Add ("C");
    Choice.Clear_Damage;
    Check (Choice.Set_Chosen (3) and Choice.Chosen_Index = 3 and Choice.Is_Damaged,
        "a choice's Set_Chosen chooses, and redraws it");
    Check (not Choice.Set_Chosen (3), "False if it was chosen");
    I := Choice.Insert (1, "Z");
    Check (I = 1 and Choice.Chosen_Index = 4 and Choice.Get_Label (4) = "C",
        "inserting before the chosen item keeps it");
    Choice.Remove (1);
    Check (Choice.Chosen_Index = 3, "so does removing");
    Choice.Remove (3);
    Check (Choice.Chosen_Index = Mnu.No_Index, "removing it leaves none");
    Check (Choice.Set_Chosen (2), "choosing again");
    Choice.Clear_Chosen;
    Check (Choice.Chosen_Index = Mnu.No_Index, "Clear_Chosen");
    Choice.Set_Text_Size (20);
    Choice.Set_Text_Color (Red_Color);
    Choice.Set_Down_Box (Flat_Box);
    Check (Choice.Get_Text_Size = 20 and Choice.Get_Text_Color = Red_Color
            and Choice.Get_Down_Box = Flat_Box,
        "the items' look");

    --  A menu button, popped up.
    Button.Add ("One", Open_CB'Unrestricted_Access);
    Button.Add ("Two");
    Check (Button.Get_Popup_Kind = MBt.No_Popup, "a menu button is a button to start with");
    if Prb.On_Wayland then
        Skip ("Wayland closes a pop-up menu of a window no user clicked (pofltk 29)");
    else
        Window.Show;
        Window.Wait_For_Expose;
        Pick_Popup := True;
        FLTK.Static.Add_Timeout (0.2, Answer'Unrestricted_Access);
        I := Button.Popup;
        Check (I = 1 and Opened = 3 and Button.Chosen_Index = 1,
            "Popup returns the item picked, after its callback");
        Pick_Popup := False;
        FLTK.Static.Add_Timeout (0.2, Answer'Unrestricted_Access);
        Check (Button.Popup = Mnu.No_Index and Opened = 3, "or No_Index, closed");

        --  A Menu's Popup, unlike a Menu_Button's, only returns the item
        --  picked:  as in FLTK, it neither calls the item's callback nor
        --  changes a toggle.  Picked does both (pofltk 150).
        Toggler.Add ("Toggle", Open_CB'Unrestricted_Access, Flags => Flag_Toggle);
        Pick_Popup := True;
        FLTK.Static.Add_Timeout (0.2, Answer'Unrestricted_Access);
        I := Mnu.Menu (Toggler).Popup (60, 160);
        Check (I = 1 and Opened = 3 and not Is_On (Toggler, 1),
            "Menu Popup returns the item, without its callback or toggling it");
        Pick (Toggler, I);
        Check (Opened = 4 and Is_On (Toggler, 1), "Picked then does both");
        Window.Hide;
    end if;

    --  A system menu bar, here a menu bar, through its own type's calls.
    declare
        Sys : SMB.System_Menu_Bar := SMB.Forge.Create (0, 0, 100, 25);
    begin
        I := Sys.Add ("File/Open", Open_CB'Unrestricted_Access, Mod_Ctrl + 'o');
        N := Sys.Add ("File/Quit", Quit_CB'Unrestricted_Access);
        Check (Sys.Find_Index ("File/Quit") = N, "a system menu bar adds items");
        I := Sys.Insert (I, "New");
        Check (Sys.Get_Label (I) = "New" and Sys.Find_Index ("File/Quit") = N + 1,
            "inserts them");
        Sys.Set_Label (I, "Fresh");
        Check (Sys.Get_Label (I) = "Fresh", "relabels them");
        Sys.Set_Flags (I, Flag_Inactive);
        Check (Sys.Get_Flags (I) = Flag_Inactive, "sets their flags");
        Sys.Set_Shortcut (I, Mod_Ctrl + 'f');
        Check (Sys.Item (I).Get_Shortcut = Mod_Ctrl + 'f', "their shortcuts");
        I := Sys.Add ("Size/Small", Flags => Flag_Radio + Flag_Value);
        N := Sys.Add ("Size/Large", Flags => Flag_Radio);
        Sys.Set_Only (MI.Menu_Item (Sys.Item (N).Data.all));
        Check (Is_On (Sys, N) and not Is_On (Sys, I), "their radio items");
        Sys.Remove (N);
        Check (Sys.Find_Index ("Size/Large") = Mnu.No_Index, "removes them");
        Sys.Clear_Submenu (Sys.Find_Index ("Size"));
        Check (Sys.Find_Index ("Size/Small") = Mnu.No_Index, "clears a submenu");
        Opened := 0;
        Pick (Sys, Sys.Find_Index ("File/Open"));
        Check (Opened = 1, "and an item picked runs its callback");
        SMB.Set_About_Callback (About_CB'Unrestricted_Access);
        SMB.Set_Window_Menu_Style (SMB.Tabbing_Mode_None);
        SMB.Create_Window_Menu;
        Check (SMB.Get_Window_Menu_Style = SMB.No_Window_Menu and Abouts = 0,
            "only macOS has a Window menu");
        SMB.Set_About_Callback (null);
        Sys.Clear;
        Check (Sys.Number_Of_Items = 0, "and Clear");
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Menu;




