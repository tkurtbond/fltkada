

package FLTK.Images.Bitmaps is


    -------------
    --  Types  --
    -------------

    type Bitmap is new Image with private;

    type Bitmap_Reference (Data : not null access Bitmap'Class) is limited null record
        with Implicit_Dereference => Data;




    --------------------
    --  Construction  --
    --------------------

    package Forge is

        --  Please note that I'm pretty sure (?) input data here should be some
        --  declared item that lives at least as long as the resulting Bitmap

        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural)
            return Bitmap;

    end Forge;

    function Copy
           (This          : in Bitmap;
            Width, Height : in Natural)
        return Bitmap'Class;

    function Copy
           (This : in Bitmap)
        return Bitmap'Class;




    ----------------
    --  Activity  --
    ----------------

    procedure Uncache
           (This : in out Bitmap);




    ---------------
    --  Drawing  --
    ---------------

    procedure Draw
           (This : in Bitmap;
            X, Y : in Integer);

    procedure Draw
           (This       : in Bitmap;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0);


private


    type Bitmap is new Image with null record;

    overriding procedure Finalize
           (This : in out Bitmap);


    pragma Inline (Copy);
    pragma Inline (Uncache);
    pragma Inline (Draw);


end FLTK.Images.Bitmaps;

