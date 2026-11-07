

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A double window that draws on itself with cairo (FLTK.Cairo), after
--  pofltk's FlCairo.CairoWindow.  Its Draw_Cairo comes after the window's
--  box and widgets, so it draws over them, as part of the Draw it
--  inherits:  a type overriding Draw calls its parent's Draw to have it.
--
--  Draw_Cairo is for the display.  On another surface, such as an image
--  surface or a printer, the window shows its widgets without it.
--
--  This isn't FLTK's Fl_Cairo_Window, which only an FLTK built for it
--  has, and which FLTKAda binds as FLTK.Widgets.Groups.Windows.Double.Cairo.
--  This window draws on any FLTK with X11 or Wayland (pofltk 114).  It is
--  in the library fltkada_cairo.


with

    FLTK.Cairo;


package FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn is


    type Cairo_Drawn_Window is new Double_Window with private;

    type Cairo_Drawn_Window_Reference (Data : not null access Cairo_Drawn_Window'Class) is
        limited null record with Implicit_Dereference => Data;




    --  Each raises Unsupported_Error if this FLTK has neither X11 nor
    --  Wayland (Is_Supported).
    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Cairo_Drawn_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Cairo_Drawn_Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Cairo_Drawn_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Cairo_Drawn_Window;

    end Forge;




    --  Whether this FLTK can make the window:  whether it has X11 or
    --  Wayland.
    function Is_Supported
        return Boolean;




    --  Drawing  --

    --  Draws on the window with Context, which is good for this call
    --  alone.  The default draws nothing.  An exception raised here is
    --  raised again once control is back in Ada, as from Draw.
    procedure Draw_Cairo
           (This    : in out Cairo_Drawn_Window;
            Context : in     FLTK.Cairo.Context)
    is null;

    --  Draws the window's box and widgets, then calls Draw_Cairo.
    procedure Draw
           (This : in out Cairo_Drawn_Window);


private


    type Cairo_Drawn_Window is new Double_Window with null record;

    overriding procedure Initialize
           (This : in out Cairo_Drawn_Window);

    overriding procedure Finalize
           (This : in out Cairo_Drawn_Window);

    procedure Extra_Init
           (This       : in out Cairo_Drawn_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Cairo_Drawn_Window)
    with Inline;


    pragma Inline (Draw);


end FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;

