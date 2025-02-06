

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

    function Relative
           (Name    : in     Path_String;
            Changed :    out Boolean)
        return Path_String;

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

    function Is_Directory
           (Name : in Path_String)
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


