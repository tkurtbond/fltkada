--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Shared_Image's handlers (pofltk 95), from pofltk's TestImageHandlers,
--  and Pool_Images.  Fl_Shared_Image::add_handler takes a function with no
--  data, and FLTK deletes the image a handler returns with the pool's
--  entry, so FLTK has one handler that asks the Ada list, and the pool
--  gets a copy.  Run from test/unit.


with

    Ada.Exceptions,
    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Images.RGB,
    FLTK.Images.Shared,
    FLTK.Probe,
    FLTK.Widgets.Boxes;

use

    Checks,
    FLTK;


procedure Test_Image_Handlers is

    package RGB renames FLTK.Images.RGB;
    package Shr renames FLTK.Images.Shared;
    package Prb renames FLTK.Probe;
    package Bxs renames FLTK.Widgets.Boxes;

    use type Shr.Image_Handler;

    Custom : constant String := "../images/rb.rbx";    --  this test's format, 6 bytes
    Long   : constant String := "../images/long.rbx";  --  the same, 100 bytes, a 0 the seventh
    Known  : constant String := "../images/rb.bmp";
    Gone   : constant String := "../images/no-such-file";

    Red  : constant Prb.RGB := 16#FF0000#;
    Blue : constant Prb.RGB := 16#0000FF#;

    type RGB_Access is access RGB.RGB_Image;
    procedure Free is new Ada.Unchecked_Deallocation (RGB.RGB_Image, RGB_Access);

    type String_Access is access String;
    procedure Free is new Ada.Unchecked_Deallocation (String, String_Access);

    --  What Second made last.  GNAT's Free left a volatile one set.
    Made : RGB_Access;

    --  The handlers set these inside the loads, so they are volatile.
    Seen       : String_Access with Volatile;
    Head       : Color_Component_Array (1 .. Shr.Max_Header) := (others => 0) with Volatile;
    Head_Len   : Natural := 0 with Volatile;
    Count      : Natural := 0 with Volatile;
    First_At   : Natural := 0 with Volatile;
    Second_At  : Natural := 0 with Volatile;
    Once_Asked : Natural := 0 with Volatile;
    Swapped    : Boolean := False with Volatile;   --  blue left and red right, not rb's

    Bad : exception;

    --  Knows no file, and notes when it was asked.
    function First
           (Name   : in String;
            Header : in Color_Component_Array)
        return access constant Images.Image'Class
    is
        pragma Unreferenced (Name, Header);
    begin
        Count := Count + 1;
        First_At := Count;
        return null;
    end First;

    --  Makes the 4x2 image of a file starting RB, as rb.bmp shows, or the
    --  other way round if Swapped.
    function Second
           (Name   : in String;
            Header : in Color_Component_Array)
        return access constant Images.Image'Class
    is
        Bits : Color_Component_Array (1 .. 24) := (others => 0);
    begin
        Count := Count + 1;
        Second_At := Count;
        declare
            Old : String_Access := Seen;
        begin
            Free (Old);
        end;
        Seen := new String'(Name);
        Head_Len := Header'Length;
        Head := (others => 0);
        Head (1 .. Header'Length) := Header;
        if Header'Length < 2 or else Header (Header'First) /= Character'Pos ('R')
            or else Header (Header'First + 1) /= Character'Pos ('B')
        then
            return null;
        end if;
        for I in 0 .. 7 loop
            if (I mod 4 < 2) /= Swapped then
                Bits (Size_Type (I * 3 + 1)) := 255;
            else
                Bits (Size_Type (I * 3 + 3)) := 255;
            end if;
        end loop;
        Free (Made);
        Made := new RGB.RGB_Image'(RGB.Forge.Create (Bits, 4, 2, 3));
        return Made;
    end Second;

    --  Removes itself as it is asked.
    function Once
           (Name   : in String;
            Header : in Color_Component_Array)
        return access constant Images.Image'Class
    is
        pragma Unreferenced (Name, Header);
    begin
        Once_Asked := Once_Asked + 1;
        Shr.Remove_Handler (Once'Unrestricted_Access);
        return null;
    end Once;

    --  Raises Bad.
    function Raiser
           (Name   : in String;
            Header : in Color_Component_Array)
        return access constant Images.Image'Class
    is
        pragma Unreferenced (Header);
    begin
        raise Bad with Name;
        return null;
    end Raiser;

    Empty : aliased RGB.RGB_Image;

    --  Answers with an image never made.
    function Gives_Empty
           (Name   : in String;
            Header : in Color_Component_Array)
        return access constant Images.Image'Class
    is
        pragma Unreferenced (Name, Header);
    begin
        return Empty'Access;
    end Gives_Empty;

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

    Ignore : Natural;

    procedure Load_Custom is
        Pic : constant Shr.Shared_Image := Shr.Forge.Create (Custom, 0, 0);
    begin
        Ignore := Pic.Get_W;
    end Load_Custom;

    procedure Load_Gone is
        Pic : constant Shr.Shared_Image := Shr.Forge.Create (Gone, 0, 0);
    begin
        Ignore := Pic.Get_W;
    end Load_Gone;

    F_Handler : constant Shr.Image_Handler := First'Unrestricted_Access;
    S_Handler : constant Shr.Image_Handler := Second'Unrestricted_Access;

begin

    Shr.Register_Images;
    Raises (Load_Custom'Access, Images.No_Image_Error'Identity,
        "no handler, a format FLTK can't read");
    Shr.Add_Handler (F_Handler);
    Shr.Add_Handler (S_Handler);
    Shr.Add_Handler (F_Handler);

    --  FLTK's own loaders
    Count := 0;
    declare
        Pic : constant Shr.Shared_Image := Shr.Forge.Create (Known, 0, 0);
    begin
        Check (Pic.Get_W = 4 and Count = 0, "a file FLTK can read asks no handler");
    end;
    Raises (Load_Gone'Access, Images.No_Image_Error'Identity, "nor does a file not there");
    Check (Count = 0, "which asks none");

    Count := 0;
    declare
        Pic : Shr.Shared_Image := Shr.Forge.Create (Custom, 0, 0);
    begin
        Check (Pic.Get_W = 4 and Pic.Get_H = 2, "a handler's image goes into the pool");
        Check (First_At = 1 and Second_At = 2 and Count = 2,
            "the first handler added first, a repeat ignored");
        Check (Seen.all = Custom, "the handler gets the name");
        Check (Head_Len = 6 and Head (1) = Character'Pos ('R') and Head (5) = Character'Pos ('2')
                and Head (6) = 10,
            "and the file's start");
        Check (Drawn (Pic) = (Red, Blue), "its pixels");
        Free (Made);
        Check (Drawn (Pic) = (Red, Blue), "the pool has a copy, so the handler's image can go");
        declare
            Found : constant Shr.Shared_Image := Shr.Forge.Find (Custom);
        begin
            Check (Found.Get_W = 4, "and the pool finds it by name");
        end;

        --  The pool's listing
        declare
            Before : constant Natural := Pic.Reference_Count;
            List   : constant Shr.Shared_Image_Array := Shr.Pool_Images;
            Names  : Natural := 0;
        begin
            Check (List'Length = Shr.Number_Of_Images and List'Length = 1,
                "Pool_Images lists the pool");
            for Item of List loop
                if Item.Name = Custom then
                    Names := Names + 1;
                end if;
            end loop;
            Check (Names = 1, "by name");
            Check (Pic.Reference_Count = Before + 1, "each with a reference of its own");
        end;
        Check (Pic.Reference_Count = 1, "given back when the listing goes");

        --  reloading
        Swapped := True;
        Pic.Reload;
        Check (Drawn (Pic) = (Blue, Red), "Reload asks again");
        Swapped := False;
        Shr.Remove_Handler (S_Handler);
        Shr.Remove_Handler (S_Handler);
        Count := 0;
        Pic.Reload;
        Check (Drawn (Pic) = (Blue, Red) and Count = 1,
            "a handler removed isn't asked, and the image is unchanged");
    end;
    Shr.Add_Handler (S_Handler);

    --  a long header, and a long name
    declare
        Pic : constant Shr.Shared_Image := Shr.Forge.Create (Long, 0, 0);
    begin
        Check (Pic.Get_W = 4, "a longer file");
        Check (Head_Len = Shr.Max_Header and Head (7) = 0 and Head (8) = Character'Pos ('x')
                and Head (Shr.Max_Header) = Character'Pos ('x'),
            "shows its first bytes, a 0 among them");
    end;
    declare
        Dots : String (1 .. 300);
    begin
        for I in 0 .. 149 loop
            Dots (2 * I + 1 .. 2 * I + 2) := "./";
        end loop;
        declare
            Name : constant String := "../images/" & Dots & "rb.rbx";
            Pic  : constant Shr.Shared_Image := Shr.Forge.Create (Name, 0, 0);
        begin
            Check (Pic.Get_W = 4 and Seen.all = Name, "a long name isn't cut");
        end;
    end;

    --  a handler may remove itself
    Shr.Remove_Handler (F_Handler);
    Shr.Remove_Handler (S_Handler);
    Shr.Add_Handler (Once'Unrestricted_Access);
    Shr.Add_Handler (S_Handler);
    declare
        Pic : constant Shr.Shared_Image := Shr.Forge.Create (Custom, 0, 0);
    begin
        Check (Pic.Get_W = 4 and Once_Asked = 1,
            "a handler removes itself, and the next is asked");
    end;
    Free (Made);
    declare
        Pic : constant Shr.Shared_Image := Shr.Forge.Create (Custom, 0, 0);
    begin
        Check (Pic.Get_W = 4 and Once_Asked = 1, "and isn't asked again");
    end;
    Free (Made);
    Shr.Remove_Handler (S_Handler);

    --  what goes wrong in a handler
    Shr.Add_Handler (Raiser'Unrestricted_Access);
    begin
        Load_Custom;
        Check (False, "a handler's exception is raised by the load");
    exception
    when Occurrence : Bad =>
        Check (Ada.Exceptions.Exception_Message (Occurrence) = Custom,
            "a handler's exception is raised by the load");
    end;
    Shr.Remove_Handler (Raiser'Unrestricted_Access);
    Shr.Add_Handler (Gives_Empty'Unrestricted_Access);
    Raises (Load_Custom'Access, Images.No_Image_Error'Identity, "a handler's image with no pixels");
    Shr.Remove_Handler (Gives_Empty'Unrestricted_Access);

    Check (Shr.Number_Of_Images = 0, "the pool empty");
    Check (Shr.Pool_Images'Length = 0, "and its listing");
    declare
        Old : String_Access := Seen;
    begin
        Free (Old);
    end;

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Image_Handlers;
