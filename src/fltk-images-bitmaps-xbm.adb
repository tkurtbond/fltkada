

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.Bitmaps.XBM is


    function new_fl_xbm_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_xbm_image, "new_fl_xbm_image");
    pragma Inline (new_fl_xbm_image);

    procedure free_fl_xbm_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_xbm_image, "free_fl_xbm_image");
    pragma Inline (free_fl_xbm_image);




    overriding procedure Finalize
           (This : in out XBM_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_xbm_image (This.Void_Ptr);
        end if;
    end Finalize;




    --------------------
    --  Construction  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return XBM_Image is
        begin
            return This : XBM_Image do
                This.Void_Ptr := new_fl_xbm_image
                       (Interfaces.C.To_C (Filename));
                case fl_image_fail (This.Void_Ptr) is
                    when 1 =>
                        --  raise No_Image_Error;
                        null;
                        --  Since the image depth and line data are both zero here,
                        --  the fail method will think there's no image even though
                        --  nothing is wrong. This is a bug in FLTK.
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

    end Forge;


end FLTK.Images.Bitmaps.XBM;

