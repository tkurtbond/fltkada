

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Images.RGB.BMP.ICO is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_ico_image
           (F  : in Interfaces.C.char_array;
            Id : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_ico_image, "new_fl_ico_image");
    pragma Inline (new_fl_ico_image);

    function new_fl_ico_image2
           (D  : in Storage.Integer_Address;
            S  : in Interfaces.C.unsigned_long;
            Id : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_ico_image2, "new_fl_ico_image2");
    pragma Inline (new_fl_ico_image2);

    procedure free_fl_ico_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_ico_image, "free_fl_ico_image");
    pragma Inline (free_fl_ico_image);




    --  Directory  --

    function fl_ico_image_idcount
           (P : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_ico_image_idcount, "fl_ico_image_idcount");
    pragma Inline (fl_ico_image_idcount);

    type Entry_Fields is array (1 .. 8) of Interfaces.C.unsigned
        with Convention => C;

    procedure fl_ico_image_entry
           (P      : in     Storage.Integer_Address;
            K      : in     Interfaces.C.int;
            Fields :    out Entry_Fields);
    pragma Import (C, fl_ico_image_entry, "fl_ico_image_entry");
    pragma Inline (fl_ico_image_entry);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out ICO_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_ico_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Check_Id
           (Id : in Integer) is
    begin
        if Id < -1 then
            raise Constraint_Error with "ICO_Image Create with id" & Integer'Image (Id);
        end if;
    end Check_Id;


    --  An Id past the directory fails as a format error; it is the caller's,
    --  so it raises Constraint_Error.
    procedure Check_Loaded
           (This : in ICO_Image;
            Id   : in Integer)
    is
        Count : Integer;
    begin
        if This.Void_Ptr = Null_Pointer then
            raise Storage_Error with "no memory for an ICO_Image";
        end if;
        Count := Integer (fl_ico_image_idcount (This.Void_Ptr));
        if Count > 0 and Id >= Count then
            raise Constraint_Error with "ICO_Image Create with id" & Integer'Image (Id)
                & ", of" & Integer'Image (Count) & " entries";
        end if;
        Raise_Fail_Errors (This);
    end Check_Loaded;


    package body Forge is

        function Create
               (Filename : in String;
                Id       : in Integer := -1)
            return ICO_Image is
        begin
            Check_Id (Id);
            return This : ICO_Image do
                This.Void_Ptr := new_fl_ico_image
                   (Interfaces.C.To_C (Filename),
                    Interfaces.C.int (Id));
                Check_Loaded (This, Id);
            end return;
        end Create;


        function Create
               (Data : in Color_Component_Array;
                Id   : in Integer := -1)
            return ICO_Image is
        begin
            Check_Id (Id);
            return This : ICO_Image do
                This.Void_Ptr := new_fl_ico_image2
                   ((if Data'Length > 0
                     then Storage.To_Integer (Data (Data'First)'Address)
                     else Null_Pointer),
                    Interfaces.C.unsigned_long (Data'Length),
                    Interfaces.C.int (Id));
                Check_Loaded (This, Id);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  The count of a directory loaded with Id 0: one that loads no entry
    --  fails, and that is the count's to report only if there are none.
    function Count_Of
           (This : in ICO_Image)
        return Natural
    is
        Count : constant Natural := Natural (fl_ico_image_idcount (This.Void_Ptr));
    begin
        if Count = 0 then
            Raise_Fail_Errors (This);
        end if;
        return Count;
    end Count_Of;


    function ICO_Count
           (Filename : in String)
        return Natural
    is
        Dir : ICO_Image;
    begin
        Dir.Void_Ptr := new_fl_ico_image (Interfaces.C.To_C (Filename), -2);
        if Dir.Void_Ptr = Null_Pointer then
            raise Storage_Error with "no memory for an ICO_Image";
        end if;
        return Count_Of (Dir);
    end ICO_Count;


    function ICO_Count
           (Data : in Color_Component_Array)
        return Natural
    is
        Dir : ICO_Image;
    begin
        Dir.Void_Ptr := new_fl_ico_image2
           ((if Data'Length > 0
             then Storage.To_Integer (Data (Data'First)'Address)
             else Null_Pointer),
            Interfaces.C.unsigned_long (Data'Length),
            -2);
        if Dir.Void_Ptr = Null_Pointer then
            raise Storage_Error with "no memory for an ICO_Image";
        end if;
        return Count_Of (Dir);
    end ICO_Count;


    function Entries
           (This : in ICO_Image)
        return Icon_Entry_Array
    is
        Count  : constant Natural :=
            (if This.Void_Ptr = Null_Pointer
             then 0
             else Natural (fl_ico_image_idcount (This.Void_Ptr)));
        Fields : Entry_Fields;
    begin
        return Result : Icon_Entry_Array (1 .. Count) do
            for K in Result'Range loop
                fl_ico_image_entry (This.Void_Ptr, Interfaces.C.int (K - 1), Fields);
                Result (K) :=
                   (Width          => Natural (Fields (1)),
                    Height         => Natural (Fields (2)),
                    Color_Count    => Natural (Fields (3)),
                    Reserved       => Natural (Fields (4)),
                    Planes         => Natural (Fields (5)),
                    Bit_Count      => Natural (Fields (6)),
                    Resource_Bytes => Size_Type (Fields (7)),
                    Image_Offset   => Size_Type (Fields (8)));
            end loop;
        end return;
    end Entries;


end FLTK.Images.RGB.BMP.ICO;


