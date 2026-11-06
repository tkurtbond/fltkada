


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Drawing with the mouse, after pofltk's examples/Scribble.Mod:  a box
--  that overrides both Handle and Draw.
--
--  Drag with the left button to draw.  The right button clears, and
--  Escape quits.  The box keeps every stroke, and Draw draws them all,
--  so the drawing survives the window being covered.


with

    Ada.Containers.Vectors,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double;


function Scribble
    return Integer
is


    package Drw renames FLTK.Draw;
    package Ev  renames FLTK.Events;
    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    use type FLTK.Mouse_Button;


    type Point is record
        X, Y : Integer;
    end record;

    package Point_Vectors is new Ada.Containers.Vectors (Positive, Point);

    package Stroke_Vectors is new Ada.Containers.Vectors
        (Positive, Point_Vectors.Vector, Point_Vectors."=");


    type Canvas is new Bx.Box with record
        Strokes : Stroke_Vectors.Vector;
        --  Whether a stroke is being drawn:  from a left press to its release.
        Drawing : Boolean := False;
    end record;

    overriding procedure Draw
           (This : in out Canvas);

    overriding function Handle
           (This  : in out Canvas;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    procedure Draw
           (This : in out Canvas) is
    begin
        This.Draw_Box;
        Drw.Push_Clip (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        Drw.Set_Color (FLTK.Dark_Blue_Color);
        Drw.Set_Line_Style
           (Cap   => Drw.Round_Cap,
            Join  => Drw.Round_Join,
            Width => 3);
        for Stroke of This.Strokes loop
            Drw.Begin_Line;
            for Dot of Stroke loop
                Drw.Vertex (Long_Float (Dot.X), Long_Float (Dot.Y));
            end loop;
            Drw.End_Line;
        end loop;
        Drw.Set_Line_Style;
        if This.Strokes.Is_Empty then
            This.Draw_Label;
        end if;
        Drw.Pop_Clip;
    end Draw;


    function Handle
           (This  : in out Canvas;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        case Event is
            when FLTK.Push =>
                if Ev.Last_Button = FLTK.Right_Button then
                    This.Strokes.Clear;
                    This.Drawing := False;
                else
                    This.Strokes.Append (Point_Vectors.To_Vector ((Ev.Mouse_X, Ev.Mouse_Y), 1));
                    This.Drawing := True;
                end if;
                This.Redraw;
                return FLTK.Handled;
            when FLTK.Drag =>
                if This.Drawing then
                    This.Strokes.Reference (This.Strokes.Last_Index).Append
                        ((Ev.Mouse_X, Ev.Mouse_Y));
                    This.Redraw;
                    return FLTK.Handled;
                end if;
            when FLTK.Release =>
                This.Drawing := False;
                return FLTK.Handled;
            when others =>
                null;
        end case;
        return Bx.Box (This).Handle (Event);
    end Handle;


    Window : Dbl.Double_Window := Dbl.Forge.Create (400, 300, "Scribble");
    Board  : Canvas :=
       (Bx.Forge.Create (Window, 0, 0, 400, 300, "Drag to draw; right-click clears")
        with others => <>);


begin


    Board.Set_Box (FLTK.Flat_Box);
    Board.Set_Background_Color (FLTK.White_Color);
    Board.Set_Label_Color (FLTK.Grey_Ramp ('M'));
    Window.Set_Resizable (Board);
    Window.Show;

    return FLTK.Run;


end Scribble;


