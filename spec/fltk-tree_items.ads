

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

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




    --  Label  --

    function Get_Label
           (This : in Tree_Item)
        return String;

    procedure Set_Label
           (This : in Tree_Item;
            Text : in String);




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


private


    type Tree_Item is record
        Void_Ptr : Storage.Integer_Address := Null_Pointer;
    end record;

    No_Tree_Item : constant Tree_Item := (Void_Ptr => Null_Pointer);

    pragma Inline (Is_Null);
    pragma Inline (Cast);
    pragma Inline (Address_Of);

    pragma Inline (Is_Open);
    pragma Inline (Is_Selected);
    pragma Inline (Is_Active);
    pragma Inline (Is_Visible);
    pragma Inline (Is_Root);

    pragma Inline (Has_Children);
    pragma Inline (Number_Of_Children);
    pragma Inline (Depth);


end FLTK.Tree_Items;


