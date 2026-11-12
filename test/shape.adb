--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/shape.cxx: a polygon drawn with GL, in a GL window that is
--  a child of a plain one.  The slider sets its number of sides.  Guided
--  by pofltk's Shape.Mod.


with

    Ada.Numerics.Long_Elementary_Functions,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows.OpenGL,
    FLTK.Widgets.Valuators.Sliders.Horizontal,
    GL1;

use

    Ada.Numerics.Long_Elementary_Functions,
    GL1;


function Shape
    return Integer
is

    package Win renames FLTK.Widgets.Groups.Windows;
    package OGL renames FLTK.Widgets.Groups.Windows.OpenGL;
    package HS  renames FLTK.Widgets.Valuators.Sliders.Horizontal;


    type Shape_Window is new OGL.GL_Window with record
        Sides : Positive := 3;
    end record;

    overriding procedure Draw
           (This : in out Shape_Window);

    procedure Draw
           (This : in out Shape_Window)
    is
        Ang : Long_Float;
    begin
        --  Get_Valid may be used to avoid setting up GL's transformation
        --  at each draw.
        if not This.Get_Valid then
            This.Set_Valid (True);
            glLoadIdentity;
            glViewport (0, 0, GLsizei (This.Pixel_W), GLsizei (This.Pixel_H));
        end if;
        --  Draw an amazing graphic.
        glClear (GL_COLOR_BUFFER_BIT);
        glColor3f (0.5, 0.6, 0.7);
        glBegin (GL_POLYGON);
        for J in 0 .. This.Sides - 1 loop
            Ang := Long_Float (J) * 2.0 * Ada.Numerics.Pi / Long_Float (This.Sides);
            glVertex3f (GLfloat (Cos (Ang)), GLfloat (Sin (Ang)), 0.0);
        end loop;
        glEnd;
    end Draw;


begin

    FLTK.Static.Set_Use_High_Res_GL (True);

    declare

        Window : Win.Window := Win.Forge.Create (300, 330);

        --  The shape window could be its own window, but here it is a
        --  child.
        SW : Shape_Window := (OGL.Forge.Create (Window, 10, 10, 280, 280) with others => <>);

        Slider : HS.Horizontal_Slider :=
            HS.Forge.Create (Window, 50, 295, Window.Get_W - 60, 30, "Sides:");

        --  When the data changes, as here, Redraw must be called.
        procedure Sides_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            SW.Sides := Integer (HS.Horizontal_Slider (Item).Get_Value);
            SW.Redraw;
        end Sides_CB;

    begin
        --  Make it resize.
        Window.Set_Resizable (SW);
        Slider.Set_Alignment (FLTK.Align_Left);
        Slider.Set_Callback (Sides_CB'Unrestricted_Access);
        Slider.Set_Value (Long_Float (SW.Sides));
        Slider.Set_Step (1);
        Slider.Set_Bounds (3.0, 40.0);
        Window.Show_With_Args;
        return FLTK.Run;
    end;

end Shape;
