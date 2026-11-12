

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.IO_Exceptions,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Filenames is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Constants From C  --
    ------------------------

    error_bsize : constant Interfaces.C.int;
    pragma Import (C, error_bsize, "error_bsize");




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Data Structures  --

    procedure free_filename_file_list
           (L : in Storage.Integer_Address;
            N : in Interfaces.C.int);
    pragma Import (C, free_filename_file_list, "free_filename_file_list");
    pragma Inline (free_filename_file_list);

    function filename_dname
           (L : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, filename_dname, "filename_dname");
    pragma Inline (filename_dname);




    --  C API  --

    procedure filename_decode_uri
           (URI : in Interfaces.C.char_array);
    pragma Import (C, filename_decode_uri, "filename_decode_uri");
    pragma Inline (filename_decode_uri);

    function filename_absolute
           (To   :    out Interfaces.C.char_array;
            Len  : in     Interfaces.C.int;
            From : in     Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_absolute, "filename_absolute");
    pragma Inline (filename_absolute);

    function filename_expand
           (To   :    out Interfaces.C.char_array;
            Len  : in     Interfaces.C.int;
            From : in     Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_expand, "filename_expand");
    pragma Inline (filename_expand);

    function filename_ext
           (Buf : in Interfaces.C.char_array)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, filename_ext, "filename_ext");
    pragma Inline (filename_ext);

    function filename_isdir
           (Name : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_isdir, "filename_isdir");
    pragma Inline (filename_isdir);

    function filename_list
           (D : in     Interfaces.C.char_array;
            L :    out Storage.Integer_Address;
            F : in     Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, filename_list, "filename_list");
    pragma Inline (filename_list);

    function filename_match
           (Name, Pattern : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_match, "filename_match");
    pragma Inline (filename_match);

    function filename_name
           (Name : in Interfaces.C.char_array)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, filename_name, "filename_name");
    pragma Inline (filename_name);

    function filename_relative
           (To   :    out Interfaces.C.char_array;
            Len  : in     Interfaces.C.int;
            From : in     Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_relative, "filename_relative");
    pragma Inline (filename_relative);

    function filename_setext
           (To  : in Interfaces.C.char_array;
            Len : in Interfaces.C.int;
            Ext : in Interfaces.C.char_array)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, filename_setext, "filename_setext");
    pragma Inline (filename_setext);

    function filename_open_uri
           (U   : in     Interfaces.C.char_array;
            M   :    out Interfaces.C.char_array;
            Len : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, filename_open_uri, "filename_open_uri");
    pragma Inline (filename_open_uri);




    --  Sorting  --

    function fl_tolower
           (Code : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_tolower, "fl_tolower");
    pragma Inline (fl_tolower);




    -----------------------------
    --  Auxiliary Subprograms  --
    -----------------------------

    --  Sorting  --

    --  The sorts are done here, not by FLTK's, since FLTK's take a dirent,
    --  whose name holds 255 bytes, and fl_numericsort and
    --  fl_casenumericsort sort wrongly (pofltk 63).

    function Order
           (Left, Right : in Integer)
        return Comparison is
    begin
        if Left < Right then
            return Lesser;
        elsif Left > Right then
            return Greater;
        else
            return Equal;
        end if;
    end Order;


    --  What strcasecmp folds in the C locale: ASCII letters only.
    function ASCII_Lower
           (Item : in Character)
        return Character is
    begin
        if Item in 'A' .. 'Z' then
            return Character'Val (Character'Pos (Item) + 32);
        else
            return Item;
        end if;
    end ASCII_Lower;


    --  As strcmp and strcasecmp compare: by bytes, unsigned.
    function Byte_Compare
           (A, B : in String;
            Fold : in Boolean)
        return Comparison
    is
        Left, Right : Character;
    begin
        for N in 0 .. Integer'Min (A'Length, B'Length) - 1 loop
            Left := A (A'First + N);
            Right := B (B'First + N);
            if Fold then
                Left := ASCII_Lower (Left);
                Right := ASCII_Lower (Right);
            end if;
            if Left /= Right then
                return Order (Character'Pos (Left), Character'Pos (Right));
            end if;
        end loop;
        return Order (A'Length, B'Length);
    end Byte_Compare;


    --  The character at Place, as fl_utf8decode reads it, and Place moved
    --  past it.  A byte that doesn't start a well-formed UTF-8 character
    --  stands for itself (fl_utf8decode reads 16#80# .. 16#9F# as CP1252,
    --  which only moves those bytes among themselves).
    procedure Decode
           (Text  : in     String;
            Place : in out Positive;
            Code  :    out Natural)
    is
        Lead : constant Natural := Character'Pos (Text (Place));
        Size : Natural;
        Low  : Natural;
    begin
        case Lead is
        when 16#C2# .. 16#DF# => Size := 2; Low := 16#80#;
        when 16#E0# .. 16#EF# => Size := 3; Low := 16#800#;
        when 16#F0# .. 16#F4# => Size := 4; Low := 16#10000#;
        when others           => Size := 1; Low := 0;
        end case;
        if Size > 1 and then Place + Size - 1 <= Text'Last then
            Code := Lead mod (2 ** (7 - Size));
            for N in 1 .. Size - 1 loop
                if Character'Pos (Text (Place + N)) / 16#40# /= 2 then
                    Size := 1;
                    exit;
                end if;
                Code := Code * 16#40# + Character'Pos (Text (Place + N)) mod 16#40#;
            end loop;
            if Size > 1 and then Code >= Low and then Code <= 16#10FFFF# then
                Place := Place + Size;
                return;
            end if;
        end if;
        Code := Lead;
        Place := Place + 1;
    end Decode;


    --  As FLTK documents fl_numericsort: runs of digits compare as numbers,
    --  leading zeros aside, then what follows them; other characters as
    --  Unicode code points, case folded by fl_tolower if Fold; and a name
    --  comes before a longer one it starts.  Ported from pofltk's
    --  numeric_compare.
    function Numeric_Compare
           (A, B : in String;
            Fold : in Boolean)
        return Comparison
    is
        I : Positive := A'First;
        J : Positive := B'First;

        DA, DB : Positive;

        Left, Right : Natural;

        function Is_Digit
               (Text  : in String;
                Place : in Positive)
            return Boolean is
        begin
            return Place <= Text'Last and then Text (Place) in '0' .. '9';
        end Is_Digit;

    begin
        while I <= A'Last and J <= B'Last loop
            if Is_Digit (A, I) and Is_Digit (B, J) then
                while I <= A'Last and then A (I) = '0' loop
                    I := I + 1;
                end loop;
                while J <= B'Last and then B (J) = '0' loop
                    J := J + 1;
                end loop;
                DA := I;
                DB := J;
                while Is_Digit (A, I) loop
                    I := I + 1;
                end loop;
                while Is_Digit (B, J) loop
                    J := J + 1;
                end loop;
                if I - DA /= J - DB then
                    return Order (I - DA, J - DB);
                elsif A (DA .. I - 1) /= B (DB .. J - 1) then
                    return (if A (DA .. I - 1) < B (DB .. J - 1) then Lesser else Greater);
                end if;
            else
                Decode (A, I, Left);
                Decode (B, J, Right);
                if Fold then
                    Left := Natural (fl_tolower (Interfaces.C.unsigned (Left)));
                    Right := Natural (fl_tolower (Interfaces.C.unsigned (Right)));
                end if;
                if Left /= Right then
                    return Order (Left, Right);
                end if;
            end if;
        end loop;
        return Order (Boolean'Pos (I <= A'Last), Boolean'Pos (J <= B'Last));
    end Numeric_Compare;


    function Alpha_Sort
           (A, B : in String)
        return Comparison is
    begin
        return Byte_Compare (A, B, False);
    end Alpha_Sort;


    function Case_Alpha_Sort
           (A, B : in String)
        return Comparison is
    begin
        return Byte_Compare (A, B, True);
    end Case_Alpha_Sort;


    function Numeric_Sort
           (A, B : in String)
        return Comparison is
    begin
        return Numeric_Compare (A, B, False);
    end Numeric_Sort;


    function Case_Numeric_Sort
           (A, B : in String)
        return Comparison is
    begin
        return Numeric_Compare (A, B, True);
    end Case_Numeric_Sort;




    --  Datatypes  --

    procedure Finalize
           (This : in out File_List) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_filename_file_list (This.Void_Ptr, This.Entries);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;


    function Length
           (This : in File_List)
        return Natural is
    begin
        return Natural (This.Entries);
    end Length;


    function Item
           (This  : in File_List;
            Index : in Positive)
        return Path_String is
    begin
        return Interfaces.C.Strings.Value
            (filename_dname (This.Void_Ptr, Interfaces.C.int (Index) - 1));
    end Item;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Uniform Resource Identifiers  --

    function Decode_URI
           (URI : in Path_String)
        return Path_String
    is
        C_Ptr : constant Interfaces.C.char_array := Interfaces.C.To_C (URI);
    begin
        filename_decode_uri (C_Ptr);
        return Interfaces.C.To_Ada (C_Ptr);
    end Decode_URI;


    procedure Open_URI
           (URI : in Path_String)
    is
        Message : Interfaces.C.char_array (1 .. Interfaces.C.size_t (error_bsize)) :=
           (others => Interfaces.C.char'Val (0));
        Result : constant Interfaces.C.int := filename_open_uri
           (Interfaces.C.To_C (URI),
            Message,
            error_bsize);
    begin
        if Result = 0 then
            raise Open_URI_Error with "Error: " & Interfaces.C.To_Ada (Message);
        else
            pragma Assert (Result = 1);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "fl_open_uri returned unexpected int value of " & Interfaces.C.int'Image (Result);
    end Open_URI;




    --  Pathnames  --

    function Absolute
           (Name : in Path_String)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Ignore : constant Interfaces.C.int := filename_absolute
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
    begin
        return Interfaces.C.To_Ada (Result);
    end Absolute;


    function Absolute
           (Name    : in     Path_String;
            Changed :    out Boolean)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Code : constant Interfaces.C.int := filename_absolute
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
    begin
        Changed := Code /= 0;
        return Interfaces.C.To_Ada (Result);
    end Absolute;


    function Relative
           (Name : in Path_String)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Ignore : constant Interfaces.C.int := filename_relative
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
    begin
        return Interfaces.C.To_Ada (Result);
    end Relative;


    function Relative
           (Name    : in     Path_String;
            Changed :    out Boolean)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Ignore : constant Interfaces.C.int := filename_relative
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
        Answer : constant String := Interfaces.C.To_Ada (Result);
    begin
        --  FLTK returns 0, no change, for the current directory, which it
        --  makes "." (filename_absolute.cxx:248-252).  pofltk 94.
        Changed := Answer /= Name;
        return Answer;
    end Relative;


    function Expand
           (Name : in Path_String)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Ignore : constant Interfaces.C.int := filename_expand
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
    begin
        return Interfaces.C.To_Ada (Result);
    end Expand;


    function Expand
           (Name    : in     Path_String;
            Changed :    out Boolean)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Code : constant Interfaces.C.int := filename_expand
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
    begin
        Changed := Code /= 0;
        return Interfaces.C.To_Ada (Result);
    end Expand;




    --  Filenames  --

    function Base_Name
           (Name : in Path_String)
        return Path_String
    is
        Data : constant Interfaces.C.char_array := Interfaces.C.To_C (Name);
    begin
        return Interfaces.C.Strings.Value (filename_name (Data));
    end Base_Name;


    function Extension
           (Name : in Path_String)
        return Path_String
    is
        Data : constant Interfaces.C.char_array := Interfaces.C.To_C (Name);
        Result : constant Interfaces.C.Strings.chars_ptr := filename_ext (Data);
    begin
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Extension;


    function Set_Extension
           (Name   : in Path_String;
            Suffix : in String)
        return Path_String
    is
        --  Room for Name, Suffix and the nul, so that FLTK never cuts the
        --  result short.  To_C (Name) is Name'Length + 1 long (FLTKAda-BUGS.md
        --  138).
        Data : Interfaces.C.char_array
            (1 .. Interfaces.C.size_t (Name'Length + Suffix'Length + 1)) :=
           (others => Interfaces.C.char'Val (0));
        Result : Interfaces.C.Strings.chars_ptr;
    begin
        Data (1 .. Name'Length + 1) := Interfaces.C.To_C (Name);
        Result := filename_setext
           (Data,
            Data'Length,
            Interfaces.C.To_C (Suffix));
        return Interfaces.C.Strings.Value (Result);
    end Set_Extension;




    --  Directories  --

    function Is_Directory
           (Name : in String)
        return Boolean is
    begin
        return filename_isdir (Interfaces.C.To_C (Name)) /= 0;
    end Is_Directory;


    Current_Sort : Compare_Function;

    function Compare_Hook
           (DA, DB : in Storage.Integer_Address)
        return Interfaces.C.int;

    pragma Convention (C, Compare_Hook);

    function Compare_Hook
           (DA, DB : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark   : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Result : constant Comparison := Current_Sort
           (Interfaces.C.Strings.Value (filename_dname (DA, 0)),
            Interfaces.C.Strings.Value (filename_dname (DB, 0)));
    begin
        return Comparison'Pos (Result) - 1;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Compare_Hook;

    function Get_Listing
           (Name : in Path_String;
            Sort : in not null Compare_Function := Numeric_Sort'Access)
        return File_List is
    begin
        Current_Sort := Sort;
        return This : File_List do
            This.Entries := filename_list
               (Interfaces.C.To_C (Name),
                This.Void_Ptr,
                Storage.To_Integer (Compare_Hook'Address));
            Hook_Exceptions.Reraise;
            --  fl_filename_list gives -1, and no list, when it can't read
            --  the directory (FLTKAda-BUGS.md 124).
            if This.Entries < 0 then
                This.Entries := 0;
                raise Ada.IO_Exceptions.Name_Error with
                    "Get_Listing: can't list " & Name;
            end if;
        end return;
    end Get_Listing;




    --  Patterns  --

    function Match
           (Input, Pattern : in String)
        return Boolean is
    begin
        return filename_match (Interfaces.C.To_C (Input), Interfaces.C.To_C (Pattern)) /= 0;
    end Match;


end FLTK.Filenames;


