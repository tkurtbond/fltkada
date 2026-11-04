--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 11: FLTK.Devices.Surface.SVG, after pofltk's TestPrint.
--  The file is read back, and is whole even with a Translate not undone
--  (FLTK-issues.md F18); a file that can't be written raises; a finished
--  surface can't be drawn on, since FLTK has deleted its driver.


with

    Ada.Directories,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Strings.Maps,
    Ada.Text_IO,
    Checks,
    FLTK.Devices.Surface.SVG,
    FLTK.Devices.Surface.Image,
    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_SVG_Surface is

    package Surf renames FLTK.Devices.Surface;
    package SVG renames FLTK.Devices.Surface.SVG;
    package Dr renames FLTK.Draw;

    Name    : constant String := "test_svg_surface.svg";
    Nowhere : constant String := "/nonexistent/test_svg_surface.svg";

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
        FLTK.Widgets.Groups.Windows.Forge.Create (120, 120, "Test_SVG_Surface");
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

    function Count
           (Text, Part : in String)
        return Natural is
    begin
        return Ada.Strings.Fixed.Count (Text, Part, Ada.Strings.Maps.Identity);
    end Count;

    procedure Draw_Some is
    begin
        Dr.Set_Color (FLTK.Blue_Color);
        Dr.Rect (10, 10, 100, 50);
        Dr.Draw_Text (20, 30, "text");
        Dr.Set_Line_Style (Dashes => (1 => (7, 3)));
        Dr.Ecks_Why_Line (10, 70, 100);
        Dr.Set_Line_Style;
    end Draw_Some;

    --  So much that the file's buffer is written before it is closed.
    procedure Draw_Lots is
    begin
        for I in 0 .. 20_000 loop
            Dr.Line (I mod 100, 0, 100, I mod 97);
            Dr.Draw_Text (20, I mod 89, "text");
        end loop;
    end Draw_Lots;

