

package FLTK.Images is


    -------------
    --  Types  --
    -------------

    type Image is new Wrapper with private;

    type Image_Reference (Data : not null access Image'Class) is limited null record
        with Implicit_Dereference => Data;

    type Scaling_Kind is (Nearest, Bilinear);

    type Blend is new Float range 0.0 .. 1.0;

    No_Image_Error, File_Access_Error, Format_Error : exception;




    --------------------
    --  Construction  --
    --------------------

    package Forge is

        function Create
               (Width, Height, Depth : in Natural)
            return Image;

    end Forge;

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




    --------------
    --  Colors  --
    --------------

    procedure Color_Average
           (This   : in out Image;
            Col    : in     Color;
            Amount : in     Blend);

    procedure Desaturate
           (This : in out Image);




    ----------------
    --  Activity  --
    ----------------

    procedure Inactive
           (This : in out Image);

    function Is_Empty
           (This : in Image)
        return Boolean;

    procedure Uncache
           (This : in out Image);




    ------------------
    --  Dimensions  --
    ------------------

    function Get_W
           (This : in Image)
        return Natural;

    function Get_H
           (This : in Image)
        return Natural;

    function Get_D
           (This : in Image)
        return Natural;

    function Get_Line_Data
           (This : in Image)
        return Natural;

    function Get_Data_Count
           (This : in Image)
        return Natural;

    function Get_Data_Size
           (This : in Image)
        return Natural;




    ------------------
    --  Pixel Data  --
    ------------------

    function Get_Datum
           (This     : in Image;
            Data     : in Positive;
            Position : in Positive)
        return Color_Component
    with Pre =>
            Data <= Get_Data_Count (This) and
            Position <= Get_Data_Size (This);

    procedure Set_Datum
           (This     : in out Image;
            Data     : in     Positive;
            Position : in     Positive;
            Value    : in     Color_Component)
    with Pre =>
            Data <= Get_Data_Count (This) and
            Position <= Get_Data_Size (This);

    function Get_Data
           (This     : in Image;
            Data     : in Positive;
            Position : in Positive;
            Count    : in Natural)
        return Color_Component_Array
    with Pre =>
            Data <= Get_Data_Count (This) and
            Position <= Get_Data_Size (This) and
            Count <= Get_Data_Size (This) - Position + 1;

    function All_Data
           (This : in Image;
            Data : in Positive)
        return Color_Component_Array
    with Pre =>
            Data <= Get_Data_Count (This);

    procedure Update_Data
           (This     : in out Image;
            Data     : in     Positive;
            Position : in     Positive;
            Values   : in     Color_Component_Array)
    with Pre =>
            Data <= Get_Data_Count (This) and
            Position <= Get_Data_Size (This) and
            Values'Length <= Get_Data_Size (This) - Position + 1;




    ---------------
    --  Drawing  --
    ---------------

    procedure Draw
           (This : in Image;
            X, Y : in Integer);

    procedure Draw
           (This       : in Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0);

    procedure Draw_Empty
           (This : in Image;
            X, Y : in Integer);


private


    type Image is new Wrapper with null record;

    overriding procedure Finalize
           (This : in out Image);




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
    pragma Inline (Get_Line_Data);
    pragma Inline (Get_Data_Count);


    pragma Inline (Draw);
    pragma Inline (Draw_Empty);




    function fl_image_fail
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_fail, "fl_image_fail");


end FLTK.Images;

