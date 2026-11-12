--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/fltk-versions.cxx: the system and back end, and FLTK's
--  version, API version and ABI version, each as the headers FLTKAda's
--  shim was compiled with have it and as the library running has it, and
--  whether the two agree; printed, and shown in a window.  A mismatch of
--  the ABI versions is also shown in a message.  Guided by pofltk's
--  FltkVersions.Mod.


with

    Ada.Long_Float_Text_IO,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows;

use type

    FLTK.Alignment,
    FLTK.Version_Number;


function FLTK_Versions
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Win renames FLTK.Widgets.Groups.Windows;
    package SU  renames Ada.Strings.Unbounded;
    package TIO renames Ada.Text_IO;

    WW : constant := 640;  MW : constant := 750;  --  initial, max. window width
    WH : constant := 200;  MH : constant := 300;  --  initial, max. window height


    function Get_Platform
        return String is
    begin
        case FLTK.Static.Get_Display_Platform is
            when FLTK.Static.X11_Platform     => return "Unix/Linux (X11)";
            when FLTK.Static.Wayland_Platform => return "Unix/Linux (Wayland)";
            when FLTK.Static.Other_Platform   =>
                return "platform unknown, unsupported, or display not opened";
        end case;
    end Get_Platform;


    procedure Set_Attributes
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Item.Set_Label_Font (FLTK.Courier);
        Item.Set_Label_Size (16);
        Item.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);
    end Set_Attributes;


    --  printf's "%6.4f", for a version.
    function Real
           (Value : in Long_Float)
        return String
    is
        Result : String (1 .. 6);
    begin
        Ada.Long_Float_Text_IO.Put (Result, Value, Aft => 4, Exp => 0);
        return Result;
    end Real;


    --  printf's "%6d".
    function Int
           (Value : in FLTK.Version_Number)
        return String is
    begin
        return Ada.Strings.Fixed.Tail
            (Ada.Strings.Fixed.Trim (Value'Image, Ada.Strings.Left), 6);
    end Int;


    function Image
           (Value : in FLTK.Version_Number)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Value'Image, Ada.Strings.Left);
    end Image;


    function Verdict
           (OK : in Boolean)
        return String is
    begin
        return (if OK then "OK" else "FAIL");
    end Verdict;


    function "+"
           (Item : in String)
        return SU.Unbounded_String
        renames SU.To_Unbounded_String;

begin

    declare

        Platform : constant String := Get_Platform;  --  opens the display

        Version : constant array (0 .. 8) of SU.Unbounded_String :=
           (+("FL_VERSION        = " & Real (FLTK.Built_Version)),
            +("Fl::version()     = " & Real (FLTK.Version)),
            +Verdict (FLTK.Built_Version = FLTK.Version),
            +("FL_API_VERSION    = " & Int (FLTK.Built_API_Version)),
            +("Fl::api_version() = " & Int (FLTK.API_Version)),
            +Verdict (FLTK.Built_API_Version = FLTK.API_Version),
            +("FL_ABI_VERSION    = " & Int (FLTK.Built_ABI_Version)),
            +("Fl::abi_version() = " & Int (FLTK.ABI_Version)),
            +Verdict (FLTK.Built_ABI_Version = FLTK.ABI_Version));

    begin

        TIO.Put_Line ("System/platform   = " & Platform);

        for I in Version'Range loop
            if I mod 3 = 1 then  --  2nd line followed by check mark or text
                TIO.Put (SU.To_String (Version (I)) & "  ");
            else                 --  1st and 3rd line
                TIO.Put_Line (SU.To_String (Version (I)));
            end if;
        end loop;
        TIO.Flush;

        if FLTK.Built_ABI_Version /= FLTK.ABI_Version then
            declare
                Mismatch : constant String :=
                    "*** FLTK ABI version mismatch: headers = " &
                    Image (FLTK.Built_ABI_Version) & ", lib = " &
                    Image (FLTK.ABI_Version) & " ***";
            begin
                TIO.Put_Line (Mismatch);
                TIO.Flush;
                FLTK.Asks.Message_Box (Mismatch);
            end;
        end if;

        declare

            Window : Win.Window := Win.Forge.Create (WW, WH);
            Grid   : Grd.Grid := Grd.Forge.Create (Window, 0, 0, WW, WH);
            Title  : Bx.Box := Bx.Forge.Create (Grid, 0, 0, 0, 0, Platform);

            --  each row's version as the headers have it, as the library
            --  has it, and whether they agree, as FLTK makes them
            function Make
                   (Index : in Natural)
                return Bx.Box is
            begin
                return Bx.Forge.Create
                    (Grid, 0, 0, (if Index mod 3 = 2 then 40 else 270), 0,
                     SU.To_String (Version (Index)));
            end Make;

            Box : array (0 .. 8) of Bx.Box :=
               (Make (0), Make (1), Make (2),
                Make (3), Make (4), Make (5),
                Make (6), Make (7), Make (8));

        begin

            Grid.Set_Layout (4, 3, 20, 5);

            Set_Attributes (Title);
            Title.Set_Label_Font (FLTK.Helvetica_Bold);
            Grid.Set_Widget (Title, 1, 1, 1, 3);
            Grid.Set_Row_Height (1, 40);
            Title.Set_Label_Size (20);

            for I in 0 .. 2 loop
                Grid.Set_Widget (Box (3 * I),     I + 2, 1);
                Grid.Set_Widget (Box (3 * I + 1), I + 2, 2);
                Grid.Set_Widget (Box (3 * I + 2), I + 2, 3);
                Grid.Set_Row_Height (I + 2, 30);
            end loop;

            for B of Box loop
                Set_Attributes (B);
            end loop;

            Window.End_Current;
            Window.Set_Resizable (Grid);
            Window.Set_Size_Range (WW, WH, MW, MH);
            Window.Show_With_Args;

            return FLTK.Run;

        end;

    end;

end FLTK_Versions;

