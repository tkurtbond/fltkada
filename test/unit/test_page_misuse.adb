--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 103: under Pango, Fl_PostScript_File_Device's
--  scale, rotate and origin restore Cairo state saved by begin_page
--  (Fl_PostScript.cxx:1852-1887, Fl_Cairo_Graphics_Driver.cxx:615-623), and
--  translate saves it, so outside a page they unbalance Cairo, and with no
--  job they use a null cairo_t.  The MEDIA format indexes page_formats out
--  of bounds (Fl_PostScript.cxx:1530-1543).


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


procedure Test_Page_Misuse is

    package PS renames FLTK.Devices.Surface.Paged.Postscript;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;
    package Dr renames FLTK.Draw;

    Name : constant String := "test_page_misuse.ps";

    type Misuse is access procedure
           (Device : in out FLTK.Devices.Surface.Paged.Paged_Device'Class);

    procedure Scale
           (Device : in out FLTK.Devices.Surface.Paged.Paged_Device'Class) is
    begin
        Device.Scale (2.0);
    end Scale;

    procedure Scale_XY
           (Device : in out FLTK.Devices.Surface.Paged.Paged_Device'Class) is
    begin
        Device.Scale (2.0, 3.0);
    end Scale_XY;

    procedure Rotate
           (Device : in out FLTK.Devices.Surface.Paged.Paged_Device'Class) is
    begin
        Device.Rotate (30.0);
    end Rotate;

    procedure Set_Origin
           (Device : in out FLTK.Devices.Surface.Paged.Paged_Device'Class) is
    begin
        Device.Set_Origin (20, 20);
    end Set_Origin;

    procedure Translate
           (Device : in out FLTK.Devices.Surface.Paged.Paged_Device'Class) is
    begin
        Device.Translate (20, 20);
    end Translate;

    type Moment is (No_Job, Before_Page, After_Page);

    --  Bad done at At_Time, outside a page: Bad raises Page_Error, and a job
    --  around it still writes its file.
    procedure Outside
           (Bad  : in Misuse;
            What : in String;
            At_Time : in Moment)
    is
        Raised : Boolean := False;
        Ended  : Boolean := True;
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        procedure Try is
        begin
            Bad (Device);
        exception
        when FLTK.Devices.Surface.Paged.Page_Error =>
            Raised := True;
        end Try;
    begin
        if At_Time = No_Job then
            Try;
            Check (Raised, What & " with no job raises Page_Error");
            return;
        end if;
        declare
            Output : PS.File_Type;
        begin
            Output.Open (Name);
            Device.Start_Job (Output, 1);
            if At_Time = Before_Page then
                Try;
            end if;
            Device.Start_Page;
            Dr.Line (10, 10, 100, 100);
            Device.End_Page;
            if At_Time = After_Page then
                Try;
            end if;
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
        Check (Raised, What & " " & Moment'Image (At_Time) & " raises Page_Error");
        Check (Ended and then Ada.Directories.Size (Name) > 1000,
            What & " " & Moment'Image (At_Time) & ", and the file is still written:"
            & Ada.Directories.File_Size'Image (Ada.Directories.Size (Name)));
        Ada.Directories.Delete_File (Name);
    end Outside;

    type Case_Entry is record
        Bad  : Misuse;
        What : access constant String;
    end record;

    Scale_Name      : aliased constant String := "Scale";
    Scale_XY_Name   : aliased constant String := "Scale (X, Y)";
    Rotate_Name     : aliased constant String := "Rotate";
    Set_Origin_Name : aliased constant String := "Set_Origin";
    Translate_Name  : aliased constant String := "Translate";

    Cases : constant array (1 .. 5) of Case_Entry :=
       ((Scale'Access, Scale_Name'Access),
        (Scale_XY'Access, Scale_XY_Name'Access),
        (Rotate'Access, Rotate_Name'Access),
        (Set_Origin'Access, Set_Origin_Name'Access),
        (Translate'Access, Translate_Name'Access));

begin

    --  All of them in a page: none raises, and the file is written.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
    begin
        Output.Open (Name);
        Device.Start_Job (Output, 1);
        Device.Start_Page;
        for C of Cases loop
            C.Bad (Device);
        end loop;
        Device.Untranslate;
        Dr.Line (10, 10, 100, 100);
        Device.End_Page;
        Device.End_Job;
        Output.Close;
    end;
    Check (Ada.Directories.Size (Name) > 1000, "in a page they work:"
        & Ada.Directories.File_Size'Image (Ada.Directories.Size (Name)));
    Ada.Directories.Delete_File (Name);

    --  The MEDIA format.
    declare
        Device : PS.Postscript_File_Device := PS.Forge.Create;
        Output : PS.File_Type;
        Raised : Boolean := False;
    begin
        Output.Open (Name);
        begin
            Device.Start_Job (Output, 1, Format => FLTK.Devices.Surface.Paged.Media);
        exception
        when Constraint_Error =>
            Raised := True;
        end;
        Check (Raised, "Start_Job with the Media format raises Constraint_Error");
        Device.Start_Job (Output, 1, Format => FLTK.Devices.Surface.Paged.Letter);
        Device.Start_Page;
        Dr.Line (10, 10, 100, 100);
        Device.End_Page;
        Device.End_Job;
        Output.Close;
        Check (Ada.Directories.Size (Name) > 1000, "a job after it is written:"
            & Ada.Directories.File_Size'Image (Ada.Directories.Size (Name)));
        Ada.Directories.Delete_File (Name);
    end;

    for At_Time in Before_Page .. After_Page loop
        for C of Cases loop
            Outside (C.Bad, C.What.all, At_Time);
        end loop;
    end loop;
    for C of Cases loop
        Outside (C.Bad, C.What.all, No_Job);
    end loop;

    --  A printer with no job, checked before any job, so without a dialog.
    declare
        Printer : Prn.Printer := Prn.Forge.Create;
        Raised  : Natural := 0;
    begin
        for C of Cases loop
            begin
                C.Bad (Printer);
            exception
            when FLTK.Devices.Surface.Paged.Page_Error =>
                Raised := Raised + 1;
            end;
        end loop;
        Check (Raised = Cases'Length, "a printer with no job raises:" & Integer'Image (Raised));
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Page_Misuse;
