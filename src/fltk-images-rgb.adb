

with

    Interfaces.C,
    System;

use type

    System.Address;


package body FLTK.Images.RGB is


    function new_fl_rgb_image
           (Data       : in System.Address;
            W, H, D, L : in Interfaces.C.int)
        return System.Address;
    pragma Import (C, new_fl_rgb_image, "new_fl_rgb_image");
    pragma Inline (new_fl_rgb_image);

    function new_fl_rgb_image2
           (P : in System.Address;
            C : in Interfaces.C.unsigned)
        return System.Address;
    pragma Import (C, new_fl_rgb_image2, "new_fl_rgb_image2");
    pragma Inline (new_fl_rgb_image2);

    procedure free_fl_rgb_image
           (I : in System.Address);
    pragma Import (C, free_fl_rgb_image, "free_fl_rgb_image");
    pragma Inline (free_fl_rgb_image);

    function fl_rgb_image_get_max_size
        return Interfaces.C.size_t;
    pragma Import (C, fl_rgb_image_get_max_size, "fl_rgb_image_get_max_size");
    pragma Inline (fl_rgb_image_get_max_size);

    procedure fl_rgb_image_set_max_size
           (V : in Interfaces.C.size_t);
    pragma Import (C, fl_rgb_image_set_max_size, "fl_rgb_image_set_max_size");
    pragma Inline (fl_rgb_image_set_max_size);

    function fl_rgb_image_copy
           (I    : in System.Address;
            W, H : in Interfaces.C.int)
        return System.Address;
    pragma Import (C, fl_rgb_image_copy, "fl_rgb_image_copy");
    pragma Inline (fl_rgb_image_copy);

    function fl_rgb_image_copy2
           (I : in System.Address)
        return System.Address;
    pragma Import (C, fl_rgb_image_copy2, "fl_rgb_image_copy2");
    pragma Inline (fl_rgb_image_copy2);




    procedure fl_rgb_image_color_average
           (I : in System.Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_rgb_image_color_average, "fl_rgb_image_color_average");
    pragma Inline (fl_rgb_image_color_average);

    procedure fl_rgb_image_desaturate
           (I : in System.Address);
    pragma Import (C, fl_rgb_image_desaturate, "fl_rgb_image_desaturate");
    pragma Inline (fl_rgb_image_desaturate);




    procedure fl_rgb_image_uncache
           (I : in System.Address);
    pragma Import (C, fl_rgb_image_uncache, "fl_rgb_image_uncache");
    pragma Inline (fl_rgb_image_uncache);




    procedure fl_rgb_image_draw2
           (I    : in System.Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_rgb_image_draw2, "fl_rgb_image_draw2");
    pragma Inline (fl_rgb_image_draw2);

    procedure fl_rgb_image_draw
           (I                  : in System.Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_rgb_image_draw, "fl_rgb_image_draw");
    pragma Inline (fl_rgb_image_draw);




    overriding procedure Finalize
           (This : in out RGB_Image) is
    begin
        if  This.Void_Ptr /= System.Null_Address and then
            This in RGB_Image'Class
        then
            free_fl_rgb_image (This.Void_Ptr);
            This.Void_Ptr := System.Null_Address;
        end if;
        Finalize (Image (This));
    end Finalize;




    --------------------
    --  Construction  --
    --------------------

    package body Forge is

        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural;
                Depth         : in Natural := 3;
                Line_Data     : in Natural := 0)
            return RGB_Image is
        begin
            return This : RGB_Image do
                This.Void_Ptr := new_fl_rgb_image
                   (Data (Data'First)'Address,
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height),
                    Interfaces.C.int (Depth),
                    Interfaces.C.int (Line_Data));
                case fl_image_fail (This.Void_Ptr) is
                    when 1 => raise No_Image_Error;
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

        function Create
               (Data       : in FLTK.Images.Pixmaps.Pixmap'Class;
                Background : in Color := Background_Color)
            return RGB_Image is
        begin
            return This : RGB_Image do
                This.Void_Ptr := new_fl_rgb_image2
                   (Wrapper (Data).Void_Ptr,
                    Interfaces.C.unsigned (Background));
                case fl_image_fail (This.Void_Ptr) is
                    when 1 => raise No_Image_Error;
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

    end Forge;


    function Get_Max_Size
        return Natural is
    begin
        return Natural (fl_rgb_image_get_max_size);
    end Get_Max_Size;


    procedure Set_Max_Size
           (Value : in Natural) is
    begin
        fl_rgb_image_set_max_size (Interfaces.C.size_t (Value));
    end Set_Max_Size;


    function Copy
           (This          : in RGB_Image;
            Width, Height : in Natural)
        return RGB_Image'Class is
    begin
        return Copied : RGB_Image do
            Copied.Void_Ptr := fl_rgb_image_copy
                   (This.Void_Ptr,
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height));
        end return;
    end Copy;


    function Copy
           (This : in RGB_Image)
        return RGB_Image'Class is
    begin
        return Copied : RGB_Image do
            Copied.Void_Ptr := fl_rgb_image_copy2 (This.Void_Ptr);
        end return;
    end Copy;




    --------------
    --  Colors  --
    --------------

    procedure Color_Average
           (This   : in out RGB_Image;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_rgb_image_color_average
           (This.Void_Ptr,
            Interfaces.C.int (Col),
            Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out RGB_Image) is
    begin
        fl_rgb_image_desaturate (This.Void_Ptr);
    end Desaturate;




    ----------------
    --  Activity  --
    ----------------

    procedure Uncache
           (This : in out RGB_Image) is
    begin
        fl_rgb_image_uncache (This.Void_Ptr);
    end Uncache;




    ---------------
    --  Drawing  --
    ---------------

    procedure Draw
           (This : in RGB_Image;
            X, Y : in Integer) is
    begin
        fl_rgb_image_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;


    procedure Draw
           (This       : in RGB_Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0) is
    begin
        fl_rgb_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (CX),
            Interfaces.C.int (CY));
    end Draw;


end FLTK.Images.RGB;

