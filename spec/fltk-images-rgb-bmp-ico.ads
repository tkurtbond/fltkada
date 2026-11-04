

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


package FLTK.Images.RGB.BMP.ICO is


    type ICO_Image is new BMP_Image with private;

    type ICO_Image_Reference (Data : not null access ICO_Image'Class) is limited null record
        with Implicit_Dereference => Data;


    --  One entry of an ICO's directory, as the file has it:  a width or
    --  height of 0 is 256.
    type Icon_Entry is record
        Width, Height  : Natural;
        Color_Count    : Natural;
        Reserved       : Natural;
        Planes         : Natural;
        Bit_Count      : Natural;
        Resource_Bytes : Size_Type;
        Image_Offset   : Size_Type;
    end record;

    type Icon_Entry_Array is array (Positive range <>) of Icon_Entry;




    package Forge is

        --  Id is the entry to show, counted from 0, or -1 for the largest.
        --  A file is read whole and decoded as Data is, so that an entry
        --  that is a PNG loads from either (pofltk 82).  An Id at or past
        --  the number of entries raises Constraint_Error, and an Id below
        --  -1 does too.  A bitmap entry FLTK would read past raises
        --  Format_Error (pofltk 87).
        function Create
               (Filename : in String;
                Id       : in Integer := -1)
            return ICO_Image;

        function Create
               (Data : in Color_Component_Array;
                Id   : in Integer := -1)
            return ICO_Image;

    end Forge;




    --  How many images a file or data holds, read from its directory.  A
    --  file that can't be read raises File_Access_Error, and one that isn't
    --  an ICO Format_Error.
    function ICO_Count
           (Filename : in String)
        return Natural;

    function ICO_Count
           (Data : in Color_Component_Array)
        return Natural;




    --  The entries of the image's directory, the first the one of Id 0.
    function Entries
           (This : in ICO_Image)
        return Icon_Entry_Array;


private


    type ICO_Image is new BMP_Image with null record;

    overriding procedure Finalize
           (This : in out ICO_Image);


end FLTK.Images.RGB.BMP.ICO;


