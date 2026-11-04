--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A drawing, saved as PostScript, EPS, PDF or SVG, after pofltk's
--  examples/SaveAs.Mod.  One procedure draws the picture, in the window and
--  in each file:  what FLTK.Draw draws goes to the surface current.  A page
--  is a job with one page, A4, with the picture in its middle, scaled down
--  to fit if it must be; EPS and SVG are the picture's own size.  A file
--  that can't be written isn't the program's fault, so it says so and
--  carries on.
--
--  Given a format (ps, eps, pdf or svg) and a file name, it writes that
--  file and stops, with no window, its exit status 1 if it couldn't.


with

    Ada.Command_Line,
    Ada.Exceptions,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Devices.Surface.EPS,
    FLTK.Devices.Surface.Paged.PDF,
    FLTK.Devices.Surface.Paged.Postscript,
    FLTK.Devices.Surface.SVG,
    FLTK.Draw,
    FLTK.Native_File_Choosers,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double;


function SaveAs
    return Integer
is


    package ACom renames Ada.Command_Line;
    package Surf renames FLTK.Devices.Surface;
    package Pgd  renames FLTK.Devices.Surface.Paged;
    package PS   renames FLTK.Devices.Surface.Paged.Postscript;
    package PDF  renames FLTK.Devices.Surface.Paged.PDF;
    package EPS  renames FLTK.Devices.Surface.EPS;
    package SVG  renames FLTK.Devices.Surface.SVG;
    package Dr   renames FLTK.Draw;
    package NFC  renames FLTK.Native_File_Choosers;

    use type NFC.Chooser_Option, NFC.Show_Result;

    Width  : constant := 400;
    Height : constant := 300;

    type Format_Kind is (Postscript_Format, EPS_Format, PDF_Format, SVG_Format);


    --  The picture, with its top left at X, Y.
    procedure Scene
           (X, Y : in Integer) is
    begin
        Dr.Set_Color (FLTK.RGB_Color (135, 206, 235));
        Dr.Rect_Fill (X, Y, Width, Height);
        Dr.Set_Color (FLTK.Yellow_Color);
        Dr.Pie (X + 300, Y + 30, 60, 60, 0.0, 360.0);
        Dr.Set_Color (FLTK.Dark_Yellow_Color);
        Dr.Set_Line_Style (Dr.Solid_Line, Width => 3);
        for I in 0 .. 7 loop
            Dr.Push_Matrix;
            Dr.Translate (Long_Float (X + 330), Long_Float (Y + 60));
            Dr.Rotate (Long_Float (I * 45));
            Dr.Begin_Line;
            Dr.Vertex (40.0, 0.0);
            Dr.Vertex (55.0, 0.0);
            Dr.End_Line;
            Dr.Pop_Matrix;
        end loop;

        Dr.Set_Color (FLTK.Dark_Green_Color);
        Dr.Begin_Polygon;
        Dr.Curve
           (Long_Float (X),         Long_Float (Y + 220),
            Long_Float (X + 130),   Long_Float (Y + 150),
            Long_Float (X + 270),   Long_Float (Y + 280),
            Long_Float (X + Width), Long_Float (Y + 200));
        Dr.Vertex (Long_Float (X + Width), Long_Float (Y + Height));
        Dr.Vertex (Long_Float (X), Long_Float (Y + Height));
        Dr.End_Polygon;

        Dr.Set_Color (FLTK.Red_Color);
        Dr.Rect_Fill (X + 80, Y + 150, 100, 70);
        Dr.Set_Color (FLTK.Dark_Red_Color);
        Dr.Polygon (X + 70, Y + 150, X + 130, Y + 100, X + 190, Y + 150);
        Dr.Set_Color (FLTK.White_Color);
        Dr.Rect_Fill (X + 95, Y + 165, 25, 25);
        Dr.Set_Color (FLTK.Black_Color);
        Dr.Set_Line_Style (Dr.Solid_Line, Width => 1);
        Dr.Rect (X + 95, Y + 165, 25, 25);
        Dr.Line (X + 107, Y + 165, X + 107, Y + 190);
        Dr.Line (X + 95, Y + 177, X + 120, Y + 177);

        Dr.Set_Line_Style (Dr.Dash_Line, Dr.Round_Cap, Width => 2);
        Dr.Ecks_Why_Line (X + 20, Y + 280, X + Width - 20);
        Dr.Set_Line_Style;

        Dr.Set_Font (FLTK.Times_Bold, 24);
        Dr.Draw_Text (X + 20, Y + 40, "Drawn by Ada");
    end Scene;


    type Picture is new FLTK.Widgets.Widget with null record;

    overriding procedure Draw
           (This : in out Picture);

    overriding procedure Draw
           (This : in out Picture) is
    begin
        Scene (This.Get_X, This.Get_Y);
    end Draw;


    --  One page, with the picture in its middle.
    procedure Page
           (Device : in out Pgd.Paged_Device'Class)
    is
        W, H   : Integer;
        Factor : Float := 1.0;
    begin
        Device.Start_Page;
        Device.Get_Printable_Rect (W, H);
        Factor := Float'Min (Factor, Float (W) / Float (Width));
        Factor := Float'Min (Factor, Float (H) / Float (Height));
        Device.Scale (Factor);
        Device.Get_Printable_Rect (W, H);
        Device.Set_Origin (W / 2, H / 2);
        Scene (-Width / 2, -Height / 2);
        Device.End_Page;
    end Page;


    --  Writes the file, and returns "" or why it couldn't.
    function Write
           (Format : in Format_Kind;
            Name   : in String)
        return String is
    begin
        case Format is
            when Postscript_Format =>
                declare
                    Device : PS.Postscript_File_Device := PS.Forge.Create;
                    File   : PS.File_Type;
                begin
                    File.Open (Name);
                    Device.Start_Job (File, 1, Pgd.A4, Pgd.Portrait);
                    Page (Device);
                    Device.End_Job;
                    File.Close;
                end;
            when EPS_Format =>
                declare
                    Surface : EPS.EPS_File_Surface :=
                        EPS.Forge.Create (Name, Width, Height, FLTK.White_Color);
                begin
                    Surface.Set_Current;
                    Scene (0, 0);
                    Surf.Get_Original.Set_Current;
                    Surface.Finish;
                end;
            when PDF_Format =>
                declare
                    Device : PDF.PDF_File_Surface := PDF.Forge.Create;
                begin
                    Device.Start_Document (Name, Pgd.A4, Pgd.Portrait);
                    Page (Device);
                    Device.End_Job;
                end;
            when SVG_Format =>
                declare
                    Surface : SVG.SVG_File_Surface := SVG.Forge.Create (Name, Width, Height);
                begin
                    Surface.Set_Current;
                    Scene (0, 0);
                    Surf.Get_Original.Set_Current;
                    Surface.Finish;
                end;
        end case;
        return "";
    exception
        when E : PS.File_Open_Error | PS.File_Write_Error | PS.File_Close_Error |
            EPS.File_Open_Error | EPS.File_Write_Error |
            PDF.File_Open_Error | PDF.File_Write_Error |
            SVG.File_Open_Error | SVG.File_Write_Error | FLTK.Unsupported_Error =>
            declare
                Message : constant String := Ada.Exceptions.Exception_Message (E);
            begin
                return (if Message = "" then "It wasn't written." else Message);
            end;
    end Write;


    type Save_Button is new FLTK.Widgets.Buttons.Button with record
        Format : Format_Kind;
    end record;

    procedure Save_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Format  : constant Format_Kind := Save_Button (Item).Format;
        Chooser : NFC.Native_File_Chooser := NFC.Forge.Create (NFC.Browse_Save_File);
    begin
        Chooser.Set_Options (NFC.Saveas_Confirm + NFC.Use_Filter_Ext);
        case Format is
            when Postscript_Format =>
                Chooser.Set_Title ("Save as PostScript");
                Chooser.Set_Filter ("*.ps");
            when EPS_Format =>
                Chooser.Set_Title ("Save as EPS");
                Chooser.Set_Filter ("*.eps");
            when PDF_Format =>
                Chooser.Set_Title ("Save as PDF");
                Chooser.Set_Filter ("*.pdf");
            when SVG_Format =>
                Chooser.Set_Title ("Save as SVG");
                Chooser.Set_Filter ("*.svg");
        end case;
        if Chooser.Show = NFC.Picked then
            declare
                Message : constant String := Write (Format, Chooser.Get_Filename);
            begin
                if Message /= "" then
                    FLTK.Asks.Alert (Message);
                end if;
            end;
        end if;
    end Save_Callback;


    The_Window : FLTK.Widgets.Groups.Windows.Double.Double_Window :=
        FLTK.Widgets.Groups.Windows.Double.Forge.Create (Width + 20, Height + 60, "SaveAs");

    The_Picture : Picture :=
       (FLTK.Widgets.Forge.Create (The_Window, 10, 10, Width, Height)
        with null record);

    function Save
           (X      : in Integer;
            Format : in Format_Kind;
            Label  : in String)
        return Save_Button is
    begin
        return Result : Save_Button :=
           (FLTK.Widgets.Buttons.Forge.Create (The_Window, X, Height + 20, 90, 30, Label)
            with Format => Format)
        do
            Result.Set_Callback (Save_Callback'Unrestricted_Access);
        end return;
    end Save;

    Postscript_Button : Save_Button := Save (10, Postscript_Format, "PostScript");
    EPS_Button        : Save_Button := Save (113, EPS_Format, "EPS");
    PDF_Button        : Save_Button := Save (217, PDF_Format, "PDF");
    SVG_Button        : Save_Button := Save (320, SVG_Format, "SVG");

    pragma Unreferenced (The_Picture, Postscript_Button, EPS_Button, PDF_Button, SVG_Button);


begin


    The_Window.End_Current;

    if ACom.Argument_Count = 2 then
        declare
            Format  : constant Format_Kind :=
                (if ACom.Argument (1) = "ps" then Postscript_Format
                 elsif ACom.Argument (1) = "eps" then EPS_Format
                 elsif ACom.Argument (1) = "pdf" then PDF_Format
                 else SVG_Format);
            Message : constant String := Write (Format, ACom.Argument (2));
        begin
            if Message /= "" then
                Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, Message);
                return 1;
            end if;
            return 0;
        end;
    end if;

    The_Window.Show_With_Args;

    return FLTK.Run;


end SaveAs;
