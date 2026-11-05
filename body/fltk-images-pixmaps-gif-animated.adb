

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Ada.Unchecked_Conversion,
    Ada.Unchecked_Deallocation,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Images.Pixmaps.GIF.Animated is


    function To_C is new Ada.Unchecked_Conversion
        (Animation_Flags, Interfaces.C.unsigned_short);

    procedure Free is new Ada.Unchecked_Deallocation
        (FLTK.Images.RGB.RGB_Image, Frame_Wrapper_Access);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_anim_gif_image
           (F : in Interfaces.C.char_array;
            C : in Storage.Integer_Address;
            L : in Interfaces.C.unsigned_short)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_anim_gif_image, "new_fl_anim_gif_image");
    pragma Inline (new_fl_anim_gif_image);

    function new_fl_anim_gif_image2
           (N : in Interfaces.C.char_array;
            D : in Storage.Integer_Address;
            S : in Interfaces.C.size_t;
            C : in Storage.Integer_Address;
            L : in Interfaces.C.unsigned_short)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_anim_gif_image2, "new_fl_anim_gif_image2");
    pragma Inline (new_fl_anim_gif_image2);

    function new_fl_anim_gif_image3
        return Storage.Integer_Address;
    pragma Import (C, new_fl_anim_gif_image3, "new_fl_anim_gif_image3");
    pragma Inline (new_fl_anim_gif_image3);

    procedure free_fl_anim_gif_image
           (A : in Storage.Integer_Address);
    pragma Import (C, free_fl_anim_gif_image, "free_fl_anim_gif_image");
    pragma Inline (free_fl_anim_gif_image);




    --  Static Settings  --

    function fl_anim_gif_image_get_loop
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_get_loop, "fl_anim_gif_image_get_loop");
    pragma Inline (fl_anim_gif_image_get_loop);

    procedure fl_anim_gif_image_set_loop
           (V : in Interfaces.C.int);
    pragma Import (C, fl_anim_gif_image_set_loop, "fl_anim_gif_image_set_loop");
    pragma Inline (fl_anim_gif_image_set_loop);

    function fl_anim_gif_image_get_min_delay
        return Interfaces.C.double;
    pragma Import (C, fl_anim_gif_image_get_min_delay, "fl_anim_gif_image_get_min_delay");
    pragma Inline (fl_anim_gif_image_get_min_delay);

    procedure fl_anim_gif_image_set_min_delay
           (V : in Interfaces.C.double);
    pragma Import (C, fl_anim_gif_image_set_min_delay, "fl_anim_gif_image_set_min_delay");
    pragma Inline (fl_anim_gif_image_set_min_delay);

    function fl_anim_gif_image_frame_count
           (N : in Interfaces.C.char_array;
            D : in Storage.Integer_Address;
            S : in Interfaces.C.size_t)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_frame_count, "fl_anim_gif_image_frame_count");
    pragma Inline (fl_anim_gif_image_frame_count);




    --  Loading  --

    function fl_anim_gif_image_load
           (A : in Storage.Integer_Address;
            N : in Interfaces.C.char_array;
            D : in Storage.Integer_Address;
            S : in Interfaces.C.size_t)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_load, "fl_anim_gif_image_load");
    pragma Inline (fl_anim_gif_image_load);

    function fl_anim_gif_image_valid
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_valid, "fl_anim_gif_image_valid");
    pragma Inline (fl_anim_gif_image_valid);

    function fl_anim_gif_image_name
           (A : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_anim_gif_image_name, "fl_anim_gif_image_name");
    pragma Inline (fl_anim_gif_image_name);

    function fl_image_fail
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_image_fail, "fl_image_fail");
    pragma Inline (fl_image_fail);




    --  Canvas  --

    function fl_anim_gif_image_get_canvas
           (A : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_anim_gif_image_get_canvas, "fl_anim_gif_image_get_canvas");
    pragma Inline (fl_anim_gif_image_get_canvas);

    procedure fl_anim_gif_image_set_canvas
           (A : in Storage.Integer_Address;
            C : in Storage.Integer_Address;
            L : in Interfaces.C.unsigned_short);
    pragma Import (C, fl_anim_gif_image_set_canvas, "fl_anim_gif_image_set_canvas");
    pragma Inline (fl_anim_gif_image_set_canvas);

    function fl_anim_gif_image_canvas_w
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_canvas_w, "fl_anim_gif_image_canvas_w");
    pragma Inline (fl_anim_gif_image_canvas_w);

    function fl_anim_gif_image_canvas_h
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_canvas_h, "fl_anim_gif_image_canvas_h");
    pragma Inline (fl_anim_gif_image_canvas_h);




    --  Frames  --

    function fl_anim_gif_image_frames
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_frames, "fl_anim_gif_image_frames");
    pragma Inline (fl_anim_gif_image_frames);

    function fl_anim_gif_image_get_frame
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_get_frame, "fl_anim_gif_image_get_frame");
    pragma Inline (fl_anim_gif_image_get_frame);

    procedure fl_anim_gif_image_set_frame
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_anim_gif_image_set_frame, "fl_anim_gif_image_set_frame");
    pragma Inline (fl_anim_gif_image_set_frame);

    function fl_anim_gif_image_image2
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_anim_gif_image_image2, "fl_anim_gif_image_image2");
    pragma Inline (fl_anim_gif_image_image2);

    function fl_anim_gif_image_get_delay
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.double;
    pragma Import (C, fl_anim_gif_image_get_delay, "fl_anim_gif_image_get_delay");
    pragma Inline (fl_anim_gif_image_get_delay);

    procedure fl_anim_gif_image_set_delay
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int;
            V : in Interfaces.C.double);
    pragma Import (C, fl_anim_gif_image_set_delay, "fl_anim_gif_image_set_delay");
    pragma Inline (fl_anim_gif_image_set_delay);

    function fl_anim_gif_image_frame_x
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_frame_x, "fl_anim_gif_image_frame_x");
    pragma Inline (fl_anim_gif_image_frame_x);

    function fl_anim_gif_image_frame_y
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_frame_y, "fl_anim_gif_image_frame_y");
    pragma Inline (fl_anim_gif_image_frame_y);

    function fl_anim_gif_image_frame_w
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_frame_w, "fl_anim_gif_image_frame_w");
    pragma Inline (fl_anim_gif_image_frame_w);

    function fl_anim_gif_image_frame_h
           (A : in Storage.Integer_Address;
            F : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_frame_h, "fl_anim_gif_image_frame_h");
    pragma Inline (fl_anim_gif_image_frame_h);




    --  Playback  --

    function fl_anim_gif_image_is_animated
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_is_animated, "fl_anim_gif_image_is_animated");
    pragma Inline (fl_anim_gif_image_is_animated);

    function fl_anim_gif_image_playing
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_playing, "fl_anim_gif_image_playing");
    pragma Inline (fl_anim_gif_image_playing);

    function fl_anim_gif_image_start
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_start, "fl_anim_gif_image_start");
    pragma Inline (fl_anim_gif_image_start);

    function fl_anim_gif_image_stop
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_stop, "fl_anim_gif_image_stop");
    pragma Inline (fl_anim_gif_image_stop);

    function fl_anim_gif_image_next
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_next, "fl_anim_gif_image_next");
    pragma Inline (fl_anim_gif_image_next);

    function fl_anim_gif_image_get_speed
           (A : in Storage.Integer_Address)
        return Interfaces.C.double;
    pragma Import (C, fl_anim_gif_image_get_speed, "fl_anim_gif_image_get_speed");
    pragma Inline (fl_anim_gif_image_get_speed);

    procedure fl_anim_gif_image_set_speed
           (A : in Storage.Integer_Address;
            V : in Interfaces.C.double);
    pragma Import (C, fl_anim_gif_image_set_speed, "fl_anim_gif_image_set_speed");
    pragma Inline (fl_anim_gif_image_set_speed);

    function fl_anim_gif_image_get_frame_uncache
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_get_frame_uncache,
        "fl_anim_gif_image_get_frame_uncache");
    pragma Inline (fl_anim_gif_image_get_frame_uncache);

    procedure fl_anim_gif_image_set_frame_uncache
           (A : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_anim_gif_image_set_frame_uncache,
        "fl_anim_gif_image_set_frame_uncache");
    pragma Inline (fl_anim_gif_image_set_frame_uncache);

    function fl_anim_gif_image_debug
           (A : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_anim_gif_image_debug, "fl_anim_gif_image_debug");
    pragma Inline (fl_anim_gif_image_debug);




    --  Dimensions  --

    procedure fl_anim_gif_image_resize
           (A    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int);
    pragma Import (C, fl_anim_gif_image_resize, "fl_anim_gif_image_resize");
    pragma Inline (fl_anim_gif_image_resize);

    procedure fl_anim_gif_image_resize2
           (A : in Storage.Integer_Address;
            S : in Interfaces.C.double);
    pragma Import (C, fl_anim_gif_image_resize2, "fl_anim_gif_image_resize2");
    pragma Inline (fl_anim_gif_image_resize2);




    --  Copying  --

    function fl_anim_gif_image_copy
           (A    : in Storage.Integer_Address;
            W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_anim_gif_image_copy, "fl_anim_gif_image_copy");
    pragma Inline (fl_anim_gif_image_copy);

    function fl_anim_gif_image_copy2
           (A : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_anim_gif_image_copy2, "fl_anim_gif_image_copy2");
    pragma Inline (fl_anim_gif_image_copy2);




    --  Colors  --

    procedure fl_anim_gif_image_color_average
           (A : in Storage.Integer_Address;
            C : in Interfaces.C.int;
            B : in Interfaces.C.C_float);
    pragma Import (C, fl_anim_gif_image_color_average, "fl_anim_gif_image_color_average");
    pragma Inline (fl_anim_gif_image_color_average);

    procedure fl_anim_gif_image_desaturate
           (A : in Storage.Integer_Address);
    pragma Import (C, fl_anim_gif_image_desaturate, "fl_anim_gif_image_desaturate");
    pragma Inline (fl_anim_gif_image_desaturate);




    --  Activity  --

    procedure fl_anim_gif_image_uncache
           (A : in Storage.Integer_Address);
    pragma Import (C, fl_anim_gif_image_uncache, "fl_anim_gif_image_uncache");
    pragma Inline (fl_anim_gif_image_uncache);




    --  Drawing  --

    procedure fl_anim_gif_image_draw
           (A                  : in Storage.Integer_Address;
            X, Y, W, H, CX, CY : in Interfaces.C.int);
    pragma Import (C, fl_anim_gif_image_draw, "fl_anim_gif_image_draw");
    pragma Inline (fl_anim_gif_image_draw);




    ------------------------
    --  Internal Utility  --
    ------------------------

    function Data_Address
           (Data : in Color_Component_Array)
        return Storage.Integer_Address is
    begin
        if Data'Length > 0 then
            return Storage.To_Integer (Data (Data'First)'Address);
        else
            return Null_Pointer;
        end if;
    end Data_Address;


    --  Keeps the Ada side of the canvas in step with what FLTK did to it.
    procedure Attach_Canvas
           (This   : in out Animated_GIF_Image'Class;
            Canvas : in out FLTK.Widgets.Widget'Class;
            Flags  : in     Animation_Flags) is
    begin
        This.Canvas_Ptr := Canvas'Unchecked_Access;
        if not Flags.Dont_Set_As_Image then
            Canvas.Set_Image (This);
        end if;
    end Attach_Canvas;


    --  Whether the canvas the Ada side knows is still there.  FLTK's canvas
    --  is cleared as a widget is finalized (pofltk 62), so a Canvas_Ptr
    --  FLTK no longer has may be dangling, and is not used.
    function Has_Live_Canvas
           (This : in Animated_GIF_Image'Class)
        return Boolean is
    begin
        return This.Canvas_Ptr /= null and then This.Void_Ptr /= Null_Pointer
            and then fl_anim_gif_image_get_canvas (This.Void_Ptr) /= Null_Pointer;
    end Has_Live_Canvas;


    --  The Ada side of a canvas the animation leaves follows what FLTK does
    --  to it.  Fl_Anim_GIF_Image::canvas takes the image away from the
    --  canvas it leaves, whatever the image (Fl_Anim_GIF_Image.cxx:640-641);
    --  free_fl_anim_gif_image does so only if the canvas shows the animation.
    procedure Detach_Canvas
           (This          : in out Animated_GIF_Image'Class;
            Only_If_Shown : in     Boolean) is
    begin
        if Has_Live_Canvas (This) and not Only_If_Shown then
            This.Canvas_Ptr.Clear_Image;
        elsif Has_Live_Canvas (This) then
            declare
                Shown : constant access FLTK.Images.Image'Class := This.Canvas_Ptr.Get_Image;
            begin
                if Shown /= null and then Wrapper (Shown.all).Void_Ptr = This.Void_Ptr then
                    This.Canvas_Ptr.Clear_Image;
                end if;
            end;
        end if;
        This.Canvas_Ptr := null;
    end Detach_Canvas;


    procedure Free_Frame_Wrappers
           (This : in out Animated_GIF_Image) is
    begin
        for Wrap of This.Frame_Wraps loop
            Free (Wrap);
        end loop;
        This.Frame_Wraps.Clear;
    end Free_Frame_Wrappers;




    -----------------
    --  Operators  --
    -----------------

    function "+"
           (Left, Right : in Animation_Flags)
        return Animation_Flags is
    begin
        return
           (Dont_Start         => Left.Dont_Start or Right.Dont_Start,
            Dont_Resize_Canvas => Left.Dont_Resize_Canvas or Right.Dont_Resize_Canvas,
            Dont_Set_As_Image  => Left.Dont_Set_As_Image or Right.Dont_Set_As_Image,
            Optimize_Memory    => Left.Optimize_Memory or Right.Optimize_Memory,
            Log                => Left.Log or Right.Log,
            Debug              => Left.Debug or Right.Debug);
    end "+";


    function "-"
           (Left, Right : in Animation_Flags)
        return Animation_Flags is
    begin
        return
           (Dont_Start         => Left.Dont_Start and not Right.Dont_Start,
            Dont_Resize_Canvas => Left.Dont_Resize_Canvas and not Right.Dont_Resize_Canvas,
            Dont_Set_As_Image  => Left.Dont_Set_As_Image and not Right.Dont_Set_As_Image,
            Optimize_Memory    => Left.Optimize_Memory and not Right.Optimize_Memory,
            Log                => Left.Log and not Right.Log,
            Debug              => Left.Debug and not Right.Debug);
    end "-";




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out Animated_GIF_Image) is
    begin
        Free_Frame_Wrappers (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            Detach_Canvas (This, Only_If_Shown => True);
            free_fl_anim_gif_image (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return Animated_GIF_Image is
        begin
            return This : Animated_GIF_Image do
                This.Void_Ptr := new_fl_anim_gif_image3;
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an Animated_GIF_Image";
                end if;
            end return;
        end Create;


        function Create
               (Filename : in String;
                Flags    : in Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image is
        begin
            return This : Animated_GIF_Image do
                This.Void_Ptr := new_fl_anim_gif_image
                   (Interfaces.C.To_C (Filename),
                    Null_Pointer,
                    To_C (Flags));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an Animated_GIF_Image";
                end if;
            end return;
        end Create;


        function Create
               (Filename : in     String;
                Canvas   : in out FLTK.Widgets.Widget'Class;
                Flags    : in     Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image is
        begin
            return This : Animated_GIF_Image do
                This.Void_Ptr := new_fl_anim_gif_image
                   (Interfaces.C.To_C (Filename),
                    Wrapper (Canvas).Void_Ptr,
                    To_C (Flags));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an Animated_GIF_Image";
                end if;
                Attach_Canvas (This, Canvas, Flags);
            end return;
        end Create;


        function Create
               (Name  : in String := "";
                Data  : in Color_Component_Array;
                Flags : in Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image is
        begin
            return This : Animated_GIF_Image do
                This.Void_Ptr := new_fl_anim_gif_image2
                   (Interfaces.C.To_C (Name),
                    Data_Address (Data),
                    Interfaces.C.size_t (Data'Length),
                    Null_Pointer,
                    To_C (Flags));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an Animated_GIF_Image";
                end if;
            end return;
        end Create;


        function Create
               (Name   : in     String := "";
                Data   : in     Color_Component_Array;
                Canvas : in out FLTK.Widgets.Widget'Class;
                Flags  : in     Animation_Flags := No_Animation_Flags)
            return Animated_GIF_Image is
        begin
            return This : Animated_GIF_Image do
                This.Void_Ptr := new_fl_anim_gif_image2
                   (Interfaces.C.To_C (Name),
                    Data_Address (Data),
                    Interfaces.C.size_t (Data'Length),
                    Wrapper (Canvas).Void_Ptr,
                    To_C (Flags));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for an Animated_GIF_Image";
                end if;
                Attach_Canvas (This, Canvas, Flags);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Static Settings  --

    function Get_Loop
        return Boolean is
    begin
        return fl_anim_gif_image_get_loop /= 0;
    end Get_Loop;


    procedure Set_Loop
           (Value : in Boolean) is
    begin
        fl_anim_gif_image_set_loop (Boolean'Pos (Value));
    end Set_Loop;


    function Get_Min_Delay
        return Long_Float is
    begin
        return Long_Float (fl_anim_gif_image_get_min_delay);
    end Get_Min_Delay;


    procedure Set_Min_Delay
           (Value : in Long_Float) is
    begin
        fl_anim_gif_image_set_min_delay (Interfaces.C.double (Value));
    end Set_Min_Delay;


    function Frame_Count
           (Filename : in String)
        return Natural is
    begin
        return Natural'Max (0, Integer (fl_anim_gif_image_frame_count
           (Interfaces.C.To_C (Filename), Null_Pointer, 0)));
    end Frame_Count;


    function Frame_Count
           (Name : in String := "";
            Data : in Color_Component_Array)
        return Natural is
    begin
        return Natural'Max (0, Integer (fl_anim_gif_image_frame_count
           (Interfaces.C.To_C (Name),
            Data_Address (Data),
            Interfaces.C.size_t (Data'Length))));
    end Frame_Count;




    --  Loading  --

    procedure Load
           (This     : in out Animated_GIF_Image;
            Filename : in     String)
    is
        Result : constant Boolean := This.Load (Filename);
        pragma Unreferenced (Result);
    begin
        null;
    end Load;


    function Load
           (This     : in out Animated_GIF_Image;
            Filename : in     String)
        return Boolean is
    begin
        return fl_anim_gif_image_load
           (This.Void_Ptr,
            Interfaces.C.To_C (Filename),
            Null_Pointer,
            0) /= 0;
    end Load;


    procedure Load
           (This : in out Animated_GIF_Image;
            Name : in     String := "";
            Data : in     Color_Component_Array)
    is
        Result : constant Boolean := This.Load (Name, Data);
        pragma Unreferenced (Result);
    begin
        null;
    end Load;


    function Load
           (This : in out Animated_GIF_Image;
            Name : in     String := "";
            Data : in     Color_Component_Array)
        return Boolean is
    begin
        return fl_anim_gif_image_load
           (This.Void_Ptr,
            Interfaces.C.To_C (Name),
            Data_Address (Data),
            Interfaces.C.size_t (Data'Length)) /= 0;
    end Load;


    function Is_Loaded
           (This : in Animated_GIF_Image)
        return Boolean is
    begin
        return fl_anim_gif_image_valid (This.Void_Ptr) /= 0;
    end Is_Loaded;


    function Fail_Code
           (This : in Animated_GIF_Image)
        return Integer is
    begin
        --  Fl_Image::fail, which is -1 for an animation never loaded, as
        --  ld() alone isn't (Fl_Image.cxx:203-212).
        return Integer (fl_image_fail (This.Void_Ptr));
    end Fail_Code;


    function Name
           (This : in Animated_GIF_Image)
        return String
    is
        Result : constant Interfaces.C.Strings.chars_ptr := fl_anim_gif_image_name (This.Void_Ptr);
    begin
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Name;




    --  Canvas  --

    function Get_Canvas
           (This : in Animated_GIF_Image)
        return access FLTK.Widgets.Widget'Class is
    begin
        if Has_Live_Canvas (This) then
            return This.Canvas_Ptr;
        else
            return null;
        end if;
    end Get_Canvas;


    procedure Set_Canvas
           (This   : in out Animated_GIF_Image;
            Canvas : in out FLTK.Widgets.Widget'Class;
            Flags  : in     Animation_Flags := No_Animation_Flags) is
    begin
        Detach_Canvas (This, Only_If_Shown => False);
        fl_anim_gif_image_set_canvas (This.Void_Ptr, Wrapper (Canvas).Void_Ptr, To_C (Flags));
        Attach_Canvas (This, Canvas, Flags);
    end Set_Canvas;


    procedure Clear_Canvas
           (This : in out Animated_GIF_Image) is
    begin
        Detach_Canvas (This, Only_If_Shown => False);
        fl_anim_gif_image_set_canvas (This.Void_Ptr, Null_Pointer, 0);
    end Clear_Canvas;


    function Get_Canvas_W
           (This : in Animated_GIF_Image)
        return Natural is
    begin
        return Natural (fl_anim_gif_image_canvas_w (This.Void_Ptr));
    end Get_Canvas_W;


    function Get_Canvas_H
           (This : in Animated_GIF_Image)
        return Natural is
    begin
        return Natural (fl_anim_gif_image_canvas_h (This.Void_Ptr));
    end Get_Canvas_H;




    --  Frames  --

    function Frames
           (This : in Animated_GIF_Image)
        return Natural is
    begin
        return Natural (fl_anim_gif_image_frames (This.Void_Ptr));
    end Frames;


    function Get_Frame
           (This : in Animated_GIF_Image)
        return Extended_Frame_Index is
    begin
        return Extended_Frame_Index (fl_anim_gif_image_get_frame (This.Void_Ptr) + 1);
    end Get_Frame;


    procedure Set_Frame
           (This  : in out Animated_GIF_Image;
            Frame : in     Frame_Index) is
    begin
        fl_anim_gif_image_set_frame (This.Void_Ptr, Interfaces.C.int (Frame - 1));
    end Set_Frame;


    function Frame_Image
           (This  : in out Animated_GIF_Image;
            Frame : in     Frame_Index)
        return FLTK.Images.RGB.RGB_Image_Reference is
    begin
        while Natural (This.Frame_Wraps.Length) < Frame loop
            This.Frame_Wraps.Append (new FLTK.Images.RGB.RGB_Image);
        end loop;
        declare
            Wrap : constant Frame_Wrapper_Access := This.Frame_Wraps.Element (Frame);
        begin
            --  The frame images are owned by the animation, and are replaced
            --  when it is reloaded or resized, so refresh the pointer each time.
            Wrapper (Wrap.all).Void_Ptr := fl_anim_gif_image_image2
                (This.Void_Ptr, Interfaces.C.int (Frame - 1));
            Wrapper (Wrap.all).Needs_Dealloc := False;
            return (Data => Wrap);
        end;
    end Frame_Image;


    function Current_Frame_Image
           (This : in out Animated_GIF_Image)
        return FLTK.Images.RGB.RGB_Image_Reference is
    begin
        return This.Frame_Image (This.Get_Frame);
    end Current_Frame_Image;


    function Get_Delay
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Long_Float is
    begin
        return Long_Float (fl_anim_gif_image_get_delay
            (This.Void_Ptr, Interfaces.C.int (Frame - 1)));
    end Get_Delay;


    procedure Set_Delay
           (This  : in out Animated_GIF_Image;
            Frame : in     Frame_Index;
            Value : in     Long_Float) is
    begin
        fl_anim_gif_image_set_delay
           (This.Void_Ptr,
            Interfaces.C.int (Frame - 1),
            Interfaces.C.double (Value));
    end Set_Delay;


    function Frame_X
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer is
    begin
        return Integer (fl_anim_gif_image_frame_x (This.Void_Ptr, Interfaces.C.int (Frame - 1)));
    end Frame_X;


    function Frame_Y
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer is
    begin
        return Integer (fl_anim_gif_image_frame_y (This.Void_Ptr, Interfaces.C.int (Frame - 1)));
    end Frame_Y;


    function Frame_W
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer is
    begin
        return Integer (fl_anim_gif_image_frame_w (This.Void_Ptr, Interfaces.C.int (Frame - 1)));
    end Frame_W;


    function Frame_H
           (This  : in Animated_GIF_Image;
            Frame : in Frame_Index)
        return Integer is
    begin
        return Integer (fl_anim_gif_image_frame_h (This.Void_Ptr, Interfaces.C.int (Frame - 1)));
    end Frame_H;




    --  Playback  --

    function Is_Animated
           (This : in Animated_GIF_Image)
        return Boolean is
    begin
        return fl_anim_gif_image_is_animated (This.Void_Ptr) /= 0;
    end Is_Animated;


    function Is_Playing
           (This : in Animated_GIF_Image)
        return Boolean is
    begin
        return fl_anim_gif_image_playing (This.Void_Ptr) /= 0;
    end Is_Playing;


    procedure Start
           (This : in out Animated_GIF_Image) is
    begin
        if fl_anim_gif_image_start (This.Void_Ptr) = 0 then
            null;
        end if;
    end Start;


    function Start
           (This : in out Animated_GIF_Image)
        return Boolean is
    begin
        return fl_anim_gif_image_start (This.Void_Ptr) /= 0;
    end Start;


    procedure Stop
           (This : in out Animated_GIF_Image) is
    begin
        if fl_anim_gif_image_stop (This.Void_Ptr) = 0 then
            null;
        end if;
    end Stop;


    function Stop
           (This : in out Animated_GIF_Image)
        return Boolean is
    begin
        return fl_anim_gif_image_stop (This.Void_Ptr) /= 0;
    end Stop;


    procedure Next
           (This : in out Animated_GIF_Image) is
    begin
        if fl_anim_gif_image_next (This.Void_Ptr) = 0 then
            null;
        end if;
    end Next;


    function Next
           (This : in out Animated_GIF_Image)
        return Boolean is
    begin
        return fl_anim_gif_image_next (This.Void_Ptr) /= 0;
    end Next;


    function Get_Speed
           (This : in Animated_GIF_Image)
        return Long_Float is
    begin
        return Long_Float (fl_anim_gif_image_get_speed (This.Void_Ptr));
    end Get_Speed;


    procedure Set_Speed
           (This  : in out Animated_GIF_Image;
            Value : in     Long_Float) is
    begin
        fl_anim_gif_image_set_speed (This.Void_Ptr, Interfaces.C.double (Value));
    end Set_Speed;


    function Get_Frame_Uncache
           (This : in Animated_GIF_Image)
        return Boolean is
    begin
        return fl_anim_gif_image_get_frame_uncache (This.Void_Ptr) /= 0;
    end Get_Frame_Uncache;


    procedure Set_Frame_Uncache
           (This  : in out Animated_GIF_Image;
            Value : in     Boolean) is
    begin
        fl_anim_gif_image_set_frame_uncache (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Frame_Uncache;


    function Debug_Level
           (This : in Animated_GIF_Image)
        return Natural is
    begin
        return Natural (fl_anim_gif_image_debug (This.Void_Ptr));
    end Debug_Level;




    --  Dimensions  --

    procedure Resize
           (This          : in out Animated_GIF_Image;
            Width, Height : in     Natural) is
    begin
        fl_anim_gif_image_resize
           (This.Void_Ptr,
            Interfaces.C.int (Width),
            Interfaces.C.int (Height));
    end Resize;


    procedure Resize
           (This   : in out Animated_GIF_Image;
            Factor : in     Long_Float) is
    begin
        fl_anim_gif_image_resize2 (This.Void_Ptr, Interfaces.C.double (Factor));
    end Resize;




    --  Copying  --

    function Copy
           (This          : in Animated_GIF_Image;
            Width, Height : in Natural)
        return Animated_GIF_Image'Class is
    begin
        return Copied : Animated_GIF_Image do
            Copied.Void_Ptr := fl_anim_gif_image_copy
               (This.Void_Ptr,
                Interfaces.C.int (Width),
                Interfaces.C.int (Height));
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for an Animated_GIF_Image";
            end if;
        end return;
    end Copy;


    function Copy
           (This : in Animated_GIF_Image)
        return Animated_GIF_Image'Class is
    begin
        return Copied : Animated_GIF_Image do
            Copied.Void_Ptr := fl_anim_gif_image_copy2 (This.Void_Ptr);
            if Copied.Void_Ptr = Null_Pointer then
                raise Storage_Error with "no memory for an Animated_GIF_Image";
            end if;
        end return;
    end Copy;




    --  Colors  --

    procedure Color_Average
           (This   : in out Animated_GIF_Image;
            Col    : in     Color;
            Amount : in     Blend) is
    begin
        fl_anim_gif_image_color_average
           (This.Void_Ptr,
            Interfaces.C.int (Col),
            Interfaces.C.C_float (Amount));
    end Color_Average;


    procedure Desaturate
           (This : in out Animated_GIF_Image) is
    begin
        fl_anim_gif_image_desaturate (This.Void_Ptr);
    end Desaturate;




    --  Activity  --

    procedure Uncache
           (This : in out Animated_GIF_Image) is
    begin
        fl_anim_gif_image_uncache (This.Void_Ptr);
    end Uncache;




    --  Drawing  --

    procedure Draw
           (This           : in Animated_GIF_Image;
            X, Y, W, H     : in Integer;
            Clip_X, Clip_Y : in Integer := 0) is
    begin
        fl_anim_gif_image_draw
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Clip_X),
            Interfaces.C.int (Clip_Y));
    end Draw;


end FLTK.Images.Pixmaps.GIF.Animated;


