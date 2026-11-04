--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 11: FLTK.Devices.Surface.Paged.PDF, after pofltk's
--  TestPrint.  The file is read back; a file that can't be written raises,
--  and never alerts (pofltk 102); a surface with no document can't be
--  drawn on (pofltk 103); the format dialog shows the texts set.


with

    Ada.Directories,
    Ada.Environment_Variables,
    Ada.Exceptions,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    Checks,
    FLTK.Devices.Surface.Paged.PDF,
    FLTK.Draw,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_PDF_Surface is

    package Surf renames FLTK.Devices.Surface;
    package Pgd renames FLTK.Devices.Surface.Paged;
    package PDF renames FLTK.Devices.Surface.Paged.PDF;
    package Dr renames FLTK.Draw;
    package Prb renames FLTK.Probe;

    Name    : constant String := "test_pdf_surface.pdf";
    Nowhere : constant String := "/nonexistent/test_pdf_surface.pdf";

    --  Set by Picture's Draw, which FLTK calls.
    Draws : Natural := 0
    with Volatile;

    type Picture is new FLTK.Widgets.Boxes.Box with null record;

    overriding procedure Draw
           (This : in out Picture);

    overriding procedure Draw
           (This : in out Picture) is
    begin
        Draws := Draws + 1;
        Dr.Set_Color (FLTK.Red_Color);
        Dr.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
    end Draw;

    Window : FLTK.Widgets.Groups.Windows.Window :=
        FLTK.Widgets.Groups.Windows.Forge.Create (120, 120, "Test_PDF_Surface");
    Shown  : constant Picture :=
        (FLTK.Widgets.Boxes.Forge.Create (Window, 0, 40, 100, 40) with null record);

    function Contents
           (Name : in String)
        return String
    is
        File   : Ada.Text_IO.File_Type;
        Result : Ada.Strings.Unbounded.Unbounded_String;
    begin
        Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Name);
        while not Ada.Text_IO.End_Of_File (File) loop
            Ada.Strings.Unbounded.Append (Result, Ada.Text_IO.Get_Line (File));
            Ada.Strings.Unbounded.Append (Result, ASCII.LF);
        end loop;
        Ada.Text_IO.Close (File);
        return Ada.Strings.Unbounded.To_String (Result);
    end Contents;

    function Has
           (Text, Part : in String)
        return Boolean is
    begin
        return Ada.Strings.Fixed.Index (Text, Part) > 0;
    end Has;

    procedure Draw_Some is
    begin
        Dr.Set_Color (FLTK.Blue_Color);
        Dr.Set_Font (FLTK.Helvetica, 14);
        Dr.Rect (10, 10, 100, 50);
        Dr.Draw_Text (20, 30, "text");
    end Draw_Some;

    --  So much that FLTK's buffer is written before End_Job.
    procedure Draw_Lots is
    begin
        Dr.Set_Font (FLTK.Helvetica, 14);
        for I in 0 .. 20_000 loop
            Dr.Set_Color (FLTK.Color (I mod 256));
            Dr.Rect_Fill (I mod 500, I mod 700, 30, 30);
            Dr.Draw_Text (I mod 400, I mod 600, "text, text and more text");
        end loop;
    end Draw_Lots;

    --  The FIFOs the binding has left in the temporary directory.
    function Left_Behind
        return Natural
    is
        Dir    : constant String :=
            (if Ada.Environment_Variables.Exists ("TMPDIR")
                and then Ada.Environment_Variables.Value ("TMPDIR") /= ""
             then Ada.Environment_Variables.Value ("TMPDIR")
             else "/tmp");
        Search : Ada.Directories.Search_Type;
        Item   : Ada.Directories.Directory_Entry_Type;
        Count  : Natural := 0;
    begin
        Ada.Directories.Start_Search (Search, Dir, "fltkada-pdf-*");
        while Ada.Directories.More_Entries (Search) loop
            Ada.Directories.Get_Next_Entry (Search, Item);
            Count := Count + 1;
        end loop;
        Ada.Directories.End_Search (Search);
        return Count;
    end Left_Behind;

    --  End_Job raises File_Write_Error with a message that has Part.
    procedure Check_Write_Error
           (Surface : in out PDF.PDF_File_Surface;
            Part    : in     String;
            What    : in     String) is
    begin
        Surface.End_Job;
        Check (False, What & ": no exception");
    exception
        when E : PDF.File_Write_Error =>
            Check (Has (Ada.Exceptions.Exception_Message (E), Part),
                What & ": " & Ada.Exceptions.Exception_Message (E));
    end Check_Write_Error;

    Before : Natural;

    Title_Shown, Size_Shown : Boolean := False;

    --  Waits for the format dialog, notes what it shows, and closes it.
    procedure Look_And_Close is
    begin
        if Prb.Modal then
            Title_Shown := Prb.Modal_Title = "Test PDF settings";
            Size_Shown := Prb.Has_Label ("Test page size:");
        end if;
        if not Prb.Close_Modal then
            FLTK.Static.Add_Timeout (0.1, Look_And_Close'Unrestricted_Access);
        end if;
    end Look_And_Close;

begin

    Window.End_Current;

    if not PDF.Is_Supported then
        Skip ("this FLTK can't write PDF");
        Summary;
        return;
    end if;

    Before := Left_Behind;

    Check (PDF.Get_Dialog_Text (PDF.Title_Text) = "PDF document settings",
        "the dialog's title is FLTK's: " & PDF.Get_Dialog_Text (PDF.Title_Text));
    PDF.Set_Dialog_Text (PDF.Title_Text, "Test PDF settings");
    PDF.Set_Dialog_Text (PDF.Page_Size_Text, "Test page size:");
    Check (PDF.Get_Dialog_Text (PDF.Title_Text) = "Test PDF settings",
        "Set_Dialog_Text, Get_Dialog_Text");

    declare
        Surface : PDF.PDF_File_Surface := PDF.Forge.Create;
        W, H, X, Y, L, T, R, B : Integer;

        procedure Start_Page is
        begin
            Surface.Start_Page;
        end Start_Page;

        procedure End_Page is
        begin
            Surface.End_Page;
        end End_Page;

        procedure End_Job is
        begin
            Surface.End_Job;
        end End_Job;

        procedure Printable_Rect is
        begin
            Surface.Get_Printable_Rect (W, H);
        end Printable_Rect;

        procedure Print_Box is
        begin
            Surface.Print_Widget (Shown);
        end Print_Box;

        procedure Set_Current is
        begin
            Surface.Set_Current;
        end Set_Current;

        procedure Start_Again is
        begin
            Surface.Start_Document (Name);
        end Start_Again;

        procedure Print_Dialog is
        begin
            Surface.Start_Job (1);
        end Print_Dialog;
    begin
        Check (not Surface.Is_Open and Surface.Get_File_Name = "", "no document to begin with");
        Raises (Start_Page'Access, Program_Error'Identity,
            "Start_Page with no document raises Program_Error");
        Raises (Printable_Rect'Access, Program_Error'Identity,
            "Get_Printable_Rect with no document raises Program_Error");
        Raises (Print_Box'Access, Program_Error'Identity,
            "Print_Widget with no document raises Program_Error");
        Raises (Set_Current'Access, Program_Error'Identity,
            "Set_Current with no document raises Program_Error");
        Raises (Print_Dialog'Access, Pgd.Page_Error'Identity,
            "a print dialog's Start_Job raises Page_Error");
        No_Raise (End_Job'Access, "End_Job with no document does nothing");

        Surface.Start_Document (Name, Pgd.A4, Pgd.Portrait);
        Check (Surface.Is_Open, "Start_Document opens it");
        Check (Surface.Get_File_Name = Name, "Get_File_Name: " & Surface.Get_File_Name);
        Check (Left_Behind = Before, "its FIFO is gone already");
        Surface.Get_Printable_Rect (W, H);
        Check (W in 400 .. 595 and H in 600 .. 842, "A4 portrait:" & W'Image & H'Image);
        Surface.Get_Margins (L, T, R, B);
        Check (L = 18 and T = 18, "A4 margins:" & L'Image & T'Image & R'Image & B'Image);

        Surface.Start_Page;
        Check (Surface.Is_Current, "Start_Page makes it current");
        Raises (Start_Page'Access, Pgd.Page_Error'Identity,
            "Start_Page in a page raises Page_Error");
        Raises (End_Job'Access, Pgd.Page_Error'Identity,
            "End_Job in a page raises Page_Error");
        Draw_Some;
        Draws := 0;
        Surface.Print_Widget (Shown, 50, 20);
        Check (Draws = 1, "a widget's Draw runs:" & Draws'Image);
        Surface.Set_Origin (30, 40);
        Surface.Get_Origin (X, Y);
        Check (X = 30 and Y = 40, "Set_Origin, Get_Origin:" & X'Image & Y'Image);
        Surface.End_Page;
        Check (Surf.Get_Original.Is_Current, "End_Page makes the original current again");
        Raises (End_Page'Access, Pgd.Page_Error'Identity,
            "End_Page outside a page raises Page_Error");

        Surface.Start_Page;
        Surface.Scale (2.0);
        Surface.Rotate (45.0);
        Surface.Translate (10, 10);
        Draw_Some;
        Surface.Untranslate;
        Surface.End_Page;

        Surface.End_Job;
        Check (not Surface.Is_Open, "End_Job closes it");
        No_Raise (End_Job'Access, "a second End_Job does nothing");
        Raises (Start_Again'Access, Pgd.Page_Error'Identity,
            "a second Start_Document raises Page_Error");
        Raises (Start_Page'Access, Program_Error'Identity,
            "Start_Page after End_Job raises Program_Error");
        Check (Surf.Get_Original.Is_Current, "the original is still current");
    end;

    declare
        Text : constant String := Contents (Name);
    begin
        Check (Ada.Strings.Fixed.Head (Text, 5) = "%PDF-", "the file is PDF");
        Check (Has (Text, "/Count 2"), "of 2 pages");
        Check (Has (Text, "%%EOF"), "and complete");
    end;

    declare
        Surface : PDF.PDF_File_Surface := PDF.Forge.Create;
        W, H    : Integer;
    begin
        Surface.Start_Document (Name, Pgd.Letter, Pgd.Landscape);
        Surface.Get_Printable_Rect (W, H);
        Check (W > H, "Letter landscape:" & W'Image & H'Image);
        --  Text first, with no font set on the surface (pofltk 100).
        Surface.Start_Page;
        Dr.Draw_Text (20, 30, "text");
        Surface.End_Page;
        Surface.End_Job;
    end;
    Check (Has (Contents (Name), "%%EOF"), "text with no font set is drawn");

    declare
        Surface : PDF.PDF_File_Surface := PDF.Forge.Create;

        procedure Media is
        begin
            Surface.Start_Document (Name, Pgd.Media);
        end Media;
    begin
        Raises (Media'Access, Constraint_Error'Identity,
            "the Media format raises Constraint_Error");
    end;

    --  Finalizing it in a page ends the page and the document.
    Ada.Directories.Delete_File (Name);
    declare
        Surface : PDF.PDF_File_Surface := PDF.Forge.Create;
    begin
        Surface.Start_Document (Name);
        Surface.Start_Page;
        Draw_Some;
    end;
    Check (Surf.Get_Original.Is_Current, "the original is current after it is finalized");
    Check (Has (Contents (Name), "%%EOF"), "finalizing it in a page writes the file");

    --  Files that can't be written.
    declare
        Surface : PDF.PDF_File_Surface := PDF.Forge.Create;
    begin
        Surface.Start_Document (Nowhere);
        Check (False, "a missing directory raises File_Open_Error");
    exception
        when E : PDF.File_Open_Error =>
            Check (Has (Ada.Exceptions.Exception_Message (E), Nowhere),
                "a missing directory raises File_Open_Error: " &
                Ada.Exceptions.Exception_Message (E));
            Check (not Surface.Is_Open, "and leaves it with no document");
    end;

    if not Ada.Directories.Exists ("/dev/full") then
        Skip ("no /dev/full");
    else
        declare
            Surface : PDF.PDF_File_Surface := PDF.Forge.Create;
        begin
            Surface.Start_Document ("/dev/full");
            Surface.Start_Page;
            Draw_Lots;
            Surface.End_Page;
            Surface.Start_Page;
            Draw_Lots;
            Surface.End_Page;
            Check_Write_Error (Surface, "couldn't all be written",
                "a full disk raises File_Write_Error, with no alert");
        end;
        declare
            Surface : PDF.PDF_File_Surface := PDF.Forge.Create;
        begin
            Surface.Start_Document ("/dev/full");
            Surface.Start_Page;
            Draw_Lots;
        end;
        Check (True, "a full disk: finalizing it unfinished doesn't alert");
    end if;

    Check (Left_Behind = Before, "no FIFO is left behind");

    --  The file chooser's format dialog, cancelled.
    declare
        Surface : PDF.PDF_File_Surface := PDF.Forge.Create;
    begin
        FLTK.Static.Add_Timeout (0.2, Look_And_Close'Unrestricted_Access);
        Surface.Start_Job ("chosen.pdf");
        Check (False, "cancelling the format dialog raises User_Cancel_Error");
        Surface.End_Job;
    exception
        when PDF.User_Cancel_Error =>
            Check (True, "cancelling the format dialog raises User_Cancel_Error");
            Check (not Surface.Is_Open, "and leaves it with no document");
    end;
    Check (Title_Shown, "the format dialog has the title set");
    Check (Size_Shown, "and the page size label set");

    Ada.Directories.Delete_File (Name);

    Summary;

end Test_PDF_Surface;
