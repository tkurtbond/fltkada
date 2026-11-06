
--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/utf8.cxx: Unicode text in inputs and outputs, and a font
--  chooser.  The main window has, on the left, a UTF-8 string, its lower
--  and upper case, combining and right-to-left text, an input that shows
--  its own bytes in the input under it, a box that shows the code of a
--  character dropped or pasted on it, and Japanese text.  On the right, a
--  scroll lists the characters U+0020 to U+FFFF, sixteen to a row, or,
--  given a number as the argument, the 65536 from there on.
--
--  The font chooser lists the fonts from Free_Font on, with their sizes
--  and a sample.  Select prints the chosen font and size, and makes the
--  font the one the main window's Unicode text uses.
--
--  The C++ asks every font's sizes when it starts; this port, like
--  fonts.adb, asks a font's sizes when the font is chosen.


with

    Ada.Command_Line,
    Ada.Containers.Vectors,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    Interfaces.C.Strings,
    System,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Static,
    FLTK.UTF8,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Groups.Browsers.Textline.Hold,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Widgets.Groups.Tiled,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Outputs,
    FLTK.Widgets.Valuators.Value_Outputs;

use type

    FLTK.Alignment,
    FLTK.Event_Kind,
    FLTK.Font_Kind,
    FLTK.Font_Size,
    Interfaces.C.unsigned_long;


function UTF8
    return Integer
