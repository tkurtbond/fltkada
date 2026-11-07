

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A Forms free object, after pofltk's examples/FreeForm.Mod:  it traces
--  the mouse with a line that shortens by itself.
--
--  A Free hears everything through one function, Handle_Free:  the mouse,
--  drawing (Draw_Event), and, since this one is a continuous free, a step
--  (Step_Event) a hundred times a second.


with

    FLTK.Draw,
    FLTK.Widgets.Forms.Frees,
    FLTK.Widgets.Groups.Windows.Double;


function Free_Form
    return Integer
is


    package Drw renames FLTK.Draw;
    package Fre renames FLTK.Widgets.Forms.Frees;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;


    Points : constant := 200;
    --  Steps before the oldest point goes.
    Steps_Per_Point : constant := 5;

    type Point is record
        X, Y : Integer;
    end record;

    type Point_Index is mod Points;

    type Trail is array (Point_Index) of Point;


    --  The trail, oldest first from First, wrapping.
    type Tracer is new Fre.Free with record
        Trace  : Trail;
        First  : Point_Index := 0;
        Count  : Natural range 0 .. Points := 0;
        Steps  : Natural := 0;
    end record;

    overriding function Handle_Free
           (This  : in out Tracer;
            Kind  : in     Fre.Free_Event_Kind;
            Event : in     FLTK.Event_Kind;
            X, Y  : in     Integer)
        return Boolean;


    procedure Add_Point
           (This : in out Tracer;
            X, Y : in     Integer) is
    begin
        This.Trace (This.First + Point_Index (This.Count mod Points)) := (X, Y);
        if This.Count < Points then
            This.Count := This.Count + 1;
        else
            This.First := This.First + 1;
        end if;
        This.Redraw;
    end Add_Point;


    procedure Shorten
           (This : in out Tracer) is
    begin
        This.Steps := This.Steps + 1;
        if This.Steps >= Steps_Per_Point and This.Count > 0 then
            This.Steps := 0;
            This.First := This.First + 1;
            This.Count := This.Count - 1;
            This.Redraw;
        end if;
    end Shorten;


    procedure Draw_Trail
           (This : in out Tracer)
    is
        A, B  : Point_Index;
        Shade : FLTK.Color_Component;
    begin
        Drw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H, FLTK.White_Color);
        for I in 1 .. This.Count - 1 loop
            A := This.First + Point_Index (I - 1);
            B := This.First + Point_Index (I);
            --  The oldest palest.
            Shade := FLTK.Color_Component (255 - 255 * I / This.Count);
            Drw.Set_Color (Shade, Shade, 255);
            Drw.Line (This.Trace (A).X, This.Trace (A).Y, This.Trace (B).X, This.Trace (B).Y);
        end loop;
    end Draw_Trail;


    function Handle_Free
           (This  : in out Tracer;
            Kind  : in     Fre.Free_Event_Kind;
            Event : in     FLTK.Event_Kind;
            X, Y  : in     Integer)
        return Boolean is
    begin
        case Kind is
            when Fre.Draw_Event =>
                Draw_Trail (This);
            when Fre.Step_Event =>
                Shorten (This);
            when Fre.FLTK_Event =>
                case Event is
                    when FLTK.Move | FLTK.Drag =>
                        Add_Point (This, X, Y);
                    when others =>
                        null;
                end case;
        end case;
        return False;
    end Handle_Free;


    Window : Dbl.Double_Window := Dbl.Forge.Create (400, 300, "Free form");
    Trace  : constant Tracer :=
       (Fre.Forge.Create (Window, Fre.Continuous_Free, 10, 10, 380, 280) with others => <>);


begin


    Window.Set_Resizable (Trace);
    Window.Show;

    return FLTK.Run;


end Free_Form;
