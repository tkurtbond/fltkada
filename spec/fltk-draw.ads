

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Strings.Unbounded,
    FLTK.Images.Pixmaps,
    FLTK.Images.RGB,
    FLTK.Widgets.Groups.Windows;


package FLTK.Draw is


    type Line_Kind is
       (Solid_Line,
        Dash_Line,
        Dot_Line,
        Dashdot_Line,
        Dashdotdot_Line);

    type Cap_Kind is
       (Default_Cap,
        Flat_Cap,
        Round_Cap,
        Square_Cap);

    type Join_Kind is
       (Default_Join,
        Miter_Join,
        Round_Join,
        Bevel_Join);

    --  Fl_Arrow_Type, FL_ARROW_SINGLE .. FL_ARROW_RETURN (1 .. 4).
    type Arrow_Kind is
       (Single_Arrow,
        Double_Arrow,
        Choice_Arrow,
        Return_Arrow);

    --  Fl_Orientation: the direction an arrow points, 45 degrees apart
    --  anticlockwise from Right.
    type Orientation_Kind is
       (Orient_Right,
        Orient_NE,
        Orient_Up,
        Orient_NW,
        Orient_Left,
        Orient_SW,
        Orient_Down,
        Orient_SE);

    --  A dash or gap is in pixels, not in multiples of the line width as the
    --  Line_Kind dashes are.  FLTK passes the lengths as a C char, which is
    --  signed on x86, so a length over 127 would be negative (pofltk 136).
    type Dash_Length is new Integer range 1 .. 127;

    type Dash_Gap is record
        Solid : Dash_Length;
        Blank : Dash_Length;
    end record;

    type Dash_Gap_Array is array (Positive range <>) of Dash_Gap;

    Empty_Dashes : constant Dash_Gap_Array (1 .. 0) := (others => (1, 1));

    --  Cairo and PostScript copy a pattern into an array of 256 chars, so
    --  Set_Line_Style raises Constraint_Error on more pairs than this
    --  (pofltk 136).  FLTK's OpenGL drawing ignores a pattern.
    Max_Dash_Gaps : constant := 127;

    type Image_Draw_Function is access procedure
           (X, Y : in     Natural;
            Data :    out Color_Component_Array);

    type Symbol_Draw_Function is access procedure
           (Hue : in Color);

    type Text_Draw_Function is access procedure
           (X, Y : in Integer;
            Text : in String);

    type Area_Draw_Function is access procedure
           (X, Y, W, H : in Integer);

    Draw_Error : exception;




    --  No Documentation  --

    procedure Reset_Spot;

    procedure Set_Spot
           (X, Y, W, H : in Integer;
            Font       : in Font_Kind;
            Size       : in Font_Size);

    procedure Set_Spot
           (X, Y, W, H : in Integer;
            Font       : in Font_Kind;
            Size       : in Font_Size;
            Pane       : in FLTK.Widgets.Groups.Windows.Window'Class);

    procedure Set_Status
           (X, Y, W, H : in Integer);




    --  Utility  --

    function Can_Do_Alpha_Blending
        return Boolean;

    function Shortcut_Label
           (Keys : in Key_Combo)
        return String;




    --  Charset Conversion  --

    function Latin1_To_Local
           (From : in String)
        return String;

    function Local_To_Latin1
           (From : in String)
        return String;

    function Mac_Roman_To_Local
           (From : in String)
        return String;

    function Local_To_Mac_Roman
           (From : in String)
        return String;




    --  Clipping  --

    --  True exactly when BX, BY, BW, BH differ from X, Y, W, H.  A box
    --  wholly outside the clip gives 0, 0, 0, 0.  FLTK's Cairo driver
    --  says the reverse, and leaves BH unset for a box outside (pofltk 2).
    function Clip_Box
           (X, Y, W, H     : in     Integer;
            BX, BY, BW, BH :    out Integer)
        return Boolean;

    function Clip_Intersects
           (X, Y, W, H : in Integer)
        return Boolean;

    procedure Pop_Clip;

    --  A clip pushed in a Draw that raises before Pop_Clip stays pushed,
    --  so pop it in a handler there before re-raising (FLTK-issues.md F3).
    procedure Push_Clip
           (X, Y, W, H : in Integer);

    procedure Push_No_Clip;

    --  Not needed by Ada programs, which can't change the clip behind
    --  FLTK's back; use Push_Clip and Pop_Clip.  Where FLTK draws with
    --  Cairo (on Wayland, and on X11 in a build with FLTK_USE_CAIRO), it
    --  drops any clip pushed with Push_Clip, so what follows is drawn
    --  outside it until that clip is popped (pofltk 128).
    procedure Restore_Clip;




    --  Overlay  --

    --  These two raise Program_Error unless a shown window is current and no
    --  other surface is: outside a window's Draw, or after Make_Current
    --  (pofltk 124).
    procedure Overlay_Clear;

    procedure Overlay_Rect
           (X, Y, W, H : in Integer);




    --  Settings  --

    function Get_Color
        return Color;

    procedure Set_Color
           (To : in Color);

    procedure Set_Color
           (R, G, B : in Color_Component);

    procedure Set_Cursor
           (To : in Mouse_Cursor_Kind);

    procedure Set_Cursor
           (To   : in Mouse_Cursor_Kind;
            Fore : in Color;
            Back : in Color := White_Color);

    function Get_Font
        return Font_Kind;

    function Get_Font_Size
        return Font_Size;

    procedure Set_Font
           (Kind : in Font_Kind;
            Size : in Font_Size);

    function Font_Line_Spacing
        return Integer;

    function Font_Descent
        return Integer;

    function Font_Height
           (Kind : in Font_Kind;
            Size : in Font_Size)
        return Natural;

    procedure Set_Line_Style
           (Line   : in Line_Kind      := Solid_Line;
            Cap    : in Cap_Kind       := Default_Cap;
            Join   : in Join_Kind      := Default_Join;
            Width  : in Natural        := 0;
            Dashes : in Dash_Gap_Array := Empty_Dashes);

    --  Whether lines are drawn antialiased.  Only FLTK's Cairo drawing
    --  (X11 with Cairo, and Wayland) can change it.  Raises Program_Error
    --  with nothing to draw on, neither a shown window current nor a
    --  surface (pofltk 124).
    function Get_Antialias
        return Boolean;

    procedure Set_Antialias
           (To : in Boolean);

    --  Draws at the scale of the screen's pixels until Restore_Scale, and
    --  returns the scale that was in effect, to pass to Restore_Scale.
    --  Both raise Program_Error with nothing to draw on: FLTK crashes when
    --  the scale isn't 1 (Fl_Cairo_Graphics_Driver.cxx:1493-1508).
    function Override_Scale
        return Float;

    procedure Restore_Scale
           (Factor : in Float);




    --  Matrix Operations  --

    --  Load_Identity and Load_Matrix replace the current matrix, where
    --  Mult_Matrix multiplies it.
    procedure Load_Identity;

    procedure Load_Matrix
           (A, B, C, D, X, Y : in Long_Float);

    procedure Mult_Matrix
           (A, B, C, D, X, Y : in Long_Float);

    procedure Pop_Matrix;

    procedure Push_Matrix;

    procedure Rotate
           (Angle : in Long_Float);

    procedure Scale
           (Factor : in Long_Float);

    procedure Scale
           (Factor_X, Factor_Y : in Long_Float);

    function Transform_DX
           (X, Y : in Long_Float)
        return Long_Float;

    function Transform_DY
           (X, Y : in Long_Float)
        return Long_Float;

    function Transform_X
           (X, Y : in Long_Float)
        return Long_Float;

    function Transform_Y
           (X, Y : in Long_Float)
        return Long_Float;

    procedure Transformed_Vertex
           (XF, YF : in Long_Float);

    procedure Translate
           (X, Y : in Long_Float);

    procedure Vertex
           (X, Y : in Long_Float);




    --  Image Drawing  --

    --  Each Draw_Image and Draw_Image_Mono raises Draw_Error inside an
    --  Image_Draw_Function.  FLTK's Xlib drawing keeps its image and buffer
    --  in statics, which the inner image would spoil, or free while the
    --  outer one writes to them (pofltk 133).  The outer Draw_Image then
    --  raises it, once FLTK returns.
    --
    --  A W or H below 1 draws nothing (FLTK-issues.md F34).  Data must hold
    --  (H - 1) * Line_Size + W * Depth bytes (Line_Size 0 means W * Depth),
    --  or Constraint_Error is raised.  The flips read the same Data the
    --  other way round (FLTKAda-BUGS.md 117).
    procedure Draw_Image
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 3;
            Line_Size       : in Natural := 0;
            Flip_Horizontal : in Boolean := False;
            Flip_Vertical   : in Boolean := False);

    procedure Draw_Image
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 3);

    procedure Draw_Image_Mono
           (X, Y, W, H      : in Integer;
            Data            : in Color_Component_Array;
            Depth           : in Positive := 1;
            Line_Size       : in Natural := 0;
            Flip_Horizontal : Boolean := False;
            Flip_Vertical   : Boolean := False);

    procedure Draw_Image_Mono
           (X, Y, W, H : in Integer;
            Callback   : in Image_Draw_Function;
            Depth      : in Positive := 1);

    procedure Draw_Pixmap
           (Values : in FLTK.Images.Pixmaps.Header;
            Colors : in FLTK.Images.Pixmaps.Color_Definition_Array;
            Pixels : in FLTK.Images.Pixmaps.Pixmap_Data;
            X, Y   : in Integer;
            Tone   : in Color := Grey0_Color)
    with Pre =>
        Colors'Length = Values.Colors and
        Pixels'Length (1) = Values.Height and
        (for all Definition of Colors =>
            Ada.Strings.Unbounded.Length (Definition.Name) = Values.Per_Pixel) and
        Pixels'Length (2) = Values.Width * Values.Per_Pixel;

    --  Only the part of the rectangle inside the window or surface drawn on
    --  is read, into its place in the result, and the rest is zeros: FLTK
    --  doesn't clip, and reads or writes outside its buffers (pofltk 127).
    --  Raises Draw_Error if nothing is drawn on (a shown window that is
    --  current, as in its Draw, or a surface such as an Image_Surface), or
    --  FLTK couldn't read it.
    function Read_Image
           (X, Y, W, H : in Integer;
            Alpha      : in Integer := 0)
        return Color_Component_Array
    with Post =>
       (if Alpha = 0
        then Read_Image'Result'Length = Size_Type (W) * Size_Type (H) * 3
        else Read_Image'Result'Length = Size_Type (W) * Size_Type (H) * 4);

    --  What Item shows of the rectangle X, Y, W, H, with what is drawn on its
    --  subwindows, as an image of the part of the rectangle inside Item: FLTK
    --  doesn't clip, and writes or reads outside its buffers (pofltk 127).
    --  Raises Draw_Error if Item was never made or isn't shown, or no part of
    --  the rectangle is inside it.
    function Capture_Window
           (Item       : in FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H : in Integer)
        return FLTK.Images.RGB.RGB_Image;




    --  Special Drawing  --

    --  The name is copied and kept.  Raises Draw_Error if FLTK's symbol table is
    --  full, or if the name is refused: one that is empty, holds an @ or a byte
    --  outside ASCII, or starts the way a symbol's modifiers do (#, $, %, a digit,
    --  or - or + then 1 to 9), since a label could never name it.
    procedure Add_Symbol
           (Text     : in String;
            Callback : in Symbol_Draw_Function;
            Scalable : in Boolean);

    procedure Draw_Text
           (X, Y : in Integer;
            Text : in String)
    with Pre => Text'Length > 0;

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Picture    : in FLTK.Images.Image'Class;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Callback   : in Text_Draw_Function;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y, W, H : in Integer;
            Text       : in String;
            Align      : in Alignment;
            Callback   : in Text_Draw_Function;
            Picture    : in FLTK.Images.Image'Class;
            Symbols    : in Boolean := True);

    procedure Draw_Text
           (X, Y  : in Integer;
            Text  : in String;
            Angle : in Integer);

    procedure Draw_Text_Right_Left
           (X, Y : in Integer;
            Text : in String);

    procedure Draw_Box
           (X, Y, W, H : in Integer;
            Kind       : in Box_Kind;
            Hue        : in Color);

    --  The focus frame Kind draws inside a box, if Visible_Focus is on.
    procedure Draw_Box_Focus
           (X, Y, W, H : in Integer;
            Kind       : in Box_Kind;
            Fore, Back : in Color);

    --  A check mark, centred in the box.
    procedure Draw_Check
           (X, Y, W, H : in Integer;
            Hue        : in Color);

    --  A radio button of diameter D, as the scheme draws it.
    procedure Draw_Radio
           (X, Y, D : in Integer;
            Hue     : in Color);

    procedure Draw_Arrow
           (X, Y, W, H : in Integer;
            Kind       : in Arrow_Kind;
            Direction  : in Orientation_Kind;
            Hue        : in Color);

    --  Raises Draw_Error if Name does not start with @, names no symbol, or holds
    --  a byte outside ASCII (FLTK's symbol lookup misbehaves on those).
    procedure Draw_Symbol
           (X, Y, W, H : in Integer;
            Name       : in String;
            Hue        : in Color);

    procedure Measure
           (Text    : in     String;
            W, H    :    out Natural;
            Symbols : in     Boolean := True;
            Wrap    : in     Natural := 0);

    --  On a surface other than the display, there are no pixels to move, so
    --  Callback draws the whole area again.  Otherwise a shown window must be
    --  current, as in its Draw, or Program_Error is raised (pofltk 124).
    procedure Scroll
           (X, Y, W, H : in Integer;
            DX, DY     : in Integer;
            Callback   : in Area_Draw_Function);

    procedure Text_Extents
           (Text         : in     String;
            DX, DY, W, H :    out Integer);

    --  Last is the index of the last character processed in Text which
    --  would normally be one before the index of the char pointed at by
    --  the return value in the C++ version. Instead, the return value
    --  here is the processed text buffer.
    function Expand_Text
           (Text      : in     String;
            Max_Width : in     Long_Float;
            Width     :    out Long_Float;
            Last      :    out Natural;
            Wrap      : in     Boolean;
            Symbols   : in     Boolean := False)
        return String;

    function Width
           (Text : in String)
        return Long_Float;

    function Width
           (Glyph : in Character)
        return Long_Float;

    function Width
           (Glyph : in Wide_Character)
        return Long_Float;

    function Width
           (Glyph : in Wide_Wide_Character)
        return Long_Float;




    --  Manual Drawing  --

    procedure Begin_Complex_Polygon;
    procedure Begin_Line;
    procedure Begin_Loop;
    procedure Begin_Points;
    procedure Begin_Polygon;

    procedure Arc
           (X, Y, R, Start, Finish : in Long_Float);

    procedure Arc
           (X, Y, W, H    : in Integer;
            Start, Finish : in Long_Float);

    --  As per 1.3.9 docs, currently a placeholder
    procedure Chord
           (X, Y, W, H     : in Integer;
            Angle1, Angle2 : in Long_Float);

    procedure Circle
           (X, Y, R : in Long_Float);

    procedure Curve
           (X0, Y0 : in Long_Float;
            X1, Y1 : in Long_Float;
            X2, Y2 : in Long_Float;
            X3, Y3 : in Long_Float);

    procedure Frame
           (X, Y, W, H               : in Integer;
            Top, Left, Bottom, Right : in Greyscale);

    --  Frame, with the sides drawn in the other order.
    procedure Frame2
           (X, Y, W, H               : in Integer;
            Bottom, Right, Top, Left : in Greyscale);

    procedure Focus_Rect
           (X, Y, W, H : in Integer);

    procedure Gap;

    procedure Line
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer);

    procedure Line
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer);

    procedure Outline
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer);

    procedure Outline
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer;
            X3, Y3 : in Integer);

    procedure Pie
           (X, Y, W, H     : in Integer;
            Angle1, Angle2 : in Long_Float);

    procedure Point
           (X, Y : in Integer);

    procedure Polygon
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer);

    procedure Polygon
           (X0, Y0 : in Integer;
            X1, Y1 : in Integer;
            X2, Y2 : in Integer;
            X3, Y3 : in Integer);

    procedure Rect
           (X, Y, W, H : in Integer);

    procedure Rect
           (X, Y, W, H : in Integer;
            Hue        : in Color);

    procedure Rect_Fill
           (X, Y, W, H : in Integer);

    procedure Rect_Fill
           (X, Y, W, H : in Integer;
            Hue        : in Color);

    procedure Rect_Fill
           (X, Y, W, H : in Integer;
            R, G, B    : in Color_Component);

    procedure Rounded_Rect
           (X, Y, W, H, R : in Integer);

    procedure Rounded_Rect_Fill
           (X, Y, W, H, R : in Integer);

    procedure Ecks_Why_Line
           (X0, Y0, X1 : in Integer);

    procedure Ecks_Why_Line
           (X0, Y0, X1, Y2 : in Integer);

    procedure Ecks_Why_Line
           (X0, Y0, X1, Y2, X3 : in Integer);

    procedure Why_Ecks_Line
           (X0, Y0, Y1 : in Integer);

    procedure Why_Ecks_Line
           (X0, Y0, Y1, X2 : in Integer);

    procedure Why_Ecks_Line
           (X0, Y0, Y1, X2, Y3 : in Integer);

    procedure End_Complex_Polygon;
    procedure End_Line;
    procedure End_Loop;
    procedure End_Points;
    procedure End_Polygon;


