--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  pofltk 73: an FLTK may be built without SVG, and then its library has no
--  Fl_SVG_Image although the header may be there.  The shim names the class
--  only #ifdef FLTK_USE_SVG, as FLTK's own sources test it
--  (Fl_SVG_Image.cxx:19, fl_images_core.cxx:127).  Without it,
--  SVG.Is_Supported is False and each Create raises Unsupported_Error.
--  This FLTK has SVG, so a run here checks the first case; the other was
--  checked by putting in front of the shim's fl_svg_image_available one that
--  gives 0 (LD_PRELOAD), which the Has_SVG check below then fails.


with

    Checks,
    FLTK.Images.RGB.SVG,
    FLTK.Probe;

use

    Checks,
    FLTK;


procedure Test_SVG_Support is

    package SVG renames FLTK.Images.RGB.SVG;
    package Prb renames FLTK.Probe;

    Text : constant String :=
        "<svg xmlns=""http://www.w3.org/2000/svg"" width=""8"" height=""4"">"
        & "<rect width=""8"" height=""4"" fill=""red""/></svg>";

    procedure From_Text is
        Image : constant SVG.SVG_Image := SVG.Forge.Create (Data => Text);
    begin
        if Image.Get_W /= 8 or else Image.Get_H /= 4 then
            raise Program_Error with "the image is the wrong size";
        end if;
    end From_Text;

    procedure From_File is
        Image : constant SVG.SVG_Image := SVG.Forge.Create ("../images/no-such.svg");
        pragma Unreferenced (Image);
    begin
        null;
    end From_File;

    procedure From_Bytes is
        Bytes : constant Color_Component_Array (1 .. 3) := (60, 115, 118);
        Image : constant SVG.SVG_Image := SVG.Forge.Create (Data => Bytes);
        pragma Unreferenced (Image);
    begin
        null;
    end From_Bytes;

begin

    Check (SVG.Is_Supported = Prb.Has_SVG,
        "Is_Supported says what this FLTK was built with: "
        & Boolean'Image (SVG.Is_Supported));

    if SVG.Is_Supported then
        No_Raise (From_Text'Access, "an SVG image is made from text, 8 by 4");
    else
        Raises (From_Text'Access, Unsupported_Error'Identity,
            "Create from text raises Unsupported_Error");
        Raises (From_File'Access, Unsupported_Error'Identity,
            "Create from a file raises Unsupported_Error");
        Raises (From_Bytes'Access, Unsupported_Error'Identity,
            "Create from bytes raises Unsupported_Error");
    end if;

    Summary;

end Test_SVG_Support;
