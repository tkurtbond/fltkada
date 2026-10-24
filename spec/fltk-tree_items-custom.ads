

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    FLTK.Widgets.Groups.Trees;


package FLTK.Tree_Items.Custom is


    --  A tree item whose label area is drawn by Ada code, by overriding
    --  Draw_Item_Content.  Unlike a plain Tree_Item, this is a Wrapper:
    --  Forge.Create allocates the C++ item, and handing it to a tree with
    --  Trees.Add or Tree_Items.Replace makes the tree its owner.
    --
    --  The Ada object must stay alive for as long as it should draw the
    --  item, so it is normally allocated.  If it is finalized first, the
    --  item goes back to being drawn like a plain one; if the tree deletes
    --  the item first, the Ada object is simply left unattached.

    type Custom_Item is new Wrapper with private;




    package Forge is

        function Create
               (Parent : in out FLTK.Widgets.Groups.Trees.Tree'Class)
            return Custom_Item;

    end Forge;




    --  The handle used to pass this item to Trees.Add, Tree_Items.Replace,
    --  or any of the other Tree_Items subprograms.  It is No_Tree_Item
    --  once the tree has deleted the item.
    function Item
           (This : in Custom_Item)
        return Tree_Item;




    --  Drawing  --

    --  Draws the item's label area, and its background, when Render is
    --  True, and returns the rightmost X position of the item's content,
    --  for the tree's horizontal scrollbar.  The item's area is given by
    --  Tree_Items.Label_X, Label_Y, Label_W and Label_H.  The default
    --  draws the label just as a plain item would.
    function Draw_Item_Content
           (This   : in out Custom_Item;
            Render : in     Boolean)
        return Integer;

    --  The colors the item's content should be drawn with, which take
    --  into account whether the item is selected and active.  Only
    --  meaningful inside Draw_Item_Content.
    function Draw_Foreground_Color
           (This : in Custom_Item)
        return Color;

    function Draw_Background_Color
           (This : in Custom_Item)
        return Color;


private


    type Custom_Item is new Wrapper with null record;

    overriding procedure Finalize
           (This : in out Custom_Item);

    procedure Extra_Init
           (This : in out Custom_Item)
    with Inline;


    pragma Inline (Item);
    pragma Inline (Draw_Item_Content);
    pragma Inline (Draw_Foreground_Color);
    pragma Inline (Draw_Background_Color);


end FLTK.Tree_Items.Custom;


