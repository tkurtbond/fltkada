--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 104: an FLTK built with --disable-print has no
--  Fl_PostScript_File_Device::file_chooser_title (Fl_PostScript.cxx:18, 49),
--  so FLTKAda didn't link against it, and its Fl_Printer strings are all
--  null (Fl_Printer.cxx:21, 49-67), which Ada can't read as a String.  The
--  shim names the title weakly and gives "" for a null.  This FLTK prints,
--  so a run here checks the first case.  The raise in the other was checked
--  by putting in front of fl_postscript_file_device_supported one that gives
--  0 (LD_PRELOAD); the strings are then still FLTK's, so the other checks of
--  that case fail.  The weak reference was checked by a scratch C++ program
--  built with and without libfltk: its address was null without.


with

    Checks,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Devices.Surface.Paged.Printers;

use

    Checks,
    FLTK;


procedure Test_Print_Support is

    package PS  renames FLTK.Devices.Surface.Paged.Postscript;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;

    procedure Set_Title is
    begin
        PS.Set_File_Chooser_Title ("Pick a file");
    end Set_Title;

begin

    Check (PS.Is_Supported, "this FLTK prints");

    if PS.Is_Supported then
        Check (PS.Get_File_Chooser_Title = "Select a .ps file",
            "the chooser title is FLTK's: " & PS.Get_File_Chooser_Title);
        No_Raise (Set_Title'Access, "the chooser title can be set");
        Check (PS.Get_File_Chooser_Title = "Pick a file",
            "the chooser title reads back: " & PS.Get_File_Chooser_Title);
        Check (Prn.Get_Dialog_Title = "Print",
            "the print dialog title is FLTK's: " & Prn.Get_Dialog_Title);
    else
        Check (PS.Get_File_Chooser_Title = "", "with no printing the chooser title is empty");
        Raises (Set_Title'Access, Unsupported_Error'Identity,
            "with no printing the chooser title can't be set");
        Check (Prn.Get_Dialog_Title = "",
            "with no printing the print dialog title is empty: " & Prn.Get_Dialog_Title);
    end if;

    Summary;

end Test_Print_Support;
