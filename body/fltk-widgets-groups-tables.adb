

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Characters.Latin_1,
    Interfaces.C,
    System.Address_To_Access_Conversions;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Tables is


    package Chk   renames Ada.Assertions;
    package Latin renames Ada.Characters.Latin_1;




    ------------------------
    --  Constants From C  --
    ------------------------

    fl_context_none : constant Interfaces.C.int;
    pragma Import (C, fl_context_none, "fl_context_none");

    fl_context_startpage : constant Interfaces.C.int;
    pragma Import (C, fl_context_startpage, "fl_context_startpage");

    fl_context_endpage : constant Interfaces.C.int;
    pragma Import (C, fl_context_endpage, "fl_context_endpage");

    fl_context_row_header : constant Interfaces.C.int;
    pragma Import (C, fl_context_row_header, "fl_context_row_header");

    fl_context_col_header : constant Interfaces.C.int;
    pragma Import (C, fl_context_col_header, "fl_context_col_header");

    fl_context_cell : constant Interfaces.C.int;
    pragma Import (C, fl_context_cell, "fl_context_cell");

    fl_context_table : constant Interfaces.C.int;
    pragma Import (C, fl_context_table, "fl_context_table");

    fl_context_rc_resize : constant Interfaces.C.int;
    pragma Import (C, fl_context_rc_resize, "fl_context_rc_resize");




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_table
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_table, "new_fl_table");
    pragma Inline (new_fl_table);

    procedure free_fl_table
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_table, "free_fl_table");
    pragma Inline (free_fl_table);




    --  Attributes  --

    function fl_table_hscrollbar
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_table_hscrollbar, "fl_table_hscrollbar");
    pragma Inline (fl_table_hscrollbar);

    function fl_table_vscrollbar
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_table_vscrollbar, "fl_table_vscrollbar");
    pragma Inline (fl_table_vscrollbar);

    function fl_table_table
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_table_table, "fl_table_table");
    pragma Inline (fl_table_table);




    --  Contents Modification  --

    procedure fl_table_add
           (T, W : in Storage.Integer_Address);
    pragma Import (C, fl_table_add, "fl_table_add");
    pragma Inline (fl_table_add);

    procedure fl_table_insert
           (T, W : in Storage.Integer_Address;
            P    : in Interfaces.C.int);
    pragma Import (C, fl_table_insert, "fl_table_insert");
    pragma Inline (fl_table_insert);

    procedure fl_table_insert2
           (T, W, B : in Storage.Integer_Address);
    pragma Import (C, fl_table_insert2, "fl_table_insert2");
    pragma Inline (fl_table_insert2);

    procedure fl_table_remove
           (T, W : in Storage.Integer_Address);
    pragma Import (C, fl_table_remove, "fl_table_remove");
    pragma Inline (fl_table_remove);




    --  Contents Query  --

    function fl_table_child
           (T : in Storage.Integer_Address;
            P : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_table_child, "fl_table_child");
    pragma Inline (fl_table_child);

    function fl_table_find
           (T, W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_find, "fl_table_find");
    pragma Inline (fl_table_find);

    function fl_table_children
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_children, "fl_table_children");
    pragma Inline (fl_table_children);

    function fl_table_is_fltk_container
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_is_fltk_container, "fl_table_is_fltk_container");
    pragma Inline (fl_table_is_fltk_container);




    --  Current  --

    procedure fl_table_begin
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_begin, "fl_table_begin");
    pragma Inline (fl_table_begin);

    procedure fl_table_end
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_end, "fl_table_end");
    pragma Inline (fl_table_end);




    --  Callbacks  --

    procedure fl_table_set_callback
           (T, F : in Storage.Integer_Address);
    pragma Import (C, fl_table_set_callback, "fl_table_set_callback");
    pragma Inline (fl_table_set_callback);

    function fl_table_callback_col
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_callback_col, "fl_table_callback_col");
    pragma Inline (fl_table_callback_col);

    function fl_table_callback_row
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_callback_row, "fl_table_callback_row");
    pragma Inline (fl_table_callback_row);

    function fl_table_callback_context
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_callback_context, "fl_table_callback_context");
    pragma Inline (fl_table_callback_context);

    procedure fl_table_do_callback
           (T       : in Storage.Integer_Address;
            X, R, C : in Interfaces.C.int);
    pragma Import (C, fl_table_do_callback, "fl_table_do_callback");
    pragma Inline (fl_table_do_callback);

    procedure fl_table_when
           (T : in Storage.Integer_Address;
            W : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_table_when, "fl_table_when");
    pragma Inline (fl_table_when);

    procedure fl_table_scroll_cb
           (S, T : in Storage.Integer_Address);
    pragma Import (C, fl_table_scroll_cb, "fl_table_scroll_cb");
    pragma Inline (fl_table_scroll_cb);




    --  Columns  --

    function fl_table_get_col_header
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_col_header, "fl_table_get_col_header");
    pragma Inline (fl_table_get_col_header);

    procedure fl_table_set_col_header
           (T : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_table_set_col_header, "fl_table_set_col_header");
    pragma Inline (fl_table_set_col_header);

    function fl_table_get_col_header_color
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_table_get_col_header_color, "fl_table_get_col_header_color");
    pragma Inline (fl_table_get_col_header_color);

    procedure fl_table_set_col_header_color
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_table_set_col_header_color, "fl_table_set_col_header_color");
    pragma Inline (fl_table_set_col_header_color);

    function fl_table_get_col_header_height
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_col_header_height, "fl_table_get_col_header_height");
    pragma Inline (fl_table_get_col_header_height);

    procedure fl_table_set_col_header_height
           (T : in Storage.Integer_Address;
            H : in Interfaces.C.int);
    pragma Import (C, fl_table_set_col_header_height, "fl_table_set_col_header_height");
    pragma Inline (fl_table_set_col_header_height);

    function fl_table_get_col_width
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_col_width, "fl_table_get_col_width");
    pragma Inline (fl_table_get_col_width);

    procedure fl_table_set_col_width
           (T    : in Storage.Integer_Address;
            C, W : in Interfaces.C.int);
    pragma Import (C, fl_table_set_col_width, "fl_table_set_col_width");
    pragma Inline (fl_table_set_col_width);

    procedure fl_table_col_width_all
           (T : in Storage.Integer_Address;
            W : in Interfaces.C.int);
    pragma Import (C, fl_table_col_width_all, "fl_table_col_width_all");
    pragma Inline (fl_table_col_width_all);

    function fl_table_get_cols
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_cols, "fl_table_get_cols");
    pragma Inline (fl_table_get_cols);

    procedure fl_table_set_cols
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_table_set_cols, "fl_table_set_cols");
    pragma Inline (fl_table_set_cols);

    function fl_table_get_col_position
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_col_position, "fl_table_get_col_position");
    pragma Inline (fl_table_get_col_position);

    procedure fl_table_set_col_position
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_table_set_col_position, "fl_table_set_col_position");
    pragma Inline (fl_table_set_col_position);

    function fl_table_col_scroll_position
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.long;
    pragma Import (C, fl_table_col_scroll_position, "fl_table_col_scroll_position");
    pragma Inline (fl_table_col_scroll_position);

    function fl_table_get_col_resize
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_col_resize, "fl_table_get_col_resize");
    pragma Inline (fl_table_get_col_resize);

    procedure fl_table_set_col_resize
           (T : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_table_set_col_resize, "fl_table_set_col_resize");
    pragma Inline (fl_table_set_col_resize);

    function fl_table_get_col_resize_min
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_col_resize_min, "fl_table_get_col_resize_min");
    pragma Inline (fl_table_get_col_resize_min);

    procedure fl_table_set_col_resize_min
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_table_set_col_resize_min, "fl_table_set_col_resize_min");
    pragma Inline (fl_table_set_col_resize_min);




    --  Rows  --

    function fl_table_get_row_header
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_row_header, "fl_table_get_row_header");
    pragma Inline (fl_table_get_row_header);

    procedure fl_table_set_row_header
           (T : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_table_set_row_header, "fl_table_set_row_header");
    pragma Inline (fl_table_set_row_header);

    function fl_table_get_row_header_color
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_table_get_row_header_color, "fl_table_get_row_header_color");
    pragma Inline (fl_table_get_row_header_color);

    procedure fl_table_set_row_header_color
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_table_set_row_header_color, "fl_table_set_row_header_color");
    pragma Inline (fl_table_set_row_header_color);

    function fl_table_get_row_header_width
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_row_header_width, "fl_table_get_row_header_width");
    pragma Inline (fl_table_get_row_header_width);

    procedure fl_table_set_row_header_width
           (T : in Storage.Integer_Address;
            W : in Interfaces.C.int);
    pragma Import (C, fl_table_set_row_header_width, "fl_table_set_row_header_width");
    pragma Inline (fl_table_set_row_header_width);

    function fl_table_get_row_height
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_row_height, "fl_table_get_row_height");
    pragma Inline (fl_table_get_row_height);

    procedure fl_table_set_row_height
           (T    : in Storage.Integer_Address;
            R, H : in Interfaces.C.int);
    pragma Import (C, fl_table_set_row_height, "fl_table_set_row_height");
    pragma Inline (fl_table_set_row_height);

    procedure fl_table_row_height_all
           (T : in Storage.Integer_Address;
            H : in Interfaces.C.int);
    pragma Import (C, fl_table_row_height_all, "fl_table_row_height_all");
    pragma Inline (fl_table_row_height_all);

    function fl_table_get_rows
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_rows, "fl_table_get_rows");
    pragma Inline (fl_table_get_rows);

    procedure fl_table_set_rows
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int);
    pragma Import (C, fl_table_set_rows, "fl_table_set_rows");
    pragma Inline (fl_table_set_rows);

    function fl_table_get_row_position
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_row_position, "fl_table_get_row_position");
    pragma Inline (fl_table_get_row_position);

    procedure fl_table_set_row_position
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_table_set_row_position, "fl_table_set_row_position");
    pragma Inline (fl_table_set_row_position);

    function fl_table_row_scroll_position
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int)
        return Interfaces.C.long;
    pragma Import (C, fl_table_row_scroll_position, "fl_table_row_scroll_position");
    pragma Inline (fl_table_row_scroll_position);

    function fl_table_get_row_resize
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_row_resize, "fl_table_get_row_resize");
    pragma Inline (fl_table_get_row_resize);

    procedure fl_table_set_row_resize
           (T : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_table_set_row_resize, "fl_table_set_row_resize");
    pragma Inline (fl_table_set_row_resize);

    function fl_table_get_row_resize_min
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_row_resize_min, "fl_table_get_row_resize_min");
    pragma Inline (fl_table_get_row_resize_min);

    procedure fl_table_set_row_resize_min
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_table_set_row_resize_min, "fl_table_set_row_resize_min");
    pragma Inline (fl_table_set_row_resize_min);

    function fl_table_get_top_row
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_top_row, "fl_table_get_top_row");
    pragma Inline (fl_table_get_top_row);

    procedure fl_table_set_top_row
           (T : in Storage.Integer_Address;
            R : in Interfaces.C.int);
    pragma Import (C, fl_table_set_top_row, "fl_table_set_top_row");
    pragma Inline (fl_table_set_top_row);




    --  Selection  --

    procedure fl_table_change_cursor
           (T : in Storage.Integer_Address;
            C : in Interfaces.C.int);
    pragma Import (C, fl_table_change_cursor, "fl_table_change_cursor");
    pragma Inline (fl_table_change_cursor);

    function fl_table_cursor2rowcol
           (T       : in     Storage.Integer_Address;
            R, C, F :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_cursor2rowcol, "fl_table_cursor2rowcol");
    pragma Inline (fl_table_cursor2rowcol);

    procedure fl_table_visible_cells
           (T              : in     Storage.Integer_Address;
            R1, R2, C1, C2 :    out Interfaces.C.int);
    pragma Import (C, fl_table_visible_cells, "fl_table_visible_cells");
    pragma Inline (fl_table_visible_cells);

    procedure fl_table_get_selection
           (T              : in     Storage.Integer_Address;
            RT, CL, RB, CR :    out Interfaces.C.int);
    pragma Import (C, fl_table_get_selection, "fl_table_get_selection");
    pragma Inline (fl_table_get_selection);

    procedure fl_table_set_selection
           (T              : in Storage.Integer_Address;
            RT, CL, RB, CR : in Interfaces.C.int);
    pragma Import (C, fl_table_set_selection, "fl_table_set_selection");
    pragma Inline (fl_table_set_selection);

    function fl_table_is_selected
           (T    : in Storage.Integer_Address;
            R, C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_is_selected, "fl_table_is_selected");
    pragma Inline (fl_table_is_selected);

    function fl_table_move_cursor
           (T       : in Storage.Integer_Address;
            R, C, S : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_move_cursor, "fl_table_move_cursor");
    pragma Inline (fl_table_move_cursor);

    function fl_table_get_tab_cell_nav
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_tab_cell_nav, "fl_table_get_tab_cell_nav");
    pragma Inline (fl_table_get_tab_cell_nav);

    procedure fl_table_set_tab_cell_nav
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_table_set_tab_cell_nav, "fl_table_set_tab_cell_nav");
    pragma Inline (fl_table_set_tab_cell_nav);

    function fl_table_get_table_box
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_table_box, "fl_table_get_table_box");
    pragma Inline (fl_table_get_table_box);

    procedure fl_table_set_table_box
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_table_set_table_box, "fl_table_set_table_box");
    pragma Inline (fl_table_set_table_box);




    --  Dimensions  --

    function fl_table_get_scrollbar_size
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_get_scrollbar_size, "fl_table_get_scrollbar_size");
    pragma Inline (fl_table_get_scrollbar_size);

    procedure fl_table_set_scrollbar_size
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_table_set_scrollbar_size, "fl_table_set_scrollbar_size");
    pragma Inline (fl_table_set_scrollbar_size);

    procedure fl_table_resize
           (T          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_table_resize, "fl_table_resize");
    pragma Inline (fl_table_resize);

    function fl_table_is_interactive_resize
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_table_is_interactive_resize, "fl_table_is_interactive_resize");
    pragma Inline (fl_table_is_interactive_resize);

    procedure fl_table_init_sizes
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_init_sizes, "fl_table_init_sizes");
    pragma Inline (fl_table_init_sizes);

    procedure fl_table_recalc_dimensions
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_recalc_dimensions, "fl_table_recalc_dimensions");
    pragma Inline (fl_table_recalc_dimensions);

    procedure fl_table_table_resized
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_table_resized, "fl_table_table_resized");
    pragma Inline (fl_table_table_resized);

    procedure fl_table_table_scrolled
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_table_scrolled, "fl_table_table_scrolled");
    pragma Inline (fl_table_table_scrolled);




    --  Drawing, Events  --

    procedure fl_table_draw
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_table_draw, "fl_table_draw");
    pragma Inline (fl_table_draw);

    procedure fl_table_draw_cell
           (T                   : in Storage.Integer_Address;
            E, R, C, X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_table_draw_cell, "fl_table_draw_cell");
    pragma Inline (fl_table_draw_cell);

    procedure fl_table_redraw_range
           (T              : in Storage.Integer_Address;
            RT, RB, CL, CR : in Interfaces.C.int);
    pragma Import (C, fl_table_redraw_range, "fl_table_redraw_range");
    pragma Inline (fl_table_redraw_range);

    procedure fl_table_damage_zone
           (T                      : in Storage.Integer_Address;
            RT, CL, RB, CR, RR, RC : in Interfaces.C.int);
    pragma Import (C, fl_table_damage_zone, "fl_table_damage_zone");
    pragma Inline (fl_table_damage_zone);

    function fl_table_find_cell
           (T          : in     Storage.Integer_Address;
            E, R, C    : in     Interfaces.C.int;
            X, Y, W, H :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_find_cell, "fl_table_find_cell");
    pragma Inline (fl_table_find_cell);

    procedure fl_table_get_bounds
           (T          : in     Storage.Integer_Address;
            E          : in     Interfaces.C.int;
            X, Y, W, H :    out Interfaces.C.int);
    pragma Import (C, fl_table_get_bounds, "fl_table_get_bounds");
    pragma Inline (fl_table_get_bounds);

    function fl_table_row_col_clamp
           (T    : in     Storage.Integer_Address;
            E    : in     Interfaces.C.int;
            R, C : in out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_row_col_clamp, "fl_table_row_col_clamp");
    pragma Inline (fl_table_row_col_clamp);

    function fl_table_handle
           (T : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_table_handle, "fl_table_handle");
    pragma Inline (fl_table_handle);




    ------------------------
    --  Internal Utility  --
    ------------------------

    function To_Cint
           (Context : in Table_Context)
        return Interfaces.C.int is
    begin
        case Context is
        when No_Context        => return fl_context_none;
        when Start_Page        => return fl_context_startpage;
        when End_Page          => return fl_context_endpage;
        when Row_Header        => return fl_context_row_header;
        when Column_Header     => return fl_context_col_header;
        when Within_Cell       => return fl_context_cell;
        when Dead_Zone         => return fl_context_table;
        when Row_Column_Resize => return fl_context_rc_resize;
        end case;
    end To_Cint;


    function To_Context
           (Value : in Interfaces.C.int)
        return Table_Context is
    begin
        if Value = fl_context_none then
            return No_Context;
        elsif Value = fl_context_startpage then
            return Start_Page;
        elsif Value = fl_context_endpage then
            return End_Page;
        elsif Value = fl_context_row_header then
            return Row_Header;
        elsif Value = fl_context_col_header then
            return Column_Header;
        elsif Value = fl_context_cell then
            return Within_Cell;
        elsif Value = fl_context_table then
            return Dead_Zone;
        elsif Value = fl_context_rc_resize then
            return Row_Column_Resize;
        else
            raise Constraint_Error;
        end if;
    end To_Context;




    ----------------------
    --  Exported Hooks  --
    ----------------------

    package Table_Convert is new System.Address_To_Access_Conversions (Table'Class);

    procedure Table_Draw_Cell_Hook
           (UD                  : in Storage.Integer_Address;
            E, R, C, X, Y, W, H : in Interfaces.C.int);
    pragma Export (C, Table_Draw_Cell_Hook, "table_draw_cell_hook");

    procedure Table_Draw_Cell_Hook
           (UD                  : in Storage.Integer_Address;
            E, R, C, X, Y, W, H : in Interfaces.C.int)
    is
        Ada_Table : access Table'Class;
        Context : Table_Context;
        Row, Column : Natural;
    begin
        pragma Assert (UD /= Null_Pointer);
        Ada_Table := Table_Convert.To_Pointer (Storage.To_Address (UD));
        Context := To_Context (E);
        case Context is
        when Row_Header =>
            Row := Positive (R + 1);
            Column := Natural (C);
        when Column_Header =>
            Row := Natural (R);
            Column := Positive (C + 1);
        when Within_Cell =>
            Row := Positive (R + 1);
            Column := Positive (C + 1);
        when others =>
            Row := Natural (R);
            Column := Natural (C);
        end case;
        Ada_Table.Draw_Cell
           (Context, Row, Column,
            Integer (X), Integer (Y), Integer (W), Integer (H));
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "User data null pointer passed to Fl_Table::draw_cell override hook";
    when Constraint_Error => raise Internal_FLTK_Error with
        "Unexpected int values passed to Fl_Table::draw_cell override hook of" & Latin.LF &
        Latin.HT & "row = " & Interfaces.C.int'Image (R) & Latin.LF &
        Latin.HT & "column = " & Interfaces.C.int'Image (C);
    end Table_Draw_Cell_Hook;




    -------------------
    --  Destructors  --
    -------------------

    --  Attempting to divide by zero
    procedure fl_scrollbar_extra_final
           (Ada_Obj : in Storage.Integer_Address);
    pragma Import (C, fl_scrollbar_extra_final, "fl_scrollbar_extra_final");
    pragma Inline (fl_scrollbar_extra_final);


    --  Close the door; Open the nExt
    procedure fl_scroll_extra_final
           (Ada_Obj : in Storage.Integer_Address);
    pragma Import (C, fl_scroll_extra_final, "fl_scroll_extra_final");
    pragma Inline (fl_scroll_extra_final);


    procedure Extra_Final
           (This : in out Table) is
    begin
        fl_scrollbar_extra_final (Storage.To_Integer (This.Horizon'Address));
        fl_scrollbar_extra_final (Storage.To_Integer (This.Vertigo'Address));
        fl_scroll_extra_final (Storage.To_Integer (This.Playing_Area'Address));
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Table) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_table (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Engage silent drive!
    procedure fl_scrollbar_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_scrollbar_extra_init, "fl_scrollbar_extra_init");
    pragma Inline (fl_scrollbar_extra_init);


    --  Conducting Penrose experiment
    procedure fl_scroll_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_scroll_extra_init, "fl_scroll_extra_init");
    pragma Inline (fl_scroll_extra_init);


    procedure Extra_Init
           (This       : in out Table;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Widget (This.Horizon).Void_Ptr := fl_table_hscrollbar (This.Void_Ptr);
        Widget (This.Horizon).Needs_Dealloc := False;
        fl_scrollbar_extra_init
           (Storage.To_Integer (This.Horizon'Address),
            Interfaces.C.int (This.Horizon.Get_X),
            Interfaces.C.int (This.Horizon.Get_Y),
            Interfaces.C.int (This.Horizon.Get_W),
            Interfaces.C.int (This.Horizon.Get_H),
            Interfaces.C.To_C (This.Horizon.Get_Label));
        This.Horizon.Set_Callback (Scroll_Callback'Access);

        Widget (This.Vertigo).Void_Ptr := fl_table_vscrollbar (This.Void_Ptr);
        Widget (This.Vertigo).Needs_Dealloc := False;
        fl_scrollbar_extra_init
           (Storage.To_Integer (This.Vertigo'Address),
            Interfaces.C.int (This.Vertigo.Get_X),
            Interfaces.C.int (This.Vertigo.Get_Y),
            Interfaces.C.int (This.Vertigo.Get_W),
            Interfaces.C.int (This.Vertigo.Get_H),
            Interfaces.C.To_C (This.Vertigo.Get_Label));
        This.Vertigo.Set_Callback (Scroll_Callback'Access);

        Widget (This.Playing_Area).Void_Ptr := fl_table_table (This.Void_Ptr);
        Widget (This.Playing_Area).Needs_Dealloc := False;
        fl_scroll_extra_init
           (Storage.To_Integer (This.Playing_Area'Address),
            Interfaces.C.int (This.Playing_Area.Get_X),
            Interfaces.C.int (This.Playing_Area.Get_Y),
            Interfaces.C.int (This.Playing_Area.Get_W),
            Interfaces.C.int (This.Playing_Area.Get_H),
            Interfaces.C.To_C (This.Playing_Area.Get_Label));

        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Table) is
    begin
        This.Draw_Ptr      := fl_table_draw'Address;
        This.Handle_Ptr    := fl_table_handle'Address;
        This.Draw_Cell_Ptr := fl_table_draw_cell'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Table is
        begin
            return This : Table do
                This.Void_Ptr := new_fl_table
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Table is
        begin
            return This : Table := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Attributes  --

    function H_Bar
           (This : in out Table)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Horizon'Unchecked_Access);
    end H_Bar;


    function V_Bar
           (This : in out Table)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Vertigo'Unchecked_Access);
    end V_Bar;


    function Scroll_Area
           (This : in out Table)
        return Scrolls.Scroll_Reference is
    begin
        return (Data => This.Playing_Area'Unchecked_Access);
    end Scroll_Area;




    --  Contents Modification  --

    procedure Add
           (This : in out Table;
            Item : in out Widget'Class) is
    begin
        fl_table_add (This.Void_Ptr, Item.Void_Ptr);
    end Add;


    procedure Insert
           (This  : in out Table;
            Item  : in out Widget'Class;
            Place : in     Index) is
    begin
        fl_table_insert
           (This.Void_Ptr,
            Item.Void_Ptr,
            Interfaces.C.int (Place) - 1);
    end Insert;


    procedure Insert
           (This   : in out Table;
            Item   : in out Widget'Class;
            Before : in     Widget'Class) is
    begin
        fl_table_insert2
           (This.Void_Ptr,
            Item.Void_Ptr,
            Before.Void_Ptr);
    end Insert;


    procedure Remove
           (This : in out Table;
            Item : in out Widget'Class) is
    begin
        fl_table_remove (This.Void_Ptr, Item.Void_Ptr);
    end Remove;


    procedure Clear
           (This : in out Table) is
    begin
        This.Set_Rows (0);
        This.Set_Columns (0);
        This.Playing_Area.Clear;
    end Clear;




    --  Contents Query  --

    function Has_Child
           (This  : in Table;
            Place : in Index)
        return Boolean is
    begin
        return Place in 1 .. This.Number_Of_Children;
    end Has_Child;


    function Has_Child
           (Place : in Cursor)
        return Boolean is
    begin
        return Place.My_Container.Has_Child (Place.My_Index);
    end Has_Child;


    function Child
           (This  : in Table;
            Place : in Index)
        return Widget_Reference
    is
        Widget_Ptr : Storage.Integer_Address :=
            fl_table_child (This.Void_Ptr, Interfaces.C.int (Place) - 1);
        Actual_Widget : access Widget'Class;
    begin
        Widget_Ptr := fl_widget_get_user_data (Widget_Ptr);
        pragma Assert (Widget_Ptr /= Null_Pointer);
        Actual_Widget := Widget_Convert.To_Pointer (Storage.To_Address (Widget_Ptr));
        return (Data => Actual_Widget);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Table::child returned a widget with no user data reference back to Ada";
    end Child;


    function Child
           (This  : in Table;
            Place : in Cursor)
        return Widget_Reference is
    begin
        return This.Child (Place.My_Index);
    end Child;


    function Find
           (This : in Table;
            Item : in Widget'Class)
        return Extended_Index
    is
        Result : constant Interfaces.C.int := fl_table_find (This.Void_Ptr, Item.Void_Ptr);
    begin
        if Result = fl_table_children (This.Void_Ptr) then
            return No_Index;
        end if;
        return Extended_Index (Result + 1);
    end Find;


    function Number_Of_Children
           (This : in Table)
        return Natural is
    begin
        return Natural (fl_table_children (This.Void_Ptr));
    end Number_Of_Children;


    function Used_As_Container
           (This : in Table)
        return Boolean is
    begin
        return fl_table_is_fltk_container (This.Void_Ptr) /= 0;
    end Used_As_Container;




    --  Current  --

    procedure Begin_Current
           (This : in out Table) is
    begin
        fl_table_begin (This.Void_Ptr);
    end Begin_Current;


    procedure End_Current
           (This : in out Table) is
    begin
        fl_table_end (This.Void_Ptr);
    end End_Current;




    --  Callbacks  --

    procedure Set_Callback
           (This : in out Table;
            Func : in     Widget_Callback) is
    begin
        if Func /= null then
            This.Callback := Func;
            fl_table_set_callback (This.Void_Ptr, Storage.To_Integer (Callback_Hook'Address));
        end if;
    end Set_Callback;


    function Callback_Column
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_callback_col (This.Void_Ptr);
    begin
        return Positive (Result + 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::callback_col returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Callback_Column;


    function Callback_Row
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_callback_row (This.Void_Ptr);
    begin
        return Positive (Result + 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::callback_row returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Callback_Row;


    function Callback_Context
           (This : in Table)
        return Table_Context
    is
        Result : constant Interfaces.C.int := fl_table_callback_context (This.Void_Ptr);
    begin
        return To_Context (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::callback_context returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Callback_Context;


    procedure Do_Callback
           (This        : in out Table;
            Context     : in     Table_Context;
            Row, Column : in     Positive) is
    begin
        fl_table_do_callback
           (This.Void_Ptr,
            To_Cint (Context),
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1);
    end Do_Callback;


    procedure Set_When
           (This  : in out Table;
            Value : in     Callback_Flag) is
    begin
        fl_table_when (This.Void_Ptr, Flag_To_UChar (Value));
    end Set_When;


    procedure Scroll_Callback
           (Item : in out Widget'Class) is
    begin
        fl_table_scroll_cb (Item.Void_Ptr, Item.Parent.Void_Ptr);
    end Scroll_Callback;




    --  Columns  --

    function Column_Headers_Enabled
           (This : in Table)
        return Boolean is
    begin
        return fl_table_get_col_header (This.Void_Ptr) /= 0;
    end Column_Headers_Enabled;


    procedure Set_Column_Headers
           (This  : in out Table;
            Value : in     Boolean) is
    begin
        fl_table_set_col_header (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Column_Headers;


    function Get_Column_Header_Color
           (This : in Table)
        return Color is
    begin
        return Color (fl_table_get_col_header_color (This.Void_Ptr));
    end Get_Column_Header_Color;


    procedure Set_Column_Header_Color
           (This  : in out Table;
            Value : in     Color) is
    begin
        fl_table_set_col_header_color (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Column_Header_Color;


    function Get_Column_Header_Height
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_col_header_height (This.Void_Ptr);
    begin
        return Positive (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::col_header_height returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Column_Header_Height;


    procedure Set_Column_Header_Height
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_set_col_header_height (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Column_Header_Height;


    function Get_Column_Width
           (This   : in Table;
            Column : in Positive)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_col_width
            (This.Void_Ptr, Interfaces.C.int (Column) - 1);
    begin
        return Positive (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::col_width returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Column_Width;


    procedure Set_Column_Width
           (This   : in out Table;
            Column : in     Positive;
            Value  : in     Positive) is
    begin
        fl_table_set_col_width
           (This.Void_Ptr,
            Interfaces.C.int (Column) - 1,
            Interfaces.C.int (Value));
    end Set_Column_Width;


    procedure Set_All_Columns_Width
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_col_width_all (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_All_Columns_Width;


    function Get_Columns
           (This : in Table)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_table_get_cols (This.Void_Ptr);
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::cols returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Columns;


    procedure Set_Columns
           (This  : in out Table;
            Value : in     Natural) is
    begin
        fl_table_set_cols (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Columns;


    function Get_Column_Position
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_col_position (This.Void_Ptr);
    begin
        return Positive (Result + 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::col_position returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Column_Position;


    procedure Set_Column_Position
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_set_col_position (This.Void_Ptr, Interfaces.C.int (Value) - 1);
    end Set_Column_Position;


    function Get_Column_Scroll_Position
           (This   : in Table;
            Column : in Positive)
        return Long_Integer is
    begin
        return Long_Integer (fl_table_col_scroll_position
           (This.Void_Ptr,
            Interfaces.C.int (Column) - 1));
    end Get_Column_Scroll_Position;


    function Column_Resize_Allowed
           (This : in Table)
        return Boolean is
    begin
        return fl_table_get_col_resize (This.Void_Ptr) /= 0;
    end Column_Resize_Allowed;


    procedure Set_Column_Resize
           (This  : in out Table;
            Value : in     Boolean) is
    begin
        fl_table_set_col_resize (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Column_Resize;


    function Get_Column_Resize_Minimum
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_col_resize_min (This.Void_Ptr);
    begin
        return Positive (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::col_resize_min returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Column_Resize_Minimum;


    procedure Set_Column_Resize_Minimum
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_set_col_resize_min (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Column_Resize_Minimum;




    --  Rows  --

    function Row_Headers_Enabled
           (This : in Table)
        return Boolean is
    begin
        return fl_table_get_row_header (This.Void_Ptr) /= 0;
    end Row_Headers_Enabled;


    procedure Set_Row_Headers
           (This  : in out Table;
            Value : in     Boolean) is
    begin
        fl_table_set_row_header (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Row_Headers;


    function Get_Row_Header_Color
           (This : in Table)
        return Color is
    begin
        return Color (fl_table_get_row_header_color (This.Void_Ptr));
    end Get_Row_Header_Color;


    procedure Set_Row_Header_Color
           (This  : in out Table;
            Value : in     Color) is
    begin
        fl_table_set_row_header_color (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Row_Header_Color;


    function Get_Row_Header_Width
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_row_header_width (This.Void_Ptr);
    begin
        return Positive (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::row_header_width returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Row_Header_Width;


    procedure Set_Row_Header_Width
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_set_row_header_width (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Row_Header_Width;


    function Get_Row_Height
           (This : in Table;
            Row  : in Positive)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_row_height
            (This.Void_Ptr, Interfaces.C.int (Row) - 1);
    begin
        return Positive (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::row_height returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Row_Height;


    procedure Set_Row_Height
           (This  : in out Table;
            Row   : in     Positive;
            Value : in     Positive) is
    begin
        fl_table_set_row_height
           (This.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Value));
    end Set_Row_Height;


    procedure Set_All_Rows_Height
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_row_height_all (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_All_Rows_Height;


    function Get_Rows
           (This : in Table)
        return Natural
    is
        Result : constant Interfaces.C.int := fl_table_get_rows (This.Void_Ptr);
    begin
        return Natural (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::rows returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Rows;


    procedure Set_Rows
           (This  : in out Table;
            Value : in     Natural) is
    begin
        fl_table_set_rows (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Rows;


    function Get_Row_Position
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_row_position (This.Void_Ptr);
    begin
        return Positive (Result + 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::row_position returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Row_Position;


    procedure Set_Row_Position
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_set_row_position (This.Void_Ptr, Interfaces.C.int (Value) - 1);
    end Set_Row_Position;


    function Get_Row_Scroll_Position
           (This : in Table;
            Row  : in Positive)
        return Long_Integer is
    begin
        return Long_Integer (fl_table_row_scroll_position
           (This.Void_Ptr,
            Interfaces.C.int (Row) - 1));
    end Get_Row_Scroll_Position;


    function Row_Resize_Allowed
           (This : in Table)
        return Boolean is
    begin
        return fl_table_get_row_resize (This.Void_Ptr) /= 0;
    end Row_Resize_Allowed;


    procedure Set_Row_Resize
           (This  : in out Table;
            Value : in     Boolean) is
    begin
        fl_table_set_row_resize (This.Void_Ptr, Boolean'Pos (Value));
    end Set_Row_Resize;


    function Get_Row_Resize_Minimum
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_row_resize_min (This.Void_Ptr);
    begin
        return Positive (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::row_resize_min returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Row_Resize_Minimum;


    procedure Set_Row_Resize_Minimum
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_set_row_resize_min (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Row_Resize_Minimum;


    function Get_Top_Row
           (This : in Table)
        return Positive
    is
        Result : constant Interfaces.C.int := fl_table_get_top_row (This.Void_Ptr);
    begin
        return Positive (Result + 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::top_row returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Top_Row;


    procedure Set_Top_Row
           (This  : in out Table;
            Value : in     Positive) is
    begin
        fl_table_set_top_row (This.Void_Ptr, Interfaces.C.int (Value) - 1);
    end Set_Top_Row;




    --  Selection  --

    procedure Set_Cursor_Kind
           (This : in out Table;
            Kind : in     Mouse_Cursor_Kind) is
    begin
        fl_table_change_cursor (This.Void_Ptr, Cursor_Values (Kind));
    end Set_Cursor_Kind;


    procedure Cursor_To_Row_Column
           (This        : in     Table;
            Row, Column :    out Positive;
            Context     :    out Table_Context;
            Resize      :    out Resize_Flag)
    is
        C_Row, C_Column, C_Flag : Interfaces.C.int;
        Result : constant Interfaces.C.int := fl_table_cursor2rowcol
            (This.Void_Ptr, C_Row, C_Column, C_Flag);
    begin
        Row     := Positive (C_Row + 1);
        Column  := Positive (C_Column + 1);
        Context := To_Context (Result);
        Resize  := Resize_Flag'Val (C_Flag);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::cursor2rowcol returned unexpected values with" & Latin.LF &
        Latin.HT & "row = " & Interfaces.C.int'Image (C_Row) & Latin.LF &
        Latin.HT & "column = " & Interfaces.C.int'Image (C_Column) & Latin.LF &
        Latin.HT & "context = " & Interfaces.C.int'Image (Result) & Latin.LF &
        Latin.HT & "resize = " & Interfaces.C.int'Image (C_Flag);
    end Cursor_To_Row_Column;


    procedure Get_Visible_Cells
           (This         : in     Table;
            Row_Top      :    out Positive;
            Column_Left  :    out Positive;
            Row_Bottom   :    out Natural;
            Column_Right :    out Natural)
    is
        C_Row_Top, C_Row_Bottom, C_Column_Left, C_Column_Right : Interfaces.C.int;
    begin
        fl_table_visible_cells
           (This.Void_Ptr,
            C_Row_Top,     C_Row_Bottom,
            C_Column_Left, C_Column_Right);
        Row_Top      := Positive (C_Row_Top + 1);
        Row_Bottom   := Positive (C_Row_Bottom + 1);
        Column_Left  := Natural (C_Column_Left + 1);
        Column_Right := Natural (C_Column_Right + 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::visible_cells returned unexpected values with" & Latin.LF &
        Latin.HT & "row_top = " & Interfaces.C.int'Image (C_Row_Top) & Latin.LF &
        Latin.HT & "row_bottom = " & Interfaces.C.int'Image (C_Row_Bottom) & Latin.LF &
        Latin.HT & "column_left = " & Interfaces.C.int'Image (C_Column_Left) & Latin.LF &
        Latin.HT & "column_right = " & Interfaces.C.int'Image (C_Column_Right);
    end Get_Visible_Cells;


    procedure Get_Selection
           (This         : in     Table;
            Row_Top      :    out Positive;
            Column_Left  :    out Positive;
            Row_Bottom   :    out Positive;
            Column_Right :    out Positive)
    is
        C_Row_Top, C_Column_Left, C_Row_Bottom, C_Column_Right : Interfaces.C.int;
    begin
        fl_table_get_selection
           (This.Void_Ptr,
            C_Row_Top,    C_Column_Left,
            C_Row_Bottom, C_Column_Right);
        Row_Top      := Positive (C_Row_Top + 1);
        Column_Left  := Positive (C_Column_Left + 1);
        Row_Bottom   := Positive (C_Row_Bottom + 1);
        Column_Right := Positive (C_Column_Right + 1);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::get_selection returned unexpected values with" & Latin.LF &
        Latin.HT & "row_top = " & Interfaces.C.int'Image (C_Row_Top) & Latin.LF &
        Latin.HT & "column_left = " & Interfaces.C.int'Image (C_Column_Left) & Latin.LF &
        Latin.HT & "row_bottom = " & Interfaces.C.int'Image (C_Row_Bottom) & Latin.LF &
        Latin.HT & "column_right = " & Interfaces.C.int'Image (C_Column_Right);
    end Get_Selection;


    procedure Set_Selection
           (This         : in out Table;
            Row_Top      : in     Positive;
            Column_Left  : in     Positive;
            Row_Bottom   : in     Positive;
            Column_Right : in     Positive) is
    begin
        fl_table_set_selection
           (This.Void_Ptr,
            Interfaces.C.int (Row_Top) - 1,
            Interfaces.C.int (Column_Left) - 1,
            Interfaces.C.int (Row_Bottom) - 1,
            Interfaces.C.int (Column_Right) - 1);
    end Set_Selection;


    function Is_Selected
           (This        : in Table;
            Row, Column : in Positive)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_table_is_selected
           (This.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::is_selected returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Is_Selected;


    procedure Move_Cursor
           (This         : in out Table;
            Row, Column  : in     Positive;
            Shift_Select : in     Boolean := True)
    is
        Result : constant Interfaces.C.int := fl_table_move_cursor
           (This.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1,
            Boolean'Pos (Shift_Select));
    begin
        pragma Assert (Result in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Table::move_cursor returned unexpected value of " &
        Interfaces.C.int'Image (Result);
    end Move_Cursor;


    function Move_Cursor
           (This         : in out Table;
            Row, Column  : in     Positive;
            Shift_Select : in     Boolean := True)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_table_move_cursor
           (This.Void_Ptr,
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1,
            Boolean'Pos (Shift_Select));
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::move_cursor returned unexpected value of " &
        Interfaces.C.int'Image (Result);
    end Move_Cursor;


    function Get_Tab_Mode
           (This : in Table)
        return Tab_Navigation
    is
        Result : constant Interfaces.C.int := fl_table_get_tab_cell_nav (This.Void_Ptr);
    begin
        return Tab_Navigation'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::tab_cell_nav returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Tab_Mode;


    procedure Set_Tab_Mode
           (This  : in out Table;
            Value : in     Tab_Navigation) is
    begin
        fl_table_set_tab_cell_nav (This.Void_Ptr, Tab_Navigation'Pos (Value));
    end Set_Tab_Mode;


    function Get_Table_Box
           (This : in Table)
        return Box_Kind
    is
        Result : constant Interfaces.C.int := fl_table_get_table_box (This.Void_Ptr);
    begin
        return Box_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::table_box returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Table_Box;


    procedure Set_Table_Box
           (This : in out Table;
            Box  : in     Box_Kind) is
    begin
        fl_table_set_table_box (This.Void_Ptr, Box_Kind'Pos (Box));
    end Set_Table_Box;




    --  Dimensions  --

    function Get_Scrollbar_Size
           (This : in Table)
        return Integer is
    begin
        return Integer (fl_table_get_scrollbar_size (This.Void_Ptr));
    end Get_Scrollbar_Size;


    procedure Set_Scrollbar_Size
           (This  : in out Table;
            Value : in     Integer) is
    begin
        fl_table_set_scrollbar_size (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Scrollbar_Size;


    procedure Resize
           (This       : in out Table;
            X, Y, W, H : in     Integer) is
    begin
        fl_table_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


    function Is_Interactive_Resize
           (This : in Table)
        return Boolean
    is
        Result : constant Interfaces.C.int := fl_table_is_interactive_resize (This.Void_Ptr);
    begin
        return Boolean'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Table::is_interactive_resize returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Is_Interactive_Resize;


    procedure Reset_Sizes
           (This : in out Table) is
    begin
        fl_table_init_sizes (This.Void_Ptr);
    end Reset_Sizes;


    procedure Recalculate_Dimensions
           (This : in out Table) is
    begin
        fl_table_recalc_dimensions (This.Void_Ptr);
    end Recalculate_Dimensions;


    procedure Table_Resized
           (This : in out Table) is
    begin
        fl_table_table_resized (This.Void_Ptr);
    end Table_Resized;


    procedure Table_Scrolled
           (This : in out Table) is
    begin
        fl_table_table_scrolled (This.Void_Ptr);
    end Table_Scrolled;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Table) is
    begin
        Group (This).Draw;
    end Draw;


    procedure Draw_Cell
           (This        : in out Table;
            Context     : in     Table_Context;
            Row, Column : in     Natural := 0;
            X, Y, W, H  : in     Integer := 0)
    is
        procedure my_draw_cell
               (T                   : in Storage.Integer_Address;
                E, R, C, X, Y, W, H : in Interfaces.C.int);
        for my_draw_cell'Address use This.Draw_Cell_Ptr;
        pragma Import (Ada, my_draw_cell);

        C_Row, C_Column : Interfaces.C.int;
    begin
        case Context is
        when Row_Header =>
            C_Row := Interfaces.C.int (Row) - 1;
            C_Column := Interfaces.C.int (Column);
        when Column_Header =>
            C_Row := Interfaces.C.int (Row);
            C_Column := Interfaces.C.int (Column) - 1;
        when Within_Cell =>
            C_Row := Interfaces.C.int (Row) - 1;
            C_Column := Interfaces.C.int (Column) - 1;
        when others =>
            C_Row := Interfaces.C.int (Row);
            C_Column := Interfaces.C.int (Column);
        end case;
        my_draw_cell
           (This.Void_Ptr,
            To_Cint (Context),
            C_Row, C_Column,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Draw_Cell;


    procedure Redraw_Range
           (This         : in out Table;
            Row_Top      : in     Positive;
            Column_Left  : in     Positive;
            Row_Bottom   : in     Positive;
            Column_Right : in     Positive) is
    begin
        fl_table_redraw_range
           (This.Void_Ptr,
            Interfaces.C.int (Row_Top) - 1,
            Interfaces.C.int (Row_Bottom) - 1,
            Interfaces.C.int (Column_Left) - 1,
            Interfaces.C.int (Column_Right) - 1);
    end Redraw_Range;


    procedure Damage_Zone
           (This         : in out Table;
            Row_Top      : in     Positive;
            Column_Left  : in     Positive;
            Row_Bottom   : in     Positive;
            Column_Right : in     Positive;
            Reach_Row    : in     Positive := 1;
            Reach_Column : in     Positive := 1) is
    begin
        fl_table_damage_zone
           (This.Void_Ptr,
            Interfaces.C.int (Row_Top) - 1,
            Interfaces.C.int (Column_Left) - 1,
            Interfaces.C.int (Row_Bottom) - 1,
            Interfaces.C.int (Column_Right) - 1,
            Interfaces.C.int (Reach_Row) - 1,
            Interfaces.C.int (Reach_Column) - 1);
    end Damage_Zone;


    procedure Cell_Dimensions
           (This        : in     Table;
            Context     : in     Table_Context;
            Row, Column : in     Positive;
            X, Y, W, H  :    out Integer)
    is
        Result : constant Interfaces.C.int := fl_table_find_cell
           (This.Void_Ptr,
            To_Cint (Context),
            Interfaces.C.int (Row) - 1,
            Interfaces.C.int (Column) - 1,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    begin
        if Result = -1 then
            raise Range_Error with
                "Row = " & Integer'Image (Row) & ", Column = " & Integer'Image (Column);
        else
            pragma Assert (Result = 0);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Table::find_cell returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Cell_Dimensions;


    procedure Bounding_Region
           (This       : in     Table;
            Context    : in     Table_Context;
            X, Y, W, H :    out Integer) is
    begin
        fl_table_get_bounds
           (This.Void_Ptr,
            To_Cint (Context),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Bounding_Region;


    procedure Row_Column_Clamp
           (This        : in     Table;
            Context     : in     Table_Context;
            Row, Column : in out Integer)
    is
        C_Row    : Interfaces.C.int := Interfaces.C.int (Row) - 1;
        C_Column : Interfaces.C.int := Interfaces.C.int (Column) - 1;
        Result : constant Interfaces.C.int := fl_table_row_col_clamp
           (This.Void_Ptr,
            To_Cint (Context),
            C_Row, C_Column);
    begin
        pragma Assert (Result in 0 .. 1);
        Row    := Integer (C_Row) + 1;
        Column := Integer (C_Column) + 1;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Table::row_col_clamp returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Row_Column_Clamp;


    function Row_Column_Clamp
           (This        : in     Table;
            Context     : in     Table_Context;
            Row, Column : in out Integer)
        return Boolean
    is
        C_Row    : Interfaces.C.int := Interfaces.C.int (Row) - 1;
        C_Column : Interfaces.C.int := Interfaces.C.int (Column) - 1;
        Result : constant Interfaces.C.int := fl_table_row_col_clamp
           (This.Void_Ptr,
            To_Cint (Context),
            C_Row, C_Column);
    begin
        pragma Assert (Result in 0 .. 1);
        Row    := Integer (C_Row) + 1;
        Column := Integer (C_Column) + 1;
        return Boolean'Val (Result);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
       "Fl_Table::row_col_clamp returned unexpected int value of " &
       Interfaces.C.int'Image (Result);
    end Row_Column_Clamp;


    function Handle
           (This  : in out Table;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Tables;


