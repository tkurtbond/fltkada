

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Tree_Items is


    ------------------------
    --  Functions From C  --
    ------------------------

    function fl_tree_item_get_label
           (TI : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_tree_item_get_label, "fl_tree_item_get_label");
    pragma Inline (fl_tree_item_get_label);

    procedure fl_tree_item_set_label
           (TI : in Storage.Integer_Address;
            T  : in Interfaces.C.char_array);
    pragma Import (C, fl_tree_item_set_label, "fl_tree_item_set_label");
    pragma Inline (fl_tree_item_set_label);




    function fl_tree_item_is_open
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_is_open, "fl_tree_item_is_open");
    pragma Inline (fl_tree_item_is_open);

    function fl_tree_item_is_selected
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_is_selected, "fl_tree_item_is_selected");
    pragma Inline (fl_tree_item_is_selected);

    function fl_tree_item_is_active
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_is_active, "fl_tree_item_is_active");
    pragma Inline (fl_tree_item_is_active);

    function fl_tree_item_is_visible
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_is_visible, "fl_tree_item_is_visible");
    pragma Inline (fl_tree_item_is_visible);

    function fl_tree_item_is_root
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_is_root, "fl_tree_item_is_root");
    pragma Inline (fl_tree_item_is_root);




    function fl_tree_item_children
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_children, "fl_tree_item_children");
    pragma Inline (fl_tree_item_children);

    function fl_tree_item_child
           (TI    : in Storage.Integer_Address;
            Place : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_child, "fl_tree_item_child");
    pragma Inline (fl_tree_item_child);

    function fl_tree_item_parent
           (TI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_parent, "fl_tree_item_parent");
    pragma Inline (fl_tree_item_parent);

    function fl_tree_item_depth
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_depth, "fl_tree_item_depth");
    pragma Inline (fl_tree_item_depth);

    function fl_tree_item_next
           (TI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_next, "fl_tree_item_next");
    pragma Inline (fl_tree_item_next);

    function fl_tree_item_prev
           (TI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_prev, "fl_tree_item_prev");
    pragma Inline (fl_tree_item_prev);




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Is_Null
           (This : in Tree_Item)
        return Boolean is
    begin
        return This.Void_Ptr = Null_Pointer;
    end Is_Null;


    function Cast
           (Addr : in System.Address)
        return Tree_Item is
    begin
        return (Void_Ptr => Storage.To_Integer (Addr));
    end Cast;


    function Address_Of
           (This : in Tree_Item)
        return System.Address is
    begin
        return Storage.To_Address (This.Void_Ptr);
    end Address_Of;




    --  Label  --

    function Get_Label
           (This : in Tree_Item)
        return String
    is
        Ptr : constant Interfaces.C.Strings.chars_ptr := fl_tree_item_get_label (This.Void_Ptr);
    begin
        if Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Ptr);
        end if;
    end Get_Label;


    procedure Set_Label
           (This : in Tree_Item;
            Text : in String) is
    begin
        fl_tree_item_set_label (This.Void_Ptr, Interfaces.C.To_C (Text));
    end Set_Label;




    --  State  --

    function Is_Open
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_is_open (This.Void_Ptr) /= 0;
    end Is_Open;


    function Is_Selected
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_is_selected (This.Void_Ptr) /= 0;
    end Is_Selected;


    function Is_Active
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_is_active (This.Void_Ptr) /= 0;
    end Is_Active;


    function Is_Visible
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_is_visible (This.Void_Ptr) /= 0;
    end Is_Visible;


    function Is_Root
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_is_root (This.Void_Ptr) /= 0;
    end Is_Root;




    --  Hierarchy  --

    function Has_Children
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_children (This.Void_Ptr) > 0;
    end Has_Children;


    function Number_Of_Children
           (This : in Tree_Item)
        return Natural is
    begin
        return Natural (fl_tree_item_children (This.Void_Ptr));
    end Number_Of_Children;


    function Child
           (This  : in Tree_Item;
            Place : in Positive)
        return Tree_Item is
    begin
        return (Void_Ptr => fl_tree_item_child (This.Void_Ptr, Interfaces.C.int (Place - 1)));
    end Child;


    function Parent
           (This : in Tree_Item)
        return Tree_Item is
    begin
        return (Void_Ptr => fl_tree_item_parent (This.Void_Ptr));
    end Parent;


    function Depth
           (This : in Tree_Item)
        return Natural is
    begin
        return Natural (fl_tree_item_depth (This.Void_Ptr));
    end Depth;


    function Next
           (This : in Tree_Item)
        return Tree_Item is
    begin
        return (Void_Ptr => fl_tree_item_next (This.Void_Ptr));
    end Next;


    function Prev
           (This : in Tree_Item)
        return Tree_Item is
    begin
        return (Void_Ptr => fl_tree_item_prev (This.Void_Ptr));
    end Prev;


end FLTK.Tree_Items;


