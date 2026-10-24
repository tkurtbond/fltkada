

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/nativefilechooser-simple-app.cxx: the
--  common File/Open, File/Save and File/Save As menu operations, built
--  on a Native_File_Chooser.
--
--  The C++ original wraps the window, menu, box and chooser in an
--  Application subclass of Fl_Window whose static callbacks receive
--  "this" as user data. Here they are plain objects in the main
--  program's declarative part and the callbacks are nested procedures
--  that see them directly, which is the same thing in Ada's idiom.


with

    Ada.Environment_Variables,
    Ada.Directories,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Native_File_Choosers,
    FLTK.Static,
    FLTK.Widgets,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Bars,
    GNAT.OS_Lib;

use type

    FLTK.Alignment,
    FLTK.Modifier;


function Nativefilechooser_Simple_App
    return Integer
is


    package Env renames Ada.Environment_Variables;
    package Dir renames Ada.Directories;
    package TIO renames Ada.Text_IO;

    package AK  renames FLTK.Asks;
    package NFC renames FLTK.Native_File_Choosers;
    package Stc renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package BX  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;
    package MB  renames FLTK.Widgets.Menus.Menu_Bars;


    App : Win.Window := Win.Forge.Create (400, 200, "Native File Chooser Example");

    Menu : MB.Menu_Bar := MB.Forge.Create (App, 0, 0, 400, 25);

    The_Box : BX.Box := BX.Forge.Create
        (App, 20, 25 + 20, App.Get_W - 40, App.Get_H - 40 - 25);

    FC : NFC.Native_File_Chooser := NFC.Forge.Create;


    --  Does file exist?
    function Exist
           (Filename : in String)
        return Boolean is
    begin
        return Dir.Exists (Filename);
    end Exist;


    --  'Open' the file
    procedure Open
           (Filename : in String) is
    begin
        TIO.Put_Line ("Open '" & Filename & "'");
    end Open;


    --  'Save' the file
    --    Create the file if it doesn't exist
    --    and save something in it.
    procedure Save
           (Filename : in String) is
    begin
        TIO.Put_Line ("Saving '" & Filename & "'");
        if not Exist (Filename) then
            declare
                Output : TIO.File_Type;
            begin
                TIO.Create (Output, TIO.Out_File, Filename);  --  create file if it doesn't exist
                --  A real app would do something useful here.
                TIO.Put_Line (Output, "Hello world.");
                TIO.Close (Output);
            exception
                when TIO.Name_Error | TIO.Use_Error =>
                    AK.Message_Box ("Error: " & Filename & ": " & GNAT.OS_Lib.Errno_Message);
            end;
        else
            --  A real app would do something useful here.
            null;
        end if;
    end Save;


    --  Handle an 'Open' request from the menu
    procedure Open_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        FC.Set_Title ("Open");
        FC.Set_Kind (NFC.Browse_File);          --  only picks files that exist
        case FC.Show is
            when NFC.Error     => null;
            when NFC.Cancelled => null;
            when NFC.Picked    =>
                FC.Set_Preset_File (FC.Get_Filename);
                Open (FC.Get_Filename);
        end case;
    end Open_CB;


    --  Handle a 'Save as' request from the menu
    procedure Saveas_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        FC.Set_Title ("Save As");
        FC.Set_Kind (NFC.Browse_Save_File);     --  need this if file doesn't exist yet
        case FC.Show is
            when NFC.Error     => null;
            when NFC.Cancelled => null;
            when NFC.Picked    =>
                FC.Set_Preset_File (FC.Get_Filename);
                Save (FC.Get_Filename);
        end case;
    end Saveas_CB;


    --  Handle a 'Save' request from the menu
    procedure Save_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        if FC.Get_Filename'Length = 0 then
            Saveas_CB (Item);
        else
            Save (FC.Get_Filename);
        end if;
    end Save_CB;


    procedure Quit_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        GNAT.OS_Lib.OS_Exit (0);
    end Quit_CB;


    --  Return an 'untitled' default pathname
    function Untitled_Default
        return String
    is
        function Home
            return String is
        begin
            if Env.Exists ("HOME") then                 --  unix
                return Env.Value ("HOME");
            elsif Env.Exists ("HOME_PATH") then         --  windows
                return Env.Value ("HOME_PATH");
            else                                        --  other
                return ".";
            end if;
        end Home;
    begin
        return Home & "/untitled.txt";
    end Untitled_Default;


begin


    Stc.Set_Scheme ("gtk+");

    Menu.Add ("&File/&Open",    Open_CB'Unrestricted_Access,   FLTK.Mod_Command + 'o');
    Menu.Add ("&File/&Save",    Save_CB'Unrestricted_Access,   FLTK.Mod_Command + 's');
    Menu.Add ("&File/&Save As", Saveas_CB'Unrestricted_Access);
    Menu.Add ("&File/&Quit",    Quit_CB'Unrestricted_Access,   FLTK.Mod_Command + 'q');

    --  Describe the demo..
    The_Box.Set_Background_Color (45);
    The_Box.Set_Box (FLTK.Flat_Box);
    The_Box.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside + FLTK.Align_Wrap);
    The_Box.Set_Label
       ("This demo shows an example of implementing "
        & "common 'File' menu operations like:" & ASCII.LF
        & "    File/Open, File/Save, File/Save As" & ASCII.LF
        & "..using the Fl_Native_File_Chooser widget." & ASCII.LF & ASCII.LF
        & "Note 'Save' and 'Save As' really *does* create files! "
        & "This is to show how behavior differs when "
        & "files exist vs. do not.");
    The_Box.Set_Label_Size (12);

    --  Initialize the file chooser
    FC.Set_Filter ("Text" & ASCII.HT & "*.txt" & ASCII.LF);
    FC.Set_Preset_File (Untitled_Default);

    App.Show_With_Args;

    return FLTK.Run;


end Nativefilechooser_Simple_App;


