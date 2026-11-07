

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Drawing with cairo, in a Cairo_Drawn_Window
--  (FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn), after pofltk's FlCairo.
--
--  A window's Draw_Cairo is given a Context, good for that call alone:
--  one kept and used later raises Program_Error.  Each draw has a new one,
--  so nothing set in it lasts.  A call cairo refuses, such as a Restore
--  with no Save, a Scale by 0, or text that isn't UTF-8, makes the rest of
--  the context's calls do nothing, and Is_Ok False; the next draw starts
--  again.
--
--  Cairo has hundreds of calls.  This binds those FLTK's programs use, as
--  FLTK.Draw binds fl_draw.H, and a few as simple, as pofltk does.  It is
--  a library of its own, fltkada_cairo, so that a program using only
--  widgets isn't linked with libcairo.


with

    Ada.Finalization;


package FLTK.Cairo is


    --  The context of one call of a window's Draw_Cairo.  Coordinates are
    --  the window's, in pixels, from its top left, with Y downwards.
    type Context is private;

    --  A gradient.  It is closed when finalized, or by Close.
    type Pattern is new Ada.Finalization.Limited_Controlled with private;


    --  Cairo's values for these, which test_cairo_constants checks.
    type Font_Slant is (Normal_Slant, Italic_Slant, Oblique_Slant);

    type Font_Weight is (Normal_Weight, Bold_Weight);

    type Antialias_Mode is
       (Default_Antialias, No_Antialias, Gray_Antialias, Subpixel_Antialias,
        Fast_Antialias, Good_Antialias, Best_Antialias);

    --  What a pattern is beyond its ends.
    type Extend_Mode is (No_Extend, Repeat_Extend, Reflect_Extend, Pad_Extend);


    --  The size of some text in the current font (Get_Text_Extents).  The
    --  bearings run from where it is drawn to its top left; the advance is
    --  to where the next text would go.
    type Text_Extents is record
        X_Bearing, Y_Bearing : Long_Float;
        Width, Height        : Long_Float;
        X_Advance, Y_Advance : Long_Float;
    end record;




    --  Every call on a Context raises Program_Error if it isn't the
    --  context of a Draw_Cairo that is still running.


    --  State  --

    --  False once cairo has refused a call on this context.
    function Is_Ok
           (This : in Context)
        return Boolean;

    procedure Save
           (This : in Context);

    --  Without a Save, cairo refuses it, and Is_Ok is False.
    procedure Restore
           (This : in Context);




    --  Transformations  --

    procedure Translate
           (This : in Context;
            X, Y : in Long_Float);

    procedure Scale
           (This : in Context;
            X, Y : in Long_Float);

    --  Angle is in radians, clockwise.
    procedure Rotate
           (This  : in Context;
            Angle : in Long_Float);




    --  Source and Lines  --

    procedure Set_Line_Width
           (This  : in Context;
            Width : in Long_Float);

    procedure Set_Antialias
           (This : in Context;
            Mode : in Antialias_Mode);

    --  Each component from 0.0 to 1.0.
    procedure Set_Source_RGB
           (This    : in Context;
            R, G, B : in Long_Float);

    procedure Set_Source_RGBA
           (This       : in Context;
            R, G, B, A : in Long_Float);

    --  Cairo keeps the pattern for as long as it is the source, so This
    --  may be closed in the meantime.  Raises Program_Error if Source is
    --  closed.
    procedure Set_Source
           (This   : in Context;
            Source : in Pattern'Class);




    --  Paths  --

    procedure New_Path
           (This : in Context);

    procedure Close_Path
           (This : in Context);

    procedure Move_To
           (This : in Context;
            X, Y : in Long_Float);

    procedure Line_To
           (This : in Context;
            X, Y : in Long_Float);

    procedure Curve_To
           (This                   : in Context;
            X1, Y1, X2, Y2, X3, Y3 : in Long_Float);

    procedure Rectangle
           (This : in Context;
            X, Y : in Long_Float;
            W, H : in Long_Float);

    --  From angle From to angle To, in radians, clockwise.
    procedure Arc
           (This     : in Context;
            X, Y     : in Long_Float;
            Radius   : in Long_Float;
            From, To : in Long_Float);




    --  Drawing  --

    procedure Stroke
           (This : in Context);

    procedure Stroke_Preserve
           (This : in Context);

    procedure Fill
           (This : in Context);

    procedure Fill_Preserve
           (This : in Context);

    procedure Paint
           (This : in Context);

    procedure Clip
           (This : in Context);




    --  Text  --

    --  Family is a fontconfig family, such as "Sans" or "Serif".
    procedure Select_Font_Face
           (This   : in Context;
            Family : in String;
            Slant  : in Font_Slant  := Normal_Slant;
            Weight : in Font_Weight := Normal_Weight);

    procedure Set_Font_Size
           (This : in Context;
            Size : in Long_Float);

    --  Text is UTF-8.  It ends at a NUL, if it has one.
    procedure Show_Text
           (This : in Context;
            Text : in String);

    procedure Text_Path
           (This : in Context;
            Text : in String);

    function Get_Text_Extents
           (This : in Context;
            Text : in String)
        return Text_Extents;




    --  Patterns  --

    package Forge is

        --  From X0, Y0 to X1, Y1.
        function Create_Linear
               (X0, Y0, X1, Y1 : in Long_Float)
            return Pattern;

        --  From the circle at X0, Y0 of radius R0 to that at X1, Y1 of R1.
        function Create_Radial
               (X0, Y0, R0, X1, Y1, R1 : in Long_Float)
            return Pattern;

    end Forge;

    --  These raise Program_Error if This is closed.

    procedure Add_Color_Stop_RGB
           (This    : in out Pattern;
            Offset  : in     Long_Float;
            R, G, B : in     Long_Float);

    procedure Add_Color_Stop_RGBA
           (This       : in out Pattern;
            Offset     : in     Long_Float;
            R, G, B, A : in     Long_Float);

    procedure Set_Extend
           (This : in out Pattern;
            Mode : in     Extend_Mode);

    --  False once cairo has refused a call on this pattern.
    function Is_Ok
           (This : in Pattern)
        return Boolean;

    --  May be called again.
    procedure Close
           (This : in out Pattern);

    function Is_Closed
           (This : in Pattern)
        return Boolean;


private


    pragma Linker_Options ("-lcairo");


    --  Each draw's context has a serial number of its own.  A context is
    --  live while its serial number is the current one.
    type Serial_Number is mod 2 ** 64;

    type Context is record
        Handle : Storage.Integer_Address := Null_Pointer;
        Serial : Serial_Number := 0;
    end record;

    type Pattern is new Ada.Finalization.Limited_Controlled with record
        Handle : Storage.Integer_Address := Null_Pointer;
    end record;

    overriding procedure Finalize
           (This : in out Pattern);


end FLTK.Cairo;

