

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/cairo-draw-x.cxx: an orange "X" drawn with
--  Cairo to the four corners of a resizable window.
--
--  FLTK's program uses Fl_Cairo_Window, and so does this port, which
--  imports the few cairo functions it uses directly, since Cairo_Window
--  gives its callback cairo's own context; examples.gpr links it with
--  -lcairo.  Without an FLTK built with Cairo support, Set_Cairo_Draw
--  raises Unsupported_Error.  test/cairo/cairo_draw_x.adb draws the same
--  with FLTK.Cairo's Cairo_Drawn_Window, which works on any FLTK with X11
--  or Wayland.


with

    Interfaces.C,
    System,
    FLTK.Widgets.Groups.Windows.Double.Cairo;


function Cairo_Draw_X
    return Integer
is


    package C  renames Interfaces.C;
    package CW renames FLTK.Widgets.Groups.Windows.Double.Cairo;


    --  The parts of cairo.h used here

    CAIRO_ANTIALIAS_DEFAULT : constant C.int := 0;

    procedure cairo_set_antialias
           (Cr        : in System.Address;
            Antialias : in C.int);
    pragma Import (C, cairo_set_antialias, "cairo_set_antialias");

    procedure cairo_set_line_width
           (Cr    : in System.Address;
            Width : in C.double);
    pragma Import (C, cairo_set_line_width, "cairo_set_line_width");

    procedure cairo_set_source_rgb
           (Cr      : in System.Address;
            R, G, B : in C.double);
    pragma Import (C, cairo_set_source_rgb, "cairo_set_source_rgb");

    procedure cairo_move_to
           (Cr   : in System.Address;
            X, Y : in C.double);
    pragma Import (C, cairo_move_to, "cairo_move_to");

    procedure cairo_line_to
           (Cr   : in System.Address;
            X, Y : in C.double);
    pragma Import (C, cairo_line_to, "cairo_line_to");

    procedure cairo_stroke
           (Cr : in System.Address);
    pragma Import (C, cairo_stroke, "cairo_stroke");


    --  Cairo rendering cb called during Cairo_Window's Draw
    procedure My_Cairo_Draw_CB
           (Window : in out CW.Cairo_Window;
            Cr     : in     System.Address)
    is
        Xmax : constant C.double := C.double (Window.Get_W - 1);
        Ymax : constant C.double := C.double (Window.Get_H - 1);
    begin
        --  Set antialiasing mode. We could check the Cairo version at compile time but we'd
        --  also have to check the runtime version which would make this demo too complicated.

        --  CAIRO_ANTIALIAS_BEST    is available since Cairo version 1.12,
        --  CAIRO_ANTIALIAS_DEFAULT is available since Cairo version 1.0.

        cairo_set_antialias (Cr, CAIRO_ANTIALIAS_DEFAULT);       --  use default antialiasing

        --  Draw orange "X"
        --      Draws an X to four corners of resizable window.
        --      See Fl_Cairo_Window docs for more info.
        --
        cairo_set_line_width (Cr, 1.00);                          --  line width for drawing
        cairo_set_source_rgb (Cr, 1.0, 0.5, 0.0);                 --  orange
        cairo_move_to (Cr, 0.0, 0.0);
        cairo_line_to (Cr, Xmax, Ymax);                           --  draw diagonal "\"
        cairo_move_to (Cr, 0.0, Ymax);
        cairo_line_to (Cr, Xmax, 0.0);                            --  draw diagonal "/"
        cairo_stroke (Cr);                                        --  stroke the lines
    end My_Cairo_Draw_CB;


    Window : CW.Cairo_Window := CW.Forge.Create (300, 300, "Cairo Draw 'X'");


begin


    Window.Set_Background_Color (FLTK.Black_Color);   --  cairo window's default bg color
    Window.Set_Size_Range (50, 50, -1, -1);           --  allow resize 50,50 and up
    Window.Set_Resizable (Window);                    --  allow window to be resized
    Window.Set_Cairo_Draw (My_Cairo_Draw_CB'Unrestricted_Access);   --  draw callback
    Window.Show_With_Args;
    return FLTK.Run;


end Cairo_Draw_X;
