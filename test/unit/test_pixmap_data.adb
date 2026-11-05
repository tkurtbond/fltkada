

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Phase 12's Pixmaps data access, and the checks on Pixmaps.Forge.Create
--  that keep FLTK from reading past its data (FLTKAda-BUGS.md 77).  The
--  release library makes the same checks in Draw.Draw_Pixmap, whose Pre it
--  doesn't check, and raises Draw_Error for data FLTK can't decode.


with

    Ada.Strings.Unbounded,
    Checks,
    FLTK.Draw,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Images.Pixmaps.XPM;

use

    Checks;


procedure Test_Pixmap_Data is

    package Pix renames FLTK.Images.Pixmaps;
    package GIF renames FLTK.Images.Pixmaps.GIF;
    package XPM renames FLTK.Images.Pixmaps.XPM;

    function "+"
           (Item : in String)
        return Ada.Strings.Unbounded.Unbounded_String
        renames Ada.Strings.Unbounded.To_Unbounded_String;

    Dir : constant String := "../images/";

    Colors : constant Pix.Color_Definition_Array :=
       ((+"a", Pix.Colorful, +"#ff0000"),
        (+"b", Pix.Colorful, +"#0000ff"));

    function Lines
           (Image : in Pix.Pixmap'Class)
        return String
    is
        use Ada.Strings.Unbounded;
        Result : Unbounded_String;
    begin
        for N in 1 .. Image.Get_Line_Count loop
            Append (Result, (if N = 1 then "" else "|") & Image.Get_Line (N));
        end loop;
        return To_String (Result);
    end Lines;

    procedure Made is
        Pixels : constant Pix.Pixmap_Data (1 .. 2, 1 .. 3) := ("aba", "bab");
        Image  : constant Pix.Pixmap := Pix.Forge.Create ((3, 2, 2, 1), Colors, Pixels);

        procedure Beyond is
            Line : constant String := Image.Get_Line (6);
            pragma Unreferenced (Line);
        begin
            null;
        end Beyond;
    begin
        Check (Image.Get_Line_Count = 5, "a made pixmap has 5 lines:" &
            Natural'Image (Image.Get_Line_Count));
        Check (Lines (Image) = "3 2 2 1|a c #ff0000|b c #0000ff|aba|bab",
            "and they are the XPM: " & Lines (Image));
        Raises (Beyond'Access, Constraint_Error'Identity,
            "Get_Line of a line beyond the last raises Constraint_Error");
    end Made;

    --  Before the fix, a line was taken from column 1, not Pixels'First (2),
    --  so Create raised Constraint_Error for these.
    procedure Not_From_One is
        Pixels : constant Pix.Pixmap_Data (1 .. 2, 2 .. 4) := ("aab", "bba");
        Image  : constant Pix.Pixmap := Pix.Forge.Create ((3, 2, 2, 1), Colors, Pixels);
    begin
        Check (Image.Get_Line (4) = "aab" and Image.Get_Line (5) = "bba",
            "pixel lines from data not indexed from 1 (FLTKAda-BUGS.md 77): " &
            Lines (Image));
    end Not_From_One;

    procedure Refused is
        Pixels : constant Pix.Pixmap_Data (1 .. 2, 1 .. 2) := ("ab", "ba");

        procedure Make
               (Values : in Pix.Header;
                Using  : in Pix.Color_Definition_Array)
        is
            Image : constant Pix.Pixmap := Pix.Forge.Create (Values, Using, Pixels);
            pragma Unreferenced (Image);
        begin
            null;
        end Make;

        procedure Too_Many_Colors is
        begin
            Make ((2, 2, 3, 1), Colors);
        end Too_Many_Colors;

        procedure Too_Many_Lines is
        begin
            Make ((2, 4, 2, 1), Colors);
        end Too_Many_Lines;

        procedure Too_Wide is
        begin
            Make ((3, 2, 2, 1), Colors);
        end Too_Wide;

        procedure Two_Per_Pixel is
        begin
            Make ((1, 2, 2, 2), Colors);
        end Two_Per_Pixel;

        procedure Too_Big is
        begin
            Make ((50_000, 50_000, 2, 1), Colors);
        end Too_Big;
    begin
        Raises (Too_Many_Colors'Access, Constraint_Error'Identity,
            "a header with more colors than given raises Constraint_Error");
        Raises (Too_Many_Lines'Access, Constraint_Error'Identity,
            "and one with more lines than given");
        Raises (Too_Wide'Access, Constraint_Error'Identity,
            "and one wider than the lines");
        Raises (Two_Per_Pixel'Access, Constraint_Error'Identity,
            "and one whose color names are shorter than Per_Pixel");
        Raises (Too_Big'Access, Constraint_Error'Identity,
            "and one bigger than FLTK can draw");
    end Refused;

    procedure Draw_Refused is
        Pixels : constant Pix.Pixmap_Data (1 .. 2, 1 .. 2) := ("ab", "ba");

        procedure Too_Many_Lines is
        begin
            FLTK.Draw.Draw_Pixmap ((2, 4, 2, 1), Colors, Pixels, 0, 0);
        end Too_Many_Lines;

        procedure Too_Many_Colors is
        begin
            FLTK.Draw.Draw_Pixmap ((2, 2, 3, 1), Colors, Pixels, 0, 0);
        end Too_Many_Colors;

        --  As the header says, but FLTK takes 1 or 2 characters a pixel.
        procedure Three_Per_Pixel is
            Wide : constant Pix.Pixmap_Data (1 .. 1, 1 .. 3) := (1 => "aaa");
        begin
            FLTK.Draw.Draw_Pixmap
               ((1, 1, 1, 3), (1 => (+"aaa", Pix.Colorful, +"#ff0000")), Wide, 0, 0);
        end Three_Per_Pixel;
    begin
        Raises (Too_Many_Lines'Access, Constraint_Error'Identity,
            "Draw_Pixmap with more lines in the header than given raises Constraint_Error");
        Raises (Too_Many_Colors'Access, Constraint_Error'Identity,
            "and with more colors");
        Raises (Three_Per_Pixel'Access, FLTK.Draw.Draw_Error'Identity,
            "and data FLTK can't decode raises Draw_Error");
    end Draw_Refused;

    procedure From_Files is
        File  : constant XPM.XPM_Image := XPM.Forge.Create (Dir & "rb.xpm");
        Still : constant GIF.GIF_Image := GIF.Forge.Create (Dir & "rb.gif");
        Empty : constant GIF.Animated.Animated_GIF_Image := GIF.Animated.Forge.Create;
        Count : constant Natural := Still.Get_Line_Count;

        procedure None is
            Line : constant String := Empty.Get_Line (1);
            pragma Unreferenced (Line);
        begin
            null;
        end None;
    begin
        Check (Lines (File) = "4 2 2 1 |  c #FF0000|. c #0000FF|  ..|  ..",
            "an XPM's lines are its file's: " & Lines (File));

        --  rb.gif is 4 by 2, in FLTK's compressed form.
        Check (Count = 4, "a GIF has its height and 2 lines:" & Natural'Image (Count));
        if Count = 4 then
            declare
                Header : constant String := Still.Get_Line (1);
                Map    : constant String := Still.Get_Line (2);
            begin
                Check (Header (Header'First .. Header'First + 3) = "4 2 ",
                    "its header gives its size: " & Header);
                Check (Map'Length mod 4 = 0 and Map'Length > 0,
                    "its second line is 4 bytes a color:" & Natural'Image (Map'Length));
                Check (Still.Get_Line (3)'Length = 4 and Still.Get_Line (4)'Length = 4,
                    "its pixel lines are as wide as it is");
                Check ((for some C of Map => C = ASCII.NUL),
                    "and its colors are all there, NULs and all");
                Check (Still.Get_Line (3) /= Still.Get_Line (4)
                        or else Still.Get_Line (3) (1) /= Still.Get_Line (3) (4),
                    "and they hold more than one index");
            end;
        end if;

        Check (Empty.Get_Line_Count = 0, "a pixmap with no data has no lines");
        Raises (None'Access, Constraint_Error'Identity,
            "and Get_Line of it raises Constraint_Error");
    end From_Files;

begin

    Made;
    Not_From_One;
    Refused;
    Draw_Refused;
    From_Files;

    Summary;

end Test_Pixmap_Data;
