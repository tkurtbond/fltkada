

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images.RGB;


package FLTK.Images.Shared is


    type Shared_Image is new Image with private;

    type Shared_Image_Reference (Data : not null access Shared_Image'Class) is
        limited null record with Implicit_Dereference => Data;




    package Forge is

        function Create
               (Filename : in String;
                W, H     : in Integer)
            return Shared_Image;

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

    function Name
           (This : in Shared_Image)
        return String;

    function Original
           (This : in Shared_Image)
        return Boolean;

    function Reference_Count
           (This : in Shared_Image)
        return Natural;

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


private


    type Shared_Image is new Image with null record;

    overriding procedure Finalize
           (This : in out Shared_Image);


    pragma Inline (Copy);

    pragma Inline (Color_Average);
    pragma Inline (Desaturate);

    pragma Inline (Number_Of_Images);
    pragma Inline (Name);
    pragma Inline (Original);
    pragma Inline (Reference_Count);
    pragma Inline (Reload);
    pragma Inline (Uncache);

    pragma Inline (Set_Scaling_Algorithm);
    pragma Inline (Scale);
    pragma Inline (Draw);


end FLTK.Images.Shared;


