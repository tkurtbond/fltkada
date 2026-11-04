


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK-issues.md F8, FLTKAda-BUGS.md 56: a PNG, JPEG or SVG read from
--  memory with a name is put in the shared image pool under that name, and
--  the pool's entry doesn't own it (Fl_PNG_Image.cxx:239-242,
--  Fl_JPEG_Image.cxx:341-344, Fl_SVG_Image.cxx:299-302,
--  Fl_Shared_Image.cxx:133-146).  When the image goes, the entry is left
--  pointing at it.  FLTKAda passed an empty name on, so every PNG and JPEG
--  read from memory was put in the pool.  And FLTKAda-BUGS.md 57: a
--  Shared_Image made from an RGB_Image shared that image, unowned
--  (Fl_Shared_Image.cxx:629-635), so it had the same fault.  Valgrind
--  checks the reads and writes of an entry whose image has gone.


with

    Ada.Direct_IO,
    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Images.RGB.JPEG,
    FLTK.Images.RGB.PNG,
    FLTK.Images.RGB.SVG,
    FLTK.Images.Shared;

use

    Checks,
    FLTK;


procedure Test_Image_Names is

    package JPEG renames FLTK.Images.RGB.JPEG;
    package PNG  renames FLTK.Images.RGB.PNG;
    package Shr  renames FLTK.Images.Shared;
    package SVG  renames FLTK.Images.RGB.SVG;

    package Byte_IO is new Ada.Direct_IO (Color_Component);

    function Contents
           (Name : in String)
        return Color_Component_Array
    is
        File : Byte_IO.File_Type;
    begin
        Byte_IO.Open (File, Byte_IO.In_File, "../images/" & Name);
        declare
            Data : Color_Component_Array (1 .. Positive_Size (Byte_IO.Size (File)));
        begin
            for Byte of Data loop
                Byte_IO.Read (File, Byte);
            end loop;
            Byte_IO.Close (File);
            return Data;
        end;
    end Contents;

    Square : constant String :=
        "<svg xmlns=""http://www.w3.org/2000/svg"" width=""6"" height=""3"">"
        & "<rect width=""6"" height=""3"" fill=""red""/></svg>";

    Name : String (1 .. 9);

    procedure Find_Name is
        Found : Shr.Shared_Image := Shr.Forge.Find (Name);
    begin
        Found.Desaturate;
        Check (False, Name & " found, " & Integer'Image (Found.Get_W) & " wide");
    end Find_Name;

    Before : Natural;

begin

    Before := Shr.Number_Of_Images;

    --  No name: the pool is left alone.
    declare
        P : constant PNG.PNG_Image := PNG.Forge.Create (Data => Contents ("rb.png"));
        J : constant JPEG.JPEG_Image := JPEG.Forge.Create (Data => Contents ("plasma.jpg"));
        S : constant SVG.SVG_Image := SVG.Forge.Create (Data => Square);
    begin
        Check (P.Get_W = 4 and then J.Get_W = 64 and then S.Get_W = 6, "images from memory load");
        Check (Shr.Number_Of_Images = Before, "with no name, they aren't shared:"
            & Integer'Image (Shr.Number_Of_Images - Before));
    end;

    --  A name: shared while the image lasts, and not after.
    declare
        P : constant PNG.PNG_Image := PNG.Forge.Create ("named.png", Contents ("rb.png"));
        J : constant JPEG.JPEG_Image := JPEG.Forge.Create ("named.jpg", Contents ("plasma.jpg"));
        S : constant SVG.SVG_Image := SVG.Forge.Create ("named.svg", Square);
    begin
        Check (Shr.Number_Of_Images = Before + 3, "with a name, they are shared");
        declare
            Found : Shr.Shared_Image := Shr.Forge.Find ("named.png");
        begin
            Found.Desaturate;
            Check (Found.Get_W = P.Get_W, "a named image is found");
        end;
        Check (J.Get_W = 64 and then S.Get_W = 6, "and the others load");
    end;
    Name := "named.png";
    Raises (Find_Name'Access, Images.No_Image_Error'Identity, "a named PNG that is gone");
    Name := "named.jpg";
    Raises (Find_Name'Access, Images.No_Image_Error'Identity, "a named JPEG that is gone");
    Name := "named.svg";
    Raises (Find_Name'Access, Images.No_Image_Error'Identity, "a named SVG that is gone");
    Check (Shr.Number_Of_Images = Before, "the pool is as it was:"
        & Integer'Image (Shr.Number_Of_Images - Before));

    --  A shared image found while the image lasted keeps it.
    declare
        type Shared_Access is access Shr.Shared_Image;
        procedure Free is new Ada.Unchecked_Deallocation (Shr.Shared_Image, Shared_Access);
        Kept : Shared_Access;
    begin
        declare
            P : constant PNG.PNG_Image := PNG.Forge.Create ("named.png", Contents ("rb.png"));
        begin
            Kept := new Shr.Shared_Image'(Shr.Forge.Find ("named.png"));
            Check (P.Get_W = 4, "a named image is found again");
        end;
        Kept.Desaturate;
        Check (Kept.Get_W = 4, "a shared image found keeps it:" & Integer'Image (Kept.Get_W));
        Free (Kept);
        Check (Shr.Number_Of_Images = Before, "and the pool is as it was after it");
    end;

    --  A shared image made from an image that goes first.
    declare
        type Shared_Access is access Shr.Shared_Image;
        procedure Free is new Ada.Unchecked_Deallocation (Shr.Shared_Image, Shared_Access);
        Kept : Shared_Access;
    begin
        declare
            P : constant PNG.PNG_Image := PNG.Forge.Create (Data => Contents ("rb.png"));
        begin
            Kept := new Shr.Shared_Image'(Shr.Forge.Create (P));
        end;
        Kept.Desaturate;
        Check (Kept.Get_W = 4, "a shared image outlives the image it was made from:"
            & Integer'Image (Kept.Get_W));
        Free (Kept);
        Check (Shr.Number_Of_Images = Before, "and goes from the pool");
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Image_Names;


