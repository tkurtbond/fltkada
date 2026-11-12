--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/colbrowser.cxx: a hold browser of the colours in an X11
--  rgb.txt (by default ./rgb.txt; test/rgb.txt is one), and red, green
--  and blue sliders that find the nearest colour in it.  Guided by
--  pofltk's ColBrowser.Mod.
--
--  Where FLTK's program would read past the end of its table (no file
--  loaded, or a file loaded more than once, which adds to the browser
--  without clearing it) this one stops at the end.  It keeps an entry on
--  the last line of a file with no newline at the end, which FLTK's
--  drops.


with

    Ada.Command_Line,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Valuators.Sliders.Value;

use type

    FLTK.Color;


function ColBrowser
    return Integer
is

    package UStr renames Ada.Strings.Unbounded;
    package Bx   renames FLTK.Widgets.Boxes;
    package Btn  renames FLTK.Widgets.Buttons;
    package Hld  renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Dbl  renames FLTK.Widgets.Groups.Windows.Double;
    package Sld  renames FLTK.Widgets.Valuators.Sliders;
    package VS   renames FLTK.Widgets.Valuators.Sliders.Value;

    Max_RGB    : constant := 3000;
    Free_Col4  : constant FLTK.Color := FLTK.Free_Color + 3;
    Indian_Red : constant FLTK.Color := 164;

    type RGB is record
        R, G, B : Integer := 0;
    end record;

    --  The last entry read is followed by one whose R is 1000.
    RGB_DB : array (0 .. Max_RGB - 1) of RGB;

    --  As in FLTK's program, main's dbname hides this one, which the
    --  database button offers and sets, so its first dialog starts empty.
    DB_Name : UStr.Unbounded_String;

    CL     : Dbl.Double_Window := Dbl.Forge.Create (400, 385);
    Title  : Bx.Box := Bx.Forge.Create (CL, 40, 10, 300, 30, "Color Browser");
    DB_Obj : Btn.Button := Btn.Forge.Create (CL, 40, 50, 300, 25, "");
    ColBr  : Hld.Hold_Browser := Hld.Forge.Create (CL, 10, 90, 280, 240, "");
    ResCol : Bx.Box := Bx.Forge.Create (CL, 300, 90, 90, 35, "");
    RS     : VS.Value_Slider := VS.Forge.Create (CL, 300, 130, 30, 200, "");
    GS     : VS.Value_Slider := VS.Forge.Create (CL, 330, 130, 30, 200, "");
    BS     : VS.Value_Slider := VS.Forge.Create (CL, 360, 130, 30, 200, "");
    Done   : Btn.Button := Btn.Forge.Create (CL, 160, 345, 80, 30, "Done");


    procedure Set_Entry
           (I : in Natural)
    is
        DB : RGB renames RGB_DB (I);
    begin
        FLTK.Static.Set_Color
           (Free_Col4,
            FLTK.Color_Component (DB.R),
            FLTK.Color_Component (DB.G),
            FLTK.Color_Component (DB.B));
        RS.Set_Value (Long_Float (DB.R));
        GS.Set_Value (Long_Float (DB.G));
        BS.Set_Value (Long_Float (DB.B));
        ResCol.Redraw;
    end Set_Entry;


    procedure Br_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        R : constant Natural := ColBr.Selected_Index;
    begin
        if R = 0 or R > Max_RGB then
            return;
        end if;
        Set_Entry (R - 1);
    end Br_CB;


    --  FLTK's read_entry: skips a line that begins with "!", reads
    --  " %d %d %d %n", and keeps the rest without its spaces as the name.
    procedure Read_Entry
           (File    : in out Ada.Text_IO.File_Type;
            R, G, B :    out Integer;
            Name    :    out UStr.Unbounded_String;
            OK      :    out Boolean)
    is
        Line : UStr.Unbounded_String;
        P    : Positive := 1;

        function Is_Space
               (C : in Character)
            return Boolean
        is (C in ' ' | ASCII.HT | ASCII.LF | ASCII.VT | ASCII.FF | ASCII.CR);

        procedure Skip_Spaces is
        begin
            while P <= UStr.Length (Line) and then Is_Space (UStr.Element (Line, P)) loop
                P := P + 1;
            end loop;
        end Skip_Spaces;

        procedure Number
               (Value : out Integer;
                Found : out Boolean)
        is
            Negative : Boolean := False;
            Start    : Positive;
        begin
            Value := 0;
            Skip_Spaces;
            if P <= UStr.Length (Line) and then UStr.Element (Line, P) in '+' | '-' then
                Negative := UStr.Element (Line, P) = '-';
                P := P + 1;
            end if;
            Start := P;
            while P <= UStr.Length (Line) and then UStr.Element (Line, P) in '0' .. '9' loop
                Value := Value * 10 +
                    (Character'Pos (UStr.Element (Line, P)) - Character'Pos ('0'));
                P := P + 1;
            end loop;
            Found := P > Start;
            if Negative then
                Value := -Value;
            end if;
        end Number;

        Found : Boolean;

    begin
        R := 0;
        G := 0;
        B := 0;
        Name := UStr.Null_Unbounded_String;
        OK := False;

        if Ada.Text_IO.End_Of_File (File) then
            return;
        end if;
        Line := UStr.To_Unbounded_String (Ada.Text_IO.Get_Line (File));
        if UStr.Length (Line) > 0 and then UStr.Element (Line, 1) = '!' then
            if Ada.Text_IO.End_Of_File (File) then
                return;
            end if;
            Line := UStr.To_Unbounded_String (Ada.Text_IO.Get_Line (File));
        end if;

        Number (R, Found);
        if not Found then
            return;
        end if;
        Number (G, Found);
        if not Found then
            return;
        end if;
        Number (B, Found);
        if not Found then
            return;
        end if;
        Skip_Spaces;

        for I in P .. UStr.Length (Line) loop
            if UStr.Element (Line, I) /= ' ' then
                UStr.Append (Name, UStr.Element (Line, I));
            end if;
        end loop;
        OK := True;
    end Read_Entry;


    --  printf's %3d.
    function D3
           (Value : in Integer)
        return String
    is
        Image : constant String := Integer'Image (Value);
        Text  : constant String :=
            (if Value < 0 then Image else Image (Image'First + 1 .. Image'Last));
    begin
        return (if Text'Length < 3 then (1 .. 3 - Text'Length => ' ') & Text else Text);
    end D3;


    function Load_Browser
           (File_Name : in String)
        return Boolean
    is
        File       : Ada.Text_IO.File_Type;
        DB         : Natural := 0;
        R, G, B    : Integer;
        LR, LG, LB : Integer := -1;
        Name       : UStr.Unbounded_String;
        OK         : Boolean;
    begin
        begin
            Ada.Text_IO.Open (File, Ada.Text_IO.In_File, File_Name);
        exception
        when Ada.Text_IO.Name_Error | Ada.Text_IO.Use_Error =>
            FLTK.Asks.Alert ("Load:" & ASCII.LF & "Can't open '" & File_Name & "'");
            return False;
        end;

        while DB < Max_RGB loop
            Read_Entry (File, R, G, B, Name, OK);
            exit when not OK;
            RGB_DB (DB) := (R, G, B);

            --  unique the entries on the fly
            if LR /= R or LG /= G or LB /= B then
                DB := DB + 1;
                LR := R;
                LG := G;
                LB := B;
                ColBr.Add ("(" & D3 (R) & " " & D3 (G) & " " & D3 (B) & ") " &
                    UStr.To_String (Name));
            end if;
        end loop;
        Ada.Text_IO.Close (File);

        if DB < Max_RGB then
            RGB_DB (DB).R := 1000;  --  sentinel
        else
            RGB_DB (DB - 1).R := 1000;
        end if;

        ColBr.Set_Top_Line (1);
        ColBr.Set_Select (Line => 1, State => True);
        Set_Entry (0);

        return True;
    end Load_Browser;


    function Search_Entry
           (R, G, B : in Integer)
        return Natural
    is
        Diff     : Long_Long_Integer;
        Min_Diff : Long_Long_Integer := Long_Long_Integer'Last;
        J        : Natural := 0;
    begin
        for I in RGB_DB'Range loop
            exit when RGB_DB (I).R >= 256;
            declare
                Diff_R : constant Integer := R - RGB_DB (I).R;
                Diff_G : constant Integer := G - RGB_DB (I).G;
                Diff_B : constant Integer := B - RGB_DB (I).B;
            begin
                Diff := Long_Long_Integer (Long_Float'Truncation
                   (3.0 * Long_Float (Diff_R * Diff_R) +
                    5.9 * Long_Float (Diff_G * Diff_G) +
                    1.1 * Long_Float (Diff_B * Diff_B)));
            end;
            if Min_Diff > Diff then
                Min_Diff := Diff;
                J := I;
            end if;
        end loop;
        return J;
    end Search_Entry;


    procedure Search_RGB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        Top     : constant Integer := ColBr.Get_Top_Line;
        R, G, B : Integer;
        I       : Natural;
    begin
        R := Integer (Long_Float'Truncation (RS.Get_Value));
        G := Integer (Long_Float'Truncation (GS.Get_Value));
        B := Integer (Long_Float'Truncation (BS.Get_Value));

        FLTK.Static.Set_Color
           (Free_Col4,
            FLTK.Color_Component (R),
            FLTK.Color_Component (G),
            FLTK.Color_Component (B));
        ResCol.Redraw;
        I := Search_Entry (R, G, B);
        --  change topline only if necessary; FLTK's topline keeps the line
        --  in range
        if I < Top or I > Top + 15 then
            ColBr.Set_Top_Line
               (Integer'Max (1, Integer'Min (I - 8, ColBr.Number_Of_Lines)));
        end if;
        if I + 1 <= ColBr.Number_Of_Lines then
            ColBr.Set_Select (Line => I + 1, State => True);
        end if;
    end Search_RGB;


    --  change database
    procedure DB_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Answer : UStr.Unbounded_String := DB_Name;
        use type FLTK.Asks.Confirm_Result;
        use type UStr.Unbounded_String;
    begin
        if FLTK.Asks.Text_Input ("Enter New Database Name", Answer) /= FLTK.Asks.Confirm
            or else Answer = DB_Name
        then
            return;
        end if;

        if Load_Browser (UStr.To_String (Answer)) then
            DB_Name := Answer;
        else
            Item.Set_Label (UStr.To_String (DB_Name));
        end if;
    end DB_CB;


    procedure Done_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        CL.Hide;
    end Done_CB;


    procedure Slider
           (This : in out VS.Value_Slider;
            Hue  : in     FLTK.Color) is
    begin
        Sld.Extra.Set_Kind (Sld.Slider (This), Sld.Vertical_Fill_Slider);
        This.Set_Background_Color (Indian_Red);
        This.Set_Selection_Color (Hue);
        This.Set_Bounds (0.0, 255.0);
        This.Set_Precision (0);
        This.Set_Callback (Search_RGB'Unrestricted_Access);
        This.Set_When (FLTK.When_Release);
    end Slider;


    Count : Natural;

begin

    FLTK.Static.Parse_Args (Count);

    CL.Set_Box (FLTK.Up_Box);
    CL.Set_Background_Color (Indian_Red);
    CL.Set_Selection_Color (FLTK.Background_Color);

    Title.Set_Box (FLTK.No_Box);
    Title.Set_Label_Color (FLTK.Red_Color);
    Title.Set_Label_Size (32);
    Title.Set_Label_Font (FLTK.Helvetica_Bold);
    Title.Set_Label_Kind (FLTK.Shadow_Label);

    DB_Obj.Set_Box (FLTK.Border_Box);
    DB_Obj.Set_Background_Color (Indian_Red);
    DB_Obj.Set_Selection_Color (Indian_Red);
    DB_Obj.Set_Callback (DB_CB'Unrestricted_Access);

    ColBr.Set_Text_Font (FLTK.Courier);
    ColBr.Set_Callback (Br_CB'Unrestricted_Access);
    ColBr.Set_Box (FLTK.Down_Box);

    ResCol.Set_Background_Color (Free_Col4);
    ResCol.Set_Selection_Color (Free_Col4);
    ResCol.Set_Box (FLTK.Border_Box);

    Slider (RS, FLTK.Red_Color);
    Slider (GS, FLTK.Green_Color);
    Slider (BS, FLTK.Blue_Color);

    Done.Set_Callback (Done_CB'Unrestricted_Access);

    CL.End_Current;
    CL.Set_Resizable (CL);

    declare
        File_Name : constant String :=
           (if Count < Ada.Command_Line.Argument_Count
            then Ada.Command_Line.Argument (Count + 1)
            else "rgb.txt");
    begin
        if Load_Browser (File_Name) then
            DB_Obj.Set_Label (File_Name);
        else
            DB_Obj.Set_Label ("None");
        end if;
    end;
    DB_Obj.Redraw;

    CL.Set_Size_Range (CL.Get_W, CL.Get_H, 2 * CL.Get_W, 2 * CL.Get_H);

    CL.Set_Label ("RGB Browser");
    CL.Free_Position;
    CL.Show_With_Args;

    return FLTK.Run;

end ColBrowser;
