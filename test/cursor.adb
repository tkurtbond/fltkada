--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/cursor.cxx: a choice of FLTK's mouse cursors, a slider
--  over FLTK's cursor numbers 0 to 255, and a custom cursor made from
--  fluid/pixmaps/compressed.xpm.  A number that isn't one of FLTK's
--  cursors shows FLTK's arrow, as FLTK falls back to it (fl_cursor.cxx,
--  fallback_cursor).


with

    Ada.Strings.Unbounded,
    FLTK.Draw,
    FLTK.Images.Pixmaps,
    FLTK.Images.RGB,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

use type

    FLTK.Callback_Flag,
    FLTK.Mouse_Cursor_Kind;


function Cursor
    return Integer
is


    package SU  renames Ada.Strings.Unbounded;
    package FD  renames FLTK.Draw;
    package Pix renames FLTK.Images.Pixmaps;
    package RGB renames FLTK.Images.RGB;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;
    package MC  renames FLTK.Widgets.Menus.Choices;
    package HV  renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;


    --  FLTK's number for each cursor (Enumerations.H, Fl_Cursor).

    FLTK_Value : constant array (FLTK.Mouse_Cursor_Kind) of Integer :=
       (FLTK.Default_Mouse   => 0,
        FLTK.Arrow_Mouse     => 35,
        FLTK.Crosshair_Mouse => 66,
        FLTK.Wait_Mouse      => 76,
        FLTK.Insert_Mouse    => 77,
        FLTK.Hand_Mouse      => 31,
        FLTK.Help_Mouse      => 47,
        FLTK.Move_Mouse      => 27,
        FLTK.NS_Mouse        => 78,
        FLTK.WE_Mouse        => 79,
        FLTK.NWSE_Mouse      => 80,
        FLTK.NESW_Mouse      => 81,
        FLTK.N_Mouse         => 70,
        FLTK.NE_Mouse        => 69,
        FLTK.E_Mouse         => 49,
        FLTK.SE_Mouse        => 8,
        FLTK.S_Mouse         => 9,
        FLTK.SW_Mouse        => 7,
        FLTK.W_Mouse         => 36,
        FLTK.NW_Mouse        => 68,
        FLTK.None_Mouse      => 255);

    function To_Kind
           (Value : in Integer)
        return FLTK.Mouse_Cursor_Kind is
    begin
        for K in FLTK_Value'Range loop
            if FLTK_Value (K) = Value then
                return K;
            end if;
        end loop;
        return FLTK.Arrow_Mouse;
    end To_Kind;


    --  fluid/pixmaps/compressed.xpm

    type Pixel_Rows is array (1 .. 32) of String (1 .. 32);

    function To_Data
           (Rows : in Pixel_Rows)
        return Pix.Pixmap_Data
    is
        Data : Pix.Pixmap_Data (Rows'Range, Rows (Rows'First)'Range);
    begin
        for R in Data'Range (1) loop
            for C in Data'Range (2) loop
                Data (R, C) := Rows (R) (C);
            end loop;
        end loop;
        return Data;
    end To_Data;

    Compressed_Header : constant Pix.Header := (32, 32, 6, 1);
    Compressed_Colors : constant Pix.Color_Definition_Array :=
       ((+"-", Pix.Colorful, +"#000"), (+"=", Pix.Colorful, +"#444"),
        (+"c", Pix.Colorful, +"none"), (+"d", Pix.Colorful, +"#cccccc"),
        (+".", Pix.Colorful, +"#888"), (+",", Pix.Colorful, +"#888"));
    Compressed_Rows : constant Pixel_Rows :=
       ("cccccccccccccccccccccccccccccccc",
        "cccccccccccccccccccccccccccccccc",
        "ccccccc==================ccccccc",
        "cccccccc================cccccccc",
        "ccccccccc==============ccccccccc",
        "cccccccccc============cccccccccc",
        "ccccccccccc==========ccccccccccc",
        "cccccccccccc========cccccccccccc",
        "ccccccccccccc======ccccccccccccc",
        "cccccccccccccc====cccccccccccccc",
        "cc==.cccccccccc==ccccccccccc==cc",
        "cc.====..cccccccccccccc..====.cc",
        "cccc.======================.cccc",
        "cccccccc..============..cccccccc",
        "cccccccccccccccccccccccccccccccc",
        "cccccccccccccccccccccccccccccccc",
        "cccccccc..============..cccccccc",
        "cccc.======================.cccc",
        "cc.====..cccccccccccccc..====.cc",
        "cc==.cccccccccc==ccccccccccc==cc",
        "cccccccccccccc====cccccccccccccc",
        "ccccccccccccc======ccccccccccccc",
        "cccccccccccc========cccccccccccc",
        "ccccccccccc==========ccccccccccc",
        "cccccccccc============cccccccccc",
        "ccccccccc==============ccccccccc",
        "cccccccc================cccccccc",
        "ccccccc==================ccccccc",
        "cccccccccccccccccccccccccccccccc",
        "cccccccccccccccccccccccccccccccc",
        "cccccccccccccccccccccccccccccccc",
        "cccccccccccccccccccccccccccccccc");


    The_Window : WD.Double_Window := WD.Forge.Create (400, 300);

    The_Choices : MC.Choice := MC.Forge.Create
        (The_Window, 80, 100, 200, 25, "Cursor:");

    The_Slider : HV.Horizontal_Value_Slider := HV.Forge.Create
        (The_Window, 80, 180, 310, 30, "Cursor:");


    --  The chosen item is the cursor's position in Mouse_Cursor_Kind.
    procedure Choice_Callback
           (This : in out FLTK.Widgets.Widget'Class)
    is
        Kind : constant FLTK.Mouse_Cursor_Kind :=
            FLTK.Mouse_Cursor_Kind'Val (MC.Choice (This).Chosen_Index - 1);
    begin
        The_Slider.Set_Value (Long_Float (FLTK_Value (Kind)));
        FD.Set_Cursor (Kind);
    end Choice_Callback;


    procedure Custom_Callback
           (This : in out FLTK.Widgets.Widget'Class)
    is
        Pxm : constant Pix.Pixmap := Pix.Forge.Create
            (Compressed_Header, Compressed_Colors, To_Data (Compressed_Rows));
        Img : RGB.RGB_Image := RGB.Forge.Create (Pxm);
    begin
        Img.Scale (16, 16);
        This.Top_Window.Set_Cursor (Img, Img.Get_W / 2, Img.Get_H / 2);
    end Custom_Callback;


    procedure Slider_Callback
           (This : in out FLTK.Widgets.Widget'Class) is
    begin
        FD.Set_Cursor (To_Kind (Integer (HV.Horizontal_Value_Slider (This).Get_Value)));
    end Slider_Callback;


begin


    for K in FLTK.Mouse_Cursor_Kind loop
        declare
            Name : constant String := FLTK.Mouse_Cursor_Kind'Image (K);
            Base : constant String := Name (Name'First .. Name'Last - 6);
        begin
            The_Choices.Add
                ("FL_CURSOR_" & (if K = FLTK.Crosshair_Mouse then "CROSS" else Base),
                 Choice_Callback'Unrestricted_Access);
        end;
    end loop;
    The_Choices.Add ("custom cursor", Custom_Callback'Unrestricted_Access);

    --  Fl_Menu_::menu chooses the first item; Add chooses none.
    The_Choices.Set_Chosen (1);

    The_Choices.Set_When (FLTK.When_Release + FLTK.When_Interact);

    The_Slider.Set_Alignment (FLTK.Align_Left);
    The_Slider.Set_Step (1);
    The_Slider.Set_Precision (0);
    The_Slider.Set_Bounds (0.0, 255.0);
    The_Slider.Set_Value (0.0);
    The_Slider.Set_Callback (Slider_Callback'Unrestricted_Access);

    The_Window.Set_Resizable (The_Window);
    The_Window.Show_With_Args;

    return FLTK.Run;


end Cursor;

