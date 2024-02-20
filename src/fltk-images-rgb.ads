

with

    FLTK.Images.Pixmaps;


package FLTK.Images.RGB is


    -------------
    --  Types  --
    -------------

    type RGB_Image is new Image with private;

    type RGB_Image_Reference (Data : not null access RGB_Image'Class) is limited null record
        with Implicit_Dereference => Data;




    --------------------
    --  Construction  --
    --------------------

    package Forge is

        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural;
                Depth         : in Natural := 3;
                Line_Data     : in Natural := 0)
            return RGB_Image;

        function Create
               (Data       : in FLTK.Images.Pixmaps.Pixmap'Class;
                Background : in Color := Background_Color)
            return RGB_Image;

    end Forge;

    function Get_Max_Size
        return Natural;

    procedure Set_Max_Size
           (Value : in Natural);

    function Copy
           (This          : in RGB_Image;
            Width, Height : in Natural)
        return RGB_Image'Class;

    function Copy
           (This : in RGB_Image)
        return RGB_Image'Class;




    --------------
    --  Colors  --
    --------------

    procedure Color_Average
           (This   : in out RGB_Image;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out RGB_Image);




    ----------------
    --  Activity  --
    ----------------

    procedure Uncache
           (This : in out RGB_Image);




    ---------------
    --  Drawing  --
    ---------------

    procedure Draw
           (This : in RGB_Image;
            X, Y : in Integer);

    procedure Draw
           (This       : in RGB_Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0);


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


    pragma Inline (Draw);


end FLTK.Images.RGB;

