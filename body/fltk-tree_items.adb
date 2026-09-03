

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


with

    Ada.Containers.Ordered_Maps,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Tree_Items is


    --  Fl_Image has no spare pointer of its own to stash an Ada
    --  back-reference in (unlike Fl_Widget's user_data(), which
    --  Get_Widget relies on), so Get_User_Icon/Get_User_Deicon look
    --  the Ada object up here instead, keyed by the *item's* address.
    --  Stale if a Tree_Item's underlying pointer is later reused for
    --  an unrelated item (the same caveat FLTK.Registry's Label_Store
    --  already carries for labels).

    type Image_Access is access all FLTK.Images.Image'Class;

    package Icon_Maps is new Ada.Containers.Ordered_Maps
       (Key_Type     => Storage.Integer_Address,
        Element_Type => Image_Access);

    User_Icon_Store   : Icon_Maps.Map;
    User_Deicon_Store : Icon_Maps.Map;


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




    function fl_tree_item_move_above
           (TI   : in Storage.Integer_Address;
            Item : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_move_above, "fl_tree_item_move_above");
    pragma Inline (fl_tree_item_move_above);

    function fl_tree_item_move_below
           (TI   : in Storage.Integer_Address;
            Item : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_move_below, "fl_tree_item_move_below");
    pragma Inline (fl_tree_item_move_below);

    function fl_tree_item_move_into
           (TI   : in Storage.Integer_Address;
            Item : in Storage.Integer_Address;
            Pos  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_move_into, "fl_tree_item_move_into");
    pragma Inline (fl_tree_item_move_into);

    function fl_tree_item_deparent
           (TI    : in Storage.Integer_Address;
            Index : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_deparent, "fl_tree_item_deparent");
    pragma Inline (fl_tree_item_deparent);

    function fl_tree_item_reparent
           (TI       : in Storage.Integer_Address;
            Newchild : in Storage.Integer_Address;
            Index    : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_reparent, "fl_tree_item_reparent");
    pragma Inline (fl_tree_item_reparent);

    function fl_tree_item_swap_children
           (TI   : in Storage.Integer_Address;
            A, B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_swap_children, "fl_tree_item_swap_children");
    pragma Inline (fl_tree_item_swap_children);




    procedure fl_tree_item_set_widget
           (TI : in Storage.Integer_Address;
            W  : in Storage.Integer_Address);
    pragma Import (C, fl_tree_item_set_widget, "fl_tree_item_set_widget");
    pragma Inline (fl_tree_item_set_widget);

    function fl_tree_item_get_widget
           (TI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_get_widget, "fl_tree_item_get_widget");
    pragma Inline (fl_tree_item_get_widget);




    procedure fl_tree_item_set_usericon
           (TI  : in Storage.Integer_Address;
            Img : in Storage.Integer_Address);
    pragma Import (C, fl_tree_item_set_usericon, "fl_tree_item_set_usericon");
    pragma Inline (fl_tree_item_set_usericon);

    function fl_tree_item_get_usericon
           (TI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_get_usericon, "fl_tree_item_get_usericon");
    pragma Inline (fl_tree_item_get_usericon);

    procedure fl_tree_item_set_userdeicon
           (TI  : in Storage.Integer_Address;
            Img : in Storage.Integer_Address);
    pragma Import (C, fl_tree_item_set_userdeicon, "fl_tree_item_set_userdeicon");
    pragma Inline (fl_tree_item_set_userdeicon);

    function fl_tree_item_get_userdeicon
           (TI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_get_userdeicon, "fl_tree_item_get_userdeicon");
    pragma Inline (fl_tree_item_get_userdeicon);




    -----------------------
    --  API Subprograms  --
    -----------------------

    function "+"
           (Left, Right : in Item_Draw_Mode)
        return Item_Draw_Mode is
    begin
        return
           (Label_And_Widget   => Left.Label_And_Widget or Right.Label_And_Widget,
            Height_From_Widget => Left.Height_From_Widget or Right.Height_From_Widget);
    end "+";


    function "-"
           (Left, Right : in Item_Draw_Mode)
        return Item_Draw_Mode is
    begin
        return
           (Label_And_Widget   => Left.Label_And_Widget and not Right.Label_And_Widget,
            Height_From_Widget => Left.Height_From_Widget and not Right.Height_From_Widget);
    end "-";




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




    --  Restructuring  --

    function Move_Above
           (This   : in Tree_Item;
            Target : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_move_above (This.Void_Ptr, Target.Void_Ptr) = 0;
    end Move_Above;


    function Move_Below
           (This   : in Tree_Item;
            Target : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_move_below (This.Void_Ptr, Target.Void_Ptr) = 0;
    end Move_Below;


    function Move_Into
           (This   : in Tree_Item;
            Target : in Tree_Item;
            Place  : in Natural := 0)
        return Boolean is
    begin
        return
            fl_tree_item_move_into
               (This.Void_Ptr, Target.Void_Ptr, Interfaces.C.int (Place)) = 0;
    end Move_Into;


    function Deparent
           (This  : in Tree_Item;
            Place : in Positive)
        return Tree_Item is
    begin
        return
           (Void_Ptr =>
                fl_tree_item_deparent (This.Void_Ptr, Interfaces.C.int (Place - 1)));
    end Deparent;


    function Reparent
           (This       : in Tree_Item;
            Child_Item : in Tree_Item;
            Place      : in Natural)
        return Boolean is
    begin
        return
            fl_tree_item_reparent
               (This.Void_Ptr, Child_Item.Void_Ptr, Interfaces.C.int (Place)) = 0;
    end Reparent;


    function Swap_Children
           (This          : in Tree_Item;
            First, Second : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_swap_children (This.Void_Ptr, First.Void_Ptr, Second.Void_Ptr) = 0;
    end Swap_Children;




    --  Embedded Widget  --

    procedure Set_Widget
           (This : in Tree_Item;
            W    : in out FLTK.Widgets.Widget'Class) is
    begin
        fl_tree_item_set_widget
           (This.Void_Ptr,
            Storage.To_Integer (FLTK.Widgets.Address_Of (W)));
    end Set_Widget;


    function Has_Widget
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_get_widget (This.Void_Ptr) /= Null_Pointer;
    end Has_Widget;


    function Get_Widget
           (This : in Tree_Item)
        return access FLTK.Widgets.Widget'Class
    is
        Raw : constant Storage.Integer_Address := fl_tree_item_get_widget (This.Void_Ptr);
    begin
        if Raw = Null_Pointer then
            return null;
        else
            return FLTK.Widgets.Widget_At (Storage.To_Address (Raw));
        end if;
    end Get_Widget;




    --  Icons  --

    procedure Set_User_Icon
           (This : in Tree_Item;
            Pic  : in out FLTK.Images.Image'Class) is
    begin
        User_Icon_Store.Include (This.Void_Ptr, Pic'Unchecked_Access);
        fl_tree_item_set_usericon
           (This.Void_Ptr,
            Storage.To_Integer (FLTK.Images.Address_Of (Pic)));
    end Set_User_Icon;


    function Has_User_Icon
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_get_usericon (This.Void_Ptr) /= Null_Pointer;
    end Has_User_Icon;


    procedure Clear_User_Icon
           (This : in Tree_Item) is
    begin
        User_Icon_Store.Exclude (This.Void_Ptr);
        fl_tree_item_set_usericon (This.Void_Ptr, Null_Pointer);
    end Clear_User_Icon;


    function Get_User_Icon
           (This : in Tree_Item)
        return access FLTK.Images.Image'Class
    is
        Place : constant Icon_Maps.Cursor := User_Icon_Store.Find (This.Void_Ptr);
    begin
        if Icon_Maps.Has_Element (Place) then
            return Icon_Maps.Element (Place);
        else
            return null;
        end if;
    end Get_User_Icon;


    procedure Set_User_Deicon
           (This : in Tree_Item;
            Pic  : in out FLTK.Images.Image'Class) is
    begin
        User_Deicon_Store.Include (This.Void_Ptr, Pic'Unchecked_Access);
        fl_tree_item_set_userdeicon
           (This.Void_Ptr,
            Storage.To_Integer (FLTK.Images.Address_Of (Pic)));
    end Set_User_Deicon;


    function Has_User_Deicon
           (This : in Tree_Item)
        return Boolean is
    begin
        return fl_tree_item_get_userdeicon (This.Void_Ptr) /= Null_Pointer;
    end Has_User_Deicon;


    procedure Clear_User_Deicon
           (This : in Tree_Item) is
    begin
        User_Deicon_Store.Exclude (This.Void_Ptr);
        fl_tree_item_set_userdeicon (This.Void_Ptr, Null_Pointer);
    end Clear_User_Deicon;


    function Get_User_Deicon
           (This : in Tree_Item)
        return access FLTK.Images.Image'Class
    is
        Place : constant Icon_Maps.Cursor := User_Deicon_Store.Find (This.Void_Ptr);
    begin
        if Icon_Maps.Has_Element (Place) then
            return Icon_Maps.Element (Place);
        else
            return null;
        end if;
    end Get_User_Deicon;


end FLTK.Tree_Items;


