--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/line_style_docs.cxx, which makes the screenshot for
--  fl_line_style's documentation: a grid of boxes, each drawing thin and
--  thick lines in one line style, cap or join, the thick lines' width
--  depending on the box's size.  FLTK's style is one int; here a box
--  has a line kind, a cap and a join, and a name.  Guided by pofltk's
--  LineStyleDocs.Mod.


with

    Ada.Strings.Unbounded,
    FLTK.Draw,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows.Double;


function Line_Style_Docs
    return Integer
is

    package SU  renames Ada.Strings.Unbounded;
    package FDR renames FLTK.Draw;
    package Bx  renames FLTK.Widgets.Boxes;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

    Sep   : constant := 22;          --  separation between items
    Width : array (0 .. 1) of Natural := (1, 4);  --  line widths (thin + thick/dyn.)

    Text_Width : Natural := 0;       --  the widest name's


    --  A box with one line style inside an Fl_Grid; an empty box draws
    --  no lines.
    type Style_Box is new Bx.Box with record
        Empty : Boolean := False;
        Line  : FDR.Line_Kind := FDR.Solid_Line;
        Cap   : FDR.Cap_Kind := FDR.Default_Cap;
        Join  : FDR.Join_Kind := FDR.Default_Join;
        Name  : SU.Unbounded_String;
    end record;

    overriding procedure Draw
           (This : in out Style_Box);


    procedure Draw
           (This : in out Style_Box)
    is
        X, Y, DX, DY : Integer;
        Dummy        : Natural;
    begin
        This.Draw_Box;
        if This.Empty then  --  draw an empty box
            return;
        end if;

        --  set font and measure widest text
        FDR.Set_Font (FLTK.Helvetica, 12);
        FDR.Set_Color (FLTK.Black_Color);
        if Text_Width = 0 then
            FDR.Measure ("FL_DASHDOTDOT", Text_Width, Dummy);
        end if;

        --  draw the text
        X := This.Get_X + Sep / 2;
        FDR.Draw_Text
           (X, This.Get_Y + This.Get_H / 2 + FDR.Font_Line_Spacing / 2 - 2,
            SU.To_String (This.Name));

        --  calculate dynamic line sizes and widths
        X := X + Text_Width + Sep / 2;
        DX := (This.Get_W - Text_Width - 5 * Sep) / 4;  --  horizontal distance
        DY := This.Get_H - Sep;
        Y := This.Get_Y + Sep / 2;
        if DX >= 80 or DY >= 80 then
            Width (1) := 9;
        elsif DX >= 60 or DY >= 60 then
            Width (1) := 8;
        elsif DX >= 40 or DY >= 40 then
            Width (1) := 7;
        else
            Width (1) := 5;
        end if;

        --  draw the lines
        for I in 0 .. 1 loop  --  thin + thick lines
            FDR.Set_Line_Style (This.Line, This.Cap, This.Join, Width (I));
            --  ___
            --     |
            --     |
            FDR.Line (X, Y, X + DX, Y, X + DX, Y + DY);
            X := X + DX + Sep;
            --  ___
            --    /
            --   /
            FDR.Line (X, Y, X + DX, Y, X, Y + DY);
            X := X + DX + Sep;
        end loop;

        --  restore line settings to default
        FDR.Set_Line_Style (FDR.Solid_Line, Width => 0);
    end Draw;


    Win  : Dbl.Double_Window := Dbl.Forge.Create (740, 400, "fl_line_style()");

    --  a grid with a nice white 4px border and a light gray background
    --  (color) so margins and gaps show thru
    Grid : Grd.Grid := Grd.Forge.Create (Win, 4, 4, Win.Get_W - 8, Win.Get_H - 8);


    --  FLTK's StyleBox constructor.
    function Make
           (Name  : in String;
            Line  : in FDR.Line_Kind := FDR.Solid_Line;
            Cap   : in FDR.Cap_Kind := FDR.Default_Cap;
            Join  : in FDR.Join_Kind := FDR.Default_Join;
            Empty : in Boolean := False)
        return Style_Box is
    begin
        return This : Style_Box :=
           (Bx.Forge.Create (Grid, 0, 0, 0, 0) with
            Empty => Empty, Line => Line, Cap => Cap, Join => Join,
            Name => SU.To_Unbounded_String (Name))
        do
            This.Set_Box (FLTK.Flat_Box);
            This.Set_Background_Color (FLTK.White_Color);
        end return;
    end Make;


    Boxes : constant array (1 .. 2, 1 .. 6) of Style_Box :=
       --  first column
       ((Make ("FL_SOLID", Line => FDR.Solid_Line),
         Make ("FL_DASH", Line => FDR.Dash_Line),
         Make ("FL_DOT", Line => FDR.Dot_Line),
         Make ("FL_DASHDOT", Line => FDR.Dashdot_Line),
         Make ("FL_DASHDOTDOT", Line => FDR.Dashdotdot_Line),
         Make ("", Empty => True)),
        --  second column
        (Make ("FL_CAP_FLAT", Cap => FDR.Flat_Cap),
         Make ("FL_CAP_ROUND", Cap => FDR.Round_Cap),
         Make ("FL_CAP_SQUARE", Cap => FDR.Square_Cap),
         Make ("FL_JOIN_MITER", Join => FDR.Miter_Join),
         Make ("FL_JOIN_ROUND", Join => FDR.Round_Join),
         Make ("FL_JOIN_BEVEL", Join => FDR.Bevel_Join)));

begin

    Win.Set_Background_Color (FLTK.White_Color);

    Grid.Set_Box (FLTK.Flat_Box);
    Grid.Set_Background_Color (FLTK.RGB_Color (16#D0#, 16#D0#, 16#D0#));
    Grid.Set_Layout (6, 2, 4, 4);  --  6 rows, 2 columns, ...

    for Column in Boxes'Range (1) loop
        for Row in Boxes'Range (2) loop
            Grid.Set_Widget (Boxes (Column, Row), Row, Column, Grd.Grid_Fill);
        end loop;
    end loop;

    Grid.End_Current;
    Win.End_Current;
    Win.Set_Resizable (Win);
    Win.Set_Size_Range (660, 340);  --  don't allow to shrink too much
    Win.Show_With_Args;

    return FLTK.Run;

end Line_Style_Docs;
