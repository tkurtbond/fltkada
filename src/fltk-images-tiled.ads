

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.Tiled is


    -------------
    --  Types  --
    -------------

    type Tiled_Image is new Image with private;

    type Tiled_Image_Reference (Data : not null access Tiled_Image'Class) is
        limited null record with Implicit_Dereference => Data;




    --------------------
    --  Construction  --
    --------------------

    package Forge is

        function Create
               (From : in out Image'Class;
                W, H : in     Integer := 0)
            return Tiled_Image;

    end Forge;

    function Copy
           (This          : in Tiled_Image;
            Width, Height : in Natural)
        return Tiled_Image'Class;

    function Copy
           (This : in Tiled_Image)
        return Tiled_Image'Class;




    ---------------------
    --  Miscellaneous  --
    ---------------------

    procedure Inactive
           (This : in out Tiled_Image);

    function Tile
           (This : in out Tiled_Image)
        return Image_Reference;




    --------------
    --  Colors  --
    --------------

    procedure Color_Average
           (This   : in out Tiled_Image;
            Hue    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Tiled_Image);




    ---------------
    --  Drawing  --
    ---------------

    procedure Draw
           (This : in Tiled_Image;
            X, Y : in Integer);

    procedure Draw
           (This       : in Tiled_Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer);


private


    type Tiled_Image is new Image with record
        Dummy : aliased Image;
    end record;

    overriding procedure Finalize
           (This : in out Tiled_Image);


    pragma Inline (Copy);


    pragma Inline (Inactive);
    pragma Inline (Tile);


    pragma Inline (Color_Average);
    pragma Inline (Desaturate);


    pragma Inline (Draw);


end FLTK.Images.Tiled;

