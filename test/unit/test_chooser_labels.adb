

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Bug 35 (FLTKAda-BUGS.md): File_Chooser's static labels.  A chooser's
--  constructor hands its widgets the static label pointers without copying
--  them, for example showChoice->label(show_label) (Fl_File_Chooser.cxx:181).
--  So a setter must not free a label an existing chooser still shows.  The
--  test sets each label, makes a chooser, sets the labels again, scribbles
--  over the heap with strings of the same size, and then looks for the first
--  labels in the shown chooser.


with

    Checks,
    FLTK.File_Choosers,
    FLTK.Probe,
    Interfaces.C.Strings;

use

    Checks,
    FLTK;


procedure Test_Chooser_Labels is

    package Prb renames FLTK.Probe;
    package FC  renames FLTK.File_Choosers;
    package ICS renames Interfaces.C.Strings;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    Junk      : array (1 .. 256) of ICS.chars_ptr := (others => ICS.Null_Ptr);
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

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    type Label_Kind is (Show, Favorites, Preview, Hidden, Filename, Tooltip, Save, Manage);

    --  Shown by a widget of the chooser's own window; Save and Manage are in
    --  the favorites window, which the test doesn't open.
    subtype Shown_Kind is Label_Kind range Show .. Tooltip;

    procedure Set
           (Kind : in Label_Kind;
            Text : in String) is
    begin
        case Kind is
            when Show      => FC.Set_Show_Label (Text);
            when Favorites => FC.Set_Favorites_Label (Text);
            when Preview   => FC.Set_Preview_Label (Text);
            when Hidden    => FC.Set_Hidden_Label (Text);
            when Filename  => FC.Set_Filename_Label (Text);
            when Tooltip   => FC.Set_New_Directory_Tooltip (Text);
            when Save      => FC.Set_Save_Label (Text);
            when Manage    => FC.Set_Manage_Favorites_Label (Text);
        end case;
    end Set;

    First : array (Label_Kind) of ICS.chars_ptr;

begin

    for Kind in Label_Kind loop
        First (Kind) := ICS.New_String (Fresh (Label_Kind'Image (Kind)));
        Set (Kind, ICS.Value (First (Kind)));
    end loop;

    declare
        Chooser : FC.File_Chooser := FC.Forge.Create ("Test_Chooser_Labels", "*", ".");
    begin
        --  New labels, for later choosers; this one keeps the first ones.
        for Kind in Label_Kind loop
            Set (Kind, Fresh (Label_Kind'Image (Kind)));
        end loop;
        for Kind in Label_Kind loop
            Scribble (Natural (ICS.Strlen (First (Kind))));
        end loop;

        Chooser.Show;
        while not Chooser.Is_Shown loop
            exit when FLTK.Wait < 0;
        end loop;
        Pump (5);
        for Kind in Shown_Kind loop
            Check (Prb.Has_Label (ICS.Value (First (Kind))),
                "an existing chooser still shows its " & Label_Kind'Image (Kind) & " label");
        end loop;
        Chooser.Hide;
        Pump (2);
    end;

    for Kind in Label_Kind loop
        ICS.Free (First (Kind));
    end loop;
    for J of Junk loop
        ICS.Free (J);
    end loop;
    Summary;

end Test_Chooser_Labels;

