

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Images FLTK reads and shares, after pofltk's examples/Icons.Mod:  an
--  XBM file, a bitmap made here, each size in an ICO file, and one image
--  on three buttons.
--
--  A bitmap is drawn in its widget's label colour.  A shared image is one
--  file's pixels however many widgets show them.  A widget shows an image
--  without owning it, so the enlarged copies and the shared images are
--  kept here until Run returns.  The images are in images/, as make runs
--  it from test/.


with

    Ada.Containers.Vectors,
    Ada.Strings.Fixed,
    Ada.Unchecked_Deallocation,
    FLTK.Images.Bitmaps.XBM,
    FLTK.Images.RGB.BMP.ICO,
    FLTK.Images.Shared,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;


function Icons
    return Integer
is


    package Img renames FLTK.Images;
    package Bit renames FLTK.Images.Bitmaps;
    package XBM renames FLTK.Images.Bitmaps.XBM;
    package ICO renames FLTK.Images.RGB.BMP.ICO;
    package Shr renames FLTK.Images.Shared;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;


    --  The test images are tiny.
    Scale : constant := 8;

    ICO_File : constant String := "images/rb.ico";
    XBM_File : constant String := "images/rb.xbm";
    GIF_File : constant String := "images/rb.gif";

    type Image_Access is access Img.Image'Class;
    type Shared_Access is access Shr.Shared_Image;
    type Widget_Access is access Wdg.Widget'Class;

    procedure Free is new Ada.Unchecked_Deallocation (Img.Image'Class, Image_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Shr.Shared_Image, Shared_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Wdg.Widget'Class, Widget_Access);

    package Image_Vectors is new Ada.Containers.Vectors (Positive, Image_Access);
    package Shared_Vectors is new Ada.Containers.Vectors (Positive, Shared_Access);
    package Widget_Vectors is new Ada.Containers.Vectors (Positive, Widget_Access);

    Images  : Image_Vectors.Vector;
    Shareds : Shared_Vectors.Vector;
    Widgets : Widget_Vectors.Vector;

    Window : Win.Window := Win.Forge.Create (370, 280, "Icons");


    --  C's "%d".
    function Image
           (Item : in Integer)
        return String is (Ada.Strings.Fixed.Trim (Integer'Image (Item), Ada.Strings.Left));


    --  Shows Pic, enlarged, in a box at X, Y.
    procedure Show
           (X, Y  : in Integer;
            Pic   : in Img.Image'Class;
            Label : in String)
    is
        Box   : constant Widget_Access :=
            new Bx.Box'(Bx.Forge.Create (Window, X, Y, 80, 60, Label));
        Large : constant Image_Access :=
            new Img.Image'Class'(Pic.Copy (Pic.Get_W * Scale, Pic.Get_H * Scale));
    begin
        Box.Set_Box (FLTK.Down_Box);
        Box.Set_Label_Color (FLTK.Blue_Color);
        Box.Set_Image (Large.all);
        Widgets.Append (Box);
        Images.Append (Large);
    end Show;


    --  A checkered bitmap, four by two:  a byte a row, its lowest bit
    --  leftmost.
    function Checks
        return Bit.Bitmap is (Bit.Forge.Create ((16#05#, 16#0A#), 4, 2));


    procedure Shared_Button
           (X     : in Integer;
            Label : in String)
    is
        Button : constant Widget_Access :=
            new Btn.Button'(Btn.Forge.Create (Window, X, 120, 80, 60, Label));
        Pic    : constant Shared_Access :=
            new Shr.Shared_Image'(Shr.Forge.Create (GIF_File, 64, 32));
    begin
        Button.Set_Image (Pic.all);
        Widgets.Append (Button);
        Shareds.Append (Pic);
    end Shared_Button;


    procedure Quit_CB
           (Ignore : in out Wdg.Widget'Class) is
    begin
        Window.Hide;
    end Quit_CB;


    --  "N buttons, M images in the pool".  A size of the file holds a
    --  reference to the file itself, so the pool has the GIF at both sizes,
    --  and Found is the fourth reference to the smaller.
    function Pool_Info
        return String
    is
        Found : constant Shr.Shared_Image := Shr.Forge.Find (GIF_File, 64, 32);
    begin
        return Image (Found.Reference_Count - 1) & " buttons, "
            & Image (Shr.Number_Of_Images) & " images in the pool";
    end Pool_Info;


    X : Integer := 190;


begin


    --  Fl_Shared_Image reads only XBM files without the other loaders.
    Shr.Register_Images;
    Show (10, 20, XBM.Forge.Create (XBM_File), "XBM");
    Show (100, 20, Checks, "bitmap");
    declare
        Count : constant Natural := ICO.Forge.Create (ICO_File).Entries'Length;
    begin
        for Id in 0 .. Count - 1 loop
            declare
                Pic : constant ICO.ICO_Image := ICO.Forge.Create (ICO_File, Id);
            begin
                Show (X, 20, Pic, "ICO " & Image (Pic.Get_W) & "x" & Image (Pic.Get_H));
                X := X + 90;
            end;
        end loop;
    end;
    Shared_Button (10, "one");
    Shared_Button (100, "two");
    Shared_Button (190, "three");

    declare
        Info : Bx.Box := Bx.Forge.Create (Window, 10, 215, 350, 25, Pool_Info);
        Quit : Btn.Button := Btn.Forge.Create (Window, 280, 245, 80, 25, "Quit");
    begin
        Quit.Set_Callback (Quit_CB'Unrestricted_Access);
        Window.Show;

        return Result : constant Integer := FLTK.Run do
            for Item of Widgets loop
                Free (Item);
            end loop;
            for Item of Images loop
                Free (Item);
            end loop;
            for Item of Shareds loop
                Free (Item);
            end loop;
        end return;
    end;


end Icons;

