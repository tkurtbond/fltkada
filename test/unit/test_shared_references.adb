--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 100:  Forge.Create of an image already in the pool took
--  two references, and Finalize gave back one, so the image stayed in the
--  pool for good.  Each Shared_Image holds one reference.


with

    Ada.Exceptions,
    Checks,
    FLTK.Images.Shared;

use

    Checks;


procedure Test_Shared_References is

    package Shr renames FLTK.Images.Shared;

    File : constant String := "../images/rb.gif";

    --  The references to File at W by H, not counting the one Find takes.
    function References
           (W, H : in Integer)
        return Natural
    is
        Found : constant Shr.Shared_Image := Shr.Forge.Find (File, W, H);
    begin
        return Found.Reference_Count - 1;
    end References;

    procedure Expect
           (W, H     : in Integer;
            Expected : in Natural;
            Message  : in String)
    is
        Count : constant Natural := References (W, H);
    begin
        Check (Count = Expected, Message & ":" & Natural'Image (Count));
    end Expect;

    Images : Natural;

begin

    Shr.Register_Images;
    Images := Shr.Number_Of_Images;

    declare
        First : constant Shr.Shared_Image := Shr.Forge.Create (File, 0, 0);
    begin
        Expect (0, 0, 1, "the file, made once");
        declare
            Second : constant Shr.Shared_Image := Shr.Forge.Create (File, 0, 0);
        begin
            Expect (0, 0, 2, "the file, made twice");
        end;
        Expect (0, 0, 1, "the file, once the second has gone");
    end;
    Check (Shr.Number_Of_Images = Images, "the file leaves the pool");

    declare
        First : constant Shr.Shared_Image := Shr.Forge.Create (File, 64, 32);
    begin
        --  The size holds a reference to the file.
        Expect (64, 32, 1, "a size, made once");
        Expect (0, 0, 1, "its file");
        declare
            Second : constant Shr.Shared_Image := Shr.Forge.Create (File, 64, 32);
            Third  : constant Shr.Shared_Image := Shr.Forge.Create (File, 64, 32);
        begin
            Expect (64, 32, 3, "a size, made three times");
            Expect (0, 0, 1, "its file still");
        end;
        Expect (64, 32, 1, "a size, once the others have gone");
    end;
    Check (Shr.Number_Of_Images = Images, "the size and its file leave the pool");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Shared_References;