begin

    Window.End_Current;

    if not SVG.Is_Supported then
        Skip ("this FLTK has no SVG");
        Summary;
        return;
    end if;

    declare
        Surface : SVG.SVG_File_Surface := SVG.Forge.Create (Name, 200, 100);
        W, H, X, Y : Integer;

        procedure Untranslate is
        begin
            Surface.Untranslate;
        end Untranslate;

        procedure Finish is
        begin
            Surface.Finish;
        end Finish;

        procedure Set_Current is
        begin
            Surface.Set_Current;
        end Set_Current;
    begin
        Surface.Get_Printable_Rect (W, H);
        Check (W = 200 and H = 100, "its size:" & W'Image & H'Image);
        Surface.Set_Current;
        Check (Surface.Is_Current and Surf.Get_Current.Data.all in SVG.SVG_File_Surface'Class,
            "Set_Current makes it current");
        Draw_Some;
        Surface.Set_Origin (30, 40);
        Surface.Get_Origin (X, Y);
        Check (X = 30 and Y = 40, "Set_Origin, Get_Origin");
        Surface.Translate (5, 5);
        Draws := 0;
        Surface.Draw_Widget (Shown, 50, 20);
        Check (Draws = 1, "a widget's Draw runs:" & Draws'Image);
        Surface.Untranslate;
        Dr.Set_Font (FLTK.Times_Bold, 24);
        Draw_Some;
        Check (Surface.Is_Current, "Draw_Widget leaves it current");
        Surf.Get_Original.Set_Current;

        Raises (Untranslate'Access, Constraint_Error'Identity,
            "Untranslate with no Translate raises Constraint_Error");
        Surface.Set_Current;
        Raises (Finish'Access, Program_Error'Identity,
            "Finish while current raises Program_Error");
        Surf.Get_Original.Set_Current;

        Surface.Finish;
        Check (Surface.Is_Finished, "Is_Finished after Finish");
        No_Raise (Finish'Access, "a second Finish does nothing");
        Raises (Set_Current'Access, Program_Error'Identity,
            "Set_Current after Finish raises Program_Error");
        declare
            procedure Push is
            begin
                Surf.Push_Current (Surface);
            end Push;
            procedure Draw_Box is
            begin
                Surface.Draw_Widget (Shown);
            end Draw_Box;
        begin
            Raises (Push'Access, Program_Error'Identity,
                "Push_Current after Finish raises Program_Error");
            Raises (Draw_Box'Access, Program_Error'Identity,
                "Draw_Widget after Finish raises Program_Error");
        end;
        Check (Surf.Get_Original.Is_Current, "the original is still current");
    end;

    declare
        Text : constant String := Contents (Name);
    begin
        Check (Has (Text, "<svg") and Has (Text, "</svg>"), "the file is SVG");
        Check (Has (Text, ">text<"), "with its text");
        Check (Has (Text, "font-family=""Times""") and Has (Text, "font-size=""24"""),
            "in the font set");
        Check (Has (Text, "stroke-dasharray:7.000,3.000"), "and the dashes set");
    end;

    --  FLTK's close() would leave the Translate's group open (F18).
    declare
        Surface : SVG.SVG_File_Surface := SVG.Forge.Create (Name, 40, 40);
    begin
        Surface.Translate (5, 5);
        Surface.Translate (1, 1);
        Surf.Push_Current (Surface);
        Draw_Some;
        Surf.Pop_Current;
        Surface.Finish;
    end;
    declare
        Text : constant String := Contents (Name);
    begin
        Check (Count (Text, "<g") = Count (Text, "</g>"),
            "Finish closes the groups of a Translate not undone:"
            & Count (Text, "<g")'Image & Count (Text, "</g>")'Image);
    end;

    --  Finalizing it, unfinished, finishes it.
    declare
        Surface : SVG.SVG_File_Surface := SVG.Forge.Create (Name, 40, 40);
    begin
        Surface.Set_Current;
        Draw_Some;
    end;
    Check (Surf.Get_Original.Is_Current, "the original is current after it is finalized");
    Check (Has (Contents (Name), "</svg>"), "finalizing it unfinished writes the file");

    --  Nesting, with an image surface.
    declare
        Outer : SVG.SVG_File_Surface := SVG.Forge.Create (Name, 40, 40);
        Inner : FLTK.Devices.Surface.Image.Image_Surface :=
            FLTK.Devices.Surface.Image.Forge.Create (4, 4);
    begin
        Surf.Push_Current (Outer);
        Surf.Push_Current (Inner);
        Dr.Set_Color (FLTK.Red_Color);
        Dr.Rect_Fill (0, 0, 4, 4);
        Surf.Pop_Current;
        Check (Outer.Is_Current, "popping the image surface makes the SVG current again");
        Draw_Some;
        Surf.Pop_Current;
        Check (Surf.Get_Original.Is_Current, "and popping it, the original");
        Outer.Finish;
    end;

    --  Files that can't be written.
    declare
        procedure Open_Nowhere is
            Surface : SVG.SVG_File_Surface := SVG.Forge.Create (Nowhere, 20, 20);
        begin
            Surface.Finish;
        end Open_Nowhere;
    begin
        Raises (Open_Nowhere'Access, SVG.File_Open_Error'Identity,
            "a missing directory raises File_Open_Error");
    end;

    if not Ada.Directories.Exists ("/dev/full") then
        Skip ("no /dev/full");
    else
        declare
            Surface : SVG.SVG_File_Surface := SVG.Forge.Create ("/dev/full", 20, 20);

            procedure Finish is
            begin
                Surface.Finish;
            end Finish;
        begin
            Surf.Push_Current (Surface);
            Draw_Lots;
            Surf.Pop_Current;
            Raises (Finish'Access, SVG.File_Write_Error'Identity,
                "a full disk: Finish raises File_Write_Error, with no alert");
        end;
        declare
            Surface : SVG.SVG_File_Surface := SVG.Forge.Create ("/dev/full", 20, 20);
        begin
            Surf.Push_Current (Surface);
            Draw_Lots;
            Surf.Pop_Current;
        end;
        Check (True, "a full disk: finalizing it unfinished doesn't alert");
    end if;

    Ada.Directories.Delete_File (Name);

    Summary;

end Test_SVG_Surface;
