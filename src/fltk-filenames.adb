

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Filenames is


    ------------------------
    --  Constants From C  --
    ------------------------

    error_bsize : constant Interfaces.C.int;
    pragma Import (C, error_bsize, "error_bsize");




    ------------------------
    --  Functions From C  --
    ------------------------

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




    procedure filename_decode_uri
           (URI : in Interfaces.C.char_array);
    pragma Import (C, filename_decode_uri, "filename_decode_uri");
    pragma Inline (filename_decode_uri);

    function filename_absolute
           (To   : in Interfaces.C.char_array;
            Len  : in Interfaces.C.int;
            From : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_absolute, "filename_absolute");
    pragma Inline (filename_absolute);

    function filename_expand
           (To   : in Interfaces.C.char_array;
            Len  : in Interfaces.C.int;
            From : in Interfaces.C.char_array)
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
           (To   : in Interfaces.C.char_array;
            Len  : in Interfaces.C.int;
            From : in Interfaces.C.char_array)
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
           (U, M : in Interfaces.C.char_array;
            Len  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, filename_open_uri, "filename_open_uri");
    pragma Inline (filename_open_uri);




    function filename_alphasort
           (A, B : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_alphasort, "filename_alphasort");

    function filename_casealphasort
           (A, B : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_casealphasort, "filename_casealphasort");

    function filename_numericsort
           (A, B : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_numericsort, "filename_numericsort");

    function filename_casenumericsort
           (A, B : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, filename_casenumericsort, "filename_casenumericsort");




    ------------------------------
    --  Comparison Subprograms  --
    ------------------------------

    function Alpha_Sort
           (A, B : in String)
        return Comparison
    is
        Result : Interfaces.C.int :=
            filename_alphasort (Interfaces.C.To_C (A), Interfaces.C.To_C (B));
    begin
        if Result not in Comparison'Pos (Comparison'First) .. Comparison'Pos (Comparison'Last) then
            raise Internal_FLTK_Error;
        else
            return Comparison'Val (Result);
        end if;
    end Alpha_Sort;


    function Case_Alpha_Sort
           (A, B : in String)
        return Comparison
    is
        Result : Interfaces.C.int :=
            filename_casealphasort (Interfaces.C.To_C (A), Interfaces.C.To_C (B));
    begin
        if Result not in Comparison'Pos (Comparison'First) .. Comparison'Pos (Comparison'Last) then
            raise Internal_FLTK_Error;
        else
            return Comparison'Val (Result);
        end if;
    end Case_Alpha_Sort;


    function Numeric_Sort
           (A, B : in String)
        return Comparison
    is
        Result : Interfaces.C.int :=
            filename_numericsort (Interfaces.C.To_C (A), Interfaces.C.To_C (B));
    begin
        if Result not in Comparison'Pos (Comparison'First) .. Comparison'Pos (Comparison'Last) then
            raise Internal_FLTK_Error;
        else
            return Comparison'Val (Result);
        end if;
    end Numeric_Sort;


    function Case_Numeric_Sort
           (A, B : in String)
        return Comparison
    is
        Result : Interfaces.C.int :=
            filename_casenumericsort (Interfaces.C.To_C (A), Interfaces.C.To_C (B));
    begin
        if Result not in Comparison'Pos (Comparison'First) .. Comparison'Pos (Comparison'Last) then
            raise Internal_FLTK_Error;
        else
            return Comparison'Val (Result);
        end if;
    end Case_Numeric_Sort;




    ---------------------------
    --  Listing Subprograms  --
    ---------------------------

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




    --------------------
    --  Filename API  --
    --------------------

    function Decode_URI
           (URI : in Path_String)
        return Path_String
    is
        C_Ptr : Interfaces.C.char_array := Interfaces.C.To_C (URI);
    begin
        filename_decode_uri (C_Ptr);
        return Interfaces.C.To_Ada (C_Ptr);
    end Decode_URI;


    procedure Open_URI
           (URI : in Path_String)
    is
        Message : Interfaces.C.char_array (1 .. Interfaces.C.size_t (error_bsize)) :=
           (others => Interfaces.C.char'Val (0));
        Result : Interfaces.C.int := filename_open_uri
           (Interfaces.C.To_C (URI),
            Message,
            error_bsize);
    begin
        if Result = 0 then
            raise Open_URI_Error with "Error: " & Interfaces.C.To_Ada (Message);
        elsif Result /= 1 then
            raise Internal_FLTK_Error;
        end if;
    end Open_URI;




    function Absolute
           (Name : in Path_String)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Code : Interfaces.C.int := filename_absolute
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
        Code : Interfaces.C.int := filename_absolute
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
        Code : Interfaces.C.int := filename_relative
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
        Code : Interfaces.C.int := filename_relative
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
    begin
        Changed := Code /= 0;
        return Interfaces.C.To_Ada (Result);
    end Relative;


    function Expand
           (Name : in Path_String)
        return Path_String
    is
        Result : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Code : Interfaces.C.int := filename_expand
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
        Code : Interfaces.C.int := filename_expand
           (Result,
            Interfaces.C.int (Max_Path_Length),
            Interfaces.C.To_C (Name));
    begin
        Changed := Code /= 0;
        return Interfaces.C.To_Ada (Result);
    end Expand;




    function Base_Name
           (Name : in Path_String)
        return Path_String
    is
        Data : Interfaces.C.char_array := Interfaces.C.To_C (Name);
    begin
        return Interfaces.C.Strings.Value (filename_name (Data));
    end Base_Name;


    function Extension
           (Name : in Path_String)
        return Path_String
    is
        Data : Interfaces.C.char_array := Interfaces.C.To_C (Name);
        Result : Interfaces.C.Strings.chars_ptr := filename_ext (Data);
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
        Data : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Max_Path_Length)) :=
           (others => Interfaces.C.char'Val (0));
        Result : Interfaces.C.Strings.chars_ptr;
    begin
        Data (1 .. Name'Length) := Interfaces.C.To_C (Name);
        Result := filename_setext
           (Data,
            Data'Length,
            Interfaces.C.To_C (Suffix));
        return Interfaces.C.Strings.Value (Result);
    end Set_Extension;




    function Is_Directory
           (Name : in Path_String)
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
        Result : Comparison := Current_Sort
           (Interfaces.C.Strings.Value (filename_dname (DA, 0)),
            Interfaces.C.Strings.Value (filename_dname (DB, 0)));
    begin
        return Comparison'Pos (Result) - 1;
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
        end return;
    end Get_Listing;




    function Match
           (Input, Pattern : in String)
        return Boolean is
    begin
        return filename_match (Interfaces.C.To_C (Input), Interfaces.C.To_C (Pattern)) /= 0;
    end Match;


end FLTK.Filenames;


