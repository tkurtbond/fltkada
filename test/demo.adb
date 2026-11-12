--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/demo.cxx:  the launcher of the other programs, a window of
--  up to nine buttons, each a program or a menu of more, read from a menu
--  file in FLTK's form (test/demo.menu, which names FLTKAda's programs as
--  FLTK's demo.menu names FLTK's).  A click on the panel outside the
--  buttons goes back a menu, and the right button's menu shows or hides a
--  terminal listing what was run.  Guided by pofltk's examples/Demo.Mod.
--
--  A program is run from the directory of demo itself, bin/, as FLTK's
--  are, in the background (sh's "&"), with the menu file's directory as
--  the working directory, where the files the menu names are.  FLTK's demo
--  runs fluid and fltk-options from FLTK's build tree; this one runs them
--  from PATH, where FLTK installs them, and so doesn't list their paths in
--  the terminal, or set FLTK_DOCDIR for fluid.  The menu file is the
--  command line's argument, or demo.menu beside the program, or else
--  test/demo.menu beside the program's bin/.  The Exit button hides the
--  window, so that Run returns, where FLTK's calls exit (0).


with

    Ada.Command_Line,
    Ada.Directories,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Filenames,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices.Schemes,
    FLTK.Widgets.Menus.Menu_Buttons,
    Interfaces.C,
    System;

use type

    FLTK.Color,
    Interfaces.C.int,
    System.Address;


function Demo
    return Integer
is


    package ACom renames Ada.Command_Line;
    package UStr renames Ada.Strings.Unbounded;
    package BX   renames FLTK.Widgets.Boxes;
    package BU   renames FLTK.Widgets.Buttons;
    package GR   renames FLTK.Widgets.Groups;
    package TM   renames FLTK.Widgets.Groups.Terminals;
    package DW   renames FLTK.Widgets.Groups.Windows.Double;
    package SC   renames FLTK.Widgets.Menus.Choices.Schemes;
    package MB   renames FLTK.Widgets.Menus.Menu_Buttons;

    use type UStr.Unbounded_String;


    Form_W : constant := 350;
    Form_H : constant := 440;
    TTY_W  : constant := 780;
    TTY_H  : constant := 200;


    --  The form  --

    Form : DW.Double_Window := DW.Forge.Create (Form_W, Form_H, "FLTK Demonstration");

    --  The demo's group
    Demo_Grp : GR.Group := GR.Forge.Create (Form, 0, 0, Form_W, Form_H - 1);

    --  The title
    Title : BX.Box := BX.Forge.Create
        (Demo_Grp, FLTK.Engraved_Box, 10, 15, 330, 40, "FLTK Demonstration");
    Panel : BX.Box := BX.Forge.Create (Demo_Grp, FLTK.Engraved_Box, 10, 65, 330, 330);

    Scheme_Choice : SC.Scheme_Choice :=
        SC.Forge.Create (Demo_Grp, 90, 405, 100, 25, "Scheme:");

    Exit_Button : BU.Button := BU.Forge.Create (Demo_Grp, 280, 405, 60, 25, "Exit");

    --  The panel behind the buttons:  a click goes back a menu
    Back : BU.Button := BU.Forge.Create (Demo_Grp, 10, 15, 330, 380);

    type Button_Index is range 0 .. 8;

    But : array (Button_Index) of BU.Button :=
       (BU.Forge.Create (Demo_Grp,  30,  85, 90, 90),
        BU.Forge.Create (Demo_Grp, 130,  85, 90, 90),
        BU.Forge.Create (Demo_Grp, 230,  85, 90, 90),
        BU.Forge.Create (Demo_Grp,  30, 185, 90, 90),
        BU.Forge.Create (Demo_Grp, 130, 185, 90, 90),
        BU.Forge.Create (Demo_Grp, 230, 185, 90, 90),
        BU.Forge.Create (Demo_Grp,  30, 285, 90, 90),
        BU.Forge.Create (Demo_Grp, 130, 285, 90, 90),
        BU.Forge.Create (Demo_Grp, 230, 285, 90, 90));

    --  The right button's menu, over the whole group
    Popup : MB.Menu_Button := MB.Forge.Create (Demo_Grp, 0, 0, Form_W, Form_H);

    --  So that the demo isn't resized with the window when the terminal shows
    Keeper : constant BX.Box := BX.Forge.Create (Demo_Grp, FLTK.No_Box, Form_W - 1, 0, 1, Form_H);

    --  The debug terminal, in the window, not the demo's group
    TTY : TM.Terminal := TM.Forge.Create (Form, 10, Form_H - 1, Form_W - 20, 1);


    --  Writes "name       = value" and a line feed to the terminal.
    procedure Debug_Var
           (Name, Value : in String)
    is
        Padded : String (1 .. Integer'Max (10, Name'Length)) := (others => ' ');
    begin
        Padded (1 .. Name'Length) := Name;
        TTY.Print (Padded & " = " & Value & ASCII.LF);
    end Debug_Var;


    --  Cuts Path at its last "/", as FLTK's fix_path does.
    function Strip_Name
           (Path : in String)
        return String is
    begin
        for I in reverse Path'Range loop
            if Path (I) = '/' then
                return Path (Path'First .. I - 1);
            end if;
        end loop;
        return Path;
    end Strip_Name;




    --  Maintaining and building up the menus  --

    Max_Menu : constant := 32;

    type Name_Array is array (Button_Index) of UStr.Unbounded_String;

    type Menu is record
        Name     : UStr.Unbounded_String;
        Numb     : Natural := 0;
        IName    : Name_Array;
        ICommand : Name_Array;
    end record;

    Menus   : array (0 .. Max_Menu - 1) of Menu;
    Mennumb : Natural := 0;


    --  The number of the menu named Name, or -1.
    function Find_Menu
           (Name : in String)
        return Integer is
    begin
        for I in 0 .. Mennumb - 1 loop
            if Menus (I).Name = Name then
                return I;
            end if;
        end loop;
        return -1;
    end Find_Menu;


    procedure Create_Menu
           (Name : in String) is
    begin
        if Mennumb = Max_Menu - 1 then
            return;
        end if;
        Menus (Mennumb) := (Name => UStr.To_Unbounded_String (Name), others => <>);
        Mennumb := Mennumb + 1;
    end Create_Menu;


    procedure Add_To_Menu
           (Men, Item, Comm : in String)
    is
        N : Integer := Find_Menu (Men);
    begin
        if N < 0 then
            Create_Menu (Men);
            N := Find_Menu (Men);
        end if;
        --  FLTK's demo drops the 32nd menu's items, and each past the 9th
        if N < 0 or else Menus (N).Numb = 9 then
            return;
        end if;
        Menus (N).IName (Button_Index (Menus (N).Numb)) := UStr.To_Unbounded_String (Item);
        Menus (N).ICommand (Button_Index (Menus (N).Numb)) := UStr.To_Unbounded_String (Comm);
        Menus (N).Numb := Menus (N).Numb + 1;
    end Add_To_Menu;




    --  Button to item conversion and back  --

    type Table is array (0 .. 8, 0 .. 8) of Integer;

    B2N : constant Table :=
       ((-1, -1, -1, -1,  0, -1, -1, -1, -1),
        (-1, -1, -1,  0, -1,  1, -1, -1, -1),
        (0,  -1, -1, -1,  1, -1, -1, -1,  2),
        (0,  -1,  1, -1, -1, -1,  2, -1,  3),
        (0,  -1,  1, -1,  2, -1,  3, -1,  4),
        (0,  -1,  1,  2, -1,  3,  4, -1,  5),
        (0,  -1,  1,  2,  3,  4,  5, -1,  6),
        (0,   1,  2,  3, -1,  4,  5,  6,  7),
        (0,   1,  2,  3,  4,  5,  6,  7,  8));

    N2B : constant Table :=
       ((4,  -1, -1, -1, -1, -1, -1, -1, -1),
        (3,   5, -1, -1, -1, -1, -1, -1, -1),
        (0,   4,  8, -1, -1, -1, -1, -1, -1),
        (0,   2,  6,  8, -1, -1, -1, -1, -1),
        (0,   2,  4,  6,  8, -1, -1, -1, -1),
        (0,   2,  3,  5,  6,  8, -1, -1, -1),
        (0,   2,  3,  4,  5,  6,  8, -1, -1),
        (0,   1,  2,  3,  5,  6,  7,  8, -1),
        (0,   1,  2,  3,  4,  5,  6,  7,  8));




    --  Pushing and popping menus  --

    Stack  : array (0 .. 63) of UStr.Unbounded_String;
    Stsize : Natural := 0;


    --  Makes the menu named Name visible.
    procedure Push_Menu
           (Name : in String)
    is
        Men : constant Integer := Find_Menu (Name);
        N   : Natural;
        BN  : Button_Index;
    begin
        if Men < 0 then
            return;
        end if;
        N := Menus (Men).Numb;
        for B of But loop
            B.Hide;
        end loop;
        for I in 0 .. N - 1 loop
            BN := Button_Index (N2B (N - 1, I));
            But (BN).Show;
            But (BN).Set_Label (UStr.To_String (Menus (Men).IName (Button_Index (I))));
            declare
                Command : constant String :=
                    UStr.To_String (Menus (Men).ICommand (Button_Index (I)));
            begin
                if Command'Length > 0 and then Command (Command'First) = '@' then
                    But (BN).Set_Tooltip ("");
                else
                    But (BN).Set_Tooltip (Command);
                end if;
            end;
        end loop;
        Stack (Stsize) := UStr.To_Unbounded_String (Name);
        Stsize := Stsize + 1;
    end Push_Menu;


    procedure Pop_Menu is
    begin
        if Stsize <= 1 then
            return;
        end if;
        Stsize := Stsize - 2;
        Push_Menu (UStr.To_String (Stack (Stsize)));
    end Pop_Menu;




    --  The callbacks  --

    --  Shows or hides the terminal:  the window grows to show it, and can
    --  then be resized; it shrinks back to its fixed size without.
    procedure Show_TTY
           (Show : in Boolean) is
    begin
        if Show then
            TTY.Show;
            Form.Set_Size_Range (Form_W, Form_H + TTY_H / 2, 0, 0);
            Form.Resize (TTY_W + 20, Form_H + TTY_H + 10);
            TTY.Resize (TTY_W, TTY_H);
        else
            TTY.Hide;
            Form.Set_Size_Range (Form_W, Form_H, Form_W, Form_H);
            Form.Resize (Form_W, Form_H);
            TTY.Resize (10, Form_H - 1, Form_W - 20, 1);
        end if;
        Form.Reset_Sizes;
        if Exit_Button.Take_Focus then
            null;
        end if;
    end Show_TTY;


    procedure Show_TTY_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Show_TTY (True);
    end Show_TTY_CB;


    procedure Hide_TTY_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Show_TTY (False);
    end Hide_TTY_CB;


    procedure Do_Back
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Pop_Menu;
    end Do_Back;


    procedure Do_Exit
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Form.Hide;
    end Do_Exit;


    function System
           (Command : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, System, "system");


    App_Path  : UStr.Unbounded_String;
    Data_Path : UStr.Unbounded_String;
    Menu_File : UStr.Unbounded_String;


    --  Runs a button's program, or shows its menu.
    procedure Do_But
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Men  : constant Integer := Find_Menu (UStr.To_String (Stack (Stsize - 1)));
        N    : constant Natural := Menus (Men).Numb;
        Arg  : Button_Index := 0;
        BN   : Button_Index;
    begin
        while BU.Button (Item)'Address /= But (Arg)'Address loop
            Arg := Arg + 1;
        end loop;
        BN := Button_Index (B2N (N - 1, Integer (Arg)));
        declare
            Line  : constant String := UStr.To_String (Menus (Men).ICommand (BN));
            First : Positive := Line'First;
            Space : Natural;
        begin
            --  A menu?
            if Line'Length > 0 and then Line (Line'First) = '@' then
                Push_Menu (Line);
                return;
            end if;
            --  Not a menu:  run the program.  Skip the leading spaces, and
            --  separate the command from its parameters.
            while First <= Line'Last and then Line (First) = ' ' loop
                First := First + 1;
            end loop;
            Space := First;
            while Space <= Line'Last and then Line (Space) /= ' ' loop
                Space := Space + 1;
            end loop;
            declare
                Cmd    : constant String := Line (First .. Space - 1);
                Params : constant String :=
                    (if Space < Line'Last then Line (Space + 1 .. Line'Last) else "");
                --  FLTK's tools from PATH, as FLTK compares:  "fluid", "fltk-"
                Path    : constant String :=
                   (if Cmd'Length >= 5 and then
                       (Cmd (Cmd'First .. Cmd'First + 4) = "fluid" or
                        Cmd (Cmd'First .. Cmd'First + 4) = "fltk-")
                    then ""
                    else UStr.To_String (App_Path) & "/");
                Command : constant String :=
                    Path & Cmd & (if Params = "" then "" else " " & Params) & " &";
            begin
                Debug_Var ("Command", Command);
                if System (Interfaces.C.To_C (Command)) = -1 then
                    FLTK.Asks.Alert ("Could not start program" & ASCII.LF & "'" & Command & "'");
                end if;
            end;
        end;
    end Do_But;




    --  Loads the menu file.  Returns whether successful.
    function Load_The_Menu
           (Name : in String)
        return Boolean
    is
        File : Ada.Text_IO.File_Type;
    begin
        begin
            Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Name);
        exception
        when Ada.Text_IO.Name_Error | Ada.Text_IO.Use_Error =>
            return False;
        end;
        while not Ada.Text_IO.End_Of_File (File) loop
            declare
                Raw   : constant String := Ada.Text_IO.Get_Line (File);
                Line  : String (1 .. Raw'Length);
                Last  : Natural := 0;
                I     : Positive := 1;
                MName, IName, CName : UStr.Unbounded_String;
            begin
                --  remove all carriage returns
                for C of Raw loop
                    if C /= ASCII.CR then
                        Last := Last + 1;
                        Line (Last) := C;
                    end if;
                end loop;
                while I <= Last and then (Line (I) = ' ' or Line (I) = ASCII.HT) loop
                    I := I + 1;
                end loop;
                if I <= Last and then Line (I) /= '#' then
                    while I <= Last and then Line (I) /= ':' loop
                        UStr.Append (MName, Line (I));
                        I := I + 1;
                    end loop;
                    I := I + 1;
                    while I <= Last and then Line (I) /= ':' loop
                        if Line (I) = '\' and I < Last then
                            I := I + 1;
                            UStr.Append (IName, (if Line (I) = 'n' then ASCII.LF else Line (I)));
                        else
                            UStr.Append (IName, Line (I));
                        end if;
                        I := I + 1;
                    end loop;
                    I := I + 1;
                    while I <= Last and then Line (I) /= ':' loop
                        UStr.Append (CName, Line (I));
                        I := I + 1;
                    end loop;
                    Add_To_Menu
                       (UStr.To_String (MName), UStr.To_String (IName), UStr.To_String (CName));
                end if;
            end;
        end loop;
        Ada.Text_IO.Close (File);
        return True;
    end Load_The_Menu;


    Count    : Natural := 0;
    Bad_Args : Boolean := False;

begin

    --  The form's widgets
    Title.Set_Background_Color (FLTK.Background_Color - 4);
    Title.Set_Label_Size (24);
    Title.Set_Label_Font (FLTK.Helvetica_Bold);
    Title.Set_Label_Kind (FLTK.Engraved_Label);

    Panel.Set_Background_Color (FLTK.Background_Color - 8);

    Scheme_Choice.Set_Label_Font (FLTK.Helvetica_Bold);

    Exit_Button.Set_Callback (Do_Exit'Unrestricted_Access);
    if Exit_Button.Take_Focus then
        null;
    end if;

    Back.Set_Kind (BU.Hidden_Kind);
    Back.Set_Callback (Do_Back'Unrestricted_Access);
    Back.Set_Tooltip ("Use right mouse button to show/hide debug terminal");

    for B of But loop
        B.Set_Alignment (FLTK.Align_Wrap);
        B.Set_Callback (Do_But'Unrestricted_Access);
    end loop;

    Popup.Set_Box (FLTK.No_Box);
    Popup.Set_Popup_Kind (MB.Popup3);
    Popup.Add ("Show debug terminal", Show_TTY_CB'Unrestricted_Access);
    Popup.Add ("Hide debug terminal", Hide_TTY_CB'Unrestricted_Access);

    Demo_Grp.Set_Resizable (Keeper);

    TTY.Set_History_Lines (50);
    TTY.Set_Display_Rows (2);
    TTY.Set_Display_Columns (100);
    TTY.Set_ANSI (True);
    TTY.Hide;
    TTY.Set_Text_Size (12);

    Form.Set_Resizable (TTY);

    --  The paths:  the programs are beside this one, and the menu file is
    --  <data path>/<this program's name>.menu
    App_Path  := UStr.To_Unbounded_String
        (Strip_Name (FLTK.Filenames.Absolute (ACom.Command_Name)));
    Data_Path := App_Path;
    Menu_File := UStr.To_Unbounded_String (FLTK.Filenames.Set_Extension
        (UStr.To_String (Data_Path) & "/" & FLTK.Filenames.Base_Name (ACom.Command_Name),
         ".menu"));
    --  Not there:  test/ beside bin/
    if not Ada.Directories.Exists (UStr.To_String (Menu_File)) then
        Data_Path := UStr.To_Unbounded_String (Strip_Name (UStr.To_String (App_Path)) & "/test");
        Menu_File := UStr.To_Unbounded_String (FLTK.Filenames.Set_Extension
            (UStr.To_String (Data_Path) & "/" & FLTK.Filenames.Base_Name (ACom.Command_Name),
             ".menu"));
    end if;

    --  The command line
    begin
        FLTK.Static.Parse_Args (Count);
    exception
    when FLTK.Static.Argument_Error =>
        Bad_Args := True;  --  an option FLTK doesn't know
    end;
    if Bad_Args or else Count < ACom.Argument_Count - 1 then
        --  Fl::fatal's default, off Windows
        Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error,
            "Usage: " & ACom.Command_Name & " <switches> <menufile>" & ASCII.LF &
            FLTK.Static.Help_Message);
        return 1;
    end if;
    if Count < ACom.Argument_Count then
        --  The menu file and the data path both
        Menu_File := UStr.To_Unbounded_String
            (FLTK.Filenames.Absolute (ACom.Argument (Count + 1)));
        Data_Path := UStr.To_Unbounded_String (Strip_Name (UStr.To_String (Menu_File)));
    end if;

    begin
        Ada.Directories.Set_Directory (UStr.To_String (Data_Path));
    exception
    when others =>
        null;  --  ignored, as FLTK's demo ignores it
    end;

    Debug_Var ("app_path", UStr.To_String (App_Path));
    Debug_Var ("data_path", UStr.To_String (Data_Path));
    Debug_Var ("menu file", UStr.To_String (Menu_File));
    Debug_Var ("cwd", Ada.Directories.Current_Directory);
    TTY.Print ((1 => ASCII.LF));

    if not Load_The_Menu (UStr.To_String (Menu_File)) then
        Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error,
            "Can't open menu file '" & UStr.To_String (Menu_File) & "'");
        return 1;
    end if;

    Push_Menu ("@main");
    Form.Show_With_Args;

    --  After Show, so that the window can be resizable (Windows and macOS)
    Form.Set_Size_Range (Form_W, Form_H, Form_W, Form_H);

    return FLTK.Run;

end Demo;
