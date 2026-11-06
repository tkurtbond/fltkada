--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/offscreen.cxx: lines of random colour and width, drawn one
--  every tenth of a second on an offscreen larger than the window, and
--  copied to a box in the window.  Drag the box to move the view.  After
--  300 lines the offscreen is cleared and drawing starts again.


with

    Ada.Unchecked_Deallocation,
    Interfaces.C,
    System,
    FLTK.Draw.Offscreens,
    FLTK.Events,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double;


function Offscreen
    return Integer
is


    package Drw renames FLTK.Draw;
    package Ofs renames FLTK.Draw.Offscreens;
    package Ev  renames FLTK.Events;
    package Stc renames FLTK.Static;
    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;


    Offscreen_Size     : constant := 1000;
    Win_Size           : constant := 512;
    First_Useful_Color : constant := 56;
    Last_Useful_Color  : constant := 255;
    Num_Iterations     : constant := 300;
    Max_Line_Width     : constant := 9;
    Delta_Time         : constant := 0.1;


    --  C's generator, as the C++ uses, so that the two draw the same lines
    --  from the same seed.  RAND_MAX is a macro, 2**31 - 1 in glibc and in
    --  the BSDs' libc.
    function C_Rand
        return Interfaces.C.int
    with Import, Convention => C, External_Name => "rand";

    procedure C_Srand
           (Seed : in Interfaces.C.unsigned)
    with Import, Convention => C, External_Name => "srand";

    function C_Time
           (T : in System.Address)
        return Interfaces.C.long
    with Import, Convention => C, External_Name => "time";

    Rand_Max : constant := 2 ** 31 - 1;

    --  0.0 to V.
    function Random_Value
           (V : in Integer)
        return Long_Float is
    begin
        return Long_Float (C_Rand) / Long_Float (Rand_Max) * Long_Float (V);
    end Random_Value;

    --  As C converts a double to an int.
    function Truncate
           (V : in Long_Float)
        return Integer is
    begin
        return Integer (Long_Float'Truncation (V));
    end Truncate;


    --  The scale FLTK draws at now, which Fl_Graphics_Driver::default_driver
    --  ().scale () gives the C++.
    function Current_Scale
        return Float
    is
        Factor : constant Float := Drw.Override_Scale;
    begin
        Drw.Restore_Scale (Factor);
        return Factor;
    end Current_Scale;


    type Offscreen_Access is access Ofs.Offscreen;

    procedure Free is new Ada.Unchecked_Deallocation (Ofs.Offscreen, Offscreen_Access);


    type Offscreen_Box is new Bx.Box with record
        --  Made by the first Draw, once there is a window to base it on.
        Picture          : Offscreen_Access := null;
        --  The drag: where it was last, and whether one is going on.
        X1, Y1           : Integer := 0;
        Dragging         : Boolean := False;
        --  The top left of the view, roughly centred.
        Page_X, Page_Y   : Integer := (Offscreen_Size - Win_Size) / 2;
        Offsc_W, Offsc_H : Integer := 0;
        Iters            : Integer := Num_Iterations + 1;
        Scale            : Float   := 1.0;
    end record;

    overriding procedure Draw
           (This : in out Offscreen_Box);

    overriding function Handle
           (This  : in out Offscreen_Box;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    Main_Window : Dbl.Double_Window := Dbl.Forge.Create (Win_Size, Win_Size, "Offscreen demo");
    Box         : Offscreen_Box :=
       (Bx.Forge.Create (Main_Window, 5, 5, Win_Size - 10, Win_Size - 10) with others => <>);

    --  The C++'s statics in oscr_drawing.
    Icol   : Integer := First_Useful_Color;
    Ox, Oy : Integer := Offscreen_Size / 2;


    procedure Draw
           (This : in out Offscreen_Box)
    is
        X : constant Integer := This.Get_X;
        Y : constant Integer := This.Get_Y;
        W : constant Integer := This.Get_W;
        H : constant Integer := This.Get_H;
    begin
        Drw.Set_Color (FLTK.Grey_Ramp ('T'));
        Drw.Rect_Fill (X, Y, W, H);

        if This.Picture /= null then
            if This.Scale /= Current_Scale then
                This.Picture.Rescale;
                This.Scale := Current_Scale;
            end if;
            This.Picture.Copy (X, Y, W, H, This.Page_X, This.Page_Y);
        else
            --  Some hosts may need a window to base the offscreen on.
            Main_Window.Make_Current;
            This.Offsc_W := Offscreen_Size;
            This.Offsc_H := Offscreen_Size;
            This.Picture := new Ofs.Offscreen'(Ofs.Forge.Create (This.Offsc_W, This.Offsc_H));
            This.Scale := Current_Scale;
        end if;
    end Draw;


    function Handle
           (This  : in out Offscreen_Box;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Result : FLTK.Event_Outcome := Bx.Box (This).Handle (Event);
        X2, Y2 : Integer;
    begin
        if This.Picture = null then
            return Result;
        end if;
        case Event is
            when FLTK.Enter =>
                Main_Window.Set_Cursor (FLTK.Move_Mouse);
                Result := FLTK.Handled;
            when FLTK.Leave =>
                Main_Window.Set_Cursor (FLTK.Default_Mouse);
                Result := FLTK.Handled;
            when FLTK.Push =>
                This.X1 := Ev.Mouse_X_Root;
                This.Y1 := Ev.Mouse_Y_Root;
                This.Dragging := True;
                Result := FLTK.Handled;
            when FLTK.Drag =>
                if This.Dragging then
                    X2 := Ev.Mouse_X_Root;
                    Y2 := Ev.Mouse_Y_Root;
                    This.Page_X := Integer'Max (-This.Get_W,
                        Integer'Min (This.Page_X + This.X1 - X2, This.Offsc_W));
                    This.Page_Y := Integer'Max (-This.Get_H,
                        Integer'Min (This.Page_Y + This.Y1 - Y2, This.Offsc_H));
                    This.X1 := X2;
                    This.Y1 := Y2;
                    This.Redraw;
                end if;
                Result := FLTK.Handled;
            when FLTK.Release =>
                This.Dragging := False;
                Result := FLTK.Handled;
            when others =>
                null;
        end case;
        return Result;
    end Handle;


    --  One more line on the offscreen, or a clean one after Num_Iterations.
    procedure Draw_Line
           (This : in out Offscreen_Box)
    is
        DRX, DRY, DRT : Long_Float;
        EX, EY        : Integer;
    begin
        if This.Picture = null then
            return;
        end if;

        This.Picture.Begin_Drawing;
        if This.Iters > Num_Iterations then
            Drw.Set_Color (FLTK.White_Color);
            Drw.Rect_Fill (0, 0, This.Offsc_W, This.Offsc_H);
            This.Iters := 0;
        end if;
        This.Iters := This.Iters + 1;

        Icol := (if Icol = Last_Useful_Color then First_Useful_Color else Icol + 1);
        Drw.Set_Color (FLTK.Color (Icol));

        --  In the C++'s order, each a call of rand.
        DRX := Random_Value (This.Offsc_W);
        DRY := Random_Value (This.Offsc_H);
        DRT := Random_Value (Max_Line_Width);

        EX := Truncate (DRX);
        EY := Truncate (DRY);
        Drw.Set_Line_Style (Drw.Solid_Line, Width => Truncate (DRT));
        Drw.Line (Ox, Oy, EX, EY);
        Ox := EX;
        Oy := EY;

        Drw.Set_Line_Style (Drw.Solid_Line);
        This.Picture.End_Drawing;
        This.Redraw;
    end Draw_Line;


    procedure Animate is
    begin
        Draw_Line (Box);
        Stc.Repeat_Timeout (Delta_Time, Animate'Unrestricted_Access);
    end Animate;


    Status : Integer;


begin


    Main_Window.Set_Resizable (Box);
    Main_Window.Show_With_Args;

    C_Srand (Interfaces.C.unsigned'Mod (C_Time (System.Null_Address)));

    Stc.Add_Timeout (Delta_Time, Animate'Unrestricted_Access);

    Status := FLTK.Run;
    Free (Box.Picture);
    return Status;


end Offscreen;
