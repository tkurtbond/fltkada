

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/forms.cxx, after pofltk's examples/Forms.Mod:  every kind of
--  widget the Forms library has, and a choice of box types.
--
--  FLTK's program makes this window with fl_add_box and the rest of
--  FL/forms.H, the C calls of old programs.  Each only makes the FLTK
--  widget, so this makes them itself, and the Forms library's own classes,
--  Forms_Text, Forms_Bitmap and Timer, come from FLTK.Widgets.Forms.
--  FLTK's Forms menu of type FL_PUSH_MENU is a pop-up, so it shows nothing
--  until clicked.  FLTK's window opens under the mouse, and its graphics
--  mode choice has no items; this one opens where the window manager puts
--  it.


with

    FLTK.Images.Bitmaps,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Round,
    FLTK.Widgets.Charts,
    FLTK.Widgets.Clocks,
    FLTK.Widgets.Forms.Bitmaps,
    FLTK.Widgets.Forms.Texts,
    FLTK.Widgets.Forms.Timers,
    FLTK.Widgets.Groups.Browsers.Textline,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Menus.Menu_Buttons,
    FLTK.Widgets.Positioners,
    FLTK.Widgets.Valuators.Counters,
    FLTK.Widgets.Valuators.Dials.Line,
    FLTK.Widgets.Valuators.Sliders.Value;

use type

    FLTK.Color,
    FLTK.Color_Component,
    FLTK.Size_Type;


function Forms
    return Integer
