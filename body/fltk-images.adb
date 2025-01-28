

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Images is


    ------------------------
    --  Constants From C  --
    ------------------------

    fl_image_err_no_image : constant Interfaces.C.int;
    pragma Import (C, fl_image_err_no_image, "fl_image_err_no_image");

    fl_image_err_file_access : constant Interfaces.C.int;
    pragma Import (C, fl_image_err_file_access, "fl_image_err_file_access");

    fl_image_err_format : constant Interfaces.C.int;
    pragma Import (C, fl_image_err_format, "fl_image_err_format");




    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_image
           (W, H, D : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_image, "new_fl_image");
    pragma Inline (new_fl_image);

    procedure free_fl_image
           (I : in Storage.Integer_Address);
    pragma Import (C, free_fl_image, "free_fl_image");
    pragma Inline (free_fl_image);




    function fl_image_fail
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_fail, "fl_image_fail");




    function fl_image_get_rgb_scaling
        return Interfaces.C.int;
    pragma Import (C, fl_image_get_rgb_scaling, "fl_image_get_rgb_scaling");
    pragma Inline (fl_image_get_rgb_scaling);

    procedure fl_image_set_rgb_scaling
           (T : in Interfaces.C.int);
    pragma Import (C, fl_image_set_rgb_scaling, "fl_image_set_rgb_scaling");
    pragma Inline (fl_image_set_rgb_scaling);

    function fl_image_copy
           (I    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_image_copy, "fl_image_copy");
    pragma Inline (fl_image_copy);

    function fl_image_copy2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_image_copy2, "fl_image_copy2");
    pragma Inline (fl_image_copy2);




    procedure fl_image_color_average
           (I : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_image_color_average, "fl_image_color_average");
    pragma Inline (fl_image_color_average);

    procedure fl_image_desaturate
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_image_desaturate, "fl_image_desaturate");
    pragma Inline (fl_image_desaturate);




    procedure fl_image_inactive
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_image_inactive, "fl_image_inactive");
    pragma Inline (fl_image_inactive);

    procedure fl_image_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_image_uncache, "fl_image_uncache");
    pragma Inline (fl_image_uncache);




    function fl_image_w
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_w, "fl_image_w");
    pragma Inline (fl_image_w);

    function fl_image_h
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_h, "fl_image_h");
    pragma Inline (fl_image_h);

    function fl_image_d
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_d, "fl_image_d");
    pragma Inline (fl_image_d);

    function fl_image_ld
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_ld, "fl_image_ld");
    pragma Inline (fl_image_ld);




    procedure fl_image_draw
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_image_draw, "fl_image_draw");
    pragma Inline (fl_image_draw);

    procedure fl_image_draw2
           (I                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_image_draw2, "fl_image_draw2");
    pragma Inline (fl_image_draw2);

    procedure fl_image_draw_empty
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_image_draw_empty, "fl_image_draw_empty");
    pragma Inline (fl_image_draw_empty);




    ------------------------
    --  Internal Utility  --
    ------------------------

    procedure Raise_Fail_Errors
           (This : in Image'Class)
    is
        Result : Interfaces.C.int := fl_image_fail (This.Void_Ptr);
    begin
        if Result = fl_image_err_no_image and This.Is_Empty then
            raise No_Image_Error;
        elsif Result = fl_image_err_file_access then
            raise File_Access_Error;
        elsif Result = fl_image_err_format then
            raise Format_Error;
        end if;
    end Raise_Fail_Errors;




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Width, Height, Depth : in Natural)
            return Image is
        begin
            return This : Image do
                This.Void_Ptr := new_fl_image
                   (Interfaces.C.int (Width),
                    Interfaces.C.int (Height),
                    Interfaces.C.int (Depth));
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Copying  --

    function Get_Copy_Algorithm
        return Scaling_Kind is
    begin
        return Scaling_Kind'Val (fl_image_get_rgb_scaling);
    end Get_Copy_Algorithm;


    procedure Set_Copy_Algorithm
           (To : in Scaling_Kind) is
    begin
        fl_image_set_rgb_scaling (Scaling_Kind'Pos (To));
    end Set_Copy_Algorithm;


    function Copy
           (This          : in Image;
            Width, Height : in Natural)
        return Image'Class is
    begin
        return Copied : Image do
            Copied.Void_Ptr := fl_image_copy
               (This.Void_Ptr,
                Interfaces.C.int (Width),
                Interfaces.C.int (Height));
        end return;
    end Copy;


    function Copy
           (This : in Image)
        return Image'Class is
    begin
        return Copied : Image do
            Copied.Void_Ptr := fl_image_copy2 (This.Void_Ptr);
        end return;
    end Copy;




    --  Colors  --

    procedure Color_Average
           (This   : in out Image;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_image_color_average
           (This.Void_Ptr,
            Interfaces.C.int (Col),
            Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out Image) is
    begin
        fl_image_desaturate (This.Void_Ptr);
    end Desaturate;




    --  Activity  --

    procedure Inactive
           (This : in out Image) is
    begin
        fl_image_inactive (This.Void_Ptr);
    end Inactive;


    function Is_Empty
           (This : in Image)
        return Boolean is
    begin
        return fl_image_count (This.Void_Ptr) = 0 or This.Get_W = 0 or This.Get_H = 0;
    end Is_Empty;


    procedure Uncache
           (This : in out Image) is
    begin
        fl_image_uncache (This.Void_Ptr);
    end Uncache;




    --  Dimensions  --

    function Get_W
           (This : in Image)
        return Natural is
    begin
        return Natural (fl_image_w (This.Void_Ptr));
    end Get_W;


    function Get_H
           (This : in Image)
        return Natural is
    begin
        return Natural (fl_image_h (This.Void_Ptr));
    end Get_H;


    function Get_D
           (This : in Image)
        return Natural is
    begin
        return Natural (fl_image_d (This.Void_Ptr));
    end Get_D;


    function Get_Line_Size
           (This : in Image)
        return Natural is
    begin
        return Natural (fl_image_ld (This.Void_Ptr));
    end Get_Line_Size;




    --  Drawing  --

    procedure Draw
           (This : in Image;
            X, Y : in Integer) is
    begin
        fl_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;


    procedure Draw
           (This           : in Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0) is
    begin
        fl_image_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Clip_X),
            Interfaces.C.int (Clip_Y));
    end Draw;


    procedure Draw_Empty
           (This : in Image;
            X, Y : in Integer) is
    begin
        fl_image_draw_empty
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw_Empty;


end FLTK.Images;


