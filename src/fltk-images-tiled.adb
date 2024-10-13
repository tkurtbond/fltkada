

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.Tiled is


    function new_fl_tiled_image
           (T    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_tiled_image, "new_fl_tiled_image");
    pragma Inline (new_fl_tiled_image);

    procedure free_fl_tiled_image
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_tiled_image, "free_fl_tiled_image");
    pragma Inline (free_fl_tiled_image);

    function fl_tiled_image_copy
           (T    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_tiled_image_copy, "fl_tiled_image_copy");
    pragma Inline (fl_tiled_image_copy);

    function fl_tiled_image_copy2
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tiled_image_copy2, "fl_tiled_image_copy2");
    pragma Inline (fl_tiled_image_copy2);




    function fl_tiled_image_get_image
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tiled_image_get_image, "fl_tiled_image_get_image");
    pragma Inline (fl_tiled_image_get_image);




    procedure fl_tiled_image_color_average
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_tiled_image_color_average, "fl_tiled_image_color_average");
    pragma Inline (fl_tiled_image_color_average);

    procedure fl_tiled_image_desaturate
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_tiled_image_desaturate, "fl_tiled_image_desaturate");
    pragma Inline (fl_tiled_image_desaturate);




    procedure fl_tiled_image_draw
           (T    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_tiled_image_draw, "fl_tiled_image_draw");
    pragma Inline (fl_tiled_image_draw);

    procedure fl_tiled_image_draw2
           (T          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            CX, CY     : in Interfaces.C.int);
    pragma Import (C, fl_tiled_image_draw2, "fl_tiled_image_draw2");
    pragma Inline (fl_tiled_image_draw2);




    overriding procedure Finalize
           (This : in out Tiled_Image) is
    begin
        if  This.Void_Ptr /= Null_Pointer and then
            This in Tiled_Image'Class
        then
            free_fl_tiled_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Finalize (Image (This));
    end Finalize;




    --------------------
    --  Construction  --
    --------------------

    package body Forge is

        function Create
               (From : in out Image'Class;
                W, H : in     Integer := 0)
            return Tiled_Image is
        begin
            return This : Tiled_Image do
                This.Void_Ptr := new_fl_tiled_image
                   (From.Void_Ptr,
                    Interfaces.C.int (W),
                    Interfaces.C.int (H));
                This.Dummy.Void_Ptr := fl_tiled_image_get_image (This.Void_Ptr);
                This.Dummy.Needs_Dealloc := False;
            end return;
        end Create;

    end Forge;


    function Copy
           (This          : in Tiled_Image;
            Width, Height : in Natural)
        return Tiled_Image'Class is
    begin
        return Copied : Tiled_Image do
            Copied.Void_Ptr := fl_tiled_image_copy
               (This.Void_Ptr,
                Interfaces.C.int (Width),
                Interfaces.C.int (Height));
            Copied.Dummy.Void_Ptr := fl_tiled_image_get_image (Copied.Void_Ptr);
            Copied.Dummy.Needs_Dealloc := False;
        end return;
    end Copy;


    function Copy
           (This : in Tiled_Image)
        return Tiled_Image'Class is
    begin
        return Copied : Tiled_Image do
            Copied.Void_Ptr := fl_tiled_image_copy2 (This.Void_Ptr);
            Copied.Dummy.Void_Ptr := fl_tiled_image_get_image (Copied.Void_Ptr);
            Copied.Dummy.Needs_Dealloc := False;
        end return;
    end Copy;




    ---------------------
    --  Miscellaneous  --
    ---------------------

    procedure Inactive
           (This : in out Tiled_Image) is
    begin
        This.Dummy.Void_Ptr := fl_tiled_image_get_image (This.Void_Ptr);
        This.Dummy.Needs_Dealloc := False;
        Image (This).Inactive;
    end Inactive;


    function Tile
           (This : in out Tiled_Image)
        return Image_Reference is
    begin
        return (Data => This.Dummy'Unchecked_Access);
    end Tile;




    --------------
    --  Colors  --
    --------------

    procedure Color_Average
           (This   : in out Tiled_Image;
            Hue    : in     Color;
            Amount : in     Blend) is
    begin
        This.Dummy.Void_Ptr := fl_tiled_image_get_image (This.Void_Ptr);
        This.Dummy.Needs_Dealloc := False;
        fl_tiled_image_color_average
           (This.Void_Ptr,
            Interfaces.C.int (Hue),
            Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out Tiled_Image) is
    begin
        This.Dummy.Void_Ptr := fl_tiled_image_get_image (This.Void_Ptr);
        This.Dummy.Needs_Dealloc := False;
        fl_tiled_image_desaturate (This.Void_Ptr);
    end Desaturate;




    procedure Draw
           (This : in Tiled_Image;
            X, Y : in Integer) is
    begin
        fl_tiled_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;


    procedure Draw
           (This       : in Tiled_Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer) is
    begin
        fl_tiled_image_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (CX),
            Interfaces.C.int (CY));
    end Draw;


end FLTK.Images.Tiled;

