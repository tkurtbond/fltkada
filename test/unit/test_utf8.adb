--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 9: FLTK.UTF8, on bad text, text that stops inside a
--  character, and results longer than the text.  Ported from pofltk's
--  TestUtf8 and HaltUtf8Offset, less what Ada itself does.


with

    Ada.Exceptions,
    Ada.Strings.UTF_Encoding.Wide_Wide_Strings,
    Checks,
    FLTK.UTF8;

use

    Checks;


procedure Test_UTF8 is

    package U renames FLTK.UTF8;

    function Encode
           (Item : in Wide_Wide_String)
        return String is
    begin
        return Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Encode (Item);
    end Encode;

    function C
           (Value : in Natural)
        return Character is
    begin
        return Character'Val (Value);
    end C;

    function W
           (Value : in Natural)
        return Wide_Wide_Character is
    begin
        return Wide_Wide_Character'Val (Value);
    end W;

    --  The bytes of Text, for a message.
    function Bytes
           (Text : in String)
        return String is
    begin
        if Text'Length = 0 then
            return "";
        end if;
        return Integer'Image (Character'Pos (Text (Text'First)))
            & Bytes (Text (Text'First + 1 .. Text'Last));
    end Bytes;

    procedure Check_Text
           (Got, Want : in String;
            Message   : in String) is
    begin
        Check (Got = Want, Message & ":" & Bytes (Got)
            & (if Got = Want then "" else ", not" & Bytes (Want)));
    end Check_Text;

    Flag   : constant String := Encode (W (16#1F1E6#) & W (16#1F1E7#)) & "x";
    Keycap : constant String := "9" & Encode (W (16#FE0F#) & W (16#20E3#));
    Joiner : constant String := "a" & Encode ((1 => W (16#200D#)));

    Index_At : Integer := 1;
    Result   : Natural := 0;

    procedure Next_Outside is
    begin
        Result := U.Next_Composed ("abc", Index_At);
    end Next_Outside;

    procedure Previous_Outside is
    begin
        Result := U.Previous_Composed ("abc", Index_At);
    end Previous_Outside;

    Long : constant String (1 .. 2000) := (others => 'x');
    Bad  : constant String (1 .. 2000) := (others => C (16#80#));

begin

    --  Characters.
    Check (U.Is_Nonspacing (W (16#301#)), "Is_Nonspacing of a mark");
    Check (not U.Is_Nonspacing ('A'), "Is_Nonspacing of a letter");
    Check (U.Width ('A') = 1, "Width of a letter");
    Check (U.Width (W (16#301#)) = 0, "Width of a mark");
    Check (U.Width (W (16#4E00#)) = 2, "Width of an ideograph");
    Check (U.Width (W (7)) = -1, "Width of a control character");
    Check (U.To_Lower (W (16#C9#)) = W (16#E9#), "To_Lower");
    Check (U.To_Upper (W (16#E9#)) = W (16#C9#), "To_Upper");
    Check (U.To_Upper (W (16#110000#)) = W (16#110000#), "To_Upper past Unicode");
    Check (U.To_Lower (Wide_Wide_Character'Last) = Wide_Wide_Character'Last,
        "To_Lower of the last Wide_Wide_Character");

    --  Testing an encoding.
    Check (U.Test ("") = 1, "Test of nothing");
    Check (U.Test ("abc") = 1, "Test of ASCII");
    Check (U.Test ("a" & Encode ((1 => W (16#20AC#))) & "b") = 3, "Test of three");
    Check (U.Test (Encode ((1 => W (16#1F600#)))) = 4, "Test of four");
    Check (U.Test (C (16#E2#) & C (16#82#)) = 0, "Test of a character cut short");

    --  Emoji sequences (pofltk 115).
    Check (U.Next_Composed (Flag, 1) = 9, "Next_Composed of a flag");
    Check (U.Next_Composed (Flag, 9) = 10, "Next_Composed to the end");
    Check (U.Next_Composed (Flag, 10) = 10, "Next_Composed at the end");
    Check (U.Previous_Composed (Flag, 10) = 9, "Previous_Composed");
    Check (U.Previous_Composed (Flag, 9) = 1, "Previous_Composed of a flag");
    Check (U.Previous_Composed (Flag, 1) = 1, "Previous_Composed at the start");
    Check (U.Next_Composed (Keycap, 1) = 8, "Next_Composed of a keycap");
    Check (U.Previous_Composed (Keycap, 8) = 1, "Previous_Composed of a keycap");
    Check (U.Next_Composed ("e" & C (16#CC#) & C (16#81#), 1) = 2,
        "Next_Composed stops at a mark");
    Check (U.Next_Composed ((1 => C (16#F0#)), 1) = 2, "Next_Composed of a lone lead byte");
    Check (U.Next_Composed (Joiner, 1) = 5, "Next_Composed of a joiner at the end");
    Check (U.Next_Composed (Joiner & C (16#80#), 1) in 2 .. 6,
        "Next_Composed of a joiner and a stray byte");
    Check (U.Previous_Composed (Joiner, 5) = 2, "Previous_Composed of a joiner at the end");
    Check (U.Previous_Composed (Encode ((1 => W (16#FE0F#))), 4) = 1,
        "Previous_Composed of a selector at the start");
    Check (U.Next_Composed (Encode ((1 => W (16#1F1E6#))), 1) = 5,
        "Next_Composed of half a flag");
    declare
        Shifted : constant String (11 .. 19) := Flag;
    begin
        Check (U.Next_Composed (Shifted, 11) = 19, "Next_Composed of a text not from 1");
        Check (U.Previous_Composed (Shifted, 20) = 19, "and Previous_Composed");
    end;
    Index_At := 5;
    Raises (Next_Outside'Access, Constraint_Error'Identity,
        "Next_Composed past the end raises Constraint_Error");
    Raises (Previous_Outside'Access, Constraint_Error'Identity,
        "Previous_Composed past the end raises Constraint_Error");
    Index_At := 4;
    No_Raise (Next_Outside'Access, "Next_Composed just past the end doesn't raise");
    Check (Result = 4, "and gives the end:" & Integer'Image (Result));

    --  Case (pofltk 116).
    Check_Text (U.To_Lower ("A" & C (16#C3#) & C (16#89#) & "B"),
        "a" & C (16#C3#) & C (16#A9#) & "b", "To_Lower");
    Check_Text (U.To_Upper ("a" & C (16#C3#) & C (16#A9#) & "b"),
        "A" & C (16#C3#) & C (16#89#) & "B", "To_Upper");
    Check_Text (U.To_Lower (""), "", "To_Lower of nothing");
    declare
        Got : constant String := U.To_Upper (Bad);
    begin
        Check (Got'Length = 6000, "To_Upper of bad bytes, each three:"
            & Integer'Image (Got'Length));
        Check (Got (1 .. 3) = Encode ((1 => W (16#20AC#))), "each read as CP1252");
    end;
    Check_Text (U.To_Lower ((1 => C (16#C9#))), C (16#C3#) & C (16#A9#),
        "To_Lower of a lone byte, read as Latin-1");
    Check_Text (U.To_Lower ((1 => C (16#C3#))), C (16#C3#) & C (16#A3#),
        "To_Lower of a character cut short");
    Check (U.Compare_No_Case ("ABC", "abc") = 0, "Compare_No_Case of the same");
    Check (U.Compare_No_Case ("ab", "abc") < 0, "Compare_No_Case, shorter");
    Check (U.Compare_No_Case ("abd", "ABC") > 0, "Compare_No_Case, after");
    Check (U.Compare_No_Case (C (16#C3#) & C (16#89#), C (16#C3#) & C (16#A9#)) = 0,
        "Compare_No_Case past ASCII");
    Check (U.Compare_No_Case ("abX", "ABY", 2) = 0, "Compare_No_Case of 2");
    Check (U.Compare_No_Case ("abX", "ABY", 3) < 0, "Compare_No_Case of all 3");
    Check (U.Compare_No_Case ("a", "b", 0) = 0, "Compare_No_Case of none");
    Check (U.Compare_No_Case (C (16#E2#) & C (16#82#), C (16#E2#) & C (16#82#)) = 0,
        "Compare_No_Case of characters cut short");

    --  The locale (pofltk 118).
    Check_Text (U.To_Locale ("abc"), "abc", "To_Locale");
    Check_Text (U.From_Locale ("abc"), "abc", "From_Locale");
    Check_Text (U.To_Locale (""), "", "To_Locale of nothing");
    Check (U.To_Locale (Long) = Long, "To_Locale, long");
    Check (U.From_Locale (Long) = Long, "From_Locale, long");
    if U.Is_UTF8_Locale then
        Check_Text (U.To_Locale (Encode ((1 => W (16#20AC#)))), Encode ((1 => W (16#20AC#))),
            "To_Locale in a UTF-8 locale is the text");
        Check_Text (U.From_Locale ("a" & C (0) & "b"), "a" & C (0) & "b",
            "From_Locale in a UTF-8 locale keeps a NUL");
    else
        Skip ("the locale isn't UTF-8");
    end if;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_UTF8;
