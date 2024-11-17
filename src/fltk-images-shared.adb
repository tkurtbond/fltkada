

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Images.Shared is


    function fl_shared_image_get
           (F    : in Interfaces.C.char_array;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_get, "fl_shared_image_get");
    pragma Inline (fl_shared_image_get);

    function fl_shared_image_get2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_get2, "fl_shared_image_get2");
    pragma Inline (fl_shared_image_get2);

    function fl_shared_image_find
           (N    : in Interfaces.C.char_array;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_find, "fl_shared_image_find");
    pragma Inline (fl_shared_image_find);

    procedure fl_shared_image_release
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_release, "fl_shared_image_release");
    pragma Inline (fl_shared_image_release);

    function fl_shared_image_copy
           (I    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_copy, "fl_shared_image_copy");
    pragma Inline (fl_shared_image_copy);

    function fl_shared_image_copy2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_copy2, "fl_shared_image_copy2");
    pragma Inline (fl_shared_image_copy2);




    procedure fl_shared_image_color_average
           (I : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_shared_image_color_average, "fl_shared_image_color_average");
    pragma Inline (fl_shared_image_color_average);

    procedure fl_shared_image_desaturate
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_desaturate, "fl_shared_image_desaturate");
    pragma Inline (fl_shared_image_desaturate);




    function fl_shared_image_num_images
        return Interfaces.C.int;
    pragma Import (C, fl_shared_image_num_images, "fl_shared_image_num_images");
    pragma Inline (fl_shared_image_num_images);

    function fl_shared_image_name
           (I : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_shared_image_name, "fl_shared_image_name");
    pragma Inline (fl_shared_image_name);

    function fl_shared_image_original
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_shared_image_original, "fl_shared_image_original");
    pragma Inline (fl_shared_image_original);

    function fl_shared_image_refcount
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_shared_image_refcount, "fl_shared_image_refcount");
    pragma Inline (fl_shared_image_refcount);

    procedure fl_shared_image_reload
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_reload, "fl_shared_image_reload");
    pragma Inline (fl_shared_image_reload);

    procedure fl_shared_image_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_uncache, "fl_shared_image_uncache");
    pragma Inline (fl_shared_image_uncache);




    procedure fl_shared_image_scaling_algorithm
           (A : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_scaling_algorithm, "fl_shared_image_scaling_algorithm");
    pragma Inline (fl_shared_image_scaling_algorithm);

    procedure fl_shared_image_scale
           (I : in Storage.Integer_Address;
            W, H, P, E : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_scale, "fl_shared_image_scale");
    pragma Inline (fl_shared_image_scale);

    procedure fl_shared_image_draw
           (I                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_draw, "fl_shared_image_draw");
    pragma Inline (fl_shared_image_draw);

    procedure fl_shared_image_draw2
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_draw2, "fl_shared_image_draw2");
    pragma Inline (fl_shared_image_draw2);




    overriding procedure Finalize
           (This : in out Shared_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            fl_shared_image_release (This.Void_Ptr);
        end if;
    end Finalize;




    --------------------
    --  Construction  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String;
                W, H     : in Integer)
            return Shared_Image is
        begin
            return This : Shared_Image do
                This.Void_Ptr := fl_shared_image_get
                   (Interfaces.C.To_C (Filename),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H));
            end return;
        end Create;


        function Create
               (From : in FLTK.Images.RGB.RGB_Image'Class)
            return Shared_Image is
        begin
            return This : Shared_Image do
                This.Void_Ptr := fl_shared_image_get2 (Wrapper (From).Void_Ptr);
            end return;
        end Create;


        function Find
               (Name : in String;
                W, H : in Integer := 0)
            return Shared_Image is
        begin
            return This : Shared_Image do
                This.Void_Ptr := fl_shared_image_find
                   (Interfaces.C.To_C (Name),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H));
                if This.Void_Ptr = Null_Pointer then
                    raise No_Image_Error;
                end if;
            end return;
        end Find;

    end Forge;


    function Copy
           (This          : in Shared_Image;
            Width, Height : in Natural)
        return Shared_Image'Class is
    begin
        return Copied : Shared_Image do
            Copied.Void_Ptr := fl_shared_image_copy
                   (This.Void_Ptr,
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height));
        end return;
    end Copy;


    function Copy
           (This : in Shared_Image)
        return Shared_Image'Class is
    begin
        return Copied : Shared_Image do
            Copied.Void_Ptr := fl_shared_image_copy2 (This.Void_Ptr);
        end return;
    end Copy;




    --------------
    --  Colors  --
    --------------

    procedure Color_Average
           (This   : in out Shared_Image;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_shared_image_color_average
               (This.Void_Ptr,
                Interfaces.C.int (Col),
                Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out Shared_Image) is
    begin
        fl_shared_image_desaturate (This.Void_Ptr);
    end Desaturate;




    ----------------
    --  Activity  --
    ----------------

    function Number_Of_Images
        return Natural is
    begin
        return Natural (fl_shared_image_num_images);
    end Number_Of_Images;


    function Name
           (This : in Shared_Image)
        return String
    is
        Ptr : Interfaces.C.Strings.chars_ptr := fl_shared_image_name (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Name;


    function Original
           (This : in Shared_Image)
        return Boolean is
    begin
        return fl_shared_image_original (This.Void_Ptr) /= 0;
    end Original;


    function Reference_Count
           (This : in Shared_Image)
        return Natural is
    begin
        return Natural (fl_shared_image_refcount (This.Void_Ptr));
    end Reference_Count;


    procedure Reload
           (This : in out Shared_Image) is
    begin
        fl_shared_image_reload (This.Void_Ptr);
    end Reload;


    procedure Uncache
           (This : in out Shared_Image) is
    begin
        fl_shared_image_uncache (This.Void_Ptr);
    end Uncache;




    ---------------
    --  Drawing  --
    ---------------

    procedure Set_Scaling_Algorithm
           (To : in Scaling_Kind) is
    begin
        fl_shared_image_scaling_algorithm (Scaling_Kind'Pos (To));
    end Set_Scaling_Algorithm;


    procedure Scale
           (This         : in out Shared_Image;
            W, H         : in     Integer;
            Proportional : in     Boolean := True;
            Can_Expand   : in     Boolean := False) is
    begin
        fl_shared_image_scale
           (This.Void_Ptr,
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Boolean'Pos (Proportional),
            Boolean'Pos (Can_Expand));
    end Scale;


    procedure Draw
           (This       : in Shared_Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0) is
    begin
        fl_shared_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (CX),
            Interfaces.C.int (CY));
    end Draw;


    procedure Draw
           (This : in Shared_Image;
            X, Y : in Integer) is
    begin
        fl_shared_image_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;


end FLTK.Images.Shared;

