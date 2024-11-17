

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings,
    System.Address_To_Access_Conversions;


package body FLTK.Widgets.Groups.Browsers is


    ------------------------
    --  Constants From C  --
    ------------------------

    fl_sort_ascending : constant Interfaces.C.int;
    pragma Import (C, fl_sort_ascending, "fl_sort_ascending");

    fl_sort_descending : constant Interfaces.C.int;
    pragma Import (C, fl_sort_descending, "fl_sort_descending");




    ------------------------
    --  Functions From C  --
    ------------------------

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

    package Browser_Convert is new System.Address_To_Access_Conversions (Abstract_Browser'Class);


    function Full_Width_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Full_Width_Hook, "browser_full_width_hook");

    function Full_Width_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Full_List_Width);
    end Full_Width_Hook;


    function Full_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Full_Height_Hook, "browser_full_height_hook");

    function Full_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Full_List_Height);
    end Full_Height_Hook;


    function Average_Item_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Average_Item_Height_Hook, "browser_incr_height_hook");

    function Average_Item_Height_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Average_Item_Height);
    end Average_Item_Height_Hook;


    function Item_Quick_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Quick_Height_Hook, "browser_item_quick_height_hook");

    function Item_Quick_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Item_Quick_Height (Address_To_Cursor (Item_Ptr)));
    end Item_Quick_Height_Hook;


    function Item_Width_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Width_Hook, "browser_item_width_hook");

    function Item_Width_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Item_Width (Address_To_Cursor (Item_Ptr)));
    end Item_Width_Hook;


    function Item_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Height_Hook, "browser_item_height_hook");

    function Item_Height_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Interfaces.C.int (Ada_Object.Item_Height (Address_To_Cursor (Item_Ptr)));
    end Item_Height_Hook;


    function Item_First_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_First_Hook, "browser_item_first_hook");

    function Item_First_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_First);
    end Item_First_Hook;


    function Item_Last_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_Last_Hook, "browser_item_last_hook");

    function Item_Last_Hook
           (Ada_Addr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_Last);
    end Item_Last_Hook;


    function Item_Next_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_Next_Hook, "browser_item_next_hook");

    function Item_Next_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_Next (Address_To_Cursor (Item_Ptr)));
    end Item_Next_Hook;


    function Item_Previous_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Export (C, Item_Previous_Hook, "browser_item_prev_hook");

    function Item_Previous_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Storage.Integer_Address
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Cursor_To_Address (Ada_Object.Item_Previous (Address_To_Cursor (Item_Ptr)));
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
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
        use type Interfaces.C.int;
    begin
        return Cursor_To_Address (Ada_Object.Item_At (Positive (Index + 1)));
    end Item_At_Hook;


    procedure Item_Select_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            Int_State          : in Interfaces.C.int);
    pragma Export (C, Item_Select_Hook, "browser_item_select_hook");

    procedure Item_Select_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            Int_State          : in Interfaces.C.int)
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
        use type Interfaces.C.int;
    begin
        Ada_Object.Item_Select
           (Address_To_Cursor (Item_Ptr),
            Int_State /= 0);
    end Item_Select_Hook;


    function Item_Selected_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Export (C, Item_Selected_Hook, "browser_item_selected_hook");

    function Item_Selected_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        return Boolean'Pos (Ada_Object.Item_Selected (Address_To_Cursor (Item_Ptr)));
    end Item_Selected_Hook;


    procedure Item_Swap_Hook
           (Ada_Addr, A_Ptr, B_Ptr : in Storage.Integer_Address);
    pragma Export (C, Item_Swap_Hook, "browser_item_swap_hook");

    procedure Item_Swap_Hook
           (Ada_Addr, A_Ptr, B_Ptr : in Storage.Integer_Address)
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        Ada_Object.Item_Swap (Address_To_Cursor (A_Ptr), Address_To_Cursor (B_Ptr));
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

    Text_Hook_Storage  : Interfaces.C.Strings.chars_ptr_array (1 .. 2);
    Current_Text_Store : Interfaces.C.size_t := 1;

    function Item_Text_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Export (C, Item_Text_Hook, "browser_item_text_hook");

    function Item_Text_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        Interfaces.C.Strings.Free (Text_Hook_Storage (Current_Text_Store));
        Text_Hook_Storage (Current_Text_Store) := Interfaces.C.Strings.New_String
            (Ada_Object.Item_Text (Address_To_Cursor (Item_Ptr)));
        return C_Char_Is_Not_A_String : Interfaces.C.Strings.chars_ptr :=
            Text_Hook_Storage (Current_Text_Store)
        do
            Current_Text_Store := Current_Text_Store + 1;
            if Current_Text_Store > Text_Hook_Storage'Last then
                Current_Text_Store := Text_Hook_Storage'First;
            end if;
        end return;
    end Item_Text_Hook;


    procedure Item_Draw_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            X, Y, W, H         : in Interfaces.C.int);
    pragma Export (C, Item_Draw_Hook, "browser_item_draw_hook");

    procedure Item_Draw_Hook
           (Ada_Addr, Item_Ptr : in Storage.Integer_Address;
            X, Y, W, H         : in Interfaces.C.int)
    is
        Ada_Object : access Abstract_Browser'Class :=
            Browser_Convert.To_Pointer (Storage.To_Address (Ada_Addr));
    begin
        Ada_Object.Item_Draw
           (Address_To_Cursor (Item_Ptr),
            Integer (X),
            Integer (Y),
            Integer (W),
            Integer (H));
    end Item_Draw_Hook;




    -----------------------------------
    --  Controlled Type Subprograms  --
    -----------------------------------

    procedure Extra_Final
           (This : in out Abstract_Browser) is
    begin
        Extra_Final (Widget (This.Horizon));
        Extra_Final (Widget (This.Vertigo));
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Abstract_Browser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_abstract_browser (This.Void_Ptr);
        end if;
    end Finalize;


    procedure Finalize
           (This : in out Item_Text_Hook_Final_Controller) is
    begin
        for Index in Text_Hook_Storage'Range loop
            Interfaces.C.Strings.Free (Text_Hook_Storage (Index));
        end loop;
    end Finalize;




    ---------------------------
    --  Abstract Browser API --
    ---------------------------

    procedure Extra_Init
           (This       : in out Abstract_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Widget (This.Horizon).Void_Ptr := fl_abstract_browser_hscrollbar (This.Void_Ptr);
        Widget (This.Horizon).Needs_Dealloc := False;
        Extra_Init
           (Widget (This.Horizon),
            This.Horizon.Get_X,
            This.Horizon.Get_Y,
            This.Horizon.Get_W,
            This.Horizon.Get_H,
            This.Horizon.Get_Label);
        Widget (This.Vertigo).Void_Ptr := fl_abstract_browser_scrollbar (This.Void_Ptr);
        Widget (This.Vertigo).Needs_Dealloc := False;
        Extra_Init
           (Widget (This.Vertigo),
            This.Vertigo.Get_X,
            This.Vertigo.Get_Y,
            This.Vertigo.Get_W,
            This.Vertigo.Get_H,
            This.Vertigo.Get_Label);
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Abstract_Browser is
        begin
            return This : Abstract_Browser do
                This.Void_Ptr := new_fl_abstract_browser
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;

    end Forge;




    --  Access to the Browser's self contained scrollbars

    function H_Bar
           (This : in out Abstract_Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Horizon'Unchecked_Access);
    end H_Bar;


    function V_Bar
           (This : in out Abstract_Browser)
        return Valuators.Sliders.Scrollbars.Scrollbar_Reference is
    begin
        return (Data => This.Vertigo'Unchecked_Access);
    end V_Bar;




    --  Item related settings

    function Set_Select
           (This         : in out Abstract_Browser;
            Item         : in     Item_Cursor;
            State        : in     Boolean := True;
            Do_Callbacks : in     Boolean := False)
        return Boolean
    is
        Code : Interfaces.C.int := fl_abstract_browser_select
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Boolean'Pos (State),
            Boolean'Pos (Do_Callbacks));
    begin
        if Code not in 0 .. 1 then
            raise Program_Error;
        end if;
        return Boolean'Val (Code);
    end Set_Select;


    function Select_Only
           (This         : in out Abstract_Browser;
            Item         : in     Item_Cursor;
            Do_Callbacks : in     Boolean := False)
        return Boolean
    is
        Code : Interfaces.C.int := fl_abstract_browser_select_only
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Boolean'Pos (Do_Callbacks));
    begin
        if Code not in 0 .. 1 then
            raise Program_Error;
        end if;
        return Boolean'Val (Code);
    end Select_Only;


    function Current_Selection
           (This : in Abstract_Browser)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_abstract_browser_selection (This.Void_Ptr));
    end Current_Selection;


    function Deselect
           (This         : in out Abstract_Browser;
            Do_Callbacks : in     Boolean := False)
        return Boolean
    is
        Code : Interfaces.C.int := fl_abstract_browser_deselect
           (This.Void_Ptr,
            Boolean'Pos (Do_Callbacks));
    begin
        if Code not in 0 .. 1 then
            raise Program_Error;
        end if;
        return Boolean'Val (Code);
    end Deselect;


    procedure Display
           (This : in out Abstract_Browser;
            Item : in     Item_Cursor) is
    begin
        fl_abstract_browser_display (This.Void_Ptr, Cursor_To_Address (Item));
    end Display;


    function Is_Displayed
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Boolean
    is
        Code : Interfaces.C.int := fl_abstract_browser_displayed
           (This.Void_Ptr,
            Cursor_To_Address (Item));
    begin
        if Code not in 0 .. 1 then
            raise Program_Error;
        end if;
        return Boolean'Val (Code);
    end Is_Displayed;


    function Find_Item
           (This  : in Abstract_Browser;
            Y_Pos : in Integer)
        return Item_Cursor is
    begin
        return Address_To_Cursor
            (fl_abstract_browser_find_item (This.Void_Ptr, Interfaces.C.int (Y_Pos)));
    end Find_Item;


    function Top_Item
           (This : in Abstract_Browser)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_abstract_browser_top (This.Void_Ptr));
    end Top_Item;


    procedure Sort
           (This  : in out Abstract_Browser;
            Order : in     Sort_Order)
    is
        Code : Interfaces.C.int :=
           (case Order is
            when Ascending  => fl_sort_ascending,
            when Descending => fl_sort_descending);
    begin
        fl_abstract_browser_sort (This.Void_Ptr, Code);
    end Sort;




    --  Scrollbar related settings

    function Get_Scrollbar_Mode
           (This : in Abstract_Browser)
        return Scrollbar_Mode is
    begin
        return Uchar_To_Mode (fl_abstract_browser_get_has_scrollbar (This.Void_Ptr));
    end Get_Scrollbar_Mode;


    procedure Set_Scrollbar_Mode
           (This : in out Abstract_Browser;
            Mode : in     Scrollbar_Mode) is
    begin
        fl_abstract_browser_set_has_scrollbar (This.Void_Ptr, Mode_To_Uchar (Mode));
    end Set_Scrollbar_Mode;


    function Get_H_Position
           (This : in Abstract_Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_get_hposition (This.Void_Ptr));
    end Get_H_Position;


    procedure Set_H_Position
           (This  : in out Abstract_Browser;
            Value : in     Integer) is
    begin
        fl_abstract_browser_set_hposition
           (This.Void_Ptr,
            Interfaces.C.int (Value));
    end Set_H_Position;


    function Get_V_Position
           (This : in Abstract_Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_get_position (This.Void_Ptr));
    end Get_V_Position;


    procedure Set_V_Position
           (This  : in out Abstract_Browser;
            Value : in     Integer) is
    begin
        fl_abstract_browser_set_position
           (This.Void_Ptr,
            Interfaces.C.int (Value));
    end Set_V_Position;


    procedure Set_Vertical_Left
           (This : in out Abstract_Browser) is
    begin
        fl_abstract_browser_scrollbar_left (This.Void_Ptr);
    end Set_Vertical_Left;


    procedure Set_Vertical_Right
           (This : in out Abstract_Browser) is
    begin
        fl_abstract_browser_scrollbar_right (This.Void_Ptr);
    end Set_Vertical_Right;


    function Get_Scrollbar_Size
           (This : in Abstract_Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_get_scrollbar_size (This.Void_Ptr));
    end Get_Scrollbar_Size;


    procedure Set_Scrollbar_Size
           (This  : in out Abstract_Browser;
            Value : in     Integer) is
    begin
        fl_abstract_browser_set_scrollbar_size
           (This.Void_Ptr,
            Interfaces.C.int (Value));
    end Set_Scrollbar_Size;




    --  Text related settings

    function Get_Text_Color
           (This : in Abstract_Browser)
        return Color is
    begin
        return Color (fl_abstract_browser_get_textcolor (This.Void_Ptr));
    end Get_Text_Color;


    procedure Set_Text_Color
           (This  : in out Abstract_Browser;
            Value : in     Color) is
    begin
        fl_abstract_browser_set_textcolor (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Set_Text_Color;


    function Get_Text_Font
           (This : in Abstract_Browser)
        return Font_Kind is
    begin
        return Font_Kind'Val (fl_abstract_browser_get_textfont (This.Void_Ptr));
    end Get_Text_Font;


    procedure Set_Text_Font
           (This : in out Abstract_Browser;
            Font : in     Font_Kind) is
    begin
        fl_abstract_browser_set_textfont (This.Void_Ptr, Font_Kind'Pos (Font));
    end Set_Text_Font;


    function Get_Text_Size
           (This : in Abstract_Browser)
        return Font_Size is
    begin
        return Font_Size (fl_abstract_browser_get_textsize (This.Void_Ptr));
    end Get_Text_Size;


    procedure Set_Text_Size
           (This : in out Abstract_Browser;
            Size : in     Font_Size) is
    begin
        fl_abstract_browser_set_textsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Text_Size;




    --  Graphical dimensions and redrawing

    procedure Resize
           (This       : in out Abstract_Browser;
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
           (This       : in     Abstract_Browser;
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
           (This : in Abstract_Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_leftedge (This.Void_Ptr));
    end Left_Edge;


    procedure Redraw_Line
           (This : in out Abstract_Browser;
            Item : in     Item_Cursor) is
    begin
        fl_abstract_browser_redraw_line (This.Void_Ptr, Cursor_To_Address (Item));
    end Redraw_Line;


    procedure Redraw_List
           (This : in out Abstract_Browser) is
    begin
        fl_abstract_browser_redraw_lines (This.Void_Ptr);
    end Redraw_List;




    --  Optional Override API

    function Full_List_Width
           (This : in Abstract_Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_full_width (This.Void_Ptr));
    end Full_List_Width;


    function Full_List_Height
           (This : in Abstract_Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_full_height (This.Void_Ptr));
    end Full_List_Height;


    function Average_Item_Height
           (This : in Abstract_Browser)
        return Integer is
    begin
        return Integer (fl_abstract_browser_incr_height (This.Void_Ptr));
    end Average_Item_Height;


    function Item_Quick_Height
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return Integer (fl_abstract_browser_item_quick_height
           (This.Void_Ptr,
            Cursor_To_Address (Item)));
    end Item_Quick_Height;




    --  Mandatory Override API

    function Item_Width
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return raise Program_Error with "Abstract_Browser Item_Width must be overridden";
    end Item_Width;

    function Item_Height
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return raise Program_Error with "Abstract_Browser Item_Height must be overridden";
    end Item_Height;

    function Item_First
           (This : in Abstract_Browser)
        return Item_Cursor is
    begin
        return raise Program_Error with "Abstract_Browser Item_First must be overridden";
    end Item_First;

    function Item_Last
           (This : in Abstract_Browser)
        return Item_Cursor is
    begin
        return raise Program_Error with "Abstract_Browser Item_Last must be overridden";
    end Item_Last;

    function Item_Next
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Item_Cursor is
    begin
        return raise Program_Error with "Abstract_Browser Item_Next must be overridden";
    end Item_Next;

    function Item_Previous
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Item_Cursor is
    begin
        return raise Program_Error with "Abstract_Browser Item_Previous must be overridden";
    end Item_Previous;

    function Item_At
           (This  : in Abstract_Browser;
            Index : in Positive)
        return Item_Cursor is
    begin
        return raise Program_Error with "Abstract_Browser Item_At must be overridden";
    end Item_At;

    procedure Item_Select
           (This  : in out Abstract_Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True) is
    begin
        raise Program_Error with "Abstract_Browser Item_Select must be overridden";
    end Item_Select;

    function Item_Selected
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return Boolean is
    begin
        return raise Program_Error with "Abstract_Browser Item_Selected must be overridden";
    end Item_Selected;

    procedure Item_Swap
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor) is
    begin
        raise Program_Error with "Abstract_Browser Item_Swap must be overridden";
    end Item_Swap;

    function Item_Text
           (This : in Abstract_Browser;
            Item : in Item_Cursor)
        return String is
    begin
        return raise Program_Error with "Abstract_Browser Item_Text must be overridden";
    end Item_Text;

    procedure Item_Draw
           (This       : in Abstract_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer) is
    begin
        raise Program_Error with "Abstract_Browser Item_Draw must be overridden";
    end Item_Draw;




    --  Cache invalidation

    procedure New_List
           (This : in out Abstract_Browser) is
    begin
        fl_abstract_browser_new_list (This.Void_Ptr);
    end New_List;


    procedure Inserting
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_abstract_browser_inserting
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Inserting;


    procedure Deleting
           (This : in out Abstract_Browser;
            Item : in     Item_Cursor) is
    begin
        fl_abstract_browser_deleting
           (This.Void_Ptr,
            Cursor_To_Address (Item));
    end Deleting;


    procedure Replacing
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_abstract_browser_replacing
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Replacing;


    procedure Swapping
           (This : in out Abstract_Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_abstract_browser_swapping
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Swapping;




    --  Standard Override API

    procedure Draw
           (This : in out Abstract_Browser) is
    begin
        fl_abstract_browser_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Abstract_Browser;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
           (fl_abstract_browser_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Browsers;


