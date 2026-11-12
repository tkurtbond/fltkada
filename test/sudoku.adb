--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/sudoku.cxx, Michael Sweet's Sudoku:  new games at four
--  difficulty levels, marks, checking, solving, undo and redo, the game
--  and the window's place saved in the preferences, and notes played on
--  the X11 bell.  Guided by pofltk's examples/Sudoku.Mod.
--
--  As in the C++ built without ALSA, as FLTK's Linux packages are, the
--  notes are the X11 bell's, and Wayland has none.  The C++ marks an item
--  of the Edit menu, not the difficulty, with FL_MENU_VALUE, which shows
--  nothing; this marks nothing.  New_Game, when it gives up on a square
--  and starts again, goes on reading and writing in the 27 bytes in front
--  of the C++'s grid_values_; Values models them as pofltk does, so that
--  the games dealt are the same as the C++'s for the same time().


with

    Ada.Strings.Fixed,
    Ada.Unchecked_Conversion,
    FLTK.Asks,
    FLTK.Devices.Surface.Image,
    FLTK.Draw,
    FLTK.Environment,
    FLTK.Events,
    FLTK.Help_Dialogs,
    FLTK.Images.Bitmaps,
    FLTK.Static,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide,
    Interfaces.C,
    System;

use type

    FLTK.Asks.Choice_Result,
    FLTK.Color,
    FLTK.Keypress,
    FLTK.Menu_Flag,
    FLTK.Modifier,
    FLTK.Static.Display_Platform,
    Interfaces.C.int,
    Interfaces.C.unsigned_long,
    Interfaces.Unsigned_32,
    Interfaces.Unsigned_64,
    System.Address;


function Sudoku
    return Integer
