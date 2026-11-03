

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  N1 (PLAN.md): Font_Sizes.  The shim read entry I of FLTK's int array at
--  a + (I-1)*sizeof(int), an int pointer moved by bytes' worth of ints, so
--  every entry after the first came from past it.  A Cairo or Pango FLTK
--  lists one size, 0, for every font (Fl_Cairo_Graphics_Driver.cxx:1189-
--  1201), which hides that, so the test also gives the shim's accessor an
--  array of its own.


with

    Checks,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows,
    Interfaces.C;

use

    Checks,
    FLTK;

use type

    Interfaces.C.int;


procedure Test_Font_Sizes is

    package Win renames FLTK.Widgets.Groups.Windows;

    type Int_Array is array (Positive range <>) of Interfaces.C.int;
    pragma Convention (C, Int_Array);

    function fl_static_font_size_array_get
           (A : in Int_Array;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_font_size_array_get, "fl_static_font_size_array_get");

    Known : Int_Array (1 .. 64);

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Font_Sizes");

begin

    for I in Known'Range loop
        Known (I) := Interfaces.C.int (I * 2);
    end loop;

    Window.Show;
    for N in 1 .. 5 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;

    for I in 1 .. 8 loop
        Check (fl_static_font_size_array_get (Known, Interfaces.C.int (I)) = Known (I),
            "the accessor reads entry" & Integer'Image (I));
    end loop;

    declare
        Sizes : constant Font_Size_Array := FLTK.Static.Font_Sizes (Helvetica);
    begin
        Check (Sizes'Length >= 1, "Helvetica has sizes:" & Integer'Image (Sizes'Length));
        for I in Sizes'First + 1 .. Sizes'Last loop
            Check (Sizes (I) > Sizes (I - 1), "the sizes go up at entry" & Integer'Image (I));
        end loop;
    end;

    Summary;

end Test_Font_Sizes;


