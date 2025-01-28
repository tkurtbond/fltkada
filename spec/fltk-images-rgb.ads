

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images.Pixmaps;


package FLTK.Images.RGB is


    type RGB_Image is new Image with private;

    type RGB_Image_Reference (Data : not null access RGB_Image'Class) is limited null record
        with Implicit_Dereference => Data;




    function Get_Max_Size
        return Natural;

    procedure Set_Max_Size
           (Value : in Natural);




    package Forge is

        --  Please note that input data should be some declared item
        --  that lives at least as long as the resulting RGB_Image.

        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural;
                Depth         : in Natural := 3;
                Line_Size     : in Natural := 0)
            return RGB_Image
        with Pre => (if Line_Size = 0
            then Data'Length = Width * Height * Depth
            else Data'Length = Line_Size * Height)
            and Data'Length <= Get_Max_Size;

        function Create
               (Data       : in FLTK.Images.Pixmaps.Pixmap'Class;
                Background : in Color := Background_Color)
            return RGB_Image;

    end Forge;




    --  Copying  --

    function Copy
           (This          : in RGB_Image;
            Width, Height : in Natural)
        return RGB_Image'Class;

    function Copy
           (This : in RGB_Image)
        return RGB_Image'Class;




    --  Colors  --

    procedure Color_Average
           (This   : in out RGB_Image;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out RGB_Image);




    --  Activity  --

    procedure Uncache
           (This : in out RGB_Image);




    --  Pixel Data  --

    function Data_Size
           (This : in RGB_Image)
        return Natural;

    function Get_Datum
           (This  : in RGB_Image;
            Place : in Positive)
        return Color_Component
    with Pre => Place <= This.Data_Size;

    procedure Set_Datum
           (This  : in out RGB_Image;
            Place : in     Positive;
            Value : in     Color_Component)
    with Pre => Place <= This.Data_Size;

    function Slice
           (This : in RGB_Image;
            Low  : in Positive;
            High : in Natural)
        return Color_Component_Array
    with Pre => High <= This.Data_Size,
        Post => Slice'Result'Length = Integer'Max (0, High - Low + 1);

    procedure Overwrite
           (This   : in out RGB_Image;
            Place  : in     Positive;
            Values : in     Color_Component_Array)
    with Pre => Place + Values'Length - 1 <= This.Data_Size;

    function All_Data
           (This : in RGB_Image)
        return Color_Component_Array
    with Post => All_Data'Result'Length = This.Data_Size;




    --  Drawing  --

    procedure Draw
           (This : in RGB_Image;
            X, Y : in Integer);

    procedure Draw
           (This           : in RGB_Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0);


private


    type RGB_Image is new Image with null record;

    overriding procedure Finalize
           (This : in out RGB_Image);


    pragma Inline (Get_Max_Size);
    pragma Inline (Set_Max_Size);

    pragma Inline (Copy);

    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Uncache);

    pragma Inline (Data_Size);
    pragma Inline (Get_Datum);
    pragma Inline (Set_Datum);
    pragma Inline (Slice);
    pragma Inline (Overwrite);
    pragma Inline (All_Data);

    pragma Inline (Draw);


end FLTK.Images.RGB;