private


    pragma Convention (C, Symbol_Draw_Function);


    pragma Import (C, Reset_Spot,    "fl_draw_reset_spot");

    pragma Import (C, Pop_Clip,      "fl_draw_pop_clip");
    pragma Import (C, Push_No_Clip,  "fl_draw_push_no_clip");
    pragma Import (C, Restore_Clip,  "fl_draw_restore_clip");


    pragma Import (C, Pop_Matrix,    "fl_draw_pop_matrix");
    pragma Import (C, Push_Matrix,   "fl_draw_push_matrix");

    pragma Import (C, Begin_Complex_Polygon, "fl_draw_begin_complex_polygon");
    pragma Import (C, Begin_Line,    "fl_draw_begin_line");
    pragma Import (C, Begin_Loop,    "fl_draw_begin_loop");
    pragma Import (C, Begin_Points,  "fl_draw_begin_points");
    pragma Import (C, Begin_Polygon, "fl_draw_begin_polygon");

    pragma Import (C, Gap,           "fl_draw_gap");

    pragma Import (C, End_Complex_Polygon, "fl_draw_end_complex_polygon");
    pragma Import (C, End_Line,      "fl_draw_end_line");
    pragma Import (C, End_Loop,      "fl_draw_end_loop");
    pragma Import (C, End_Points,    "fl_draw_end_points");
    pragma Import (C, End_Polygon,   "fl_draw_end_polygon");


    pragma Inline (Reset_Spot);
    pragma Inline (Set_Spot);
    pragma Inline (Set_Status);

    pragma Inline (Can_Do_Alpha_Blending);
    pragma Inline (Shortcut_Label);

    pragma Inline (Latin1_To_Local);
    pragma Inline (Local_To_Latin1);
    pragma Inline (Mac_Roman_To_Local);
    pragma Inline (Local_To_Mac_Roman);

    pragma Inline (Clip_Intersects);
    pragma Inline (Pop_Clip);
    pragma Inline (Push_Clip);
    pragma Inline (Push_No_Clip);
    pragma Inline (Restore_Clip);

    pragma Inline (Overlay_Clear);
    pragma Inline (Overlay_Rect);

    pragma Inline (Get_Color);
    pragma Inline (Set_Color);
    pragma Inline (Get_Font);
    pragma Inline (Get_Font_Size);
    pragma Inline (Set_Font);
    pragma Inline (Font_Line_Spacing);
    pragma Inline (Font_Descent);
    pragma Inline (Font_Height);

    pragma Inline (Load_Identity);
    pragma Inline (Load_Matrix);
    pragma Inline (Mult_Matrix);
    pragma Inline (Pop_Matrix);
    pragma Inline (Push_Matrix);
    pragma Inline (Rotate);
    pragma Inline (Scale);
    pragma Inline (Transform_DX);
    pragma Inline (Transform_DY);
    pragma Inline (Transform_X);
    pragma Inline (Transform_Y);
    pragma Inline (Transformed_Vertex);
    pragma Inline (Translate);
    pragma Inline (Vertex);

    pragma Inline (Add_Symbol);
    pragma Inline (Draw_Text);
    pragma Inline (Draw_Text_Right_Left);
    pragma Inline (Draw_Box);
    pragma Inline (Draw_Symbol);
    pragma Inline (Measure);
    pragma Inline (Scroll);
    pragma Inline (Text_Extents);
    pragma Inline (Width);

    pragma Inline (Begin_Complex_Polygon);
    pragma Inline (Begin_Line);
    pragma Inline (Begin_Loop);
    pragma Inline (Begin_Points);
    pragma Inline (Begin_Polygon);

    pragma Inline (Arc);
    pragma Inline (Chord);
    pragma Inline (Circle);
    pragma Inline (Curve);
    pragma Inline (Frame);
    pragma Inline (Frame2);
    pragma Inline (Focus_Rect);
    pragma Inline (Rounded_Rect);
    pragma Inline (Rounded_Rect_Fill);
    pragma Inline (Draw_Box_Focus);
    pragma Inline (Draw_Check);
    pragma Inline (Draw_Radio);
    pragma Inline (Draw_Arrow);
    pragma Inline (Gap);
    pragma Inline (Line);
    pragma Inline (Outline);
    pragma Inline (Pie);
    pragma Inline (Point);
    pragma Inline (Polygon);
    pragma Inline (Rect);
    pragma Inline (Rect_Fill);
    pragma Inline (Ecks_Why_Line);
    pragma Inline (Why_Ecks_Line);

    pragma Inline (End_Complex_Polygon);
    pragma Inline (End_Line);
    pragma Inline (End_Loop);
    pragma Inline (End_Points);
    pragma Inline (End_Polygon);


end FLTK.Draw;