is


    package Drw renames FLTK.Draw;
    package Sta renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Grp renames FLTK.Widgets.Groups;
    package Hld renames FLTK.Widgets.Groups.Browsers.Textline.Hold;
    package Scr renames FLTK.Widgets.Groups.Scrolls;
    package Til renames FLTK.Widgets.Groups.Tiled;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Otp renames FLTK.Widgets.Inputs.Text.Outputs;
    package VO  renames FLTK.Widgets.Valuators.Value_Outputs;




    --  Text  --

    --  fl_utf8encode: a code above U+10FFFF becomes U+FFFD, and anything
    --  else is encoded as it is, the surrogates and U+FFFE too.
    function Encode
           (Code : in Long_Long_Integer)
        return String
    is
        function B
               (Item : in Long_Long_Integer)
            return Character is (Character'Val (Item mod 256));
    begin
        if Code < 16#80# then
            return (1 => B (Code));
        elsif Code < 16#800# then
            return (B (16#C0# + Code / 2**6), B (16#80# + Code mod 2**6));
        elsif Code < 16#1_0000# then
            return (B (16#E0# + Code / 2**12), B (16#80# + Code / 2**6 mod 2**6),
                    B (16#80# + Code mod 2**6));
        elsif Code <= 16#10_FFFF# then
            return (B (16#F0# + Code / 2**18), B (16#80# + Code / 2**12 mod 2**6),
                    B (16#80# + Code / 2**6 mod 2**6), B (16#80# + Code mod 2**6));
        else
            return (B (16#EF#), B (16#BF#), B (16#BD#));
        end if;
    end Encode;


    --  The text of codes, encoded and run together.
    function Encode
           (Codes : in Wide_Wide_String)
        return String is
    begin
        if Codes'Length = 0 then
            return "";
        end if;
        return Encode (Wide_Wide_Character'Pos (Codes (Codes'First)))
            & Encode (Codes (Codes'First + 1 .. Codes'Last));
    end Encode;


    --  C's "%0<Width>X" (or "%0<Width>x" when Lower), for N >= 0.
    function Hex
           (N     : in Long_Long_Integer;
            Width : in Positive;
            Lower : in Boolean := False)
        return String
    is
        All_Digits : constant String :=
            (if Lower then "0123456789abcdef" else "0123456789ABCDEF");
        Digit : constant Character := All_Digits (Integer (N mod 16) + 1);
    begin
        if Width = 1 and then N < 16 then
            return (1 => Digit);
        else
            return Hex (N / 16, Positive'Max (Width - 1, 1), Lower) & Digit;
        end if;
    end Hex;


    --  C's "%d".
    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return (if N < 0 then S else S (S'First + 1 .. S'Last));
    end Image;


    --  "Font Sample", the printable ASCII characters, and every ninth
    --  character from U+00A1 to U+05FF, 32 to a line.
    function Make_Sample
        return String
    is
        Result : String (1 .. 1000);
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
        Put ("Font Sample" & ASCII.LF);
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
            Put (Encode (Long_Long_Integer (Code)));
            Code := Code + 9;
        end loop;
        return Result (1 .. Last);
    end Make_Sample;


    --  The number a size line shows, after its "@b" if it has one.
    function Size_Of
           (Line : in String)
        return FLTK.Font_Size
    is
        First : Positive := Line'First;
        Last  : Natural;
    begin
        while Line (First) not in '0' .. '9' loop
            First := First + 1;
        end loop;
        Last := First;
        while Last < Line'Last and then Line (Last + 1) in '0' .. '9' loop
            Last := Last + 1;
        end loop;
        return FLTK.Font_Size'Value (Line (First .. Last));
    end Size_Of;




    --  The Font Chooser  --

    Default_Size : constant FLTK.Font_Size := 16;

    type Font_Display is new Bx.Box with record
        Font : FLTK.Font_Kind := 0;
        Size : FLTK.Font_Size := Default_Size;
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

    type Pitch is (Proportional, Fixed, Near_Fixed);

    --  Fixed if a line of wide letters is as wide as one of i's, nearly so
    --  if within 5%.
    function Test_Fixed_Pitch
           (This : in Font_Display)
        return Pitch
    is
        W1, W2, H1, H2 : Natural;
    begin
        Drw.Set_Font (This.Font, This.Size);
        Drw.Measure ("MHMHWWMHMHMHM###WWX__--HUW", W1, H1, Symbols => False);
        Drw.Measure ("iiiiiiiiiiiiiiiiiiiiiiiiii", W2, H2, Symbols => False);
        if W1 = W2 then
            return Fixed;
        elsif abs (Long_Float (W1) - Long_Float (W2)) * 5.0 <= Long_Float (W1) then
            return Near_Fixed;
        else
            return Proportional;
        end if;
    end Test_Fixed_Pitch;


    Chooser : Dbl.Double_Window := Dbl.Forge.Create (380, 420, "Font Selector");

    Tile : Til.Tiled_Group := Til.Forge.Create (Chooser, 0, 0, 380, 420);

    Text_Group : Grp.Group := Grp.Forge.Create (Tile, 0, 0, 380, 105);

    --  FL_FRAME_BOX is FL_ENGRAVED_BOX.
    Text_Obj : Font_Display :=
       (Bx.Forge.Create (Text_Group, FLTK.Engraved_Box, 10, 10, 360, 90, Make_Sample)
        with Font => 0, Size => Default_Size);

    Font_Group : Grp.Group := Grp.Forge.Create (Tile, 0, 105, 380, 315);

    Font_Obj : Hld.Hold_Browser := Hld.Forge.Create (Font_Group, 10, 110, 290, 270);
    Size_Obj : Hld.Hold_Browser := Hld.Forge.Create (Font_Group, 310, 110, 60, 270);

    Status_Bar : Grp.Group := Grp.Forge.Create (Font_Group, 10, 385, 380, 30);

    Font_Count_Out : VO.Value_Output := VO.Forge.Create (Status_Bar, 10, 390, 40, 20);
    Fix_Prop       : Otp.Output := Otp.Forge.Create (Status_Bar, 100, 390, 40, 20);
    Own_Face       : Chk.Check_Button := Chk.Forge.Create (Status_Bar, 150, 390, 40, 20, "Self");
    Dummy          : Bx.Box := Bx.Forge.Create (Status_Bar, 220, 390, 1, 1);
    Choose_Button  : Btn.Button := Btn.Forge.Create (Status_Bar, 240, 385, 60, 30, "Select");
    Refresh_Button : Btn.Button := Btn.Forge.Create (Status_Bar, 310, 385, 60, 30, "Refresh");

    Font_Count  : Natural := 0;
    First_Free  : constant FLTK.Font_Kind := FLTK.Free_Font;
    Picked_Size : FLTK.Font_Size := Default_Size;

    Extra_Font : constant FLTK.Font_Kind := FLTK.Times_Bold_Italic;


    --  The font on a line of Font_Obj.  The C++ doesn't check for no line
    --  (its test for 0 adds First_Free first), so with none it takes the
    --  font before First_Free; so does this.
    function Font_On
           (Line : in Natural)
        return FLTK.Font_Kind is (First_Free + FLTK.Font_Kind (Line) - 1);


    procedure Size_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Line : constant Natural := Size_Obj.Selected_Index;
    begin
        if Line = 0 then
            return;
        end if;
        Picked_Size := Size_Of (Size_Obj.Get_Line_Text (Line));
        Text_Obj.Size := Picked_Size;
        Text_Obj.Redraw;
    end Size_CB;


    procedure Font_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Font  : constant FLTK.Font_Kind := Font_On (Font_Obj.Selected_Index);
        Sizes : constant FLTK.Font_Size_Array := Sta.Font_Sizes (Font);
    begin
        Text_Obj.Font := Font;
        Size_Obj.Clear;
        if Sizes'Length = 0 then
            null;
        elsif Sizes (Sizes'First) = 0 then
            --  Scalable: any size, and in bold those it lists.
            declare
                J    : Positive := Sizes'First + 1;
                Size : FLTK.Font_Size := 1;
            begin
                while Size <= 64 or else Size < Sizes (Sizes'Last) loop
                    if J <= Sizes'Last and then Size = Sizes (J) then
                        Size_Obj.Add ("@b" & Image (Integer (Size)));
                        J := J + 1;
                    else
                        Size_Obj.Add (Image (Integer (Size)));
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
                    Size_Obj.Add ("@b" & Image (Integer (Sizes (I))));
                end loop;
                Size_Obj.Set_Select (Picked);
            end;
        end if;
        Size_CB (Size_Obj);

        case Test_Fixed_Pitch (Text_Obj) is
            when Fixed        => Fix_Prop.Set_Value ("fixed");
            when Near_Fixed   => Fix_Prop.Set_Value ("near");
            when Proportional => Fix_Prop.Set_Value ("prop");
        end case;
    end Font_CB;


    Main_Window : Dbl.Double_Window :=
        Dbl.Forge.Create (240 + 10 + 5 * 75, 400, "Unicode Display Test");


    procedure Choose_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        use Ada.Text_IO;
        Font : constant FLTK.Font_Kind := Font_On (Font_Obj.Selected_Index);
        Line : constant Natural := Size_Obj.Selected_Index;
    begin
        Put_Line ("idx " & Image (Integer (Font)));
        Put_Line ("User name :" & Sta.Font_Family_Image (Font) & ":");
        Put_Line ("FLTK name :" & Sta.Font_Image (Font) & ":");
        Sta.Set_Font_Kind (Extra_Font, Font);

        if Line = 0 then
            Put_Line ("No size selected");
        else
            Put_Line ("size " & Image (Integer (Size_Of (Size_Obj.Get_Line_Text (Line)))));
            New_Line;
        end if;

        Flush;
        Main_Window.Redraw;
    end Choose_CB;


    procedure Refresh_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Main_Window.Redraw;
    end Refresh_CB;


    First_Listing : Boolean := True;

    --  Each font's name, in its own face if Self is checked.  "@." keeps
    --  a name's own "@" from being taken as formatting.
    procedure Own_Face_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
        Top : Natural := 1;
    begin
        if not First_Listing then
            Top := Font_Obj.Get_Top_Line;
            Font_Obj.Clear;
            Chooser.Set_Cursor (FLTK.Wait_Mouse);
        end if;

        for I in Natural (First_Free) .. Font_Count - 1 loop
            declare
                Font  : constant FLTK.Font_Kind := FLTK.Font_Kind (I);
                Name  : constant String := Sta.Font_Family_Image (Font);
                Attrs : constant Sta.Font_Attributes := Sta.Font_Family_Attributes (Font);
            begin
                if not Own_Face.Is_On then
                    Font_Obj.Add ((if Attrs.Bold then "@b" else "")
                        & (if Attrs.Italic then "@i" else "") & "@." & Name);
                else
                    Font_Obj.Add ("@F" & Image (I) & "@." & Name);
                end if;
            end;
        end loop;

        if Top > 0 and then Font_Obj.Number_Of_Lines > 0 then
            Font_Obj.Set_Top_Line (Top);
        end if;
        if not First_Listing then
            Chooser.Set_Cursor (FLTK.Default_Mouse);
        end if;
        First_Listing := False;
    end Own_Face_CB;


    procedure Exit_CB
           (Item : in out Wdg.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Chooser.Hide;
        Main_Window.Hide;
    end Exit_CB;


    procedure Make_Font_Chooser is
    begin
        Text_Obj.Set_Alignment
           (FLTK.Align_Top + FLTK.Align_Left + FLTK.Align_Inside + FLTK.Align_Clip);
        Text_Obj.Set_Background_Color (53);
        Text_Obj.Set_Selection_Color (3);
        Text_Group.Set_Box (FLTK.Flat_Box);
        Text_Group.Set_Resizable (Text_Obj);

        Font_Obj.Set_Box (FLTK.Engraved_Box);
        Font_Obj.Set_Background_Color (53);
        Font_Obj.Set_Selection_Color (3);
        Font_Obj.Set_Callback (Font_CB'Unrestricted_Access);
        Chooser.Set_Resizable (Font_Obj);

        Size_Obj.Set_Box (FLTK.Engraved_Box);
        Size_Obj.Set_Background_Color (53);
        Size_Obj.Set_Selection_Color (3);
        Size_Obj.Set_Callback (Size_CB'Unrestricted_Access);

        Font_Count_Out.Set_Label ("fonts");
        Font_Count_Out.Set_Alignment (FLTK.Align_Right);

        Fix_Prop.Set_Background_Color (FLTK.Background_Color);
        Fix_Prop.Set_Value ("prop");
        Fix_Prop.Clear_Visible_Focus;

        --  A check button is a toggle button already.
        Own_Face.Set_State (Btn.Off);
        Own_Face.Clear_Visible_Focus;
        Own_Face.Set_Callback (Own_Face_CB'Unrestricted_Access);
        Own_Face.Set_Tooltip ("Display font names in their own face");

        Choose_Button.Set_Callback (Choose_CB'Unrestricted_Access);
        Refresh_Button.Set_Callback (Refresh_CB'Unrestricted_Access);

        Status_Bar.Set_Resizable (Dummy);

        Font_Group.Set_Box (FLTK.Flat_Box);
        Font_Group.Set_Resizable (Font_Obj);

        Chooser.Set_Resizable (Tile);
        Chooser.Set_Callback (Exit_CB'Unrestricted_Access);

        Sta.Setup_Fonts (Font_Count);

        Own_Face_CB (Own_Face);
        Font_Obj.Set_Select (Positive'(1));
        Font_CB (Font_Obj);
        Font_Count_Out.Set_Value (Long_Float (Font_Count));
    end Make_Font_Chooser;




    --  The Main Window's Widgets  --

    --  Text drawn from the right, by fl_rtl_draw.  It can't be edited
    --  where it shows, since the cursor and selection aren't drawn.  The
    --  C++ draws nothing for a hidden input, which FLTKAda's Input_Kind
    --  has no name for; these inputs aren't hidden.
    type Right_Left_Input is new Inp.Text_Input with null record;

    overriding procedure Draw
           (This : in out Right_Left_Input);

    procedure Draw
           (This : in out Right_Left_Input)
    is
        Kind : constant FLTK.Box_Kind := This.Get_Box;
        X    : constant Integer := This.Get_X + Sta.Get_Box_X_Offset (Kind) + 3;
        Y    : constant Integer := This.Get_Y + Sta.Get_Box_Y_Offset (Kind);
        W    : constant Integer := This.Get_W - Sta.Get_Box_Width_Offset (Kind) - 6;
    begin
        if This.Get_Damage.Full then
            This.Draw_Box (Kind, This.Get_Background_Color);
        end if;
        Drw.Set_Color (This.Get_Text_Color);
        Drw.Set_Font (This.Get_Text_Font, This.Get_Text_Size);
        Drw.Draw_Text_Right_Left
           (X + W,
            Y + Drw.Font_Height (This.Get_Text_Font, This.Get_Text_Size) - Drw.Font_Descent,
            This.Get_Value);
    end Draw;


    --  Shows the first character dropped or pasted on it: the character,
    --  its bytes, and its code.
    type UChar_Drop_Box is new Otp.Output with null record;

    overriding function Handle
           (This  : in out UChar_Drop_Box;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    --  fl_utf8decode's length for the character Text starts with: 1 for
    --  an encoding that isn't valid, or one that runs past the end.
    function Char_Length
           (Text : in String)
        return Positive
    is
        function Byte_At
               (Offset : in Natural)
            return Natural is
               (if Text'First + Offset <= Text'Last
                then Character'Pos (Text (Text'First + Offset)) else 0);
        function Follows
               (Offset : in Natural)
            return Boolean is (Byte_At (Offset) in 16#80# .. 16#BF#);
        C : constant Natural := Byte_At (0);
    begin
        if C < 16#C2# or else not Follows (1) then
            return 1;
        elsif C < 16#E0# then
            return 2;
        elsif C = 16#E0# and then Byte_At (1) < 16#A0# then
            return 1;
        elsif C < 16#F0# then
            return (if Follows (2) then 3 else 1);
        elsif C = 16#F0# and then Byte_At (1) < 16#90# then
            return 1;
        elsif C = 16#F4# and then Byte_At (1) > 16#8F# then
            --  Past U+10FFFF.
            return 1;
        elsif C < 16#F5# then
            return (if Follows (2) and then Follows (3) then 4 else 1);
        else
            return 1;
        end if;
    end Char_Length;

    --  fl_utf8decode's Unicode for the bytes 16#80# .. 16#9F#.
    CP1252 : constant array (Long_Long_Integer range 16#80# .. 16#9F#) of Long_Long_Integer :=
       (16#20AC#, 16#0081#, 16#201A#, 16#0192#, 16#201E#, 16#2026#, 16#2020#, 16#2021#,
        16#02C6#, 16#2030#, 16#0160#, 16#2039#, 16#0152#, 16#008D#, 16#017D#, 16#008F#,
        16#0090#, 16#2018#, 16#2019#, 16#201C#, 16#201D#, 16#2022#, 16#2013#, 16#2014#,
        16#02DC#, 16#2122#, 16#0161#, 16#203A#, 16#0153#, 16#009D#, 16#017E#, 16#0178#);

    function Handle
           (This  : in out UChar_Drop_Box;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        case Event is
            when FLTK.DnD_Enter | FLTK.DnD_Drag | FLTK.DnD_Release =>
                return FLTK.Handled;
            when FLTK.Paste =>
                declare
                    Text : constant String := FLTK.Events.Text;
                    N    : constant Positive := Char_Length (Text);
                    Char : constant String :=
                        (if Text'Length = 0 then (1 => ASCII.NUL)
                         else Text (Text'First .. Text'First + N - 1));
                    Code : Long_Long_Integer := 0;
                    Bytes : String (1 .. 4 * N);
                begin
                    --  fl_utf8decode reads a byte that starts no valid
                    --  encoding as CP1252 if it is in 16#80# .. 16#9F#, and
                    --  as ISO-8859-1 otherwise.
                    if N = 1 then
                        Code := Character'Pos (Char (Char'First));
                        if Code in CP1252'Range then
                            Code := CP1252 (Code);
                        end if;
                    else
                        Code := Character'Pos (Char (Char'First)) mod 2 ** (7 - N);
                        for I in Char'First + 1 .. Char'Last loop
                            Code := Code * 2**6 + Character'Pos (Char (I)) mod 2**6;
                        end loop;
                    end if;
                    for I in 0 .. N - 1 loop
                        Bytes (4 * I + 1 .. 4 * I + 4) := "\x"
                            & Hex (Character'Pos (Char (Char'First + I)), 2, Lower => True);
                    end loop;
                    --  Like the C++'s value (buffer), which stops at a NUL.
                    if Char (Char'First) = ASCII.NUL then
                        This.Set_Value ("");
                    else
                        This.Set_Value (Char & " " & Bytes & " 0x" & Hex (Code, 6, Lower => True));
                    end if;
                end;
                return FLTK.Handled;
            when others =>
                return Otp.Output (This).Handle (Event);
        end case;
    end Handle;


    procedure Exit_Main_CB
           (Item : in out Wdg.Widget'Class) renames Exit_CB;




    --  The Character Rows  --

    type Input_Access is access Inp.Text_Input;

    procedure Free is new Ada.Unchecked_Deallocation (Inp.Text_Input, Input_Access);

    package Input_Vectors is new Ada.Containers.Vectors (Positive, Input_Access);

    --  Every input in the scroll, freed when the program ends.
    Rows : Input_Vectors.Vector;

    type Box_Access is access Bx.Box;

    procedure Free is new Ada.Unchecked_Deallocation (Bx.Box, Box_Access);

    Surrogates : Box_Access;


    function strtoul
           (Str  : in Interfaces.C.Strings.chars_ptr;
            Endp : in System.Address;
            Base : in Interfaces.C.int)
        return Interfaces.C.unsigned_long;
    pragma Import (C, strtoul, "strtoul");

    --  C's (int) strtoul (Text, NULL, 0): decimal, octal after 0, or hex
    --  after 0x, cut to 32 bits.
    function C_Number
           (Text : in String)
        return Long_Long_Integer
    is
        C_Text : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.New_String (Text);
        Value  : constant Interfaces.C.unsigned_long := strtoul (C_Text, System.Null_Address, 0);
        Low    : constant Long_Long_Integer := Long_Long_Integer (Value mod 2**32);
    begin
        Interfaces.C.Strings.Free (C_Text);
        return (if Low >= 2**31 then Low - 2**32 else Low);
    end C_Number;


    procedure Make_Rows
           (Scroll : in out Scr.Scroll)
    is
        Off      : Long_Long_Integer := 2;
        End_List : Long_Long_Integer := 16#1_0000# / 16;
        Y        : Long_Long_Integer;
        Input    : Input_Access;
        Text     : String (1 .. 16 * 4);
        Last     : Natural;
    begin
        --  As in the C++, in 32-bit int, which wraps on the machines FLTK
        --  runs on: an argument over 0x7FFEFFFF makes no rows.
        if Ada.Command_Line.Argument_Count > 0 then
            Off := C_Number (Ada.Command_Line.Argument (1));
            End_List := ((Off + 16#1_0000# + 2**31) mod 2**32 - 2**31) / 16;
            Off := Off / 16;
        end if;

        Y := Off;
        while Y < End_List loop
            --  Skip the UTF-16 surrogates, U+D800 to U+DFFF.
            if Y = 16#D80# then
                Surrogates := new Bx.Box'(Bx.Forge.Create
                   (Scroll, 250, Integer (Y - Off) * 25, 460, 25,
                    "U+D800 " & Encode (16#2026#) & " U+DFFF: UTF-16 surrogate pairs"));
                Surrogates.Set_Background_Color (FLTK.Lighter (FLTK.Yellow_Color));
                Surrogates.Set_Box (FLTK.Down_Box);
                Surrogates.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Left);
                Y := 16#E00#;
                Off := Off + 127;
                exit when Y >= End_List;
            end if;

            Last := 0;
            for X in 0 .. 15 loop
                declare
                    --  fl_utf8encode takes an unsigned code.
                    Char : constant String :=
                        Encode ((16 * Y + Long_Long_Integer (X)) mod 2**32);
                begin
                    Text (Last + 1 .. Last + Char'Length) := Char;
                    Last := Last + Char'Length;
                end;
            end loop;
            --  The C++ text is a C string, which ends at the NUL of U+0000.
            for I in 1 .. Last loop
                if Text (I) = ASCII.NUL then
                    Last := I - 1;
                    exit;
                end if;
            end loop;

            Input := new Inp.Text_Input'(Inp.Forge.Create
               (Scroll, 250, Integer (Y - Off) * 25, 80, 25));
            Input.Set_Text_Font (FLTK.Courier);
            --  "%06X" of an int, which is unsigned for "%X".
            Input.Set_Value ("0x" & Hex (Y * 16 mod 2**32, 6));
            Rows.Append (Input);
            Input := new Inp.Text_Input'(Inp.Forge.Create
               (Scroll, 330, Integer (Y - Off) * 25, 380, 25));
            Input.Set_Text_Font (Extra_Font);
            Input.Set_Value (Text (1 .. Last));
            Rows.Append (Input);

            Y := Y + 1;
        end loop;
    end Make_Rows;


    --  The bytes of a text, those outside ' ' .. '~' as \ooo, and a
    --  backslash doubled.
    function Escaped
           (Text : in String)
        return String
    is
        Octal : constant String := "01234567";
        Code  : Natural;
    begin
        if Text'Length = 0 then
            return "";
        end if;
        Code := Character'Pos (Text (Text'First));
        return (if Code not in 32 .. 126
                then ('\', Octal (Code / 64 + 1), Octal (Code / 8 mod 8 + 1),
                      Octal (Code mod 8 + 1))
                elsif Text (Text'First) = '\' then "\\"
                else (1 => Text (Text'First)))
            & Escaped (Text (Text'First + 1 .. Text'Last));
    end Escaped;


    UTF8_Text : constant String :=
        "ABCabc"
        & Encode ((Wide_Wide_Character'Val (16#E0#), Wide_Wide_Character'Val (16#E8#),
                   Wide_Wide_Character'Val (16#E9#), Wide_Wide_Character'Val (16#EF#),
                   Wide_Wide_Character'Val (16#DF#), Wide_Wide_Character'Val (16#EE#),
                   Wide_Wide_Character'Val (16#F6#), Wide_Wide_Character'Val (16#FC#),
                   Wide_Wide_Character'Val (16#E3#)))
        & "123"
        & Encode ((Wide_Wide_Character'Val (16#1F604#), Wide_Wide_Character'Val (16#1F44D#)))
        & ".";

    Arabic : constant Wide_Wide_String :=
       (Wide_Wide_Character'Val (1610), Wide_Wide_Character'Val (1608),
        Wide_Wide_Character'Val (1606), Wide_Wide_Character'Val (1604),
        Wide_Wide_Character'Val (1603), Wide_Wide_Character'Val (1608),
        Wide_Wide_Character'Val (1583));

    function Spaced
           (Text : in Wide_Wide_String)
        return Wide_Wide_String is
           (if Text'Length <= 1 then Text
            else Text (Text'First) & ' ' & Spaced (Text (Text'First + 1 .. Text'Last)));


    I1 : Inp.Text_Input := Inp.Forge.Create (Main_Window, 5, 5, 240, 25);

    Scroll : Scr.Scroll := Scr.Forge.Create (Main_Window, 250, 0, 5 * 75, 400);


begin


    Make_Font_Chooser;
    Sta.Set_Font_Kind (Extra_Font, "-*-*-*-*-*-*-*-*-*-*-*-*-iso10646-1");

    I1.Set_Value (UTF8_Text);
    Make_Rows (Scroll);
    Main_Window.Set_Resizable (Scroll);

    declare
        I2 : Inp.Text_Input := Inp.Forge.Create (Main_Window, 5, 35, 240, 25);
        I3 : Inp.Text_Input := Inp.Forge.Create (Main_Window, 5, 65, 240, 25);
        I4 : Inp.Text_Input := Inp.Forge.Create (Main_Window, 5, 90, 240, 25);
        I5 : Right_Left_Input :=
            (Inp.Forge.Create (Main_Window, 5, 115, 240, 50) with null record);
        I7 : Inp.Text_Input := Inp.Forge.Create (Main_Window, 5, 230, 240, 25);
        I8 : Inp.Text_Input := Inp.Forge.Create (Main_Window, 5, 260, 240, 25);
        I6 : Right_Left_Input :=
            (Inp.Forge.Create (Main_Window, 5, 175, 240, 50) with null record);
        DB : UChar_Drop_Box := (Otp.Forge.Create (Main_Window, 5, 300, 240, 30) with null record);
        O9 : Otp.Output := Otp.Forge.Create (Main_Window, 5, 330, 240, 45);

        procedure I7_CB
               (Item : in out Wdg.Widget'Class) is
        begin
            I8.Set_Value (Escaped (Inp.Text_Input (Item).Get_Value));
        end I7_CB;
    begin
        I2.Set_Value (FLTK.UTF8.To_Lower (UTF8_Text));
        I3.Set_Value (FLTK.UTF8.To_Upper (UTF8_Text));

        I4.Set_Value ("\->e" & Encode (16#302#) & "=" & Encode (16#EA#));
        I4.Set_Text_Font (Extra_Font);

        I5.Set_Text_Font (Extra_Font);
        I5.Set_Text_Size (30);
        I5.Set_Value (Encode (Arabic));

        I7.Set_Callback (I7_CB'Unrestricted_Access);
        I7.Set_Text_Size (20);
        I7.Set_Value (Encode (Arabic));
        I7.Set_When (FLTK.When_Changed);

        I6.Set_Text_Font (Extra_Font);
        I6.Set_Text_Size (30);
        I6.Set_Value (Encode (Spaced (Arabic)));

        DB.Set_Text_Size (16);
        DB.Set_Value ("unichar drop box");

        O9.Set_Text_Font (Extra_Font);
        O9.Set_Text_Size (30);
        --  "Do nothing.", Greg Ercolano's Japanese test.
        O9.Set_Value (Encode ((Wide_Wide_Character'Val (16#4F55#),
                               Wide_Wide_Character'Val (16#3082#),
                               Wide_Wide_Character'Val (16#884C#),
                               Wide_Wide_Character'Val (16#308B#),
                               Wide_Wide_Character'Val (16#3002#))));

        Main_Window.Set_Callback (Exit_Main_CB'Unrestricted_Access);

        Drw.Set_Status (0, 370, 100, 30);

        --  main_win->show (1, argv): it parses no arguments, so the hex
        --  argument isn't taken for an option.
        Sta.System_Colors;
        Main_Window.Set_X_Class ("utf8");
        Sta.Set_Scheme (Sta.Get_Scheme);
        Main_Window.Show;

        Chooser.Show;

        return Result : constant Integer := FLTK.Run do
            for Item of Rows loop
                Free (Item);
            end loop;
            Free (Surrogates);
        end return;
    end;


end UTF8;
