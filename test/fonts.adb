--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/fonts.cxx: every font Setup_Fonts finds, with the sizes it
--  has, and a sample text in the chosen one.  In the font list, a bold or
--  italic font is shown so.  In the size list, the sizes the font has are
--  bold; a scalable font lists 1 to 63 as well.  F1 opens an editor for
--  the strokes of a vector font, which Save writes out as a C table.
--
--  FLTK's port asks every font's sizes when it starts.  This one, like
--  pofltk's, asks a font's sizes when the font is chosen, which lists the
--  same sizes.  The editor is made at the start, not on the first F1, and
--  only shown on F1.


with

    Ada.Containers.Vectors,
    Ada.Strings.Fixed,
    Ada.Strings.UTF_Encoding.Wide_Wide_Strings,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.Asks,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Tiled,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment,
    FLTK.Event_Kind,
    FLTK.Font_Size,
    FLTK.Keypress,
    FLTK.Modifier;


function Fonts
    return Integer
is


    package Drw renames FLTK.Draw;
    package Sta renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Hld renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Til renames FLTK.Widgets.Groups.Tiled;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;




    --  The Sample Text  --

    --  "Hello, world!", the printable ASCII characters, and every ninth
    --  character from U+00A1 to U+05FF, 32 to a line.
    function Make_Sample
        return String
    is
        use Ada.Strings.UTF_Encoding.Wide_Wide_Strings;
        Result : String (1 .. 16#1000#);
        Last   : Natural := 0;
        N      : Natural := 0;
        Code   : Natural;
        procedure Put
               (Text : in String) is
        begin
            Result (Last + 1 .. Last + Text'Length) := Text;
            Last := Last + Text'Length;
        end Put;
    begin
        Put ("Hello, world!" & ASCII.LF);
        for C in Character'Pos (' ') + 1 .. 126 loop
            if C mod 16#20# = 0 then
                Put ((1 => ASCII.LF));
            end if;
            if C = Character'Pos ('@') then
                Put ("@");
            end if;
            Put ((1 => Character'Val (C)));
        end loop;
        Put ((1 => ASCII.LF));
        Code := 16#A1#;
        while Code < 16#600# loop
            N := N + 1;
            if N mod 16#20# = 0 then
                Put ((1 => ASCII.LF));
            end if;
            Put (Encode ((1 => Wide_Wide_Character'Val (Code))));
            Code := Code + 9;
        end loop;
        return Result (1 .. Last);
    end Make_Sample;




    --  The Main Window  --

    type Font_Display is new Bx.Box with record
        Font : FLTK.Font_Kind := FLTK.Helvetica;
        Size : FLTK.Font_Size := 14;
    end record;

    overriding procedure Draw
           (This : in out Font_Display);

    procedure Draw
           (This : in out Font_Display) is
    begin
        This.Draw_Box;
        Drw.Set_Font (This.Font, This.Size);
        Drw.Set_Color (FLTK.Black_Color);
        Drw.Draw_Text (This.Get_X + 3, This.Get_Y + 3, This.Get_W - 6, This.Get_H - 6,
            This.Get_Label, This.Get_Alignment);
    end Draw;


    type Main_Window is new Dbl.Double_Window with null record;

    overriding function Handle
           (This  : in out Main_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    Form : Main_Window := (Dbl.Forge.Create (550, 370) with null record);

    Tile : Til.Tiled_Group := Til.Forge.Create (Form, 0, 0, 550, 370);

    Text_Group : Grp.Group := Grp.Forge.Create (Tile, 0, 0, 550, 185);

    Text_Obj : Font_Display :=
       (Bx.Forge.Create (Text_Group, FLTK.Engraved_Box, 10, 10, 530, 170, Make_Sample)
        with Font => FLTK.Helvetica, Size => 14);

    Font_Group : Grp.Group := Grp.Forge.Create (Tile, 0, 185, 550, 185);

    Font_Obj : Hld.Hold_Browser := Hld.Forge.Create (Font_Group, 10, 190, 390, 170);
    Size_Obj : Hld.Hold_Browser := Hld.Forge.Create (Font_Group, 410, 190, 130, 170);

    Picked_Size : FLTK.Font_Size := 14;


    procedure Font_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Line : constant Natural := Font_Obj.Selected_Index;
    begin
        if Line = 0 then
            return;
        end if;
        Text_Obj.Font := FLTK.Font_Kind (Line - 1);
        Size_Obj.Clear;
        declare
            Sizes : constant FLTK.Font_Size_Array := Sta.Font_Sizes (Text_Obj.Font);
            function Image
                   (Size : in FLTK.Font_Size)
                return String is (Ada.Strings.Fixed.Trim (FLTK.Font_Size'Image (Size),
                                                          Ada.Strings.Left));
        begin
            if Sizes'Length = 0 then
                null;
            elsif Sizes (Sizes'First) = 0 then
                --  Scalable: any size, and in bold those it lists.
                declare
                    J    : Positive := Sizes'First + 1;
                    Size : FLTK.Font_Size := 1;
                begin
                    while Size < 64 or else Size < Sizes (Sizes'Last) loop
                        if J <= Sizes'Last and then Size = Sizes (J) then
                            Size_Obj.Add ("@b" & Image (Size));
                            J := J + 1;
                        else
                            Size_Obj.Add (Image (Size));
                        end if;
                        Size := Size + 1;
                    end loop;
                end;
                if Natural (Picked_Size) in 1 .. Size_Obj.Number_Of_Lines then
                    Size_Obj.Set_Select (Positive (Picked_Size));
                end if;
            else
                declare
                    Picked : Positive := 1;
                begin
                    for I in Sizes'Range loop
                        if Sizes (I) <= Picked_Size then
                            Picked := I - Sizes'First + 1;
                        end if;
                        Size_Obj.Add ("@b" & Image (Sizes (I)));
                    end loop;
                    Size_Obj.Set_Select (Picked);
                end;
            end if;
        end;
        Text_Obj.Redraw;
    end Font_CB;


    procedure Size_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Line : constant Natural := Size_Obj.Selected_Index;
    begin
        if Line = 0 then
            return;
        end if;
        declare
            Text  : constant String := Size_Obj.Get_Line_Text (Line);
            First : Positive := Text'First;
            Last  : Natural;
        begin
            while Text (First) not in '0' .. '9' loop
                First := First + 1;
            end loop;
            Last := First;
            while Last < Text'Last and then Text (Last + 1) in '0' .. '9' loop
                Last := Last + 1;
            end loop;
            Picked_Size := FLTK.Font_Size'Value (Text (First .. Last));
        end;
        Text_Obj.Size := Picked_Size;
        Text_Obj.Redraw;
    end Size_CB;


    --  "@." keeps a name's own "@" from being taken as formatting; some
    --  fonts have one.
    procedure List_Fonts is
        Count : Natural;
    begin
        Sta.Setup_Fonts (Count);
        for I in 0 .. Count - 1 loop
            declare
                Font  : constant FLTK.Font_Kind := FLTK.Font_Kind (I);
                Name  : constant String := Sta.Font_Family_Image (Font);
                Attrs : constant Sta.Font_Attributes := Sta.Font_Family_Attributes (Font);
            begin
                if Attrs.Bold or Attrs.Italic then
                    Font_Obj.Add ((if Attrs.Bold then "@b" else "")
                        & (if Attrs.Italic then "@i" else "") & "@." & Name);
                else
                    Font_Obj.Add (Name);
                end if;
            end;
        end loop;
        Font_Obj.Set_Select (Positive'(1));
        Font_CB (Font_Obj);
    end List_Fonts;




    --  The Vector Font Editor  --

    --  A stroke command is one of the 8 by 8 points, numbered 8 * column +
    --  row, or a gap, which ends a line.
    subtype Command is Natural range 0 .. 64;
    subtype Point is Command range 0 .. 63;
    Gap : constant Command := 64;

    package Command_Lists is new Ada.Containers.Vectors (Positive, Command);

    Strokes : array (Character) of Command_Lists.Vector;

    Current_Char : Character := 'A';


    type Letter_Box is new Grp.Group with null record;

    overriding procedure Draw
           (This : in out Letter_Box);

    procedure Draw
           (This : in out Letter_Box)
    is
        Rendering : Boolean := False;
    begin
        This.Draw_Box;
        Drw.Push_Clip (This.Get_X, This.Get_Y, This.Get_W, This.Get_H);
        This.Draw_Label (This.Get_X, This.Get_Y - 5, This.Get_W, This.Get_H - 16,
            FLTK.Align_Center);

        Drw.Set_Color (FLTK.Blue_Color);
        Drw.Set_Line_Style (Drw.Solid_Line, Drw.Round_Cap, Drw.Round_Join, 10);
        for Cmd of Strokes (Current_Char) loop
            if Cmd = Gap then
                if Rendering then
                    Drw.End_Line;
                    Rendering := False;
                end if;
            else
                if not Rendering then
                    Drw.Begin_Line;
                    Rendering := True;
                end if;
                Drw.Vertex (Long_Float (Cmd / 8 * 16 + 8 + 10),
                            Long_Float (Cmd mod 8 * 32 + 16 + 10));
            end if;
        end loop;
        if Rendering then
            Drw.End_Line;
        end if;
        Drw.Set_Line_Style (Drw.Solid_Line, Width => 1);

        This.Draw_Children;
        Drw.Pop_Clip;
    end Draw;


    type Dot is new Btn.Button with record
        Where : Point;
    end record;

    type Dot_Access is access Dot;

    procedure Free is new Ada.Unchecked_Deallocation (Dot, Dot_Access);


    Editor : Dbl.Double_Window := Dbl.Forge.Create (400, 400);

    Letter : Letter_Box := (Grp.Forge.Create (Editor, 10, 10, 128, 256, "A") with null record);

    --  Made when the program starts, and freed when it ends.
    Dots : array (Point) of Dot_Access;

    Gap_Button   : Btn.Button := Btn.Forge.Create (Editor, 10, 290, 70, 20, "Gap");
    Clear_Button : Btn.Button := Btn.Forge.Create (Editor, 90, 290, 70, 20, "Clear");
    Prev_Button  : Btn.Button := Btn.Forge.Create (Editor, 10, 315, 70, 20, "<-");
    Next_Button  : Btn.Button := Btn.Forge.Create (Editor, 90, 315, 70, 20, "->");
    Back_Button  : Btn.Button := Btn.Forge.Create (Editor, 10, 340, 70, 20, "Back");
    Save_Button  : Btn.Button := Btn.Forge.Create (Editor, 90, 340, 70, 20, "Save");


    procedure Add_Point_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        --  The saved table is a C string per letter, in which the top left
        --  dot, 0, would end the string.  fonts.cxx can't record that dot
        --  either: its 0 ends its table (FLTK-issues.md F30).  So it's left
        --  out here too.
        if Dot (Item).Where /= 0 then
            Strokes (Current_Char).Append (Dot (Item).Where);
        end if;
        Letter.Redraw;
    end Add_Point_CB;

    procedure Add_Gap_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Strokes (Current_Char).Append (Gap);
        Letter.Redraw;
    end Add_Gap_CB;

    procedure Clear_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Strokes (Current_Char).Clear;
        Letter.Redraw;
    end Clear_CB;

    procedure Show_Char is
    begin
        Letter.Set_Label ((1 => Current_Char));
        Letter.Redraw;
    end Show_Char;

    procedure Prev_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Current_Char := Character'Val ((Character'Pos (Current_Char) - 1) mod 256);
        Show_Char;
    end Prev_CB;

    procedure Next_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Current_Char := Character'Val ((Character'Pos (Current_Char) + 1) mod 256);
        Show_Char;
    end Next_CB;

    procedure Back_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if not Strokes (Current_Char).Is_Empty then
            Strokes (Current_Char).Delete_Last;
            Letter.Redraw;
        end if;
    end Back_CB;


    --  N in Base, with at least two digits, as C's %02o and %02X.
    function Digits_Of
           (N, Base : in Natural)
        return String
    is
        Hex : constant String := "0123456789ABCDEF";
    begin
        if N < Base * Base then
            return (Hex (N / Base + 1), Hex (N mod Base + 1));
        else
            return Digits_Of (N / Base, Base) & Hex (N mod Base + 1);
        end if;
    end Digits_Of;

    procedure Save_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        use Ada.Text_IO;
        Name : constant String := FLTK.Asks.File_Chooser ("Save font as:", "", "");
        File : File_Type;
    begin
        if Name = "" then
            return;
        end if;
        begin
            Create (File, Out_File, Name);
        exception
        when Name_Error | Use_Error =>
            FLTK.Asks.Alert ("can't open file for writing");
            return;
        end;
        New_Line (File);
        Put (File, "static const char *font_data[128] = {" & ASCII.LF & "  ");
        for C in Character'Val (0) .. Character'Val (127) loop
            if C in ' ' .. '~' then
                Put (File, "/*" & C & "*/");
            else
                Put (File, "/*" & Digits_Of (Character'Pos (C), 16) & "*/");
            end if;
            if Strokes (C).Is_Empty then
                Put (File, "0");
            else
                Put (File, '"');
                for Cmd of Strokes (C) loop
                    Put (File, "\" & Digits_Of (Cmd, 8));
                end loop;
                Put (File, '"');
            end if;
            if C < Character'Val (127) then
                Put (File, ", ");
            end if;
            if Character'Pos (C) mod 4 = 3 then
                Put (File, ASCII.LF & "  ");
            end if;
        end loop;
        Put_Line (File, "};");
        New_Line (File);
        Close (File);
    end Save_CB;


    function Handle
           (This  : in out Main_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        if Event = FLTK.Keydown and then FLTK.Events.Last_Key = FLTK.Function_Key (1) then
            Editor.Show;
            return FLTK.Handled;
        end if;
        return Dbl.Double_Window (This).Handle (Event);
    end Handle;


begin


    Sta.Parse_Args;
    Sta.System_Colors;
    Sta.Set_Scheme (Sta.Get_Scheme);

    Text_Group.Set_Box (FLTK.Flat_Box);
    Text_Obj.Set_Alignment
       (FLTK.Align_Top + FLTK.Align_Left + FLTK.Align_Inside + FLTK.Align_Clip);
    Text_Obj.Set_Background_Color (9);
    Text_Obj.Set_Selection_Color (47);
    Text_Group.Set_Resizable (Text_Obj);

    Font_Group.Set_Box (FLTK.Flat_Box);
    --  FL_FRAME_BOX is FL_ENGRAVED_BOX.
    Font_Obj.Set_Box (FLTK.Engraved_Box);
    Font_Obj.Set_Background_Color (53);
    Font_Obj.Set_Selection_Color (3);
    Size_Obj.Set_Box (FLTK.Engraved_Box);
    Size_Obj.Set_Background_Color (53);
    Size_Obj.Set_Selection_Color (3);
    Font_Obj.Set_Callback (Font_CB'Unrestricted_Access);
    Size_Obj.Set_Callback (Size_CB'Unrestricted_Access);
    Font_Group.Set_Resizable (Font_Obj);

    Form.Set_Resizable (Tile);

    Letter.Set_Alignment (FLTK.Align_Center);
    Letter.Set_Label_Size (200);
    Letter.Set_Label_Color (FLTK.Dark3_Color);
    Letter.Set_Box (FLTK.Down_Box);
    for I in 0 .. 7 loop
        for J in 0 .. 7 loop
            Dots (I * 8 + J) := new Dot'
               (Btn.Forge.Create (Letter, I * 16 + 8 - 5 + 10, J * 32 + 16 - 5 + 10, 10, 10)
                with Where => I * 8 + J);
            Dots (I * 8 + J).Set_Box (FLTK.Oval_Box);
            Dots (I * 8 + J).Set_Callback (Add_Point_CB'Unrestricted_Access);
        end loop;
    end loop;
    Gap_Button.Set_Callback (Add_Gap_CB'Unrestricted_Access);
    Clear_Button.Set_Callback (Clear_CB'Unrestricted_Access);
    Prev_Button.Set_Callback (Prev_CB'Unrestricted_Access);
    Prev_Button.Set_Shortcut (FLTK.Press (FLTK.Left_Key));
    Next_Button.Set_Callback (Next_CB'Unrestricted_Access);
    Next_Button.Set_Shortcut (FLTK.Press (FLTK.Right_Key));
    Back_Button.Set_Callback (Back_CB'Unrestricted_Access);
    Save_Button.Set_Callback (Save_CB'Unrestricted_Access);
    Save_Button.Set_Shortcut (FLTK.Mod_Command + 's');

    List_Fonts;

    Form.Show_With_Args;
    return Result : constant Integer := FLTK.Run do
        for Item of Dots loop
            Free (Item);
        end loop;
    end return;


end Fonts;
