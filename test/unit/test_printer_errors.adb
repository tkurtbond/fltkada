

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 85 and 140: Printer.Start_Job's results.  FLTK's
--  begin_job returns 1 if the user cancels and 2, with a message, if the
--  job can't start (Fl_Posix_Printer_Driver.cxx:293, 366-372).  Start_Job
--  raised Page_Error for both, with no message; it should raise
--  User_Cancel_Error for a cancel and Page_Error with FLTK's message for a
--  failure.  And the form with From and To copied back FLTK's page numbers
--  even when FLTK hadn't set them (bug 140).
--
--  The test drives FLTK's own print panel, not GTK's dialog.  A fake lpstat
--  on PATH gives the panel a printer, and a fake lp prints to a file here.
--  A failure is popen failing to start lp, with this process allowed no
--  other (FLTK.Probe.Limit_Processes).  Bug 140's copy back of numbers
--  FLTK never set showed as two uses of uninitialised values under
--  valgrind, from the cancelled job with a range.


with

    Ada.Directories,
    Ada.Environment_Variables,
    Ada.Exceptions,
    Ada.Strings.Fixed,
    Ada.Text_IO,
    Checks,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Probe,
    FLTK.Static,
    GNAT.OS_Lib;

use

    Checks,
    FLTK;


procedure Test_Printer_Errors is

    package Dir renames Ada.Directories;
    package Env renames Ada.Environment_Variables;
    package Prb renames FLTK.Probe;
    package Pgd renames FLTK.Devices.Surface.Paged;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;

    use type Dir.File_Size;

    Where   : constant String := Dir.Current_Directory & "/test_printer_errors.tmp";
    Printed : constant String := Where & "/printed.ps";

    --  The fake printer, item 1 in the panel's Printer choice; item 0 is
    --  printing to a file.
    Printer_Name : constant String := "fakejet";

    procedure Script
           (Name, Text : in String)
    is
        File : Ada.Text_IO.File_Type;
    begin
        Ada.Text_IO.Create (File, Ada.Text_IO.Out_File, Where & "/" & Name);
        Ada.Text_IO.Put_Line (File, "#!/bin/sh");
        Ada.Text_IO.Put_Line (File, Text);
        Ada.Text_IO.Close (File);
        GNAT.OS_Lib.Set_Executable (Where & "/" & Name);
    end Script;

    function Has
           (Text, Part : in String)
        return Boolean is
    begin
        return Ada.Strings.Fixed.Index (Text, Part) > 0;
    end Has;

    type Answer is (Cancel, Print, Print_Unable);

    Action : Answer := Cancel;

    --  What the panel showed as its printer.
    Shown_Printer : String (1 .. 32);
    Shown_Last    : Natural := 0;

    --  Waits for the panel and answers it as Action says.
    procedure Answer_Panel is
    begin
        if not Prb.Modal then
            FLTK.Static.Add_Timeout (0.1, Answer_Panel'Unrestricted_Access);
            return;
        end if;
        case Action is
        when Cancel =>
            Check (Prb.Close_Modal, "the panel is cancelled");
        when Print | Print_Unable =>
            Check (Prb.Choose_In_Modal ("Printer:", 1), "the fake printer is chosen");
            declare
                Chosen : constant String := Prb.Chosen_In_Modal ("Printer:");
            begin
                Shown_Last := Integer'Min (Chosen'Length, Shown_Printer'Length);
                Shown_Printer (1 .. Shown_Last) :=
                    Chosen (Chosen'First .. Chosen'First + Shown_Last - 1);
            end;
            if Action = Print_Unable then
                Prb.Limit_Processes (True);
            end if;
            Check (Prb.Press_In_Modal ("Print"), "Print is pressed");
        end case;
    end Answer_Panel;

    procedure Start
           (What : in Answer) is
    begin
        Action := What;
        FLTK.Static.Add_Timeout (0.2, Answer_Panel'Unrestricted_Access);
    end Start;

    procedure Cancelled
           (Job : in out Prn.Printer) is
    begin
        Start (Cancel);
        Job.Start_Job (1);
        Check (False, "a cancelled job raises User_Cancel_Error, not starting");
        Job.End_Job;
    exception
        when Prn.User_Cancel_Error =>
            Check (True, "a cancelled job raises User_Cancel_Error");
        when Occurrence : others =>
            Check (False, "a cancelled job raises User_Cancel_Error, not " &
                Ada.Exceptions.Exception_Information (Occurrence));
    end Cancelled;

    procedure Cancelled_Range
           (Job : in out Prn.Printer)
    is
        From, To : Positive;
    begin
        Start (Cancel);
        Job.Start_Job (1, From, To);
        Check (False, "a cancelled job with a range raises User_Cancel_Error, not starting");
        Job.End_Job;
    exception
        when Prn.User_Cancel_Error =>
            Check (True, "a cancelled job with a range raises User_Cancel_Error");
        when Occurrence : others =>
            Check (False, "a cancelled job with a range raises User_Cancel_Error, not " &
                Ada.Exceptions.Exception_Information (Occurrence));
    end Cancelled_Range;

    procedure Printing
           (Job : in out Prn.Printer)
    is
        From, To : Positive := 99;
    begin
        Start (Print);
        Job.Start_Job (3, From, To);
        Check (Shown_Printer (1 .. Shown_Last) = Printer_Name,
            "the panel offers the fake printer: " & Shown_Printer (1 .. Shown_Last));
        Check (From = 1 and To = 3, "a job of 3 pages prints 1 to 3:" &
            Integer'Image (From) & Integer'Image (To));
        Job.Start_Page;
        Job.End_Page;
        Job.End_Job;
        Check (Dir.Exists (Printed) and then Dir.Size (Printed) > 0,
            "and lp has the job in " & Printed);
        if Dir.Exists (Printed) then
            declare
                File : Ada.Text_IO.File_Type;
            begin
                Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Printed);
                declare
                    Line : constant String := Ada.Text_IO.Get_Line (File);
                begin
                    Check (Line'Length >= 4 and then Line (Line'First .. Line'First + 3) = "%!PS",
                        "it is PostScript: " & Line);
                end;
                Ada.Text_IO.Close (File);
            end;
        end if;
    exception
        when Occurrence : others =>
            Check (False, "a job to the fake printer starts, not " &
                Ada.Exceptions.Exception_Information (Occurrence));
    end Printing;

    procedure Unable
           (Job : in out Prn.Printer) is
    begin
        Start (Print_Unable);
        Job.Start_Job (1);
        Prb.Limit_Processes (False);
        Check (False, "a job lp can't run for raises Page_Error, not starting");
        Job.End_Job;
    exception
        when Occurrence : Pgd.Page_Error =>
            Prb.Limit_Processes (False);
            declare
                Message : constant String := Ada.Exceptions.Exception_Message (Occurrence);
            begin
                Check (Has (Message, "could not run command") and Has (Message, Printer_Name),
                    "a job lp can't run for raises Page_Error with FLTK's message: " & Message);
            end;
        when Occurrence : others =>
            Prb.Limit_Processes (False);
            Check (False, "a job lp can't run for raises Page_Error, not " &
                Ada.Exceptions.Exception_Information (Occurrence));
    end Unable;

begin

    if Dir.Exists (Where) then
        Dir.Delete_Tree (Where);
    end if;
    Dir.Create_Directory (Where);
    Script ("lpstat",
        "echo 'printer " & Printer_Name & " is idle.  enabled since today'" & ASCII.LF &
        "echo 'system default destination: " & Printer_Name & "'");
    Script ("lp", "cat > '" & Printed & "'");
    Env.Set ("PATH", Where & ":" &
        (if Env.Exists ("PATH") then Env.Value ("PATH") else "/usr/bin:/bin"));

    --  FLTK's own panel, not GTK's dialog.
    Prb.Set_Printer_Uses_GTK (False);

    declare
        Job : Prn.Printer := Prn.Forge.Create;
    begin
        Cancelled (Job);
        Cancelled_Range (Job);
        Printing (Job);
        Unable (Job);
    end;

    Dir.Delete_Tree (Where);
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Printer_Errors;

