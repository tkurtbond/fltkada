--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/checkers.cxx, Bill Spitzak's checkers game, from Steve
--  Poulsen's 1979 Pascal program:  drag a black piece to move, and the
--  computer answers; the right mouse button or a key gives the menu.
--  The search keeps C's arithmetic (short and unsigned char wrap, the
--  random seed's 32-bit overflow) so it picks the same moves.
--  Guided by pofltk's Checkers.Mod.


with

    Ada.Strings.Fixed,
    Ada.Text_IO,
    Checkers_Pieces,
    FLTK.Asks,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Images.RGB.PNG,
    FLTK.Menu_Items,
    FLTK.Screen,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Menus.Menu_Buttons,
    FLTK.Widgets.Valuators.Sliders,
    FLTK.Widgets.Valuators.Value_Outputs,
    GNAT.OS_Lib,
    Interfaces.C,
    System;

use

    Interfaces;

use type

    FLTK.Alignment,
    FLTK.Event_Kind,
    FLTK.Menu_Flag,
    FLTK.Mouse_Button;


function Checkers
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Mn  renames FLTK.Widgets.Menus;
    package MB  renames FLTK.Widgets.Menus.Menu_Buttons;
    package PNG renames FLTK.Images.RGB.PNG;
    package Sld renames FLTK.Widgets.Valuators.Sliders;
    package VO  renames FLTK.Widgets.Valuators.Value_Outputs;

    Copyright : constant String :=
        "Checkers game" & ASCII.LF &
        "Copyright (C) 1997-2010 Bill Spitzak    spitzak@@d2.com" & ASCII.LF &
        "Original Pascal code:" & ASCII.LF &
        "Copyright 1978, Oregon Minicomputer Software, Inc." & ASCII.LF &
        "2340 SW Canyon Road, Portland, Oregon 97201" & ASCII.LF &
        "Written by Steve Poulsen 18-Jan-79" & ASCII.LF &
        ASCII.LF &
        "This program is free software; you can redistribute it and/or modify " &
        "it under the terms of the GNU General Public License as published by " &
        "the Free Software Foundation; either version 2 of the License, or " &
        "(at your option) any later version." & ASCII.LF &
        ASCII.LF &
        "This program is distributed in the hope that it will be useful, " &
        "but WITHOUT ANY WARRANTY; without even the implied warranty of " &
        "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " &
        "GNU General Public License for more details." & ASCII.LF &
        ASCII.LF &
        "You should have received a copy of the GNU Library General Public " &
        "License along with this library; if not, write to the Free Software " &
        "Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 " &
        "USA.";


    ----------------------------------------------------------------
    --  The algorithm  --

    Max_Evaluate : Integer := 2500;     --  max number of moves to examine on a turn
    Max_Nodes    : Integer := 2500;     --  maximum number of nodes in search tree
    Max_Ply      : constant := 20;      --  maximum depth to look ahead
    Force_Jumps  : Boolean := True;     --  is forced jumps rule in effect?

    --  Scoring parameters:  all divided by 5 from the original code.
    S_Piece  : constant := 800;     --  value of a piece
    S_King   : constant := 1200;    --  value of a king
    S_Advan  : constant := 160;     --  value of mypieces/theirpieces-1
    S_Allpin : constant := 80;      --  mobil = 0
    S_Deny   : constant := 10;      --  moves enemy can make that will be jumped
    S_Pin    : constant := 32;      --  enemy pieces that have no move except jumped
    S_Threat : constant := -10;     --  enemy pieces we can jump if not moved
    S_Grad   : constant := 1;       --  score of piece positions
    S_Back   : constant := 10;      --  back row occupied so enemy can't make king
    S_Moc2   : constant := 200;     --  more mobility, more center
    S_Moc3   : constant := -8;      --  less mobility, less center
    S_Moc4   : constant := -80;     --  more mobility, less center
    S_Mode2  : constant := -14;     --  less mobility, less denied
    S_Mode3  : constant := -40;     --  more mobility, more denied
    S_Demmo  : constant := -20;     --  more denied, more moves
    S_Cent   : constant := 10;      --  pieces in center
    S_Kcent  : constant := 100;     --  kings in center

    Depth_Penalty : constant := 4;
    Noise         : constant := 2;  --  values less or eq to this apart are eq

    subtype Bit is Integer range 0 .. 1;

    type Node;
    type Node_Access is access Node;

    type Node is record
        Father   : Node_Access;
        Son      : Node_Access;     --  best son
        Brother  : Node_Access;     --  next brother
        Value    : Integer_16 := 0; --  value of this position to the player moving
        From, To : Integer := 0;    --  the move to reach this board
        Jump     : Unsigned_32 := 0;    --  bit map of locations jumped
        Mobil    : Unsigned_8 := 0;
        Deny     : Unsigned_8 := 0;
        Pin      : Unsigned_8 := 0;
        Threat   : Unsigned_8 := 0;
        Gradient : Integer_16 := 0;
        Who      : Bit := 0;        --  0 = black's move, 1 = white's move
        King     : Bit := 0;        --  1 = move causes piece to be kinged
        Back     : Bit := 0;
        Moc2     : Bit := 0;
        Moc3     : Bit := 0;
        Moc4     : Bit := 0;
        Mode2    : Bit := 0;
        Mode3    : Bit := 0;
        Demmo    : Bit := 0;
    end record;

    Nodes : Integer := 0;   --  count of nodes

    --  Board positions:        Border positions:
    --
    --            WHITE               00  01  02  03  04
    --        05  06  07  08        04  XX  XX  XX  XX
    --      09  10  11  12            XX  XX  XX  XX  13
    --        14  15  16  17        13  XX  XX  XX  XX
    --      18  19  20  21            XX  XX  XX  XX  22
    --        23  24  25  26        22  XX  XX  XX  XX
    --      27  28  29  30            XX  XX  XX  XX  31
    --        32  33  34  35        31  XX  XX  XX  XX
    --      36  37  38  39            XX  XX  XX  XX  40
    --            BLACK             40  41  42  43  44

    subtype Piece is Unsigned_8;

    --  Piece values so that Black and White are bit flags.
    Empty      : constant Piece := 0;
    Black      : constant Piece := 1;
    White      : constant Piece := 2;
    King       : constant Piece := 4;
    Black_King : constant Piece := 5;
    White_King : constant Piece := 6;
    Blue       : constant Piece := 8;

    Flip : constant array (Piece range 0 .. 8) of Piece :=
       (Empty, White, Black, 0, 0, White_King, Black_King, 0, Blue);

    --  Legal move directions.
    Offset : constant array (Piece range 0 .. 8, 0 .. 3) of Integer :=
       ((0, 0, 0, 0),
        (-5, -4, 0, 0),
        (4, 5, 0, 0),
        (0, 0, 0, 0),
        (0, 0, 0, 0),
        (4, 5, -4, -5),
        (4, 5, -4, -5),
        (0, 0, 0, 0),
        (0, 0, 0, 0));

    type Board_Array is array (0 .. 44) of Piece;
    type Board_Access is access all Board_Array;

    Brd : aliased Board_Array := (others => Empty);   --  current board position being considered

    Evaluated : Integer := 0;   --  number of moves evaluated this turn

    Central_Squares : array (0 .. 44) of Integer := (others => 0);
    Is_Protected    : array (0 .. 44) of Boolean := (others => False);

    Flip_Board : aliased Board_Array := (others => Empty);   --  swapped if enemy is black
    TB         : Board_Access := Brd'Access;                --  the real or swapped board

    Friend      : constant Piece := Black;
    Friend_King : constant Piece := Black_King;
    Enemy       : constant Piece := White;
    Enemy_King  : constant Piece := White_King;

    Denied_Moves, Undenied_Moves : Integer := 0;


    function Img
           (V : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (V), Ada.Strings.Left);
    end Img;

    --  C's conversion of an int to a short.
    function To_Short
           (V : in Integer)
        return Integer_16
    is
        U : constant Unsigned_16 := Unsigned_16'Mod (V);
    begin
        if U >= 2 ** 15 then
            return Integer_16 (Integer (U) - 2 ** 16);
        else
            return Integer_16 (U);
        end if;
    end To_Short;

    function To_Bit
           (B : in Boolean)
        return Bit is
    begin
        return Boolean'Pos (B);
    end To_Bit;

    function Has
           (P, Flag : in Piece)
        return Boolean is
    begin
        return (P and Flag) /= 0;
    end Has;


    --  See if the enemy at Target can be jumped from Direction by our piece.
    function Check_Jump
           (Target, Direction : in Integer)
        return Boolean
    is
        Dst  : constant Integer := Target - Direction;
        Src  : constant Integer := Target + Direction;
        A, B : Piece;
        Safe : Boolean;
    begin
        if TB (Dst) /= Empty then
            return False;
        end if;
        if TB (Src) /= Friend_King and then (Direction < 0 or else TB (Src) /= Friend) then
            return False;
        end if;
        A := TB (Target);
        B := TB (Src);
        TB (Target) := Empty;
        TB (Src) := Empty;
        Safe :=
            (Has (TB (Src - 4), Friend) and then Has (TB (Src - 8), Enemy))
            or else (Has (TB (Src - 5), Friend) and then Has (TB (Src - 10), Enemy))
            or else (Has (TB (Dst - 4), Enemy) and then TB (Dst + 4) = Empty)
            or else (Has (TB (Dst - 5), Enemy) and then TB (Dst + 5) = Empty)
            or else (Has (TB (Src + 4), Friend) and then TB (Src + 8) = Enemy_King)
            or else (Has (TB (Src + 5), Friend) and then TB (Src + 10) = Enemy_King)
            or else (TB (Dst + 4) = Enemy_King and then TB (Dst - 4) = Empty)
            or else (TB (Dst + 5) = Enemy_King and then TB (Dst - 5) = Empty);
        TB (Target) := A;
        TB (Src) := B;
        return Safe;
    end Check_Jump;

    procedure Analyze_Move
           (Direction, Src : in Integer)
    is
        Target : constant Integer := Src + Direction;
        A      : Piece;
    begin
        if TB (Target) = Empty then
            if TB (Target + Direction) = Empty then
                Is_Protected (Target) := True;
            end if;
            A := TB (Src);
            TB (Src) := Empty;
            if Check_Jump (Target, 4) or else Check_Jump (Target, 5)
                or else Check_Jump (Target, -4) or else Check_Jump (Target, -5)
                or else (Has (TB (Src + 4), Enemy) and then Check_Jump (Src + 4, 4))
                or else (Has (TB (Src + 5), Enemy) and then Check_Jump (Src + 5, 5))
                or else (Has (TB (Src - 4), Enemy) and then Check_Jump (Src - 4, -4))
                or else (Has (TB (Src - 5), Enemy) and then Check_Jump (Src - 5, -5))
            then
                Denied_Moves := Denied_Moves + 1;
            else
                Undenied_Moves := Undenied_Moves + 1;
            end if;
            TB (Src) := A;
        end if;
    end Analyze_Move;

    procedure Evaluate_Board
           (N     : in Node_Access;
            Print : in Boolean)
    is
        use Ada.Text_IO;

        Friend_Pieces, Enemy_Pieces : Integer := 0;
        Friend_Kings,  Enemy_Kings  : Integer := 0;
        Friend_Kcent,  Friend_Cent  : Integer := 0;
        Enemy_Kcent,   Enemy_Cent   : Integer := 0;
        Gradient : array (4 .. 39) of Integer;
        Total    : Integer := 0;
        X        : Integer;
        F        : Node_Access;

        procedure Count_Enemy
               (I : in Integer) is
        begin
            Enemy_Pieces := Enemy_Pieces + 1;
            Enemy_Cent := Enemy_Cent + Central_Squares (I);
            if I < 36 then
                Analyze_Move (4, I);
                Analyze_Move (5, I);
            end if;
            if Denied_Moves /= 0 and Undenied_Moves = 0 then
                N.Pin := N.Pin + 1;
            end if;
            N.Deny := N.Deny + Unsigned_8'Mod (Denied_Moves);
            N.Mobil := N.Mobil + Unsigned_8'Mod (Undenied_Moves);
        end Count_Enemy;

        procedure Count_Friend
               (I : in Integer) is
        begin
            Friend_Pieces := Friend_Pieces + 1;
            Friend_Cent := Friend_Cent + Central_Squares (I);
            if Has (TB (I - 4), Enemy) and then TB (I - 8) = Empty and then TB (I + 4) /= Empty then
                N.Threat := N.Threat + 1;
            end if;
            if Has (TB (I - 5), Enemy) and then TB (I - 10) = Empty and then TB (I + 5) /= Empty
            then
                N.Threat := N.Threat + 1;
            end if;
        end Count_Friend;

        function D
               (New_V, Old_V : in Unsigned_8)
            return Integer is
        begin
            return Integer (New_V) - Integer (Old_V);
        end D;

        procedure Row
               (Name           : in String;
                Old_V, New_V   : in Integer;
                Score          : in Integer) is
        begin
            Put_Line (Name & ASCII.HT & Img (Old_V) & ASCII.HT & Img (New_V) & ASCII.HT &
                Img (Score));
        end Row;

    begin
        if N.Who = 0 then       --  move was black's
            TB := Brd'Access;
        else
            for I in 0 .. 44 loop
                Flip_Board (44 - I) := Flip (Brd (I));
            end loop;
            TB := Flip_Board'Access;
        end if;

        Is_Protected := (others => False);
        N.Mobil := 0;
        N.Deny := 0;
        N.Pin := 0;
        N.Threat := 0;

        for I in 5 .. 39 loop
            case TB (I) is
                when Enemy_King =>
                    Enemy_Kings := Enemy_Kings + 1;
                    Enemy_Kcent := Enemy_Kcent + Central_Squares (I);
                    Denied_Moves := 0;
                    Undenied_Moves := 0;
                    if I > 8 then
                        Analyze_Move (-4, I);
                        Analyze_Move (-5, I);
                    end if;
                    Count_Enemy (I);
                when Enemy =>
                    Denied_Moves := 0;
                    Undenied_Moves := 0;
                    Count_Enemy (I);
                when Friend_King =>
                    Friend_Kings := Friend_Kings + 1;
                    Friend_Kcent := Friend_Kcent + Central_Squares (I);
                    if Has (TB (I + 4), Enemy) and then TB (I + 8) = Empty
                        and then not (TB (I + 4) = Enemy_King and then TB (I - 4) = Empty)
                    then
                        N.Threat := N.Threat + 1;
                    end if;
                    if Has (TB (I + 5), Enemy) and then TB (I + 10) = Empty
                        and then not (TB (I + 5) = Enemy_King and then TB (I - 5) = Empty)
                    then
                        N.Threat := N.Threat + 1;
                    end if;
                    Count_Friend (I);
                when Friend =>
                    Count_Friend (I);
                when others =>
                    null;
            end case;
        end loop;

        for I in 4 .. 8 loop
            Gradient (I) := (if TB (I) /= Empty then 0 else 32);
        end loop;
        for I in 9 .. 39 loop
            X := (Gradient (I - 4) + Gradient (I - 5)) / 2;
            if TB (I) = Friend then
                Total := Total + X;
            end if;
            Gradient (I) :=
                (if Has (TB (I), Friend) or else (TB (I) = Empty and then not Is_Protected (I))
                 then X else 0);
        end loop;
        N.Gradient := To_Short (Total);

        N.Back := To_Bit (TB (39) = Friend and then TB (37) = Friend and then Enemy_Kings = 0);

        F := N.Father;

        N.Moc2 := To_Bit (F.Mobil > N.Mobil and then Friend_Cent > Enemy_Cent);
        N.Moc3 := To_Bit (F.Mobil <= N.Mobil and then Friend_Cent < Enemy_Cent);
        N.Moc4 := To_Bit (F.Mobil > N.Mobil and then Friend_Cent < Enemy_Cent);
        N.Mode2 := To_Bit (F.Mobil <= N.Mobil and then N.Deny < F.Deny);
        N.Mode3 := To_Bit (F.Mobil > N.Mobil and then N.Deny > F.Deny);
        N.Demmo := To_Bit (N.Deny > F.Deny and then
            Integer (F.Deny) + Integer (F.Mobil) > Integer (N.Deny) + Integer (N.Mobil));

        Total :=
            S_Piece * (Friend_Pieces - Enemy_Pieces) +
            (S_King - S_Piece) * (Friend_Kings - Enemy_Kings) +
            S_Deny * D (N.Deny, F.Deny) +
            S_Pin * D (N.Pin, F.Pin) +
            S_Threat * D (N.Threat, F.Threat) +
            S_Grad * (Integer (N.Gradient) - Integer (F.Gradient)) +
            S_Back * (N.Back - F.Back) +
            S_Moc2 * (N.Moc2 - F.Moc2) +
            S_Moc3 * (N.Moc3 - F.Moc3) +
            S_Moc4 * (N.Moc4 - F.Moc4) +
            S_Mode2 * (N.Mode2 - F.Mode2) +
            S_Mode3 * (N.Mode3 - F.Mode3) +
            S_Demmo * (N.Demmo - F.Demmo) +
            S_Cent * (Friend_Cent - Enemy_Cent) +
            (S_Kcent - S_Cent) * (Friend_Kcent - Enemy_Kcent);
        if N.Mobil = 0 then
            Total := Total + S_Allpin;
        end if;

        if Enemy_Pieces = 0 then
            Total := 30000;
        elsif Friend_Pieces > Enemy_Pieces then
            Total := Total + (S_Advan * Friend_Pieces) / Enemy_Pieces - S_Advan;
        else
            Total := Total - ((S_Advan * Enemy_Pieces) / Friend_Pieces - S_Advan);
        end if;

        if Print then
            Put_Line (ASCII.HT & "Parent" & ASCII.HT & "New" & ASCII.HT & "Score");
            Row ("pieces", Enemy_Pieces, Friend_Pieces, S_Piece * (Friend_Pieces - Enemy_Pieces));
            Row ("kings", Enemy_Kings, Friend_Kings,
                (S_King - S_Piece) * (Friend_Kings - Enemy_Kings));
            Put_Line ("mobil" & ASCII.HT & Img (Integer (F.Mobil)) & ASCII.HT &
                Img (Integer (N.Mobil)));
            Row ("deny", Integer (F.Deny), Integer (N.Deny), S_Deny * D (N.Deny, F.Deny));
            Row ("pin", Integer (F.Pin), Integer (N.Pin), S_Pin * D (N.Pin, F.Pin));
            Row ("threat", Integer (F.Threat), Integer (N.Threat),
                S_Threat * D (N.Threat, F.Threat));
            Row ("grad", Integer (F.Gradient), Integer (N.Gradient),
                S_Grad * (Integer (N.Gradient) - Integer (F.Gradient)));
            Row ("back", F.Back, N.Back, S_Back * (N.Back - F.Back));
            Row ("moc2", F.Moc2, N.Moc2, S_Moc2 * (N.Moc2 - F.Moc2));
            Row ("moc3", F.Moc3, N.Moc3, S_Moc3 * (N.Moc3 - F.Moc3));
            Row ("moc4", F.Moc4, N.Moc4, S_Moc4 * (N.Moc4 - F.Moc4));
            Row ("mode2", F.Mode2, N.Mode2, S_Mode2 * (N.Mode2 - F.Mode2));
            Row ("mode3", F.Mode3, N.Mode3, S_Mode3 * (N.Mode3 - F.Mode3));
            Row ("demmo", F.Demmo, N.Demmo, S_Demmo * (N.Demmo - F.Demmo));
            --  FLTK's format here ends "%dn", not "%d\n".
            Put ("cent" & ASCII.HT & Img (Enemy_Cent) & ASCII.HT & Img (Friend_Cent) & ASCII.HT &
                Img (S_Cent * (Friend_Cent - Enemy_Cent)) & "n");
            Row ("kcent", Enemy_Kcent, Friend_Kcent, S_Kcent * (Friend_Kcent - Enemy_Kcent));
            Put_Line ("total:" & ASCII.HT & ASCII.HT & ASCII.HT & Img (Total));
        else
            N.Value := To_Short (Total);
            Evaluated := Evaluated + 1;
        end if;
    end Evaluate_Board;


    --  Tree management  --

    Free_List : Node_Access;

    function New_Node
        return Node_Access
    is
        N : Node_Access;
    begin
        if Free_List /= null then
            N := Free_List;
            Free_List := N.Brother;
            N.all := (others => <>);
        else
            N := new Node;
        end if;
        Nodes := Nodes + 1;
        return N;
    end New_Node;

    procedure Extract
           (N : in Node_Access)
    is
        I : Node_Access := N.Father;
        J : Node_Access;
    begin
        if I /= null then
            J := I.Son;
            if J = N then
                I.Son := N.Brother;
            else
                while J /= null loop
                    I := J;
                    J := J.Brother;
                    if J = N then
                        I.Brother := N.Brother;
                        exit;
                    end if;
                end loop;
            end if;
        end if;
        N.Brother := null;
    end Extract;

    procedure Kill_Node
           (X : in Node_Access)
    is
        Y : Node_Access := X;
    begin
        if X = null then
            return;
        end if;
        loop
            Nodes := Nodes - 1;
            Kill_Node (Y.Son);
            Y.Son := null;
            exit when Y.Brother = null;
            Y := Y.Brother;
        end loop;
        Y.Brother := Free_List;
        Free_List := X;
    end Kill_Node;

    Seed : Integer := 0;    --  current random number

    --  C's seed = (seed * 13077 + 5051) % 0100000, with int overflow wrapping.
    procedure Next_Seed is
        U : constant Unsigned_32 := Unsigned_32'Mod (Seed) * 13077 + 5051;
        S : constant Integer :=
            (if U >= 2 ** 31 then Integer (Long_Long_Integer (U) - 2 ** 32) else Integer (U));
    begin
        Seed := S rem 8#100000#;
    end Next_Seed;

    procedure Insert
           (N : in Node_Access)
    is
        Val  : constant Integer := Integer (N.Value);
        Prev : Node_Access := null;
        Cur  : Node_Access := N.Father.Son;
        Val1 : Integer;
    begin
        while Cur /= null loop
            Val1 := Integer (Cur.Value);
            if abs (Val - Val1) <= Noise then
                Next_Seed;
                exit when (Unsigned_32'Mod (Seed) and 8#70#) >= 8#60#;
            elsif Val > Val1 then
                exit;
            end if;
            Prev := Cur;
            Cur := Cur.Brother;
        end loop;
        N.Brother := Cur;
        if Prev = null then
            N.Father.Son := N;
        else
            Prev.Brother := N;
        end if;
    end Insert;


    Jump_Happened : Boolean := False;

    procedure Move_Piece
           (F     : in Node_Access;
            I     : in Integer;
            JNode : in Node_Access)
    is
        Direction, J, Jump_Loc : Integer;
        N                      : Node_Access;
        Old_Piece, Jumped      : Piece;
    begin
        for K in 0 .. 3 loop
            Direction := Offset (Brd (I), K);
            exit when Direction = 0;
            J := I + Direction;
            if Brd (J) = Empty then
                if JNode = null
                    and then (not Force_Jumps or else F.Son = null or else F.Son.Jump = 0)
                then
                    N := New_Node;
                    N.Father := F;
                    N.Who := 1 - F.Who;
                    N.From := I;
                    N.To := J;
                    Old_Piece := Brd (I);
                    Brd (I) := Empty;
                    if (if not Has (Old_Piece, King) and then N.Who = 1 then J >= 36 else J <= 8)
                    then
                        N.King := 1;
                        Brd (J) := Old_Piece or King;
                    else
                        Brd (J) := Old_Piece;
                    end if;
                    Evaluate_Board (N, False);
                    Insert (N);
                    Brd (I) := Old_Piece;
                    Brd (J) := Empty;
                end if;
            elsif ((Brd (J) xor Brd (I)) and (White or Black)) = (White or Black)
                and then Brd (J + Direction) = Empty
            then
                if Force_Jumps and then F.Son /= null and then F.Son.Jump = 0 then
                    Kill_Node (F.Son);
                    F.Son := null;
                end if;
                Jump_Loc := J;
                J := J + Direction;
                N := New_Node;
                N.Father := F;
                N.Who := 1 - F.Who;
                N.From := I;
                N.To := J;
                N.Jump := Shift_Left (1, Jump_Loc - 10);
                Old_Piece := Brd (I);
                Brd (I) := Empty;
                if (if not Has (Old_Piece, King) and then N.Who = 1 then J >= 36 else J <= 8) then
                    N.King := 1;
                    Brd (J) := Old_Piece or King;
                else
                    Brd (J) := Old_Piece;
                end if;
                if JNode /= null then
                    N.From := JNode.From;
                    N.Jump := N.Jump or JNode.Jump;
                    N.King := Integer'Max (N.King, JNode.King);
                end if;
                Jumped := Brd (Jump_Loc);
                Brd (Jump_Loc) := Empty;
                Jump_Happened := False;
                Move_Piece (F, J, N);
                if Force_Jumps and Jump_Happened then
                    Kill_Node (N);
                else
                    Evaluate_Board (N, False);
                    Insert (N);
                end if;
                Brd (I) := Old_Piece;
                Brd (J) := Empty;
                Brd (Jump_Loc) := Jumped;
                Jump_Happened := True;
            end if;
        end loop;
    end Move_Piece;

    procedure Expand_Node
           (F : in Node_Access)
    is
        Turn : Piece;
    begin
        if F.Son /= null or else F.Value > 28000 then   --  already done
            return;
        end if;
        Turn := (if F.Who = 1 then Black else White);
        for I in 5 .. 39 loop
            if Has (Brd (I), Turn) then
                Move_Piece (F, I, null);
            end if;
        end loop;
        if F.Son /= null then
            F.Value := To_Short (-Integer (F.Son.Value));
            if F.Brother /= null then
                F.Value := To_Short (Integer (F.Value) - Depth_Penalty);
            end if;
        else
            F.Value := 30000;
        end if;
    end Expand_Node;

    procedure Make_Move
           (N : in Node_Access) is
    begin
        Brd (N.To) := Brd (N.From);
        if N.King = 1 then
            Brd (N.To) := Brd (N.To) or King;
        end if;
        Brd (N.From) := Empty;
        if N.Jump /= 0 then
            for I in 0 .. 31 loop
                if (N.Jump and Shift_Left (1, I)) /= 0 then
                    Brd (10 + I) := Empty;
                end if;
            end loop;
        end if;
    end Make_Move;

    Abort_Flag : Boolean := False;
    Autoplay   : Boolean := False;

    function Did_Abort
        return Boolean is
    begin
        FLTK.Check;
        if Abort_Flag then
            Autoplay := False;
            Abort_Flag := False;
            return True;
        end if;
        return False;
    end Did_Abort;

    function Full_Expand
           (F     : in Node_Access;
            Level : in Integer)
        return Boolean
    is
        Lev       : Integer := Level;
        Old_Board : Board_Array;
        N         : Node_Access;
        Sons      : array (1 .. 128) of Node_Access;
        Count     : Natural := 0;
        Ret       : Boolean := True;
        I         : Positive := 1;
    begin
        if Did_Abort or else Nodes > Max_Nodes - (Max_Ply * 10) or else Evaluated > Max_Evaluate
        then
            return False;
        end if;
        Expand_Node (F);
        if F.Son = null then
            return True;
        end if;
        Old_Board := Brd;
        N := F.Son;
        if N.Jump = 0 and then N.Brother /= null then
            if Lev < 1 then
                return True;
            end if;
            Lev := Lev - 1;
        end if;
        while N /= null loop
            Count := Count + 1;
            Sons (Count) := N;
            N := N.Brother;
        end loop;
        while Ret and then I <= Count loop
            N := Sons (I);
            I := I + 1;
            Make_Move (N);
            Ret := Full_Expand (N, Lev);
            Brd := Old_Board;
            Extract (N);
            Insert (N);
        end loop;
        F.Value := To_Short (-Integer (F.Son.Value));
        return Ret;
    end Full_Expand;

    Depth : Integer := 0;

    function Descend
           (F : in Node_Access)
        return Boolean
    is
        N   : Node_Access;
        Ret : Boolean;
    begin
        if Did_Abort or else Nodes > Max_Nodes or else Depth >= Max_Ply then
            return False;
        end if;
        if F.Son /= null then
            N := F.Son;
            Make_Move (N);
            Depth := Depth + 1;
            Ret := Descend (N);
            Depth := Depth - 1;
            Extract (N);
            Insert (N);
            F.Value := To_Short (-Integer (F.Son.Value));
            return Ret;
        else
            Expand_Node (F);
            return True;
        end if;
    end Descend;

    Debug : Boolean := False;

    --  Returns the best move after Root.
    function Calc_Move
           (Root : in Node_Access)
        return Node_Access
    is
        X          : Integer;
        Save_Board : Board_Array;
    begin
        Expand_Node (Root);
        if Root.Son = null then     --  no move due to loss
            return null;
        end if;
        if Debug then
            Ada.Text_IO.Put_Line ("calcmove() initial nodes = " & Img (Nodes));
        end if;
        Evaluated := 0;
        if Root.Son.Brother /= null then
            X := 1;
            while abs Integer (Root.Value) < 28000 and then Full_Expand (Root, X) loop
                X := X + 1;
            end loop;
            Save_Board := Brd;
            while abs Integer (Root.Value) < 28000 loop
                X := Boolean'Pos (Descend (Root));
                Brd := Save_Board;
                exit when X = 0;
            end loop;
        end if;
        if Debug then
            Ada.Text_IO.Put_Line (" evaluated " & Img (Evaluated) & ", nodes = " & Img (Nodes));
        end if;
        return Root.Son;
    end Calc_Move;


    --  The actual game state  --

    Root, Undo_Root : Node_Access;

    Jump_Boards : array (0 .. 23) of Board_Array;  --  saved boards for undoing jumps
    Next_Jump   : Natural := 0;

    User    : Boolean := False;     --  False = black, True = white
    Playing : Boolean := False;

    procedure New_Game is
    begin
        Brd (0 .. 4) := (others => Blue);
        Brd (5 .. 17) := (others => White);
        Brd (18 .. 26) := (others => Empty);
        Brd (27 .. 39) := (others => Black);
        Brd (40 .. 44) := (others => Blue);
        Brd (13) := Blue;
        Brd (22) := Blue;
        Brd (31) := Blue;

        Central_Squares (15 .. 16) := (others => 1);
        Central_Squares (19 .. 20) := (others => 1);
        Central_Squares (24 .. 25) := (others => 1);
        Central_Squares (28 .. 29) := (others => 1);

        --  Set up the initial search tree.
        Next_Jump := 0;
        Kill_Node (Undo_Root);
        Root := New_Node;
        Undo_Root := Root;

        --  Make it white's move, so the first move is black's.
        Root.Who := 1;
        User := False;
        Playing := True;
    end New_Game;

    procedure Do_Move
           (Move : in Node_Access) is
    begin
        if Move.Jump /= 0 then
            Jump_Boards (Next_Jump) := Brd;
            Next_Jump := Next_Jump + 1;
        end if;
        Make_Move (Move);
        Extract (Move);
        Kill_Node (Root.Son);
        Root.Son := Move;
        Root := Move;
        if Debug then
            Evaluate_Board (Move, True);
        end if;
    end Do_Move;

    function Undo_Move
        return Node_Access
    is
        N : constant Node_Access := Root;
    begin
        if N = Undo_Root then   --  no more undo possible
            return null;
        end if;
        if N.Jump /= 0 then
            Next_Jump := Next_Jump - 1;
            Brd := Jump_Boards (Next_Jump);
        else
            Brd (N.From) := Brd (N.To);
            if N.King = 1 then
                Brd (N.From) := Brd (N.From) and (White or Black);
            end if;
            Brd (N.To) := Empty;
        end if;
        Root := N.Father;
        Kill_Node (N);
        Root.Son := null;
        Root.Value := 0;    --  prevent it from thinking the game is over
        Playing := True;
        if Root = Undo_Root then
            User := False;
        end if;
        return N;
    end Undo_Move;

    --  The text ends in C's NUL, at index 72 counting from 0.
    User_Moves : constant String :=
        "B1D1F1H1A2C2E2G2??B3D3F3H3A4C4E4G4??B5D5F5H5A6C6E6G6??B7D7F7H7A8C8E8G8??" &
        Character'Val (0);

    --  FLTK's usermoves, which gives '?' outside the text.
    function User_Move
           (X, Y : in Integer)
        return Character
    is
        Index : constant Integer := 2 * (X - 5) + Y - 1;
    begin
        if Index < 0 or Index > User_Moves'Length - 1 then
            return '?';
        end if;
        return User_Moves (User_Moves'First + Index);
    end User_Move;


    ----------------------------------------------------------------
    --  The FLTK interface  --

    --  Checkers pieces with built in transparency and drop shadows.
    Pieces : array (0 .. 3) of PNG.PNG_Image :=
       (PNG.Forge.Create (Data => Checkers_Pieces.Black_Checker_PNG),
        PNG.Forge.Create (Data => Checkers_Pieces.White_Checker_PNG),
        PNG.Forge.Create (Data => Checkers_Pieces.Black_Checker_King_PNG),
        PNG.Forge.Create (Data => Checkers_Pieces.White_Checker_King_PNG));

    I_Size : constant := 62;

    procedure Draw_Piece
           (Which : in Piece;
            X, Y  : in Integer)
    is
        Index : Integer;
    begin
        if not FLTK.Draw.Clip_Intersects (X, Y, I_Size, I_Size) then
            return;
        end if;
        case Which is
            when Black      => Index := 0;
            when White      => Index := 1;
            when Black_King => Index := 2;
            when White_King => Index := 3;
            when others     => return;
        end case;
        Pieces (Index).Draw (X, Y);
    end Draw_Piece;

    Box_Size  : constant := 52;
    Border    : constant := 4;
    Board_Size : constant := 8 * Box_Size + Border;
    BM_Offset : constant := 3;

    Erase_This : Integer := 0;      --  real location of dragging piece, don't draw it
    Dragging   : Piece := Empty;    --  piece being dragged
    Drag_X     : Integer := 0;      --  where it is
    Drag_Y     : Integer := 0;
    Show_Legal : Integer := 0;      --  show legal moves

    function Square_X
           (I : in Integer)
        return Integer is
    begin
        return (Character'Pos (User_Move (I, 1)) - Character'Pos ('A')) * Box_Size + BM_Offset;
    end Square_X;

    function Square_Y
           (I : in Integer)
        return Integer is
    begin
        return (Character'Pos (User_Move (I, 2)) - Character'Pos ('1')) * Box_Size + BM_Offset;
    end Square_Y;

    --  FLTK's menus are plain Fl_Menu_Item arrays, popped up with no
    --  button.  These menu buttons, in no window and never shown, hold them
    --  here, and Picked calls the item's callback as do_callback did.
    Main_Menu : MB.Menu_Button := MB.Forge.Create (0, 0, 0, 0);
    Busy_Menu : MB.Menu_Button := MB.Forge.Create (0, 0, 0, 0);

    type Board_Window is new Dbl.Double_Window with null record;

    overriding procedure Draw
           (This : in out Board_Window);

    overriding function Handle
           (This  : in out Board_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;

    Board : Board_Window :=
        (Dbl.Forge.Create (Board_Size, Board_Size, "FLTK Checkers") with null record);

    --  Drag the piece on square J to DX, DY.
    procedure Drag_Piece
           (J      : in Integer;
            DX, DY : in Integer);

    --  Drop the dragged piece on square J.
    procedure Drop_Piece
           (J : in Integer) is
    begin
        if Erase_This = 0 then  --  should not happen!
            return;
        end if;
        Erase_This := 0;
        Dragging := Empty;
        declare
            X : constant Integer := Square_X (J);
            Y : constant Integer := Square_Y (J);
        begin
            if X /= Drag_X or Y /= Drag_Y then
                Board.Set_Damage (FLTK.Damage_Scroll, Drag_X, Drag_Y, I_Size, I_Size);
                Board.Set_Damage (FLTK.Damage_Scroll, X, Y, I_Size, I_Size);
            end if;
        end;
    end Drop_Piece;

    procedure Drag_Piece
           (J      : in Integer;
            DX, DY : in Integer)
    is
        --  Make the halftone shadows line up:  C's (dy & -2) | (dx & 1).
        Y : constant Integer := DY - DY mod 2 + DX mod 2;
    begin
        if J /= Erase_This then     --  should not happen
            Drop_Piece (Erase_This);
        end if;
        if Erase_This = 0 then      --  pick up the old piece
            Drag_X := Square_X (J);
            Drag_Y := Square_Y (J);
            Erase_This := J;
            Dragging := Brd (J);
        end if;
        if DX /= Drag_X or Y /= Drag_Y then
            Board.Set_Damage (FLTK.Damage_Full, Drag_X, Drag_Y, I_Size, I_Size);
            Board.Set_Damage (FLTK.Damage_Full, DX, Y, I_Size, I_Size);
        end if;
        Drag_X := DX;
        Drag_Y := Y;
    end Drag_Piece;

    --  Show a move:  call this before the move, and after an undo.
    procedure Animate
           (Move      : in Node_Access;
            Backwards : in Boolean)
    is
        Steps  : constant := 35;
        F, T   : Integer;
        Ignore : Long_Float;
    begin
        if Show_Legal /= 0 then
            Show_Legal := 0;
            Board.Redraw;
        end if;
        if Move = null then
            return;
        end if;
        F := Move.From;
        T := Move.To;
        if Backwards then
            F := Move.To;
            T := Move.From;
        end if;
        declare
            X1 : constant Integer := Square_X (F);
            Y1 : constant Integer := Square_Y (F);
            X2 : constant Integer := Square_X (T);
            Y2 : constant Integer := Square_Y (T);
        begin
            for J in 0 .. Steps - 1 loop
                Drag_Piece (Move.From, X1 + (X2 - X1) * J / Steps, Y1 + (Y2 - Y1) * J / Steps);
                FLTK.Screen.Flush;
                Ignore := FLTK.Wait (0.01);
            end loop;
        end;
        Drop_Piece (T);
        if Move.Jump /= 0 then
            Board.Redraw;
        end if;
    end Animate;

    Busy : Boolean := False;    --  causes the pop-up abort menu

    procedure Computer_Move
           (Help : in Boolean)
    is
        Move : Node_Access;
    begin
        if not Playing then
            return;
        end if;
        Board.Set_Cursor (FLTK.Wait_Mouse);
        FLTK.Screen.Flush;
        Busy := True;
        Abort_Flag := False;
        Move := Calc_Move (Root);
        Busy := False;
        if Move /= null then
            if not Help and Move.Value <= -30000 then
                FLTK.Asks.Message_Box ((if Move.Who = 1 then "White" else "Black") & " resigns");
                Playing := False;
                Autoplay := False;
                Board.Set_Cursor (FLTK.Default_Mouse);
                return;
            end if;
            Animate (Move, False);
            Do_Move (Move);
        end if;
        Expand_Node (Root);
        if Root.Son = null then
            FLTK.Asks.Message_Box ((if Root.Who = 1 then "Black" else "White") & " has no move");
            Playing := False;
            Autoplay := False;
        end if;
        if not Autoplay then
            Board.Set_Cursor (FLTK.Default_Mouse);
        end if;
    end Computer_Move;


    --  Callbacks  --

    procedure Quit_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        GNAT.OS_Lib.OS_Exit (0);
    end Quit_CB;

    procedure Autoplay_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Autoplay then
            Autoplay := False;
            return;
        end if;
        if not Playing then
            return;
        end if;
        Autoplay := True;
        while Autoplay loop
            Computer_Move (False);
            Computer_Move (False);
        end loop;
    end Autoplay_CB;

    type Window_Access is access Win.Window;
    type Box_Access is access Bx.Box;

    Copyright_Window : Window_Access;
    Copyright_Box    : Box_Access;

    procedure Copyright_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Copyright_Window = null then
            Copyright_Window := new Win.Window'(Win.Forge.Create (400, 270, "Copyright"));
            Copyright_Window.Set_Background_Color (FLTK.White_Color);
            Copyright_Box := new Bx.Box'(Bx.Forge.Create
                (Copyright_Window.all, 20, 0, 380, 270, Copyright));
            Copyright_Box.Set_Label_Size (10);
            Copyright_Box.Set_Alignment (FLTK.Align_Left + FLTK.Align_Inside + FLTK.Align_Wrap);
            Copyright_Window.End_Current;
        end if;
        Copyright_Window.Hotspot (Copyright_Window.all);
        Copyright_Window.Set_Non_Modal;
        Copyright_Window.Show;
    end Copyright_CB;

    --  The item's flags, in the menu that called back.
    procedure Set_Toggle
           (Item  : in out FLTK.Widgets.Widget'Class;
            Name  : in     String;
            Value : in     Boolean) is
    begin
        Mn.Menu'Class (Item).Find_Item (Name).Set_Flags
            (if Value then FLTK.Flag_Toggle + FLTK.Flag_Value else FLTK.Flag_Toggle);
    end Set_Toggle;

    procedure Debug_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Debug := not Debug;
        Set_Toggle (Item, "Debug", Debug);
    end Debug_CB;

    procedure Forced_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Force_Jumps := not Force_Jumps;
        Set_Toggle (Item, "Forced jumps rule", Force_Jumps);
        Kill_Node (Root.Son);
        Root.Son := null;
        if Show_Legal /= 0 then
            Expand_Node (Root);
            Board.Redraw;
        end if;
    end Forced_CB;

    procedure Move_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Playing then
            Computer_Move (True);
        end if;
        if Playing then
            Computer_Move (False);
        end if;
    end Move_CB;

    procedure New_Game_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Show_Legal := 0;
        New_Game;
        Board.Redraw;
    end New_Game_CB;

    procedure Legal_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Show_Legal = 1 then
            Show_Legal := 0;
            Board.Redraw;
            return;
        end if;
        if not Playing then
            return;
        end if;
        Expand_Node (Root);
        Show_Legal := 1;
        Board.Redraw;
    end Legal_CB;

    procedure Predict_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Show_Legal = 2 then
            Show_Legal := 0;
            Board.Redraw;
            return;
        end if;
        if Playing then
            Expand_Node (Root);
        end if;
        Show_Legal := 2;
        Board.Redraw;
    end Predict_CB;

    procedure Switch_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        User := not User;
        Computer_Move (False);
    end Switch_CB;

    procedure Undo_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Animate (Undo_Move, True);
        Animate (Undo_Move, True);
    end Undo_CB;

    type Slider_Access is access Sld.Slider;
    type Output_Access is access VO.Value_Output;

    Intel_Window : Window_Access;
    Intel_Slider : Slider_Access;
    Intel_Output : Output_Access;

    procedure Intel_Slider_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        V : constant Long_Float := Sld.Slider (Item).Get_Value;
        N : constant Integer := Integer (Long_Float'Truncation (V * V));
    begin
        Intel_Output.Set_Value (Long_Float (N));
        Max_Evaluate := N;
        Max_Nodes := N;
    end Intel_Slider_CB;

    procedure Intel_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        if Intel_Window = null then
            Intel_Window := new Win.Window'(Win.Forge.Create (200, 25, "Checkers Intelligence"));
            Intel_Slider := new Sld.Slider'(Sld.Forge.Create (Intel_Window.all, 60, 0, 140, 25));
            Sld.Extra.Set_Kind (Intel_Slider.all, Sld.Horizontal_Nice_Slider);
            Intel_Slider.Set_Bounds (1.0, 500.0);
            Intel_Slider.Set_Value (50.0);
            Intel_Slider.Set_Callback (Intel_Slider_CB'Unrestricted_Access);
            Intel_Output := new VO.Value_Output'(VO.Forge.Create (Intel_Window.all, 0, 0, 60, 25));
            Intel_Output.Set_Value (Long_Float (Max_Evaluate));
            Intel_Window.Set_Resizable (Intel_Slider.all);
        end if;
        Intel_Window.Hotspot (Intel_Window.all);
        Intel_Window.Set_Non_Modal;
        Intel_Window.Show;
    end Intel_CB;

    procedure Stop_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Abort_Flag := True;
    end Stop_CB;

    procedure Continue_CB
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        null;
    end Continue_CB;


    --  The board  --

    procedure Draw
           (This : in out Board_Window)
    is
        use FLTK.Draw;

        N   : Node_Access;
        Num : Integer;

        function Next
               (N : in Node_Access)
            return Node_Access is
        begin
            return (if Show_Legal = 2 then N.Son else N.Brother);
        end Next;

    begin
        --  Draw the board itself.
        Draw_Box (0, 0, This.Get_W, This.Get_H, This.Get_Box, This.Get_Background_Color);
        --  Draw all the dark tiles.
        Set_Color (10);
        for X in 0 .. 7 loop
            for Y in 0 .. 7 loop
                if (X + Y) mod 2 = 0 then
                    Rect_Fill (Border + X * Box_Size, Border + Y * Box_Size,
                        Box_Size - Border, Box_Size - Border);
                end if;
            end loop;
        end loop;
        --  Draw the outlines around the fields.
        Set_Color (FLTK.Dark3_Color);
        for X in 0 .. 8 loop
            Rect_Fill (X * Box_Size, 0, Border, This.Get_H);
            Rect_Fill (0, X * Box_Size, This.Get_W, Border);
        end loop;
        for J in 5 .. 39 loop
            if J /= Erase_This then
                Draw_Piece (Brd (J), Square_X (J), Square_Y (J));
            end if;
        end loop;
        if Show_Legal /= 0 then
            Set_Color (FLTK.White_Color);
            N := Root.Son;
            while N /= null loop
                declare
                    X1 : constant Integer := Square_X (N.From) + Box_Size / 2 - 5;
                    Y1 : constant Integer := Square_Y (N.From) + Box_Size / 2 - 5;
                    X2 : constant Integer := Square_X (N.To) + Box_Size / 2 - 5;
                    Y2 : constant Integer := Square_Y (N.To) + Box_Size / 2 - 5;
                begin
                    Line (X1, Y1, X2, Y2);
                    Push_Matrix;
                    Mult_Matrix (Long_Float (X2 - X1), Long_Float (Y2 - Y1),
                        Long_Float (Y1 - Y2), Long_Float (X2 - X1),
                        Long_Float (X2), Long_Float (Y2));
                    Begin_Polygon;
                    Vertex (0.0, 0.0);
                    Vertex (-0.3, 0.1);
                    Vertex (-0.3, -0.1);
                    End_Polygon;
                    Pop_Matrix;
                end;
                N := Next (N);
            end loop;
            Num := 1;
            Set_Color (FLTK.Black_Color);
            Set_Font (FLTK.Helvetica_Bold, 10);
            N := Root.Son;
            while N /= null loop
                declare
                    X1 : constant Integer := Square_X (N.From) + Box_Size / 2 - 5;
                    Y1 : constant Integer := Square_Y (N.From) + Box_Size / 2 - 5;
                    X2 : constant Integer := Square_X (N.To) + Box_Size / 2 - 5;
                    Y2 : constant Integer := Square_Y (N.To) + Box_Size / 2 - 5;
                begin
                    Draw_Text
                       (X1 + Integer (Long_Float'Truncation (Long_Float (X2 - X1) * 0.85)) - 3,
                        Y1 + Integer (Long_Float'Truncation (Long_Float (Y2 - Y1) * 0.85)) + 5,
                        Img (Num));
                end;
                Num := Num + 1;
                N := Next (N);
            end loop;
        end if;
        if Dragging /= Empty then
            Draw_Piece (Dragging, Drag_X, Drag_Y);
        end if;
    end Draw;

    Delta_X, Delta_Y : Integer := 0;

    --  Pop up a menu at the mouse, and call back the item picked.
    procedure Pop_Up
           (M : in out MB.Menu_Button)
    is
        Index : constant Mn.Extended_Index :=
            M.Popup (FLTK.Events.Mouse_X, FLTK.Events.Mouse_Y);
    begin
        if Index /= Mn.No_Index then
            M.Picked (FLTK.Menu_Items.Menu_Item (M.Item (Index).Data.all));
        end if;
    end Pop_Up;

    function Handle
           (This  : in out Board_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        pragma Unreferenced (This);
        T, N    : Node_Access;
        Dist, D : Integer;
    begin
        if Busy then
            case Event is
                when FLTK.Push =>
                    Pop_Up (Busy_Menu);
                    return FLTK.Handled;
                when FLTK.Shortcut =>
                    return (if Busy_Menu.Test_Shortcut /= null
                            then FLTK.Handled else FLTK.Not_Handled);
                when others =>
                    return FLTK.Not_Handled;
            end case;
        end if;
        case Event is
            when FLTK.Push =>
                if FLTK.Events.Last_Button > FLTK.Left_Button then
                    Pop_Up (Main_Menu);
                    return FLTK.Handled;
                end if;
                if Playing then
                    Expand_Node (Root);
                    T := Root.Son;
                    while T /= null loop
                        declare
                            X : constant Integer := Square_X (T.From);
                            Y : constant Integer := Square_Y (T.From);
                        begin
                            if FLTK.Events.Is_Inside (X, Y, Box_Size, Box_Size) then
                                Delta_X := FLTK.Events.Mouse_X - X;
                                Delta_Y := FLTK.Events.Mouse_Y - Y;
                                Drag_Piece (T.From, X, Y);
                                return FLTK.Handled;
                            end if;
                        end;
                        T := T.Brother;
                    end loop;
                end if;
                return FLTK.Not_Handled;
            when FLTK.Shortcut =>
                return (if Main_Menu.Test_Shortcut /= null
                        then FLTK.Handled else FLTK.Not_Handled);
            when FLTK.Drag =>
                Drag_Piece (Erase_This, FLTK.Events.Mouse_X - Delta_X,
                    FLTK.Events.Mouse_Y - Delta_Y);
                return FLTK.Handled;
            when FLTK.Release =>
                --  Find the closest legal move the piece was dropped on.
                Dist := 50 * 50;
                N := null;
                T := Root.Son;
                while T /= null loop
                    if T.From = Erase_This then
                        D := (FLTK.Events.Mouse_X - Delta_X - Square_X (T.To)) ** 2 +
                            (FLTK.Events.Mouse_Y - Delta_Y - Square_Y (T.To)) ** 2;
                        if D < Dist then
                            Dist := D;
                            N := T;
                        end if;
                    end if;
                    T := T.Brother;
                end loop;
                if N = null then    --  none found
                    Drop_Piece (Erase_This);
                    return FLTK.Handled;
                end if;
                Drop_Piece (N.To);
                Do_Move (N);
                if Show_Legal /= 0 then
                    Show_Legal := 0;
                    Board.Redraw;
                end if;
                if N.Jump /= 0 then
                    Board.Redraw;
                end if;
                Computer_Move (False);
                return FLTK.Handled;
            when others =>
                return FLTK.Not_Handled;
        end case;
    end Handle;


    procedure Add
           (M      : in out MB.Menu_Button;
            Text   : in     String;
            Key    : in     Character;
            Action : in     FLTK.Widgets.Widget_Callback;
            Flags  : in     FLTK.Menu_Flag := FLTK.Flag_Normal) is
    begin
        if Key = ASCII.NUL then
            M.Add (Text, Action, FLTK.No_Key, Flags);
        else
            M.Add (Text, Action, FLTK.Press (Key), Flags);
        end if;
    end Add;

    function C_Time
           (T : in System.Address)
        return Interfaces.C.long;
    pragma Import (C, C_Time, "time");

begin

    --  C's int seed = time (0), keeping the low 32 bits.
    declare
        U : constant Unsigned_32 := Unsigned_32'Mod (C_Time (System.Null_Address));
    begin
        Seed := (if U >= 2 ** 31 then Integer (Long_Long_Integer (U) - 2 ** 32) else Integer (U));
    end;
    New_Game;

    for P of Pieces loop
        P.Scale (P.Get_Data_W / 2, P.Get_Data_H / 2);
    end loop;

    Add (Main_Menu, "Autoplay", 'a', Autoplay_CB'Unrestricted_Access);
    Add (Main_Menu, "Legal moves", 'l', Legal_CB'Unrestricted_Access);
    Add (Main_Menu, "Move for me", 'm', Move_CB'Unrestricted_Access);
    Add (Main_Menu, "New game", 'n', New_Game_CB'Unrestricted_Access);
    Add (Main_Menu, "Predict", 'p', Predict_CB'Unrestricted_Access);
    Add (Main_Menu, "Switch sides", 's', Switch_CB'Unrestricted_Access);
    Add (Main_Menu, "Undo", 'u', Undo_CB'Unrestricted_Access, FLTK.Flag_Divider);
    Add (Main_Menu, "Forced jumps rule", 'f', Forced_CB'Unrestricted_Access,
        FLTK.Flag_Toggle + FLTK.Flag_Value);
    Add (Main_Menu, "Debug", 'd', Debug_CB'Unrestricted_Access, FLTK.Flag_Toggle);
    Add (Main_Menu, "Intelligence...", 'i', Intel_CB'Unrestricted_Access, FLTK.Flag_Divider);
    Add (Main_Menu, "Copyright", 'c', Copyright_CB'Unrestricted_Access);
    Add (Main_Menu, "Quit", 'q', Quit_CB'Unrestricted_Access);

    Add (Busy_Menu, "Stop", '.', Stop_CB'Unrestricted_Access);
    Add (Busy_Menu, "Autoplay", 'a', Autoplay_CB'Unrestricted_Access);
    Add (Busy_Menu, "Continue", ASCII.NUL, Continue_CB'Unrestricted_Access);
    Add (Busy_Menu, "Debug", 'd', Debug_CB'Unrestricted_Access, FLTK.Flag_Toggle);
    Add (Busy_Menu, "Intelligence...", 'i', Intel_CB'Unrestricted_Access);
    Add (Busy_Menu, "Copyright", 'c', Copyright_CB'Unrestricted_Access);
    Add (Busy_Menu, "Quit", 'q', Quit_CB'Unrestricted_Access);

    --  FLTK asks for FL_DOUBLE | FL_INDEX, which X11 refuses at once for
    --  FL_DOUBLE, as it does Double_Buffer (Fl_X11_Screen_Driver.cxx).
    FLTK.Screen.Set_Visual_Mode (FLTK.Screen.Double_Buffer);
    Board.Set_Background_Color (FLTK.Background_Color);
    Board.Set_Callback (Quit_CB'Unrestricted_Access);
    Board.Show_With_Args;
    return FLTK.Run;

end Checkers;
