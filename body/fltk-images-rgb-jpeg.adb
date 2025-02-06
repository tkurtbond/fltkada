

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.RGB.JPEG is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_jpeg_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_jpeg_image, "new_fl_jpeg_image");
    pragma Inline (new_fl_jpeg_image);

    function new_fl_jpeg_image2
           (N : in Interfaces.C.char_array;
            D : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_jpeg_image2, "new_fl_jpeg_image2");
    pragma Inline (new_fl_jpeg_image2);

    procedure free_fl_jpeg_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_jpeg_image, "free_fl_jpeg_image");
    pragma Inline (free_fl_jpeg_image);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out JPEG_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_jpeg_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return JPEG_Image is
        begin
            return This : JPEG_Image do
                This.Void_Ptr := new_fl_jpeg_image
                   (Interfaces.C.To_C (Filename));
                Raise_Fail_Errors (This);
            end return;
        end Create;


        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return JPEG_Image is
        begin
            return This : JPEG_Image do
                This.Void_Ptr := new_fl_jpeg_image2
                   (Interfaces.C.To_C (Name),
                    Storage.To_Integer (Data (Data'First)'Address));
                Raise_Fail_Errors (This);
            end return;
        end Create;

    end Forge;


end FLTK.Images.RGB.JPEG;


