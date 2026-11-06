--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/gl_overlay.cxx: a shaded polygon in a GL window, with a red
--  outline of another drawn over it in the window's overlay.  One slider
--  sets the polygon's sides, the other the outline's.  Without a hardware
--  overlay, which is usual, FLTK draws the overlay in the front buffer over
--  the window.


with

    Ada.Numerics.Long_Elementary_Functions,
    Ada.Text_IO,
    FLTK.Draw.OpenGL,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows.OpenGL,
    FLTK.Widgets.Valuators.Sliders.Horizontal,
    GL1,
    Interfaces.C;

use

    GL1;

use type

    Interfaces.C.C_float;


function GL_Overlay
    return Integer
is

    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package HSl renames FLTK.Widgets.Valuators.Sliders.Horizontal;
    package Wdg renames FLTK.Widgets;

    use Ada.Numerics.Long_Elementary_Functions;


    type Shape_Window is new OGL.GL_Window with record
        Sides         : Positive := 3;
        Overlay_Sides : Positive := 3;
    end record;

    overriding procedure Draw
           (This : in out Shape_Window);

    overriding procedure Draw_Overlay
           (This : in out Shape_Window);

    --  The valid flag saves setting up the GL transformation on each draw.
    procedure Set_Up
           (This : in out Shape_Window) is
    begin
        if not This.Get_Valid then
            This.Set_Valid (True);
            glLoadIdentity;
            glViewport (0, 0, GLsizei (This.Pixel_W), GLsizei (This.Pixel_H));
        end if;
    end Set_Up;

    procedure Vertex
           (J, Sides : in Natural)
    is
        Angle : constant Long_Float :=
            Long_Float (J) * 2.0 * Ada.Numerics.Pi / Long_Float (Sides);
    begin
        glVertex3f (GLfloat (Cos (Angle)), GLfloat (Sin (Angle)), 0.0);
    end Vertex;

    procedure Draw
           (This : in out Shape_Window) is
    begin
        Set_Up (This);
        glClear (GL_COLOR_BUFFER_BIT);
        glBegin (GL_POLYGON);
        for J in 0 .. This.Sides - 1 loop
            declare
                Shade : constant GLfloat := GLfloat (J) / GLfloat (This.Sides);
            begin
                glColor3f (Shade, Shade, Shade);
            end;
            Vertex (J, This.Sides);
        end loop;
        glEnd;
    end Draw;

    procedure Draw_Overlay
           (This : in out Shape_Window) is
    begin
        Set_Up (This);
        FLTK.Draw.OpenGL.Set_Color (FLTK.Red_Color);
        glBegin (GL_LINE_LOOP);
        for J in 0 .. This.Overlay_Sides - 1 loop
            Vertex (J, This.Overlay_Sides);
        end loop;
        glEnd;
    end Draw_Overlay;


    Window : Win.Window := Win.Forge.Create (300, 370);

    Shape : Shape_Window :=
       (OGL.Forge.Create (Window, 10, 75, 300 - 20, 370 - 90) with others => <>);

    Slider  : HSl.Horizontal_Slider :=
        HSl.Forge.Create (Window, 60, 5, 300 - 70, 30, "Sides:");
    OSlider : HSl.Horizontal_Slider :=
        HSl.Forge.Create (Window, 60, 40, 300 - 70, 30, "Overlay:");


    --  When the data changes, as here, the window must be redrawn.
    procedure Sides_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Shape.Sides := Positive (HSl.Horizontal_Slider (Item).Get_Value);
        Shape.Redraw;
    end Sides_CB;

    procedure Overlay_Sides_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Shape.Overlay_Sides := Positive (HSl.Horizontal_Slider (Item).Get_Value);
        Shape.Redraw_Overlay;
    end Overlay_Sides_CB;

begin

    FLTK.Static.Set_Use_High_Res_GL (True);
    Window.Set_Resizable (Shape);

    Slider.Set_Alignment (FLTK.Align_Left);
    Slider.Set_Callback (Sides_CB'Unrestricted_Access);
    Slider.Set_Value (Long_Float (Shape.Sides));
    Slider.Set_Step (1.0, 1);
    Slider.Set_Bounds (3.0, 40.0);

    OSlider.Set_Alignment (FLTK.Align_Left);
    OSlider.Set_Callback (Overlay_Sides_CB'Unrestricted_Access);
    OSlider.Set_Value (Long_Float (Shape.Overlay_Sides));
    OSlider.Set_Step (1.0, 1);
    OSlider.Set_Bounds (3.0, 40.0);

    Window.Show_With_Args;
    Ada.Text_IO.Put_Line
        ("Can do overlay =" & Integer'Image (Boolean'Pos (Shape.Can_Do_Overlay)));
    Shape.Show;
    Shape.Redraw_Overlay;

    return FLTK.Run;

end GL_Overlay;
