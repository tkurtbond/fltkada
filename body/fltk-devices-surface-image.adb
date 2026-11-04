

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Devices.Surface.Image is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_image_surface
           (W, H, R : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_image_surface, "new_fl_image_surface");
    pragma Inline (new_fl_image_surface);

    procedure free_fl_image_surface
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_image_surface, "free_fl_image_surface");
    pragma Inline (free_fl_image_surface);




    --  Drawing  --

    procedure fl_image_surface_draw
           (S, I   : in Storage.Integer_Address;
            OX, OY : in Interfaces.C.int);
    pragma Import (C, fl_image_surface_draw, "fl_image_surface_draw");
    pragma Inline (fl_image_surface_draw);

    procedure fl_image_surface_draw_decorated_window
           (S, I   : in Storage.Integer_Address;
            OX, OY : in Interfaces.C.int);
    pragma Import (C, fl_image_surface_draw_decorated_window,
        "fl_image_surface_draw_decorated_window");
    pragma Inline (fl_image_surface_draw_decorated_window);




    --  Images  --

    function fl_image_surface_image
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_image_surface_image, "fl_image_surface_image");
    pragma Inline (fl_image_surface_image);

    function fl_image_surface_highres_image
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_image_surface_highres_image, "fl_image_surface_highres_image");
    pragma Inline (fl_image_surface_highres_image);

    function fl_image_surface_mask
           (S, M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_surface_mask, "fl_image_surface_mask");
    pragma Inline (fl_image_surface_mask);

    procedure fl_image_surface_rescale
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_image_surface_rescale, "fl_image_surface_rescale");
    pragma Inline (fl_image_surface_rescale);




    --  Surfaces  --

    procedure fl_image_surface_set_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_image_surface_set_current, "fl_image_surface_set_current");
    pragma Inline (fl_image_surface_set_current);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Image_Surface) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if Release_Current (This) then
                free_fl_image_surface (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (W, H    : in Integer;
                Highres : in Boolean := False)
            return Image_Surface is
        begin
            if W < 1 or H < 1 then
                raise Constraint_Error with "Image_Surface of a size below 1";
            end if;
            return This : Image_Surface do
                This.Void_Ptr := new_fl_image_surface
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Boolean'Pos (Highres));
                This.High := Highres;
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Resolution  --

    function Is_Highres
           (This : in Image_Surface)
        return Boolean is
    begin
        return This.High;
    end Is_Highres;


    procedure Rescale
           (This : in out Image_Surface) is
    begin
        if Is_Remembered (This) then
            raise Program_Error with "Rescale of an Image_Surface current or pushed";
        end if;
        fl_image_surface_rescale (This.Void_Ptr);
    end Rescale;




    --  Drawing  --

    procedure Draw_Widget
           (This               : in out Image_Surface;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        fl_image_surface_draw
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Draw_Widget;


    procedure Draw_Decorated_Window
           (This               : in out Image_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        fl_image_surface_draw_decorated_window
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Draw_Decorated_Window;




    --  Images  --

    function Get_Image
           (This : in Image_Surface)
        return FLTK.Images.RGB.RGB_Image is
    begin
        return Img : FLTK.Images.RGB.RGB_Image do
            Wrapper (Img).Void_Ptr := fl_image_surface_image (This.Void_Ptr);
        end return;
    end Get_Image;


    function Get_Highres_Image
           (This : in Image_Surface)
        return FLTK.Images.Shared.Shared_Image is
    begin
        return Img : FLTK.Images.Shared.Shared_Image do
            Wrapper (Img).Void_Ptr := fl_image_surface_highres_image (This.Void_Ptr);
        end return;
    end Get_Highres_Image;


    procedure Mask
           (This : in out Image_Surface;
            Item : in     FLTK.Images.RGB.RGB_Image'Class) is
    begin
        if Wrapper (Item).Void_Ptr = Null_Pointer then
            raise FLTK.Images.No_Image_Error with "Mask of an image never made";
        end if;
        case fl_image_surface_mask (This.Void_Ptr, Wrapper (Item).Void_Ptr) is
            when 0 =>
                null;
            when 1 =>
                raise Unsupported_Error with "Mask of an image not 3 bytes a pixel";
            when 2 =>
                raise Program_Error with "Mask of the current Image_Surface";
            when others =>
                raise Program_Error with "Mask twice with no Get_Image between";
        end case;
    end Mask;




    --  Surfaces  --

    procedure Set_Current
           (This : in out Image_Surface) is
    begin
        fl_image_surface_set_current (This.Void_Ptr);
        This.Set_Current_Bookkeep;
    end Set_Current;


end FLTK.Devices.Surface.Image;


