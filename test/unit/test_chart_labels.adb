


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 65: an Fl_Chart entry keeps 18 bytes of its
--  label, cut with strlcpy (Fl_Chart.cxx:394, 430, 453), which can leave
--  the first byte of a UTF-8 character whose last crosses the 18th.  FLTK
--  keeps no way to read a label back, so each chart is drawn into an image
--  surface and compared with one labelled as the cut should leave it.


with

    Ada.Exceptions,
    Checks,
    FLTK.Devices.Surface.Image,
    FLTK.Images.RGB,
    FLTK.Widgets.Charts;

use

    Checks,
    FLTK;


procedure Test_Chart_Labels is

    package Img renames FLTK.Devices.Surface.Image;
    package Chr renames FLTK.Widgets.Charts;

    E_Acute : constant String := Character'Val (16#C3#) & Character'Val (16#A9#);
    Euro    : constant String :=
        Character'Val (16#E2#) & Character'Val (16#82#) & Character'Val (16#AC#);
    Clef    : constant String :=
        Character'Val (16#F0#) & Character'Val (16#9D#) & Character'Val (16#84#)
        & Character'Val (16#9E#);

    function A_s
           (N : in Natural)
        return String is
    begin
        return (1 .. N => 'a');
    end A_s;

    type Way is (By_Add, By_Insert, By_Replace);

    --  A pie chart, which draws each label beside its slice, with one
    --  entry labelled Text, put there in the given way.
    function Picture
           (Text : in String;
            How  : in Way)
        return Color_Component_Array
    is
        The_Chart : Chr.Chart := Chr.Forge.Create (0, 0, 300, 200);
        Surface   : Img.Image_Surface := Img.Forge.Create (300, 200);
    begin
        The_Chart.Set_Kind (Chr.Pie_Chart);
        The_Chart.Set_Text_Size (14);
        case How is
        when By_Add =>
            The_Chart.Add (1.0, Text, Red_Color);
        when By_Insert =>
            The_Chart.Add (1.0, "x", Red_Color);
            The_Chart.Insert (1, 1.0, Text, Red_Color);
            The_Chart.Replace (2, 1.0, "", Red_Color);
        when By_Replace =>
            The_Chart.Add (1.0, "x", Red_Color);
            The_Chart.Replace (1, 1.0, Text, Red_Color);
        end case;
        Surface.Draw_Widget (The_Chart);
        declare
            Shot : constant FLTK.Images.RGB.RGB_Image := Surface.Get_Image;
        begin
            return Shot.All_Data;
        end;
    end Picture;

    procedure Same
           (Text, As : in String;
            Message  : in String) is
    begin
        for How in Way loop
            Check (Picture (Text, How) = Picture (As, How),
                Message & ", by " & Way'Image (How));
        end loop;
    end Same;

begin

    --  The test can see the difference a character makes.
    Check (Picture (A_s (16) & E_Acute, By_Add) /= Picture (A_s (16), By_Add),
        "a label's last character is drawn");

    Same (A_s (16) & E_Acute, A_s (16) & E_Acute, "a label that fits is kept whole");
    Same (A_s (17) & E_Acute, A_s (17), "a two-byte character across the 18th byte is cut");
    Same (A_s (16) & Euro, A_s (16), "a three-byte character across the 18th byte is cut");
    Same (A_s (15) & Clef & "b", A_s (15), "a four-byte character across the 18th byte is cut");
    Same (A_s (18) & E_Acute, A_s (18), "a character after the 18th byte is cut");
    Same (A_s (16) & E_Acute & "bb", A_s (16) & E_Acute,
        "a character ending at the 18th byte is kept");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Chart_Labels;


