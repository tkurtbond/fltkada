


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestImages: images from pixels, files and memory,
--  their colours, drawn in Draw and as labels, image surfaces and their
--  masks, tiled images and image cursors.  Each image is a 4 by 2 one, red
--  on the left and blue on the right (test/images/rb.*).  pofltk's checks
--  that a widget, browser, tree or menu keeps the images it shows have no
--  counterpart: the program owns its images here.  Other tests cover the
--  rest: test_browser_icons, test_tree_methods, test_menu_item_labels,
--  test_widget_multi_label, test_window_shape, test_image_data,
--  test_pixmap_data, test_tiled_tile and test_write_png.  Run from
--  test/unit.


with

    Ada.Directories,
    Ada.Exceptions,
    Ada.Streams.Stream_IO,
    Checks,
    FLTK.Devices.Surface.Image,
    FLTK.Draw,
    FLTK.Images.Bitmaps,
    FLTK.Images.Pixmaps.GIF,
    FLTK.Images.Pixmaps.XPM,
    FLTK.Images.RGB.BMP,
    FLTK.Images.RGB.JPEG,
    FLTK.Images.RGB.PNG,
    FLTK.Images.RGB.PNM,
    FLTK.Images.RGB.SVG,
    FLTK.Images.Tiled,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;

use type

    Ada.Exceptions.Exception_Id,
    FLTK.Color_Component,
    FLTK.Size_Type;


