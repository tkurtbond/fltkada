

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.RGB.BMP is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_bmp_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_bmp_image, "new_fl_bmp_image");
    pragma Inline (new_fl_bmp_image);

    procedure free_fl_bmp_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_bmp_image, "free_fl_bmp_image");
    pragma Inline (free_fl_bmp_image);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out BMP_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_bmp_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return BMP_Image is
        begin
            return This : BMP_Image do
                This.Void_Ptr := new_fl_bmp_image
                   (Interfaces.C.To_C (Filename));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for a BMP_Image";
                end if;
                Raise_Fail_Errors (This);
            end return;
        end Create;

    end Forge;


end FLTK.Images.RGB.BMP;


