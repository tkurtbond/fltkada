

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Containers.Vectors,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings,
    System;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Images.Shared is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function fl_shared_image_get
           (F    : in Interfaces.C.char_array;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_get, "fl_shared_image_get");
    pragma Inline (fl_shared_image_get);

    function fl_shared_image_get2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_get2, "fl_shared_image_get2");
    pragma Inline (fl_shared_image_get2);

    function fl_shared_image_find
           (N    : in Interfaces.C.char_array;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_find, "fl_shared_image_find");
    pragma Inline (fl_shared_image_find);

    procedure fl_shared_image_release
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_release, "fl_shared_image_release");
    pragma Inline (fl_shared_image_release);




    --  Copying  --

    function fl_shared_image_copy
           (I    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_copy, "fl_shared_image_copy");
    pragma Inline (fl_shared_image_copy);

    function fl_shared_image_copy2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_copy2, "fl_shared_image_copy2");
    pragma Inline (fl_shared_image_copy2);




    --  Colors  --

    procedure fl_shared_image_color_average
           (I : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_shared_image_color_average, "fl_shared_image_color_average");
    pragma Inline (fl_shared_image_color_average);

    procedure fl_shared_image_desaturate
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_desaturate, "fl_shared_image_desaturate");
    pragma Inline (fl_shared_image_desaturate);




    --  Activity  --

    function fl_shared_image_num_images
        return Interfaces.C.int;
    pragma Import (C, fl_shared_image_num_images, "fl_shared_image_num_images");
    pragma Inline (fl_shared_image_num_images);

    function fl_shared_image_pool_count
        return Interfaces.C.int;
    pragma Import (C, fl_shared_image_pool_count, "fl_shared_image_pool_count");
    pragma Inline (fl_shared_image_pool_count);

    function fl_shared_image_pool_take
           (K : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_shared_image_pool_take, "fl_shared_image_pool_take");
    pragma Inline (fl_shared_image_pool_take);

    function fl_shared_image_name
           (I : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_shared_image_name, "fl_shared_image_name");
    pragma Inline (fl_shared_image_name);

    function fl_shared_image_original
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_shared_image_original, "fl_shared_image_original");
    pragma Inline (fl_shared_image_original);

    function fl_shared_image_refcount
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_shared_image_refcount, "fl_shared_image_refcount");
    pragma Inline (fl_shared_image_refcount);

    procedure fl_shared_image_reload
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_reload, "fl_shared_image_reload");
    pragma Inline (fl_shared_image_reload);

    procedure fl_shared_image_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_shared_image_uncache, "fl_shared_image_uncache");
    pragma Inline (fl_shared_image_uncache);




    --  Drawing  --

    procedure fl_shared_image_scaling_algorithm
           (A : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_scaling_algorithm, "fl_shared_image_scaling_algorithm");
    pragma Inline (fl_shared_image_scaling_algorithm);

    procedure fl_shared_image_scale
           (I : in Storage.Integer_Address;
            W, H, P, E : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_scale, "fl_shared_image_scale");
    pragma Inline (fl_shared_image_scale);

    procedure fl_shared_image_draw
           (I                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_draw, "fl_shared_image_draw");
    pragma Inline (fl_shared_image_draw);

    procedure fl_shared_image_draw2
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_shared_image_draw2, "fl_shared_image_draw2");
    pragma Inline (fl_shared_image_draw2);




    --  Image Handlers  --

    procedure fl_shared_image_register_images;
    pragma Import (C, fl_shared_image_register_images, "fl_shared_image_register_images");
    pragma Inline (fl_shared_image_register_images);

    procedure fl_shared_image_add_ada_handler;
    pragma Import (C, fl_shared_image_add_ada_handler, "fl_shared_image_add_ada_handler");
    pragma Inline (fl_shared_image_add_ada_handler);




    ----------------
    --  Handlers  --
    ----------------

    package Handler_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Image_Handler);

    Handlers : Handler_Vectors.Vector;

    --  FLTK's call, through the shim's one handler: asks each handler in
    --  turn about Name, whose first N bytes are at Header.
    function Ask_Hook
           (Name   : in Interfaces.C.Strings.chars_ptr;
            Header : in System.Address;
            N      : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Export (C, Ask_Hook, "shared_image_ask_hook");

    function Ask_Hook
           (Name   : in Interfaces.C.Strings.chars_ptr;
            Header : in System.Address;
            N      : in Interfaces.C.int)
        return Storage.Integer_Address
    is
        Length : constant Size_Type := Size_Type (Interfaces.C.int'Max (0, N));
        Bytes  : Color_Component_Array (1 .. Length);
        for Bytes'Address use Header;
        pragma Import (Ada, Bytes);
        Asked  : constant Handler_Vectors.Vector := Handlers;
        Text   : constant String := Interfaces.C.Strings.Value (Name);
    begin
        for Handler of Asked loop
            --  One an earlier handler removed isn't asked.
            if Handlers.Contains (Handler) then
                declare
                    Made : constant access constant Image'Class := Handler (Text, Bytes);
                begin
                    if Made /= null then
                        if Wrapper (Made.all).Void_Ptr = Null_Pointer or else Made.Is_Empty then
                            raise No_Image_Error with "an image handler gave no image";
                        end if;
                        return Wrapper (Made.all).Void_Ptr;
                    end if;
                end;
            end if;
        end loop;
        return Null_Pointer;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
        return Null_Pointer;
    end Ask_Hook;




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out Shared_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            fl_shared_image_release (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String;
                W, H     : in Integer)
            return Shared_Image is
        begin
            return This : Shared_Image do
                This.Void_Ptr := fl_shared_image_get
                   (Interfaces.C.To_C (Filename),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H));
                Hook_Exceptions.Reraise;
                --  FLTK's get returns null only when no loader takes the
                --  file (Fl_Shared_Image.cxx:594-598).  An image a loader
                --  took and couldn't load is shared 0 wide.
                if This.Void_Ptr = Null_Pointer or else This.Is_Empty then
                    raise No_Image_Error;
                end if;
            end return;
        end Create;


        function Create
               (From : in FLTK.Images.RGB.RGB_Image'Class)
            return Shared_Image is
        begin
            return This : Shared_Image do
                This.Void_Ptr := fl_shared_image_get2 (Wrapper (From).Void_Ptr);
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for a Shared_Image";
                end if;
            end return;
        end Create;


        function Find
               (Name : in String;
                W, H : in Integer := 0)
            return Shared_Image is
        begin
            return This : Shared_Image do
                This.Void_Ptr := fl_shared_image_find
                   (Interfaces.C.To_C (Name),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H));
                if This.Void_Ptr = Null_Pointer then
                    raise No_Image_Error;
                end if;
            end return;
        end Find;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Copying  --

    function Copy
           (This          : in Shared_Image;
            Width, Height : in Natural)
        return Shared_Image'Class is
    begin
        return Copied : Shared_Image do
            Copied.Void_Ptr := fl_shared_image_copy
                   (This.Void_Ptr,
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height));
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for a Shared_Image";
            end if;
        end return;
    end Copy;


    function Copy
           (This : in Shared_Image)
        return Shared_Image'Class is
    begin
        return Copied : Shared_Image do
            Copied.Void_Ptr := fl_shared_image_copy2 (This.Void_Ptr);
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for a Shared_Image";
            end if;
        end return;
    end Copy;




    --  Colors  --

    procedure Color_Average
           (This   : in out Shared_Image;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_shared_image_color_average
               (This.Void_Ptr,
                Interfaces.C.int (Col),
                Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out Shared_Image) is
    begin
        fl_shared_image_desaturate (This.Void_Ptr);
    end Desaturate;




    --  Activity  --

    function Number_Of_Images
        return Natural is
    begin
        return Natural (fl_shared_image_num_images);
    end Number_Of_Images;


    function Pool_Images
        return Shared_Image_Array is
    begin
        return Result : Shared_Image_Array (1 .. Natural (fl_shared_image_pool_count)) do
            for Index in Result'Range loop
                Result (Index).Void_Ptr := fl_shared_image_pool_take
                    (Interfaces.C.int (Index - 1));
            end loop;
        end return;
    end Pool_Images;


    function Name
           (This : in Shared_Image)
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_shared_image_name (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Name;


    function Original
           (This : in Shared_Image)
        return Boolean is
    begin
        return fl_shared_image_original (This.Void_Ptr) /= 0;
    end Original;


    function Reference_Count
           (This : in Shared_Image)
        return Natural is
    begin
        return Natural (fl_shared_image_refcount (This.Void_Ptr));
    end Reference_Count;


    function "<"
           (Left, Right : in Shared_Image)
        return Boolean
    is
        --  Ada's String "<" compares as strcmp does, by unsigned bytes.
        Left_Name  : constant String := Left.Name;
        Right_Name : constant String := Right.Name;
    begin
        if Left_Name /= Right_Name then
            return Left_Name < Right_Name;
        elsif Left.Get_Data_W /= Right.Get_Data_W then
            return Left.Get_Data_W < Right.Get_Data_W;
        else
            return Left.Get_Data_H < Right.Get_Data_H;
        end if;
    end "<";


    procedure Reload
           (This : in out Shared_Image) is
    begin
        fl_shared_image_reload (This.Void_Ptr);
        Hook_Exceptions.Reraise;
    end Reload;


    procedure Uncache
           (This : in out Shared_Image) is
    begin
        fl_shared_image_uncache (This.Void_Ptr);
    end Uncache;




    --  Drawing  --

    procedure Set_Scaling_Algorithm
           (To : in Scaling_Kind) is
    begin
        fl_shared_image_scaling_algorithm (Scaling_Kind'Pos (To));
    end Set_Scaling_Algorithm;


    procedure Scale
           (This         : in out Shared_Image;
            W, H         : in     Integer;
            Proportional : in     Boolean := True;
            Can_Expand   : in     Boolean := False) is
    begin
        fl_shared_image_scale
           (This.Void_Ptr,
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Boolean'Pos (Proportional),
            Boolean'Pos (Can_Expand));
    end Scale;


    procedure Draw
           (This       : in Shared_Image;
            X, Y, W, H : in Integer;
            CX, CY     : in Integer := 0) is
    begin
        fl_shared_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (CX),
            Interfaces.C.int (CY));
    end Draw;


    procedure Draw
           (This : in Shared_Image;
            X, Y : in Integer) is
    begin
        fl_shared_image_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;




    --  Image Handlers  --

    procedure Register_Images is
    begin
        fl_shared_image_register_images;
    end Register_Images;


    procedure Add_Handler
           (Handler : in not null Image_Handler) is
    begin
        if not Handlers.Contains (Handler) then
            Handlers.Append (Handler);
        end if;
        fl_shared_image_add_ada_handler;
    end Add_Handler;


    procedure Remove_Handler
           (Handler : in not null Image_Handler)
    is
        Place : constant Handler_Vectors.Extended_Index := Handlers.Find_Index (Handler);
    begin
        if Place /= Handler_Vectors.No_Index then
            Handlers.Delete (Place);
        end if;
    end Remove_Handler;


end FLTK.Images.Shared;


