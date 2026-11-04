


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 5, pofltk 87 and 88: FLTK trusts a BMP's count of
--  colors, depth and size, and a GIF's sizes and LZW codes, and writes past
--  what it has when they lie.  The files in test/images are pofltk's: a BMP
--  with too many colors, an absurd size or a depth that isn't one; an ICO
--  holding such a BMP; a GIF whose codes loop, one with an empty image, one
--  with an impossible code size, and one whose frame is off its screen,
--  which is refused only as an animation.  Valgrind checks the reads and
--  writes.  And FLTKAda's own: a PNG and a JPEG that claim more bytes than
--  an int holds, which FLTK's loaders count in one (FLTK-issues.md, F7).
--  And pofltk 81: Fl_XBM_Image takes any two #defines as the size, leaves
--  the bits it can't find unset, counts the size in an int, and never
--  deletes the bits; valgrind checks the leak.  And FLTKAda-BUGS.md 55: a
--  JPEG from memory, cut short, which FLTK read past the end of when it
--  wasn't told the length.


with

    Ada.Directories,
    Ada.Direct_IO,
    Ada.Exceptions,
    Ada.Strings.Unbounded,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Images.Bitmaps.XBM,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Images.RGB.BMP,
    FLTK.Images.RGB.JPEG,
    FLTK.Images.RGB.PNG,
    FLTK.Images.Shared;

use

    Checks,
    FLTK;

use type

    FLTK.Size_Type;


