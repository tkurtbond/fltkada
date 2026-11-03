

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 3: text on a PostScript page before any font is set
--  (pofltk 100).  FLTK 1.4.5 draws PostScript text with the display
--  driver's Pango font description, unchecked
--  (Fl_PostScript.cxx:1571), and there is none until a font is set.  So
--  the text calls here are the program's first.


with

    Ada.Directories,
    Checks,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Draw;

use

    Checks;

use type

    Ada.Directories.File_Size,
    FLTK.Font_Size;


procedure Test_Print_Font is

    package PS renames FLTK.Devices.Surface.Paged.Postscript;
    package Dr renames FLTK.Draw;

    Name : constant String := "test_print_font.ps";

begin

    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
    begin
        Output.Open (Name);
        Device.Start_Job (Output, 1);
        Device.Start_Page;
        Dr.Draw_Text (10, 20, "text");
        Check (Dr.Font_Line_Spacing > 0, "the page's line spacing is positive");
        Check (Dr.Width ("text") > 0.0, "the page's text width is positive");
        Check (Dr.Get_Font_Size = 14, "the page has FLTK's normal size:"
            & Integer'Image (Integer (Dr.Get_Font_Size)));
        Device.End_Page;
        Device.End_Job;
        Output.Close;
    end;

    Check (Ada.Directories.Size (Name) > 1000, "the PostScript file was written:"
        & Ada.Directories.File_Size'Image (Ada.Directories.Size (Name)));
    Ada.Directories.Delete_File (Name);

    Summary;

end Test_Print_Font;


