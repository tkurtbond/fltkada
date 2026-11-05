

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

        --  A colour given by name, such as "red", is read only on X11: elsewhere
        --  FLTK reads hexadecimal alone, and a name becomes FLTK's gray
        --  (Fl_Screen_Driver.cxx:625-646, pofltk 47).  Give colours as "#rrggbb".
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




    --  Data  --

    --  The pixmap's data, as FLTK holds it: the lines of an XPM, the first
    --  of which is the header.  A pixmap from a GIF has them in FLTK's own
    --  form, where the header gives the number of colors as negative and
    --  the second line holds all the colors, 4 bytes each (an index, then
    --  red, green and blue), so it can hold NUL.  A pixmap with no data has
    --  no lines.  Get_Line raises Constraint_Error for a line it doesn't have.
    function Get_Line_Count
           (This : in Pixmap)
        return Natural;

    function Get_Line
           (This  : in Pixmap;
            Index : in Positive)
        return String;




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


    pragma Inline (Get_Line_Count);

    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Uncache);

    pragma Inline (Copy);
    pragma Inline (Draw);


end FLTK.Images.Pixmaps;