procedure Test_Image_Crafted is

    package Anim renames FLTK.Images.Pixmaps.GIF.Animated;
    package BMP  renames FLTK.Images.RGB.BMP;
    package GIF  renames FLTK.Images.Pixmaps.GIF;
    package JPEG renames FLTK.Images.RGB.JPEG;
    package PNG  renames FLTK.Images.RGB.PNG;
    package RGB  renames FLTK.Images.RGB;
    package Shr  renames FLTK.Images.Shared;
    package XBM  renames FLTK.Images.Bitmaps.XBM;

    package Byte_IO is new Ada.Direct_IO (Color_Component);

    Dir : constant String := "../images/";

    function Contents
           (Name : in String)
        return Color_Component_Array
    is
        File : Byte_IO.File_Type;
    begin
        Byte_IO.Open (File, Byte_IO.In_File, Dir & Name);
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

    Name : Ada.Strings.Unbounded.Unbounded_String;

    function Named
        return String is
    begin
        return Ada.Strings.Unbounded.To_String (Name);
    end Named;

    procedure Open_BMP is
        Image : constant BMP.BMP_Image := BMP.Forge.Create (Dir & Named);
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_BMP;

    procedure Open_GIF is
        Image : constant GIF.GIF_Image := GIF.Forge.Create (Dir & Named);
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_GIF;

    procedure Open_GIF_Data is
        Image : constant GIF.GIF_Image := GIF.Forge.Create (Data => Contents (Named));
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_GIF_Data;

    procedure Open_PNG is
        Image : constant PNG.PNG_Image := PNG.Forge.Create (Dir & Named);
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_PNG;

    procedure Open_PNG_Data is
        Image : constant PNG.PNG_Image := PNG.Forge.Create (Data => Contents (Named));
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_PNG_Data;

    procedure Open_JPEG is
        Image : constant JPEG.JPEG_Image := JPEG.Forge.Create (Dir & Named);
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_JPEG;

    procedure Open_JPEG_Data is
        Image : constant JPEG.JPEG_Image := JPEG.Forge.Create (Data => Contents (Named));
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_JPEG_Data;

    procedure Open_XBM is
        Image : constant XBM.XBM_Image := XBM.Forge.Create (Dir & Named);
    begin
        Check (False, Named & " loaded, " & Integer'Image (Image.Get_W) & " wide");
    end Open_XBM;

    --  On the heap, where valgrind sees a read past the end.
    type Data_Access is access Color_Component_Array;
    procedure Free is new Ada.Unchecked_Deallocation (Color_Component_Array, Data_Access);

    function JPEG_W
           (Data : in Color_Component_Array)
        return Integer
    is
        Held  : Data_Access := new Color_Component_Array'(Data);
        Width : Integer := -1;
    begin
        begin
            declare
                Image : constant JPEG.JPEG_Image := JPEG.Forge.Create (Data => Held.all);
            begin
                Width := Image.Get_W;
            end;
        exception
        when Images.Format_Error =>
            Width := 0;
        end;
        Free (Held);
        return Width;
    end JPEG_W;

    Int_Last : constant Size_Type := Size_Type (Integer'Last);

    procedure Raise_Max_Size is
    begin
        RGB.Set_Max_Size (Int_Last + 1);
    end Raise_Max_Size;

    procedure Open_Shared is
        Image : constant Shr.Shared_Image := Shr.Forge.Create (Dir & Named, 0, 0);
    begin
        Check (False, Named & " shared, " & Integer'Image (Image.Get_W) & " wide");
    end Open_Shared;

    procedure Refused
           (File   : in String;
            Action : not null access procedure;
            Error  : in Ada.Exceptions.Exception_Id;
            Label  : in String) is
    begin
        Name := Ada.Strings.Unbounded.To_Unbounded_String (File);
        Raises (Action, Error, Label & ": " & File);
    end Refused;

    procedure Not_Animated
           (File : in String)
    is
        A : constant Anim.Animated_GIF_Image := Anim.Forge.Create (Dir & File);
        B : constant Anim.Animated_GIF_Image := Anim.Forge.Create (Data => Contents (File));
        C : Anim.Animated_GIF_Image := Anim.Forge.Create;
    begin
        Check (not A.Is_Loaded and then A.Fail_Code = -3,
            "an animation of " & File & " isn't loaded:" & Integer'Image (A.Fail_Code));
        Check (not B.Is_Loaded and then B.Fail_Code = -3,
            "nor from memory:" & Integer'Image (B.Fail_Code));
        Check (not C.Load (Dir & File) and then not C.Is_Loaded, "nor by Load");
        Check (not C.Load (Data => Contents (File)) and then not C.Is_Loaded,
            "nor by Load from memory");
        Check (Anim.Frame_Count (Dir & File) = 0
            and then Anim.Frame_Count (Data => Contents (File)) = 0, "it has no frames");
        Check (not GIF.Is_Animated (Dir & File), "it isn't animated");
    end Not_Animated;

    Copy : constant String := "test_image_crafted.bmp";

begin

    Shr.Register_Images;

    --  pofltk 87: BMP headers that would have FLTK write past what it has.
    declare
        Good : constant BMP.BMP_Image := BMP.Forge.Create (Dir & "rb.bmp");
    begin
        Check (Good.Get_W = 4 and then Good.Get_H = 2, "a sound BMP loads");
    end;
    Refused ("colors.bmp", Open_BMP'Access, Images.Format_Error'Identity, "too many colors");
    Refused ("size.bmp", Open_BMP'Access, Images.Format_Error'Identity, "an absurd size");
    Refused ("depth.bmp", Open_BMP'Access, Images.Format_Error'Identity, "a depth that isn't");

    --  pofltk 88: GIFs.
    declare
        Good   : constant GIF.GIF_Image := GIF.Forge.Create (Dir & "rb.gif");
        Beyond : constant GIF.GIF_Image := GIF.Forge.Create (Dir & "beyond.gif");
    begin
        Check (Good.Get_W = 4 and then Good.Get_H = 2, "a sound GIF loads");
        Check (Beyond.Get_W > 0, "a frame off its screen loads as a still image");
    end;
    Refused ("no-such-file.gif", Open_GIF'Access, Images.File_Access_Error'Identity,
        "FLTKAda-BUGS.md 53, a GIF of no file");
    Refused ("loop.gif", Open_GIF'Access, Images.Format_Error'Identity, "codes that loop");
    Refused ("loop.gif", Open_GIF_Data'Access, Images.Format_Error'Identity,
        "codes that loop, from memory");
    Refused ("zero.gif", Open_GIF'Access, Images.Format_Error'Identity, "an empty image");
    Refused ("code.gif", Open_GIF'Access, Images.Format_Error'Identity, "an impossible code size");

    --  Animations.
    declare
        Good : constant Anim.Animated_GIF_Image := Anim.Forge.Create (Dir & "anim.gif");
    begin
        Check (Good.Is_Loaded and then Anim.Frame_Count (Dir & "anim.gif") = 3,
            "a sound animation loads");
    end;
    Not_Animated ("loop.gif");
    Not_Animated ("beyond.gif");

    --  F7: sizes over an int.
    Check (RGB.Get_Max_Size = Int_Last,
        "Max_Size is at most an int:" & Size_Type'Image (RGB.Get_Max_Size));
    Raises (Raise_Max_Size'Access, Constraint_Error'Identity, "a Max_Size over an int raises");
    Refused ("huge.png", Open_PNG'Access, Images.Format_Error'Identity, "too big for an int");
    Refused ("huge.png", Open_PNG_Data'Access, Images.Format_Error'Identity,
        "too big for an int, from memory");
    Refused ("huge.jpg", Open_JPEG'Access, Images.Format_Error'Identity, "too big for an int");
    Refused ("huge.jpg", Open_JPEG_Data'Access, Images.Format_Error'Identity,
        "too big for an int, from memory");
    Refused ("huge.png", Open_Shared'Access, Images.No_Image_Error'Identity,
        "shared, which FLTK's loader takes and fails");

    --  FLTKAda-BUGS.md 55: a JPEG from memory, whole and cut short.
    declare
        Whole : constant Color_Component_Array := Contents ("plasma.jpg");
        Half  : constant Integer :=
            JPEG_W (Whole (Whole'First .. Whole'First + Whole'Length / 2 - 1));
    begin
        Check (JPEG_W (Whole) = 64, "a JPEG loads from memory");
        Check (Half in 0 | 64, "a JPEG cut short loads what it has, or is refused:"
            & Integer'Image (Half));
        Check (JPEG_W (Whole (Whole'First .. Whole'First + 1)) = 0,
            "a JPEG of two bytes is refused");
    end;

    --  pofltk 81: XBMs.
    declare
        Good : constant XBM.XBM_Image := XBM.Forge.Create (Dir & "rb.xbm");
    begin
        Check (Good.Get_W = 4 and then Good.Get_H = 2 and then Good.Get_D = 0,
            "a sound XBM loads:" & Integer'Image (Good.Get_W) & Integer'Image (Good.Get_H));
    end;
    Refused ("no-such-file.xbm", Open_XBM'Access, Images.File_Access_Error'Identity,
        "an XBM of no file");
    Refused ("not-xbm.h", Open_XBM'Access, Images.Format_Error'Identity, "no width or height");
    Refused ("short.xbm", Open_XBM'Access, Images.Format_Error'Identity, "too few bytes");
    Refused ("huge.xbm", Open_XBM'Access, Images.Format_Error'Identity, "an absurd size");

    --  Shared images read each kind by its contents.
    declare
        Good  : constant Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.xbm", 0, 0);
        Twice : constant Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.xbm", 8, 4);
    begin
        Check (Good.Get_W = 4 and then Twice.Get_W = 8,
            "a sound XBM is shared:" & Integer'Image (Good.Get_W) & Integer'Image (Twice.Get_W));
    end;
    Refused ("short.xbm", Open_Shared'Access, Images.No_Image_Error'Identity, "shared");
    Refused ("huge.xbm", Open_Shared'Access, Images.No_Image_Error'Identity, "shared");
    declare
        Good : constant Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.ico", 0, 0);
    begin
        Check (Good.Get_W = 8, "a sound ICO is shared:" & Integer'Image (Good.Get_W));
    end;
    Refused ("no-such-file.bmp", Open_Shared'Access, Images.No_Image_Error'Identity,
        "a shared image of no file");
    Refused ("colors.bmp", Open_Shared'Access, Images.No_Image_Error'Identity, "shared");
    Refused ("colors.ico", Open_Shared'Access, Images.No_Image_Error'Identity, "shared");
    Refused ("loop.gif", Open_Shared'Access, Images.No_Image_Error'Identity, "shared");
    GIF.Set_Animate (True);
    Refused ("beyond.gif", Open_Shared'Access, Images.No_Image_Error'Identity,
        "shared as an animation");
    GIF.Set_Animate (False);

    --  A shared image whose file is replaced by a crafted one isn't reloaded.
    Ada.Directories.Copy_File (Dir & "rb.bmp", Copy);
    declare
        Image : Shr.Shared_Image := Shr.Forge.Create (Copy, 0, 0);
    begin
        Ada.Directories.Delete_File (Copy);
        Ada.Directories.Copy_File (Dir & "colors.bmp", Copy);
        Image.Reload;
        Check (Image.Get_W = 4,
            "a file that went bad isn't reloaded:" & Integer'Image (Image.Get_W));
    end;
    Ada.Directories.Delete_File (Copy);

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    if Ada.Directories.Exists (Copy) then
        Ada.Directories.Delete_File (Copy);
    end if;
    Summary;
end Test_Image_Crafted;


