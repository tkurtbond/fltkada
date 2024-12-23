

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Devices.Surface.Image is


    function new_fl_image_surface
           (W, H, R : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_image_surface, "new_fl_image_surface");
    pragma Inline (new_fl_image_surface);

    procedure free_fl_image_surface
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_image_surface, "free_fl_image_surface");
    pragma Inline (free_fl_image_surface);




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




    procedure fl_image_surface_set_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_image_surface_set_current, "fl_image_surface_set_current");
    pragma Inline (fl_image_surface_set_current);




    procedure Finalize
           (This : in out Image_Surface) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_image_surface (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    package body Forge is

        function Create
               (W, H    : in Integer;
                Highres : in Boolean := False)
            return Image_Surface is
        begin
            return This : Image_Surface do
                This.Void_Ptr := new_fl_image_surface
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Boolean'Pos (Highres));
                This.High := Highres;
            end return;
        end Create;

    end Forge;




    function Is_Highres
           (This : in Image_Surface)
        return Boolean is
    begin
        return This.High;
    end Is_Highres;




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




    procedure Set_Current
           (This : in out Image_Surface) is
    begin
        fl_image_surface_set_current (This.Void_Ptr);
        This.Set_Current_Bookkeep;
    end Set_Current;


end FLTK.Devices.Surface.Image;


