

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  pofltk 126: the Mac Roman conversions.  FLTK's take their buffer to be
--  big enough when it isn't (fl_encoding_mac_roman.cxx:67, 89), so the first
--  call with text writes through a null pointer, and local_to_mac_roman
--  writes only its first byte, again and again (:72-78).  Neither ends the
--  result with a NUL, and the binding read it as a C string.  The binding
--  now converts a byte at a time.  The Latin-1 pair leaves text as it is
--  off macOS (fl_encoding_latin1.cxx:40-57).


with

    Checks,
    FLTK.Draw,
    FLTK.Widgets.Groups.Windows;

use

    Checks;


procedure Test_Recode is

    package Win renames FLTK.Widgets.Groups.Windows;

    function Byte
           (Code : in Natural)
        return Character is
    begin
        return Character'Val (Code);
    end Byte;

    --  Latin-1 a, A with diaeresis, b, e with acute, NUL, z.
    Latin : constant String :=
        "a" & Byte (16#C4#) & "b" & Byte (16#E9#) & Byte (0) & "z";

    --  The same in Mac Roman (latin2roman, fl_encoding_mac_roman.cxx:37-46).
    Roman : constant String :=
        "a" & Byte (16#80#) & "b" & Byte (16#8E#) & Byte (0) & "z";

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Recode");

    Offset : constant String (11 .. 16) := Roman;

begin

    Window.Show;
    for N in 1 .. 5 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;

    Check (FLTK.Draw.Local_To_Mac_Roman (Latin) = Roman,
        "Local_To_Mac_Roman converts every byte");
    Check (FLTK.Draw.Mac_Roman_To_Local (Roman) = Latin,
        "Mac_Roman_To_Local converts every byte");
    Check (FLTK.Draw.Mac_Roman_To_Local (Offset) = Latin,
        "Mac_Roman_To_Local converts a string that doesn't start at 1");
    Check (FLTK.Draw.Local_To_Mac_Roman (FLTK.Draw.Local_To_Mac_Roman ("plain")) = "plain",
        "ASCII is the same in Mac Roman, converted twice");
    Check (FLTK.Draw.Local_To_Mac_Roman ("") = "", "an empty string converts to itself");
    Check (FLTK.Draw.Latin1_To_Local (Latin) = Latin, "Latin1_To_Local keeps the text");
    Check (FLTK.Draw.Local_To_Latin1 (Latin) = Latin, "Local_To_Latin1 keeps the text");

    Summary;

end Test_Recode;


