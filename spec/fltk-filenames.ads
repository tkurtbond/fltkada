

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Filenames is


    Max_Path_Length : constant Natural;

    subtype Path_String is String
        with Dynamic_Predicate => Path_String'Length <= Max_Path_Length;


    type Comparison is (Lesser, Equal, Greater);

    type Compare_Function is access function
           (A, B : in String)
        return Comparison;

    --  The sorts are done in Ada.  Alpha_Sort compares bytes, as strcmp
    --  does, and Case_Alpha_Sort folds ASCII case, as strcasecmp does.
    --  Numeric_Sort compares runs of digits as numbers, leading zeros
    --  aside, then what follows them, and other characters as code points;
    --  a name comes before a longer one it starts.  Case_Numeric_Sort folds
    --  case with fl_tolower.  FLTK's fl_numericsort skips the character
    --  after a number (pofltk 63).

    function Alpha_Sort
           (A, B : in String)
        return Comparison;

    function Case_Alpha_Sort
           (A, B : in String)
        return Comparison;

    function Numeric_Sort
           (A, B : in String)
        return Comparison;

    function Case_Numeric_Sort
           (A, B : in String)
        return Comparison;


    type File_List is new Wrapper with private;

    function Length
           (This : in File_List)
        return Natural;

    function Item
           (This  : in File_List;
            Index : in Positive)
        return Path_String
    with Pre => Index in 1 .. This.Length;


    Open_URI_Error : exception;




    --  Uniform Resource Identifiers  --

    function Decode_URI
           (URI : in Path_String)
        return Path_String;

    procedure Open_URI
           (URI : in Path_String);




    --  Pathnames  --

    function Absolute
           (Name : in Path_String)
        return Path_String;

    function Absolute
           (Name    : in     Path_String;
            Changed :    out Boolean)
        return Path_String;

    function Relative
           (Name : in Path_String)
        return Path_String;

    --  Changed is whether the result differs from Name, so True for the
    --  current directory, which becomes "." (pofltk 94).  FLTK looks only
    --  at the text: Name should have no "." or ".." or doubled "/" in it.
    function Relative
           (Name    : in     Path_String;
            Changed :    out Boolean)
        return Path_String;

    --  Expand puts each value in once, so a value naming itself doesn't
    --  loop, and cuts the result short to Max_Path_Length - 1 characters,
    --  where FLTK aborted (pofltk 120).
    function Expand
           (Name : in Path_String)
        return Path_String;

    function Expand
           (Name    : in     Path_String;
            Changed :    out Boolean)
        return Path_String;




    --  Filenames  --

    function Base_Name
           (Name : in Path_String)
        return Path_String;

    function Extension
           (Name : in Path_String)
        return Path_String;

    function Set_Extension
           (Name   : in Path_String;
            Suffix : in String)
        return Path_String;




    --  Directories  --

    --  Name may be longer than Max_Path_Length (pofltk 121).
    function Is_Directory
           (Name : in String)
        return Boolean;

    function Get_Listing
           (Name : in Path_String;
            Sort : in not null Compare_Function := Numeric_Sort'Access)
        return File_List;




    --  Patterns  --

    function Match
           (Input, Pattern : in String)
        return Boolean;


private


    type File_List is new Wrapper with record
        Entries : Interfaces.C.int := 0;
    end record;

    overriding procedure Finalize
           (This : in out File_List);


    fl_path_max : constant Interfaces.C.int;
    pragma Import (C, fl_path_max, "fl_path_max");

    Max_Path_Length : constant Natural := Natural (fl_path_max);


    pragma Inline (Length);
    pragma Inline (Item);

    pragma Inline (Is_Directory);

    pragma Inline (Match);


end FLTK.Filenames;


