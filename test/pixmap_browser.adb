--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/pixmap_browser.cxx: shows an image file, chosen with "load"
--  or named on the command line, and prints the window or saves it as SVG.
--  The file chooser shows each file as the user moves over it.  A timer
--  redraws the windows every tenth of a second, so that animated GIFs move.


with

    Ada.Command_Line,
    Ada.Exceptions,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    Interfaces.C.Strings,
    FLTK.Asks,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Devices.Surface.SVG,
    FLTK.Filenames,
    FLTK.Images.Pixmaps.GIF,
    FLTK.Images.Shared,
    FLTK.Native_File_Choosers,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double;

use

    Ada.Strings.Unbounded;

use type

    FLTK.Alignment,
    FLTK.Native_File_Choosers.Chooser_Option,
    FLTK.Native_File_Choosers.Show_Result;


function Pixmap_Browser
    return Integer
is


    package Prn renames FLTK.Devices.Surface.Paged.Printers;
    package SVG renames FLTK.Devices.Surface.SVG;
    package Shr renames FLTK.Images.Shared;
    package NFC renames FLTK.Native_File_Choosers;
    package Stc renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;


    type Shared_Access is access Shr.Shared_Image;

    procedure Free is new Ada.Unchecked_Deallocation (Shr.Shared_Image, Shared_Access);


    Window : Dbl.Double_Window := Dbl.Forge.Create (400, 450);
    Box    : Bx.Box := Bx.Forge.Create (Window, 10, 45, 380, 380);
    Load   : Btn.Button := Btn.Forge.Create (Window, 150, 5, 100, 30, "load");
    Print  : Btn.Button := Btn.Forge.Create (Window, 300, 425, 50, 25, "Print");
    Save   : Btn.Button := Btn.Forge.Create (Window, 190, 425, 100, 25, "save as SVG");

    Img  : Shared_Access := null;
    Name : Unbounded_String;

    --  The C++ starts with animate set, so its -a changes nothing.
    Dvisual : Boolean := False;
    Animate : Boolean := True;


    --  Fl::redraw, where the C++ redraws each window but a menu's.  Neither
    --  FLTKAda nor the C++ makes a menu window here.
    procedure Forced_Redraw is
    begin
        FLTK.Screen.Redraw;
        if Stc.Get_First_Window /= null then
            Stc.Repeat_Timeout (1.0 / 10.0, Forced_Redraw'Unrestricted_Access);
        end if;
    end Forced_Redraw;


    --  A file no loader takes shows an empty document.  So does one a
    --  loader took and couldn't load, which FLTK's Fl_Shared_Image::get
    --  returns anyway, 0 wide, and the C++ shows as nothing.
    procedure Load_File
           (N : in String) is
    begin
        if Img /= null then
            Box.Clear_Image;
            Free (Img);
        end if;

        if FLTK.Filenames.Is_Directory (N) then
            Box.Set_Label ("@fileopen");  --  a generic folder
            Box.Set_Label_Size (64);
            Box.Set_Label_Color (FLTK.Light2_Color);
            Box.Redraw;
            return;
        end if;

        begin
            Img := new Shr.Shared_Image'(Shr.Forge.Create (N, 0, 0));
        exception
        when FLTK.Images.No_Image_Error =>
            Box.Set_Label ("@filenew");  --  an empty document
            Box.Set_Label_Size (64);
            Box.Set_Label_Color (FLTK.Light2_Color);
            Box.Redraw;
            return;
        end;

        Box.Set_Label_Size (14);
        Box.Set_Label_Color (FLTK.Foreground_Color);
        Box.Set_Image (Img.all);
        Img.Scale (Box.Get_W, Box.Get_H);
        Box.Set_Label ("");
        Box.Redraw;
    end Load_File;


    procedure File_Picked
           (N : in String) is
    begin
        if N = To_String (Name) then
            return;
        end if;
        Load_File (N);
        Name := To_Unbounded_String (N);
        Window.Set_Label (N);
    end File_Picked;


    procedure Load_Pressed
           (Ignore : in out Wdg.Widget'Class)
    is
        Images : constant String := "*.{bm,bmp,gif,ico,jpg,pbm,pgm,png,ppm,xbm,xpm"
            & (if SVG.Is_Supported then ",svg,svgz" else "") & "}";
    begin
        FLTK.Asks.Set_File_Chooser_Callback (File_Picked'Unrestricted_Access);
        declare
            Chosen : constant String :=
                FLTK.Asks.File_Chooser ("Image file?", Images, To_String (Name));
        begin
            --  File_Chooser gives "" where FLTK's gives null.
            Ada.Text_IO.Put_Line (if Chosen = "" then "(null)" else Chosen);
            Ada.Text_IO.Flush;
        end;
        FLTK.Asks.Set_File_Chooser_Callback (null);
    end Load_Pressed;


    procedure Print_Pressed
           (Item : in out Wdg.Widget'Class)
    is
        Printer       : Prn.Printer := Prn.Forge.Create;
        Width, Height : Integer;
        FW, FH        : Float;
    begin
        --  Start_Job raises where FLTK's start_job returns nonzero: the user
        --  cancelled or the job couldn't start.
        begin
            Printer.Start_Job (1);
        exception
        when FLTK.Devices.Surface.Paged.Page_Error =>
            return;
        end;
        Printer.Start_Page;
        Printer.Get_Printable_Rect (Width, Height);
        FW := Float (Item.Nearest_Window.Get_Decorated_W) / Float (Width);
        FH := Float (Item.Nearest_Window.Get_Decorated_H) / Float (Height);
        if FH > FW then
            FW := FH;
        end if;
        Printer.Scale (1.0 / FW);
        Printer.Print_Window (Item.Nearest_Window.all);
        Printer.End_Page;
        Printer.End_Job;
    end Print_Pressed;


    --  A file that can't be opened or written is reported; the C++ writes
    --  to a null FILE.
    procedure Save_Pressed
           (Item : in out Wdg.Widget'Class)
    is
        Chooser : NFC.Native_File_Chooser := NFC.Forge.Create;
    begin
        Chooser.Set_Title ("Pick a .svg file");
        Chooser.Set_Kind (NFC.Browse_Save_File);
        Chooser.Set_Filter ("SVG" & ASCII.HT & "*.svg" & ASCII.LF);
        Chooser.Set_Options (NFC.Saveas_Confirm + NFC.Use_Filter_Ext);
        if Chooser.Show /= NFC.Picked then
            return;
        end if;
        declare
            Surface : SVG.SVG_File_Surface := SVG.Forge.Create
               (Chooser.Get_Filename,
                Item.Nearest_Window.Get_Decorated_W,
                Item.Nearest_Window.Get_Decorated_H);
        begin
            Surface.Draw_Decorated_Window (Item.Nearest_Window.all);
            Surface.Finish;
        end;
    exception
    when Error : SVG.File_Open_Error | SVG.File_Write_Error =>
        FLTK.Asks.Alert (Ada.Exceptions.Exception_Message (Error));
    end Save_Pressed;


    --  The C++ looks only at the second character: -8 asks for fewer
    --  colours, and -a animates GIFs.
    function Arg
           (Index : in Positive)
        return Natural
    is
        Text : constant String := Ada.Command_Line.Argument (Index);
    begin
        if Text'Length >= 2 and then Text (Text'First + 1) = '8' then
            Dvisual := True;
            return 1;
        end if;
        if Text'Length >= 2 and then Text (Text'First + 1) = 'a' then
            Animate := True;
            return 1;
        end if;
        return 0;
    end Arg;


    --  For the file chooser's errors in the user's language.
    function C_Setlocale
           (Category : in Interfaces.C.int;
            Locale   : in Interfaces.C.char_array)
        return Interfaces.C.Strings.chars_ptr
    with Import, Convention => C, External_Name => "setlocale";

    LC_ALL : constant Interfaces.C.int := 6;  --  glibc's; FreeBSD's is 0

    Locale : Interfaces.C.Strings.chars_ptr with Unreferenced;
    Count  : Natural;
    Status : Integer;


begin


    Locale := C_Setlocale (LC_ALL, Interfaces.C.To_C (""));
    Shr.Register_Images;

    --  Fl::args with a handler, as the C++ calls it, stops at an argument
    --  it doesn't know, and says nothing.
    begin
        Stc.Parse_Args (Count, Arg'Unrestricted_Access);
    exception
    when Stc.Argument_Error =>
        null;
    end;

    if Animate then
        FLTK.Images.Pixmaps.GIF.Set_Animate (True);
    end if;

    Box.Set_Box (FLTK.Thin_Down_Box);
    Box.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center + FLTK.Align_Clip);
    Load.Set_Callback (Load_Pressed'Unrestricted_Access);
    if not Dvisual then
        FLTK.Screen.Set_Visual_Mode (FLTK.Screen.RGB);
    end if;
    --  The C++ loads its first argument, whatever Fl::args made of it.
    if Ada.Command_Line.Argument_Count >= 1 then
        Load_File (Ada.Command_Line.Argument (1));
    end if;
    Window.Set_Resizable (Box);
    Print.Set_Callback (Print_Pressed'Unrestricted_Access);
    Save.Set_Callback (Save_Pressed'Unrestricted_Access);

    Window.Show_With_Args;
    if Animate then
        Stc.Add_Timeout (1.0 / 10.0, Forced_Redraw'Unrestricted_Access);
    end if;
    Status := FLTK.Run;

    Box.Clear_Image;
    Free (Img);
    return Status;


end Pixmap_Browser;
