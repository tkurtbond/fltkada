

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.Bitmaps is


    type Bitmap is new Image with private;

    type Bitmap_Reference (Data : not null access Bitmap'Class) is limited null record
        with Implicit_Dereference => Data;




    --  Calculates the bytes needed to hold a given number of bits.

    function Bytes_Needed
           (Bits : in Natural)
        return Natural;




    package Forge is

        --  The bitmap keeps a copy of Data.  Data shorter than Height
        --  rows of Bytes_Needed (Width) bytes raises Constraint_Error.
        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural)
            return Bitmap;

    end Forge;




    --  Copying  --

    function Copy
           (This          : in Bitmap;
            Width, Height : in Natural)
        return Bitmap'Class;

    function Copy
           (This : in Bitmap)
        return Bitmap'Class;




    --  Activity  --

    procedure Uncache
           (This : in out Bitmap);




    --  Pixel Data  --

    function Data_Size
           (This : in Bitmap)
        return Size_Type;

    function Get_Datum
           (This  : in Bitmap;
            Place : in Positive_Size)
        return Color_Component
    with Pre => Place <= This.Data_Size;

    procedure Set_Datum
           (This  : in out Bitmap;
            Place : in     Positive_Size;
            Value : in     Color_Component)
    with Pre => Place <= This.Data_Size;

    function Slice
           (This : in Bitmap;
            Low  : in Positive_Size;
            High : in Size_Type)
        return Color_Component_Array
    with Pre => High <= This.Data_Size,
        Post => Slice'Result'Length = Size_Type'Max (0, High - Low + 1);

    procedure Overwrite
           (This   : in out Bitmap;
            Place  : in     Positive_Size;
            Values : in     Color_Component_Array)
    with Pre => Place + Values'Length - 1 <= This.Data_Size;

    function All_Data
           (This : in Bitmap)
        return Color_Component_Array
    with Post => All_Data'Result'Length = This.Data_Size;




    --  Drawing  --

    procedure Draw
           (This : in Bitmap;
            X, Y : in Integer);

    procedure Draw
           (This           : in Bitmap;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0);


private


    type Bitmap is new Image with null record;

    overriding procedure Finalize
           (This : in out Bitmap);


    pragma Inline (Bytes_Needed);

    pragma Inline (Copy);

    pragma Inline (Uncache);

    pragma Inline (Data_Size);
    pragma Inline (Get_Datum);
    pragma Inline (Set_Datum);
    pragma Inline (Slice);
    pragma Inline (Overwrite);
    pragma Inline (All_Data);

    pragma Inline (Draw);


end FLTK.Images.Bitmaps;


