

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images.RGB;


package FLTK.Images.Shared is


    type Shared_Image is new Image with private;

    type Shared_Image_Reference (Data : not null access Shared_Image'Class) is
        limited null record with Implicit_Dereference => Data;

    type Shared_Image_Array is array (Positive range <>) of Shared_Image;

    --  The most of a file an Image_Handler is shown.
    Max_Header : constant := 64;

    --  Makes an image of the file Name, whose first bytes, at most
    --  Max_Header, are Header, or returns null for the next handler to try.
    --  The pool gets a copy, at the image's size, and the image stays the
    --  handler's.  An exception the handler raises is raised again by the
    --  call that loaded the file.
    type Image_Handler is access function
           (Name   : in String;
            Header : in Color_Component_Array)
        return access constant Image'Class;




    package Forge is

        --  A file that can't be read, isn't an image, or that FLTK's loader
        --  can't load raises No_Image_Error.
        function Create
               (Filename : in String;
                W, H     : in Integer)
            return Shared_Image;

        --  Shares a copy of From, which may then go.
        function Create
               (From : in FLTK.Images.RGB.RGB_Image'Class)
            return Shared_Image;

        function Find
               (Name : in String;
                W, H : in Integer := 0)
            return Shared_Image;

    end Forge;




    --  Copying  --

    function Copy
           (This          : in Shared_Image;
            Width, Height : in Natural)
        return Shared_Image'Class;

    function Copy
           (This : in Shared_Image)
        return Shared_Image'Class;




    --  Colors  --

    procedure Color_Average
           (This   : in out Shared_Image;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Shared_Image);




    --  Activity  --

    function Number_Of_Images
        return Natural;

    --  Every image in the pool, each with a reference of its own.
    function Pool_Images
        return Shared_Image_Array;

    function Name
           (This : in Shared_Image)
        return String;

    function Original
           (This : in Shared_Image)
        return Boolean;

    function Reference_Count
           (This : in Shared_Image)
        return Natural;

    --  The pool's order: by Name, then Get_Data_W, then Get_Data_H, as
    --  Fl_Shared_Image::compare orders FLTK's cache, which keeps
    --  Pool_Images in this order.  A Shared_Image is limited, so to sort
    --  others, sort their indexes, with Ada.Containers.Generic_Sort for one.
    function "<"
           (Left, Right : in Shared_Image)
        return Boolean;

    --  An image of another size than its file's keeps that size, by which
    --  Find finds it (pofltk 83).
    procedure Reload
           (This : in out Shared_Image);

    procedure Uncache
           (This : in out Shared_Image);




    --  Drawing  --

    procedure Set_Scaling_Algorithm
           (To : in Scaling_Kind);

    procedure Scale
           (This         : in out Shared_Image;
            W, H         : in     Integer;
            Proportional : in     Boolean := True;
            Can_Expand   : in     Boolean := False);

    procedure Draw
           (This       : in Shared_Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0);

    procedure Draw
           (This : in Shared_Image;
            X, Y : in Integer);




    --  Image Handlers  --

    --  Registers handlers for all the image file formats FLTK supports,
    --  so that Shared_Image and the file chooser preview can load them.
    --  A binary PNM is then scaled as PNM's Create scales it (pofltk 45).
    procedure Register_Images;

    --  Adds Handler after those added before, unless it is there already.
    --  FLTK asks the handlers about any file but an XBM or XPM that no
    --  handler before them could load, the handlers Register_Images adds
    --  among them if it ran first.  A handler must not load the same
    --  file as a shared image: that asks it again.  pofltk 95.
    procedure Add_Handler
           (Handler : in not null Image_Handler);

    --  Removes Handler, if it was added.  A handler may remove itself.
    procedure Remove_Handler
           (Handler : in not null Image_Handler);


private


    type Shared_Image is new Image with null record;

    overriding procedure Finalize
           (This : in out Shared_Image);


    pragma Inline (Copy);

    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Number_Of_Images);
    pragma Inline (Pool_Images);
    pragma Inline (Name);
    pragma Inline (Original);
    pragma Inline (Reference_Count);
    pragma Inline ("<");
    pragma Inline (Reload);
    pragma Inline (Uncache);

    pragma Inline (Set_Scaling_Algorithm);
    pragma Inline (Scale);
    pragma Inline (Draw);

    pragma Inline (Register_Images);


end FLTK.Images.Shared;


