

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Command_Line,
    Ada.Containers.Vectors,
    FLTK.Box_Draw_Marshal,
    FLTK.Hook_Exceptions,
    FLTK.Label_Draw_Marshal,
    Interfaces.C.Strings,
    System.Address_To_Access_Conversions,
    FLTK.Static_Callback_Conversions;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Static is


    package Chk  renames Ada.Assertions;
    package Conv renames FLTK.Static_Callback_Conversions;




    -----------------
    --  Operators  --
    -----------------

    type File_Mode_Bitmask is mod 2 ** Interfaces.C.int'Size;

    function FMode_To_Bits is new
        Ada.Unchecked_Conversion (File_Mode, File_Mode_Bitmask);

    function Bits_To_FMode is new
        Ada.Unchecked_Conversion (File_Mode_Bitmask, File_Mode);


    function "+"
           (Left, Right : in File_Mode)
        return File_Mode is
    begin
        return Bits_To_FMode (FMode_To_Bits (Left) or FMode_To_Bits (Right));
    end "+";


    function "-"
           (Left, Right : in File_Mode)
        return File_Mode is
    begin
        return Bits_To_FMode (FMode_To_Bits (Left) and not FMode_To_Bits (Right));
    end "-";




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Display  --

    function fl_static_display_platform
        return Interfaces.C.int;
    pragma Import (C, fl_static_display_platform, "fl_static_display_platform");
    pragma Inline (fl_static_display_platform);




    --  Command Line Arguments  --

    function fl_static_arg
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_arg, "fl_static_arg");
    pragma Inline (fl_static_arg);

    procedure fl_static_args
           (C : in Interfaces.C.int;
            V : in Storage.Integer_Address);
    pragma Import (C, fl_static_args, "fl_static_args");
    pragma Inline (fl_static_args);

    function fl_static_args2
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int;
            H : in     Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_args2, "fl_static_args2");
    pragma Inline (fl_static_args2);




    --  Thread Notify  --

    function fl_static_add_awake_handler
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_add_awake_handler, "fl_static_add_awake_handler");
    pragma Inline (fl_static_add_awake_handler);

    function fl_static_get_awake_handler
           (H, F : out Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_awake_handler, "fl_static_get_awake_handler");
    pragma Inline (fl_static_get_awake_handler);

    function fl_static_awake2
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_awake2, "fl_static_awake2");
    pragma Inline (fl_static_awake2);

    procedure fl_static_awake
           (M : in Storage.Integer_Address);
    pragma Import (C, fl_static_awake, "fl_static_awake");
    pragma Inline (fl_static_awake);




    --  Pre-Eventloop Callbacks  --

    procedure fl_static_add_check
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_check, "fl_static_add_check");
    pragma Inline (fl_static_add_check);

    function fl_static_has_check
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_has_check, "fl_static_has_check");
    pragma Inline (fl_static_has_check);

    procedure fl_static_remove_check
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_check, "fl_static_remove_check");
    pragma Inline (fl_static_remove_check);




    --  Timer Callbacks  --

    procedure fl_static_add_timeout
           (S    : in Interfaces.C.double;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_timeout, "fl_static_add_timeout");
    pragma Inline (fl_static_add_timeout);

    function fl_static_has_timeout
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_has_timeout, "fl_static_has_timeout");
    pragma Inline (fl_static_has_timeout);

    procedure fl_static_remove_timeout
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_timeout, "fl_static_remove_timeout");
    pragma Inline (fl_static_remove_timeout);

    procedure fl_static_repeat_timeout
           (S    : in Interfaces.C.double;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_repeat_timeout, "fl_static_repeat_timeout");
    pragma Inline (fl_static_repeat_timeout);




    --  Clipboard Callbacks  --

    procedure fl_static_add_clipboard_notify
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_clipboard_notify, "fl_static_add_clipboard_notify");
    pragma Inline (fl_static_add_clipboard_notify);

    procedure fl_static_remove_clipboard_notify
           (H : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_clipboard_notify, "fl_static_remove_clipboard_notify");
    pragma Inline (fl_static_remove_clipboard_notify);




    --  File Descriptor Waiting Callbacks  --

    procedure fl_static_add_fd
           (D    : in Interfaces.C.int;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_fd, "fl_static_add_fd");
    pragma Inline (fl_static_add_fd);

    procedure fl_static_add_fd2
           (D, M : in Interfaces.C.int;
            H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_fd2, "fl_static_add_fd2");
    pragma Inline (fl_static_add_fd2);

    procedure fl_static_remove_fd
           (D : in Interfaces.C.int);
    pragma Import (C, fl_static_remove_fd, "fl_static_remove_fd");
    pragma Inline (fl_static_remove_fd);

    procedure fl_static_remove_fd2
           (D, M : in Interfaces.C.int);
    pragma Import (C, fl_static_remove_fd2, "fl_static_remove_fd2");
    pragma Inline (fl_static_remove_fd2);




    --  Idle Callbacks  --

    procedure fl_static_add_idle
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_add_idle, "fl_static_add_idle");
    pragma Inline (fl_static_add_idle);

    function fl_static_has_idle
           (H, F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_has_idle, "fl_static_has_idle");
    pragma Inline (fl_static_has_idle);

    procedure fl_static_remove_idle
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_static_remove_idle, "fl_static_remove_idle");
    pragma Inline (fl_static_remove_idle);




    --  Custom Colors  --

    function fl_static_get_color2
           (C : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_static_get_color2, "fl_static_get_color2");
    pragma Inline (fl_static_get_color2);

    procedure fl_static_get_color
           (C       : in     Interfaces.C.unsigned;
            R, G, B :    out Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_get_color, "fl_static_get_color");
    pragma Inline (fl_static_get_color);

    procedure fl_static_set_color2
           (T, F : in Interfaces.C.unsigned);
    pragma Import (C, fl_static_set_color2, "fl_static_set_color2");
    pragma Inline (fl_static_set_color2);

    procedure fl_static_set_color
           (C       : in Interfaces.C.unsigned;
            R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_set_color, "fl_static_set_color");
    pragma Inline (fl_static_set_color);

    procedure fl_static_free_color
           (C : in Interfaces.C.unsigned;
            B : in Interfaces.C.int);
    pragma Import (C, fl_static_free_color, "fl_static_free_color");
    pragma Inline (fl_static_free_color);

    function fl_static_get_box_color
           (T : in Interfaces.C.unsigned)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_static_get_box_color, "fl_static_get_box_color");
    pragma Inline (fl_static_get_box_color);

    procedure fl_static_set_box_color
           (T : in Interfaces.C.unsigned);
    pragma Import (C, fl_static_set_box_color, "fl_static_set_box_color");
    pragma Inline (fl_static_set_box_color);

    procedure fl_static_foreground
           (R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_foreground, "fl_static_foreground");
    pragma Inline (fl_static_foreground);

    procedure fl_static_background
           (R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_background, "fl_static_background");
    pragma Inline (fl_static_background);

    procedure fl_static_background2
           (R, G, B : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_background2, "fl_static_background2");
    pragma Inline (fl_static_background2);

    procedure fl_static_get_color3
           (C          : in     Interfaces.C.unsigned;
            R, G, B, A :    out Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_get_color3, "fl_static_get_color3");
    pragma Inline (fl_static_get_color3);

    procedure fl_static_set_color3
           (C          : in Interfaces.C.unsigned;
            R, G, B, A : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_set_color3, "fl_static_set_color3");
    pragma Inline (fl_static_set_color3);




    --  Custom Fonts  --

    function fl_static_get_font
           (K : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_static_get_font, "fl_static_get_font");
    pragma Inline (fl_static_get_font);

    function fl_static_get_font_name
           (K : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_static_get_font_name, "fl_static_get_font_name");
    pragma Inline (fl_static_get_font_name);

    function fl_static_get_font_attributes
           (K : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_font_attributes, "fl_static_get_font_attributes");
    pragma Inline (fl_static_get_font_attributes);

    function fl_static_font_end
        return Interfaces.C.int;
    pragma Import (C, fl_static_font_end, "fl_static_font_end");
    pragma Inline (fl_static_font_end);

    procedure fl_static_set_font2
           (T : in Interfaces.C.int;
            S : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_static_set_font2, "fl_static_set_font2");
    pragma Inline (fl_static_set_font2);

    function fl_static_get_font_sizes
           (F : in     Interfaces.C.int;
            A :    out Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_font_sizes, "fl_static_get_font_sizes");
    pragma Inline (fl_static_get_font_sizes);

    function fl_static_font_size_array_get
           (A : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_font_size_array_get, "fl_static_font_size_array_get");
    pragma Inline (fl_static_font_size_array_get);

    function fl_static_set_fonts
        return Interfaces.C.int;
    pragma Import (C, fl_static_set_fonts, "fl_static_set_fonts");
    pragma Inline (fl_static_set_fonts);




    --  Box_Kind Attributes  --

    function fl_static_box_dh
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dh, "fl_static_box_dh");
    pragma Inline (fl_static_box_dh);

    function fl_static_box_dw
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dw, "fl_static_box_dw");
    pragma Inline (fl_static_box_dw);

    function fl_static_box_dx
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dx, "fl_static_box_dx");
    pragma Inline (fl_static_box_dx);

    function fl_static_box_dy
           (B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_box_dy, "fl_static_box_dy");
    pragma Inline (fl_static_box_dy);

    function fl_static_get_boxtype
           (T : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_static_get_boxtype, "fl_static_get_boxtype");
    pragma Inline (fl_static_get_boxtype);

    procedure fl_static_set_boxtype
           (T, F : in Interfaces.C.int);
    pragma Import (C, fl_static_set_boxtype, "fl_static_set_boxtype");
    pragma Inline (fl_static_set_boxtype);

    procedure fl_static_set_boxtype2
           (T              : in Interfaces.C.int;
            F              : in Storage.Integer_Address;
            DX, DY, DW, DH : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_static_set_boxtype2, "fl_static_set_boxtype2");
    pragma Inline (fl_static_set_boxtype2);

    function fl_static_draw_box_active
        return Interfaces.C.int;
    pragma Import (C, fl_static_draw_box_active, "fl_static_draw_box_active");
    pragma Inline (fl_static_draw_box_active);




    --  Label_Kind Attributes  --

    procedure fl_static_set_labeltype
           (K    : in Interfaces.C.int;
            D, M : in Storage.Integer_Address);
    pragma Import (C, fl_static_set_labeltype, "fl_static_set_labeltype");
    pragma Inline (fl_static_set_labeltype);




    --  Clipboard / Selection  --

    procedure fl_static_copy
           (T    : in Interfaces.C.char_array;
            L, K : in Interfaces.C.int);
    pragma Import (C, fl_static_copy, "fl_static_copy");
    pragma Inline (fl_static_copy);

    procedure fl_static_paste
           (R : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_static_paste, "fl_static_paste");
    pragma Inline (fl_static_paste);

    procedure fl_static_paste_image
           (R : in Storage.Integer_Address);
    pragma Import (C, fl_static_paste_image, "fl_static_paste_image");
    pragma Inline (fl_static_paste_image);

    procedure fl_static_selection
           (O : in Storage.Integer_Address;
            T : in Interfaces.C.char_array;
            L : in Interfaces.C.int);
    pragma Import (C, fl_static_selection, "fl_static_selection");
    pragma Inline (fl_static_selection);

    function fl_static_clipboard_contains
           (K : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_static_clipboard_contains, "fl_static_clipboard_contains");
    pragma Inline (fl_static_clipboard_contains);




    --  Dragon Drop  --

    function fl_static_dnd
        return Interfaces.C.int;
    pragma Import (C, fl_static_dnd, "fl_static_dnd");
    pragma Inline (fl_static_dnd);

    function fl_static_get_dnd_text_ops
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_dnd_text_ops, "fl_static_get_dnd_text_ops");
    pragma Inline (fl_static_get_dnd_text_ops);

    procedure fl_static_set_dnd_text_ops
           (T : in Interfaces.C.int);
    pragma Import (C, fl_static_set_dnd_text_ops, "fl_static_set_dnd_text_ops");
    pragma Inline (fl_static_set_dnd_text_ops);




    --  Windows  --

    procedure fl_static_default_atclose
           (W, U : in Storage.Integer_Address);
    pragma Import (C, fl_static_default_atclose, "fl_static_default_atclose");
    pragma Inline (fl_static_default_atclose);

    function fl_static_get_first_window
        return Storage.Integer_Address;
    pragma Import (C, fl_static_get_first_window, "fl_static_get_first_window");
    pragma Inline (fl_static_get_first_window);

    procedure fl_static_set_first_window
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_static_set_first_window, "fl_static_set_first_window");
    pragma Inline (fl_static_set_first_window);

    function fl_static_next_window
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_static_next_window, "fl_static_next_window");
    pragma Inline (fl_static_next_window);

    function fl_static_modal
        return Storage.Integer_Address;
    pragma Import (C, fl_static_modal, "fl_static_modal");
    pragma Inline (fl_static_modal);




    --  Queue  --

    function fl_static_readqueue
        return Storage.Integer_Address;
    pragma Import (C, fl_static_readqueue, "fl_static_readqueue");
    pragma Inline (fl_static_readqueue);




    --  Schemes  --

    function fl_static_get_scheme
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_static_get_scheme, "fl_static_get_scheme");
    pragma Inline (fl_static_get_scheme);

    procedure fl_static_set_scheme
           (S : in Interfaces.C.char_array);
    pragma Import (C, fl_static_set_scheme, "fl_static_set_scheme");
    pragma Inline (fl_static_set_scheme);

    procedure fl_static_set_system_scheme;
    pragma Import (C, fl_static_set_system_scheme, "fl_static_set_system_scheme");
    pragma Inline (fl_static_set_system_scheme);

    function fl_static_is_scheme
           (S : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_static_is_scheme, "fl_static_is_scheme");
    pragma Inline (fl_static_is_scheme);




    --  Library Options  --

    function fl_static_get_option
           (O : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_option, "fl_static_get_option");
    pragma Inline (fl_static_get_option);

    procedure fl_static_set_option
           (O, T : in Interfaces.C.int);
    pragma Import (C, fl_static_set_option, "fl_static_set_option");
    pragma Inline (fl_static_set_option);

    function fl_static_get_use_high_res_gl
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_use_high_res_gl, "fl_static_get_use_high_res_gl");
    pragma Inline (fl_static_get_use_high_res_gl);

    procedure fl_static_set_use_high_res_gl
           (V : in Interfaces.C.int);
    pragma Import (C, fl_static_set_use_high_res_gl, "fl_static_set_use_high_res_gl");
    pragma Inline (fl_static_set_use_high_res_gl);




    --  Scrollbars  --

    function fl_static_get_scrollbar_size
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_scrollbar_size, "fl_static_get_scrollbar_size");
    pragma Inline (fl_static_get_scrollbar_size);

    procedure fl_static_set_scrollbar_size
           (S : in Interfaces.C.int);
    pragma Import (C, fl_static_set_scrollbar_size, "fl_static_set_scrollbar_size");
    pragma Inline (fl_static_set_scrollbar_size);




    --  Shutdown  --

    function fl_static_get_program_should_quit
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_program_should_quit, "fl_static_get_program_should_quit");
    pragma Inline (fl_static_get_program_should_quit);

    procedure fl_static_set_program_should_quit
           (Q : in Interfaces.C.int);
    pragma Import (C, fl_static_set_program_should_quit, "fl_static_set_program_should_quit");
    pragma Inline (fl_static_set_program_should_quit);

    procedure fl_static_hide_all_windows;
    pragma Import (C, fl_static_hide_all_windows, "fl_static_hide_all_windows");
    pragma Inline (fl_static_hide_all_windows);

    procedure fl_static_run_checks;
    pragma Import (C, fl_static_run_checks, "fl_static_run_checks");
    pragma Inline (fl_static_run_checks);

    procedure fl_static_run_idle;
    pragma Import (C, fl_static_run_idle, "fl_static_run_idle");
    pragma Inline (fl_static_run_idle);

    procedure fl_static_set_atclose
           (H : in Storage.Integer_Address);
    pragma Import (C, fl_static_set_atclose, "fl_static_set_atclose");
    pragma Inline (fl_static_set_atclose);




    --  Timestamps  --

    procedure fl_static_now
           (O : in     Interfaces.C.double;
            S :    out Interfaces.C.long_long;
            U :    out Interfaces.C.int);
    pragma Import (C, fl_static_now, "fl_static_now");
    pragma Inline (fl_static_now);

    function fl_static_seconds_between
           (S1 : in Interfaces.C.long_long;
            U1 : in Interfaces.C.int;
            S2 : in Interfaces.C.long_long;
            U2 : in Interfaces.C.int)
        return Interfaces.C.double;
    pragma Import (C, fl_static_seconds_between, "fl_static_seconds_between");
    pragma Inline (fl_static_seconds_between);

    function fl_static_ticks_between
           (S1 : in Interfaces.C.long_long;
            U1 : in Interfaces.C.int;
            S2 : in Interfaces.C.long_long;
            U2 : in Interfaces.C.int)
        return Interfaces.C.long;
    pragma Import (C, fl_static_ticks_between, "fl_static_ticks_between");
    pragma Inline (fl_static_ticks_between);




    --  Contrast  --

    function fl_static_get_contrast_mode
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_contrast_mode, "fl_static_get_contrast_mode");
    pragma Inline (fl_static_get_contrast_mode);

    procedure fl_static_set_contrast_mode
           (M : in Interfaces.C.int);
    pragma Import (C, fl_static_set_contrast_mode, "fl_static_set_contrast_mode");
    pragma Inline (fl_static_set_contrast_mode);

    function fl_static_get_contrast_level
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_contrast_level, "fl_static_get_contrast_level");
    pragma Inline (fl_static_get_contrast_level);

    procedure fl_static_set_contrast_level
           (L : in Interfaces.C.int);
    pragma Import (C, fl_static_set_contrast_level, "fl_static_set_contrast_level");
    pragma Inline (fl_static_set_contrast_level);

    procedure fl_static_set_contrast_function
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_static_set_contrast_function, "fl_static_set_contrast_function");
    pragma Inline (fl_static_set_contrast_function);

    function fl_static_parse_color
           (N       : in     Interfaces.C.char_array;
            R, G, B :    out Interfaces.C.unsigned_char)
        return Interfaces.C.int;
    pragma Import (C, fl_static_parse_color, "fl_static_parse_color");
    pragma Inline (fl_static_parse_color);




    --  Box and Menu Settings  --

    function fl_static_get_box_border_radius_max
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_box_border_radius_max, "fl_static_get_box_border_radius_max");
    pragma Inline (fl_static_get_box_border_radius_max);

    procedure fl_static_set_box_border_radius_max
           (R : in Interfaces.C.int);
    pragma Import (C, fl_static_set_box_border_radius_max, "fl_static_set_box_border_radius_max");
    pragma Inline (fl_static_set_box_border_radius_max);

    function fl_static_get_box_shadow_width
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_box_shadow_width, "fl_static_get_box_shadow_width");
    pragma Inline (fl_static_get_box_shadow_width);

    procedure fl_static_set_box_shadow_width
           (W : in Interfaces.C.int);
    pragma Import (C, fl_static_set_box_shadow_width, "fl_static_set_box_shadow_width");
    pragma Inline (fl_static_set_box_shadow_width);

    function fl_static_get_menu_linespacing
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_menu_linespacing, "fl_static_get_menu_linespacing");
    pragma Inline (fl_static_get_menu_linespacing);

    procedure fl_static_set_menu_linespacing
           (H : in Interfaces.C.int);
    pragma Import (C, fl_static_set_menu_linespacing, "fl_static_set_menu_linespacing");
    pragma Inline (fl_static_set_menu_linespacing);




    --  Callback Reasons  --

    function fl_static_callback_reason
        return Interfaces.C.int;
    pragma Import (C, fl_static_callback_reason, "fl_static_callback_reason");
    pragma Inline (fl_static_callback_reason);




    --  Selection Owner  --

    function fl_static_get_selection_owner
        return Storage.Integer_Address;
    pragma Import (C, fl_static_get_selection_owner, "fl_static_get_selection_owner");
    pragma Inline (fl_static_get_selection_owner);

    procedure fl_static_set_selection_owner
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_static_set_selection_owner, "fl_static_set_selection_owner");
    pragma Inline (fl_static_set_selection_owner);

    function fl_static_get_selection_to_clipboard
        return Interfaces.C.int;
    pragma Import (C, fl_static_get_selection_to_clipboard, "fl_static_get_selection_to_clipboard");
    pragma Inline (fl_static_get_selection_to_clipboard);

    procedure fl_static_set_selection_to_clipboard
           (M : in Interfaces.C.int);
    pragma Import (C, fl_static_set_selection_to_clipboard, "fl_static_set_selection_to_clipboard");
    pragma Inline (fl_static_set_selection_to_clipboard);




    --  Scheme List  --

    function fl_static_scheme_count
        return Interfaces.C.int;
    pragma Import (C, fl_static_scheme_count, "fl_static_scheme_count");
    pragma Inline (fl_static_scheme_count);

    function fl_static_scheme_name
           (I : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_static_scheme_name, "fl_static_scheme_name");
    pragma Inline (fl_static_scheme_name);

    function fl_static_add_scheme_name
           (N : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_static_add_scheme_name, "fl_static_add_scheme_name");
    pragma Inline (fl_static_add_scheme_name);




    --  User Data  --

    package Widget_Convert is new System.Address_To_Access_Conversions
        (FLTK.Widgets.Widget'Class);
    package Window_Convert is new System.Address_To_Access_Conversions
        (FLTK.Widgets.Groups.Windows.Window'Class);

    function fl_widget_get_user_data
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_get_user_data, "fl_widget_get_user_data");




    ----------------------
    --  Callback Hooks  --
    ----------------------

    Current_Args_Handler : Args_Handler;

    function Args_Hook
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Convention (C, Args_Hook);

    function Args_Hook
           (C : in     Interfaces.C.int;
            V : in     Storage.Integer_Address;
            I : in out Interfaces.C.int)
        return Interfaces.C.int
    is
        Mark   : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Result : Natural;
    begin
        --  Checked here, and not by handlers around the call, so that the
        --  handler's own exceptions aren't taken for FLTK's (FLTKAda-BUGS.md
        --  45).
        if V = Null_Pointer or I >= C then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "Args_Handler callback was supplied irregular argc and argv values of " &
                Interfaces.C.int'Image (C) & " and " & Storage.Integer_Address'Image (V));
            return 0;
        end if;
        if I < 1 then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "Args_Handler callback was supplied unexpected int i value of " &
                Interfaces.C.int'Image (I));
            return 0;
        end if;
        Result := Current_Args_Handler (Positive (I));
        I := I + Interfaces.C.int (Result);
        return Interfaces.C.int (Result);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Args_Hook;


    procedure Awake_Hook
           (U : in Storage.Integer_Address);
    pragma Convention (C, Awake_Hook);

    procedure Awake_Hook
           (U : in Storage.Integer_Address)
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
    begin
        if U /= Null_Pointer then
            Conv.To_Awake_Access (U).all;
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Awake_Hook;


    procedure Timeout_Hook
           (U : in Storage.Integer_Address);
    pragma Convention (C, Timeout_Hook);

    procedure Timeout_Hook
           (U : in Storage.Integer_Address)
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
    begin
        Conv.To_Timeout_Access (U).all;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Timeout_Hook;


    --  This is handled on the Ada side because otherwise there would be
    --  no way to specify which callback to remove in FLTK once one was
    --  added. This is because Fl::remove_clipboard_notify does not pay
    --  attention to the void * data. This hook is passed to FLTK only while
    --  at least one handler is registered, since on X11 without XFixes FLTK
    --  polls the clipboard owner twice a second for as long as any notify
    --  handler exists.
    package Clipboard_Notify_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Clipboard_Notify_Handler);

    Current_Clip_Notes : Clipboard_Notify_Vectors.Vector;

    procedure Clipboard_Notify_Hook
           (S : in Interfaces.C.int;
            U : in Storage.Integer_Address);
    pragma Convention (C, Clipboard_Notify_Hook);

    procedure Clipboard_Notify_Hook
           (S : in Interfaces.C.int;
            U : in Storage.Integer_Address)
    is
        Mark    : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        --  A copy, so that a handler can add or remove handlers.  Those it
        --  removes are still called for this notice, and those it adds
        --  aren't.
        Current : constant Clipboard_Notify_Vectors.Vector := Current_Clip_Notes;
    begin
        --  Checked here, and not by a handler around the calls, so that a
        --  handler's own exceptions aren't taken for FLTK's (FLTKAda-BUGS.md
        --  45).
        if S not in Buffer_Kind'Pos (Buffer_Kind'First) .. Buffer_Kind'Pos (Buffer_Kind'Last) then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "Clipboard_Notify_Hook was passed unexpected Buffer_Kind int value of " &
                Interfaces.C.int'Image (S));
            return;
        end if;
        for Call of Current loop
            Call.all (Buffer_Kind'Val (S));
        end loop;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Clipboard_Notify_Hook;


    procedure FD_Hook
           (FD : in Interfaces.C.int;
            U  : in Storage.Integer_Address);
    pragma Convention (C, FD_Hook);

    procedure FD_Hook
           (FD : in Interfaces.C.int;
            U  : in Storage.Integer_Address)
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
    begin
        Conv.To_File_Access (U).all (File_Descriptor (FD));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end FD_Hook;


    procedure Idle_Hook
           (U : in Storage.Integer_Address);
    pragma Convention (C, Idle_Hook);

    procedure Idle_Hook
           (U : in Storage.Integer_Address)
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
    begin
        Conv.To_Idle_Access (U).all;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Idle_Hook;


    Current_Window_Close : Window_Close_Handler;

    --  Fl::atclose's handler while Current_Window_Close is set.  A window
    --  that isn't FLTKAda's gets FLTK's default.
    procedure Window_Close_Hook
           (W, U : in Storage.Integer_Address);
    pragma Convention (C, Window_Close_Hook);

    procedure Window_Close_Hook
           (W, U : in Storage.Integer_Address)
    is
        Mark    : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Ptr : constant Storage.Integer_Address :=
            (if W = Null_Pointer then Null_Pointer else fl_widget_get_user_data (W));
    begin
        if Ada_Ptr = Null_Pointer or Current_Window_Close = null then
            fl_static_default_atclose (W, U);
        else
            Current_Window_Close (Window_Convert.To_Pointer (Storage.To_Address (Ada_Ptr)).all);
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Window_Close_Hook;


    Current_Contrast : Contrast_Function;

    function Contrast_Hook
           (F, B : in Interfaces.C.unsigned;
            C, S : in Interfaces.C.int)
        return Interfaces.C.unsigned;
    pragma Convention (C, Contrast_Hook);

    function Contrast_Hook
           (F, B : in Interfaces.C.unsigned;
            C, S : in Interfaces.C.int)
        return Interfaces.C.unsigned
    is
        Mark : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
    begin
        return Interfaces.C.unsigned (Current_Contrast
           (Color (F), Color (B), Integer (C), Integer (S)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return F;
    end Contrast_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out FLTK_Static_Final_Controller) is
    begin
        for Override of Font_Overrides loop
            Interfaces.C.Strings.Free (Override);
        end loop;
        if not Current_Clip_Notes.Is_Empty then
            fl_static_remove_clipboard_notify (Storage.To_Integer (Clipboard_Notify_Hook'Address));
        end if;
        if Current_Window_Close /= null then
            fl_static_set_atclose (Null_Pointer);
        end if;
        if Current_Contrast /= null then
            fl_static_set_contrast_function (Null_Pointer);
        end if;
    end Finalize;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Display  --

    function Get_Display_Platform
        return Display_Platform is
    begin
        case fl_static_display_platform is
            when 1 => return X11_Platform;
            when 2 => return Wayland_Platform;
            when others => return Other_Platform;
        end case;
    end Get_Display_Platform;




    --  Command Line Arguments  --

    function Parse_Arg
           (Index : in Positive)
        return Natural
    is
        Count : Interfaces.C.int := Interfaces.C.int (Index);
    begin
        --  Fl::arg reads argv[i] unchecked (Fl_arg.cxx:132).
        if Index > Ada.Command_Line.Argument_Count then
            raise Constraint_Error with
                "Parse_Arg of argument" & Integer'Image (Index) & " of" &
                Integer'Image (Ada.Command_Line.Argument_Count);
        end if;
        return Natural (fl_static_arg
           (FLTK.Args_Marshal.Argc,
            FLTK.Args_Marshal.Argv,
            Count));
    end Parse_Arg;


    procedure Parse_Args is
    begin
        fl_static_args
           (FLTK.Args_Marshal.Argc,
            FLTK.Args_Marshal.Argv);
    end Parse_Args;


    procedure Parse_Args
           (Count :    out Natural;
            Func  : in     Args_Handler := null)
    is
        My_Count : Interfaces.C.int := 1;
        Result   : Interfaces.C.int;
    begin
        Current_Args_Handler := Func;
        Result := fl_static_args2
           (FLTK.Args_Marshal.Argc,
            FLTK.Args_Marshal.Argv,
            My_Count,
            (if Func = null then Null_Pointer else Storage.To_Integer (Args_Hook'Address)));
        Count := Integer (My_Count) - 1;
        if Result = 0 then
            raise Argument_Error with
                "Fl::args could not recognise switch at argument number " &
                Interfaces.C.int'Image (My_Count);
        else
            pragma Assert (Result > 0);
        end if;
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::args produced unexpected i parameter of " & Interfaces.C.int'Image (My_Count);
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl::args returned unexpected int value of " & Interfaces.C.int'Image (Result);
    end Parse_Args;




    --  Thread Notify  --

    procedure Add_Awake_Handler
           (Func : in Awake_Handler)
    is
        Result : constant Interfaces.C.int := fl_static_add_awake_handler
           (Storage.To_Integer (Awake_Hook'Address),
            Conv.To_Address (Func));
    begin
        --  Explicit, not pragma Assert, which a release build doesn't
        --  check (FLTKAda-BUGS.md 28).
        if Result = -1 then
            raise Tasking_Error with
                "Fl::add_awake_handler_ failed to register Awake_Handler callback";
        elsif Result /= 0 then
            raise Internal_FLTK_Error with
                "Fl::add_awake_handler_ returned unexpected int value of " &
                Interfaces.C.int'Image (Result);
        end if;
    end Add_Awake_Handler;


    function Get_Awake_Handler
        return Awake_Handler
    is
        Hook, Func : Storage.Integer_Address;
        Result : constant Interfaces.C.int := fl_static_get_awake_handler (Hook, Func);
    begin
        --  Explicit, so that a release build doesn't return Func unset
        --  (FLTKAda-BUGS.md 28).
        if Result = -1 then
            raise Tasking_Error with
                "Fl::get_awake_handler_ invoked without prior awake setup";
        elsif Result /= 0 then
            raise Internal_FLTK_Error with
                "Fl::get_awake_handler_ returned unexpected int value of " &
                Interfaces.C.int'Image (Result);
        end if;
        return Conv.To_Awake_Access (Func);
    end Get_Awake_Handler;


    procedure Awake
           (Func : in Awake_Handler)
    is
        Result : constant Interfaces.C.int := fl_static_awake2
           (Storage.To_Integer (Awake_Hook'Address),
            Conv.To_Address (Func));
    begin
        --  Explicit, not pragma Assert (FLTKAda-BUGS.md 28).
        if Result = -1 then
            raise Tasking_Error with "Fl::awake failed to register Awake_Handler callback";
        elsif Result /= 0 then
            raise Internal_FLTK_Error with "Fl::awake returned unexpected int value of " &
                Interfaces.C.int'Image (Result);
        end if;
    end Awake;


    procedure Awake is
    begin
        fl_static_awake (Null_Pointer);
    end Awake;




    --  Pre-Eventloop Callbacks  --

    procedure Add_Check
           (Func : in not null Timeout_Handler) is
    begin
        fl_static_add_check
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Add_Check;


    function Has_Check
           (Func : in not null Timeout_Handler)
        return Boolean is
    begin
        return fl_static_has_check
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func))) /= 0;
    end Has_Check;


    procedure Remove_Check
           (Func : in not null Timeout_Handler) is
    begin
        fl_static_remove_check
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Remove_Check;




    --  Timer Callbacks  --

    procedure Add_Timeout
           (Seconds : in          Long_Float;
            Func    : in not null Timeout_Handler) is
    begin
        fl_static_add_timeout
           (Interfaces.C.double (Seconds),
            Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Add_Timeout;


    function Has_Timeout
           (Func : in not null Timeout_Handler)
        return Boolean is
    begin
        return fl_static_has_timeout
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func))) /= 0;
    end Has_Timeout;


    procedure Remove_Timeout
           (Func : in not null Timeout_Handler) is
    begin
        fl_static_remove_timeout
           (Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Remove_Timeout;


    procedure Repeat_Timeout
           (Seconds : in          Long_Float;
            Func    : in not null Timeout_Handler) is
    begin
        fl_static_repeat_timeout
           (Interfaces.C.double (Seconds),
            Storage.To_Integer (Timeout_Hook'Address),
            Conv.To_Address (Timeout_Handler'(Func)));
    end Repeat_Timeout;




    --  Clipboard Callbacks  --

    procedure Add_Clipboard_Notify
           (Func : in not null Clipboard_Notify_Handler) is
    begin
        if Current_Clip_Notes.Is_Empty then
            fl_static_add_clipboard_notify
                (Storage.To_Integer (Clipboard_Notify_Hook'Address), Null_Pointer);
        end if;
        Current_Clip_Notes.Append (Func);
    end Add_Clipboard_Notify;


    procedure Remove_Clipboard_Notify
           (Func : in not null Clipboard_Notify_Handler) is
    begin
        for Index in reverse Current_Clip_Notes.First_Index .. Current_Clip_Notes.Last_Index loop
            if Current_Clip_Notes (Index) = Func then
                Current_Clip_Notes.Delete (Index);
                if Current_Clip_Notes.Is_Empty then
                    fl_static_remove_clipboard_notify
                        (Storage.To_Integer (Clipboard_Notify_Hook'Address));
                end if;
                return;
            end if;
        end loop;
    end Remove_Clipboard_Notify;




    --  File Descriptor Waiting Callbacks  --

    procedure Add_File_Descriptor
           (FD   : in          File_Descriptor;
            Func : in not null File_Handler) is
    begin
        fl_static_add_fd
           (Interfaces.C.int (FD),
            Storage.To_Integer (FD_Hook'Address),
            Conv.To_Address (Func));
    end Add_File_Descriptor;


    procedure Add_File_Descriptor
           (FD   : in          File_Descriptor;
            Mode : in          File_Mode;
            Func : in not null File_Handler) is
    begin
        fl_static_add_fd2
           (Interfaces.C.int (FD),
            FMode_To_Cint (Mode),
            Storage.To_Integer (FD_Hook'Address),
            Conv.To_Address (Func));
    end Add_File_Descriptor;


    procedure Remove_File_Descriptor
           (FD : in File_Descriptor) is
    begin
        fl_static_remove_fd (Interfaces.C.int (FD));
    end Remove_File_Descriptor;


    procedure Remove_File_Descriptor
           (FD   : in File_Descriptor;
            Mode : in File_Mode) is
    begin
        fl_static_remove_fd2 (Interfaces.C.int (FD), FMode_To_Cint (Mode));
    end Remove_File_Descriptor;




    --  Idle Callbacks  --

    procedure Add_Idle
           (Func : in not null Idle_Handler) is
    begin
        fl_static_add_idle
           (Storage.To_Integer (Idle_Hook'Address),
            Conv.To_Address (Idle_Handler'(Func)));
    end Add_Idle;


    function Has_Idle
           (Func : in not null Idle_Handler)
        return Boolean is
    begin
        return fl_static_has_idle
           (Storage.To_Integer (Idle_Hook'Address),
            Conv.To_Address (Idle_Handler'(Func))) /= 0;
    end Has_Idle;


    procedure Remove_Idle
           (Func : in not null Idle_Handler) is
    begin
        fl_static_remove_idle
           (Storage.To_Integer (Idle_Hook'Address),
            Conv.To_Address (Idle_Handler'(Func)));
    end Remove_Idle;




    --  Custom Colors  --

    function Get_Color
           (From : in Color)
        return Color is
    begin
        return Color (fl_static_get_color2 (Interfaces.C.unsigned (From)));
    end Get_Color;


    procedure Get_Color
           (From    : in     Color;
            R, G, B :    out Color_Component) is
    begin
        fl_static_get_color
           (Interfaces.C.unsigned (From),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Get_Color;


    procedure Set_Color
           (Target, Source : in Color) is
    begin
        fl_static_set_color2
           (Interfaces.C.unsigned (Target),
            Interfaces.C.unsigned (Source));
    end Set_Color;


    procedure Set_Color
           (Target  : in Color;
            R, G, B : in Color_Component) is
    begin
        fl_static_set_color
           (Interfaces.C.unsigned (Target),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Color;


    procedure Free_Color
           (Value   : in Color;
            Overlay : in Boolean := False) is
    begin
        fl_static_free_color
           (Interfaces.C.unsigned (Value),
            Boolean'Pos (Overlay));
    end Free_Color;


    function Get_Box_Color
           (Tone : in Color)
        return Color is
    begin
        return Color (fl_static_get_box_color (Interfaces.C.unsigned (Tone)));
    end Get_Box_Color;


    procedure Set_Box_Color
           (Tone : in Color) is
    begin
        fl_static_set_box_color (Interfaces.C.unsigned (Tone));
    end Set_Box_Color;


    procedure Set_Foreground
           (R, G, B : in Color_Component) is
    begin
        fl_static_foreground
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Foreground;


    procedure Set_Background
           (R, G, B : in Color_Component) is
    begin
        fl_static_background
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Background;


    procedure Set_Alt_Background
           (R, G, B : in Color_Component) is
    begin
        fl_static_background2
           (Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B));
    end Set_Alt_Background;


    procedure Get_Color
           (From       : in     Color;
            R, G, B, A :    out Color_Component) is
    begin
        fl_static_get_color3
           (Interfaces.C.unsigned (From),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B),
            Interfaces.C.unsigned_char (A));
    end Get_Color;


    procedure Set_Color
           (Target     : in Color;
            R, G, B, A : in Color_Component) is
    begin
        fl_static_set_color3
           (Interfaces.C.unsigned (Target),
            Interfaces.C.unsigned_char (R),
            Interfaces.C.unsigned_char (G),
            Interfaces.C.unsigned_char (B),
            Interfaces.C.unsigned_char (A));
    end Set_Color;




    --  Custom Fonts  --

    function Last_Font
        return Font_Kind is
    begin
        return Font_Kind (fl_static_font_end - 1);
    end Last_Font;


    function Font_Image
           (Kind : in Font_Kind)
        return String is
    begin
        --  The shim gives "" for an empty slot, never null.
        return Interfaces.C.Strings.Value (fl_static_get_font (To_C (Kind)));
    end Font_Image;


    function Font_Family_Image
           (Kind : in Font_Kind)
        return String is
    begin
        --  The shim gives "" for an empty slot, never null.
        return Interfaces.C.Strings.Value (fl_static_get_font_name (To_C (Kind)));
    end Font_Family_Image;


    function Font_Family_Attributes
           (Kind : in Font_Kind)
        return Font_Attributes
    is
        --  FL_BOLD and FL_ITALIC (Enumerations.H:1083-1084)
        Bits : constant Interfaces.C.int := fl_static_get_font_attributes (To_C (Kind));
    begin
        return (Bold => Bits mod 2 = 1, Italic => Bits / 2 mod 2 = 1);
    end Font_Family_Attributes;


    --  FLTK keeps the name pointer, and compares the next name with it
    --  (Fl_Cairo_Graphics_Driver.cxx:1158), so the old copy is freed only
    --  after FLTK holds the new one.  Copying a kind would share the
    --  source's pointer (fl_set_font.cxx:71), which a later change of the
    --  source frees, so the target gets its own copy of the name instead.

    procedure Set_Font_Kind
           (Target, Source : in Font_Kind) is
    begin
        Set_Font_Kind (Target, Font_Image (Source));
    end Set_Font_Kind;


    --  FLTK copies a name into fontname[128], and keeps its last byte for
    --  the font's type (Fl_Cairo_Graphics_Driver.cxx:1176-1182), so a name
    --  is cut to 126 bytes, before a UTF-8 character that would cross that
    --  (pofltk 130).
    Longest_Font_Name : constant := 126;

    procedure Set_Font_Kind
           (Target : in Font_Kind;
            Source : in String)
    is
        Old  : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.Null_Ptr;
        Name : Interfaces.C.Strings.chars_ptr;
        Last : Natural := Source'Last;
    begin
        if Target > Max_Font then
            raise Constraint_Error with "font" & Font_Kind'Image (Target)
                & " is past Max_Font," & Font_Kind'Image (Max_Font);
        end if;
        if Font_Overrides.Contains (Target) then
            Old := Font_Overrides.Element (Target);
        end if;
        if Source'Length > Longest_Font_Name then
            Last := Source'First + Longest_Font_Name - 1;
            while Last >= Source'First
                and then Character'Pos (Source (Last + 1)) in 16#80# .. 16#BF#
            loop
                Last := Last - 1;
            end loop;
        end if;
        Name := Interfaces.C.Strings.New_String (Source (Source'First .. Last));
        Font_Overrides.Include (Target, Name);
        fl_static_set_font2 (Interfaces.C.int (Target), Name);
        Interfaces.C.Strings.Free (Old);
    end Set_Font_Kind;


    function Font_Sizes
           (Kind : in Font_Kind)
        return Font_Size_Array
    is
        Ptr : Storage.Integer_Address;
        Arr : Font_Size_Array
            (1 .. Integer (fl_static_get_font_sizes (To_C (Kind), Ptr)));
    begin
        --  This array copying avoids any worry that the static buffer will be overwritten.
        for I in 1 .. Arr'Length loop
            Arr (I) := Font_Size (fl_static_font_size_array_get (Ptr, Interfaces.C.int (I)));
        end loop;
        return Arr;
    end Font_Sizes;


    procedure Setup_Fonts
           (How_Many_Set_Up : out Natural)
    is
        Result : constant Interfaces.C.int := fl_static_set_fonts;
    begin
        How_Many_Set_Up := Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::set_fonts returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Setup_Fonts;




    --  Box_Kind Attributes  --

    function Get_Box_Height_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dh (Box_Kind'Pos (Kind)));
    end Get_Box_Height_Offset;


    function Get_Box_Width_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dw (Box_Kind'Pos (Kind)));
    end Get_Box_Width_Offset;


    function Get_Box_X_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dx (Box_Kind'Pos (Kind)));
    end Get_Box_X_Offset;


    function Get_Box_Y_Offset
           (Kind : in Box_Kind)
        return Integer is
    begin
        return Integer (fl_static_box_dy (Box_Kind'Pos (Kind)));
    end Get_Box_Y_Offset;


    procedure Set_Box_Kind
           (To, From : in Box_Kind) is
    begin
        fl_static_set_boxtype (Box_Kind'Pos (To), Box_Kind'Pos (From));
    end Set_Box_Kind;


    function Draw_Box_Active
        return Boolean is
    begin
        return fl_static_draw_box_active /= 0;
    end Draw_Box_Active;


    function Get_Box_Draw_Function
           (Kind : in Box_Kind)
        return Box_Draw_Function is
    begin
        return FLTK.Box_Draw_Marshal.To_Ada (Kind, fl_static_get_boxtype (Box_Kind'Pos (Kind)));
    end Get_Box_Draw_Function;


    procedure Set_Box_Draw_Function
           (Kind               : in Box_Kind;
            Func               : in Box_Draw_Function;
            Offset_X, Offset_Y : in Byte_Integer := 0;
            Offset_W, Offset_H : in Byte_Integer := 0) is
    begin
        fl_static_set_boxtype2
           (Box_Kind'Pos (Kind),
            FLTK.Box_Draw_Marshal.To_C (Kind, Func),
            Interfaces.C.unsigned_char (Offset_X),
            Interfaces.C.unsigned_char (Offset_Y),
            Interfaces.C.unsigned_char (Offset_W),
            Interfaces.C.unsigned_char (Offset_H));
    end Set_Box_Draw_Function;




    --  Label_Kind Attributes  --

    procedure Set_Label_Kind
           (Target, Source : in Label_Kind) is
    begin
        --  As of FLTK 1.3.11 there is no definition given for this function
        --  so this is null to avoid linker errors.
        null;
    end Set_Label_Kind;


    procedure Set_Label_Draw_Function
           (Kind         : in Label_Kind;
            Draw_Func    : in Label_Draw_Function;
            Measure_Func : in Label_Measure_Function) is
    begin
        fl_static_set_labeltype
           (Label_Kind'Pos (Kind),
            FLTK.Label_Draw_Marshal.To_C (Kind, Draw_Func),
            FLTK.Label_Draw_Marshal.To_C (Kind, Measure_Func));
    end Set_Label_Draw_Function;




    --  Clipboard / Selection  --

    procedure Copy
           (Text : in String;
            Dest : in Buffer_Kind) is
    begin
        fl_static_copy
           (Interfaces.C.To_C (Text),
            Text'Length,
            Buffer_Kind'Pos (Dest));
    end Copy;


    procedure Copy_To_Both
           (Text : in String) is
    begin
        fl_static_copy (Interfaces.C.To_C (Text), Text'Length, 2);
    end Copy_To_Both;


    procedure Paste
           (Receiver : in FLTK.Widgets.Widget'Class;
            Source   : in Buffer_Kind) is
    begin
        fl_static_paste
           (Wrapper (Receiver).Void_Ptr,
            Buffer_Kind'Pos (Source));
    end Paste;


    procedure Paste_Image
           (Receiver : in FLTK.Widgets.Widget'Class) is
    begin
        if Wrapper (Receiver).Void_Ptr = Null_Pointer then
            raise Program_Error with "Paste_Image to a widget that doesn't exist";
        end if;
        fl_static_paste_image (Wrapper (Receiver).Void_Ptr);
    end Paste_Image;


    procedure Selection
           (Owner : in FLTK.Widgets.Widget'Class;
            Text  : in String) is
    begin
        fl_static_selection
           (Wrapper (Owner).Void_Ptr,
            Interfaces.C.To_C (Text),
            Text'Length);
    end Selection;


    function Clipboard_Contains
           (Kind : in String)
        return Boolean is
    begin
        return fl_static_clipboard_contains (Interfaces.C.To_C (Kind)) /= 0;
    end Clipboard_Contains;




    --  Dragon Drop  --

    procedure Drag_Drop_Start is
        Ignore : Interfaces.C.int := fl_static_dnd;
    begin
        null;
    end Drag_Drop_Start;


    function Get_Drag_Drop_Text_Support
        return Boolean is
    begin
        return fl_static_get_dnd_text_ops /= 0;
    end Get_Drag_Drop_Text_Support;


    procedure Set_Drag_Drop_Text_Support
           (To : in Boolean) is
    begin
        fl_static_set_dnd_text_ops (Boolean'Pos (To));
    end Set_Drag_Drop_Text_Support;




    --  Windows  --

    procedure Default_Window_Close
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        --  Fl::default_atclose would hide a null widget (FLTKAda-BUGS.md 28).
        if Wrapper (Item).Void_Ptr = Null_Pointer then
            raise Program_Error with
                "Default_Window_Close given a widget with no FLTK object";
        end if;
        fl_static_default_atclose
           (Wrapper (Item).Void_Ptr,
            fl_widget_get_user_data (Wrapper (Item).Void_Ptr));
    end Default_Window_Close;


    function Get_First_Window
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        First_Ptr : Storage.Integer_Address := fl_static_get_first_window;
        Actual_First : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        --  The shim skips the windows FLTK made.
        if First_Ptr /= Null_Pointer then
            First_Ptr := fl_widget_get_user_data (First_Ptr);
            if First_Ptr = Null_Pointer then
                raise Internal_FLTK_Error with
                    "Fl::first_window gave a window with no Ada object";
            end if;
            Actual_First := Window_Convert.To_Pointer (Storage.To_Address (First_Ptr));
        end if;
        return Actual_First;
    end Get_First_Window;


    procedure Set_First_Window
           (To : in FLTK.Widgets.Groups.Windows.Window'Class) is
    begin
        fl_static_set_first_window (Wrapper (To).Void_Ptr);
    end Set_First_Window;


    function Get_Next_Window
           (From : in FLTK.Widgets.Groups.Windows.Window'Class)
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Next_Ptr : Storage.Integer_Address := fl_static_next_window (Wrapper (From).Void_Ptr);
        Actual_Next : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if Next_Ptr /= Null_Pointer then
            Next_Ptr := fl_widget_get_user_data (Next_Ptr);
            if Next_Ptr = Null_Pointer then
                raise Internal_FLTK_Error with
                    "Fl::next_window gave a window with no Ada object";
            end if;
            Actual_Next := Window_Convert.To_Pointer (Storage.To_Address (Next_Ptr));
        end if;
        return Actual_Next;
    end Get_Next_Window;


    function Get_Top_Modal
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Modal_Ptr : Storage.Integer_Address := fl_static_modal;
        Actual_Modal : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        --  A window FLTK made, such as a dialog's, has no Ada object.
        if Modal_Ptr /= Null_Pointer then
            Modal_Ptr := fl_widget_get_user_data (Modal_Ptr);
            if Modal_Ptr /= Null_Pointer then
                Actual_Modal := Window_Convert.To_Pointer (Storage.To_Address (Modal_Ptr));
            end if;
        end if;
        return Actual_Modal;
    end Get_Top_Modal;




    --  Queue  --

    function Read_Queue
        return access FLTK.Widgets.Widget'Class
    is
        Queue_Ptr : Storage.Integer_Address := fl_static_readqueue;
        Actual_Queue : access FLTK.Widgets.Widget'Class;
    begin
        if Queue_Ptr /= Null_Pointer then
            Queue_Ptr := fl_widget_get_user_data (Queue_Ptr);
            pragma Assert (Queue_Ptr /= Null_Pointer);
            Actual_Queue := Widget_Convert.To_Pointer (Storage.To_Address (Queue_Ptr));
        end if;
        return Actual_Queue;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::readqueue did not have user_data reference back to Ada";
    end Read_Queue;




    --  Schemes  --

    function Get_Scheme
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_static_get_scheme;
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Scheme;


    procedure Set_Scheme
           (To : in String) is
    begin
        --  A copy of the Scheme string is stored in FLTK
        fl_static_set_scheme (Interfaces.C.To_C (To));
    end Set_Scheme;


    procedure Set_System_Scheme is
    begin
        fl_static_set_system_scheme;
    end Set_System_Scheme;


    function Is_Scheme
           (Scheme : in String)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_static_is_scheme (Interfaces.C.To_C (Scheme));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::is_scheme returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Is_Scheme;




    --  Library Options  --

    function Get_Option
           (Opt : in Option)
        return Boolean is
    begin
        return fl_static_get_option (Option'Pos (Opt)) /= 0;
    end Get_Option;


    procedure Set_Option
           (Opt : in Option;
            To  : in Boolean) is
    begin
        fl_static_set_option (Option'Pos (Opt), Boolean'Pos (To));
    end Set_Option;


    function Get_Use_High_Res_GL
        return Boolean is
    begin
        return fl_static_get_use_high_res_gl /= 0;
    end Get_Use_High_Res_GL;


    procedure Set_Use_High_Res_GL
           (To : in Boolean) is
    begin
        fl_static_set_use_high_res_gl (Boolean'Pos (To));
    end Set_Use_High_Res_GL;




    --  Scrollbars  --

    function Get_Default_Scrollbar_Size
        return Natural
    is
        Result : constant Interfaces.C.int := fl_static_get_scrollbar_size;
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::scrollbar_size returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Default_Scrollbar_Size;


    procedure Set_Default_Scrollbar_Size
           (To : in Natural) is
    begin
        fl_static_set_scrollbar_size (Interfaces.C.int (To));
    end Set_Default_Scrollbar_Size;




    --  Shutdown  --

    function Get_Program_Should_Quit
        return Boolean is
    begin
        return fl_static_get_program_should_quit /= 0;
    end Get_Program_Should_Quit;


    procedure Set_Program_Should_Quit
           (To : in Boolean) is
    begin
        fl_static_set_program_should_quit (Boolean'Pos (To));
    end Set_Program_Should_Quit;


    procedure Hide_All_Windows is
    begin
        fl_static_hide_all_windows;
        Hook_Exceptions.Reraise;
    end Hide_All_Windows;


    procedure Run_Checks is
    begin
        fl_static_run_checks;
        Hook_Exceptions.Reraise;
    end Run_Checks;


    procedure Run_Idle is
    begin
        fl_static_run_idle;
        Hook_Exceptions.Reraise;
    end Run_Idle;


    procedure Set_Window_Close_Handler
           (Func : in Window_Close_Handler) is
    begin
        Current_Window_Close := Func;
        fl_static_set_atclose
           (if Func = null
            then Null_Pointer
            else Storage.To_Integer (Window_Close_Hook'Address));
    end Set_Window_Close_Handler;




    --  Timestamps  --

    function Now
           (Offset : in Long_Float := 0.0)
        return Timestamp
    is
        S : Interfaces.C.long_long;
        U : Interfaces.C.int;
    begin
        fl_static_now (Interfaces.C.double (Offset), S, U);
        return (Sec => Long_Long_Integer (S), Usec => U);
    end Now;


    function Seconds_Between
           (Earlier, Later : in Timestamp)
        return Long_Float is
    begin
        --  Fl::seconds_between (back, further_back) is back - further_back
        --  (Fl_Timeout.cxx:126-128).
        return Long_Float (fl_static_seconds_between
           (Interfaces.C.long_long (Later.Sec), Later.Usec,
            Interfaces.C.long_long (Earlier.Sec), Earlier.Usec));
    end Seconds_Between;


    function Seconds_Since
           (Moment : in Timestamp)
        return Long_Float is
    begin
        return Seconds_Between (Moment, Now);
    end Seconds_Since;


    function Ticks_Between
           (Earlier, Later : in Timestamp)
        return Long_Integer is
    begin
        return Long_Integer (fl_static_ticks_between
           (Interfaces.C.long_long (Later.Sec), Later.Usec,
            Interfaces.C.long_long (Earlier.Sec), Earlier.Usec));
    end Ticks_Between;


    function Ticks_Since
           (Moment : in Timestamp)
        return Long_Integer is
    begin
        return Ticks_Between (Moment, Now);
    end Ticks_Since;




    --  Contrast  --

    function Get_Contrast_Mode
        return Contrast_Mode
    is
        Result : constant Interfaces.C.int := fl_static_get_contrast_mode;
    begin
        return Contrast_Mode'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "fl_contrast_mode returned unexpected int value of " & Interfaces.C.int'Image (Result);
    end Get_Contrast_Mode;


    procedure Set_Contrast_Mode
           (To : in Contrast_Mode) is
    begin
        fl_static_set_contrast_mode (Contrast_Mode'Pos (To));
    end Set_Contrast_Mode;


    function Get_Contrast_Level
        return Contrast_Level
    is
        Result : constant Interfaces.C.int := fl_static_get_contrast_level;
    begin
        return Contrast_Level (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "fl_contrast_level returned unexpected int value of " & Interfaces.C.int'Image (Result);
    end Get_Contrast_Level;


    procedure Set_Contrast_Level
           (To : in Contrast_Level) is
    begin
        fl_static_set_contrast_level (Interfaces.C.int (To));
    end Set_Contrast_Level;


    procedure Set_Contrast_Function
           (Func : in Contrast_Function) is
    begin
        Current_Contrast := Func;
        fl_static_set_contrast_function
           (if Func = null
            then Null_Pointer
            else Storage.To_Integer (Contrast_Hook'Address));
    end Set_Contrast_Function;


    function Parse_Color
           (Name    : in     String;
            R, G, B : in out Color_Component)
        return Boolean
    is
        CR, CG, CB : Interfaces.C.unsigned_char := 0;
    begin
        if fl_static_parse_color (Interfaces.C.To_C (Name), CR, CG, CB) = 0 then
            return False;
        end if;
        R := Color_Component (CR);
        G := Color_Component (CG);
        B := Color_Component (CB);
        return True;
    end Parse_Color;




    --  Box and Menu Settings  --

    function Get_Box_Border_Radius_Max
        return Integer is
    begin
        return Integer (fl_static_get_box_border_radius_max);
    end Get_Box_Border_Radius_Max;


    procedure Set_Box_Border_Radius_Max
           (To : in Integer) is
    begin
        fl_static_set_box_border_radius_max (Interfaces.C.int (To));
    end Set_Box_Border_Radius_Max;


    function Get_Box_Shadow_Width
        return Integer is
    begin
        return Integer (fl_static_get_box_shadow_width);
    end Get_Box_Shadow_Width;


    procedure Set_Box_Shadow_Width
           (To : in Integer) is
    begin
        fl_static_set_box_shadow_width (Interfaces.C.int (To));
    end Set_Box_Shadow_Width;


    function Get_Menu_Line_Spacing
        return Integer is
    begin
        return Integer (fl_static_get_menu_linespacing);
    end Get_Menu_Line_Spacing;


    procedure Set_Menu_Line_Spacing
           (To : in Integer) is
    begin
        fl_static_set_menu_linespacing (Interfaces.C.int (To));
    end Set_Menu_Line_Spacing;




    --  Callback Reasons  --

    function Get_Callback_Reason
        return Callback_Reason
    is
        Result : constant Interfaces.C.int := fl_static_callback_reason;
    begin
        return Callback_Reason (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::callback_reason returned unexpected int value of " & Interfaces.C.int'Image (Result);
    end Get_Callback_Reason;




    --  Selection Owner  --

    function Get_Selection_Owner
        return access FLTK.Widgets.Widget'Class
    is
        Owner_Ptr : Storage.Integer_Address := fl_static_get_selection_owner;
    begin
        if Owner_Ptr = Null_Pointer then
            return null;
        end if;
        Owner_Ptr := fl_widget_get_user_data (Owner_Ptr);
        if Owner_Ptr = Null_Pointer then
            return null;
        end if;
        return Widget_Convert.To_Pointer (Storage.To_Address (Owner_Ptr));
    end Get_Selection_Owner;


    procedure Set_Selection_Owner
           (To : in FLTK.Widgets.Widget'Class) is
    begin
        if Wrapper (To).Void_Ptr = Null_Pointer then
            raise Program_Error with "Set_Selection_Owner of a widget that doesn't exist";
        end if;
        fl_static_set_selection_owner (Wrapper (To).Void_Ptr);
    end Set_Selection_Owner;


    procedure Clear_Selection_Owner is
    begin
        fl_static_set_selection_owner (Null_Pointer);
    end Clear_Selection_Owner;


    function Get_Selection_To_Clipboard
        return Boolean is
    begin
        return fl_static_get_selection_to_clipboard /= 0;
    end Get_Selection_To_Clipboard;


    procedure Set_Selection_To_Clipboard
           (To : in Boolean) is
    begin
        fl_static_set_selection_to_clipboard (Boolean'Pos (To));
    end Set_Selection_To_Clipboard;




    --  Scheme List  --

    function Scheme_Count
        return Natural is
    begin
        return Natural (fl_static_scheme_count);
    end Scheme_Count;


    function Scheme_Name
           (Index : in Positive)
        return String is
    begin
        if Index > Scheme_Count then
            raise Constraint_Error with
                "Scheme_Name" & Integer'Image (Index) & " of" & Integer'Image (Scheme_Count);
        end if;
        return Interfaces.C.Strings.Value (fl_static_scheme_name (Interfaces.C.int (Index) - 1));
    end Scheme_Name;


    function Add_Scheme_Name
           (Name : in String)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_static_add_scheme_name (Interfaces.C.To_C (Name));
    begin
        case Result is
        when 0 => return False;
        when -1 => raise Constraint_Error with
            "Add_Scheme_Name """ & Name & """ has a character other than a-z, 0-9, $, +, _ or .";
        when -2 => raise Constraint_Error with
            "Add_Scheme_Name """ & Name & """ is longer than 12 characters";
        when others =>
            if Result < 0 then
                raise Internal_FLTK_Error with
                    "Fl_Scheme::add_scheme_name returned unexpected int value of " &
                    Interfaces.C.int'Image (Result);
            end if;
            return True;
        end case;
    end Add_Scheme_Name;


end FLTK.Static;


