

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Static;


package body FLTK.Rects is


    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (W, H : in Integer)
            return Rect is
        begin
            return (X => 0, Y => 0, W => W, H => H);
        end Create;


        function Create
               (X, Y, W, H : in Integer)
            return Rect is
        begin
            return (X => X, Y => Y, W => W, H => H);
        end Create;


        function Create
               (X, Y, W, H : in Integer;
                Box        : in Box_Kind)
            return Rect
        is
            Result : Rect := (X => X, Y => Y, W => W, H => H);
        begin
            Inset (Result, Box);
            return Result;
        end Create;


        function Create
               (Item : in FLTK.Widgets.Widget'Class)
            return Rect is
        begin
            return (X => Item.Get_X, Y => Item.Get_Y, W => Item.Get_W, H => Item.Get_H);
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_Right
           (This : in Rect)
        return Integer is
    begin
        return This.X + This.W;
    end Get_Right;


    function Get_Bottom
           (This : in Rect)
        return Integer is
    begin
        return This.Y + This.H;
    end Get_Bottom;


    procedure Set_Right
           (This  : in out Rect;
            Right : in     Integer) is
    begin
        This.W := Right - This.X;
    end Set_Right;


    procedure Set_Bottom
           (This   : in out Rect;
            Bottom : in     Integer) is
    begin
        This.H := Bottom - This.Y;
    end Set_Bottom;


    procedure Inset
           (This : in out Rect;
            D    : in     Integer) is
    begin
        Inset (This, D, D, D, D);
    end Inset;


    procedure Inset
           (This                     : in out Rect;
            Left, Top, Right, Bottom : in     Integer) is
    begin
        This.X := This.X + Left;
        This.Y := This.Y + Top;
        This.W := This.W - (Left + Right);
        This.H := This.H - (Top + Bottom);
    end Inset;


    procedure Inset
           (This : in out Rect;
            Box  : in     Box_Kind) is
    begin
        This.X := This.X + FLTK.Static.Get_Box_X_Offset (Box);
        This.Y := This.Y + FLTK.Static.Get_Box_Y_Offset (Box);
        This.W := This.W - FLTK.Static.Get_Box_Width_Offset (Box);
        This.H := This.H - FLTK.Static.Get_Box_Height_Offset (Box);
    end Inset;


end FLTK.Rects;


