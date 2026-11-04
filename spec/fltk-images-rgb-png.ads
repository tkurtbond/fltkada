

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.RGB.PNG is


    type PNG_Image is new RGB_Image with private;

    type PNG_Image_Reference (Data : not null access PNG_Image'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        function Create
               (Filename : in String)
            return PNG_Image;

        --  A non-empty Name also shares the image under that name, while the
        --  image lasts (FLTK-issues.md F8).
        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return PNG_Image;

    end Forge;




    --  Writes Item's data, at its data size, to Filename as a PNG.  An image
    --  with no pixels raises No_Image_Error, a file that can't be opened
    --  File_Access_Error, and a FLTK built without libpng Unsupported_Error.
    procedure Write_PNG
           (Item     : in RGB_Image'Class;
            Filename : in String);


private


    type PNG_Image is new RGB_Image with null record;

    overriding procedure Finalize
           (This : in out PNG_Image);


end FLTK.Images.RGB.PNG;


