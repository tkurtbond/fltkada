--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/tree.fl (tree.cxx): a tree of items, some holding an
--  input, a button or a group of two buttons, beside panels of controls
--  that try out the tree's margins, icons, connectors, selection and
--  when modes, item fonts and colours, item operations (open and close
--  all, insert above, remove, swap, select by path, add 20,000 items,
--  load a preferences database), and the tree's own fonts, colours and
--  scrollbar sizes.  Every tree callback and test result is written to
--  the terminal at the bottom.
--
--  What is left out, and why:
--
--  * Color_Chooser always passes a mode, and FLTK's -1 (leave the
--    chooser's mode alone) can't be given.  RGB, the default, is the
--    same mode, but setting it reformats the fields, so they show
--    "0.000" where FLTK's program shows "0".
--
--  Guided by pofltk's Tree.Mod.


with

    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    FLTK.Asks,
    FLTK.Environment,
    FLTK.Events,
    FLTK.Images.Pixmaps,
    FLTK.Static,
    FLTK.Text_Buffers,
    FLTK.Tooltips,
    FLTK.Tree_Items,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Text_Displays,
    FLTK.Widgets.Groups.Trees,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Alignment,
    FLTK.Asks.Confirm_Result,
    FLTK.Callback_Flag,
    FLTK.Tree_Items.Item_Draw_Mode,
    FLTK.Tree_Items.Tree_Item,
    FLTK.Widgets.Widget_Callback;


function Tree
    return Integer
