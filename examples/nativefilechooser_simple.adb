

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/nativefilechooser-simple.cxx: a window with
--  a right-click popup menu whose "Open File Chooser.." item shows a
--  reusable Native_File_Chooser and reports the chosen file.
--
--  The C++ original gives both menu items one callback and tells them
--  apart with a user-data string ("open"/"quit") and strcmp. Ada
--  callbacks are closures, so here each item simply gets its own
--  callback instead.


with

    FLTK.Asks,
    FLTK.Native_File_Choosers,
    FLTK.Static,
    FLTK.Widgets,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Buttons,
    GNAT.OS_Lib;


function Nativefilechooser_Simple
    return Integer
is


    package AK  renames FLTK.Asks;
    package NFC renames FLTK.Native_File_Choosers;
    package Stc renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;
    package MB  renames FLTK.Widgets.Menus.Menu_Buttons;


    type Chooser_Access is access NFC.Native_File_Chooser;


    G_Win : Win.Window := Win.Forge.Create (640, 480, "Test Native File Chooser");

    G_Menu : MB.Menu_Button := MB.Forge.Create (G_Win, 0, 20, 640, 480, "Popup Menu");

    G_Chooser : Chooser_Access := null;


    procedure Quit_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        GNAT.OS_Lib.OS_Exit (0);
    end Quit_CB;


    procedure Open_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        if G_Chooser = null then
            --  Create an instance of file chooser we can reuse..
            G_Chooser := new NFC.Native_File_Chooser'(NFC.Forge.Create);
            G_Chooser.Set_Directory (".");    --  directory to start browsing with
            G_Chooser.Set_Preset_File ("nativefilechooser-simple.cxx");  --  file to start with
            G_Chooser.Set_Filter ("C++" & ASCII.HT & "*.{cxx,cpp,h,H}" & ASCII.LF);
            G_Chooser.Set_Kind (NFC.Browse_File);  --  only picks files that exist
            --  custom title for chooser window
            G_Chooser.Set_Title ("Pick a file please..");
        end if;

        --  Show the chooser
        --    This blocks while chooser is open.
        case G_Chooser.Show is
            when NFC.Error     => null;
            when NFC.Cancelled => null;
            when NFC.Picked    =>
                G_Chooser.Set_Preset_File (G_Chooser.Get_Filename);
                AK.Message_Box ("You chose: " & G_Chooser.Get_Filename);
        end case;
    end Open_CB;


begin


    Stc.Set_Scheme ("gtk+");

    G_Win.Set_Tooltip ("Use right-click for popup menu..");

    --  Setup right-click menu for window..
    G_Menu.Set_Popup_Kind (MB.Popup3);
    G_Menu.Add ("Open File Chooser..", Open_CB'Unrestricted_Access);
    G_Menu.Add ("Quit",                Quit_CB'Unrestricted_Access);

    G_Win.Show_With_Args;

    return FLTK.Run;


end Nativefilechooser_Simple;


