

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.Bitmaps.XBM is


    -------------
    --  Types  --
    -------------

    type XBM_Image is new Bitmap with private;

    type XBM_Image_Reference (Data : not null access XBM_Image'Class) is limited null record
        with Implicit_Dereference => Data;




    --------------------
    --  Construction  --
    --------------------

    package Forge is

        function Create
               (Filename : in String)
            return XBM_Image;

    end Forge;


private


    type XBM_Image is new Bitmap with null record;

    overriding procedure Finalize
           (This : in out XBM_Image);


end FLTK.Images.Bitmaps.XBM;

