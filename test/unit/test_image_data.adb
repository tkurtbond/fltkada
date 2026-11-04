


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTKAda-BUGS.md 48: Fl_RGB_Image and Fl_Bitmap keep the pointer to the
--  pixels they are made from, and don't copy them (Fl_Image.cxx:374-384,
--  Fl_Bitmap.H:48-49).  RGB_Image and Bitmap Create gave FLTK the address
--  of the caller's array, so an image outliving it read freed memory, and
--  Set_Datum wrote into the caller's constant.  Data too short for the
--  size was refused only by a precondition, which release builds don't
--  check.  pofltk copies the pixels (ofl_image_rgb, new_bitmap).


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Images.Bitmaps,
    FLTK.Images.RGB;

use

    Checks,
    FLTK;


procedure Test_Image_Data is

    package Bmp renames FLTK.Images.Bitmaps;
    package RGB renames FLTK.Images.RGB;

    type Data_Access is access Color_Component_Array;

    procedure Free is new Ada.Unchecked_Deallocation (Color_Component_Array, Data_Access);

    function Counting
           (Length : in Size_Type)
        return Color_Component_Array
    is
        Result : Color_Component_Array (1 .. Length);
    begin
        for N in Result'Range loop
            Result (N) := Color_Component (N);
        end loop;
        return Result;
    end Counting;

    --  Fills freed memory the size of Length with zeros.
    procedure Scribble
           (Length : in Size_Type)
    is
        Junk : array (1 .. 8) of Data_Access;
    begin
        for J of Junk loop
            J := new Color_Component_Array'(1 .. Length => 0);
        end loop;
        for J of Junk loop
            Free (J);
        end loop;
    end Scribble;

    function Same
           (Image  : in RGB.RGB_Image;
            Values : in Color_Component_Array)
        return Boolean is
    begin
        for N in Values'Range loop
            if Image.Get_Datum (N - Values'First + 1) /= Values (N) then
                return False;
            end if;
        end loop;
        return True;
    end Same;

    function Same
           (Image  : in Bmp.Bitmap;
            Values : in Color_Component_Array)
        return Boolean is
    begin
        for N in Values'Range loop
            if Image.Get_Datum (N - Values'First + 1) /= Values (N) then
                return False;
            end if;
        end loop;
        return True;
    end Same;

    Twelve : constant Color_Component_Array := Counting (12);
    Kept   : constant Color_Component_Array := Counting (12);
    Ignore : Natural;

    procedure Short_RGB is
        Image : constant RGB.RGB_Image := RGB.Forge.Create (Counting (11), 2, 2);
    begin
        Ignore := Image.Get_W;
    end Short_RGB;

    procedure Short_Line_RGB is
        Image : constant RGB.RGB_Image := RGB.Forge.Create (Counting (12), 2, 2, 3, 8);
    begin
        Ignore := Image.Get_W;
    end Short_Line_RGB;

    procedure Short_Bitmap is
        Image : constant Bmp.Bitmap := Bmp.Forge.Create (Counting (3), 9, 2);
    begin
        Ignore := Image.Get_W;
    end Short_Bitmap;

begin

    --  The pixels freed after the image is made.
    declare
        Pixels : Data_Access := new Color_Component_Array'(Twelve);
        Image  : constant RGB.RGB_Image := RGB.Forge.Create (Pixels.all, 2, 2);
    begin
        Free (Pixels);
        Scribble (12);
        Check (Same (Image, Twelve), "an RGB image keeps its pixels after the array goes");
    end;

    declare
        Pixels : Data_Access := new Color_Component_Array'(Twelve);
        Image  : constant Bmp.Bitmap := Bmp.Forge.Create (Pixels.all, 16, 6);
    begin
        Free (Pixels);
        Scribble (12);
        Check (Same (Image, Twelve), "a bitmap keeps its bits after the array goes");
    end;

    --  The pixels a temporary.
    declare
        Image : constant RGB.RGB_Image := RGB.Forge.Create (Counting (12), 2, 2);
    begin
        Scribble (12);
        Check (Same (Image, Twelve), "an RGB image made from a temporary");
    end;

    --  Setting a pixel changes the image, not the caller's array.
    declare
        Image : RGB.RGB_Image := RGB.Forge.Create (Kept, 2, 2);
        Bits  : Bmp.Bitmap := Bmp.Forge.Create (Kept, 16, 6);
    begin
        Image.Set_Datum (1, 99);
        Bits.Set_Datum (2, 98);
        Check (Image.Get_Datum (1) = 99 and then Bits.Get_Datum (2) = 98, "a pixel set");
        Check (Kept = Twelve, "setting a pixel leaves the caller's array alone");
    end;

    --  Too little data for the size.
    Raises (Short_RGB'Access, Constraint_Error'Identity, "an RGB image short of data raises");
    Raises (Short_Line_RGB'Access, Constraint_Error'Identity,
        "an RGB image short of data for its line size raises");
    Raises (Short_Bitmap'Access, Constraint_Error'Identity, "a bitmap short of data raises");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Image_Data;


