

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Hook_Exceptions,
    Interfaces.C,
    System.Address_To_Access_Conversions;


package body FLTK.Widgets.Groups.Browsers is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Constants From C  --
    ------------------------

    fl_sort_ascending : constant Interfaces.C.int;
    pragma Import (C, fl_sort_ascending, "fl_sort_ascending");

    fl_sort_descending : constant Interfaces.C.int;
    pragma Import (C, fl_sort_descending, "fl_sort_descending");

    fl_sort_caseinsensitive : constant Interfaces.C.int;
    pragma Import (C, fl_sort_caseinsensitive, "fl_sort_caseinsensitive");




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_abstract_browser
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_abstract_browser, "new_fl_abstract_browser");
    pragma Inline (new_fl_abstract_browser);

    procedure free_fl_abstract_browser
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_abstract_browser, "free_fl_abstract_browser");
    pragma Inline (free_fl_abstract_browser);




    --  Attributes  --

    function fl_abstract_browser_hscrollbar
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_abstract_browser_hscrollbar, "fl_abstract_browser_hscrollbar");
    pragma Inline (fl_abstract_browser_hscrollbar);

    function fl_abstract_browser_scrollbar
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_abstract_browser_scrollbar, "fl_abstract_browser_scrollbar");
    pragma Inline (fl_abstract_browser_scrollbar);

    function fl_widget_get_type
           (B : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_get_type, "fl_widget_get_type");
    pragma Inline (fl_widget_get_type);

    procedure fl_widget_set_type
           (B : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_type, "fl_widget_set_type");
    pragma Inline (fl_widget_set_type);




    --  Items  --

    function fl_abstract_browser_select
           (B, I : in Storage.Integer_Address;
            V, C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_select, "fl_abstract_browser_select");
    pragma Inline (fl_abstract_browser_select);

    function fl_abstract_browser_select_only
           (B, I : in Storage.Integer_Address;
            C    : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_select_only, "fl_abstract_browser_select_only");
    pragma Inline (fl_abstract_browser_select_only);

    function fl_abstract_browser_selection
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_abstract_browser_selection, "fl_abstract_browser_selection");
    pragma Inline (fl_abstract_browser_selection);

    function fl_abstract_browser_deselect
           (B : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_deselect, "fl_abstract_browser_deselect");
    pragma Inline (fl_abstract_browser_deselect);

    procedure fl_abstract_browser_display
           (B, I : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_display, "fl_abstract_browser_display");
    pragma Inline (fl_abstract_browser_display);

    function fl_abstract_browser_displayed
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_displayed, "fl_abstract_browser_displayed");
    pragma Inline (fl_abstract_browser_displayed);

    function fl_abstract_browser_find_item
           (B : in Storage.Integer_Address;
            Y : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_abstract_browser_find_item, "fl_abstract_browser_find_item");
    pragma Inline (fl_abstract_browser_find_item);

    function fl_abstract_browser_top
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_abstract_browser_top, "fl_abstract_browser_top");
    pragma Inline (fl_abstract_browser_top);

    procedure fl_abstract_browser_sort
           (B : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_sort, "fl_abstract_browser_sort");
    pragma Inline (fl_abstract_browser_sort);




    --  Scrollbar Settings  --

    function fl_abstract_browser_get_has_scrollbar
           (B : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_abstract_browser_get_has_scrollbar,
        "fl_abstract_browser_get_has_scrollbar");
    pragma Inline (fl_abstract_browser_get_has_scrollbar);

    procedure fl_abstract_browser_set_has_scrollbar
           (B : in Storage.Integer_Address;
            M : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_abstract_browser_set_has_scrollbar,
        "fl_abstract_browser_set_has_scrollbar");
    pragma Inline (fl_abstract_browser_set_has_scrollbar);

    function fl_abstract_browser_get_hposition
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_get_hposition, "fl_abstract_browser_get_hposition");
    pragma Inline (fl_abstract_browser_get_hposition);

    procedure fl_abstract_browser_set_hposition
           (B : in Storage.Integer_Address;
            P : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_set_hposition, "fl_abstract_browser_set_hposition");
    pragma Inline (fl_abstract_browser_set_hposition);

    function fl_abstract_browser_get_position
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_get_position, "fl_abstract_browser_get_position");
    pragma Inline (fl_abstract_browser_get_position);

    procedure fl_abstract_browser_set_position
           (B : in Storage.Integer_Address;
            P : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_set_position, "fl_abstract_browser_set_position");
    pragma Inline (fl_abstract_browser_set_position);

    procedure fl_abstract_browser_scrollbar_left
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_scrollbar_left, "fl_abstract_browser_scrollbar_left");
    pragma Inline (fl_abstract_browser_scrollbar_left);

    procedure fl_abstract_browser_scrollbar_right
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_scrollbar_right, "fl_abstract_browser_scrollbar_right");
    pragma Inline (fl_abstract_browser_scrollbar_right);

    function fl_abstract_browser_get_scrollbar_size
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_get_scrollbar_size,
        "fl_abstract_browser_get_scrollbar_size");
    pragma Inline (fl_abstract_browser_get_scrollbar_size);

    procedure fl_abstract_browser_set_scrollbar_size
           (B : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_set_scrollbar_size,
        "fl_abstract_browser_set_scrollbar_size");
    pragma Inline (fl_abstract_browser_set_scrollbar_size);

    function fl_abstract_browser_get_linespacing
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_get_linespacing,
        "fl_abstract_browser_get_linespacing");
    pragma Inline (fl_abstract_browser_get_linespacing);

    procedure fl_abstract_browser_set_linespacing
           (B : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_set_linespacing,
        "fl_abstract_browser_set_linespacing");
    pragma Inline (fl_abstract_browser_set_linespacing);




    --  Text Settings  --

    function fl_abstract_browser_get_textcolor
           (B : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_abstract_browser_get_textcolor, "fl_abstract_browser_get_textcolor");
    pragma Inline (fl_abstract_browser_get_textcolor);

    procedure fl_abstract_browser_set_textcolor
           (B : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_abstract_browser_set_textcolor, "fl_abstract_browser_set_textcolor");
    pragma Inline (fl_abstract_browser_set_textcolor);

    function fl_abstract_browser_get_textfont
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_get_textfont, "fl_abstract_browser_get_textfont");
    pragma Inline (fl_abstract_browser_get_textfont);

    procedure fl_abstract_browser_set_textfont
           (B : in Storage.Integer_Address;
            F : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_set_textfont, "fl_abstract_browser_set_textfont");
    pragma Inline (fl_abstract_browser_set_textfont);

    function fl_abstract_browser_get_textsize
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_get_textsize, "fl_abstract_browser_get_textsize");
    pragma Inline (fl_abstract_browser_get_textsize);

    procedure fl_abstract_browser_set_textsize
           (B : in Storage.Integer_Address;
            S : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_set_textsize, "fl_abstract_browser_set_textsize");
    pragma Inline (fl_abstract_browser_set_textsize);




    --  Dimensions, Redrawing  --

    procedure fl_abstract_browser_resize
           (B          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_resize, "fl_abstract_browser_resize");
    pragma Inline (fl_abstract_browser_resize);

    procedure fl_abstract_browser_bbox
           (B          : in     Storage.Integer_Address;
            X, Y, W, H :    out Interfaces.C.int);
    pragma Import (C, fl_abstract_browser_bbox, "fl_abstract_browser_bbox");
    pragma Inline (fl_abstract_browser_bbox);

    function fl_abstract_browser_leftedge
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_leftedge, "fl_abstract_browser_leftedge");
    pragma Inline (fl_abstract_browser_leftedge);

    procedure fl_abstract_browser_redraw_line
           (B, I : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_redraw_line, "fl_abstract_browser_redraw_line");
    pragma Inline (fl_abstract_browser_redraw_line);

    procedure fl_abstract_browser_redraw_lines
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_redraw_lines, "fl_abstract_browser_redraw_lines");
    pragma Inline (fl_abstract_browser_redraw_lines);




    --  Optional Overrides  --

    function fl_abstract_browser_full_width
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_full_width, "fl_abstract_browser_full_width");
    pragma Inline (fl_abstract_browser_full_width);

    function fl_abstract_browser_full_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_full_height, "fl_abstract_browser_full_height");
    pragma Inline (fl_abstract_browser_full_height);

    function fl_abstract_browser_incr_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_incr_height, "fl_abstract_browser_incr_height");
    pragma Inline (fl_abstract_browser_incr_height);

    function fl_abstract_browser_item_quick_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_item_quick_height,
        "fl_abstract_browser_item_quick_height");
    pragma Inline (fl_abstract_browser_item_quick_height);




    --  Cache Invalidation  --

    procedure fl_abstract_browser_new_list
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_new_list, "fl_abstract_browser_new_list");
    pragma Inline (fl_abstract_browser_new_list);

    procedure fl_abstract_browser_inserting
           (B, A1, A2 : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_inserting, "fl_abstract_browser_inserting");
    pragma Inline (fl_abstract_browser_inserting);

    procedure fl_abstract_browser_deleting
           (B, I : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_deleting, "fl_abstract_browser_deleting");
    pragma Inline (fl_abstract_browser_deleting);

    procedure fl_abstract_browser_replacing
           (B, A1, A2 : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_replacing, "fl_abstract_browser_replacing");
    pragma Inline (fl_abstract_browser_replacing);

    procedure fl_abstract_browser_swapping
           (B, A1, A2 : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_swapping, "fl_abstract_browser_swapping");
    pragma Inline (fl_abstract_browser_swapping);




    -- Drawing, Events  --

    procedure fl_abstract_browser_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_abstract_browser_draw, "fl_abstract_browser_draw");
    pragma Inline (fl_abstract_browser_draw);

    function fl_abstract_browser_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_abstract_browser_handle, "fl_abstract_browser_handle");
    pragma Inline (fl_abstract_browser_handle);




    ----------------------
    --  Exported Hooks  --
    ----------------------

    package Browser_Convert is new System.Address_To_Access_Conversions (Browser'Class);


    function Full_Width_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Full_Width_Hook, "browser_full_width_hook");

    function Full_Width_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Full_List_Width);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Full_Width_Hook;


    function Full_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Full_Height_Hook, "browser_full_height_hook");

    function Full_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Full_List_Height);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Full_Height_Hook;


    function Average_Item_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Average_Item_Height_Hook, "browser_incr_height_hook");

    function Average_Item_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Average_Item_Height);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Average_Item_Height_Hook;


    function Item_Quick_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Quick_Height_Hook, "browser_item_quick_height_hook");

    function Item_Quick_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Item_Quick_Height (Address_To_Cursor (Item_Ptr)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Item_Quick_Height_Hook;


    function Item_Width_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Width_Hook, "browser_item_width_hook");

    function Item_Width_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Item_Width (Address_To_Cursor (Item_Ptr)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Item_Width_Hook;


    function Item_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Height_Hook, "browser_item_height_hook");

    function Item_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Item_Height (Address_To_Cursor (Item_Ptr)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Item_Height_Hook;


    function Item_First_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_First_Hook, "browser_item_first_hook");

    function Item_First_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_First);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return Null_Pointer;
    end Item_First_Hook;


    function Item_Last_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_Last_Hook, "browser_item_last_hook");

    function Item_Last_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_Last);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return Null_Pointer;
    end Item_Last_Hook;


    function Item_Next_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_Next_Hook, "browser_item_next_hook");

    function Item_Next_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_Next (Address_To_Cursor (Item_Ptr)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return Null_Pointer;
    end Item_Next_Hook;


    function Item_Previous_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_Previous_Hook, "browser_item_prev_hook");

    function Item_Previous_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_Previous (Address_To_Cursor (Item_Ptr)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return Null_Pointer;
    end Item_Previous_Hook;


    function Item_At_Hook
           (Ada_Addr : in Storage.Integer_Address;
            Index    : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Export (C, Item_At_Hook, "browser_item_at_hook");

    function Item_At_Hook
           (Ada_Addr : in Storage.Integer_Address;
            Index    : in Interfaces.C.int)
        return Storage.Integer_Address
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
        use type Interfaces.C.int;
    begin
        return Cursor_To_Address (Ada_Object.Item_At (Positive (Index + 1)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return Null_Pointer;
    end Item_At_Hook;


    procedure Item_Select_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            Int_State          : in Interfaces.C.int);
    pragma Export (C, Item_Select_Hook, "browser_item_select_hook");

    procedure Item_Select_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            Int_State          : in Interfaces.C.int)
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
        use type Interfaces.C.int;
    begin
        Ada_Object.Item_Select
           (Address_To_Cursor (Item_Ptr),
            Int_State /= 0);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Item_Select_Hook;


    function Item_Selected_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Selected_Hook, "browser_item_selected_hook");

    function Item_Selected_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Boolean'Pos (Ada_Object.Item_Selected (Address_To_Cursor (Item_Ptr)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Item_Selected_Hook;


    procedure Item_Swap_Hook
           (Ada_Addr, A_Ptr, B_Ptr : in Storage.Integer_Address);
    pragma Export (C, Item_Swap_Hook, "browser_item_swap_hook");

    procedure Item_Swap_Hook
           (Ada_Addr, A_Ptr, B_Ptr : in Storage.Integer_Address)
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        Ada_Object.Item_Swap (Address_To_Cursor (A_Ptr), Address_To_Cursor (B_Ptr));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Item_Swap_Hook;


    --  The following is a hack due to inherent incompatibilities between Ada Strings
    --  and C char pointers. The hook will convert Strings to char* and return them
    --  fine for the first two calls, but after that it will deallocate the oldest
    --  char* it previously returned to make room for more. Fortunately, this hook
    --  is only used by the FLTK C++ side of things for comparing two strings for the
    --  purposes of sorting items so it all works out in the end.

    --  Calls by the Ada programmer to Item_Text will be completely unaffected, but
    --  this does mean that the default implementation of Sort is not task safe.

    --  At the time of writing this I have no idea how task safe FLTK is anyway.

    --  What Item_Text_Hook gives FLTK if Item_Text raised.
    Empty_Text : aliased Interfaces.C.char_array := (0 => Interfaces.C.nul);

    function Item_Text_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Export (C, Item_Text_Hook, "browser_item_text_hook");

    function Item_Text_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        Interfaces.C.Strings.Free (Ada_Object.Text_Store (Ada_Object.Current));
        Ada_Object.Text_Store (Ada_Object.Current) := Interfaces.C.Strings.New_String
            (Ada_Object.Item_Text (Address_To_Cursor (Item_Ptr)));
        return C_Char_Is_Not_A_String : constant Interfaces.C.Strings.chars_ptr :=
            Ada_Object.Text_Store (Ada_Object.Current)
        do
            Ada_Object.Current := Ada_Object.Current + 1;
            if Ada_Object.Current > Ada_Object.Text_Store'Last then
                Ada_Object.Current := Ada_Object.Text_Store'First;
            end if;
        end return;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return Interfaces.C.Strings.To_Chars_Ptr (Empty_Text'Access);
    end Item_Text_Hook;


    procedure Item_Draw_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            X, Y, W, H         : in Interfaces.C.int);
    pragma Export (C, Item_Draw_Hook, "browser_item_draw_hook");

    procedure Item_Draw_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            X, Y, W, H         : in Interfaces.C.int)
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Object : constant access Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        Ada_Object.Item_Draw
           (Address_To_Cursor (Item_Ptr),
            Integer (X),
            Integer (Y),
            Integer (W),
            Integer (H));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
    end Item_Draw_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Browser) is
    begin
        Extra_Final (Group (This));
        for Index in This.Text_Store'Range loop
            Interfaces.C.Strings.Free (This.Text_Store (Index));
        end loop;
    end Extra_Final;


    procedure Finalize
           (This : in out Browser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_abstract_browser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    --  Boarding the Titanic...
    procedure fl_scrollbar_extra_init
           (Ada_Obj    : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C_Str      : in Interfaces.C.char_array);
    pragma Import (C, fl_scrollbar_extra_init, "fl_scrollbar_extra_init");
    pragma Inline (fl_scrollbar_extra_init);


    procedure Extra_Init
           (This       : in out Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Widget (This.Horizon).Void_Ptr := fl_abstract_browser_hscrollbar (This.Void_Ptr);
        Widget (This.Horizon).Needs_Dealloc := False;
        fl_scrollbar_extra_init
           (Storage.To_Integer (This.Horizon'Address),
            Interfaces.C.int (This.Horizon.Get_X),
            Interfaces.C.int (This.Horizon.Get_Y),
            Interfaces.C.int (This.Horizon.Get_W),
            Interfaces.C.int (This.Horizon.Get_H),
            Interfaces.C.To_C (This.Horizon.Get_Label));
        Widget (This.Vertigo).Void_Ptr := fl_abstract_browser_scrollbar (This.Void_Ptr);
        Widget (This.Vertigo).Needs_Dealloc := False;
        fl_scrollbar_extra_init
           (Storage.To_Integer (This.Vertigo'Address),
            Interfaces.C.int (This.Vertigo.Get_X),
            Interfaces.C.int (This.Vertigo.Get_Y),
            Interfaces.C.int (This.Vertigo.Get_W),
            Interfaces.C.int (This.Vertigo.Get_H),
            Interfaces.C.To_C (This.Vertigo.Get_Label));
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Browser) is
    begin
        This.Wide_High_Ptrs :=
           (Full_List_Width_Ptr     => fl_abstract_browser_full_width'Address,
            Full_List_Height_Ptr    => fl_abstract_browser_full_height'Address,
            Average_Item_Height_Ptr => fl_abstract_browser_incr_height'Address,
            Item_Quick_Height_Ptr   => fl_abstract_browser_item_quick_height'Address);
        This.Draw_Ptr   := fl_abstract_browser_draw'Address;
        This.Handle_Ptr := fl_abstract_browser_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Browser is
        begin
            return This : Browser do
                This.Void_Ptr := new_fl_abstract_browser
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
            return Browser is
        begin
            return This : Browser := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Attributes  --

    function H_Bar
           (This : in out Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Horizon'Unchecked_Access);
    end H_Bar;


    function V_Bar
           (This : in out Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Vertigo'Unchecked_Access);
    end V_Bar;


    function Get_Kind
           (This : in Browser)
        return Browser_Kind
    is
        Result : constant Interfaces.C.unsigned_char := fl_widget_get_type (This.Void_Ptr);
    begin
        return Browser_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::type returned unexpected unsigned char value of " &
        Interfaces.C.unsigned_char'Image (Result);
    end Get_Kind;


    procedure Set_Kind
           (This : in out Browser;
            To   : in     Browser_Kind) is
    begin
        fl_widget_set_type (This.Void_Ptr, Browser_Kind'Pos (To));
    end Set_Kind;




    --  Items  --

    function Set_Select
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            State        : in     Boolean := True;
            Do_Callbacks : in     Boolean := False)
        return Boolean
    is
        Code : constant Interfaces.C.int := fl_abstract_browser_select
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Boolean'Pos (State),
            Boolean'Pos (Do_Callbacks));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::select returned unexpected int value of " & Interfaces.C.int'Image (Code);
    end Set_Select;


    procedure Set_Select
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            State        : in     Boolean := True;
            Do_Callbacks : in     Boolean := False)
    is
        Code : constant Interfaces.C.int := fl_abstract_browser_select
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Boolean'Pos (State),
            Boolean'Pos (Do_Callbacks));
    begin
        pragma Assert (Code in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::select returned unexpected int value of " & Interfaces.C.int'Image (Code);
    end Set_Select;


    function Select_Only
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            Do_Callbacks : in     Boolean := False)
        return Boolean
    is
        Code : constant Interfaces.C.int := fl_abstract_browser_select_only
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Boolean'Pos (Do_Callbacks));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::select_only returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Select_Only;


    procedure Select_Only
           (This         : in out Browser;
            Item         : in     Item_Cursor;
            Do_Callbacks : in     Boolean := False)
    is
        Code : constant Interfaces.C.int := fl_abstract_browser_select_only
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Boolean'Pos (Do_Callbacks));
    begin
        pragma Assert (Code in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::select_only returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Select_Only;


    function Current_Selection
           (This : in Browser)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_abstract_browser_selection (This.Void_Ptr));
    end Current_Selection;


    function Deselect
           (This         : in out Browser;
            Do_Callbacks : in     Boolean := False)
        return Boolean
    is
        Code : constant Interfaces.C.int := fl_abstract_browser_deselect
           (This.Void_Ptr,
            Boolean'Pos (Do_Callbacks));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::deselect returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Deselect;


    procedure Deselect
           (This         : in out Browser;
            Do_Callbacks : in     Boolean := False)
    is
        Code : constant Interfaces.C.int := fl_abstract_browser_deselect
           (This.Void_Ptr,
            Boolean'Pos (Do_Callbacks));
    begin
        pragma Assert (Code in 0 .. 1);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::deselect returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Deselect;


    procedure Display
           (This : in out Browser;
            Item : in     Item_Cursor) is
    begin
        fl_abstract_browser_display (This.Void_Ptr, Cursor_To_Address (Item));
    end Display;


    function Is_Displayed
           (This : in Browser;
            Item : in Item_Cursor)
        return Boolean
    is
        Code : constant Interfaces.C.int := fl_abstract_browser_displayed
            (This.Void_Ptr, Cursor_To_Address (Item));
    begin
        pragma Assert (Code in 0 .. 1);
        return Boolean'Val (Code);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_Browser_::displayed returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Is_Displayed;


    function Find_Item
           (This  : in Browser;
            Y_Pos : in Integer)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_abstract_browser_find_item
           (This.Void_Ptr,
            Interfaces.C.int (Y_Pos)));
    end Find_Item;


    function Top_Item
           (This : in Browser)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_abstract_browser_top (This.Void_Ptr));
    end Top_Item;


    procedure Sort
           (This        : in out Browser;
            Order       : in     Sort_Order;
            Ignore_Case : in     Boolean := False)
    is
        Code : constant Interfaces.C.int :=
           (case Order is
            when Ascending  => fl_sort_ascending,
            when Descending => fl_sort_descending);
    begin
        if Ignore_Case then
            fl_abstract_browser_sort
               (This.Void_Ptr, Interfaces.C."+" (Code, fl_sort_caseinsensitive));
        else
            fl_abstract_browser_sort (This.Void_Ptr, Code);
        end if;
    end Sort;




    --  Scrollbar Settings  --

    function Get_Scrollbar_Mode
           (This : in Browser)
        return Scrollbar_Mode is
    begin
        return Uchar_To_Mode (fl_abstract_browser_get_has_scrollbar (This.Void_Ptr));
    end Get_Scrollbar_Mode;


    procedure Set_Scrollbar_Mode
           (This : in out Browser;
            Mode : in     Scrollbar_Mode) is
    begin
        fl_abstract_browser_set_has_scrollbar (This.Void_Ptr, Mode_To_Uchar (Mode));
    end Set_Scrollbar_Mode;


    function Get_H_Position
           (This : in Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_get_hposition (This.Void_Ptr));
    end Get_H_Position;


    procedure Set_H_Position
           (This  : in out Browser;
            Value : in     Integer) is
    begin
        fl_abstract_browser_set_hposition
           (This.Void_Ptr,
            Interfaces.C.int (Value));
    end Set_H_Position;


    function Get_V_Position
           (This : in Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_get_position (This.Void_Ptr));
    end Get_V_Position;


    procedure Set_V_Position
           (This  : in out Browser;
            Value : in     Integer) is
    begin
        fl_abstract_browser_set_position
           (This.Void_Ptr,
            Interfaces.C.int (Value));
    end Set_V_Position;


    procedure Set_Vertical_Left
           (This : in out Browser) is
    begin
        fl_abstract_browser_scrollbar_left (This.Void_Ptr);
    end Set_Vertical_Left;


    procedure Set_Vertical_Right
           (This : in out Browser) is
    begin
        fl_abstract_browser_scrollbar_right (This.Void_Ptr);
    end Set_Vertical_Right;


    function Get_Scrollbar_Size
           (This : in Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_get_scrollbar_size (This.Void_Ptr));
    end Get_Scrollbar_Size;


    procedure Set_Scrollbar_Size
           (This  : in out Browser;
            Value : in     Integer) is
    begin
        fl_abstract_browser_set_scrollbar_size
           (This.Void_Ptr,
            Interfaces.C.int (Value));
    end Set_Scrollbar_Size;


    function Get_Line_Spacing
           (This : in Browser)
        return Natural is
    begin
        return Natural (fl_abstract_browser_get_linespacing (This.Void_Ptr));
    end Get_Line_Spacing;


    procedure Set_Line_Spacing
           (This  : in out Browser;
            Value : in     Natural) is
    begin
        fl_abstract_browser_set_linespacing (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Line_Spacing;




    --  Text Settings  --

    function Get_Text_Color
           (This : in Browser)
        return Color is
    begin
        return Color (fl_abstract_browser_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This  : in out Browser;
            Value : in     Color) is
    begin
        fl_abstract_browser_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Browser)
        return Font_Kind is
    begin
        return Font_Kind (fl_abstract_browser_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Browser;
            Font : in     Font_Kind) is
    begin
        fl_abstract_browser_set_textfont (This.Void_Ptr, To_C (Font));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Browser)
        return Font_Size is
    begin
        return Font_Size (fl_abstract_browser_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Browser;
            Size : in     Font_Size) is
    begin
        fl_abstract_browser_set_textsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    --  Dimensions, Redrawing  --

    procedure Resize
           (This       : in out Browser;
            X, Y, W, H : in     Integer) is
    begin
        fl_abstract_browser_resize
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Resize;


    procedure Bounding_Box
           (This       : in     Browser;
            X, Y, W, H :    out Integer) is
    begin
        fl_abstract_browser_bbox
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Bounding_Box;


    function Left_Edge
           (This : in Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_leftedge (This.Void_Ptr));
    end Left_Edge;


    procedure Redraw_Line
           (This : in out Browser;
            Item : in     Item_Cursor) is
    begin
        fl_abstract_browser_redraw_line (This.Void_Ptr, Cursor_To_Address (Item));
    end Redraw_Line;


    procedure Redraw_List
           (This : in out Browser) is
    begin
        fl_abstract_browser_redraw_lines (This.Void_Ptr);
    end Redraw_List;




    --  Optional Overrides  --

    function Full_List_Width
           (This : in Browser)
        return Integer
    is
        function my_full_width
               (V : in Storage.Integer_Address)
            return Interfaces.C.int;
        for my_full_width'Address use This.Wide_High_Ptrs (Full_List_Width_Ptr);
        pragma Import (Ada, my_full_width);
    begin
        return Integer (my_full_width (This.Void_Ptr));
    end Full_List_Width;


    function Full_List_Height
           (This : in Browser)
        return Integer
    is
        function my_full_height
               (V : in Storage.Integer_Address)
            return Interfaces.C.int;
        for my_full_height'Address use This.Wide_High_Ptrs (Full_List_Height_Ptr);
        pragma Import (Ada, my_full_height);
    begin
        return Integer (my_full_height (This.Void_Ptr));
    end Full_List_Height;


    function Average_Item_Height
           (This : in Browser)
        return Integer
    is
        function my_incr_height
               (V : in Storage.Integer_Address)
            return Interfaces.C.int;
        for my_incr_height'Address use This.Wide_High_Ptrs (Average_Item_Height_Ptr);
        pragma Import (Ada, my_incr_height);
    begin
        return Integer (my_incr_height (This.Void_Ptr));
    end Average_Item_Height;


    function Item_Quick_Height
           (This : in Browser;
            Item : in Item_Cursor)
        return Integer
    is
        function my_item_quick_height
               (V, I : Storage.Integer_Address)
            return Interfaces.C.int;
        for my_item_quick_height'Address use This.Wide_High_Ptrs (Item_Quick_Height_Ptr);
        pragma Import (Ada, my_item_quick_height);
    begin
        return Integer (my_item_quick_height
           (This.Void_Ptr,
            Cursor_To_Address (Item)));
    end Item_Quick_Height;




    --  Mandatory Overrides  --

    function Item_Width
           (This : in Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return raise Program_Error with "Browser Item_Width must be overridden";
    end Item_Width;

    function Item_Height
           (This : in Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return raise Program_Error with "Browser Item_Height must be overridden";
    end Item_Height;

    function Item_First
           (This : in Browser)
        return Item_Cursor is
    begin
        return raise Program_Error with "Browser Item_First must be overridden";
    end Item_First;

    function Item_Last
           (This : in Browser)
        return Item_Cursor is
    begin
        return raise Program_Error with "Browser Item_Last must be overridden";
    end Item_Last;

    function Item_Next
           (This : in Browser;
            Item : in Item_Cursor)
        return Item_Cursor is
    begin
        return raise Program_Error with "Browser Item_Next must be overridden";
    end Item_Next;

    function Item_Previous
           (This : in Browser;
            Item : in Item_Cursor)
        return Item_Cursor is
    begin
        return raise Program_Error with "Browser Item_Previous must be overridden";
    end Item_Previous;

    function Item_At
           (This  : in Browser;
            Index : in Positive)
        return Item_Cursor is
    begin
        return raise Program_Error with "Browser Item_At must be overridden";
    end Item_At;

    procedure Item_Select
           (This  : in out Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True) is
    begin
        raise Program_Error with "Browser Item_Select must be overridden";
    end Item_Select;

    function Item_Selected
           (This : in Browser;
            Item : in Item_Cursor)
        return Boolean is
    begin
        return raise Program_Error with "Browser Item_Selected must be overridden";
    end Item_Selected;

    procedure Item_Swap
           (This : in out Browser;
            A, B : in     Item_Cursor) is
    begin
        raise Program_Error with "Browser Item_Swap must be overridden";
    end Item_Swap;

    function Item_Text
           (This : in Browser;
            Item : in Item_Cursor)
        return String is
    begin
        return raise Program_Error with "Browser Item_Text must be overridden";
    end Item_Text;

    procedure Item_Draw
           (This       : in Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer) is
    begin
        raise Program_Error with "Browser Item_Draw must be overridden";
    end Item_Draw;




    --  Cache Invalidation  --

    procedure New_List
           (This : in out Browser) is
    begin
        fl_abstract_browser_new_list (This.Void_Ptr);
    end New_List;


    procedure Inserting
           (This : in out Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_abstract_browser_inserting
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Inserting;


    procedure Deleting
           (This : in out Browser;
            Item : in     Item_Cursor) is
    begin
        fl_abstract_browser_deleting
           (This.Void_Ptr,
            Cursor_To_Address (Item));
    end Deleting;


    procedure Replacing
           (This : in out Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_abstract_browser_replacing
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Replacing;


    procedure Swapping
           (This : in out Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_abstract_browser_swapping
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Swapping;


end FLTK.Widgets.Groups.Browsers;


