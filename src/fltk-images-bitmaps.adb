

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.Bitmaps is


    function new_fl_bitmap
           (D    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_bitmap, "new_fl_bitmap");
    pragma Inline (new_fl_bitmap);

    procedure free_fl_bitmap
           (I : in Storage.Integer_Address);
    pragma Import (C, free_fl_bitmap, "free_fl_bitmap");
    pragma Inline (free_fl_bitmap);

    function fl_bitmap_copy
           (I    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_bitmap_copy, "fl_bitmap_copy");
    pragma Inline (fl_bitmap_copy);

    function fl_bitmap_copy2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_bitmap_copy2, "fl_bitmap_copy2");
    pragma Inline (fl_bitmap_copy2);




    procedure fl_bitmap_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_bitmap_uncache, "fl_bitmap_uncache");
    pragma Inline (fl_bitmap_uncache);




    procedure fl_bitmap_draw2
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_bitmap_draw2, "fl_bitmap_draw2");
    pragma Inline (fl_bitmap_draw2);

    procedure fl_bitmap_draw
           (I                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_bitmap_draw, "fl_bitmap_draw");
    pragma Inline (fl_bitmap_draw);




    overriding procedure Finalize
           (This : in out Bitmap) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_bitmap (This.Void_Ptr);
        end if;
    end Finalize;




    --------------------
    --  Construction  --
    --------------------

    package body Forge is

        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural)
            return Bitmap is
        begin
            return This : Bitmap do
                This.Void_Ptr := new_fl_bitmap
                   (Storage.To_Integer (Data (Data'First)'Address),
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height));
                case fl_image_fail (This.Void_Ptr) is
                    when 1 =>
                        --  raise No_Image_Error;
                        null;
                        --  Since the image depth and line data are both zero here,
                        --  the fail method will think there's no image even though
                        --  nothing is wrong. This is a bug in FLTK.
                    when 2 => raise File_Access_Error;
                    when 3 => raise Format_Error;
                    when others => null;
                end case;
            end return;
        end Create;

    end Forge;


    function Copy
           (This          : in Bitmap;
            Width, Height : in Natural)
        return Bitmap'Class is
    begin
        return Copied : Bitmap do
            Copied.Void_Ptr := fl_bitmap_copy
               (This.Void_Ptr,
                Interfaces.C.int (Width),
                Interfaces.C.int (Height));
        end return;
    end Copy;


    function Copy
           (This : in Bitmap)
        return Bitmap'Class is
    begin
        return Copied : Bitmap do
            Copied.Void_Ptr := fl_bitmap_copy2 (This.Void_Ptr);
        end return;
    end Copy;




    ----------------
    --  Activity  --
    ----------------

    procedure Uncache
           (This : in out Bitmap) is
    begin
        fl_bitmap_uncache (This.Void_Ptr);
    end Uncache;



    ---------------
    --  Drawing  --
    ---------------

    procedure Draw
           (This : in Bitmap;
            X, Y : in Integer) is
    begin
        fl_bitmap_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;


    procedure Draw
           (This       : in Bitmap;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0) is
    begin
        fl_bitmap_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (CX),
            Interfaces.C.int (CY));
    end Draw;


end FLTK.Images.Bitmaps;

