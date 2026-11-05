


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 54: an Fl_Menu_Item showing an image or a
--  multi-label holds the Fl_Image or Fl_Multi_Label pointer in its text.
--  Fl_Menu_::remove and replace free() that pointer (Fl_Menu_add.cxx), and
--  item_pathname, find_index and insert read it as the item's text, so the
--  item's path is not found.  Set_Image and Set_Multi_Label also freed the
--  item's text, its name in the menu.  And no label kind whose label is
--  a pointer is given to an item's text (FLTKAda-BUGS.md 83): FLTK read it
--  as the pointer when it drew the menu.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.RGB,
    FLTK.Menu_Items,
    FLTK.Multi_Labels,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Menus.Menu_Bars;

use

    Checks,
    FLTK;


procedure Test_Menu_Item_Labels is

    package RGB renames FLTK.Images.RGB;
    package MI  renames FLTK.Menu_Items;
    package ML  renames FLTK.Multi_Labels;
    package Mnu renames FLTK.Widgets.Menus;
    package Bar renames FLTK.Widgets.Menus.Menu_Bars;
    package Win renames FLTK.Widgets.Groups.Windows;

    Pixels : constant FLTK.Color_Component_Array (1 .. 8 * 8 * 3) := (others => 100);
    Icon   : RGB.RGB_Image := RGB.Forge.Create (Pixels, 8, 8);
    Multi  : ML.Multi_Label := ML.Forge.Create;

    Menu : Bar.Menu_Bar := Bar.Forge.Create (0, 0, 200, 25);

    function Place
           (Path : in String)
        return Mnu.Index is
    begin
        return Mnu.Index (Menu.Find_Index (Path));
    end Place;

    function Path_Of
           (Path : in String)
        return String is
    begin
        return Menu.Item_Pathname (MI.Menu_Item (Menu.Item (Place (Path)).Data.all));
    end Path_Of;

