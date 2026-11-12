--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 28: guards against memory errors that were only a Pre
--  or a pragma Assert, which a release build doesn't check.  Each call
--  here, unguarded, reads outside FLTK's memory or hands FLTK a null
--  object: Filenames.Item past the list's end reads past fl_filename_list's
--  array; Entry_Key and Group_Name past the last read past
--  Fl_Preferences::Node's arrays (Fl_Preferences.H:381,
--  Fl_Preferences.cxx:1881-1886); Frame_Image past the last frame gave
--  an image with no FLTK object, after growing a vector to the frame's
--  number; and Default_Window_Close of a widget never made called hide on
--  a null pointer.


with

    Ada.Exceptions,
    Checks,
    FLTK.Environment,
    FLTK.Filenames,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Images.RGB,
    FLTK.Static,
    FLTK.Widgets;

use

    Checks;


procedure Test_Index_Guards is

    package Anm renames FLTK.Images.Pixmaps.GIF.Animated;
    package Env renames FLTK.Environment;
    package Fnm renames FLTK.Filenames;

    List : constant Fnm.File_List := Fnm.Get_Listing ("../images/");

    Prefs : Env.Pref_Group := Env.Forge.In_Memory ("test_index_guards");

    Anim : Anm.Animated_GIF_Image :=
        Anm.Forge.Create ("../images/anim.gif", Anm.Flag_Dont_Start);

    Ignore : Integer;

    procedure Item_Past_End is
    begin
        Ignore := Fnm.Item (List, List.Length + 1)'Length;
    end Item_Past_End;

    procedure Item_Far_Past_End is
    begin
        Ignore := Fnm.Item (List, List.Length + 100_000)'Length;
    end Item_Far_Past_End;

    procedure Entry_Past_End is
    begin
        Ignore := Prefs.Entry_Key (Prefs.Number_Of_Entries + 1)'Length;
    end Entry_Past_End;

    procedure Entry_Far_Past_End is
    begin
        Ignore := Prefs.Entry_Key (Prefs.Number_Of_Entries + 100_000)'Length;
    end Entry_Far_Past_End;

    procedure Group_Past_End is
    begin
        Ignore := Prefs.Group_Name (Prefs.Number_Of_Groups + 1)'Length;
    end Group_Past_End;

    procedure Group_Far_Past_End is
    begin
        Ignore := Prefs.Group_Name (Prefs.Number_Of_Groups + 100_000)'Length;
    end Group_Far_Past_End;

    procedure Frame_Past_End is
        Image : constant FLTK.Images.RGB.RGB_Image_Reference :=
            Anim.Frame_Image (Anim.Frames + 1);
    begin
        Ignore := Image.Get_W;
    end Frame_Past_End;

    --  Not Integer'Last: unguarded, Frame_Image appends a wrapper for each
    --  frame up to this one, and Integer'Last took 28 GB before the kernel
    --  killed it (2026-11-12).  This is far enough to show the guard.
    procedure Frame_Far_Past_End is
        Image : constant FLTK.Images.RGB.RGB_Image_Reference :=
            Anim.Frame_Image (Anim.Frames + 100_000);
    begin
        Ignore := Image.Get_W;
    end Frame_Far_Past_End;

    procedure Close_Unmade is
        Unmade : FLTK.Widgets.Widget;
    begin
        FLTK.Static.Default_Window_Close (Unmade);
    end Close_Unmade;

begin

    --  Filenames.
    Check (List.Length > 2, "a directory to list:" & Natural'Image (List.Length));
    Check (Fnm.Item (List, List.Length)'Length > 0,
        "its last item: " & Fnm.Item (List, List.Length));
    Raises (Item_Past_End'Access, Constraint_Error'Identity, "Item past the last raises");
    Raises (Item_Far_Past_End'Access, Constraint_Error'Identity, "Item far past the last raises");

    --  Preferences, with two entries and two groups.
    Prefs.Set ("one", 1);
    Prefs.Set ("two", 2);
    declare
        A : constant Env.Pref_Group'Class := Env.Forge.By_Name (Prefs, "a");
        B : constant Env.Pref_Group'Class := Env.Forge.By_Name (Prefs, "b");
    begin
        Check (A.At_Name = "a" and B.At_Name = "b", "two groups");
        Check (Prefs.Entry_Key (2) = "two", "the last entry: " & Prefs.Entry_Key (2));
        Check (Prefs.Group_Name (2) = "b", "the last group: " & Prefs.Group_Name (2));
        Raises (Entry_Past_End'Access, Constraint_Error'Identity,
            "Entry_Key past the last raises");
        Raises (Entry_Far_Past_End'Access, Constraint_Error'Identity,
            "Entry_Key far past the last raises");
        Raises (Group_Past_End'Access, Constraint_Error'Identity,
            "Group_Name past the last raises");
        Raises (Group_Far_Past_End'Access, Constraint_Error'Identity,
            "Group_Name far past the last raises");
    end;

    --  An animated GIF's frames.
    Check (Anim.Is_Loaded and Anim.Frames > 1, "an animation:" & Integer'Image (Anim.Frames));
    Check (Anim.Frame_Image (Anim.Frames).Get_W > 0, "its last frame");
    Raises (Frame_Past_End'Access, Constraint_Error'Identity,
        "Frame_Image past the last raises");
    Raises (Frame_Far_Past_End'Access, Constraint_Error'Identity,
        "Frame_Image far past the last raises");

    --  A widget never made.
    Raises (Close_Unmade'Access, Program_Error'Identity,
        "Default_Window_Close of a widget never made raises");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Index_Guards;
