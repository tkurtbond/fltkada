

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package FLTK.Images.RGB.SVG is


    type SVG_Image is new RGB_Image with private;

    type SVG_Image_Reference (Data : not null access SVG_Image'Class) is limited null record
        with Implicit_Dereference => Data;




    --  True if this FLTK can read SVG.  An FLTK may be built without it, and
    --  then every Create raises FLTK.Unsupported_Error (pofltk 73).

    function Is_Supported
        return Boolean;




    package Forge is

        function Create
               (Filename : in String)
            return SVG_Image;

        --  If a Name is given then the image is also made available
        --  under that name as a Shared_Image, while the image lasts
        --  (FLTK-issues.md F8). The SVG text is copied,
        --  so Data need not outlive the resulting SVG_Image.

        function Create
               (Name : in String := "";
                Data : in String)
            return SVG_Image;

        --  The Data may be either SVG text or gzip compressed SVG text.

        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return SVG_Image;

    end Forge;




    --  Copying  --

    function Copy
           (This          : in SVG_Image;
            Width, Height : in Natural)
        return SVG_Image'Class;

    function Copy
           (This : in SVG_Image)
        return SVG_Image'Class;

    --  Copy called on an Image'Class, which gives the same as the two
    --  above (FLTKAda-BUGS.md 101).

    overriding function Copy
           (This          : in SVG_Image;
            Width, Height : in Natural)
        return Image'Class;

    overriding function Copy
           (This : in SVG_Image)
        return Image'Class;




    --  Colors  --

    procedure Color_Average
           (This   : in out SVG_Image;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out SVG_Image);




    --  Dimensions  --

    function Is_Proportional
           (This : in SVG_Image)
        return Boolean;

    procedure Set_Proportional
           (This  : in out SVG_Image;
            Value : in     Boolean);

    procedure Resize
           (This          : in out SVG_Image;
            Width, Height : in     Natural);

    --  Rasterizes the image at its current size, if not done yet,
    --  so that the pixel data is available.
    procedure Normalize
           (This : in out SVG_Image);




    --  Drawing  --

    procedure Draw
           (This           : in SVG_Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0);


private


    type SVG_Image is new RGB_Image with null record;

    overriding procedure Finalize
           (This : in out SVG_Image);


    pragma Inline (Is_Supported);

    pragma Inline (Copy);

    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Is_Proportional);
    pragma Inline (Set_Proportional);
    pragma Inline (Resize);
    pragma Inline (Normalize);

    pragma Inline (Draw);


end FLTK.Images.RGB.SVG;


