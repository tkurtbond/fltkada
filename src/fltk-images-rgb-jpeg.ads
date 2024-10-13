

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.RGB.JPEG is


    -------------
    --  Types  --
    -------------

    type JPEG_Image is new RGB_Image with private;

    type JPEG_Image_Reference (Data : not null access JPEG_Image'Class) is
        limited null record with Implicit_Dereference => Data;




    --------------------
    --  Construction  --
    --------------------

    package Forge is

        function Create
               (Filename : in String)
            return JPEG_Image;

        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return JPEG_Image;

    end Forge;


private


    type JPEG_Image is new RGB_Image with null record;

    overriding procedure Finalize
           (This : in out JPEG_Image);


end FLTK.Images.RGB.JPEG;