begin

    Multi.Set_First (Icon);
    Multi.Set_Second ("multi");

    Menu.Add ("File/New", Shortcut => No_Key);
    Menu.Add ("File/Open", Shortcut => No_Key);
    Menu.Add ("File/Save", Shortcut => No_Key);
    Menu.Add ("Edit/Copy", Shortcut => No_Key);
    Menu.Add ("Edit/Paste", Shortcut => No_Key);
    Menu.Add ("Help", Shortcut => No_Key);

    Menu.Item (Place ("File/New")).Set_Image (Icon);
    Menu.Item (Place ("Edit/Copy")).Set_Multi_Label (Multi);
    Menu.Item (Place ("File")).Set_Image (Icon);

    --  The names still find the items.
    Check (Menu.Find_Index ("File/New") > 0, "an item showing an image is found by its path");
    Check (Menu.Find_Index ("Edit/Copy") > 0,
        "an item showing a multi-label is found by its path");
    Check (Menu.Find_Index ("File/Open") > 0, "an item below a title showing an image is found");
    Check (Path_Of ("File/New") = "File/New", "an image item's path");
    Check (Path_Of ("Edit/Copy") = "Edit/Copy", "a multi-label item's path");
    Check (Menu.Item (Place ("File/New")).Get_Label = "New", "an image item's label is its name");
    Check (Menu.Get_Label (Place ("Edit/Copy")) = "Copy", "a multi-label item's label");
    Check (Menu.Item (Place ("File/New")).Get_Label_Kind = FLTK.Image_Label,
        "an image item's label kind");
    Check (Menu.Item (Place ("Edit/Copy")).Get_Label_Kind = FLTK.Multi_Label,
        "a multi-label item's label kind");

    --  An item added below a title showing an image goes in its submenu.
    declare
        Before : constant Natural := Menu.Number_Of_Items;
    begin
        Menu.Add ("File/Close", Shortcut => No_Key);
        Check (Menu.Number_Of_Items = Before + 1,
            "an item added below a title showing an image goes in its submenu");
        Check (Path_Of ("File/Close") = "File/Close", "the added item's path");
    end;

    --  A copy of the menu, with its own labels.
    declare
        Other : Bar.Menu_Bar := Bar.Forge.Create (0, 0, 200, 25);
    begin
        Other.Use_Same_Items (Menu);
        Check (Other.Find_Index ("File/New") > 0
                and then Other.Item (Mnu.Index (Other.Find_Index ("File/New"))).Get_Label_Kind
                    = FLTK.Image_Label,
            "a copied menu's image item");
        Other.Remove (Mnu.Index (Other.Find_Index ("File/New")));
    end;
    Check (Menu.Find_Index ("File/New") > 0, "the copy's items are its own");

    --  An item relabelled, then removed, and a submenu cleared.
    Menu.Set_Label (Place ("File/New"), "Renamed");
    Check (Menu.Item (Place ("File/Renamed")).Get_Label_Kind = FLTK.Normal_Label,
        "an image item relabelled shows text");
    Menu.Item (Place ("File/Renamed")).Set_Image (Icon);
    Menu.Remove (Place ("File/Renamed"));
    Check (Menu.Find_Index ("File/Renamed") = 0, "an image item removed");
    Menu.Item (Place ("File/Open")).Set_Image (Icon);
    Menu.Clear_Submenu (Place ("File"));
    Check (Menu.Find_Index ("File/Open") = 0, "a submenu with an image item cleared");
    Check (Path_Of ("Edit/Copy") = "Edit/Copy", "the other submenu is still there");

    --  A label given text again.
    Menu.Item (Place ("Edit/Paste")).Set_Image (Icon);
    Menu.Item (Place ("Edit/Paste")).Set_Label ("Paste2");
    Check (Menu.Find_Index ("Edit/Paste2") > 0, "an image item given a text label");

    --  A free-standing item.
    declare
        Item : MI.Menu_Item := MI.Forge.Create ("alone");
    begin
        Item.Set_Image (Icon);
        Check (Item.Get_Label = "alone", "a free-standing image item keeps its name");
        Item.Set_Multi_Label (Multi);
        Check (Item.Get_Label = "alone", "and a multi-label item");
    end;

    --  The menu cleared, and finalized, with labels showing.
    Menu.Item (Place ("Help")).Set_Image (Icon);
    Menu.Clear;
    Menu.Add ("Again", Shortcut => No_Key);
    Menu.Item (Place ("Again")).Set_Image (Icon);

    --  Text with a pointer's label kind, drawn (83).  The bar's first items
    --  show an image and a multi-label, so FLTK has the kinds' functions.
    declare
        Window : Win.Window := Win.Forge.Create (0, 0, 600, 100, "Test_Menu_Item_Labels");
        Drawn  : Bar.Menu_Bar := Bar.Forge.Create (Window, 0, 0, 600, 25);

        function Item
               (N : in Positive)
            return access MI.Menu_Item'Class is
        begin
            return Drawn.Item (Mnu.Index (N)).Data;
        end Item;

        function Plain
               (N    : in Positive;
                Text : in String)
            return Boolean is
        begin
            return Item (N).Get_Label_Kind = FLTK.Normal_Label and Item (N).Get_Label = Text;
        end Plain;
    begin
        Drawn.Add ("image", Shortcut => No_Key);
        Drawn.Add ("multi", Shortcut => No_Key);
        Drawn.Add ("kind-image", Shortcut => No_Key);
        Drawn.Add ("kind-multi", Shortcut => No_Key);
        Drawn.Add ("kind-icon", Shortcut => No_Key);
        Drawn.Add ("with-image", Shortcut => No_Key);
        Drawn.Add ("with-multi", Shortcut => No_Key);
        Drawn.Add ("with-icon", Shortcut => No_Key);
        Drawn.Add ("image-text", Shortcut => No_Key);
        Drawn.Add ("image-normal-text", Shortcut => No_Key);
        Item (1).Set_Image (Icon);
        Item (2).Set_Multi_Label (Multi);
        Item (3).Set_Label_Kind (FLTK.Image_Label);
        Item (4).Set_Label_Kind (FLTK.Multi_Label);
        Item (5).Set_Label_Kind (FLTK.Icon_Label);
        Item (6).Set_Label (FLTK.Image_Label, "6");
        Item (7).Set_Label (FLTK.Multi_Label, "7");
        Item (8).Set_Label (FLTK.Icon_Label, "8");
        Item (9).Set_Image (Icon);
        Item (9).Set_Label ("9");
        Item (10).Set_Image (Icon);
        Item (10).Set_Label (FLTK.Normal_Label, "10");
        Window.Show;
        for N in 1 .. 20 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
        Check (Plain (3, "kind-image") and Plain (4, "kind-multi") and Plain (5, "kind-icon"),
            "Set_Label_Kind doesn't give text a pointer's kind (83)");
        Check (Plain (6, "6") and Plain (7, "7") and Plain (8, "8"),
            "nor does Set_Label (Kind, Text) (83)");
        Check (Plain (9, "9") and Plain (10, "10"),
            "and text given to an item showing an image is plain text (83)");
        Check (Item (1).Get_Label_Kind = FLTK.Image_Label
                and Item (2).Get_Label_Kind = FLTK.Multi_Label,
            "the image and the multi-label are still shown");
        Window.Hide;
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Menu_Item_Labels;


