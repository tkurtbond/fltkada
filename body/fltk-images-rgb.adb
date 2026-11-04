

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Images.RGB is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_rgb_image
           (Data       : in Storage.Integer_Address;
            W, H, D, L : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_rgb_image, "new_fl_rgb_image");
    pragma Inline (new_fl_rgb_image);

    function new_fl_rgb_image2
           (P : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_rgb_image2, "new_fl_rgb_image2");
    pragma Inline (new_fl_rgb_image2);

    procedure free_fl_rgb_image
           (I : in Storage.Integer_Address);
    pragma Import (C, free_fl_rgb_image, "free_fl_rgb_image");
    pragma Inline (free_fl_rgb_image);

    function fl_event_take_clipboard_image
        return Storage.Integer_Address;
    pragma Import (C, fl_event_take_clipboard_image, "fl_event_take_clipboard_image");
    pragma Inline (fl_event_take_clipboard_image);




    --  Static Settings  --

    function fl_rgb_image_get_max_size
        return Interfaces.C.size_t;
    pragma Import (C, fl_rgb_image_get_max_size, "fl_rgb_image_get_max_size");
    pragma Inline (fl_rgb_image_get_max_size);

    procedure fl_rgb_image_set_max_size
           (V : in Interfaces.C.size_t);
    pragma Import (C, fl_rgb_image_set_max_size, "fl_rgb_image_set_max_size");
    pragma Inline (fl_rgb_image_set_max_size);




    --  Copying  --

    function fl_rgb_image_copy
           (I    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_rgb_image_copy, "fl_rgb_image_copy");
    pragma Inline (fl_rgb_image_copy);

    function fl_rgb_image_copy2
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_rgb_image_copy2, "fl_rgb_image_copy2");
    pragma Inline (fl_rgb_image_copy2);




    --  Colors  --

    procedure fl_rgb_image_color_average
           (I : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_rgb_image_color_average, "fl_rgb_image_color_average");
    pragma Inline (fl_rgb_image_color_average);

    procedure fl_rgb_image_desaturate
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_rgb_image_desaturate, "fl_rgb_image_desaturate");
    pragma Inline (fl_rgb_image_desaturate);




    --  Activity  --

    procedure fl_rgb_image_uncache
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_rgb_image_uncache, "fl_rgb_image_uncache");
    pragma Inline (fl_rgb_image_uncache);




    --  Pixel Data  --

    function fl_rgb_image_data
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_rgb_image_data, "fl_rgb_image_data");
    pragma Inline (fl_rgb_image_data);




    --  Drawing  --

    procedure fl_rgb_image_draw2
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_rgb_image_draw2, "fl_rgb_image_draw2");
    pragma Inline (fl_rgb_image_draw2);

    procedure fl_rgb_image_draw
           (I                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_rgb_image_draw, "fl_rgb_image_draw");
    pragma Inline (fl_rgb_image_draw);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out RGB_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_rgb_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Pasted
            return RGB_Image is
        begin
            return Result : RGB_Image do
                Result.Void_Ptr := fl_event_take_clipboard_image;
                if Result.Void_Ptr = Null_Pointer then
                    raise Program_Error with "no pasted image to take";
                end if;
            end return;
        end Pasted;


        function Create
               (Data          : in Color_Component_Array;
                Width, Height : in Natural;
                Depth         : in Natural := 3;
                Line_Size     : in Natural := 0)
            return RGB_Image
        is
            Needed : constant Size_Type :=
                (if Line_Size = 0
                 then Size_Type (Width) * Size_Type (Height) * Size_Type (Depth)
                 else Size_Type (Line_Size) * Size_Type (Height));
        begin
            if Depth not in 1 .. 4 then
                raise Constraint_Error with "RGB_Image Create with depth" & Natural'Image (Depth);
            end if;
            if Line_Size /= 0 and then
                Size_Type (Line_Size) < Size_Type (Width) * Size_Type (Depth)
            then
                raise Constraint_Error with "RGB_Image Create with line size"
                    & Natural'Image (Line_Size) & ", less than width times depth";
            end if;
            if Data'Length < Needed then
                raise Constraint_Error with "RGB_Image Create with" & Size_Type'Image (Data'Length)
                    & " bytes, needing" & Size_Type'Image (Needed);
            end if;
            return This : RGB_Image do
                This.Void_Ptr := new_fl_rgb_image
                   ((if Data'Length > 0
                     then Storage.To_Integer (Data (Data'First)'Address)
                     else Null_Pointer),
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height),
                    Interfaces.C.int (Depth),
                    Interfaces.C.int (Line_Size));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an RGB_Image";
                end if;
            end return;
        end Create;


        function Create
               (Data       : in FLTK.Images.Pixmaps.Pixmap'Class;
                Background : in Color := Background_Color)
            return RGB_Image is
        begin
            return This : RGB_Image do
                This.Void_Ptr := new_fl_rgb_image2
                   (Wrapper (Data).Void_Ptr,
                    Interfaces.C.unsigned (Background));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an RGB_Image";
                end if;
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Static Settings  --

    function Get_Max_Size
        return Size_Type is
    begin
        return Size_Type (fl_rgb_image_get_max_size);
    end Get_Max_Size;


    procedure Set_Max_Size
           (Value : in Size_Type) is
    begin
        if Value > Size_Type (Interfaces.C.int'Last) then
            raise Constraint_Error with "Max_Size over Integer'Last:" & Size_Type'Image (Value);
        end if;
        fl_rgb_image_set_max_size (Interfaces.C.size_t (Value));
    end Set_Max_Size;




    --  Copying  --

    function Copy
           (This          : in RGB_Image;
            Width, Height : in Natural)
        return RGB_Image'Class is
    begin
        return Copied : RGB_Image do
            Copied.Void_Ptr := fl_rgb_image_copy
                   (This.Void_Ptr,
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height));
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for an RGB_Image";
            end if;
        end return;
    end Copy;


    function Copy
           (This : in RGB_Image)
        return RGB_Image'Class is
    begin
        return Copied : RGB_Image do
            Copied.Void_Ptr := fl_rgb_image_copy2 (This.Void_Ptr);
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for an RGB_Image";
            end if;
        end return;
    end Copy;




    --  Colors  --

    procedure Color_Average
           (This   : in out RGB_Image;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_rgb_image_color_average
           (This.Void_Ptr,
            Interfaces.C.int (Col),
            Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out RGB_Image) is
    begin
        fl_rgb_image_desaturate (This.Void_Ptr);
    end Desaturate;




    --  Activity  --

    procedure Uncache
           (This : in out RGB_Image) is
    begin
        fl_rgb_image_uncache (This.Void_Ptr);
    end Uncache;




    --  Pixel Data  --

    function Data_Size
           (This : in RGB_Image)
        return Size_Type
    is
        Per_Line : constant Natural := This.Get_Line_Size;
    begin
        if Per_Line = 0 then
            return Size_Type (This.Get_W) * Size_Type (This.Get_D) * Size_Type (This.Get_H);
        else
            return Size_Type (Per_Line) * Size_Type (This.Get_H);
        end if;
    end Data_Size;


    function Get_Datum
           (This  : in RGB_Image;
            Place : in Positive_Size)
        return Color_Component
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_rgb_image_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        return The_Data (Place);
    end Get_Datum;


    procedure Set_Datum
           (This  : in out RGB_Image;
            Place : in     Positive_Size;
            Value : in     Color_Component)
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_rgb_image_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        The_Data (Place) := Value;
    end Set_Datum;


    function Slice
           (This : in RGB_Image;
            Low  : in Positive_Size;
            High : in Size_Type)
        return Color_Component_Array
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_rgb_image_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        return The_Data (Low .. High);
    end Slice;


    procedure Overwrite
           (This   : in out RGB_Image;
            Place  : in     Positive_Size;
            Values : in     Color_Component_Array)
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_rgb_image_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        The_Data (Place .. Place + Values'Length - 1) := Values;
    end Overwrite;


    function All_Data
           (This : in RGB_Image)
        return Color_Component_Array
    is
        The_Data : Color_Component_Array (1 .. This.Data_Size);
        for The_Data'Address use Storage.To_Address (fl_rgb_image_data (This.Void_Ptr));
        pragma Import (Ada, The_Data);
    begin
        return The_Data;
    end All_Data;




    --  Drawing  --

    procedure Draw
           (This : in RGB_Image;
            X, Y : in Integer) is
    begin
        fl_rgb_image_draw2
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw;


    procedure Draw
           (This           : in RGB_Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0) is
    begin
        fl_rgb_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Clip_X),
            Interfaces.C.int (Clip_Y));
    end Draw;


end FLTK.Images.RGB;


