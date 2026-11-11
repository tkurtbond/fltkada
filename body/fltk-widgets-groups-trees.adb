

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


with

    FLTK.Tree_Icons,
    Interfaces.C,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.unsigned;


package body FLTK.Widgets.Groups.Trees is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_tree
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_tree, "new_fl_tree");
    pragma Inline (new_fl_tree);

    procedure free_fl_tree
           (T : in Storage.Integer_Address);
    pragma Import (C, free_fl_tree, "free_fl_tree");
    pragma Inline (free_fl_tree);




    --  Item Creation and Removal  --

    function fl_tree_add
           (T    : in Storage.Integer_Address;
            Path : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_add, "fl_tree_add");
    pragma Inline (fl_tree_add);

    function fl_tree_add_item
           (T    : in Storage.Integer_Address;
            Path : in Interfaces.C.char_array;
            Item : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_add_item, "fl_tree_add_item");
    pragma Inline (fl_tree_add_item);

    function fl_tree_insert
           (T     : in Storage.Integer_Address;
            Under : in Storage.Integer_Address;
            Name  : in Interfaces.C.char_array;
            Place : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_insert, "fl_tree_insert");
    pragma Inline (fl_tree_insert);

    function fl_tree_insert_above
           (T     : in Storage.Integer_Address;
            Above : in Storage.Integer_Address;
            Name  : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_insert_above, "fl_tree_insert_above");
    pragma Inline (fl_tree_insert_above);

    procedure fl_tree_remove
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_remove, "fl_tree_remove");
    pragma Inline (fl_tree_remove);

    procedure fl_tree_clear
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_tree_clear, "fl_tree_clear");
    pragma Inline (fl_tree_clear);

    procedure fl_tree_clear_children
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_clear_children, "fl_tree_clear_children");
    pragma Inline (fl_tree_clear_children);

    function fl_tree_find_item
           (T    : in Storage.Integer_Address;
            Path : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_find_item, "fl_tree_find_item");
    pragma Inline (fl_tree_find_item);




    --  Root  --

    function fl_tree_root
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_root, "fl_tree_root");
    pragma Inline (fl_tree_root);

    procedure fl_tree_set_root_label
           (T    : in Storage.Integer_Address;
            Text : in Interfaces.C.char_array);
    pragma Import (C, fl_tree_set_root_label, "fl_tree_set_root_label");
    pragma Inline (fl_tree_set_root_label);




    --  Callback Information  --

    function fl_tree_callback_item
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_callback_item, "fl_tree_callback_item");
    pragma Inline (fl_tree_callback_item);

    function fl_tree_callback_reason
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_callback_reason, "fl_tree_callback_reason");
    pragma Inline (fl_tree_callback_reason);

    function fl_tree_item_pathname
           (T   : in Storage.Integer_Address;
            Buf : in Interfaces.C.Strings.chars_ptr;
            Len : in Interfaces.C.int;
            I   : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_pathname, "fl_tree_item_pathname");
    pragma Inline (fl_tree_item_pathname);




    --  Walking the Tree  --

    function fl_tree_first
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_first, "fl_tree_first");
    pragma Inline (fl_tree_first);

    function fl_tree_last
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_last, "fl_tree_last");
    pragma Inline (fl_tree_last);




    --  Open and Close  --

    procedure fl_tree_open
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_open, "fl_tree_open");
    pragma Inline (fl_tree_open);

    procedure fl_tree_close
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_close, "fl_tree_close");
    pragma Inline (fl_tree_close);

    procedure fl_tree_open_toggle
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_open_toggle, "fl_tree_open_toggle");
    pragma Inline (fl_tree_open_toggle);




    --  Selection  --

    procedure fl_tree_select
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_select, "fl_tree_select");
    pragma Inline (fl_tree_select);

    procedure fl_tree_deselect
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_deselect, "fl_tree_deselect");
    pragma Inline (fl_tree_deselect);

    function fl_tree_select_all
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_select_all, "fl_tree_select_all");
    pragma Inline (fl_tree_select_all);

    function fl_tree_deselect_all
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_deselect_all, "fl_tree_deselect_all");
    pragma Inline (fl_tree_deselect_all);

    procedure fl_tree_select_toggle
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_select_toggle, "fl_tree_select_toggle");
    pragma Inline (fl_tree_select_toggle);

    function fl_tree_first_selected
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_first_selected, "fl_tree_first_selected");
    pragma Inline (fl_tree_first_selected);

    function fl_tree_last_selected
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_last_selected, "fl_tree_last_selected");
    pragma Inline (fl_tree_last_selected);

    function fl_tree_next_selected
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address;
            Up   : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_next_selected, "fl_tree_next_selected");
    pragma Inline (fl_tree_next_selected);

    function fl_tree_selected_count
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_selected_count, "fl_tree_selected_count");
    pragma Inline (fl_tree_selected_count);

    procedure fl_tree_selected_fill
           (T   : in Storage.Integer_Address;
            Buf : in Storage.Integer_Address;
            Max : in Interfaces.C.int);
    pragma Import (C, fl_tree_selected_fill, "fl_tree_selected_fill");
    pragma Inline (fl_tree_selected_fill);




    --  Preferences  --

    function fl_tree_get_show_root
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_show_root, "fl_tree_get_show_root");
    pragma Inline (fl_tree_get_show_root);

    procedure fl_tree_set_show_root
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_show_root, "fl_tree_set_show_root");
    pragma Inline (fl_tree_set_show_root);

    function fl_tree_get_show_collapse
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_show_collapse, "fl_tree_get_show_collapse");
    pragma Inline (fl_tree_get_show_collapse);

    procedure fl_tree_set_show_collapse
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_show_collapse, "fl_tree_set_show_collapse");
    pragma Inline (fl_tree_set_show_collapse);

    function fl_tree_get_select_mode
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_select_mode, "fl_tree_get_select_mode");
    pragma Inline (fl_tree_get_select_mode);

    procedure fl_tree_set_select_mode
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_select_mode, "fl_tree_set_select_mode");
    pragma Inline (fl_tree_set_select_mode);

    function fl_tree_get_connector_style
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_connector_style, "fl_tree_get_connector_style");
    pragma Inline (fl_tree_get_connector_style);

    procedure fl_tree_set_connector_style
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_connector_style, "fl_tree_set_connector_style");
    pragma Inline (fl_tree_set_connector_style);

    function fl_tree_get_sort_order
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_sort_order, "fl_tree_get_sort_order");
    pragma Inline (fl_tree_get_sort_order);

    procedure fl_tree_set_sort_order
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_sort_order, "fl_tree_set_sort_order");
    pragma Inline (fl_tree_set_sort_order);

    function fl_tree_get_item_label_font
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_item_label_font, "fl_tree_get_item_label_font");
    pragma Inline (fl_tree_get_item_label_font);

    procedure fl_tree_set_item_label_font
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_item_label_font, "fl_tree_set_item_label_font");
    pragma Inline (fl_tree_set_item_label_font);

    function fl_tree_get_item_label_size
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_item_label_size, "fl_tree_get_item_label_size");
    pragma Inline (fl_tree_get_item_label_size);

    procedure fl_tree_set_item_label_size
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_item_label_size, "fl_tree_set_item_label_size");
    pragma Inline (fl_tree_set_item_label_size);

    function fl_tree_get_item_label_color
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_tree_get_item_label_color, "fl_tree_get_item_label_color");
    pragma Inline (fl_tree_get_item_label_color);

    procedure fl_tree_set_item_label_color
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.unsigned);
    pragma Import (C, fl_tree_set_item_label_color, "fl_tree_set_item_label_color");
    pragma Inline (fl_tree_set_item_label_color);

    function fl_tree_get_item_label_bgcolor
           (T : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_tree_get_item_label_bgcolor, "fl_tree_get_item_label_bgcolor");
    pragma Inline (fl_tree_get_item_label_bgcolor);

    procedure fl_tree_set_item_label_bgcolor
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.unsigned);
    pragma Import (C, fl_tree_set_item_label_bgcolor, "fl_tree_set_item_label_bgcolor");
    pragma Inline (fl_tree_set_item_label_bgcolor);

    function fl_tree_get_margin_left
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_margin_left, "fl_tree_get_margin_left");
    pragma Inline (fl_tree_get_margin_left);

    procedure fl_tree_set_margin_left
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_margin_left, "fl_tree_set_margin_left");
    pragma Inline (fl_tree_set_margin_left);

    function fl_tree_get_widget_margin_left
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_widget_margin_left, "fl_tree_get_widget_margin_left");
    pragma Inline (fl_tree_get_widget_margin_left);

    procedure fl_tree_set_widget_margin_left
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_widget_margin_left, "fl_tree_set_widget_margin_left");
    pragma Inline (fl_tree_set_widget_margin_left);

    function fl_tree_get_margin_top
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_margin_top, "fl_tree_get_margin_top");
    pragma Inline (fl_tree_get_margin_top);

    procedure fl_tree_set_margin_top
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_margin_top, "fl_tree_set_margin_top");
    pragma Inline (fl_tree_set_margin_top);

    function fl_tree_get_margin_bottom
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_margin_bottom, "fl_tree_get_margin_bottom");
    pragma Inline (fl_tree_get_margin_bottom);

    procedure fl_tree_set_margin_bottom
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_margin_bottom, "fl_tree_set_margin_bottom");
    pragma Inline (fl_tree_set_margin_bottom);

    function fl_tree_get_open_child_margin_bottom
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_open_child_margin_bottom, "fl_tree_get_open_child_margin_bottom");
    pragma Inline (fl_tree_get_open_child_margin_bottom);

    procedure fl_tree_set_open_child_margin_bottom
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_open_child_margin_bottom, "fl_tree_set_open_child_margin_bottom");
    pragma Inline (fl_tree_set_open_child_margin_bottom);

    function fl_tree_get_user_icon_margin_left
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_user_icon_margin_left, "fl_tree_get_user_icon_margin_left");
    pragma Inline (fl_tree_get_user_icon_margin_left);

    procedure fl_tree_set_user_icon_margin_left
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_user_icon_margin_left, "fl_tree_set_user_icon_margin_left");
    pragma Inline (fl_tree_set_user_icon_margin_left);

    function fl_tree_get_label_margin_left
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_label_margin_left, "fl_tree_get_label_margin_left");
    pragma Inline (fl_tree_get_label_margin_left);

    procedure fl_tree_set_label_margin_left
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_label_margin_left, "fl_tree_set_label_margin_left");
    pragma Inline (fl_tree_set_label_margin_left);

    function fl_tree_get_connector_width
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_connector_width, "fl_tree_get_connector_width");
    pragma Inline (fl_tree_get_connector_width);

    procedure fl_tree_set_connector_width
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_connector_width, "fl_tree_set_connector_width");
    pragma Inline (fl_tree_set_connector_width);

    function fl_tree_get_line_spacing
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_line_spacing, "fl_tree_get_line_spacing");
    pragma Inline (fl_tree_get_line_spacing);

    procedure fl_tree_set_line_spacing
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_line_spacing, "fl_tree_set_line_spacing");
    pragma Inline (fl_tree_set_line_spacing);

    function fl_tree_get_item_draw_mode
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_item_draw_mode, "fl_tree_get_item_draw_mode");
    pragma Inline (fl_tree_get_item_draw_mode);

    procedure fl_tree_set_item_draw_mode
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_item_draw_mode, "fl_tree_set_item_draw_mode");
    pragma Inline (fl_tree_set_item_draw_mode);

    function fl_tree_get_select_box
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_select_box, "fl_tree_get_select_box");
    pragma Inline (fl_tree_get_select_box);

    procedure fl_tree_set_select_box
           (T   : in Storage.Integer_Address;
            Val : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_select_box, "fl_tree_set_select_box");
    pragma Inline (fl_tree_set_select_box);

    function fl_tree_get_icon
           (T    : in Storage.Integer_Address;
            What : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_get_icon, "fl_tree_get_icon");
    pragma Inline (fl_tree_get_icon);

    procedure fl_tree_set_icon
           (T    : in Storage.Integer_Address;
            What : in Interfaces.C.int;
            Img  : in Storage.Integer_Address);
    pragma Import (C, fl_tree_set_icon, "fl_tree_set_icon");
    pragma Inline (fl_tree_set_icon);

    function fl_tree_get_vposition
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_vposition, "fl_tree_get_vposition");
    pragma Inline (fl_tree_get_vposition);

    procedure fl_tree_set_vposition
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_vposition, "fl_tree_set_vposition");
    pragma Inline (fl_tree_set_vposition);

    function fl_tree_get_hposition
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_hposition, "fl_tree_get_hposition");
    pragma Inline (fl_tree_get_hposition);

    procedure fl_tree_set_hposition
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_hposition, "fl_tree_set_hposition");
    pragma Inline (fl_tree_set_hposition);

    function fl_tree_get_scrollbar_size
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_get_scrollbar_size, "fl_tree_get_scrollbar_size");
    pragma Inline (fl_tree_get_scrollbar_size);

    procedure fl_tree_set_scrollbar_size
           (T : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_tree_set_scrollbar_size, "fl_tree_set_scrollbar_size");
    pragma Inline (fl_tree_set_scrollbar_size);

    function fl_tree_displayed
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_displayed, "fl_tree_displayed");
    pragma Inline (fl_tree_displayed);

    procedure fl_tree_show_item
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_show_item, "fl_tree_show_item");
    pragma Inline (fl_tree_show_item);

    procedure fl_tree_show_item_top
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_show_item_top, "fl_tree_show_item_top");
    pragma Inline (fl_tree_show_item_top);

    procedure fl_tree_show_item_middle
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_show_item_middle, "fl_tree_show_item_middle");
    pragma Inline (fl_tree_show_item_middle);

    procedure fl_tree_show_item_bottom
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address);
    pragma Import (C, fl_tree_show_item_bottom, "fl_tree_show_item_bottom");
    pragma Inline (fl_tree_show_item_bottom);

    procedure fl_tree_show_item_offset
           (T    : in Storage.Integer_Address;
            Item : in Storage.Integer_Address;
            Y    : in Interfaces.C.int);
    pragma Import (C, fl_tree_show_item_offset, "fl_tree_show_item_offset");
    pragma Inline (fl_tree_show_item_offset);




    --  Debugging  --

    procedure fl_tree_show_self
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_tree_show_self, "fl_tree_show_self");
    pragma Inline (fl_tree_show_self);




    --  Drawing, Events  --

    procedure fl_tree_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_tree_draw, "fl_tree_draw");
    pragma Inline (fl_tree_draw);

    function fl_tree_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_handle, "fl_tree_handle");
    pragma Inline (fl_tree_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Tree) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Tree) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_tree (This.Void_Ptr);
            FLTK.Tree_Icons.Drop_All (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Tree;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Tree) is
    begin
        This.Draw_Ptr   := fl_tree_draw'Address;
        This.Handle_Ptr := fl_tree_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Tree is
        begin
            return This : Tree do
                This.Void_Ptr := new_fl_tree
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
            return Tree is
        begin
            return This : Tree := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  Item Validation  --
    -----------------------

    --  FLTK dereferences the item given to most Fl_Tree calls, so a null
    --  one crashes it (Fl_Tree.cxx, e.g. 1463, 1520, 1728); bug 127.
    function Item_Ptr
           (Item : in FLTK.Tree_Items.Tree_Item)
        return Storage.Integer_Address is
    begin
        if FLTK.Tree_Items.Is_Null (Item) then
            raise Constraint_Error with "No_Tree_Item given to a tree";
        end if;
        return Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item));
    end Item_Ptr;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Item Creation and Removal  --

    function Add
           (This : in out Tree;
            Path : in     String)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast
           (Storage.To_Address (fl_tree_add (This.Void_Ptr, Interfaces.C.To_C (Path))));
    end Add;


    function Add
           (This : in out Tree;
            Path : in     String;
            Item : in     FLTK.Tree_Items.Tree_Item)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast
           (Storage.To_Address
              (fl_tree_add_item
                 (This.Void_Ptr,
                  Interfaces.C.To_C (Path),
                  Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)))));
    end Add;


    function Insert
           (This  : in out Tree;
            Under : in     FLTK.Tree_Items.Tree_Item;
            Name  : in     String;
            Place : in     Natural)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast
           (Storage.To_Address
              (fl_tree_insert
                 (This.Void_Ptr,
                  Item_Ptr (Under),
                  Interfaces.C.To_C (Name),
                  Interfaces.C.int (Place))));
    end Insert;


    function Insert_Above
           (This  : in out Tree;
            Above : in     FLTK.Tree_Items.Tree_Item;
            Name  : in     String)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast
           (Storage.To_Address
              (fl_tree_insert_above
                 (This.Void_Ptr,
                  Item_Ptr (Above),
                  Interfaces.C.To_C (Name))));
    end Insert_Above;


    procedure Remove
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_remove (This.Void_Ptr, Item_Ptr (Item));
        FLTK.Tree_Icons.Drop_Unused (This.Void_Ptr);
    end Remove;


    procedure Clear
           (This : in out Tree) is
    begin
        fl_tree_clear (This.Void_Ptr);
        FLTK.Tree_Icons.Drop_Unused (This.Void_Ptr);
    end Clear;


    procedure Clear_Children
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_clear_children (This.Void_Ptr, Item_Ptr (Item));
        FLTK.Tree_Icons.Drop_Unused (This.Void_Ptr);
    end Clear_Children;


    function Find
           (This : in Tree;
            Path : in String)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast
           (Storage.To_Address (fl_tree_find_item (This.Void_Ptr, Interfaces.C.To_C (Path))));
    end Find;




    --  Root  --

    function Root
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_root (This.Void_Ptr)));
    end Root;


    procedure Set_Root_Label
           (This : in out Tree;
            Text : in     String) is
    begin
        fl_tree_set_root_label (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Set_Root_Label;




    --  Callback Information  --

    function Callback_Item
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_callback_item (This.Void_Ptr)));
    end Callback_Item;


    function Callback_Reason
           (This : in Tree)
        return Reason_Kind
    is
        Result : constant Interfaces.C.int := fl_tree_callback_reason (This.Void_Ptr);
    begin
        if Result in Reason_Kind'Pos (Reason_Kind'First) .. Reason_Kind'Pos (Reason_Kind'Last) then
            return Reason_Kind'Val (Result);
        else
            return No_Reason;
        end if;
    end Callback_Reason;


    function Item_Pathname
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return String
    is
        Length : Interfaces.C.size_t := 256;
        Result : Interfaces.C.int;
    begin
        loop
            declare
                Buffer : aliased Interfaces.C.char_array := (1 .. Length => Interfaces.C.nul);
            begin
                Result := fl_tree_item_pathname
                   (This.Void_Ptr,
                    Interfaces.C.Strings.To_Chars_Ptr (Buffer'Unchecked_Access),
                    Interfaces.C.int (Length),
                    Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
                if Result = 0 then
                    return Interfaces.C.To_Ada (Buffer);
                elsif Result = -1 then
                    return "";
                end if;
            end;
            --  -2 means the buffer was too small
            Length := Length * 2;
        end loop;
    end Item_Pathname;




    --  Walking the Tree  --

    function First
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_first (This.Void_Ptr)));
    end First;


    function Last
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_last (This.Void_Ptr)));
    end Last;




    --  Open and Close  --

    procedure Open
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_open (This.Void_Ptr, Item_Ptr (Item));
    end Open;


    procedure Close
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_close (This.Void_Ptr, Item_Ptr (Item));
    end Close;


    procedure Open_Toggle
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_open_toggle (This.Void_Ptr, Item_Ptr (Item));
    end Open_Toggle;




    --  Selection  --

    procedure Select_Item
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_select (This.Void_Ptr, Item_Ptr (Item));
    end Select_Item;


    procedure Deselect
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_deselect (This.Void_Ptr, Item_Ptr (Item));
    end Deselect;


    function Select_All
           (This : in out Tree)
        return Natural is
    begin
        return Natural (fl_tree_select_all (This.Void_Ptr));
    end Select_All;


    function Deselect_All
           (This : in out Tree)
        return Natural is
    begin
        return Natural (fl_tree_deselect_all (This.Void_Ptr));
    end Deselect_All;


    procedure Select_Toggle
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_select_toggle (This.Void_Ptr, Item_Ptr (Item));
    end Select_Toggle;


    function First_Selected
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_first_selected (This.Void_Ptr)));
    end First_Selected;


    function Last_Selected
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_last_selected (This.Void_Ptr)));
    end Last_Selected;


    function Next_Selected
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_next_selected
           (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)), 0)));
    end Next_Selected;


    function Prev_Selected
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return FLTK.Tree_Items.Tree_Item is
    begin
        return FLTK.Tree_Items.Cast (Storage.To_Address (fl_tree_next_selected
           (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)), 1)));
    end Prev_Selected;


    function Selected_Items
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item_Array
    is
        Count : constant Natural := Natural (fl_tree_selected_count (This.Void_Ptr));
        Buf   : array (1 .. Count) of aliased Storage.Integer_Address :=
            (others => Null_Pointer);
        Result : FLTK.Tree_Items.Tree_Item_Array (1 .. Count);
    begin
        if Count > 0 then
            fl_tree_selected_fill
               (This.Void_Ptr,
                Storage.To_Integer (Buf (1)'Address),
                Interfaces.C.int (Count));
            for I in Buf'Range loop
                Result (I) := FLTK.Tree_Items.Cast (Storage.To_Address (Buf (I)));
            end loop;
        end if;
        return Result;
    end Selected_Items;




    --  Preferences  --

    function Get_Show_Root
           (This : in Tree)
        return Boolean is
    begin
        return fl_tree_get_show_root (This.Void_Ptr) /= 0;
    end Get_Show_Root;


    procedure Set_Show_Root
           (This : in out Tree;
            To   : in     Boolean) is
    begin
        fl_tree_set_show_root (This.Void_Ptr, Boolean'Pos (To));
    end Set_Show_Root;


    function Get_Show_Collapse
           (This : in Tree)
        return Boolean is
    begin
        return fl_tree_get_show_collapse (This.Void_Ptr) /= 0;
    end Get_Show_Collapse;


    procedure Set_Show_Collapse
           (This : in out Tree;
            To   : in     Boolean) is
    begin
        fl_tree_set_show_collapse (This.Void_Ptr, Boolean'Pos (To));
    end Set_Show_Collapse;


    function Get_Select_Mode
           (This : in Tree)
        return FLTK.Tree_Items.Selection_Kind
    is
        Result : constant Interfaces.C.int := fl_tree_get_select_mode (This.Void_Ptr);
    begin
        return FLTK.Tree_Items.Selection_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Tree::selectmode returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Select_Mode;


    procedure Set_Select_Mode
           (This : in out Tree;
            Mode : in     FLTK.Tree_Items.Selection_Kind) is
    begin
        fl_tree_set_select_mode
           (This.Void_Ptr,
            Interfaces.C.int (FLTK.Tree_Items.Selection_Kind'Pos (Mode)));
    end Set_Select_Mode;


    function Get_Connector_Style
           (This : in Tree)
        return FLTK.Tree_Items.Connector_Kind
    is
        Result : constant Interfaces.C.int := fl_tree_get_connector_style (This.Void_Ptr);
    begin
        return FLTK.Tree_Items.Connector_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Tree::connectorstyle returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Connector_Style;


    procedure Set_Connector_Style
           (This  : in out Tree;
            Style : in     FLTK.Tree_Items.Connector_Kind) is
    begin
        fl_tree_set_connector_style
           (This.Void_Ptr,
            Interfaces.C.int (FLTK.Tree_Items.Connector_Kind'Pos (Style)));
    end Set_Connector_Style;


    function Get_Sort_Order
           (This : in Tree)
        return FLTK.Tree_Items.Sort_Kind
    is
        Result : constant Interfaces.C.int := fl_tree_get_sort_order (This.Void_Ptr);
    begin
        return FLTK.Tree_Items.Sort_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Tree::sortorder returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Sort_Order;


    procedure Set_Sort_Order
           (This  : in out Tree;
            Order : in     FLTK.Tree_Items.Sort_Kind) is
    begin
        fl_tree_set_sort_order
           (This.Void_Ptr,
            Interfaces.C.int (FLTK.Tree_Items.Sort_Kind'Pos (Order)));
    end Set_Sort_Order;


    function Get_Item_Label_Font
           (This : in Tree)
        return Font_Kind
    is
        Result : constant Interfaces.C.int := fl_tree_get_item_label_font (This.Void_Ptr);
    begin
        return Font_Kind (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Tree::item_labelfont returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Item_Label_Font;


    procedure Set_Item_Label_Font
           (This : in out Tree;
            Kind : in     Font_Kind) is
    begin
        fl_tree_set_item_label_font (This.Void_Ptr, To_C (Kind));
    end Set_Item_Label_Font;


    function Get_Item_Label_Size
           (This : in Tree)
        return Font_Size is
    begin
        return Font_Size (fl_tree_get_item_label_size (This.Void_Ptr));
    end Get_Item_Label_Size;


    procedure Set_Item_Label_Size
           (This : in out Tree;
            Size : in     Font_Size) is
    begin
        fl_tree_set_item_label_size (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Item_Label_Size;


    function Get_Item_Label_Color
           (This : in Tree)
        return Color is
    begin
        return Color (fl_tree_get_item_label_color (This.Void_Ptr));
    end Get_Item_Label_Color;


    procedure Set_Item_Label_Color
           (This : in out Tree;
            Hue  : in     Color) is
    begin
        fl_tree_set_item_label_color (This.Void_Ptr, Interfaces.C.unsigned (Hue));
    end Set_Item_Label_Color;


    function Get_Margin_Left
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_margin_left (This.Void_Ptr));
    end Get_Margin_Left;


    procedure Set_Margin_Left
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_margin_left (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Margin_Left;


    function Get_Widget_Margin_Left
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_widget_margin_left (This.Void_Ptr));
    end Get_Widget_Margin_Left;


    procedure Set_Widget_Margin_Left
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_widget_margin_left (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Widget_Margin_Left;


    function Get_Margin_Top
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_margin_top (This.Void_Ptr));
    end Get_Margin_Top;


    procedure Set_Margin_Top
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_margin_top (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Margin_Top;


    function Get_Margin_Bottom
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_margin_bottom (This.Void_Ptr));
    end Get_Margin_Bottom;


    procedure Set_Margin_Bottom
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_margin_bottom (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Margin_Bottom;


    function Get_Open_Child_Margin_Bottom
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_open_child_margin_bottom (This.Void_Ptr));
    end Get_Open_Child_Margin_Bottom;


    procedure Set_Open_Child_Margin_Bottom
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_open_child_margin_bottom (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Open_Child_Margin_Bottom;


    function Get_User_Icon_Margin_Left
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_user_icon_margin_left (This.Void_Ptr));
    end Get_User_Icon_Margin_Left;


    procedure Set_User_Icon_Margin_Left
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_user_icon_margin_left (This.Void_Ptr, Interfaces.C.int (To));
    end Set_User_Icon_Margin_Left;


    function Get_Label_Margin_Left
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_label_margin_left (This.Void_Ptr));
    end Get_Label_Margin_Left;


    procedure Set_Label_Margin_Left
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_label_margin_left (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Label_Margin_Left;


    function Get_Connector_Width
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_connector_width (This.Void_Ptr));
    end Get_Connector_Width;


    procedure Set_Connector_Width
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_connector_width (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Connector_Width;


    function Get_Line_Spacing
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_line_spacing (This.Void_Ptr));
    end Get_Line_Spacing;


    procedure Set_Line_Spacing
           (This : in out Tree;
            To   : in     Integer) is
    begin
        fl_tree_set_line_spacing (This.Void_Ptr, Interfaces.C.int (To));
    end Set_Line_Spacing;


    function Get_Item_Draw_Mode
           (This : in Tree)
        return FLTK.Tree_Items.Item_Draw_Mode
    is
        Raw : constant Interfaces.C.int := fl_tree_get_item_draw_mode (This.Void_Ptr);
    begin
        return
           (Label_And_Widget   => Raw = 1 or Raw = 3,
            Height_From_Widget => Raw = 2 or Raw = 3);
    end Get_Item_Draw_Mode;


    procedure Set_Item_Draw_Mode
           (This : in out Tree;
            Mode : in     FLTK.Tree_Items.Item_Draw_Mode)
    is
        Raw : Interfaces.C.int := 0;
    begin
        if Mode.Label_And_Widget then
            Raw := Raw + 1;
        end if;
        if Mode.Height_From_Widget then
            Raw := Raw + 2;
        end if;
        fl_tree_set_item_draw_mode (This.Void_Ptr, Raw);
    end Set_Item_Draw_Mode;


    function Get_Select_Box
           (This : in Tree)
        return Box_Kind
    is
        Result : constant Interfaces.C.int := fl_tree_get_select_box (This.Void_Ptr);
    begin
        return Box_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Tree::selectbox returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Select_Box;


    procedure Set_Select_Box
           (This : in out Tree;
            Box  : in     Box_Kind) is
    begin
        fl_tree_set_select_box (This.Void_Ptr, Box_Kind'Pos (Box));
    end Set_Select_Box;

    function Get_Item_Label_BG_Color
           (This : in Tree)
        return Color is
    begin
        return Color (fl_tree_get_item_label_bgcolor (This.Void_Ptr));
    end Get_Item_Label_BG_Color;


    procedure Set_Item_Label_BG_Color
           (This : in out Tree;
            Hue  : in     Color) is
    begin
        fl_tree_set_item_label_bgcolor (This.Void_Ptr, Interfaces.C.unsigned (Hue));
    end Set_Item_Label_BG_Color;




    --  Icons  --

    type Icon_Kind is (Open_Icon, Close_Icon, User_Icon);


    function Get_Icon
           (This : in Tree;
            Kind : in Icon_Kind)
        return access FLTK.Images.Image'Class is
    begin
        return FLTK.Tree_Icons.Find
           (This.Void_Ptr, fl_tree_get_icon (This.Void_Ptr, Icon_Kind'Pos (Kind)));
    end Get_Icon;


    procedure Set_Icon
           (This : in out Tree;
            Kind : in     Icon_Kind;
            Icon : in     FLTK.Images.Image'Class)
    is
        Ptr : Storage.Integer_Address := Null_Pointer;
    begin
        if Wrapper (Icon).Void_Ptr /= Null_Pointer then
            Ptr := FLTK.Tree_Icons.Hold_Private (This.Void_Ptr, Icon);
        end if;
        fl_tree_set_icon (This.Void_Ptr, Icon_Kind'Pos (Kind), Ptr);
        FLTK.Tree_Icons.Drop_Unused (This.Void_Ptr);
    end Set_Icon;


    procedure Clear_Icon
           (This : in out Tree;
            Kind : in     Icon_Kind) is
    begin
        fl_tree_set_icon (This.Void_Ptr, Icon_Kind'Pos (Kind), Null_Pointer);
        FLTK.Tree_Icons.Drop_Unused (This.Void_Ptr);
    end Clear_Icon;


    function Get_Open_Icon
           (This : in Tree)
        return access FLTK.Images.Image'Class is
    begin
        return Get_Icon (This, Open_Icon);
    end Get_Open_Icon;


    procedure Set_Open_Icon
           (This : in out Tree;
            Icon : in     FLTK.Images.Image'Class) is
    begin
        Set_Icon (This, Open_Icon, Icon);
    end Set_Open_Icon;


    procedure Clear_Open_Icon
           (This : in out Tree) is
    begin
        Clear_Icon (This, Open_Icon);
    end Clear_Open_Icon;


    function Get_Close_Icon
           (This : in Tree)
        return access FLTK.Images.Image'Class is
    begin
        return Get_Icon (This, Close_Icon);
    end Get_Close_Icon;


    procedure Set_Close_Icon
           (This : in out Tree;
            Icon : in     FLTK.Images.Image'Class) is
    begin
        Set_Icon (This, Close_Icon, Icon);
    end Set_Close_Icon;


    procedure Clear_Close_Icon
           (This : in out Tree) is
    begin
        Clear_Icon (This, Close_Icon);
    end Clear_Close_Icon;


    function Get_User_Icon
           (This : in Tree)
        return access FLTK.Images.Image'Class is
    begin
        return Get_Icon (This, User_Icon);
    end Get_User_Icon;


    procedure Set_User_Icon
           (This : in out Tree;
            Icon : in     FLTK.Images.Image'Class) is
    begin
        Set_Icon (This, User_Icon, Icon);
    end Set_User_Icon;


    procedure Clear_User_Icon
           (This : in out Tree) is
    begin
        Clear_Icon (This, User_Icon);
    end Clear_User_Icon;




    --  Scrolling  --


    function Get_V_Position
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_vposition (This.Void_Ptr));
    end Get_V_Position;


    procedure Set_V_Position
           (This  : in out Tree;
            Value : in     Integer) is
    begin
        fl_tree_set_vposition (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_V_Position;


    function Get_H_Position
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_hposition (This.Void_Ptr));
    end Get_H_Position;


    procedure Set_H_Position
           (This  : in out Tree;
            Value : in     Integer) is
    begin
        fl_tree_set_hposition (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_H_Position;


    function Get_Scrollbar_Size
           (This : in Tree)
        return Integer is
    begin
        return Integer (fl_tree_get_scrollbar_size (This.Void_Ptr));
    end Get_Scrollbar_Size;


    procedure Set_Scrollbar_Size
           (This  : in out Tree;
            Value : in     Integer) is
    begin
        fl_tree_set_scrollbar_size (This.Void_Ptr, Interfaces.C.int (Value));
    end Set_Scrollbar_Size;


    function Is_Displayed
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return Boolean is
    begin
        return fl_tree_displayed
           (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item))) /= 0;
    end Is_Displayed;


    procedure Show_Item
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_show_item
           (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Show_Item;


    procedure Show_Item
           (This   : in out Tree;
            Item   : in     FLTK.Tree_Items.Tree_Item;
            Offset : in     Integer) is
    begin
        fl_tree_show_item_offset
           (This.Void_Ptr,
            Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)),
            Interfaces.C.int (Offset));
    end Show_Item;


    procedure Show_Item_Top
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_show_item_top
           (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Show_Item_Top;


    procedure Show_Item_Middle
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_show_item_middle
           (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Show_Item_Middle;


    procedure Show_Item_Bottom
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_show_item_bottom
           (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Show_Item_Bottom;




    --  Debugging  --

    procedure Show_Self
           (This : in out Tree) is
    begin
        fl_tree_show_self (This.Void_Ptr);
    end Show_Self;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Tree) is
    begin
        Group (This).Draw;
    end Draw;


    function Handle
           (This  : in out Tree;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Group (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Groups.Trees;


