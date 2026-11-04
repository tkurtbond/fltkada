


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 4, pofltk 84: Fl_Tiled_Image keeps its tile's pointer,
--  and Color_Average and Desaturate first change it for a copy they own
--  (Fl_Tiled_Image.cxx, color_average and desaturate).  A shared image's
--  copy is the pool's own entry (Fl_Shared_Image.cxx:374-379), so the
--  pool's image was changed, for every user, and then deleted with the
--  tiled image, while still in the pool.  And a tiled image's copy tiles
--  the same image (Fl_Tiled_Image.cxx, copy), which an original that had
--  changed its colours deletes as it goes.  The binding's Tile also
--  returned the tile from before the colours changed.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Images.RGB,
    FLTK.Images.Shared,
    FLTK.Images.Tiled,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Tiled_Tile is

    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package Shr renames FLTK.Images.Shared;
    package Til renames FLTK.Images.Tiled;
    package Bxs renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    type Tiled_Access is access Til.Tiled_Image'Class;
    procedure Free is new Ada.Unchecked_Deallocation (Til.Tiled_Image'Class, Tiled_Access);

    function Reds
        return Color_Component_Array
    is
        Data : Color_Component_Array (1 .. 4 * 4 * 3) := (others => 0);
    begin
        for N in 0 .. 15 loop
            Data (Data'First + Size_Type (3 * N)) := 255;
        end loop;
        return Data;
    end Reds;

    Red : constant Prb.RGB := Prb.To_RGB (255, 0, 0);

    Window : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_Tiled_Tile");
    Shows  : Bxs.Box := Bxs.Forge.Create (Window, 0, 0, 40, 40);
    Tiles  : Bxs.Box := Bxs.Forge.Create (Window, 50, 0, 40, 40);

    --  The pixel at the middle of a box, as drawn now.
    function Middle
           (Item : in Bxs.Box)
        return Prb.RGB
    is
        Result : Prb.RGB := -1;
    begin
        if Prb.Capture (Item) then
            Result := Prb.Pixel (20, 20);
        end if;
        Prb.Release;
        return Result;
    end Middle;

    Pixels : RGB.RGB_Image := RGB.Forge.Create (Reds, 4, 4);
    Pooled : Shr.Shared_Image := Shr.Forge.Create (Pixels);

    Images : Natural;

begin

    Shows.Set_Image (Pooled);
    Check (Middle (Shows) = Red, "a shared image shows red");
    Images := Shr.Number_Of_Images;

    --  pofltk 84: a shared image as a tile.
    declare
        Tiled : Til.Tiled_Image := Til.Forge.Create (Pooled, 12, 4);
    begin
        Tiled.Desaturate;
        Check (Middle (Shows) = Red, "desaturating a tiled image leaves its shared tile alone");
        Check (Pooled.Reference_Count = 1,
            "tiling a shared image takes no reference:" & Integer'Image (Pooled.Reference_Count));
    end;
    Check (Middle (Shows) = Red, "a tiled image that goes leaves its shared tile alone");
    Check (Shr.Number_Of_Images = Images and then Pooled.Reference_Count = 1,
        "the pool is as it was:" & Integer'Image (Shr.Number_Of_Images)
        & Integer'Image (Pooled.Reference_Count));

    --  Tile is the tile the tiled image has now: the first Color_Average
    --  changes it for a copy.
    declare
        Tiled : Til.Tiled_Image := Til.Forge.Create (Pixels, 40, 40);
    begin
        Tiled.Color_Average (Blue_Color, 0.5);
        Tiles.Set_Image (Tiled.Tile.Data.all);
        Check (Middle (Tiles) not in -1 | Red,
            "a tiled image's tile after its colours change:" & Integer'Image (Middle (Tiles)));
        Tiles.Clear_Image;
    end;

    --  A copy of a tiled image whose colours were changed outlives it.
    declare
        Copied : Tiled_Access;
        Before : Integer;
    begin
        declare
            Tiled : Til.Tiled_Image := Til.Forge.Create (Pixels, 40, 40);
        begin
            Tiled.Color_Average (Blue_Color, 0.5);
            Copied := new Til.Tiled_Image'Class'(Tiled.Copy (40, 40));
            Tiles.Set_Image (Tiled);
            Before := Middle (Tiles);
            Tiles.Clear_Image;
        end;
        Tiles.Set_Image (Copied.all);
        Check (Before not in -1 | Red and then Middle (Tiles) = Before,
            "a tiled image's copy shows its changed colours:" & Integer'Image (Before)
            & Integer'Image (Middle (Tiles)));
        Tiles.Clear_Image;
        Free (Copied);
    end;

    Shows.Clear_Image;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Tiled_Tile;


