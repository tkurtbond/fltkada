

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

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


    procedure Remove
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_remove (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Remove;


    procedure Clear
           (This : in out Tree) is
    begin
        fl_tree_clear (This.Void_Ptr);
    end Clear;


    procedure Clear_Children
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_clear_children
           (This.Void_Ptr,
            Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
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
        fl_tree_open (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Open;


    procedure Close
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_close (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Close;


    procedure Open_Toggle
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_open_toggle (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Open_Toggle;




    --  Selection  --

    procedure Select_Item
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_select (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
    end Select_Item;


    procedure Deselect
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item) is
    begin
        fl_tree_deselect (This.Void_Ptr, Storage.To_Integer (FLTK.Tree_Items.Address_Of (Item)));
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
        return Font_Kind'Val (Result);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Tree::item_labelfont returned unexpected int value of " &
        Interfaces.C.int'Image (Result);
    end Get_Item_Label_Font;


    procedure Set_Item_Label_Font
           (This : in out Tree;
            Kind : in     Font_Kind) is
    begin
        fl_tree_set_item_label_font (This.Void_Ptr, Interfaces.C.int (Font_Kind'Pos (Kind)));
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


