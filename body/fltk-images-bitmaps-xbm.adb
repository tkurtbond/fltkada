

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.Bitmaps.XBM is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_xbm_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_xbm_image, "new_fl_xbm_image");
    pragma Inline (new_fl_xbm_image);

    procedure free_fl_xbm_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_xbm_image, "free_fl_xbm_image");
    pragma Inline (free_fl_xbm_image);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out XBM_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_xbm_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return XBM_Image is
        begin
            return This : XBM_Image do
                This.Void_Ptr := new_fl_xbm_image
                       (Interfaces.C.To_C (Filename));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an XBM_Image";
                end if;
                Raise_Fail_Errors (This);
            end return;
        end Create;

    end Forge;


end FLTK.Images.Bitmaps.XBM;


