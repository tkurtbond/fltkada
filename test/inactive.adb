--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/inactive.fl: one of each kind of widget in a group, which
--  two radio buttons activate and deactivate.  Ported from the C++ that
--  FLUID writes from it, guided by pofltk's Inactive.Mod.


with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Round,
    FLTK.Widgets.Clocks.Updated,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Menu_Buttons,
    FLTK.Widgets.Valuators.Dials,
    FLTK.Widgets.Valuators.Rollers,
    FLTK.Widgets.Valuators.Sliders.Scrollbars,
    FLTK.Widgets.Valuators.Value_Outputs;

use type

    FLTK.Alignment;


function Inactive
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Lit renames FLTK.Widgets.Buttons.Light;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Rnd renames FLTK.Widgets.Buttons.Light.Round;
    package Clk renames FLTK.Widgets.Clocks.Updated;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Grp renames FLTK.Widgets.Groups;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package MB  renames FLTK.Widgets.Menus.Menu_Buttons;
    package Dia renames FLTK.Widgets.Valuators.Dials;
    package Rol renames FLTK.Widgets.Valuators.Rollers;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Scr renames FLTK.Widgets.Valuators.Sliders.Scrollbars;
    package VO  renames FLTK.Widgets.Valuators.Value_Outputs;


    W : Dbl.Double_Window := Dbl.Forge.Create (420, 369);

    The_Group : Grp.Group := Grp.Forge.Create
       (W, 25, 25, 375, 295, "activate()/deactivate() called on this Fl_Group");

    Plain : Btn.Button := Btn.Forge.Create (The_Group, 50, 50, 105, 20, "button");
    Light : Lit.Light_Button := Lit.Forge.Create (The_Group, 50, 75, 105, 20, "light button");

    Pair : Grp.Group := Grp.Forge.Create (The_Group, 50, 100, 105, 20);
    On   : Btn.Button := Btn.Forge.Create (Pair, 50, 100, 52, 20, "On");
    Off  : Btn.Button := Btn.Forge.Create (Pair, 102, 100, 53, 20, "Off");

    Child : Grp.Group := Grp.Forge.Create (The_Group, 50, 150, 105, 105, "Child group");
    Red   : Chk.Check_Button := Chk.Forge.Create (Child, 54, 192, 97, 20, "red");
    Green : Chk.Check_Button := Chk.Forge.Create (Child, 54, 212, 97, 20, "green");
    Blue  : Chk.Check_Button := Chk.Forge.Create (Child, 54, 232, 97, 20, "blue");
    Check : Chk.Check_Button := Chk.Forge.Create (Child, 54, 152, 97, 20, "check");
    Round : Rnd.Round_Button := Rnd.Forge.Create (Child, 54, 172, 97, 20, "round");

    Slider : Sld.Slider := Sld.Forge.Create (The_Group, 165, 50, 24, 205, "Fl_Slider");
    Input  : Inp.Text_Input := Inp.Forge.Create (The_Group, 195, 50, 195, 30);
    Menu   : MB.Menu_Button := MB.Forge.Create (The_Group, 245, 90, 130, 30, "menu");
    Value  : VO.Value_Output := VO.Forge.Create (The_Group, 245, 130, 130, 30, "value:");
    Box    : Bx.Box := Bx.Forge.Create (The_Group, 245, 170, 140, 50, "Fl_Box");
    Bar    : Scr.Scrollbar := Scr.Forge.Create (The_Group, 40, 274, 180, 20, "scrollbar");
    Roller : Rol.Roller := Rol.Forge.Create (The_Group, 235, 230, 25, 65, "roller");
    Dial   : Dia.Dial := Dia.Forge.Create (The_Group, 275, 235, 50, 50, "dial");
    Clock  : Clk.Updated_Clock := Clk.Forge.Create (The_Group, 335, 235, 50, 50, "clock");

    Active_Button   : Btn.Button := Btn.Forge.Create (W, 25, 330, 185, 25, "active");
    Inactive_Button : Btn.Button := Btn.Forge.Create (W, 220, 330, 180, 25, "inactive");


    procedure Active_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Group.Activate;
    end Active_Callback;

    procedure Inactive_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Group.Deactivate;
    end Inactive_Callback;


    procedure Radio
           (Item  : in out Chk.Check_Button;
            Color : in     FLTK.Color) is
    begin
        Item.Set_Kind (Btn.Radio_Kind);
        Item.Set_Down_Box (FLTK.Diamond_Down_Box);
        Item.Set_Selection_Color (Color);
        Item.Set_Label_Color (Color);
    end Radio;


begin

    The_Group.Set_Box (FLTK.Engraved_Frame);
    The_Group.Set_Alignment (FLTK.Align_Top + FLTK.Align_Inside);

    Light.Set_State (Btn.On);
    Light.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);

    On.Set_Kind (Btn.Radio_Kind);
    On.Set_State (Btn.On);
    On.Set_Compact (True);
    Off.Set_Kind (Btn.Radio_Kind);
    Off.Set_Compact (True);

    Child.Set_Box (FLTK.Down_Frame);
    Radio (Red, 1);
    Radio (Green, 2);
    Radio (Blue, 4);
    Check.Set_Down_Box (FLTK.Down_Box);
    Round.Set_Down_Box (FLTK.Round_Down_Box);

    Slider.Set_Value (0.5);
    Input.Set_Value ("Fl_Input");

    --  FLTK's menu has five items labelled "item".  Add would replace an
    --  item of the same name, so each is added under a name of its own and
    --  then relabelled.
    for N in 1 .. 5 loop
        Menu.Set_Label (Menu.Add ("item" & Character'Val (Character'Pos ('0') + N)), "item");
    end loop;

    Value.Set_Maximum (10000.0);
    Value.Set_Step (1);
    Value.Set_Text_Font (FLTK.Courier_Bold);
    Value.Set_Text_Size (24);
    Value.Set_Text_Color (4);

    Box.Set_Box (FLTK.Embossed_Frame);
    Box.Set_Label_Kind (FLTK.Shadow_Label);
    Box.Set_Label_Font (FLTK.Helvetica_Bold_Italic);
    Box.Set_Label_Size (38);

    Sld.Extra.Set_Kind (Sld.Slider (Bar), Sld.Horizontal_Slider);

    W.Set_Resizable (The_Group);

    Active_Button.Set_Kind (Btn.Radio_Kind);
    Active_Button.Set_State (Btn.On);
    Active_Button.Set_Callback (Active_Callback'Unrestricted_Access);
    Inactive_Button.Set_Kind (Btn.Radio_Kind);
    Inactive_Button.Set_Callback (Inactive_Callback'Unrestricted_Access);

    W.Show_With_Args;

    return FLTK.Run;

end Inactive;
