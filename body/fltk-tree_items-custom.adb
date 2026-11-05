

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Hook_Exceptions,
    Interfaces.C,
    System.Address_To_Access_Conversions;


package body FLTK.Tree_Items.Custom is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_tree_item_custom
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_tree_item_custom, "new_fl_tree_item_custom");
    pragma Inline (new_fl_tree_item_custom);

    procedure free_fl_tree_item_custom
           (TI : in Storage.Integer_Address);
    pragma Import (C, free_fl_tree_item_custom, "free_fl_tree_item_custom");
    pragma Inline (free_fl_tree_item_custom);

    procedure fl_tree_item_custom_set_ada
           (TI, UD : in Storage.Integer_Address);
    pragma Import (C, fl_tree_item_custom_set_ada, "fl_tree_item_custom_set_ada");
    pragma Inline (fl_tree_item_custom_set_ada);




    function fl_tree_item_custom_draw_item_content
           (TI : in Storage.Integer_Address;
            R  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_tree_item_custom_draw_item_content,
        "fl_tree_item_custom_draw_item_content");
    pragma Inline (fl_tree_item_custom_draw_item_content);

    function fl_tree_item_custom_drawfgcolor
           (TI : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_tree_item_custom_drawfgcolor, "fl_tree_item_custom_drawfgcolor");
    pragma Inline (fl_tree_item_custom_drawfgcolor);

    function fl_tree_item_custom_drawbgcolor
           (TI : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_tree_item_custom_drawbgcolor, "fl_tree_item_custom_drawbgcolor");
    pragma Inline (fl_tree_item_custom_drawbgcolor);




    ----------------------
    --  Exported Hooks  --
    ----------------------

    package Custom_Convert is new System.Address_To_Access_Conversions (Custom_Item'Class);

    function Tree_Item_Draw_Content_Hook
           (UD : in Storage.Integer_Address;
            R  : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Export (C, Tree_Item_Draw_Content_Hook, "tree_item_draw_content_hook");

    function Tree_Item_Draw_Content_Hook
           (UD : in Storage.Integer_Address;
            R  : in Interfaces.C.int)
        return Interfaces.C.int
    is
        use type Interfaces.C.int;
        Ada_Item : access Custom_Item'Class;
    begin
        --  Checked here, and not by a handler around the call, so that the
        --  program's own exceptions aren't taken for FLTK's (FLTKAda-BUGS.md 45).
        if UD = Null_Pointer then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "User data null pointer passed to Fl_Tree_Item::draw_item_content override hook");
            return 0;
        end if;
        Ada_Item := Custom_Convert.To_Pointer (Storage.To_Address (UD));
        return Interfaces.C.int (Ada_Item.Draw_Item_Content (R /= 0));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
        return 0;
    end Tree_Item_Draw_Content_Hook;


    --  The tree deleted the item before the Ada object went away.
    procedure Tree_Item_Gone_Hook
           (UD : in Storage.Integer_Address);
    pragma Export (C, Tree_Item_Gone_Hook, "tree_item_gone_hook");

    procedure Tree_Item_Gone_Hook
           (UD : in Storage.Integer_Address)
    is
        Ada_Item : access Custom_Item'Class;
    begin
        if UD = Null_Pointer then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "User data null pointer passed to Fl_Tree_Item destructor hook");
            return;
        end if;
        Ada_Item := Custom_Convert.To_Pointer (Storage.To_Address (UD));
        Ada_Item.Void_Ptr := Null_Pointer;
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Tree_Item_Gone_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Custom_Item) is
    begin
        if This.Void_Ptr /= Null_Pointer then
            free_fl_tree_item_custom (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This : in out Custom_Item) is
    begin
        fl_tree_item_custom_set_ada
           (This.Void_Ptr,
            Storage.To_Integer (Custom_Convert.To_Address (This'Unchecked_Access)));
    end Extra_Init;


    package body Forge is

        function Create
               (Parent : in out FLTK.Widgets.Groups.Trees.Tree'Class)
            return Custom_Item is
        begin
            return This : Custom_Item do
                This.Void_Ptr := new_fl_tree_item_custom
                   (Storage.To_Integer (FLTK.Widgets.Address_Of (Parent)));
                Extra_Init (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Item
           (This : in Custom_Item)
        return Tree_Item is
    begin
        return (Void_Ptr => This.Void_Ptr);
    end Item;




    function Draw_Item_Content
           (This   : in out Custom_Item;
            Render : in     Boolean)
        return Integer is
    begin
        return Integer (fl_tree_item_custom_draw_item_content
           (This.Void_Ptr, Boolean'Pos (Render)));
    end Draw_Item_Content;


    function Draw_Foreground_Color
           (This : in Custom_Item)
        return Color is
    begin
        return Color (fl_tree_item_custom_drawfgcolor (This.Void_Ptr));
    end Draw_Foreground_Color;


    function Draw_Background_Color
           (This : in Custom_Item)
        return Color is
    begin
        return Color (fl_tree_item_custom_drawbgcolor (This.Void_Ptr));
    end Draw_Background_Color;


end FLTK.Tree_Items.Custom;


