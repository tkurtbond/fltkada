

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


with

    FLTK.Environment,
    FLTK.Images,
    FLTK.Tree_Items;


package FLTK.Widgets.Groups.Trees is


    type Tree is new Group with private;

    type Tree_Reference (Data : not null access Tree'Class) is limited null record
        with Implicit_Dereference => Data;

    --  Why the tree's callback was called; see Callback_Reason.
    type Reason_Kind is
       (No_Reason, Selected, Deselected, Reselected, Opened, Closed, Dragged);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Tree;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Tree;

    end Forge;




    --  Item Creation and Removal  --

    --  Every call here that takes an item, except Add, Item_Pathname and
    --  those that say what a null item means, raises Constraint_Error if
    --  it is null (No_Tree_Item), where FLTK would crash (bug 127).

    --  Path components are separated by '/', eg. "Flintstones/Fred" --
    --  any parent items named along the way that don't already exist
    --  are created automatically.
    function Add
           (This : in out Tree;
            Path : in     String)
        return FLTK.Tree_Items.Tree_Item;

    --  As above, but the last path component is Item itself, typically a
    --  FLTK.Tree_Items.Custom item, rather than a new item.  Item's label
    --  is left as it is.  The tree takes ownership of Item.
    function Add
           (This : in out Tree;
            Path : in     String;
            Item : in     FLTK.Tree_Items.Tree_Item)
        return FLTK.Tree_Items.Tree_Item;

    --  Appends a new child item named Name to Parent; Name is a label,
    --  not a path (Fl_Tree::add (Fl_Tree_Item *, const char *)).
    function Add
           (This   : in out Tree;
            Parent : in     FLTK.Tree_Items.Tree_Item;
            Name   : in     String)
        return FLTK.Tree_Items.Tree_Item;

    --  Adds an item for each entry of From and its groups, as Fl_Tree::load
    --  does: a group is an item, and an entry is an item labelled
    --  "name = value".  Raises FLTK.Environment.Preference_Error if From's
    --  group has been deleted.
    procedure Load
           (This : in out Tree;
            From : in     FLTK.Environment.Pref_Group'Class);

    --  Adds a new child item named Name to Under at child position
    --  Place (0 = first), rather than appending it like Add does.
    function Insert
           (This  : in out Tree;
            Under : in     FLTK.Tree_Items.Tree_Item;
            Name  : in     String;
            Place : in     Natural)
        return FLTK.Tree_Items.Tree_Item;

    --  Adds a new item named Name as Above's previous sibling.
    function Insert_Above
           (This  : in out Tree;
            Above : in     FLTK.Tree_Items.Tree_Item;
            Name  : in     String)
        return FLTK.Tree_Items.Tree_Item;

    procedure Remove
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    --  Deletes the root as well, so Root is null until Add makes a new one
    --  (Fl_Tree.cxx:934-940, pofltk 43).
    procedure Clear
           (This : in out Tree);

    procedure Clear_Children
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    function Find
           (This : in Tree;
            Path : in String)
        return FLTK.Tree_Items.Tree_Item;




    --  Root  --

    --  Is null (Tree_Items.Is_Null) after Clear, until Add makes a new root.
    function Root
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item;

    procedure Set_Root_Label
           (This : in out Tree;
            Text : in     String);




    --  Callback Information  --

    --  Inside the tree's callback, the item that caused the callback
    --  and why. The item can be null, so check with Tree_Items.Is_Null.
    --  It is null once the item has been removed, in the callback or not.
    function Callback_Item
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item;

    function Callback_Reason
           (This : in Tree)
        return Reason_Kind;

    --  The '/'-separated path of Item, as Find takes it, with any '/' or
    --  '\' in item labels escaped by a '\'. A null Item means the root.
    function Item_Pathname
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return String;




    --  Walking the Tree  --

    function First
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item;

    function Last
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item;




    --  Open and Close  --

    --  Each of these calls the callback, with Reason Opened, Closed,
    --  Selected or Deselected, if it changes the item and Do_Callback is
    --  True.

    procedure Open
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item;
            Do_Callback : in     Boolean := True);

    procedure Close
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item;
            Do_Callback : in     Boolean := True);

    procedure Open_Toggle
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item;
            Do_Callback : in     Boolean := True);

    --  The item at Path, as Find gives it.  These path forms raise
    --  Constraint_Error if there is no item there.

    procedure Open
           (This        : in out Tree;
            Path        : in     String;
            Do_Callback : in     Boolean := True);

    procedure Close
           (This        : in out Tree;
            Path        : in     String;
            Do_Callback : in     Boolean := True);




    --  Selection  --

    procedure Select_Item
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item;
            Do_Callback : in     Boolean := True);

    procedure Deselect
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item;
            Do_Callback : in     Boolean := True);

    procedure Select_Item
           (This        : in out Tree;
            Path        : in     String;
            Do_Callback : in     Boolean := True);

    procedure Deselect
           (This        : in out Tree;
            Path        : in     String;
            Do_Callback : in     Boolean := True);

    --  Selects or deselects Item and all its descendants, or with a null
    --  Item the whole tree, calling the callback for each item changed if
    --  Do_Callback is True.  Returns how many items changed state.
    function Select_All
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item := FLTK.Tree_Items.No_Tree_Item;
            Do_Callback : in     Boolean := True)
        return Natural;

    function Deselect_All
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item := FLTK.Tree_Items.No_Tree_Item;
            Do_Callback : in     Boolean := True)
        return Natural;

    --  Selects Item if it isn't selected, deselects it if it is, and calls
    --  the callback with Reason Selected or Deselected if Do_Callback is
    --  True.
    procedure Select_Toggle
           (This        : in out Tree;
            Item        : in     FLTK.Tree_Items.Tree_Item;
            Do_Callback : in     Boolean := True);

    --  The first or last selected item in the whole tree, open or not,
    --  or null if none is selected.
    function First_Selected
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item;

    function Last_Selected
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item;

    --  The next selected item after Item, or before it, or null if there
    --  is none.  A null Item starts from the first or the last item, so
    --  Next_Selected (T, No_Tree_Item) is First_Selected (T).
    function Next_Selected
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return FLTK.Tree_Items.Tree_Item;

    function Prev_Selected
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return FLTK.Tree_Items.Tree_Item;

    function Selected_Items
           (This : in Tree)
        return FLTK.Tree_Items.Tree_Item_Array;




    --  Preferences  --

    --  These stand in for a standalone Fl_Tree_Prefs binding -- see
    --  FLTK.Tree_Items for why.

    function Get_Show_Root
           (This : in Tree)
        return Boolean;

    procedure Set_Show_Root
           (This : in out Tree;
            To   : in     Boolean);

    function Get_Show_Collapse
           (This : in Tree)
        return Boolean;

    procedure Set_Show_Collapse
           (This : in out Tree;
            To   : in     Boolean);

    function Get_Select_Mode
           (This : in Tree)
        return FLTK.Tree_Items.Selection_Kind;

    procedure Set_Select_Mode
           (This : in out Tree;
            Mode : in     FLTK.Tree_Items.Selection_Kind);

    function Get_Item_Reselect_Mode
           (This : in Tree)
        return FLTK.Tree_Items.Reselect_Kind;

    procedure Set_Item_Reselect_Mode
           (This : in out Tree;
            Mode : in     FLTK.Tree_Items.Reselect_Kind);

    function Get_Connector_Style
           (This : in Tree)
        return FLTK.Tree_Items.Connector_Kind;

    procedure Set_Connector_Style
           (This  : in out Tree;
            Style : in     FLTK.Tree_Items.Connector_Kind);

    function Get_Sort_Order
           (This : in Tree)
        return FLTK.Tree_Items.Sort_Kind;

    procedure Set_Sort_Order
           (This  : in out Tree;
            Order : in     FLTK.Tree_Items.Sort_Kind);

    --  Fonts, sizes, and colors below apply to new items only; they do
    --  not retroactively change items already in the tree.

    function Get_Item_Label_Font
           (This : in Tree)
        return Font_Kind;

    procedure Set_Item_Label_Font
           (This : in out Tree;
            Kind : in     Font_Kind);

    function Get_Item_Label_Size
           (This : in Tree)
        return Font_Size;

    procedure Set_Item_Label_Size
           (This : in out Tree;
            Size : in     Font_Size);

    function Get_Item_Label_Color
           (This : in Tree)
        return Color;

    procedure Set_Item_Label_Color
           (This : in out Tree;
            Hue  : in     Color);

    --  Tree_Items.Transparent_Background, the default, draws new items'
    --  labels on the tree's background.
    function Get_Item_Label_BG_Color
           (This : in Tree)
        return Color;

    procedure Set_Item_Label_BG_Color
           (This : in out Tree;
            Hue  : in     Color);

    function Get_Margin_Left
           (This : in Tree)
        return Integer;

    procedure Set_Margin_Left
           (This : in out Tree;
            To   : in     Integer);

    --  Space between an item's label and its Tree_Items.Set_Widget
    --  widget, when both are shown together (see Item_Draw_Mode).
    function Get_Widget_Margin_Left
           (This : in Tree)
        return Integer;

    procedure Set_Widget_Margin_Left
           (This : in out Tree;
            To   : in     Integer);

    --  Space above the first item.
    function Get_Margin_Top
           (This : in Tree)
        return Integer;

    procedure Set_Margin_Top
           (This : in out Tree;
            To   : in     Integer);

    --  Space below the last item, when the tree scrolls to its end.
    function Get_Margin_Bottom
           (This : in Tree)
        return Integer;

    procedure Set_Margin_Bottom
           (This : in out Tree;
            To   : in     Integer);

    --  Space below the last child of an open item.
    function Get_Open_Child_Margin_Bottom
           (This : in Tree)
        return Integer;

    procedure Set_Open_Child_Margin_Bottom
           (This : in out Tree;
            To   : in     Integer);

    --  Space left of an item's user icon.
    function Get_User_Icon_Margin_Left
           (This : in Tree)
        return Integer;

    procedure Set_User_Icon_Margin_Left
           (This : in out Tree;
            To   : in     Integer);

    --  Space left of an item's label.
    function Get_Label_Margin_Left
           (This : in Tree)
        return Integer;

    procedure Set_Label_Margin_Left
           (This : in out Tree;
            To   : in     Integer);

    --  Width of the connector lines from an item to its children.
    function Get_Connector_Width
           (This : in Tree)
        return Integer;

    procedure Set_Connector_Width
           (This : in out Tree;
            To   : in     Integer);

    function Get_Line_Spacing
           (This : in Tree)
        return Integer;

    procedure Set_Line_Spacing
           (This : in out Tree;
            To   : in     Integer);

    --  Controls how a Tree_Items.Set_Widget-assigned widget is drawn
    --  relative to its item's label; see FLTK.Tree_Items.Item_Draw_Mode.
    function Get_Item_Draw_Mode
           (This : in Tree)
        return FLTK.Tree_Items.Item_Draw_Mode;

    procedure Set_Item_Draw_Mode
           (This : in out Tree;
            Mode : in     FLTK.Tree_Items.Item_Draw_Mode);

    --  The box drawn behind selected items.
    function Get_Select_Box
           (This : in Tree)
        return Box_Kind;

    procedure Set_Select_Box
           (This : in out Tree;
            Box  : in     Box_Kind);




    --  Icons  --

    --  The tree's own icons: the open icon, shown beside a closed item
    --  with children, in place of FLTK's [+]; the close icon, shown beside
    --  an open one, in place of [-] (Fl_Tree_Item.cxx:1079-1096); and the
    --  user icon, shown beside every item without one of its own
    --  (Tree_Items.Set_User_Icon).
    --  FLTK keeps the image it is given, so the tree gets a copy of Icon,
    --  which it keeps while it shows it (pofltk 78).  FLTK makes and
    --  deletes an inactive copy of it as well, so a Shared_Image is copied
    --  as a plain image, leaving the shared one alone (pofltk 84).  The
    --  Get functions return the tree's copy, or null if there is none.

    function Get_Open_Icon
           (This : in Tree)
        return access FLTK.Images.Image'Class;

    procedure Set_Open_Icon
           (This : in out Tree;
            Icon : in     FLTK.Images.Image'Class);

    procedure Clear_Open_Icon
           (This : in out Tree);

    function Get_Close_Icon
           (This : in Tree)
        return access FLTK.Images.Image'Class;

    procedure Set_Close_Icon
           (This : in out Tree;
            Icon : in     FLTK.Images.Image'Class);

    procedure Clear_Close_Icon
           (This : in out Tree);

    function Get_User_Icon
           (This : in Tree)
        return access FLTK.Images.Image'Class;

    procedure Set_User_Icon
           (This : in out Tree;
            Icon : in     FLTK.Images.Image'Class);

    procedure Clear_User_Icon
           (This : in out Tree);




    --  Scrolling  --

    --  How many pixels of the tree are scrolled off the top, or the left.
    --  A position is clamped between 0 and as far as the tree can scroll,
    --  which is 1 until the tree is first drawn (Fl_Tree.cxx, vposition
    --  and calc_dimensions).
    function Get_V_Position
           (This : in Tree)
        return Integer;

    procedure Set_V_Position
           (This  : in out Tree;
            Value : in     Integer);

    function Get_H_Position
           (This : in Tree)
        return Integer;

    procedure Set_H_Position
           (This  : in out Tree;
            Value : in     Integer);

    --  The width of this tree's scrollbars.  0, the default, means
    --  FLTK.Static's global scrollbar size.
    function Get_Scrollbar_Size
           (This : in Tree)
        return Integer;

    procedure Set_Scrollbar_Size
           (This  : in out Tree;
            Value : in     Integer);

    --  Whether Item is wholly inside the tree's area.  Items get their
    --  positions when the tree is drawn, so this, and the Show_Item calls
    --  below, need a tree that has been drawn (Fl_Tree.cxx:2359-2433).
    --  In all of them a null Item means First.
    function Is_Displayed
           (This : in Tree;
            Item : in FLTK.Tree_Items.Tree_Item)
        return Boolean;

    --  Scrolls Item to the top, if it isn't displayed already.
    procedure Show_Item
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    --  Scrolls so that Item is Offset pixels below the top, as far as the
    --  tree can scroll.
    procedure Show_Item
           (This   : in out Tree;
            Item   : in     FLTK.Tree_Items.Tree_Item;
            Offset : in     Integer);

    procedure Show_Item_Top
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    procedure Show_Item_Middle
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    procedure Show_Item_Bottom
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);




    --  Debugging  --

    --  Prints the tree's structure to standard output.
    procedure Show_Self
           (This : in out Tree);




    --  Drawing, Events  --

    procedure Draw
           (This : in out Tree);

    function Handle
           (This  : in out Tree;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Tree is new Group with null record;

    overriding procedure Initialize
           (This : in out Tree);

    overriding procedure Finalize
           (This : in out Tree);

    procedure Extra_Init
           (This       : in out Tree;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Tree)
    with Inline;


    pragma Inline (Add);
    pragma Inline (Insert);
    pragma Inline (Insert_Above);
    pragma Inline (Remove);
    pragma Inline (Clear);
    pragma Inline (Clear_Children);
    pragma Inline (Find);

    pragma Inline (Root);
    pragma Inline (Set_Root_Label);

    pragma Inline (Callback_Item);
    pragma Inline (Callback_Reason);

    pragma Inline (First);
    pragma Inline (Last);

    pragma Inline (Open);
    pragma Inline (Close);
    pragma Inline (Open_Toggle);

    pragma Inline (Select_Item);
    pragma Inline (Deselect);
    pragma Inline (Select_All);
    pragma Inline (Deselect_All);
    pragma Inline (Select_Toggle);
    pragma Inline (First_Selected);
    pragma Inline (Last_Selected);
    pragma Inline (Next_Selected);
    pragma Inline (Prev_Selected);

    pragma Inline (Get_Show_Root);
    pragma Inline (Set_Show_Root);
    pragma Inline (Get_Show_Collapse);
    pragma Inline (Set_Show_Collapse);
    pragma Inline (Get_Select_Mode);
    pragma Inline (Set_Select_Mode);
    pragma Inline (Get_Connector_Style);
    pragma Inline (Set_Connector_Style);
    pragma Inline (Get_Sort_Order);
    pragma Inline (Set_Sort_Order);
    pragma Inline (Get_Item_Label_Font);
    pragma Inline (Set_Item_Label_Font);
    pragma Inline (Get_Item_Label_Size);
    pragma Inline (Set_Item_Label_Size);
    pragma Inline (Get_Item_Label_Color);
    pragma Inline (Set_Item_Label_Color);
    pragma Inline (Get_Margin_Left);
    pragma Inline (Set_Margin_Left);
    pragma Inline (Get_Widget_Margin_Left);
    pragma Inline (Set_Widget_Margin_Left);
    pragma Inline (Get_Margin_Top);
    pragma Inline (Set_Margin_Top);
    pragma Inline (Get_Margin_Bottom);
    pragma Inline (Set_Margin_Bottom);
    pragma Inline (Get_Open_Child_Margin_Bottom);
    pragma Inline (Set_Open_Child_Margin_Bottom);
    pragma Inline (Get_User_Icon_Margin_Left);
    pragma Inline (Set_User_Icon_Margin_Left);
    pragma Inline (Get_Label_Margin_Left);
    pragma Inline (Set_Label_Margin_Left);
    pragma Inline (Get_Connector_Width);
    pragma Inline (Set_Connector_Width);
    pragma Inline (Get_Line_Spacing);
    pragma Inline (Set_Line_Spacing);
    pragma Inline (Get_Item_Draw_Mode);
    pragma Inline (Set_Item_Draw_Mode);
    pragma Inline (Get_Select_Box);
    pragma Inline (Set_Select_Box);
    pragma Inline (Get_Item_Label_BG_Color);
    pragma Inline (Set_Item_Label_BG_Color);

    pragma Inline (Get_Open_Icon);
    pragma Inline (Clear_Open_Icon);
    pragma Inline (Get_Close_Icon);
    pragma Inline (Clear_Close_Icon);
    pragma Inline (Get_User_Icon);
    pragma Inline (Clear_User_Icon);

    pragma Inline (Get_V_Position);
    pragma Inline (Set_V_Position);
    pragma Inline (Get_H_Position);
    pragma Inline (Set_H_Position);
    pragma Inline (Get_Scrollbar_Size);
    pragma Inline (Set_Scrollbar_Size);

    pragma Inline (Is_Displayed);
    pragma Inline (Show_Item);
    pragma Inline (Show_Item_Top);
    pragma Inline (Show_Item_Middle);
    pragma Inline (Show_Item_Bottom);

    pragma Inline (Show_Self);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Trees;


