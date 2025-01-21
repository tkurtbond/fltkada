

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.RGB.PNG is


    -------------
    --  Types  --
    -------------

    type PNG_Image is new RGB_Image with private;

    type PNG_Image_Reference (Data : not null access PNG_Image'Class) is limited null record
        with Implicit_Dereference => Data;




    --------------------
    --  Construction  --
    --------------------

    package Forge is

        function Create
               (Filename : in String)
            return PNG_Image;

        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return PNG_Image;

    end Forge;


private


    type PNG_Image is new RGB_Image with null record;

    overriding procedure Finalize
           (This : in out PNG_Image);


end FLTK.Images.RGB.PNG;

