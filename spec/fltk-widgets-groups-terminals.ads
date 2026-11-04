

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package FLTK.Widgets.Groups.Terminals is


    type Terminal is new Group with private;

    type Terminal_Reference (Data : not null access Terminal'Class) is
        limited null record with Implicit_Dereference => Data;

    type Redraw_Style is (No_Redraw, Rate_Limited, Per_Write);

    type Scrollbar_Style is (Scrollbar_Off, Scrollbar_Auto, Scrollbar_On);

    --  An xterm 256-color palette index, as used by ESC[38;5;<n>m
    type Xterm_Color is mod 256;




    --  Text Attributes  --

    type Text_Attributes is record
        Bold      : Boolean := False;
        Dim       : Boolean := False;
        Italic    : Boolean := False;
        Underline : Boolean := False;
        Inverse   : Boolean := False;
        Strikeout : Boolean := False;
    end record;

    function "+" (Left, Right : in Text_Attributes) return Text_Attributes;
    function "-" (Left, Right : in Text_Attributes) return Text_Attributes;

    Attrib_Normal    : constant Text_Attributes := (others => False);
    Attrib_Bold      : constant Text_Attributes := (Bold      => True, others => False);
    Attrib_Dim       : constant Text_Attributes := (Dim       => True, others => False);
    Attrib_Italic    : constant Text_Attributes := (Italic    => True, others => False);
    Attrib_Underline : constant Text_Attributes := (Underline => True, others => False);
    Attrib_Inverse   : constant Text_Attributes := (Inverse   => True, others => False);
    Attrib_Strikeout : constant Text_Attributes := (Strikeout => True, others => False);




    --  Output Translation  --

    type Output_Translation is record
        CR_To_LF   : Boolean := False;
        LF_To_CR   : Boolean := False;
        LF_To_CRLF : Boolean := False;
    end record;

    function "+" (Left, Right : in Output_Translation) return Output_Translation;
    function "-" (Left, Right : in Output_Translation) return Output_Translation;

    Translate_Off        : constant Output_Translation := (others => False);
    Translate_CR_To_LF   : constant Output_Translation := (CR_To_LF   => True, others => False);
    Translate_LF_To_CR   : constant Output_Translation := (LF_To_CR   => True, others => False);
    Translate_LF_To_CRLF : constant Output_Translation := (LF_To_CRLF => True, others => False);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Terminal;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Terminal;

        --  Rows and Columns must be at least 1 and History at least 0, and
        --  the cells fit as the size setters' must, with a history of at
        --  least 100 rows, which FLTK uses whatever History says (pofltk
        --  99).  Otherwise Constraint_Error is raised.
        function Create
               (X, Y, W, H : in Integer;
                Rows       : in Integer;
                Columns    : in Integer;
                History    : in Integer;
                Text       : in String := "")
            return Terminal;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Rows       : in     Integer;
                Columns    : in     Integer;
                History    : in     Integer;
                Text       : in     String := "")
            return Terminal;

    end Forge;




    --  Text Output  --

    procedure Append
           (This : in out Terminal;
            Text : in     String);

    procedure Append_UTF8
           (This : in out Terminal;
            Text : in     String);

    procedure Append_ASCII
           (This : in out Terminal;
            Text : in     String);

    --  The equivalent of Fl_Terminal::printf, with the formatting done in Ada
    procedure Print
           (This : in out Terminal;
            Text : in     String);

    procedure Print_Char
           (This : in out Terminal;
            Text : in     String);

    procedure Print_Char
           (This : in out Terminal;
            Char : in     Character);

    procedure Plot_Char
           (This   : in out Terminal;
            Text   : in     String;
            Row    : in     Natural;
            Column : in     Natural);

    procedure Plot_Char
           (This   : in out Terminal;
            Char   : in     Character;
            Row    : in     Natural;
            Column : in     Natural);

    function Get_Text
           (This               : in Terminal;
            Lines_Below_Cursor : in Boolean := False)
        return String;




    --  Clearing  --

    procedure Clear
           (This : in out Terminal);

    procedure Clear
           (This : in out Terminal;
            Hue  : in     Color);

    procedure Clear_Screen
           (This              : in out Terminal;
            Scroll_To_History : in     Boolean := True);

    procedure Clear_Screen_Home
           (This              : in out Terminal;
            Scroll_To_History : in     Boolean := True);

    procedure Clear_History
           (This : in out Terminal);

    procedure Reset_Terminal
           (This : in out Terminal);




    --  Cursor  --

    procedure Cursor_Home
           (This : in out Terminal);

    function Get_Cursor_Row
           (This : in Terminal)
        return Natural;

    procedure Set_Cursor_Row
           (This : in out Terminal;
            To   : in     Natural);

    function Get_Cursor_Column
           (This : in Terminal)
        return Natural;

    procedure Set_Cursor_Column
           (This : in out Terminal;
            To   : in     Natural);

    function Get_Cursor_Fore_Color
           (This : in Terminal)
        return Color;

    procedure Set_Cursor_Fore_Color
           (This : in out Terminal;
            To   : in     Color);

    function Get_Cursor_Back_Color
           (This : in Terminal)
        return Color;

    procedure Set_Cursor_Back_Color
           (This : in out Terminal;
            To   : in     Color);




    --  Sizes  --

    --  The size setters raise Constraint_Error on more than 2**24 cells,
    --  rows on the screen and in the history by columns, or on no columns
    --  (pofltk 99).  After each of them, and the margin, font, box and
    --  scrollbar setters, and a resize, the cursor and the place ESC[s
    --  saved are moved back onto the screen; FLTK leaves them where they
    --  were (pofltk 96).  Set_Display_Rows of 0 snaps back to what the
    --  height allows.

    function Get_Display_Rows
           (This : in Terminal)
        return Natural;

    procedure Set_Display_Rows
           (This : in out Terminal;
            To   : in     Natural);

    function Get_Display_Columns
           (This : in Terminal)
        return Natural;

    procedure Set_Display_Columns
           (This : in out Terminal;
            To   : in     Natural);

    function Get_History_Rows
           (This : in Terminal)
        return Natural;

    procedure Set_History_Rows
           (This : in out Terminal;
            To   : in     Natural);

    function Get_History_Use
           (This : in Terminal)
        return Natural;

    function Get_History_Lines
           (This : in Terminal)
        return Natural;

    procedure Set_History_Lines
           (This : in out Terminal;
            To   : in     Natural);

    function Get_Redraw_Rate
           (This : in Terminal)
        return Float;

    procedure Set_Redraw_Rate
           (This : in out Terminal;
            To   : in     Float);

    function Get_Redraw_Style
           (This : in Terminal)
        return Redraw_Style;

    procedure Set_Redraw_Style
           (This : in out Terminal;
            To   : in     Redraw_Style);




    --  Behaviour  --

    function Get_ANSI
           (This : in Terminal)
        return Boolean;

    procedure Set_ANSI
           (This : in out Terminal;
            To   : in     Boolean);

    function Get_Show_Unknown
           (This : in Terminal)
        return Boolean;

    procedure Set_Show_Unknown
           (This : in out Terminal;
            To   : in     Boolean);

    function Get_Error_Char
           (This : in Terminal)
        return String;

    --  To must be one printable UTF-8 character, or Constraint_Error is
    --  raised: FLTK copies it into a cell of 4 bytes unchecked, and a
    --  control character recurses without end (pofltk 98).
    procedure Set_Error_Char
           (This : in out Terminal;
            To   : in     String);

    function Get_Output_Translate
           (This : in Terminal)
        return Output_Translation;

    procedure Set_Output_Translate
           (This : in out Terminal;
            To   : in     Output_Translation);




    --  Text Font, Size, Color, Attributes  --

    function Get_Text_Font
           (This : in Terminal)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Terminal;
            To   : in     Font_Kind);

    function Get_Text_Size
           (This : in Terminal)
        return Font_Size;

    --  Raises Constraint_Error on 0, which divides by zero (pofltk 99).
    procedure Set_Text_Size
           (This : in out Terminal;
            To   : in     Font_Size);

    function Get_Text_Color
           (This : in Terminal)
        return Color;

    procedure Set_Text_Color
           (This : in out Terminal;
            To   : in     Color);

    function Get_Text_Fore_Color
           (This : in Terminal)
        return Color;

    procedure Set_Text_Fore_Color
           (This : in out Terminal;
            To   : in     Color);

    function Get_Text_Back_Color
           (This : in Terminal)
        return Color;

    procedure Set_Text_Back_Color
           (This : in out Terminal;
            To   : in     Color);

    function Get_Text_Fore_Color_Default
           (This : in Terminal)
        return Color;

    procedure Set_Text_Fore_Color_Default
           (This : in out Terminal;
            To   : in     Color);

    function Get_Text_Back_Color_Default
           (This : in Terminal)
        return Color;

    procedure Set_Text_Back_Color_Default
           (This : in out Terminal;
            To   : in     Color);

    procedure Set_Text_Fore_Color_Xterm
           (This : in out Terminal;
            To   : in     Xterm_Color);

    procedure Set_Text_Back_Color_Xterm
           (This : in out Terminal;
            To   : in     Xterm_Color);

    function Get_Text_Attrib
           (This : in Terminal)
        return Text_Attributes;

    procedure Set_Text_Attrib
           (This : in out Terminal;
            To   : in     Text_Attributes);

    function Get_Selection_Fore_Color
           (This : in Terminal)
        return Color;

    procedure Set_Selection_Fore_Color
           (This : in out Terminal;
            To   : in     Color);

    function Get_Selection_Back_Color
           (This : in Terminal)
        return Color;

    procedure Set_Selection_Back_Color
           (This : in out Terminal;
            To   : in     Color);




    --  Box  --

    procedure Set_Box
           (This : in out Terminal;
            Box  : in     Box_Kind);




    --  Margins  --

    function Get_Margin_Left
           (This : in Terminal)
        return Integer;

    procedure Set_Margin_Left
           (This : in out Terminal;
            To   : in     Integer);

    function Get_Margin_Right
           (This : in Terminal)
        return Integer;

    procedure Set_Margin_Right
           (This : in out Terminal;
            To   : in     Integer);

    function Get_Margin_Top
           (This : in Terminal)
        return Integer;

    procedure Set_Margin_Top
           (This : in out Terminal;
            To   : in     Integer);

    function Get_Margin_Bottom
           (This : in Terminal)
        return Integer;

    procedure Set_Margin_Bottom
           (This : in out Terminal;
            To   : in     Integer);




    --  Scrollbars  --

    function Get_Scrollbar_Size
           (This : in Terminal)
        return Integer;

    procedure Set_Scrollbar_Size
           (This : in out Terminal;
            To   : in     Integer);

    function Get_Scrollbar_Actual_Size
           (This : in Terminal)
        return Integer;

    function Get_Hscrollbar_Style
           (This : in Terminal)
        return Scrollbar_Style;

    procedure Set_Hscrollbar_Style
           (This : in out Terminal;
            To   : in     Scrollbar_Style);




    --  Selection  --

    function Get_Selection
           (This         : in     Terminal;
            Start_Row    :    out Integer;
            Start_Column :    out Integer;
            End_Row      :    out Integer;
            End_Column   :    out Integer)
        return Boolean;

    function Selection_Text_Length
           (This : in Terminal)
        return Natural;

    function Selection_Text
           (This : in Terminal)
        return String;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Terminal);

    function Handle
           (This  : in out Terminal;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Terminal is new Group with null record;

    overriding procedure Initialize
           (This : in out Terminal);

    overriding procedure Finalize
           (This : in out Terminal);

    procedure Extra_Init
           (This       : in out Terminal;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Terminal)
    with Inline;


    pragma Inline (Append);
    pragma Inline (Append_UTF8);
    pragma Inline (Append_ASCII);
    pragma Inline (Print);
    pragma Inline (Print_Char);
    pragma Inline (Plot_Char);

    pragma Inline (Clear);
    pragma Inline (Clear_Screen);
    pragma Inline (Clear_Screen_Home);
    pragma Inline (Clear_History);
    pragma Inline (Reset_Terminal);

    pragma Inline (Cursor_Home);
    pragma Inline (Get_Cursor_Row);
    pragma Inline (Set_Cursor_Row);
    pragma Inline (Get_Cursor_Column);
    pragma Inline (Set_Cursor_Column);
    pragma Inline (Get_Cursor_Fore_Color);
    pragma Inline (Set_Cursor_Fore_Color);
    pragma Inline (Get_Cursor_Back_Color);
    pragma Inline (Set_Cursor_Back_Color);

    pragma Inline (Get_Display_Rows);
    pragma Inline (Set_Display_Rows);
    pragma Inline (Get_Display_Columns);
    pragma Inline (Set_Display_Columns);
    pragma Inline (Get_History_Rows);
    pragma Inline (Set_History_Rows);
    pragma Inline (Get_History_Use);
    pragma Inline (Get_History_Lines);
    pragma Inline (Set_History_Lines);
    pragma Inline (Get_Redraw_Rate);
    pragma Inline (Set_Redraw_Rate);
    pragma Inline (Get_Redraw_Style);
    pragma Inline (Set_Redraw_Style);

    pragma Inline (Get_ANSI);
    pragma Inline (Set_ANSI);
    pragma Inline (Get_Show_Unknown);
    pragma Inline (Set_Show_Unknown);
    pragma Inline (Set_Error_Char);

    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);
    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Fore_Color);
    pragma Inline (Set_Text_Fore_Color);
    pragma Inline (Get_Text_Back_Color);
    pragma Inline (Set_Text_Back_Color);
    pragma Inline (Get_Text_Fore_Color_Default);
    pragma Inline (Set_Text_Fore_Color_Default);
    pragma Inline (Get_Text_Back_Color_Default);
    pragma Inline (Set_Text_Back_Color_Default);
    pragma Inline (Set_Text_Fore_Color_Xterm);
    pragma Inline (Set_Text_Back_Color_Xterm);
    pragma Inline (Get_Selection_Fore_Color);
    pragma Inline (Set_Selection_Fore_Color);
    pragma Inline (Get_Selection_Back_Color);
    pragma Inline (Set_Selection_Back_Color);

    pragma Inline (Set_Box);

    pragma Inline (Get_Margin_Left);
    pragma Inline (Set_Margin_Left);
    pragma Inline (Get_Margin_Right);
    pragma Inline (Set_Margin_Right);
    pragma Inline (Get_Margin_Top);
    pragma Inline (Set_Margin_Top);
    pragma Inline (Get_Margin_Bottom);
    pragma Inline (Set_Margin_Bottom);

    pragma Inline (Get_Scrollbar_Size);
    pragma Inline (Set_Scrollbar_Size);
    pragma Inline (Get_Scrollbar_Actual_Size);
    pragma Inline (Set_Hscrollbar_Style);

    pragma Inline (Selection_Text_Length);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Terminals;

