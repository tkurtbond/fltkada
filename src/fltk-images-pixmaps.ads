

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images.Pixmaps is


    -------------
    --  Types  --
    -------------

    type Pixmap is new Image with private;

    type Pixmap_Reference (Data : not null access Pixmap'Class) is limited null record
        with Implicit_Dereference => Data;




    --------------------
    --  Construction  --
    --------------------

    function Copy
           (This          : in Pixmap;
            Width, Height : in Natural)
        return Pixmap'Class;

    function Copy
           (This : in Pixmap)
        return Pixmap'Class;




    --------------
    --  Colors  --
    --------------

    procedure Color_Average
           (This   : in out Pixmap;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Pixmap);




    ----------------
    --  Activity  --
    ----------------

    procedure Uncache
           (This : in out Pixmap);




    ---------------
    --  Drawing  --
    ---------------

    procedure Draw
           (This : in Pixmap;
            X, Y : in Integer);

    procedure Draw
           (This       : in Pixmap;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0);


private


    type Pixmap is new Image with null record;

    overriding procedure Finalize
           (This : in out Pixmap);


    pragma Inline (Color_Average);
    pragma Inline (Desaturate);


    pragma Inline (Uncache);


    pragma Inline (Copy);
    pragma Inline (Draw);


end FLTK.Images.Pixmaps;

