

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Shared_Image's "<", which orders images as Fl_Shared_Image::compare
--  orders FLTK's pool: by name, then data width, then data height.  FLTK
--  keeps the pool sorted, so Pool_Images comes in that order.  Run from
--  test/unit.


with

    Ada.Containers.Generic_Sort,
    Checks,
    FLTK.Images.Shared;

use

    Checks;


procedure Test_Shared_Order is

    package Shr renames FLTK.Images.Shared;

    Dir : constant String := "../images/";

    function Describe
           (Item : in Shr.Shared_Image)
        return String is
    begin
        return " " & Item.Name & Integer'Image (Item.Get_Data_W) & "x" &
            Integer'Image (Item.Get_Data_H);
    end Describe;

begin

    Shr.Register_Images;

    declare
        PNG  : constant Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.png", 0, 0);
        GIF  : constant Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.gif", 0, 0);
        XPM  : constant Shr.Shared_Image := Shr.Forge.Create (Dir & "rb.xpm", 0, 0);
        Wide : constant Shr.Shared_Image'Class := PNG.Copy (8, 2);
        Tall : constant Shr.Shared_Image'Class := PNG.Copy (8, 5);
        use type Shr.Shared_Image;
    begin
        Check (GIF < PNG and not (PNG < GIF), "by name first:" & Describe (GIF) & Describe (PNG));
        Check (PNG < XPM, "and by name whatever the size");
        Check (PNG < Shr.Shared_Image (Wide) and not (Shr.Shared_Image (Wide) < PNG),
            "then by data width:" & Describe (PNG) & Describe (Shr.Shared_Image (Wide)));
        Check (Shr.Shared_Image (Wide) < Shr.Shared_Image (Tall),
            "then by data height:" & Describe (Shr.Shared_Image (Wide)) &
            Describe (Shr.Shared_Image (Tall)));
        Check (not (PNG < PNG), "an image isn't less than itself");

        declare
            Pool  : constant Shr.Shared_Image_Array := Shr.Pool_Images;
            Order : array (Pool'Range) of Positive;

            function Before
                   (Left, Right : in Positive)
                return Boolean is
            begin
                return Pool (Order (Left)) < Pool (Order (Right));
            end Before;

            procedure Swap
                   (Left, Right : in Positive)
            is
                Kept : constant Positive := Order (Left);
            begin
                Order (Left) := Order (Right);
                Order (Right) := Kept;
            end Swap;

            procedure Sort is new Ada.Containers.Generic_Sort (Positive, Before, Swap);

            Same : Boolean := True;
        begin
            Check (Pool'Length = 5, "five images in the pool:" & Integer'Image (Pool'Length));
            for I in Pool'First .. Pool'Last - 1 loop
                Check (Pool (I) < Pool (I + 1),
                    "FLTK's pool is in this order:" & Describe (Pool (I)) &
                    Describe (Pool (I + 1)));
            end loop;
            for I in Order'Range loop
                Order (I) := Pool'Last - I + Pool'First;
            end loop;
            Sort (Order'First, Order'Last);
            for I in Order'Range loop
                Same := Same and Order (I) = I;
            end loop;
            Check (Same, "sorting the pool's indexes by it gives FLTK's order");
        end;
    end;

    Summary;

end Test_Shared_Order;



