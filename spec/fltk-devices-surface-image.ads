

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images.RGB,
    FLTK.Images.Shared,
    FLTK.Widgets.Groups.Windows;


package FLTK.Devices.Surface.Image is


    type Image_Surface is new Surface_Device with private;

    type Image_Surface_Reference (Data : not null access Image_Surface'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        --  Raises Constraint_Error if W or H is below 1: FLTK makes such a
        --  surface, then crashes or exits when it is drawn on or read.
        function Create
               (W, H    : in Integer;
                Highres : in Boolean := False)
            return Image_Surface;

    end Forge;




    --  Resolution  --

    function Is_Highres
           (This : in Image_Surface)
        return Boolean;

    --  Remakes the surface for the screen's scale now, keeping what is
    --  drawn on it, for one made Highres.  Raises Program_Error if This is
    --  current or remembered by Push_Current: FLTK frees what it would then
    --  draw on.  A mask set and not yet used by Get_Image is used.
    procedure Rescale
           (This : in out Image_Surface);




    --  Drawing  --

    procedure Draw_Widget
           (This               : in out Image_Surface;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    procedure Draw_Decorated_Window
           (This               : in out Image_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0);




    --  Images  --

    function Get_Image
           (This : in Image_Surface)
        return FLTK.Images.RGB.RGB_Image;

    function Get_Highres_Image
           (This : in Image_Surface)
        return FLTK.Images.Shared.Shared_Image;

    --  Drawing after this shows only where Item is white, and is mixed by
    --  its grey elsewhere, until the next Get_Image or Get_Highres_Image,
    --  which gives the two together.  Item may be any size, and isn't kept.
    --  Raises FLTK.Unsupported_Error if Item isn't 3 bytes a pixel, which
    --  FLTK reads it as (pofltk 137), and Program_Error if This is current,
    --  as FLTK forbids, or has a mask not yet used by Get_Image, which FLTK
    --  would lose.
    procedure Mask
           (This : in out Image_Surface;
            Item : in     FLTK.Images.RGB.RGB_Image'Class);




    --  Surfaces  --

    procedure Set_Current
           (This : in out Image_Surface);


private


    type Image_Surface is new Surface_Device with record
        High : Boolean := False;
    end record;

    overriding procedure Finalize
           (This : in out Image_Surface);


    pragma Inline (Is_Highres);
    pragma Inline (Rescale);

    pragma Inline (Draw_Widget);
    pragma Inline (Draw_Decorated_Window);

    pragma Inline (Get_Image);
    pragma Inline (Get_Highres_Image);

    pragma Inline (Set_Current);


end FLTK.Devices.Surface.Image;


