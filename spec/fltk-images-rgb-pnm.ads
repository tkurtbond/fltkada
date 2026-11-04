

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.RGB.PNM is


    type PNM_Image is new RGB_Image with private;

    type PNM_Image_Reference (Data : not null access PNM_Image'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        --  The samples of a binary PNM (P5, P6) with a maxval under 255
        --  are scaled to 0 .. 255, as FLTK scales the text forms, and a
        --  sample over the maxval reads as 255 (pofltk 45).
        function Create
               (Filename : in String)
            return PNM_Image;

    end Forge;


private


    type PNM_Image is new RGB_Image with null record;

    overriding procedure Finalize
           (This : in out PNM_Image);


end FLTK.Images.RGB.PNM;


