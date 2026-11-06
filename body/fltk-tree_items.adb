

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


with

    FLTK.Tree_Icons,
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

    function fl_tree_item_get_labelfont
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_get_labelfont, "fl_tree_item_get_labelfont");
    pragma Inline (fl_tree_item_get_labelfont);

    procedure fl_tree_item_set_labelfont
           (TI : in Storage.Integer_Address;
            F  : in Interfaces.C.int);
    pragma Import (C, fl_tree_item_set_labelfont, "fl_tree_item_set_labelfont");
    pragma Inline (fl_tree_item_set_labelfont);

    function fl_tree_item_get_labelsize
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_get_labelsize, "fl_tree_item_get_labelsize");
    pragma Inline (fl_tree_item_get_labelsize);

    procedure fl_tree_item_set_labelsize
           (TI : in Storage.Integer_Address;
            S  : in Interfaces.C.int);
    pragma Import (C, fl_tree_item_set_labelsize, "fl_tree_item_set_labelsize");
    pragma Inline (fl_tree_item_set_labelsize);

    function fl_tree_item_get_labelfgcolor
           (TI : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_tree_item_get_labelfgcolor, "fl_tree_item_get_labelfgcolor");
    pragma Inline (fl_tree_item_get_labelfgcolor);

    procedure fl_tree_item_set_labelfgcolor
           (TI : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_tree_item_set_labelfgcolor, "fl_tree_item_set_labelfgcolor");
    pragma Inline (fl_tree_item_set_labelfgcolor);

    function fl_tree_item_get_labelbgcolor
           (TI : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_tree_item_get_labelbgcolor, "fl_tree_item_get_labelbgcolor");
    pragma Inline (fl_tree_item_get_labelbgcolor);

    procedure fl_tree_item_set_labelbgcolor
           (TI : in Storage.Integer_Address;
            C  : in Interfaces.C.unsigned);
    pragma Import (C, fl_tree_item_set_labelbgcolor, "fl_tree_item_set_labelbgcolor");
    pragma Inline (fl_tree_item_set_labelbgcolor);

    function fl_tree_item_label_x
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_label_x, "fl_tree_item_label_x");
    pragma Inline (fl_tree_item_label_x);

    function fl_tree_item_label_y
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_label_y, "fl_tree_item_label_y");
    pragma Inline (fl_tree_item_label_y);

    function fl_tree_item_label_w
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_label_w, "fl_tree_item_label_w");
    pragma Inline (fl_tree_item_label_w);

    function fl_tree_item_label_h
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_label_h, "fl_tree_item_label_h");
    pragma Inline (fl_tree_item_label_h);




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

    procedure fl_tree_item_activate
           (TI : in Storage.Integer_Address;
            V  : in Interfaces.C.int);
    pragma Import (C, fl_tree_item_activate, "fl_tree_item_activate");
    pragma Inline (fl_tree_item_activate);

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

    procedure fl_tree_item_swap_children2
           (TI   : in Storage.Integer_Address;
            A, B : in Interfaces.C.int);
    pragma Import (C, fl_tree_item_swap_children2, "fl_tree_item_swap_children2");
    pragma Inline (fl_tree_item_swap_children2);

    function fl_tree_item_replace
           (TI : in Storage.Integer_Address;
            N  : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_replace, "fl_tree_item_replace");
    pragma Inline (fl_tree_item_replace);




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

    function fl_tree_item_tree
           (TI : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tree_item_tree, "fl_tree_item_tree");
    pragma Inline (fl_tree_item_tree);

    function fl_tree_item_in_tree
           (TI : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_in_tree, "fl_tree_item_in_tree");
    pragma Inline (fl_tree_item_in_tree);




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


    function Get_Label_Font
           (This : in Tree_Item)
        return Font_Kind is
    begin
        return Font_Kind (fl_tree_item_get_labelfont (This.Void_Ptr));
    end Get_Label_Font;


    procedure Set_Label_Font
           (This : in Tree_Item;
            Font : in Font_Kind) is
    begin
        fl_tree_item_set_labelfont (This.Void_Ptr, To_C (Font));
    end Set_Label_Font;


    function Get_Label_Size
           (This : in Tree_Item)
        return Font_Size is
    begin
        return Font_Size (fl_tree_item_get_labelsize (This.Void_Ptr));
    end Get_Label_Size;


    procedure Set_Label_Size
           (This : in Tree_Item;
            Size : in Font_Size) is
    begin
        fl_tree_item_set_labelsize (This.Void_Ptr, Interfaces.C.int (Size));
    end Set_Label_Size;

    function Get_Label_FG_Color
           (This : in Tree_Item)
        return Color is
    begin
        return Color (fl_tree_item_get_labelfgcolor (This.Void_Ptr));
    end Get_Label_FG_Color;


    procedure Set_Label_FG_Color
           (This : in Tree_Item;
            Hue  : in Color) is
    begin
        fl_tree_item_set_labelfgcolor (This.Void_Ptr, Interfaces.C.unsigned (Hue));
    end Set_Label_FG_Color;


    function Get_Label_BG_Color
           (This : in Tree_Item)
        return Color is
    begin
        return Color (fl_tree_item_get_labelbgcolor (This.Void_Ptr));
    end Get_Label_BG_Color;


    procedure Set_Label_BG_Color
           (This : in Tree_Item;
            Hue  : in Color) is
    begin
        fl_tree_item_set_labelbgcolor (This.Void_Ptr, Interfaces.C.unsigned (Hue));
    end Set_Label_BG_Color;


    function Label_X
           (This : in Tree_Item)
        return Integer is
    begin
        return Integer (fl_tree_item_label_x (This.Void_Ptr));
    end Label_X;


    function Label_Y
           (This : in Tree_Item)
        return Integer is
    begin
        return Integer (fl_tree_item_label_y (This.Void_Ptr));
    end Label_Y;


    function Label_W
           (This : in Tree_Item)
        return Integer is
    begin
        return Integer (fl_tree_item_label_w (This.Void_Ptr));
    end Label_W;


    function Label_H
           (This : in Tree_Item)
        return Integer is
    begin
        return Integer (fl_tree_item_label_h (This.Void_Ptr));
    end Label_H;




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


    procedure Activate
           (This : in Tree_Item) is
    begin
        fl_tree_item_activate (This.Void_Ptr, 1);
    end Activate;


    procedure Deactivate
           (This : in Tree_Item) is
    begin
        fl_tree_item_activate (This.Void_Ptr, 0);
    end Deactivate;


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


    procedure Swap_Children
           (This          : in Tree_Item;
            First, Second : in Positive) is
    begin
        if First > Number_Of_Children (This) or Second > Number_Of_Children (This) then
            raise Constraint_Error;
        end if;
        fl_tree_item_swap_children2
           (This.Void_Ptr,
            Interfaces.C.int (First) - 1,
            Interfaces.C.int (Second) - 1);
    end Swap_Children;


    function Replace
           (This     : in Tree_Item;
            New_Item : in Tree_Item)
        return Tree_Item
    is
        Tree   : constant Storage.Integer_Address := fl_tree_item_tree (This.Void_Ptr);
        Result : constant Tree_Item :=
           (Void_Ptr => fl_tree_item_replace (This.Void_Ptr, New_Item.Void_Ptr));
    begin
        if Tree /= Null_Pointer then
            FLTK.Tree_Icons.Drop_Unused (Tree);
        end if;
        return Result;
    end Replace;




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

    --  pofltk 78: FLTK keeps the image's pointer, so it is given a copy,
    --  held for the item's tree (FLTK.Tree_Icons).
    procedure Set_Icon
           (This   : in Tree_Item;
            Pic    : in FLTK.Images.Image'Class;
            Deicon : in Boolean)
    is
        Tree : constant Storage.Integer_Address := fl_tree_item_tree (This.Void_Ptr);
        Ptr  : Storage.Integer_Address := Null_Pointer;
    begin
        if Tree = Null_Pointer then
            raise Program_Error with "a tree item that belongs to no tree";
        end if;
        if Wrapper (Pic).Void_Ptr /= Null_Pointer then
            Ptr := FLTK.Tree_Icons.Hold
               (Tree, Pic, Kept => fl_tree_item_in_tree (This.Void_Ptr) = 0);
        end if;
        if Deicon then
            fl_tree_item_set_userdeicon (This.Void_Ptr, Ptr);
        else
            fl_tree_item_set_usericon (This.Void_Ptr, Ptr);
        end if;
        FLTK.Tree_Icons.Drop_Unused (Tree);
    end Set_Icon;


    procedure Clear_Icon
           (This   : in Tree_Item;
            Deicon : in Boolean)
    is
        Tree : constant Storage.Integer_Address := fl_tree_item_tree (This.Void_Ptr);
    begin
        if Deicon then
            fl_tree_item_set_userdeicon (This.Void_Ptr, Null_Pointer);
        else
            fl_tree_item_set_usericon (This.Void_Ptr, Null_Pointer);
        end if;
        if Tree /= Null_Pointer then
            FLTK.Tree_Icons.Drop_Unused (Tree);
        end if;
    end Clear_Icon;


    procedure Set_User_Icon
           (This : in Tree_Item;
            Pic  : in FLTK.Images.Image'Class) is
    begin
        Set_Icon (This, Pic, Deicon => False);
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
        Clear_Icon (This, Deicon => False);
    end Clear_User_Icon;


    function Get_User_Icon
           (This : in Tree_Item)
        return access FLTK.Images.Image'Class is
    begin
        return FLTK.Tree_Icons.Find
           (fl_tree_item_tree (This.Void_Ptr), fl_tree_item_get_usericon (This.Void_Ptr));
    end Get_User_Icon;


    procedure Set_User_Deicon
           (This : in Tree_Item;
            Pic  : in FLTK.Images.Image'Class) is
    begin
        Set_Icon (This, Pic, Deicon => True);
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
        Clear_Icon (This, Deicon => True);
    end Clear_User_Deicon;


    function Get_User_Deicon
           (This : in Tree_Item)
        return access FLTK.Images.Image'Class is
    begin
        return FLTK.Tree_Icons.Find
           (fl_tree_item_tree (This.Void_Ptr), fl_tree_item_get_userdeicon (This.Void_Ptr));
    end Get_User_Deicon;


end FLTK.Tree_Items;


