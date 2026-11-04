

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 101: under Pango, on any Cairo error,
--  Fl_PostScript_File_Device::end_job fcloses its file and then writes to
--  it (Fl_PostScript.cxx:1956-1959), and the File_Type closes it again.  A
--  Cairo error comes from a write that fails, such as to /dev/full, or from
--  drawing that Cairo refuses: an Untranslate with no Translate, a scale of
--  0, or a NaN.


with

    Ada.Directories,
    Ada.Exceptions,
    Checks,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Draw;

use

    Checks;

use type

    Ada.Directories.File_Size;


procedure Test_PS_Errors is

    package PS renames FLTK.Devices.Surface.Paged.Postscript;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;
    package Dr renames FLTK.Draw;

    Name : constant String := "test_ps_errors.ps";

    --  A variable, so that 0.0 / 0.0 isn't folded at compile time.
    Zero : Float := 0.0;
    pragma Warnings (Off, Zero);

    function Not_A_Number
        return Float is
    begin
        return Zero / Zero;
    end Not_A_Number;

    procedure Draw_Lots is
    begin
        for N in 1 .. 2000 loop
            Dr.Line (N mod 500, 10, 10, N mod 700);
            Dr.Draw_Text (10, N mod 700, "some text to make the file long");
        end loop;
    end Draw_Lots;

    type Misuse is access procedure
           (Device : in out PS.Postscript_File_Device);

    procedure Untranslate
           (Device : in out PS.Postscript_File_Device) is
    begin
        Device.Untranslate;
    end Untranslate;

    procedure Untranslate_Twice
           (Device : in out PS.Postscript_File_Device) is
    begin
        Device.Translate (10, 10);
        Device.Untranslate;
        Device.Untranslate;
    end Untranslate_Twice;

    procedure Scale_Zero
           (Device : in out PS.Postscript_File_Device) is
    begin
        Device.Scale (Zero);
    end Scale_Zero;

    procedure Scale_X_Zero
           (Device : in out PS.Postscript_File_Device) is
    begin
        Device.Scale (Zero, 2.0);
    end Scale_X_Zero;

    procedure Scale_NaN
           (Device : in out PS.Postscript_File_Device) is
    begin
        Device.Scale (2.0, Not_A_Number);
    end Scale_NaN;

    procedure Rotate_NaN
           (Device : in out PS.Postscript_File_Device) is
    begin
        Device.Rotate (Not_A_Number);
    end Rotate_NaN;

    --  A job in which Bad is done on the page: Bad raises
    --  Constraint_Error, and the job still ends and writes its file.
    procedure Refused
           (Bad  : in Misuse;
            What : in String)
    is
        Raised : Boolean := False;
        Ended  : Boolean := True;
    begin
        declare
            Device : PS.Postscript_File_Device := PS.Forge.Create;
            Output : PS.File_Type;
        begin
            Output.Open (Name);
            Device.Start_Job (Output, 1);
            Device.Start_Page;
            Dr.Line (10, 10, 100, 100);
            begin
                Bad (Device);
            exception
            when Constraint_Error =>
                Raised := True;
            end;
            Dr.Line (10, 100, 100, 10);
            Device.End_Page;
            begin
                Device.End_Job;
            exception
            when Occurrence : others =>
                Ended := False;
                Check (False, What & ": End_Job raised "
                    & Ada.Exceptions.Exception_Name (Occurrence));
            end;
            Output.Close;
        end;
        Check (Raised, What & " raises Constraint_Error");
        Check (Ended and then Ada.Directories.Size (Name) > 1000,
            What & ", and the file is still written:"
            & Ada.Directories.File_Size'Image (Ada.Directories.Size (Name)));
        Ada.Directories.Delete_File (Name);
    end Refused;

begin

    --  A write that fails.
    declare
        Device  : PS.Postscript_File_Device := PS.Forge.Create;
        Output  : PS.File_Type;
        Written : Boolean := True;
    begin
        Output.Open ("/dev/full");
        Device.Start_Job (Output, 1);
        Device.Start_Page;
        Draw_Lots;
        Device.End_Page;
        begin
            Device.End_Job;
        exception
        when PS.File_Write_Error =>
            Written := False;
        end;
        Check (not Written, "End_Job to /dev/full raises File_Write_Error");
        begin
            Output.Close;
        exception
        when PS.File_Close_Error =>
            null;
        end;
        Check (not Output.Is_Open, "the file is closed after it");
    end;

    --  A file not open.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
        Raised : Boolean := False;
    begin
        begin
            Device.Start_Job (Output, 1);
        exception
        when PS.File_Open_Error =>
            Raised := True;
        end;
        Check (Raised, "a job to a file not open raises File_Open_Error");
    end;

    --  A job after it, to a file, is written.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
    begin
        Output.Open (Name);
        Device.Start_Job (Output, 1);
        Device.Start_Page;
        Draw_Lots;
        Device.End_Page;
        Device.End_Job;
        Output.Close;
    end;
    Check (Ada.Directories.Size (Name) > 10_000, "a job after it is written:"
        & Ada.Directories.File_Size'Image (Ada.Directories.Size (Name)));
    Ada.Directories.Delete_File (Name);

    --  Drawing that Cairo refuses.
    Refused (Untranslate'Access, "an Untranslate with no Translate");
    Refused (Untranslate_Twice'Access, "an Untranslate after one for each Translate");
    Refused (Scale_Zero'Access, "a scale of 0");
    Refused (Scale_X_Zero'Access, "a scale of 0 across");
    Refused (Scale_NaN'Access, "a scale of NaN");
    Refused (Rotate_NaN'Access, "a rotation of NaN");

    --  A printer, the same; checked before any job, so without a dialog.
    declare
        Printer : Prn.Printer := Prn.Forge.Create;
        Raised  : Natural := 0;
    begin
        begin
            Printer.Untranslate;
        exception
        when Constraint_Error =>
            Raised := Raised + 1;
        end;
        begin
            Printer.Scale (Zero);
        exception
        when Constraint_Error =>
            Raised := Raised + 1;
        end;
        begin
            Printer.Rotate (Not_A_Number);
        exception
        when Constraint_Error =>
            Raised := Raised + 1;
        end;
        Check (Raised = 3, "a printer refuses them too:" & Integer'Image (Raised));
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_PS_Errors;