procedure Test_Images is

    package Bxs renames FLTK.Widgets.Boxes;
    package Img renames FLTK.Images;
    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package Srf renames FLTK.Devices.Surface;
    package Win renames FLTK.Widgets.Groups.Windows;

    Temp_PNG : constant String := "test_images.tmp.png";

    Red   : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Green : constant Prb.RGB := Prb.To_RGB (0, 255, 0);
    Blue  : constant Prb.RGB := Prb.To_RGB (0, 0, 255);
    White : constant Prb.RGB := Prb.To_RGB (255, 255, 255);
    Black : constant Prb.RGB := Prb.To_RGB (0, 0, 0);

    --  4 by 2 RGB pixels, the left half red and the right blue.
    Red_Blue : constant Color_Component_Array :=
       (255, 0, 0,  255, 0, 0,  0, 0, 255,  0, 0, 255,
        255, 0, 0,  255, 0, 0,  0, 0, 255,  0, 0, 255);

    --  Draws its image at its top left, on white.
    type Picture is new Bxs.Box with record
        Pic : access RGB.RGB_Image'Class;
    end record;

    overriding procedure Draw
           (This : in out Picture) is
    begin
        FLTK.Draw.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H, White_Color);
        This.Pic.Draw (This.Get_X, This.Get_Y);
    end Draw;

    --  The pixel at X, Y of Item, counted from 0, whose rows are packed.
    function Pixel
           (Item : in RGB.RGB_Image'Class;
            X, Y : in Natural)
        return Prb.RGB
    is
        D     : constant Positive_Size := Positive_Size (Item.Get_D);
        Place : constant Positive_Size :=
            Size_Type (Y * Item.Get_Data_W + X) * D + 1;
        function Int (C : in Color_Component) return Integer is (Integer (C));
    begin
        if D < 3 then
            return Prb.To_RGB (Int (Item.Get_Datum (Place)), Int (Item.Get_Datum (Place)),
                Int (Item.Get_Datum (Place)));
        else
            return Prb.To_RGB (Int (Item.Get_Datum (Place)), Int (Item.Get_Datum (Place + 1)),
                Int (Item.Get_Datum (Place + 2)));
        end if;
    end Pixel;

    function Alpha
           (Item : in RGB.RGB_Image'Class;
            X, Y : in Natural)
        return Color_Component is
    begin
        return Item.Get_Datum (Size_Type ((Y * Item.Get_Data_W + X) * Item.Get_D + Item.Get_D));
    end Alpha;

    function Part
           (C     : in Prb.RGB;
            Shift : in Natural)
        return Integer is (C / 2 ** Shift mod 256);

    --  Within 8 in each of red, green and blue, for a lossy format.
    function Near
           (C, Want : in Prb.RGB)
        return Boolean is
    begin
        return (for all K in 0 .. 2 =>
            abs (Part (C, 8 * K) - Part (Want, 8 * K)) <= 8);
    end Near;

    function Is_Red_Blue
           (Item : in RGB.RGB_Image'Class)
        return Boolean is
    begin
        return Item.Get_Data_W = 4 and Item.Get_Data_H = 2
            and Near (Pixel (Item, 0, 0), Red) and Near (Pixel (Item, 1, 1), Red)
            and Near (Pixel (Item, 2, 0), Blue) and Near (Pixel (Item, 3, 1), Blue);
    end Is_Red_Blue;

    function Is_Grey
           (C : in Prb.RGB)
        return Boolean is (Part (C, 16) = Part (C, 8) and Part (C, 8) = Part (C, 0));

    --  The bytes of file Name.
    function Read
           (Name : in String)
        return Color_Component_Array
    is
        use Ada.Streams;
        File   : Stream_IO.File_Type;
        Bytes  : Stream_Element_Array (1 .. Stream_Element_Offset (Ada.Directories.Size (Name)));
        Last   : Stream_Element_Offset;
        Result : Color_Component_Array (1 .. Bytes'Length);
    begin
        Stream_IO.Open (File, Stream_IO.In_File, Name);
        Stream_IO.Read (File, Bytes, Last);
        Stream_IO.Close (File);
        for K in Result'Range loop
            Result (K) := Color_Component (Bytes (Stream_Element_Offset (K)));
        end loop;
        return Result;
    end Read;

    --  Whether Make raises Expected.
    generic
        with procedure Make;
    function Raises
           (Expected : in Ada.Exceptions.Exception_Id)
        return Boolean;

    function Raises
           (Expected : in Ada.Exceptions.Exception_Id)
        return Boolean is
    begin
        Make;
        return False;
    exception
    when Occurrence : others =>
        return Ada.Exceptions.Exception_Identity (Occurrence) = Expected;
    end Raises;

    --  Draws Item into a surface W by H, on white, and gives it back.
    function Drawn
           (Item : in Img.Image'Class;
            W, H : in Positive)
        return RGB.RGB_Image
    is
        S : Srf.Image.Image_Surface := Srf.Image.Forge.Create (W, H);
    begin
        Srf.Push_Current (S);
        FLTK.Draw.Rect_Fill (0, 0, W, H, White_Color);
        Item.Draw (0, 0);
        Srf.Pop_Current;
        return S.Get_Image;
    end Drawn;

    --  A mask of Size by Size pixels, black to the left of the middle and
    --  white to its right, or the other way round.
    function Half_Mask
           (Size        : in Positive;
            White_Right : in Boolean)
        return RGB.RGB_Image
    is
        S     : Srf.Image.Image_Surface := Srf.Image.Forge.Create (Size, Size);
        Left  : constant Color := (if White_Right then Black_Color else White_Color);
        Right : constant Color := (if White_Right then White_Color else Black_Color);
    begin
        Srf.Push_Current (S);
        FLTK.Draw.Rect_Fill (0, 0, Size / 2, Size, Left);
        FLTK.Draw.Rect_Fill (Size / 2, 0, Size - Size / 2, Size, Right);
        Srf.Pop_Current;
        return S.Get_Image;
    end Half_Mask;

    procedure Fill
           (S   : in out Srf.Image.Image_Surface;
            Hue : in     Color) is
    begin
        Srf.Push_Current (S);
        FLTK.Draw.Rect_Fill (0, 0, 40, 40, Hue);
        Srf.Pop_Current;
    end Fill;

    Window : Win.Window := Win.Forge.Create (0, 0, 100, 100, "Test_Images");

    I : aliased RGB.RGB_Image := RGB.Forge.Create (Red_Blue, 4, 2);

begin

    --  From pixels
    Check (I.Get_D = 3 and I.Get_W = 4 and I.Get_H = 2 and Is_Red_Blue (I)
            and Pixel (I, 0, 0) = Red,
        "RGB_Image from pixels");
    declare
        J : constant RGB.RGB_Image :=
            RGB.Forge.Create (Color_Component_Array'(255, 128, 0, 16#40#), 1, 1, 4);
        K : constant RGB.RGB_Image :=
            RGB.Forge.Create (Color_Component_Array'(16#80#, 7), 1, 1, 2);
    begin
        Check (J.Get_D = 4 and Pixel (J, 0, 0) = Prb.To_RGB (255, 128, 0)
                and Alpha (J, 0, 0) = 16#40#,
            "RGBA");
        Check (K.Get_D = 2 and Pixel (K, 0, 0) = Prb.To_RGB (128, 128, 128)
                and Alpha (K, 0, 0) = 7,
            "grey and alpha");
    end;
    declare
        J : constant RGB.RGB_Image'Class := I.Copy (8, 4);
    begin
        Check (J.Get_Data_W = 8 and J.Get_Data_H = 4 and Pixel (J, 0, 0) = Red
                and Pixel (J, 7, 3) = Blue,
            "Copy, scaled");
    end;
    I.Scale (8, 4, Proportional => False, Can_Expand => True);
    Check (I.Get_W = 8 and I.Get_H = 4 and I.Get_Data_W = 4,
        "Scale changes the size drawn, not the data");
    Check (I.Data_Size = 24 and I.All_Data'Length = 24, "and Data_Size is the data's (bug 115)");
    I.Scale (4, 2, Proportional => False, Can_Expand => True);
    declare
        B : Img.Bitmaps.Bitmap := Img.Bitmaps.Forge.Create ((16#0F#, 16#F0#), 8, 2);
    begin
        B.Scale (64, 64, Proportional => False, Can_Expand => True);
        Check (B.Data_Size = 2 and B.Get_Datum (2) = 16#F0#,
            "a bitmap's Data_Size is its data's too (bug 115)");
    end;

    --  Files, in each format FLTK reads
    --  test/images/rb.png isn't red and blue (the ICO tests use it), so
    --  this writes one.
    RGB.PNG.Write_PNG (I, Temp_PNG);
    Check (Is_Red_Blue (RGB.PNG.Forge.Create (Temp_PNG)), "PNG");
    Check (Is_Red_Blue (RGB.JPEG.Forge.Create ("../images/rb.jpg")), "JPEG (near)");
    Check (Is_Red_Blue (RGB.BMP.Forge.Create ("../images/rb.bmp")), "BMP, with a palette");
    Check (Is_Red_Blue (RGB.PNM.Forge.Create ("../images/rb.ppm")), "PNM");
    if RGB.SVG.Is_Supported then
        Check (Is_Red_Blue (RGB.SVG.Forge.Create ("../images/rb.svg")), "SVG, rasterized");
    else
        Skip ("SVG, rasterized");
    end if;
    Check (Is_Red_Blue (RGB.Forge.Create (Img.Pixmaps.GIF.Forge.Create ("../images/rb.gif"))),
        "GIF, a pixmap");
    Check (Is_Red_Blue (RGB.Forge.Create (Img.Pixmaps.XPM.Forge.Create ("../images/rb.xpm"))),
        "XPM");
    declare
        procedure Missing is
            J : constant RGB.PNG.PNG_Image := RGB.PNG.Forge.Create ("../images/none.png");
        begin
            null;
        end Missing;
        procedure Not_Image is
            J : constant RGB.PNG.PNG_Image := RGB.PNG.Forge.Create ("test_images.adb");
        begin
            null;
        end Not_Image;
        function Missing_Raises is new Raises (Missing);
        function Not_Image_Raises is new Raises (Not_Image);
    begin
        Check (Missing_Raises (Img.File_Access_Error'Identity),
            "a missing file raises File_Access_Error");
        Check (Not_Image_Raises (Img.Format_Error'Identity),
            "and a file that isn't an image Format_Error");
    end;

    --  From memory
    declare
        PNG_Bytes : constant Color_Component_Array := Read (Temp_PNG);
        SVG_Bytes : constant Color_Component_Array := Read ("../images/rb.svg");
        SVG_Text  : String (1 .. SVG_Bytes'Length);
        procedure Short is
            J : constant RGB.PNG.PNG_Image :=
                RGB.PNG.Forge.Create (Data => PNG_Bytes (1 .. 10));
        begin
            null;
        end Short;
        function Short_Raises is new Raises (Short);
    begin
        Ada.Directories.Delete_File (Temp_PNG);
        for K in SVG_Text'Range loop
            SVG_Text (K) := Character'Val (SVG_Bytes (Size_Type (K)));
        end loop;
        Check (Is_Red_Blue (RGB.PNG.Forge.Create (Data => PNG_Bytes)), "PNG data");
        if RGB.SVG.Is_Supported then
            Check (Is_Red_Blue (RGB.SVG.Forge.Create (Data => SVG_Text)), "SVG text");
            Check (Is_Red_Blue (RGB.SVG.Forge.Create (Data => SVG_Bytes)), "SVG bytes");
        else
            Skip ("SVG text");
            Skip ("SVG bytes");
        end if;
        Check (Short_Raises (Img.Format_Error'Identity), "PNG data cut short raises Format_Error");
    end;

    --  Changing pixels
    declare
        J : RGB.RGB_Image'Class := I.Copy;
        K : RGB.RGB_Image'Class := I.Copy;
        G : Img.Pixmaps.GIF.GIF_Image := Img.Pixmaps.GIF.Forge.Create ("../images/rb.gif");
    begin
        J.Desaturate;
        Check (Is_Grey (Pixel (J, 0, 0)) and Pixel (J, 0, 0) /= Red, "Desaturate");
        K.Color_Average (Black_Color, 0.5);
        Check (Near (Pixel (K, 0, 0), Prb.To_RGB (128, 0, 0)), "Color_Average");
        G.Color_Average (Black_Color, 0.5);
        Check (Near (Pixel (RGB.Forge.Create (G), 0, 0), Prb.To_RGB (128, 0, 0)),
            "a pixmap's Color_Average");
        G.Desaturate;
        Check (Is_Grey (Pixel (RGB.Forge.Create (G), 0, 0)), "a pixmap's Desaturate");
    end;

    --  An image drawn in Draw
    declare
        Pic : constant Picture := (Bxs.Forge.Create (Window, 0, 0, 10, 10) with Pic => I'Access);
    begin
        Check (Prb.Capture (Pic) and Prb.Pixel (0, 0) = Red and Prb.Pixel (3, 1) = Blue
                and Prb.Pixel (4, 0) = White,
            "an image drawn in Draw");
        Prb.Release;
    end;

    --  A label image, and an inactive one
    declare
        Box  : Bxs.Box := Bxs.Forge.Create (Window, 20, 0, 20, 20);
        J    : RGB.RGB_Image'Class := I.Copy;
        Grey : RGB.RGB_Image'Class := I.Copy;
        C    : Prb.RGB;
    begin
        Box.Set_Box (Flat_Box);
        Box.Set_Background_Color (White_Color);
        Box.Set_Image (J);
        Check (Prb.Capture (Box) and Prb.Pixel (8, 9) = Red and Prb.Pixel (11, 9) = Blue,
            "Set_Image: a label image, centred");
        Prb.Release;
        Grey.Desaturate;
        Box.Set_Inactive_Image (Grey);
        Box.Deactivate;
        Check (Prb.Capture (Box), "an inactive widget draws");
        C := Prb.Pixel (8, 9);
        Prb.Release;
        Check (Is_Grey (C) and C /= White, "with its inactive image");
        Box.Activate;
        Box.Clear_Image;
        Check (Prb.Capture (Box) and Prb.Pixel (8, 9) = White, "Clear_Image");
        Prb.Release;
    end;

    --  Image surfaces
    declare
        S   : Srf.Image.Image_Surface := Srf.Image.Forge.Create (20, 10);
        T   : Srf.Image.Image_Surface := Srf.Image.Forge.Create (2, 2);
        Pic : constant Picture := (Bxs.Forge.Create (Window, 0, 0, 10, 10) with Pic => I'Access);
    begin
        Srf.Push_Current (S);
        FLTK.Draw.Rect_Fill (0, 0, 20, 10, Blue_Color);
        FLTK.Draw.Rect_Fill (5, 5, 2, 2, Red_Color);
        declare
            Read : constant Color_Component_Array := FLTK.Draw.Read_Image (4, 4, 4, 4);
        begin
            Check (Read (1 .. 3) = (0, 0, 255) and Read (16 .. 18) = (255, 0, 0),
                "Read_Image on a surface reads its pixels");
        end;
        S.Draw_Widget (Pic, 10, 0);
        Srf.Pop_Current;
        declare
            J : constant RGB.RGB_Image := S.Get_Image;
        begin
            Check (J.Get_Data_W = 20 and Pixel (J, 0, 0) = Blue and Pixel (J, 5, 5) = Red
                    and Pixel (J, 10, 0) = Red and Pixel (J, 12, 1) = Blue
                    and Pixel (J, 14, 0) = White,
                "Get_Image, with a widget drawn");
        end;
        Srf.Push_Current (S);
        Srf.Push_Current (T);
        FLTK.Draw.Rect_Fill (0, 0, 2, 2, Red_Color);
        Srf.Pop_Current;
        FLTK.Draw.Rect_Fill (0, 0, 1, 1, Black_Color);
        Srf.Pop_Current;
        Check (Pixel (T.Get_Image, 1, 1) = Red and Pixel (S.Get_Image, 0, 0) = Black
                and Pixel (S.Get_Image, 1, 1) = Blue,
            "surfaces nest, drawing going to the one before after Pop_Current");
    end;

    --  Masks.  The edge of a mask is soft, so these look well away from it.
    declare
        S : Srf.Image.Image_Surface := Srf.Image.Forge.Create (40, 40);
    begin
        Fill (S, Red_Color);
        S.Mask (Half_Mask (40, White_Right => True));
        Fill (S, Blue_Color);
        declare
            J : constant RGB.RGB_Image := S.Get_Image;
        begin
            Check (Pixel (J, 5, 20) = Red and Pixel (J, 35, 20) = Blue,
                "Mask: drawing shows where it is white");
        end;
        S.Mask (Half_Mask (20, White_Right => False));
        Fill (S, Green_Color);
        declare
            J : constant RGB.RGB_Image := S.Get_Image;
        begin
            Check (Pixel (J, 5, 20) = Green and Pixel (J, 35, 20) = Blue,
                "a next mask after Get_Image, of another size");
        end;
        S.Mask (Half_Mask (40, White_Right => True));
        --  and a mask never used, freed with the surface: valgrind
    end;

    --  A window's decorations
    declare
        W : Win.Window := Win.Forge.Create (0, 0, 40, 30);
    begin
        W.End_Current;
        W.Set_Background_Color (Red_Color);
        W.Set_Box (Flat_Box);
        declare
            S : Srf.Image.Image_Surface := Srf.Image.Forge.Create (8, 8);
        begin
            Srf.Push_Current (S);
            FLTK.Draw.Rect_Fill (0, 0, 8, 8, Blue_Color);
            S.Draw_Decorated_Window (W);
            Srf.Pop_Current;
            Check (Pixel (S.Get_Image, 4, 4) = Blue,
                "Draw_Decorated_Window: nothing of a window never shown");
        end;
        W.Show;
        W.Wait_For_Expose;
        declare
            DW : constant Integer := W.Get_Decorated_W;
            DH : constant Integer := W.Get_Decorated_H;
            S  : Srf.Image.Image_Surface := Srf.Image.Forge.Create (DW, DH);
        begin
            Srf.Push_Current (S);
            FLTK.Draw.Rect_Fill (0, 0, DW, DH, Blue_Color);
            S.Draw_Decorated_Window (W);
            Srf.Pop_Current;
            Check (Pixel (S.Get_Image, DW - 20, DH - 15) = Red, "and of a window shown");
        end;
        W.Hide;
    end;

    --  Tiled images
    declare
        Tile  : RGB.RGB_Image := RGB.Forge.Create (Red_Blue, 4, 2);
        Tiled : Img.Tiled.Tiled_Image := Img.Tiled.Forge.Create (Tile, 10, 3);
    begin
        Check (Tiled.Get_W = 10 and Tiled.Get_H = 3, "a tiled image's size");
        declare
            J : constant RGB.RGB_Image := Drawn (Tiled, 12, 4);
        begin
            Check (Pixel (J, 4, 0) = Red and Pixel (J, 6, 2) = Blue and Pixel (J, 9, 1) = Red
                    and Pixel (J, 10, 0) = White and Pixel (J, 0, 3) = White,
                "draws its image repeated, to its size");
        end;
        Tiled.Color_Average (Green_Color, 0.0);
        declare
            J : constant RGB.RGB_Image := Drawn (Tiled, 12, 4);
        begin
            Check (Pixel (J, 4, 0) = Green and Pixel (J, 6, 2) = Green,
                "Color_Average of a tiled image");
        end;
    end;

    --  Cursors: a window not shown ignores them, FLTK copies the image, and
    --  a scaled image is read at its drawn size.  Valgrind checks it.
    declare
        W : Win.Window := Win.Forge.Create (0, 0, 40, 40);
        J : RGB.RGB_Image := RGB.Forge.Create (Red_Blue, 4, 2);
    begin
        W.End_Current;
        W.Set_Cursor (J, 3, 1);
        W.Show;
        W.Wait_For_Expose;
        W.Set_Cursor (J, 0, 0);
        J.Scale (16, 8, Proportional => False, Can_Expand => True);
        W.Set_Cursor (J, 15, 7);
        W.Set_Cursor (Default_Mouse);
        Check (True, "Set_Cursor with an image, in a window shown and not");
        W.Hide;
    end;

    Window.End_Current;
    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Images;
