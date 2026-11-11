

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    System;

private with

    Interfaces.C;


package FLTK.Widgets.Groups.Windows.OpenGL is


    type GL_Window is new Window with private;

    type GL_Window_Reference (Data : not null access GL_Window'Class) is
        limited null record with Implicit_Dereference => Data;

    --  Vertical blanks between buffer swaps; see Get_Swap_Interval.
    subtype Swap_Interval is Integer range -1 .. Integer'Last;

    Unknown_Interval : constant Swap_Interval := -1;

    --  RGB mode is achieved by Index being set to False
    --  Single buffer mode is achieved by Double being set to False
    type Mode_Mask is record
        Index       : Boolean := False;
        Double      : Boolean := False;
        Accum       : Boolean := False;
        Alpha       : Boolean := False;
        Depth       : Boolean := False;
        Stencil     : Boolean := False;
        RGB8        : Boolean := False;
        Multisample : Boolean := False;
        Stereo      : Boolean := False;
        Fake_Single : Boolean := False;
        OpenGL3     : Boolean := False;
    end record;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return GL_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return GL_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return GL_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return GL_Window;

    end Forge;




    --  Visibility  --

    procedure Show
           (This : in out GL_Window);

    procedure Show_With_Args
           (This : in out GL_Window);

    procedure Hide
           (This : in out GL_Window);

    procedure Hide_Overlay
           (This : in out GL_Window);

    procedure Flush
           (This : in out GL_Window);




    --  Dimensions  --

    function Pixel_H
           (This : in GL_Window)
        return Integer;

    function Pixel_W
           (This : in GL_Window)
        return Integer;

    function Pixels_Per_Unit
           (This : in GL_Window)
        return Float;

    procedure Resize
           (This       : in out GL_Window;
            X, Y, W, H : in     Integer);




    --  OpenGL Modes  --

    --  On Wayland FLTK adds Double to every mode, since EGL there draws
    --  double-buffered only, so Get_Mode reads back Double after Set_Mode
    --  asked for a single buffer (Fl_Wayland_Gl_Window_Driver.cxx:37, 113,
    --  301; pofltk 113).
    function Get_Mode
           (This : in GL_Window)
        return Mode_Mask;

    --  Raises Program_Error inside a GL_Window's Draw, where the new mode
    --  would replace the context being drawn with (pofltk 111).
    procedure Set_Mode
           (This : in out GL_Window;
            Mask : in     Mode_Mask);

    function Can_Do
           (Mask : in Mode_Mask)
        return Boolean;

    function Can_Do
           (This : in GL_Window)
        return Boolean;

    function Can_Do_Overlay
           (This : in GL_Window)
        return Boolean;




    --  OpenGL Contexts  --

    function Get_Context
           (This : in GL_Window)
        return System.Address;

    procedure Set_Context
           (This    : in out GL_Window;
            Struct  : in     System.Address;
            Destroy : in     Boolean := False);

    function Get_Context_Valid
           (This : in GL_Window)
        return Boolean;

    procedure Set_Context_Valid
           (This  : in out GL_Window;
            Value : in     Boolean);

    function Get_Valid
           (This : in GL_Window)
        return Boolean;

    procedure Set_Valid
           (This  : in out GL_Window;
            Value : in     Boolean);

    procedure Invalidate
           (This : in out GL_Window);

    --  Raises Program_Error if the window is not shown (pofltk 111).
    procedure Make_Current
           (This : in out GL_Window);

    procedure Make_Overlay_Current
           (This : in out GL_Window);




    --  Drawing, Events  --

    procedure Ortho
           (This : in out GL_Window);

    procedure Redraw_Overlay
           (This : in out GL_Window);

    procedure Swap_Buffers
           (This : in out GL_Window);

    --  How many vertical blanks the window waits for between buffer
    --  swaps.  Set it on a shown window, typically from Draw.  What works
    --  depends on the GL driver: most take only 0 and 1, and some can set
    --  the interval but not read it, so Get_Swap_Interval is then
    --  Unknown_Interval.  On X11 it is also Unknown_Interval for a window
    --  not shown.  On Wayland the interval is one setting for every GL
    --  window, 1 at first, and Get_Swap_Interval reads it for any window,
    --  shown or not (FLTK-issues.md F22).
    function Get_Swap_Interval
           (This : in GL_Window)
        return Swap_Interval;

    procedure Set_Swap_Interval
           (This   : in out GL_Window;
            Frames : in     Natural);

    procedure Draw
           (This : in out GL_Window);

    --  FLTK's own drawing in a GL window's Draw, as GL_Window's Draw does
    --  it:  from Draw_Begin to Draw_End, FLTK.Draw draws over the GL scene
    --  in the window's coordinates, y down, and Draw_Window draws the
    --  window's box and its widgets.  GL_Window's Draw is the three
    --  together, so call these instead of it, not around it.  A Draw that
    --  returns, or raises, without Draw_End is ended for it.  Each raises
    --  Program_Error out of order:  outside This's own Draw, Draw_Begin
    --  after Draw_Begin, and the others before it (pofltk's
    --  HaltGlDrawBegin).  FLTK's draw_begin pushes GL's state, which only
    --  draw_end pops (Fl_Gl_Window.cxx:382-431).
    procedure Draw_Begin
           (This : in out GL_Window);

    procedure Draw_Window
           (This : in out GL_Window);

    procedure Draw_End
           (This : in out GL_Window);

    --  Override this to draw the overlay, as Draw draws the window.  FLTK
    --  calls it after Redraw_Overlay, in the window's GL context, after
    --  Draw.  Without a hardware overlay, which is usual, FLTK draws it in
    --  the front buffer over what Draw drew.  This one draws nothing, as
    --  FLTK's does.  A GLUT window draws its overlay with GLUT's overlay
    --  display function instead, and doesn't call this.
    procedure Draw_Overlay
           (This : in out GL_Window);

    function Handle
           (This  : in out GL_Window;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type GL_Window is new Window with null record;

    overriding procedure Initialize
           (This : in out GL_Window);

    overriding procedure Finalize
           (This : in out GL_Window);

    procedure Extra_Init
           (This       : in out GL_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out GL_Window)
    with Inline;


    for Mode_Mask use record
        Index       at 0 range 0 .. 0;
        Double      at 0 range 1 .. 1;
        Accum       at 0 range 2 .. 2;
        Alpha       at 0 range 3 .. 3;
        Depth       at 0 range 4 .. 4;
        Stencil     at 0 range 5 .. 5;
        RGB8        at 0 range 6 .. 6;
        Multisample at 0 range 7 .. 7;
        Stereo      at 0 range 8 .. 8;
        Fake_Single at 0 range 9 .. 9;
        OpenGL3     at 0 range 10 .. Interfaces.C.unsigned'Size - 1;
    end record;

    for Mode_Mask'Size use Interfaces.C.unsigned'Size;

    pragma Convention (C_Pass_By_Copy, Mode_Mask);


    pragma Inline (Show);
    pragma Inline (Show_With_Args);
    pragma Inline (Hide);
    pragma Inline (Hide_Overlay);
    pragma Inline (Flush);

    pragma Inline (Pixel_H);
    pragma Inline (Pixel_W);
    pragma Inline (Pixels_Per_Unit);

    pragma Inline (Get_Mode);
    pragma Inline (Set_Mode);
    pragma Inline (Can_Do);
    pragma Inline (Can_Do_Overlay);

    pragma Inline (Get_Context);
    pragma Inline (Set_Context);
    pragma Inline (Get_Context_Valid);
    pragma Inline (Set_Context_Valid);
    pragma Inline (Get_Valid);
    pragma Inline (Set_Valid);
    pragma Inline (Invalidate);
    pragma Inline (Make_Current);
    pragma Inline (Make_Overlay_Current);

    pragma Inline (Ortho);
    pragma Inline (Redraw_Overlay);
    pragma Inline (Swap_Buffers);
    pragma Inline (Get_Swap_Interval);
    pragma Inline (Set_Swap_Interval);
    pragma Inline (Draw);
    pragma Inline (Draw_Begin);
    pragma Inline (Draw_Window);
    pragma Inline (Draw_End);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Windows.OpenGL;


