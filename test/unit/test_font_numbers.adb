--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTKAda-BUGS.md 88: Setup_Fonts (Fl::set_fonts) adds the system's fonts
--  from Free_Font on, and Fl::set_font any font number, but Font_Kind was
--  an enumeration of the 17 built-in fonts, which could name none of them.
--  Font_Kind is now FLTK's font number.  FLTK doesn't check a number
--  against its table (pofltk 130), so FLTKAda raises Constraint_Error on a
--  font past Last_Font, and on setting one past Max_Font.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Font_Numbers is

    package Bx  renames FLTK.Widgets.Boxes;
    package Drw renames FLTK.Draw;
    package Sta renames FLTK.Static;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Sta.Font_Attributes;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 60, "Test_Font_Numbers");

    System_Box : Bx.Box := Bx.Forge.Create (Window, Flat_Box, 10, 10, 280, 40, "System");

    Count : Natural;

    System_Font : constant Font_Kind := Free_Font + 1;

    procedure Raises
           (Name : in String;
            Call : not null access procedure)
    is
    begin
        Call.all;
        Check (False, Name & " raises Constraint_Error, but returned");
    exception
    when Constraint_Error =>
        Check (True, Name & " raises Constraint_Error");
    end Raises;

    procedure Image_Past_End is
        Ignore : constant String := Sta.Font_Image (Sta.Last_Font + 1);
    begin
        null;
    end Image_Past_End;

    procedure Family_Past_End is
        Ignore : constant String := Sta.Font_Family_Image (Sta.Last_Font + 1);
    begin
        null;
    end Family_Past_End;

    procedure Sizes_Past_End is
        Ignore : constant Font_Size_Array := Sta.Font_Sizes (Sta.Last_Font + 1);
    begin
        null;
    end Sizes_Past_End;

    procedure Copy_From_Past_End is
    begin
        Sta.Set_Font_Kind (Free_Font, Sta.Last_Font + 1);
    end Copy_From_Past_End;

    procedure Set_Past_Max is
    begin
        Sta.Set_Font_Kind (Sta.Max_Font + 1, "Serif");
    end Set_Past_Max;

    procedure Label_Past_End is
    begin
        System_Box.Set_Label_Font (Sta.Last_Font + 1);
    end Label_Past_End;

    procedure Height_Past_End is
        Ignore : constant Natural := Drw.Font_Height (Sta.Last_Font + 1, 14);
    begin
        null;
    end Height_Past_End;

begin

    Check (Sta.Last_Font = Free_Font, "before Setup_Fonts, Free_Font is the last:"
        & Font_Kind'Image (Sta.Last_Font));
    Raises ("Font_Image of the font after Free_Font", Image_Past_End'Access);

    Sta.Setup_Fonts (Count);
    Check (Count > Natural (System_Font),
        "Setup_Fonts found system fonts:" & Natural'Image (Count));
    Check (Sta.Last_Font = Font_Kind (Count - 1),
        "Last_Font is Setup_Fonts' count less one:" & Font_Kind'Image (Sta.Last_Font));

    --  A system font is named, sized and drawn in.
    Check (Sta.Font_Image (System_Font) /= "", "a system font: " & Sta.Font_Image (System_Font));
    Check (Sta.Font_Family_Image (System_Font) /= "",
        "its family: " & Sta.Font_Family_Image (System_Font));
    Check (Sta.Font_Sizes (System_Font)'Length >= 1, "it has sizes");
    Check (Drw.Font_Height (System_Font, 14) > 0, "it has a height");
    System_Box.Set_Label_Font (System_Font);
    Check (System_Box.Get_Label_Font = System_Font,
        "a box's label font reads back as the system font:"
        & Font_Kind'Image (System_Box.Get_Label_Font));
    System_Box.Set_Label_Font (Sta.Last_Font);
    Check (System_Box.Get_Label_Font = Sta.Last_Font, "and so does the last font");
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (5);

    --  Attributes, as Fl::get_font_name gives them.
    Check (Sta.Font_Family_Attributes (Helvetica) = (Bold => False, Italic => False),
        "Helvetica is plain");
    Check (Sta.Font_Family_Attributes (Helvetica_Bold) = (Bold => True, Italic => False),
        "Helvetica_Bold is bold");
    Check (Sta.Font_Family_Attributes (Times_Italic) = (Bold => False, Italic => True),
        "Times_Italic is italic");
    Check (Sta.Font_Family_Attributes (Courier_Bold_Italic) = (Bold => True, Italic => True),
        "Courier_Bold_Italic is bold and italic");

    --  Past the table.
    Raises ("Font_Image past Last_Font", Image_Past_End'Access);
    Raises ("Font_Family_Image past Last_Font", Family_Past_End'Access);
    Raises ("Font_Sizes past Last_Font", Sizes_Past_End'Access);
    Raises ("Set_Font_Kind from a font past Last_Font", Copy_From_Past_End'Access);
    Raises ("Set_Label_Font past Last_Font", Label_Past_End'Access);
    Raises ("Font_Height past Last_Font", Height_Past_End'Access);
    Raises ("Set_Font_Kind past Max_Font", Set_Past_Max'Access);

    --  Setting a font past the table grows it, and leaves a gap of empty
    --  fonts, whose images are "".
    declare
        Old_Last : constant Font_Kind := Sta.Last_Font;
    begin
        Sta.Set_Font_Kind (Old_Last + 5, Sta.Font_Image (Helvetica));
        Check (Sta.Last_Font = Old_Last + 5, "setting a font past the last grows the table");
        Check (Sta.Font_Image (Old_Last + 5) = Sta.Font_Image (Helvetica), "and names it");
        Check (Sta.Font_Image (Old_Last + 2) = ""
            and then Sta.Font_Family_Image (Old_Last + 2) = "",
            "a font in the gap is empty");
        Check (Sta.Font_Family_Attributes (Old_Last + 2) = (Bold => False, Italic => False),
            "and plain");
    end;

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Font_Numbers;
