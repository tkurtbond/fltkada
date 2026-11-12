--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Draw;


package body Resize_Arrows is


    package Drw renames FLTK.Draw;


    procedure Draw
           (This : in out Harrow)
    is
        Old    : constant FLTK.Color := Drw.Get_Color;
        DX     : constant := 5;
        DY     : constant := 4;
        X      : constant Integer := This.Get_X;
        Y      : constant Integer := This.Get_Y;
        W      : constant Integer := This.Get_W;
        Middle : constant Integer := Y + This.Get_H / 2;
    begin
        Drw.Rect_Fill (X, Y, W, This.Get_H, FLTK.White_Color);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Polygon (X, Middle, X + DX, Middle - DY, X + DX, Middle + DY);
        Drw.Line (X + DX, Middle, X + W - DX, Middle);
        Drw.Polygon (X + W, Middle, X + W - DX, Middle + DY, X + W - DX, Middle - DY);
        Drw.Set_Color (Old);
    end Draw;


    procedure Draw
           (This : in out Varrow)
    is
        Old    : constant FLTK.Color := Drw.Get_Color;
        DX     : constant := 4;
        DY     : constant := 5;
        X      : constant Integer := This.Get_X;
        Y      : constant Integer := This.Get_Y;
        H      : constant Integer := This.Get_H;
        Middle : constant Integer := X + This.Get_W / 2;
    begin
        Drw.Rect_Fill (X, Y, This.Get_W, H, FLTK.White_Color);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Polygon (Middle - DX, Y + DY, Middle, Y, Middle + DX, Y + DY);
        Drw.Line (Middle, Y + DY, Middle, Y + H - DY);
        Drw.Polygon (Middle - DX, Y + H - DY, Middle + DX, Y + H - DY, Middle, Y + H);
        Drw.Set_Color (Old);
    end Draw;


    package body Forge is

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Harrow is
        begin
            return This : Harrow :=
                (FLTK.Widgets.Boxes.Forge.Create (Parent, X, Y, W, H, Text) with null record)
            do
                This.Set_Alignment (FLTK.Align_Bottom);
                This.Set_Box (FLTK.No_Box);
                This.Set_Background_Color (FLTK.White_Color);
            end return;
        end Create;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Varrow is
        begin
            return This : Varrow :=
                (FLTK.Widgets.Boxes.Forge.Create (Parent, X, Y, W, H, Text) with null record)
            do
                This.Set_Alignment (FLTK.Align_Right);
                This.Set_Box (FLTK.No_Box);
                This.Set_Background_Color (FLTK.White_Color);
            end return;
        end Create;

    end Forge;


end Resize_Arrows;

