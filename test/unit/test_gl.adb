

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestGl: a GL window's mode, drawing and reading
--  back, validity and resizing, GL outside a Draw, a mode changed while
--  shown, hiding and showing again, a GL window inside a plain one, and
--  FLTK.Draw.OpenGL's text and rectangles, in a GL window and in a plain
--  window through Start.  The overlay is test_gl_overlay's, text with no
--  width test_gl_text_width's, the current group test_gl_window_group's.
--  pofltk's check that a deleted GL window takes its child with it has no
--  counterpart, as the child is an Ada object of its own.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Draw.OpenGL,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.OpenGL,
    Interfaces.C.Strings;

use

    Checks,
    FLTK;


procedure Test_GL is

    package C renames Interfaces.C;
    package GD renames FLTK.Draw.OpenGL;
    package GL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type C.unsigned;
    use type C.unsigned_char;
    use type C.size_t;
    use type C.Strings.chars_ptr;
    use type GL.Mode_Mask;

    pragma Linker_Options ("-lGL");


    --  GL's own calls.
    Color_Buffer_Bit : constant := 16#4000#;
    GL_RGB           : constant := 16#1907#;
    GL_Unsigned_Byte : constant := 16#1401#;
    GL_Version       : constant := 16#1F02#;
    GL_No_Error      : constant := 0;

    type Pixel is array (1 .. 4) of C.unsigned_char with Convention => C;

    procedure Clear_Color (R, G, B, A : in C.C_float)
    with Import, Convention => C, External_Name => "glClearColor";

    procedure Clear (Mask : in C.unsigned)
    with Import, Convention => C, External_Name => "glClear";

    procedure Flush
    with Import, Convention => C, External_Name => "glFlush";

    procedure Viewport (X, Y, W, H : in C.int)
    with Import, Convention => C, External_Name => "glViewport";

    procedure Read_Pixels
           (X, Y, W, H   : in     C.int;
            Format, Kind : in     C.unsigned;
            Data         :    out Pixel)
    with Import, Convention => C, External_Name => "glReadPixels";

    function Get_String (Name : in C.unsigned) return C.Strings.chars_ptr
    with Import, Convention => C, External_Name => "glGetString";

    function Get_Error return C.unsigned
    with Import, Convention => C, External_Name => "glGetError";


    --  Waits, of 0.02 s, for a window to draw; generous, for valgrind.
    Limit : constant := 500;

    type Red is new GL.GL_Window with record
        Draws, Invalid : Natural := 0;
        PW, PH         : Integer := 0;     --  its size in pixels, when not valid
        R, G, B        : Natural := 0;     --  a pixel read back as it drew
        Height         : Integer := 0;
        Descent        : Integer := 0;
        Width          : Long_Float := 0.0;
        TW, TH         : Natural := 0;
    end record;

    overriding procedure Draw
           (This : in out Red);

    overriding procedure Draw
           (This : in out Red)
    is
        P : Pixel := (others => 0);
    begin
        This.Draws := This.Draws + 1;
        if not This.Get_Valid then
            This.Invalid := This.Invalid + 1;
            This.PW := This.Pixel_W;
            This.PH := This.Pixel_H;
            Viewport (0, 0, C.int (This.PW), C.int (This.PH));
            This.Ortho;
        end if;
        Clear_Color (1.0, 0.0, 0.0, 1.0);
        Clear (Color_Buffer_Bit);
        Flush;
        Read_Pixels (1, 1, 1, 1, GL_RGB, GL_Unsigned_Byte, P);
        This.R := Natural (P (1));
        This.G := Natural (P (2));
        This.B := Natural (P (3));
        GD.Set_Font (Helvetica, 14);
        This.Height := GD.Font_Height;
        This.Descent := GD.Font_Descent;
        This.Width := GD.Width ("wide");
        GD.Measure ("wide", This.TW, This.TH);
        GD.Set_Color (White_Color);
        GD.Draw_Text (Float'(10.0), 10.0, "hi");
        GD.Rect (2, 2, 10, 10);
        GD.Rect_Fill (4, 4, 2, 2);
        GL.GL_Window (This).Draw;
    end Draw;

    function Open
           (W, H : in Integer)
        return Red is
    begin
        return (GL.Forge.Create (W, H) with others => <>);
    end Open;

    --  Runs FLTK until Window draws again.
    procedure Draws
           (Window : in out Red)
    is
        Before : constant Natural := Window.Draws;
        Ignore : Long_Float;
    begin
        for K in 1 .. Limit loop
            exit when Window.Draws /= Before;
            Ignore := Wait (0.02);
        end loop;
    end Draws;


    --  A window drawing with FLTK.Draw over its scene, between Draw_Begin
    --  and Draw_End, and its widgets with Draw_Window.  With Unended, it
    --  leaves Draw_End to FLTKAda.  It also tries the calls out of order.
    type Mixed is new GL.GL_Window with record
        Draws                    : Natural := 0;
        Unended                  : Boolean := False;
        Rect, Kid, Scene         : Pixel := (others => 0);
        Error                    : C.unsigned := 1;
        Early_End, Early_Window  : Boolean := False;   --  raised before Draw_Begin
        Twice                    : Boolean := False;   --  raised at a second Draw_Begin
    end record;

    overriding procedure Draw
           (This : in out Mixed);

    --  The pixel at X, Y in This's units, from the top.
    procedure Read_At
           (This : in out Mixed;
            X, Y : in     Integer;
            P    :    out Pixel) is
    begin
        Read_Pixels (C.int (X * This.Pixel_W / This.Get_W),
            C.int (This.Pixel_H - 1 - Y * This.Pixel_H / This.Get_H),
            1, 1, GL_RGB, GL_Unsigned_Byte, P);
    end Read_At;

    overriding procedure Draw
           (This : in out Mixed) is
    begin
        This.Draws := This.Draws + 1;
        Viewport (0, 0, C.int (This.Pixel_W), C.int (This.Pixel_H));
        Clear_Color (0.0, 0.0, 1.0, 1.0);
        Clear (Color_Buffer_Bit);
        begin
            This.Draw_End;
        exception
        when Program_Error =>
            This.Early_End := True;
        end;
        begin
            This.Draw_Window;
        exception
        when Program_Error =>
            This.Early_Window := True;
        end;
        This.Draw_Begin;
        begin
            This.Draw_Begin;
        exception
        when Program_Error =>
            This.Twice := True;
        end;
        This.Draw_Window;
        FLTK.Draw.Set_Color (Red_Color);
        FLTK.Draw.Rect_Fill (0, 0, 10, 10);
        if not This.Unended then
            This.Draw_End;
            Flush;
            Read_At (This, 5, 5, This.Rect);
            Read_At (This, 50, 5, This.Kid);
            Read_At (This, 30, 30, This.Scene);
            This.Error := Get_Error;
        end if;
    end Draw;

    function RGB_Is
           (P       : in Pixel;
            R, G, B : in C.unsigned_char)
        return Boolean is
    begin
        return P (1) = R and P (2) = G and P (3) = B;
    end RGB_Is;


    --  A plain window, drawing with GL through Start.
    type Plain is new Win.Window with record
        Draws       : Natural := 0;
        Height      : Integer := 0;
        Unsupported : Boolean := False;
    end record;

    overriding procedure Draw
           (This : in out Plain);

    overriding procedure Draw
           (This : in out Plain) is
    begin
        FLTK.Draw.Set_Color (Blue_Color);
        FLTK.Draw.Rect_Fill (0, 0, This.Get_W, This.Get_H);
        This.Draws := This.Draws + 1;
        GD.Start;
        GD.Set_Font (Helvetica, 14);
        This.Height := GD.Font_Height;
        GD.Set_Color (Green_Color);
        GD.Rect_Fill (0, 0, 10, 10);
        GD.Finish;
    exception
    when Unsupported_Error =>
        This.Unsupported := True;
    end Draw;


    RGB_Double_Depth : constant GL.Mode_Mask := (Double | Depth => True, others => False);
    RGB_Double       : constant GL.Mode_Mask := (Double => True, others => False);
    RGB_Single_Depth : constant GL.Mode_Mask := (Depth => True, others => False);

    Before : Natural;
    Ignore : Long_Float;

begin

    --  The mode.
    declare
        Window : Red := Open (60, 40);
    begin
        Check (Window.Get_Mode = RGB_Double_Depth, "a window's mode to start with");
        Check (Window.Can_Do, "its mode can be had");
        Check (GL.Can_Do (RGB_Double), "a mode can be asked about");
        Window.Set_Mode (RGB_Double);
        Check (Window.Get_Mode = RGB_Double, "a window not shown takes the mode it was given");
    end;

    declare
        Window : Red := Open (100, 80);
        P      : Pixel := (others => 1);
    begin
        Check (not Window.Get_Valid, "not valid before it is shown");
        Window.Show;
        Draws (Window);
        Check (Window.Draws > 0, "a GL window draws");
        Check (Window.Invalid > 0, "not valid at its first draw");
        Check (Window.PW > 0 and Window.PH > 0, "it has a size in pixels:"
            & Window.PW'Image & Window.PH'Image);
        Check (Window.R = 255 and Window.G = 0 and Window.B = 0,
            "GL drew red, and read it back:" & Window.R'Image & Window.G'Image & Window.B'Image);
        Check (Window.Height > 0, "text has a height:" & Window.Height'Image);
        Check (Window.Descent > 0, "text has a descent:" & Window.Descent'Image);
        Check (Window.Width > 0.0, "text has a width:" & Window.Width'Image);
        Check (Window.TW > 0 and Window.TH > 0, "text can be measured:"
            & Window.TW'Image & Window.TH'Image);
        Check (Window.Pixels_Per_Unit > 0.0, "pixels per unit");

        Before := Window.Invalid;
        Window.Redraw;
        Draws (Window);
        Check (Window.Invalid = Before, "valid at a later draw");
        Check (Window.Get_Valid, "valid after a draw");

        Window.Resize (0, 0, 120, 90);
        Draws (Window);
        Check (Window.Invalid > Before, "a resize makes it not valid");
        Check (Window.PW = Window.Pixel_W, "drawn at its new size:" & Window.PW'Image);

        Window.Make_Current;
        Read_Pixels (1, 1, 1, 1, GL_RGB, GL_Unsigned_Byte, P);
        Check (P (1) = 255 or P (1) = 0, "GL can be read outside a Draw:" & P (1)'Image);
        Check (Get_String (GL_Version) /= C.Strings.Null_Ptr
                and then C.Strings.Strlen (Get_String (GL_Version)) > 0,
            "GL's version: " & C.Strings.Value (Get_String (GL_Version)));
        Check (Get_Error = GL_No_Error, "no GL error");

        Window.Set_Swap_Interval (0);
        Window.Invalidate;
        Check (not Window.Get_Valid, "Invalidate");
        Window.Redraw;
        Draws (Window);

        Window.Set_Mode (RGB_Single_Depth);
        Window.Redraw;
        Draws (Window);
        Check (Window.R = 255 and Window.G = 0, "a shown window's mode can change, and it draws");

        Window.Make_Current;
        Window.Hide;
        Window.Show;
        Window.Make_Current;
        GD.Set_Font (Helvetica, 14);
        Check (GD.Font_Height > 0, "text before a draw, shown again");
        Draws (Window);
        Check (Window.Is_Shown, "shown again");
        Check (Window.R = 255 and Window.G = 0, "it draws after being hidden");
    end;
    Check (True, "a window with a context can be finalized");

    --  A GL window, with a child, in a plain one.
    declare
        Group : Win.Window := Win.Forge.Create (200, 200);
        Inner : Red := (GL.Forge.Create (Group, 10, 10, 100, 100) with others => <>);
        Kid   : constant FLTK.Widgets.Boxes.Box :=
            FLTK.Widgets.Boxes.Forge.Create (Inner, 5, 5, 20, 20);
    begin
        Check (Inner.Number_Of_Children = 1 and Inner.Contains (Kid), "a GL window has a child");
        Group.Show;
        Draws (Inner);
        Check (Inner.Draws > 0 and Inner.R = 255, "a GL window in a window draws");
        Group.Hide;
    end;

    --  Another, after one is finalized.
    declare
        Window : Red := Open (50, 50);
    begin
        Window.Show;
        Draws (Window);
        Check (Window.R = 255, "a window after a finalized one draws");
    end;

    --  Draw_Begin, Draw_Window and Draw_End.
    declare
        Window : Mixed := (GL.Forge.Create (60, 40) with others => <>);
        Green  : FLTK.Widgets.Boxes.Box := FLTK.Widgets.Boxes.Forge.Create (Window, 40, 0, 20, 20);
        Raised : Boolean := False;
    begin
        Green.Set_Box (Flat_Box);
        Green.Set_Background_Color (Green_Color);
        begin
            Window.Draw_Begin;
        exception
        when Program_Error =>
            Raised := True;
        end;
        Check (Raised, "Draw_Begin outside the window's Draw raises (pofltk's HaltGlDrawBegin)");
        Window.Show;
        for K in 1 .. Limit loop
            exit when Window.Draws > 0;
            Ignore := Wait (0.02);
        end loop;
        Check (RGB_Is (Window.Rect, 255, 0, 0), "FLTK.Draw draws in a GL window, y down");
        Check (RGB_Is (Window.Kid, 0, 255, 0), "Draw_Window draws its widgets");
        Check (RGB_Is (Window.Scene, 0, 0, 255), "over the GL scene");
        Check (Window.Error = GL_No_Error, "with no GL error");
        Check (Window.Early_End and Window.Early_Window,
            "Draw_End and Draw_Window before Draw_Begin raise");
        Check (Window.Twice, "Draw_Begin after Draw_Begin raises");

        Window.Unended := True;
        Before := Window.Draws;
        Window.Redraw;
        for K in 1 .. Limit loop
            exit when Window.Draws /= Before;
            Ignore := Wait (0.02);
        end loop;
        Window.Unended := False;
        Window.Error := 1;
        Window.Rect := (others => 0);
        Before := Window.Draws;
        Window.Redraw;
        for K in 1 .. Limit loop
            exit when Window.Draws /= Before;
            Ignore := Wait (0.02);
        end loop;
        Check (RGB_Is (Window.Rect, 255, 0, 0) and Window.Error = GL_No_Error,
            "a Draw left begun is ended for it");
        Raised := False;
        begin
            Window.Draw_End;
        exception
        when Program_Error =>
            Raised := True;
        end;
        Check (Raised, "Draw_End outside the window's Draw raises");
        Window.Hide;
    end;

    --  Start, in a plain window.
    declare
        Window : Plain := (Win.Forge.Create (40, 40) with others => <>);
    begin
        Window.Show;
        for K in 1 .. Limit loop
            exit when Window.Draws > 0;
            Ignore := Wait (0.02);
        end loop;
        if Window.Unsupported then
            Skip ("Start: FLTK crashes on it under Wayland (pofltk 109)");
        else
            Check (Window.Draws > 0, "Start in a plain window");
            Check (Window.Height > 0, "and text through it:" & Window.Height'Image);
        end if;
        Window.Hide;
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_GL;
