


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/file_chooser.cxx: every way of asking a file chooser for
--  files.  file_chooser [filter]
--
--  The button by Filter shows the chooser; its callback, and the files it
--  was left with, are listed.  The filter is patterns, or names with a
--  pattern in round brackets, separated by tabs.
--
--  The chooser previews PDF and PostScript with Ghostscript, if it is
--  installed, through image handlers.  They leave .preview.ppm and
--  .preview.ps in the home directory, as FLTK's program does.
--
--  Close hides the window, so that Run returns and the program can free
--  what it made, where FLTK's program calls exit.


with

    Ada.Command_Line,
    Ada.Directories,
    Ada.Environment_Variables,
    Ada.IO_Exceptions,
    Ada.Streams.Stream_IO,
    Ada.Strings.Fixed,
    Ada.Unchecked_Deallocation,
    FLTK.File_Choosers,
    FLTK.Filenames,
    FLTK.Images.File_Icons,
    FLTK.Images.RGB.PNM,
    FLTK.Images.Shared,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Browsers.Textline.File,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Choices,
    GNAT.OS_Lib;


function File_Chooser
    return Integer
is


    package FC  renames FLTK.File_Choosers;
    package Ico renames FLTK.Images.File_Icons;
    package PNM renames FLTK.Images.RGB.PNM;
    package Shr renames FLTK.Images.Shared;
    package Wdg renames FLTK.Widgets;
    package Btn renames FLTK.Widgets.Buttons;
    package Lit renames FLTK.Widgets.Buttons.Light;
    package Grp renames FLTK.Widgets.Groups;
    package Fbr renames FLTK.Widgets.Groups.Browsers.Textline.File;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package OS  renames GNAT.OS_Lib;

    use type FC.Chooser_Kind;
    use type FLTK.Color_Component;
    use type OS.Argument_List;
    use type OS.String_Access;
    use type FLTK.Size_Type;
    use type Ico.File_Icon_Access;


    Terminal_Height : constant := 120;
    Green           : constant String := ASCII.ESC & "[32m";
    Normal          : constant String := ASCII.ESC & "[0m";

    Default_Filter : constant String :=
        "PDF Files (*.pdf)" & ASCII.HT &
        "PostScript Files (*.ps)" & ASCII.HT &
        "Image Files (*.{bmp,gif,jpg,png})" & ASCII.HT &
        "C/C++ Source Files (*.{c,C,cc,cpp,cxx})";


    type PNM_Access is access PNM.PNM_Image;
    type Group_Access is access Grp.Group;
    type Choice_Access is access Chc.Choice;
    type Check_Access is access Btn.Light.Check.Check_Button;

    procedure Free is new Ada.Unchecked_Deallocation (PNM.PNM_Image, PNM_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Grp.Group, Group_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Chc.Choice, Choice_Access);
    procedure Free is new Ada.Unchecked_Deallocation
        (Btn.Light.Check.Check_Button, Check_Access);


    --  The last image the handlers made, which stays theirs.
    Preview : PNM_Access;

    --  The extra widgets, made the first time they are chosen.
    Encodings    : Group_Access;
    Encoding     : Choice_Access;
    Version      : Check_Access;


    Chooser : FC.File_Chooser := FC.Forge.Create
        ("Fl_File_Chooser Test", "*", ".", FC.Single);

    Win : Dbl.Double_Window := Dbl.Forge.Create
        (400, 215 + Terminal_Height, "File Chooser Test");

    TTY : Trm.Terminal := Trm.Forge.Create (Win, 0, 215, 400, Terminal_Height);

    --  Limits resizing to the filter, not the button that shows the chooser.
    Filter_Group : Grp.Group := Grp.Forge.Create (Win, 0, 10, 400, 25);
    Filter       : Wdg.Inputs.Text.Text_Input := Wdg.Inputs.Text.Forge.Create
        (Filter_Group, 50, 10, 315, 25, "Filter:");
    Show         : Btn.Button := Btn.Forge.Create (Filter_Group, 365, 10, 25, 25);

    --  Keeps the light buttons from resizing.
    type Toggle is new Lit.Light_Button with record
        What : FC.Chooser_Kind;
    end record;

    Light_Group : Grp.Group := Grp.Forge.Create (Win, 0, 45, 400, 55);
    Multi_Toggle     : Toggle :=
       (Lit.Forge.Create (Light_Group, 50, 45, 80, 25, "MULTI") with What => FC.Multi);
    Create_Toggle    : Toggle :=
       (Lit.Forge.Create (Light_Group, 140, 45, 90, 25, "CREATE") with What => FC.Create);
    Directory_Toggle : Toggle :=
       (Lit.Forge.Create (Light_Group, 240, 45, 115, 25, "DIRECTORY")
        with What => FC.Directory);
    Extra            : Chc.Choice := Chc.Forge.Create
        (Light_Group, 150, 75, 150, 25, "Extra Group:");

    Files : Fbr.File_Browser := Fbr.Forge.Create (Win, 50, 105, 340, 75, "Files:");

    --  Keeps Close at the right edge, its own size.
    Close_Group : Grp.Group := Grp.Forge.Create (Win, 0, 185, 400, 25);
    Invisible   : Wdg.Boxes.Box := Wdg.Boxes.Forge.Create (Close_Group, 100, 185, 1, 1);
    Close       : Btn.Button := Btn.Forge.Create (Close_Group, 310, 185, 80, 25, "Close");




    --  Image Handlers  --

    function Starts_With
           (Header : in FLTK.Color_Component_Array;
            Text   : in String)
        return Boolean is
    begin
        if Header'Length < Text'Length then
            return False;
        end if;
        for I in Text'Range loop
            if Header (Header'First + FLTK.Size_Type (I - Text'First)) /=
                Character'Pos (Text (I))
            then
                return False;
            end if;
        end loop;
        return True;
    end Starts_With;


    function Home_File
           (Name : in String)
        return String is
    begin
        return Ada.Environment_Variables.Value ("HOME", "") & "/" & Name;
    end Home_File;


    --  The image of file Name that Ghostscript draws, with Options before
    --  the name on its command line, or null if it can't.  It is run
    --  without a shell, so names need no quoting.
    function Ghostscript
           (Name    : in String;
            Options : in OS.Argument_List)
        return access constant FLTK.Images.Image'Class
    is
        PPM     : constant String := Home_File (".preview.ppm");
        Program : OS.String_Access := OS.Locate_Exec_On_Path ("gs");
        Args    : OS.Argument_List :=
           (new String'("-r100"),
            new String'("-dFIXED"),
            new String'("-sDEVICE=ppmraw"),
            new String'("-dQUIET"),
            new String'("-dNOPAUSE"),
            new String'("-dBATCH"),
            new String'("-sstdout=%stderr"),
            new String'("-sOUTPUTFILE=" & PPM)) &
            Options & OS.Argument_List'(1 => new String'(Name));
        Success : Boolean;
        Status  : Integer;
    begin
        if Program = null then
            for Arg of Args loop
                OS.Free (Arg);
            end loop;
            return null;
        end if;
        OS.Spawn (Program.all, Args, "/dev/null", Success, Status);
        OS.Free (Program);
        for Arg of Args loop
            OS.Free (Arg);
        end loop;
        if not Success or else Status /= 0 then
            return null;
        end if;
        Free (Preview);
        Preview := new PNM.PNM_Image'(PNM.Forge.Create (PPM));
        return Preview;
    exception
    when FLTK.Images.No_Image_Error | FLTK.Images.File_Access_Error |
         FLTK.Images.Format_Error =>
        return null;
    end Ghostscript;


    function PDF_Check
           (Name   : in String;
            Header : in FLTK.Color_Component_Array)
        return access constant FLTK.Images.Image'Class is
    begin
        if not Starts_With (Header, "%PDF") then
            return null;
        end if;
        return Ghostscript
           (Name,
           (new String'("-dFirstPage=1"),
            new String'("-dLastPage=1")));
    end PDF_Check;


    --  Copies structured PostScript From to To, up to its second page.
    procedure Copy_First_Page
           (From, To : in String)
    is
        package SIO renames Ada.Streams.Stream_IO;
        type Text_Access is access String;
        procedure Free is new Ada.Unchecked_Deallocation (String, Text_Access);
        Page_Mark : constant String := "%%Page:";
        Text  : Text_Access := new String (1 .. Natural (Ada.Directories.Size (From)));
        Last  : Natural := Text'Last;
        Pages : Natural := 0;
        File  : SIO.File_Type;
    begin
        SIO.Open (File, SIO.In_File, From);
        String'Read (SIO.Stream (File), Text.all);
        SIO.Close (File);
        for I in Text'Range loop
            if (I = Text'First or else Text (I - 1) = ASCII.LF) and then
                Ada.Strings.Fixed.Head (Text (I .. Text'Last), Page_Mark'Length) = Page_Mark
            then
                Pages := Pages + 1;
                if Pages > 1 then
                    Last := I - 1;
                    exit;
                end if;
            end if;
        end loop;
        SIO.Create (File, SIO.Out_File, To);
        String'Write (SIO.Stream (File), Text (Text'First .. Last));
        SIO.Close (File);
        Free (Text);
    exception
    when others =>
        if SIO.Is_Open (File) then
            SIO.Close (File);
        end if;
        Free (Text);
        raise;
    end Copy_First_Page;


    --  PostScript has no page numbers for Ghostscript to go by, so
    --  structured PostScript is cut before its second page.
    function PS_Check
           (Name   : in String;
            Header : in FLTK.Color_Component_Array)
        return access constant FLTK.Images.Image'Class
    is
        PS : constant String := Home_File (".preview.ps");
    begin
        if not Starts_With (Header, "%!") then
            return null;
        end if;
        if Starts_With (Header, "%!PS") then
            if Name /= PS then
                Copy_First_Page (Name, PS);
            end if;
            return Ghostscript (PS, (1 .. 0 => null));
        end if;
        return Ghostscript (Name, (1 .. 0 => null));
    exception
    when Ada.IO_Exceptions.Name_Error | Ada.IO_Exceptions.Use_Error |
         Ada.IO_Exceptions.Device_Error | Ada.IO_Exceptions.End_Error =>
        return null;
    end PS_Check;




    --  Callbacks  --

    procedure Chooser_CB
           (Item : in out FC.File_Chooser'Class) is
    begin
        TTY.Print ("fc_callback" & ASCII.LF);
        TTY.Print ("    filename = """ &
           (if Item.Number_Selected > 0 then Item.Get_Selected else "(null)") &
            """" & ASCII.LF);
    end Chooser_CB;


    procedure Show_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Count : Natural;
    begin
        if Filter.Get_Value /= "" then
            Chooser.Set_Filter (Filter.Get_Value);
        end if;
        Chooser.Show;
        while Chooser.Is_Visible loop
            exit when FLTK.Wait < 0;
        end loop;
        Count := Chooser.Number_Selected;
        if Count > 0 then
            Files.Clear;
            for I in 1 .. Count loop
                declare
                    Name     : constant String := Chooser.Get_Selected (I);
                    Relative : constant String := FLTK.Filenames.Relative (Name);
                    Number   : constant String :=
                        Ada.Strings.Fixed.Trim (Integer'Image (I), Ada.Strings.Left) & "/" &
                        Ada.Strings.Fixed.Trim (Integer'Image (Count), Ada.Strings.Left);
                begin
                    TTY.Print (Number & ") " & Green & "Picked: '" & Name & "'" & ASCII.LF &
                        "     Relative: '" & Relative & "'" & Normal & ASCII.LF);
                    Ico.Add_File (Files, Relative, Ico.Find (Name, Ico.Plain_File));
                end;
            end loop;
            Files.Redraw;
        end if;
    end Show_CB;


    procedure Toggle_CB
           (Item : in out Wdg.Widget'Class)
    is
        What : constant FC.Chooser_Kind := Toggle (Item).What;
        Kind : constant FC.Chooser_Kind := Chooser.Get_Kind;
    begin
        if FC.Includes (Kind, What) then
            Chooser.Set_Kind (Kind - What);
        else
            Chooser.Set_Kind (Kind + What);
        end if;
    end Toggle_CB;


    procedure Extra_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        case Chc.Choice (Item).Chosen_Index is
        when 2 =>
            if Encodings = null then
                Encodings := new Grp.Group'(Grp.Forge.Create (0, 0, 254, 30));
                Encoding := new Chc.Choice'(Chc.Forge.Create
                    (Encodings.all, 152, 2, 100, 25, "Choose Encoding:"));
                Encoding.Add_Items ("ASCII|Koi8-r|win1251|Utf-8");
            end if;
            Chooser.Add_Extra (Encodings.all);
        when 3 =>
            if Version = null then
                Version := new Btn.Light.Check.Check_Button'(Btn.Light.Check.Forge.Create
                    (5, 0, 200, 25, "Save binary 1.0 version"));
            end if;
            Chooser.Add_Extra (Version.all);
        when others =>
            Chooser.Remove_Extra;
        end case;
    end Extra_CB;


    procedure Close_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Win.Hide;
    end Close_CB;


    Argument : Positive := 1;
    Used     : Natural;
    Icon     : Ico.File_Icon_Access;


begin


    Ico.Load_System_Icons;
    Chooser.Set_Callback (Chooser_CB'Unrestricted_Access);

    Shr.Add_Handler (PDF_Check'Unrestricted_Access);
    Shr.Add_Handler (PS_Check'Unrestricted_Access);

    TTY.Set_ANSI (True);
    TTY.Set_Display_Columns (100);  --  wider than the window, for long names

    --  FLTK's options first; the first word that isn't one is the filter.
    while Argument <= Ada.Command_Line.Argument_Count loop
        Used := FLTK.Static.Parse_Arg (Argument);
        if Used = 0 then
            Filter.Set_Value (Ada.Command_Line.Argument (Argument));
            exit;
        end if;
        Argument := Argument + Used;
    end loop;
    if Filter.Get_Value = "" then
        Filter.Set_Value (Default_Filter);
    end if;

    Show.Set_Tooltip ("Click to open file browser..");
    Show.Set_Callback (Show_CB'Unrestricted_Access);
    Icon := Ico.Find (".", Ico.Directory_File);
    if Icon /= null then
        Show.Set_Label_Color (FLTK.Yellow_Color);
        Ico.Set_Icon_Label (Show, Icon.all);
    else
        Show.Set_Label ("..");
    end if;
    Filter_Group.Set_Resizable (Filter);

    Multi_Toggle.Set_Callback (Toggle_CB'Unrestricted_Access);
    Create_Toggle.Set_Callback (Toggle_CB'Unrestricted_Access);
    Directory_Toggle.Set_Callback (Toggle_CB'Unrestricted_Access);
    Extra.Add_Items ("none|encodings group|check button");
    Extra.Set_Chosen (1);
    Extra.Set_Callback (Extra_CB'Unrestricted_Access);
    Light_Group.Clear_Resizable;

    Files.Set_Alignment (FLTK.Align_Left);

    Invisible.Set_Box (FLTK.No_Box);
    Close.Set_Callback (Close_CB'Unrestricted_Access);
    Close_Group.Set_Resizable (Invisible);

    Win.Set_Resizable (Files);
    Win.Show_With_Args;

    return Result : constant Integer := FLTK.Run do
        Chooser.Remove_Extra;
        Free (Encoding);
        Free (Encodings);
        Free (Version);
        Shr.Remove_Handler (PDF_Check'Unrestricted_Access);
        Shr.Remove_Handler (PS_Check'Unrestricted_Access);
        Free (Preview);
    end return;


end File_Chooser;


