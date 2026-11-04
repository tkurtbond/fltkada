

--  Programmed by T. Kurt Bond and Claude Sonnet 5
--  Released into the public domain


with

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

    procedure Open
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    procedure Close
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    procedure Open_Toggle
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);




    --  Selection  --

    procedure Select_Item
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    procedure Deselect
           (This : in out Tree;
            Item : in     FLTK.Tree_Items.Tree_Item);

    --  Returns how many items in the whole tree changed state.
    function Select_All
           (This : in out Tree)
        return Natural;

    function Deselect_All
           (This : in out Tree)
        return Natural;

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
    pragma Inline (Get_Line_Spacing);
    pragma Inline (Set_Line_Spacing);
    pragma Inline (Get_Item_Draw_Mode);
    pragma Inline (Set_Item_Draw_Mode);
    pragma Inline (Get_Select_Box);
    pragma Inline (Set_Select_Box);

    pragma Inline (Show_Self);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Trees;


