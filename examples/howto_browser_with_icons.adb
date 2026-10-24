

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-browser-with-icons.cxx: a browser
--  whose items have icons, which the user can change with a choice.
--
--  The original passes the browser to the choice's callback as user data;
--  here the callback is nested where the browser is declared and simply
--  refers to it.


with

    Ada.Strings.Unbounded,
    FLTK.Images.Pixmaps,
    FLTK.Widgets.Groups.Browsers.Textline.Multi,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices;


function Howto_Browser_With_Icons
    return Integer
is


    package SU  renames Ada.Strings.Unbounded;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;

    package Pix renames FLTK.Images.Pixmaps;
    package Mul renames FLTK.Widgets.Groups.Browsers.Textline.Multi;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;
    package Ch  renames FLTK.Widgets.Menus.Choices;


    --  XPM
    Big_Header : constant Pix.Header := (50, 34, 4, 1);
    Big_Colors : constant Pix.Color_Definition_Array :=
       ((+" ", Pix.Colorful, +"#000000"),
        (+"o", Pix.Colorful, +"#ff9900"),
        (+"@", Pix.Colorful, +"#ffffff"),
        (+"#", Pix.Colorful, +"None"));
    Big_Pixels : constant Pix.Pixmap_Data :=
       ("##################################################",
        "###      ##############################       ####",
        "### ooooo  ###########################  ooooo ####",
        "### oo  oo  #########################  oo  oo ####",
        "### oo   oo  #######################  oo   oo ####",
        "### oo    oo  #####################  oo    oo ####",
        "### oo     oo  ###################  oo     oo ####",
        "### oo      oo                     oo      oo ####",
        "### oo       oo  ooooooooooooooo  oo       oo ####",
        "### oo        ooooooooooooooooooooo        oo ####",
        "### oo     ooooooooooooooooooooooooooo    ooo ####",
        "#### oo   ooooooo ooooooooooooo ooooooo   oo #####",
        "####  oo oooooooo ooooooooooooo oooooooo oo  #####",
        "##### oo oooooooo ooooooooooooo oooooooo oo ######",
        "#####  o ooooooooooooooooooooooooooooooo o  ######",
        "###### ooooooooooooooooooooooooooooooooooo #######",
        "##### ooooooooo     ooooooooo     ooooooooo ######",
        "##### oooooooo  @@@  ooooooo  @@@  oooooooo ######",
        "##### oooooooo @@@@@ ooooooo @@@@@ oooooooo ######",
        "##### oooooooo @@@@@ ooooooo @@@@@ oooooooo ######",
        "##### oooooooo  @@@  ooooooo  @@@  oooooooo ######",
        "##### ooooooooo     ooooooooo     ooooooooo ######",
        "###### oooooooooooooo       oooooooooooooo #######",
        "###### oooooooo@@@@@@@     @@@@@@@oooooooo #######",
        "###### ooooooo@@@@@@@@@   @@@@@@@@@ooooooo #######",
        "####### ooooo@@@@@@@@@@@ @@@@@@@@@@@ooooo ########",
        "######### oo@@@@@@@@@@@@ @@@@@@@@@@@@oo ##########",
        "########## o@@@@@@ @@@@@ @@@@@ @@@@@@o ###########",
        "########### @@@@@@@     @     @@@@@@@ ############",
        "############  @@@@@@@@@@@@@@@@@@@@@  #############",
        "##############  @@@@@@@@@@@@@@@@@  ###############",
        "################    @@@@@@@@@    #################",
        "####################         #####################",
        "##################################################");


    --  XPM
    Med_Header : constant Pix.Header := (14, 14, 2, 1);
    Med_Colors : constant Pix.Color_Definition_Array :=
       ((+"#", Pix.Colorful, +"#000000"),
        (+" ", Pix.Colorful, +"#ffffff"));
    Med_Pixels : constant Pix.Pixmap_Data :=
       ("##############",
        "##############",
        "##          ##",
        "##  ##  ##  ##",
        "##  ##  ##  ##",
        "##   ####   ##",
        "##    ##    ##",
        "##    ##    ##",
        "##   ####   ##",
        "##  ##  ##  ##",
        "##  ##  ##  ##",
        "##          ##",
        "##############",
        "##############");


    --  XPM
    Sml_Header : constant Pix.Header := (9, 11, 5, 1);
    Sml_Colors : constant Pix.Color_Definition_Array :=
       ((+".", Pix.Colorful, +"None"),
        (+"@", Pix.Colorful, +"#000000"),
        (+"+", Pix.Colorful, +"#808080"),
        (+"r", Pix.Colorful, +"#802020"),
        (+"#", Pix.Colorful, +"#ff8080"));
    Sml_Pixels : constant Pix.Pixmap_Data :=
       (".........",
        ".........",
        "@+.......",
        "@@@+.....",
        "@@r@@+...",
        "@@##r@@+.",
        "@@####r@@",
        "@@##r@@+.",
        "@@r@@+...",
        "@@@+.....",
        "@+.......");


    type My_Browser is new Mul.Multi_Browser with record
        Big_Icon : Pix.Pixmap;
        Med_Icon : Pix.Pixmap;
        Sml_Icon : Pix.Pixmap;
    end record;


    function Create
           (Parent     : in out FLTK.Widgets.Groups.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String := "")
        return My_Browser is
    begin
        return This : My_Browser :=
           (Mul.Forge.Create (Parent, X, Y, W, H, Text) with
            --  Create icons (these could also be pngs, jpegs..)
            Big_Icon => Pix.Forge.Create (Big_Header, Big_Colors, Big_Pixels),
            Med_Icon => Pix.Forge.Create (Med_Header, Med_Colors, Med_Pixels),
            Sml_Icon => Pix.Forge.Create (Sml_Header, Sml_Colors, Sml_Pixels))
        do
            --  Normal browser initialization stuff
            This.Set_Text_Font (FLTK.Courier);
            This.Set_Text_Size (14);
            This.Add ("One");
            This.Add ("Two");
            This.Add ("Three");
            This.Add ("Four");
            This.Add ("Five");
            This.Add ("Six");
            This.Add ("Seven");
        end return;
    end Create;


    W : DW.Double_Window := DW.Forge.Create (400, 300);

    --  Create a browser
    B : My_Browser := Create (W, 10, 40, W.Get_W - 20, W.Get_H - 50);

    --  Create a chooser to let the user change the icons
    Choice : Ch.Choice := Ch.Forge.Create (W, 60, 10, 140, 25, "Icon:");


    procedure Choice_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Text : constant String := Ch.Choice (Item).Chosen_Label;
    begin
        --  See which icon the user picked, and change the icon of three
        --  browser items to it.  This is all you have to do to change a
        --  browser item's icon.  The browser will automatically resize the
        --  items if need be.
        if Text = "None" then
            for Line in 3 .. 5 loop
                B.Remove_Icon (Line);
            end loop;
        else
            for Line in 3 .. 5 loop
                B.Set_Icon
                   (Line,
                    (if    Text = "Small"  then B.Sml_Icon
                     elsif Text = "Medium" then B.Med_Icon
                     else                       B.Big_Icon));
            end loop;
        end if;
    end Choice_CB;


begin


    Choice.Add ("None", null);
    Choice.Add ("Small", null);
    Choice.Add ("Medium", null);
    Choice.Add ("Large", null);
    Choice.Set_Callback (Choice_CB'Unrestricted_Access);
    if Choice.Take_Focus then
        null;
    end if;
    Choice.Set_Chosen (2);
    Choice.Do_Callback;

    W.End_Current;
    W.Show;
    return FLTK.Run;


end Howto_Browser_With_Icons;
