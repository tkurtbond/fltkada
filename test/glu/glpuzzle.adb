--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/glpuzzle.cxx, with its trackball.c: a sliding-block puzzle
--  drawn with GL through GLUT.  The left mouse button slides the pieces,
--  the middle one spins the puzzle, and the right one has a menu; "s"
--  solves it, breadth first.  The arithmetic is the C++'s, float where it
--  has float and double where it has double, so that it draws the same.
--  Guided by pofltk's GlPuzzle.Mod.


with

    Ada.Command_Line,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.GLU,
    FLTK.GLUT,
    FLTK.Static,
    GL1,
    GNAT.OS_Lib,
    Interfaces.C;

use

    GL1;

use type

    GL1.GLbitfield,
    GL1.GLdouble,
    GL1.GLfloat,
    GL1.GLint,
    FLTK.GLUT.Visibility_State;


function Glpuzzle
    return Integer
is

    package Glut renames FLTK.GLUT;


    --  The C library's float functions and asin, as trackball.c calls
    --  them, so that the results are the C++ program's to the bit.
    function sqrtf (X : in GLfloat) return GLfloat
        with Import, Convention => Intrinsic, External_Name => "sqrtf";
    function sinf (X : in GLfloat) return GLfloat
        with Import, Convention => Intrinsic, External_Name => "sinf";
    function cosf (X : in GLfloat) return GLfloat
        with Import, Convention => Intrinsic, External_Name => "cosf";
    function asin (X : in GLdouble) return GLdouble
        with Import, Convention => Intrinsic, External_Name => "asin";




    --  The Puzzle  --

    Width  : constant := 4;
    Height : constant := 5;
    Pieces : constant := 10;

    Offset_X : constant GLfloat := -2.0;
    Offset_Y : constant GLfloat := -2.5;
    Offset_Z : constant GLfloat := -0.5;

    subtype Piece_Number is Integer range 0 .. Pieces;

    --  Rows from the top, then columns:  each square's piece, 0 if empty.
    type Config is array (0 .. Height - 1, 0 .. Width - 1) of Piece_Number;

    Hash_Size : constant := 10_691;

    type Puzzle;
    type Puzzle_Access is access Puzzle;

    type Puzzle is record
        Back_Ptr   : Puzzle_Access;
        Soln_Ptr   : Puzzle_Access;
        Pieces     : Config;
        Next       : Puzzle_Access;
        Hash_Value : Interfaces.C.unsigned;
    end record;

    type List_Entry;
    type List_Access is access List_Entry;

    type List_Entry is record
        Puzzle : Puzzle_Access;
        Next   : List_Access;
    end record;

    procedure Free is new Ada.Unchecked_Deallocation (Puzzle, Puzzle_Access);
    procedure Free is new Ada.Unchecked_Deallocation (List_Entry, List_Access);

    --  Pieces of the same shape are the same to the solver.
    Convert : constant array (Piece_Number) of Natural := (0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 4);

    subtype Colour is GLubyte_Array (0 .. 2);

    Colours : constant array (Piece_Number) of Colour :=
       ((0, 0, 0),
        (255, 255, 127), (255, 255, 127), (255, 255, 127), (255, 255, 127),
        (255, 127, 255), (255, 127, 255), (255, 127, 255), (255, 127, 255),
        (255, 127, 127),
        (255, 255, 255));

    X_Size : constant array (Piece_Number) of Natural := (0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2);
    Y_Size : constant array (Piece_Number) of Natural := (0, 1, 1, 1, 1, 2, 2, 2, 2, 1, 2);
    Z_Size : constant array (Piece_Number) of GLfloat :=
        (0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.6);

    Start_Config : constant Config :=
       ((8, 10, 10, 7),
        (8, 10, 10, 7),
        (6, 9, 9, 5),
        (6, 4, 3, 5),
        (2, 0, 0, 1));

    The_Puzzle : Config := Start_Config;

    --  The directions:  0 left, 1 up, 2 right, 3 down.
    X_Adds : constant array (0 .. 3) of Integer := (-1, 0, 1, 0);
    Y_Adds : constant array (0 .. 3) of Integer := (0, -1, 0, 1);

    Hash_Table   : array (0 .. Hash_Size - 1) of Puzzle_Access := (others => null);
    Start_Puzzle : Puzzle_Access := null;
    Puzzles      : List_Access := null;
    Last_Entry   : List_Access := null;

    Move_Speed   : constant GLfloat := 0.2;
    Moving_Piece : Piece_Number := 0;
    Move_X       : GLfloat := 0.0;
    Move_Y       : GLfloat := 0.0;

    Double_Buffer : Boolean := True;
    Depth         : Boolean := True;
    Visible       : Boolean := False;

    Win_W : Integer := 400;
    Win_H : Integer := 300;

    Viewport : GLint_Array (0 .. 3) := (others => 0);

    --  GL keeps the select buffer until glRenderMode (GL_RENDER), so it
    --  lives here, not in Select_Piece.
    Select_Buf : GLuint_Array (0 .. 1023) := (others => 0);

    subtype Vec3   is GLfloat_Array (0 .. 2);
    subtype Vec4   is GLfloat_Array (0 .. 3);
    subtype Matrix is GLfloat_Array (0 .. 15);

    Cur_Quat  : Vec4 := (others => 0.0);
    Last_Quat : Vec4 := (others => 0.0);




    --  The Trackball, from trackball.c  --

    Trackball_Size : constant GLfloat := 0.8;
    Max_Velocity   : constant GLfloat := 0.1;
    Renorm_Count   : constant := 97;

    Quat_Count : Natural := 0;  --  add_quats' count

    function Cross
           (V1, V2 : in Vec3)
        return Vec3 is
    begin
        return ((V1 (1) * V2 (2)) - (V1 (2) * V2 (1)),
                (V1 (2) * V2 (0)) - (V1 (0) * V2 (2)),
                (V1 (0) * V2 (1)) - (V1 (1) * V2 (0)));
    end Cross;

    function Length
           (V : in Vec3)
        return GLfloat is
    begin
        return sqrtf (V (0) * V (0) + V (1) * V (1) + V (2) * V (2));
    end Length;

    function Dot
           (V1, V2 : in GLfloat_Array)
        return GLfloat is
    begin
        return V1 (V1'First) * V2 (V2'First) + V1 (V1'First + 1) * V2 (V2'First + 1)
            + V1 (V1'First + 2) * V2 (V2'First + 2);
    end Dot;

    function Project_To_Sphere
           (R, X, Y : in GLfloat)
        return GLfloat
    is
        D : constant GLfloat := sqrtf (X * X + Y * Y);
        T : GLfloat;
    begin
        if GLdouble (D) < GLdouble (R) * 0.70710678118654752440 then  --  inside the sphere
            return sqrtf (R * R - D * D);
        else  --  on the hyperbola
            T := GLfloat (GLdouble (R) / 1.41421356237309504880);
            return T * T / D;
        end if;
    end Project_To_Sphere;

    procedure Axis_To_Quat
           (A   : in     Vec3;
            Phi : in     GLfloat;
            Q   :    out Vec4)
    is
        Scale : constant GLfloat := 1.0 / Length (A);
        S     : constant GLfloat := sinf (Phi / 2.0);
    begin
        for I in 0 .. 2 loop
            Q (I) := A (I) * Scale * S;
        end loop;
        Q (3) := cosf (Phi / 2.0);
    end Axis_To_Quat;

    procedure Trackball
           (Q                  :    out Vec4;
            P1_X, P1_Y         : in     GLfloat;
            P2_X, P2_Y         : in     GLfloat)
    is
        P1, P2 : Vec3;
        T      : GLfloat;
    begin
        if P1_X = P2_X and P1_Y = P2_Y then  --  no rotation
            Q := (0.0, 0.0, 0.0, 1.0);
            return;
        end if;
        P1 := (P1_X, P1_Y, Project_To_Sphere (Trackball_Size, P1_X, P1_Y));
        P2 := (P2_X, P2_Y, Project_To_Sphere (Trackball_Size, P2_X, P2_Y));
        T := Length ((P1 (0) - P2 (0), P1 (1) - P2 (1), P1 (2) - P2 (2))) / (2.0 * Trackball_Size);
        if T > Max_Velocity then
            T := Max_Velocity;
        end if;
        if T < -Max_Velocity then
            T := -Max_Velocity;
        end if;
        Axis_To_Quat (Cross (P2, P1), GLfloat (2.0 * asin (GLdouble (T))), Q);
    end Trackball;

    procedure Normalize_Quat
           (Q : in out Vec4)
    is
        Mag : constant GLfloat := Q (0) * Q (0) + Q (1) * Q (1) + Q (2) * Q (2) + Q (3) * Q (3);
    begin
        for I in Q'Range loop
            Q (I) := Q (I) / Mag;
        end loop;
    end Normalize_Quat;

    --  Q2 := Q1 then Q2.  The C++ has a destination, which glpuzzle
    --  always makes Q2.
    procedure Add_Quats
           (Q1 : in     Vec4;
            Q2 : in out Vec4)
    is
        T3 : constant Vec3 := Cross (Q2 (0 .. 2), Q1 (0 .. 2));
        TF : Vec4;
    begin
        for I in 0 .. 2 loop
            TF (I) := T3 (I) + (Q1 (I) * Q2 (3) + Q2 (I) * Q1 (3));
        end loop;
        TF (3) := Q1 (3) * Q2 (3) - Dot (Q1, Q2);
        Q2 := TF;
        Quat_Count := Quat_Count + 1;
        if Quat_Count > Renorm_Count then
            Quat_Count := 0;
            Normalize_Quat (Q2);
        end if;
    end Add_Quats;

    --  A row-major matrix that glMultMatrixf reads as GL's column-major.
    function Build_Rot_Matrix
           (Q : in Vec4)
        return Matrix is
    begin
        return (1.0 - 2.0 * (Q (1) * Q (1) + Q (2) * Q (2)),
                2.0 * (Q (0) * Q (1) - Q (2) * Q (3)),
                2.0 * (Q (2) * Q (0) + Q (1) * Q (3)),
                0.0,
                2.0 * (Q (0) * Q (1) + Q (2) * Q (3)),
                1.0 - 2.0 * (Q (2) * Q (2) + Q (0) * Q (0)),
                2.0 * (Q (1) * Q (2) - Q (0) * Q (3)),
                0.0,
                2.0 * (Q (2) * Q (0) - Q (1) * Q (3)),
                2.0 * (Q (1) * Q (2) + Q (0) * Q (3)),
                1.0 - 2.0 * (Q (1) * Q (1) + Q (0) * Q (0)),
                0.0,
                0.0, 0.0, 0.0, 1.0);
    end Build_Rot_Matrix;




    --  Drawing  --

    Box_Coords : constant array (0 .. 23) of Vec3 :=
       ((0.2, 0.2, 0.9), (0.8, 0.2, 0.9), (0.8, 0.8, 0.9), (0.2, 0.8, 0.9),
        (0.2, 0.1, 0.8), (0.8, 0.1, 0.8), (0.9, 0.2, 0.8), (0.9, 0.8, 0.8),
        (0.8, 0.9, 0.8), (0.2, 0.9, 0.8), (0.1, 0.8, 0.8), (0.1, 0.2, 0.8),
        (0.2, 0.1, 0.2), (0.8, 0.1, 0.2), (0.9, 0.2, 0.2), (0.9, 0.8, 0.2),
        (0.8, 0.9, 0.2), (0.2, 0.9, 0.2), (0.1, 0.8, 0.2), (0.1, 0.2, 0.2),
        (0.2, 0.2, 0.1), (0.8, 0.2, 0.1), (0.8, 0.8, 0.1), (0.2, 0.8, 0.1));

    Box_Normals : constant array (0 .. 25) of Vec3 :=
       ((0.0, 0.0, 1.0), (0.0, 1.0, 0.0), (1.0, 0.0, 0.0),
        (0.0, 0.0, -1.0), (0.0, -1.0, 0.0), (-1.0, 0.0, 0.0),
        (0.7071, 0.7071, 0.0), (0.7071, -0.7071, 0.0),
        (-0.7071, 0.7071, 0.0), (-0.7071, -0.7071, 0.0),
        (0.7071, 0.0, 0.7071), (0.7071, 0.0, -0.7071),
        (-0.7071, 0.0, 0.7071), (-0.7071, 0.0, -0.7071),
        (0.0, 0.7071, 0.7071), (0.0, 0.7071, -0.7071),
        (0.0, -0.7071, 0.7071), (0.0, -0.7071, -0.7071),
        (0.5774, 0.5774, 0.5774), (0.5774, 0.5774, -0.5774),
        (0.5774, -0.5774, 0.5774), (0.5774, -0.5774, -0.5774),
        (-0.5774, 0.5774, 0.5774), (-0.5774, 0.5774, -0.5774),
        (-0.5774, -0.5774, 0.5774), (-0.5774, -0.5774, -0.5774));

    --  Quadrilaterals to 17, then triangles, with -1 for no corner.
    Box_Faces : constant array (0 .. 25, 0 .. 3) of Integer :=
       ((0, 1, 2, 3), (9, 8, 16, 17), (6, 14, 15, 7), (20, 23, 22, 21),
        (12, 13, 5, 4), (19, 11, 10, 18),
        (7, 15, 16, 8), (13, 14, 6, 5), (18, 10, 9, 17), (19, 12, 4, 11),
        (1, 6, 7, 2), (14, 21, 22, 15), (11, 0, 3, 10), (20, 19, 18, 23),
        (3, 2, 8, 9), (17, 16, 22, 23), (4, 5, 1, 0), (20, 21, 13, 12),
        (2, 7, 8, -1), (16, 15, 22, -1), (5, 6, 1, -1), (13, 21, 14, -1),
        (10, 3, 9, -1), (18, 17, 23, -1), (11, 4, 0, -1), (20, 12, 19, -1));

    Container_Coords : constant array (0 .. 23) of Vec3 :=
       ((-0.1, -0.1, 1.0), (-0.1, -0.1, -0.1), (4.1, -0.1, -0.1), (4.1, -0.1, 1.0),
        (1.0, -0.1, 0.6), (3.0, -0.1, 0.6), (1.0, -0.1, 0.0), (3.0, -0.1, 0.0),
        (1.0, 0.0, 0.0), (3.0, 0.0, 0.0), (3.0, 0.0, 0.6), (1.0, 0.0, 0.6),
        (0.0, 0.0, 1.0), (4.0, 0.0, 1.0), (4.0, 0.0, 0.0), (0.0, 0.0, 0.0),
        (0.0, 5.0, 0.0), (0.0, 5.0, 1.0), (4.0, 5.0, 1.0), (4.0, 5.0, 0.0),
        (-0.1, 5.1, -0.1), (4.1, 5.1, -0.1), (4.1, 5.1, 1.0), (-0.1, 5.1, 1.0));

    Container_Normals : constant array (0 .. 23) of Vec3 :=
       ((0.0, -1.0, 0.0), (0.0, -1.0, 0.0), (0.0, -1.0, 0.0), (0.0, -1.0, 0.0),
        (0.0, -1.0, 0.0), (0.0, 1.0, 0.0), (0.0, 1.0, 0.0), (0.0, 1.0, 0.0),
        (1.0, 0.0, 0.0), (1.0, 0.0, 0.0), (1.0, 0.0, 0.0), (-1.0, 0.0, 0.0),
        (-1.0, 0.0, 0.0), (-1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, -1.0),
        (0.0, 0.0, -1.0), (0.0, 0.0, 1.0), (0.0, 0.0, 1.0), (0.0, 0.0, 1.0),
        (0.0, 0.0, 1.0), (0.0, 0.0, 1.0), (0.0, 0.0, 1.0), (0.0, 0.0, 1.0));

    Container_Faces : constant array (0 .. 23, 0 .. 3) of Natural :=
       ((1, 6, 4, 0), (0, 4, 5, 3), (1, 2, 7, 6), (7, 2, 3, 5), (16, 19, 18, 17),
        (23, 22, 21, 20), (12, 11, 8, 15), (10, 13, 14, 9),
        (15, 16, 17, 12), (2, 21, 22, 3), (6, 8, 11, 4),
        (1, 0, 23, 20), (14, 13, 18, 19), (9, 7, 5, 10),
        (12, 13, 10, 11),
        (1, 20, 21, 2), (4, 11, 10, 5),
        (15, 8, 19, 16), (19, 8, 9, 14), (8, 6, 7, 9), (0, 3, 13, 12),
        (13, 3, 22, 18), (18, 22, 23, 17), (17, 23, 0, 12));

    --  Draws a piece, bevelled.
    procedure Draw_Box
           (Piece        : in Piece_Number;
            X_Off, Y_Off : in GLfloat)
    is
        X_Len : constant Natural := X_Size (Piece);
        Y_Len : constant Natural := Y_Size (Piece);
        Z_Len : constant GLfloat := Z_Size (Piece);

        procedure Corner
               (Index : in Integer)
        is
            V       : Vec3 renames Box_Coords (Index);
            X, Y, Z : GLfloat;
        begin
            X := V (0) + Offset_X;
            if V (0) > 0.5 then
                X := X + GLfloat (X_Len - 1);
            end if;
            Y := V (1) + Offset_Y;
            if V (1) > 0.5 then
                Y := Y + GLfloat (Y_Len - 1);
            end if;
            Z := V (2) + Offset_Z;
            if V (2) > 0.5 then
                Z := Z + (Z_Len - 1.0);
            end if;
            glVertex3f (X_Off + X, Y_Off + Y, Z);
        end Corner;

        procedure Faces
               (First, Last : in Natural;
                Corners     : in Positive) is
        begin
            for I in First .. Last loop
                glNormal3fv (Box_Normals (I));
                for K in 0 .. Corners - 1 loop
                    if Box_Faces (I, K) /= -1 then
                        Corner (Box_Faces (I, K));
                    end if;
                end loop;
            end loop;
        end Faces;
    begin
        glColor3ubv (Colours (Piece));
        glBegin (GL_QUADS);
        Faces (0, 17, 4);
        glEnd;
        glBegin (GL_TRIANGLES);
        Faces (18, Box_Faces'Last (1), 3);
        glEnd;
    end Draw_Box;

    --  Draws the container.  Y is reversed here because the model has it
    --  reversed.
    procedure Draw_Container is
    begin
        glColor3ub (209, 103, 23);  --  arbitrary bright wood-like colour
        glBegin (GL_QUADS);
        for I in Container_Faces'Range (1) loop
            declare
                N : Vec3 renames Container_Normals (I);
            begin
                glNormal3f (N (0), -N (1), N (2));
            end;
            for K in reverse 0 .. 3 loop
                declare
                    V : Vec3 renames Container_Coords (Container_Faces (I, K));
                begin
                    glVertex3f (V (0) + Offset_X, -(V (1) + Offset_Y), V (2) + Offset_Z);
                end;
            end loop;
        end loop;
        glEnd;
    end Draw_Container;

    procedure Draw_All
    is
        Done  : array (1 .. Pieces) of Boolean := (others => False);
        Piece : Piece_Number;
    begin
        glMatrixMode (GL_MODELVIEW);
        glLoadIdentity;
        glTranslatef (0.0, 0.0, -10.0);
        glMultMatrixf (Build_Rot_Matrix (Cur_Quat));
        glRotatef (180.0, 0.0, 0.0, 1.0);

        if Depth then
            glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        else
            glClear (GL_COLOR_BUFFER_BIT);
        end if;
        glLoadName (0);
        Draw_Container;
        for I in Config'Range (1) loop
            for J in Config'Range (2) loop
                Piece := The_Puzzle (I, J);
                if Piece /= 0 and then not Done (Piece) then
                    Done (Piece) := True;
                    glLoadName (GLuint (Piece));
                    if Piece = Moving_Piece then
                        Draw_Box (Piece, Move_X, Move_Y);
                    else
                        Draw_Box (Piece, GLfloat (J), GLfloat (I));
                    end if;
                end if;
            end loop;
        end loop;
    end Draw_All;

    procedure Redraw is
    begin
        glMatrixMode (GL_PROJECTION);
        glLoadIdentity;
        FLTK.GLU.Perspective
           (45.0, Long_Float (GLdouble (Viewport (2)) * 1.0 / GLdouble (Viewport (3))), 0.1, 100.0);

        Draw_All;

        if Double_Buffer then
            Glut.Swap_Buffers;
        else
            glFinish;
        end if;
    end Redraw;




    --  Solving  --

    procedure Change_State;

    function Hash
           (Pieces : in Config)
        return Interfaces.C.unsigned
    is
        --  C's int arithmetic, which wraps, then taken as unsigned.
        Value : Interfaces.C.unsigned := 0;
    begin
        for I in Pieces'Range (1) loop
            for J in Pieces'Range (2) loop
                Value := Value + Interfaces.C.unsigned (Convert (Pieces (I, J)));
                Value := Value * 6;
            end loop;
        end loop;
        return Value;
    end Hash;

    function Solution
           (Pieces : in Config)
        return Boolean is
    begin
        return Pieces (4, 1) = 10 and Pieces (4, 2) = 10;
    end Solution;

    procedure Set_Title
           (Text : in String) is
    begin
        Glut.Set_Window_Title (Text);
    end Set_Title;

    function Image
           (N : in Integer)
        return String
    is
        S : constant String := Integer'Image (N);
    begin
        return (if S (S'First) = ' ' then S (S'First + 1 .. S'Last) else S);
    end Image;

    procedure Solidify_Chain
           (Start : in Puzzle_Access)
    is
        Puzzle : Puzzle_Access := Start;
        Moves  : Natural := 0;
    begin
        while Puzzle.Back_Ptr /= null loop
            Moves := Moves + 1;
            Puzzle.Back_Ptr.Soln_Ptr := Puzzle;
            Puzzle := Puzzle.Back_Ptr;
        end loop;
        Set_Title (Image (Moves) & " moves to complete!");
    end Solidify_Chain;

    function Same_Shapes
           (A, B : in Config)
        return Boolean is
    begin
        for I in 0 .. Width - 1 loop
            for J in 0 .. Height - 1 loop
                if Convert (A (J, I)) /= Convert (B (J, I)) then
                    return False;
                end if;
            end loop;
        end loop;
        return True;
    end Same_Shapes;

    --  Adds Pieces to the hash table and the queue, if it is new.  True if
    --  it is a solution.
    function Add_Config
           (Pieces : in Config;
            Back   : in Puzzle_Access)
        return Boolean
    is
        Hash_Value : constant Interfaces.C.unsigned := Hash (Pieces);
        Bucket     : constant Natural := Natural (Hash_Value mod Hash_Size);
        New_Piece  : Puzzle_Access := Hash_Table (Bucket);
        New_Entry  : List_Access;
    begin
        while New_Piece /= null loop
            if New_Piece.Hash_Value = Hash_Value and then Same_Shapes (Pieces, New_Piece.Pieces)
            then
                return False;
            end if;
            New_Piece := New_Piece.Next;
        end loop;

        New_Piece := new Puzzle'
           (Back_Ptr   => Back,
            Soln_Ptr   => null,
            Pieces     => Pieces,
            Next       => Hash_Table (Bucket),
            Hash_Value => Hash_Value);
        Hash_Table (Bucket) := New_Piece;

        New_Entry := new List_Entry'(Puzzle => New_Piece, Next => null);
        if Last_Entry /= null then
            Last_Entry.Next := New_Entry;
        else
            Puzzles := New_Entry;
        end if;
        Last_Entry := New_Entry;

        if Back = null then
            Start_Puzzle := New_Piece;
        end if;
        if Solution (Pieces) then
            Solidify_Chain (New_Piece);
            return True;
        end if;
        return False;
    end Add_Config;

    --  Whether the space at X, Y can move in direction Dir, with the
    --  result in New_Pieces.
    function Can_Move_0
           (Pieces     : in     Config;
            X, Y, Dir  : in     Integer;
            New_Pieces :    out Config)
        return Boolean
    is
        X_Add : Integer := X_Adds (Dir);
        Y_Add : Integer := Y_Adds (Dir);
        Piece : Piece_Number;
        New_X : Integer;
        New_Y : Integer;
    begin
        New_Pieces := Pieces;
        if X + X_Add < 0 or X + X_Add >= Width or Y + Y_Add < 0 or Y + Y_Add >= Height then
            return False;
        end if;
        Piece := Pieces (Y + Y_Add, X + X_Add);
        if Piece = 0 then
            return False;
        end if;
        for L in 0 .. Width - 1 loop
            for M in 0 .. Height - 1 loop
                if New_Pieces (M, L) = Piece then
                    New_Pieces (M, L) := 0;
                end if;
            end loop;
        end loop;
        X_Add := -X_Add;
        Y_Add := -Y_Add;
        for L in 0 .. Width - 1 loop
            for M in 0 .. Height - 1 loop
                if Pieces (M, L) = Piece then
                    New_X := L + X_Add;
                    New_Y := M + Y_Add;
                    if New_X < 0 or New_X >= Width or New_Y < 0 or New_Y >= Height then
                        return False;
                    end if;
                    if New_Pieces (New_Y, New_X) /= 0 then
                        return False;
                    end if;
                    New_Pieces (New_Y, New_X) := Piece;
                end if;
            end loop;
        end loop;
        return True;
    end Can_Move_0;

    --  Whether the piece at X, Y can move in direction Dir.
    function Can_Move
           (Pieces     : in     Config;
            X, Y, Dir  : in     Integer;
            New_Pieces :    out Config)
        return Boolean
    is
        X_Add : constant Integer := X_Adds (Dir);
        Y_Add : constant Integer := Y_Adds (Dir);
    begin
        New_Pieces := Pieces;
        if X + X_Add < 0 or X + X_Add >= Width or Y + Y_Add < 0 or Y + Y_Add >= Height then
            return False;
        end if;
        if Pieces (Y + Y_Add, X + X_Add) = Pieces (Y, X) then
            return Can_Move (Pieces, X + X_Add, Y + Y_Add, Dir, New_Pieces);
        end if;
        if Pieces (Y + Y_Add, X + X_Add) /= 0 then
            return False;
        end if;
        return Can_Move_0 (Pieces, X + X_Add, Y + Y_Add, (Dir + 2) mod 4, New_Pieces);
    end Can_Move;

    function Generate_New_Configs
           (Puzzle : in Puzzle_Access)
        return Boolean
    is
        Pieces     : constant Config := Puzzle.Pieces;
        New_Pieces : Config;
    begin
        for I in 0 .. Width - 1 loop
            for J in 0 .. Height - 1 loop
                if Pieces (J, I) = 0 then
                    for K in 0 .. 3 loop
                        if Can_Move_0 (Pieces, I, J, K, New_Pieces)
                            and then Add_Config (New_Pieces, Puzzle)
                        then
                            return True;
                        end if;
                    end loop;
                end if;
            end loop;
        end loop;
        return False;
    end Generate_New_Configs;

    procedure Free_Solutions
    is
        Next_Puz : List_Access;
        Puzzle   : Puzzle_Access;
        Next     : Puzzle_Access;
    begin
        while Puzzles /= null loop
            Next_Puz := Puzzles.Next;
            Free (Puzzles);
            Puzzles := Next_Puz;
        end loop;
        Last_Entry := null;
        for I in Hash_Table'Range loop
            Puzzle := Hash_Table (I);
            Hash_Table (I) := null;
            while Puzzle /= null loop
                Next := Puzzle.Next;
                Free (Puzzle);
                Puzzle := Next;
            end loop;
        end loop;
        Start_Puzzle := null;
    end Free_Solutions;

    --  Moves the piece of the next step a little.  False when there are no
    --  more steps.
    function Continue_Solving
        return Boolean
    is
        Next_Puz    : Puzzle_Access;
        Moved_Piece : Piece_Number := 0;
        Move_Dir    : Integer := 0;
        From_X      : Integer := 0;
        From_Y      : Integer := 0;
        To_X, To_Y  : Integer;
        Found       : Boolean := False;
    begin
        if Start_Puzzle = null then
            return False;
        end if;
        if Start_Puzzle.Soln_Ptr = null then
            Free_Solutions;
            return False;
        end if;
        Next_Puz := Start_Puzzle.Soln_Ptr;
        Search :
        for I in 0 .. Height - 1 loop
            for J in 0 .. Width - 1 loop
                if Start_Puzzle.Pieces (I, J) /= Next_Puz.Pieces (I, J) then
                    if Start_Puzzle.Pieces (I, J) /= 0 then
                        Moved_Piece := Start_Puzzle.Pieces (I, J);
                        From_X := J;
                        From_Y := I;
                        if I < Height - 1 and then Next_Puz.Pieces (I + 1, J) = Moved_Piece then
                            Move_Dir := 3;
                        else
                            Move_Dir := 2;
                        end if;
                    else
                        Moved_Piece := Next_Puz.Pieces (I, J);
                        if I < Height - 1 and then Start_Puzzle.Pieces (I + 1, J) = Moved_Piece
                        then
                            From_X := J;
                            From_Y := I + 1;
                            Move_Dir := 1;
                        else
                            From_X := J + 1;
                            From_Y := I;
                            Move_Dir := 0;
                        end if;
                    end if;
                    Found := True;
                    exit Search;
                end if;
            end loop;
        end loop Search;
        if not Found then
            Set_Title ("What!  No change?");
            Free_Solutions;
            return False;
        end if;

        if Moving_Piece = 0 then
            Moving_Piece := Moved_Piece;
            Move_X := GLfloat (From_X);
            Move_Y := GLfloat (From_Y);
        end if;
        Move_X := Move_X + GLfloat (X_Adds (Move_Dir)) * Move_Speed;
        Move_Y := Move_Y + GLfloat (Y_Adds (Move_Dir)) * Move_Speed;

        To_X := From_X + X_Adds (Move_Dir);
        To_Y := From_Y + Y_Adds (Move_Dir);

        if Move_X > GLfloat (To_X) - Move_Speed / 2.0 and Move_X < GLfloat (To_X) + Move_Speed / 2.0
            and Move_Y > GLfloat (To_Y) - Move_Speed / 2.0
            and Move_Y < GLfloat (To_Y) + Move_Speed / 2.0
        then
            Start_Puzzle := Next_Puz;
            Moving_Piece := 0;
        end if;
        The_Puzzle := Start_Puzzle.Pieces;
        Change_State;
        return True;
    end Continue_Solving;

    --  Finds the solution, breadth first.  False if there is nothing to do.
    function Solve_Puzzle
        return Boolean
    is
        Next_Puz : List_Access;
        Examined : Natural := 0;
    begin
        if Solution (The_Puzzle) then
            Set_Title ("Puzzle already solved!");
            return False;
        end if;
        if Add_Config (The_Puzzle, null) then
            null;  --  the C++ ignores it too
        end if;

        while Puzzles /= null loop
            Examined := Examined + 1;
            exit when Generate_New_Configs (Puzzles.Puzzle);
            Next_Puz := Puzzles.Next;
            Free (Puzzles);
            Puzzles := Next_Puz;
        end loop;
        if Puzzles = null then
            Free_Solutions;
            Set_Title ("I can't solve it! (" & Image (Examined) & " positions examined)");
        end if;
        return True;
    end Solve_Puzzle;




    --  Picking and Moving Pieces  --

    function Select_Piece
           (Mouse_X, Mouse_Y : in Integer)
        return Piece_Number
    is
        Hits    : GLint;
        Closest : GLuint;
        Dist    : GLuint;
    begin
        glSelectBuffer (Select_Buf'Length, Select_Buf);
        Hits := glRenderMode (GL_SELECT);
        glInitNames;

        --  Because LoadName () won't work with no names on the stack.
        glPushName (0);

        glMatrixMode (GL_PROJECTION);
        glLoadIdentity;
        FLTK.GLU.Pick_Matrix
           (Long_Float (Mouse_X), Long_Float (Win_H - Mouse_Y), 4.0, 4.0,
            (Integer (Viewport (0)), Integer (Viewport (1)),
             Integer (Viewport (2)), Integer (Viewport (3))));
        FLTK.GLU.Perspective
           (45.0, Long_Float (GLdouble (Viewport (2)) * 1.0 / GLdouble (Viewport (3))), 0.1, 100.0);

        Draw_All;

        Hits := glRenderMode (GL_RENDER);
        if Hits <= 0 then
            return 0;
        end if;
        Closest := 0;
        Dist := 16#FFFF_FFFF#;
        while Hits /= 0 loop
            if Select_Buf (Natural (Hits - 1) * 4 + 1) < Dist then
                Dist := Select_Buf (Natural (Hits - 1) * 4 + 1);
                Closest := Select_Buf (Natural (Hits - 1) * 4 + 3);
            end if;
            Hits := Hits - 1;
        end loop;
        return Piece_Number (Closest);
    end Select_Piece;

    procedure Nuke_Piece
           (Piece : in Piece_Number) is
    begin
        for I in The_Puzzle'Range (1) loop
            for J in The_Puzzle'Range (2) loop
                if The_Puzzle (I, J) = Piece then
                    The_Puzzle (I, J) := 0;
                end if;
            end loop;
        end loop;
    end Nuke_Piece;

    function Mult_Matrices
           (A, B : in Matrix)
        return Matrix
    is
        R : Matrix;
    begin
        for I in 0 .. 3 loop
            for J in 0 .. 3 loop
                R (I * 4 + J) :=
                    A (I * 4 + 0) * B (0 * 4 + J)
                    + A (I * 4 + 1) * B (1 * 4 + J)
                    + A (I * 4 + 2) * B (2 * 4 + J)
                    + A (I * 4 + 3) * B (3 * 4 + J);
            end loop;
        end loop;
        return R;
    end Mult_Matrices;

    --  M := its inverse, by Gauss-Jordan elimination.  False if it is
    --  singular, which shouldn't happen.
    function Invert_Matrix
           (M : in out Matrix)
        return Boolean
    is
        Temp    : array (0 .. 3, 0 .. 3) of GLfloat;
        Inverse : Matrix := (0 | 5 | 10 | 15 => 1.0, others => 0.0);
        Swap    : Integer;
        T       : GLfloat;
    begin
        for I in 0 .. 3 loop
            for J in 0 .. 3 loop
                Temp (I, J) := M (I * 4 + J);
            end loop;
        end loop;

        for I in 0 .. 3 loop
            --  Look for the largest element in the column.
            Swap := I;
            for J in I + 1 .. 3 loop
                if abs Temp (J, I) > abs Temp (I, I) then
                    Swap := J;
                end if;
            end loop;

            if Swap /= I then
                for K in 0 .. 3 loop
                    T := Temp (I, K);
                    Temp (I, K) := Temp (Swap, K);
                    Temp (Swap, K) := T;

                    T := Inverse (I * 4 + K);
                    Inverse (I * 4 + K) := Inverse (Swap * 4 + K);
                    Inverse (Swap * 4 + K) := T;
                end loop;
            end if;
            if Temp (I, I) = 0.0 then
                M := Inverse;  --  as far as it got, as the C++ leaves it
                return False;
            end if;
            T := Temp (I, I);
            for K in 0 .. 3 loop
                Temp (I, K) := Temp (I, K) / T;
                Inverse (I * 4 + K) := Inverse (I * 4 + K) / T;
            end loop;
            for J in 0 .. 3 loop
                if J /= I then
                    T := Temp (J, I);
                    for K in 0 .. 3 loop
                        Temp (J, K) := Temp (J, K) - Temp (I, K) * T;
                        Inverse (J * 4 + K) := Inverse (J * 4 + K) - Inverse (I * 4 + K) * T;
                    end loop;
                end if;
            end loop;
        end loop;
        M := Inverse;
        return True;
    end Invert_Matrix;

    --  The object space X and Y under the mouse at the height of the top of
    --  Piece.  False if there is none.
    function Compute_Coords
           (Piece            : in     Piece_Number;
            Mouse_X, Mouse_Y : in     Integer;
            Sel_X, Sel_Y     :    out GLfloat)
        return Boolean
    is
        Model_Matrix : Matrix;
        Proj_Matrix  : Matrix;
        Final_Matrix : Matrix;
        In_X, In_Y   : GLfloat;
        A, B, C, D   : GLfloat;
        Top, Bot     : GLfloat;
        Z, W         : GLfloat;
        Level        : GLfloat;
    begin
        Sel_X := 0.0;
        Sel_Y := 0.0;
        if Piece = 0 then
            return False;
        end if;
        Level := Z_Size (Piece) - 0.1 + Offset_Z;

        glGetFloatv (GL_PROJECTION_MATRIX, Proj_Matrix);
        glGetFloatv (GL_MODELVIEW_MATRIX, Model_Matrix);
        Final_Matrix := Mult_Matrices (Model_Matrix, Proj_Matrix);
        if not Invert_Matrix (Final_Matrix) then
            return False;
        end if;

        In_X := (2.0 * GLfloat (Mouse_X - Integer (Viewport (0))) / GLfloat (Viewport (2))) - 1.0;
        In_Y := (2.0 * GLfloat ((Win_H - Mouse_Y) - Integer (Viewport (1)))
            / GLfloat (Viewport (3))) - 1.0;

        A := In_X * Final_Matrix (0 * 4 + 2) + In_Y * Final_Matrix (1 * 4 + 2)
            + Final_Matrix (3 * 4 + 2);
        B := Final_Matrix (2 * 4 + 2);
        C := In_X * Final_Matrix (0 * 4 + 3) + In_Y * Final_Matrix (1 * 4 + 3)
            + Final_Matrix (3 * 4 + 3);
        D := Final_Matrix (2 * 4 + 3);

        --  Solve (A + B Z) / (C + D Z) = Level for Z.
        Top := Level * C - A;
        Bot := B - Level * D;
        if Bot = 0.0 then
            return False;
        end if;

        Z := Top / Bot;
        W := C + D * Z;

        Sel_X := (In_X * Final_Matrix (0 * 4 + 0) + In_Y * Final_Matrix (1 * 4 + 0)
            + Z * Final_Matrix (2 * 4 + 0) + Final_Matrix (3 * 4 + 0)) / W - Offset_X;
        Sel_Y := (In_X * Final_Matrix (0 * 4 + 1) + In_Y * Final_Matrix (1 * 4 + 1)
            + Z * Final_Matrix (2 * 4 + 1) + Final_Matrix (3 * 4 + 1)) / W - Offset_Y;
        return True;
    end Compute_Coords;

    Selected    : Boolean := False;
    Select_X    : Integer := 0;
    Select_Y    : Integer := 0;
    Sel_Start_X : GLfloat := 0.0;
    Sel_Start_Y : GLfloat := 0.0;

    procedure Grab_Piece
           (Piece        : in Piece_Number;
            Sel_X, Sel_Y : in GLfloat)
    is
        Hit : Piece_Number;
    begin
        --  C's int () truncates towards zero, so -1 < Sel_X < Width is a
        --  column.  This also keeps a NaN or a huge value from raising.
        if not (Sel_X > -1.0 and Sel_X < GLfloat (Width)
            and Sel_Y > -1.0 and Sel_Y < GLfloat (Height))
        then
            return;
        end if;
        Select_X := Integer (GLfloat'Truncation (Sel_X));
        Select_Y := Integer (GLfloat'Truncation (Sel_Y));
        Hit := The_Puzzle (Select_Y, Select_X);
        if Hit /= Piece then
            return;
        end if;
        if Hit /= 0 then
            Moving_Piece := Hit;
            while Select_X > 0 and then The_Puzzle (Select_Y, Select_X - 1) = Moving_Piece loop
                Select_X := Select_X - 1;
            end loop;
            while Select_Y > 0 and then The_Puzzle (Select_Y - 1, Select_X) = Moving_Piece loop
                Select_Y := Select_Y - 1;
            end loop;
            Move_X := GLfloat (Select_X);
            Move_Y := GLfloat (Select_Y);
            Selected := True;
            Sel_Start_X := Sel_X;
            Sel_Start_Y := Sel_Y;
        else
            Selected := False;
        end if;
        Change_State;
    end Grab_Piece;

    procedure Move_Selection
           (Sel_X, Sel_Y : in GLfloat)
    is
        Delta_X, Delta_Y : GLfloat;
        Dir              : Integer;
        New_Pieces       : Config;
    begin
        if not Selected then
            return;
        end if;
        Delta_X := Sel_X - Sel_Start_X;
        Delta_Y := Sel_Y - Sel_Start_Y;

        if abs Delta_X > abs Delta_Y then
            Delta_Y := 0.0;
            if Delta_X > 0.0 then
                if Delta_X > 1.0 then
                    Delta_X := 1.0;
                end if;
                Dir := 2;
            else
                if Delta_X < -1.0 then
                    Delta_X := -1.0;
                end if;
                Dir := 0;
            end if;
        else
            Delta_X := 0.0;
            if Delta_Y > 0.0 then
                if Delta_Y > 1.0 then
                    Delta_Y := 1.0;
                end if;
                Dir := 3;
            else
                if Delta_Y < -1.0 then
                    Delta_Y := -1.0;
                end if;
                Dir := 1;
            end if;
        end if;
        if Can_Move (The_Puzzle, Select_X, Select_Y, Dir, New_Pieces) then
            Move_X := Delta_X + GLfloat (Select_X);
            Move_Y := Delta_Y + GLfloat (Select_Y);
            if Delta_X > 0.5 then
                The_Puzzle := New_Pieces;
                Select_X := Select_X + 1;
                Sel_Start_X := Sel_Start_X + 1.0;
            elsif Delta_X < -0.5 then
                The_Puzzle := New_Pieces;
                Select_X := Select_X - 1;
                Sel_Start_X := Sel_Start_X - 1.0;
            elsif Delta_Y > 0.5 then
                The_Puzzle := New_Pieces;
                Select_Y := Select_Y + 1;
                Sel_Start_Y := Sel_Start_Y + 1.0;
            elsif Delta_Y < -0.5 then
                The_Puzzle := New_Pieces;
                Select_Y := Select_Y - 1;
                Sel_Start_Y := Sel_Start_Y - 1.0;
            end if;
        elsif Delta_Y > 0.0 and The_Puzzle (Select_Y, Select_X) = 10
            and Select_X = 1 and Select_Y = 3
        then
            --  Allow visual movement of the solution piece outside the box.
            Move_X := GLfloat (Select_X);
            Move_Y := Sel_Y - Sel_Start_Y + GLfloat (Select_Y);
        else
            Move_X := GLfloat (Select_X);
            Move_Y := GLfloat (Select_Y);
        end if;
    end Move_Selection;

    procedure Drop_Selection is
    begin
        if not Selected then
            return;
        end if;
        Moving_Piece := 0;
        Selected := False;
        Change_State;
    end Drop_Selection;




    --  GLUT Callbacks  --

    Left_Mouse      : Boolean := False;
    Middle_Mouse    : Boolean := False;
    Mouse_X         : Integer := 0;
    Mouse_Y         : Integer := 0;
    Solving         : Boolean := False;
    Spinning        : Boolean := False;
    Enable_Spinning : Boolean := True;
    Sel_Piece       : Piece_Number := 0;
    Timer_Active    : Boolean := False;  --  restart another timer at the end of Animate
    Timer_Pending   : Boolean := False;  --  a timer is waiting to be triggered
    Timer_Delay     : constant := 13;    --  in milliseconds:  72 frames a second

    procedure Animate
           (Value : in Integer);

    procedure Reshape
           (W, H : in Integer) is
    begin
        Win_W := W;
        Win_H := H;
        glViewport (0, 0, GLsizei (Win_W), GLsizei (Win_H));
        glGetIntegerv (GL_VIEWPORT, Viewport);
    end Reshape;

    procedure Stop_Solving is
    begin
        Free_Solutions;
        Solving := False;
        Glut.Change_To_Menu_Entry (2, "Solve", 2);
        Set_Title ("glpuzzle");
        Moving_Piece := 0;
    end Stop_Solving;

    procedure Toggle_Solve is
    begin
        if Solving then
            Stop_Solving;
        else
            Glut.Change_To_Menu_Entry (2, "Stop solving", 2);
            Set_Title ("Solving...");
            if Solve_Puzzle then
                Solving := True;
            end if;
        end if;
        Change_State;
        Glut.Post_Redisplay;
    end Toggle_Solve;

    procedure Reset_Position is
    begin
        Spinning := False;
        Trackball (Cur_Quat, 0.0, 0.0, 0.0, 0.0);
        if not Timer_Pending then
            Timer_Pending := True;
            Glut.Timer_Func (Timer_Delay, Animate'Unrestricted_Access, 0);
        end if;
    end Reset_Position;

    procedure Reset is
    begin
        Reset_Position;
        if Solving then
            Stop_Solving;
            Change_State;
        end if;
        The_Puzzle := Start_Config;
        Glut.Post_Redisplay;
    end Reset;

    procedure Keyboard
           (Key  : in Character;
            X, Y : in Integer)
    is
        Piece : Piece_Number;
    begin
        case Key is
            when ASCII.ESC =>
                GNAT.OS_Lib.OS_Exit (0);
            when ' ' | 'n' | 'N' =>
                Reset_Position;
            when 'D' | 'd' =>
                if Solving then
                    Stop_Solving;
                    Change_State;
                end if;
                Piece := Select_Piece (X, Y);
                if Piece /= 0 then
                    Nuke_Piece (Piece);
                end if;
                Glut.Post_Redisplay;
            when 'R' | 'r' =>
                Reset;
            when 'S' | 's' =>
                Toggle_Solve;
            when 'b' | 'B' =>
                Depth := not Depth;
                if Depth then
                    glEnable (GL_DEPTH_TEST);
                else
                    glDisable (GL_DEPTH_TEST);
                end if;
                Glut.Post_Redisplay;
            when others =>
                null;
        end case;
    end Keyboard;

    procedure Motion
           (X, Y : in Integer)
    is
        Sel_X, Sel_Y : GLfloat;
    begin
        if Middle_Mouse and not Left_Mouse then
            if Mouse_X /= X or Mouse_Y /= Y then
                Trackball (Last_Quat,
                    (2.0 * GLfloat (Mouse_X) - GLfloat (Win_W)) / GLfloat (Win_W),
                    (GLfloat (Win_H) - 2.0 * GLfloat (Mouse_Y)) / GLfloat (Win_H),
                    (2.0 * GLfloat (X) - GLfloat (Win_W)) / GLfloat (Win_W),
                    (GLfloat (Win_H) - 2.0 * GLfloat (Y)) / GLfloat (Win_H));
                Spinning := Enable_Spinning;  --  unless -n disabled it
            else
                Spinning := False;
            end if;
            Change_State;
        else
            if Compute_Coords (Sel_Piece, X, Y, Sel_X, Sel_Y) then
                null;  --  the C++ ignores it too
            end if;
            Move_Selection (Sel_X, Sel_Y);
        end if;
        Mouse_X := X;
        Mouse_Y := Y;
        Glut.Post_Redisplay;
    end Motion;

    procedure Mouse
           (Button : in Glut.Mouse_Button_Index;
            State  : in Glut.Button_State;
            X, Y   : in Integer)
    is
        Sel_X, Sel_Y : GLfloat;
    begin
        Mouse_X := X;
        Mouse_Y := Y;
        case State is
            when Glut.Down =>
                case Button is
                    when Glut.Left =>
                        if Solving then
                            Stop_Solving;
                        end if;
                        Left_Mouse := True;
                        Sel_Piece := Select_Piece (Mouse_X, Mouse_Y);
                        if Sel_Piece = 0 then
                            Left_Mouse := False;
                            Middle_Mouse := True;  --  let it rotate the object
                        elsif Compute_Coords (Sel_Piece, Mouse_X, Mouse_Y, Sel_X, Sel_Y) then
                            Grab_Piece (Sel_Piece, Sel_X, Sel_Y);
                        end if;
                        Glut.Post_Redisplay;
                    when Glut.Middle =>
                        Middle_Mouse := True;
                        Glut.Post_Redisplay;
                    when others =>
                        null;
                end case;
            when Glut.Up =>
                if Left_Mouse then
                    Left_Mouse := False;
                    Drop_Selection;
                    Glut.Post_Redisplay;
                elsif Middle_Mouse then
                    Middle_Mouse := False;
                    Glut.Post_Redisplay;
                end if;
        end case;
        Motion (X, Y);
    end Mouse;

    procedure Animate
           (Value : in Integer) is
    begin
        Timer_Pending := False;
        if Spinning then
            Add_Quats (Last_Quat, Cur_Quat);
        end if;
        Glut.Post_Redisplay;
        if Solving and then not Continue_Solving then
            Solving := False;
            Glut.Change_To_Menu_Entry (2, "Solve", 2);
            Set_Title ("glpuzzle");
        end if;
        if (not Solving and not Spinning) or not Visible then
            Timer_Active := False;
        end if;
        if Timer_Active and not Timer_Pending then
            Timer_Pending := True;
            Glut.Timer_Func (Timer_Delay, Animate'Unrestricted_Access, 0);
        end if;
    end Animate;

    procedure Change_State is
    begin
        if Visible then
            if not Solving and not Spinning then
                Timer_Active := False;
            else
                Timer_Active := True;
                if not Timer_Pending then
                    Timer_Pending := True;
                    Glut.Timer_Func (Timer_Delay, Animate'Unrestricted_Access, 0);
                end if;
            end if;
        else
            Timer_Active := False;
        end if;
    end Change_State;

    procedure Visibility
           (State : in Glut.Visibility_State) is
    begin
        Visible := State = Glut.Visible;
        Change_State;
    end Visibility;

    procedure Menu
           (Value : in Integer) is
    begin
        case Value is
            when 1 =>
                Reset_Position;
            when 2 =>
                Toggle_Solve;
            when 3 =>
                Reset;
            when 4 =>
                GNAT.OS_Lib.OS_Exit (0);
            when others =>
                null;
        end case;
    end Menu;




    --  Setting Up  --

    procedure Init
    is
        L_Model_Ambient     : constant GLfloat_Array := (0.0, 0.0, 0.0, 0.0);
        L_Model_Two_Side    : constant GLfloat_Array := (0 => GLfloat (GL_FALSE));
        L_Model_Local       : constant GLfloat_Array := (0 => GLfloat (GL_FALSE));
        Light0_Ambient      : constant GLfloat_Array := (0.1, 0.1, 0.1, 1.0);
        Light0_Diffuse      : constant GLfloat_Array := (1.0, 1.0, 1.0, 0.0);
        Light0_Position     : constant GLfloat_Array := (0.8660254, 0.5, 1.0, 0.0);
        Light0_Specular     : constant GLfloat_Array := (0.0, 0.0, 0.0, 0.0);
        Bevel_Mat_Ambient   : constant GLfloat_Array := (0.0, 0.0, 0.0, 1.0);
        Bevel_Mat_Shininess : constant GLfloat_Array := (0 => 40.0);
        Bevel_Mat_Specular  : constant GLfloat_Array := (0.0, 0.0, 0.0, 0.0);
        Bevel_Mat_Diffuse   : constant GLfloat_Array := (1.0, 0.0, 0.0, 0.0);
    begin
        glEnable (GL_CULL_FACE);
        glCullFace (GL_BACK);
        glEnable (GL_DEPTH_TEST);
        glClearDepth (1.0);

        glClearColor (0.5, 0.5, 0.5, 0.0);
        glLightfv (GL_LIGHT0, GL_AMBIENT, Light0_Ambient);
        glLightfv (GL_LIGHT0, GL_DIFFUSE, Light0_Diffuse);
        glLightfv (GL_LIGHT0, GL_SPECULAR, Light0_Specular);
        glLightfv (GL_LIGHT0, GL_POSITION, Light0_Position);
        glEnable (GL_LIGHT0);

        glLightModelfv (GL_LIGHT_MODEL_LOCAL_VIEWER, L_Model_Local);
        glLightModelfv (GL_LIGHT_MODEL_TWO_SIDE, L_Model_Two_Side);
        glLightModelfv (GL_LIGHT_MODEL_AMBIENT, L_Model_Ambient);
        glEnable (GL_LIGHTING);

        glMaterialfv (GL_FRONT, GL_AMBIENT, Bevel_Mat_Ambient);
        glMaterialfv (GL_FRONT, GL_SHININESS, Bevel_Mat_Shininess);
        glMaterialfv (GL_FRONT, GL_SPECULAR, Bevel_Mat_Specular);
        glMaterialfv (GL_FRONT, GL_DIFFUSE, Bevel_Mat_Diffuse);

        glColorMaterial (GL_FRONT_AND_BACK, GL_DIFFUSE);
        glEnable (GL_COLOR_MATERIAL);
        glShadeModel (GL_FLAT);

        Trackball (Cur_Quat, 0.0, 0.0, 0.0, 0.0);
        --  The C++ seeds random numbers here, and never uses them.
    end Init;

    procedure Usage is
    begin
        Ada.Text_IO.Put_Line ("Usage: puzzle [-s]");
        Ada.Text_IO.Put_Line ("   -s:  Run in single buffered mode");
        GNAT.OS_Lib.OS_Exit (-1);
    end Usage;

    --  Glut.Init has given FLTK its options; the rest are the program's.
    procedure Options
    is
        Index : Positive := 1;
        Taken : Natural;
    begin
        while Index <= Ada.Command_Line.Argument_Count loop
            Taken := FLTK.Static.Parse_Arg (Index);
            if Taken > 0 then
                Index := Index + Taken;
            else
                declare
                    Arg : constant String := Ada.Command_Line.Argument (Index);
                begin
                    if Arg'Length >= 2 and then Arg (Arg'First) = '-'
                        and then Arg (Arg'First + 1) = 'n'
                    then
                        Enable_Spinning := False;  --  spinning can annoy
                    elsif Arg'Length >= 2 and then Arg (Arg'First) = '-'
                        and then Arg (Arg'First + 1) = 's'
                    then
                        Double_Buffer := False;
                    else
                        Usage;
                    end if;
                end;
                Index := Index + 1;
            end if;
        end loop;
    end Options;

    procedure Help
           (Text : in String) is
    begin
        Ada.Text_IO.Put_Line (Text);
    end Help;


begin

    FLTK.Static.Set_Use_High_Res_GL (True);
    Glut.Init;
    Options;

    Glut.Init_Window_Size (Win_W, Win_H);
    Glut.Init_Display_Mode
       ((Depth       => True,
         Double      => Double_Buffer,
         Multisample => True,
         others      => False));

    declare
        Window : constant Glut.Valid_Window_Number := Glut.Create_Window ("glpuzzle");
        pragma Unreferenced (Window);
    begin
        null;
    end;
    Visible := True;  --  added for FLTK:  a bug in the original program?

    Init;

    glGetIntegerv (GL_VIEWPORT, Viewport);

    Help ("");
    Help ("n   Normal position - stop spinning");
    Help ("r   Reset puzzle");
    Help ("s   Solve puzzle (may take a few seconds to compute)");
    Help ("d   Destroy a piece - makes the puzzle easier");
    Help ("b   Toggles the depth buffer on and off");
    Help ("");
    Help ("Left mouse moves pieces");
    Help ("Middle mouse spins the puzzle");
    Help ("Right mouse has menu");

    Glut.Reshape_Func (Reshape'Unrestricted_Access);
    Glut.Display_Func (Redraw'Unrestricted_Access);
    Glut.Keyboard_Func (Keyboard'Unrestricted_Access);
    Glut.Motion_Func (Motion'Unrestricted_Access);
    Glut.Mouse_Func (Mouse'Unrestricted_Access);
    Glut.Visibility_Func (Visibility'Unrestricted_Access);
    declare
        Puzzle_Menu : constant Glut.Valid_Menu_Number :=
            Glut.Create_Menu (Menu'Unrestricted_Access);
        pragma Unreferenced (Puzzle_Menu);
    begin
        Glut.Add_Menu_Entry ("Normal pos", 1);
        Glut.Add_Menu_Entry ("Solve", 2);
        Glut.Add_Menu_Entry ("Reset", 3);
        Glut.Add_Menu_Entry ("Quit", 4);
    end;
    Glut.Attach_Menu (Glut.Right);
    Glut.Main_Loop;
    return 0;

end Glpuzzle;
