--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.
--
--  Written by tools/gen-constants.py; edit that, not this.


--  Checks each of FLTKAda's constants against FLTK's value, from
--  c_cairo_constants.cpp.  A child of FLTK, so it can see the private
--  conversions.  Run by test_cairo_constants.adb.


with

    Checks,
    FLTK.Cairo;


procedure FLTK.Test_Cairo_Constants is


    package Cairo renames FLTK.Cairo;


    type Value_Array is array (1 .. 16) of Long_Long_Integer;
    pragma Convention (C, Value_Array);

    FLTK_Values : Value_Array;
    pragma Import (C, FLTK_Values, "c_cairo_constants");


    procedure Same
           (Ada_Value : in Long_Long_Integer;
            Index     : in Positive;
            Label     : in String)
    is
        FLTK_Value : constant Long_Long_Integer := FLTK_Values (Index);
    begin
        if Ada_Value = FLTK_Value then
            Checks.Check (True, Label & " =" & Long_Long_Integer'Image (FLTK_Value));
        else
            Checks.Check
               (False, Label & ": FLTKAda has" & Long_Long_Integer'Image (Ada_Value) &
                ", FLTK" & Long_Long_Integer'Image (FLTK_Value));
        end if;
    end Same;


begin

    --  Font slants (cairo_font_slant_t)
    Same
       (Cairo.Font_Slant'Pos (Cairo.Normal_Slant),
        1,
        "Cairo.Font_Slant'Pos (Cairo.Normal_Slant) = CAIRO_FONT_SLANT_NORMAL");
    Same
       (Cairo.Font_Slant'Pos (Cairo.Italic_Slant),
        2,
        "Cairo.Font_Slant'Pos (Cairo.Italic_Slant) = CAIRO_FONT_SLANT_ITALIC");
    Same
       (Cairo.Font_Slant'Pos (Cairo.Oblique_Slant),
        3,
        "Cairo.Font_Slant'Pos (Cairo.Oblique_Slant) = CAIRO_FONT_SLANT_OBLIQUE");

    --  Font weights (cairo_font_weight_t)
    Same
       (Cairo.Font_Weight'Pos (Cairo.Normal_Weight),
        4,
        "Cairo.Font_Weight'Pos (Cairo.Normal_Weight) = CAIRO_FONT_WEIGHT_NORMAL");
    Same
       (Cairo.Font_Weight'Pos (Cairo.Bold_Weight),
        5,
        "Cairo.Font_Weight'Pos (Cairo.Bold_Weight) = CAIRO_FONT_WEIGHT_BOLD");

    --  Antialiasing (cairo_antialias_t)
    Same
       (Cairo.Antialias_Mode'Pos (Cairo.Default_Antialias),
        6,
        "Cairo.Antialias_Mode'Pos (Cairo.Default_Antialias) = CAIRO_ANTIALIAS_DEFAULT");
    Same
       (Cairo.Antialias_Mode'Pos (Cairo.No_Antialias),
        7,
        "Cairo.Antialias_Mode'Pos (Cairo.No_Antialias) = CAIRO_ANTIALIAS_NONE");
    Same
       (Cairo.Antialias_Mode'Pos (Cairo.Gray_Antialias),
        8,
        "Cairo.Antialias_Mode'Pos (Cairo.Gray_Antialias) = CAIRO_ANTIALIAS_GRAY");
    Same
       (Cairo.Antialias_Mode'Pos (Cairo.Subpixel_Antialias),
        9,
        "Cairo.Antialias_Mode'Pos (Cairo.Subpixel_Antialias) = CAIRO_ANTIALIAS_SUBPIXEL");
    Same
       (Cairo.Antialias_Mode'Pos (Cairo.Fast_Antialias),
        10,
        "Cairo.Antialias_Mode'Pos (Cairo.Fast_Antialias) = CAIRO_ANTIALIAS_FAST");
    Same
       (Cairo.Antialias_Mode'Pos (Cairo.Good_Antialias),
        11,
        "Cairo.Antialias_Mode'Pos (Cairo.Good_Antialias) = CAIRO_ANTIALIAS_GOOD");
    Same
       (Cairo.Antialias_Mode'Pos (Cairo.Best_Antialias),
        12,
        "Cairo.Antialias_Mode'Pos (Cairo.Best_Antialias) = CAIRO_ANTIALIAS_BEST");

    --  Pattern extends (cairo_extend_t)
    Same
       (Cairo.Extend_Mode'Pos (Cairo.No_Extend),
        13,
        "Cairo.Extend_Mode'Pos (Cairo.No_Extend) = CAIRO_EXTEND_NONE");
    Same
       (Cairo.Extend_Mode'Pos (Cairo.Repeat_Extend),
        14,
        "Cairo.Extend_Mode'Pos (Cairo.Repeat_Extend) = CAIRO_EXTEND_REPEAT");
    Same
       (Cairo.Extend_Mode'Pos (Cairo.Reflect_Extend),
        15,
        "Cairo.Extend_Mode'Pos (Cairo.Reflect_Extend) = CAIRO_EXTEND_REFLECT");
    Same
       (Cairo.Extend_Mode'Pos (Cairo.Pad_Extend),
        16,
        "Cairo.Extend_Mode'Pos (Cairo.Pad_Extend) = CAIRO_EXTEND_PAD");

end FLTK.Test_Cairo_Constants;
