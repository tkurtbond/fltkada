

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Characters.Latin_1,
    Ada.Unchecked_Conversion,
    Ada.Unchecked_Deallocation,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Groups.Text_Displays is


    package Chk   renames Ada.Assertions;
    package Latin renames Ada.Characters.Latin_1;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_text_display
           (X, Y, W, H : in Interfaces.C.int;
            Label      : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_text_display, "new_fl_text_display");
    pragma Inline (new_fl_text_display);

    procedure free_fl_text_display
           (TD : in Storage.Integer_Address);
    pragma Import (C, free_fl_text_display, "free_fl_text_display");
    pragma Inline (free_fl_text_display);




    --  Buffers  --

    --  function fl_text_display_get_buffer
    --         (TD : in Storage.Integer_Address)
    --      return Storage.Integer_Address;
    --  pragma Import (C, fl_text_display_get_buffer, "fl_text_display_get_buffer");
    --  pragma Inline (fl_text_display_get_buffer);

    procedure fl_text_display_set_buffer
           (TD, TB : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_set_buffer, "fl_text_display_set_buffer");
    pragma Inline (fl_text_display_set_buffer);

    procedure fl_text_display_buffer_modified_cb
           (P, I, D, R : in Interfaces.C.int;
            T          : in Interfaces.C.Strings.chars_ptr;
            TD         : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_buffer_modified_cb, "fl_text_display_buffer_modified_cb");
    pragma Inline (fl_text_display_buffer_modified_cb);

    procedure fl_text_display_buffer_predelete_cb
           (P, D : in Interfaces.C.int;
            TD   : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_buffer_predelete_cb, "fl_text_display_buffer_predelete_cb");
    pragma Inline (fl_text_display_buffer_predelete_cb);




    --  Highlighting  --

    procedure fl_text_display_highlight_data
           (TD, TB, ST : in Storage.Integer_Address;
            L          : in Interfaces.C.int);
    pragma Import (C, fl_text_display_highlight_data, "fl_text_display_highlight_data");
    pragma Inline (fl_text_display_highlight_data);

    procedure fl_text_display_highlight_data2
           (TD, TB, ST : in Storage.Integer_Address;
            L          : in Interfaces.C.int;
            C          : in Interfaces.C.char;
            B, A       : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_highlight_data2, "fl_text_display_highlight_data2");
    pragma Inline (fl_text_display_highlight_data2);

    function fl_text_display_position_style
           (TD      : in Storage.Integer_Address;
            S, L, I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_position_style, "fl_text_display_position_style");
    pragma Inline (fl_text_display_position_style);




    --  Measurement Conversion  --

    function fl_text_display_col_to_x
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_text_display_col_to_x, "fl_text_display_col_to_x");
    pragma Inline (fl_text_display_col_to_x);

    function fl_text_display_x_to_col
           (TD : in Storage.Integer_Address;
            X  : in Interfaces.C.double)
        return Interfaces.C.double;
    pragma Import (C, fl_text_display_x_to_col, "fl_text_display_x_to_col");
    pragma Inline (fl_text_display_x_to_col);

    function fl_text_display_in_selection
           (TD   : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_in_selection, "fl_text_display_in_selection");
    pragma Inline (fl_text_display_in_selection);

    function fl_text_display_position_to_xy
           (TD   : in     Storage.Integer_Address;
            P    : in     Interfaces.C.int;
            X, Y :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_position_to_xy, "fl_text_display_position_to_xy");
    pragma Inline (fl_text_display_position_to_xy);

    procedure fl_text_display_find_line_end
           (TD        : in     Storage.Integer_Address;
            SP, SPILS : in     Interfaces.C.int;
            LE, NLS   :    out Interfaces.C.int);
    pragma Import (C, fl_text_display_find_line_end, "fl_text_display_find_line_end");
    pragma Inline (fl_text_display_find_line_end);

    function fl_text_display_find_x
           (TD      : in Storage.Integer_Address;
            T       : in Interfaces.C.char_array;
            L, S, X : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_find_x, "fl_text_display_find_x");
    pragma Inline (fl_text_display_find_x);

    function fl_text_display_position_to_line
           (TD : in     Storage.Integer_Address;
            P  : in     Interfaces.C.int;
            LN :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_position_to_line, "fl_text_display_position_to_line");
    pragma Inline (fl_text_display_position_to_line);

    function fl_text_display_position_to_linecol
           (TD    : in     Storage.Integer_Address;
            P     : in     Interfaces.C.int;
            LN, C :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_position_to_linecol, "fl_text_display_position_to_linecol");
    pragma Inline (fl_text_display_position_to_linecol);

    function fl_text_display_xy_to_position
           (TD      : in Storage.Integer_Address;
            X, Y, K : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_xy_to_position, "fl_text_display_xy_to_position");
    pragma Inline (fl_text_display_xy_to_position);

    procedure fl_text_display_xy_to_rowcol
           (TD   : in     Storage.Integer_Address;
            X, Y : in     Interfaces.C.int;
            R, C :    out Interfaces.C.int;
            K    : in     Interfaces.C.int);
    pragma Import (C, fl_text_display_xy_to_rowcol, "fl_text_display_xy_to_rowcol");
    pragma Inline (fl_text_display_xy_to_rowcol);




    --  Cursors  --

    function fl_text_display_get_cursor_color
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_text_display_get_cursor_color, "fl_text_display_get_cursor_color");
    pragma Inline (fl_text_display_get_cursor_color);

    procedure fl_text_display_set_cursor_color
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_text_display_set_cursor_color, "fl_text_display_set_cursor_color");
    pragma Inline (fl_text_display_set_cursor_color);

    procedure fl_text_display_set_cursor_style
           (TD : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_cursor_style, "fl_text_display_set_cursor_style");
    pragma Inline (fl_text_display_set_cursor_style);

    procedure fl_text_display_hide_cursor
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_hide_cursor, "fl_text_display_hide_cursor");
    pragma Inline (fl_text_display_hide_cursor);

    procedure fl_text_display_show_cursor
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_show_cursor, "fl_text_display_show_cursor");
    pragma Inline (fl_text_display_show_cursor);




    --  Text Settings  --

    function fl_text_display_get_text_color
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_text_display_get_text_color, "fl_text_display_get_text_color");
    pragma Inline (fl_text_display_get_text_color);

    procedure fl_text_display_set_text_color
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_text_display_set_text_color, "fl_text_display_set_text_color");
    pragma Inline (fl_text_display_set_text_color);

    function fl_text_display_get_text_font
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_text_font, "fl_text_display_get_text_font");
    pragma Inline (fl_text_display_get_text_font);

    procedure fl_text_display_set_text_font
           (TD : in Storage.Integer_Address;
            F  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_text_font, "fl_text_display_set_text_font");
    pragma Inline (fl_text_display_set_text_font);

    function fl_text_display_get_text_size
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_text_size, "fl_text_display_get_text_size");
    pragma Inline (fl_text_display_get_text_size);

    procedure fl_text_display_set_text_size
           (TD : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_text_size, "fl_text_display_set_text_size");
    pragma Inline (fl_text_display_set_text_size);




    --  Text Insert  --

    procedure fl_text_display_insert
           (TD : in Storage.Integer_Address;
            I  : in Interfaces.C.char_array);
    pragma Import (C, fl_text_display_insert, "fl_text_display_insert");
    pragma Inline (fl_text_display_insert);

    procedure fl_text_display_overstrike
           (TD : in Storage.Integer_Address;
            T  : in Interfaces.C.char_array);
    pragma Import (C, fl_text_display_overstrike, "fl_text_display_overstrike");
    pragma Inline (fl_text_display_overstrike);

    function fl_text_display_get_insert_pos
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_insert_pos, "fl_text_display_get_insert_pos");
    pragma Inline (fl_text_display_get_insert_pos);

    procedure fl_text_display_set_insert_pos
           (TD : in Storage.Integer_Address;
            P  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_insert_pos, "fl_text_display_set_insert_pos");
    pragma Inline (fl_text_display_set_insert_pos);

    procedure fl_text_display_show_insert_pos
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_show_insert_pos, "fl_text_display_show_insert_pos");
    pragma Inline (fl_text_display_show_insert_pos);




    --  Words  --

    function fl_text_display_word_start
           (TD : in Storage.Integer_Address;
            P  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_word_start, "fl_text_display_word_start");
    pragma Inline (fl_text_display_word_start);

    function fl_text_display_word_end
           (TD : in Storage.Integer_Address;
            P  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_word_end, "fl_text_display_word_end");
    pragma Inline (fl_text_display_word_end);

    procedure fl_text_display_next_word
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_next_word, "fl_text_display_next_word");
    pragma Inline (fl_text_display_next_word);

    procedure fl_text_display_previous_word
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_previous_word, "fl_text_display_previous_word");
    pragma Inline (fl_text_display_previous_word);




    --  Wrapping  --

    procedure fl_text_display_wrap_mode
           (TD    : in Storage.Integer_Address;
            W, M  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_wrap_mode, "fl_text_display_wrap_mode");
    pragma Inline (fl_text_display_wrap_mode);

    function fl_text_display_wrapped_row
           (TD : in Storage.Integer_Address;
            R  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_wrapped_row, "fl_text_display_wrapped_row");
    pragma Inline (fl_text_display_wrapped_row);

    function fl_text_display_wrapped_column
           (TD   : in Storage.Integer_Address;
            R, C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_wrapped_column, "fl_text_display_wrapped_column");
    pragma Inline (fl_text_display_wrapped_column);

    function fl_text_display_wrap_uses_character
           (TD : in Storage.Integer_Address;
            L  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_wrap_uses_character, "fl_text_display_wrap_uses_character");
    pragma Inline (fl_text_display_wrap_uses_character);

    procedure fl_text_display_wrapped_line_counter
           (TD, Buf                : in     Storage.Integer_Address;
            SP, MP, ML, SPILS, SBO : in     Interfaces.C.int;
            RP, RL, RLS, RLE       :    out Interfaces.C.int;
            CLLMNL                 : in     Interfaces.C.int);
    pragma Import (C, fl_text_display_wrapped_line_counter, "fl_text_display_wrapped_line_counter");
    pragma Inline (fl_text_display_wrapped_line_counter);




    --  Lines  --

    function fl_text_display_line_start
           (TD : in Storage.Integer_Address;
            S  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_line_start, "fl_text_display_line_start");
    pragma Inline (fl_text_display_line_start);

    function fl_text_display_line_end
           (TD   : in Storage.Integer_Address;
            S, P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_line_end, "fl_text_display_line_end");
    pragma Inline (fl_text_display_line_end);

    function fl_text_display_count_lines
           (TD      : in Storage.Integer_Address;
            S, F, P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_count_lines, "fl_text_display_count_lines");
    pragma Inline (fl_text_display_count_lines);

    function fl_text_display_skip_lines
           (TD      : in Storage.Integer_Address;
            S, L, P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_skip_lines, "fl_text_display_skip_lines");
    pragma Inline (fl_text_display_skip_lines);

    function fl_text_display_rewind_lines
           (TD   : in Storage.Integer_Address;
            S, L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_rewind_lines, "fl_text_display_rewind_lines");
    pragma Inline (fl_text_display_rewind_lines);

    procedure fl_text_display_calc_last_char
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_calc_last_char, "fl_text_display_calc_last_char");
    pragma Inline (fl_text_display_calc_last_char);

    procedure fl_text_display_calc_line_starts
           (TD   : in Storage.Integer_Address;
            S, F : in Interfaces.C.int);
    pragma Import (C, fl_text_display_calc_line_starts, "fl_text_display_calc_line_starts");
    pragma Inline (fl_text_display_calc_line_starts);

    procedure fl_text_display_offset_line_starts
           (TD : in Storage.Integer_Address;
            T  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_offset_line_starts, "fl_text_display_offset_line_starts");
    pragma Inline (fl_text_display_offset_line_starts);




    --  Absolute Lines  --

    procedure fl_text_display_absolute_top_line_number
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_absolute_top_line_number,
        "fl_text_display_absolute_top_line_number");
    pragma Inline (fl_text_display_absolute_top_line_number);

    function fl_text_display_get_absolute_top_line_number
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_absolute_top_line_number,
        "fl_text_display_get_absolute_top_line_number");
    pragma Inline (fl_text_display_get_absolute_top_line_number);

    procedure fl_text_display_maintain_absolute_top_line_number
           (TD : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_maintain_absolute_top_line_number,
        "fl_text_display_maintain_absolute_top_line_number");
    pragma Inline (fl_text_display_maintain_absolute_top_line_number);

    function fl_text_display_maintaining_absolute_top_line_number
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_maintaining_absolute_top_line_number,
        "fl_text_display_maintaining_absolute_top_line_number");
    pragma Inline (fl_text_display_maintaining_absolute_top_line_number);

    procedure fl_text_display_reset_absolute_top_line_number
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_reset_absolute_top_line_number,
        "fl_text_display_reset_absolute_top_line_number");
    pragma Inline (fl_text_display_reset_absolute_top_line_number);




    --  Visible Lines  --

    function fl_text_display_empty_vlines
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_empty_vlines, "fl_text_display_empty_vlines");
    pragma Inline (fl_text_display_empty_vlines);

    function fl_text_display_longest_vline
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_longest_vline, "fl_text_display_longest_vline");
    pragma Inline (fl_text_display_longest_vline);

    function fl_text_display_vline_length
           (TD : in Storage.Integer_Address;
            L  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_vline_length, "fl_text_display_vline_length");
    pragma Inline (fl_text_display_vline_length);




    --  Line Numbers  --

    function fl_text_display_get_linenumber_align
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_text_display_get_linenumber_align,
        "fl_text_display_get_linenumber_align");
    pragma Inline (fl_text_display_get_linenumber_align);

    procedure fl_text_display_set_linenumber_align
           (TD : in Storage.Integer_Address;
            A  : in Interfaces.C.unsigned);
    pragma Import (C, fl_text_display_set_linenumber_align,
        "fl_text_display_set_linenumber_align");
    pragma Inline (fl_text_display_set_linenumber_align);

    function fl_text_display_get_linenumber_bgcolor
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_text_display_get_linenumber_bgcolor,
        "fl_text_display_get_linenumber_bgcolor");
    pragma Inline (fl_text_display_get_linenumber_bgcolor);

    procedure fl_text_display_set_linenumber_bgcolor
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_text_display_set_linenumber_bgcolor,
        "fl_text_display_set_linenumber_bgcolor");
    pragma Inline (fl_text_display_set_linenumber_bgcolor);

    function fl_text_display_get_linenumber_fgcolor
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_text_display_get_linenumber_fgcolor,
        "fl_text_display_get_linenumber_fgcolor");
    pragma Inline (fl_text_display_get_linenumber_fgcolor);

    procedure fl_text_display_set_linenumber_fgcolor
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_text_display_set_linenumber_fgcolor,
        "fl_text_display_set_linenumber_fgcolor");
    pragma Inline (fl_text_display_set_linenumber_fgcolor);

    function fl_text_display_get_linenumber_font
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_linenumber_font,
        "fl_text_display_get_linenumber_font");
    pragma Inline (fl_text_display_get_linenumber_font);

    procedure fl_text_display_set_linenumber_font
           (TD : in Storage.Integer_Address;
            F  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_linenumber_font,
        "fl_text_display_set_linenumber_font");
    pragma Inline (fl_text_display_set_linenumber_font);

    function fl_text_display_get_linenumber_size
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_linenumber_size,
        "fl_text_display_get_linenumber_size");
    pragma Inline (fl_text_display_get_linenumber_size);

    procedure fl_text_display_set_linenumber_size
           (TD : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_linenumber_size,
        "fl_text_display_set_linenumber_size");
    pragma Inline (fl_text_display_set_linenumber_size);

    function fl_text_display_get_linenumber_width
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_linenumber_width,
        "fl_text_display_get_linenumber_width");
    pragma Inline (fl_text_display_get_linenumber_width);

    procedure fl_text_display_set_linenumber_width
           (TD : in Storage.Integer_Address;
            W  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_linenumber_width,
        "fl_text_display_set_linenumber_width");
    pragma Inline (fl_text_display_set_linenumber_width);

    function fl_text_display_get_linenumber_format
           (TD : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_text_display_get_linenumber_format,
        "fl_text_display_get_linenumber_format");
    pragma Inline (fl_text_display_get_linenumber_format);

    procedure fl_text_display_set_linenumber_format
           (TD : in Storage.Integer_Address;
            V  : in Interfaces.C.char_array);
    pragma Import (C, fl_text_display_set_linenumber_format,
        "fl_text_display_set_linenumber_format");
    pragma Inline (fl_text_display_set_linenumber_format);




    --  Text Measurement  --

    function fl_text_display_measure_proportional_character
           (TD   : in Storage.Integer_Address;
            T    : in Interfaces.C.char_array;
            X, P : in Interfaces.C.int)
        return Interfaces.C.double;
    pragma Import (C, fl_text_display_measure_proportional_character,
        "fl_text_display_measure_proportional_character");
    pragma Inline (fl_text_display_measure_proportional_character);

    function fl_text_display_measure_vline
           (TD : in Storage.Integer_Address;
            L  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_measure_vline, "fl_text_display_measure_vline");
    pragma Inline (fl_text_display_measure_vline);

    function fl_text_display_string_width
           (TD   : in Storage.Integer_Address;
            T    : in Interfaces.C.char_array;
            L, S : in Interfaces.C.int)
        return Interfaces.C.double;
    pragma Import (C, fl_text_display_string_width, "fl_text_display_string_width");
    pragma Inline (fl_text_display_string_width);




    --  Movement  --

    function fl_text_display_move_down
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_move_down, "fl_text_display_move_down");
    pragma Inline (fl_text_display_move_down);

    function fl_text_display_move_left
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_move_left, "fl_text_display_move_left");
    pragma Inline (fl_text_display_move_left);

    function fl_text_display_move_right
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_move_right, "fl_text_display_move_right");
    pragma Inline (fl_text_display_move_right);

    function fl_text_display_move_up
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_move_up, "fl_text_display_move_up");
    pragma Inline (fl_text_display_move_up);




    --  Scrolling  --

    procedure fl_text_display_scroll
           (TD   : in Storage.Integer_Address;
            L, C : in Interfaces.C.int);
    pragma Import (C, fl_text_display_scroll, "fl_text_display_scroll");
    pragma Inline (fl_text_display_scroll);

    function fl_text_display_scroll2
           (TD   : in Storage.Integer_Address;
            L, P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_scroll2, "fl_text_display_scroll2");
    pragma Inline (fl_text_display_scroll2);

    function fl_text_display_get_scrollbar_align
           (TD : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_text_display_get_scrollbar_align, "fl_text_display_get_scrollbar_align");
    pragma Inline (fl_text_display_get_scrollbar_align);

    procedure fl_text_display_set_scrollbar_align
           (TD : in Storage.Integer_Address;
            A  : in Interfaces.C.unsigned);
    pragma Import (C, fl_text_display_set_scrollbar_align, "fl_text_display_set_scrollbar_align");
    pragma Inline (fl_text_display_set_scrollbar_align);

    function fl_text_display_get_scrollbar_width
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_scrollbar_width, "fl_text_display_get_scrollbar_width");
    pragma Inline (fl_text_display_get_scrollbar_width);

    procedure fl_text_display_set_scrollbar_width
           (TD : in Storage.Integer_Address;
            W  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_scrollbar_width, "fl_text_display_set_scrollbar_width");
    pragma Inline (fl_text_display_set_scrollbar_width);

    procedure fl_text_display_update_h_scrollbar
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_update_h_scrollbar, "fl_text_display_update_h_scrollbar");
    pragma Inline (fl_text_display_update_h_scrollbar);

    procedure fl_text_display_update_v_scrollbar
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_update_v_scrollbar, "fl_text_display_update_v_scrollbar");
    pragma Inline (fl_text_display_update_v_scrollbar);




    --  Shortcuts  --

    function fl_text_display_get_shortcut
           (TD : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_get_shortcut, "fl_text_display_get_shortcut");
    pragma Inline (fl_text_display_get_shortcut);

    procedure fl_text_display_set_shortcut
           (TD : in Storage.Integer_Address;
            V  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_set_shortcut, "fl_text_display_set_shortcut");
    pragma Inline (fl_text_display_set_shortcut);




    --  Dimensions  --

    procedure fl_text_display_resize
           (TD         : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_text_display_resize, "fl_text_display_resize");
    pragma Inline (fl_text_display_resize);




    --  Drawing, Events  --

    procedure fl_text_display_clear_rect
           (TD            : in Storage.Integer_Address;
            S, X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_text_display_clear_rect, "fl_text_display_clear_rect");
    pragma Inline (fl_text_display_clear_rect);

    procedure fl_text_display_display_insert
           (TD : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_display_insert, "fl_text_display_display_insert");
    pragma Inline (fl_text_display_display_insert);

    procedure fl_text_display_redisplay_range
           (TD   : in Storage.Integer_Address;
            S, F : in Interfaces.C.int);
    pragma Import (C, fl_text_display_redisplay_range, "fl_text_display_redisplay_range");
    pragma Inline (fl_text_display_redisplay_range);

    procedure fl_text_display_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_text_display_draw, "fl_text_display_draw");
    pragma Inline (fl_text_display_draw);

    procedure fl_text_display_draw_cursor
           (TD   : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_text_display_draw_cursor, "fl_text_display_draw_cursor");
    pragma Inline (fl_text_display_draw_cursor);

    procedure fl_text_display_draw_line_numbers
           (TD : in Storage.Integer_Address;
            C  : in Interfaces.C.int);
    pragma Import (C, fl_text_display_draw_line_numbers, "fl_text_display_draw_line_numbers");
    pragma Inline (fl_text_display_draw_line_numbers);

    procedure fl_text_display_draw_range
           (TD   : in Storage.Integer_Address;
            S, F : in Interfaces.C.int);
    pragma Import (C, fl_text_display_draw_range, "fl_text_display_draw_range");
    pragma Inline (fl_text_display_draw_range);

    procedure fl_text_display_draw_string
           (TD         : in Storage.Integer_Address;
            S, X, Y, R : in Interfaces.C.int;
            T          : in Interfaces.C.char_array;
            N          : in Interfaces.C.int);
    pragma Import (C, fl_text_display_draw_string, "fl_text_display_draw_string");
    pragma Inline (fl_text_display_draw_string);

    procedure fl_text_display_draw_text
           (TD         : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_text_display_draw_text, "fl_text_display_draw_text");
    pragma Inline (fl_text_display_draw_text);

    procedure fl_text_display_draw_vline
           (TD                 : in Storage.Integer_Address;
            N, L, R, LC, RC : in Interfaces.C.int);
    pragma Import (C, fl_text_display_draw_vline, "fl_text_display_draw_vline");
    pragma Inline (fl_text_display_draw_vline);

    function fl_text_display_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_text_display_handle, "fl_text_display_handle");
    pragma Inline (fl_text_display_handle);




    ------------------------
    --  Internal Utility  --
    ------------------------

    function UChar_To_Mask is new Ada.Unchecked_Conversion
        (Interfaces.C.unsigned_char, Styles.Style_Mask);

    function Cint_To_Style_Info
           (Value : in Interfaces.C.int)
        return Styles.Style_Info is
    begin
        return
           (Mask  => UChar_To_Mask (Interfaces.C.unsigned_char ((Value / 256) mod 256)),
            Index => Styles.Style_Index (Character'Val (Value mod 256)));
    end Cint_To_Style_Info;


    function Mask_To_UChar is new Ada.Unchecked_Conversion
        (Styles.Style_Mask, Interfaces.C.unsigned_char);

    function Style_Info_To_Cint
           (Value : in Styles.Style_Info)
        return Interfaces.C.int is
    begin
        return Interfaces.C.int (Mask_To_UChar (Value.Mask)) * 256 +
            Character'Pos (Character (Value.Index));
    end Style_Info_To_Cint;




    ----------------------
    --  Callback Hooks  --
    ----------------------

    procedure Style_Hook
           (C : in Interfaces.C.int;
            D : in Storage.Integer_Address)
    is
        use Styles;  --  for maximum stylin'

        Ada_Widget : constant access Text_Display'Class :=
            Text_Display_Convert.To_Pointer (Storage.To_Address (D));
    begin
        if Ada_Widget.Style_Callback /= null then
            Ada_Widget.Style_Callback (Character'Val (C), Text_Display (Ada_Widget.all));
        end if;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Style_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Text_Display) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Text_Display) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_text_display (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
            Release_Kept (This);
        end if;
    end Finalize;


    procedure Free_Table is new Ada.Unchecked_Deallocation
        (Styles.Style_Array, Style_Array_Access);

    procedure Release_Kept
           (This : in out Text_Display'Class) is
    begin
        if This.Raw_Buffer /= Null_Pointer then
            free_fl_text_buffer (This.Raw_Buffer);  --  buffer is reference counted
            This.Raw_Buffer := Null_Pointer;
        end if;
        if This.Raw_Styles /= Null_Pointer then
            free_fl_text_buffer (This.Raw_Styles);
            This.Raw_Styles := Null_Pointer;
        end if;
        Free_Table (This.Style_Table);
    end Release_Kept;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Text_Display;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Text_Display) is
    begin
        This.Draw_Ptr   := fl_text_display_draw'Address;
        This.Handle_Ptr := fl_text_display_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Text_Display is
        begin
            return This : Text_Display do
                This.Void_Ptr := new_fl_text_display
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Text_Display is
        begin
            return This : Text_Display := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Buffers  --

    function Get_Buffer
           (This : in Text_Display)
        return FLTK.Text_Buffers.Text_Buffer_Reference is
    begin
        return Ref : FLTK.Text_Buffers.Text_Buffer_Reference (This.Buffer);
    end Get_Buffer;


    procedure Set_Buffer
           (This : in out Text_Display;
            Buff : in out FLTK.Text_Buffers.Text_Buffer) is
    begin
        This.Buffer := Buff'Unchecked_Access;
        fl_text_display_set_buffer (This.Void_Ptr, Wrapper (Buff).Void_Ptr);
        if This.Raw_Buffer /= Null_Pointer then
            free_fl_text_buffer (This.Raw_Buffer);
        end if;
        This.Raw_Buffer := Wrapper (Buff).Void_Ptr;
        upref_fl_text_buffer (This.Raw_Buffer);
    end Set_Buffer;


    procedure Buffer_Modified_Callback
           (This         : in out Text_Display;
            Action       : in     FLTK.Text_Buffers.Modification;
            Place        : in     FLTK.Text_Buffers.Position;
            Length       : in     Natural;
            Deleted_Text : in     String)
    is
        Bytes_Inserted, Bytes_Deleted, Bytes_Restyled : Interfaces.C.int := 0;
        C_Text : aliased Interfaces.C.char_array := Interfaces.C.To_C (Deleted_Text);
        use type FLTK.Text_Buffers.Modification;
    begin
        case Action is
        when FLTK.Text_Buffers.Insert  => Bytes_Inserted := Interfaces.C.int (Length);
        when FLTK.Text_Buffers.Restyle => Bytes_Restyled := Interfaces.C.int (Length);
        when FLTK.Text_Buffers.Delete  => Bytes_Deleted  := Interfaces.C.int (Length);
        when FLTK.Text_Buffers.None => null;
        end case;
        fl_text_display_buffer_modified_cb
           (Interfaces.C.int (Place),
            Bytes_Inserted,
            Bytes_Deleted,
            Bytes_Restyled,
            (if Action = FLTK.Text_Buffers.Delete
             then Interfaces.C.Strings.To_Chars_Ptr (C_Text'Unchecked_Access)
             else Interfaces.C.Strings.Null_Ptr),
            This.Void_Ptr);
    end Buffer_Modified_Callback;


    procedure Buffer_Predelete_Callback
           (This   : in out Text_Display;
            Place  : in     FLTK.Text_Buffers.Position;
            Length : in     Natural) is
    begin
        fl_text_display_buffer_predelete_cb
           (Interfaces.C.int (Place),
            Interfaces.C.int (Length),
            This.Void_Ptr);
    end Buffer_Predelete_Callback;




    --  Highlighting  --

    --  Checks the table, and keeps a copy of it and a reference on the style
    --  buffer, letting go of the ones kept before once FLTK has the new ones.
    procedure Keep_Styles
           (This  : in out Text_Display;
            Buff  : in out FLTK.Text_Buffers.Text_Buffer;
            Table : in     Styles.Style_Array;
            Old   :    out Style_Array_Access;
            Raw   :    out Storage.Integer_Address) is
    begin
        if Table'Length = 0 then
            raise Constraint_Error with "Highlight_Data given an empty style table";
        end if;
        if Styles."/=" (Table'First, Styles.Style_Index'First) then
            raise Constraint_Error with "Highlight_Data given a style table not starting at 'A'";
        end if;
        Old := This.Style_Table;
        Raw := This.Raw_Styles;
        This.Style_Table := new Styles.Style_Array'(Table);
        This.Raw_Styles := Wrapper (Buff).Void_Ptr;
        upref_fl_text_buffer (This.Raw_Styles);
    end Keep_Styles;

    procedure Let_Go
           (Old : in out Style_Array_Access;
            Raw : in     Storage.Integer_Address) is
    begin
        Free_Table (Old);
        if Raw /= Null_Pointer then
            free_fl_text_buffer (Raw);
        end if;
    end Let_Go;


    procedure Highlight_Data
           (This  : in out Text_Display;
            Buff  : in out FLTK.Text_Buffers.Text_Buffer;
            Table : in     Styles.Style_Array)
    is
        Old : Style_Array_Access;
        Raw : Storage.Integer_Address;
    begin
        Keep_Styles (This, Buff, Table, Old, Raw);
        fl_text_display_highlight_data
           (This.Void_Ptr,
            This.Raw_Styles,
            Storage.To_Integer (This.Style_Table (This.Style_Table'First)'Address),
            This.Style_Table'Length);
        Let_Go (Old, Raw);
    end Highlight_Data;


    procedure Highlight_Data
           (This       : in out Text_Display;
            Buff       : in out FLTK.Text_Buffers.Text_Buffer;
            Table      : in     Styles.Style_Array;
            Unfinished : in     Character;
            Callback   : in     Styles.Unfinished_Style_Callback)
    is
        Old : Style_Array_Access;
        Raw : Storage.Integer_Address;
    begin
        Keep_Styles (This, Buff, Table, Old, Raw);
        This.Style_Callback := Callback;
        fl_text_display_highlight_data2
           (This.Void_Ptr,
            This.Raw_Styles,
            Storage.To_Integer (This.Style_Table (This.Style_Table'First)'Address),
            This.Style_Table'Length,
            Interfaces.C.To_C (Unfinished),
            Storage.To_Integer (Style_Hook'Address),
            Storage.To_Integer (This'Address));
        Let_Go (Old, Raw);
    end Highlight_Data;


    function Position_Style
           (This        : in Text_Display;
            Line_Start  : in Natural;
            Line_Length : in Natural;
            Line_Index  : in Natural)
        return Styles.Style_Info
    is
        Result : constant Interfaces.C.int := fl_text_display_position_style
           (This.Void_Ptr,
            Interfaces.C.int (Line_Start),
            Interfaces.C.int (Line_Length),
            Interfaces.C.int (Line_Index));
    begin
        return Cint_To_Style_Info (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_style returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Position_Style;




    --  Measurement Conversion  --

    function Col_To_X
           (This    : in Text_Display;
            Col_Num : in Integer)
        return Integer is
    begin
        return Integer (Interfaces.C.double'Rounding
            (fl_text_display_col_to_x (This.Void_Ptr, Interfaces.C.double (Col_Num))));
    end Col_To_X;


    function X_To_Col
           (This  : in Text_Display;
            X_Pos : in Integer)
        return Integer is
    begin
        return Integer (Interfaces.C.double'Rounding
            (fl_text_display_x_to_col (This.Void_Ptr, Interfaces.C.double (X_Pos))));
    end X_To_Col;


    function In_Selection
           (This : in Text_Display;
            X, Y : in Integer)
        return Boolean is
    begin
        return fl_text_display_in_selection
            (This.Void_Ptr, Interfaces.C.int (X), Interfaces.C.int (Y)) /= 0;
    end In_Selection;


    procedure Position_To_XY
           (This     : in     Text_Display;
            Pos      : in     Integer;
            X, Y     :    out Integer;
            Vert_Out :    out Boolean) is
    begin
        Vert_Out := fl_text_display_position_to_xy
           (This.Void_Ptr,
            Interfaces.C.int (Pos),
            Interfaces.C.int (X),
            Interfaces.C.int (Y)) = 0;
    end Position_To_XY;


    procedure Find_Line_End
           (This                    : in     Text_Display;
            Start                   : in     Natural;
            Start_Pos_Is_Line_Start : in     Boolean;
            Line_End                :    out Natural;
            Next_Line_Start         :    out Natural)
    is
        C_Line_End, C_Next_Line_Start : Interfaces.C.int;
    begin
        fl_text_display_find_line_end
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Boolean'Pos (Start_Pos_Is_Line_Start),
            C_Line_End, C_Next_Line_Start);
        Line_End := Natural (C_Line_End);
        Next_Line_Start := Natural (C_Next_Line_Start);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::find_line_end returned unexpected int values of" & Latin.LF &
        Latin.HT & "lineEnd = " & Interfaces.C.int'Image (C_Line_End) & Latin.LF &
        Latin.HT & "nextLineStart = " & Interfaces.C.int'Image (C_Next_Line_Start);
    end Find_Line_End;


    function Find_Character
           (This  : in Text_Display;
            Text  : in String;
            Style : in Styles.Style_Index;
            X     : in Integer)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_text_display_find_x
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Text'Length,
            Character'Pos (Character (Style)),
            Interfaces.C.int (X));
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::find_x returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Find_Character;


    function Position_To_Line
           (This     : in Text_Display;
            Position : in Natural)
        return Natural
    is
        C_Line_Num : Interfaces.C.int;
        Result : constant Interfaces.C.int := fl_text_display_position_to_line
           (This.Void_Ptr,
            Interfaces.C.int (Position),
            C_Line_Num);
    begin
        pragma Assert (Result >= 0);
        return Natural (C_Line_Num);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_line returned unexpected int value of" & Latin.LF &
        Latin.HT & "lineNum = " & Interfaces.C.int'Image (C_Line_Num);
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_line returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Position_To_Line;


    function Position_To_Line
           (This      : in     Text_Display;
            Position  : in     Natural;
            Displayed :    out Boolean)
        return Natural
    is
        C_Line_Num : Interfaces.C.int;
        Result : constant Interfaces.C.int := fl_text_display_position_to_line
           (This.Void_Ptr,
            Interfaces.C.int (Position),
            C_Line_Num);
    begin
        pragma Assert (Result >= 0);
        Displayed := Result /= 0;
        return Natural (C_Line_Num);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_line returned unexpected int value of" & Latin.LF &
        Latin.HT & "lineNum = " & Interfaces.C.int'Image (C_Line_Num);
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_line returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Position_To_Line;


    procedure Position_To_Line_Column
           (This     : in     Text_Display;
            Position : in     Natural;
            Line     :    out Natural;
            Column   :    out Natural)
    is
        C_Line_Num, C_Column : Interfaces.C.int;
        Result : constant Interfaces.C.int := fl_text_display_position_to_linecol
           (This.Void_Ptr,
            Interfaces.C.int (Position),
            C_Line_Num, C_Column);
    begin
        Line := Natural (C_Line_Num);
        Column := Natural (C_Column);
        pragma Assert (Result >= 0);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_linecol returned unexpected int values of" & Latin.LF &
        Latin.HT & "lineNum = " & Interfaces.C.int'Image (C_Line_Num) & Latin.LF &
        Latin.HT & "column = " & Interfaces.C.int'Image (C_Column);
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_linecol returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Position_To_Line_Column;


    procedure Position_To_Line_Column
           (This      : in     Text_Display;
            Position  : in     Natural;
            Line      :    out Natural;
            Column    :    out Natural;
            Displayed :    out Boolean)
    is
        C_Line_Num, C_Column : Interfaces.C.int;
        Result : constant Interfaces.C.int := fl_text_display_position_to_linecol
           (This.Void_Ptr,
            Interfaces.C.int (Position),
            C_Line_Num, C_Column);
    begin
        Line := Natural (C_Line_Num);
        Column := Natural (C_Column);
        pragma Assert (Result >= 0);
        Displayed := Result /= 0;
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_linecol returned unexpected int values of" & Latin.LF &
        Latin.HT & "lineNum = " & Interfaces.C.int'Image (C_Line_Num) & Latin.LF &
        Latin.HT & "column = " & Interfaces.C.int'Image (C_Column);
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::position_to_linecol returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Position_To_Line_Column;


    function XY_To_Position
           (This : in Text_Display;
            X, Y : in Integer;
            Kind : in Position_Kind := Character_Position)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_text_display_xy_to_position
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Position_Kind'Pos (Kind));
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::xy_to_position returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end XY_To_Position;


    procedure XY_To_Row_Column
           (This        : in     Text_Display;
            X, Y        : in     Integer;
            Row, Column :    out Natural;
            Kind        : in     Position_Kind := Character_Position)
    is
        C_Row, C_Column : Interfaces.C.int;
    begin
        fl_text_display_xy_to_rowcol
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            C_Row, C_Column,
            Position_Kind'Pos (Kind));
        Row := Natural (C_Row);
        Column := Natural (C_Column);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::xy_to_rowcol returned unexpected int values of" & Latin.LF &
        Latin.HT & "row = " & Interfaces.C.int'Image (C_Row) & Latin.LF &
        Latin.HT & "column = " & Interfaces.C.int'Image (C_Column);
    end XY_To_Row_Column;




    --  Cursors  --

    function Get_Cursor_Color
           (This : in Text_Display)
        return Color is
    begin
        return Color (fl_text_display_get_cursor_color (This.Void_Ptr));
    end Get_Cursor_Color;


    procedure Set_Cursor_Color
           (This : in out Text_Display;
            Col  : in     Color) is
    begin
        fl_text_display_set_cursor_color (This.Void_Ptr, Interfaces.C.unsigned (Col));
    end Set_Cursor_Color;


    procedure Set_Cursor_Style
           (This  : in out Text_Display;
            Style : in     Cursor_Style) is
    begin
        fl_text_display_set_cursor_style (This.Void_Ptr, Cursor_Style'Pos (Style));
    end Set_Cursor_Style;


    procedure Hide_Cursor
           (This : in out Text_Display) is
    begin
        fl_text_display_hide_cursor (This.Void_Ptr);
    end Hide_Cursor;


    procedure Show_Cursor
           (This : in out Text_Display) is
    begin
        fl_text_display_show_cursor (This.Void_Ptr);
    end Show_Cursor;




    --  Text Settings  --

    function Get_Text_Color
           (This : in Text_Display)
        return Color is
    begin
        return Color (fl_text_display_get_text_color (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Text_Display;
            Col  : in     Color) is
    begin
        fl_text_display_set_text_color (This.Void_Ptr, Interfaces.C.unsigned (Col));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Text_Display)
        return Font_Kind is
    begin
        return Font_Kind (fl_text_display_get_text_font (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Text_Display;
            Font : in     Font_Kind) is
    begin
        fl_text_display_set_text_font (This.Void_Ptr, To_C (Font));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Text_Display)
        return Font_Size is
    begin
        return Font_Size (fl_text_display_get_text_size (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Text_Display;
            Size : in     Font_Size) is
    begin
        fl_text_display_set_text_size (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    --  Text Insert  --

    procedure Insert_Text
           (This : in out Text_Display;
            Item : in     String) is
    begin
        fl_text_display_insert (This.Void_Ptr, Interfaces.C.To_C (Item));
    end Insert_Text;


    procedure Overstrike
           (This : in out Text_Display;
            Text : in     String) is
    begin
        fl_text_display_overstrike (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Overstrike;


    function Get_Insert_Position
           (This : in Text_Display)
        return Natural is
    begin
        return Natural (fl_text_display_get_insert_pos (This.Void_Ptr));
    end Get_Insert_Position;


    procedure Set_Insert_Position
           (This : in out Text_Display;
            Pos  : in     Natural) is
    begin
        fl_text_display_set_insert_pos (This.Void_Ptr, Interfaces.C.int (Pos));
    end Set_Insert_Position;


    procedure Show_Insert_Position
           (This : in out Text_Display) is
    begin
        fl_text_display_show_insert_pos (This.Void_Ptr);
    end Show_Insert_Position;




    --  Words  --

    function Word_Start
           (This : in out Text_Display;
            Pos  : in     Natural)
        return Natural is
    begin
        return Natural (fl_text_display_word_start
           (This.Void_Ptr,
            Interfaces.C.int (Pos)));
    end Word_Start;


    function Word_End
           (This : in out Text_Display;
            Pos  : in     Natural)
        return Natural is
    begin
        return Natural (fl_text_display_word_end
           (This.Void_Ptr,
            Interfaces.C.int (Pos)));
    end Word_End;


    procedure Next_Word
           (This : in out Text_Display) is
    begin
        fl_text_display_next_word (This.Void_Ptr);
    end Next_Word;


    procedure Previous_Word
           (This : in out Text_Display) is
    begin
        fl_text_display_previous_word (This.Void_Ptr);
    end Previous_Word;




    --  Wrapping  --

    procedure Set_Wrap_Mode
           (This   : in out Text_Display;
            Mode   : in     Wrap_Mode;
            Margin : in     Natural := 0) is
    begin
        fl_text_display_wrap_mode
           (This.Void_Ptr,
            Wrap_Mode'Pos (Mode),
            Interfaces.C.int (Margin));
    end Set_Wrap_Mode;


    function Wrapped_Row
           (This : in Text_Display;
            Row  : in Natural)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_text_display_wrapped_row
           (This.Void_Ptr,
            Interfaces.C.int (Row));
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::wrapped_row returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Wrapped_Row;


    function Wrapped_Column
           (This        : in Text_Display;
            Row, Column : in Natural)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_text_display_wrapped_column
           (This.Void_Ptr,
            Interfaces.C.int (Row),
            Interfaces.C.int (Column));
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::wrapped_column returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Wrapped_Column;


    function Wrap_Uses_Character
           (This     : in Text_Display;
            Line_End : in Natural)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_wrap_uses_character
           (This.Void_Ptr,
            Interfaces.C.int (Line_End));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::wrap_uses_character returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Wrap_Uses_Character;


    procedure Count_Wrapped_Lines
           (This                       : in     Text_Display;
            Buffer                     : in     FLTK.Text_Buffers.Text_Buffer;
            Start                      : in     Natural;
            Max_Position, Max_Lines    : in     Natural;
            Start_Pos_Is_Line_Start    : in     Boolean;
            Style_Offset               : in     Natural;
            Finish, Line_Count         :    out Natural;
            End_Count_Line_Start       :    out Natural;
            Last_Line_End              :    out Natural;
            Count_Last_Missing_Newline : in     Boolean := True)
    is
        C_Finish, C_Line_Count, C_End_Count_Line_Start, C_Last_Line_End : Interfaces.C.int;
    begin
        fl_text_display_wrapped_line_counter
           (This.Void_Ptr,
            Wrapper (Buffer).Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Max_Position),
            Interfaces.C.int (Max_Lines),
            Boolean'Pos (Start_Pos_Is_Line_Start),
            Interfaces.C.int (Style_Offset),
            C_Finish,
            C_Line_Count,
            C_End_Count_Line_Start,
            C_Last_Line_End,
            Boolean'Pos (Count_Last_Missing_Newline));
        Finish               := Natural (C_Finish);
        Line_Count           := Natural (C_Line_Count);
        End_Count_Line_Start := Natural (C_End_Count_Line_Start);
        Last_Line_End        := Natural (C_Last_Line_End);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::wrapped_line_counter returned unexpected int values of" & Latin.LF &
        Latin.HT & "retPos = " & Interfaces.C.int'Image (C_Finish) & Latin.LF &
        Latin.HT & "retLines = " & Interfaces.C.int'Image (C_Line_Count) & Latin.LF &
        Latin.HT & "retLineStart = " & Interfaces.C.int'Image (C_End_Count_Line_Start) & Latin.LF &
        Latin.HT & "retLineEnd = " & Interfaces.C.int'Image (C_Last_Line_End);
    end Count_Wrapped_Lines;




    --  Lines  --

    function Line_Start
           (This : in Text_Display;
            Pos  : in Natural)
        return Natural is
    begin
        return Natural (fl_text_display_line_start
           (This.Void_Ptr,
            Interfaces.C.int (Pos)));
    end Line_Start;


    function Line_End
           (This                    : in Text_Display;
            Pos                     : in Natural;
            Start_Pos_Is_Line_Start : in Boolean := False)
        return Natural is
    begin
        return Natural (fl_text_display_line_end
           (This.Void_Ptr,
            Interfaces.C.int (Pos),
            Boolean'Pos (Start_Pos_Is_Line_Start)));
    end Line_End;


    function Count_Lines
           (This                    : in Text_Display;
            Start, Finish           : in Natural;
            Start_Pos_Is_Line_Start : in Boolean := False)
        return Natural is
    begin
        return Natural (fl_text_display_count_lines
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Finish),
            Boolean'Pos (Start_Pos_Is_Line_Start)));
    end Count_Lines;


    function Skip_Lines
           (This                    : in Text_Display;
            Start, Lines            : in Natural;
            Start_Pos_Is_Line_Start : in Boolean := False)
        return Natural is
    begin
        return Natural (fl_text_display_skip_lines
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Lines),
            Boolean'Pos (Start_Pos_Is_Line_Start)));
    end Skip_Lines;


    function Rewind_Lines
           (This         : in Text_Display;
            Start, Lines : in Natural)
        return Natural is
    begin
        return Natural (fl_text_display_rewind_lines
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Lines)));
    end Rewind_Lines;


    procedure Calculate_Last_Character
           (This : in out Text_Display) is
    begin
        fl_text_display_calc_last_char (This.Void_Ptr);
    end Calculate_Last_Character;


    procedure Calculate_Line_Starts
           (This          : in out Text_Display;
            Start, Finish : in     Natural) is
    begin
        fl_text_display_calc_line_starts
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Finish));
    end Calculate_Line_Starts;


    procedure Offset_Line_Starts
           (This    : in out Text_Display;
            New_Top : in     Natural) is
    begin
        fl_text_display_offset_line_starts
           (This.Void_Ptr,
            Interfaces.C.int (New_Top));
    end Offset_Line_Starts;




    --  Absolute Lines  --

    procedure Redo_Absolute_Top_Line
           (This      : in out Text_Display;
            Old_First : in     Natural) is
    begin
        fl_text_display_absolute_top_line_number (This.Void_Ptr, Interfaces.C.int (Old_First));
    end Redo_Absolute_Top_Line;


    function Get_Absolute_Top_Line
           (This : in Text_Display)
        return Natural
    is
        Result : constant Interfaces.C.int :=
            fl_text_display_get_absolute_top_line_number (This.Void_Ptr);
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::get_absolute_top_line_number returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Absolute_Top_Line;


    procedure Maintain_Absolute_Top_Line
           (This  : in out Text_Display;
            State : in     Boolean := True) is
    begin
        fl_text_display_maintain_absolute_top_line_number (This.Void_Ptr, Boolean'Pos (State));
    end Maintain_Absolute_Top_Line;


    function Maintaining_Absolute_Top_Line
           (This : in Text_Display)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_maintaining_absolute_top_line_number
            (This.Void_Ptr);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::maintaining_absolute_top_line_number returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Maintaining_Absolute_Top_Line;


    procedure Reset_Absolute_Top_Line
           (This : in out Text_Display) is
    begin
        fl_text_display_reset_absolute_top_line_number (This.Void_Ptr);
    end Reset_Absolute_Top_Line;




    --  Visible Lines  --

    function Has_Empty_Visible_Lines
           (This : in Text_Display)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_empty_vlines (This.Void_Ptr);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::empty_vlines returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Has_Empty_Visible_Lines;


    function Get_Longest_Visible_Line
           (This : in Text_Display)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_text_display_longest_vline (This.Void_Ptr);
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::longest_vline returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Longest_Visible_Line;


    function Visible_Line_Length
           (This : in Text_Display;
            Line : in Natural)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_text_display_vline_length
           (This.Void_Ptr,
            Interfaces.C.int (Line));
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::vline_length returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Visible_Line_Length;




    --  Line Numbers  --

    function Get_Linenumber_Alignment
           (This : in Text_Display)
        return Alignment is
    begin
        return Alignment (fl_text_display_get_linenumber_align (This.Void_Ptr));
    end Get_Linenumber_Alignment;


    procedure Set_Linenumber_Alignment
           (This : in out Text_Display;
            To   : in     Alignment) is
    begin
        fl_text_display_set_linenumber_align
           (This.Void_Ptr,
            Interfaces.C.unsigned (To));
    end Set_Linenumber_Alignment;


    function Get_Linenumber_Back_Color
           (This : in Text_Display)
        return Color is
    begin
        return Color (fl_text_display_get_linenumber_bgcolor (This.Void_Ptr));
    end Get_Linenumber_Back_Color;


    procedure Set_Linenumber_Back_Color
           (This : in out Text_Display;
            To   : in     Color) is
    begin
        fl_text_display_set_linenumber_bgcolor
           (This.Void_Ptr,
            Interfaces.C.unsigned (To));
    end Set_Linenumber_Back_Color;


    function Get_Linenumber_Fore_Color
           (This : in Text_Display)
        return Color is
    begin
        return Color (fl_text_display_get_linenumber_fgcolor (This.Void_Ptr));
    end Get_Linenumber_Fore_Color;


    procedure Set_Linenumber_Fore_Color
           (This : in out Text_Display;
            To   : in     Color) is
    begin
        fl_text_display_set_linenumber_fgcolor
           (This.Void_Ptr,
            Interfaces.C.unsigned (To));
    end Set_Linenumber_Fore_Color;


    function Get_Linenumber_Font
           (This : in Text_Display)
        return Font_Kind is
    begin
        return Font_Kind (fl_text_display_get_linenumber_font (This.Void_Ptr));
    end Get_Linenumber_Font;


    procedure Set_Linenumber_Font
           (This : in out Text_Display;
            To   : in     Font_Kind) is
    begin
        fl_text_display_set_linenumber_font
           (This.Void_Ptr,
            To_C (To));
    end Set_Linenumber_Font;


    function Get_Linenumber_Size
           (This : in Text_Display)
        return Font_Size is
    begin
        return Font_Size (fl_text_display_get_linenumber_size (This.Void_Ptr));
    end Get_Linenumber_Size;


    procedure Set_Linenumber_Size
           (This : in out Text_Display;
            To   : in     Font_Size) is
    begin
        fl_text_display_set_linenumber_size
           (This.Void_Ptr,
            Interfaces.C.int (To));
    end Set_Linenumber_Size;


    function Get_Linenumber_Width
           (This : in Text_Display)
        return Natural is
    begin
        return Natural (fl_text_display_get_linenumber_width (This.Void_Ptr));
    end Get_Linenumber_Width;


    procedure Set_Linenumber_Width
           (This  : in out Text_Display;
            Width : in     Natural) is
    begin
        fl_text_display_set_linenumber_width
           (This.Void_Ptr,
            Interfaces.C.int (Width));
    end Set_Linenumber_Width;


    function Get_Linenumber_Format
           (This : in Text_Display)
        return String
    is
        Result : constant Interfaces.C.Strings.chars_ptr :=
            fl_text_display_get_linenumber_format (This.Void_Ptr);
    begin
        if Result = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Result);
        end if;
    end Get_Linenumber_Format;


    procedure Set_Linenumber_Format
           (This  : in out Text_Display;
            Value : in     String) is
    begin
        fl_text_display_set_linenumber_format (This.Void_Ptr, Interfaces.C.To_C (Value));
    end Set_Linenumber_Format;




    --  Text Measurement  --

    function Measure_Character
           (This  : in Text_Display;
            Text  : in String;
            X     : in Integer;
            Index : in Positive)
        return Long_Float is
    begin
        return Long_Float (fl_text_display_measure_proportional_character
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (X),
            Interfaces.C.int (Index) - 1));
    end Measure_Character;


    function Measure_Visible_Line
           (This : in Text_Display;
            Line : in Natural)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_text_display_measure_vline
           (This.Void_Ptr,
            Interfaces.C.int (Line));
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::measure_vline returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Measure_Visible_Line;


    function Measure_String
           (This  : in Text_Display;
            Text  : in String;
            Style : in Styles.Style_Index)
        return Long_Float is
    begin
        return Long_Float (fl_text_display_string_width
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Text'Length,
            Character'Pos (Character (Style))));
    end Measure_String;




    --  Movement  --

    procedure Move_Down
           (This : in out Text_Display)
    is
        Result : constant Interfaces.C.int := fl_text_display_move_down (This.Void_Ptr);
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_down returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Down;


    function Move_Down
           (This : in out Text_Display)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_move_down (This.Void_Ptr);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_down returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Down;


    procedure Move_Left
           (This : in out Text_Display)
    is
        Result : constant Interfaces.C.int := fl_text_display_move_left (This.Void_Ptr);
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_left returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Left;


    function Move_Left
           (This : in out Text_Display)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_move_left (This.Void_Ptr);
    begin
        return Boolean'Val (Result);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_left returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Left;


    procedure Move_Right
           (This : in out Text_Display)
    is
        Result : constant Interfaces.C.int := fl_text_display_move_right (This.Void_Ptr);
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_right returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Right;


    function Move_Right
           (This : in out Text_Display)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_move_right (This.Void_Ptr);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_right returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Right;


    procedure Move_Up
           (This : in out Text_Display)
    is
        Result : constant Interfaces.C.int := fl_text_display_move_up (This.Void_Ptr);
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_up returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Up;


    function Move_Up
           (This : in out Text_Display)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_move_up (This.Void_Ptr);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::move_up returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Move_Up;




    --  Scrolling  --

    procedure Scroll_To
           (This   : in out Text_Display;
            Line   : in     Natural;
            Column : in     Natural := 0) is
    begin
        fl_text_display_scroll
           (This.Void_Ptr,
            Interfaces.C.int (Line),
            Interfaces.C.int (Column));
    end Scroll_To;


    function Scroll_To
           (This  : in out Text_Display;
            Line  : in     Natural;
            Pixel : in     Natural := 0)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_text_display_scroll2
           (This.Void_Ptr,
            Interfaces.C.int (Line),
            Interfaces.C.int (Pixel));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Text_Display::scroll_ returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Scroll_To;


    function Get_Scrollbar_Alignment
           (This : in Text_Display)
        return Alignment is
    begin
        return Alignment (fl_text_display_get_scrollbar_align (This.Void_Ptr));
    end Get_Scrollbar_Alignment;


    procedure Set_Scrollbar_Alignment
           (This  : in out Text_Display;
            Align : in     Alignment) is
    begin
        fl_text_display_set_scrollbar_align
           (This.Void_Ptr,
            Interfaces.C.unsigned (Align));
    end Set_Scrollbar_Alignment;


    function Get_Scrollbar_Width
           (This : in Text_Display)
        return Natural is
    begin
        return Natural (fl_text_display_get_scrollbar_width (This.Void_Ptr));
    end Get_Scrollbar_Width;


    procedure Set_Scrollbar_Width
           (This  : in out Text_Display;
            Width : in     Natural) is
    begin
        fl_text_display_set_scrollbar_width
           (This.Void_Ptr,
            Interfaces.C.int (Width));
    end Set_Scrollbar_Width;


    procedure Update_Horizontal_Scrollbar
           (This : in out Text_Display) is
    begin
        fl_text_display_update_h_scrollbar (This.Void_Ptr);
    end Update_Horizontal_Scrollbar;


    procedure Update_Vertical_Scrollbar
           (This : in out Text_Display) is
    begin
        fl_text_display_update_v_scrollbar (This.Void_Ptr);
    end Update_Vertical_Scrollbar;




    --  Shortcuts  --

    function Get_Shortcut
           (This : in Text_Display)
        return Key_Combo is
    begin
        return To_Ada (Interfaces.C.unsigned (fl_text_display_get_shortcut (This.Void_Ptr)));
    end Get_Shortcut;


    procedure Set_Shortcut
           (This  : in out Text_Display;
            Value : in     Key_Combo) is
    begin
        fl_text_display_set_shortcut (This.Void_Ptr, Interfaces.C.int (To_C (Value)));
    end Set_Shortcut;




    --  Dimensions  --

    procedure Resize
           (This       : in out Text_Display;
            X, Y, W, H : in     Integer) is
    begin
        fl_text_display_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;




    --  Drawing, Events  --

    procedure Clear_Rect
           (This       : in out Text_Display;
            Style      : in     Styles.Style_Info;
            X, Y, W, H : in     Integer) is
    begin
        fl_text_display_clear_rect
           (This.Void_Ptr,
            Style_Info_To_Cint (Style),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Clear_Rect;


    procedure Display_Insert
           (This : in out Text_Display) is
    begin
        fl_text_display_display_insert (This.Void_Ptr);
    end Display_Insert;


    procedure Redisplay_Range
           (This          : in out Text_Display;
            Start, Finish : in     Natural) is
    begin
        fl_text_display_redisplay_range
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Finish));
    end Redisplay_Range;


    procedure Draw
           (This : in out Text_Display) is
    begin
        Group (This).Draw;
    end Draw;


    procedure Draw_Cursor
           (This : in out Text_Display;
            X, Y : in     Integer) is
    begin
        fl_text_display_draw_cursor
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Draw_Cursor;


    procedure Draw_Line_Numbers
           (This  : in out Text_Display;
            Clear : in     Boolean :=  False) is
    begin
        fl_text_display_draw_line_numbers (This.Void_Ptr, Boolean'Pos (Clear));
    end Draw_Line_Numbers;


    procedure Draw_Range
           (This          : in out Text_Display;
            Start, Finish : in     Natural) is
    begin
        fl_text_display_draw_range
           (This.Void_Ptr,
            Interfaces.C.int (Start),
            Interfaces.C.int (Finish));
    end Draw_Range;


    procedure Draw_String
           (This      : in out Text_Display;
            Style     : in     Styles.Style_Info;
            X, Y      : in     Integer;
            Right     : in     Integer;
            Text      : in     String;
            Num_Chars : in     Natural) is
    begin
        fl_text_display_draw_string
           (This.Void_Ptr,
            Style_Info_To_Cint (Style),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (Right),
            Interfaces.C.To_C (Text),
            Interfaces.C.int (Num_Chars));
    end Draw_String;


    procedure Draw_Text
           (This       : in out Text_Display;
            X, Y, W, H : in     Integer) is
    begin
        fl_text_display_draw_text
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw_Text;


    procedure Draw_Visible_Line
           (This                  : in out Text_Display;
            Line                  : in     Natural;
            Left_Clip, Right_Clip : in     Integer;
            Left_Char, Right_Char : in     Natural) is
    begin
        fl_text_display_draw_vline
           (This.Void_Ptr,
            Interfaces.C.int (Line),
            Interfaces.C.int (Left_Clip),
            Interfaces.C.int (Right_Clip),
            Interfaces.C.int (Left_Char),
            Interfaces.C.int (Right_Char));
    end Draw_Visible_Line;


    function Handle
           (This  : in out Text_Display;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Text_Displays;


