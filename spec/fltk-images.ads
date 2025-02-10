

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Images is


    type Image is new Wrapper with private;

    type Image_Reference (Data : not null access Image'Class) is limited null record
        with Implicit_Dereference => Data;

    type Scaling_Kind is (Nearest, Bilinear);


    No_Image_Error, File_Access_Error, Format_Error : exception;




    package Forge is

        --  This creates an empty image with no data, so not that useful.

        function Create
               (Width, Height, Depth : in Natural)
            return Image;

    end Forge;




    --  Copying  --

    function Get_Copy_Algorithm
        return Scaling_Kind;

    procedure Set_Copy_Algorithm
           (To : in Scaling_Kind);

    function Copy
           (This          : in Image;
            Width, Height : in Natural)
        return Image'Class;

    function Copy
           (This : in Image)
        return Image'Class;




    --  Colors  --

    procedure Color_Average
           (This   : in out Image;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Image);




    --  Activity  --

    procedure Inactive
           (This : in out Image);

    function Is_Empty
           (This : in Image)
        return Boolean;

    procedure Uncache
           (This : in out Image);




    --  Dimensions  --

    function Get_W
           (This : in Image)
        return Natural;

    function Get_H
           (This : in Image)
        return Natural;

    function Get_D
           (This : in Image)
        return Natural;

    function Get_Line_Size
           (This : in Image)
        return Natural;




    --  Drawing  --

    procedure Draw
           (This : in Image;
            X, Y : in Integer);

    procedure Draw
           (This           : in Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0);

    procedure Draw_Empty
           (This : in Image;
            X, Y : in Integer);


private


    type Image is new Wrapper with null record;

    overriding procedure Finalize
           (This : in out Image);


    procedure Raise_Fail_Errors
           (This : in Image'Class);


    function fl_image_data
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_image_data, "fl_image_data");
    pragma Inline (fl_image_data);

    function fl_image_count
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_count, "fl_image_count");
    pragma Inline (fl_image_count);


    pragma Inline (Get_Copy_Algorithm);
    pragma Inline (Set_Copy_Algorithm);
    pragma Inline (Copy);

    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Inactive);
    pragma Inline (Is_Empty);
    pragma Inline (Uncache);

    pragma Inline (Get_W);
    pragma Inline (Get_H);
    pragma Inline (Get_D);
    pragma Inline (Get_Line_Size);

    pragma Inline (Draw);
    pragma Inline (Draw_Empty);


end FLTK.Images;


