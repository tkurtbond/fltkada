

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  The hook that calls Draw_Cairo is in FLTK.Cairo's body, which alone can
--  make a Context.


with

    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn is


    ------------------------
    --  Functions From C  --
    ------------------------

    function fl_cairo_drawn_window_supported
        return Interfaces.C.int;
    pragma Import (C, fl_cairo_drawn_window_supported, "fl_cairo_drawn_window_supported");
    pragma Inline (fl_cairo_drawn_window_supported);




    --  Allocation  --

    function new_fl_cairo_drawn_window
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_cairo_drawn_window, "new_fl_cairo_drawn_window");
    pragma Inline (new_fl_cairo_drawn_window);

    function new_fl_cairo_drawn_window2
           (W, H : in Interfaces.C.int;
            Text : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_cairo_drawn_window2, "new_fl_cairo_drawn_window2");
    pragma Inline (new_fl_cairo_drawn_window2);

    procedure free_fl_cairo_drawn_window
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_cairo_drawn_window, "free_fl_cairo_drawn_window");
    pragma Inline (free_fl_cairo_drawn_window);




    --  Drawing, Events  --

    procedure fl_cairo_drawn_window_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_cairo_drawn_window_draw, "fl_cairo_drawn_window_draw");
    pragma Inline (fl_cairo_drawn_window_draw);

    function fl_cairo_drawn_window_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_cairo_drawn_window_handle, "fl_cairo_drawn_window_handle");
    pragma Inline (fl_cairo_drawn_window_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Cairo_Drawn_Window) is
    begin
        Extra_Final (Double_Window (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Cairo_Drawn_Window) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_cairo_drawn_window (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Cairo_Drawn_Window;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Double_Window (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Cairo_Drawn_Window) is
    begin
        This.Draw_Ptr   := fl_cairo_drawn_window_draw'Address;
        This.Handle_Ptr := fl_cairo_drawn_window_handle'Address;
    end Initialize;


    procedure Check_Supported is
    begin
        if not Is_Supported then
            raise Unsupported_Error with "this FLTK has neither X11 nor Wayland";
        end if;
    end Check_Supported;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Cairo_Drawn_Window is
        begin
            Check_Supported;
            return This : Cairo_Drawn_Window do
                This.Void_Ptr := new_fl_cairo_drawn_window
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Cairo_Drawn_Window is
        begin
            return This : Cairo_Drawn_Window := Create (X, Y, W, H, Text) do
                Parent.Add (This);
                --  FLTK leaves a window made with a position visible only when it
                --  has a parent from the start, which here it only gets afterwards
                This.Set_Visible;
            end return;
        end Create;


        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Cairo_Drawn_Window is
        begin
            Check_Supported;
            return This : Cairo_Drawn_Window do
                This.Void_Ptr := new_fl_cairo_drawn_window2
                   (Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, This.Get_X, This.Get_Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Cairo_Drawn_Window is
        begin
            return This : Cairo_Drawn_Window := Create (W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Is_Supported
        return Boolean is
    begin
        return fl_cairo_drawn_window_supported /= 0;
    end Is_Supported;




    --  Drawing  --

    procedure Draw
           (This : in out Cairo_Drawn_Window) is
    begin
        Double_Window (This).Draw;
    end Draw;


end FLTK.Widgets.Groups.Windows.Double.Cairo_Drawn;

