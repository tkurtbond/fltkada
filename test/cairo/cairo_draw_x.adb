

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's examples/cairo-draw-x.cxx, after pofltk's examples/CairoDrawX.Mod:
--  an orange X across a resizable window, drawn with FLTK.Cairo.  FLTK's
--  program uses Fl_Cairo_Window, which only an FLTK built for it has;
--  examples/cairo_draw_x.adb is that port.  This one draws on any FLTK
--  with X11 or Wayland.


with

    FLTK.Cairo,
    FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;


function Cairo_Draw_X
    return Integer
is

    package Cai renames FLTK.Cairo;
    package CDW renames FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;


    type X_Window is new CDW.Cairo_Drawn_Window with null record;

    overriding procedure Draw_Cairo
           (This    : in out X_Window;
            Context : in     Cai.Context)
    is
        X_Max : constant Long_Float := Long_Float (This.Get_W - 1);
        Y_Max : constant Long_Float := Long_Float (This.Get_H - 1);
    begin
        Cai.Set_Antialias (Context, Cai.Default_Antialias);
        Cai.Set_Line_Width (Context, 1.0);
        Cai.Set_Source_RGB (Context, 1.0, 0.5, 0.0);
        Cai.Move_To (Context, 0.0, 0.0);
        Cai.Line_To (Context, X_Max, Y_Max);
        Cai.Move_To (Context, 0.0, Y_Max);
        Cai.Line_To (Context, X_Max, 0.0);
        Cai.Stroke (Context);
    end Draw_Cairo;


    Window : X_Window := (CDW.Forge.Create (300, 300, "Cairo Draw 'X'") with null record);


begin


    Window.Set_Background_Color (FLTK.Black_Color);
    Window.Set_Size_Range (50, 50);
    Window.Set_Resizable (Window);
    Window.Show_With_Args;
    return FLTK.Run;


end Cairo_Draw_X;


