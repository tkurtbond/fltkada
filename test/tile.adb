--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/tile.cxx, its new Fl_Tile test: a tile of boxes and a
--  child window.  Drag the borders between them to resize them, each no
--  smaller than 30 by 30.  Box 0 is the tile's resizable, so it takes up
--  what the window grows.  Guided by pofltk's Tile.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Tiled,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment;


function Tile
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Til renames FLTK.Widgets.Groups.Tiled;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;

begin

    FLTK.Static.Parse_Args;

    declare

        Window : Dbl.Double_Window := Dbl.Forge.Create (300, 300);
        Tiles  : Til.Tiled_Group := Til.Forge.Create (Window, 0, 0, 300, 300);

    begin

        --  all children's size shall be at least 30x30, set before they
        --  are made
        Tiles.Init_Size_Range (30, 30);

        declare

            Box0 : Bx.Box := Bx.Forge.Create (Tiles, 0, 0, 150, 150, "0");

            W1   : Dbl.Double_Window := Dbl.Forge.Create (Tiles, 150, 0, 150, 150, "1");
            Box1 : Bx.Box := Bx.Forge.Create
                (W1, 0, 0, 150, 150, "1" & ASCII.LF & "This is a child window");

            Box2a : Bx.Box := Bx.Forge.Create (Tiles, 0, 150, 70, 150, "2a");
            Box2b : Bx.Box := Bx.Forge.Create (Tiles, 70, 150, 80, 150, "2b");
            Box3a : Bx.Box := Bx.Forge.Create (Tiles, 150, 150, 150, 70, "3a");
            Box3b : Bx.Box := Bx.Forge.Create (Tiles, 150, 150 + 70, 150, 80, "3b");


            procedure Set_Up
                   (Item : in out Bx.Box;
                    Hue  : in     FLTK.Color) is
            begin
                Item.Set_Box (FLTK.Down_Box);
                Item.Set_Background_Color (Hue);
                Item.Set_Label_Size (36);
                Item.Set_Alignment (FLTK.Align_Clip);
            end Set_Up;

        begin

            Window.Set_Box (FLTK.No_Box);
            Window.Set_Resizable (Window);

            Set_Up (Box0, 9);
            Tiles.Set_Resizable (Box0);

            W1.Set_Box (FLTK.No_Box);
            Box1.Set_Box (FLTK.Down_Box);
            Box1.Set_Background_Color (19);
            Box1.Set_Label_Size (18);
            Box1.Set_Alignment (FLTK.Align_Clip + FLTK.Align_Inside + FLTK.Align_Wrap);
            W1.Set_Resizable (Box1);
            W1.End_Current;

            Set_Up (Box2a, 12);
            Set_Up (Box2b, 13);
            Set_Up (Box3a, 12);
            Set_Up (Box3b, 13);

            Tiles.End_Current;
            Window.End_Current;

            W1.Show;
            Window.Set_Size_Range (90, 90);
            Window.Show_With_Args;

            return FLTK.Run;

        end;

    end;

end Tile;
