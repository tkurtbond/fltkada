

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-menu-with-images.cxx: how to use
--  Multi_Label to make menu items with images and labels.
--
--  The original passes each item's name to a single callback as user data;
--  here a generic callback is instantiated once per name instead.  The
--  original also has to free the label that Add duplicated before giving
--  an item an image, to avoid a leak; Set_Image and Set_Multi_Label take
--  care of that here.


with

    Ada.Strings.Unbounded,
    FLTK.Asks,
    FLTK.Images.Pixmaps,
    FLTK.Menu_Items,
    FLTK.Multi_Labels,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Bars,
    FLTK.Widgets.Menus.Menu_Buttons;

use type

    FLTK.Alignment,
    FLTK.Modifier;


function Howto_Menu_With_Images
    return Integer
is


    package SU  renames Ada.Strings.Unbounded;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;

    package Pix renames FLTK.Images.Pixmaps;
    package ML  renames FLTK.Multi_Labels;
    package Bx  renames FLTK.Widgets.Boxes;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package Mnu renames FLTK.Widgets.Menus;
    package Ch  renames FLTK.Widgets.Menus.Choices;
    package MB  renames FLTK.Widgets.Menus.Menu_Bars;
    package MBt renames FLTK.Widgets.Menus.Menu_Buttons;

    --  Document icon
    Document_Header : constant Pix.Header := (13, 11, 3, 1);
    Document_Colors : constant Pix.Color_Definition_Array :=
       ((+" ", Pix.Colorful, +"None"),
        (+"x", Pix.Colorful, +"#d8d8f8"),
        (+"@", Pix.Colorful, +"#202060"));
    Document_Pixels : constant Pix.Pixmap_Data :=
       (" @@@@@@@@@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @xxxxxxx@   ",
        " @@@@@@@@@   ");
    Document_Pixmap : aliased Pix.Pixmap :=
        Pix.Forge.Create (Document_Header, Document_Colors, Document_Pixels);

    --  Folder icon
    Folder_Header : constant Pix.Header := (13, 11, 3, 1);
    Folder_Colors : constant Pix.Color_Definition_Array :=
       ((+" ", Pix.Colorful, +"None"),
        (+"x", Pix.Colorful, +"#d8d833"),
        (+"@", Pix.Colorful, +"#808011"));
    Folder_Pixels : constant Pix.Pixmap_Data :=
       ("             ",
        "     @@@@    ",
        "    @xxxx@   ",
        "@@@@@xxxx@@  ",
        "@xxxxxxxxx@  ",
        "@xxxxxxxxx@  ",
        "@xxxxxxxxx@  ",
        "@xxxxxxxxx@  ",
        "@xxxxxxxxx@  ",
        "@xxxxxxxxx@  ",
        "@@@@@@@@@@@  ");
    Folder_Pixmap : aliased Pix.Pixmap :=
        Pix.Forge.Create (Folder_Header, Folder_Colors, Folder_Pixels);

    --  Red "X"
    Redx_Header : constant Pix.Header := (13, 11, 5, 1);
    Redx_Colors : constant Pix.Color_Definition_Array :=
       ((+" ", Pix.Colorful, +"None"),
        (+"+", Pix.Colorful, +"#222222"),
        (+"x", Pix.Colorful, +"#555555"),
        (+"-", Pix.Colorful, +"#882222"),
        (+"@", Pix.Colorful, +"#ffffff"));
    Redx_Pixels : constant Pix.Pixmap_Data :=
       ("   x+++x     ",
        "  ++---++    ",
        " ++-----++   ",
        "++-@@-@@-++  ",
        "++--@@@--++  ",
        "++---@---++  ",
        "++--@@@--++  ",
        "++-@@-@@-++  ",
        " ++-----++   ",
        "  ++---++    ",
        "   x+++x     ");
    Redx_Pixmap : aliased Pix.Pixmap :=
        Pix.Forge.Create (Redx_Header, Redx_Colors, Redx_Pixels);


    --  Handle the different menu items..
    generic
        Item_Name : String;   --  "New", "Open", etc
    procedure Menu_CB
           (Item : in out FLTK.Widgets.Widget'Class);

    procedure Menu_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if Item_Name = "Quit" then   --  handle Quit
            Item.Nearest_Window.Hide;
        else                         --  just show a message for other items
            FLTK.Asks.Message_Box ("'" & Item_Name & "' would happen here");
        end if;
    end Menu_CB;

    procedure New_CB   is new Menu_CB ("New");
    procedure Open_CB  is new Menu_CB ("Open");
    procedure Quit_CB  is new Menu_CB ("Quit");
    procedure Copy_CB  is new Menu_CB ("Copy");
    procedure Paste_CB is new Menu_CB ("Paste");
    procedure One_CB   is new Menu_CB ("One");
    procedure Two_CB   is new Menu_CB ("Two");
    procedure Three_CB is new Menu_CB ("Three");


    type Multi_Label_Access is access ML.Multi_Label;


    --  Add an image in front of item's text
    function Add_Item_To_Menu
           (Menu       : in out Mnu.Menu'Class;            --  menu to add item to
            Label_Text : in     String;                   --  label text
            Shortcut   : in     FLTK.Key_Combo;           --  shortcut (e.g. Mod_Command + 'a')
            Action     : in     FLTK.Widgets.Widget_Callback;   --  callback to invoke
            Pixmap     : access Pix.Pixmap;              --  image (if any) to add to item
            Flags      : in     FLTK.Menu_Flag := FLTK.Flag_Normal)   --  menu flags
        return Mnu.Index
    is
        --  Add a new menu item
        I : constant Mnu.Index := Menu.Add (Label_Text, Action, Shortcut, Flags);
    begin
        if Pixmap = null then
            return I;
        end if;
        declare
            Item : constant FLTK.Menu_Items.Menu_Item_Reference := Menu.Item (I);

            --  Create a multi label, assign it an image + text.  Like the
            --  item, it is never freed.
            Label : constant Multi_Label_Access := new ML.Multi_Label'(ML.Forge.Create);
        begin
            --  Left side of label is image
            Label.Set_First (Pixmap.all);

            --  Right side of label is text
            Label.Set_Second (Item.Get_Label);

            --  Assign multilabel to item.
            Item.Set_Multi_Label (Label.all);
        end;
        return I;
    end Add_Item_To_Menu;


    --  Add a menu item with just an image (no label).
    --  This shows why you need Multi_Label; the item's label gets clobbered
    --  by Set_Image.
    procedure Add_Image_Item
           (Menu   : in out Mnu.Menu'Class;
            Text   : in     String;
            Action : in     FLTK.Widgets.Widget_Callback;
            Pixmap : in out Pix.Pixmap)
    is
        I : constant Mnu.Index := Menu.Add (Text, Action);
    begin
        Menu.Item (I).Set_Image (Pixmap);
    end Add_Image_Item;


    --  Create Menu Items
    --    This same technique works for Menu derived widgets,
    --    e.g. Menu_Bar, Menu_Button, Choice..
    --
    procedure Create_Menu_Items
           (Menu : in out Mnu.Menu'Class)
    is
        Ignore : Mnu.Index;
    begin
        --  Add items with LABELS AND IMAGES using Multi_Label..
        Ignore := Add_Item_To_Menu
           (Menu, "File/New",  FLTK.Mod_Command + 'n', New_CB'Unrestricted_Access,
            Document_Pixmap'Access);
        Ignore := Add_Item_To_Menu
           (Menu, "File/Open", FLTK.Mod_Command + 'o', Open_CB'Unrestricted_Access,
            Folder_Pixmap'Access, FLTK.Flag_Divider);
        Ignore := Add_Item_To_Menu
           (Menu, "File/Quit", FLTK.Mod_Command + 'q', Quit_CB'Unrestricted_Access,
            Redx_Pixmap'Access);

        --  Create menu bar items with JUST LABELS
        Menu.Add ("Edit/Copy",  Copy_CB'Unrestricted_Access,  FLTK.Mod_Command + 'c');
        Menu.Add ("Edit/Paste", Paste_CB'Unrestricted_Access, FLTK.Mod_Command + 'v');

        --  Create menu bar items with JUST IMAGES (no labels)
        Add_Image_Item (Menu, "Images/One",   One_CB'Unrestricted_Access,   Document_Pixmap);
        Add_Image_Item (Menu, "Images/Two",   Two_CB'Unrestricted_Access,   Folder_Pixmap);
        Add_Image_Item (Menu, "Images/Three", Three_CB'Unrestricted_Access, Redx_Pixmap);
    end Create_Menu_Items;


    Help : constant String := "Right click on window background" & ASCII.LF & "for popup menu";

    Win : DW.Double_Window := DW.Forge.Create (400, 400, "Menu items with images");

    --  Help message
    Box : Bx.Box := Bx.Forge.Create (Win, 100, 100, 200, 200, Help);

    --  Menu bar
    Menu_Bar : MB.Menu_Bar := MB.Forge.Create (Win, 0, 0, Win.Get_W, 25);

    --  Right click context menu
    Menu_Butt : MBt.Menu_Button := MBt.Forge.Create (Win, 0, 25, Win.Get_W, Win.Get_H - 25);

    --  Chooser menu
    Choice : Ch.Choice := Ch.Forge.Create (Win, 140, 50, 200, 25, "Choice");


begin


    Win.Set_Tooltip (Help);
    Box.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);

    Create_Menu_Items (Menu_Bar);

    Create_Menu_Items (Menu_Butt);
    Menu_Butt.Set_Popup_Kind (MBt.Popup3);

    Create_Menu_Items (Choice);
    Choice.Set_Chosen (2);

    --  TODO: Show complex labels with Multi_Label. From docs:
    --
    --      "More complex labels can be constructed by setting labelb as another
    --      Fl_Multi_Label and thus chaining up a series of label elements."

    Win.End_Current;
    Win.Set_Resizable (Win);
    Win.Show_With_Args;
    return FLTK.Run;


end Howto_Menu_With_Images;


