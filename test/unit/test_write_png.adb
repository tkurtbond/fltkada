--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Write_PNG (fl_write_png) and the data size of an image, Get_Data_W and
--  Get_Data_H.  FLTK sets libpng no error handler, so writing an image
--  with no pixels aborts the program (FLTK-issues.md F17); Write_PNG
--  raises No_Image_Error instead.  RGB_Image Create took a depth outside
--  1 .. 4, and a line size shorter than a row, and FLTK then read past the
--  pixels (FLTKAda-BUGS.md 71).


with

    Ada.Directories,
    Checks,
    FLTK.Images.RGB.PNG;

use

    Checks,
    FLTK;


procedure Test_Write_PNG is

    package RGB renames FLTK.Images.RGB;
    package PNG renames FLTK.Images.RGB.PNG;

    Name : constant String := "test_write_png.tmp.png";

    --  Three by two, depth three, each row padded to twelve bytes.
    Padded : constant Color_Component_Array :=
        (10, 20, 30,  40, 50, 60,  70, 80, 90,  0, 0, 0,
         11, 21, 31,  41, 51, 61,  71, 81, 91,  0, 0, 0);
    Rows : constant Color_Component_Array :=
        (10, 20, 30,  40, 50, 60,  70, 80, 90,
         11, 21, 31,  41, 51, 61,  71, 81, 91);

    Ignore : Natural;

    procedure Never_Created is
        Blank : RGB.RGB_Image;
    begin
        PNG.Write_PNG (Blank, Name);
    end Never_Created;

    procedure No_Pixels is
        Empty : constant RGB.RGB_Image := RGB.Forge.Create ((1 .. 0 => 0), 0, 4);
    begin
        PNG.Write_PNG (Empty, Name);
    end No_Pixels;

    procedure No_Directory is
        Image : constant RGB.RGB_Image := RGB.Forge.Create (Rows, 3, 2);
    begin
        PNG.Write_PNG (Image, "/nonexistent/test_write_png.png");
    end No_Directory;

    procedure Depth_Zero is
        Image : constant RGB.RGB_Image := RGB.Forge.Create ((1 => 0), 4, 4, Depth => 0);
    begin
        Ignore := Image.Get_W;
    end Depth_Zero;

    procedure Depth_Five is
        Image : constant RGB.RGB_Image :=
            RGB.Forge.Create ((1 .. 80 => 0), 4, 4, Depth => 5);
    begin
        Ignore := Image.Get_W;
    end Depth_Five;

    procedure Tight_Lines is
        Image : constant RGB.RGB_Image :=
            RGB.Forge.Create ((1 .. 8 => 0), 4, 4, Depth => 3, Line_Size => 2);
    begin
        Ignore := Image.Get_W;
    end Tight_Lines;

begin

    --  Written and read back: the padding goes, the pixels stay.
    declare
        Image : RGB.RGB_Image := RGB.Forge.Create (Padded, 3, 2, 3, 12);
    begin
        Check (Image.Get_Data_W = 3 and Image.Get_Data_H = 2, "the data size is the image's size");
        Image.Scale (30, 20, Proportional => False, Can_Expand => True);
        Check (Image.Get_W = 30 and Image.Get_H = 20, "Scale changes the drawn size");
        Check (Image.Get_Data_W = 3 and Image.Get_Data_H = 2, "Scale leaves the data size");
        PNG.Write_PNG (Image, Name);
        declare
            Back : constant PNG.PNG_Image := PNG.Forge.Create (Name);
        begin
            Check (Back.Get_W = 3 and Back.Get_H = 2 and Back.Get_D = 3,
                "the PNG is written at the data size");
            Check (Back.All_Data = Rows, "the PNG has the pixels, without the padding");
        end;
        Ada.Directories.Delete_File (Name);
    end;

    --  Grey with alpha, depth two.
    declare
        Grey : constant Color_Component_Array := (0, 255, 128, 64, 255, 0, 7, 9);
        Image : constant RGB.RGB_Image := RGB.Forge.Create (Grey, 2, 2, 2);
    begin
        PNG.Write_PNG (Image, Name);
        declare
            Back : constant PNG.PNG_Image := PNG.Forge.Create (Name);
        begin
            Check (Back.Get_D = 2 and Back.All_Data = Grey, "a grey and alpha PNG reads back");
        end;
        Ada.Directories.Delete_File (Name);
    end;

    Raises (Never_Created'Access, Images.No_Image_Error'Identity,
        "writing an image never created");
    Raises (No_Pixels'Access, Images.No_Image_Error'Identity,
        "writing an image with no pixels, which aborted (F17)");
    Check (not Ada.Directories.Exists (Name), "nothing is written for an image with no pixels");
    Raises (No_Directory'Access, Images.File_Access_Error'Identity,
        "writing into a directory that isn't there");

    Raises (Depth_Zero'Access, Constraint_Error'Identity, "an RGB image of depth 0 (71)");
    Raises (Depth_Five'Access, Constraint_Error'Identity, "an RGB image of depth 5 (71)");
    Raises (Tight_Lines'Access, Constraint_Error'Identity,
        "an RGB image with lines shorter than a row (71)");

    Summary;

end Test_Write_PNG;
