

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.Tiled is


    type Tiled_Image is new Image with private;

    type Tiled_Image_Reference (Data : not null access Tiled_Image'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        --  A shared image is tiled as a private copy, so that changing the
        --  tiled image's colours leaves the shared image, and the pool, alone.
        function Create
               (From : in out Image'Class;
                W, H : in     Integer := 0)
            return Tiled_Image;

    end Forge;




    --  Copying  --

    --  A copy of a tiled image whose colours have changed has its own copy
    --  of the tile, so it outlives the original.  Otherwise the copy shares
    --  the tile, as in FLTK.
    function Copy
           (This          : in Tiled_Image;
            Width, Height : in Natural)
        return Tiled_Image'Class;

    function Copy
           (This : in Tiled_Image)
        return Tiled_Image'Class;




    --  Miscellaneous  --

    procedure Inactive
           (This : in out Tiled_Image);

    --  The tile as it is now, which after Color_Average or Desaturate is the
    --  tiled image's own copy.
    function Tile
           (This : in out Tiled_Image)
        return Image_Reference;




    --  Colors  --

    procedure Color_Average
           (This   : in out Tiled_Image;
            Hue    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Tiled_Image);




    --  Drawing  --

    procedure Draw
           (This : in Tiled_Image;
            X, Y : in Integer);

    procedure Draw
           (This           : in Tiled_Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer);


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


