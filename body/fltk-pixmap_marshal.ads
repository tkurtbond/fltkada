

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Images.Pixmaps;

with

    Interfaces.C.Strings;


private package FLTK.Pixmap_Marshal is


    type chars_ptr_array_access is access all Interfaces.C.Strings.chars_ptr_array;




    --  From Ada to C char *  --

    --  Note the resulting chars_ptr_array_access must be deallocated manually.

    function To_Coltype
           (Value : in FLTK.Images.Pixmaps.Color_Kind)
        return Character;

    --  Raises Constraint_Error if the data isn't as the header says, so
    --  that FLTK doesn't read past it (FLTKAda-BUGS.md 77).
    function Marshal_Data
           (Values : in FLTK.Images.Pixmaps.Header;
            Colors : in FLTK.Images.Pixmaps.Color_Definition_Array;
            Pixels : in FLTK.Images.Pixmaps.Pixmap_Data)
        return chars_ptr_array_access;

    procedure Free_Recursive
           (This : in out chars_ptr_array_access);


end FLTK.Pixmap_Marshal;


