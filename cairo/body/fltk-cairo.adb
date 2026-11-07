

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Hook_Exceptions,
    FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn,
    Interfaces.C,
    System.Address_To_Access_Conversions;

use type

    Interfaces.C.int;


package body FLTK.Cairo is


    package Drawn renames FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;

    subtype C_Double is Interfaces.C.double;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  State  --

    function fl_cairo_status
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_cairo_status, "fl_cairo_status");
    pragma Inline (fl_cairo_status);

    procedure fl_cairo_save
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_save, "fl_cairo_save");
    pragma Inline (fl_cairo_save);

    procedure fl_cairo_restore
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_restore, "fl_cairo_restore");
    pragma Inline (fl_cairo_restore);




    --  Transformations  --

    procedure fl_cairo_translate
           (C    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.double);
    pragma Import (C, fl_cairo_translate, "fl_cairo_translate");
    pragma Inline (fl_cairo_translate);

    procedure fl_cairo_scale
           (C    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.double);
    pragma Import (C, fl_cairo_scale, "fl_cairo_scale");
    pragma Inline (fl_cairo_scale);

    procedure fl_cairo_rotate
           (C     : in Storage.Integer_Address;
            Angle : in Interfaces.C.double);
    pragma Import (C, fl_cairo_rotate, "fl_cairo_rotate");
    pragma Inline (fl_cairo_rotate);




    --  Source and Lines  --

    procedure fl_cairo_set_line_width
           (C     : in Storage.Integer_Address;
            Width : in Interfaces.C.double);
    pragma Import (C, fl_cairo_set_line_width, "fl_cairo_set_line_width");
    pragma Inline (fl_cairo_set_line_width);

    procedure fl_cairo_set_antialias
           (C    : in Storage.Integer_Address;
            Mode : in Interfaces.C.int);
    pragma Import (C, fl_cairo_set_antialias, "fl_cairo_set_antialias");
    pragma Inline (fl_cairo_set_antialias);

    procedure fl_cairo_set_source_rgba
           (C          : in Storage.Integer_Address;
            R, G, B, A : in Interfaces.C.double);
    pragma Import (C, fl_cairo_set_source_rgba, "fl_cairo_set_source_rgba");
    pragma Inline (fl_cairo_set_source_rgba);

    procedure fl_cairo_set_source
           (C, P : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_set_source, "fl_cairo_set_source");
    pragma Inline (fl_cairo_set_source);




    --  Paths  --

    procedure fl_cairo_new_path
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_new_path, "fl_cairo_new_path");
    pragma Inline (fl_cairo_new_path);

    procedure fl_cairo_close_path
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_close_path, "fl_cairo_close_path");
    pragma Inline (fl_cairo_close_path);

    procedure fl_cairo_move_to
           (C    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.double);
    pragma Import (C, fl_cairo_move_to, "fl_cairo_move_to");
    pragma Inline (fl_cairo_move_to);

    procedure fl_cairo_line_to
           (C    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.double);
    pragma Import (C, fl_cairo_line_to, "fl_cairo_line_to");
    pragma Inline (fl_cairo_line_to);

    procedure fl_cairo_curve_to
           (C                      : in Storage.Integer_Address;
            X1, Y1, X2, Y2, X3, Y3 : in Interfaces.C.double);
    pragma Import (C, fl_cairo_curve_to, "fl_cairo_curve_to");
    pragma Inline (fl_cairo_curve_to);

    procedure fl_cairo_rectangle
           (C          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.double);
    pragma Import (C, fl_cairo_rectangle, "fl_cairo_rectangle");
    pragma Inline (fl_cairo_rectangle);

    procedure fl_cairo_arc
           (C                      : in Storage.Integer_Address;
            X, Y, Radius, From, To : in Interfaces.C.double);
    pragma Import (C, fl_cairo_arc, "fl_cairo_arc");
    pragma Inline (fl_cairo_arc);




    --  Drawing  --

    procedure fl_cairo_stroke
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_stroke, "fl_cairo_stroke");
    pragma Inline (fl_cairo_stroke);

    procedure fl_cairo_stroke_preserve
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_stroke_preserve, "fl_cairo_stroke_preserve");
    pragma Inline (fl_cairo_stroke_preserve);

    procedure fl_cairo_fill
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_fill, "fl_cairo_fill");
    pragma Inline (fl_cairo_fill);

    procedure fl_cairo_fill_preserve
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_fill_preserve, "fl_cairo_fill_preserve");
    pragma Inline (fl_cairo_fill_preserve);

    procedure fl_cairo_paint
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_paint, "fl_cairo_paint");
    pragma Inline (fl_cairo_paint);

    procedure fl_cairo_clip
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_clip, "fl_cairo_clip");
    pragma Inline (fl_cairo_clip);




    --  Text  --

    type Extents_Array is array (1 .. 6) of C_Double;
    pragma Convention (C, Extents_Array);

    procedure fl_cairo_select_font_face
           (C             : in Storage.Integer_Address;
            Family        : in Interfaces.C.char_array;
            Slant, Weight : in Interfaces.C.int);
    pragma Import (C, fl_cairo_select_font_face, "fl_cairo_select_font_face");
    pragma Inline (fl_cairo_select_font_face);

    procedure fl_cairo_set_font_size
           (C    : in Storage.Integer_Address;
            Size : in Interfaces.C.double);
    pragma Import (C, fl_cairo_set_font_size, "fl_cairo_set_font_size");
    pragma Inline (fl_cairo_set_font_size);

    procedure fl_cairo_show_text
           (C    : in Storage.Integer_Address;
            Text : in Interfaces.C.char_array);
    pragma Import (C, fl_cairo_show_text, "fl_cairo_show_text");
    pragma Inline (fl_cairo_show_text);

    procedure fl_cairo_text_path
           (C    : in Storage.Integer_Address;
            Text : in Interfaces.C.char_array);
    pragma Import (C, fl_cairo_text_path, "fl_cairo_text_path");
    pragma Inline (fl_cairo_text_path);

    procedure fl_cairo_text_extents
           (C    : in Storage.Integer_Address;
            Text : in Interfaces.C.char_array;
            E    : out Extents_Array);
    pragma Import (C, fl_cairo_text_extents, "fl_cairo_text_extents");
    pragma Inline (fl_cairo_text_extents);




    --  Patterns  --

    function fl_cairo_pattern_create_linear
           (X0, Y0, X1, Y1 : in Interfaces.C.double)
        return Storage.Integer_Address;
    pragma Import (C, fl_cairo_pattern_create_linear, "fl_cairo_pattern_create_linear");
    pragma Inline (fl_cairo_pattern_create_linear);

    function fl_cairo_pattern_create_radial
           (X0, Y0, R0, X1, Y1, R1 : in Interfaces.C.double)
        return Storage.Integer_Address;
    pragma Import (C, fl_cairo_pattern_create_radial, "fl_cairo_pattern_create_radial");
    pragma Inline (fl_cairo_pattern_create_radial);

    procedure fl_cairo_pattern_add_color_stop_rgba
           (P                  : in Storage.Integer_Address;
            Offset, R, G, B, A : in Interfaces.C.double);
    pragma Import (C, fl_cairo_pattern_add_color_stop_rgba, "fl_cairo_pattern_add_color_stop_rgba");
    pragma Inline (fl_cairo_pattern_add_color_stop_rgba);

    procedure fl_cairo_pattern_set_extend
           (P      : in Storage.Integer_Address;
            Extend : in Interfaces.C.int);
    pragma Import (C, fl_cairo_pattern_set_extend, "fl_cairo_pattern_set_extend");
    pragma Inline (fl_cairo_pattern_set_extend);

    function fl_cairo_pattern_status
           (P : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_cairo_pattern_status, "fl_cairo_pattern_status");
    pragma Inline (fl_cairo_pattern_status);

    procedure fl_cairo_pattern_destroy
           (P : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_pattern_destroy, "fl_cairo_pattern_destroy");
    pragma Inline (fl_cairo_pattern_destroy);




    ----------------------
    --  Context Serials  --
    ----------------------

    --  The serial number of the context of the Draw_Cairo running, or 0
    --  for none.  Each draw takes the next.
    Current : Serial_Number := 0;
    Last    : Serial_Number := 0;


    function Live
           (This : in Context)
        return Storage.Integer_Address is
    begin
        if This.Serial = 0 or This.Serial /= Current or This.Handle = Null_Pointer then
            raise Program_Error with "a cairo context used outside its window's Draw_Cairo";
        end if;
        return This.Handle;
    end Live;


    function Live
           (This : in Pattern'Class)
        return Storage.Integer_Address is
    begin
        if This.Handle = Null_Pointer then
            raise Program_Error with "a cairo pattern used after it was closed";
        end if;
        return This.Handle;
    end Live;




    ---------------------
    --  Callback Hook  --
    ---------------------

    package Window_Convert is new System.Address_To_Access_Conversions
        (Drawn.Cairo_Drawn_Window'Class);


    procedure Draw_Cairo_Hook
           (U, Handle : in Storage.Integer_Address);
    pragma Export (C, Draw_Cairo_Hook, "cairo_drawn_window_draw_hook");

    --  Called by the window's C++ draw, with a context made for the call,
    --  which it destroys after.  A draw within a draw, which an Fl.Check in
    --  Draw_Cairo could start, has a context of its own, and the outer one
    --  is live again once it ends.
    procedure Draw_Cairo_Hook
           (U, Handle : in Storage.Integer_Address)
    is
        Mark     : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Previous : constant Serial_Number := Current;
        Window   : constant access Drawn.Cairo_Drawn_Window'Class :=
            Window_Convert.To_Pointer (Storage.To_Address (U));
    begin
        Last := Last + 1;
        if Last = 0 then
            Last := 1;
        end if;
        Current := Last;
        Window.Draw_Cairo ((Handle => Handle, Serial => Current));
        Current := Previous;
    exception
    when Occurrence : others =>
        Current := Previous;
        Hook_Exceptions.Save (Occurrence, Mark);
    end Draw_Cairo_Hook;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  State  --

    function Is_Ok
           (This : in Context)
        return Boolean is
    begin
        return fl_cairo_status (Live (This)) = 0;
    end Is_Ok;


    procedure Save
           (This : in Context) is
    begin
        fl_cairo_save (Live (This));
    end Save;


    procedure Restore
           (This : in Context) is
    begin
        fl_cairo_restore (Live (This));
    end Restore;




    --  Transformations  --

    procedure Translate
           (This : in Context;
            X, Y : in Long_Float) is
    begin
        fl_cairo_translate (Live (This), C_Double (X), C_Double (Y));
    end Translate;


    procedure Scale
           (This : in Context;
            X, Y : in Long_Float) is
    begin
        fl_cairo_scale (Live (This), C_Double (X), C_Double (Y));
    end Scale;


    procedure Rotate
           (This  : in Context;
            Angle : in Long_Float) is
    begin
        fl_cairo_rotate (Live (This), C_Double (Angle));
    end Rotate;




    --  Source and Lines  --

    procedure Set_Line_Width
           (This  : in Context;
            Width : in Long_Float) is
    begin
        fl_cairo_set_line_width (Live (This), C_Double (Width));
    end Set_Line_Width;


    procedure Set_Antialias
           (This : in Context;
            Mode : in Antialias_Mode) is
    begin
        fl_cairo_set_antialias (Live (This), Antialias_Mode'Pos (Mode));
    end Set_Antialias;


    procedure Set_Source_RGB
           (This    : in Context;
            R, G, B : in Long_Float) is
    begin
        Set_Source_RGBA (This, R, G, B, 1.0);
    end Set_Source_RGB;


    procedure Set_Source_RGBA
           (This       : in Context;
            R, G, B, A : in Long_Float) is
    begin
        fl_cairo_set_source_rgba
           (Live (This), C_Double (R), C_Double (G), C_Double (B), C_Double (A));
    end Set_Source_RGBA;


    procedure Set_Source
           (This   : in Context;
            Source : in Pattern'Class) is
    begin
        fl_cairo_set_source (Live (This), Live (Source));
    end Set_Source;




    --  Paths  --

    procedure New_Path
           (This : in Context) is
    begin
        fl_cairo_new_path (Live (This));
    end New_Path;


    procedure Close_Path
           (This : in Context) is
    begin
        fl_cairo_close_path (Live (This));
    end Close_Path;


    procedure Move_To
           (This : in Context;
            X, Y : in Long_Float) is
    begin
        fl_cairo_move_to (Live (This), C_Double (X), C_Double (Y));
    end Move_To;


    procedure Line_To
           (This : in Context;
            X, Y : in Long_Float) is
    begin
        fl_cairo_line_to (Live (This), C_Double (X), C_Double (Y));
    end Line_To;


    procedure Curve_To
           (This                   : in Context;
            X1, Y1, X2, Y2, X3, Y3 : in Long_Float) is
    begin
        fl_cairo_curve_to
           (Live (This),
            C_Double (X1), C_Double (Y1),
            C_Double (X2), C_Double (Y2),
            C_Double (X3), C_Double (Y3));
    end Curve_To;


    procedure Rectangle
           (This : in Context;
            X, Y : in Long_Float;
            W, H : in Long_Float) is
    begin
        fl_cairo_rectangle (Live (This), C_Double (X), C_Double (Y), C_Double (W), C_Double (H));
    end Rectangle;


    procedure Arc
           (This     : in Context;
            X, Y     : in Long_Float;
            Radius   : in Long_Float;
            From, To : in Long_Float) is
    begin
        fl_cairo_arc
           (Live (This),
            C_Double (X), C_Double (Y),
            C_Double (Radius),
            C_Double (From), C_Double (To));
    end Arc;




    --  Drawing  --

    procedure Stroke
           (This : in Context) is
    begin
        fl_cairo_stroke (Live (This));
    end Stroke;


    procedure Stroke_Preserve
           (This : in Context) is
    begin
        fl_cairo_stroke_preserve (Live (This));
    end Stroke_Preserve;


    procedure Fill
           (This : in Context) is
    begin
        fl_cairo_fill (Live (This));
    end Fill;


    procedure Fill_Preserve
           (This : in Context) is
    begin
        fl_cairo_fill_preserve (Live (This));
    end Fill_Preserve;


    procedure Paint
           (This : in Context) is
    begin
        fl_cairo_paint (Live (This));
    end Paint;


    procedure Clip
           (This : in Context) is
    begin
        fl_cairo_clip (Live (This));
    end Clip;




    --  Text  --

    procedure Select_Font_Face
           (This   : in Context;
            Family : in String;
            Slant  : in Font_Slant  := Normal_Slant;
            Weight : in Font_Weight := Normal_Weight) is
    begin
        fl_cairo_select_font_face
           (Live (This),
            Interfaces.C.To_C (Family),
            Font_Slant'Pos (Slant),
            Font_Weight'Pos (Weight));
    end Select_Font_Face;


    procedure Set_Font_Size
           (This : in Context;
            Size : in Long_Float) is
    begin
        fl_cairo_set_font_size (Live (This), C_Double (Size));
    end Set_Font_Size;


    procedure Show_Text
           (This : in Context;
            Text : in String) is
    begin
        fl_cairo_show_text (Live (This), Interfaces.C.To_C (Text));
    end Show_Text;


    procedure Text_Path
           (This : in Context;
            Text : in String) is
    begin
        fl_cairo_text_path (Live (This), Interfaces.C.To_C (Text));
    end Text_Path;


    function Get_Text_Extents
           (This : in Context;
            Text : in String)
        return Text_Extents
    is
        E : Extents_Array;
    begin
        fl_cairo_text_extents (Live (This), Interfaces.C.To_C (Text), E);
        return
           (X_Bearing => Long_Float (E (1)),
            Y_Bearing => Long_Float (E (2)),
            Width     => Long_Float (E (3)),
            Height    => Long_Float (E (4)),
            X_Advance => Long_Float (E (5)),
            Y_Advance => Long_Float (E (6)));
    end Get_Text_Extents;




    --  Patterns  --

    package body Forge is

        function Create_Linear
               (X0, Y0, X1, Y1 : in Long_Float)
            return Pattern is
        begin
            return This : Pattern do
                This.Handle := fl_cairo_pattern_create_linear
                   (C_Double (X0), C_Double (Y0), C_Double (X1), C_Double (Y1));
            end return;
        end Create_Linear;


        function Create_Radial
               (X0, Y0, R0, X1, Y1, R1 : in Long_Float)
            return Pattern is
        begin
            return This : Pattern do
                This.Handle := fl_cairo_pattern_create_radial
                   (C_Double (X0), C_Double (Y0), C_Double (R0),
                    C_Double (X1), C_Double (Y1), C_Double (R1));
            end return;
        end Create_Radial;

    end Forge;


    procedure Add_Color_Stop_RGB
           (This    : in out Pattern;
            Offset  : in     Long_Float;
            R, G, B : in     Long_Float) is
    begin
        Add_Color_Stop_RGBA (This, Offset, R, G, B, 1.0);
    end Add_Color_Stop_RGB;


    procedure Add_Color_Stop_RGBA
           (This       : in out Pattern;
            Offset     : in     Long_Float;
            R, G, B, A : in     Long_Float) is
    begin
        fl_cairo_pattern_add_color_stop_rgba
           (Live (This),
            C_Double (Offset),
            C_Double (R), C_Double (G), C_Double (B), C_Double (A));
    end Add_Color_Stop_RGBA;


    procedure Set_Extend
           (This : in out Pattern;
            Mode : in     Extend_Mode) is
    begin
        fl_cairo_pattern_set_extend (Live (This), Extend_Mode'Pos (Mode));
    end Set_Extend;


    function Is_Ok
           (This : in Pattern)
        return Boolean is
    begin
        return fl_cairo_pattern_status (Live (This)) = 0;
    end Is_Ok;


    procedure Close
           (This : in out Pattern) is
    begin
        if This.Handle /= Null_Pointer then
            fl_cairo_pattern_destroy (This.Handle);
            This.Handle := Null_Pointer;
        end if;
    end Close;


    function Is_Closed
           (This : in Pattern)
        return Boolean is
    begin
        return This.Handle = Null_Pointer;
    end Is_Closed;


    procedure Finalize
           (This : in out Pattern) is
    begin
        Close (This);
    end Finalize;


end FLTK.Cairo;
