

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 130.  FLTK's font table holds its 16 built-in
--  fonts until Fl::set_font or Fl::set_fonts grows it (fl_set_font.cxx:45-
--  68), so Free_Font is past its end, and Fl::get_font reads garbage.  An
--  empty slot crashes Fl::get_font_name on Cairo, which copies the name
--  before it tests it (Fl_Cairo_Graphics_Driver.cxx:1176), and a name of
--  127 bytes or more overruns its fontname[128].  This test must be the
--  first in its process to use Free_Font.


with

    Ada.Exceptions,
    Checks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Free_Font is

    package Bx  renames FLTK.Widgets.Boxes;
    package Sta renames FLTK.Static;
    package Win renames FLTK.Widgets.Groups.Windows;

    Ignore_Done : Boolean;

    procedure Pump
           (Times : in Positive) is
    begin
        for N in 1 .. Times loop
            Ignore_Done := FLTK.Wait (0.02) < 0.0;
        end loop;
    end Pump;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 60, "Test_Free_Font");

    Free_Box : Bx.Box := Bx.Forge.Create (Window, Flat_Box, 10, 10, 280, 40, "Free");

    Count : Natural;

begin

    --  Before anything grows the table.
    Check (Sta.Font_Image (Free_Font) = "", "Free_Font before it is set: "
        & Sta.Font_Image (Free_Font));
    Check (Sta.Font_Family_Image (Free_Font) = "", "Free_Font's family before it is set");
    Check (Sta.Font_Sizes (Free_Font)'Length <= 1, "Free_Font's sizes before it is set");
    Check (Sta.Font_Image (Helvetica) /= "", "a built-in font: " & Sta.Font_Image (Helvetica));

    --  An empty slot draws.
    Free_Box.Set_Label_Font (Free_Font);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Pump (5);

    Sta.Set_Font_Kind (Free_Font, "Serif");
    Check (Sta.Font_Image (Free_Font) = "Serif"
        and then Sta.Font_Family_Image (Free_Font) = "Serif",
        "Free_Font set: " & Sta.Font_Image (Free_Font) & ", " & Sta.Font_Family_Image (Free_Font));
    Free_Box.Redraw;
    Pump (5);

    --  A name too long is cut short, at a character's boundary.
    Sta.Set_Font_Kind (Free_Font, (1 .. 150 => 'A'));
    Check (Sta.Font_Image (Free_Font) = (1 .. 126 => 'A')
        and then Sta.Font_Family_Image (Free_Font) = (1 .. 126 => 'A'),
        "a name too long is cut to 126 bytes:"
        & Integer'Image (Sta.Font_Family_Image (Free_Font)'Length));
    Sta.Set_Font_Kind (Free_Font, (1 .. 125 => 'B') & Character'Val (16#C3#)
        & Character'Val (16#A9#));
    Check (Sta.Font_Image (Free_Font) = (1 .. 125 => 'B'),
        "a name is cut before a character, not in it:"
        & Integer'Image (Sta.Font_Image (Free_Font)'Length));
    Sta.Set_Font_Kind (Free_Font, (1 .. 124 => 'C') & Character'Val (16#C3#)
        & Character'Val (16#A9#) & "D");
    Check (Sta.Font_Image (Free_Font) = (1 .. 124 => 'C') & Character'Val (16#C3#)
        & Character'Val (16#A9#), "a character ending at 126 bytes is kept");
    Free_Box.Redraw;
    Pump (5);

    Sta.Set_Font_Kind (Free_Font, Helvetica);
    Check (Sta.Font_Image (Free_Font) = Sta.Font_Image (Helvetica),
        "Free_Font copied from another");

    Sta.Setup_Fonts (Count);
    Check (Count > 0 and then Sta.Font_Image (Free_Font) /= "",
        "the fonts set up:" & Integer'Image (Count) & ", " & Sta.Font_Image (Free_Font));
    Free_Box.Redraw;
    Pump (5);

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Free_Font;
