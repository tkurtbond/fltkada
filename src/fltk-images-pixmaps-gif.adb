

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.Pixmaps.GIF is


    function new_fl_gif_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_gif_image, "new_fl_gif_image");
    pragma Inline (new_fl_gif_image);

    procedure free_fl_gif_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_gif_image, "free_fl_gif_image");
    pragma Inline (free_fl_gif_image);




    overriding procedure Finalize
           (This : in out GIF_Image) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in GIF_Image'Class
        then
            free_fl_gif_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Pixmap (This));
    end Finalize;




    --------------------
    --  Construction  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return GIF_Image is
        begin
            return This : GIF_Image do
                This.Void_Ptr := new_fl_gif_image
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


end FLTK.Images.Pixmaps.GIF;

