

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 36 (FLTKAda-BUGS.md): the printer dialog's static labels.  FLTK builds
--  its print panel once, the first time a job starts, and keeps it
--  (Fl_Posix_Printer_Driver.cxx:282).  The panel's widgets get the static
--  label pointers without copies (print_panel.cxx:249-503).  So a setter must
--  not free a label the panel still shows.  The test sets each label and starts
--  a job, which builds the panel.  Then it sets the labels again, scribbles
--  over the heap with strings of the same size, starts a second job, and looks
--  for the first labels in the panel.  The properties panel isn't opened, so
--  its six labels rest on valgrind.  Print_To_File is copied by a menu add.


with

    Checks,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Probe,
    FLTK.Static,
    Interfaces.C.Strings;

use

    Checks,
    FLTK;


procedure Test_Printer_Labels is

    package Prb renames FLTK.Probe;
    package Pgd renames FLTK.Devices.Surface.Paged;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;
    package ICS renames Interfaces.C.Strings;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    Junk      : array (1 .. 512) of ICS.chars_ptr := (others => ICS.Null_Ptr);
    Junk_Next : Positive := Junk'First;

    --  Takes back freed blocks of Length + 1 bytes and fills them with 'X's.
    procedure Scribble
           (Length : in Positive) is
    begin
        for N in 1 .. 32 loop
            ICS.Free (Junk (Junk_Next));
            Junk (Junk_Next) := ICS.New_String ((1 .. Length => 'X'));
            Junk_Next := (if Junk_Next = Junk'Last then Junk'First else Junk_Next + 1);
        end loop;
    end Scribble;

    type Label_Kind is
       (Title, Printer, Properties, Print_Range, All_Pages, Pages, From, To, Copies,
        Number_Copies, Print_Button, Cancel_Button,
        Print_To_File,
        Property_Title, Page_Size, Mode, Use_Button, Save, Property_Cancel);

    --  Shown by the print panel itself.
    subtype Shown_Kind is Label_Kind range Title .. Cancel_Button;

    procedure Set
           (Kind : in Label_Kind;
            Text : in String) is
    begin
        case Kind is
            when Title           => Prn.Set_Dialog_Title (Text);
            when Printer         => Prn.Set_Dialog_Printer (Text);
            when Properties      => Prn.Set_Dialog_Properties (Text);
            when Print_Range     => Prn.Set_Dialog_Range (Text);
            when All_Pages       => Prn.Set_Dialog_All (Text);
            when Pages           => Prn.Set_Dialog_Pages (Text);
            when From            => Prn.Set_Dialog_From (Text);
            when To              => Prn.Set_Dialog_To (Text);
            when Copies          => Prn.Set_Dialog_Copies (Text);
            when Number_Copies   => Prn.Set_Dialog_Number_Copies (Text);
            when Print_Button    => Prn.Set_Dialog_Print_Button (Text);
            when Cancel_Button   => Prn.Set_Dialog_Cancel_Button (Text);
            when Print_To_File   => Prn.Set_Dialog_Print_To_File (Text);
            when Property_Title  => Prn.Set_Property_Title (Text);
            when Page_Size       => Prn.Set_Property_Page_Size (Text);
            when Mode            => Prn.Set_Property_Mode (Text);
            when Use_Button      => Prn.Set_Property_Use (Text);
            when Save            => Prn.Set_Property_Save (Text);
            when Property_Cancel => Prn.Set_Property_Cancel (Text);
        end case;
    end Set;

    First : array (Label_Kind) of ICS.chars_ptr;

    Looking : Boolean := False;

    Found : array (Shown_Kind) of Boolean := (others => False);

    --  Waits for the panel, notes which first labels it shows, and closes it.
    procedure Look_And_Close is
    begin
        if Looking then
            for Kind in Shown_Kind loop
                Found (Kind) := Prb.Has_Label (ICS.Value (First (Kind)));
            end loop;
        end if;
        if not Prb.Close_Modal then
            FLTK.Static.Add_Timeout (0.1, Look_And_Close'Unrestricted_Access);
        end if;
    end Look_And_Close;

    --  Starts a job and lets Look_And_Close cancel it.
    procedure Cancel_Job
           (This : in out Prn.Printer;
            Name : in     String) is
    begin
        FLTK.Static.Add_Timeout (0.2, Look_And_Close'Unrestricted_Access);
        This.Start_Job (1);
        Check (False, Name & " is cancelled");
        This.End_Job;
    exception
        when Pgd.Page_Error =>
            Check (True, Name & " is cancelled");
    end Cancel_Job;

begin

    --  FLTK's own panel, not GTK's dialog, which copies its title.
    Prb.Set_Printer_Uses_GTK (False);

    for Kind in Label_Kind loop
        First (Kind) := ICS.New_String (Fresh (Label_Kind'Image (Kind)));
        Set (Kind, ICS.Value (First (Kind)));
    end loop;

    declare
        Job : Prn.Printer := Prn.Forge.Create;
    begin
        Cancel_Job (Job, "the first job");

        --  New labels; FLTK's panel keeps the first ones.
        for Kind in Label_Kind loop
            Set (Kind, Fresh (Label_Kind'Image (Kind)));
        end loop;
        for Kind in Label_Kind loop
            Scribble (Natural (ICS.Strlen (First (Kind))));
        end loop;

        Looking := True;
        Cancel_Job (Job, "the second job");
        for Kind in Shown_Kind loop
            Check (Found (Kind),
                "the kept print panel still shows its " & Label_Kind'Image (Kind) & " label");
        end loop;
    end;

    for Kind in Label_Kind loop
        ICS.Free (First (Kind));
    end loop;
    for J of Junk loop
        ICS.Free (J);
    end loop;
    Summary;

end Test_Printer_Labels;

