

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.Bitmaps is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

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




    --  Copying  --

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




    --  Activity  --

    procedure fl_bitmap_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_bitmap_uncache, "fl_bitmap_uncache");
    pragma Inline (fl_bitmap_uncache);




    --  Pixel Data  --

    function fl_bitmap_data
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_bitmap_data, "fl_bitmap_data");
    pragma Inline (fl_bitmap_data);




    --  Drawing  --

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




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out Bitmap) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_bitmap (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural)
            return Bitmap is
        begin
            return This : Bitmap do
                This.Void_Ptr := new_fl_bitmap
                   ((if Data'Length > 0
                     then Storage.To_Integer (Data (Data'First)'Address)
                     else Null_Pointer),
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height));
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Contracts  --

    function Bytes_Needed
           (Bits : in Natural)
        return Natural is
    begin
        return Integer (Float'Ceiling
            (Float (Bits) / Float (Color_Component_Array'Component_Size)));
    end Bytes_Needed;




    --  Copying  --

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




    --  Activity  --

    procedure Uncache
           (This : in out Bitmap) is
    begin
        fl_bitmap_uncache (This.Void_Ptr);
    end Uncache;




    --  Pixel Data  --

    function Data_Size
           (This : in Bitmap)
        return Size_Type is
    begin
        return Size_Type (Bytes_Needed (This.Get_W)) * Size_Type (This.Get_H);
    end Data_Size;


    function Get_Datum
           (This  : in Bitmap;
            Place : in Positive_Size)
        return Color_Component
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_bitmap_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        return The_Data (Place);
    end Get_Datum;


    procedure Set_Datum
           (This  : in out Bitmap;
            Place : in     Positive_Size;
            Value : in     Color_Component)
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_bitmap_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        The_Data (Place) := Value;
    end Set_Datum;


    function Slice
           (This : in Bitmap;
            Low  : in Positive_Size;
            High : in Size_Type)
        return Color_Component_Array
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_bitmap_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        return The_Data (Low .. High);
    end Slice;


    procedure Overwrite
           (This   : in out Bitmap;
            Place  : in     Positive_Size;
            Values : in     Color_Component_Array)
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_bitmap_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        The_Data (Place .. Place + Values'Length - 1) := Values;
    end Overwrite;


    function All_Data
           (This : in Bitmap)
        return Color_Component_Array
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_bitmap_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        return The_Data;
    end All_Data;




    --  Drawing  --

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
           (This           : in Bitmap;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0) is
    begin
        fl_bitmap_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Clip_X),
            Interfaces.C.int (Clip_Y));
    end Draw;


end FLTK.Images.Bitmaps;


