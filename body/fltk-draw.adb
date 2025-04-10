

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Unchecked_Deallocation,
    FLTK.Pixmap_Marshal,
    Interfaces.C.Pointers,
    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Draw is


    package Chk renames Ada.Assertions;

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

    function fl_draw_latin1_to_local
           (T : in Interfaces.C.char_array;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_draw_latin1_to_local, "fl_draw_latin1_to_local");
    pragma Inline (fl_draw_latin1_to_local);

    function fl_draw_local_to_latin1
           (T : in Interfaces.C.char_array;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_draw_local_to_latin1, "fl_draw_local_to_latin1");
    pragma Inline (fl_draw_local_to_latin1);

    function fl_draw_mac_roman_to_local
           (T : in Interfaces.C.char_array;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_draw_mac_roman_to_local, "fl_draw_mac_roman_to_local");
    pragma Inline (fl_draw_mac_roman_to_local);

    function fl_draw_local_to_mac_roman
           (T : in Interfaces.C.char_array;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_draw_local_to_mac_roman, "fl_draw_local_to_mac_roman");
    pragma Inline (fl_draw_local_to_mac_roman);




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




    --  Overlay  --

    procedure fl_draw_overlay_rect
           (X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_draw_overlay_rect, "fl_draw_overlay_rect");
    pragma Inline (fl_draw_overlay_rect);




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

    procedure fl_draw_mult_matrix
           (A, B, C, D, X, Y : in Interfaces.C.double);
    pragma Import (C, fl_draw_mult_matrix, "fl_draw_mult_matrix");
    pragma Inline (fl_draw_mult_matrix);

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

    procedure fl_draw_scroll
           (X, Y, W, H : in Interfaces.C.int;
            DX, DY     : in Interfaces.C.int;
            Func, Data : in Storage.Integer_Address);
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
            Buf       :    out Interfaces.C.Strings.chars_ptr;
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
           (Font_Kind'Pos (Font),
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
           (Font_Kind'Pos (Font),
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

    function Latin1_To_Local
           (From : in String)
        return String is
    begin
        return Interfaces.C.Strings.Value
            (fl_draw_latin1_to_local (Interfaces.C.To_C (From), -1));
    end Latin1_To_Local;


    function Local_To_Latin1
           (From : in String)
        return String is
    begin
        return Interfaces.C.Strings.Value
            (fl_draw_local_to_latin1 (Interfaces.C.To_C (From), -1));
    end Local_To_Latin1;


    function Mac_Roman_To_Local
           (From : in String)
        return String is
    begin
        return Interfaces.C.Strings.Value
            (fl_draw_mac_roman_to_local (Interfaces.C.To_C (From), -1));
    end Mac_Roman_To_Local;


    function Local_To_Mac_Roman
           (From : in String)
        return String is
    begin
        return Interfaces.C.Strings.Value
            (fl_draw_local_to_mac_roman (Interfaces.C.To_C (From), -1));
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
    end Push_Clip;




    --  Overlay  --

    procedure Overlay_Rect
           (X, Y, W, H : in Integer) is
    begin
        fl_draw_overlay_rect
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
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
        return Font_Kind'Val (fl_draw_get_font);
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
        fl_draw_set_font (Font_Kind'Pos (Kind), Interfaces.C.int (Size));
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
        return Natural (fl_draw_height2 (Font_Kind'Pos (Kind), Interfaces.C.int (Size)));
    end Font_Height;


    type Char_Array_Access is access Interfaces.C.char_array;

    procedure Free_Char_Array is new Ada.Unchecked_Deallocation
       (Object => Interfaces.C.char_array,
        Name   => Char_Array_Access);

    Current_Dashes : Char_Array_Access;

    procedure Set_Line_Style
           (Line   : in Line_Kind      := Solid_Line;
            Cap    : in Cap_Kind       := Default_Cap;
            Join   : in Join_Kind      := Default_Join;
            Width  : in Natural        := 0;
            Dashes : in Dash_Gap_Array := Empty_Dashes) is
    begin
        Free_Char_Array (Current_Dashes);
        Current_Dashes := new Interfaces.C.char_array (1 .. (Dashes'Length + 1) * 2);
        for Index in Integer range 1 .. Dashes'Length loop
            Current_Dashes (2 * Interfaces.C.size_t (Index) - 1) :=
                Interfaces.C.char'Val (Integer (Dashes (Index).Solid));
            Current_Dashes (2 * Interfaces.C.size_t (Index)) :=
                Interfaces.C.char'Val (Integer (Dashes (Index).Blank));
        end loop;
        Current_Dashes (Current_Dashes'Last - 1) := Interfaces.C.char'Val (0);
        Current_Dashes (Current_Dashes'Last) := Interfaces.C.char'Val (0);
        fl_draw_line_style
           (Line_Kind'Pos (Line) + Cap_Kind'Pos (Cap) * 16#100# + Join_Kind'Pos (Join) * 16#1000#,
            Interfaces.C.int (Width),
            Current_Dashes.all);
    end Set_Line_Style;




    --  Matrix Operations  --

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

    procedure Draw_Image
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 3;
            Line_Data       : in Natural := 0;
            Flip_Horizontal : in Boolean := False;
            Flip_Vertical   : in Boolean := False)
    is
        Real_Depth : Integer := Depth;
        Real_Line_Data : Integer := Line_Data;
    begin
        if Flip_Horizontal then
            Real_Depth := Real_Depth * (-1);
        end if;
        if Flip_Vertical then
            if Real_Line_Data = 0 then
                Real_Line_Data := W * Depth * (-1);
            else
                Real_Line_Data := Real_Line_Data * (-1);
            end if;
        end if;
        fl_draw_draw_image
           ((if Data'Length > 0
             then Storage.To_Integer (Data (Data'First)'Address)
             else Null_Pointer),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Real_Depth),
            Interfaces.C.int (Real_Line_Data));
    end Draw_Image;


    Image_Func_Ptr : Image_Draw_Function;

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
        Data_Buffer : Color_Component_Array (1 .. Integer (W));
        for Data_Buffer'Address use Storage.To_Address (Buf_Ptr);
        pragma Import (Ada, Data_Buffer);
    begin
        Image_Func_Ptr (Integer (X), Integer (Y), Data_Buffer);
    end Draw_Image_Hook;

    procedure Draw_Image
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 3) is
    begin
        Image_Func_Ptr := Callback;
        fl_draw_draw_image2
           (Storage.To_Integer (Draw_Image_Hook'Address),
            Null_Pointer,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Depth));
    end Draw_Image;


    procedure Draw_Image_Mono
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 1;
            Line_Data       : in Natural := 0;
            Flip_Horizontal : Boolean := False;
            Flip_Vertical   : Boolean := False)
    is
        Real_Depth : Integer := Depth;
        Real_Line_Data : Integer := Line_Data;
    begin
        if Flip_Horizontal then
            Real_Depth := Real_Depth * (-1);
        end if;
        if Flip_Vertical then
            if Real_Line_Data = 0 then
                Real_Line_Data := W * Depth * (-1);
            else
                Real_Line_Data := Real_Line_Data * (-1);
            end if;
        end if;
        fl_draw_draw_image_mono
           ((if Data'Length > 0
             then Storage.To_Integer (Data (Data'First)'Address)
             else Null_Pointer),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Real_Depth),
            Interfaces.C.int (Real_Line_Data));
    end Draw_Image_Mono;


    Mono_Image_Func_Ptr : Image_Draw_Function;

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
        Data_Buffer : Color_Component_Array (1 .. Integer (W));
        for Data_Buffer'Address use Storage.To_Address (Buf_Ptr);
        pragma Import (Ada, Data_Buffer);
    begin
        Mono_Image_Func_Ptr (Integer (X), Integer (Y), Data_Buffer);
    end Draw_Image_Mono_Hook;

    procedure Draw_Image_Mono
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 1) is
    begin
        Mono_Image_Func_Ptr := Callback;
        fl_draw_draw_image_mono2
           (Storage.To_Integer (Draw_Image_Mono_Hook'Address),
            Null_Pointer,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Depth));
    end Draw_Image_Mono;


    procedure Draw_Pixmap
           (Values : in FLTK.Images.Pixmaps.Header;
            Colors : in FLTK.Images.Pixmaps.Color_Definition_Array;
            Pixels : in FLTK.Images.Pixmaps.Pixmap_Data;
            X, Y   : in Integer;
            Hue    : in Color := Grey0_Color)
    is
        C_Data : Pixmap_Marshal.chars_ptr_array_access :=
            Pixmap_Marshal.Marshal_Data (Values, Colors, Pixels);
        Result : constant Interfaces.C.int := fl_draw_draw_pixmap
           (Storage.To_Integer (C_Data (C_Data'First)'Address),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.unsigned (Hue));
    begin
        pragma Assert (Result /= 0);
        Pixmap_Marshal.Free_Recursive (C_Data);
    exception
    when Chk.Assertion_Error =>
        Pixmap_Marshal.Free_Recursive (C_Data);
        raise Draw_Error with "fl_draw_pixmap could not decode supplied XPM pixmap data";
    end Draw_Pixmap;


    function Read_Image
           (X, Y, W, H : in Integer;
            Alpha      : in Integer := 0)
        return Color_Component_Array
    is
        My_Len : constant Integer := (if Alpha = 0 then W * H * 3 else W * H * 4);
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
        pragma Assert
           ((if Result'Length > 0
             then Buffer = Storage.To_Integer (Result (Result'First)'Address)
             else Buffer = Null_Pointer));
        return Result;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "fl_read_image returned unexpected address value that did not " &
        "correspond to supplied address value";
    end Read_Image;




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
        Data : String (1 .. Integer (N));
        for Data'Address use Storage.To_Address (Ptr);
        pragma Import (Ada, Data);
    begin
        Text_Func_Ptr (Integer (X0), Integer (Y0), Data);
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
        procedure my_area_draw
               (X, Y, W, H : in Integer);
        for my_area_draw'Address use Storage.To_Address (Ptr);
        pragma Import (Ada, my_area_draw);
    begin
        my_area_draw (Integer (X), Integer (Y), Integer (W), Integer (H));
    end Scroll_Hook;

    procedure Scroll
           (X, Y, W, H : in Integer;
            DX, DY     : in Integer;
            Callback   : in Area_Draw_Function) is
    begin
        fl_draw_scroll
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (DX),
            Interfaces.C.int (DY),
            Storage.To_Integer (Scroll_Hook'Address),
            Storage.To_Integer (Callback.all'Address));
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
        Buffer : Interfaces.C.Strings.chars_ptr;
        Length : Interfaces.C.int;
        Temp   : Interfaces.C.char_array := Interfaces.C.To_C (Text);
        Result : constant Char_Pointers.Pointer := fl_draw_expand_text
           (Temp, Buffer, 0,
            Interfaces.C.double (Max_Width),
            Length,
            Interfaces.C.double (Width),
            Boolean'Pos (Wrap),
            Boolean'Pos (Symbols));
        use type Char_Pointers.Pointer;
    begin
        Last := Natural (Result - Temp (Temp'First)'Unchecked_Access);
        return Interfaces.C.Strings.Value (Buffer, Interfaces.C.size_t (Length));
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


