

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestPrint: a PostScript job's pages, margins,
--  origin, scale and rotation, landscape and reversed jobs, a widget on a
--  page, a job finalized halfway, surfaces nested three deep, and windows
--  drawn before and after they are shown.  The rest of TestPrint is
--  elsewhere: EPS in test_eps_surface, PDF in test_pdf_surface, SVG in
--  test_svg_surface, failing files in test_ps_errors, misuse in
--  test_page_misuse and test_page_finalize, text with no font in
--  test_print_font, the dialogs' texts in test_printer_labels, and a
--  FLTK that can't print in test_print_support.  pofltk's printer dialog,
--  cancelled, is test/desktop's, as a native dialog can reach the desktop.


with

    Ada.Directories,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    Checks,
    FLTK.Devices.Surface.EPS,
    FLTK.Devices.Surface.Image,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Draw,
    FLTK.Images.RGB,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;

use type

    Ada.Directories.File_Size;


procedure Test_Print is

    package Surf renames FLTK.Devices.Surface;
    package Paged renames FLTK.Devices.Surface.Paged;
    package PS renames FLTK.Devices.Surface.Paged.Postscript;
    package EPS renames FLTK.Devices.Surface.EPS;
    package Img renames FLTK.Devices.Surface.Image;
    package Dr renames FLTK.Draw;
    package Win renames FLTK.Widgets.Groups.Windows;

    PS_Name  : constant String := "test_print.ps";
    EPS_Name : constant String := "test_print.eps";

    --  A4 and Letter, in points.
    A4_W     : constant := 595;
    A4_H     : constant := 842;

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

    Window : Win.Window := Win.Forge.Create (0, 0, 120, 120, "Test_Print");
    Shown  : constant Picture :=
        (FLTK.Widgets.Boxes.Forge.Create (Window, 10, 40, 100, 40) with null record);

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

    function Size
           (Name : in String)
        return Ada.Directories.File_Size is
    begin
        if Ada.Directories.Exists (Name) then
            return Ada.Directories.Size (Name);
        else
            return 0;
        end if;
    end Size;

    procedure Draw_Some is
    begin
        Dr.Set_Color (FLTK.Blue_Color);
        Dr.Rect (10, 10, 100, 50);
        Dr.Draw_Text (20, 30, "text");
        Dr.Set_Line_Style (Dashes => (1 => (7, 3)));
        Dr.Ecks_Why_Line (10, 70, 100);
        Dr.Set_Line_Style;
    end Draw_Some;

    Plain : Ada.Directories.File_Size;
    Bare  : Ada.Directories.File_Size;

