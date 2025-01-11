

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C,
    System;

use type

    Interfaces.C.int,
    Interfaces.C.signed_char,
    Interfaces.C.unsigned;


package body FLTK.Widgets.Groups.Windows.OpenGL is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_gl_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_gl_window, "new_fl_gl_window");
    pragma Inline (new_fl_gl_window);

    function new_fl_gl_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_gl_window2, "new_fl_gl_window2");
    pragma Inline (new_fl_gl_window2);

    procedure free_fl_gl_window
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_gl_window, "free_fl_gl_window");
    pragma Inline (free_fl_gl_window);




    procedure fl_gl_window_show
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_show, "fl_gl_window_show");
    pragma Inline (fl_gl_window_show);

    procedure fl_gl_window_hide
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_hide, "fl_gl_window_hide");
    pragma Inline (fl_gl_window_hide);

    procedure fl_gl_window_hide_overlay
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_hide_overlay, "fl_gl_window_hide_overlay");
    pragma Inline (fl_gl_window_hide_overlay);

    procedure fl_gl_window_flush
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_flush, "fl_gl_window_flush");
    pragma Inline (fl_gl_window_flush);




    function fl_gl_window_pixel_h
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_gl_window_pixel_h, "fl_gl_window_pixel_h");
    pragma Inline (fl_gl_window_pixel_h);

    function fl_gl_window_pixel_w
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_gl_window_pixel_w, "fl_gl_window_pixel_w");
    pragma Inline (fl_gl_window_pixel_w);

    function fl_gl_window_pixels_per_unit
           (S : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_gl_window_pixels_per_unit, "fl_gl_window_pixels_per_unit");
    pragma Inline (fl_gl_window_pixels_per_unit);

    procedure fl_gl_window_resize
           (G          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_gl_window_resize, "fl_gl_window_resize");
    pragma Inline (fl_gl_window_resize);




    function fl_gl_window_get_mode
           (S : in Storage.Integer_Address)
        return Mode_Mask;
    pragma Import (C, fl_gl_window_get_mode, "fl_gl_window_get_mode");
    pragma Inline (fl_gl_window_get_mode);

    procedure fl_gl_window_set_mode
           (S : in Storage.Integer_Address;
            M : in Mode_Mask);
    pragma Import (C, fl_gl_window_set_mode, "fl_gl_window_set_mode");
    pragma Inline (fl_gl_window_set_mode);

    function fl_gl_window_static_can_do
           (M : in Mode_Mask)
        return Interfaces.C.int;
    pragma Import (C, fl_gl_window_static_can_do, "fl_gl_window_static_can_do");
    pragma Inline (fl_gl_window_static_can_do);

    function fl_gl_window_can_do
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_gl_window_can_do, "fl_gl_window_can_do");
    pragma Inline (fl_gl_window_can_do);

    function fl_gl_window_can_do_overlay
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_gl_window_can_do_overlay, "fl_gl_window_can_do_overlay");
    pragma Inline (fl_gl_window_can_do_overlay);




    function fl_gl_window_get_context
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_gl_window_get_context, "fl_gl_window_get_context");
    pragma Inline (fl_gl_window_get_context);

    procedure fl_gl_window_set_context
           (S, P : in Storage.Integer_Address;
            D    : in Interfaces.C.int);
    pragma Import (C, fl_gl_window_set_context, "fl_gl_window_set_context");
    pragma Inline (fl_gl_window_set_context);

    function fl_gl_window_context_valid
           (S : in Storage.Integer_Address)
        return Interfaces.C.signed_char;
    pragma Import (C, fl_gl_window_context_valid, "fl_gl_window_context_valid");
    pragma Inline (fl_gl_window_context_valid);

    procedure fl_gl_window_set_context_valid
           (S : in Storage.Integer_Address;
            V : in Interfaces.C.signed_char);
    pragma Import (C, fl_gl_window_set_context_valid, "fl_gl_window_set_context_valid");
    pragma Inline (fl_gl_window_set_context_valid);

    function fl_gl_window_valid
           (S : in Storage.Integer_Address)
        return Interfaces.C.signed_char;
    pragma Import (C, fl_gl_window_valid, "fl_gl_window_valid");
    pragma Inline (fl_gl_window_valid);

    procedure fl_gl_window_set_valid
           (S : in Storage.Integer_Address;
            V : in Interfaces.C.signed_char);
    pragma Import (C, fl_gl_window_set_valid, "fl_gl_window_set_valid");
    pragma Inline (fl_gl_window_set_valid);

    procedure fl_gl_window_make_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_make_current, "fl_gl_window_make_current");
    pragma Inline (fl_gl_window_make_current);

    procedure fl_gl_window_make_overlay_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_make_overlay_current, "fl_gl_window_make_overlay_current");
    pragma Inline (fl_gl_window_make_overlay_current);




    procedure fl_gl_window_ortho
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_ortho, "fl_gl_window_ortho");
    pragma Inline (fl_gl_window_ortho);

    procedure fl_gl_window_redraw_overlay
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_redraw_overlay, "fl_gl_window_redraw_overlay");
    pragma Inline (fl_gl_window_redraw_overlay);

    procedure fl_gl_window_swap_buffers
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_swap_buffers, "fl_gl_window_swap_buffers");
    pragma Inline (fl_gl_window_swap_buffers);

    procedure fl_gl_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_gl_window_draw, "fl_gl_window_draw");
    pragma Inline (fl_gl_window_draw);

    function fl_gl_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_gl_window_handle, "fl_gl_window_handle");
    pragma Inline (fl_gl_window_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out GL_Window) is
    begin
        Extra_Final (Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out GL_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_gl_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out GL_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Window (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out GL_Window) is
    begin
        This.Draw_Ptr   := fl_gl_window_draw'Address;
        This.Handle_Ptr := fl_gl_window_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return GL_Window is
        begin
            return This : GL_Window do
                This.Void_Ptr := new_fl_gl_window
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String := "")
            return GL_Window is
        begin
            return This : GL_Window do
                This.Void_Ptr := new_fl_gl_window2
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, Text);
            end return;
        end Create;

    end Forge;




    ---------------
    --  Display  --
    ---------------

    procedure Show
           (This : in out GL_Window) is
    begin
        fl_gl_window_show (This.Void_Ptr);
    end Show;


    procedure Hide
           (This : in out GL_Window) is
    begin
        fl_gl_window_hide (This.Void_Ptr);
    end Hide;


    procedure Hide_Overlay
           (This : in out GL_Window) is
    begin
        fl_gl_window_hide_overlay (This.Void_Ptr);
    end Hide_Overlay;


    procedure Flush
           (This : in out GL_Window) is
    begin
        fl_gl_window_flush (This.Void_Ptr);
    end Flush;




    ------------------
    --  Dimensions  --
    ------------------

    function Pixel_H
           (This : in GL_Window)
        return Integer is
    begin
        return Integer (fl_gl_window_pixel_h (This.Void_Ptr));
    end Pixel_H;


    function Pixel_W
           (This : in GL_Window)
        return Integer is
    begin
        return Integer (fl_gl_window_pixel_w (This.Void_Ptr));
    end Pixel_W;


    function Pixels_Per_Unit
           (This : in GL_Window)
        return Float is
    begin
        return Float (fl_gl_window_pixels_per_unit (This.Void_Ptr));
    end Pixels_Per_Unit;


    procedure Resize
           (This       : in out GL_Window;
            X, Y, W, H : in     Integer) is
    begin
        fl_gl_window_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --------------------
    --  OpenGL Modes  --
    --------------------

    function Get_Mode
           (This : in GL_Window)
        return Mode_Mask is
    begin
        return fl_gl_window_get_mode (This.Void_Ptr);
    end Get_Mode;


    procedure Set_Mode
           (This : in out GL_Window;
            Mask : in     Mode_Mask) is
    begin
        fl_gl_window_set_mode (This.Void_Ptr, Mask);
    end Set_Mode;


    function Can_Do
           (Mask : in Mode_Mask)
        return Boolean is
    begin
        return fl_gl_window_static_can_do (Mask) /= 0;
    end Can_Do;


    function Can_Do
           (This : in GL_Window)
        return Boolean is
    begin
        return fl_gl_window_can_do (This.Void_Ptr) /= 0;
    end Can_Do;


    function Can_Do_Overlay
           (This : in GL_Window)
        return Boolean is
    begin
        return fl_gl_window_can_do_overlay (This.Void_Ptr) /= 0;
    end Can_Do_Overlay;




    -----------------------
    --  OpenGL Contexts  --
    -----------------------

    function Get_Context
           (This : in GL_Window)
        return System.Address is
    begin
        return Storage.To_Address (fl_gl_window_get_context (This.Void_Ptr));
    end Get_Context;


    procedure Set_Context
           (This    : in out GL_Window;
            Struct  : in     System.Address;
            Destroy : in     Boolean := False) is
    begin
        fl_gl_window_set_context
            (This.Void_Ptr, Storage.To_Integer (Struct), Boolean'Pos (Destroy));
    end Set_Context;


    function Get_Context_Valid
           (This : in GL_Window)
        return Boolean is
    begin
        return fl_gl_window_context_valid (This.Void_Ptr) /= 0;
    end Get_Context_Valid;


    procedure Set_Context_Valid
           (This  : in out GL_Window;
            Value : in     Boolean) is
    begin
        fl_gl_window_set_context_valid (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Context_Valid;


    function Get_Valid
           (This : in GL_Window)
        return Boolean is
    begin
        return fl_gl_window_valid (This.Void_Ptr) /= 0;
    end Get_Valid;


    procedure Set_Valid
           (This  : in out GL_Window;
            Value : in     Boolean) is
    begin
        fl_gl_window_set_valid (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Valid;


    procedure Make_Current
           (This : in out GL_Window) is
    begin
        fl_gl_window_make_current (This.Void_Ptr);
    end Make_Current;


    procedure Make_Overlay_Current
           (This : in out GL_Window) is
    begin
        fl_gl_window_make_overlay_current (This.Void_Ptr);
    end Make_Overlay_Current;




    ----------------------------------
    --  Drawing and Event Handling  --
    ----------------------------------

    procedure Ortho
           (This : in out GL_Window) is
    begin
        fl_gl_window_ortho (This.Void_Ptr);
    end Ortho;


    procedure Redraw_Overlay
           (This : in out GL_Window) is
    begin
        fl_gl_window_redraw_overlay (This.Void_Ptr);
    end Redraw_Overlay;


    procedure Swap_Buffers
           (This : in out GL_Window) is
    begin
        fl_gl_window_swap_buffers (This.Void_Ptr);
    end Swap_Buffers;


    procedure Draw
           (This : in out GL_Window) is
    begin
        Window (This).Draw;
    end Draw;


    function Handle
           (This  : in out GL_Window;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Window (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Windows.OpenGL;