is

    pragma Linker_Options ("-lX11");

    package Ask renames FLTK.Asks;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Env renames FLTK.Environment;
    package Ev  renames FLTK.Events;
    package Grp renames FLTK.Widgets.Groups;
    package Hlp renames FLTK.Help_Dialogs;
    package Sfc renames FLTK.Devices.Surface;
    package Sys renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;
    package Wdg renames FLTK.Widgets;

    subtype U32 is Interfaces.Unsigned_32;


    Group_Size  : constant := 160;
    Cell_Size   : constant := 50;
    Cell_Offset : constant := 5;
    Menu_Offset : constant := 25;


    --  The C library's random numbers and clock, which the C++ uses.

    function C_Rand
        return Interfaces.C.int
    with Import, Convention => C, External_Name => "rand";

    procedure C_Srand
           (Seed : in Interfaces.C.unsigned)
    with Import, Convention => C, External_Name => "srand";

    function C_Time
           (T : in System.Address)
        return Interfaces.C.long
    with Import, Convention => C, External_Name => "time";

    function Rand
        return Integer is
    begin
        return Integer (C_Rand);
    end Rand;


    --  The preferences, opened as the C++'s static prefs_ is.

    Prefs_Base : constant Env.Database := Env.Forge.From_Scope (Env.User, "fltk.org", "sudoku");
    Prefs      : Env.Pref_Group'Class := Env.Forge.Root (Prefs_Base);


    --  A cell.  Hint_Map has bit N set for a mark N, 1 to 9.

    type Cell is new Wdg.Widget with record
        Row, Col  : Natural := 0;
        Read_Only : Boolean := False;
        Value     : Integer := 0;
        Hint_Map  : U32 := 0;
    end record;

    overriding procedure Draw
           (This : in out Cell);

    overriding function Handle
           (This  : in out Cell;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    type Board_Type is new Dbl.Double_Window with null record;

    --  Saves the window's place and size, as the C++'s resize does.
    overriding procedure Resize
           (This       : in out Board_Type;
            X, Y, W, H : in     Integer);


    Board : Board_Type := (Dbl.Forge.Create
        (Group_Size * 3, Group_Size * 3 + Menu_Offset, "Sudoku") with null record);

    Menu_Bar : Sys.System_Menu_Bar :=
        Sys.Forge.Create (Board, 0, 0, 3 * Group_Size, 25);

    Grid : Grp.Group :=
        Grp.Forge.Create (Board, 0, Menu_Offset, 3 * Group_Size, 3 * Group_Size);

    --  Freed when the program ends, before the window.
    type Cell_Access is access Cell;
    type Group_Access is access Grp.Group;
    type Help_Access is access Hlp.Help_Dialog;

    Cells       : array (0 .. 8, 0 .. 8) of Cell_Access;
    Grid_Groups : array (0 .. 2, 0 .. 2) of Group_Access;
    Help        : Help_Access := null;


    --  The solution, at 0 .. 80, and in front of it the 27 bytes that the
    --  C++'s new_game can reach before grid_values_:  three of the end of
    --  Fl_Double_Window, menubar_ and grid_, whose low four bytes are taken
    --  to be no digit and whose four high ones are zero, and seed_, set by
    --  each New_Game.  The bytes are C's char, signed.
    type Byte is mod 256;

    Values : array (-27 .. 80) of Byte :=
       (-24 .. -21 | -16 .. -13 => 16#A0#, others => 0);

    Game_Seed  : Interfaces.C.long := 0;
    Difficulty : Integer := 0;
    Sound_On   : Boolean := False;

    type Game_State is array (0 .. 80) of U32;

    Undo_Stack : array (0 .. 63) of Game_State := (others => (others => 0));
    Undo_Head, Undo_Tail, Redo_Head : Natural := 0;


    function To_Integer is new Ada.Unchecked_Conversion (U32, Interfaces.Integer_32);
    function To_U32 is new Ada.Unchecked_Conversion (Interfaces.Integer_32, U32);

    function Signed
           (Item : in Byte)
        return Integer is
    begin
        if Item >= 128 then
            return Integer (Item) - 256;
        else
            return Integer (Item);
        end if;
    end Signed;

    function Image
           (N : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (N), Ada.Strings.Left);
    end Image;

    function Key
           (Name : in String;
            J, K : in Natural)
        return String is
    begin
        return Name & Image (J) & "." & Image (K);
    end Key;




    --  Sound, as the C++'s SudokuSound::play does with X11 and no ALSA.

    type X_Keyboard_State is record
        Key_Click_Percent  : Interfaces.C.int;
        Bell_Percent       : Interfaces.C.int;
        Bell_Pitch         : Interfaces.C.unsigned;
        Bell_Duration      : Interfaces.C.unsigned;
        LED_Mask           : Interfaces.C.unsigned_long;
        Global_Auto_Repeat : Interfaces.C.int;
        Auto_Repeats       : Interfaces.C.char_array (0 .. 31);
    end record with Convention => C;

    type X_Keyboard_Control is record
        Key_Click_Percent : Interfaces.C.int := 0;
        Bell_Percent      : Interfaces.C.int := 0;
        Bell_Pitch        : Interfaces.C.int := 0;
        Bell_Duration     : Interfaces.C.int := 0;
        LED               : Interfaces.C.int := 0;
        LED_Mode          : Interfaces.C.int := 0;
        Key               : Interfaces.C.int := 0;
        Auto_Repeat_Mode  : Interfaces.C.int := 0;
    end record with Convention => C;

    FL_Display : System.Address
    with Import, Convention => C, External_Name => "fl_display";

    procedure X_Get_Keyboard_Control
           (Display : in     System.Address;
            State   :    out X_Keyboard_State)
    with Import, Convention => C, External_Name => "XGetKeyboardControl";

    procedure X_Change_Keyboard_Control
           (Display : in System.Address;
            Mask    : in Interfaces.C.unsigned_long;
            Values  : in X_Keyboard_Control)
    with Import, Convention => C, External_Name => "XChangeKeyboardControl";

    procedure X_Bell
           (Display : in System.Address;
            Percent : in Interfaces.C.int)
    with Import, Convention => C, External_Name => "XBell";

    procedure X_Flush
           (Display : in System.Address)
    with Import, Convention => C, External_Name => "XFlush";

    --  KBBellPercent, KBBellPitch and KBBellDuration.
    Bell_Mask : constant Interfaces.C.unsigned_long := 2 + 4 + 8;

    Note_Duration : constant := 50;

    Frequencies : constant array (Character range 'A' .. 'I') of Interfaces.C.int :=
       (880, 988, 1046, 1174, 1318, 1396, 1568, 1760, 1976);

    procedure Play
           (Note : in Character)
    is
        State   : X_Keyboard_State;
        Control : X_Keyboard_Control;
    begin
        FLTK.Check;
        if FLTK.Static.Get_Display_Platform /= FLTK.Static.X11_Platform then
            return;
        end if;
        X_Get_Keyboard_Control (FL_Display, State);
        Control.Bell_Percent := 100;
        Control.Bell_Pitch := Frequencies (Note);
        Control.Bell_Duration := Note_Duration;
        X_Change_Keyboard_Control (FL_Display, Bell_Mask, Control);
        X_Bell (FL_Display, 100);
        X_Flush (FL_Display);
        Control.Bell_Percent := State.Bell_Percent;
        Control.Bell_Pitch := Interfaces.C.int (State.Bell_Pitch);
        Control.Bell_Duration := Interfaces.C.int (State.Bell_Duration);
        X_Change_Keyboard_Control (FL_Display, Bell_Mask, Control);
    end Play;

    --  The note for the value V, 1 to 9.
    function Note
           (V : in Integer)
        return Character is
    begin
        return Character'Val (Character'Pos ('A') + V - 1);
    end Note;




    --  The cell's setters, which redraw it as the C++'s do.

    procedure Set_Value
           (This : in out Cell;
            To   : in     Integer) is
    begin
        This.Value := To;
        This.Redraw;
    end Set_Value;

    procedure Set_Read_Only
           (This : in out Cell;
            To   : in     Boolean) is
    begin
        This.Read_Only := To;
        This.Redraw;
    end Set_Read_Only;

    function Hint_Set
           (This : in Cell;
            N    : in Natural)
        return Boolean is
    begin
        return (This.Hint_Map and Interfaces.Shift_Left (1, N)) /= 0;
    end Hint_Set;

    procedure Set_Hint
           (This : in out Cell;
            N    : in     Natural) is
    begin
        This.Hint_Map := This.Hint_Map or Interfaces.Shift_Left (1, N);
        This.Redraw;
    end Set_Hint;

    procedure Clear_Hint
           (This : in out Cell;
            N    : in     Natural) is
    begin
        This.Hint_Map := This.Hint_Map and not Interfaces.Shift_Left (1, N);
        This.Redraw;
    end Clear_Hint;

    procedure Clear_Hints
           (This : in out Cell) is
    begin
        This.Hint_Map := 0;
        This.Redraw;
    end Clear_Hints;

    function Get_State
           (This : in Cell)
        return U32 is
    begin
        return Interfaces.Shift_Right (This.Hint_Map, 1)
            or Interfaces.Shift_Left (To_U32 (Interfaces.Integer_32 (This.Value)), 12)
            or Interfaces.Shift_Left (Boolean'Pos (This.Read_Only), 9);
    end Get_State;

    procedure Set_State
           (This : in out Cell;
            S    : in     U32) is
    begin
        This.Hint_Map := Interfaces.Shift_Left (S and 16#1ff#, 1);
        This.Read_Only := (S and 16#200#) /= 0;
        This.Value := Integer (Interfaces.Shift_Right (S and 16#f000#, 12));
        if This.Read_Only then
            This.Set_Background_Color (FLTK.Background_Color);
        else
            This.Set_Background_Color (FLTK.Light3_Color);
        end if;
        This.Redraw;
    end Set_State;




    --  Undo and redo.

    procedure Save_State
           (S : out Game_State) is
    begin
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                S (J * 9 + K) := Get_State (Cells (J, K).all);
            end loop;
        end loop;
    end Save_State;

    procedure Load_State
           (S : in Game_State) is
    begin
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                Set_State (Cells (J, K).all, S (J * 9 + K));
            end loop;
        end loop;
    end Load_State;

    procedure Undo is
    begin
        if Undo_Head /= Undo_Tail then
            Undo_Head := (Undo_Head + 63) mod 64;
            Load_State (Undo_Stack (Undo_Head));
            Board.Redraw;
        else
            Ask.Beep (Ask.Error_Beep);
        end if;
    end Undo;

    procedure Redo is
    begin
        if Undo_Head /= Redo_Head then
            Undo_Head := (Undo_Head + 1) mod 64;
            Load_State (Undo_Stack (Undo_Head));
            Board.Redraw;
        else
            Ask.Beep (Ask.Error_Beep);
        end if;
    end Redo;

    procedure Clear_Undo is
    begin
        Undo_Head := 0;
        Undo_Tail := 0;
        Redo_Head := 0;
        Save_State (Undo_Stack (Undo_Head));
    end Clear_Undo;

    procedure Undo_Checkpoint is
    begin
        if Undo_Head = Redo_Head then
            Redo_Head := (Redo_Head + 1) mod 64;
        end if;
        Undo_Head := (Undo_Head + 1) mod 64;
        if Undo_Head = Undo_Tail then
            Undo_Tail := (Undo_Tail + 1) mod 64;
        end if;
        Save_State (Undo_Stack (Undo_Head));
    end Undo_Checkpoint;




    --  The game.

    procedure Check_Game
           (Highlight : in Boolean := True)
    is
        Empty   : Boolean := False;
        Correct : Boolean := True;
        Clash   : Boolean;
        Val     : Integer;
    begin
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                Val := Cells (J, K).Value;
                if Cells (J, K).Read_Only then
                    null;
                elsif Val = 0 then
                    Empty := True;
                else
                    Clash := False;
                    for M in 0 .. 8 loop
                        if (J /= M and then Cells (M, K).Value = Val) or else
                            (K /= M and then Cells (J, M).Value = Val)
                        then
                            Clash := True;
                            exit;
                        end if;
                    end loop;
                    if Clash then
                        if Highlight then
                            Cells (J, K).Set_Background_Color (FLTK.Yellow_Color);
                            Cells (J, K).Redraw;
                        end if;
                        Correct := False;
                    elsif Highlight then
                        Cells (J, K).Set_Background_Color (FLTK.Light3_Color);
                        Cells (J, K).Redraw;
                    end if;
                end if;
            end loop;
        end loop;

        for J in 0 .. 2 loop
            for K in 0 .. 2 loop
                for JJ in 0 .. 2 loop
                    for KK in 0 .. 2 loop
                        declare
                            This : Cell renames Cells (3 * J + JJ, 3 * K + KK).all;
                        begin
                            Val := This.Value;
                            if not This.Read_Only and Val /= 0 then
                                Clash := False;
                                for JJJ in 0 .. 2 loop
                                    for KKK in 0 .. 2 loop
                                        if JJ /= JJJ and KK /= KKK and
                                            Cells (3 * J + JJJ, 3 * K + KKK).Value = Val
                                        then
                                            Clash := True;
                                        end if;
                                    end loop;
                                end loop;
                                if Clash then
                                    if Highlight then
                                        This.Set_Background_Color (FLTK.Yellow_Color);
                                        This.Redraw;
                                    end if;
                                    Correct := False;
                                end if;
                            end if;
                        end;
                    end loop;
                end loop;
            end loop;
        end loop;

        if not Empty and Correct then
            for J in 0 .. 8 loop
                for K in 0 .. 8 loop
                    Cells (J, K).Set_Background_Color (FLTK.Green_Color);
                    Set_Read_Only (Cells (J, K).all, True);
                end loop;
                if Sound_On then
                    Play (Note (Cells (J, 8).Value));
                end if;
            end loop;
        end if;
    end Check_Game;

    procedure Clear_Hints_For
           (Row, Col : in Natural;
            Val      : in Natural) is
    begin
        for I in 0 .. 8 loop
            Clear_Hint (Cells (Row, I).all, Val);
        end loop;
        for I in 0 .. 8 loop
            Clear_Hint (Cells (I, Col).all, Val);
        end loop;
        for I in 0 .. 2 loop
            for J in 0 .. 2 loop
                Clear_Hint (Cells (Row / 3 * 3 + I, Col / 3 * 3 + J).all, Val);
            end loop;
        end loop;
    end Clear_Hints_For;

    procedure Update_Helpers is
        Taken    : array (1 .. 9) of Boolean;
        Row, Col : Natural;

        procedure Take
               (V : in Integer) is
        begin
            if V /= 0 then
                Taken (V) := True;
            end if;
        end Take;
    begin
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                Clear_Hints (Cells (J, K).all);
            end loop;
        end loop;
        for J in 0 .. 80 loop
            Row := J / 9;
            Col := J mod 9;
            if Cells (Row, Col).Value = 0 then
                Taken := (others => False);
                for K in 0 .. 8 loop
                    Take (Cells (Row, K).Value);
                    Take (Cells (K, Col).Value);
                end loop;
                for K in 0 .. 2 loop
                    for M in 0 .. 2 loop
                        Take (Cells (Row / 3 * 3 + K, Col / 3 * 3 + M).Value);
                    end loop;
                end loop;
                for M in Taken'Range loop
                    if not Taken (M) then
                        Set_Hint (Cells (Row, Col).all, M);
                    end if;
                end loop;
            end if;
        end loop;
        Undo_Checkpoint;
    end Update_Helpers;

    --  The first number, 1 to 9, not yet in This's square.
    function Next_Value
           (This : in Cell)
        return Positive
    is
        J     : constant Natural := This.Row / 3 * 3;
        K     : constant Natural := This.Col / 3 * 3;
        Taken : array (1 .. 9) of Boolean := (others => False);
        V     : Integer;
    begin
        for M in 0 .. 2 loop
            for N in 0 .. 2 loop
                V := Cells (J + M, K + N).Value;
                if V /= 0 then
                    Taken (V) := True;
                end if;
            end loop;
        end loop;
        for N in Taken'Range loop
            if not Taken (N) then
                return N;
            end if;
        end loop;
        return 1;
    end Next_Value;

    procedure New_Game
           (Seed : in Interfaces.C.long)
    is
        J, K, M, N, Count : Integer;
        Numbers           : array (0 .. 8) of Integer;
        S                 : Interfaces.Unsigned_64 :=
            Interfaces.Unsigned_64'Mod (Seed);

        --  Whether T is in column N above row M, or in row M left of
        --  column N, as the C++ reads them.
        function Used
               (T : in Integer)
            return Boolean is
        begin
            for MM in 0 .. M - 1 loop
                if Values (MM * 9 + N) = Byte (T) then
                    return True;
                end if;
            end loop;
            for NN in 0 .. N - 1 loop
                if Values (M * 9 + NN) = Byte (T) then
                    return True;
                end if;
            end loop;
            return False;
        end Used;
    begin
        Game_Seed := Seed;
        for I in -8 .. -1 loop
            Values (I) := Byte (S and 16#ff#);
            S := Interfaces.Shift_Right (S, 8);
        end loop;
        C_Srand (Interfaces.C.unsigned'Mod (Seed));
        Values (0 .. 80) := (others => 0);

        J := 0;
        while J < 9 loop
            K := 0;
            while K < 9 loop
                for T in 1 .. 9 loop
                    Count := 0;
                    while Count < 20 loop
                        M := J + Rand mod 3;
                        N := K + Rand mod 3;
                        if Values (M * 9 + N) = 0 and then not Used (T) then
                            Values (M * 9 + N) := Byte (T);
                            exit;
                        end if;
                        Count := Count + 1;
                    end loop;
                    if Count = 20 then
                        K := 9;
                        J := -3;
                        Values (0 .. 80) := (others => 0);
                    end if;
                end loop;
                K := K + 3;
            end loop;
            J := J + 3;
        end loop;

        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                Set_Value (Cells (J, K).all, 0);
                Set_Read_Only (Cells (J, K).all, False);
                Cells (J, K).Set_Background_Color (FLTK.Light3_Color);
                Clear_Hints (Cells (J, K).all);
            end loop;
        end loop;

        Count := 11 * (5 - Difficulty);
        for I in Numbers'Range loop
            Numbers (I) := I + 1;
        end loop;

        while Count > 0 loop
            for I in 1 .. 20 loop
                K := Rand mod 9;
                M := Rand mod 9;
                N := Numbers (K);
                Numbers (K) := Numbers (M);
                Numbers (M) := N;
            end loop;
            J := 0;
            while Count > 0 and J < 9 loop
                K := 0;
                while Count > 0 and K < 9 loop
                    if Values (J * 9 + K) = Byte (Numbers (J)) and
                        not Cells (J, K).Read_Only
                    then
                        Set_Value (Cells (J, K).all, Signed (Values (J * 9 + K)));
                        Set_Read_Only (Cells (J, K).all, True);
                        Cells (J, K).Set_Background_Color (FLTK.Background_Color);
                        Count := Count - 1;
                        exit;
                    end if;
                    K := K + 1;
                end loop;
                J := J + 1;
            end loop;
        end loop;
        Clear_Undo;
    end New_Game;

    procedure Solve_Game is
    begin
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                Set_Value (Cells (J, K).all, Signed (Values (J * 9 + K)));
                Set_Read_Only (Cells (J, K).all, True);
                Cells (J, K).Set_Background_Color (FLTK.Background_Color);
            end loop;
            if Sound_On then
                Play (Note (Cells (J, 8).Value));
            end if;
        end loop;
        Undo_Checkpoint;
    end Solve_Game;

    procedure Load_Game is
        Solved : Boolean := True;
        Val    : Integer;
    begin
        Values (0 .. 80) := (others => 0);
        Rows :
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                if not Prefs.Key_Exists (Key ("value", J, K)) then
                    Values (0) := 0;
                    exit Rows;
                end if;
                Values (J * 9 + K) := Byte'Mod (Integer'(Prefs.Get (Key ("value", J, K), 0)));
                Set_Value (Cells (J, K).all, Prefs.Get (Key ("state", J, K), 0));
                Val := Prefs.Get (Key ("readonly", J, K), 0);
                Set_Read_Only (Cells (J, K).all, Val /= 0);
                if Val /= 0 then
                    Cells (J, K).Set_Background_Color (FLTK.Background_Color);
                else
                    Cells (J, K).Set_Background_Color (FLTK.Light3_Color);
                    Solved := False;
                end if;
                Cells (J, K).Hint_Map :=
                    To_U32 (Interfaces.Integer_32 (Integer'(Prefs.Get (Key ("hint", J, K), 0))));
            end loop;
        end loop Rows;
        if Solved or Values (0) = 0 then
            New_Game (C_Time (System.Null_Address));
        else
            Check_Game (False);
        end if;
        Clear_Undo;
    end Load_Game;

    procedure Save_Game is
    begin
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                Prefs.Set (Key ("value", J, K), Signed (Values (J * 9 + K)));
                Prefs.Set (Key ("state", J, K), Cells (J, K).Value);
                Prefs.Set (Key ("readonly", J, K), Boolean'Pos (Cells (J, K).Read_Only));
                Prefs.Set (Key ("hint", J, K), Integer (To_Integer (Cells (J, K).Hint_Map)));
            end loop;
        end loop;
    end Save_Game;

    procedure Set_Title is
    begin
        case Difficulty is
            when 0      => Board.Set_Label ("Sudoku - Easy");
            when 1      => Board.Set_Label ("Sudoku - Medium");
            when 2      => Board.Set_Label ("Sudoku - Hard");
            when others => Board.Set_Label ("Sudoku - Impossible");
        end case;
    end Set_Title;


    Help_Text : constant String :=
        "<HTML>" & ASCII.LF &
        "<HEAD>" & ASCII.LF &
        "<TITLE>Sudoku Help</TITLE>" & ASCII.LF &
        "</HEAD>" & ASCII.LF &
        "<BODY BGCOLOR='#ffffff'>" & ASCII.LF &
        "<H2>About the Game</H2>" & ASCII.LF &
        "<P>Sudoku (pronounced soo-dough-coo with the emphasis on the" & ASCII.LF &
        "first syllable) is a simple number-based puzzle/game played on a" & ASCII.LF &
        "9x9 grid that is divided into 3x3 subgrids. The goal is to enter" & ASCII.LF &
        "a number from 1 to 9 in each cell so that each number appears" & ASCII.LF &
        "only once in each column and row. In addition, each 3x3 subgrid" & ASCII.LF &
        "may only contain one of each number.</P>" & ASCII.LF &
        "<P>This version of the puzzle is copyright 2005-2010 by Michael R" & ASCII.LF &
        "Sweet.</P>" & ASCII.LF &
        "<P><B>Note:</B> The 'Hard' and 'Impossible' difficulty" & ASCII.LF &
        "levels generate Sudoku puzzles with multiple possible solutions." & ASCII.LF &
        "While some purists insist that these cannot be called 'Sudoku'" & ASCII.LF &
        "puzzles, the author (me) has personally solved many such puzzles" & ASCII.LF &
        "in published/printed Sudoku books and finds them far more" & ASCII.LF &
        "interesting than the simple single solution variety. If you don't" & ASCII.LF &
        "like it, don't play with the difficulty set to 'High' or" & ASCII.LF &
        "'Impossible'.</P>" & ASCII.LF &
        "<H2>How to Play the Game</H2>" & ASCII.LF &
        "<P>At the start of a new game, Sudoku fills in a random selection" & ASCII.LF &
        "of cells for you - the number of cells depends on the difficulty" & ASCII.LF &
        "level you use. Click in any of the empty cells or use the arrow" & ASCII.LF &
        "keys to highlight individual cells and press a number from 1 to 9" & ASCII.LF &
        "to fill in the cell. To clear a cell, press 0, Delete, or" & ASCII.LF &
        "Backspace. When you have successfully completed all subgrids, the" & ASCII.LF &
        "entire puzzle is highlighted in green until you start a new" & ASCII.LF &
        "game.</P>" & ASCII.LF &
        "<P>As you work to complete the puzzle, you can display possible" & ASCII.LF &
        "solutions inside each cell by holding the Shift key and pressing" & ASCII.LF &
        "each number in turn. Repeat the process to remove individual" & ASCII.LF &
        "numbers, or press a number without the Shift key to replace them" & ASCII.LF &
        "with the actual number to use.</P>" & ASCII.LF &
        "</BODY>" & ASCII.LF;




    --  Callbacks.

    procedure Check_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Check_Game;
    end Check_CB;

    procedure Close_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Save_Game;
        Board.Hide;
        if Help /= null then
            Help.Hide;
        end if;
    end Close_CB;

    procedure New_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        if Cells (0, 0).Get_Background_Color /= FLTK.Green_Color and then
            Ask.Choice
               ("Are you sure you want to change the difficulty level and " &
                "discard the current game?", "Keep Current Game", "Start New Game") =
            Ask.First
        then
            return;
        end if;
        New_Game (C_Time (System.Null_Address));
    end New_CB;

    procedure Diff
           (Item : in out Wdg.Widget'Class;
            To   : in     Integer) is
    begin
        if To /= Difficulty then
            Difficulty := To;
            New_CB (Item);
            Set_Title;
            if To > 1 and then Prefs.Get ("difficulty_warning", 0) = 0 then
                Prefs.Set ("difficulty_warning", 1);
                Ask.Alert
                   ("Note: 'Hard' and 'Impossible' puzzles may have more than " &
                    "one possible solution." & ASCII.LF &
                    "This is not an error or bug.");
            end if;
            Prefs.Set ("difficulty", Difficulty);
        end if;
    end Diff;

    procedure Easy_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Diff (Item, 0);
    end Easy_CB;

    procedure Medium_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Diff (Item, 1);
    end Medium_CB;

    procedure Hard_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Diff (Item, 2);
    end Hard_CB;

    procedure Impossible_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Diff (Item, 3);
    end Impossible_CB;

    procedure Update_Helpers_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Update_Helpers;
    end Update_Helpers_CB;

    procedure Help_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        if Help = null then
            Help := new Hlp.Help_Dialog'(Hlp.Forge.Create);
            Help.Set_Content (Help_Text);
        end if;
        Help.Show;
    end Help_CB;

    procedure Mute_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Sound_On := not Sound_On;
        Prefs.Set ("mute_sound", (if Sound_On then 0 else 1));
    end Mute_CB;

    procedure Reset_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Item.Set_Background_Color (FLTK.Light3_Color);
        Item.Redraw;
        Check_Game (False);
    end Reset_CB;

    procedure Restart_CB
           (Item : in out Wdg.Widget'Class)
    is
        Solved : Boolean := True;
        V      : Integer;
    begin
        for J in 0 .. 8 loop
            for K in 0 .. 8 loop
                Clear_Hints (Cells (J, K).all);
                if not Cells (J, K).Read_Only then
                    Solved := False;
                    V := Cells (J, K).Value;
                    Set_Value (Cells (J, K).all, 0);
                    Cells (J, K).Set_Background_Color (FLTK.Light3_Color);
                    if V /= 0 and Sound_On then
                        Play (Note (V));
                    end if;
                end if;
            end loop;
        end loop;
        if Solved then
            New_Game (Game_Seed);
        else
            Clear_Undo;
        end if;
    end Restart_CB;

    procedure Solve_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Solve_Game;
    end Solve_CB;

    procedure Undo_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Undo;
    end Undo_CB;

    procedure Redo_CB
           (Item : in out Wdg.Widget'Class) is
    begin
        Redo;
    end Redo_CB;




    --  The cell's and window's overrides.

    procedure Draw
           (This : in out Cell)
    is
        Hint_Align : constant array (1 .. 9) of FLTK.Alignment :=
           (FLTK.Align_Top_Left, FLTK.Align_Top, FLTK.Align_Top_Right,
            FLTK.Align_Left, FLTK.Align_Center, FLTK.Align_Right,
            FLTK.Align_Bottom_Left, FLTK.Align_Bottom, FLTK.Align_Bottom_Right);
        X : constant Integer := This.Get_X;
        Y : constant Integer := This.Get_Y;
        W : constant Integer := This.Get_W;
        H : constant Integer := This.Get_H;
        C : FLTK.Color;
    begin
        if This.Read_Only then
            FLTK.Draw.Draw_Box (X, Y, W, H, FLTK.Up_Box, This.Get_Background_Color);
        else
            FLTK.Draw.Draw_Box (X, Y, W, H, FLTK.Down_Box, This.Get_Background_Color);
        end if;

        if Ev.Get_Focus /= null and then Ev.Get_Focus.all'Address = This'Address then
            C := FLTK.Color_Average (FLTK.Selection_Color, This.Get_Background_Color, 0.5);
            FLTK.Draw.Set_Color (C);
            FLTK.Draw.Rect_Fill (X + 4, Y + 4, W - 8, H - 8);
            FLTK.Draw.Set_Color (FLTK.Contrast (This.Get_Label_Color, C));
        else
            FLTK.Draw.Set_Color (This.Get_Label_Color);
        end if;

        if This.Value /= 0 then
            FLTK.Draw.Set_Font (FLTK.Helvetica_Bold, FLTK.Font_Size (H - 10));
            FLTK.Draw.Draw_Text
               (X, Y, W, H, (1 => Character'Val (This.Value + Character'Pos ('0'))),
                FLTK.Align_Center);
        else
            FLTK.Draw.Set_Font (FLTK.Helvetica_Bold, FLTK.Font_Size (H / 5));
            for I in Hint_Align'Range loop
                if Hint_Set (This, I) then
                    FLTK.Draw.Draw_Text
                       (X + 5, Y + 5, W - 10, H - 10,
                        (1 => Character'Val (I + Character'Pos ('0'))), Hint_Align (I));
                end if;
            end loop;
        end if;
    end Draw;

    function Handle
           (This  : in out Cell;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        --  The digit pressed, on the main keys or the keypad, or -1.
        function Digit
            return Integer
        is
            Pressed : constant FLTK.Keypress := Ev.Last_Key;
        begin
            for D in Character range '0' .. '9' loop
                if Pressed = FLTK.Press (D) then
                    return Character'Pos (D) - Character'Pos ('0');
                end if;
            end loop;
            if FLTK.Is_Keypad (Pressed) and then FLTK.Keypad_Character (Pressed) in '0' .. '9' then
                return Character'Pos (FLTK.Keypad_Character (Pressed)) - Character'Pos ('0');
            end if;
            return -1;
        end Digit;

        function Shifted
            return Boolean is
        begin
            return Ev.Last_Modifier (FLTK.Mod_Shift + FLTK.Mod_Caps_Lock);
        end Shifted;

        Number : Integer;
    begin
        case Event is
            when FLTK.Focus =>
                Ev.Set_Focus (This);
                This.Redraw;
                return FLTK.Handled;

            when FLTK.Unfocus =>
                This.Redraw;
                return FLTK.Handled;

            when FLTK.Push =>
                if not This.Read_Only and then Ev.Is_Inside (This) then
                    if Ev.Is_Multi_Click then
                        if This.Value /= 0 then
                            if This.Value < 9 then
                                Set_Value (This, This.Value + 1);
                            else
                                Set_Value (This, 1);
                            end if;
                        else
                            Set_Value (This, Next_Value (This));
                        end if;
                    end if;
                    Ev.Set_Focus (This);
                    This.Redraw;
                    return FLTK.Handled;
                end if;

            when FLTK.Keydown =>
                if not Ev.Last_Modifier (FLTK.Mod_Ctrl) then
                    Number := Digit;
                    if Number in 1 .. 9 then
                        if This.Read_Only then
                            Ask.Beep (Ask.Error_Beep);
                            return FLTK.Handled;
                        end if;
                        if Shifted then
                            if Hint_Set (This, Number) then
                                Clear_Hint (This, Number);
                            else
                                Set_Hint (This, Number);
                            end if;
                            Undo_Checkpoint;
                            This.Redraw;
                        else
                            Set_Value (This, Number);
                            Clear_Hints_For (This.Row, This.Col, Number);
                            Undo_Checkpoint;
                            This.Do_Callback;
                        end if;
                        return FLTK.Handled;
                    elsif Number = 0 or else Ev.Last_Key = FLTK.Backspace_Key or else
                        Ev.Last_Key = FLTK.Delete_Key
                    then
                        if This.Read_Only then
                            Ask.Beep (Ask.Error_Beep);
                            return FLTK.Handled;
                        end if;
                        if Shifted then
                            Clear_Hints (This);
                            Undo_Checkpoint;
                        else
                            Set_Value (This, 0);
                            This.Do_Callback;
                            Undo_Checkpoint;
                        end if;
                        return FLTK.Handled;
                    end if;
                end if;

            when others =>
                null;
        end case;
        return Wdg.Widget (This).Handle (Event);
    end Handle;

    procedure Resize
           (This       : in out Board_Type;
            X, Y, W, H : in     Integer) is
    begin
        Dbl.Double_Window (This).Resize (X, Y, W, H);
        Prefs.Set ("x", X);
        Prefs.Set ("y", Y);
        Prefs.Set ("width", W);
        Prefs.Set ("height", H);
    end Resize;




    --  The icon, test/pixmaps/sudoku.xbm.

    Icon_Bits : constant FLTK.Color_Component_Array :=
       (16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#,
        16#03#, 16#0c#, 16#30#, 16#c0#, 16#63#, 16#cc#, 16#33#, 16#cf#,
        16#63#, 16#4c#, 16#33#, 16#cc#, 16#63#, 16#4c#, 16#33#, 16#cc#,
        16#63#, 16#cc#, 16#33#, 16#cc#, 16#63#, 16#0c#, 16#33#, 16#cc#,
        16#63#, 16#0c#, 16#33#, 16#cc#, 16#03#, 16#0c#, 16#30#, 16#c0#,
        16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#,
        16#03#, 16#0c#, 16#30#, 16#c0#, 16#d3#, 16#cc#, 16#33#, 16#cf#,
        16#d3#, 16#cc#, 16#30#, 16#cc#, 16#d3#, 16#cc#, 16#33#, 16#ce#,
        16#f3#, 16#cc#, 16#32#, 16#ce#, 16#c3#, 16#cc#, 16#32#, 16#cc#,
        16#c3#, 16#cc#, 16#33#, 16#cf#, 16#03#, 16#0c#, 16#30#, 16#c0#,
        16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#,
        16#03#, 16#0c#, 16#30#, 16#c0#, 16#f3#, 16#cc#, 16#33#, 16#cf#,
        16#83#, 16#4c#, 16#33#, 16#c1#, 16#f3#, 16#cc#, 16#33#, 16#cf#,
        16#33#, 16#4c#, 16#33#, 16#cc#, 16#33#, 16#4c#, 16#33#, 16#cc#,
        16#f3#, 16#cc#, 16#33#, 16#cf#, 16#03#, 16#0c#, 16#30#, 16#c0#,
        16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#, 16#ff#);

    Mute : Integer;


begin


    --  Sound, and the menus.
    Mute := Prefs.Get ("mute_sound", 0);
    Sound_On := Mute = 0;
    Difficulty := Prefs.Get ("difficulty", 0);
    if Difficulty not in 0 .. 3 then
        Difficulty := 0;
    end if;

    Menu_Bar.Add ("&Game/&New Game", New_CB'Unrestricted_Access,
        FLTK.Mod_Command + 'n', FLTK.Flag_Divider);
    Menu_Bar.Add ("&Game/&Check Game", Check_CB'Unrestricted_Access, FLTK.Mod_Command + 'c');
    Menu_Bar.Add ("&Game/&Restart Game", Restart_CB'Unrestricted_Access, FLTK.Mod_Command + 'r');
    Menu_Bar.Add ("&Game/&Solve Game", Solve_CB'Unrestricted_Access,
        FLTK.Mod_Command + 's', FLTK.Flag_Divider);
    Menu_Bar.Add ("&Game/&Update Helpers", Update_Helpers_CB'Unrestricted_Access);
    Menu_Bar.Add ("&Game/&Mute Sound", Mute_CB'Unrestricted_Access, FLTK.Mod_Command + 'm',
        FLTK.Flag_Toggle + FLTK.Flag_Divider +
        (if Mute /= 0 then FLTK.Flag_Value else FLTK.Flag_Normal));
    Menu_Bar.Add ("&Game/&Quit", Close_CB'Unrestricted_Access, FLTK.Mod_Command + 'q');
    Menu_Bar.Add ("&Edit/&Undo", Undo_CB'Unrestricted_Access, FLTK.Mod_Command + 'z');
    Menu_Bar.Add ("&Edit/&Redo", Redo_CB'Unrestricted_Access, FLTK.Mod_Command + 'Z');
    Menu_Bar.Add ("&Difficulty/&Easy", Easy_CB'Unrestricted_Access, Flags => FLTK.Flag_Radio);
    Menu_Bar.Add ("&Difficulty/&Medium", Medium_CB'Unrestricted_Access, Flags => FLTK.Flag_Radio);
    Menu_Bar.Add ("&Difficulty/&Hard", Hard_CB'Unrestricted_Access, Flags => FLTK.Flag_Radio);
    Menu_Bar.Add ("&Difficulty/&Impossible", Impossible_CB'Unrestricted_Access,
        Flags => FLTK.Flag_Radio);
    Menu_Bar.Add ("&Help/&About Sudoku", Help_CB'Unrestricted_Access,
        FLTK.Press (FLTK.Function_Key (1)));

    --  The grid:  the squares, then the cells over them, all children of
    --  Grid as in the C++.
    for J in 0 .. 2 loop
        for K in 0 .. 2 loop
            Grid_Groups (J, K) := new Grp.Group'(Grp.Forge.Create
               (Grid, K * Group_Size, J * Group_Size + Menu_Offset, Group_Size, Group_Size));
            Grid_Groups (J, K).Set_Box (FLTK.Border_Box);
            if (J = 1) xor (K = 1) then
                Grid_Groups (J, K).Set_Background_Color (FLTK.Dark3_Color);
            else
                Grid_Groups (J, K).Set_Background_Color (FLTK.Dark2_Color);
            end if;
            Grid_Groups (J, K).End_Current;
        end loop;
    end loop;

    for J in 0 .. 8 loop
        for K in 0 .. 8 loop
            Cells (J, K) := new Cell'(Wdg.Forge.Create
               (Grid,
                K * Cell_Size + Cell_Offset + K / 3 * (Group_Size - 3 * Cell_Size),
                J * Cell_Size + Cell_Offset + Menu_Offset + J / 3 * (Group_Size - 3 * Cell_Size),
                Cell_Size, Cell_Size)
                with Row => J, Col => K, Read_Only => False, Value => 0, Hint_Map => 0);
            Cells (J, K).Set_Callback (Reset_CB'Unrestricted_Access);
        end loop;
    end loop;

    --  The window's icon.
    declare
        Bits    : constant FLTK.Images.Bitmaps.Bitmap :=
            FLTK.Images.Bitmaps.Forge.Create (Icon_Bits, 32, 32);
        Surface : Sfc.Image.Image_Surface := Sfc.Image.Forge.Create (32, 32, True);
    begin
        Sfc.Push_Current (Surface);
        FLTK.Draw.Set_Color (FLTK.White_Color);
        FLTK.Draw.Rect_Fill (0, 0, 32, 32);
        FLTK.Draw.Set_Color (FLTK.Black_Color);
        Bits.Draw (0, 0);
        Sfc.Pop_Current;
        Board.Set_Icon (Surface.Get_Image);
    end;

    Board.Set_Callback (Close_CB'Unrestricted_Access);
    Board.Set_Resizable (Grid);
    Board.Set_Size_Range (3 * Group_Size, 3 * Group_Size + Menu_Offset, 0, 0, 5, 5, True);

    --  The window's last place and size.
    if Prefs.Key_Exists ("x") then
        Board.Resize
           (Prefs.Get ("x", -1), Prefs.Get ("y", -1),
            Prefs.Get ("width", 3 * Group_Size),
            Prefs.Get ("height", 3 * Group_Size + Menu_Offset));
    end if;

    Set_Title;
    Clear_Undo;

    Board.Show_With_Args;
    Load_Game;
    return FLTK.Run;


end Sudoku;