begin

    Window.End_Current;

    if not PS.Is_Supported then
        Skip ("this FLTK can't print");
        Summary;
        return;
    end if;

    --  A job of three pages.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
        W, H, X, Y, L, T, R, B : Integer;
    begin
        Check (not Output.Is_Open, "a file starts closed");
        Output.Open (PS_Name);
        Check (Output.Is_Open, "Open");
        Device.Start_Job (Output, 3, Paged.A4, Paged.Portrait);
        Device.Get_Printable_Rect (W, H);
        Device.Get_Margins (L, T, R, B);
        Check (W > 400 and W < A4_W and H > 600 and H < A4_H,
            "Get_Printable_Rect, A4 in points:" & W'Image & H'Image);
        Check (L >= 0 and L + W + R = A4_W and T + H + B = A4_H,
            "Get_Margins and Get_Printable_Rect make the page:"
                & L'Image & T'Image & R'Image & B'Image);

        Device.Start_Page;
        Draw_Some;
        Device.Set_Origin (30, 40);
        Device.Get_Origin (X, Y);
        Check (X = 30 and Y = 40, "Set_Origin, Get_Origin");
        Device.Translate (5, 5);
        Device.Translate (5, 5);
        Draw_Some;
        Device.Untranslate;
        Device.Untranslate;
        Device.Get_Origin (X, Y);
        Check (X = 30 and Y = 40, "Translate leaves the origin");
        Device.Set_Origin (0, 0);
        Device.End_Page;

        Device.Start_Page;
        Device.Scale (0.5, 0.5);
        Device.Get_Printable_Rect (W, H);
        Check (W > 800 and H > 1200, "Scale widens what fits:" & W'Image & H'Image);
        Device.Rotate (10.0);
        Draw_Some;
        Device.End_Page;

        Device.Start_Page;
        Device.Get_Printable_Rect (X, Y);
        Check (X < A4_W and Y < A4_H, "a new page starts unscaled:" & X'Image & Y'Image);
        Device.End_Page;
        Device.End_Job;
        Check (Output.Is_Open, "End_Job leaves the file open");
        Output.Close;
        Output.Close;
        Check (not Output.Is_Open, "Close, twice");
    end;
    declare
        Text : constant String := Contents (PS_Name);
    begin
        Check (Ada.Strings.Fixed.Head (Text, 4) = "%!PS", "the file is PostScript");
        Check (Has (Text, "%%Page: 3") and not Has (Text, "%%Page: 4"), "of three pages");
    end;

    --  Landscape.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
        W, H   : Integer;
    begin
        Output.Open (PS_Name);
        Device.Start_Job (Output, 1, Paged.Letter, Paged.Landscape);
        Device.Get_Printable_Rect (W, H);
        Check (W > H, "Landscape is wider than high:" & W'Image & H'Image);
        Device.Start_Page;
        Device.End_Page;
        Device.End_Job;
        Output.Close;
    end;
    Plain := Size (PS_Name);
    Check (Plain > 0 and Has (Contents (PS_Name), "Landscape"),
        "and says so in the file");

    --  A widget on a page.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
        Box    : constant FLTK.Widgets.Boxes.Box :=
            FLTK.Widgets.Boxes.Forge.Create (0, 0, 40, 20, "box");
    begin
        Output.Open (PS_Name);
        Device.Start_Job (Output, 1, Paged.Letter, Paged.Landscape);
        Draws := 0;
        Device.Start_Page;
        Device.Print_Widget (Shown, 50, 50);
        Device.Print_Widget (Box, 50, 100);
        Device.End_Page;
        Check (Draws = 1, "Print_Widget runs a widget's Draw:" & Draws'Image);
        Device.End_Job;
        Output.Close;
    end;
    Check (Size (PS_Name) > Plain, "making the file bigger:"
        & Size (PS_Name)'Image & " >" & Plain'Image);

    --  Finalized halfway: in a page, translated, with the file still open.
    declare
        Output : PS.File_Type;
    begin
        Output.Open (PS_Name);
        declare
            Device : PS.Postscript_File_Device := PS.Forge.Create;
        begin
            Device.Start_Job (Output, 1);
            Device.Start_Page;
            Device.Translate (1, 1);
            Device.Translate (1, 1);
            Draw_Some;
        end;
        Check (Surf.Get_Original.Is_Current,
            "a device finalized halfway leaves the original current");
        Draw_Some;
        Output.Close;
    end;
    Check (Ada.Strings.Fixed.Head (Contents (PS_Name), 4) = "%!PS"
            and Has (Contents (PS_Name), "%%EOF"),
        "and its job is ended, the file whole (FLTKAda-BUGS.md 121):" & Size (PS_Name)'Image);

    --  Reversed, with no pages at all.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
    begin
        Output.Open (PS_Name);
        Device.Start_Job (Output, 0, Paged.A4, Paged.Reversed);
        Device.End_Job;
        Output.Close;
    end;
    Check (Ada.Strings.Fixed.Head (Contents (PS_Name), 4) = "%!PS", "Reversed, no pages at all");

    --  Nesting: a page, a drawing in it, and an image surface in that.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
    begin
        Output.Open (PS_Name);
        Device.Start_Job (Output, 1);
        declare
            Drawing : EPS.EPS_File_Surface := EPS.Forge.Create (EPS_Name, 40, 40);
            Inner   : Img.Image_Surface := Img.Forge.Create (4, 4);
        begin
            Device.Start_Page;
            Surf.Push_Current (Drawing);
            Surf.Push_Current (Inner);
            Dr.Set_Color (FLTK.Red_Color);
            Dr.Rect_Fill (0, 0, 4, 4);
            Surf.Pop_Current;
            Draw_Some;
            Surf.Pop_Current;
            Check (Device.Is_Current, "nesting: the page is current again");
            Draw_Some;
            Device.End_Page;
            declare
                Got : constant FLTK.Images.RGB.RGB_Image := Inner.Get_Image;
            begin
                Check (Got.Get_W = 4 and Got.Get_H = 4,
                    "an image surface inside them works:" & Got.Get_W'Image);
            end;
            Drawing.Finish;
        end;
        Device.End_Job;
        Output.Close;
    end;
    Check (Size (PS_Name) > 0 and Size (EPS_Name) > 0, "the page and the drawing are written");
    Check (Surf.Get_Original.Is_Current, "and the original is current");

    declare
        Outer   : Img.Image_Surface := Img.Forge.Create (4, 4);
        Drawing : EPS.EPS_File_Surface := EPS.Forge.Create (EPS_Name, 40, 40);
    begin
        Surf.Push_Current (Outer);
        Surf.Push_Current (Drawing);
        Draw_Some;
        Surf.Pop_Current;
        Check (Outer.Is_Current, "a drawing inside an image surface");
        Surf.Pop_Current;
        Drawing.Finish;
    end;
    Check (Has (Contents (EPS_Name), "%%EOF"), "is written");

    --  A window, not shown and then shown.
    Check (Window.Get_Decorated_W = Window.Get_W and Window.Get_Decorated_H = Window.Get_H,
        "a window not shown has no title bar:"
            & Window.Get_Decorated_W'Image & Window.Get_Decorated_H'Image);
    declare
        Drawing : EPS.EPS_File_Surface := EPS.Forge.Create (EPS_Name, 200, 200);
    begin
        Surf.Push_Current (Drawing);
        Drawing.Draw_Widget (Window);
        Drawing.Draw_Decorated_Window (Window);
        Drawing.Print_Window_Part (Window, 0, 0, 50, 50);
        Surf.Pop_Current;
        Drawing.Finish;
    end;
    Bare := Size (EPS_Name);
    Check (Bare > 0, "drawing a window not shown:" & Bare'Image);

    Window.Show;
    Window.Wait_For_Expose;
    Check (Window.Is_Shown, "shown");
    Check (Window.Get_Decorated_W >= Window.Get_W and Window.Get_Decorated_H >= Window.Get_H,
        "Get_Decorated_W, Get_Decorated_H, of one that is:"
            & Window.Get_Decorated_W'Image & Window.Get_Decorated_H'Image);

    declare
        Drawing : EPS.EPS_File_Surface := EPS.Forge.Create (EPS_Name, 200, 200);
    begin
        Surf.Push_Current (Drawing);
        Drawing.Draw_Widget (Window);
        Surf.Pop_Current;
        Drawing.Finish;
    end;
    Check (Size (EPS_Name) > Bare, "Draw_Widget draws it:" & Size (EPS_Name)'Image);
    declare
        Drawing : EPS.EPS_File_Surface := EPS.Forge.Create (EPS_Name, 200, 200);
    begin
        Surf.Push_Current (Drawing);
        Drawing.Print_Window_Part (Window, 0, 0, 50, 50, 10, 10);
        Surf.Pop_Current;
        Drawing.Finish;
    end;
    Check (Size (EPS_Name) > Bare, "Print_Window_Part draws it:" & Size (EPS_Name)'Image);
    declare
        Drawing : EPS.EPS_File_Surface := EPS.Forge.Create (EPS_Name, 200, 200);
    begin
        Surf.Push_Current (Drawing);
        Drawing.Draw_Decorated_Window (Window);
        Surf.Pop_Current;
        Drawing.Finish;
    end;
    Check (Size (EPS_Name) > Bare, "Draw_Decorated_Window draws it:" & Size (EPS_Name)'Image);
    Window.Hide;

    Ada.Directories.Delete_File (PS_Name);
    Ada.Directories.Delete_File (EPS_Name);

    Summary;

end Test_Print;
