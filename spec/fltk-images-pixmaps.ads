

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Strings.Unbounded;

private with

    Interfaces.C.Strings;


package FLTK.Images.Pixmaps is


    type Pixmap is new Image with private;

    type Pixmap_Reference (Data : not null access Pixmap'Class) is limited null record
        with Implicit_Dereference => Data;


    type Header is record
        Width, Height, Colors, Per_Pixel : Positive;
    end record;

    type Color_Kind is (Colorful, Monochrome, Greyscale, Symbolic);

    type Color_Definition is record
        Name  : Ada.Strings.Unbounded.Unbounded_String;
        Kind  : Color_Kind;
        Value : Ada.Strings.Unbounded.Unbounded_String;
    end record;

    type Color_Definition_Array is array (Positive range <>) of Color_Definition;

    type Pixmap_Data is array (Positive range <>, Positive range <>) of Character;




    package Forge is

        --  Unlike Bitmaps or RGB_Images, you do NOT have to keep this data around.
        --  A copy will be allocated and deallocated internally.

        function Create
               (Values : in Header;
                Colors : in Color_Definition_Array;
                Pixels : in Pixmap_Data)
            return Pixmap
        with Pre =>
            Colors'Length = Values.Colors and
            Pixels'Length (1) = Values.Height and
            (for all Definition of Colors =>
                Ada.Strings.Unbounded.Length (Definition.Name) = Values.Per_Pixel) and
            Pixels'Length (2) = Values.Width * Values.Per_Pixel;

    end Forge;




    --  Copying  --

    function Copy
           (This          : in Pixmap;
            Width, Height : in Natural)
        return Pixmap'Class;

    function Copy
           (This : in Pixmap)
        return Pixmap'Class;




    --  Colors  --

    procedure Color_Average
           (This   : in out Pixmap;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Pixmap);




    --  Activity  --

    procedure Uncache
           (This : in out Pixmap);




    --  Drawing  --

    procedure Draw
           (This : in Pixmap;
            X, Y : in Integer);

    procedure Draw
           (This           : in Pixmap;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0);


private


    type Pixmap is new Image with record
        Loose_Ptr : access Interfaces.C.Strings.chars_ptr_array;
    end record;

    overriding procedure Finalize
           (This : in out Pixmap);


    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Uncache);

    pragma Inline (Copy);
    pragma Inline (Draw);


end FLTK.Images.Pixmaps;