is


    package Bmi renames FLTK.Images.Bitmaps;
    package Bxs renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Lgt renames FLTK.Widgets.Buttons.Light;
    package Rnd renames FLTK.Widgets.Buttons.Light.Round;
    package Chr renames FLTK.Widgets.Charts;
    package Clk renames FLTK.Widgets.Clocks;
    package Fbm renames FLTK.Widgets.Forms.Bitmaps;
    package Ftx renames FLTK.Widgets.Forms.Texts;
    package Tmr renames FLTK.Widgets.Forms.Timers;
    package Brw renames FLTK.Widgets.Groups.Browsers.Textline;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package Mbt renames FLTK.Widgets.Menus.Menu_Buttons;
    package Pos renames FLTK.Widgets.Positioners;
    package Cnt renames FLTK.Widgets.Valuators.Counters;
    package Dil renames FLTK.Widgets.Valuators.Dials.Line;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Vsl renames FLTK.Widgets.Valuators.Sliders.Value;
    package Wdg renames FLTK.Widgets;


    Slate_Blue : constant FLTK.Color := 195;


    --  The sorceress, 75 by 75, from FLTK's test/srs.xbm:  ten bytes a row.
    type Hex_Rows is array (1 .. 75) of String (1 .. 20);

    Rows : constant Hex_Rows :=
       ("fc7e4020900007802300", "00c6c14198b801076600", "159f03478cc6dc7bcc00",
        "b0710e4d0666738e8f01", "18c4394b02230c041e03", "0c08c7ef083006071c02",
        "063018aec8983f782006", "022060a0c41dc0ff4104", "fa6380a1a43d0084bf04",
        "0f06fca1346b011cc905", "06c706be111e43309105", "c36102301b30cc201100",
        "c13c03200a00e8602100", "611bc16308f0c6c72103", "f808e1cf0afc4d994307",
        "3c0cf19f0bfc5b814702", "1604311c0b1f17894d06", "1a043138020756894904",
        "0b04b17282a1549a4904", "1d6650e7c2f0549a5804", "0d62c11f44fc51909004",
        "8663e07404ef311a9100", "02e2c1fd84f9300a9100", "82a9c0b984f931168100",
        "42a9db7f0cff1c161100", "02280b0708601c029100", "46290e00000010161102",
        "06290400000010169106", "a62a0400000018249104", "862a0400000018279304",
        "964a0400000004029104", "864a0c0000001e239304", "56880800000090219304",
        "520a09800100d0219504", "570a0f802700d8209d04", "5d081c806700e4018504",
        "798a3f000000f4118506", "39087d000018b7108103", "2912cb007e3028008503",
        "2910be81ff270c108503", "2932fac1ff2794118503", "28206ce1ff070c018501",
        "28625ce38f034e918005", "3940f4c2ff009f918405", "31c6e8077f80cd00c404",
        "3106c90e00c04888e004", "7904db1200300cc8e404", "6d06b62300181cc08404",
        "250cffc2004e06b08004", "3f8ab383ffc303918404", "2ed80f3f00005f838404",
        "2a70fd7f0000c8c08404", "4be22f01000858608004", "5b82ff010008d0a08404",
        "7280e5000008d2204404", "ca02ff000008dea04404", "82026d000008f6b04002",
        "82073f00000844584402", "933f1f000030884f4403", "83233e0000001860e007",
        "e30ffe0000007070e407", "c71bfe010000e03ce407", "c7e3fe1f0000ff1ffc07",
        "c703f83300c0f007ff07", "8702fc430060f0ffff07", "8f06be870030f8ffff07",
        "8f149c8f0000fcffff07", "9f8d8a0f0000feffff07", "bf0b801f0000ffffff07",
        "7f3a803f0080ffffff07", "ff20c03f0080ffffff07", "ff01e07f00c0ffffff07",
        "ff0ff8ff40e0ffffff07", "ffffffff40f0ffffff07", "ffffffff41f0ffffff07");

    function Sorceress
        return FLTK.Color_Component_Array
    is
        function Digit
               (C : in Character)
            return FLTK.Color_Component is
        begin
            if C >= 'a' then
                return Character'Pos (C) - Character'Pos ('a') + 10;
            else
                return Character'Pos (C) - Character'Pos ('0');
            end if;
        end Digit;
        Result : FLTK.Color_Component_Array (1 .. 750);
        N      : FLTK.Size_Type := 1;
    begin
        for Row of Rows loop
            for I in 0 .. 9 loop
                Result (N) := Digit (Row (2 * I + 1)) * 16 + Digit (Row (2 * I + 2));
                N := N + 1;
            end loop;
        end loop;
        return Result;
    end Sorceress;


    type Name_Access is access constant String;

    type Box_Choice is record
        Kind : FLTK.Box_Kind;
        Name : Name_Access;
    end record;

    type Box_Choice_Array is array (Positive range <>) of Box_Choice;

    Box_Choices : constant Box_Choice_Array :=
       ((FLTK.No_Box,              new String'("no box")),
        (FLTK.Up_Box,              new String'("up box")),
        (FLTK.Down_Box,            new String'("down box")),
        (FLTK.Border_Box,          new String'("border box")),
        (FLTK.Shadow_Box,          new String'("shadow box")),
        (FLTK.Flat_Box,            new String'("flat box")),
        (FLTK.Engraved_Box,        new String'("frame box")),
        (FLTK.Embossed_Box,        new String'("embossed box")),
        (FLTK.Rounded_Box,         new String'("rounded box")),
        (FLTK.RFlat_Box,           new String'("rflat box")),
        (FLTK.RShadow_Box,         new String'("rshadow box")),
        (FLTK.Oval_Box,            new String'("oval box")),
        (FLTK.Round_Up_Box,        new String'("rounded3d upbox")),
        (FLTK.Round_Down_Box,      new String'("rounded3d downbox")),
        (FLTK.Round_Up_Box,        new String'("oval3d upbox")),
        (FLTK.Round_Down_Box,      new String'("oval3d downbox")),
        (FLTK.Plastic_Up_Box,      new String'("plastic upbox")),
        (FLTK.Plastic_Down_Box,    new String'("plastic downbox")),
        (FLTK.Gtk_Up_Box,          new String'("GTK up box")),
        (FLTK.Gtk_Round_Up_Box,    new String'("GTK round up box")),
        (FLTK.Gleam_Up_Box,        new String'("Gleam up box")));

    Browser_Lines : constant array (Positive range <>) of Name_Access :=
       (new String'(" "), new String'("@C1@c@l@bObjects Demo"), new String'(" "),
        new String'("This demo shows you all"), new String'("objects that currently"),
        new String'("exist in the Forms Library."), new String'(" "),
        new String'("You can change the boxtype"), new String'("of the different objects"),
        new String'("using the buttons at the top"), new String'("of the form. Note that some"),
        new String'("combinations might not"), new String'("look too good. Also realize"),
        new String'("that for all object classes"), new String'("many different types are"),
        new String'("available with different"), new String'("behaviour."), new String'(" "),
        new String'("With this demo you can also"), new String'("see the effect of the drawing"),
        new String'("mode on the appearance of"), new String'("the objects."));


    Picture : Bmi.Bitmap := Bmi.Forge.Create (Sorceress, 75, 75);

    Form : Win.Window := Win.Forge.Create (720, 520, "Box types");

    --  The backgrounds go first, so the rest are drawn over them.
    Back       : Bxs.Box := Bxs.Forge.Create (Form, 0, 0, 720, 520);
    Middle     : Bxs.Box := Bxs.Forge.Create (Form, 10, 90, 700, 420);
    Top        : Bxs.Box := Bxs.Forge.Create (Form, 10, 10, 700, 70);
    Plain_Box  : aliased Bxs.Box := Bxs.Forge.Create (Form, 30, 110, 110, 110, "Box");
    Text       : aliased Ftx.Forms_Text := Ftx.Forge.Create (Form, 30, 240, 110, 30, "Text");
    Bitmap     : aliased Fbm.Forms_Bitmap :=
        Fbm.Forge.Create (Form, 40, 280, 90, 80, "Bitmap");
    Chart      : aliased Chr.Chart := Chr.Forge.Create (Form, 160, 110, 160, 110, "Chart");
    Clock      : aliased Clk.Clock := Clk.Forge.Create (Form, 40, 390, 90, 90, "Clock");
    Button     : aliased Btn.Button := Btn.Forge.Create (Form, 340, 110, 120, 30, "Button");
    Light      : aliased Lgt.Light_Button :=
        Lgt.Forge.Create (Form, 340, 150, 120, 30, "Lightbutton");
    Round      : aliased Rnd.Round_Button :=
        Rnd.Forge.Create (Form, 340, 190, 120, 30, "Roundbutton");
    Slider     : aliased Sld.Slider := Sld.Forge.Create (Form, 160, 250, 40, 230, "Slider");
    Valslider  : aliased Vsl.Value_Slider :=
        Vsl.Forge.Create (Form, 220, 250, 40, 230, "Valslider");
    Dial       : aliased Dil.Line_Dial := Dil.Forge.Create (Form, 280, 250, 100, 100, "Dial");
    Positioner : aliased Pos.Positioner :=
        Pos.Forge.Create (Form, 280, 380, 150, 100, "Positioner");
    Counter    : aliased Cnt.Counter := Cnt.Forge.Create (Form, 480, 110, 210, 30, "Counter");
    Input      : aliased Inp.Text_Input := Inp.Forge.Create (Form, 520, 170, 170, 30, "Input");
    Menu       : aliased Mbt.Menu_Button := Mbt.Forge.Create (Form, 400, 240, 100, 30, "Menu");
    Choice     : aliased Chc.Choice := Chc.Forge.Create (Form, 580, 250, 110, 30, "Choice");
    Timer      : aliased Tmr.Timer :=
        Tmr.Forge.Create (Form, Tmr.Value_Timer, 580, 210, 110, 30, "Timer");
    Browser    : aliased Brw.Textline_Browser :=
        Brw.Forge.Create (Form, 450, 300, 240, 180, "Browser");
    Quit       : Btn.Button := Btn.Forge.Create (Form, 590, 30, 100, 30, "Exit");
    Kinds      : Chc.Choice := Chc.Forge.Create (Form, 110, 30, 130, 30, "Boxtype");
    Mode       : Chc.Choice := Chc.Forge.Create (Form, 370, 30, 130, 30, "Graphics mode");
    pragma Unreferenced (Mode);

    --  The widgets whose box can be chosen.
    type Widget_Access is access all Wdg.Widget'Class;

    Tests : constant array (0 .. 17) of Widget_Access :=
       (Plain_Box'Access, Text'Access, Bitmap'Access, Chart'Access, Clock'Access,
        Button'Access, Light'Access, Round'Access, Slider'Access, Valslider'Access,
        Dial'Access, Positioner'Access, Counter'Access, Input'Access, Menu'Access,
        Choice'Access, Timer'Access, Browser'Access);

    Last_Kind : Natural := 0;

    procedure Box_Kind_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Chosen : constant Natural := Kinds.Chosen_Index;
    begin
        if Chosen /= 0 and Chosen /= Last_Kind then
            for T of Tests loop
                T.Set_Box (Box_Choices (Chosen).Kind);
            end loop;
            Last_Kind := Chosen;
            Form.Redraw;
        end if;
    end Box_Kind_CB;

    procedure Exit_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Form.Hide;
    end Exit_CB;

    procedure Plain
           (Item : in out Bxs.Box;
            Kind : in     FLTK.Box_Kind;
            Hue  : in     FLTK.Color) is
    begin
        Item.Set_Box (Kind);
        Item.Set_Background_Color (Hue);
        Item.Set_Selection_Color (FLTK.Background_Color);
    end Plain;

    procedure Add_Items
           (Item : in out FLTK.Widgets.Menus.Menu'Class) is
    begin
        for I in 1 .. 5 loop
            Item.Add ("item" & Integer'Image (I));
        end loop;
    end Add_Items;


begin


    Form.Set_Box (FLTK.No_Box);
    Plain (Back, FLTK.Up_Box, FLTK.Blue_Color);
    Plain (Middle, FLTK.Down_Box, FLTK.Background_Color);
    Plain (Top, FLTK.Down_Box, Slate_Blue);
    Plain_Box.Set_Box (FLTK.Up_Box);

    Bitmap.Set_Label_Color (FLTK.Blue_Color);
    Bitmap.Set_Bitmap (Picture);

    Chart.Set_Kind (Chr.Bar_Chart);
    Chart.Add (15.0, "item 1", FLTK.Black_Color);
    Chart.Add (5.0, "item 2", FLTK.Black_Color + 1);
    Chart.Add (-10.0, "item 3", FLTK.Black_Color + 2);
    Chart.Add (25.0, "item 4", FLTK.Black_Color + 3);

    Light.Set_Kind (Btn.Toggle_Kind);
    Round.Set_Kind (Btn.Toggle_Kind);
    Menu.Set_Popup_Kind (Mbt.Popup1);
    Add_Items (Menu);
    Add_Items (Choice);
    Timer.Set_Value (1000.0);
    for Line of Browser_Lines loop
        Browser.Add (Line.all);
    end loop;

    Quit.Set_Callback (Exit_CB'Unrestricted_Access);
    Kinds.Set_Callback (Box_Kind_CB'Unrestricted_Access);
    for B of Box_Choices loop
        Kinds.Add (B.Name.all);
    end loop;

    --  As fl_show_form does, which gets the system colors.
    Form.Show_With_Args;

    return FLTK.Run;


end Forms;
