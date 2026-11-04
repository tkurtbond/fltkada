

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    System;


package FLTK.Widgets.Groups.Windows.Double.Cairo is


    --  If FLTK has not been built with Cairo support then
    --  this will just be a duplicate of Double_Window, Is_Supported
    --  is False, and Set_Cairo_Draw raises FLTK.Unsupported_Error,
    --  since its callback would never be called (pofltk 114).

    --  Building with Cairo support requires either of
    --  1. CMake option FLTK_OPTION_CAIRO_WINDOW
    --  2. configure -enable-cairo
    --  when building FLTK itself.


    type Cairo_Window is new Double_Window with private;

    type Cairo_Window_Reference (Data : not null access Cairo_Window'Class) is
        limited null record with Implicit_Dereference => Data;

    type Cairo_Callback is access procedure
           (This    : in out Cairo_Window;
            Context : in     System.Address);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Cairo_Window;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Cairo_Window;

        function Create
               (W, H : in Integer;
                Text : in String)
            return Cairo_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer;
                Text   : in     String)
            return Cairo_Window;

        function Create
               (W, H : in Integer)
            return Cairo_Window;

        function Create
               (Parent : in out Groups.Group'Class;
                W, H   : in     Integer)
            return Cairo_Window;

    end Forge;




    --  Cairo Callback  --

    function Is_Supported
        return Boolean;

    --  Func must leave the context's cairo_save and cairo_restore balanced.
    --  On Wayland the context is the one FLTK draws the window with
    --  (Fl_Cairo.cxx:104-112), which holds a cairo_save of FLTK's from the
    --  start (Fl_Wayland_Graphics_Driver.cxx:219).  One cairo_restore too
    --  many takes that, and the context stays in error, so the window, FLTK's
    --  own drawing in it too, draws nothing more.  On X11 the context is made
    --  for the window, and only that draw is lost.  pofltk 114, which saw it
    --  with Fl_Cairo_Window under Xvfb and on a headless sway.
    procedure Set_Cairo_Draw
           (This : in out Cairo_Window;
            Func : in     Cairo_Callback);




    --  Drawing  --

    procedure Draw
           (This : in out Cairo_Window);


private


    type Cairo_Window is new Double_Window with record
        My_Func : Cairo_Callback;
    end record;

    overriding procedure Initialize
           (This : in out Cairo_Window);

    overriding procedure Finalize
           (This : in out Cairo_Window);

    procedure Extra_Init
           (This       : in out Cairo_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Cairo_Window);


    pragma Inline (Is_Supported);
    pragma Inline (Set_Cairo_Draw);

    pragma Inline (Draw);


end FLTK.Widgets.Groups.Windows.Double.Cairo;


