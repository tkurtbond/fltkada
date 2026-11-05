

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Widgets.Groups.Terminals is


    package ICS renames Interfaces.C.Strings;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_terminal
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_terminal, "new_fl_terminal");
    pragma Inline (new_fl_terminal);

    function new_fl_terminal2
           (X, Y, W, H        : in Interfaces.C.int;
            Text              : in Interfaces.C.char_array;
            Rows, Cols, Hist  : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_terminal2, "new_fl_terminal2");
    pragma Inline (new_fl_terminal2);

    function fl_terminal_fits
           (Rows, Hist, Cols : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_fits, "fl_terminal_fits");
    pragma Inline (fl_terminal_fits);

    procedure free_fl_terminal
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_terminal, "free_fl_terminal");
    pragma Inline (free_fl_terminal);




    --  Text Output  --

    procedure fl_terminal_append
           (T   : in Storage.Integer_Address;
            S   : in Interfaces.C.char_array;
            Len : in Interfaces.C.int);
    pragma Import (C, fl_terminal_append, "fl_terminal_append");
    pragma Inline (fl_terminal_append);

    procedure fl_terminal_append_utf8
           (T   : in Storage.Integer_Address;
            S   : in Interfaces.C.char_array;
            Len : in Interfaces.C.int);
    pragma Import (C, fl_terminal_append_utf8, "fl_terminal_append_utf8");
    pragma Inline (fl_terminal_append_utf8);

    procedure fl_terminal_append_ascii
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.char_array);
    pragma Import (C, fl_terminal_append_ascii, "fl_terminal_append_ascii");
    pragma Inline (fl_terminal_append_ascii);

    procedure fl_terminal_print_char
           (T   : in Storage.Integer_Address;
            S   : in Interfaces.C.char_array;
            Len : in Interfaces.C.int);
    pragma Import (C, fl_terminal_print_char, "fl_terminal_print_char");
    pragma Inline (fl_terminal_print_char);

    procedure fl_terminal_print_char2
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.char);
    pragma Import (C, fl_terminal_print_char2, "fl_terminal_print_char2");
    pragma Inline (fl_terminal_print_char2);

    procedure fl_terminal_plot_char
           (T    : in Storage.Integer_Address;
            S    : in Interfaces.C.char_array;
            Len  : in Interfaces.C.int;
            R, C : in Interfaces.C.int);
    pragma Import (C, fl_terminal_plot_char, "fl_terminal_plot_char");
    pragma Inline (fl_terminal_plot_char);

    procedure fl_terminal_plot_char2
           (T    : in Storage.Integer_Address;
            Ch   : in Interfaces.C.char;
            R, C : in Interfaces.C.int);
    pragma Import (C, fl_terminal_plot_char2, "fl_terminal_plot_char2");
    pragma Inline (fl_terminal_plot_char2);

    function fl_terminal_text
           (T : in Storage.Integer_Address;
            B : in Interfaces.C.int)
        return ICS.chars_ptr;
    pragma Import (C, fl_terminal_text, "fl_terminal_text");
    pragma Inline (fl_terminal_text);

    procedure fl_terminal_free_text
           (S : in ICS.chars_ptr);
    pragma Import (C, fl_terminal_free_text, "fl_terminal_free_text");
    pragma Inline (fl_terminal_free_text);




    --  Clearing  --

    procedure fl_terminal_clear
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_terminal_clear, "fl_terminal_clear");
    pragma Inline (fl_terminal_clear);

    procedure fl_terminal_clear2
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_clear2, "fl_terminal_clear2");
    pragma Inline (fl_terminal_clear2);

    procedure fl_terminal_clear_screen
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_terminal_clear_screen, "fl_terminal_clear_screen");
    pragma Inline (fl_terminal_clear_screen);

    procedure fl_terminal_clear_screen_home
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_terminal_clear_screen_home, "fl_terminal_clear_screen_home");
    pragma Inline (fl_terminal_clear_screen_home);

    procedure fl_terminal_clear_history
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_terminal_clear_history, "fl_terminal_clear_history");
    pragma Inline (fl_terminal_clear_history);

    procedure fl_terminal_reset_terminal
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_terminal_reset_terminal, "fl_terminal_reset_terminal");
    pragma Inline (fl_terminal_reset_terminal);




    --  Cursor  --

    procedure fl_terminal_cursor_home
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_terminal_cursor_home, "fl_terminal_cursor_home");
    pragma Inline (fl_terminal_cursor_home);

    procedure fl_terminal_cursor_move
           (T       : in Storage.Integer_Address;
            W, C, S : in Interfaces.C.int);
    pragma Import (C, fl_terminal_cursor_move, "fl_terminal_cursor_move");
    pragma Inline (fl_terminal_cursor_move);

    function fl_terminal_get_cursor_row
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_cursor_row, "fl_terminal_get_cursor_row");
    pragma Inline (fl_terminal_get_cursor_row);

    procedure fl_terminal_set_cursor_row
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_cursor_row, "fl_terminal_set_cursor_row");
    pragma Inline (fl_terminal_set_cursor_row);

    function fl_terminal_get_cursor_col
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_cursor_col, "fl_terminal_get_cursor_col");
    pragma Inline (fl_terminal_get_cursor_col);

    procedure fl_terminal_set_cursor_col
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_cursor_col, "fl_terminal_set_cursor_col");
    pragma Inline (fl_terminal_set_cursor_col);

    function fl_terminal_get_cursorfgcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_cursorfgcolor, "fl_terminal_get_cursorfgcolor");
    pragma Inline (fl_terminal_get_cursorfgcolor);

    procedure fl_terminal_set_cursorfgcolor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_cursorfgcolor, "fl_terminal_set_cursorfgcolor");
    pragma Inline (fl_terminal_set_cursorfgcolor);

    function fl_terminal_get_cursorbgcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_cursorbgcolor, "fl_terminal_get_cursorbgcolor");
    pragma Inline (fl_terminal_get_cursorbgcolor);

    procedure fl_terminal_set_cursorbgcolor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_cursorbgcolor, "fl_terminal_set_cursorbgcolor");
    pragma Inline (fl_terminal_set_cursorbgcolor);




    --  Sizes  --

    function fl_terminal_get_display_rows
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_display_rows, "fl_terminal_get_display_rows");
    pragma Inline (fl_terminal_get_display_rows);

    function fl_terminal_set_display_rows
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_set_display_rows, "fl_terminal_set_display_rows");
    pragma Inline (fl_terminal_set_display_rows);

    function fl_terminal_get_display_columns
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_display_columns, "fl_terminal_get_display_columns");
    pragma Inline (fl_terminal_get_display_columns);

    function fl_terminal_set_display_columns
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_set_display_columns, "fl_terminal_set_display_columns");
    pragma Inline (fl_terminal_set_display_columns);

    function fl_terminal_get_history_rows
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_history_rows, "fl_terminal_get_history_rows");
    pragma Inline (fl_terminal_get_history_rows);

    function fl_terminal_set_history_rows
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_set_history_rows, "fl_terminal_set_history_rows");
    pragma Inline (fl_terminal_set_history_rows);

    function fl_terminal_get_history_lines
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_history_lines, "fl_terminal_get_history_lines");
    pragma Inline (fl_terminal_get_history_lines);

    function fl_terminal_set_history_lines
           (T : in Storage.Integer_Address;
            L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_set_history_lines, "fl_terminal_set_history_lines");
    pragma Inline (fl_terminal_set_history_lines);

    function fl_terminal_get_history_use
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_history_use, "fl_terminal_get_history_use");
    pragma Inline (fl_terminal_get_history_use);

    function fl_terminal_get_redraw_rate
           (T : in Storage.Integer_Address)
        return Interfaces.C.C_float;
    pragma Import (C, fl_terminal_get_redraw_rate, "fl_terminal_get_redraw_rate");
    pragma Inline (fl_terminal_get_redraw_rate);

    procedure fl_terminal_set_redraw_rate
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.C_float);
    pragma Import (C, fl_terminal_set_redraw_rate, "fl_terminal_set_redraw_rate");
    pragma Inline (fl_terminal_set_redraw_rate);

    function fl_terminal_get_redraw_style
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_redraw_style, "fl_terminal_get_redraw_style");
    pragma Inline (fl_terminal_get_redraw_style);

    procedure fl_terminal_set_redraw_style
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_redraw_style, "fl_terminal_set_redraw_style");
    pragma Inline (fl_terminal_set_redraw_style);




    --  Behaviour  --

    function fl_terminal_get_ansi
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_ansi, "fl_terminal_get_ansi");
    pragma Inline (fl_terminal_get_ansi);

    procedure fl_terminal_set_ansi
           (T : in Storage.Integer_Address;
            A : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_ansi, "fl_terminal_set_ansi");
    pragma Inline (fl_terminal_set_ansi);

    function fl_terminal_get_show_unknown
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_show_unknown, "fl_terminal_get_show_unknown");
    pragma Inline (fl_terminal_get_show_unknown);

    procedure fl_terminal_set_show_unknown
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_show_unknown, "fl_terminal_set_show_unknown");
    pragma Inline (fl_terminal_set_show_unknown);

    function fl_terminal_get_error_char
           (T : in Storage.Integer_Address)
        return ICS.chars_ptr;
    pragma Import (C, fl_terminal_get_error_char, "fl_terminal_get_error_char");
    pragma Inline (fl_terminal_get_error_char);

    function fl_terminal_set_error_char
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_set_error_char, "fl_terminal_set_error_char");
    pragma Inline (fl_terminal_set_error_char);

    function fl_terminal_get_output_translate
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_output_translate, "fl_terminal_get_output_translate");
    pragma Inline (fl_terminal_get_output_translate);

    procedure fl_terminal_set_output_translate
           (T : in Storage.Integer_Address;
            O : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_output_translate, "fl_terminal_set_output_translate");
    pragma Inline (fl_terminal_set_output_translate);




    --  Text Font, Size, Color, Attributes  --

    function fl_terminal_get_textfont
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_textfont, "fl_terminal_get_textfont");
    pragma Inline (fl_terminal_get_textfont);

    procedure fl_terminal_set_textfont
           (T : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_textfont, "fl_terminal_set_textfont");
    pragma Inline (fl_terminal_set_textfont);

    function fl_terminal_get_textsize
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_textsize, "fl_terminal_get_textsize");
    pragma Inline (fl_terminal_get_textsize);

    function fl_terminal_set_textsize
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_set_textsize, "fl_terminal_set_textsize");
    pragma Inline (fl_terminal_set_textsize);

    function fl_terminal_get_textcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_textcolor, "fl_terminal_get_textcolor");
    pragma Inline (fl_terminal_get_textcolor);

    procedure fl_terminal_set_textcolor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_textcolor, "fl_terminal_set_textcolor");
    pragma Inline (fl_terminal_set_textcolor);

    function fl_terminal_get_textfgcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_textfgcolor, "fl_terminal_get_textfgcolor");
    pragma Inline (fl_terminal_get_textfgcolor);

    procedure fl_terminal_set_textfgcolor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_textfgcolor, "fl_terminal_set_textfgcolor");
    pragma Inline (fl_terminal_set_textfgcolor);

    function fl_terminal_get_textbgcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_textbgcolor, "fl_terminal_get_textbgcolor");
    pragma Inline (fl_terminal_get_textbgcolor);

    procedure fl_terminal_set_textbgcolor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_textbgcolor, "fl_terminal_set_textbgcolor");
    pragma Inline (fl_terminal_set_textbgcolor);

    function fl_terminal_get_textfgcolor_default
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_textfgcolor_default,
        "fl_terminal_get_textfgcolor_default");
    pragma Inline (fl_terminal_get_textfgcolor_default);

    procedure fl_terminal_set_textfgcolor_default
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_textfgcolor_default,
        "fl_terminal_set_textfgcolor_default");
    pragma Inline (fl_terminal_set_textfgcolor_default);

    function fl_terminal_get_textbgcolor_default
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_textbgcolor_default,
        "fl_terminal_get_textbgcolor_default");
    pragma Inline (fl_terminal_get_textbgcolor_default);

    procedure fl_terminal_set_textbgcolor_default
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_textbgcolor_default,
        "fl_terminal_set_textbgcolor_default");
    pragma Inline (fl_terminal_set_textbgcolor_default);

    procedure fl_terminal_set_textfgcolor_xterm
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_terminal_set_textfgcolor_xterm, "fl_terminal_set_textfgcolor_xterm");
    pragma Inline (fl_terminal_set_textfgcolor_xterm);

    procedure fl_terminal_set_textbgcolor_xterm
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_terminal_set_textbgcolor_xterm, "fl_terminal_set_textbgcolor_xterm");
    pragma Inline (fl_terminal_set_textbgcolor_xterm);

    function fl_terminal_get_textattrib
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_terminal_get_textattrib, "fl_terminal_get_textattrib");
    pragma Inline (fl_terminal_get_textattrib);

    procedure fl_terminal_set_textattrib
           (T : in Storage.Integer_Address;
            A : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_terminal_set_textattrib, "fl_terminal_set_textattrib");
    pragma Inline (fl_terminal_set_textattrib);

    function fl_terminal_get_selectionfgcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_selectionfgcolor, "fl_terminal_get_selectionfgcolor");
    pragma Inline (fl_terminal_get_selectionfgcolor);

    procedure fl_terminal_set_selectionfgcolor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_selectionfgcolor, "fl_terminal_set_selectionfgcolor");
    pragma Inline (fl_terminal_set_selectionfgcolor);

    function fl_terminal_get_selectionbgcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_terminal_get_selectionbgcolor, "fl_terminal_get_selectionbgcolor");
    pragma Inline (fl_terminal_get_selectionbgcolor);

    procedure fl_terminal_set_selectionbgcolor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_terminal_set_selectionbgcolor, "fl_terminal_set_selectionbgcolor");
    pragma Inline (fl_terminal_set_selectionbgcolor);




    --  Box  --

    procedure fl_terminal_set_box
           (T : in Storage.Integer_Address;
            B : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_box, "fl_terminal_set_box");
    pragma Inline (fl_terminal_set_box);




    --  Margins  --

    function fl_terminal_get_margin_left
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_margin_left, "fl_terminal_get_margin_left");
    pragma Inline (fl_terminal_get_margin_left);

    procedure fl_terminal_set_margin_left
           (T : in Storage.Integer_Address;
            M : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_margin_left, "fl_terminal_set_margin_left");
    pragma Inline (fl_terminal_set_margin_left);

    function fl_terminal_get_margin_right
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_margin_right, "fl_terminal_get_margin_right");
    pragma Inline (fl_terminal_get_margin_right);

    procedure fl_terminal_set_margin_right
           (T : in Storage.Integer_Address;
            M : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_margin_right, "fl_terminal_set_margin_right");
    pragma Inline (fl_terminal_set_margin_right);

    function fl_terminal_get_margin_top
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_margin_top, "fl_terminal_get_margin_top");
    pragma Inline (fl_terminal_get_margin_top);

    procedure fl_terminal_set_margin_top
           (T : in Storage.Integer_Address;
            M : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_margin_top, "fl_terminal_set_margin_top");
    pragma Inline (fl_terminal_set_margin_top);

    function fl_terminal_get_margin_bottom
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_margin_bottom, "fl_terminal_get_margin_bottom");
    pragma Inline (fl_terminal_get_margin_bottom);

    procedure fl_terminal_set_margin_bottom
           (T : in Storage.Integer_Address;
            M : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_margin_bottom, "fl_terminal_set_margin_bottom");
    pragma Inline (fl_terminal_set_margin_bottom);




    --  Scrollbars  --

    function fl_terminal_get_scrollbar_size
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_scrollbar_size, "fl_terminal_get_scrollbar_size");
    pragma Inline (fl_terminal_get_scrollbar_size);

    procedure fl_terminal_set_scrollbar_size
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_scrollbar_size, "fl_terminal_set_scrollbar_size");
    pragma Inline (fl_terminal_set_scrollbar_size);

    function fl_terminal_get_scrollbar_actual_size
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_scrollbar_actual_size,
        "fl_terminal_get_scrollbar_actual_size");
    pragma Inline (fl_terminal_get_scrollbar_actual_size);

    function fl_terminal_get_hscrollbar_style
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_hscrollbar_style, "fl_terminal_get_hscrollbar_style");
    pragma Inline (fl_terminal_get_hscrollbar_style);

    procedure fl_terminal_set_hscrollbar_style
           (T : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_terminal_set_hscrollbar_style, "fl_terminal_set_hscrollbar_style");
    pragma Inline (fl_terminal_set_hscrollbar_style);




    --  Selection  --

    function fl_terminal_get_selection
           (T                      : in     Storage.Integer_Address;
            SRow, SCol, ERow, ECol :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_get_selection, "fl_terminal_get_selection");
    pragma Inline (fl_terminal_get_selection);

    function fl_terminal_selection_text_len
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_selection_text_len, "fl_terminal_selection_text_len");
    pragma Inline (fl_terminal_selection_text_len);

    function fl_terminal_selection_text
           (T : in Storage.Integer_Address)
        return ICS.chars_ptr;
    pragma Import (C, fl_terminal_selection_text, "fl_terminal_selection_text");
    pragma Inline (fl_terminal_selection_text);




    --  Drawing, Events  --

    procedure fl_terminal_draw
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_terminal_draw, "fl_terminal_draw");
    pragma Inline (fl_terminal_draw);

    function fl_terminal_handle
           (T : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_terminal_handle, "fl_terminal_handle");
    pragma Inline (fl_terminal_handle);




    -----------------------
    --  Flag Conversion  --
    -----------------------

    function "+"
           (Left, Right : in Text_Attributes)
        return Text_Attributes is
    begin
        return
           (Bold      => Left.Bold      or Right.Bold,
            Dim       => Left.Dim       or Right.Dim,
            Italic    => Left.Italic    or Right.Italic,
            Underline => Left.Underline or Right.Underline,
            Inverse   => Left.Inverse   or Right.Inverse,
            Strikeout => Left.Strikeout or Right.Strikeout);
    end "+";


    function "-"
           (Left, Right : in Text_Attributes)
        return Text_Attributes is
    begin
        return
           (Bold      => Left.Bold      and not Right.Bold,
            Dim       => Left.Dim       and not Right.Dim,
            Italic    => Left.Italic    and not Right.Italic,
            Underline => Left.Underline and not Right.Underline,
            Inverse   => Left.Inverse   and not Right.Inverse,
            Strikeout => Left.Strikeout and not Right.Strikeout);
    end "-";


    function "+"
           (Left, Right : in Output_Translation)
        return Output_Translation is
    begin
        return
           (CR_To_LF   => Left.CR_To_LF   or Right.CR_To_LF,
            LF_To_CR   => Left.LF_To_CR   or Right.LF_To_CR,
            LF_To_CRLF => Left.LF_To_CRLF or Right.LF_To_CRLF);
    end "+";


    function "-"
           (Left, Right : in Output_Translation)
        return Output_Translation is
    begin
        return
           (CR_To_LF   => Left.CR_To_LF   and not Right.CR_To_LF,
            LF_To_CR   => Left.LF_To_CR   and not Right.LF_To_CR,
            LF_To_CRLF => Left.LF_To_CRLF and not Right.LF_To_CRLF);
    end "-";


    type Bits is mod 2 ** Interfaces.C.int'Size;

    function Bit
           (Set   : in Boolean;
            Value : in Bits)
        return Bits is
    begin
        return (if Set then Value else 0);
    end Bit;


    --  Bit values from Fl_Terminal::Attrib
    function To_C
           (Attrib : in Text_Attributes)
        return Interfaces.C.unsigned_char is
    begin
        return Interfaces.C.unsigned_char
           (Bit (Attrib.Bold,      16#01#) or
            Bit (Attrib.Dim,       16#02#) or
            Bit (Attrib.Italic,    16#04#) or
            Bit (Attrib.Underline, 16#08#) or
            Bit (Attrib.Inverse,   16#20#) or
            Bit (Attrib.Strikeout, 16#80#));
    end To_C;


    function To_Ada
           (Value : in Interfaces.C.unsigned_char)
        return Text_Attributes
    is
        B : constant Bits := Bits (Value);
    begin
        return
           (Bold      => (B and 16#01#) /= 0,
            Dim       => (B and 16#02#) /= 0,
            Italic    => (B and 16#04#) /= 0,
            Underline => (B and 16#08#) /= 0,
            Inverse   => (B and 16#20#) /= 0,
            Strikeout => (B and 16#80#) /= 0);
    end To_Ada;


    --  Bit values from Fl_Terminal::OutFlags
    function To_C
           (Flags : in Output_Translation)
        return Interfaces.C.int is
    begin
        return Interfaces.C.int
           (Bit (Flags.CR_To_LF,   16#01#) or
            Bit (Flags.LF_To_CR,   16#02#) or
            Bit (Flags.LF_To_CRLF, 16#04#));
    end To_C;


    function To_Ada
           (Value : in Interfaces.C.int)
        return Output_Translation
    is
        B : constant Bits := Bits (Value);
    begin
        return
           (CR_To_LF   => (B and 16#01#) /= 0,
            LF_To_CR   => (B and 16#02#) /= 0,
            LF_To_CRLF => (B and 16#04#) /= 0);
    end To_Ada;


    --  Copies a malloc'd string from the shim into Ada, then frees it
    function Take_String
           (Raw : in ICS.chars_ptr)
        return String is
    begin
        if Raw = ICS.Null_Ptr then
            return "";
        end if;
        declare
            Ada_String : constant String := ICS.Value (Raw);
        begin
            fl_terminal_free_text (Raw);
            return Ada_String;
        end;
    end Take_String;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Terminal) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Terminal) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_terminal (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Terminal;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Terminal) is
    begin
        This.Draw_Ptr   := fl_terminal_draw'Address;
        This.Handle_Ptr := fl_terminal_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Terminal is
        begin
            return This : Terminal do
                This.Void_Ptr := new_fl_terminal
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
            return Terminal is
        begin
            return This : Terminal := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;


        function Create
               (X, Y, W, H : in Integer;
                Rows       : in Integer;
                Columns    : in Integer;
                History    : in Integer;
                Text       : in String := "")
            return Terminal is
        begin
            --  FLTK makes the history 100 rows whatever History says
            --  (Fl_Terminal.cxx:3450), so that is checked too.
            if Rows < 1 or else Columns < 1 or else History < 0
                or else fl_terminal_fits
                   (Interfaces.C.int (Rows),
                    Interfaces.C.int (Integer'Max (History, 100)),
                    Interfaces.C.int (Columns)) = 0
            then
                raise Constraint_Error with "a terminal of" & Integer'Image (Rows) & " by"
                    & Integer'Image (Columns) & " with a history of" & Integer'Image (History);
            end if;
            return This : Terminal do
                This.Void_Ptr := new_fl_terminal2
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text),
                    Interfaces.C.int (Rows),
                    Interfaces.C.int (Columns),
                    Interfaces.C.int (History));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Rows       : in     Integer;
                Columns    : in     Integer;
                History    : in     Integer;
                Text       : in     String := "")
            return Terminal is
        begin
            return This : Terminal := Create (X, Y, W, H, Rows, Columns, History, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Text Output  --

    procedure Append
           (This : in out Terminal;
            Text : in     String) is
    begin
        fl_terminal_append
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (Text'Length));
    end Append;


    procedure Append_UTF8
           (This : in out Terminal;
            Text : in     String) is
    begin
        fl_terminal_append_utf8
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (Text'Length));
    end Append_UTF8;


    procedure Append_ASCII
           (This : in out Terminal;
            Text : in     String) is
    begin
        fl_terminal_append_ascii (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Append_ASCII;


    procedure Print
           (This : in out Terminal;
            Text : in     String) is
    begin
        This.Append (Text);
    end Print;


    procedure Print_Char
           (This : in out Terminal;
            Text : in     String) is
    begin
        fl_terminal_print_char
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (Text'Length));
    end Print_Char;


    procedure Print_Char
           (This : in out Terminal;
            Char : in     Character) is
    begin
        fl_terminal_print_char2 (This.Void_Ptr, Interfaces.C.To_C (Char));
    end Print_Char;


    procedure Plot_Char
           (This   : in out Terminal;
            Text   : in     String;
            Row    : in     Natural;
            Column : in     Natural) is
    begin
        fl_terminal_plot_char
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Interfaces.C.int (Text'Length),
            Interfaces.C.int (Row),
            Interfaces.C.int (Column));
    end Plot_Char;


    procedure Plot_Char
           (This   : in out Terminal;
            Char   : in     Character;
            Row    : in     Natural;
            Column : in     Natural) is
    begin
        fl_terminal_plot_char2
           (This.Void_Ptr,
            Interfaces.C.To_C (Char),
            Interfaces.C.int (Row),
            Interfaces.C.int (Column));
    end Plot_Char;


    function Get_Text
           (This               : in Terminal;
            Lines_Below_Cursor : in Boolean := False)
        return String is
    begin
        return Take_String (fl_terminal_text (This.Void_Ptr, Boolean'Pos (Lines_Below_Cursor)));
    end Get_Text;




    --  Clearing  --

    procedure Clear
           (This : in out Terminal) is
    begin
        fl_terminal_clear (This.Void_Ptr);
    end Clear;


    procedure Clear
           (This : in out Terminal;
            Hue  : in     Color) is
    begin
        fl_terminal_clear2 (This.Void_Ptr, Interfaces.C.unsigned (Hue));
    end Clear;


    procedure Clear_Screen
           (This              : in out Terminal;
            Scroll_To_History : in     Boolean := True) is
    begin
        fl_terminal_clear_screen (This.Void_Ptr, Boolean'Pos (Scroll_To_History));
    end Clear_Screen;


    procedure Clear_Screen_Home
           (This              : in out Terminal;
            Scroll_To_History : in     Boolean := True) is
    begin
        fl_terminal_clear_screen_home (This.Void_Ptr, Boolean'Pos (Scroll_To_History));
    end Clear_Screen_Home;


    procedure Clear_History
           (This : in out Terminal) is
    begin
        fl_terminal_clear_history (This.Void_Ptr);
    end Clear_History;


    procedure Reset_Terminal
           (This : in out Terminal) is
    begin
        fl_terminal_reset_terminal (This.Void_Ptr);
    end Reset_Terminal;




    --  Cursor  --

    procedure Cursor_Home
           (This : in out Terminal) is
    begin
        fl_terminal_cursor_home (This.Void_Ptr);
    end Cursor_Home;


    --  What fl_terminal_cursor_move does, by number
    procedure Move
           (This   : in out Terminal;
            What   : in     Natural;
            Count  : in     Positive := 1;
            Scroll : in     Boolean  := False) is
    begin
        fl_terminal_cursor_move
           (This.Void_Ptr,
            Interfaces.C.int (What),
            Interfaces.C.int (Count),
            Boolean'Pos (Scroll));
    end Move;


    procedure Cursor_Up
           (This   : in out Terminal;
            Count  : in     Positive := 1;
            Scroll : in     Boolean  := False) is
    begin
        Move (This, 0, Count, Scroll);
    end Cursor_Up;


    procedure Cursor_Down
           (This   : in out Terminal;
            Count  : in     Positive := 1;
            Scroll : in     Boolean  := False) is
    begin
        Move (This, 1, Count, Scroll);
    end Cursor_Down;


    procedure Cursor_Left
           (This  : in out Terminal;
            Count : in     Positive := 1) is
    begin
        Move (This, 2, Count);
    end Cursor_Left;


    procedure Cursor_Right
           (This   : in out Terminal;
            Count  : in     Positive := 1;
            Scroll : in     Boolean  := False) is
    begin
        Move (This, 3, Count, Scroll);
    end Cursor_Right;


    procedure Cursor_End_Of_Line
           (This : in out Terminal) is
    begin
        Move (This, 4);
    end Cursor_End_Of_Line;


    procedure Cursor_Start_Of_Line
           (This : in out Terminal) is
    begin
        Move (This, 5);
    end Cursor_Start_Of_Line;


    procedure Cursor_CR
           (This : in out Terminal) is
    begin
        Move (This, 6);
    end Cursor_CR;


    procedure Cursor_CRLF
           (This  : in out Terminal;
            Count : in     Positive := 1) is
    begin
        Move (This, 7, Count);
    end Cursor_CRLF;


    procedure Cursor_Tab_Right
           (This  : in out Terminal;
            Count : in     Positive := 1) is
    begin
        Move (This, 8, Count);
    end Cursor_Tab_Right;


    procedure Cursor_Tab_Left
           (This  : in out Terminal;
            Count : in     Positive := 1) is
    begin
        Move (This, 9, Count);
    end Cursor_Tab_Left;


    procedure Save_Cursor
           (This : in out Terminal) is
    begin
        Move (This, 10);
    end Save_Cursor;


    procedure Restore_Cursor
           (This : in out Terminal) is
    begin
        Move (This, 11);
    end Restore_Cursor;


    function Get_Cursor_Row
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_get_cursor_row (This.Void_Ptr));
    end Get_Cursor_Row;


    procedure Set_Cursor_Row
           (This : in out Terminal;
            To   : in     Natural) is
    begin
        fl_terminal_set_cursor_row (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Cursor_Row;


    function Get_Cursor_Column
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_get_cursor_col (This.Void_Ptr));
    end Get_Cursor_Column;


    procedure Set_Cursor_Column
           (This : in out Terminal;
            To   : in     Natural) is
    begin
        fl_terminal_set_cursor_col (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Cursor_Column;


    function Get_Cursor_Fore_Color
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_cursorfgcolor (This.Void_Ptr));
    end Get_Cursor_Fore_Color;


    procedure Set_Cursor_Fore_Color
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_cursorfgcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Cursor_Fore_Color;


    function Get_Cursor_Back_Color
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_cursorbgcolor (This.Void_Ptr));
    end Get_Cursor_Back_Color;


    procedure Set_Cursor_Back_Color
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_cursorbgcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Cursor_Back_Color;




    --  Sizes  --

    function Get_Display_Rows
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_get_display_rows (This.Void_Ptr));
    end Get_Display_Rows;


    procedure Set_Display_Rows
           (This : in out Terminal;
            To   : in     Natural) is
    begin
        if fl_terminal_set_display_rows (This.Void_Ptr, Interfaces.C.int (To)) = 0 then
            raise Constraint_Error with "too many cells for display rows of" & Natural'Image (To);
        end if;
    end Set_Display_Rows;


    function Get_Display_Columns
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_get_display_columns (This.Void_Ptr));
    end Get_Display_Columns;


    procedure Set_Display_Columns
           (This : in out Terminal;
            To   : in     Natural) is
    begin
        if fl_terminal_set_display_columns (This.Void_Ptr, Interfaces.C.int (To)) = 0 then
            raise Constraint_Error with "too many cells, or none, for display columns of"
                & Natural'Image (To);
        end if;
    end Set_Display_Columns;


    function Get_History_Rows
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_get_history_rows (This.Void_Ptr));
    end Get_History_Rows;


    procedure Set_History_Rows
           (This : in out Terminal;
            To   : in     Natural) is
    begin
        if fl_terminal_set_history_rows (This.Void_Ptr, Interfaces.C.int (To)) = 0 then
            raise Constraint_Error with "too many cells for history rows of" & Natural'Image (To);
        end if;
    end Set_History_Rows;


    function Get_History_Use
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_get_history_use (This.Void_Ptr));
    end Get_History_Use;


    function Get_History_Lines
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_get_history_lines (This.Void_Ptr));
    end Get_History_Lines;


    procedure Set_History_Lines
           (This : in out Terminal;
            To   : in     Natural) is
    begin
        if fl_terminal_set_history_lines (This.Void_Ptr, Interfaces.C.int (To)) = 0 then
            raise Constraint_Error with "too many cells for history lines of" & Natural'Image (To);
        end if;
    end Set_History_Lines;


    function Get_Redraw_Rate
           (This : in Terminal)
        return Float is
    begin
        return Float (fl_terminal_get_redraw_rate (This.Void_Ptr));
    end Get_Redraw_Rate;


    procedure Set_Redraw_Rate
           (This : in out Terminal;
            To   : in     Float) is
    begin
        fl_terminal_set_redraw_rate (This.Void_Ptr, Interfaces.C.C_float (To));
    end Set_Redraw_Rate;


    function Get_Redraw_Style
           (This : in Terminal)
        return Redraw_Style
    is
        Result : constant Interfaces.C.int := fl_terminal_get_redraw_style (This.Void_Ptr);
    begin
        return Redraw_Style'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Terminal::redraw_style returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Redraw_Style;


    procedure Set_Redraw_Style
           (This : in out Terminal;
            To   : in     Redraw_Style) is
    begin
        fl_terminal_set_redraw_style (This.Void_Ptr, Redraw_Style'Pos (To));
    end Set_Redraw_Style;




    --  Behaviour  --

    function Get_ANSI
           (This : in Terminal)
        return Boolean is
    begin
        return fl_terminal_get_ansi (This.Void_Ptr) /= 0;
    end Get_ANSI;


    procedure Set_ANSI
           (This : in out Terminal;
            To   : in     Boolean) is
    begin
        fl_terminal_set_ansi (This.Void_Ptr, Boolean'Pos (To));
    end Set_ANSI;


    function Get_Show_Unknown
           (This : in Terminal)
        return Boolean is
    begin
        return fl_terminal_get_show_unknown (This.Void_Ptr) /= 0;
    end Get_Show_Unknown;


    procedure Set_Show_Unknown
           (This : in out Terminal;
            To   : in     Boolean) is
    begin
        fl_terminal_set_show_unknown (This.Void_Ptr, Boolean'Pos (To));
    end Set_Show_Unknown;


    function Get_Error_Char
           (This : in Terminal)
        return String
    is
        Raw : constant ICS.chars_ptr := fl_terminal_get_error_char (This.Void_Ptr);
    begin
        if Raw = ICS.Null_Ptr then
            return "";
        else
            return ICS.Value (Raw);
        end if;
    end Get_Error_Char;


    procedure Set_Error_Char
           (This : in out Terminal;
            To   : in     String) is
    begin
        if fl_terminal_set_error_char (This.Void_Ptr, Interfaces.C.To_C (To)) = 0 then
            raise Constraint_Error with "not one printable UTF-8 character: """ & To & """";
        end if;
    end Set_Error_Char;


    function Get_Output_Translate
           (This : in Terminal)
        return Output_Translation is
    begin
        return To_Ada (fl_terminal_get_output_translate (This.Void_Ptr));
    end Get_Output_Translate;


    procedure Set_Output_Translate
           (This : in out Terminal;
            To   : in     Output_Translation) is
    begin
        fl_terminal_set_output_translate (This.Void_Ptr, To_C (To));
    end Set_Output_Translate;




    --  Text Font, Size, Color, Attributes  --

    function Get_Text_Font
           (This : in Terminal)
        return Font_Kind
    is
        Result : constant Interfaces.C.int := fl_terminal_get_textfont (This.Void_Ptr);
    begin
        return Font_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Terminal::textfont returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Terminal;
            To   : in     Font_Kind) is
    begin
        fl_terminal_set_textfont (This.Void_Ptr, Font_Kind'Pos (To));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Terminal)
        return Font_Size is
    begin
        return Font_Size (fl_terminal_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Terminal;
            To   : in     Font_Size) is
    begin
        if fl_terminal_set_textsize (This.Void_Ptr, Interfaces.C.int (To)) = 0 then
            raise Constraint_Error with "a text size of 0";
        end if;
    end Set_Text_Size;


    function Get_Text_Color
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Color;


    function Get_Text_Fore_Color
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_textfgcolor (This.Void_Ptr));
    end Get_Text_Fore_Color;


    procedure Set_Text_Fore_Color
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_textfgcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Fore_Color;


    function Get_Text_Back_Color
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_textbgcolor (This.Void_Ptr));
    end Get_Text_Back_Color;


    procedure Set_Text_Back_Color
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_textbgcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Back_Color;


    function Get_Text_Fore_Color_Default
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_textfgcolor_default (This.Void_Ptr));
    end Get_Text_Fore_Color_Default;


    procedure Set_Text_Fore_Color_Default
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_textfgcolor_default (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Fore_Color_Default;


    function Get_Text_Back_Color_Default
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_textbgcolor_default (This.Void_Ptr));
    end Get_Text_Back_Color_Default;


    procedure Set_Text_Back_Color_Default
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_textbgcolor_default (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Text_Back_Color_Default;


    procedure Set_Text_Fore_Color_Xterm
           (This : in out Terminal;
            To   : in     Xterm_Color) is
    begin
        fl_terminal_set_textfgcolor_xterm (This.Void_Ptr, Interfaces.C.unsigned_char (To));
    end Set_Text_Fore_Color_Xterm;


    procedure Set_Text_Back_Color_Xterm
           (This : in out Terminal;
            To   : in     Xterm_Color) is
    begin
        fl_terminal_set_textbgcolor_xterm (This.Void_Ptr, Interfaces.C.unsigned_char (To));
    end Set_Text_Back_Color_Xterm;


    function Get_Text_Attrib
           (This : in Terminal)
        return Text_Attributes is
    begin
        return To_Ada (fl_terminal_get_textattrib (This.Void_Ptr));
    end Get_Text_Attrib;


    procedure Set_Text_Attrib
           (This : in out Terminal;
            To   : in     Text_Attributes) is
    begin
        fl_terminal_set_textattrib (This.Void_Ptr, To_C (To));
    end Set_Text_Attrib;


    function Get_Selection_Fore_Color
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_selectionfgcolor (This.Void_Ptr));
    end Get_Selection_Fore_Color;


    procedure Set_Selection_Fore_Color
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_selectionfgcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Selection_Fore_Color;


    function Get_Selection_Back_Color
           (This : in Terminal)
        return Color is
    begin
        return Color (fl_terminal_get_selectionbgcolor (This.Void_Ptr));
    end Get_Selection_Back_Color;


    procedure Set_Selection_Back_Color
           (This : in out Terminal;
            To   : in     Color) is
    begin
        fl_terminal_set_selectionbgcolor (This.Void_Ptr, Interfaces.C.unsigned (To));
    end Set_Selection_Back_Color;




    --  Box  --

    procedure Set_Box
           (This : in out Terminal;
            Box  : in     Box_Kind) is
    begin
        fl_terminal_set_box (This.Void_Ptr, Box_Kind'Pos (Box));
    end Set_Box;




    --  Margins  --

    function Get_Margin_Left
           (This : in Terminal)
        return Integer is
    begin
        return Integer (fl_terminal_get_margin_left (This.Void_Ptr));
    end Get_Margin_Left;


    procedure Set_Margin_Left
           (This : in out Terminal;
            To   : in     Integer) is
    begin
        fl_terminal_set_margin_left (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Margin_Left;


    function Get_Margin_Right
           (This : in Terminal)
        return Integer is
    begin
        return Integer (fl_terminal_get_margin_right (This.Void_Ptr));
    end Get_Margin_Right;


    procedure Set_Margin_Right
           (This : in out Terminal;
            To   : in     Integer) is
    begin
        fl_terminal_set_margin_right (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Margin_Right;


    function Get_Margin_Top
           (This : in Terminal)
        return Integer is
    begin
        return Integer (fl_terminal_get_margin_top (This.Void_Ptr));
    end Get_Margin_Top;


    procedure Set_Margin_Top
           (This : in out Terminal;
            To   : in     Integer) is
    begin
        fl_terminal_set_margin_top (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Margin_Top;


    function Get_Margin_Bottom
           (This : in Terminal)
        return Integer is
    begin
        return Integer (fl_terminal_get_margin_bottom (This.Void_Ptr));
    end Get_Margin_Bottom;


    procedure Set_Margin_Bottom
           (This : in out Terminal;
            To   : in     Integer) is
    begin
        fl_terminal_set_margin_bottom (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Margin_Bottom;




    --  Scrollbars  --

    function Get_Scrollbar_Size
           (This : in Terminal)
        return Integer is
    begin
        return Integer (fl_terminal_get_scrollbar_size (This.Void_Ptr));
    end Get_Scrollbar_Size;


    procedure Set_Scrollbar_Size
           (This : in out Terminal;
            To   : in     Integer) is
    begin
        fl_terminal_set_scrollbar_size (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Scrollbar_Size;


    function Get_Scrollbar_Actual_Size
           (This : in Terminal)
        return Integer is
    begin
        return Integer (fl_terminal_get_scrollbar_actual_size (This.Void_Ptr));
    end Get_Scrollbar_Actual_Size;


    function Get_Hscrollbar_Style
           (This : in Terminal)
        return Scrollbar_Style
    is
        Result : constant Interfaces.C.int := fl_terminal_get_hscrollbar_style (This.Void_Ptr);
    begin
        return Scrollbar_Style'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Terminal::hscrollbar_style returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Hscrollbar_Style;


    procedure Set_Hscrollbar_Style
           (This : in out Terminal;
            To   : in     Scrollbar_Style) is
    begin
        fl_terminal_set_hscrollbar_style (This.Void_Ptr, Scrollbar_Style'Pos (To));
    end Set_Hscrollbar_Style;




    --  Selection  --

    function Get_Selection
           (This         : in     Terminal;
            Start_Row    :    out Integer;
            Start_Column :    out Integer;
            End_Row      :    out Integer;
            End_Column   :    out Integer)
        return Boolean
    is
        SRow, SCol, ERow, ECol : Interfaces.C.int := 0;
        Result : constant Interfaces.C.int :=
            fl_terminal_get_selection (This.Void_Ptr, SRow, SCol, ERow, ECol);
    begin
        Start_Row    := Integer (SRow);
        Start_Column := Integer (SCol);
        End_Row      := Integer (ERow);
        End_Column   := Integer (ECol);
        return Result /= 0;
    end Get_Selection;


    function Selection_Text_Length
           (This : in Terminal)
        return Natural is
    begin
        return Natural (fl_terminal_selection_text_len (This.Void_Ptr));
    end Selection_Text_Length;


    function Selection_Text
           (This : in Terminal)
        return String is
    begin
        return Take_String (fl_terminal_selection_text (This.Void_Ptr));
    end Selection_Text;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Terminal) is
    begin
        Group (This).Draw;
    end Draw;


    function Handle
           (This  : in out Terminal;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Terminals;

