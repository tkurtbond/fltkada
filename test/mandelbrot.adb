--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/mandelbrot.cxx: the Mandelbrot set, and the Julia set of a
--  point in it, each worked out and drawn a line at a time when FLTK is
--  idle.  A left click zooms out, and a box dragged with the left button
--  zooms in.  A right click shows the Julia set of the point clicked, in a
--  second window.  Ctrl-M switches between grey and colour, and Ctrl-P
--  prints the window.
--
--  The coordinates and the window's title are written as the C++ writes
--  them, with C's snprintf, since Ada's Put rounds a value exactly halfway
--  away from zero and printf rounds it to even: %.2g of the Julia window's
--  width 0.125 is 0.12.  The inputs are read as C's atof reads them,
--  except that something that isn't a number at all, such as "-", is 0.


with

    Ada.Command_Line,
    Ada.Unchecked_Deallocation,
    Interfaces.C,
    FLTK.Devices.Surface.Paged.Printers,
    FLTK.Draw,
    FLTK.Errors,
    FLTK.Events,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text.Floating_Point,
    FLTK.Widgets.Valuators.Sliders.Horizontal;

use type

    FLTK.Alignment,
    FLTK.Callback_Flag,
    FLTK.Color,
    FLTK.Modifier,
    FLTK.Mouse_Button,
    FLTK.Size_Type;


function Mandelbrot
    return Integer
