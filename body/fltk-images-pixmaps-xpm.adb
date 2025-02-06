

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.Pixmaps.XPM is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_xpm_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_xpm_image, "new_fl_xpm_image");
    pragma Inline (new_fl_xpm_image);

    procedure free_fl_xpm_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_xpm_image, "free_fl_xpm_image");
    pragma Inline (free_fl_xpm_image);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out XPM_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_xpm_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return XPM_Image is
        begin
            return This : XPM_Image do
                This.Void_Ptr := new_fl_xpm_image
                   (Interfaces.C.To_C (Filename));
                Raise_Fail_Errors (This);
            end return;
        end Create;

    end Forge;


end FLTK.Images.Pixmaps.XPM;


