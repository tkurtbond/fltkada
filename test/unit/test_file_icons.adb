--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 10, pofltk 85 and 86: Fl_File_Icon::label keeps a
--  copied label marked as the widget's to free, so FLTK later free()s
--  the icon, and FLTK gives the icon label no measure, so it measures the
--  icon as text.  Fl_File_Icon::load_image reads only some kinds of
--  image, and a bad .fti leaves half an icon.  Also the icons' list and
--  a file browser's icons.  The list changes how every file browser
--  draws, so this has a process of its own.


with

    Ada.Exceptions,
    Checks,
    FLTK.Draw,
    FLTK.Images.File_Icons,
    FLTK.Images.Shared,
    FLTK.Multi_Labels,
    FLTK.Probe,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Browsers.Textline.File,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;

use type

    FLTK.Images.File_Icons.File_Icon_Access,
    FLTK.Images.File_Icons.File_Kind;


procedure Test_File_Icons is

    package Dr  renames FLTK.Draw;
    package FI  renames FLTK.Images.File_Icons;
    package ML  renames FLTK.Multi_Labels;
    package Prb renames FLTK.Probe;
    package Box renames FLTK.Widgets.Boxes;
    package FB  renames FLTK.Widgets.Groups.Browsers.Textline.File;
    package Win renames FLTK.Widgets.Groups.Windows;

    Dir : constant String := "../images/";

    Red  : constant Prb.RGB := Prb.To_RGB (255, 0, 0);
    Blue : constant Prb.RGB := Prb.To_RGB (0, 0, 255);

    Square : constant FI.Vertex_Array :=
       ((1000, 1000), (9000, 1000), (9000, 9000), (1000, 9000));
    Whole  : constant FI.Vertex_Array :=
       ((0, 0), (10_000, 0), (10_000, 10_000), (0, 10_000));

    --  Checked before any icon is made.
    Empty_At_Start : constant Boolean := FI.Icons'Length = 0;

    --  Declared before the widgets, so they outlive the widgets that show
    --  them.
    I     : aliased FI.File_Icon := FI.Forge.Create ("*.foo", FI.Plain_File);
    J     : aliased FI.File_Icon := FI.Forge.Create ("*.bar");
    K     : aliased FI.File_Icon := FI.Forge.Create ("*.loaded", FI.Plain_File);
    Multi : ML.Multi_Label := ML.Forge.Create;

    --  Draws its icon on white, in red for Icon_Color.
    type Picture is new Box.Box with record
        Icon : FI.File_Icon_Access;
    end record;

    overriding procedure Draw
           (This : in out Picture);

    overriding procedure Draw
           (This : in out Picture) is
    begin
        Dr.Rect_Fill (This.Get_X, This.Get_Y, This.Get_W, This.Get_H, White_Color);
        if This.Icon /= null then
            This.Icon.Draw (This.Get_X, This.Get_Y, This.Get_W, This.Get_H, Red_Color);
        end if;
    end Draw;

    Window  : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Test_File_Icons");
    Pic     : Picture :=
        (Box.Forge.Create (Window, 0, 0, 40, 40) with Icon => I'Unchecked_Access);
    Shown   : Box.Box := Box.Forge.Create (Window, 50, 0, 40, 40);
    Browser : FB.File_Browser := FB.Forge.Create (Window, 100, 0, 100, 100);

    --  Whether pixel 20, 20 of a capture of Item is Hue.
    function Middle
           (Item : in FLTK.Widgets.Widget'Class;
            Hue  : in Prb.RGB)
        return Boolean
    is
        OK : Boolean;
    begin
        OK := Prb.Capture (Item) and then Prb.Pixel (20, 20) = Hue;
        Prb.Release;
        return OK;
    end Middle;

    --  A checksum of the pixels of a capture of Item.
    function Signature
           (Item : in FLTK.Widgets.Widget'Class)
        return Long_Long_Integer
    is
        Sum : Long_Long_Integer := 0;
    begin
        if not Prb.Capture (Item) then
            return -1;
        end if;
        for Y in 0 .. Item.Get_H - 1 loop
            for X in 0 .. Item.Get_W - 1 loop
                Sum := (Sum * 31 + Long_Long_Integer (Prb.Pixel (X, Y))) mod 16#7FFF_FFFF#;
            end loop;
        end loop;
        Prb.Release;
        return Sum;
    end Signature;

    --  What K.Load (Dir & Name) raises: "none", "access" or "format".
    function Load_Result
           (Name : in String)
        return String is
    begin
        K.Load (Dir & Name);
        return "none";
    exception
    when FLTK.Images.File_Access_Error => return "access";
    when FLTK.Images.Format_Error => return "format";
    end Load_Result;

    Found   : FI.File_Icon_Access;
    Shade   : Long_Long_Integer;
    Label_W : Integer;
    Label_H : Integer;
    One_W   : Integer;
    One_H   : Integer;

begin

    Window.End_Current;

    Check (Empty_At_Start, "no icons to begin with");

    --  Made from shapes.
    Check (I.Size = 0 and I.Get_Kind = FI.Plain_File, "Create: empty, of its kind");
    Check (I.Get_Pattern = "*.foo", "with its pattern");
    I.Add_Color (FI.Icon_Color);
    I.Add_Polygon (Square);
    Check (I.Size > 0, "shapes added");
    J.Add_Color (Blue_Color);
    J.Add_Outline_Polygon (Black_Color, Whole);
    Check (J.Get_Kind = FI.Any_File, "Any_File by default");
    declare
        List : constant FI.File_Icon_Array := FI.Icons;
    begin
        Check (List'Length = 3
                and then List (1) = K'Unchecked_Access
                and then List (2) = J'Unchecked_Access
                and then List (3) = I'Unchecked_Access,
            "the list holds them, last made first");
    end;
    Check (FI.Find ("x.foo", FI.Plain_File) = I'Unchecked_Access, "Find by pattern and kind");
    Check (FI.Find ("x.foo", FI.Directory_File) = null, "and no other kind");
    Check (FI.Find ("x.baz", FI.Plain_File) = null, "or pattern");

    --  Drawn and shown.
    Shown.Set_Background_Color (White_Color);
    Check (Middle (Pic, Red), "Draw draws it, in the tint for Icon_Color");
    Pic.Icon := J'Unchecked_Access;
    Check (Middle (Pic, Blue), "or in its own color");
    FI.Set_Icon_Label (Shown, J);
    Check (Shown.Get_Label_Kind = Icon_Label, "a widget's icon label");
    Check (Middle (Shown, Blue), "is drawn");
    Check (Shown.Get_Label = "", "and reads as no text");
    Shown.Measure_Label (Label_W, Label_H);
    Check (Label_W = 0 and Label_H = 0, "and measures as none, not as text");
    Shown.Set_Label ("text");
    Check (Shown.Get_Label = "text" and Shown.Get_Label_Kind = Normal_Label,
        "text replaces it");
    Shown.Measure_Label (One_W, One_H);
    Shown.Set_Label ("text text text text");
    Shown.Measure_Label (Label_W, Label_H);
    Check (One_W > 0 and One_H > 0 and Label_W > One_W and Label_H = One_H,
        "and Measure_Label measures text on one line");
    Shown.Set_Label ("text");
    FI.Set_Icon_Label (Shown, J);
    Shown.Set_Label_Kind (Shadow_Label);
    Check (Shown.Get_Label_Kind = Icon_Label, "Set_Label_Kind leaves it an icon");
    Check (Middle (Shown, Blue), "drawn still");
    Multi.Set_First ("a");
    Multi.Set_Second ("b");
    ML.Set_Multi_Label (Shown, Multi);
    FI.Set_Icon_Label (Shown, J);
    Check (Middle (Shown, Blue), "an icon replaces a multi-label");
    ML.Set_Multi_Label (Shown, Multi);
    Check (not Middle (Shown, Blue), "and a multi-label replaces it");
    Shown.Set_Label ("");

    --  Loaded.
    Check (Load_Result ("nothing.png") = "access" and K.Size = 0,
        "no file: File_Access_Error");
    Check (Load_Result ("nothing.fti") = "access" and K.Size = 0,
        "no .fti file: File_Access_Error");
    Check (Load_Result ("bad.fti") = "format" and K.Size = 0,
        "a bad .fti: Format_Error, and empty");
    Check (Load_Result ("rb.xbm") = "format" and K.Size = 0,
        "a bitmap has no pixels to read");
    Check (Load_Result ("box.fti") = "none" and K.Size > 0, "a .fti file");
    Pic.Icon := K'Unchecked_Access;
    Check (Middle (Pic, Red), "drawn in Icon_Color as it says");
    K.Clear;
    Check (K.Size = 0, "Clear");
    Check (Load_Result ("rb.bmp") = "format" and K.Size = 0,
        "a BMP before Register_Images: Format_Error, as Shared reads none");
    FLTK.Images.Shared.Register_Images;
    Check (Load_Result ("rb.bmp") = "none" and K.Size = 68, "a BMP, each row two runs");
    Check (Prb.Capture (Pic)
            and then Prb.Pixel (10, 10) = Red
            and then Prb.Pixel (30, 10) = Blue,
        "its colors");
    Prb.Release;
    K.Clear;
    Check (Load_Result ("rb.gif") = "none" and K.Size = 68, "a GIF");
    K.Clear;
    Check (Load_Result ("rb.xpm") = "none" and K.Size = 68, "an XPM");
    K.Clear;
    if Prb.Has_SVG then
        Check (Load_Result ("rb.svg") = "none" and K.Size > 0, "an SVG");
    else
        Skip ("no SVG");
    end if;
    K.Clear;
    Check (Load_Result ("rb.ico") = "none" and K.Size > 0, "an ICO");

    --  A file browser's icons.
    FI.Add_File (Browser, "one", I'Unchecked_Access);
    FI.Add_File (Browser, "two", null);
    Check (Browser.Number_Of_Lines = 2 and Browser.Get_Line_Text (1) = "one",
        "Add_File adds a line");
    Check (FI.Get_File_Icon (Browser, 1) = I'Unchecked_Access
            and FI.Get_File_Icon (Browser, 2) = null,
        "with its icon or none");
    Shade := Signature (Browser);
    FI.Set_File_Icon (Browser, 1, null);
    Check (FI.Get_File_Icon (Browser, 1) = null, "Set_File_Icon takes it away");
    Check (Signature (Browser) /= Shade, "and the line shows none");
    FI.Set_File_Icon (Browser, 1, I'Unchecked_Access);
    Check (Signature (Browser) = Shade, "and gives it back");
    declare
        procedure Past is
        begin
            FI.Set_File_Icon (Browser, 3, null);
        end Past;
        procedure Get_Past is
        begin
            Found := FI.Get_File_Icon (Browser, 3);
        end Get_Past;
    begin
        Raises (Past'Access, Constraint_Error'Identity, "Set_File_Icon past the last line");
        Raises (Get_Past'Access, Constraint_Error'Identity, "Get_File_Icon past the last line");
    end;

    --  FLTK's own icons.
    FI.Load_System_Icons;
    declare
        List : constant FI.File_Icon_Array := FI.Icons;
    begin
        Check (List'Length > 3, "Load_System_Icons adds to the list");
        Check (List (List'First) = FI.Icons (1), "one object for an icon");
    end;
    Found := FI.Find ("/tmp", FI.Directory_File);
    Check (Found /= null and then Found.Get_Kind = FI.Directory_File, "a directory's icon");
    Browser.Load (Dir => Dir);
    Check (Browser.Number_Of_Lines > 0, "a browser uses them as it loads");
    Found := null;
    for Line in 1 .. Browser.Number_Of_Lines loop
        Found := FI.Get_File_Icon (Browser, Line);
        exit when Found /= null;
    end loop;
    Check (Found /= null, "a line shows FLTK's icon");
    Check (Signature (Browser) /= -1, "and draws");

    --  The browser is cleared, and the label taken, before the icons go.
    Browser.Clear;
    Shown.Set_Label ("");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_File_Icons;
