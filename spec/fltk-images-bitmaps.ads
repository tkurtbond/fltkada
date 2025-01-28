

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.Bitmaps is


    type Bitmap is new Image with private;

    type Bitmap_Reference (Data : not null access Bitmap'Class) is limited null record
        with Implicit_Dereference => Data;




    function To_Next_Byte
           (Bits : in Natural)
        return Natural;




    package Forge is

        --  Please note that input data should be some declared item
        --  that lives at least as long as the resulting Bitmap.

        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural)
            return Bitmap
        with Pre => Data'Length = To_Next_Byte (Width) * Height;

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
        return Natural;

    function Get_Datum
           (This  : in Bitmap;
            Place : in Positive)
        return Color_Component
    with Pre => Place <= This.Data_Size;

    procedure Set_Datum
           (This  : in out Bitmap;
            Place : in     Positive;
            Value : in     Color_Component)
    with Pre => Place <= This.Data_Size;

    function Slice
           (This : in Bitmap;
            Low  : in Positive;
            High : in Natural)
        return Color_Component_Array
    with Pre => High <= This.Data_Size,
        Post => Slice'Result'Length = Integer'Max (0, High - Low + 1);

    procedure Overwrite
           (This   : in out Bitmap;
            Place  : in     Positive;
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


    pragma Inline (To_Next_Byte);

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


