

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.RGB.PNG is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

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




    --  Writing  --

    function fl_png_image_write
           (N : in Interfaces.C.char_array;
            I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_png_image_write, "fl_png_image_write");
    pragma Inline (fl_png_image_write);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out PNG_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_png_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return PNG_Image is
        begin
            return This : PNG_Image do
                This.Void_Ptr := new_fl_png_image
                   (Interfaces.C.To_C (Filename));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for a PNG_Image";
                end if;
                Raise_Fail_Errors (This);
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
                    (if Data'Length > 0
                     then Storage.To_Integer (Data (Data'First)'Address)
                     else Null_Pointer),
                    Data'Length);
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for a PNG_Image";
                end if;
                Raise_Fail_Errors (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Write_PNG
           (Item     : in RGB_Image'Class;
            Filename : in String)
    is
        use type Interfaces.C.int;
        Result : Interfaces.C.int;
    begin
        if Item.Void_Ptr = Null_Pointer then
            raise No_Image_Error with "Write_PNG of an image that was never created";
        end if;
        Result := fl_png_image_write (Interfaces.C.To_C (Filename), Item.Void_Ptr);
        case Result is
            when 0 => null;
            when -1 => raise FLTK.Unsupported_Error with "FLTK was built without libpng";
            when -2 => raise File_Access_Error with "Write_PNG can't open " & Filename;
            when -3 => raise No_Image_Error with "Write_PNG of an image with no pixels";
            when others =>
                raise Internal_FLTK_Error with
                    "fl_write_png gave" & Interfaces.C.int'Image (Result);
        end case;
    end Write_PNG;


end FLTK.Images.RGB.PNG;


