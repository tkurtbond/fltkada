

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Drawing_State,
    FLTK.Hook_Exceptions,
    FLTK.Pixmap_Marshal,
    Interfaces.C.Pointers,
    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Draw is


    package Chk renames Ada.Assertions;

    --  Pop the clip or matrix a Push_Clip, Push_No_Clip or Push_Matrix
    --  recorded in FLTK.Drawing_State.
    procedure Undo_Clip
           (Item : in System.Address);

    procedure Undo_Matrix
           (Item : in System.Address);

    --  Oh no... Anyway, this is just used for Expand_Text.
    package Char_Pointers is new Interfaces.C.Pointers
       (Index              => Interfaces.C.size_t,
        Element            => Interfaces.C.char,
        Element_Array      => Interfaces.C.char_array,
        Default_Terminator => Interfaces.C.nul);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  No Documentation  --

    procedure fl_draw_set_spot
           (F, S       : in Interfaces.C.int;
            X, Y, W, H : in Interfaces.C.int;
            Ptr        : in Storage.Integer_Address);
    pragma Import (C, fl_draw_set_spot, "fl_draw_set_spot");
    pragma Inline (fl_draw_set_spot);

    procedure fl_draw_set_status
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_set_status, "fl_draw_set_status");
    pragma Inline (fl_draw_set_status);




    --  Utility  --

    function fl_draw_can_do_alpha_blending
        return Interfaces.C.int;
    pragma Import (C, fl_draw_can_do_alpha_blending, "fl_draw_can_do_alpha_blending");
    pragma Inline (fl_draw_can_do_alpha_blending);

    function fl_draw_shortcut_label
           (Shortcut : in Interfaces.C.unsigned)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_draw_shortcut_label, "fl_draw_shortcut_label");
    pragma Inline (fl_draw_shortcut_label);




    --  Charset Conversion  --

    function fl_draw_recode
           (Kind : in     Interfaces.C.int;
            From : in     Interfaces.C.char_array;
            To   :    out Interfaces.C.char_array;
            N    : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_recode, "fl_draw_recode");
    pragma Inline (fl_draw_recode);




    --  Clipping  --

    function fl_draw_clip_box
           (X, Y, W, H     : in     Interfaces.C.int;
            BX, BY, BW, BH :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_clip_box, "fl_draw_clip_box");
    pragma Inline (fl_draw_clip_box);

    function fl_draw_not_clipped
           (X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_not_clipped, "fl_draw_not_clipped");
    pragma Inline (fl_draw_not_clipped);

    procedure fl_draw_push_clip
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_push_clip, "fl_draw_push_clip");
    pragma Inline (fl_draw_push_clip);

    procedure fl_draw_push_no_clip;
    pragma Import (C, fl_draw_push_no_clip, "fl_draw_push_no_clip");
    pragma Inline (fl_draw_push_no_clip);

    procedure fl_draw_pop_clip;
    pragma Import (C, fl_draw_pop_clip, "fl_draw_pop_clip");
    pragma Inline (fl_draw_pop_clip);




    --  Overlay  --

    function fl_draw_overlay_clear
        return Interfaces.C.int;
    pragma Import (C, fl_draw_overlay_clear, "fl_draw_overlay_clear");
    pragma Inline (fl_draw_overlay_clear);

    function fl_draw_overlay_rect
           (X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_overlay_rect, "fl_draw_overlay_rect");
    pragma Inline (fl_draw_overlay_rect);

    function fl_draw_get_antialias
           (A : out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_get_antialias, "fl_draw_get_antialias");
    pragma Inline (fl_draw_get_antialias);

    function fl_draw_set_antialias
           (A : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_set_antialias, "fl_draw_set_antialias");
    pragma Inline (fl_draw_set_antialias);

    function fl_draw_override_scale
           (S : out Interfaces.C.C_float)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_override_scale, "fl_draw_override_scale");
    pragma Inline (fl_draw_override_scale);

    function fl_draw_restore_scale
           (S : in Interfaces.C.C_float)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_restore_scale, "fl_draw_restore_scale");
    pragma Inline (fl_draw_restore_scale);




    --  Settings  --

    function fl_draw_get_color
        return Interfaces.C.unsigned;
    pragma Import (C, fl_draw_get_color, "fl_draw_get_color");
    pragma Inline (fl_draw_get_color);

    procedure fl_draw_set_color
           (C : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_set_color, "fl_draw_set_color");
    pragma Inline (fl_draw_set_color);

    procedure fl_draw_set_color2
           (R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_draw_set_color2, "fl_draw_set_color2");
    pragma Inline (fl_draw_set_color2);

    procedure fl_draw_set_cursor
           (M : in Interfaces.C.int);
    pragma Import (C, fl_draw_set_cursor, "fl_draw_set_cursor");
    pragma Inline (fl_draw_set_cursor);

    procedure fl_draw_set_cursor2
           (M    : in Interfaces.C.int;
            F, B : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_set_cursor2, "fl_draw_set_cursor2");
    pragma Inline (fl_draw_set_cursor2);

    function fl_draw_get_font
        return Interfaces.C.unsigned;
    pragma Import (C, fl_draw_get_font, "fl_draw_get_font");
    pragma Inline (fl_draw_get_font);

    function fl_draw_size
        return Interfaces.C.int;
    pragma Import (C, fl_draw_size, "fl_draw_size");
    pragma Inline (fl_draw_size);

    procedure fl_draw_set_font
           (F : in Interfaces.C.unsigned;
            S : in Interfaces.C.int);
    pragma Import (C, fl_draw_set_font, "fl_draw_set_font");
    pragma Inline (fl_draw_set_font);

    function fl_draw_height
        return Interfaces.C.int;
    pragma Import (C, fl_draw_height, "fl_draw_height");
    pragma Inline (fl_draw_height);

    function fl_draw_descent
        return Interfaces.C.int;
    pragma Import (C, fl_draw_descent, "fl_draw_descent");
    pragma Inline (fl_draw_descent);

    function fl_draw_height2
           (F : in Interfaces.C.unsigned;
            S : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_height2, "fl_draw_height2");
    pragma Inline (fl_draw_height2);

    procedure fl_draw_line_style
           (Style  : in Interfaces.C.int;
            Width  : in Interfaces.C.int;
            Dashes : in Interfaces.C.char_array);
    pragma Import (C, fl_draw_line_style, "fl_draw_line_style");
    pragma Inline (fl_draw_line_style);




    --  Matrix Operations  --

    procedure fl_draw_push_matrix;
    pragma Import (C, fl_draw_push_matrix, "fl_draw_push_matrix");
    pragma Inline (fl_draw_push_matrix);

    procedure fl_draw_pop_matrix;
    pragma Import (C, fl_draw_pop_matrix, "fl_draw_pop_matrix");
    pragma Inline (fl_draw_pop_matrix);

    procedure fl_draw_mult_matrix
           (A, B, C, D, X, Y : in Interfaces.C.double);
    pragma Import (C, fl_draw_mult_matrix, "fl_draw_mult_matrix");
    pragma Inline (fl_draw_mult_matrix);

    procedure fl_draw_load_identity;
    pragma Import (C, fl_draw_load_identity, "fl_draw_load_identity");
    pragma Inline (fl_draw_load_identity);

    procedure fl_draw_load_matrix
           (A, B, C, D, X, Y : in Interfaces.C.double);
    pragma Import (C, fl_draw_load_matrix, "fl_draw_load_matrix");
    pragma Inline (fl_draw_load_matrix);

    procedure fl_draw_rotate
           (D : in Interfaces.C.double);
    pragma Import (C, fl_draw_rotate, "fl_draw_rotate");
    pragma Inline (fl_draw_rotate);

    procedure fl_draw_scale
           (X : in Interfaces.C.double);
    pragma Import (C, fl_draw_scale, "fl_draw_scale");
    pragma Inline (fl_draw_scale);

    procedure fl_draw_scale2
           (X, Y : in Interfaces.C.double);
    pragma Import (C, fl_draw_scale2, "fl_draw_scale2");
    pragma Inline (fl_draw_scale2);

    function fl_draw_transform_dx
           (X, Y : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_draw_transform_dx, "fl_draw_transform_dx");
    pragma Inline (fl_draw_transform_dx);

    function fl_draw_transform_dy
           (X, Y : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_draw_transform_dy, "fl_draw_transform_dy");
    pragma Inline (fl_draw_transform_dy);

    function fl_draw_transform_x
           (X, Y : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_draw_transform_x, "fl_draw_transform_x");
    pragma Inline (fl_draw_transform_x);

    function fl_draw_transform_y
           (X, Y : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_draw_transform_y, "fl_draw_transform_y");
    pragma Inline (fl_draw_transform_y);

    procedure fl_draw_transformed_vertex
           (XF, YF : in Interfaces.C.double);
    pragma Import (C, fl_draw_transformed_vertex, "fl_draw_transformed_vertex");
    pragma Inline (fl_draw_transformed_vertex);

    procedure fl_draw_translate
           (X, Y : in Interfaces.C.double);
    pragma Import (C, fl_draw_translate, "fl_draw_translate");
    pragma Inline (fl_draw_translate);

    procedure fl_draw_vertex
           (X, Y : in Interfaces.C.double);
    pragma Import (C, fl_draw_vertex, "fl_draw_vertex");
    pragma Inline (fl_draw_vertex);




    --  Image Drawing  --

    procedure fl_draw_draw_image
           (Buf        : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            D, L       : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_image, "fl_draw_draw_image");
    pragma Inline (fl_draw_draw_image);

    procedure fl_draw_draw_image2
           (Call, User    : in Storage.Integer_Address;
            X, Y, W, H, D : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_image2, "fl_draw_draw_image2");
    pragma Inline (fl_draw_draw_image2);

    procedure fl_draw_draw_image_mono
           (Buf        : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            D, L       : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_image_mono, "fl_draw_draw_image_mono");
    pragma Inline (fl_draw_draw_image_mono);

    procedure fl_draw_draw_image_mono2
           (Call, User    : in Storage.Integer_Address;
            X, Y, W, H, D : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_image_mono2, "fl_draw_draw_image_mono2");
    pragma Inline (fl_draw_draw_image_mono2);

    function fl_draw_draw_pixmap
           (Data : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int;
            H    : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_draw_pixmap, "fl_draw_draw_pixmap");
    pragma Inline (fl_draw_draw_pixmap);

    function fl_draw_read_image
           (Buf        : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            Alpha      : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_draw_read_image, "fl_draw_read_image");
    pragma Inline (fl_draw_read_image);

    function fl_draw_capture_window
           (Win        : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_draw_capture_window, "fl_draw_capture_window");
    pragma Inline (fl_draw_capture_window);




    --  Special Drawing  --

    function fl_draw_add_symbol
           (Name     : in Interfaces.C.char_array;
            Drawit   : in Storage.Integer_Address;
            Scalable : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_add_symbol, "fl_draw_add_symbol");
    pragma Inline (fl_draw_add_symbol);

    procedure fl_draw_draw_text
           (Str     : in Interfaces.C.char_array;
            N, X, Y : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_text, "fl_draw_draw_text");
    pragma Inline (fl_draw_draw_text);

    procedure fl_draw_draw_text2
           (Str        : in Interfaces.C.char_array;
            X, Y, W, H : in Interfaces.C.int;
            Ali        : in Interfaces.Unsigned_16;
            Img        : in Storage.Integer_Address;
            Sym        : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_text2, "fl_draw_draw_text2");
    pragma Inline (fl_draw_draw_text2);

    procedure fl_draw_draw_text3
           (Str        : in Interfaces.C.char_array;
            X, Y, W, H : in Interfaces.C.int;
            Ali        : in Interfaces.Unsigned_16;
            Func       : in Storage.Integer_Address;
            Img        : in Storage.Integer_Address;
            Sym        : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_text3, "fl_draw_draw_text3");
    pragma Inline (fl_draw_draw_text3);

    procedure fl_draw_draw_text4
           (Ang     : in Interfaces.C.int;
            Str     : in Interfaces.C.char_array;
            N, X, Y : in Interfaces.C.int);
    pragma Import (C, fl_draw_draw_text4, "fl_draw_draw_text4");
    pragma Inline (fl_draw_draw_text4);

    procedure fl_draw_rtl_draw
           (Str     : in Interfaces.C.char_array;
            N, X, Y : in Interfaces.C.int);
    pragma Import (C, fl_draw_rtl_draw, "fl_draw_rtl_draw");
    pragma Inline (fl_draw_rtl_draw);

    procedure fl_draw_draw_box
           (BK         : in Interfaces.C.int;
            X, Y, W, H : in Interfaces.C.int;
            C          : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_draw_box, "fl_draw_draw_box");
    pragma Inline (fl_draw_draw_box);

    function fl_draw_draw_symbol
           (Lab        : in Interfaces.C.char_array;
            X, Y, W, H : in Interfaces.C.int;
            Hue        : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_draw_symbol, "fl_draw_draw_symbol");
    pragma Inline (fl_draw_draw_symbol);

    procedure fl_draw_measure
           (Str  : in     Interfaces.C.char_array;
            W, H : in out Interfaces.C.int;
            S    : in     Interfaces.C.int);
    pragma Import (C, fl_draw_measure, "fl_draw_measure");
    pragma Inline (fl_draw_measure);

    function fl_draw_scroll
           (X, Y, W, H : in Interfaces.C.int;
            DX, DY     : in Interfaces.C.int;
            Func, Data : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_draw_scroll, "fl_draw_scroll");
    pragma Inline (fl_draw_scroll);

    procedure fl_draw_text_extents
           (Str          : in     Interfaces.C.char_array;
            N            : in     Interfaces.C.int;
            DX, DY, W, H :    out Interfaces.C.int);
    pragma Import (C, fl_draw_text_extents, "fl_draw_text_extents");
    pragma Inline (fl_draw_text_extents);

    --  This function in particular is such bullshit.
    function fl_draw_expand_text
           (Str       : in     Interfaces.C.char_array;
            Buf       :    out Interfaces.C.char_array;
            Max_Buf   : in     Interfaces.C.int;
            Max_W     : in     Interfaces.C.double;
            N         :    out Interfaces.C.int;
            Width     :    out Interfaces.C.double;
            Wrap, Sym : in     Interfaces.C.int)
        return Char_Pointers.Pointer;
    pragma Import (C, fl_draw_expand_text, "fl_draw_expand_text");
    pragma Inline (fl_draw_expand_text);

    function fl_draw_width
           (Str : in Interfaces.C.char_array;
            N   : in Interfaces.C.int)
        return Interfaces.C.double;
    pragma Import (C, fl_draw_width, "fl_draw_width");
    pragma Inline (fl_draw_width);

    function fl_draw_width2
           (C : in Interfaces.C.unsigned_long)
        return Interfaces.C.double;
    pragma Import (C, fl_draw_width2, "fl_draw_width2");
    pragma Inline (fl_draw_width2);




    --  Manual Drawing  --

    procedure fl_draw_arc
           (X, Y, R, Start, Finish : in Interfaces.C.double);
    pragma Import (C, fl_draw_arc, "fl_draw_arc");
    pragma Inline (fl_draw_arc);

    procedure fl_draw_arc2
           (X, Y, W, H : in Interfaces.C.int;
            A1, A2     : in Interfaces.C.double);
    pragma Import (C, fl_draw_arc2, "fl_draw_arc2");
    pragma Inline (fl_draw_arc2);

    --  this function does not yet exist
    --  procedure fl_draw_chord
    --         (X, Y, W, H : in Interfaces.C.int;
    --          A1, A2     : in Interfaces.C.double);
    --  pragma Import (C, fl_draw_chord, "fl_draw_chord");
    --  pragma Inline (fl_draw_chord);

    procedure fl_draw_circle
           (X, Y, R : in Interfaces.C.double);
    pragma Import (C, fl_draw_circle, "fl_draw_circle");
    pragma Inline (fl_draw_circle);

    procedure fl_draw_curve
           (X0, Y0 : in Interfaces.C.double;
            X1, Y1 : in Interfaces.C.double;
            X2, Y2 : in Interfaces.C.double;
            X3, Y3 : in Interfaces.C.double);
    pragma Import (C, fl_draw_curve, "fl_draw_curve");
    pragma Inline (fl_draw_curve);

    procedure fl_draw_frame
           (S          : in Interfaces.C.char_array;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_frame, "fl_draw_frame");
    pragma Inline (fl_draw_frame);

    procedure fl_draw_frame2
           (S          : in Interfaces.C.char_array;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_frame2, "fl_draw_frame2");
    pragma Inline (fl_draw_frame2);

    procedure fl_draw_focus_rect
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_focus_rect, "fl_draw_focus_rect");
    pragma Inline (fl_draw_focus_rect);

    procedure fl_draw_rounded_rect
           (X, Y, W, H, R : in Interfaces.C.int);
    pragma Import (C, fl_draw_rounded_rect, "fl_draw_rounded_rect");
    pragma Inline (fl_draw_rounded_rect);

    procedure fl_draw_rounded_rectf
           (X, Y, W, H, R : in Interfaces.C.int);
    pragma Import (C, fl_draw_rounded_rectf, "fl_draw_rounded_rectf");
    pragma Inline (fl_draw_rounded_rectf);

    procedure fl_draw_draw_box_focus
           (K          : in Interfaces.C.int;
            X, Y, W, H : in Interfaces.C.int;
            F, B       : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_draw_box_focus, "fl_draw_draw_box_focus");
    pragma Inline (fl_draw_draw_box_focus);

    procedure fl_draw_draw_check
           (X, Y, W, H : in Interfaces.C.int;
            C          : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_draw_check, "fl_draw_draw_check");
    pragma Inline (fl_draw_draw_check);

    procedure fl_draw_draw_radio
           (X, Y, D : in Interfaces.C.int;
            C       : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_draw_radio, "fl_draw_draw_radio");
    pragma Inline (fl_draw_draw_radio);

    procedure fl_draw_draw_arrow
           (X, Y, W, H : in Interfaces.C.int;
            T, O       : in Interfaces.C.int;
            C          : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_draw_arrow, "fl_draw_draw_arrow");
    pragma Inline (fl_draw_draw_arrow);

    procedure fl_draw_line
           (X0, Y0 : in Interfaces.C.int;
            X1, Y1 : in Interfaces.C.int);
    pragma Import (C, fl_draw_line, "fl_draw_line");
    pragma Inline (fl_draw_line);

    procedure fl_draw_line2
           (X0, Y0 : in Interfaces.C.int;
            X1, Y1 : in Interfaces.C.int;
            X2, Y2 : in Interfaces.C.int);
    pragma Import (C, fl_draw_line2, "fl_draw_line2");
    pragma Inline (fl_draw_line2);

    procedure fl_draw_loop
           (X0, Y0 : in Interfaces.C.int;
            X1, Y1 : in Interfaces.C.int;
            X2, Y2 : in Interfaces.C.int);
    pragma Import (C, fl_draw_loop, "fl_draw_loop");
    pragma Inline (fl_draw_loop);

    procedure fl_draw_loop2
           (X0, Y0 : in Interfaces.C.int;
            X1, Y1 : in Interfaces.C.int;
            X2, Y2 : in Interfaces.C.int;
            X3, Y3 : in Interfaces.C.int);
    pragma Import (C, fl_draw_loop2, "fl_draw_loop2");
    pragma Inline (fl_draw_loop2);

    procedure fl_draw_pie
           (X, Y, W, H : in Interfaces.C.int;
            A1, A2     : in Interfaces.C.double);
    pragma Import (C, fl_draw_pie, "fl_draw_pie");
    pragma Inline (fl_draw_pie);

    procedure fl_draw_point
           (X, Y : in Interfaces.C.int);
    pragma Import (C, fl_draw_point, "fl_draw_point");
    pragma Inline (fl_draw_point);

    procedure fl_draw_polygon
           (X0, Y0 : in Interfaces.C.int;
            X1, Y1 : in Interfaces.C.int;
            X2, Y2 : in Interfaces.C.int);
    pragma Import (C, fl_draw_polygon, "fl_draw_polygon");
    pragma Inline (fl_draw_polygon);

    procedure fl_draw_polygon2
           (X0, Y0 : in Interfaces.C.int;
            X1, Y1 : in Interfaces.C.int;
            X2, Y2 : in Interfaces.C.int;
            X3, Y3 : in Interfaces.C.int);
    pragma Import (C, fl_draw_polygon2, "fl_draw_polygon2");
    pragma Inline (fl_draw_polygon2);

    procedure fl_draw_rect
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_rect, "fl_draw_rect");
    pragma Inline (fl_draw_rect);

    procedure fl_draw_rect2
           (X, Y, W, H : in Interfaces.C.int;
            C          : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_rect2, "fl_draw_rect2");
    pragma Inline (fl_draw_rect2);

    procedure fl_draw_rect_fill
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_rect_fill, "fl_draw_rect_fill");
    pragma Inline (fl_draw_rect_fill);

    procedure fl_draw_rect_fill2
           (X, Y, W, H : in Interfaces.C.int;
            C          : in Interfaces.C.unsigned);
    pragma Import (C, fl_draw_rect_fill2, "fl_draw_rect_fill2");
    pragma Inline (fl_draw_rect_fill2);

    procedure fl_draw_rect_fill3
           (X, Y, W, H : in Interfaces.C.int;
            R, G, B    : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_draw_rect_fill3, "fl_draw_rect_fill3");
    pragma Inline (fl_draw_rect_fill3);

    procedure fl_draw_xy_line
           (X0, Y0, X1 : in Interfaces.C.int);
    pragma Import (C, fl_draw_xy_line, "fl_draw_xy_line");
    pragma Inline (fl_draw_xy_line);

    procedure fl_draw_xy_line2
           (X0, Y0, X1, Y2 : in Interfaces.C.int);
    pragma Import (C, fl_draw_xy_line2, "fl_draw_xy_line2");
    pragma Inline (fl_draw_xy_line2);

    procedure fl_draw_xy_line3
           (X0, Y0, X1, Y2, X3 : in Interfaces.C.int);
    pragma Import (C, fl_draw_xy_line3, "fl_draw_xy_line3");
    pragma Inline (fl_draw_xy_line3);

    procedure fl_draw_yx_line
           (X0, Y0, Y1 : in Interfaces.C.int);
    pragma Import (C, fl_draw_yx_line, "fl_draw_yx_line");
    pragma Inline (fl_draw_yx_line);

    procedure fl_draw_yx_line2
           (X0, Y0, Y1, X2 : in Interfaces.C.int);
    pragma Import (C, fl_draw_yx_line2, "fl_draw_yx_line2");
    pragma Inline (fl_draw_yx_line2);

    procedure fl_draw_yx_line3
           (X0, Y0, Y1, X2, Y3 : in Interfaces.C.int);
    pragma Import (C, fl_draw_yx_line3, "fl_draw_yx_line3");
    pragma Inline (fl_draw_yx_line3);




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  No Documentation  --

    procedure Set_Spot
           (X, Y, W, H : in Integer;
            Font       : in Font_Kind;
            Size       : in Font_Size) is
    begin
        fl_draw_set_spot
           (To_C (Font),
            Interfaces.C.int (Size),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Null_Pointer);
    end Set_Spot;


    procedure Set_Spot
           (X, Y, W, H : in Integer;
            Font       : in Font_Kind;
            Size       : in Font_Size;
            Pane       : in FLTK.Widgets.Groups.Windows.Window'Class) is
    begin
        fl_draw_set_spot
           (To_C (Font),
            Interfaces.C.int (Size),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Wrapper (Pane).Void_Ptr);
    end Set_Spot;


    procedure Set_Status
           (X, Y, W, H : in Integer) is
    begin
        fl_draw_set_status
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Set_Status;




    --  Utility  --

    function Can_Do_Alpha_Blending
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_draw_can_do_alpha_blending;
    begin
        if Result = 1 then
            return True;
        else
            pragma Assert (Result = 0);
            return False;
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "fl_can_do_alpha_blending returned unexpected value of " &
        Interfaces.C.int'Image (Result);
    end Can_Do_Alpha_Blending;


    function Shortcut_Label
           (Keys : in Key_Combo)
        return String is
    begin
        return Interfaces.C.Strings.Value
            (fl_draw_shortcut_label (To_C (Keys)));
    end Shortcut_Label;




    --  Charset Conversion  --

    --  The kinds fl_draw_recode takes.
    Latin1_To_Local_Kind    : constant Interfaces.C.int := 0;
    Local_To_Latin1_Kind    : constant Interfaces.C.int := 1;
    Mac_Roman_To_Local_Kind : constant Interfaces.C.int := 2;
    Local_To_Mac_Roman_Kind : constant Interfaces.C.int := 3;

    function Recode
           (Kind : in Interfaces.C.int;
            From : in String)
        return String is
    begin
        if From'Length = 0 then
            return "";
        end if;
        declare
            Source : constant Interfaces.C.char_array :=
                Interfaces.C.To_C (From, Append_Nul => False);
            Target : Interfaces.C.char_array (Source'Range);
        begin
            if fl_draw_recode (Kind, Source, Target, Interfaces.C.int (From'Length)) /= 0 then
                raise Storage_Error with "charset conversion buffer could not be allocated";
            end if;
            return Interfaces.C.To_Ada (Target, Trim_Nul => False);
        end;
    end Recode;


    function Latin1_To_Local
           (From : in String)
        return String is
    begin
        return Recode (Latin1_To_Local_Kind, From);
    end Latin1_To_Local;


    function Local_To_Latin1
           (From : in String)
        return String is
    begin
        return Recode (Local_To_Latin1_Kind, From);
    end Local_To_Latin1;


    function Mac_Roman_To_Local
           (From : in String)
        return String is
    begin
        return Recode (Mac_Roman_To_Local_Kind, From);
    end Mac_Roman_To_Local;


    function Local_To_Mac_Roman
           (From : in String)
        return String is
    begin
        return Recode (Local_To_Mac_Roman_Kind, From);
    end Local_To_Mac_Roman;




    --  Clipping  --

    function Clip_Box
           (X, Y, W, H     : in     Integer;
            BX, BY, BW, BH :    out Integer)
        return Boolean
    is
        CX, CY, CW, CH : Interfaces.C.int;
        Result : constant Interfaces.C.int := fl_draw_clip_box
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            CX, CY, CW, CH);
    begin
        BX := Integer (CX);
        BY := Integer (CY);
        BW := Integer (CW);
        BH := Integer (CH);
        return Result /= 0;
    end Clip_Box;


    function Clip_Intersects
           (X, Y, W, H : in Integer)
        return Boolean is
    begin
        return fl_draw_not_clipped
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H)) /= 0;
    end Clip_Intersects;


    procedure Push_Clip
           (X, Y, W, H : in Integer) is
    begin
        fl_draw_push_clip
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
        Drawing_State.Remember (Undo_Clip'Access);
    end Push_Clip;


    procedure Push_No_Clip is
    begin
        fl_draw_push_no_clip;
        Drawing_State.Remember (Undo_Clip'Access);
    end Push_No_Clip;


    procedure Pop_Clip is
    begin
        fl_draw_pop_clip;
        Drawing_State.Forget (Undo_Clip'Access);
    end Pop_Clip;


    procedure Undo_Clip
           (Item : in System.Address)
    is
        pragma Unreferenced (Item);
    begin
        Pop_Clip;
    end Undo_Clip;


    procedure Initialize
           (This : in out Clip_Guard) is
    begin
        Push_Clip (This.X, This.Y, This.W, This.H);
    end Initialize;


    procedure Finalize
           (This : in out Clip_Guard)
    is
        pragma Unreferenced (This);
    begin
        Pop_Clip;
    exception
    when others =>
        null;
    end Finalize;


    procedure Initialize
           (This : in out No_Clip_Guard)
    is
        pragma Unreferenced (This);
    begin
        Push_No_Clip;
    end Initialize;


    procedure Finalize
           (This : in out No_Clip_Guard)
    is
        pragma Unreferenced (This);
    begin
        Pop_Clip;
    exception
    when others =>
        null;
    end Finalize;




    --  Overlay  --

    procedure Overlay_Clear is
    begin
        if fl_draw_overlay_clear = 0 then
            raise Program_Error with "Overlay_Clear needs a shown window to be current";
        end if;
    end Overlay_Clear;


    procedure Overlay_Rect
           (X, Y, W, H : in Integer) is
    begin
        if fl_draw_overlay_rect
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H)) = 0
        then
            raise Program_Error with "Overlay_Rect needs a shown window to be current";
        end if;
    end Overlay_Rect;




    --  Settings  --

    function Get_Color
        return Color is
    begin
        return Color (fl_draw_get_color);
    end Get_Color;


    procedure Set_Color
           (To : in Color) is
    begin
        fl_draw_set_color (Interfaces.C.unsigned (To));
    end Set_Color;


    procedure Set_Color
           (R, G, B : in Color_Component) is
    begin
        fl_draw_set_color2
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Color;


    procedure Set_Cursor
           (To : in Mouse_Cursor_Kind) is
    begin
        fl_draw_set_cursor (Cursor_Values (To));
    end Set_Cursor;

    procedure Set_Cursor
           (To   : in Mouse_Cursor_Kind;
            Fore : in Color;
            Back : in Color := White_Color) is
    begin
        fl_draw_set_cursor2
           (Cursor_Values (To),
            Interfaces.C.unsigned (Fore),
            Interfaces.C.unsigned (Back));
    end Set_Cursor;


    function Get_Font
        return Font_Kind is
    begin
        return Font_Kind (fl_draw_get_font);
    end Get_Font;


    function Get_Font_Size
        return Font_Size is
    begin
        return Font_Size (fl_draw_size);
    end Get_Font_Size;


    procedure Set_Font
           (Kind : in Font_Kind;
            Size : in Font_Size) is
    begin
        fl_draw_set_font (Interfaces.C.unsigned (To_C (Kind)), Interfaces.C.int (Size));
    end Set_Font;


    function Font_Line_Spacing
        return Integer is
    begin
        return Integer (fl_draw_height);
    end Font_Line_Spacing;


    function Font_Descent
        return Integer is
    begin
        return Integer (fl_draw_descent);
    end Font_Descent;


    function Font_Height
           (Kind : in Font_Kind;
            Size : in Font_Size)
        return Natural is
    begin
        return Natural (fl_draw_height2
           (Interfaces.C.unsigned (To_C (Kind)), Interfaces.C.int (Size)));
    end Font_Height;


    procedure Set_Line_Style
           (Line   : in Line_Kind      := Solid_Line;
            Cap    : in Cap_Kind       := Default_Cap;
            Join   : in Join_Kind      := Default_Join;
            Width  : in Natural        := 0;
            Dashes : in Dash_Gap_Array := Empty_Dashes) is
    begin
        --  FLTK copies the pattern into linedash_[256], unchecked
        --  (Fl_Cairo_Graphics_Driver.cxx:317-319; pofltk 136).
        if Dashes'Length > Max_Dash_Gaps then
            raise Constraint_Error with "more than" & Integer'Image (Max_Dash_Gaps)
                & " dash gaps:" & Integer'Image (Dashes'Length);
        end if;
        --  No driver keeps the pointer: Cairo and PostScript copy the
        --  pattern, SVG duplicates it, and Xlib uses it at once
        --  (FLTKAda-BUGS.md 59), so it is built on the stack.
        declare
            Pattern : Interfaces.C.char_array (1 .. (Dashes'Length + 1) * 2) :=
                (others => Interfaces.C.char'Val (0));
        begin
            for Index in Integer range 1 .. Dashes'Length loop
                Pattern (2 * Interfaces.C.size_t (Index) - 1) :=
                    Interfaces.C.char'Val (Integer (Dashes (Index).Solid));
                Pattern (2 * Interfaces.C.size_t (Index)) :=
                    Interfaces.C.char'Val (Integer (Dashes (Index).Blank));
            end loop;
            fl_draw_line_style
               (Line_Kind'Pos (Line) + Cap_Kind'Pos (Cap) * 16#100#
                    + Join_Kind'Pos (Join) * 16#1000#,
                Interfaces.C.int (Width),
                Pattern);
        end;
    end Set_Line_Style;


    function Get_Antialias
        return Boolean
    is
        A : Interfaces.C.int := 0;
    begin
        if fl_draw_get_antialias (A) = 0 then
            raise Program_Error with
                "Get_Antialias needs a surface, or a shown window to be current";
        end if;
        return A /= 0;
    end Get_Antialias;


    procedure Set_Antialias
           (To : in Boolean) is
    begin
        if fl_draw_set_antialias (Boolean'Pos (To)) = 0 then
            raise Program_Error with
                "Set_Antialias needs a surface, or a shown window to be current";
        end if;
    end Set_Antialias;


    function Override_Scale
        return Float
    is
        S : Interfaces.C.C_float := 1.0;
    begin
        if fl_draw_override_scale (S) = 0 then
            raise Program_Error with
                "Override_Scale needs a surface, or a shown window to be current";
        end if;
        return Float (S);
    end Override_Scale;


    procedure Restore_Scale
           (Factor : in Float) is
    begin
        if fl_draw_restore_scale (Interfaces.C.C_float (Factor)) = 0 then
            raise Program_Error with
                "Restore_Scale needs a surface, or a shown window to be current";
        end if;
    end Restore_Scale;




    --  Matrix Operations  --

    procedure Push_Matrix is
    begin
        fl_draw_push_matrix;
        Drawing_State.Remember (Undo_Matrix'Access);
    end Push_Matrix;


    procedure Pop_Matrix is
    begin
        fl_draw_pop_matrix;
        Drawing_State.Forget (Undo_Matrix'Access);
    end Pop_Matrix;


    procedure Undo_Matrix
           (Item : in System.Address)
    is
        pragma Unreferenced (Item);
    begin
        Pop_Matrix;
    end Undo_Matrix;


    procedure Initialize
           (This : in out Matrix_Guard)
    is
        pragma Unreferenced (This);
    begin
        Push_Matrix;
    end Initialize;


    procedure Finalize
           (This : in out Matrix_Guard)
    is
        pragma Unreferenced (This);
    begin
        Pop_Matrix;
    exception
    when others =>
        null;
    end Finalize;


    procedure Mult_Matrix
           (A, B, C, D, X, Y : in Long_Float) is
    begin
        fl_draw_mult_matrix
           (Interfaces.C.double (A),
            Interfaces.C.double (B),
            Interfaces.C.double (C),
            Interfaces.C.double (D),
            Interfaces.C.double (X),
            Interfaces.C.double (Y));
    end Mult_Matrix;


    procedure Load_Identity is
    begin
        fl_draw_load_identity;
    end Load_Identity;


    procedure Load_Matrix
           (A, B, C, D, X, Y : in Long_Float) is
    begin
        fl_draw_load_matrix
           (Interfaces.C.double (A),
            Interfaces.C.double (B),
            Interfaces.C.double (C),
            Interfaces.C.double (D),
            Interfaces.C.double (X),
            Interfaces.C.double (Y));
    end Load_Matrix;


    procedure Rotate
           (Angle : in Long_Float) is
    begin
        fl_draw_rotate (Interfaces.C.double (Angle));
    end Rotate;


    procedure Scale
           (Factor : in Long_Float) is
    begin
        fl_draw_scale (Interfaces.C.double (Factor));
    end Scale;


    procedure Scale
           (Factor_X, Factor_Y : in Long_Float) is
    begin
        fl_draw_scale2
           (Interfaces.C.double (Factor_X),
            Interfaces.C.double (Factor_Y));
    end Scale;


    function Transform_DX
           (X, Y : in Long_Float)
        return Long_Float is
    begin
        return Long_Float (fl_draw_transform_dx
           (Interfaces.C.double (X),
            Interfaces.C.double (Y)));
    end Transform_DX;


    function Transform_DY
           (X, Y : in Long_Float)
        return Long_Float is
    begin
        return Long_Float (fl_draw_transform_dy
           (Interfaces.C.double (X),
            Interfaces.C.double (Y)));
    end Transform_DY;


    function Transform_X
           (X, Y : in Long_Float)
        return Long_Float is
    begin
        return Long_Float (fl_draw_transform_x
           (Interfaces.C.double (X),
            Interfaces.C.double (Y)));
    end Transform_X;


    function Transform_Y
           (X, Y : in Long_Float)
        return Long_Float is
    begin
        return Long_Float (fl_draw_transform_y
           (Interfaces.C.double (X),
            Interfaces.C.double (Y)));
    end Transform_Y;


    procedure Transformed_Vertex
           (XF, YF : in Long_Float) is
    begin
        fl_draw_transformed_vertex
           (Interfaces.C.double (XF),
            Interfaces.C.double (YF));
    end Transformed_Vertex;


    procedure Translate
           (X, Y : in Long_Float) is
    begin
        fl_draw_translate
           (Interfaces.C.double (X),
            Interfaces.C.double (Y));
    end Translate;


    procedure Vertex
           (X, Y : in Long_Float) is
    begin
        fl_draw_vertex
           (Interfaces.C.double (X),
            Interfaces.C.double (Y));
    end Vertex;




    --  Image Drawing  --

    --  True while an image-line function runs.  FLTK's Xlib drawing keeps
    --  its image and buffer in statics, and the binding keeps the line
    --  function in a variable, so no Draw_Image may run inside one
    --  (pofltk 133).
    In_Image_Line : Boolean := False;

    procedure Check_Not_In_Image_Line is
    begin
        if In_Image_Line then
            raise Draw_Error with "Draw_Image or Draw_Image_Mono inside an image-line function";
        end if;
    end Check_Not_In_Image_Line;

    --  FLTK reads pixel (PX, PY) at Buf + PX * D + PY * L.  With D or L
    --  negative, Buf must be the last pixel of the first row or the first
    --  pixel of the last row, so the start moves to match, and the data
    --  must hold every row (FLTKAda-BUGS.md 117).  The check is an explicit
    --  raise, as release builds don't check a Pre.
    procedure Image_Start
           (W, H            : in     Integer;
            Data            : in     Color_Component_Array;
            Depth           : in     Positive;
            Line_Size       : in     Natural;
            Flip_Horizontal : in     Boolean;
            Flip_Vertical   : in     Boolean;
            Start           :    out Storage.Integer_Address;
            Real_Depth      :    out Integer;
            Real_Line_Size  :    out Integer)
    is
        Stride : constant Long_Long_Integer :=
            (if Line_Size = 0
             then Long_Long_Integer (W) * Long_Long_Integer (Depth)
             else Long_Long_Integer (Line_Size));
        Needed : constant Long_Long_Integer :=
            Long_Long_Integer (H - 1) * Stride
                + Long_Long_Integer (W) * Long_Long_Integer (Depth);
        Offset : constant Long_Long_Integer :=
            (if Flip_Horizontal then Long_Long_Integer (W - 1) * Long_Long_Integer (Depth) else 0)
                + (if Flip_Vertical then Long_Long_Integer (H - 1) * Stride else 0);
    begin
        if Long_Long_Integer (Data'Length) < Needed then
            raise Constraint_Error with "image data too short:" & Data'Length'Image
                & " bytes, not" & Needed'Image;
        end if;
        Start := Storage.To_Integer (Data (Data'First + Size_Type (Offset))'Address);
        Real_Depth := (if Flip_Horizontal then -Depth else Depth);
        Real_Line_Size := (if Flip_Vertical then Integer (-Stride) else Line_Size);
    end Image_Start;


    procedure Draw_Image
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 3;
            Line_Size       : in Natural := 0;
            Flip_Horizontal : in Boolean := False;
            Flip_Vertical   : in Boolean := False)
    is
        Start : Storage.Integer_Address;
        Real_Depth, Real_Line_Data : Integer;
    begin
        Check_Not_In_Image_Line;
        if W < 1 or H < 1 then
            return;
        end if;
        Image_Start (W, H, Data, Depth, Line_Size, Flip_Horizontal, Flip_Vertical,
            Start, Real_Depth, Real_Line_Data);
        fl_draw_draw_image
           (Start,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Real_Depth),
            Interfaces.C.int (Real_Line_Data));
    end Draw_Image;


    Image_Func_Ptr : Image_Draw_Function;
    Image_Depth : Positive := 1;

    --  Set when an image-line function raised.  The hook then fills the
    --  rest of the image's lines with zeros, without calling it again, and
    --  Draw_Image and Draw_Image_Mono raise its exception once FLTK returns
    --  (PLAN.md N12).
    Line_Raised : Boolean := False;

    procedure Draw_Image_Hook
           (Ignore  : in Storage.Integer_Address;
            X, Y, W : in Interfaces.C.int;
            Buf_Ptr : in Storage.Integer_Address);
    pragma Convention (C, Draw_Image_Hook);

    procedure Draw_Image_Hook
           (Ignore  : in Storage.Integer_Address;
            X, Y, W : in Interfaces.C.int;
            Buf_Ptr : in Storage.Integer_Address)
    is
        Mark        : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        --  FLTK's line holds W pixels of Depth bytes each.
        Data_Buffer : Color_Component_Array (1 .. Size_Type (W) * Size_Type (Image_Depth));
        for Data_Buffer'Address use Storage.To_Address (Buf_Ptr);
        pragma Import (Ada, Data_Buffer);
    begin
        if Line_Raised then
            Data_Buffer := (others => 0);
        else
            In_Image_Line := True;
            Image_Func_Ptr (Integer (X), Integer (Y), Data_Buffer);
            In_Image_Line := False;
        end if;
    exception
    when Occurrence : others =>
        In_Image_Line := False;
        Line_Raised := True;
        Data_Buffer := (others => 0);
        Hook_Exceptions.Save (Occurrence, Mark);
    end Draw_Image_Hook;

    procedure Draw_Image
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 3) is
    begin
        Check_Not_In_Image_Line;
        --  FLTK's Cairo drawing allocates W * Depth * H bytes, and a
        --  negative size throws (FLTK-issues.md F34).
        if W < 1 or H < 1 then
            return;
        end if;
        Image_Func_Ptr := Callback;
        Image_Depth := Depth;
        Line_Raised := False;
        fl_draw_draw_image2
           (Storage.To_Integer (Draw_Image_Hook'Address),
            Null_Pointer,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Depth));
        Hook_Exceptions.Reraise;
    end Draw_Image;


    procedure Draw_Image_Mono
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 1;
            Line_Size       : in Natural := 0;
            Flip_Horizontal : Boolean := False;
            Flip_Vertical   : Boolean := False)
    is
        Start : Storage.Integer_Address;
        Real_Depth, Real_Line_Data : Integer;
    begin
        Check_Not_In_Image_Line;
        if W < 1 or H < 1 then
            return;
        end if;
        Image_Start (W, H, Data, Depth, Line_Size, Flip_Horizontal, Flip_Vertical,
            Start, Real_Depth, Real_Line_Data);
        fl_draw_draw_image_mono
           (Start,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Real_Depth),
            Interfaces.C.int (Real_Line_Data));
    end Draw_Image_Mono;


    Mono_Image_Func_Ptr : Image_Draw_Function;
    Mono_Image_Depth : Positive := 1;

    procedure Draw_Image_Mono_Hook
           (Ignore  : in Storage.Integer_Address;
            X, Y, W : in Interfaces.C.int;
            Buf_Ptr : in Storage.Integer_Address);
    pragma Convention (C, Draw_Image_Mono_Hook);

    procedure Draw_Image_Mono_Hook
           (Ignore  : in Storage.Integer_Address;
            X, Y, W : in Interfaces.C.int;
            Buf_Ptr : in Storage.Integer_Address)
    is
        Mark        : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        --  FLTK's line holds W pixels of Depth bytes each.
        Data_Buffer : Color_Component_Array (1 .. Size_Type (W) * Size_Type (Mono_Image_Depth));
        for Data_Buffer'Address use Storage.To_Address (Buf_Ptr);
        pragma Import (Ada, Data_Buffer);
    begin
        if Line_Raised then
            Data_Buffer := (others => 0);
        else
            In_Image_Line := True;
            Mono_Image_Func_Ptr (Integer (X), Integer (Y), Data_Buffer);
            In_Image_Line := False;
        end if;
    exception
    when Occurrence : others =>
        In_Image_Line := False;
        Line_Raised := True;
        Data_Buffer := (others => 0);
        Hook_Exceptions.Save (Occurrence, Mark);
    end Draw_Image_Mono_Hook;

    procedure Draw_Image_Mono
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 1) is
    begin
        Check_Not_In_Image_Line;
        --  FLTK's Cairo drawing allocates W * Depth * H bytes, and a
        --  negative size throws (FLTK-issues.md F34).
        if W < 1 or H < 1 then
            return;
        end if;
        Mono_Image_Func_Ptr := Callback;
        Mono_Image_Depth := Depth;
        Line_Raised := False;
        fl_draw_draw_image_mono2
           (Storage.To_Integer (Draw_Image_Mono_Hook'Address),
            Null_Pointer,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Depth));
        Hook_Exceptions.Reraise;
    end Draw_Image_Mono;


    procedure Draw_Pixmap
           (Values : in FLTK.Images.Pixmaps.Header;
            Colors : in FLTK.Images.Pixmaps.Color_Definition_Array;
            Pixels : in FLTK.Images.Pixmaps.Pixmap_Data;
            X, Y   : in Integer;
            Tone   : in Color := Grey0_Color)
    is
        C_Data : Pixmap_Marshal.chars_ptr_array_access :=
            Pixmap_Marshal.Marshal_Data (Values, Colors, Pixels);
        Result : constant Interfaces.C.int := fl_draw_draw_pixmap
           (Storage.To_Integer (C_Data (C_Data'First)'Address),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.unsigned (Tone));
    begin
        Pixmap_Marshal.Free_Recursive (C_Data);
        --  Explicit, not pragma Assert, which a release build doesn't
        --  check (FLTKAda-BUGS.md 28).
        if Result = 0 then
            raise Draw_Error with "fl_draw_pixmap could not decode supplied XPM pixmap data";
        end if;
    end Draw_Pixmap;


    function Read_Image
           (X, Y, W, H : in Integer;
            Alpha      : in Integer := 0)
        return Color_Component_Array
    is
        My_Len : constant Size_Type :=
           (if Alpha = 0
            then Size_Type (W) * Size_Type (H) * 3
            else Size_Type (W) * Size_Type (H) * 4);
        Result : Color_Component_Array (1 .. My_Len);
        Buffer : Storage.Integer_Address;
    begin
        Buffer := fl_draw_read_image
           ((if Result'Length > 0
             then Storage.To_Integer (Result (Result'First)'Address)
             else Null_Pointer),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Alpha));
        if Result'Length = 0 then
            return Result;
        elsif Buffer = Null_Pointer then
            raise Draw_Error with
                "Read_Image with nothing drawn on, or that FLTK couldn't read";
        elsif Buffer /= Storage.To_Integer (Result (Result'First)'Address) then
            raise Internal_FLTK_Error with
                "fl_read_image returned unexpected address value that did not " &
                "correspond to supplied address value";
        end if;
        return Result;
    end Read_Image;


    function Capture_Window
           (Item       : in FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H : in Integer)
        return FLTK.Images.RGB.RGB_Image
    is
        Captured : constant Storage.Integer_Address := fl_draw_capture_window
           (Wrapper (Item).Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    begin
        if Captured = Null_Pointer then
            raise Draw_Error with
                "Capture_Window of a window not shown, or of nothing inside it";
        end if;
        return Img : FLTK.Images.RGB.RGB_Image do
            Wrapper (Img).Void_Ptr := Captured;
        end return;
    end Capture_Window;




    --  Special Drawing  --

    procedure Add_Symbol
           (Text     : in String;
            Callback : in Symbol_Draw_Function;
            Scalable : in Boolean)
    is
        Ret_Val : constant Interfaces.C.int := fl_draw_add_symbol
           (Interfaces.C.To_C (Text),
            Storage.To_Integer (Callback.all'Address),
            Boolean'Pos (Scalable));
    begin
        if Ret_Val = 0 then
            raise Draw_Error;
        else
            pragma Assert (Ret_Val = 1);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "fl_add_symbol returned unexpected int value of " &
        Interfaces.C.int'Image (Ret_Val);
    end Add_Symbol;

    procedure Draw_Text
           (X, Y : in Integer;
            Text : in String) is
    begin
        fl_draw_draw_text
           (Interfaces.C.To_C (Text),
            Text'Length,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw_Text;


    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Symbols    : in Boolean := True) is
    begin
        fl_draw_draw_text2
           (Interfaces.C.To_C (Text),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.Unsigned_16 (Align),
            Null_Pointer,
            Boolean'Pos (Symbols));
    end Draw_Text;


    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Picture    : in FLTK.Images.Image'Class;
            Symbols    : in Boolean := True) is
    begin
        fl_draw_draw_text2
           (Interfaces.C.To_C (Text),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.Unsigned_16 (Align),
            Wrapper (Picture).Void_Ptr,
            Boolean'Pos (Symbols));
    end Draw_Text;


    Text_Func_Ptr : Text_Draw_Function;

    procedure Draw_Text_Hook
           (Ptr       : in Storage.Integer_Address;
            N, X0, Y0 : in Interfaces.C.int);

    pragma Convention (C, Draw_Text_Hook);

    procedure Draw_Text_Hook
           (Ptr       : in Storage.Integer_Address;
            N, X0, Y0 : in Interfaces.C.int)
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Data : String (1 .. Integer (N));
        for Data'Address use Storage.To_Address (Ptr);
        pragma Import (Ada, Data);
    begin
        Text_Func_Ptr (Integer (X0), Integer (Y0), Data);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Draw_Text_Hook;

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Callback   : in Text_Draw_Function;
            Symbols    : in Boolean := True) is
    begin
        Text_Func_Ptr := Callback;
        fl_draw_draw_text3
           (Interfaces.C.To_C (Text),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.Unsigned_16 (Align),
            Storage.To_Integer (Draw_Text_Hook'Address),
            Null_Pointer,
            Boolean'Pos (Symbols));
        Hook_Exceptions.Reraise;
    end Draw_Text;


    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Callback   : in Text_Draw_Function;
            Picture    : in FLTK.Images.Image'Class;
            Symbols    : in Boolean := True) is
    begin
        Text_Func_Ptr := Callback;
        fl_draw_draw_text3
           (Interfaces.C.To_C (Text),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.Unsigned_16 (Align),
            Storage.To_Integer (Draw_Text_Hook'Address),
            Wrapper (Picture).Void_Ptr,
            Boolean'Pos (Symbols));
        Hook_Exceptions.Reraise;
    end Draw_Text;


    procedure Draw_Text
           (X, Y  : in Integer;
            Text  : in String;
            Angle : in Integer) is
    begin
        fl_draw_draw_text4
           (Interfaces.C.int (Angle),
            Interfaces.C.To_C (Text),
            Text'Length,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw_Text;


    procedure Draw_Text_Right_Left
           (X, Y : in Integer;
            Text : in String) is
    begin
        fl_draw_rtl_draw
           (Interfaces.C.To_C (Text),
            Text'Length,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw_Text_Right_Left;


    procedure Draw_Box
           (X, Y, W, H : in Integer;
            Kind       : in Box_Kind;
            Hue        : in Color) is
    begin
        fl_draw_draw_box
           (Box_Kind'Pos (Kind),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Hue));
    end Draw_Box;


    procedure Draw_Box_Focus
           (X, Y, W, H : in Integer;
            Kind       : in Box_Kind;
            Fore, Back : in Color) is
    begin
        fl_draw_draw_box_focus
           (Box_Kind'Pos (Kind),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Fore),
            Interfaces.C.unsigned (Back));
    end Draw_Box_Focus;


    procedure Draw_Check
           (X, Y, W, H : in Integer;
            Hue        : in Color) is
    begin
        fl_draw_draw_check
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Hue));
    end Draw_Check;


    procedure Draw_Radio
           (X, Y, D : in Integer;
            Hue     : in Color) is
    begin
        fl_draw_draw_radio
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (D),
            Interfaces.C.unsigned (Hue));
    end Draw_Radio;


    procedure Draw_Arrow
           (X, Y, W, H : in Integer;
            Kind       : in Arrow_Kind;
            Direction  : in Orientation_Kind;
            Hue        : in Color) is
    begin
        --  FL_ARROW_SINGLE is 1.
        fl_draw_draw_arrow
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Arrow_Kind'Pos (Kind) + 1,
            Orientation_Kind'Pos (Direction),
            Interfaces.C.unsigned (Hue));
    end Draw_Arrow;


    procedure Draw_Symbol
           (X, Y, W, H : in Integer;
            Name       : in String;
            Hue        : in Color)
    is
        Ret_Val : constant Interfaces.C.int := fl_draw_draw_symbol
           (Interfaces.C.To_C (Name),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Hue));
    begin
        if Ret_Val = 0 then
            raise Draw_Error;
        else
            pragma Assert (Ret_Val = 1);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "fl_draw_symbol returned unexpected int value of " &
        Interfaces.C.int'Image (Ret_Val);
    end Draw_Symbol;


    procedure Measure
           (Text    : in     String;
            W, H    :    out Natural;
            Symbols : in     Boolean := True;
            Wrap    : in     Natural := 0)
    is
        Result_W : Interfaces.C.int := Interfaces.C.int (Wrap);
        Result_H : Interfaces.C.int := 0;
    begin
        fl_draw_measure
           (Interfaces.C.To_C (Text),
            Result_W, Result_H,
            Boolean'Pos (Symbols));
        W := Natural (Result_W);
        H := Natural (Result_H);
    end Measure;


    procedure Scroll_Hook
           (Ptr        : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);

    pragma Convention (C, Scroll_Hook);

    procedure Scroll_Hook
           (Ptr        : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int)
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        procedure my_area_draw
               (X, Y, W, H : in Integer);
        for my_area_draw'Address use Storage.To_Address (Ptr);
        pragma Import (Ada, my_area_draw);
    begin
        my_area_draw (Integer (X), Integer (Y), Integer (W), Integer (H));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Scroll_Hook;

    procedure Scroll
           (X, Y, W, H : in Integer;
            DX, DY     : in Integer;
            Callback   : in Area_Draw_Function)
    is
        Done : Interfaces.C.int;
    begin
        Done := fl_draw_scroll
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (DX),
            Interfaces.C.int (DY),
            Storage.To_Integer (Scroll_Hook'Address),
            Storage.To_Integer (Callback.all'Address));
        Hook_Exceptions.Reraise;
        if Done = 0 then
            raise Program_Error with "Scroll needs a surface, or a shown window to be current";
        end if;
    end Scroll;


    procedure Text_Extents
           (Text         : in     String;
            DX, DY, W, H :    out Integer)
    is
        Result_DX, Result_DY, Result_W, Result_H : Interfaces.C.int;
    begin
        fl_draw_text_extents
           (Interfaces.C.To_C (Text),
            Text'Length,
            Result_DX,
            Result_DY,
            Result_W,
            Result_H);
        DX := Integer (Result_DX);
        DY := Integer (Result_DY);
        W := Integer (Result_W);
        H := Integer (Result_H);
    end Text_Extents;


    function Expand_Text
           (Text      : in     String;
            Max_Width : in     Long_Float;
            Width     :    out Long_Float;
            Last      :    out Natural;
            Wrap      : in     Boolean;
            Symbols   : in     Boolean := False)
        return String
    is
        --  fl_expand_text writes up to 8 bytes for a character (a tab) and
        --  stops 4 short of the end (fl_draw.cxx:76, 133-145).
        Size   : constant Interfaces.C.size_t := 8 * Interfaces.C.size_t (Text'Length) + 16;
        Buffer : Interfaces.C.char_array (0 .. Size - 1);
        Length : Interfaces.C.int;
        Temp   : aliased Interfaces.C.char_array := Interfaces.C.To_C (Text);
        Result : constant Char_Pointers.Pointer := fl_draw_expand_text
           (Temp, Buffer, Interfaces.C.int (Size),
            Interfaces.C.double (Max_Width),
            Length,
            Interfaces.C.double (Width),
            Boolean'Pos (Wrap),
            Boolean'Pos (Symbols));
        use type Char_Pointers.Pointer;
    begin
        Last := Text'First - 1 + Natural (Result - Temp (Temp'First)'Unchecked_Access);
        if Length = 0 then
            return "";
        end if;
        return Interfaces.C.To_Ada
           (Buffer (0 .. Interfaces.C.size_t (Length) - 1), Trim_Nul => False);
    end Expand_Text;


    function Width
           (Text : in String)
        return Long_Float is
    begin
        return Long_Float (fl_draw_width (Interfaces.C.To_C (Text), Text'Length));
    end Width;


    function Width
           (Glyph : in Character)
        return Long_Float is
    begin
        return Long_Float (fl_draw_width2 (Character'Pos (Glyph)));
    end Width;


    function Width
           (Glyph : in Wide_Character)
        return Long_Float is
    begin
        return Long_Float (fl_draw_width2 (Wide_Character'Pos (Glyph)));
    end Width;


    function Width
           (Glyph : in Wide_Wide_Character)
        return Long_Float is
    begin
        return Long_Float (fl_draw_width2 (Wide_Wide_Character'Pos (Glyph)));
    end Width;




    --  Manual Drawing  --

    procedure Arc
           (X, Y, R, Start, Finish : in Long_Float) is
    begin
        fl_draw_arc
           (Interfaces.C.double (X),
            Interfaces.C.double (Y),
            Interfaces.C.double (R),
            Interfaces.C.double (Start),
            Interfaces.C.double (Finish));
    end Arc;


    procedure Arc
           (X, Y, W, H    : in Integer;
            Start, Finish : in Long_Float) is
    begin
        fl_draw_arc2
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.double (Start),
            Interfaces.C.double (Finish));
    end Arc;


    procedure Chord
           (X, Y, W, H     : in Integer;
            Angle1, Angle2 : in Long_Float) is
    begin
        null;
        --  this function does not yet exist
        --  fl_draw_chord
        --     (Interfaces.C.int (X),
        --      Interfaces.C.int (Y),
        --      Interfaces.C.int (W),
        --      Interfaces.C.int (H),
        --      Interfaces.C.double (Angle1),
        --      Interfaces.C.double (Angle2));
    end Chord;


    procedure Circle
           (X, Y, R : in Long_Float) is
    begin
        fl_draw_circle
           (Interfaces.C.double (X),
            Interfaces.C.double (Y),
            Interfaces.C.double (R));
    end Circle;


    procedure Curve
           (X0, Y0 : in Long_Float;
            X1, Y1 : in Long_Float;
            X2, Y2 : in Long_Float;
            X3, Y3 : in Long_Float) is
    begin
        fl_draw_curve
           (Interfaces.C.double (X0), Interfaces.C.double (Y0),
            Interfaces.C.double (X1), Interfaces.C.double (Y1),
            Interfaces.C.double (X2), Interfaces.C.double (Y2),
            Interfaces.C.double (X3), Interfaces.C.double (Y3));
    end Curve;


    procedure Frame
           (X, Y, W, H               : in Integer;
            Top, Left, Bottom, Right : in Greyscale) is
    begin
        fl_draw_frame
           (Interfaces.C.To_C
               (Character (Top) & Character (Left) & Character (Bottom) & Character (Right)),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Frame;


    procedure Frame2
           (X, Y, W, H               : in Integer;
            Bottom, Right, Top, Left : in Greyscale) is
    begin
        fl_draw_frame2
           (Interfaces.C.To_C
               (Character (Bottom) & Character (Right) & Character (Top) & Character (Left)),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Frame2;


    procedure Focus_Rect
           (X, Y, W, H : in Integer) is
    begin
        fl_draw_focus_rect
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Focus_Rect;


    procedure Rounded_Rect
           (X, Y, W, H, R : in Integer) is
    begin
        fl_draw_rounded_rect
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (R));
    end Rounded_Rect;


    procedure Rounded_Rect_Fill
           (X, Y, W, H, R : in Integer) is
    begin
        fl_draw_rounded_rectf
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (R));
    end Rounded_Rect_Fill;


    procedure Line
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer) is
    begin
        fl_draw_line
           (Interfaces.C.int (X0), Interfaces.C.int (Y0),
            Interfaces.C.int (X1), Interfaces.C.int (Y1));
    end Line;


    procedure Line
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer) is
    begin
        fl_draw_line2
           (Interfaces.C.int (X0), Interfaces.C.int (Y0),
            Interfaces.C.int (X1), Interfaces.C.int (Y1),
            Interfaces.C.int (X2), Interfaces.C.int (Y2));
    end Line;


    procedure Outline
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer) is
    begin
        fl_draw_loop
           (Interfaces.C.int (X0), Interfaces.C.int (Y0),
            Interfaces.C.int (X1), Interfaces.C.int (Y1),
            Interfaces.C.int (X2), Interfaces.C.int (Y2));
    end Outline;


    procedure Outline
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer;
            X3, Y3 : in Integer) is
    begin
        fl_draw_loop2
           (Interfaces.C.int (X0), Interfaces.C.int (Y0),
            Interfaces.C.int (X1), Interfaces.C.int (Y1),
            Interfaces.C.int (X2), Interfaces.C.int (Y2),
            Interfaces.C.int (X3), Interfaces.C.int (Y3));
    end Outline;


    procedure Pie
           (X, Y, W, H     : in Integer;
            Angle1, Angle2 : in Long_Float) is
    begin
        fl_draw_pie
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.double (Angle1),
            Interfaces.C.double (Angle2));
    end Pie;


    procedure Point
           (X, Y : in Integer) is
    begin
        fl_draw_point
           (Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Point;


    procedure Polygon
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer) is
    begin
        fl_draw_polygon
           (Interfaces.C.int (X0), Interfaces.C.int (Y0),
            Interfaces.C.int (X1), Interfaces.C.int (Y1),
            Interfaces.C.int (X2), Interfaces.C.int (Y2));
    end Polygon;


    procedure Polygon
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer;
            X3, Y3 : in Integer) is
    begin
        fl_draw_polygon2
           (Interfaces.C.int (X0), Interfaces.C.int (Y0),
            Interfaces.C.int (X1), Interfaces.C.int (Y1),
            Interfaces.C.int (X2), Interfaces.C.int (Y2),
            Interfaces.C.int (X3), Interfaces.C.int (Y3));
    end Polygon;


    procedure Rect
           (X, Y, W, H : in Integer) is
    begin
        fl_draw_rect
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Rect;


    procedure Rect
           (X, Y, W, H : in Integer;
            Hue        : in Color) is
    begin
        fl_draw_rect2
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Hue));
    end Rect;


    procedure Rect_Fill
           (X, Y, W, H : in Integer) is
    begin
        fl_draw_rect_fill
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Rect_Fill;


    procedure Rect_Fill
           (X, Y, W, H : in Integer;
            Hue        : in Color) is
    begin
        fl_draw_rect_fill2
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned (Hue));
    end Rect_Fill;


    procedure Rect_Fill
           (X, Y, W, H : in Integer;
            R, G, B    : in Color_Component) is
    begin
        fl_draw_rect_fill3
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Rect_Fill;


    procedure Ecks_Why_Line
           (X0, Y0, X1 : in Integer) is
    begin
        fl_draw_xy_line
           (Interfaces.C.int (X0),
            Interfaces.C.int (Y0),
            Interfaces.C.int (X1));
    end Ecks_Why_Line;


    procedure Ecks_Why_Line
           (X0, Y0, X1, Y2 : in Integer) is
    begin
        fl_draw_xy_line2
           (Interfaces.C.int (X0),
            Interfaces.C.int (Y0),
            Interfaces.C.int (X1),
            Interfaces.C.int (Y2));
    end Ecks_Why_Line;


    procedure Ecks_Why_Line
           (X0, Y0, X1, Y2, X3 : in Integer) is
    begin
        fl_draw_xy_line3
           (Interfaces.C.int (X0),
            Interfaces.C.int (Y0),
            Interfaces.C.int (X1),
            Interfaces.C.int (Y2),
            Interfaces.C.int (X3));
    end Ecks_Why_Line;


    procedure Why_Ecks_Line
           (X0, Y0, Y1 : in Integer) is
    begin
        fl_draw_yx_line
           (Interfaces.C.int (X0),
            Interfaces.C.int (Y0),
            Interfaces.C.int (Y1));
    end Why_Ecks_Line;


    procedure Why_Ecks_Line
           (X0, Y0, Y1, X2 : in Integer) is
    begin
        fl_draw_yx_line2
           (Interfaces.C.int (X0),
            Interfaces.C.int (Y0),
            Interfaces.C.int (Y1),
            Interfaces.C.int (X2));
    end Why_Ecks_Line;


    procedure Why_Ecks_Line
           (X0, Y0, Y1, X2, Y3 : in Integer) is
    begin
        fl_draw_yx_line3
           (Interfaces.C.int (X0),
            Interfaces.C.int (Y0),
            Interfaces.C.int (Y1),
            Interfaces.C.int (X2),
            Interfaces.C.int (Y3));
    end Why_Ecks_Line;


end FLTK.Draw;


