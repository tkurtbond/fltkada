--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/valuators.fl: one of each kind of valuator, each with each
--  of its types, and a terminal where each callback prints the
--  valuator's value.  Ported from the C++ that FLUID writes from it,
--  guided by pofltk's Valuators.Mod.


with

    Interfaces.C,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Spinners,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Adjusters,
    FLTK.Widgets.Valuators.Counters,
    FLTK.Widgets.Valuators.Dials,
    FLTK.Widgets.Valuators.Rollers,
    FLTK.Widgets.Valuators.Sliders.Scrollbars,
    FLTK.Widgets.Valuators.Sliders.Value,
    FLTK.Widgets.Valuators.Value_Inputs,
    FLTK.Widgets.Valuators.Value_Outputs;

use type

    FLTK.Alignment;


function Valuators
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Grp renames FLTK.Widgets.Groups;
    package Spn renames FLTK.Widgets.Groups.Spinners;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Val renames FLTK.Widgets.Valuators;
    package Adj renames FLTK.Widgets.Valuators.Adjusters;
    package Cnt renames FLTK.Widgets.Valuators.Counters;
    package Dia renames FLTK.Widgets.Valuators.Dials;
    package Rol renames FLTK.Widgets.Valuators.Rollers;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package Scr renames FLTK.Widgets.Valuators.Sliders.Scrollbars;
    package VS  renames FLTK.Widgets.Valuators.Sliders.Value;
    package VI  renames FLTK.Widgets.Valuators.Value_Inputs;
    package VO  renames FLTK.Widgets.Valuators.Value_Outputs;


    W : Dbl.Double_Window := Dbl.Forge.Create
        (580, 640, "Valuator classes, showing values for type()");

    Sliders : Grp.Group := Grp.Forge.Create (W, 10, 10, 280, 210, "Fl_Slider");
    S1 : Sld.Slider := Sld.Forge.Create (Sliders, 30, 45, 20, 145, "0");
    S2 : Sld.Slider := Sld.Forge.Create
        (Sliders, Sld.Vertical_Fill_Slider, 70, 55, 20, 145, "FL_VERT_FILL_SLIDER");
    S3 : Sld.Slider := Sld.Forge.Create
        (Sliders, Sld.Vertical_Nice_Slider, 105, 45, 20, 145, "FL_VERT_NICE_SLIDER");
    S4 : Sld.Slider := Sld.Forge.Create
        (Sliders, Sld.Horizontal_Slider, 140, 80, 130, 20, "FL_HORIZONTAL");
    S5 : Sld.Slider := Sld.Forge.Create
        (Sliders, Sld.Horizontal_Fill_Slider, 140, 120, 130, 20, "FL_HOR_FILL_SLIDER");
    S6 : Sld.Slider := Sld.Forge.Create
        (Sliders, Sld.Horizontal_Nice_Slider, 140, 160, 130, 20, "FL_HOR_NICE_SLIDER");

    Value_Sliders : Grp.Group := Grp.Forge.Create (W, 10, 230, 280, 210, "Fl_Value_Slider");
    V1 : VS.Value_Slider := VS.Forge.Create (Value_Sliders, 30, 260, 30, 145, "0");
    V2 : VS.Value_Slider := VS.Forge.Create
        (Value_Sliders, 70, 275, 30, 140, "FL_VERT_FILL_SLIDER");
    V3 : VS.Value_Slider := VS.Forge.Create
        (Value_Sliders, 110, 260, 20, 145, "FL_VERT_NICE_SLIDER");
    V4 : VS.Value_Slider := VS.Forge.Create (Value_Sliders, 140, 290, 130, 20, "FL_HOR_SLIDER");
    V5 : VS.Value_Slider := VS.Forge.Create
        (Value_Sliders, 140, 330, 130, 20, "FL_HOR_FILL_SLIDER");
    V6 : VS.Value_Slider := VS.Forge.Create
        (Value_Sliders, 140, 370, 130, 20, "FL_HOR_NICE_SLIDER");

    Inputs : Grp.Group := Grp.Forge.Create (W, 10, 450, 135, 50, "Fl_Value_Input");
    In1    : VI.Value_Input := VI.Forge.Create (Inputs, 30, 470, 105, 25, "0");

    Outputs : Grp.Group := Grp.Forge.Create (W, 155, 450, 135, 50, "Fl_Value_Output");
    Out1    : VO.Value_Output := VO.Forge.Create (Outputs, 170, 470, 105, 25, "0");

    Scrollbars : Grp.Group := Grp.Forge.Create (W, 300, 10, 130, 120, "   Fl_Scrollbar");
    Bar1 : Scr.Scrollbar := Scr.Forge.Create (Scrollbars, 305, 55, 95, 20, "FL_HORIZONTAL");
    Bar2 : Scr.Scrollbar := Scr.Forge.Create (Scrollbars, 405, 30, 20, 90, "FL_VERTICAL (0) ->");

    Adjusters : Grp.Group := Grp.Forge.Create (W, 440, 10, 130, 120, "Fl_Adjuster");
    Adj1 : Adj.Adjuster := Adj.Forge.Create (Adjusters, 450, 60, 75, 25, "w()>h()");
    Adj2 : Adj.Adjuster := Adj.Forge.Create (Adjusters, 530, 35, 25, 75, "w()<h()");

    Counters : Grp.Group := Grp.Forge.Create (W, 300, 140, 130, 120, "Fl_Counter");
    Cnt1 : Cnt.Counter := Cnt.Forge.Create (Counters, 310, 175, 110, 25, "0");
    Cnt2 : Cnt.Counter := Cnt.Forge.Create (Counters, 310, 215, 110, 25, "FL_SIMPLE_COUNTER");

    Spinners : Grp.Group := Grp.Forge.Create (W, 440, 140, 130, 120, "Fl_Spinner");
    Spn1 : Spn.Spinner := Spn.Forge.Create (Spinners, 465, 176, 80, 24, "FL_INT_INPUT");
    Spn2 : Spn.Spinner := Spn.Forge.Create (Spinners, 465, 216, 80, 24, "FL_FLOAT_INPUT");

    Dials : Grp.Group := Grp.Forge.Create (W, 300, 270, 270, 105, "Fl_Dial");
    Dia1  : Dia.Dial := Dia.Forge.Create (Dials, 320, 295, 65, 65, "0");
    Dia2  : Dia.Dial := Dia.Forge.Create (Dials, 400, 295, 65, 65, "FL_LINE_DIAL");
    Dia3  : Dia.Dial := Dia.Forge.Create (Dials, 480, 295, 65, 65, "FL_FILL_DIAL");

    Rollers : Grp.Group := Grp.Forge.Create (W, 300, 385, 150, 115, "Fl_Roller");
    Rol1    : Rol.Roller := Rol.Forge.Create (Rollers, 315, 390, 20, 95, "0");
    Rol2    : Rol.Roller := Rol.Forge.Create (Rollers, 345, 430, 90, 20, "FL_HORIZONTAL");

    Note : Bx.Box := Bx.Forge.Create
       (W, 460, 385, 110, 115,
        "Some widgets have color(FL_GREEN) and color2(FL_RED) to show the areas these " &
        "effect.");

    TTY : Trm.Terminal := Trm.Forge.Create (W, 10, 513, 560, 117);


    --  printf's %g, which Ada's Image has no equivalent of.
    function G
           (Value : in Long_Float)
        return String
    is
        use type Interfaces.C.int;
        function snprintf
               (Buffer : out Interfaces.C.char_array;
                Size   : in  Interfaces.C.size_t;
                Format : in  Interfaces.C.char_array;
                Item   : in  Interfaces.C.double)
            return Interfaces.C.int
        with Import, Convention => C_Variadic_3, External_Name => "snprintf";
        Buffer : Interfaces.C.char_array (1 .. 32);
        Length : constant Interfaces.C.int := snprintf
           (Buffer, Buffer'Length, Interfaces.C.To_C ("%g"), Interfaces.C.double (Value));
    begin
        return Interfaces.C.To_Ada (Buffer (1 .. Interfaces.C.size_t (Length)), False);
    end G;


    --  FLTK's callback and callback_spinner, with the name FLTK passes as
    --  the user data a formal of the generic instead.
    generic
        Name : String;
    procedure Report
           (Item : in out FLTK.Widgets.Widget'Class);

    procedure Report
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Value : constant Long_Float :=
           (if Item in Val.Valuator'Class
            then Val.Valuator'Class (Item).Get_Value
            else Spn.Spinner'Class (Item).Get_Value);
    begin
        TTY.Print
           ("callback(): " & Name & " value() = " & ASCII.ESC & "[1m" & G (Value) &
            ASCII.ESC & "[0m" & ASCII.LF);
    end Report;

    procedure Report_S1 is new Report ("Fl_Slider FL_VERT_SLIDER");
    procedure Report_S2 is new Report ("Fl_Slider FL_VERT_FILL_SLIDER");
    procedure Report_S3 is new Report ("Fl_Slider FL_VERT_NICE_SLIDER");
    procedure Report_S4 is new Report ("Fl_Slider FL_HORIZONTAL");
    procedure Report_S5 is new Report ("Fl_Slider FL_HOR_FILL_SLIDER");
    procedure Report_S6 is new Report ("Fl_Slider FL_HOR_NICE_SLIDER");
    procedure Report_V1 is new Report ("FL_VERT_SLIDER");
    procedure Report_V2 is new Report ("Fl_Value_Slider FL_VERT_FILL_SLIDER");
    procedure Report_V3 is new Report ("Fl_Value_Slider FL_VERT_NICE_SLIDER");
    procedure Report_V4 is new Report ("Fl_Value_Slider FL_HOR_SLIDER");
    procedure Report_V5 is new Report ("Fl_Value_Slider FL_HOR_FILL_SLIDER");
    procedure Report_V6 is new Report ("Fl_Value_Slider FL_HOR_NICE_SLIDER");
    procedure Report_In is new Report ("Fl_Value_Input");
    --  FLTK gives the user data "Fl_Value_Output" to the output's group,
    --  not the output, so the output's callback would print "???".
    procedure Report_Out is new Report ("???");
    procedure Report_Bar1 is new Report ("Fl_Scrollbar FL_HORIZONTAL");
    procedure Report_Bar2 is new Report ("Fl_Scrollbar FL_VERTICAL");
    procedure Report_Adj1 is new Report ("Fl_Adjuster w()>h()");
    procedure Report_Adj2 is new Report ("Fl_Adjuster w()<h()");
    procedure Report_Cnt1 is new Report ("Fl_Counter");
    procedure Report_Cnt2 is new Report ("Fl_Counter FL_SIMPLE_COUNTER");
    procedure Report_Spn1 is new Report ("Fl_Spinner FL_INT_INPUT");
    procedure Report_Spn2 is new Report ("Fl_Spinner FL_FLOAT_INPUT");
    procedure Report_Dia1 is new Report ("Fl_Dial");
    procedure Report_Dia2 is new Report ("Fl_Dial FL_LINE_DIAL");
    procedure Report_Dia3 is new Report ("Fl_Dial FL_FILL_DIAL");
    procedure Report_Rol1 is new Report ("Fl_Roller FL_VERTICAL");
    procedure Report_Rol2 is new Report ("Fl_Roller FL_HORIZONTAL");


    procedure Frame
           (Item  : in out Grp.Group;
            Align : in     FLTK.Alignment := FLTK.Align_Top) is
    begin
        Item.Set_Box (FLTK.Engraved_Box);
        Item.Set_Label_Font (FLTK.Helvetica_Bold);
        Item.Set_Alignment (Align + FLTK.Align_Inside);
    end Frame;

    procedure Red
           (Item   : in out FLTK.Widgets.Widget'Class;
            Action : in     FLTK.Widgets.Widget_Callback) is
    begin
        Item.Set_Selection_Color (1);
        Item.Set_Label_Size (8);
        Item.Set_Callback (Action);
    end Red;

    procedure Green
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Item.Set_Box (FLTK.Flat_Box);
        Item.Set_Background_Color (10);
    end Green;

    procedure Small
           (Item   : in out FLTK.Widgets.Widget'Class;
            Tip    : in     String;
            Action : in     FLTK.Widgets.Widget_Callback) is
    begin
        if Tip /= "" then
            Item.Set_Tooltip (Tip);
        end if;
        Item.Set_Label_Size (8);
        Item.Set_Callback (Action);
    end Small;

    procedure Dial_Style
           (Item   : in out Dia.Dial;
            Tip    : in     String;
            Value  : in     Long_Float;
            Action : in     FLTK.Widgets.Widget_Callback) is
    begin
        Item.Set_Tooltip (Tip);
        Item.Set_Background_Color (10);
        Red (Item, Action);
        Item.Set_Value (Value);
    end Dial_Style;


begin

    W.Set_Background_Color (43);
    W.Set_Selection_Color (43);

    Frame (Sliders);
    S1.Set_Tooltip ("Vertical Slider");
    Red (S1, Report_S1'Unrestricted_Access);
    S1.Set_Alignment (FLTK.Align_Top);
    Red (S2, Report_S2'Unrestricted_Access);
    Green (S3);
    Red (S3, Report_S3'Unrestricted_Access);
    S3.Set_Alignment (FLTK.Align_Top);
    Red (S4, Report_S4'Unrestricted_Access);
    Red (S5, Report_S5'Unrestricted_Access);
    Green (S6);
    Red (S6, Report_S6'Unrestricted_Access);

    Frame (Value_Sliders);
    V1.Set_Tooltip ("Value Slider");
    Red (V1, Report_V1'Unrestricted_Access);
    V1.Set_Alignment (FLTK.Align_Top);
    Sld.Extra.Set_Kind (Sld.Slider (V2), Sld.Vertical_Fill_Slider);
    Red (V2, Report_V2'Unrestricted_Access);
    Sld.Extra.Set_Kind (Sld.Slider (V3), Sld.Vertical_Nice_Slider);
    Green (V3);
    Red (V3, Report_V3'Unrestricted_Access);
    V3.Set_Alignment (FLTK.Align_Top);
    Sld.Extra.Set_Kind (Sld.Slider (V4), Sld.Horizontal_Slider);
    Red (V4, Report_V4'Unrestricted_Access);
    Sld.Extra.Set_Kind (Sld.Slider (V5), Sld.Horizontal_Fill_Slider);
    Red (V5, Report_V5'Unrestricted_Access);
    Sld.Extra.Set_Kind (Sld.Slider (V6), Sld.Horizontal_Nice_Slider);
    Green (V6);
    Red (V6, Report_V6'Unrestricted_Access);

    Frame (Inputs);
    Small (In1, "Value Input", Report_In'Unrestricted_Access);
    In1.Set_Maximum (100.0);
    In1.Set_Step (0.1);

    Frame (Outputs);
    Small (Out1, "Value Output", Report_Out'Unrestricted_Access);
    Out1.Set_Maximum (100.0);
    Out1.Set_Step (0.1);

    Frame (Scrollbars, FLTK.Align_Top_Left);
    Small (Bar1, "Horizontal Scrollbar", Report_Bar1'Unrestricted_Access);
    Sld.Extra.Set_Kind (Sld.Slider (Bar1), Sld.Horizontal_Slider);
    Bar1.Set_Maximum (100.0);
    Bar1.Set_Value (20.0);
    Small (Bar2, "Vertical Scrollbar", Report_Bar2'Unrestricted_Access);
    Bar2.Set_Maximum (100.0);
    Bar2.Set_Value (20.0);
    Bar2.Set_Alignment (FLTK.Align_Left_Bottom);

    Frame (Adjusters);
    Small (Adj1, "Horizontal Adjuster", Report_Adj1'Unrestricted_Access);
    Small (Adj2, "Vertical Adjuster", Report_Adj2'Unrestricted_Access);

    Frame (Counters);
    Small (Cnt1, "Standard Counter", Report_Cnt1'Unrestricted_Access);
    Small (Cnt2, "Simple Counter", Report_Cnt2'Unrestricted_Access);
    Cnt.Extra.Set_Kind (Cnt2, Cnt.Simple_Counter);

    Frame (Spinners);
    Small (Spn1, "", Report_Spn1'Unrestricted_Access);
    Spn1.Set_Minimum (-30.0);
    Spn1.Set_Maximum (30.0);
    Spn1.Set_Step (2.0);
    Spn1.Set_Value (5.0);
    Spn1.Set_Alignment (FLTK.Align_Bottom);
    Spn2.Set_Kind (Spn.Float_Spin);
    Small (Spn2, "", Report_Spn2'Unrestricted_Access);
    Spn2.Set_Minimum (0.0);
    Spn2.Set_Maximum (1.0);
    Spn2.Set_Step (0.01);
    Spn2.Set_Value (0.05);
    Spn2.Set_Alignment (FLTK.Align_Bottom);
    Spn2.Set_Wrap (False);

    Frame (Dials);
    Dial_Style (Dia1, "Standard Dial", 0.5, Report_Dia1'Unrestricted_Access);
    Dia1.Set_Angles (0, 315);
    Dia.Extra.Set_Kind (Dia2, Dia.Line_Dial);
    Dial_Style (Dia2, "Line Dial", 0.5, Report_Dia2'Unrestricted_Access);
    Dia.Extra.Set_Kind (Dia3, Dia.Fill_Dial);
    Dial_Style (Dia3, "Fill Dial", 1.0, Report_Dia3'Unrestricted_Access);
    Dia3.Set_Angles (0, 360);

    Frame (Rollers);
    Small (Rol1, "Vertical Roller", Report_Rol1'Unrestricted_Access);
    Small (Rol2, "Horizontal Roller", Report_Rol2'Unrestricted_Access);
    Rol2.Set_Kind (Rol.Horizontal_Roller);

    Note.Set_Box (FLTK.Border_Frame);
    Note.Set_Background_Color (FLTK.Foreground_Color);
    Note.Set_Selection_Color (FLTK.Foreground_Color);
    Note.Set_Label_Size (11);
    Note.Set_Alignment (FLTK.Align_Wrap);

    TTY.Set_ANSI (True);

    W.Show_With_Args;

    return FLTK.Run;

end Valuators;
