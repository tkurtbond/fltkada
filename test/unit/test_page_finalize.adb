--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 75: Fl_PostScript_File_Device's begin_page pushes the
--  device on FLTK's stack of surfaces, and end_page pops it
--  (Fl_PostScript.cxx:1902, 1942).  A device finalized between them must
--  not be left there, or FLTK draws on, and makes current from, a device
--  it has freed.  End_Page outside a page would pop some other surface.


with

    Ada.Directories,
    Checks,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Draw;

use

    Checks;


procedure Test_Page_Finalize is

    package Surf renames FLTK.Devices.Surface;
    package PS renames FLTK.Devices.Surface.Paged.Postscript;

    Name : constant String := "test_page_finalize.ps";

begin

    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
    begin
        Output.Open (Name);
        Device.Start_Job (Output, 1);
        Device.Start_Page;
        Check (Device.Is_Current, "the page is drawn on");
        Check (Surf.Get_Current.Data.all in PS.Postscript_File_Device'Class,
            "Get_Current is the device during its page");
        FLTK.Draw.Rect_Fill (10, 10, 20, 20);
        Output.Close;
    end;

    Check (Surf.Get_Original.Is_Current,
        "the original surface is current after the device is finalized in a page");
    Check (Surf.Get_Current.Data.all not in PS.Postscript_File_Device'Class,
        "Get_Current isn't the device after it is finalized");

    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
    begin
        Output.Open (Name);
        Device.Start_Job (Output, 1);
        Device.Start_Page;
        begin
            Device.Start_Page;
            Check (False, "Start_Page in a page raises Page_Error");
        exception
            when FLTK.Devices.Surface.Paged.Page_Error =>
                Check (True, "Start_Page in a page raises Page_Error");
        end;
        Device.End_Page;
        Check (Surf.Get_Original.Is_Current, "End_Page makes the original current again");
        Check (Surf.Get_Current.Data.all not in PS.Postscript_File_Device'Class,
            "Get_Current isn't the device after End_Page");

        --  FLTK's end_page would pop the original surface.
        begin
            Device.End_Page;
            Check (False, "End_Page outside a page raises Page_Error");
        exception
            when FLTK.Devices.Surface.Paged.Page_Error =>
                Check (True, "End_Page outside a page raises Page_Error");
        end;
        Check (Surf.Get_Original.Is_Current,
            "the original is still current after End_Page outside a page");
        Device.End_Job;
        Output.Close;
    end;

    Ada.Directories.Delete_File (Name);

    Summary;

end Test_Page_Finalize;
