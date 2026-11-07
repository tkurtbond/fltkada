

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  The native dialogs, which only the user can answer: GTK's file chooser,
--  through Native_File_Chooser, and GTK's print dialog, through a
--  Printer's Start_Job.  It prints what to do before each one opens.  Run
--  it with make check-desktop, never headless and never by an agent
--  without asking the user first (AGENTS.md).


with

    Ada.Text_IO,
    Checks,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Native_File_Choosers;

use

    Checks;


procedure Test_Native_Dialogs is

    package NFC renames FLTK.Native_File_Choosers;
    package Pag renames FLTK.Devices.Surface.Paged;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;

    use type NFC.Show_Result;

    procedure Say
           (Text : in String) is
    begin
        Ada.Text_IO.Put_Line (">>> " & Text);
    end Say;

begin

    declare
        Chooser : NFC.Native_File_Chooser := NFC.Forge.Create (NFC.Browse_File);
        Result  : NFC.Show_Result;
    begin
        Say ("A file chooser titled ""Press Cancel"" opens.  Press Cancel.");
        Chooser.Set_Title ("Press Cancel");
        Result := Chooser.Show;
        Check (Result = NFC.Cancelled, "Native_File_Chooser: Cancel is Cancelled");
        Say ("A file chooser titled ""Pick a file"" opens.  Pick any file.");
        Chooser.Set_Title ("Pick a file");
        Result := Chooser.Show;
        Check (Result = NFC.Picked and then Chooser.Get_Filename'Length > 0,
            "a file picked is Picked, with its name: " & Chooser.Get_Filename);
    end;

    declare
        Device : Prn.Printer := Prn.Forge.Create;
    begin
        Say ("A print dialog opens.  Press Cancel.");
        Device.Start_Job (1);
        Check (False, "Printer: a cancelled print dialog raises Page_Error, but it didn't");
        Device.End_Job;
    exception
    when Pag.Page_Error =>
        Check (True, "Printer: a cancelled print dialog raises Page_Error");
    end;

    Summary;

end Test_Native_Dialogs;
