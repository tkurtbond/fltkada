--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 101:  each kind of image declared Copy returning its
--  own class, which didn't override Image's Copy, so Copy called on an
--  Image'Class ran Fl_Image::copy and gave an empty Fl_Image.  Copy
--  through Image'Class, sized and not, gives an image of the same kind.


with

    Ada.Exceptions,
    Ada.Tags,
    Checks,
    FLTK.Images.Bitmaps.XBM,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Images.Pixmaps.XPM,
    FLTK.Images.RGB.PNG,
    FLTK.Images.RGB.SVG,
    FLTK.Images.Shared,
    FLTK.Images.Tiled;

use

    Checks;


procedure Test_Image_Copy_Dispatch is

    package Img renames FLTK.Images;

    --  Pic, copied as an Image'Class, sized and not, is still Kind, and has
    --  the size asked for.  A tiled image has no data of its own
    --  (Fl_Tiled_Image.cxx:58), so it is always empty.
    procedure Copies
           (Pic   : in Img.Image'Class;
            Kind  : in Ada.Tags.Tag;
            Name  : in String;
            Empty : in Boolean := False) is
    begin
        Check (Pic.Is_Empty = Empty, Name & " is read");
        declare
            Sized : constant Img.Image'Class := Pic.Copy (Pic.Get_W * 2, Pic.Get_H * 3);
            Whole : constant Img.Image'Class := Pic.Copy;
        begin
            Check (Ada.Tags.Is_Descendant_At_Same_Level (Sized'Tag, Kind),
                Name & ", copied to a size, is still one: "
                & Ada.Tags.Expanded_Name (Sized'Tag));
            Check (Sized.Get_W = Pic.Get_W * 2 and Sized.Get_H = Pic.Get_H * 3
                    and Sized.Is_Empty = Empty,
                Name & ", copied to a size, has that size");
            Check (Ada.Tags.Is_Descendant_At_Same_Level (Whole'Tag, Kind),
                Name & ", copied whole, is still one: "
                & Ada.Tags.Expanded_Name (Whole'Tag));
            Check (Whole.Get_W = Pic.Get_W and Whole.Get_H = Pic.Get_H
                    and Whole.Is_Empty = Empty,
                Name & ", copied whole, has its size");
        end;
    end Copies;

begin

    Img.Shared.Register_Images;

    Copies (Img.Bitmaps.XBM.Forge.Create ("../images/rb.xbm"),
        Img.Bitmaps.Bitmap'Tag, "a bitmap");
    Copies (Img.Pixmaps.XPM.Forge.Create ("../images/rb.xpm"),
        Img.Pixmaps.Pixmap'Tag, "a pixmap");
    Copies (Img.RGB.PNG.Forge.Create ("../images/rb.png"),
        Img.RGB.RGB_Image'Tag, "an RGB image");
    Copies (Img.RGB.SVG.Forge.Create ("../images/rb.svg"),
        Img.RGB.SVG.SVG_Image'Tag, "an SVG image");
    Copies (Img.Shared.Forge.Create ("../images/rb.png", 0, 0),
        Img.Shared.Shared_Image'Tag, "a shared image");
    Copies (Img.Pixmaps.GIF.Animated.Forge.Create ("../images/anim.gif"),
        Img.Pixmaps.GIF.Animated.Animated_GIF_Image'Tag, "an animated GIF");
    declare
        Under : Img.RGB.PNG.PNG_Image := Img.RGB.PNG.Forge.Create ("../images/rb.png");
    begin
        Copies (Img.Tiled.Forge.Create (Under, 40, 30),
            Img.Tiled.Tiled_Image'Tag, "a tiled image", Empty => True);
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Image_Copy_Dispatch;
