

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Text_Buffers;

private with

    Interfaces.C,
    System.Address_To_Access_Conversions;


package FLTK.Widgets.Groups.Text_Displays is


    type Text_Display is new Group with private;

    type Text_Display_Reference (Data : not null access Text_Display'Class) is
        limited null record with Implicit_Dereference => Data;

    type Wrap_Mode is (None, Column, Pixel, Bounds);

    type Cursor_Style is (Normal, Caret, Dim, Block, Heavy, Simple);

    type Position_Kind is (Cursor_Position, Character_Position);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Text_Display;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Text_Display;

    end Forge;




    package Styles is

        --  Corresponds to the ATTR_BGCOLOR and ATTR_BGCOLOR_EXT attribute bits
        type Background_Mode is (No_Background, Background_Fill, Background_Extend);

        for Background_Mode use
           (No_Background     => 0,
            Background_Fill   => 1,
            Background_Extend => 3);

        --  Corresponds to the mutually exclusive ATTR_UNDERLINE, ATTR_GRAMMAR,
        --  ATTR_SPELLING, and ATTR_STRIKE_THROUGH attribute bits
        type Line_Mode is (No_Line, Underline, Grammar, Spelling, Strike_Through);

        for Line_Mode use
           (No_Line        => 0,
            Underline      => 1,
            Grammar        => 2,
            Spelling       => 3,
            Strike_Through => 4);

        type Style_Entry is record
            Hue        : Color;
            Font       : Font_Kind;
            Size       : Font_Size;
            Back_Mode  : Background_Mode := No_Background;
            Lines      : Line_Mode       := No_Line;
            Background : Color           := Background_Color;
        end record;

        type Style_Index is new Character range 'A' .. '~';

        type Style_Array is array (Style_Index range <>) of Style_Entry;

        type Unfinished_Style_Callback is access procedure
               (Char    : in     Character;
                Display : in out Text_Display);

        type Style_Mask is record
            Fill       : Boolean := False;
            Secondary  : Boolean := False;
            Primary    : Boolean := False;
            Highlight  : Boolean := False;
            Background : Boolean := False;
            Text_Only  : Boolean := False;
        end record;

        Empty_Mask : constant Style_Mask;

        type Style_Info is record
            Mask  : Style_Mask;
            Index : Style_Index;
        end record;

    private

        --  Mirrors Fl_Text_Display::Style_Table_Entry, whose attr field packs
        --  the background mode into bits 0 .. 1 and the line mode into bits 2 .. 4
        for Style_Entry use record
            Hue        at 0 * Interfaces.C.unsigned'Size / System.Storage_Unit
                range 0 .. Interfaces.C.unsigned'Size - 1;
            Font       at 1 * Interfaces.C.unsigned'Size / System.Storage_Unit
                range 0 .. Interfaces.C.int'Size - 1;
            Size       at 2 * Interfaces.C.unsigned'Size / System.Storage_Unit
                range 0 .. Interfaces.C.int'Size - 1;
            Back_Mode  at 3 * Interfaces.C.unsigned'Size / System.Storage_Unit
                range 0 .. 1;
            Lines      at 3 * Interfaces.C.unsigned'Size / System.Storage_Unit
                range 2 .. 4;
            Background at 4 * Interfaces.C.unsigned'Size / System.Storage_Unit
                range 0 .. Interfaces.C.unsigned'Size - 1;
        end record;

        for Style_Entry'Size use Interfaces.C.unsigned'Size * 4 + Interfaces.C.int'Size;

        for Style_Mask use record
            Fill       at 0 range 0 .. 0;
            Secondary  at 0 range 1 .. 1;
            Primary    at 0 range 2 .. 2;
            Highlight  at 0 range 3 .. 3;
            Background at 0 range 4 .. 4;
            Text_Only  at 0 range 5 .. 5;
        end record;

        for Style_Mask'Size use Interfaces.C.unsigned_char'Size;

        Empty_Mask : constant Style_Mask := (others => False);

        pragma Convention (C, Style_Entry);
        pragma Convention (C, Style_Array);

    end Styles;




    --  Buffers  --

    function Get_Buffer
           (This : in Text_Display)
        return FLTK.Text_Buffers.Text_Buffer_Reference;

    procedure Set_Buffer
           (This : in out Text_Display;
            Buff : in out FLTK.Text_Buffers.Text_Buffer);

    procedure Buffer_Modified_Callback
           (This         : in out Text_Display;
            Action       : in     FLTK.Text_Buffers.Modification;
            Place        : in     FLTK.Text_Buffers.Position;
            Length       : in     Natural;
            Deleted_Text : in     String);

    procedure Buffer_Predelete_Callback
           (This   : in out Text_Display;
            Place  : in     FLTK.Text_Buffers.Position;
            Length : in     Natural);




    --  Highlighting  --

    procedure Highlight_Data
           (This  : in out Text_Display;
            Buff  : in out FLTK.Text_Buffers.Text_Buffer;
            Table : in     Styles.Style_Array);

    procedure Highlight_Data
           (This       : in out Text_Display;
            Buff       : in out FLTK.Text_Buffers.Text_Buffer;
            Table      : in     Styles.Style_Array;
            Unfinished : in     Character;
            Callback   : in     Styles.Unfinished_Style_Callback);

    function Position_Style
           (This        : in Text_Display;
            Line_Start  : in Natural;
            Line_Length : in Natural;
            Line_Index  : in Natural)
        return Styles.Style_Info;




    --  Measurement Conversion  --

    function Col_To_X
           (This    : in Text_Display;
            Col_Num : in Integer)
        return Integer;

    function X_To_Col
           (This  : in Text_Display;
            X_Pos : in Integer)
        return Integer;

    function In_Selection
           (This : in Text_Display;
            X, Y : in Integer)
        return Boolean;

    procedure Position_To_XY
           (This     : in     Text_Display;
            Pos      : in     Integer;
            X, Y     :    out Integer;
            Vert_Out :    out Boolean);

    procedure Find_Line_End
           (This                    : in     Text_Display;
            Start                   : in     Natural;
            Start_Pos_Is_Line_Start : in     Boolean;
            Line_End                :    out Natural;
            Next_Line_Start         :    out Natural);

    function Find_Character
           (This  : in Text_Display;
            Text  : in String;
            Style : in Styles.Style_Index;
            X     : in Integer)
        return Natural;

    function Position_To_Line
           (This     : in Text_Display;
            Position : in Natural)
        return Natural;

    function Position_To_Line
           (This      : in     Text_Display;
            Position  : in     Natural;
            Displayed :    out Boolean)
        return Natural;

    procedure Position_To_Line_Column
           (This     : in     Text_Display;
            Position : in     Natural;
            Line     :    out Natural;
            Column   :    out Natural);

    procedure Position_To_Line_Column
           (This      : in     Text_Display;
            Position  : in     Natural;
            Line      :    out Natural;
            Column    :    out Natural;
            Displayed :    out Boolean);

    function XY_To_Position
           (This : in Text_Display;
            X, Y : in Integer;
            Kind : in Position_Kind := Character_Position)
        return Natural;

    procedure XY_To_Row_Column
           (This        : in     Text_Display;
            X, Y        : in     Integer;
            Row, Column :    out Natural;
            Kind        : in     Position_Kind := Character_Position);




    --  Cursors  --

    function Get_Cursor_Color
           (This : in Text_Display)
        return Color;

    procedure Set_Cursor_Color
           (This : in out Text_Display;
            Col  : in     Color);

    procedure Set_Cursor_Style
           (This  : in out Text_Display;
            Style : in     Cursor_Style);

    procedure Hide_Cursor
           (This : in out Text_Display);

    procedure Show_Cursor
           (This : in out Text_Display);




    --  Text Settings  --

    function Get_Text_Color
           (This : in Text_Display)
        return Color;

    procedure Set_Text_Color
           (This : in out Text_Display;
            Col  : in     Color);

    function Get_Text_Font
           (This : in Text_Display)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Text_Display;
            Font : in     Font_Kind);

    function Get_Text_Size
           (This : in Text_Display)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Text_Display;
            Size : in     Font_Size);




    --  Text Insert  --

    procedure Insert_Text
           (This : in out Text_Display;
            Item : in     String);

    procedure Overstrike
           (This : in out Text_Display;
            Text : in     String);

    function Get_Insert_Position
           (This : in Text_Display)
        return Natural;

    procedure Set_Insert_Position
           (This : in out Text_Display;
            Pos  : in     Natural);

    procedure Show_Insert_Position
           (This : in out Text_Display);




    --  Words  --

    function Word_Start
           (This : in out Text_Display;
            Pos  : in     Natural)
        return Natural;

    function Word_End
           (This : in out Text_Display;
            Pos  : in     Natural)
        return Natural;

    procedure Next_Word
           (This : in out Text_Display);

    procedure Previous_Word
           (This : in out Text_Display);




    --  Wrapping  --

    procedure Set_Wrap_Mode
           (This   : in out Text_Display;
            Mode   : in     Wrap_Mode;
            Margin : in     Natural := 0);

    function Wrapped_Row
           (This : in Text_Display;
            Row  : in Natural)
        return Natural;

    function Wrapped_Column
           (This        : in Text_Display;
            Row, Column : in Natural)
        return Natural;

    function Wrap_Uses_Character
           (This     : in Text_Display;
            Line_End : in Natural)
        return Boolean;

    procedure Count_Wrapped_Lines
           (This                       : in     Text_Display;
            Buffer                     : in     FLTK.Text_Buffers.Text_Buffer;
            Start                      : in     Natural;
            Max_Position, Max_Lines    : in     Natural;
            Start_Pos_Is_Line_Start    : in     Boolean;
            Style_Offset               : in     Natural;
            Finish, Line_Count         :    out Natural;
            End_Count_Line_Start       :    out Natural;
            Last_Line_End              :    out Natural;
            Count_Last_Missing_Newline : in     Boolean := True);




    --  Lines  --

    --  Takes into account word wrap
    function Line_Start
           (This : in Text_Display;
            Pos  : in Natural)
        return Natural;

    --  Takes into account word wrap
    function Line_End
           (This                    : in Text_Display;
            Pos                     : in Natural;
            Start_Pos_Is_Line_Start : in Boolean := False)
        return Natural;

    function Count_Lines
           (This                    : in Text_Display;
            Start, Finish           : in Natural;
            Start_Pos_Is_Line_Start : in Boolean := False)
        return Natural;

    --  Takes into account word wrap as well as newline characters
    function Skip_Lines
           (This                    : in Text_Display;
            Start, Lines            : in Natural;
            Start_Pos_Is_Line_Start : in Boolean := False)
        return Natural;

    --  Takes into account word wrap as well as newline characters
    function Rewind_Lines
           (This         : in Text_Display;
            Start, Lines : in Natural)
        return Natural;

    procedure Calculate_Last_Character
           (This : in out Text_Display);

    procedure Calculate_Line_Starts
           (This          : in out Text_Display;
            Start, Finish : in     Natural);

    procedure Offset_Line_Starts
           (This    : in out Text_Display;
            New_Top : in     Natural);




    --  Absolute Lines  --

    procedure Redo_Absolute_Top_Line
           (This      : in out Text_Display;
            Old_First : in     Natural);

    function Get_Absolute_Top_Line
           (This : in Text_Display)
        return Natural;

    procedure Maintain_Absolute_Top_Line
           (This  : in out Text_Display;
            State : in     Boolean := True);

    function Maintaining_Absolute_Top_Line
           (This : in Text_Display)
        return Boolean;

    procedure Reset_Absolute_Top_Line
           (This : in out Text_Display);




    --  Visible Lines  --

    function Has_Empty_Visible_Lines
           (This : in Text_Display)
        return Boolean;

    function Get_Longest_Visible_Line
           (This : in Text_Display)
        return Natural;

    function Visible_Line_Length
           (This : in Text_Display;
            Line : in Natural)
        return Natural;




    --  Line Numbers  --

    function Get_Linenumber_Alignment
           (This : in Text_Display)
        return Alignment;

    procedure Set_Linenumber_Alignment
           (This : in out Text_Display;
            To   : in     Alignment);

    function Get_Linenumber_Back_Color
           (This : in Text_Display)
        return Color;

    procedure Set_Linenumber_Back_Color
           (This : in out Text_Display;
            To   : in     Color);

    function Get_Linenumber_Fore_Color
           (This : in Text_Display)
        return Color;

    procedure Set_Linenumber_Fore_Color
           (This : in out Text_Display;
            To   : in     Color);

    function Get_Linenumber_Font
           (This : in Text_Display)
        return Font_Kind;

    procedure Set_Linenumber_Font
           (This : in out Text_Display;
            To   : in     Font_Kind);

    function Get_Linenumber_Size
           (This : in Text_Display)
        return Font_Size;

    procedure Set_Linenumber_Size
           (This : in out Text_Display;
            To   : in     Font_Size);

    function Get_Linenumber_Width
           (This : in Text_Display)
        return Natural;

    procedure Set_Linenumber_Width
           (This  : in out Text_Display;
            Width : in     Natural);

    function Get_Linenumber_Format
           (This : in Text_Display)
        return String;

    procedure Set_Linenumber_Format
           (This  : in out Text_Display;
            Value : in     String);




    --  Text Measurement  --

    function Measure_Character
           (This  : in Text_Display;
            Text  : in String;
            X     : in Integer;
            Index : in Positive)
        return Long_Float;

    function Measure_Visible_Line
           (This : in Text_Display;
            Line : in Natural)
        return Natural;

    function Measure_String
           (This  : in Text_Display;
            Text  : in String;
            Style : in Styles.Style_Index)
        return Long_Float;




    --  Movement  --

    procedure Move_Down
           (This : in out Text_Display);

    function Move_Down
           (This : in out Text_Display)
        return Boolean;

    procedure Move_Left
           (This : in out Text_Display);

    function Move_Left
           (This : in out Text_Display)
        return Boolean;

    procedure Move_Right
           (This : in out Text_Display);

    function Move_Right
           (This : in out Text_Display)
        return Boolean;

    procedure Move_Up
           (This : in out Text_Display);

    function Move_Up
           (This : in out Text_Display)
        return Boolean;




    --  Scrolling  --

    procedure Scroll_To
           (This   : in out Text_Display;
            Line   : in     Natural;
            Column : in     Natural := 0);

    function Scroll_To
           (This  : in out Text_Display;
            Line  : in     Natural;
            Pixel : in     Natural := 0)
        return Boolean;

    function Get_Scrollbar_Alignment
           (This : in Text_Display)
        return Alignment;

    procedure Set_Scrollbar_Alignment
           (This  : in out Text_Display;
            Align : in     Alignment);

    function Get_Scrollbar_Width
           (This : in Text_Display)
        return Natural;

    procedure Set_Scrollbar_Width
           (This  : in out Text_Display;
            Width : in     Natural);

    procedure Update_Horizontal_Scrollbar
           (This : in out Text_Display);

    procedure Update_Vertical_Scrollbar
           (This : in out Text_Display);




    --  Shortcuts  --

    function Get_Shortcut
           (This : in Text_Display)
        return Key_Combo;

    procedure Set_Shortcut
           (This  : in out Text_Display;
            Value : in     Key_Combo);




    --  Dimensions  --

    procedure Resize
           (This       : in out Text_Display;
            X, Y, W, H : in     Integer);




    --  Drawing, Events  --

    procedure Clear_Rect
           (This       : in out Text_Display;
            Style      : in     Styles.Style_Info;
            X, Y, W, H : in     Integer);

    procedure Display_Insert
           (This : in out Text_Display);

    procedure Redisplay_Range
           (This          : in out Text_Display;
            Start, Finish : in     Natural);

    procedure Draw
           (This : in out Text_Display);

    procedure Draw_Cursor
           (This : in out Text_Display;
            X, Y : in     Integer);

    procedure Draw_Line_Numbers
           (This  : in out Text_Display;
            Clear : in     Boolean :=  False);

    procedure Draw_Range
           (This          : in out Text_Display;
            Start, Finish : in     Natural);

    procedure Draw_String
           (This      : in out Text_Display;
            Style     : in     Styles.Style_Info;
            X, Y      : in     Integer;
            Right     : in     Integer;
            Text      : in     String;
            Num_Chars : in     Natural);

    procedure Draw_Text
           (This       : in out Text_Display;
            X, Y, W, H : in     Integer);

    procedure Draw_Visible_Line
           (This                  : in out Text_Display;
            Line                  : in     Natural;
            Left_Clip, Right_Clip : in     Integer;
            Left_Char, Right_Char : in     Natural);

    function Handle
           (This  : in out Text_Display;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Text_Display is new Group with
        record
            Buffer         : access FLTK.Text_Buffers.Text_Buffer;
            Raw_Buffer     : Storage.Integer_Address := Null_Pointer;
            Style_Callback : Styles.Unfinished_Style_Callback;
        end record;

    overriding procedure Initialize
           (This : in out Text_Display);

    overriding procedure Finalize
           (This : in out Text_Display);

    procedure Extra_Init
           (This       : in out Text_Display;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Text_Display)
    with Inline;


    package Text_Display_Convert is new System.Address_To_Access_Conversions (Text_Display'Class);


    --  Adds some basic reference counting on the C side to help ensure any Text_Buffers
    --  do not get deallocated before all Text_Displays they might be attached to.
    procedure upref_fl_text_buffer
           (TB : in Storage.Integer_Address);
    pragma Import (C, upref_fl_text_buffer, "upref_fl_text_buffer");
    pragma Inline (upref_fl_text_buffer);

    procedure free_fl_text_buffer
           (TB : in Storage.Integer_Address);
    pragma Import (C, free_fl_text_buffer, "free_fl_text_buffer");
    pragma Inline (free_fl_text_buffer);


    pragma Inline (Get_Buffer);
    pragma Inline (Set_Buffer);
    pragma Inline (Buffer_Predelete_Callback);

    pragma Inline (Highlight_Data);

    pragma Inline (Col_To_X);
    pragma Inline (X_To_Col);
    pragma Inline (In_Selection);
    pragma Inline (Position_To_XY);
    pragma Inline (Find_Line_End);
    pragma Inline (Find_Character);
    pragma Inline (Position_To_Line);
    pragma Inline (Position_To_Line_Column);
    pragma Inline (XY_To_Position);
    pragma Inline (XY_To_Row_Column);

    pragma Inline (Get_Cursor_Color);
    pragma Inline (Set_Cursor_Color);
    pragma Inline (Set_Cursor_Style);
    pragma Inline (Hide_Cursor);
    pragma Inline (Show_Cursor);

    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Insert_Text);
    pragma Inline (Overstrike);
    pragma Inline (Get_Insert_Position);
    pragma Inline (Set_Insert_Position);
    pragma Inline (Show_Insert_Position);

    pragma Inline (Word_Start);
    pragma Inline (Word_End);
    pragma Inline (Next_Word);
    pragma Inline (Previous_Word);

    pragma Inline (Set_Wrap_Mode);
    pragma Inline (Wrapped_Row);
    pragma Inline (Wrapped_Column);
    pragma Inline (Wrap_Uses_Character);
    pragma Inline (Count_Wrapped_Lines);

    pragma Inline (Line_Start);
    pragma Inline (Line_End);
    pragma Inline (Count_Lines);
    pragma Inline (Skip_Lines);
    pragma Inline (Rewind_Lines);
    pragma Inline (Calculate_Last_Character);
    pragma Inline (Calculate_Line_Starts);
    pragma Inline (Offset_Line_Starts);

    pragma Inline (Redo_Absolute_Top_Line);
    pragma Inline (Get_Absolute_Top_Line);
    pragma Inline (Maintain_Absolute_Top_Line);
    pragma Inline (Maintaining_Absolute_Top_Line);
    pragma Inline (Reset_Absolute_Top_Line);

    pragma Inline (Has_Empty_Visible_Lines);
    pragma Inline (Get_Longest_Visible_Line);
    pragma Inline (Visible_Line_Length);

    pragma Inline (Get_Linenumber_Alignment);
    pragma Inline (Set_Linenumber_Alignment);
    pragma Inline (Get_Linenumber_Back_Color);
    pragma Inline (Set_Linenumber_Back_Color);
    pragma Inline (Get_Linenumber_Fore_Color);
    pragma Inline (Set_Linenumber_Fore_Color);
    pragma Inline (Get_Linenumber_Font);
    pragma Inline (Set_Linenumber_Font);
    pragma Inline (Get_Linenumber_Size);
    pragma Inline (Set_Linenumber_Size);
    pragma Inline (Get_Linenumber_Width);
    pragma Inline (Set_Linenumber_Width);
    pragma Inline (Get_Linenumber_Format);
    pragma Inline (Set_Linenumber_Format);

    pragma Inline (Measure_Character);
    pragma Inline (Measure_Visible_Line);
    pragma Inline (Measure_String);

    pragma Inline (Move_Down);
    pragma Inline (Move_Left);
    pragma Inline (Move_Right);
    pragma Inline (Move_Up);

    pragma Inline (Scroll_To);
    pragma Inline (Get_Scrollbar_Alignment);
    pragma Inline (Set_Scrollbar_Alignment);
    pragma Inline (Get_Scrollbar_Width);
    pragma Inline (Set_Scrollbar_Width);
    pragma Inline (Update_Horizontal_Scrollbar);
    pragma Inline (Update_Vertical_Scrollbar);

    pragma Inline (Get_Shortcut);
    pragma Inline (Set_Shortcut);

    pragma Inline (Resize);

    pragma Inline (Clear_Rect);
    pragma Inline (Display_Insert);
    pragma Inline (Redisplay_Range);
    pragma Inline (Draw);
    pragma Inline (Draw_Cursor);
    pragma Inline (Draw_Line_Numbers);
    pragma Inline (Draw_Range);
    pragma Inline (Draw_String);
    pragma Inline (Draw_Text);
    pragma Inline (Draw_Visible_Line);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Text_Displays;


