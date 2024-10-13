

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.RGB.PNG is


    function new_fl_png_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_png_image, "new_fl_png_image");
    pragma Inline (new_fl_png_image);

    function new_fl_png_image2
           (N : in Interfaces.C.char_array;
            D : in Storage.Integer_Address;
            S : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_png_image2, "new_fl_png_image2");
    pragma Inline (new_fl_png_image2);

    procedure free_fl_png_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_png_image, "free_fl_png_image");
    pragma Inline (free_fl_png_image);




    overriding procedure Finalize
           (This : in out PNG_Image) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in PNG_Image'Class
        then
            free_fl_png_image (This.Void_Ptr);
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
            return PNG_Image is
        begin
            return This : PNG_Image do
                This.Void_Ptr := new_fl_png_image
                   (Interfaces.C.To_C (Filename));
                case fl_image_fail (This.Void_Ptr) is
                    when 1 => raise No_Image_Error;
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return PNG_Image is
        begin
            return This : PNG_Image do
                This.Void_Ptr := new_fl_png_image2
                   (Interfaces.C.To_C (Name),
                    Storage.To_Integer (Data (Data'First)'Address),
                    Data'Length);
                case fl_image_fail (This.Void_Ptr) is
                    when 1 => raise No_Image_Error;
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

    end Forge;


end FLTK.Images.RGB.PNG;

