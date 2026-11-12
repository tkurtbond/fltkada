--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/contrast.cxx: FLTK.Contrast's algorithms, on the 256
--  colours of FLTK's colormap.  Each field is drawn in its colour, with
--  its number in the label colour the sliders choose, as Contrast makes
--  it show, and a strip of that colour unchanged.  Radio buttons choose
--  the algorithm, sliders its level and the label size, a colour chooser
--  the last field's colour, and a click on a field writes its lightness
--  and contrast to the terminal.  FLTK's contrast() passes the label size
--  as its context argument, and so does this.  The fields are allocated,
--  in FLTK's order, and freed after the event loop.  Guided by pofltk's
--  Contrast.Mod.


with

    Ada.Long_Float_Text_IO,
    Ada.Numerics.Discrete_Random,
    Ada.Strings.Fixed,
    Ada.Unchecked_Deallocation,
    FLTK.Draw,
    FLTK.Static,
    FLTK.Widgets.Buttons.Light.Round.Radio,
    FLTK.Widgets.Groups.Color_Choosers,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Outputs,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Alignment,
    FLTK.Color,
    FLTK.Contrast_Mode,
    FLTK.Version_Number;


function Contrast
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Rad renames FLTK.Widgets.Buttons.Light.Round.Radio;
    package Grp renames FLTK.Widgets.Groups;
    package CC  renames FLTK.Widgets.Groups.Color_Choosers;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Opt renames FLTK.Widgets.Inputs.Text.Outputs;
    package HVS renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    --  program version
    Version : constant String := "0.9.1";


    --  printf's "%0Nx" (or "%0NX"), of Width digits.
    function Hex
           (Value : in FLTK.Color;
            Width : in Positive;
            Upper : in Boolean := False)
        return String
    is
        Digit  : constant String :=
            (if Upper then "0123456789ABCDEF" else "0123456789abcdef");
        Result : String (1 .. Width);
        V      : FLTK.Color := Value;
    begin
        for I in reverse Result'Range loop
            Result (I) := Digit (Integer (V mod 16) + 1);
            V := V / 16;
        end loop;
        return Result;
    end Hex;


    --  printf's "%W.2f".
    function Real
           (Value : in Long_Float;
            Width : in Positive)
        return String
    is
        Result : String (1 .. Width);
    begin
        Ada.Long_Float_Text_IO.Put (Result, Value, Aft => 2, Exp => 0);
        return Result;
    end Real;


    --  printf's "%Nd" with N = Width, or "%0Nd".
    function Int
           (Value : in Integer;
            Width : in Positive;
            Zero  : in Boolean := False)
        return String
    is
        Text : constant String := Ada.Strings.Fixed.Trim (Value'Image, Ada.Strings.Left);
    begin
        if Text'Length >= Width then
            return Text;
        else
            return (1 .. Width - Text'Length => (if Zero then '0' else ' ')) & Text;
        end if;
    end Int;


    --  global variables

    G_Lfg   : Long_Float := 0.0;  --  perceived lightness of foreground color
    G_Lbg   : Long_Float := 0.0;  --  perceived lightness of background color
    G_Lcref : Long_Float := 0.0;  --  calculated contrast reference (CIELAB, L*a*b*)

    G_Selected : Integer := -1;  --  selected button: -1 = none, 0 - 255 = valid button

    G_Fs    : FLTK.Font_Size := 15;  --  fontsize for button labels
    G_Level : Integer := 0;          --  *init* contrast level (sensitivity)

    G_Algo : FLTK.Contrast_Mode := FLTK.CIELAB_Contrast;  --  contrast algorithm

    --  algorithm as text: "LEGACY", "CIELAB" , or "CUSTOM"
    Alch : access constant String := null;

    None_Name   : aliased constant String := "none  ";
    Legacy_Name : aliased constant String := "LEGACY";
    CIELAB_Name : aliased constant String := "CIELAB";
    Custom_Name : aliased constant String := "CUSTOM";
    Empty_Name  : aliased constant String := "";

    Lcolor : FLTK.Color := FLTK.Black_Color;  --  label color, set by slider callback


    --  Custom contrast algorithm: currently a dummy function (returns fg).
    --  This may be used to define a "better" contrast function in user code
    function Custom_Contrast
           (Fore, Back    : in FLTK.Color;
            Context, Size : in Integer)
        return FLTK.Color
    is
        pragma Unreferenced (Back, Context, Size);
    begin
        return Fore;
    end Custom_Contrast;


    --  Local function to calculate the contrast and store it in some
    --  global variables for display purposes and logging.
    --  This function is a wrapper around FLTK.Contrast in this demo program.
    function Calc_Contrast
           (Fg, Bg : in FLTK.Color;
            Fs     : in FLTK.Font_Size)
        return FLTK.Color is
    begin
        --  Compute and set global *perceived* lightness L* (Lstar) and
        --  contrast for display
        G_Lfg   := FLTK.Lightness (Fg);
        G_Lbg   := FLTK.Lightness (Bg);
        G_Lcref := G_Lfg - G_Lbg;  --  perceived contrast (light on dark = positive)

        --  every mode: FLTK.Contrast's context is the font size, as in FLTK
        return FLTK.Contrast (Fg, Bg, Integer (Fs));
    end Calc_Contrast;


    --  class Button

    type Button is new Btn.Button with record
        Lbuf : String (1 .. 3);                --  private label buffer
        Ocol : FLTK.Color := FLTK.Black_Color;  --  "original" (label) color
        Idx  : Natural := 0;                    --  button index (0 - 255)
    end record;

    overriding procedure Draw
           (This : in out Button);

    procedure Set_Labelcolor
           (This : in out Button;
            Col  : in     FLTK.Color) is
    begin
        This.Ocol := Col;
        This.Set_Label_Color (Calc_Contrast (Col, This.Get_Background_Color, This.Get_Label_Size));
    end Set_Labelcolor;

    procedure Draw
           (This : in out Button)
    is
        Lw, Lh : Natural := 0;
    begin
        This.Draw_Box;
        --  draw small filled rectangle with "original" color
        FLTK.Draw.Set_Color (This.Ocol);
        FLTK.Draw.Rect_Fill (This.Get_X + 5, This.Get_Y + 5, 10, This.Get_H - 10);
        --  measure and draw label
        FLTK.Draw.Set_Font (This.Get_Label_Font, This.Get_Label_Size);
        FLTK.Draw.Measure (This.Lbuf, Lw, Lh);
        FLTK.Draw.Set_Color (This.Get_Label_Color);
        FLTK.Draw.Draw_Text
           (This.Get_X + 15 + (This.Get_W - Lw - 15) / 2,
            This.Get_Y + This.Get_H - (This.Get_H - Lh) / 2 - Lh / 4,
            This.Lbuf);
        FLTK.Draw.Set_Color (FLTK.Black_Color);
    end Draw;

    type Button_Access is access Button;

    procedure Free is new Ada.Unchecked_Deallocation (Button, Button_Access);

    Buttons : array (0 .. 255) of Button_Access;  --  array of color buttons


    --  set all button label colors and adjust fontsize (labelsize)
    procedure Update_Labels is
    begin
        for B of Buttons loop
            Set_Labelcolor (B.all, Lcolor);
            B.Set_Label_Size (G_Fs);
        end loop;
    end Update_Labels;


    Bw : constant := 58;
    Bh : constant := 30;
    Cw : constant := 16 * Bw + 10;
    Ch : constant := 16 * Bh + 10;
    Ww : constant := Cw + 10;
    Wh : constant := 16 * Bh + 135 + 10 + 170 + 10;  --  170 for the terminal

    Window : Dbl.Double_Window := Dbl.Forge.Create (Ww, Wh, "fl_contrast test");

begin

    declare
        N : Natural := 0;
    begin
        for Y in 0 .. 15 loop
            for X in 0 .. 15 loop
                Buttons (N) := new Button'
                   (Btn.Forge.Create (Window, X * Bw + 10, Y * Bh + 10, Bw, Bh, "")
                    with Lbuf => Int (N, 3, Zero => True), Ocol => FLTK.Black_Color, Idx => N);
                declare
                    B : Button renames Buttons (N).all;
                begin
                    B.Set_Box (FLTK.Thin_Down_Box);
                    B.Set_Label (B.Lbuf);
                    B.Set_Background_Color (FLTK.Color (N));
                    Set_Labelcolor (B, FLTK.Color (N));
                    B.Set_Label_Size (15);
                    B.Set_Label_Font (FLTK.Helvetica);
                    Set_Labelcolor (B, FLTK.Color (N));
                end;
                N := N + 1;
            end loop;
        end loop;
    end;

    declare

        --  sliders for label color (gray, red, green, blue)

        Sx : constant := 10 + Bw;
        Sw : constant := 5 * Bw;
        Sh : constant := 25;

        Gray  : HVS.Horizontal_Value_Slider :=
            HVS.Forge.Create (Window, Sx, Ch + 10, Sw, Sh, "gray");
        Red   : HVS.Horizontal_Value_Slider :=
            HVS.Forge.Create (Window, Sx, Ch + 10 + Sh + 10, Sw, Sh, "red");
        Green : HVS.Horizontal_Value_Slider :=
            HVS.Forge.Create (Window, Sx, Ch + 10 + 2 * Sh + 15, Sw, Sh, "green");
        Blue  : HVS.Horizontal_Value_Slider :=
            HVS.Forge.Create (Window, Sx, Ch + 10 + 3 * Sh + 20, Sw, Sh, "blue");

        --  contrast algorithm selection group

        Cgx : constant := 10 + 6 * Bw + 10;
        Cgy : constant := Ch + 30;
        Cgw : constant := 90;
        Cgh : constant := 100;
        Abh : constant := 25;

        Cg   : Grp.Group := Grp.Forge.Create (Window, Cgx, Cgy, Cgw, Cgh, "fl_contrast:");
        Anon : Rad.Radio_Round_Button := Rad.Forge.Create (Cg, Cgx, Cgy, Cgw, Abh, "none");
        Aleg : Rad.Radio_Round_Button :=
            Rad.Forge.Create (Cg, Cgx, Cgy + 25, Cgw, Abh, "LEGACY");
        Acie : Rad.Radio_Round_Button :=
            Rad.Forge.Create (Cg, Cgx, Cgy + 50, Cgw, Abh, "CIELAB");
        Aapc : Rad.Radio_Round_Button :=
            Rad.Forge.Create (Cg, Cgx, Cgy + 75, Cgw, Abh, "CUSTOM");

        Color_Out : Opt.Output :=
            Opt.Forge.Create (Window, 10 + 10 * Bw, Ch + 10, 100, 30, "label color:");

        --  light blue "level" slider
        S_Level : HVS.Horizontal_Value_Slider :=
            HVS.Forge.Create (Window, 10 + 9 * Bw, Red.Get_Y, 3 * Bw - 15, Sh, "level");

        --  labelsize slider
        S_Fs : HVS.Horizontal_Value_Slider :=
            HVS.Forge.Create (Window, 10 + 9 * Bw, Green.Get_Y, 3 * Bw - 15, Sh, "labelsize");

        --  line feed (LF) button
        Lf : Btn.Button := Btn.Forge.Create (Window, 10 + 8 * Bw, Blue.Get_Y, Bw, Sh, "LF");

        --  random color (R) button
        Rc : Btn.Button :=
            Btn.Forge.Create (Window, 10 + 8 * Bw + Bw + 2, Blue.Get_Y, Bw * 3 / 4, Sh, "&RC");

        --  color chooser for field #255
        Ccx : constant := 10 + 12 * Bw;
        Ccy : constant := Ch + 10;
        Ccw : constant := 4 * Bw;
        Cch : constant := 120;

        Color_Chooser : CC.Color_Chooser := CC.Forge.Create (Window, Ccx, Ccy, Ccw, Cch);

        --  Fl_Terminal for output
        Ttx : constant Integer := 10;
        Tty : constant Integer := Color_Chooser.Get_Y + Cch + 10;
        Ttw : constant Integer := Window.Get_W - 20;
        Tth : constant Integer := Window.Get_H - Tty - 10;

        Term : Trm.Terminal := Trm.Forge.Create (Window, Ttx, Tty, Ttw, Tth);


        procedure Button_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            B     : Button renames Button (Item);
            --  button's "original" label color (RGB0)
            Ocol  : constant FLTK.Color := FLTK.Static.Get_Color (B.Ocol);
            --  button's label color (RGB0)
            Fg    : constant FLTK.Color := FLTK.Static.Get_Color (B.Get_Label_Color);
            --  button's background color (RGB0)
            Bg    : constant FLTK.Color := FLTK.Static.Get_Color (B.Get_Background_Color);
            --  calculate values to be displayed
            Dummy : constant FLTK.Color := Calc_Contrast (Ocol, Bg, G_Fs);
            Color : access constant String := Empty_Name'Access;  --  calculated label color (text)
            White : aliased constant String := "WHITE";
            Black : aliased constant String := "BLACK";
            Fg_Name : aliased constant String := "fg";
            pragma Unreferenced (Dummy);
        begin
            G_Selected := B.Idx;  --  selected button index
            if Fg = Ocol then
                Color := Fg_Name'Unchecked_Access;
            elsif Fg = 16#ffffff00# then
                Color := White'Unchecked_Access;
            elsif Fg = 0 then
                Color := Black'Unchecked_Access;
            end if;
            Term.Append
               ("[" & B.Lbuf & "] fg: " & Hex (Ocol / 256, 6) & ", bg: " & Hex (Bg / 256, 6) &
                ", lfg: " & Real (G_Lfg, 6) & ", lbg: " & Real (G_Lbg, 6) &
                ", lc: " & Real (G_Lcref, 7) & ", " & Alch.all & " => " &
                Ada.Strings.Fixed.Head (Color.all, 5));
            if G_Algo = FLTK.Legacy_Contrast or G_Algo = FLTK.CIELAB_Contrast then
                Term.Append (" (level = " & Int (G_Level, 3) & ")" & ASCII.LF);
            else
                Term.Append ((1 => ASCII.LF));
            end if;
        end Button_CB;


        procedure Lf_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            Term.Append ((1 => ASCII.LF));
        end Lf_CB;


        --  output label color
        procedure Show_Color
               (R, G, B : in Natural) is
        begin
            Color_Out.Set_Value
               (Hex (FLTK.Color (R), 2, True) & " " & Hex (FLTK.Color (G), 2, True) & " " &
                Hex (FLTK.Color (B), 2, True));
        end Show_Color;


        --  callbacks for color (gray and R, G, B) sliders

        procedure Gray_Slider_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            Val : constant Natural := Natural (Long_Float'Truncation (Gray.Get_Value));
        begin
            Lcolor := FLTK.RGB_Color
               (FLTK.Color_Component (Val), FLTK.Color_Component (Val),
                FLTK.Color_Component (Val));  --  set gray value
            Red.Set_Value (Long_Float (Val));  --  set r/g/b values as well
            Green.Set_Value (Long_Float (Val));
            Blue.Set_Value (Long_Float (Val));
            --  update button label colors
            Update_Labels;
            Show_Color (Val, Val, Val);
            Window.Redraw;
        end Gray_Slider_CB;

        procedure Color_Slider_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            R : constant Natural := Natural (Long_Float'Truncation (Red.Get_Value));
            G : constant Natural := Natural (Long_Float'Truncation (Green.Get_Value));
            B : constant Natural := Natural (Long_Float'Truncation (Blue.Get_Value));
        begin
            Lcolor := FLTK.RGB_Color
               (FLTK.Color_Component (R), FLTK.Color_Component (G),
                FLTK.Color_Component (B));  --  set color value
            --  update button label colors
            Update_Labels;
            Show_Color (R, G, B);
            Window.Redraw;
        end Color_Slider_CB;


        --  callbacks for "level" and "fontsize" sliders

        procedure Level_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            G_Level := Integer (Long_Float'Truncation (S_Level.Get_Value));
            FLTK.Static.Set_Contrast_Level (G_Level);  --  set/store current contrast level
            --  update button label colors
            Update_Labels;
            Window.Redraw;
        end Level_CB;

        procedure Fs_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            G_Fs := FLTK.Font_Size (Long_Float'Truncation (S_Fs.Get_Value));
            --  update button label colors
            Update_Labels;
            Window.Redraw;
        end Fs_CB;


        --  callback for the "random color" button

        subtype Component is Integer range 0 .. 255;

        package Random_Component is new Ada.Numerics.Discrete_Random (Component);

        Gen   : Random_Component.Generator;
        First : Boolean := True;

        procedure Rc_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            R, G, B : Natural;
        begin
            if First then
                --  Seed the random number generator...
                Random_Component.Reset (Gen);
                First := False;
                R := 0;  --  initialize with black
                G := 0;
                B := 0;
            else
                R := Random_Component.Random (Gen);
                G := Random_Component.Random (Gen);
                B := Random_Component.Random (Gen);
            end if;

            Red.Set_Value (Long_Float (R));
            Green.Set_Value (Long_Float (G));
            Blue.Set_Value (Long_Float (B));

            --  update button label colors
            Lcolor := FLTK.RGB_Color
               (FLTK.Color_Component (R), FLTK.Color_Component (G),
                FLTK.Color_Component (B));  --  set color value
            Update_Labels;
            Show_Color (R, G, B);
            Window.Redraw;
        end Rc_CB;


        --  callback for contrast algorithm (radio buttons)

        procedure Algo
               (Val : in FLTK.Contrast_Mode) is
        begin
            G_Algo := Val;
            case Val is
                when FLTK.Legacy_Contrast => Alch := Legacy_Name'Access;  --  legacy 1.3.x
                when FLTK.CIELAB_Contrast => Alch := CIELAB_Name'Access;  --  CIELAB L*a*b*
                when FLTK.Custom_Contrast => Alch := Custom_Name'Access;  --  custom
                when FLTK.No_Contrast     => Alch := None_Name'Access;
            end case;
            FLTK.Static.Set_Contrast_Mode (Val);
            G_Level := FLTK.Static.Get_Contrast_Level;  --  get current contrast level (per mode)
            S_Level.Set_Value (Long_Float (G_Level));   --  set level slider value
            Update_Labels;                              --  update all button labels

            --  print selected button's attributes
            if G_Selected >= 0 then
                Button_CB (Buttons (G_Selected).all);
            end if;
            Window.Redraw;
        end Algo;

        procedure Algo_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            if Item.Get_Label = "none" then
                Algo (FLTK.No_Contrast);
            elsif Item.Get_Label = "LEGACY" then
                Algo (FLTK.Legacy_Contrast);
            elsif Item.Get_Label = "CIELAB" then
                Algo (FLTK.CIELAB_Contrast);
            else
                Algo (FLTK.Custom_Contrast);
            end if;
        end Algo_CB;


        --  color chooser callback
        procedure Color_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            Chooser : CC.Color_Chooser renames CC.Color_Chooser (Item);
            R  : constant Integer := Integer (Long_Float'Truncation (Chooser.Get_Red * 255.0));
            G  : constant Integer := Integer (Long_Float'Truncation (Chooser.Get_Green * 255.0));
            B  : constant Integer := Integer (Long_Float'Truncation (Chooser.Get_Blue * 255.0));
            C  : constant FLTK.Color := FLTK.RGB_Color
               (FLTK.Color_Component (R), FLTK.Color_Component (G), FLTK.Color_Component (B));
            Bt : Button renames Buttons (255).all;  --  last button
        begin
            Bt.Set_Background_Color (C);
            Set_Labelcolor (Bt, Lcolor);
            Bt.Redraw;
        end Color_CB;


        procedure Setup
               (Slider     : in out HVS.Horizontal_Value_Slider;
                Background : in     FLTK.Color;
                Text_Color : in     FLTK.Color;
                Max        : in     Long_Float) is
        begin
            Slider.Set_Background_Color (Background);
            Slider.Set_Text_Color (Text_Color);
            Slider.Set_Text_Size (13);
            Slider.Set_Alignment (FLTK.Align_Left);
            Slider.Set_Value (0.0);
            Slider.Set_Bounds (0.0, Max);
            Slider.Set_Step (1);
        end Setup;

    begin

        for B of Buttons loop
            B.Set_Callback (Button_CB'Unrestricted_Access);
        end loop;

        Setup (Gray, 16#dddddd00#, FLTK.Black_Color, 255.0);
        Gray.Set_Callback (Gray_Slider_CB'Unrestricted_Access);
        Setup (Red, FLTK.Red_Color, FLTK.White_Color, 255.0);
        Red.Set_Callback (Color_Slider_CB'Unrestricted_Access);
        Setup (Green, FLTK.Green_Color, FLTK.Black_Color, 255.0);
        Green.Set_Callback (Color_Slider_CB'Unrestricted_Access);
        Setup (Blue, FLTK.Blue_Color, FLTK.White_Color, 255.0);
        Blue.Set_Callback (Color_Slider_CB'Unrestricted_Access);

        Cg.Set_Alignment (FLTK.Align_Top);
        Cg.Set_Box (FLTK.Engraved_Frame);
        Acie.Set_State (Btn.On);
        Anon.Set_Callback (Algo_CB'Unrestricted_Access);
        Aleg.Set_Callback (Algo_CB'Unrestricted_Access);
        Acie.Set_Callback (Algo_CB'Unrestricted_Access);
        Aapc.Set_Callback (Algo_CB'Unrestricted_Access);
        Cg.End_Current;

        Color_Out.Set_Alignment (FLTK.Align_Left);
        Color_Out.Set_Text_Font (FLTK.Courier);
        Color_Out.Set_Text_Size (16);
        Color_Out.Set_Value ("00 00 00");

        S_Level.Set_Background_Color (231);
        S_Level.Set_Text_Color (224);
        S_Level.Set_Text_Size (13);
        S_Level.Set_Alignment (FLTK.Align_Left);
        S_Level.Set_Step (1);
        S_Level.Set_Bounds (0.0, 100.0);
        S_Level.Set_Value (Long_Float (G_Level));
        S_Level.Set_Callback (Level_CB'Unrestricted_Access);
        S_Level.Set_Tooltip ("set contrast sensitivity level (0-100), default: 50");

        S_Fs.Set_Background_Color (231);
        S_Fs.Set_Text_Color (224);
        S_Fs.Set_Text_Size (13);
        S_Fs.Set_Alignment (FLTK.Align_Left);
        S_Fs.Set_Step (1);
        S_Fs.Set_Bounds (8.0, 24.0);
        S_Fs.Set_Value (15.0);
        S_Fs.Set_Callback (Fs_CB'Unrestricted_Access);
        S_Fs.Set_Tooltip ("set label/text fontsize");

        Lf.Set_Tooltip ("Click to output a linefeed to the log.");
        Lf.Set_Callback (Lf_CB'Unrestricted_Access);

        Rc.Set_Tooltip ("Click to select a random text color.");
        Rc.Set_Callback (Rc_CB'Unrestricted_Access);

        Color_Chooser.Set_Callback (Color_CB'Unrestricted_Access);
        Color_Chooser.Set_Label ("bg color [255] @->");
        Color_Chooser.Set_RGB (1.0, 1.0, 1.0);
        Color_Chooser.Set_Mode (CC.Byte);  --  byte mode
        Color_Chooser.Set_Alignment (FLTK.Align_Left_Bottom);

        --  set contrast mode and level, update button label colors

        FLTK.Static.Set_Contrast_Mode (G_Algo);
        --  dummy contrast function
        FLTK.Static.Set_Contrast_Function (Custom_Contrast'Unrestricted_Access);
        Algo (FLTK.CIELAB_Contrast);

        Term.Set_Background_Color (FLTK.White_Color);
        Term.Set_Text_Fore_Color (FLTK.Black_Color);
        Term.Set_Text_Size (13);

        declare
            V : constant Integer := Integer (FLTK.Built_API_Version);
        begin
            Term.Append
               ("FLTK" & Integer'Image (V / 10000) & "." & Int ((V / 100) mod 100, 1) & "." &
                Int (V mod 100, 1) &
                " fl_contrast() test program with different contrast algorithms, version " &
                Version & ASCII.LF);
        end;
        Term.Append (" - Select a foreground (text) color with the gray or red/green/blue " &
            "sliders (displayed inside each field)." & ASCII.LF);
        Term.Append (" - Select an arbitrary background color for field #255 with the " &
            "color chooser." & ASCII.LF);
        Term.Append (" - Select a colored field (by clicking on it) to display its " &
            "attributes." & ASCII.LF);
        Term.Append (" - Select the contrast algorithm by clicking on the radio buttons." &
            ASCII.LF);
        Term.Append (" - Tune the contrast algorithm with the light blue ""level"" slider " &
            "(default: " & Int (FLTK.Static.Get_Contrast_Level, 1) & ")." & ASCII.LF);
        Term.Append (" - Select a random foreground (text) color by clicking the RC button" &
            ASCII.LF);

        Window.Set_Resizable (Term);
        Window.End_Current;
        Window.Show_With_Args;
        Rc_CB (Rc);  --  update button labels - must be called after show()

        return Result : constant Integer := FLTK.Run do
            for B of reverse Buttons loop
                Free (B);
            end loop;
        end return;

    end;

end Contrast;

