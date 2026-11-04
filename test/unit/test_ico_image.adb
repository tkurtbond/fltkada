--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  ICO_Image (Fl_ICO_Image), from pofltk's TestImageFiles.  Fl_ICO_Image
--  hands a PNG entry to Fl_PNG_Image by its file's name, and in memory that
--  is null, so the same data fails with fail() -2 (pofltk 82).  ICO_Image
--  reads a file whole and decodes it as data, and decodes a PNG entry from
--  its offset.  A bitmap entry FLTK would read past (colors.ico, pofltk 87)
--  crashes FLTK, and is refused.  Run from test/unit.


with

    Ada.Directories,
    Ada.Streams.Stream_IO,
    Checks,
    FLTK.Images.RGB.BMP.ICO;

use

    Checks,
    FLTK;


procedure Test_ICO_Image is

    package ICO renames FLTK.Images.RGB.BMP.ICO;
    package SIO renames Ada.Streams.Stream_IO;

    Dir : constant String := "../images/";

    function Read
           (Name : in String)
        return Color_Component_Array
    is
        File   : SIO.File_Type;
        Result : Color_Component_Array (1 .. Size_Type (Ada.Directories.Size (Name)));
    begin
        SIO.Open (File, SIO.In_File, Name);
        Color_Component_Array'Read (SIO.Stream (File), Result);
        SIO.Close (File);
        return Result;
    end Read;

    type RGB_Triple is array (1 .. 3) of Color_Component;

    Red  : constant RGB_Triple := (255, 0, 0);
    Blue : constant RGB_Triple := (0, 0, 255);

    function Pixel
           (Image : in ICO.ICO_Image;
            X, Y  : in Natural)
        return RGB_Triple
    is
        At_Byte : constant Size_Type :=
            Size_Type ((Y * Image.Get_Data_W + X) * Image.Get_D) + 1;
    begin
        return (Image.Get_Datum (At_Byte), Image.Get_Datum (At_Byte + 1),
            Image.Get_Datum (At_Byte + 2));
    end Pixel;

    --  Red on the left, blue on the right, as rb.ico and rbpng.ico are.
    function Red_Left_Blue_Right
           (Image : in ICO.ICO_Image)
        return Boolean
    is
        Right  : constant Natural := Image.Get_Data_W - 1;
        Bottom : constant Natural := Image.Get_Data_H - 1;
    begin
        return Image.Get_D = 4
            and then Pixel (Image, 0, 0) = Red and then Pixel (Image, Right, 0) = Blue
            and then Pixel (Image, 0, Bottom) = Red and then Pixel (Image, Right, Bottom) = Blue;
    end Red_Left_Blue_Right;

    PNG_Data : constant Color_Component_Array := Read (Dir & "rbpng.ico");

    Ignore : Natural;

    procedure Past_The_Count is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "rb.ico", 2);
    begin
        Ignore := Image.Get_W;
    end Past_The_Count;

    procedure Past_The_Count_In_Memory is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (PNG_Data, 1);
    begin
        Ignore := Image.Get_W;
    end Past_The_Count_In_Memory;

    procedure Below_Minus_One is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "rb.ico", -2);
    begin
        Ignore := Image.Get_W;
    end Below_Minus_One;

    procedure Colors is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "colors.ico");
    begin
        Ignore := Image.Get_W;
    end Colors;

    procedure Colors_In_Memory is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (Read (Dir & "colors.ico"), 0);
    begin
        Ignore := Image.Get_W;
    end Colors_In_Memory;

    procedure Not_An_ICO is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "rb.png");
    begin
        Ignore := Image.Get_W;
    end Not_An_ICO;

    procedure Missing is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "nonexistent.ico");
    begin
        Ignore := Image.Get_W;
    end Missing;

    procedure Empty_Data is
        Image : constant ICO.ICO_Image := ICO.Forge.Create (Color_Component_Array'(1 .. 0 => 0));
    begin
        Ignore := Image.Get_W;
    end Empty_Data;

    procedure Count_Missing is
    begin
        Ignore := ICO.ICO_Count (Dir & "nonexistent.ico");
    end Count_Missing;

    procedure Count_Not_An_ICO is
    begin
        Ignore := ICO.ICO_Count (Dir & "rb.png");
    end Count_Not_An_ICO;

begin

    --  A bitmap ICO, of two entries.
    Check (ICO.ICO_Count (Dir & "rb.ico") = 2, "rb.ico has two images");
    declare
        First   : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "rb.ico", 0);
        Second  : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "rb.ico", 1);
        Largest : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "rb.ico");
        List    : constant ICO.Icon_Entry_Array := First.Entries;
    begin
        Check (First.Get_W = 4 and First.Get_H = 2 and Red_Left_Blue_Right (First),
            "its first, by id 0");
        Check (Second.Get_W = 8 and Second.Get_H = 4 and Red_Left_Blue_Right (Second),
            "its second, by id 1");
        Check (Largest.Get_W = 8, "-1, the default, is the largest");
        Check (List'Length = 2
                and then List (1).Width = 4 and then List (1).Height = 2
                and then List (1).Bit_Count = 32 and then List (1).Image_Offset = 38
                and then List (2).Width = 8 and then List (2).Resource_Bytes = 184,
            "its directory's entries");
    end;

    --  An ICO holding a PNG.
    declare
        From_File : constant ICO.ICO_Image := ICO.Forge.Create (Dir & "rbpng.ico");
        From_Data : constant ICO.ICO_Image := ICO.Forge.Create (PNG_Data);
        By_Id     : constant ICO.ICO_Image := ICO.Forge.Create (PNG_Data, 0);
    begin
        Check (From_File.Get_W = 4 and Red_Left_Blue_Right (From_File),
            "an ICO holding a PNG loads from its file");
        Check (From_Data.Get_W = 4 and Red_Left_Blue_Right (From_Data),
            "and from memory, where FLTK fails (82)");
        Check (By_Id.Get_W = 4 and By_Id.Entries'Length = 1, "by its id");
        Check (ICO.ICO_Count (PNG_Data) = 1, "its count, from memory");
    end;

    Raises (Past_The_Count'Access, Constraint_Error'Identity, "an id past the count");
    Raises (Past_The_Count_In_Memory'Access, Constraint_Error'Identity,
        "an id past the count, in memory");
    Raises (Below_Minus_One'Access, Constraint_Error'Identity, "an id below -1");
    Raises (Colors'Access, Images.Format_Error'Identity,
        "a bitmap entry FLTK would read past, which crashed it (87)");
    Raises (Colors_In_Memory'Access, Images.Format_Error'Identity, "and from memory");
    Raises (Not_An_ICO'Access, Images.Format_Error'Identity, "a PNG file isn't an ICO");
    Raises (Missing'Access, Images.File_Access_Error'Identity, "a file that isn't there");
    Raises (Empty_Data'Access, Images.Format_Error'Identity, "no data");
    Raises (Count_Missing'Access, Images.File_Access_Error'Identity,
        "the count of a file that isn't there");
    Raises (Count_Not_An_ICO'Access, Images.Format_Error'Identity,
        "the count of a file that isn't an ICO");

    Summary;

end Test_ICO_Image;
