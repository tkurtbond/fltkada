--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  What FLTK's fl_utf8.h adds to Ada's own handling of UTF-8.  Ada already
--  encodes and decodes UTF-8 (Ada.Strings.UTF_Encoding and its children),
--  converts it to and from Latin-1 (Ada.Strings.UTF_Encoding.Strings), and
--  classifies characters (Ada.Wide_Wide_Characters.Handling).  So FLTK's
--  fl_utf8len, fl_utf8bytes, fl_utf8encode, fl_utf8decode, fl_utf8fwd,
--  fl_utf8back, fl_utf8strlen, fl_utf_nb_char, fl_utf8toa and fl_utf8froma
--  aren't bound here, nor the UTF-16 and wchar_t conversions.  What is
--  bound is what Ada has no match for: the display width and nonspacing
--  tests that FLTK's text widgets use, FLTK's own case folding, its test
--  of a text's encoding, its stepping over emoji sequences, and its
--  conversions to and from the locale's encoding.
--
--  A String here holds UTF-8, a byte to a Character, as FLTK takes it.
--  FLTK's functions read past the end of a text that stops inside a
--  character (pofltk 115), so each is given a copy, and what it returns is
--  kept within the text.


package FLTK.UTF8 is


    --  Characters  --

    --  Whether Item is a combining mark, drawn over the character before it.
    function Is_Nonspacing
           (Item : in Wide_Wide_Character)
        return Boolean;

    --  How many columns Item takes on a terminal: 0 for a combining mark,
    --  2 for a wide character such as an ideograph, 1 for most others, and
    --  -1 for a control character.  This is fl_wcwidth_; fl_wcwidth, which
    --  takes UTF-8, is this of the character decoded.
    function Width
           (Item : in Wide_Wide_Character)
        return Integer;

    --  FLTK's lower and upper case of Item, from its own tables, which FLTK
    --  uses to compare text without case.
    function To_Lower
           (Item : in Wide_Wide_Character)
        return Wide_Wide_Character;

    function To_Upper
           (Item : in Wide_Wide_Character)
        return Wide_Wide_Character;




    --  Text  --

    --  0 if Text isn't valid UTF-8, or the most bytes any of its characters
    --  takes, from 1, when all of it is ASCII, to 4.
    function Test
           (Text : in String)
        return Natural
    with Post => Test'Result <= 4;

    --  Where the character after the one at Index starts, taking an emoji
    --  sequence, such as a flag or a keycap, as one character, though not
    --  a letter and its combining mark.  Index is in Text, or just past it,
    --  and so is the result.  Raises Constraint_Error for an Index outside
    --  those.
    function Next_Composed
           (Text  : in String;
            Index : in Positive)
        return Positive;

    --  Where the character before the one at Index starts, the same way.
    function Previous_Composed
           (Text  : in String;
            Index : in Positive)
        return Positive;

    --  Text in FLTK's lower or upper case.  A byte that isn't part of a
    --  character is taken as a character of CP1252 or Latin-1, and comes out
    --  as that character, encoded.
    function To_Lower
           (Text : in String)
        return String;

    function To_Upper
           (Text : in String)
        return String;

    --  Left and Right compared without case, by To_Lower of each character:
    --  below 0 if Left comes first, 0 if they are the same, and above 0 if
    --  Right comes first.  Only the first Count characters are compared, if
    --  Count is given.  FLTK stops at a NUL, so a NUL ends each text.
    function Compare_No_Case
           (Left, Right : in String)
        return Integer;

    function Compare_No_Case
           (Left, Right : in String;
            Count       : in Natural)
        return Integer;




    --  The Locale  --

    --  Whether the locale's encoding is UTF-8.  On X11 and Wayland, FLTK
    --  takes the first of LC_CTYPE, LC_ALL and LANG that is set and not
    --  empty, and it is UTF-8 if it holds "utf" or "UTF"; with none set,
    --  it is.  FLTK reads them only once, the first time it is asked
    --  (pofltk 118).
    function Is_UTF8_Locale
        return Boolean;

    --  Text in the locale's encoding, as file names are given to the system,
    --  and back.  Each is Text itself in a UTF-8 locale.  In another, a NUL
    --  ends what From_Locale gives.
    function To_Locale
           (Text : in String)
        return String;

    function From_Locale
           (Text : in String)
        return String;


private


    pragma Inline (Is_Nonspacing);
    pragma Inline (Width);
    pragma Inline (Is_UTF8_Locale);


end FLTK.UTF8;
