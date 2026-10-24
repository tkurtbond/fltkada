

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Images.Pixmaps.GIF is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_gif_image
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_gif_image, "new_fl_gif_image");
    pragma Inline (new_fl_gif_image);

    function new_fl_gif_image2
           (N : in Interfaces.C.char_array;
            D : in Storage.Integer_Address;
            L : in Interfaces.C.size_t)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_gif_image2, "new_fl_gif_image2");
    pragma Inline (new_fl_gif_image2);

    procedure free_fl_gif_image
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_gif_image, "free_fl_gif_image");
    pragma Inline (free_fl_gif_image);




    --  Animation  --

    function fl_gif_image_get_animate
        return Interfaces.C.int;
    pragma Import (C, fl_gif_image_get_animate, "fl_gif_image_get_animate");
    pragma Inline (fl_gif_image_get_animate);

    procedure fl_gif_image_set_animate
           (A : in Interfaces.C.int);
    pragma Import (C, fl_gif_image_set_animate, "fl_gif_image_set_animate");
    pragma Inline (fl_gif_image_set_animate);

    function fl_gif_image_is_animated
           (F : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_gif_image_is_animated, "fl_gif_image_is_animated");
    pragma Inline (fl_gif_image_is_animated);




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out GIF_Image) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_gif_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Filename : in String)
            return GIF_Image is
        begin
            return This : GIF_Image do
                This.Void_Ptr := new_fl_gif_image
                   (Interfaces.C.To_C (Filename));
                Raise_Fail_Errors (This);
            end return;
        end Create;


        function Create
               (Name : in String := "";
                Data : in Color_Component_Array)
            return GIF_Image is
        begin
            return This : GIF_Image do
                This.Void_Ptr := new_fl_gif_image2
                   (Interfaces.C.To_C (Name),
                    (if Data'Length > 0
                     then Storage.To_Integer (Data (Data'First)'Address)
                     else Null_Pointer),
                    Interfaces.C.size_t (Data'Length));
                Raise_Fail_Errors (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Animation  --

    function Get_Animate
        return Boolean is
    begin
        return fl_gif_image_get_animate /= 0;
    end Get_Animate;


    procedure Set_Animate
           (Value : in Boolean) is
    begin
        fl_gif_image_set_animate (Boolean'Pos (Value));
    end Set_Animate;


    function Is_Animated
           (Filename : in String)
        return Boolean is
    begin
        return fl_gif_image_is_animated (Interfaces.C.To_C (Filename)) /= 0;
    end Is_Animated;


end FLTK.Images.Pixmaps.GIF;