is


    package C   renames Interfaces.C;
    package Prn renames FLTK.Devices.Surface.Paged.Printers;
    package Drw renames FLTK.Draw;
    package Ev  renames FLTK.Events;
    package Wdg renames FLTK.Widgets;
    package Box renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Flt renames FLTK.Widgets.Inputs.Text.Floating_Point;
    package Hor renames FLTK.Widgets.Valuators.Sliders.Horizontal;


    Max_Brightness     : constant := 16;
    Default_Brightness : constant := 16;
    Max_Iterations     : constant := 14;
    Default_Iterations : constant := 7;


    type Palette_Array is array (Natural range <>) of FLTK.Color;

    Palette : constant Palette_Array :=
       (16#CC0000#, 16#CA0002#, 16#C90004#, 16#C70006#, 16#C60008#, 16#C4000A#, 16#C3000C#,
        16#C1000E#, 16#BF0010#, 16#BE0012#, 16#BC0014#, 16#BB0016#, 16#B90018#, 16#B8001A#,
        16#B6001B#, 16#B4001D#, 16#B3001F#, 16#B10021#, 16#B00023#, 16#AE0025#, 16#AD0027#,
        16#AB0029#, 16#A9002B#, 16#A8002D#, 16#A6002F#, 16#A50031#, 16#A30033#, 16#A20035#,
        16#A00037#, 16#9E0039#, 16#9D003B#, 16#9B003D#, 16#9A003F#, 16#980041#, 16#970043#,
        16#950045#, 16#940047#, 16#920049#, 16#90004B#, 16#8F004D#, 16#8D004E#, 16#8C0050#,
        16#8A0052#, 16#890054#, 16#870056#, 16#850058#, 16#84005A#, 16#82005C#, 16#81005E#,
        16#7F0060#, 16#7E0062#, 16#7C0064#, 16#7A0066#, 16#790068#, 16#77006A#, 16#76006C#,
        16#74006E#, 16#730070#, 16#710072#, 16#6F0074#, 16#6E0076#, 16#6C0078#, 16#6B007A#,
        16#69007C#, 16#68007E#, 16#660080#, 16#640081#, 16#630083#, 16#610085#, 16#600087#,
        16#5E0089#, 16#5D008B#, 16#5B008D#, 16#59008F#, 16#580091#, 16#560093#, 16#550095#,
        16#530097#, 16#520099#, 16#50009B#, 16#4E009D#, 16#4D009F#, 16#4B00A1#, 16#4A00A3#,
        16#4800A5#, 16#4700A7#, 16#4500A9#, 16#4300AB#, 16#4200AD#, 16#4000AF#, 16#3F00B1#,
        16#3D00B3#, 16#3C00B4#, 16#3A00B6#, 16#3800B8#, 16#3700BA#, 16#3500BC#, 16#3400BE#,
        16#3200C0#, 16#3100C2#, 16#2F00C4#, 16#2E00C6#, 16#2C00C8#, 16#2A00CA#, 16#2900CC#,
        16#2700CE#, 16#2600D0#, 16#2400D2#, 16#2300D4#, 16#2100D6#, 16#1F00D8#, 16#1E00DA#,
        16#1C00DC#, 16#1B00DE#, 16#1900E0#, 16#1800E2#, 16#1600E4#, 16#1400E6#, 16#1300E7#,
        16#1100E9#, 16#1000EB#, 16#0E00ED#, 16#0D00EF#, 16#0B00F1#, 16#0900F3#, 16#0800F5#,
        16#0600F7#, 16#0500F9#, 16#0300FB#, 16#0200FD#, 16#0000FF#, 16#0202FD#, 16#0404FB#,
        16#0606F9#, 16#0808F7#, 16#0A0AF5#, 16#0C0CF3#, 16#0E0EF1#, 16#1010EF#, 16#1212ED#,
        16#1414EB#, 16#1616E9#, 16#1818E7#, 16#1A1AE6#, 16#1B1BE4#, 16#1D1DE2#, 16#1F1FE0#,
        16#2121DE#, 16#2323DC#, 16#2525DA#, 16#2727D8#, 16#2929D6#, 16#2B2BD4#, 16#2D2DD2#,
        16#2F2FD0#, 16#3131CE#, 16#3333CC#, 16#3535CA#, 16#3737C8#, 16#3939C6#, 16#3B3BC4#,
        16#3D3DC2#, 16#3F3FC0#, 16#4141BE#, 16#4343BC#, 16#4545BA#, 16#4747B8#, 16#4949B6#,
        16#4B4BB4#, 16#4D4DB3#, 16#4E4EB1#, 16#5050AF#, 16#5252AD#, 16#5454AB#, 16#5656A9#,
        16#5858A7#, 16#5A5AA5#, 16#5C5CA3#, 16#5E5EA1#, 16#60609F#, 16#62629D#, 16#64649B#,
        16#666699#, 16#686897#, 16#6A6A95#, 16#6C6C93#, 16#6E6E91#, 16#70708F#, 16#72728D#,
        16#74748B#, 16#767689#, 16#787887#, 16#7A7A85#, 16#7C7C83#, 16#7E7E81#, 16#808080#,
        16#81817E#, 16#83837C#, 16#85857A#, 16#878778#, 16#898976#, 16#8B8B74#, 16#8D8D72#,
        16#8F8F70#, 16#91916E#, 16#93936C#, 16#95956A#, 16#979768#, 16#999966#, 16#9B9B64#,
        16#9D9D62#, 16#9F9F60#, 16#A1A15E#, 16#A3A35C#, 16#A5A55A#, 16#A7A758#, 16#A9A956#,
        16#ABAB54#, 16#ADAD52#, 16#AFAF50#, 16#B1B14E#, 16#B3B34D#, 16#B4B44B#, 16#B6B649#,
        16#B8B847#, 16#BABA45#, 16#BCBC43#, 16#BEBE41#, 16#C0C03F#, 16#C2C23D#, 16#C4C43B#,
        16#C6C639#, 16#C8C837#, 16#CACA35#, 16#CCCC33#, 16#CECE31#, 16#D0D02F#, 16#D2D22D#,
        16#D4D42B#, 16#D6D629#, 16#D8D827#, 16#DADA25#, 16#DCDC23#, 16#DEDE21#, 16#E0E01F#,
        16#E2E21D#, 16#E4E41B#, 16#E6E61A#, 16#E7E718#, 16#E9E916#, 16#EBEB14#, 16#EFEF10#,
        16#F3F30C#, 16#F7F708#, 16#FBFB04#, 16#FFFF00#);


    --  The colour of a point that escaped, with T from 0 to 1.
    procedure Get_Color
           (T       : in     Float;
            R, G, B :    out FLTK.Color_Component)
    is
        Index : constant Natural :=
            Natural (Float'Truncation ((1.0 - T) * Float (Palette'Length)));
    begin
        FLTK.Static.Get_Color (Palette (Index mod Palette'Length) * 256, R, G, B);
    end Get_Color;


    --  Value as snprintf writes it in Format, which takes one double.
    function Image
           (Format : in String;
            Value  : in Long_Float)
        return String
    is
        use type C.int, C.size_t;
        function snprintf
               (Buffer : out C.char_array;
                Size   : in  C.size_t;
                Format : in  C.char_array;
                Value  : in  C.double)
            return C.int
        with Import, Convention => C_Variadic_3, External_Name => "snprintf";
        Buffer : C.char_array (0 .. 127);
        Length : constant C.int :=
            snprintf (Buffer, Buffer'Length, C.To_C (Format), C.double (Value));
    begin
        if Length < 0 or else C.size_t (Length) >= Buffer'Length then
            raise Constraint_Error with "Image of " & Format;
        end if;
        return C.To_Ada (Buffer);
    end Image;




    --  The Drawing Area  --

    type Buffer_Access is access FLTK.Color_Component_Array;

    procedure Free is new Ada.Unchecked_Deallocation (FLTK.Color_Component_Array, Buffer_Access);

    type Drawing_Window;
    type Window_Reference is access all Drawing_Window;

    type Drawing_Area is new Box.Box with record
        Owner      : Window_Reference;
        Buffer     : Buffer_Access;
        Use_Colors : Boolean := False;
        W, H       : Integer;  --  the picture's size
        DX, DY     : Integer := 0;  --  drawing box offsets
        DW, DH     : Integer := 0;
        Next_Line  : Integer := 0;
        Drawn      : Integer := 0;
        Julia      : Boolean := False;
        Iterations : Integer := 2 ** Default_Iterations;
        Brightness : Integer := Default_Brightness;
        JX, JY     : Long_Float := 0.0;
        X, Y       : Long_Float := 0.0;
        Scale      : Long_Float := 4.0;
        SX, SY     : Integer := 0;  --  selection box
        SW, SH     : Integer := 0;
    end record;

    overriding procedure Draw
           (This : in out Drawing_Area);

    overriding function Handle
           (This  : in out Drawing_Area;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    overriding procedure Resize
           (This       : in out Drawing_Area;
            X, Y, W, H : in     Integer);


    type Coordinate is (X_Coordinate, Y_Coordinate, Width);

    type Coordinate_Input is new Flt.Float_Input with record
        Owner : Window_Reference;
        Which : Coordinate;
    end record;

    type Control is (Brightness, Iterations);

    type Control_Slider is new Hor.Horizontal_Slider with record
        Owner : Window_Reference;
        Which : Control;
    end record;

    type Window_Access is access Win.Window;
    type Area_Access is access Drawing_Area;
    type Input_Access is access Coordinate_Input;
    type Slider_Access is access Control_Slider;
    type Box_Access is access Box.Box;
    type Button_Access is access Btn.Button;

    type Input_Array is array (Coordinate) of Input_Access;
    type Slider_Array is array (Control) of Slider_Access;

    type Drawing_Window is record
        Window  : Window_Access;
        D       : Area_Access;
        Inputs  : Input_Array;
        Sliders : Slider_Array;
        Help    : Box_Access;
        Print   : Button_Access;  --  the Ctrl-P and Ctrl-M buttons, in Mbrot only
        Toggle  : Button_Access;
    end record;

    Mbrot, Jbrot : aliased Drawing_Window;


    procedure Free is new Ada.Unchecked_Deallocation (Win.Window, Window_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Drawing_Area, Area_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Coordinate_Input, Input_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Control_Slider, Slider_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Box.Box, Box_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Btn.Button, Button_Access);

    --  Frees the widgets, and then the window that holds them.
    procedure Free
           (This : in out Drawing_Window) is
    begin
        if This.D /= null then
            Free (This.D.Buffer);
        end if;
        Free (This.D);
        for Item of This.Inputs loop
            Free (Item);
        end loop;
        for Item of This.Sliders loop
            Free (Item);
        end loop;
        Free (This.Help);
        Free (This.Print);
        Free (This.Toggle);
        Free (This.Window);
    end Free;




    --  Idle Drawing  --

    function Step
           (This : in out Drawing_Area)
        return Boolean;

    Idle_Ref : FLTK.Static.Idle_Handler;

    procedure Idle is
    begin
        if not Step (Mbrot.D.all) and then not (Jbrot.D /= null and then Step (Jbrot.D.all)) then
            FLTK.Static.Remove_Idle (Idle_Ref);
        end if;
    end Idle;

    procedure Set_Idle is
    begin
        FLTK.Static.Add_Idle (Idle_Ref);
    end Set_Idle;


    procedure New_Display
           (This : in out Drawing_Area) is
    begin
        This.Drawn := 0;
        This.Next_Line := 0;
        Set_Idle;
    end New_Display;

    procedure New_Buffer
           (This : in out Drawing_Area) is
    begin
        if This.Buffer /= null then
            Free (This.Buffer);
            New_Display (This);
        end if;
    end New_Buffer;


    procedure Update_Label
           (This : in out Drawing_Window) is
    begin
        This.Inputs (X_Coordinate).Set_Value (Image ("%+.10f", This.D.X));
        This.Inputs (Y_Coordinate).Set_Value (Image ("%+.10f", This.D.Y));
        This.Inputs (Width).Set_Value (Image ("%.2g", This.D.Scale));
    end Update_Label;


    procedure Draw
           (This : in out Drawing_Area) is
    begin
        if This.DX = 0 then
            This.DX := FLTK.Static.Get_Box_X_Offset (This.Get_Box);
            This.DY := FLTK.Static.Get_Box_Y_Offset (This.Get_Box);
            This.DW := FLTK.Static.Get_Box_Width_Offset (This.Get_Box);
            This.DH := FLTK.Static.Get_Box_Height_Offset (This.Get_Box);
            This.W := This.W - This.DW;
            This.H := This.H - This.DH;
        end if;
        This.Draw_Box;
        This.Drawn := 0;
        Set_Idle;
    end Draw;


    --  Works out the line Next_Line.
    procedure Compute_Line
           (This      : in out Drawing_Area;
            Linebytes : in     Positive)
    is
        YY : Long_Float := This.Y + Long_Float (This.H / 2 - This.Next_Line) * This.Scale
            / Long_Float (This.W);
        YI : constant Long_Float := YY;
        P  : FLTK.Size_Type := FLTK.Size_Type (This.Next_Line * Linebytes) + 1;
        XX, WX, WY, T : Long_Float;
        I : Integer;
    begin
        if This.Buffer = null then
            This.Buffer := new FLTK.Color_Component_Array
                (1 .. FLTK.Size_Type (Linebytes * This.H));
        end if;
        if This.Julia then
            YY := This.JY;
        end if;
        for XI in 0 .. This.W - 1 loop
            XX := This.X + Long_Float (XI - This.W / 2) * This.Scale / Long_Float (This.W);
            WX := XX;
            WY := YI;
            if This.Julia then
                XX := This.JX;
            end if;
            I := 0;
            loop
                if I >= This.Iterations then
                    This.Buffer (P) := 0;
                    if This.Use_Colors then
                        This.Buffer (P + 1) := 0;
                        This.Buffer (P + 2) := 0;
                    end if;
                    exit;
                end if;
                T := WX * WX - WY * WY + XX;
                WY := 2.0 * WX * WY + YY;
                WX := T;
                if WX * WX + WY * WY > 4.0 then
                    T := 1.0 - Long_Float (I) / Long_Float (2 ** 10);
                    WX := T;
                    if T <= 0.0 then
                        T := 0.0;
                    else
                        for N in 1 .. This.Brightness loop
                            T := T * WX;
                        end loop;
                    end if;
                    if This.Use_Colors then
                        Get_Color (Float (T),
                            This.Buffer (P), This.Buffer (P + 1), This.Buffer (P + 2));
                    else
                        This.Buffer (P) := FLTK.Color_Component
                            (255 - Integer (Long_Float'Truncation (254.0 * T)));
                    end if;
                    exit;
                end if;
                I := I + 1;
            end loop;
            P := P + (if This.Use_Colors then 3 else 1);
        end loop;
        This.Next_Line := This.Next_Line + 1;
    end Compute_Line;


    --  Draws a line worked out, or works one out.  False when there is no
    --  more to do.
    function Step
           (This : in out Drawing_Area)
        return Boolean
    is
        Linebytes : constant Positive := (if This.Use_Colors then This.W * 3 else This.W);
    begin
        if not This.Owner.Window.Is_Visible then
            return False;
        end if;
        if This.Drawn < This.Next_Line then
            This.Owner.Window.Make_Current;
            declare
                YY    : constant Integer := This.Drawn + This.Get_Y + This.DY;
                First : constant FLTK.Size_Type := FLTK.Size_Type (This.Drawn * Linebytes) + 1;
                Line  : FLTK.Color_Component_Array renames This.Buffer
                    (First .. First + FLTK.Size_Type (Linebytes) - 1);
            begin
                if YY >= This.SY and YY <= This.SY + This.SH then
                    This.Owner.Window.Make_Current;
                    Drw.Overlay_Clear;
                end if;
                if This.Use_Colors then
                    Drw.Draw_Image (This.Get_X + This.DX, YY, This.W, 1, Line, 3);
                else
                    Drw.Draw_Image_Mono (This.Get_X + This.DX, YY, This.W, 1, Line, 1, This.W);
                end if;
            end;
            This.Drawn := This.Drawn + 1;
            return True;
        end if;
        if This.Next_Line < This.H then
            Compute_Line (This, Linebytes);
            return This.Next_Line <= This.H;
        end if;
        return False;
    end Step;


    procedure Erase_Box
           (This : in out Drawing_Area) is
    begin
        This.Owner.Window.Make_Current;
        Drw.Overlay_Clear;
    end Erase_Box;




    --  The Windows  --

    procedure Coordinate_CB
           (Item : in out Wdg.Widget'Class)
    is
        Input : Coordinate_Input renames Coordinate_Input (Item);
        Value : Long_Float;
    begin
        begin
            Value := Input.Get_Value;
        exception
            when Constraint_Error => Value := 0.0;
        end;
        case Input.Which is
            when X_Coordinate => Input.Owner.D.X := Value;
            when Y_Coordinate => Input.Owner.D.Y := Value;
            when Width        => Input.Owner.D.Scale := Value;
        end case;
        New_Display (Input.Owner.D.all);
    end Coordinate_CB;

    procedure Control_CB
           (Item : in out Wdg.Widget'Class)
    is
        Slider : Control_Slider renames Control_Slider (Item);
        Value  : constant Integer := Integer (Long_Float'Truncation (Slider.Get_Value));
    begin
        case Slider.Which is
            when Brightness => Slider.Owner.D.Brightness := Value;
            when Iterations => Slider.Owner.D.Iterations := 2 ** Value;
        end case;
        New_Display (Slider.Owner.D.all);
    end Control_CB;


    procedure Make_Window
           (This : in Window_Reference)
    is
        procedure Add_Input
               (Which : in Coordinate;
                X, W  : in Integer;
                Label : in String)
        is
            Input : Input_Access renames This.Inputs (Which);
        begin
            Input := new Coordinate_Input'
               (Flt.Forge.Create (This.Window.all, X, 15, W, 30, Label) with
                Owner => This, Which => Which);
            Input.Set_Box (FLTK.Thin_Down_Box);
            Input.Set_Background_Color (48);
            Input.Set_Selection_Color (FLTK.Background2_Color);
            Input.Set_Label_Font (FLTK.Times_Bold_Italic);
            Input.Set_Label_Size (16);
            Input.Set_Text_Font (FLTK.Times_Bold_Italic);
            Input.Set_Text_Size (12);
            Input.Set_Callback (Coordinate_CB'Unrestricted_Access);
            Input.Set_When (FLTK.When_Enter_Key + FLTK.When_Release);
        end Add_Input;

        procedure Add_Slider
               (Which    : in Control;
                Y        : in Integer;
                Label    : in String;
                Min, Max : in Integer;
                Value    : in Integer)
        is
            Slider : Slider_Access renames This.Sliders (Which);
        begin
            Slider := new Control_Slider'
               (Hor.Forge.Create (This.Window.all, 80, Y, 160, 15, Label) with
                Owner => This, Which => Which);
            Slider.Set_Box (FLTK.Thin_Down_Box);
            Slider.Set_Label_Size (10);
            Slider.Set_Step (1.0);
            Slider.Set_Slide_Size (0.1);
            Slider.Set_Callback (Control_CB'Unrestricted_Access);
            Slider.Set_Alignment (FLTK.Align_Left);
            Slider.Set_Bounds (Long_Float (Min), Long_Float (Max));
            Slider.Set_Value (Long_Float (Value));
            Slider.Set_Slider_Box (FLTK.Up_Box);
        end Add_Slider;
    begin
        This.Window := new Win.Window'(Win.Forge.Create (450, 520));

        This.D := new Drawing_Area'
           (Box.Forge.Create (This.Window.all, 20, 80, 410, 430) with
            Owner => This, W => 410, H => 430, others => <>);
        This.D.Set_Box (FLTK.Down_Box);
        This.D.Set_Background_Color (FLTK.Foreground_Color);
        This.D.Set_Selection_Color (FLTK.Dark1_Color);
        This.Window.Set_Resizable (This.D.all);

        Add_Input (X_Coordinate, 30, 125, "x:");
        Add_Input (Y_Coordinate, 175, 125, "y:");
        Add_Input (Width, 325, 105, "w:");

        Add_Slider (Brightness, 50, "brightness:", 0, Max_Brightness, This.D.Brightness);

        This.Help := new Box.Box'(Box.Forge.Create (This.Window.all, 240, 50, 190, 30,
            "left click: zoom out, drag: zoom in" & ASCII.LF
            & "right click: Julia set, ctrl-M: mode, ctrl-P: Print"));
        This.Help.Set_Label_Size (8);
        This.Help.Set_Alignment (FLTK.Align_Right + FLTK.Align_Inside);

        Add_Slider (Iterations, 65, "iterations:", 1, Max_Iterations, Default_Iterations);

        This.Window.Set_Size_Range (220, 220);
    end Make_Window;


    --  Where a drag started, and with which button.
    IX, IY  : Integer := 0;
    Dragged : Boolean := False;
    Button  : FLTK.Mouse_Button := FLTK.No_Button;


    procedure Show_Julia
           (This : in out Drawing_Area) is
    begin
        if Jbrot.D = null then
            Make_Window (Jbrot'Access);
            Jbrot.D.Julia := True;
            Jbrot.D.X := 0.0;
            Jbrot.D.Y := 0.0;
            Jbrot.D.Scale := 4.0;
            Jbrot.D.Use_Colors := Mbrot.D.Use_Colors;
            Update_Label (Jbrot);
        end if;
        Jbrot.D.JX := This.X + Long_Float (IX - This.Get_X - This.W / 2) * This.Scale
            / Long_Float (This.W);
        Jbrot.D.JY := This.Y + Long_Float (This.H / 2 - IY + This.Get_Y) * This.Scale
            / Long_Float (This.W);
        Jbrot.Window.Set_Label
           ("Julia " & Image ("%.7f", Jbrot.D.JX) & " " & Image ("%.7f", Jbrot.D.JY));
        Jbrot.Window.Show;
        New_Display (Jbrot.D.all);
    end Show_Julia;


    --  The left button let go.
    procedure Zoom
           (This : in out Drawing_Area) is
    begin
        Erase_Box (This);
        if Dragged and This.SW > 3 and This.SH > 3 then
            This.X := This.X + Long_Float (This.SX + This.SW / 2 - This.Get_X - This.W / 2)
                * This.Scale / Long_Float (This.W);
            This.Y := This.Y + Long_Float (-This.SY - This.SH / 2 + This.Get_Y + This.H / 2)
                * This.Scale / Long_Float (This.W);
            This.Scale := Long_Float (This.SW) * This.Scale / Long_Float (This.W);
        elsif not Dragged then
            This.Scale := 2.0 * This.Scale;
            if This.Julia then
                if This.Scale >= 4.0 then
                    This.Scale := 4.0;
                    This.X := 0.0;
                    This.Y := 0.0;
                end if;
            elsif This.Scale >= 2.5 then
                This.Scale := 2.5;
                This.X := -0.75;
                This.Y := 0.0;
            end if;
        else
            return;
        end if;
        Update_Label (This.Owner.all);
        New_Display (This);
    end Zoom;


    function Handle
           (This  : in out Drawing_Area;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        --  The mouse, kept inside the area.
        procedure Clamp
               (X, Y : out Integer) is
        begin
            X := Integer'Max (This.Get_X,
                Integer'Min (Ev.Mouse_X, This.Get_X + This.Get_W - 1));
            Y := Integer'Max (This.Get_Y,
                Integer'Min (Ev.Mouse_Y, This.Get_Y + This.Get_H - 1));
        end Clamp;
        X2, Y2 : Integer;
    begin
        case Event is
            when FLTK.Push =>
                Erase_Box (This);
                Clamp (IX, IY);
                Dragged := False;
                Button := Ev.Last_Button;
                return FLTK.Handled;
            when FLTK.Drag =>
                Dragged := True;
                Erase_Box (This);
                Clamp (X2, Y2);
                if Button /= FLTK.Left_Button then
                    IX := X2;
                    IY := Y2;
                    return FLTK.Handled;
                end if;
                This.SX := Integer'Min (IX, X2);
                This.SW := abs (X2 - IX);
                This.SY := Integer'Min (IY, Y2);
                This.SH := abs (Y2 - IY);
                This.Owner.Window.Make_Current;
                Drw.Overlay_Rect (This.SX, This.SY, This.SW, This.SH);
                return FLTK.Handled;
            when FLTK.Release =>
                if Button = FLTK.Left_Button then
                    Zoom (This);
                elsif not This.Julia then
                    Show_Julia (This);
                end if;
                return FLTK.Handled;
            when others =>
                return FLTK.Not_Handled;
        end case;
    end Handle;


    procedure Resize
           (This       : in out Drawing_Area;
            X, Y, W, H : in     Integer) is
    begin
        if W /= This.Get_W or H /= This.Get_H then
            This.W := W - This.DW;
            This.H := H - This.DH;
            New_Buffer (This);
        end if;
        Box.Box (This).Resize (X, Y, W, H);
    end Resize;




    --  The Shortcuts  --

    procedure Print_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Window  : Win.Window renames Mbrot.Window.all;
    begin
        if not Window.Is_Visible then
            return;
        end if;
        Window.Make_Current;
        declare
            Data    : constant FLTK.Color_Component_Array :=
                Drw.Read_Image (0, 0, Window.Get_W, Window.Get_H);
            Printer : Prn.Printer := Prn.Forge.Create;
        begin
            Printer.Start_Job (1);
            Printer.Start_Page;
            Printer.Scale (0.7, 0.7);
            Drw.Draw_Image (0, 0, Window.Get_W, Window.Get_H, Data);
            Printer.End_Page;
            Printer.End_Job;
        exception
            --  Cancelled, or no printer.
            when Prn.User_Cancel_Error | FLTK.Devices.Surface.Paged.Page_Error => null;
        end;
    end Print_CB;

    procedure Toggle_Color_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Mbrot.D.Use_Colors := not Mbrot.D.Use_Colors;
        New_Buffer (Mbrot.D.all);
        if Jbrot.D /= null then
            Jbrot.D.Use_Colors := Mbrot.D.Use_Colors;
            New_Buffer (Jbrot.D.all);
        end if;
    end Toggle_Color_CB;

    --  The C++ exits: closing the Mandelbrot window closes the Julia one.
    procedure Window_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Mbrot.Window.Hide;
        if Jbrot.Window /= null then
            Jbrot.Window.Hide;
        end if;
    end Window_CB;


    Count  : Natural;
    Result : Integer;


begin


    Idle_Ref := Idle'Unrestricted_Access;

    Make_Window (Mbrot'Access);
    Mbrot.Print := new Btn.Button'(Btn.Forge.Create (Mbrot.Window.all, 0, 0, 0, 0));
    Mbrot.Print.Set_Callback (Print_CB'Unrestricted_Access);
    Mbrot.Print.Set_Shortcut (FLTK.Mod_Ctrl + 'p');
    Mbrot.Toggle := new Btn.Button'(Btn.Forge.Create (Mbrot.Window.all, 0, 0, 0, 0));
    Mbrot.Toggle.Set_Callback (Toggle_Color_CB'Unrestricted_Access);
    Mbrot.Toggle.Set_Shortcut (FLTK.Mod_Ctrl + 'm');

    Mbrot.D.X := -0.75;
    Mbrot.D.Scale := 2.5;
    Update_Label (Mbrot);

    begin
        FLTK.Static.Parse_Args (Count);
        if Count < Ada.Command_Line.Argument_Count then
            FLTK.Errors.Current_Fatal (FLTK.Static.Help_Message);
        end if;
    exception
        when FLTK.Static.Argument_Error =>
            FLTK.Errors.Current_Fatal (FLTK.Static.Help_Message);
    end;
    FLTK.Screen.Set_Visual_Mode (FLTK.Screen.RGB);
    Mbrot.Window.Set_Callback (Window_CB'Unrestricted_Access);
    Mbrot.Window.Show_With_Args;
    Result := FLTK.Run;

    Free (Jbrot);
    Free (Mbrot);
    return Result;


end Mandelbrot;
