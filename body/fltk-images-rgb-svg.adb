

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Images.RGB.SVG is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function fl_svg_image_available
        return Interfaces.C.int;
    pragma Import (C, fl_svg_image_available, "fl_svg_image_available");
    pragma Inline (fl_svg_image_available);

    function new_fl_svg_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_svg_image, "new_fl_svg_image");
    pragma Inline (new_fl_svg_image);

    function new_fl_svg_image2
           (N, D : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_svg_image2, "new_fl_svg_image2");
    pragma Inline (new_fl_svg_image2);

    function new_fl_svg_image3
           (N : in Interfaces.C.char_array;
            D : in Storage.Integer_Address;
            L : in Interfaces.C.size_t)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_svg_image3, "new_fl_svg_image3");
    pragma Inline (new_fl_svg_image3);

    procedure free_fl_svg_image
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_svg_image, "free_fl_svg_image");
    pragma Inline (free_fl_svg_image);




    --  Dimensions  --

    function fl_svg_image_get_proportional
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_svg_image_get_proportional, "fl_svg_image_get_proportional");
    pragma Inline (fl_svg_image_get_proportional);

    procedure fl_svg_image_set_proportional
           (S : in Storage.Integer_Address;
            P : in Interfaces.C.int);
    pragma Import (C, fl_svg_image_set_proportional, "fl_svg_image_set_proportional");
    pragma Inline (fl_svg_image_set_proportional);

    procedure fl_svg_image_resize
           (S    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int);
    pragma Import (C, fl_svg_image_resize, "fl_svg_image_resize");
    pragma Inline (fl_svg_image_resize);

    procedure fl_svg_image_normalize
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_svg_image_normalize, "fl_svg_image_normalize");
    pragma Inline (fl_svg_image_normalize);




    --  Copying  --

    function fl_svg_image_copy
           (S    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_svg_image_copy, "fl_svg_image_copy");
    pragma Inline (fl_svg_image_copy);

    function fl_svg_image_copy2
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_svg_image_copy2, "fl_svg_image_copy2");
    pragma Inline (fl_svg_image_copy2);




    --  Colors  --

    procedure fl_svg_image_color_average
           (S : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_svg_image_color_average, "fl_svg_image_color_average");
    pragma Inline (fl_svg_image_color_average);

    procedure fl_svg_image_desaturate
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_svg_image_desaturate, "fl_svg_image_desaturate");
    pragma Inline (fl_svg_image_desaturate);




    --  Drawing  --

    procedure fl_svg_image_draw
           (S                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_svg_image_draw, "fl_svg_image_draw");
    pragma Inline (fl_svg_image_draw);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out SVG_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_svg_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    function Is_Supported
        return Boolean is
    begin
        return fl_svg_image_available /= 0;
    end Is_Supported;


    procedure Check_Supported is
    begin
        if not Is_Supported then
            raise Unsupported_Error with "this FLTK was built without SVG";
        end if;
    end Check_Supported;




    package body Forge is

        function Create
               (Filename : in String)
            return SVG_Image is
        begin
            Check_Supported;
            return This : SVG_Image do
                This.Void_Ptr := new_fl_svg_image
                   (Interfaces.C.To_C (Filename));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an SVG_Image";
                end if;
                Raise_Fail_Errors (This);
            end return;
        end Create;


        function Create
               (Name : in String := "";
                Data : in String)
            return SVG_Image is
        begin
            Check_Supported;
            return This : SVG_Image do
                This.Void_Ptr := new_fl_svg_image2
                   (Interfaces.C.To_C (Name),
                    Interfaces.C.To_C (Data));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an SVG_Image";
                end if;
                Raise_Fail_Errors (This);
            end return;
        end Create;


        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return SVG_Image is
        begin
            Check_Supported;
            return This : SVG_Image do
                This.Void_Ptr := new_fl_svg_image3
                   (Interfaces.C.To_C (Name),
                    (if Data'Length > 0
                     then Storage.To_Integer (Data (Data'First)'Address)
                     else Null_Pointer),
                    Interfaces.C.size_t (Data'Length));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an SVG_Image";
                end if;
                Raise_Fail_Errors (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Copying  --

    function Copy
           (This          : in SVG_Image;
            Width, Height : in Natural)
        return SVG_Image'Class is
    begin
        return Copied : SVG_Image do
            Copied.Void_Ptr := fl_svg_image_copy
                   (This.Void_Ptr,
                    Interfaces.C.int (Width),
                    Interfaces.C.int (Height));
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for an SVG_Image";
            end if;
        end return;
    end Copy;


    function Copy
           (This : in SVG_Image)
        return SVG_Image'Class is
    begin
        return Copied : SVG_Image do
            Copied.Void_Ptr := fl_svg_image_copy2 (This.Void_Ptr);
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for an SVG_Image";
            end if;
        end return;
    end Copy;




    --  Colors  --

    procedure Color_Average
           (This   : in out SVG_Image;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_svg_image_color_average
           (This.Void_Ptr,
            Interfaces.C.int (Col),
            Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out SVG_Image) is
    begin
        fl_svg_image_desaturate (This.Void_Ptr);
    end Desaturate;




    --  Dimensions  --

    function Is_Proportional
           (This : in SVG_Image)
        return Boolean is
    begin
        return fl_svg_image_get_proportional (This.Void_Ptr) /= 0;
    end Is_Proportional;


    procedure Set_Proportional
           (This  : in out SVG_Image;
            Value : in     Boolean) is
    begin
        fl_svg_image_set_proportional (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Proportional;


    procedure Resize
           (This          : in out SVG_Image;
            Width, Height : in     Natural) is
    begin
        fl_svg_image_resize
           (This.Void_Ptr,
            Interfaces.C.int (Width),
            Interfaces.C.int (Height));
    end Resize;


    procedure Normalize
           (This : in out SVG_Image) is
    begin
        fl_svg_image_normalize (This.Void_Ptr);
    end Normalize;




    --  Drawing  --

    procedure Draw
           (This           : in SVG_Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0) is
    begin
        fl_svg_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Clip_X),
            Interfaces.C.int (Clip_Y));
    end Draw;


end FLTK.Images.RGB.SVG;


