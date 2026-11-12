--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/blocks.cxx, Michael R Sweet's "Block Attack!":  columns of
--  blocks march in from the right, and a click clears a group of adjacent
--  blocks of one colour, or with a bomb every block of its colour.  The
--  game is lost when the blocks reach the left side.  Space starts and
--  pauses it, '?' shows the help, '+' goes up a level, 'f' shows the frame
--  rate and Alt+Shift+H sets the high score to the score.  The high score
--  is kept in the user's preferences, as fltk.org/blocks.
--
--  The C++ plays an explosion through ALSA, CoreAudio or the Windows wave
--  API.  Without them, as on a Linux FLTK built without ALSA, it only calls
--  Fl::check, and so does this port.
--
--  Guided by pofltk's Blocks.Mod and BlocksPixmaps.Mod.


with

    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Blocks_Pixmaps,
    FLTK.Draw,
    FLTK.Environment,
    FLTK.Events,
    FLTK.Images.Bitmaps,
    FLTK.Images.Pixmaps,
    FLTK.Images.Tiled,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double,
    Interfaces.C,
    System;

use type

    FLTK.Alignment,
    FLTK.Event_Outcome,
    FLTK.Modifier,
    Interfaces.C.long;


function Blocks
    return Integer
is

    package BP  renames Blocks_Pixmaps;
    package Btn renames FLTK.Widgets.Buttons;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Env renames FLTK.Environment;
    package Ev  renames FLTK.Events;
    package Pix renames FLTK.Images.Pixmaps;
    package SU  renames Ada.Strings.Unbounded;


    Block_Cols  : constant := 25;
    Block_Rows  : constant := 15;
    Block_Size  : constant := 32;
    Block_Blast : constant := 100;

    --  The timer interval is multiplied by these when the level goes up, a
    --  group of blocks is cleared, and a bomb goes off.
    Level_Factor  : constant Float := 0.900;
    Normal_Factor : constant Float := 0.999;
    Bomb_Factor   : constant Float := 0.995;


    --  C's rand and time, as the C++ uses them, so that the game is the same.
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
        return Natural is (Natural (C_Rand));

    function Now
        return Interfaces.C.long is (C_Time (System.Null_Address));


    --  printf's "%d".
    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Left);
    end Image;




    --  Pictures  --

    function To_Data
           (Rows : in BP.Pixel_Rows)
        return Pix.Pixmap_Data
    is
        Data : Pix.Pixmap_Data (Rows'Range, Rows (Rows'First)'Range);
    begin
        for R in Rows'Range loop
            for C in Rows (R)'Range loop
                Data (R, C) := Rows (R) (C);
            end loop;
        end loop;
        return Data;
    end To_Data;

    type Pixmap_Access is access Pix.Pixmap;

    Pictures : array (BP.Picture) of Pixmap_Access;

    Screen_Bitmap : FLTK.Images.Bitmaps.Bitmap := FLTK.Images.Bitmaps.Forge.Create
       ((16#ff#, 16#55#, 16#ff#, 16#aa#, 16#ff#, 16#55#, 16#ff#, 16#aa#), 8, 8);
    Screen_Tile   : constant FLTK.Images.Tiled.Tiled_Image :=
        FLTK.Images.Tiled.Forge.Create (Screen_Bitmap);


    --  Fl::check, all the C++ explosion does without a sound library.
    procedure Play_Explosion
           (Duration : in Float) is
    begin
        FLTK.Check;
        if Duration <= 0.0 then
            return;
        end if;
    end Play_Explosion;




    --  The window  --

    type Block is record
        Color : Integer := 0;
        Bomb  : Boolean := False;
        Y     : Float   := 0.0;
    end record;

    type Block_Array is array (0 .. Block_Rows - 1) of Block;

    type Column is record
        Num_Blocks : Natural := 0;
        Blocks     : Block_Array;
        X          : Float := 0.0;
    end record;

    type Column_Array is array (0 .. Block_Cols - 1) of Column;

    type Button_Access is access Btn.Button;

    type Block_Window is new Dbl.Double_Window with record
        Frames            : Integer := 0;
        Frames_Per_Second : Integer := 0;
        Frame_Time        : Interfaces.C.long := 0;
        Show_FPS          : Boolean := False;
        Help_Button       : Button_Access;
        Play_Button       : Button_Access;
        Num_Columns       : Natural := 0;
        Columns           : Column_Array;
        Count             : Integer := 0;
        Help              : Boolean := False;
        High_Score        : Integer := 0;
        Interval          : Float := -1.0;
        Level             : Integer := 1;
        Num_Colors        : Integer := 3;
        Opened_Columns    : Integer := 0;
        Paused            : Boolean := False;
        Score             : Integer := 0;
        Title             : SU.Unbounded_String;
        Title_Y           : Integer := 0;
    end record;

    overriding procedure Draw
           (This : in out Block_Window);

    overriding function Handle
           (This  : in out Block_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    type Window_Access is access Block_Window;

    The_Window : Window_Access;


    Prefs_Data : constant Env.Database := Env.Forge.From_Scope (Env.User, "fltk.org", "blocks");
    Prefs      : Env.Pref_Group'Class := Env.Forge.Root (Prefs_Data);


    --  Marks every block of Color, and returns one more than their number.
    function Bomb
           (This  : in out Block_Window;
            Color : in     Integer)
        return Integer
    is
        Count : Integer := 1;
    begin
        if Color >= Block_Blast then
            return 0;
        end if;
        for J in 0 .. This.Num_Columns - 1 loop
            for B of This.Columns (J).Blocks (0 .. This.Columns (J).Num_Blocks - 1) loop
                if B.Color = Color then
                    B.Color := -Color;
                    Count := Count + 1;
                end if;
            end loop;
        end loop;
        return Count;
    end Bomb;


    --  Marks the blocks connected to the block at Col, Row, and returns their
    --  number.
    function Click
           (This     : in out Block_Window;
            Col, Row : in     Natural)
        return Integer
    is
        C     : Column renames This.Columns (Col);
        Color : constant Integer := C.Blocks (Row).Color;
        R     : Natural := Row;
        Count : Integer := 0;
    begin
        if Color < 0 or Color >= Block_Blast then
            return 0;
        end if;

        --  Find the bottom block...
        while R > 0 and then C.Blocks (R - 1).Color = Color loop
            R := R - 1;
        end loop;

        while R < C.Num_Blocks and then C.Blocks (R).Color = Color loop
            C.Blocks (R).Color := -Color;
            if Col > 0 and then R < This.Columns (Col - 1).Num_Blocks and then
                This.Columns (Col - 1).Blocks (R).Color = Color
            then
                Count := Count + Click (This, Col - 1, R);
            end if;
            if Col < This.Num_Columns - 1 and then R < This.Columns (Col + 1).Num_Blocks and then
                This.Columns (Col + 1).Blocks (R).Color = Color
            then
                Count := Count + Click (This, Col + 1, R);
            end if;
            Count := Count + 1;
            R := R + 1;
        end loop;
        return Count;
    end Click;


    procedure Draw
           (This : in out Block_Window)
    is
        W : constant Integer := This.Get_W;
        H : constant Integer := This.Get_H;
        Picture : BP.Picture;
        Message : SU.Unbounded_String;
        Current : Interfaces.C.long;
    begin
        --  Draw the blocks...
        FLTK.Draw.Set_Color (FLTK.Black_Color);
        FLTK.Draw.Rect_Fill (0, 0, W, H);

        for J in 0 .. This.Num_Columns - 1 loop
            declare
                C : Column renames This.Columns (J);
            begin
                for B of C.Blocks (0 .. C.Num_Blocks - 1) loop
                    if B.Color >= Block_Blast then
                        B.Color := B.Color + 1;
                        Picture := BP.Blast;
                    elsif B.Bomb then
                        Picture := BP.Picture'Val
                            (BP.Picture'Pos (BP.Red_Bomb) + abs B.Color - 1);
                    else
                        Picture := BP.Picture'Val
                            (BP.Picture'Pos (BP.Red) + abs B.Color - 1);
                    end if;
                    Pictures (Picture).Draw
                       (W - Integer (Float'Truncation (C.X)),
                        H - Block_Size - Integer (Float'Truncation (B.Y)));
                end loop;
            end;
        end loop;

        if This.Interval < 0.0 or This.Paused then
            FLTK.Draw.Set_Color (FLTK.Black_Color);
            Screen_Tile.Draw (0, 0, W, H, 0, 0);
        end if;

        --  Redraw the widgets...
        This.Play_Button.Redraw;
        This.Help_Button.Redraw;
        This.Draw_Children;

        --  Draw any paused/game over/new game message...
        if (This.Paused or This.Interval < 0.0) and This.Play_Button.Get_W = 80 then
            if This.Help then
                Message := SU.To_Unbounded_String
                   ("Click on adjacent blocks of the same color. Clear all blocks " &
                    "before they reach the left side.");
                FLTK.Draw.Set_Font (FLTK.Helvetica_Bold, 24);
                FLTK.Draw.Set_Color (FLTK.Black_Color);
                FLTK.Draw.Draw_Text (171, 3, W - 250, H - 6, SU.To_String (Message),
                    FLTK.Align_Wrap + FLTK.Align_Left);
                FLTK.Draw.Set_Color (FLTK.Yellow_Color);
                FLTK.Draw.Draw_Text (168, 0, W - 250, H, SU.To_String (Message),
                    FLTK.Align_Wrap + FLTK.Align_Left);
            else
                if This.Interval < 0.0 then
                    if This.Num_Columns > 0 and Now mod 8 < 4 then
                        Message := SU.To_Unbounded_String ("Game Over");
                    else
                        Message := SU.To_Unbounded_String
                           ("Block Attack!" & ASCII.LF & "by Michael R Sweet");
                    end if;
                else
                    Message := SU.To_Unbounded_String ("Paused");
                end if;
                FLTK.Draw.Set_Font (FLTK.Helvetica_Bold, 32);
                FLTK.Draw.Set_Color (FLTK.Black_Color);
                FLTK.Draw.Draw_Text (6, 6, W - 6, H - 6, SU.To_String (Message),
                    FLTK.Align_Center);
                FLTK.Draw.Set_Color (FLTK.Yellow_Color);
                FLTK.Draw.Draw_Text (0, 0, W, H, SU.To_String (Message), FLTK.Align_Center);
            end if;
        end if;

        Current := Now;
        This.Frames := This.Frames + 1;
        if Current > This.Frame_Time then
            This.Frames_Per_Second := (This.Frames_Per_Second +
                3 * This.Frames / Integer (Current - This.Frame_Time)) / 4;
            This.Frames := 0;
            This.Frame_Time := Current;
        end if;

        --  Draw the scores and level...
        FLTK.Draw.Set_Color (FLTK.White_Color);
        FLTK.Draw.Set_Font (FLTK.Helvetica, 14);
        FLTK.Draw.Draw_Text (40, 0, W - 40, 20, " Score: " & Image (This.Score),
            FLTK.Align_Left);
        FLTK.Draw.Draw_Text (0, 0, W, 20, "High Score: " & Image (This.High_Score) & " ",
            FLTK.Align_Right);
        if This.Level > 1 or This.Title_Y <= 0 then
            FLTK.Draw.Draw_Text (0, 0, W, 20, "Level: " & Image (This.Level) & " ",
                FLTK.Align_Center);
        end if;
        if This.Show_FPS then
            FLTK.Draw.Draw_Text (0, H - 20, W, 20, "FPS: " & Image (This.Frames_Per_Second) & " ",
                FLTK.Align_Left);
        end if;

        if This.Title_Y > 0 and This.Interval > 0.0 then
            declare
                Size : constant Integer := 14 + This.Title_Y * 86 / H;
            begin
                FLTK.Draw.Set_Font (FLTK.Helvetica_Bold, FLTK.Font_Size (Size));
                FLTK.Draw.Set_Color (FLTK.Yellow_Color);
                FLTK.Draw.Draw_Text (0, This.Title_Y, W, Size, SU.To_String (This.Title),
                    FLTK.Align_Center);
            end;
        end if;
    end Draw;


    procedure Up_Level
           (This : in out Block_Window) is
    begin
        This.Interval := This.Interval * Level_Factor;
        This.Opened_Columns := 0;
        if This.Num_Colors < 7 then
            This.Num_Colors := This.Num_Colors + 1;
        end if;
        This.Level := This.Level + 1;
        This.Title := SU.To_Unbounded_String ("Level: " & Image (This.Level));
        This.Title_Y := This.Get_H;
    end Up_Level;


    function Handle
           (This  : in out Block_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        MX, MY   : Integer;
        Count    : Integer;
        Hit_Bomb : Boolean := False;
        J        : Natural;
    begin
        if Dbl.Double_Window (This).Handle (Event) = FLTK.Handled then
            return FLTK.Handled;
        elsif This.Interval < 0.0 or This.Paused then
            return FLTK.Not_Handled;
        end if;

        case Event is
            when FLTK.Keydown =>
                --  '+': raise level
                if not Ev.Last_Modifier (FLTK.Mod_Ctrl + FLTK.Mod_Alt + FLTK.Mod_Meta) and
                    Ev.Text = "+"
                then
                    Up_Level (This);
                    return FLTK.Handled;
                end if;
                --  ALT + SHIFT + 'H': clear highscore
                if Ev.Last_Modifier (FLTK.Mod_Alt) and Ev.Last_Modifier (FLTK.Mod_Shift) and
                    Ev.Text = "H"
                then
                    This.High_Score := This.Score;
                    Prefs.Set ("high_score", This.High_Score);
                    return FLTK.Handled;
                end if;
                --  'f': toggle showing frames-per-second
                if Ev.Text = "f" then
                    This.Show_FPS := not This.Show_FPS;
                end if;

            when FLTK.Push =>
                MX := This.Get_W - Ev.Mouse_X + Block_Size;
                MY := This.Get_H - Ev.Mouse_Y;
                Count := 0;
                --  As in the C++, a block that clears nothing (one already
                --  blasting) doesn't stop the search.
                J := 0;
                while Count = 0 and J < This.Num_Columns loop
                    declare
                        C : Column renames This.Columns (J);
                    begin
                        for K in 0 .. C.Num_Blocks - 1 loop
                            if Float (MX) >= C.X and Float (MX) < C.X + Float (Block_Size) and
                                Float (MY) >= C.Blocks (K).Y and
                                Float (MY) < C.Blocks (K).Y + Float (Block_Size)
                            then
                                Hit_Bomb := C.Blocks (K).Bomb;
                                if Hit_Bomb then
                                    Count := Bomb (This, C.Blocks (K).Color);
                                else
                                    Count := Click (This, J, K);
                                end if;
                                exit;
                            end if;
                        end loop;
                    end;
                    J := J + 1;
                end loop;

                if Count < 2 then
                    for C of This.Columns (0 .. This.Num_Columns - 1) loop
                        for B of C.Blocks (0 .. C.Num_Blocks - 1) loop
                            if B.Color < 0 then
                                B.Color := -B.Color;
                            end if;
                        end loop;
                    end loop;
                else
                    Count := Count - 1;
                    if Hit_Bomb then
                        Play_Explosion (Float (0.19 + 0.005 * Long_Float (Count)));
                        This.Interval := This.Interval * Bomb_Factor;
                        This.Score := This.Score + Count;
                    else
                        Play_Explosion (Float (0.09 + 0.005 * Long_Float (Count)));
                        This.Interval := This.Interval * Normal_Factor;
                        This.Score := This.Score + Count * Count;
                    end if;
                    if This.Score > This.High_Score then
                        This.High_Score := This.Score;
                        Prefs.Set ("high_score", This.High_Score);
                    end if;
                    for C of This.Columns (0 .. This.Num_Columns - 1) loop
                        for B of C.Blocks (0 .. C.Num_Blocks - 1) loop
                            if B.Color < 0 then
                                B.Color := Block_Blast;
                            end if;
                        end loop;
                    end loop;
                end if;
                return FLTK.Handled;

            when others =>
                null;
        end case;
        return FLTK.Not_Handled;
    end Handle;


    procedure Init
           (This : in out Block_Window) is
    begin
        This.Frames            := 0;
        This.Frames_Per_Second := 0;
        This.Frame_Time        := Now;
        This.Show_FPS          := False;
        This.Count             := 0;
        This.Help              := False;
        This.Interval          := -1.0;
        This.Level             := 1;
        This.Num_Colors        := 3;
        This.Num_Columns       := 0;
        This.Paused            := False;
        This.Score             := 0;
        This.Title             := SU.Null_Unbounded_String;
        This.Title_Y           := 0;
    end Init;


    procedure New_Game
           (This : in out Block_Window) is
    begin
        --  Seed the random number generator...
        C_Srand (Interfaces.C.unsigned'Mod (Now));
        Init (This);
        This.Interval       := 0.01666666666;
        This.Opened_Columns := 0;
        This.Title          := SU.To_Unbounded_String ("Level: 1");
        This.Title_Y        := This.Get_H;
        This.Redraw;
    end New_Game;




    --  Callbacks  --

    --  Toggles the on-line help.
    procedure Help_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
        This : Block_Window renames The_Window.all;
    begin
        This.Help := not This.Help;
        This.Paused := This.Help;
        This.Play_Button.Set_Label ("@>");
        This.Redraw;
    end Help_CB;


    --  Play/pause.
    procedure Play_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        This : Block_Window renames The_Window.all;
    begin
        if This.Interval < 0.0 then
            New_Game (This);
        else
            This.Paused := not This.Paused;
        end if;
        if This.Paused then
            Item.Set_Label ("@>");
        else
            Item.Set_Label ("@-2||");
            This.Help := False;
        end if;
    end Play_CB;


    --  Animates the game.
    procedure Timeout_CB is
        This  : Block_Window renames The_Window.all;
        I, J    : Natural;
        Removed : Boolean;
        Last_X  : Float;
        Last_Y  : Float;
    begin
        --  Update blocks that have been destroyed...  When a column's last
        --  block goes, the C++ steps back to the column before (to a
        --  Column before the array when it is the first), which ends the
        --  inner loop and goes on with the column that moved into its place.
        I := 0;
        while I < This.Num_Columns loop
            J := 0;
            Removed := False;
            while not Removed and J < This.Columns (I).Num_Blocks loop
                declare
                    C : Column renames This.Columns (I);
                begin
                    if C.Blocks (J).Color > Block_Blast + 5 then
                        This.Redraw;
                        C.Num_Blocks := C.Num_Blocks - 1;
                        if J < C.Num_Blocks then
                            C.Blocks (J .. C.Num_Blocks - 1) := C.Blocks (J + 1 .. C.Num_Blocks);
                        end if;
                        if C.Num_Blocks = 0 then
                            This.Num_Columns := This.Num_Columns - 1;
                            if I < This.Num_Columns then
                                This.Columns (I .. This.Num_Columns - 1) :=
                                    This.Columns (I + 1 .. This.Num_Columns);
                            end if;
                            Removed := True;
                        end if;
                    else
                        J := J + 1;
                    end if;
                end;
            end loop;
            if not Removed then
                I := I + 1;
            end if;
        end loop;

        --  Let the rest of the blocks fall and/or move...
        Last_X := This.Columns (0).X;
        for C of This.Columns (0 .. This.Num_Columns - 1) loop
            if C.X > Last_X then
                C.X := C.X - 8.0;
                This.Redraw;
            end if;
            Last_X := C.X + Float (Block_Size);
            if not This.Paused and This.Interval > 0.0 then
                This.Redraw;
                C.X := C.X + 0.25;
            end if;
            Last_Y := 0.0;
            for B of C.Blocks (0 .. C.Num_Blocks - 1) loop
                if B.Y > Last_Y then
                    This.Redraw;
                    B.Y := B.Y - 4.0;
                end if;
                Last_Y := B.Y + Float (Block_Size);
            end loop;
        end loop;

        --  Slide the title text as needed...
        if This.Title_Y > 0 then
            This.Redraw;
            This.Title_Y := This.Title_Y - 2;
        end if;

        --  Play the game...
        if not This.Paused and This.Interval > 0.0 then
            This.Count := This.Count - 1;
            if This.Count <= 0 then
                This.Redraw;
                This.Count := 4 * Block_Size;
                if This.Num_Columns = Block_Cols then
                    This.Interval := -1.0;
                    Play_Explosion (0.8);
                    This.Play_Button.Set_Label ("@>");
                else
                    This.Opened_Columns := This.Opened_Columns + 1;
                    if This.Opened_Columns > 2 * Block_Cols then
                        Up_Level (This);
                    end if;
                    This.Columns (1 .. This.Num_Columns) :=
                        This.Columns (0 .. This.Num_Columns - 1);
                    This.Num_Columns := This.Num_Columns + 1;
                    declare
                        C : Column renames This.Columns (0);
                    begin
                        C.X := 0.0;
                        C.Num_Blocks := Block_Rows;
                        for R in C.Blocks'Range loop
                            C.Blocks (R).Bomb :=
                                This.Num_Colors > 3 and then Rand mod 128 < This.Num_Colors;
                            C.Blocks (R).Color := 1 + Rand mod This.Num_Colors;
                            C.Blocks (R).Y := Float (R * (Block_Size + 8) + 24);
                        end loop;
                    end;
                end if;
            end if;
        else
            This.Count := This.Count - 1;
            if This.Count <= 0 then
                This.Count := 40;
                This.Redraw;
            end if;
        end if;

        --  Update the play/pause button as needed...
        declare
            Button : Btn.Button renames This.Play_Button.all;
            S      : Integer;
        begin
            if (This.Paused or This.Interval < 0.0) and Button.Get_W < 80 then
                S := Button.Get_W + 5;
                Button.Resize (S, (S - 20) * (This.Get_H - S) / 120, S, S);
                Button.Set_Label_Size (FLTK.Font_Size (S / 2 + 4));
                This.Redraw;
            elsif (not This.Paused and This.Interval > 0.0) and Button.Get_W > 20 then
                S := Button.Get_W - 2;
                Button.Resize (S, (S - 20) * (This.Get_H - S) / 120, S, S);
                Button.Set_Label_Size (FLTK.Font_Size (S / 2 + 4));
                This.Redraw;
            end if;
        end;

        if This.Interval > 0.0 then
            FLTK.Static.Repeat_Timeout (Long_Float (This.Interval), Timeout_CB'Unrestricted_Access);
        else
            FLTK.Static.Repeat_Timeout (0.1, Timeout_CB'Unrestricted_Access);
        end if;
    end Timeout_CB;


    --  BlockWindow's constructor, after Fl_Double_Window's.
    procedure Construct
           (This : in out Block_Window) is
    begin
        Init (This);

        This.Help_Button := new Btn.Button'(Btn.Forge.Create (This, 0, 0, 20, 20, "?"));
        This.Help_Button.Set_Callback (Help_CB'Unrestricted_Access);
        This.Help_Button.Set_Shortcut (FLTK.Press ('?'));

        This.Play_Button := new Btn.Button'
            (Btn.Forge.Create (This, 80, (This.Get_H - 80) / 2, 80, 80, "@>"));
        This.Play_Button.Set_Callback (Play_CB'Unrestricted_Access);
        This.Play_Button.Set_Label_Size (44);
        This.Play_Button.Set_Shortcut (FLTK.Press (' '));

        This.High_Score := Prefs.Get ("high_score", 0);
        FLTK.Static.Add_Timeout (0.01666666, Timeout_CB'Unrestricted_Access);
    end Construct;


begin

    for P in BP.Picture loop
        Pictures (P) := new Pix.Pixmap'(Pix.Forge.Create
           (BP.Picture_Header, BP.Pictures (P).Colors, To_Data (BP.Pictures (P).Rows)));
    end loop;

    FLTK.Static.Set_Scheme ("plastic");
    Ev.Set_Visible_Focus (False);
    The_Window := new Block_Window'
       (Dbl.Forge.Create (Block_Cols * Block_Size, Block_Rows * Block_Size + 20, "Block Attack!")
        with others => <>);
    Construct (The_Window.all);
    The_Window.Show_With_Args;
    return FLTK.Run;

end Blocks;
