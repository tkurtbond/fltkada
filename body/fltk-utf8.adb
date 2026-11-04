--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Interfaces.C,
    System;

use type

    Interfaces.C.int,
    Interfaces.C.unsigned;


package body FLTK.UTF8 is


    ------------------------
    --  Functions From C  --
    ------------------------

    procedure fl_utf8_text_free
           (P : in Storage.Integer_Address);
    pragma Import (C, fl_utf8_text_free, "fl_utf8_text_free");
    pragma Inline (fl_utf8_text_free);




    --  Characters  --

    function fl_utf8_text_nonspacing
           (U : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_nonspacing, "fl_utf8_text_nonspacing");
    pragma Inline (fl_utf8_text_nonspacing);

    function fl_utf8_text_wcwidth
           (U : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_wcwidth, "fl_utf8_text_wcwidth");
    pragma Inline (fl_utf8_text_wcwidth);

    function fl_utf8_text_tolower
           (U : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_utf8_text_tolower, "fl_utf8_text_tolower");
    pragma Inline (fl_utf8_text_tolower);

    function fl_utf8_text_toupper
           (U : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_utf8_text_toupper, "fl_utf8_text_toupper");
    pragma Inline (fl_utf8_text_toupper);




    --  Text  --

    function fl_utf8_text_test
           (A : in System.Address;
            N : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_test, "fl_utf8_text_test");
    pragma Inline (fl_utf8_text_test);

    function fl_utf8_text_next_composed
           (A     : in System.Address;
            N, P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_next_composed, "fl_utf8_text_next_composed");
    pragma Inline (fl_utf8_text_next_composed);

    function fl_utf8_text_previous_composed
           (A     : in System.Address;
            N, P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_previous_composed, "fl_utf8_text_previous_composed");
    pragma Inline (fl_utf8_text_previous_composed);

    function fl_utf8_text_case
           (A     : in     System.Address;
            N, Up : in     Interfaces.C.int;
            Got   :    out Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_utf8_text_case, "fl_utf8_text_case");
    pragma Inline (fl_utf8_text_case);

    function fl_utf8_text_strcasecmp
           (A  : in System.Address;
            NA : in Interfaces.C.int;
            B  : in System.Address;
            NB : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_strcasecmp, "fl_utf8_text_strcasecmp");
    pragma Inline (fl_utf8_text_strcasecmp);

    function fl_utf8_text_strncasecmp
           (A     : in System.Address;
            NA    : in Interfaces.C.int;
            B     : in System.Address;
            NB, N : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_strncasecmp, "fl_utf8_text_strncasecmp");
    pragma Inline (fl_utf8_text_strncasecmp);




    --  The Locale  --

    function fl_utf8_text_locale
        return Interfaces.C.int;
    pragma Import (C, fl_utf8_text_locale, "fl_utf8_text_locale");
    pragma Inline (fl_utf8_text_locale);

    function fl_utf8_text_to_mb
           (A   : in     System.Address;
            N   : in     Interfaces.C.int;
            Got :    out Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_utf8_text_to_mb, "fl_utf8_text_to_mb");
    pragma Inline (fl_utf8_text_to_mb);

    function fl_utf8_text_from_mb
           (A   : in     System.Address;
            N   : in     Interfaces.C.int;
            Got :    out Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_utf8_text_from_mb, "fl_utf8_text_from_mb");
    pragma Inline (fl_utf8_text_from_mb);




    -------------------
    --  Auxiliaries  --
    -------------------

    --  The length of Text, for C.  Raises Constraint_Error past int'Last.
    function Length
           (Text : in String)
        return Interfaces.C.int is
    begin
        if Text'Length > Natural (Interfaces.C.int'Last) then
            raise Constraint_Error with "text too long for FLTK";
        end if;
        return Interfaces.C.int (Text'Length);
    end Length;


    --  The Got bytes at Result, which is then freed.  Raises Storage_Error
    --  if the shim couldn't allocate them.
    function Take
           (Result : in Storage.Integer_Address;
            Got    : in Interfaces.C.int)
        return String is
    begin
        if Result = Null_Pointer then
            raise Storage_Error with "FLTK.UTF8 could not allocate a result";
        end if;
        declare
            --  Value would stop at a NUL.
            Data : constant String (1 .. Integer (Got))
            with Import, Address => Storage.To_Address (Result);
            Text : constant String := Data;
        begin
            fl_utf8_text_free (Result);
            return Text;
        end;
    end Take;


    --  The offset of Index in Text, for C.  Raises Constraint_Error unless
    --  Index is in Text or just past it.
    function Offset
           (Text  : in String;
            Index : in Positive)
        return Interfaces.C.int is
    begin
        if Index < Text'First or else Index - Text'First > Text'Length then
            raise Constraint_Error with "index" & Integer'Image (Index)
                & " outside the text";
        end if;
        return Interfaces.C.int (Index - Text'First);
    end Offset;


    function To_Character
           (Value : in Interfaces.C.unsigned;
            Item  : in Wide_Wide_Character)
        return Wide_Wide_Character is
    begin
        if Value > Wide_Wide_Character'Pos (Wide_Wide_Character'Last) then
            return Item;
        end if;
        return Wide_Wide_Character'Val (Value);
    end To_Character;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Characters  --

    function Is_Nonspacing
           (Item : in Wide_Wide_Character)
        return Boolean is
    begin
        return fl_utf8_text_nonspacing (Wide_Wide_Character'Pos (Item)) /= 0;
    end Is_Nonspacing;


    function Width
           (Item : in Wide_Wide_Character)
        return Integer is
    begin
        return Integer (fl_utf8_text_wcwidth (Wide_Wide_Character'Pos (Item)));
    end Width;


    function To_Lower
           (Item : in Wide_Wide_Character)
        return Wide_Wide_Character is
    begin
        return To_Character (fl_utf8_text_tolower (Wide_Wide_Character'Pos (Item)), Item);
    end To_Lower;


    function To_Upper
           (Item : in Wide_Wide_Character)
        return Wide_Wide_Character is
    begin
        return To_Character (fl_utf8_text_toupper (Wide_Wide_Character'Pos (Item)), Item);
    end To_Upper;




    --  Text  --

    function Test
           (Text : in String)
        return Natural is
    begin
        return Natural (fl_utf8_text_test (Text'Address, Length (Text)));
    end Test;


    function Next_Composed
           (Text  : in String;
            Index : in Positive)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_utf8_text_next_composed
           (Text'Address, Length (Text), Offset (Text, Index));
    begin
        if Result < 0 then
            raise Storage_Error with "FLTK.UTF8 could not copy the text";
        end if;
        return Text'First + Integer (Result);
    end Next_Composed;


    function Previous_Composed
           (Text  : in String;
            Index : in Positive)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_utf8_text_previous_composed
           (Text'Address, Length (Text), Offset (Text, Index));
    begin
        if Result < 0 then
            raise Storage_Error with "FLTK.UTF8 could not copy the text";
        end if;
        return Text'First + Integer (Result);
    end Previous_Composed;


    function To_Lower
           (Text : in String)
        return String
    is
        Got    : Interfaces.C.int := 0;
        Result : constant Storage.Integer_Address :=
            fl_utf8_text_case (Text'Address, Length (Text), 0, Got);
    begin
        return Take (Result, Got);
    end To_Lower;


    function To_Upper
           (Text : in String)
        return String
    is
        Got    : Interfaces.C.int := 0;
        Result : constant Storage.Integer_Address :=
            fl_utf8_text_case (Text'Address, Length (Text), 1, Got);
    begin
        return Take (Result, Got);
    end To_Upper;


    function Compare_No_Case
           (Left, Right : in String)
        return Integer is
    begin
        return Integer (fl_utf8_text_strcasecmp
           (Left'Address, Length (Left), Right'Address, Length (Right)));
    end Compare_No_Case;


    function Compare_No_Case
           (Left, Right : in String;
            Count       : in Natural)
        return Integer is
    begin
        return Integer (fl_utf8_text_strncasecmp
           (Left'Address, Length (Left), Right'Address, Length (Right),
            Interfaces.C.int (Count)));
    end Compare_No_Case;




    --  The Locale  --

    function Is_UTF8_Locale
        return Boolean is
    begin
        return fl_utf8_text_locale /= 0;
    end Is_UTF8_Locale;


    function To_Locale
           (Text : in String)
        return String
    is
        Got    : Interfaces.C.int := 0;
        Result : constant Storage.Integer_Address :=
            fl_utf8_text_to_mb (Text'Address, Length (Text), Got);
    begin
        return Take (Result, Got);
    end To_Locale;


    function From_Locale
           (Text : in String)
        return String
    is
        Got    : Interfaces.C.int := 0;
        Result : constant Storage.Integer_Address :=
            fl_utf8_text_from_mb (Text'Address, Length (Text), Got);
    begin
        return Take (Result, Got);
    end From_Locale;


end FLTK.UTF8;