is

    package SU    renames Ada.Strings.Unbounded;
    package Asks  renames FLTK.Asks;
    package Env   renames FLTK.Environment;
    package Ev    renames FLTK.Events;
    package Pix   renames FLTK.Images.Pixmaps;
    package Static renames FLTK.Static;
    package TB    renames FLTK.Text_Buffers;
    package Tips  renames FLTK.Tooltips;
    package TI    renames FLTK.Tree_Items;
    package Bx    renames FLTK.Widgets.Boxes;
    package Btn   renames FLTK.Widgets.Buttons;
    package LBtn  renames FLTK.Widgets.Buttons.Light;
    package Chk   renames FLTK.Widgets.Buttons.Light.Check;
    package Grps  renames FLTK.Widgets.Groups;
    package Term  renames FLTK.Widgets.Groups.Terminals;
    package TD    renames FLTK.Widgets.Groups.Text_Displays;
    package Trees renames FLTK.Widgets.Groups.Trees;
    package DW    renames FLTK.Widgets.Groups.Windows.Double;
    package Inp   renames FLTK.Widgets.Inputs.Text;
    package Ch    renames FLTK.Widgets.Menus.Choices;
    package VS    renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;

    LF : constant Character := ASCII.LF;
    HT : constant Character := ASCII.HT;


    --  Tooltips and the help text, from tree.cxx  --

    Tip_Tree : constant String :=
        "Test tree";

    Tip_Tree_Globals : constant String :=
        "These controls only affect the selected items. If no items are selected, all " &
        "existing items in tree are modified.";

    Tip_Margintop_Slider : constant String :=
        "Changes the top margin for the tree widget";

    Tip_Marginleft_Slider : constant String :=
        "Changes the left margin for the tree widget";

    Tip_Marginbottom_Slider : constant String :=
        "Changes the bottom margin for the tree" & LF &
        "Sets how far beyond bottom of tree you can scroll";

    Tip_Linespacing_Slider : constant String :=
        "Changes the spacing between items in the tree";

    Tip_Usericonmarginleft_Slider : constant String :=
        "Changes the left margin for the user icons (if any)";

    Tip_Labelmarginleft_Slider : constant String :=
        "Changes the left margin for the item label";

    Tip_Widgetmarginleft_Slider : constant String :=
        "Changes the margin to the left of child FLTK widget()" & LF &
        """Show label + widget"" must be 'on' for this to take effect, i.e." & LF &
        "item_draw_mode(FL_TREE_ITEM_DRAW_LABEL_AND_WIDGET)";

    Tip_Openchild_Marginbottom_Slider : constant String :=
        "Changes the vertical space below an open child tree";

    Tip_Connectorwidth_Slider : constant String :=
        "Tests Fl_Tree::connectorwidth()";

    Tip_Collapseicons_Chooser : constant String :=
        "Tests Fl_Tree::openicon(), Fl_Tree::closeicon() and Fl_Tree::showcollapse().";

    Tip_Connectorstyle_Chooser : constant String :=
        "Tests Fl_Tree::connectorstyle() bit flags";

    Tip_Selectmode_Chooser : constant String :=
        "Tests Fl_Tree::selectmode()" & LF &
        "Sets how Fl_Tree handles mouse selection of tree items." & LF &
        "    NONE        -- Not selectable by keyboard/mouse" & LF &
        "    SINGLE      -- Only one item at a time selectable by keyboard/mouse" & LF &
        "    MULTI       -- Multiple items selectable" & LF &
        "    SINGLE+DRAG -- Lets user drag items to different position in tree";

    Tip_Reselectmode_Chooser : constant String :=
        "Tests Fl_Tree::item_reselect_mode()." & LF &
        "Enables 'reselect' events." & LF &
        "These happen when someone selects an item already selected" & LF &
        "(mouse drags or multi-clicks)";

    Tip_Whenmode_Chooser : constant String :=
        "Sets when() the tree's callback is invoked";

    Tip_Usericon_Radio : constant String :=
        "Tests Fl_Tree_Item::usericon()";

    Tip_Showroot_Radio : constant String :=
        "Tests tree->showroot();";

    Tip_Visiblefocus_Checkbox : constant String :=
        "Toggles the tree's visible_focus() box";

    Tip_Labelandwidget_Radio : constant String :=
        "Tests Fl_Tree::item_draw_mode(FL_TREE_ITEM_DRAW_LABEL_AND_WIDGET)" & LF &
        "Enables both label and widget() for display." & LF &
        "When enabled, widget should appear to the right of the item's label." & LF &
        "By default, the widget() is shown in place of the item's label.";

    Tip_Itemheightfromwidget_Radio : constant String :=
        "Tests Fl_Tree::item_draw_mode(FL_TREE_ITEM_HEIGHT_FROM_WIDGET)" & LF &
        "If enabled, item's height will track the widget()'s height." & LF &
        "When enabled, click 'ccc button' or 'D1/D2' buttons to test.";

    Tip_Globalvisiblefocus_Checkbox : constant String :=
        "Toggles the global Fl::visible_focus()";

    Tip_Test_Operations : constant String :=
        "These controls only affect the defaults for new items that are created. These " &
        "test the Fl_Tree_Prefs methods.";

    Tip_Show : constant String :=
        "Tests show_item() with no position specified." & LF &
        "Makes the selected item visible IF it is off-screen." & LF &
        "No change made if it is not off-screen.";

    Tip_Top : constant String :=
        "Test show_item_top()." & LF &
        "Scrolls selected item to the top of the display" & LF &
        "(only works if scrollbar showing)" & LF &
        "To use:" & LF &
        "1) open '500 items'" & LF &
        "2) select item 0010" & LF &
        "3) Hit Top/Mid/Bot";

    Tip_Mid : constant String :=
        "Tests show_item_middle()." & LF &
        "Scrolls the selected item to the middle of the display" & LF &
        "To use:" & LF &
        "  1) open '500 items'" & LF &
        "  2) select 'item 0010'" & LF &
        "  3) Hit Top/Mid/Bot";

    Tip_Bot : constant String :=
        "Tests show_item_bottom()." & LF &
        "Scrolls the selected item to the bottom of the display" & LF &
        "To use:" & LF &
        "  1) open '500 items'" & LF &
        "  2) select 'item 0010'" & LF &
        "  3) Hit Top/Mid/Bot";

    Tip_Openall_Button : constant String :=
        "Opens all nodes that have children";

    Tip_Loaddb_Button : constant String :=
        "Load the contents of an Fl_Preferences database into the tree view";

    Tip_Insertabove_Button : constant String :=
        "Inserts three items above the selected items";

    Tip_Rebuildtree_Button : constant String :=
        "Rebuilds the tree with defaults";

    Tip_Showpathname_Button : constant String :=
        "Tests Fl_Tree::item_pathname()" & LF &
        "Show the pathname for the selected item.";

    Tip_Closeall_Button : constant String :=
        "Closes all nodes that have children" & LF &
        "(doesn't affect 'root')";

    Tip_Clearall_Button : constant String :=
        "Tests Fl_Tree::clear()." & LF &
        "Clears all items";

    Tip_Testcallbackflag_Button : constant String :=
        "Test the 'docallback' argument can disable callbacks.";

    Tip_Testrootshowself_Button : constant String :=
        "Test the root->'show_self() method to show the entire tree on stdout";

    Tip_Add20k_Button : constant String :=
        "Adds 20,000 items to the selected item's parent";

    Tip_Selected_Items : constant String :=
        "These controls only affect the selected items. If no items are selected, all " &
        "existing items in tree are modified.";

    Tip_Selected_Labelfont_Choice : constant String :=
        "Tests Fl_Tree_Item::labelfont();" & LF &
        "Changes the font for the selected items's labels." & LF &
        "If none selected, all are changed.";

    Tip_Selected_Labelsize_Slider : constant String :=
        "Tests Fl_Tree_Item::labelsize();" & LF &
        "Changes the font size of the selected items's labels." & LF &
        "If none selected, all are changed.";

    Tip_All_Labelfgcolor_Button : constant String :=
        "Sets the Fl_Tree_Item::labelfgcolor() for the selected items. If none selected, " &
        "all are changed.";

    Tip_All_Labelbgcolor_Button : constant String :=
        "Sets the Fl_Tree_Item::labelbgcolor() for the selected items. If none selected, " &
        "all are changed.";

    Tip_Deactivate_Items_Toggle : constant String :=
        "Toggle the deactivation state of the selected items." & LF &
        "If none are selected, all are set.";

    Tip_Deactivate_Tree_Toggle : constant String :=
        "Deactivates the entire tree widget";

    Tip_Bold_Toggle : constant String :=
        "Toggles bold font for selected items" & LF &
        "If nothing selected, all are changed";

    Tip_Showselected_Button : constant String :=
        "Clears the selected items";

    Tip_Clearselected_Button : constant String :=
        "Removes the selected items";

    Tip_Swapselected_Button : constant String :=
        "Tests the Fl_Tree_Item::swap_children() method" & LF &
        "Swaps two selected items (items must be siblings)";

    Tip_Selectall_Button : constant String :=
        "Selects all items in the tree";

    Tip_Deselectall_Button : constant String :=
        "Deselects all items in the tree";

    Tip_Nextselected_Button : constant String :=
        "Tests the Fl_Tree::next_selected() function";

    Tip_Bbbselect_Toggle : constant String :=
        "Toggle selection of just the /Bbb item" & LF &
        "(Not children)";

    Tip_Bbbselect2_Toggle : constant String :=
        "Toggle selection of the /Bbb item and its children";

    Tip_Bbbchild02select_Toggle : constant String :=
        "Toggle the single item ""/Bbb/child-02"" using the item's ""pathname"".";

    Tip_Rootselect_Toggle : constant String :=
        "Toggle selection of the ROOT item";

    Tip_Rootselect2_Toggle : constant String :=
        "Toggle selection of the ROOT item and all children";

    Tip_Tree_Fonts_Colors : constant String :=
        "These controls only affect the selected items. If no items are selected, all " &
        "existing items in tree are modified.";

    Tip_Labelfont_Choice : constant String :=
        "Sets the default font used for new items created. Does NOT affect existing " &
        "items.";

    Tip_Labelsize_Slider : constant String :=
        "Sets the font size for the  tree's label()." & LF &
        "This is also the font size that will be used to draw the items IF their size " &
        "hasn't been set with Fl_Tree_Item::labelsize() or Fl_Tree::item_labelsize()";

    Tip_Item_Labelfont_Choice : constant String :=
        "Sets the default font used for new items created." & LF &
        ".Also affects any items whose font has NOT specifically been set with " &
        "item->labelfont().";

    Tip_Item_Labelsize_Slider : constant String :=
        "Sets the default font size used for new items created." & LF &
        ".Also affects any items whose font size has NOT specifically been set with " &
        "item->labelsize().";

    Tip_Labelcolor_Button : constant String :=
        "Changes Fl_Tree::labelcolor()." & LF &
        "This affects the text color of the widget's label.";

    Tip_Color_Button : constant String :=
        "Changes Fl_Tree::color()." & LF &
        "This affects the background color of the widget. It also affects the bg color " &
        "of newly created  items *if*  Fl_Tree::item_labelbgcolor() hasn't been changed.";

    Tip_Selection_Color_Button : constant String :=
        "Sets the Fl_Tree::selection_color()." & LF &
        "This affects the item's colors when they're selected.";

    Tip_Item_Labelfgcolor_Button : constant String :=
        "Sets the default label fg color for newly created  items.";

    Tip_Item_Labelbgcolor_Button : constant String :=
        "Sets the default label bg color for newly created items. When set, this " &
        "overrides the default behavior of using Fl_Tree::color().";

    Tip_X_Item_Labelbgcolor_Button : constant String :=
        "Make the bgcolor 'transparent' (0xffffffff)";

    Tip_Tree_Scrollbar_Size_Slider : constant String :=
        "Tests Fl_Tree::scrollbar_size() effects on tree clipping." & LF &
        "The value is normally 0, which causes Fl_Tree to use the global " &
        "Fl::scrollbar_size() instead.";

    Tip_Scrollbar_Size_Slider : constant String :=
        "Tests Fl::scrollbar_size() effects on tree clipping";

    Tip_Testsuggs_Button : constant String :=
        "Suggestions on how to do tests";

    Help_Text : constant String :=
        "CHILD WIDGET SIZING TESTS" & LF &
        "=========================" & LF &
        "   1) Start program" & LF &
        "   2) Click the 'ccc button' and D1/D2 buttons." & LF &
        "      Their sizes should not change." & LF &
        "   3) Click the 'Item h() from widget' checkbox." & LF &
        "   4) Click the 'ccc button' and D1/D2 buttons." & LF &
        "      Their sizes should change, getting larger vertically." & LF &
        "      This validates that widget's size can affect the tree." & LF &
        "   5) Disable the checkbox, widgets should resize back to the" & LF &
        "      size of the other items." & LF &
        "   6) Hit ^A to select all items" & LF &
        "   7) Under 'Selected Items', drag the 'Label Size' slider around." & LF &
        "      All the item's height should change, as well as child widgets." & LF &
        "   8) Put Label Size' slider back to normal" & LF &
        LF &
        "CHILD WIDGET + LABEL ITEM DRAWING TESTS" & LF &
        "=======================================" & LF &
        "   1) Start program" & LF &
        "   2) Click 'Show label + widget'." & LF &
        "      The widgets should all show item labels to their left." & LF &
        "   3) Disable same, item labels should disappear," & LF &
        "      showing the widgets in their place." & LF &
        LF &
        "COLORS" & LF &
        "======" & LF &
        "   1) Start program" & LF &
        "   2) Change 'Tree Fonts+Colors' -> color()" & LF &
        "   3) Entire tree's background color will change, including items." & LF &
        "   4) Change the 'Tree Fonts + Colors -> item_labelbgcolor()'" & LF &
        "   6) Click the '111' item to select it." & LF &
        "   7) Click 'Test Operations -> Insert Above'" & LF &
        "      New items should appear above the selected item using the new color." & LF &
        "      This color will be different from the background color." & LF &
        "   8) Change the 'Tree Fonts+Colors' -> color()" & LF &
        "      The entire tree's bg should change, except the new items." & LF &
        "   9) Click the Tree Fonts+Colors -> item_labelbgcolor() 'X' button." & LF &
        "      This resets item_labelbgcolor() to the default 'transparent' color " &
        "(0xffffffff)" & LF &
        "  10) Again, click the 'Insert Above' button." & LF &
        "      New items will be created in the background color, and changing the " &
        "color()" & LF &
        "      should affect the new items too." & LF &
        LF &
        "SCROLLING" & LF &
        "=========" & LF &
        "   1) Open '500 items' and 'Long Line' so that both scrollbars appear:" & LF &
        "        * The 'focus box' for the selected item should not be clipped" & LF &
        "          horizontally by the vertical scrollbar." & LF &
        "        * Resizing the window horizontally should resize the focus box" & LF &
        "        * Scrolling vertically/horizontally should show reveal all" & LF &
        "          edges of the tree. One *exception* is the widget label" & LF &
        "          to the right of the 'ccc button'; labels aren't part" & LF &
        "          of the widget, and therefore don't affect scroll tabs" & LF &
        "   2) Scroll vertical scroller to the middle of the tree" & LF &
        "   3) Left click and drag up/down to extend the selection:" & LF &
        "        * Selection should autoscroll if you drag off the top/bottom" & LF &
        "        * Selection should work *even* if you drag horizontally" & LF &
        "          off the window edge; moving up/down outside the window" & LF &
        "          should continue to autoscroll" & LF &
        "   4) Click either of the the scrollbar tabs and drag:" & LF &
        "        * Even if you drag off the scrollbar, the scrollbar" & LF &
        "          tab should continue to move" & LF &
        "        * Should continue to work if you drag off the window edge" & LF &
        "          horizontally drag off the window." & LF &
        "   5) Click 'Bbb' and hit 'Add 20,000', then position the" & LF &
        "      'ccc button' so it's partially obscured by a scrollbar tab:" & LF &
        "        * Clicking the obscured button should work" & LF &
        "        * Clicking on the tab over the button should not 'click through'" & LF &
        "          to the button." & LF;


    --  Icons  --

    type Pixel_Rows is array (1 .. 11) of String (1 .. 11);

    function To_Data
           (Rows : in Pixel_Rows)
        return Pix.Pixmap_Data
    is
        Data : Pix.Pixmap_Data (Rows'Range, Rows (Rows'First)'Range);
    begin
        for R in Data'Range (1) loop
            for C in Data'Range (2) loop
                Data (R, C) := Rows (R) (C);
            end loop;
        end loop;
        return Data;
    end To_Data;

    Folder_Rows : constant Pixel_Rows :=
       ("...........",
        ".....@@@@..",
        "....@xxxx@.",
        "@@@@@xxxx@@",
        "@xxxxxxxxx@",
        "@xxxxxxxxx@",
        "@xxxxxxxxx@",
        "@xxxxxxxxx@",
        "@xxxxxxxxx@",
        "@xxxxxxxxx@",
        "@@@@@@@@@@@");

    Folder_Colors : constant Pix.Color_Definition_Array :=
       ((+".", Pix.Colorful, +"None"),
        (+"x", Pix.Colorful, +"#d8d833"),
        (+"@", Pix.Colorful, +"#808011"));

    Document_Rows : constant Pixel_Rows :=
       (".@@@@@@@@@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@xxxxxxx@.",
        ".@@@@@@@@@.");

    Document_Colors : constant Pix.Color_Definition_Array :=
       ((+".", Pix.Colorful, +"None"),
        (+"x", Pix.Colorful, +"#d8d8f8"),
        (+"@", Pix.Colorful, +"#202060"));

    Open_Rows : constant Pixel_Rows :=
       ("...........",
        "....@......",
        "....@@.....",
        "....@@@....",
        "....@@@@...",
        "....@@@@@..",
        "....@@@@...",
        "....@@@....",
        "....@@.....",
        "....@......",
        "...........");

    Close_Rows : constant Pixel_Rows :=
       ("...........",
        "...........",
        "...........",
        "...........",
        ".@@@@@@@@@.",
        "..@@@@@@@..",
        "...@@@@@...",
        "....@@@....",
        ".....@.....",
        "...........",
        "...........");

    Arrow_Colors : constant Pix.Color_Definition_Array :=
       ((+".", Pix.Colorful, +"None"),
        (+"@", Pix.Colorful, +"#000000"));

    Icon_Header  : constant Pix.Header := (11, 11, 3, 1);
    Arrow_Header : constant Pix.Header := (11, 11, 2, 1);

    Folder_Pixmap   : constant Pix.Pixmap := Pix.Forge.Create (Icon_Header, Folder_Colors,
        To_Data (Folder_Rows));
    Document_Pixmap : constant Pix.Pixmap := Pix.Forge.Create (Icon_Header, Document_Colors,
        To_Data (Document_Rows));
    Folder_Deicon   : Pix.Pixmap := Pix.Forge.Create (Icon_Header, Folder_Colors,
        To_Data (Folder_Rows));
    Document_Deicon : Pix.Pixmap := Pix.Forge.Create (Icon_Header, Document_Colors,
        To_Data (Document_Rows));
    Open_Pixmap     : constant Pix.Pixmap := Pix.Forge.Create (Arrow_Header, Arrow_Colors,
        To_Data (Open_Rows));
    Close_Pixmap    : constant Pix.Pixmap := Pix.Forge.Create (Arrow_Header, Arrow_Colors,
        To_Data (Close_Rows));


    --  Menu entries  --

    type Name_List is array (Positive range <>) of SU.Unbounded_String;

    Font_Names : constant Name_List :=
       (+"Helvetica", +"Helvetica Bold", +"Helvetica Italic", +"Helvetica Bold Italic",
        +"Courier", +"Courier Bold", +"Courier Italic", +"Courier Bold Italic",
        +"Times", +"Times Bold", +"Times Italic", +"Times Bold Italic",
        +"Symbol", +"Screen", +"Screen bold", +"Zapf Dingbats");


    --  The window  --

    Window : DW.Double_Window := DW.Forge.Create (1045, 730, "tree");

    Tree_View : Trees.Tree := Trees.Forge.Create (Window, 15, 22, 320, 539, "Tree");

    Outer : Grps.Group := Grps.Forge.Create (Window, 350, 5, 681, 556);

    Globals : Grps.Group := Grps.Forge.Create (Outer, 350, 23, 330, 389, "Tree Globals");

    Margintop_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 36, 155, 16, "margintop()");
    Marginleft_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 56, 155, 16, "marginleft()");
    Marginbottom_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 76, 155, 16, "marginbottom()");
    Linespacing_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 96, 155, 16, "linespacing()");
    Usericonmarginleft_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 116, 155, 16, "usericonmarginleft()");
    Labelmarginleft_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 136, 155, 16, "labelmarginleft()");
    Widgetmarginleft_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 156, 155, 16, "widgetmarginleft()");
    Openchild_Marginbottom_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 176, 155, 16, "openchild_marginbottom()");
    Connectorwidth_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Globals, 505, 195, 155, 16, "connectorwidth()");

    Collapseicons_Chooser : Ch.Choice :=
        Ch.Forge.Create (Globals, 520, 221, 140, 21, "Collapse icons");
    Connectorstyle_Chooser : Ch.Choice :=
        Ch.Forge.Create (Globals, 520, 245, 140, 21, "Line style");
    Selectmode_Chooser : Ch.Choice :=
        Ch.Forge.Create (Globals, 520, 269, 140, 21, "Selection Mode");
    Reselectmode_Chooser : Ch.Choice :=
        Ch.Forge.Create (Globals, 520, 293, 140, 21, "Item Reselect Mode");
    Whenmode_Chooser : Ch.Choice :=
        Ch.Forge.Create (Globals, 520, 319, 140, 21, "When");

    Usericon_Radio : Chk.Check_Button :=
        Chk.Forge.Create (Globals, 485, 351, 20, 16, "Enable user icons?");
    Showroot_Radio : Chk.Check_Button :=
        Chk.Forge.Create (Globals, 485, 368, 20, 16, "Show root?");
    Visiblefocus_Checkbox : Chk.Check_Button :=
        Chk.Forge.Create (Globals, 485, 385, 20, 16, "Visible focus?");
    Labelandwidget_Radio : Chk.Check_Button :=
        Chk.Forge.Create (Globals, 645, 351, 20, 16, "Show label + widget");
    Itemheightfromwidget_Radio : Chk.Check_Button :=
        Chk.Forge.Create (Globals, 645, 368, 20, 16, "Item h() from widget");
    Globalvisiblefocus_Checkbox : Chk.Check_Button :=
        Chk.Forge.Create (Globals, 645, 385, 20, 16, "Global visible focus?");

    Operations : Grps.Group := Grps.Forge.Create (Outer, 350, 435, 330, 125, "Test Operations");

    Showitem_Box : Grps.Group :=
        Grps.Forge.Create (Operations, 370, 460, 70, 82,
        "show_item()" & LF);

    Show_Button : Btn.Button := Btn.Forge.Create (Showitem_Box, 385, 469, 40, 17, "Show");
    Top_Button  : Btn.Button := Btn.Forge.Create (Showitem_Box, 385, 486, 40, 16, "Top");
    Mid_Button  : Btn.Button := Btn.Forge.Create (Showitem_Box, 385, 502, 40, 16, "Mid");
    Bot_Button  : Btn.Button := Btn.Forge.Create (Showitem_Box, 385, 518, 40, 16, "Bot");

    Openall_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 470, 451, 95, 16, "Open All");
    Loaddb_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 470, 471, 95, 16, "Load Database...");
    Insertabove_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 470, 491, 95, 16, "Insert Above");
    Rebuildtree_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 470, 511, 95, 16, "Rebuild Tree");
    Showpathname_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 470, 531, 95, 16, "Show Pathname");
    Closeall_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 570, 451, 95, 16, "Close All");
    Clearall_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 570, 471, 95, 16, "Clear All");
    Testcallbackflag_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 570, 491, 95, 16, "Test Callback Flag");
    Testrootshowself_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 570, 511, 95, 16, "Root Show Self");
    Add20k_Button : Btn.Button :=
        Btn.Forge.Create (Operations, 570, 531, 95, 16, "Add 20,000");

    Selected : Grps.Group := Grps.Forge.Create (Outer, 696, 23, 335, 246, "Selected Items");

    Selected_Labelfont_Choice : Ch.Choice :=
        Ch.Forge.Create (Selected, 863, 31, 140, 21, "Fl_Tree_Item::labelfont()");
    Selected_Labelsize_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Selected, 863, 55, 140, 16, "Fl_Tree_Item::labelsize()");
    All_Labelfgcolor_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 863, 81, 16, 16, "Fl_Tree_Item::labelfgcolor()");
    All_Labelbgcolor_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 863, 99, 16, 16, "Fl_Tree_Item::labelbgcolor()");
    Deactivate_Items_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 758, 134, 100, 16, " Deactivate Items");
    Deactivate_Tree_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 758, 154, 100, 16, " Deactivate Tree");
    Bold_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 758, 174, 100, 16, " Bold Font");
    Showselected_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 864, 134, 95, 16, "Show Selected");
    Clearselected_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 864, 154, 95, 16, "Remove Selected");
    Swapselected_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 864, 174, 95, 16, "Swap Selected");
    Selectall_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 714, 199, 95, 16, "Select All");
    Deselectall_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 714, 219, 95, 16, "Deselect All");
    Nextselected_Button : Btn.Button :=
        Btn.Forge.Create (Selected, 713, 239, 95, 16, "next_selected()");
    Bbbselect_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 814, 199, 95, 16, " Select Bbb");
    Bbbselect2_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 814, 219, 95, 16, " Select Bbb+");
    Bbbchild02select_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 814, 239, 95, 16, " Toggle child-02");
    Rootselect_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 914, 199, 100, 16, "Select ROOT");
    Rootselect2_Toggle : LBtn.Light_Button :=
        LBtn.Forge.Create (Selected, 914, 219, 100, 16, "Select ROOT+");

    Fonts_Colors : Grps.Group :=
        Grps.Forge.Create (Outer, 695, 298, 335, 186, "Tree Fonts + Colors");

    Labelfont_Choice : Ch.Choice :=
        Ch.Forge.Create (Fonts_Colors, 848, 314, 140, 21, "labelfont()");
    Labelsize_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Fonts_Colors, 848, 338, 140, 16, "labelsize()");
    Item_Labelfont_Choice : Ch.Choice :=
        Ch.Forge.Create (Fonts_Colors, 848, 358, 140, 21, "Item_labelfont()");
    Item_Labelsize_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Fonts_Colors, 848, 383, 140, 16, "item_labelsize()");
    Labelcolor_Button : Btn.Button :=
        Btn.Forge.Create (Fonts_Colors, 813, 414, 16, 16, "labelcolor()");
    Color_Button : Btn.Button :=
        Btn.Forge.Create (Fonts_Colors, 813, 433, 16, 16, "color()");
    Selection_Color_Button : Btn.Button :=
        Btn.Forge.Create (Fonts_Colors, 813, 452, 16, 16, "selection_color()");
    Item_Labelfgcolor_Button : Btn.Button :=
        Btn.Forge.Create (Fonts_Colors, 973, 414, 16, 16, "item_labelfgcolor()");
    Item_Labelbgcolor_Button : Btn.Button :=
        Btn.Forge.Create (Fonts_Colors, 973, 433, 16, 16, "item_labelbgcolor()");
    X_Item_Labelbgcolor_Button : Btn.Button :=
        Btn.Forge.Create (Fonts_Colors, 993, 433, 16, 16, "X");

    Tree_Scrollbar_Size_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Outer, 835, 499, 180, 16, "Fl_Tree::scrollbar_size()");
    Scrollbar_Size_Slider : VS.Horizontal_Value_Slider :=
        VS.Forge.Create (Outer, 835, 519, 180, 16, "Fl::scrollbar_size()");
    Testsuggs_Button : Btn.Button :=
        Btn.Forge.Create (Outer, 935, 545, 95, 16, "Test Suggestions");

    Resizer_Box : Bx.Box := Bx.Forge.Create (Window, 0, 263, 15, 14);

    TTY : Term.Terminal := Term.Forge.Create (Window, 16, 571, 1014, 149);


    --  The widgets in the tree; tree.cxx makes them the first time
    --  RebuildTree runs.

    In_W : Inp.Text_Input := Inp.Forge.Create (Tree_View, 1, 1, 100, 1, "Fl_Input test");
    But  : Btn.Button := Btn.Forge.Create (Tree_View, 1, 1, 140, 1, "ccc button");
    Grp  : Grps.Group := Grps.Forge.Create (Tree_View, 100, 100, 140, 18);
    D1   : Btn.Button := Btn.Forge.Create (Grp, 100, 102, 65, 15, "D1");
    D2   : Btn.Button := Btn.Forge.Create (Grp, 175, 102, 65, 15, "D2");


    --  The help window; tree.cxx makes it the first time it is asked for.

    Help_Win  : DW.Double_Window := DW.Forge.Create (600, 600, "Test Suggestions");
    Help_Disp : TD.Text_Display := TD.Forge.Create (Help_Win, 0, 0, 600, 600);
    Help_Buff : TB.Text_Buffer := TB.Forge.Create;


    --  State  --

    CB_Counter  : Natural := 0;
    Item_Id     : Positive := 501;
    Help_Filled : Boolean := False;
    First_Icons : Boolean := True;




    --  Helpers  --

    function Img
           (N : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (N), Ada.Strings.Left);
    end Img;

    function Pad4
           (N : in Natural)
        return String
    is
        S : constant String := Img (N);
    begin
        return (1 .. 4 - S'Length => '0') & S;
    end Pad4;

    procedure Say
           (Text : in String) is
    begin
        TTY.Append (Text);
    end Say;

    procedure Ignore
           (Item : in TI.Tree_Item) is null;

    procedure Ignore
           (Count : in Natural) is null;

    procedure Add_Path
           (Path : in String)
    is
        Item : constant TI.Tree_Item := Tree_View.Add (Path);
        pragma Unreferenced (Item);
    begin
        null;
    end Add_Path;

    function Reason_Name
           (Reason : in Trees.Reason_Kind)
        return String is
    begin
        case Reason is
            when Trees.No_Reason  => return "none";
            when Trees.Selected   => return "selected";
            when Trees.Deselected => return "deselected";
            when Trees.Opened     => return "opened";
            when Trees.Closed     => return "closed";
            when Trees.Dragged    => return "dragged";
            when Trees.Reselected => return "reselected";
        end case;
    end Reason_Name;

    --  EditColor: False if the user cancelled.
    function Edit_Color
           (Hue : in out FLTK.Color)
        return Boolean
    is
        R, G, B : FLTK.Color_Component;
    begin
        Static.Get_Color (Hue, R, G, B);
        if Asks.Color_Chooser ("Choose Color", R, G, B) = Asks.Cancel then
            return False;
        end if;
        Hue := FLTK.RGB_Color (R, G, B);
        return True;
    end Edit_Color;

    function Get_Selected_Item_FG_Color
        return FLTK.Color
    is
        Item : TI.Tree_Item := Tree_View.First;
    begin
        while not TI.Is_Null (Item) loop
            if TI.Is_Selected (Item) then
                return TI.Get_Label_FG_Color (Item);
            end if;
            Item := TI.Next (Item);
        end loop;
        return Tree_View.Get_Item_Label_Color;
    end Get_Selected_Item_FG_Color;

    function Get_Selected_Item_BG_Color
        return FLTK.Color
    is
        Item : TI.Tree_Item := Tree_View.First;
    begin
        while not TI.Is_Null (Item) loop
            if TI.Is_Selected (Item) then
                return TI.Get_Label_BG_Color (Item);
            end if;
            Item := TI.Next (Item);
        end loop;
        return Tree_View.Get_Item_Label_BG_Color;
    end Get_Selected_Item_BG_Color;

    procedure Update_Color_Chips is
    begin
        Color_Button.Set_Background_Color (Tree_View.Get_Background_Color);
        Labelcolor_Button.Set_Background_Color (Tree_View.Get_Label_Color);
        Selection_Color_Button.Set_Background_Color (Tree_View.Get_Selection_Color);
        Item_Labelfgcolor_Button.Set_Background_Color (Tree_View.Get_Item_Label_Color);
        Item_Labelbgcolor_Button.Set_Background_Color (Tree_View.Get_Item_Label_BG_Color);
        All_Labelfgcolor_Button.Set_Background_Color (Tree_View.Get_Item_Label_Color);
        All_Labelbgcolor_Button.Set_Background_Color (Tree_View.Get_Item_Label_BG_Color);
        Window.Redraw;
    end Update_Color_Chips;

    procedure Assign_User_Icons
    is
        Item : TI.Tree_Item := Tree_View.First;
    begin
        if First_Icons then
            Folder_Deicon.Inactive;
            Document_Deicon.Inactive;
            First_Icons := False;
        end if;
        while not TI.Is_Null (Item) loop
            if Usericon_Radio.Is_On then
                if TI.Has_Children (Item) then
                    TI.Set_User_Icon (Item, Folder_Pixmap);
                    TI.Set_User_Deicon (Item, Folder_Deicon);
                else
                    TI.Set_User_Icon (Item, Document_Pixmap);
                    TI.Set_User_Deicon (Item, Document_Deicon);
                end if;
            else
                TI.Clear_User_Icon (Item);
                TI.Clear_User_Deicon (Item);
            end if;
            Item := TI.Next (Item);
        end loop;
        Tree_View.Redraw;
    end Assign_User_Icons;

    --  Clear takes an item's widget out of the tree (pofltk 58), where
    --  FLTK's leaves it there; so put it back before it is used again.
    procedure Attach
           (Path : in     String;
            W    : in out FLTK.Widgets.Widget'Class)
    is
        Item : constant TI.Tree_Item := Tree_View.Find (Path);
    begin
        if not TI.Is_Null (Item) then
            if W.Parent = null then
                Tree_View.Add (W);
            end if;
            W.Show;
            TI.Set_Widget (Item, W);
        end if;
    end Attach;

    procedure Rebuild_Tree is
    begin
        Tree_View.Clear;
        Add_Path ("Aaa");
        Add_Path ("Bbb");
        Add_Path ("Ccc");
        Add_Path ("Ddd");
        Add_Path ("Bbb/child-01");
        Add_Path ("Bbb/child-01/111");
        Add_Path ("Bbb/child-01/222");
        Add_Path ("Bbb/child-01/333");
        Add_Path ("Bbb/child-02");
        Add_Path ("Bbb/child-03");
        Add_Path ("Bbb/child-04");

        Attach ("Bbb/child-02", In_W);
        Attach ("Bbb/child-03", But);
        Attach ("Bbb/child-04", Grp);

        Tree_View.Set_Sort_Order (TI.No_Sort);
        TI.Close (Tree_View.Add ("Ascending"));
        Tree_View.Set_Sort_Order (TI.Ascending);
        Add_Path ("Ascending/Zzz");
        Add_Path ("Ascending/Xxx");
        Add_Path ("Ascending/Aaa");
        Add_Path ("Ascending/Bbb");
        Add_Path ("Ascending/Yyy");
        Add_Path ("Ascending/Ccc");

        Tree_View.Set_Sort_Order (TI.No_Sort);
        TI.Close (Tree_View.Add ("Descending"));
        Tree_View.Set_Sort_Order (TI.Descending);
        Add_Path ("Descending/Zzz");
        Add_Path ("Descending/Xxx");
        Add_Path ("Descending/Aaa");
        Add_Path ("Descending/Bbb");
        Add_Path ("Descending/Yyy");
        Add_Path ("Descending/Ccc");

        Tree_View.Set_Sort_Order (TI.No_Sort);
        TI.Close (Tree_View.Add ("Long Line"));
        Add_Path ("Long Line/The quick brown fox jumped over the lazy dog. 0123456789");
        TI.Close (Tree_View.Add ("Long Line/Longer Line"));
        Add_Path ("Long Line/Longer Line/The quick brown fox jumped over the lazy dog. " &
            "---------------- 0123456789");

        for T in 1 .. 500 loop
            Add_Path ("500 Items/item " & Pad4 (T));
        end loop;
        Tree_View.Close ("500 Items");

        Assign_User_Icons;
        Tree_View.Redraw;
    end Rebuild_Tree;

    --  Fonts, sizes, colours and activation for the selected items, or
    --  for all of them if none is selected.

    type Item_Change is access procedure (Item : in TI.Tree_Item);

    procedure For_Selected_Or_All
           (Change : in Item_Change)
    is
        Item  : TI.Tree_Item := Tree_View.First;
        Count : Natural := 0;
    begin
        while not TI.Is_Null (Item) loop
            if TI.Is_Selected (Item) then
                Change (Item);
                Count := Count + 1;
            end if;
            Item := TI.Next (Item);
        end loop;
        if Count = 0 then
            Item := Tree_View.First;
            while not TI.Is_Null (Item) loop
                Change (Item);
                Item := TI.Next (Item);
            end loop;
        end if;
    end For_Selected_Or_All;

    New_Font  : FLTK.Font_Kind := FLTK.Helvetica;
    New_Size  : FLTK.Font_Size := 14;
    New_Color : FLTK.Color := FLTK.Foreground_Color;

    procedure Change_Font (Item : in TI.Tree_Item) is
    begin
        TI.Set_Label_Font (Item, New_Font);
    end Change_Font;

    procedure Change_Size (Item : in TI.Tree_Item) is
    begin
        TI.Set_Label_Size (Item, New_Size);
    end Change_Size;

    procedure Change_FG (Item : in TI.Tree_Item) is
    begin
        TI.Set_Label_FG_Color (Item, New_Color);
    end Change_FG;

    procedure Change_BG (Item : in TI.Tree_Item) is
    begin
        TI.Set_Label_BG_Color (Item, New_Color);
    end Change_BG;

    procedure Activate_Item (Item : in TI.Tree_Item) is
    begin
        TI.Activate (Item);
    end Activate_Item;

    procedure Deactivate_Item (Item : in TI.Tree_Item) is
    begin
        TI.Deactivate (Item);
    end Deactivate_Item;

    function Slider_Int
           (S : in VS.Horizontal_Value_Slider)
        return Integer is
    begin
        return Integer (Long_Float'Truncation (S.Get_Value));
    end Slider_Int;

    function Chosen
           (C : in Ch.Choice)
        return Integer is
    begin
        return C.Chosen_Index - 1;   --  FLTK's 0-based value()
    end Chosen;




    --  Callbacks  --

    procedure Button_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Height : Integer;
    begin
        if Item.Get_Label = "ccc button" then
            Height := Item.Get_H + 10;
            if Height > 50 then
                Height := 20;
            end if;
            Item.Resize (Item.Get_X, Item.Get_Y, Item.Get_W, Height);
        else
            Height := Item.Parent.Get_H + 10;
            if Height > 50 then
                Height := 20;
            end if;
            Item.Parent.Resize (Item.Parent.Get_X, Item.Parent.Get_Y, Item.Parent.Get_W, Height);
        end if;
        Tree_View.Redraw;
        Say ("'" & Item.Get_Label & "' button pushed (height=" & Img (Height) & ")" & LF);
    end Button_CB;

    procedure Tree_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        It      : TI.Tree_Item;
        Changed : Character;
    begin
        CB_Counter := CB_Counter + 1;
        It := Tree_View.Callback_Item;
        Changed := (if Tree_View.Has_Changed then '1' else '0');
        if not TI.Is_Null (It) then
            Say ("TREE CALLBACK: label='" & TI.Get_Label (It) & "' userdata=1234 reason=" &
                Reason_Name (Tree_View.Callback_Reason) & ", changed=" & Changed);
            --  Get_Clicks is Fl::event_clicks () + 1, as tree.cxx prints it.
            if Ev.Is_Multi_Click then
                Say (", clicks=" & Img (Ev.Get_Clicks) & LF);
            else
                Say ((1 => LF));
            end if;
        else
            Say ("TREE CALLBACK: reason=" & Reason_Name (Tree_View.Callback_Reason) &
                ", changed=" & Changed &
                ", item=(no item -- probably multiple items were changed at once)" & LF);
        end if;
        Tree_View.Clear_Changed;
    end Tree_CB;

    procedure Margintop_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Margin_Top (Slider_Int (Margintop_Slider));
        Tree_View.Redraw;
    end Margintop_CB;

    procedure Marginleft_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Margin_Left (Slider_Int (Marginleft_Slider));
        Tree_View.Redraw;
    end Marginleft_CB;

    procedure Marginbottom_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Margin_Bottom (Slider_Int (Marginbottom_Slider));
        Tree_View.Redraw;
    end Marginbottom_CB;

    procedure Linespacing_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Line_Spacing (Slider_Int (Linespacing_Slider));
        Tree_View.Redraw;
    end Linespacing_CB;

    procedure Usericonmarginleft_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_User_Icon_Margin_Left (Slider_Int (Usericonmarginleft_Slider));
        Tree_View.Redraw;
    end Usericonmarginleft_CB;

    procedure Labelmarginleft_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Label_Margin_Left (Slider_Int (Labelmarginleft_Slider));
        Tree_View.Redraw;
    end Labelmarginleft_CB;

    procedure Widgetmarginleft_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Widget_Margin_Left (Slider_Int (Widgetmarginleft_Slider));
        Tree_View.Redraw;
    end Widgetmarginleft_CB;

    procedure Openchild_Marginbottom_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Open_Child_Margin_Bottom (Slider_Int (Openchild_Marginbottom_Slider));
        Tree_View.Redraw;
    end Openchild_Marginbottom_CB;

    procedure Connectorwidth_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Connector_Width (Slider_Int (Connectorwidth_Slider));
    end Connectorwidth_CB;

    procedure Collapseicons_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        case Chosen (Collapseicons_Chooser) is
            when 0 =>
                Tree_View.Set_Show_Collapse (True);
                Tree_View.Clear_Open_Icon;
                Tree_View.Clear_Close_Icon;
            when 1 =>
                Tree_View.Set_Show_Collapse (True);
                Tree_View.Set_Open_Icon (Open_Pixmap);
                Tree_View.Set_Close_Icon (Close_Pixmap);
            when 2 =>
                Tree_View.Set_Show_Collapse (False);
            when others =>
                null;
        end case;
    end Collapseicons_CB;

    procedure Connectorstyle_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        case Chosen (Connectorstyle_Chooser) is
            when 0 => Tree_View.Set_Connector_Style (TI.No_Connector);
            when 1 => Tree_View.Set_Connector_Style (TI.Dotted_Connector);
            when 2 => Tree_View.Set_Connector_Style (TI.Solid_Connector);
            when others => null;
        end case;
    end Connectorstyle_CB;

    procedure Selectmode_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        case Chosen (Selectmode_Chooser) is
            when 0 => Tree_View.Set_Select_Mode (TI.No_Selection);
            when 1 => Tree_View.Set_Select_Mode (TI.Single_Selection);
            when 2 => Tree_View.Set_Select_Mode (TI.Multi_Selection);
            when 3 => Tree_View.Set_Select_Mode (TI.Single_Draggable_Selection);
            when others => Tree_View.Set_Select_Mode (TI.Single_Selection);
        end case;
    end Selectmode_CB;

    procedure Reselectmode_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        case Chosen (Reselectmode_Chooser) is
            when 0 => Tree_View.Set_Item_Reselect_Mode (TI.Selectable_Once);
            when 1 => Tree_View.Set_Item_Reselect_Mode (TI.Selectable_Always);
            when others => null;
        end case;
    end Reselectmode_CB;

    --  tree.cxx's menu says Changed, Released, Never, but its callback
    --  gives Release for the first and Changed for the second.
    procedure Whenmode_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        case Chosen (Whenmode_Chooser) is
            when 0 => Tree_View.Set_When (FLTK.When_Release);
            when 1 => Tree_View.Set_When (FLTK.When_Changed);
            when 2 => Tree_View.Set_When (FLTK.Call_Never);
            when others => Tree_View.Set_When (FLTK.When_Release);
        end case;
    end Whenmode_CB;

    procedure Usericon_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Assign_User_Icons;
    end Usericon_CB;

    procedure Showroot_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Show_Root (Showroot_Radio.Is_On);
    end Showroot_CB;

    procedure Visiblefocus_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Visible_Focus (Visiblefocus_Checkbox.Is_On);
    end Visiblefocus_CB;

    procedure Labelandwidget_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Mode : TI.Item_Draw_Mode := Tree_View.Get_Item_Draw_Mode;
    begin
        if Labelandwidget_Radio.Is_On then
            Mode := Mode + TI.Draw_Label_And_Widget;
        else
            Mode := Mode - TI.Draw_Label_And_Widget;
        end if;
        Tree_View.Set_Item_Draw_Mode (Mode);
        Tree_View.Redraw;
    end Labelandwidget_CB;

    procedure Itemheightfromwidget_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Mode : TI.Item_Draw_Mode := Tree_View.Get_Item_Draw_Mode;
    begin
        if Itemheightfromwidget_Radio.Is_On then
            Mode := Mode + TI.Draw_Height_From_Widget;
        else
            Mode := Mode - TI.Draw_Height_From_Widget;
        end if;
        Tree_View.Set_Item_Draw_Mode (Mode);
        Tree_View.Redraw;
    end Itemheightfromwidget_CB;

    procedure Globalvisiblefocus_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Ev.Set_Visible_Focus (Globalvisiblefocus_Checkbox.Is_On);
    end Globalvisiblefocus_CB;

    procedure Show_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Show_Item (Tree_View.Next_Selected (TI.No_Tree_Item));
    end Show_CB;

    procedure Top_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Show_Item_Top (Tree_View.Next_Selected (TI.No_Tree_Item));
    end Top_CB;

    procedure Mid_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Show_Item_Middle (Tree_View.Next_Selected (TI.No_Tree_Item));
    end Mid_CB;

    procedure Bot_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Show_Item_Bottom (Tree_View.Next_Selected (TI.No_Tree_Item));
    end Bot_CB;

    procedure Openall_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It : TI.Tree_Item := Tree_View.First;
    begin
        while not TI.Is_Null (It) loop
            if TI.Has_Children (It) then
                TI.Open (It);
            end if;
            It := TI.Next (It);
        end loop;
        Tree_View.Redraw;
    end Openall_CB;

    procedure Loaddb_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Name : constant String :=
            Asks.File_Chooser ("Select a Preferences style Database", "Preferences(*.prefs)", "");
    begin
        if Name = "" then
            return;
        end if;
        Tree_View.Clear;
        Tree_View.Load (Env.Forge.Root (Env.Forge.From_File (Name)));
        Tree_View.Redraw;
    end Loaddb_CB;

    procedure Insertabove_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It : TI.Tree_Item := Tree_View.First;
    begin
        while not TI.Is_Null (It) loop
            if TI.Is_Selected (It) then
                Ignore (Tree_View.Insert_Above (It, "AaaAaa"));
                Ignore (Tree_View.Insert_Above (It, "BbbBbb"));
                Ignore (Tree_View.Insert_Above (It, "CccCcc"));
            end if;
            It := TI.Next (It);
        end loop;
        Tree_View.Redraw;
    end Insertabove_CB;

    procedure Rebuildtree_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Rebuild_Tree;
    end Rebuildtree_CB;

    procedure Showpathname_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It : constant TI.Tree_Item := Tree_View.First_Selected;
    begin
        if TI.Is_Null (It) then
            Asks.Message_Box ("No item was selected");
            return;
        end if;
        Asks.Message_Box ("Pathname for '" & TI.Get_Label (It) & "' is: """ &
            Tree_View.Item_Pathname (It) & """");
    end Showpathname_CB;

    procedure Closeall_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It : TI.Tree_Item := Tree_View.First;
    begin
        while not TI.Is_Null (It) loop
            if not TI.Is_Root (It) and TI.Has_Children (It) then
                TI.Close (It);
            end if;
            It := TI.Next (It);
        end loop;
        Tree_View.Redraw;
    end Closeall_CB;

    procedure Clearall_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Clear;
        Tree_View.Redraw;
    end Clearall_CB;

    procedure Testcallbackflag_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Root : constant TI.Tree_Item := Tree_View.Root;

        procedure Check
               (Message : in String) is
        begin
            if CB_Counter = 0 then
                Asks.Alert (Message);
            end if;
        end Check;

        procedure Fail_If_Called
               (Message : in String) is
        begin
            if CB_Counter /= 0 then
                Asks.Alert (Message);
            end if;
        end Fail_If_Called;
    begin
        Say ("--- Checking docallback off" & LF);
        if TI.Is_Null (Root) then
            return;
        end if;

        --  "OFF" test
        CB_Counter := 0;
        Tree_View.Close (Root, Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " close(item) triggered cb!");
        CB_Counter := 0;
        Tree_View.Open (Root, Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " open(item) triggered cb!");
        CB_Counter := 0;
        Tree_View.Open_Toggle (Root, Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " open_toggle(item) triggered cb!");
        CB_Counter := 0;
        Tree_View.Open ("ROOT", Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " open(path) triggered cb!");
        CB_Counter := 0;
        Tree_View.Close ("ROOT", Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " close(path) triggered cb!");
        Tree_View.Open (Root, Do_Callback => False);   --  leave root open
        CB_Counter := 0;
        Tree_View.Select_Item (Root, Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " select(item) triggered cb!");
        CB_Counter := 0;
        Tree_View.Deselect (Root, Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " deselect(item) triggered cb!");
        CB_Counter := 0;
        Tree_View.Select_Toggle (Root, Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " select_toggle(item) triggered cb!");
        CB_Counter := 0;
        Tree_View.Deselect ("ROOT", Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " deselect(path) triggered cb!");
        CB_Counter := 0;
        Tree_View.Select_Item ("ROOT", Do_Callback => False);
        Fail_If_Called ("FAILED 'OFF' TEST" & LF & " select(path) triggered cb!");
        Tree_View.Deselect ("ROOT");   --  leave deselected

        --  "ON" test
        CB_Counter := 0;
        Tree_View.Close (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " close(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Open (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " open(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Open_Toggle (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " open_toggle(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Open (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " open(item)[2] cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Close (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " close(item)[2] cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Open ("ROOT", Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " open(path) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Close ("ROOT", Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " close(path) cb wasn't triggered!");
        Tree_View.Open (Root, Do_Callback => False);   --  leave root open
        CB_Counter := 0;
        Tree_View.Select_Item (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " select(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Deselect (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " deselect(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Select_Toggle (Root, Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " select_toggle(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Deselect ("ROOT", Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " deselect(path) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Select_Item ("ROOT", Do_Callback => True);
        Check ("FAILED 'ON' TEST" & LF & " select(path) cb wasn't triggered!");
        Tree_View.Deselect ("ROOT");   --  leave deselected

        --  "DEFAULT" test
        CB_Counter := 0;
        Tree_View.Close (Root);
        Check ("FAILED 'DEFAULT' TEST: close(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Open (Root);
        Check ("FAILED 'DEFAULT' TEST: open(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Open_Toggle (Root);
        Check ("FAILED 'DEFAULT' TEST: open_toggle(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Open ("ROOT");
        Check ("FAILED 'DEFAULT' TEST: open(path) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Close ("ROOT");
        Check ("FAILED 'DEFAULT' TEST: close(path) cb wasn't triggered!");
        Tree_View.Open (Root, Do_Callback => False);   --  leave root open
        CB_Counter := 0;
        Tree_View.Select_Item (Root);
        Check ("FAILED 'DEFAULT' TEST" & LF & " select(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Deselect (Root);
        Check ("FAILED 'DEFAULT' TEST" & LF & " deselect(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Select_Toggle (Root);
        Check ("FAILED 'DEFAULT' TEST" & LF & " select_toggle(item) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Deselect ("ROOT");
        Check ("FAILED 'DEFAULT' TEST" & LF & " deselect(path) cb wasn't triggered!");
        CB_Counter := 0;
        Tree_View.Select_Item ("ROOT");
        Check ("FAILED 'DEFAULT' TEST" & LF & " select(path) cb wasn't triggered!");
        Tree_View.Deselect ("ROOT");   --  leave deselected

        Asks.Alert ("TEST COMPLETED" & LF & " If you didn't see any error dialogs, test PASSED.");
    end Testcallbackflag_CB;

    procedure Testrootshowself_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Say ("--- Show Tree" & LF);
        if not TI.Is_Null (Tree_View.Root) then
            TI.Show_Self (Tree_View.Root);
        end if;
    end Testrootshowself_CB;

    procedure Add20k_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It       : TI.Tree_Item := Tree_View.First;
        Parent   : TI.Tree_Item;
    begin
        while not TI.Is_Null (It) loop
            if TI.Is_Selected (It) then
                Parent := TI.Parent (It);
                if TI.Is_Null (Parent) then
                    Parent := Tree_View.Root;
                end if;
                for I in 0 .. 19_999 loop
                    Ignore (Tree_View.Add (Parent, "Item #" & Img (Item_Id + I)));
                end loop;
                Item_Id := Item_Id + 20_000;
                exit;
            end if;
            It := TI.Next (It);
        end loop;
        Tree_View.Redraw;
    end Add20k_CB;

    procedure Selected_Labelfont_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if TI.Is_Null (Tree_View.First) then
            return;
        end if;
        New_Font := FLTK.Font_Kind (Chosen (Selected_Labelfont_Choice));
        For_Selected_Or_All (Change_Font'Access);
        Tree_View.Redraw;
    end Selected_Labelfont_CB;

    procedure Selected_Labelsize_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        New_Size := FLTK.Font_Size (Slider_Int (Selected_Labelsize_Slider));
        For_Selected_Or_All (Change_Size'Access);
        Tree_View.Redraw;
    end Selected_Labelsize_CB;

    procedure All_Labelfgcolor_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        New_Color := Get_Selected_Item_FG_Color;
        if not Edit_Color (New_Color) then
            return;
        end if;
        All_Labelfgcolor_Button.Set_Background_Color (New_Color);
        For_Selected_Or_All (Change_FG'Access);
        Tree_View.Redraw;
    end All_Labelfgcolor_CB;

    procedure All_Labelbgcolor_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        New_Color := Get_Selected_Item_BG_Color;
        if not Edit_Color (New_Color) then
            return;
        end if;
        All_Labelbgcolor_Button.Set_Background_Color (New_Color);
        For_Selected_Or_All (Change_BG'Access);
        Tree_View.Redraw;
    end All_Labelbgcolor_CB;

    procedure Deactivate_Items_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Deactivate_Items_Toggle.Is_On then
            For_Selected_Or_All (Deactivate_Item'Access);
        else
            For_Selected_Or_All (Activate_Item'Access);
        end if;
        Tree_View.Redraw;
    end Deactivate_Items_CB;

    procedure Deactivate_Tree_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Deactivate_Tree_Toggle.Is_On then
            Tree_View.Deactivate;
        else
            Tree_View.Activate;
        end if;
    end Deactivate_Tree_CB;

    procedure Bold_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        New_Font := (if Bold_Toggle.Is_On then FLTK.Helvetica_Bold else FLTK.Helvetica);
        For_Selected_Or_All (Change_Font'Access);
        Tree_View.Redraw;
    end Bold_CB;

    procedure Showselected_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It : TI.Tree_Item := Tree_View.First_Selected;
    begin
        Say ("--- SELECTED ITEMS" & LF);
        while not TI.Is_Null (It) loop
            Say (HT & TI.Get_Label (It) & LF);
            It := Tree_View.Next_Selected (It);
        end loop;
    end Showselected_CB;

    procedure Clearselected_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It : TI.Tree_Item := Tree_View.First;
    begin
        while not TI.Is_Null (It) loop
            if TI.Is_Selected (It) then
                Tree_View.Remove (It);
                It := Tree_View.First;
            else
                It := TI.Next (It);
            end if;
        end loop;
        Tree_View.Redraw;
    end Clearselected_CB;

    procedure Swapselected_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It   : TI.Tree_Item := Tree_View.First;
        A, B : TI.Tree_Item;
    begin
        while not TI.Is_Null (It) loop
            if TI.Is_Selected (It) then
                if TI.Is_Null (A) then
                    A := It;
                elsif TI.Is_Null (B) then
                    B := It;
                else
                    Asks.Alert ("Too many items selected. (must select only two)");
                    return;
                end if;
            end if;
            It := TI.Next (It);
        end loop;
        if TI.Is_Null (A) or TI.Is_Null (B) then
            Asks.Alert ("Too few items selected. (you must select two)");
            return;
        end if;
        if TI.Parent (A) /= TI.Parent (B) then
            Asks.Alert ("The two selected items must be siblings");
            return;
        end if;
        if TI.Swap_Children (TI.Parent (A), A, B) then
            null;
        end if;
        Tree_View.Redraw;
    end Swapselected_CB;

    procedure Selectall_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Count : constant Natural := Tree_View.Select_All;
        pragma Unreferenced (Count);
    begin
        Tree_View.Redraw;
    end Selectall_CB;

    procedure Deselectall_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Count : constant Natural := Tree_View.Deselect_All;
        pragma Unreferenced (Count);
    begin
        Tree_View.Redraw;
    end Deselectall_CB;

    procedure Nextselected_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        It : TI.Tree_Item := Tree_View.First_Selected;
    begin
        Say ("--- TEST next_selected():" & LF);
        Say ("    // Walk down the tree (forwards)" & LF);
        while not TI.Is_Null (It) loop
            Say ("    Selected item: " & TI.Get_Label (It) & LF);
            It := Tree_View.Next_Selected (It);
        end loop;
        Say ("    // Walk up the tree (backwards)" & LF);
        It := Tree_View.Last_Selected;
        while not TI.Is_Null (It) loop
            Say ("    Selected item: " & TI.Get_Label (It) & LF);
            It := Tree_View.Prev_Selected (It);
        end loop;
    end Nextselected_CB;

    procedure Bbbselect_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Bbb : constant TI.Tree_Item := Tree_View.Find ("/Bbb");
    begin
        if TI.Is_Null (Bbb) then
            Asks.Alert ("FAIL: Couldn't find item '/Bbb'???");
            return;
        end if;
        if Bbbselect_Toggle.Is_On then
            Tree_View.Select_Item (Bbb);
        else
            Tree_View.Deselect (Bbb);
        end if;
    end Bbbselect_CB;

    procedure Bbbselect2_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Bbb : constant TI.Tree_Item := Tree_View.Find ("/Bbb");
    begin
        if TI.Is_Null (Bbb) then
            Asks.Alert ("FAIL: Couldn't find item '/Bbb'???");
            return;
        end if;
        if Bbbselect2_Toggle.Is_On then
            Ignore (Tree_View.Select_All (Bbb));
        else
            Ignore (Tree_View.Deselect_All (Bbb));
        end if;
    end Bbbselect2_CB;

    procedure Bbbchild02select_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Path  : constant String := "/Bbb/child-02";
        Child : constant TI.Tree_Item := Tree_View.Find (Path);
    begin
        if TI.Is_Null (Child) then
            Asks.Alert ("FAIL: Couldn't find item '" & Path & "'");
            return;
        end if;
        if Bbbchild02select_Toggle.Is_On then
            Tree_View.Select_Item (Child);
        else
            Tree_View.Deselect (Child);
        end if;
    end Bbbchild02select_CB;

    procedure Rootselect_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Root : constant TI.Tree_Item := Tree_View.Find ("/ROOT");
    begin
        if TI.Is_Null (Root) then
            Asks.Alert ("FAIL: Couldn't find item '/ROOT'???");
            return;
        end if;
        if Rootselect_Toggle.Is_On then
            Tree_View.Select_Item (Root);
        else
            Tree_View.Deselect (Root);
        end if;
    end Rootselect_CB;

    procedure Rootselect2_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Root : constant TI.Tree_Item := Tree_View.Find ("/ROOT");
    begin
        if TI.Is_Null (Root) then
            Asks.Alert ("FAIL: Couldn't find item '/ROOT'???");
            return;
        end if;
        if Rootselect2_Toggle.Is_On then
            Ignore (Tree_View.Select_All (Root));
        else
            Ignore (Tree_View.Deselect_All (Root));
        end if;
    end Rootselect2_CB;

    procedure Labelfont_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Label_Font (FLTK.Font_Kind (Chosen (Labelfont_Choice)));
        Window.Redraw;
    end Labelfont_CB;

    procedure Labelsize_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Label_Size (FLTK.Font_Size (Slider_Int (Labelsize_Slider)));
        Window.Redraw;
    end Labelsize_CB;

    procedure Item_Labelfont_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Item_Label_Font (FLTK.Font_Kind (Chosen (Item_Labelfont_Choice)));
        Tree_View.Redraw;
    end Item_Labelfont_CB;

    procedure Item_Labelsize_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Item_Label_Size (FLTK.Font_Size (Slider_Int (Item_Labelsize_Slider)));
        Tree_View.Redraw;
    end Item_Labelsize_CB;

    procedure Labelcolor_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Hue : FLTK.Color := Tree_View.Get_Label_Color;
    begin
        if not Edit_Color (Hue) then
            return;
        end if;
        Labelcolor_Button.Set_Background_Color (Hue);
        Tree_View.Set_Label_Color (Hue);
        Window.Redraw;
    end Labelcolor_CB;

    procedure Color_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Hue : FLTK.Color := Tree_View.Get_Background_Color;
    begin
        if not Edit_Color (Hue) then
            return;
        end if;
        Color_Button.Set_Background_Color (Hue);
        Tree_View.Set_Background_Color (Hue);
        Update_Color_Chips;
        Tree_View.Redraw;
    end Color_CB;

    procedure Selection_Color_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Hue : FLTK.Color := Tree_View.Get_Selection_Color;
    begin
        if not Edit_Color (Hue) then
            return;
        end if;
        Selection_Color_Button.Set_Background_Color (Hue);
        Tree_View.Set_Selection_Color (Hue);
        Tree_View.Redraw;
    end Selection_Color_CB;

    procedure Item_Labelfgcolor_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Hue : FLTK.Color := Tree_View.Get_Item_Label_Color;
    begin
        if not Edit_Color (Hue) then
            return;
        end if;
        Tree_View.Set_Item_Label_Color (Hue);
        Item_Labelfgcolor_Button.Set_Background_Color (Hue);
        Tree_View.Redraw;
    end Item_Labelfgcolor_CB;

    procedure Item_Labelbgcolor_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Hue : FLTK.Color := Tree_View.Get_Item_Label_BG_Color;
    begin
        if not Edit_Color (Hue) then
            return;
        end if;
        Tree_View.Set_Item_Label_BG_Color (Hue);
        Item_Labelbgcolor_Button.Set_Background_Color (Hue);
        Tree_View.Redraw;
    end Item_Labelbgcolor_CB;

    procedure X_Item_Labelbgcolor_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Item_Label_BG_Color (TI.Transparent_Background);
        Update_Color_Chips;
        Tree_View.Redraw;
    end X_Item_Labelbgcolor_CB;

    procedure Tree_Scrollbar_Size_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Tree_View.Set_Scrollbar_Size (Slider_Int (Tree_Scrollbar_Size_Slider));
        Tree_View.Redraw;
    end Tree_Scrollbar_Size_CB;

    procedure Scrollbar_Size_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Static.Set_Default_Scrollbar_Size (Slider_Int (Scrollbar_Size_Slider));
        Tree_View.Redraw;
    end Scrollbar_Size_CB;

    procedure Testsuggs_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if not Help_Filled then
            Help_Disp.Set_Buffer (Help_Buff);
            Help_Disp.Set_Text_Font (FLTK.Courier);
            Help_Disp.Set_Text_Size (12);
            Help_Buff.Set_Entire_Text (Help_Text);
            Help_Filled := True;
        end if;
        Help_Win.Set_Resizable (Help_Disp);
        Help_Win.Show;
    end Testsuggs_CB;




    --  Setting up  --

    procedure Setup_Group
           (G   : in out Grps.Group;
            Tip : in     String) is
    begin
        G.Set_Tooltip (Tip);
        G.Set_Box (FLTK.Gtk_Down_Box);
        G.Set_Background_Color (FLTK.Dark1_Color);
        G.Set_Label_Size (12);
    end Setup_Group;

    procedure Setup_Slider
           (S                     : in out VS.Horizontal_Value_Slider;
            Label_Size, Text_Size : in     FLTK.Font_Size;
            Tip                   : in     String;
            Func                  : in     FLTK.Widgets.Widget_Callback;
            Value, Low, High      : in     Long_Float;
            Red                   : in     Boolean) is
    begin
        S.Set_Tooltip (Tip);
        S.Set_Background_Color (46);
        S.Set_Selection_Color (1);
        S.Set_Label_Size (Label_Size);
        S.Set_Text_Size (Text_Size);
        S.Set_Callback (Func);
        S.Set_Alignment (FLTK.Align_Left);
        S.Set_Value (Value);
        S.Set_Range (Low, High);
        S.Set_Step (1);
        if Red then
            S.Set_Background_Color (46);
            S.Set_Selection_Color (FLTK.Red_Color);
        end if;
    end Setup_Slider;

    procedure Setup_Choice
           (C                     : in out Ch.Choice;
            Label_Size, Text_Size : in     FLTK.Font_Size;
            Tip                   : in     String;
            Func                  : in     FLTK.Widgets.Widget_Callback;
            Names                 : in     Name_List) is
    begin
        C.Set_Tooltip (Tip);
        C.Set_Down_Box (FLTK.Border_Box);
        C.Set_Label_Size (Label_Size);
        C.Set_Text_Size (Text_Size);
        if Func /= null then
            C.Set_Callback (Func);
        end if;
        for Name of Names loop
            declare
                Place : constant FLTK.Widgets.Menus.Index := C.Add (SU.To_String (Name));
            begin
                C.Item (Place).Data.Set_Label_Size (12);
            end;
        end loop;
    end Setup_Choice;

    procedure Setup_Check
           (B    : in out Chk.Check_Button;
            Tip  : in     String;
            Func : in     FLTK.Widgets.Widget_Callback;
            On   : in     Boolean) is
    begin
        B.Set_Tooltip (Tip);
        B.Set_Down_Box (FLTK.Down_Box);
        B.Set_Label_Size (11);
        B.Set_Callback (Func);
        B.Set_Alignment (FLTK.Align_Left_Top);
        B.Set_State (if On then Btn.On else Btn.Off);
    end Setup_Check;

    procedure Setup_Button
           (B          : in out Btn.Button;
            Label_Size : in     FLTK.Font_Size;
            Tip        : in     String;
            Func       : in     FLTK.Widgets.Widget_Callback) is
    begin
        B.Set_Tooltip (Tip);
        B.Set_Label_Size (Label_Size);
        B.Set_Callback (Func);
    end Setup_Button;

    procedure Setup_Light
           (B    : in out LBtn.Light_Button;
            Tip  : in     String;
            Func : in     FLTK.Widgets.Widget_Callback) is
    begin
        B.Set_Tooltip (Tip);
        B.Set_Selection_Color (1);
        B.Set_Label_Size (9);
        B.Set_Callback (Func);
    end Setup_Light;

    procedure Setup_Chip
           (B          : in out Btn.Button;
            Label_Size : in     FLTK.Font_Size;
            Tip        : in     String;
            Func       : in     FLTK.Widgets.Widget_Callback;
            Hue        : in     FLTK.Color) is
    begin
        B.Set_Tooltip (Tip);
        B.Set_Box (FLTK.Down_Box);
        B.Set_Label_Size (Label_Size);
        B.Set_Callback (Func);
        B.Set_Alignment (FLTK.Align_Left_Top);
        B.Set_Background_Color (Hue);
    end Setup_Chip;

    function Font_Place
           (Font : in FLTK.Font_Kind)
        return FLTK.Widgets.Menus.Index is
    begin
        return FLTK.Widgets.Menus.Index (Integer (Font) + 1);
    end Font_Place;

    Tip_Grp : constant String :=
        "A group of two buttons inside the tree." & LF &
        "If 'Item h() from widget' enabled, pressing either button enlarges the group " &
        "and both buttons together.";

begin
    Tree_View.Set_Tooltip (Tip_Tree);
    Tree_View.Set_Box (FLTK.Down_Box);
    Tree_View.Set_Background_Color (55);
    Tree_View.Set_Selection_Color (FLTK.Selection_Color);
    Tree_View.Set_Label_Font (0);
    Tree_View.Set_Label_Size (14);
    Tree_View.Set_Label_Color (FLTK.Foreground_Color);
    Tree_View.Set_Callback (Tree_CB'Unrestricted_Access);
    Tree_View.Set_Alignment (FLTK.Align_Top);
    Tree_View.Set_When (FLTK.When_Release);

    Setup_Group (Globals, Tip_Tree_Globals);
    Setup_Slider (Margintop_Slider, 10, 9, Tip_Margintop_Slider,
        Margintop_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Margin_Top), 0.0, 100.0, False);
    Setup_Slider (Marginleft_Slider, 10, 9, Tip_Marginleft_Slider,
        Marginleft_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Margin_Left), 0.0, 200.0, False);
    Setup_Slider (Marginbottom_Slider, 10, 9, Tip_Marginbottom_Slider,
        Marginbottom_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Margin_Bottom), 0.0, 275.0, False);
    Marginbottom_Slider.Do_Callback;
    Setup_Slider (Linespacing_Slider, 10, 9, Tip_Linespacing_Slider,
        Linespacing_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Line_Spacing), 0.0, 100.0, False);
    Setup_Slider (Usericonmarginleft_Slider, 10, 9, Tip_Usericonmarginleft_Slider,
        Usericonmarginleft_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_User_Icon_Margin_Left), 0.0, 100.0, False);
    Setup_Slider (Labelmarginleft_Slider, 10, 9, Tip_Labelmarginleft_Slider,
        Labelmarginleft_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Label_Margin_Left), 0.0, 100.0, False);
    Setup_Slider (Widgetmarginleft_Slider, 10, 9, Tip_Widgetmarginleft_Slider,
        Widgetmarginleft_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Widget_Margin_Left), 0.0, 100.0, False);
    Widgetmarginleft_Slider.Do_Callback;
    Setup_Slider (Openchild_Marginbottom_Slider, 10, 9, Tip_Openchild_Marginbottom_Slider,
        Openchild_Marginbottom_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Open_Child_Margin_Bottom), 0.0, 100.0, False);
    Setup_Slider (Connectorwidth_Slider, 11, 9, Tip_Connectorwidth_Slider,
        Connectorwidth_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Connector_Width), 1.0, 100.0, True);

    Setup_Choice (Collapseicons_Chooser, 12, 11, Tip_Collapseicons_Chooser,
        Collapseicons_CB'Unrestricted_Access, (+"Default", +"Custom", +"Off"));
    Collapseicons_Chooser.Set_Chosen (1);
    Setup_Choice (Connectorstyle_Chooser, 12, 11, Tip_Connectorstyle_Chooser,
        Connectorstyle_CB'Unrestricted_Access, (+"None", +"Dotted", +"Solid"));
    case Tree_View.Get_Connector_Style is
        when TI.No_Connector     => Connectorstyle_Chooser.Set_Chosen (1);
        when TI.Dotted_Connector => Connectorstyle_Chooser.Set_Chosen (2);
        when TI.Solid_Connector  => Connectorstyle_Chooser.Set_Chosen (3);
    end case;
    Setup_Choice (Selectmode_Chooser, 12, 11, Tip_Selectmode_Chooser,
        Selectmode_CB'Unrestricted_Access,
        (+"None", +"Single", +"Multi", +"Single + drag"));
    Selectmode_Chooser.Set_Chosen (3);
    Selectmode_CB (Selectmode_Chooser);
    Setup_Choice (Reselectmode_Chooser, 12, 11, Tip_Reselectmode_Chooser,
        Reselectmode_CB'Unrestricted_Access, (+"Selectable Once", +"Selectable Always"));
    Reselectmode_Chooser.Set_Chosen (2);
    Reselectmode_CB (Reselectmode_Chooser);
    Setup_Choice (Whenmode_Chooser, 12, 11, Tip_Whenmode_Chooser,
        Whenmode_CB'Unrestricted_Access, (+"Changed", +"Released", +"Never"));
    Whenmode_Chooser.Set_Chosen (2);
    Whenmode_CB (Whenmode_Chooser);

    Setup_Check (Usericon_Radio, Tip_Usericon_Radio,
        Usericon_CB'Unrestricted_Access, True);
    Setup_Check (Showroot_Radio, Tip_Showroot_Radio,
        Showroot_CB'Unrestricted_Access, Tree_View.Get_Show_Root);
    Setup_Check (Visiblefocus_Checkbox, Tip_Visiblefocus_Checkbox,
        Visiblefocus_CB'Unrestricted_Access, Tree_View.Has_Visible_Focus);
    Setup_Check (Labelandwidget_Radio, Tip_Labelandwidget_Radio,
        Labelandwidget_CB'Unrestricted_Access, False);
    Labelandwidget_Radio.Do_Callback;
    Setup_Check (Itemheightfromwidget_Radio, Tip_Itemheightfromwidget_Radio,
        Itemheightfromwidget_CB'Unrestricted_Access, False);
    Itemheightfromwidget_Radio.Do_Callback;
    Setup_Check (Globalvisiblefocus_Checkbox, Tip_Globalvisiblefocus_Checkbox,
        Globalvisiblefocus_CB'Unrestricted_Access, Ev.Has_Visible_Focus);

    Setup_Group (Operations, Tip_Test_Operations);
    Showitem_Box.Set_Tooltip (Tip_Show);
    Showitem_Box.Set_Box (FLTK.Gtk_Down_Box);
    Showitem_Box.Set_Label_Size (11);
    Setup_Button (Show_Button, 11, Tip_Show, Show_CB'Unrestricted_Access);
    Setup_Button (Top_Button, 11, Tip_Top, Top_CB'Unrestricted_Access);
    Setup_Button (Mid_Button, 11, Tip_Mid, Mid_CB'Unrestricted_Access);
    Setup_Button (Bot_Button, 11, Tip_Bot, Bot_CB'Unrestricted_Access);
    Setup_Button (Openall_Button, 9, Tip_Openall_Button, Openall_CB'Unrestricted_Access);
    Setup_Button (Loaddb_Button, 9, Tip_Loaddb_Button, Loaddb_CB'Unrestricted_Access);
    Setup_Button (Insertabove_Button, 9, Tip_Insertabove_Button,
        Insertabove_CB'Unrestricted_Access);
    Setup_Button (Rebuildtree_Button, 9, Tip_Rebuildtree_Button,
        Rebuildtree_CB'Unrestricted_Access);
    Setup_Button (Showpathname_Button, 9, Tip_Showpathname_Button,
        Showpathname_CB'Unrestricted_Access);
    Setup_Button (Closeall_Button, 9, Tip_Closeall_Button, Closeall_CB'Unrestricted_Access);
    Setup_Button (Clearall_Button, 9, Tip_Clearall_Button, Clearall_CB'Unrestricted_Access);
    Setup_Button (Testcallbackflag_Button, 9, Tip_Testcallbackflag_Button,
        Testcallbackflag_CB'Unrestricted_Access);
    Setup_Button (Testrootshowself_Button, 9, Tip_Testrootshowself_Button,
        Testrootshowself_CB'Unrestricted_Access);
    Setup_Button (Add20k_Button, 9, Tip_Add20k_Button, Add20k_CB'Unrestricted_Access);

    Setup_Group (Selected, Tip_Selected_Items);
    Setup_Choice (Selected_Labelfont_Choice, 11, 11, Tip_Selected_Labelfont_Choice,
        Selected_Labelfont_CB'Unrestricted_Access, Font_Names);
    Selected_Labelfont_Choice.Set_Chosen (Font_Place (Tree_View.Get_Item_Label_Font));
    Setup_Slider (Selected_Labelsize_Slider, 11, 12, Tip_Selected_Labelsize_Slider,
        Selected_Labelsize_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Item_Label_Size), 5.0, 200.0, True);
    Setup_Chip (All_Labelfgcolor_Button, 11, Tip_All_Labelfgcolor_Button,
        All_Labelfgcolor_CB'Unrestricted_Access, Get_Selected_Item_FG_Color);
    Setup_Chip (All_Labelbgcolor_Button, 11, Tip_All_Labelbgcolor_Button,
        All_Labelbgcolor_CB'Unrestricted_Access, Get_Selected_Item_BG_Color);
    Setup_Light (Deactivate_Items_Toggle, Tip_Deactivate_Items_Toggle,
        Deactivate_Items_CB'Unrestricted_Access);
    Setup_Light (Deactivate_Tree_Toggle, Tip_Deactivate_Tree_Toggle,
        Deactivate_Tree_CB'Unrestricted_Access);
    Setup_Light (Bold_Toggle, Tip_Bold_Toggle, Bold_CB'Unrestricted_Access);
    Setup_Button (Showselected_Button, 9, Tip_Showselected_Button,
        Showselected_CB'Unrestricted_Access);
    Setup_Button (Clearselected_Button, 9, Tip_Clearselected_Button,
        Clearselected_CB'Unrestricted_Access);
    Setup_Button (Swapselected_Button, 9, Tip_Swapselected_Button,
        Swapselected_CB'Unrestricted_Access);
    Setup_Button (Selectall_Button, 9, Tip_Selectall_Button, Selectall_CB'Unrestricted_Access);
    Setup_Button (Deselectall_Button, 9, Tip_Deselectall_Button,
        Deselectall_CB'Unrestricted_Access);
    Setup_Button (Nextselected_Button, 9, Tip_Nextselected_Button,
        Nextselected_CB'Unrestricted_Access);
    Setup_Light (Bbbselect_Toggle, Tip_Bbbselect_Toggle, Bbbselect_CB'Unrestricted_Access);
    Setup_Light (Bbbselect2_Toggle, Tip_Bbbselect2_Toggle, Bbbselect2_CB'Unrestricted_Access);
    Setup_Light (Bbbchild02select_Toggle, Tip_Bbbchild02select_Toggle,
        Bbbchild02select_CB'Unrestricted_Access);
    Setup_Light (Rootselect_Toggle, Tip_Rootselect_Toggle, Rootselect_CB'Unrestricted_Access);
    Setup_Light (Rootselect2_Toggle, Tip_Rootselect2_Toggle,
        Rootselect2_CB'Unrestricted_Access);

    Setup_Group (Fonts_Colors, Tip_Tree_Fonts_Colors);
    Setup_Choice (Labelfont_Choice, 12, 12, Tip_Labelfont_Choice,
        Labelfont_CB'Unrestricted_Access, Font_Names);
    Labelfont_Choice.Set_Chosen (Font_Place (Tree_View.Get_Label_Font));
    Setup_Slider (Labelsize_Slider, 12, 12, Tip_Labelsize_Slider,
        Labelsize_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Label_Size), 1.0, 50.0, True);
    Setup_Choice (Item_Labelfont_Choice, 12, 12, Tip_Item_Labelfont_Choice,
        Item_Labelfont_CB'Unrestricted_Access, Font_Names);
    Item_Labelfont_Choice.Set_Chosen (Font_Place (Tree_View.Get_Item_Label_Font));
    Setup_Slider (Item_Labelsize_Slider, 12, 12, Tip_Item_Labelsize_Slider,
        Item_Labelsize_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Item_Label_Size), 1.0, 50.0, True);
    Setup_Chip (Labelcolor_Button, 11, Tip_Labelcolor_Button,
        Labelcolor_CB'Unrestricted_Access, Tree_View.Get_Label_Color);
    Setup_Chip (Color_Button, 11, Tip_Color_Button,
        Color_CB'Unrestricted_Access, Tree_View.Get_Background_Color);
    Setup_Chip (Selection_Color_Button, 11, Tip_Selection_Color_Button,
        Selection_Color_CB'Unrestricted_Access, Tree_View.Get_Selection_Color);
    Setup_Chip (Item_Labelfgcolor_Button, 12, Tip_Item_Labelfgcolor_Button,
        Item_Labelfgcolor_CB'Unrestricted_Access, Tree_View.Get_Item_Label_Color);
    Setup_Chip (Item_Labelbgcolor_Button, 12, Tip_Item_Labelbgcolor_Button,
        Item_Labelbgcolor_CB'Unrestricted_Access, Tree_View.Get_Item_Label_BG_Color);
    X_Item_Labelbgcolor_Button.Set_Tooltip (Tip_X_Item_Labelbgcolor_Button);
    X_Item_Labelbgcolor_Button.Set_Label_Size (10);
    X_Item_Labelbgcolor_Button.Set_Callback (X_Item_Labelbgcolor_CB'Unrestricted_Access);
    X_Item_Labelbgcolor_Button.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);

    Setup_Slider (Tree_Scrollbar_Size_Slider, 11, 9, Tip_Tree_Scrollbar_Size_Slider,
        Tree_Scrollbar_Size_CB'Unrestricted_Access,
        Long_Float (Tree_View.Get_Scrollbar_Size), 0.0, 30.0, True);
    Setup_Slider (Scrollbar_Size_Slider, 11, 9, Tip_Scrollbar_Size_Slider,
        Scrollbar_Size_CB'Unrestricted_Access,
        Long_Float (Static.Get_Default_Scrollbar_Size), 5.0, 30.0, True);
    Setup_Button (Testsuggs_Button, 9, Tip_Testsuggs_Button, Testsuggs_CB'Unrestricted_Access);
    Outer.Clear_Resizable;

    --  The widgets in the tree
    In_W.Set_Label_Size (10);
    In_W.Set_Text_Size (10);
    In_W.Set_Alignment (FLTK.Align_Right);
    In_W.Set_Tooltip ("Fl_Input inside tree." & LF &
        "The widget's label 'Fl_Input test' should appear to the widget's right.");
    But.Set_Label_Size (10);
    But.Set_Callback (Button_CB'Unrestricted_Access);
    But.Set_Tooltip ("Button inside tree." & LF &
        "If 'Item h() from widget' enabled, pressing button enlarges it.");
    Grp.Set_Background_Color (FLTK.White_Color);
    D1.Set_Label_Size (10);
    D1.Set_Callback (Button_CB'Unrestricted_Access);
    D1.Set_Tooltip (Tip_Grp);
    D2.Set_Label_Size (10);
    D2.Set_Callback (Button_CB'Unrestricted_Access);
    D2.Set_Tooltip (Tip_Grp);
    Grp.Set_Resizable (Grp);

    Tree_View.Set_Root_Label ("ROOT");
    Rebuild_Tree;

    Tips.Set_Text_Size (10);

    Window.Set_Resizable (Tree_View);
    Window.Set_Size_Range (Window.Get_W, Window.Get_H);

    if Tree_View.Get_When = FLTK.When_Changed then
        Whenmode_Chooser.Set_Chosen (1);
    elsif Tree_View.Get_When = FLTK.When_Release then
        Whenmode_Chooser.Set_Chosen (2);
    elsif Tree_View.Get_When = FLTK.Call_Never then
        Whenmode_Chooser.Set_Chosen (3);
    end if;

    Window.Show_With_Args;
    return FLTK.Run;
end Tree;
