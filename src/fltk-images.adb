

with

    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Images is


    function new_fl_image
           (W, H, D : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_image, "new_fl_image");
    pragma Inline (new_fl_image);

    procedure free_fl_image
           (I : in Storage.Integer_Address);
    pragma Import (C, free_fl_image, "free_fl_image");
    pragma Inline (free_fl_image);




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

    function fl_image_count
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_count, "fl_image_count");
    pragma Inline (fl_image_count);




    function fl_image_data
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_image_data, "fl_image_data");
    pragma Inline (fl_image_data);

    function fl_image_get_pixel
           (C : in Interfaces.C.Strings.chars_ptr;
            O : in Interfaces.C.int)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_image_get_pixel, "fl_image_get_pixel");
    pragma Inline (fl_image_get_pixel);

    procedure fl_image_set_pixel
           (C : in Interfaces.C.Strings.chars_ptr;
            O : in Interfaces.C.int;
            V : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_image_set_pixel, "fl_image_set_pixel");
    pragma Inline (fl_image_set_pixel);




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




    overriding procedure Finalize
           (This : in out Image) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Image'Class
        then
            if This.Needs_Dealloc then
                free_fl_image (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Construction  --
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
                case fl_image_fail (This.Void_Ptr) is
                    when 1 => raise No_Image_Error;
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

    end Forge;


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




    --------------
    --  Colors  --
    --------------

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




    ----------------
    --  Activity  --
    ----------------

    procedure Inactive
           (This : in out Image) is
    begin
        fl_image_inactive (This.Void_Ptr);
    end Inactive;


    function Is_Empty
           (This : in Image)
        return Boolean is
    begin
        return fl_image_fail (This.Void_Ptr) /= 0;
    end Is_Empty;


    procedure Uncache
           (This : in out Image) is
    begin
        fl_image_uncache (This.Void_Ptr);
    end Uncache;




    ------------------
    --  Dimensions  --
    ------------------

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


    function Get_Line_Data
           (This : in Image)
        return Natural is
    begin
        return Natural (fl_image_ld (This.Void_Ptr));
    end Get_Line_Data;


    function Get_Data_Count
           (This : in Image)
        return Natural is
    begin
        return Natural (fl_image_count (This.Void_Ptr));
    end Get_Data_Count;


    function Get_Data_Size
           (This : in Image)
        return Natural
    is
        My_Depth : Natural := This.Get_D;
        My_Line_Data : Natural := This.Get_Line_Data;
    begin
        if My_Line_Data > 0 then
            return My_Line_Data * This.Get_H;
        elsif My_Depth = 0 then
            return Integer (Float'Ceiling (Float (This.Get_W) / 8.0)) * This.Get_H;
        else
            return This.Get_W * My_Depth * This.Get_H;
        end if;
    end Get_Data_Size;




    ------------------
    --  Pixel Data  --
    ------------------

    function Get_Datum
           (This     : in Image;
            Data     : in Positive;
            Position : in Positive)
        return Color_Component
    is
        Pointers : array (1 .. This.Get_Data_Count) of Interfaces.C.Strings.chars_ptr;
        for Pointers'Address use Storage.To_Address (fl_image_data (This.Void_Ptr));
        pragma Import (Ada, Pointers);
    begin
        return Color_Component
            (fl_image_get_pixel (Pointers (Data), Interfaces.C.int (Position) - 1));
    end Get_Datum;


    procedure Set_Datum
           (This     : in out Image;
            Data     : in     Positive;
            Position : in     Positive;
            Value    : in     Color_Component)
    is
        Pointers : array (1 .. This.Get_Data_Count) of Interfaces.C.Strings.chars_ptr;
        for Pointers'Address use Storage.To_Address (fl_image_data (This.Void_Ptr));
        pragma Import (Ada, Pointers);
    begin
        fl_image_set_pixel
           (Pointers (Data),
            Interfaces.C.int (Position) - 1,
            Interfaces.C.unsigned_char (Value));
    end Set_Datum;


    function Get_Data
           (This     : in Image;
            Data     : in Positive;
            Position : in Positive;
            Count    : in Natural)
        return Color_Component_Array
    is
        Pointers : array (1 .. This.Get_Data_Count) of Interfaces.C.Strings.chars_ptr;
        for Pointers'Address use Storage.To_Address (fl_image_data (This.Void_Ptr));
        pragma Import (Ada, Pointers);
        Result : Color_Component_Array := (1 .. Count => 0);
    begin
        for Index in Result'Range loop
            Result (Index) := Color_Component (fl_image_get_pixel
               (Pointers (Data),
                Interfaces.C.int (Index - 1 + Position - 1)));
        end loop;
        return Result;
    end Get_Data;


    function All_Data
           (This : in Image;
            Data : in Positive)
        return Color_Component_Array is
    begin
        return This.Get_Data (Data, 1, This.Get_Data_Size);
    end All_Data;


    procedure Update_Data
           (This     : in out Image;
            Data     : in     Positive;
            Position : in     Positive;
            Values   : in     Color_Component_Array)
    is
        Pointers : array (1 .. This.Get_Data_Count) of Interfaces.C.Strings.chars_ptr;
        for Pointers'Address use Storage.To_Address (fl_image_data (This.Void_Ptr));
        pragma Import (Ada, Pointers);
    begin
        for Counter in Integer range 0 .. Values'Length - 1 loop
            fl_image_set_pixel
               (Pointers (Data),
                Interfaces.C.int (Position - 1 + Counter),
                Interfaces.C.unsigned_char (Values (Values'First + Counter)));
        end loop;
    end Update_Data;




    ---------------
    --  Drawing  --
    ---------------

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
           (This       : in Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0) is
    begin
        fl_image_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (CX),
            Interfaces.C.int (CY));
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

