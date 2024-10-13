

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.RGB.BMP is


    function new_fl_bmp_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_bmp_image, "new_fl_bmp_image");
    pragma Inline (new_fl_bmp_image);

    procedure free_fl_bmp_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_bmp_image, "free_fl_bmp_image");
    pragma Inline (free_fl_bmp_image);




    overriding procedure Finalize
           (This : in out BMP_Image) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in BMP_Image'Class
        then
            free_fl_bmp_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (RGB_Image (This));
    end Finalize;




    --------------------
    --  Construction  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return BMP_Image is
        begin
            return This : BMP_Image do
                This.Void_Ptr := new_fl_bmp_image
                   (Interfaces.C.To_C (Filename));
                case fl_image_fail (This.Void_Ptr) is
                    when 1 => raise No_Image_Error;
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

    end Forge;


end FLTK.Images.RGB.BMP;

