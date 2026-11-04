

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 6, pofltk 83: the shared image pool is sorted by name
--  and data size (Fl_Shared_Image.cxx:95-105), and searched by them
--  (:498-520).  Fl_Shared_Image::reload (:277-321) puts the file's image,
--  at the file's size, in an entry scaled from it, and leaves the pool as
--  it was, so a search for the entry's size could miss it.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.Shared,
    FLTK.Probe,
    FLTK.Widgets.Boxes;

use

    Checks,
    FLTK;


procedure Test_Shared_Reload is

    package Shr renames FLTK.Images.Shared;
    package Prb renames FLTK.Probe;
    package Bxs renames FLTK.Widgets.Boxes;

    type Corners is array (1 .. 2) of Prb.RGB;

    --  The top left and bottom right pixels of a box showing Pic.
    function Drawn
           (Pic : in out Shr.Shared_Image)
        return Corners
    is
        Item   : Bxs.Box := Bxs.Forge.Create (No_Box, 0, 0, Pic.Get_W, Pic.Get_H);
        Result : Corners := (others => 0);
    begin
        Item.Set_Image (Pic);
        if Prb.Capture (Item) then
            Result := (Prb.Pixel (0, 0), Prb.Pixel (Pic.Get_W - 1, Pic.Get_H - 1));
            Prb.Release;
        else
            Check (False, "a box is captured");
        end if;
        return Result;
    end Drawn;

    File : constant String := "../images/rb.png";

    procedure Finds
           (W, H    : in Integer;
            Message : in String) is
    begin
        declare
            Found : constant Shr.Shared_Image := Shr.Forge.Find (File, W, H);
        begin
            Check (not Found.Original and Found.Get_W = W and Found.Get_H = H, Message);
        end;
    exception
    when FLTK.Images.No_Image_Error =>
        Check (False, Message & ": not found");
    end Finds;

begin

    Shr.Register_Images;

    declare
        Small : Shr.Shared_Image := Shr.Forge.Create (File, 8, 4);
        Large : Shr.Shared_Image := Shr.Forge.Create (File, 20, 10);
    begin
        Finds (8, 4, "the 8 by 4 entry is found");
        Finds (20, 10, "the 20 by 10 entry is found");

        declare
            Before : constant Corners := Drawn (Large);
        begin
            Check (Before (1) /= Before (2), "the corners differ");
            Large.Reload;
            Check (Drawn (Large) = Before, "a reloaded entry draws as it did");
        end;
        Check (Large.Get_W = 20 and Large.Get_H = 10, "a reloaded entry keeps its size");
        Finds (20, 10, "the reloaded 20 by 10 entry is found");
        Finds (8, 4, "the 8 by 4 entry is found after the reload");

        Small.Reload;
        Finds (8, 4, "the reloaded 8 by 4 entry is found");
        Finds (20, 10, "the 20 by 10 entry is found after both reloads");
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Shared_Reload;
