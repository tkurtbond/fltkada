

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


with

    FLTK.Images,
    FLTK.Widgets,
    System;


package FLTK.Tree_Items is


    --  Fl_Tree_Item objects are always owned by the Fl_Tree (or parent
    --  item) they belong to, so unlike Menu_Item this is a plain,
    --  freely-copyable handle rather than a Wrapper: there is nothing
    --  for it to allocate or finalize on its own. Values of this type
    --  are only ever obtained from a Tree, never constructed directly.


    type Tree_Item is private;

    No_Tree_Item : constant Tree_Item;

    function Is_Null
           (This : in Tree_Item)
        return Boolean;

    type Tree_Item_Array is array (Positive range <>) of Tree_Item;

    --  Escape hatches for other FLTK child packages (namely
    --  FLTK.Widgets.Groups.Trees) that receive or hand off raw
    --  Fl_Tree_Item pointers across the C boundary. Application code
    --  should never need these.
    function Cast
           (Addr : in System.Address)
        return Tree_Item;

    function Address_Of
           (This : in Tree_Item)
        return System.Address;




    --  Preference kinds shared with FLTK.Widgets.Groups.Trees, standing
    --  in for what would otherwise be a standalone Fl_Tree_Prefs binding
    --  -- see that package for why.

    type Sort_Kind is
       (No_Sort,
        Ascending,
        Descending);

    type Connector_Kind is
       (No_Connector,
        Dotted_Connector,
        Solid_Connector);

    type Selection_Kind is
       (No_Selection,
        Single_Selection,
        Multi_Selection,
        Single_Draggable_Selection);

    --  Controls how an item's label and Set_Widget-assigned widget (if
    --  any) are drawn together. With neither flag set (the default),
    --  an assigned widget replaces the label entirely, and the item's
    --  own height controls the widget's height.
    type Item_Draw_Mode is record
        Label_And_Widget   : Boolean := False;
        Height_From_Widget : Boolean := False;
    end record;

    function "+" (Left, Right : in Item_Draw_Mode) return Item_Draw_Mode;
    function "-" (Left, Right : in Item_Draw_Mode) return Item_Draw_Mode;

    Draw_Default            : constant Item_Draw_Mode;
    Draw_Label_And_Widget   : constant Item_Draw_Mode;
    Draw_Height_From_Widget : constant Item_Draw_Mode;




    --  Label  --

    function Get_Label
           (This : in Tree_Item)
        return String;

    procedure Set_Label
           (This : in Tree_Item;
            Text : in String);

    function Get_Label_Font
           (This : in Tree_Item)
        return Font_Kind;

    procedure Set_Label_Font
           (This : in Tree_Item;
            Font : in Font_Kind);

    function Get_Label_Size
           (This : in Tree_Item)
        return Font_Size;

    procedure Set_Label_Size
           (This : in Tree_Item;
            Size : in Font_Size);

    --  The area the item's label is drawn in, as of the last time the
    --  tree was drawn.  Mostly of use when drawing a custom item; see
    --  FLTK.Tree_Items.Custom.
    function Label_X
           (This : in Tree_Item)
        return Integer;

    function Label_Y
           (This : in Tree_Item)
        return Integer;

    function Label_W
           (This : in Tree_Item)
        return Integer;

    function Label_H
           (This : in Tree_Item)
        return Integer;




    --  State  --

    function Is_Open
           (This : in Tree_Item)
        return Boolean;

    function Is_Selected
           (This : in Tree_Item)
        return Boolean;

    function Is_Active
           (This : in Tree_Item)
        return Boolean;

    function Is_Visible
           (This : in Tree_Item)
        return Boolean;

    function Is_Root
           (This : in Tree_Item)
        return Boolean;




    --  Hierarchy  --

    function Has_Children
           (This : in Tree_Item)
        return Boolean;

    function Number_Of_Children
           (This : in Tree_Item)
        return Natural;

    function Child
           (This  : in Tree_Item;
            Place : in Positive)
        return Tree_Item;

    function Parent
           (This : in Tree_Item)
        return Tree_Item;

    function Depth
           (This : in Tree_Item)
        return Natural;

    --  Walks the entire tree depth-first, not just This's siblings.
    --  Returns No_Tree_Item once there is nothing left to walk to.
    function Next
           (This : in Tree_Item)
        return Tree_Item;

    function Prev
           (This : in Tree_Item)
        return Tree_Item;




    --  Restructuring  --

    --  All return False (making no change) on failure -- eg. Move_Into
    --  would create a cycle, or Reparent/Swap_Children's arguments
    --  aren't actually children of This.

    function Move_Above
           (This   : in Tree_Item;
            Target : in Tree_Item)
        return Boolean;

    function Move_Below
           (This   : in Tree_Item;
            Target : in Tree_Item)
        return Boolean;

    --  Place is the child index (0 = first) to move This to within
    --  Target's children.
    function Move_Into
           (This   : in Tree_Item;
            Target : in Tree_Item;
            Place  : in Natural := 0)
        return Boolean;

    --  Detaches the child at Place from This without destroying it,
    --  returning the now-parentless item (typically to Reparent
    --  elsewhere). Returns No_Tree_Item if Place is out of range.
    function Deparent
           (This  : in Tree_Item;
            Place : in Positive)
        return Tree_Item;

    --  Adopts Child_Item (typically just Deparent-ed from somewhere
    --  else) as This's child at index Place.
    function Reparent
           (This       : in Tree_Item;
            Child_Item : in Tree_Item;
            Place      : in Natural)
        return Boolean;

    --  Swaps two of This's immediate children.
    function Swap_Children
           (This          : in Tree_Item;
            First, Second : in Tree_Item)
        return Boolean;

    --  Swaps two of This's immediate children by place (1 = first).
    --  Raises Constraint_Error if either place is past the last child.
    procedure Swap_Children
           (This          : in Tree_Item;
            First, Second : in Positive);

    --  Puts New_Item in This's place in the tree, destroying This, and
    --  returns New_Item, or No_Tree_Item on failure.  New_Item is
    --  typically a FLTK.Tree_Items.Custom item, which the tree then owns.
    function Replace
           (This     : in Tree_Item;
            New_Item : in Tree_Item)
        return Tree_Item;




    --  Embedded Widget  --

    --  Replaces the item's label area with an arbitrary FLTK widget
    --  (eg. a table, an input field, or any other bound widget type).
    --  The tree takes over the widget's x/y position and, by default,
    --  its height; see FLTK.Widgets.Groups.Trees.Set_Item_Draw_Mode to
    --  have the widget's own height control the item's height instead.
    --  The widget's lifetime is still the caller's responsibility --
    --  the tree does not take ownership of it, so it must outlive the
    --  item (or be detached with Set_Widget again before it doesn't).
    procedure Set_Widget
           (This : in Tree_Item;
            W    : in out FLTK.Widgets.Widget'Class);

    function Has_Widget
           (This : in Tree_Item)
        return Boolean;

    --  Returns null if no widget is assigned, or if the assigned
    --  widget has no Ada twin (eg. it was assigned from outside this
    --  binding).
    function Get_Widget
           (This : in Tree_Item)
        return access FLTK.Widgets.Widget'Class;




    --  Icons  --

    --  A per-item icon shown in place of the tree's default one (see
    --  FLTK.Widgets.Groups.Trees for the tree-wide default icons). As
    --  with Set_Widget, the image's lifetime remains the caller's
    --  responsibility.
    procedure Set_User_Icon
           (This : in Tree_Item;
            Pic  : in out FLTK.Images.Image'Class);

    function Has_User_Icon
           (This : in Tree_Item)
        return Boolean;

    procedure Clear_User_Icon
           (This : in Tree_Item);

    --  Returns null if no icon is assigned, or if the assigned icon
    --  has no Ada twin. Unlike Get_Widget, this can't be recovered via
    --  a spare pointer FLTK already tracks (Fl_Image has none), so it
    --  relies on a small internal table populated by Set_User_Icon;
    --  looking up an icon assigned from outside this binding, or one
    --  whose Tree_Item slot was since reused by an unrelated item,
    --  will also return null.
    function Get_User_Icon
           (This : in Tree_Item)
        return access FLTK.Images.Image'Class;

    --  The icon shown when the item is Is_Active = False. Same caveats
    --  as the user icon above.
    procedure Set_User_Deicon
           (This : in Tree_Item;
            Pic  : in out FLTK.Images.Image'Class);

    function Has_User_Deicon
           (This : in Tree_Item)
        return Boolean;

    procedure Clear_User_Deicon
           (This : in Tree_Item);

    function Get_User_Deicon
           (This : in Tree_Item)
        return access FLTK.Images.Image'Class;


private


    type Tree_Item is record
        Void_Ptr : Storage.Integer_Address := Null_Pointer;
    end record;

    No_Tree_Item : constant Tree_Item := (Void_Ptr => Null_Pointer);

    Draw_Default            : constant Item_Draw_Mode := (others => False);
    Draw_Label_And_Widget   : constant Item_Draw_Mode :=
        (Label_And_Widget => True, others => False);
    Draw_Height_From_Widget : constant Item_Draw_Mode :=
        (Height_From_Widget => True, others => False);

    pragma Inline ("+");
    pragma Inline ("-");

    pragma Inline (Is_Null);
    pragma Inline (Cast);
    pragma Inline (Address_Of);

    pragma Inline (Get_Label_Font);
    pragma Inline (Set_Label_Font);
    pragma Inline (Get_Label_Size);
    pragma Inline (Set_Label_Size);
    pragma Inline (Label_X);
    pragma Inline (Label_Y);
    pragma Inline (Label_W);
    pragma Inline (Label_H);

    pragma Inline (Is_Open);
    pragma Inline (Is_Selected);
    pragma Inline (Is_Active);
    pragma Inline (Is_Visible);
    pragma Inline (Is_Root);

    pragma Inline (Has_Children);
    pragma Inline (Number_Of_Children);
    pragma Inline (Depth);

    pragma Inline (Move_Above);
    pragma Inline (Move_Below);
    pragma Inline (Move_Into);
    pragma Inline (Deparent);
    pragma Inline (Reparent);
    pragma Inline (Swap_Children);
    pragma Inline (Replace);

    pragma Inline (Set_Widget);
    pragma Inline (Has_Widget);
    pragma Inline (Get_Widget);

    pragma Inline (Set_User_Icon);
    pragma Inline (Has_User_Icon);
    pragma Inline (Clear_User_Icon);
    pragma Inline (Get_User_Icon);
    pragma Inline (Set_User_Deicon);
    pragma Inline (Has_User_Deicon);
    pragma Inline (Clear_User_Deicon);
    pragma Inline (Get_User_Deicon);


end FLTK.Tree_Items;


