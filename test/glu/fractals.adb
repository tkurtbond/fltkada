--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/fractals.cxx, with fracviewer.cxx and fracviewer.h, its
--  viewer:  fractal mountains, trees and an island, drawn through FLTK's
--  GLUT in a GLUT window inside an FLTK window.  The left button turns the
--  scene, the middle button and the wheel move nearer or further, and the
--  right button is a GLUT menu.  In flying mode the keys 0 to 9, + and -
--  set the speed.  Guided by pofltk's Fractals.Mod.
--
--  The arithmetic is the C++'s, float where it has float and double where
--  it has double, and srand48 and drand48 are glibc's, written out, so that
--  the scene is the C++ program's to the pixel.  A float is truncated to an
--  integer as C does, toward zero.
--
--  The FLTK buttons pass a value to their callback as user data in the
--  C++.  Here each kind is a type of button with the value as a component.
--  The C++ quits with exit (0); this hides the window instead, which ends
--  the main loop, and returns 0.


with

    Ada.Numerics.Generic_Elementary_Functions,
    Ada.Numerics.Long_Elementary_Functions,
    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.Draw.OpenGL,
    FLTK.GLU,
    FLTK.GLUT,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.OpenGL.GLUT,
    GL1,
    Interfaces.C,
    System;

use

    Ada.Numerics.Long_Elementary_Functions,
    GL1;

use type

    FLTK.GLUT.Button_State,
    FLTK.GLUT.Mouse_Button_Index,
    FLTK.GLUT.Visibility_State,
    FLTK.GLUT.Menu_State,
    GL1.GLbitfield,
    GL1.GLfloat,
    Interfaces.Unsigned_64;


function Fractals
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Glt renames FLTK.Widgets.Groups.Windows.OpenGL.GLUT;
    package GLD renames FLTK.Draw.OpenGL;
    package GLU renames FLTK.GLU;
    package Glut renames FLTK.GLUT;

    package Float_Functions is new Ada.Numerics.Generic_Elementary_Functions (GLfloat);

    subtype U64 is Interfaces.Unsigned_64;


    --  time (NULL)
    function C_Time
           (T : in System.Address)
        return Interfaces.C.long
    with Import, Convention => C, External_Name => "time";

    function Now
        return Long_Long_Integer is
    begin
        return Long_Long_Integer (C_Time (System.Null_Address));
    end Now;

    --  N without the leading space of N'Image.
    function Image
           (N : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (N'Image, Ada.Strings.Left);
    end Image;




    --  glibc's srand48 and drand48  --

    Rand_State : U64 := 0;

    --  As glibc's, which keeps only the low 32 bits of Seed.
    procedure Srand48
           (Seed : in Long_Long_Integer) is
    begin
        Rand_State := (U64'Mod (Seed) and 16#FFFF_FFFF#) * 2 ** 16 + 16#330E#;
    end Srand48;

    --  The next 48 bits of glibc's generator, X (n + 1) = (a X (n) + c) mod
    --  2 ** 48, as a double in [0, 1).  The product is taken mod 2 ** 64,
    --  which is still right mod 2 ** 48.
    function Drand48
        return Long_Float is
    begin
        Rand_State := (Rand_State * 16#5_DEEC_E66D# + 16#B#) and (2 ** 48 - 1);
        return Long_Float (Rand_State) / 2.0 ** 48;
    end Drand48;




    --  Settings  --

    --  The display lists
    Mountain_List       : constant GLuint := 1;
    Tree_List           : constant GLuint := 2;
    Island_List         : constant GLuint := 3;
    Stem_List           : constant GLuint := 5;
    Leaf_List           : constant GLuint := 6;
    Mountain_Mat_List   : constant GLuint := 7;
    Water_Mat_List      : constant GLuint := 8;
    Leaf_Mat_List       : constant GLuint := 9;
    Tree_Mat_List       : constant GLuint := 10;
    Stem_And_Leaves     : constant GLuint := 11;
    Axes_List           : constant GLuint := 12;

    Max_Level : constant := 8;
    Num_Rands : constant := 191;

    --  The menu's choices
    Menu_Quit : constant := 0;
    Menu_Rand : constant := 1;
    Menu_Axes : constant := 3;

    --  The viewer's movement modes, and its settings, as fracviewer.cxx's
    type Movement is (Flying, Polar);

    Init_Polar_Az : constant GLfloat := 0.0;
    Init_Polar_El : constant GLfloat := 30.0;
    Init_Dist     : constant GLfloat := 4.0;
    Init_Az_Spin  : constant GLfloat := 0.5;
    Init_El_Spin  : constant GLfloat := 0.0;
    Init_Ex       : constant GLfloat := 0.0;
    Init_Ey       : constant GLfloat := -2.0;
    Init_Ez       : constant GLfloat := -2.0;
    Init_Move     : constant GLfloat := 0.01;
    Min_Move      : constant GLfloat := 0.001;
    Move_Fraction : constant GLfloat := 0.25;
    El_Sens       : constant GLfloat := 0.5;
    Az_Sens       : constant GLfloat := 0.5;
    Dist_Sens     : constant GLfloat := 0.01;
    E_Sens        : constant GLfloat := 0.01;
    Min_Az_Spin   : constant GLfloat := 0.1;
    Min_El_Spin   : constant GLfloat := 0.1;
    Slow_Daz      : constant GLfloat := 0.90;
    Slow_Del      : constant GLfloat := 0.90;
    Prev_Daz      : constant GLfloat := 0.80;
    Prev_Del      : constant GLfloat := 0.80;
    Cur_Daz       : constant GLfloat := 0.20;
    Cur_Del       : constant GLfloat := 0.20;

    --  C's M_PI, and TORAD's M_PI / 180.0, rounded to a double as C has them
    M_Pi        : constant Long_Float := 3.14159265358979323846;
    Pi_Over_180 : constant Long_Float := M_Pi / 180.0;




    --  State  --

    Rebuild   : Boolean := True;          --  rebuild the display list in the next Display?
    Fractal   : GLuint := Tree_List;      --  the fractal being built
    Level     : Natural := 4;             --  levels of recursion for the fractals
    Draw_Axes : Boolean := False;

    Win_Width  : Integer := 1;
    Win_Height : Integer := 1;

    Fps_Time  : Long_Long_Integer := 0;
    Fps_Count : Integer := 0;
    Fps       : Integer := 0;

    --  The viewer's
    Move_Mode : Movement := Polar;
    Ex        : GLfloat := Init_Ex;       --  flying
    Ey        : GLfloat := Init_Ey;
    Ez        : GLfloat := Init_Ez;
    Eye_Move  : GLfloat := Init_Move;
    Eye_Dist  : GLfloat := Init_Dist;     --  polar
    Az_Spin   : GLfloat := Init_Az_Spin;
    El_Spin   : GLfloat := Init_El_Spin;
    Eye_Az    : GLfloat := Init_Polar_Az; --  both
    Eye_El    : GLfloat := Init_Polar_El;

    --  The C++'s agvMoving, lastx and lasty are set but never read, and are
    --  left out.
    Down_X, Down_Y : Integer := 0;
    Down_Held : Boolean := False;         --  downb /= -1
    Down_B    : Glut.Menu_Button := Glut.Left;

    Down_Dist, Down_El, Down_Az, Down_Ex, Down_Ey, Down_Ez, Down_Eye_Move : GLfloat := 0.0;
    D_Az, D_El, Last_Az, Last_El : GLfloat := 0.0;
    Adjusting_Az_El : Boolean := False;

    Allow_Idle       : Boolean := False;
    Redisplay_Window : Glut.Window_Number := Glut.No_Window;




    --  Vectors  --

    subtype Vec is GLfloat_Array (0 .. 2);

    function To_Rad
           (X : in GLfloat)
        return Long_Float is
    begin
        return Pi_Over_180 * Long_Float (X);
    end To_Rad;

    procedure Normalize
           (V : in out Vec)
    is
        D : constant GLfloat :=
            Float_Functions.Sqrt (V (0) * V (0) + V (1) * V (1) + V (2) * V (2));
    begin
        if D = 0.0 then
            Ada.Text_IO.Put_Line (Ada.Text_IO.Standard_Error, "Zero length vector in normalize");
        else
            V (0) := V (0) / D;
            V (1) := V (1) / D;
            V (2) := V (2) / D;
        end if;
    end Normalize;

    --  CP is the normalized cross product of V1 and V2.
    procedure N_Cross_Prod
           (V1, V2 : in     Vec;
            CP     :    out Vec) is
    begin
        CP (0) := V1 (1) * V2 (2) - V1 (2) * V2 (1);
        CP (1) := V1 (2) * V2 (0) - V1 (0) * V2 (2);
        CP (2) := V1 (0) * V2 (1) - V1 (1) * V2 (0);
        Normalize (CP);
    end N_Cross_Prod;

    --  Norm is the normal to the triangle V1, V2, V3.
    procedure Triag_Normal
           (V1, V2, V3 : in     Vec;
            Norm       :    out Vec)
    is
        Vec1, Vec2 : Vec;
    begin
        for I in Vec'Range loop
            Vec1 (I) := V3 (I) - V1 (I);
            Vec2 (I) := V2 (I) - V1 (I);
        end loop;
        N_Cross_Prod (Vec2, Vec1, Norm);
    end Triag_Normal;

    function XZ_Length
           (V1, V2 : in Vec)
        return GLfloat is
    begin
        return Float_Functions.Sqrt
           ((V1 (0) - V2 (0)) * (V1 (0) - V2 (0)) + (V1 (2) - V2 (2)) * (V1 (2) - V2 (2)));
    end XZ_Length;

    function XZ_Slope
           (V1, V2 : in Vec)
        return GLfloat is
    begin
        if V1 (0) /= V2 (0) then
            return (V1 (2) - V2 (2)) / (V1 (0) - V2 (0));
        else
            return GLfloat'Last;  --  FLT_MAX
        end if;
    end XZ_Slope;




    --  Mountains  --

    --  What to multiply the random number by for a level, to get the
    --  midpoint's displacement, and what to add to it first.
    Disp_Factor : array (0 .. Max_Level) of GLfloat := (others => 0.0);
    Disp_Bias   : array (0 .. Max_Level) of GLfloat := (others => 0.0);

    --  Random numbers, hashed so that a midpoint is always raised the same.
    Rand_Table : array (0 .. Num_Rands - 1) of GLfloat := (others => 0.0);

    --  The mountain's outside edges, which can be pegged so they are not
    --  displaced:  their vertices, their slopes, and whether each is pegged.
    Verts  : array (0 .. 2) of Vec := (others => (others => 0.0));
    Slopes : array (0 .. 2) of GLfloat := (others => 0.0);
    Pegged : array (0 .. 2) of Boolean := (others => False);

    Cutoff : GLfloat := -1.0;

    procedure Init_Rand_Table
           (Seed : in Long_Long_Integer) is
    begin
        Srand48 (Seed);
        for I in Rand_Table'Range loop
            Rand_Table (I) := GLfloat (Drand48 - 0.5);
        end loop;
    end Init_Rand_Table;

    --  Mid is the midpoint of V1 and V2, displaced if need be.
    procedure Midpoint
           (Mid         :    out Vec;
            V1, V2      : in     Vec;
            Edge, Lvl   : in     Natural)
    is
        Hash  : Long_Float;
        Index : Natural;
    begin
        Mid (0) := (V1 (0) + V2 (0)) / 2.0;
        Mid (1) := (V1 (1) + V2 (1)) / 2.0;
        Mid (2) := (V1 (2) + V2 (2)) / 2.0;
        if not Pegged (Edge)
            or else Long_Float (abs (XZ_Slope (Verts (Edge), Mid) - Slopes (Edge))) > 0.00001
        then
            Srand48 (Long_Long_Integer (GLfloat'Truncation ((V1 (0) + V2 (0)) * 23344.0)));
            Hash := Long_Float'Truncation (Drand48 * 7334334.0);
            Srand48 (Long_Long_Integer (GLfloat'Truncation ((V2 (2) + V1 (2)) * 43433.0)));
            Index := Natural (Long_Float'Truncation (Drand48 * 634344.0 + Hash)) mod Num_Rands;
            Mid (1) := Mid (1) + (Rand_Table (Index) + Disp_Bias (Lvl)) * Disp_Factor (Lvl);
        end if;
    end Midpoint;

    --  The recursive mountain, which issues only normals and vertices.
    procedure FMR
           (V1, V2, V3 : in Vec;
            Lvl        : in Natural) is
    begin
        if Lvl = Level then
            declare
                Norm : Vec;
            begin
                if V1 (1) <= Cutoff and then V2 (1) <= Cutoff and then V3 (1) <= Cutoff then
                    return;
                end if;
                Triag_Normal (V1, V2, V3, Norm);
                glNormal3fv (Norm);
                glVertex3fv (V1);
                glVertex3fv (V2);
                glVertex3fv (V3);
            end;
        else
            declare
                M1, M2, M3 : Vec;
            begin
                Midpoint (M1, V1, V2, 0, Lvl);
                Midpoint (M2, V2, V3, 1, Lvl);
                Midpoint (M3, V3, V1, 2, Lvl);
                FMR (V1, M1, M3, Lvl + 1);
                FMR (M1, V2, M2, Lvl + 1);
                FMR (M3, M2, V3, Lvl + 1);
                FMR (M1, M2, M3, Lvl + 1);
            end;
        end if;
    end FMR;

    --  Sets up the tables and draws the mountain.
    procedure Fractal_Mountain
           (V1, V2, V3 : in Vec;
            Pegs       : in Vec)
    is
        Fraction : constant array (0 .. 7) of GLfloat := (0.3, 0.3, 0.4, 0.2, 0.3, 0.2, 0.4, 0.4);
        Bias     : constant array (0 .. 7) of GLfloat := (others => 0.1);
        Lengths  : array (0 .. Max_Level) of GLfloat := (others => 0.0);
        --  The C++'s, with its precedence:  only the last length is
        --  divided by 3.
        Avg_Len  : constant GLfloat :=
            XZ_Length (V1, V2) + XZ_Length (V2, V3) + XZ_Length (V3, V1) / 3.0;
    begin
        for I in 0 .. 2 loop
            Verts (0) (I) := V1 (I);
            Verts (1) (I) := V2 (I);
            Verts (2) (I) := V3 (I);
            Pegged (I) := Pegs (I) /= 0.0;
        end loop;
        Slopes (0) := XZ_Slope (Verts (0), Verts (1));
        Slopes (1) := XZ_Slope (Verts (1), Verts (2));
        Slopes (2) := XZ_Slope (Verts (2), Verts (0));
        Lengths (0) := Avg_Len;
        for I in 1 .. Level - 1 loop
            Lengths (I) := Lengths (I - 1) / 2.0;
        end loop;
        for I in 0 .. Level - 1 loop
            Disp_Factor (I) := Lengths (I) * Fraction (Integer'Min (I, 7));
            Disp_Bias (I) := Bias (Integer'Min (I, 7));
        end loop;
        glBegin (GL_TRIANGLES);
        FMR (V1, V2, V3, 0);
        glEnd;
    end Fractal_Mountain;

    procedure Create_Mountain is
    begin
        glNewList (Mountain_List, GL_COMPILE);
        glPushAttrib (GL_LIGHTING_BIT);
        glCallList (Mountain_Mat_List);
        Fractal_Mountain ((0.0, 0.0, -1.0), (-1.0, 0.0, 1.0), (1.0, 0.0, 1.0), (1.0, 1.0, 1.0));
        glPopAttrib;
        glEndList;
    end Create_Mountain;

    --  New random numbers, for a different mountain.  The C++ casts
    --  time (NULL) to unsigned int, and srand48 keeps those 32 bits.
    procedure New_Mountain is
    begin
        Init_Rand_Table (Now mod 2 ** 32);
    end New_Mountain;




    --  Trees  --

    --  The seed, kept so that the same tree can be built at another level.
    Tree_Seed : Long_Long_Integer := 0;

    procedure Fractal_Tree
           (Lvl        : in Natural;
            Level_Seed : in Long_Long_Integer) is
    begin
        if Lvl = Level then
            glPushMatrix;
            glRotatef (GLfloat (Drand48 * 180.0), 0.0, 1.0, 0.0);
            glCallList (Stem_And_Leaves);
            glPopMatrix;
        else
            glCallList (Stem_List);
            glPushMatrix;
            glRotatef (GLfloat (Drand48 * 180.0), 0.0, 1.0, 0.0);
            glTranslatef (0.0, 1.0, 0.0);
            glScalef (0.7, 0.7, 0.7);

            Srand48 (Level_Seed + 1);
            glPushMatrix;
            glRotatef (GLfloat (110.0 + Drand48 * 40.0), 0.0, 1.0, 0.0);
            glRotatef (GLfloat (30.0 + Drand48 * 20.0), 0.0, 0.0, 1.0);
            Fractal_Tree (Lvl + 1, Level_Seed + 4);
            glPopMatrix;

            Srand48 (Level_Seed + 2);
            glPushMatrix;
            glRotatef (GLfloat (-130.0 + Drand48 * 40.0), 0.0, 1.0, 0.0);
            glRotatef (GLfloat (30.0 + Drand48 * 20.0), 0.0, 0.0, 1.0);
            Fractal_Tree (Lvl + 1, Level_Seed + 5);
            glPopMatrix;

            Srand48 (Level_Seed + 3);
            glPushMatrix;
            glRotatef (GLfloat (-20.0 + Drand48 * 40.0), 0.0, 1.0, 0.0);
            glRotatef (GLfloat (30.0 + Drand48 * 20.0), 0.0, 0.0, 1.0);
            Fractal_Tree (Lvl + 1, Level_Seed + 6);
            glPopMatrix;

            glPopMatrix;
        end if;
    end Fractal_Tree;

    --  The display lists for a stem, a leaf, and a stem with leaves.
    procedure Create_Tree_Lists is
        Cyl_Quad : GLU.Quadric := GLU.Forge.Create;
    begin
        glNewList (Stem_List, GL_COMPILE);
        glPushMatrix;
        glRotatef (-90.0, 1.0, 0.0, 0.0);
        Cyl_Quad.Cylinder (0.1, 0.08, 1.0, 10, 2);
        glPopMatrix;
        glEndList;

        glNewList (Leaf_List, GL_COMPILE);
        glBegin (GL_TRIANGLES);
        glNormal3f (-0.1, 0.0, 0.25);  --  not normalized
        glVertex3f (0.0, 0.0, 0.0);
        glVertex3f (0.25, 0.25, 0.1);
        glVertex3f (0.0, 0.5, 0.0);
        glNormal3f (0.1, 0.0, 0.25);
        glVertex3f (0.0, 0.0, 0.0);
        glVertex3f (0.0, 0.5, 0.0);
        glVertex3f (-0.25, 0.25, 0.1);
        glEnd;
        glEndList;

        glNewList (Stem_And_Leaves, GL_COMPILE);
        glPushMatrix;
        glPushAttrib (GL_LIGHTING_BIT);
        glCallList (Stem_List);
        glCallList (Leaf_Mat_List);
        for I in 1 .. 3 loop
            glTranslatef (0.0, 0.333, 0.0);
            glRotatef (90.0, 0.0, 1.0, 0.0);
            glPushMatrix;
            glRotatef (0.0, 0.0, 1.0, 0.0);
            glRotatef (50.0, 1.0, 0.0, 0.0);
            glCallList (Leaf_List);
            glPopMatrix;
            glPushMatrix;
            glRotatef (180.0, 0.0, 1.0, 0.0);
            glRotatef (60.0, 1.0, 0.0, 0.0);
            glCallList (Leaf_List);
            glPopMatrix;
        end loop;
        glPopAttrib;
        glPopMatrix;
        glEndList;

        Cyl_Quad.Close;
    end Create_Tree_Lists;

    procedure Create_Tree is
    begin
        Srand48 (Tree_Seed);
        glNewList (Tree_List, GL_COMPILE);
        glPushMatrix;
        glPushAttrib (GL_LIGHTING_BIT);
        glCallList (Tree_Mat_List);
        glTranslatef (0.0, -1.0, 0.0);
        Fractal_Tree (0, Tree_Seed);
        glPopAttrib;
        glPopMatrix;
        glEndList;
    end Create_Tree;

    procedure New_Tree is
    begin
        Tree_Seed := Now;
    end New_Tree;




    --  The Island  --

    procedure Create_Island
    is
        procedure Hill
               (Angle, X, Y, Z : in GLfloat) is
        begin
            glPushMatrix;
            glRotatef (Angle, 0.0, 1.0, 0.0);
            glTranslatef (X, Y, Z);
            glCallList (Mountain_List);
            glPopMatrix;
        end Hill;
    begin
        Cutoff := 0.06;
        Create_Mountain;
        Cutoff := -1.0;
        glNewList (Island_List, GL_COMPILE);
        glPushAttrib (GL_LIGHTING_BIT);
        glMatrixMode (GL_MODELVIEW);
        glPushMatrix;
        glCallList (Water_Mat_List);
        glBegin (GL_QUADS);
        glNormal3f (0.0, 1.0, 0.0);
        glVertex3f (10.0, 0.01, 10.0);
        glVertex3f (10.0, 0.01, -10.0);
        glVertex3f (-10.0, 0.01, -10.0);
        glVertex3f (-10.0, 0.01, 10.0);
        glEnd;
        glPushMatrix;
        glTranslatef (0.0, -0.1, 0.0);
        glCallList (Mountain_List);
        glPopMatrix;
        Hill (135.0, 0.2, -0.15, -0.4);
        Hill (-60.0, 0.7, -0.07, 0.5);
        Hill (-175.0, -0.7, -0.05, -0.5);
        Hill (165.0, -0.9, -0.12, 0.0);
        glPopMatrix;
        glPopAttrib;
        glEndList;
    end Create_Island;

    procedure New_Fractals is
    begin
        New_Mountain;
        New_Tree;
    end New_Fractals;

    procedure Create
           (Fract : in GLuint) is
    begin
        case Fract is
            when Mountain_List =>
                Create_Mountain;
            when Tree_List =>
                Create_Tree;
            when Island_List =>
                Create_Island;
            when others =>
                null;
        end case;
    end Create;




    --  OpenGL  --

    procedure Material
           (List           : in GLuint;
            Face           : in GLenum;
            Ambuse, Spec   : in GLfloat_Array;
            Shininess      : in GLfloat) is
    begin
        glNewList (List, GL_COMPILE);
        glMaterialfv (Face, GL_AMBIENT_AND_DIFFUSE, Ambuse);
        glMaterialfv (Face, GL_SPECULAR, Spec);
        glMaterialfv (Face, GL_SHININESS, (0 => Shininess));
        glEndList;
    end Material;

    procedure Setup_Materials is
    begin
        Material (Mountain_Mat_List, GL_FRONT,
            (0.426, 0.256, 0.108, 1.0), (0.394, 0.272, 0.167, 1.0), 10.0);
        Material (Water_Mat_List, GL_FRONT,
            (0.0, 0.1, 0.5, 1.0), (0.0, 0.1, 0.5, 1.0), 10.0);
        Material (Tree_Mat_List, GL_FRONT,
            (0.4, 0.25, 0.1, 1.0), (0.0, 0.0, 0.0, 1.0), 0.0);
        Material (Leaf_Mat_List, GL_FRONT_AND_BACK,
            (0.0, 0.8, 0.0, 1.0), (0.0, 0.8, 0.0, 1.0), 10.0);
    end Setup_Materials;

    procedure My_GL_Init is
    begin
        glLightfv (GL_LIGHT0, GL_AMBIENT, (0.0, 0.0, 0.0, 1.0));
        glLightfv (GL_LIGHT0, GL_DIFFUSE, (1.0, 1.0, 1.0, 1.0));
        glLightfv (GL_LIGHT0, GL_SPECULAR, (1.0, 1.0, 1.0, 1.0));
        glLightfv (GL_LIGHT0, GL_POSITION, (0.0, 0.3, 0.3, 0.0));
        glLightModelfv (GL_LIGHT_MODEL_AMBIENT, (0.4, 0.4, 0.4, 1.0));
        glEnable (GL_LIGHTING);
        glEnable (GL_LIGHT0);
        glDepthFunc (GL_LEQUAL);
        glEnable (GL_DEPTH_TEST);
        glEnable (GL_NORMALIZE);
        --  The C++ has back-face culling and blending here, under #if 0.
        glShadeModel (GL_SMOOTH);
        Setup_Materials;
        Create_Tree_Lists;
        glFlush;
    end My_GL_Init;




    --  The Viewer  --

    --  The viewing transformation, from page 90 of the red book.
    procedure Polar_Look_From
           (Dist, Elevation, Azimuth : in GLfloat) is
    begin
        glTranslatef (0.0, 0.0, -Dist);
        glRotatef (Elevation, 1.0, 0.0, 0.0);
        glRotatef (Azimuth, 0.0, 1.0, 0.0);
    end Polar_Look_From;

    procedure Fly_Look_From
           (X, Y, Z, Az, El : in GLfloat)
    is
        Look_At, Perp, Up : Vec;
    begin
        Look_At (0) := GLfloat (Sin (To_Rad (Az)) * Cos (To_Rad (El)));
        Look_At (1) := GLfloat (Sin (To_Rad (El)));
        Look_At (2) := GLfloat (-Cos (To_Rad (Az)) * Cos (To_Rad (El)));
        Normalize (Look_At);
        Perp (0) := Look_At (2);
        Perp (1) := 0.0;
        Perp (2) := -Look_At (0);
        Normalize (Perp);
        N_Cross_Prod (Look_At, Perp, Up);
        GLU.Look_At
           (Long_Float (X), Long_Float (Y), Long_Float (Z),
            Long_Float (X + Look_At (0)), Long_Float (Y + Look_At (1)),
            Long_Float (Z + Look_At (2)),
            Long_Float (Up (0)), Long_Float (Up (1)), Long_Float (Up (2)));
    end Fly_Look_From;

    procedure View_Transform is
    begin
        case Move_Mode is
            when Flying =>
                Fly_Look_From (Ex, Ey, Ez, Eye_Az, Eye_El);
            when Polar =>
                Polar_Look_From (Eye_Dist, Eye_El, Eye_Az);
        end case;
    end View_Transform;

    --  Keeps the view upright, and says whether it had to.
    function Constrain_El
        return Boolean is
    begin
        if Eye_El <= -90.0 then
            Eye_El := -89.99;
            return True;
        elsif Eye_El >= 90.0 then
            Eye_El := 89.99;
            return True;
        end if;
        return False;
    end Constrain_El;

    --  The idle procedure, which moves the eye.
    procedure Move is
    begin
        case Move_Mode is
            when Flying =>
                Ex := Ex + GLfloat (Long_Float (Eye_Move) * Sin (To_Rad (Eye_Az))
                    * Cos (To_Rad (Eye_El)));
                Ey := Ey + GLfloat (Long_Float (Eye_Move) * Sin (To_Rad (Eye_El)));
                Ez := Ez - GLfloat (Long_Float (Eye_Move) * Cos (To_Rad (Eye_Az))
                    * Cos (To_Rad (Eye_El)));
            when Polar =>
                Eye_El := Eye_El + El_Spin;
                Eye_Az := Eye_Az + Az_Spin;
                if Constrain_El then
                    --  A spin to make it look better when kept from going
                    --  upside down while spinning.
                    El_Spin := -El_Spin;
                    if abs El_Spin > abs Az_Spin then
                        Az_Spin := abs El_Spin * (if Az_Spin > 0.0 then 1.0 else -1.0);
                    end if;
                end if;
        end case;
        if Adjusting_Az_El then
            D_Az := D_Az * Slow_Daz;
            D_El := D_El * Slow_Del;
        end if;
        if Allow_Idle then
            Glut.Set_Window (Redisplay_Window);
            Glut.Post_Redisplay;
        end if;
    end Move;

    --  Installs Move as the idle procedure only if the view will change.
    procedure Move_On
           (V : in Boolean) is
    begin
        if V and then ((Move_Mode = Flying and then Eye_Move /= 0.0)
            or else (Move_Mode = Polar
                and then (Az_Spin /= 0.0 or else El_Spin /= 0.0 or else Adjusting_Az_El)))
        then
            if Allow_Idle then
                Glut.Idle_Func (Move'Unrestricted_Access);
            end if;
        else
            if Allow_Idle then
                Glut.Idle_Func (null);
            end if;
        end if;
    end Move_On;

    procedure Set_Allow_Idle
           (Allow : in Boolean) is
    begin
        Allow_Idle := Allow;
        if Allow_Idle then
            Move_On (True);
        end if;
    end Set_Allow_Idle;

    --  Switching to flying stays in the same spot; switching to polar
    --  resets, since it must look at the origin.
    procedure Switch_Move_Mode
           (Move : in Integer)
    is
        Mode : constant Movement := Movement'Val (Move);
    begin
        case Mode is
            when Flying =>
                if Move_Mode = Flying then
                    return;
                end if;
                Ex := GLfloat (Long_Float (-Eye_Dist) * Sin (To_Rad (Eye_Az))
                    * Cos (To_Rad (Eye_El)));
                Ey := GLfloat (Long_Float (Eye_Dist) * Sin (To_Rad (Eye_El)));
                Ez := GLfloat (Long_Float (Eye_Dist)
                    * (Cos (To_Rad (Eye_Az)) * Cos (To_Rad (Eye_El))));
                Eye_El := -Eye_El;
                Eye_Move := Init_Move;
            when Polar =>
                Eye_Dist := Init_Dist;
                Eye_Az := Init_Polar_Az;
                Eye_El := Init_Polar_El;
                Az_Spin := Init_Az_Spin;
                El_Spin := Init_El_Spin;
        end case;
        Move_Mode := Mode;
        Move_On (True);
        Glut.Post_Redisplay;
    end Switch_Move_Mode;

    --  Ex, Ey and Ez moved by Delta_Y, which E_Sens has scaled, along
    --  the line of sight.
    procedure Move_Eye
           (Delta_Y : in GLfloat) is
    begin
        Ex := GLfloat (Long_Float (Down_Ex) - Long_Float (Delta_Y) * Sin (To_Rad (Eye_Az))
            * Cos (To_Rad (Eye_El)));
        Ey := GLfloat (Long_Float (Down_Ey) - Long_Float (Delta_Y) * Sin (To_Rad (Eye_El)));
        Ez := GLfloat (Long_Float (Down_Ez) + Long_Float (Delta_Y) * Cos (To_Rad (Eye_Az))
            * Cos (To_Rad (Eye_El)));
    end Move_Eye;

    procedure Handle_Button
           (Button : in Glut.Mouse_Button_Index;
            State  : in Glut.Button_State;
            X, Y   : in Integer)
    is
        Delta_Y : GLfloat := 0.25;
    begin
        if State = Glut.Down and then Button in Glut.Wheel_Up | Glut.Wheel_Down then
            if Button = Glut.Wheel_Up then
                Delta_Y := -0.25;
            end if;
            Down_Held := False;
            Down_Dist := Eye_Dist;
            Down_Ex := Ex;
            Down_Ey := Ey;
            Down_Ez := Ez;
            Down_Eye_Move := Eye_Move;
            Eye_Move := 0.0;
            Eye_Dist := Down_Dist + Delta_Y;
            Move_Eye (E_Sens * Delta_Y);
            Eye_Move := Down_Eye_Move;
            Glut.Post_Redisplay;
            return;
        elsif Button not in Glut.Menu_Button then
            return;  --  ignore any other button
        end if;

        if State = Glut.Down and then not Down_Held then
            Down_X := X;
            Down_Y := Y;
            Down_Held := True;
            Down_B := Button;
            case Down_B is
                when Glut.Left =>
                    Down_El := Eye_El;
                    Last_El := Eye_El;
                    Down_Az := Eye_Az;
                    Last_Az := Eye_Az;
                    Az_Spin := 0.0;
                    El_Spin := 0.0;
                    D_Az := 0.0;
                    D_El := 0.0;
                    Adjusting_Az_El := True;
                    Move_On (True);
                when Glut.Middle =>
                    Down_Dist := Eye_Dist;
                    Down_Ex := Ex;
                    Down_Ey := Ey;
                    Down_Ez := Ez;
                    Down_Eye_Move := Eye_Move;
                    Eye_Move := 0.0;
                when Glut.Right =>
                    null;
            end case;
        elsif State = Glut.Up and then Down_Held and then Button = Down_B then
            Down_Held := False;
            case Down_B is
                when Glut.Left =>
                    if Move_Mode /= Flying then
                        Az_Spin := -D_Az;
                        if Az_Spin < Min_Az_Spin and then Az_Spin > -Min_Az_Spin then
                            Az_Spin := 0.0;
                        end if;
                        El_Spin := -D_El;
                        if El_Spin < Min_El_Spin and then El_Spin > -Min_El_Spin then
                            El_Spin := 0.0;
                        end if;
                    end if;
                    Adjusting_Az_El := False;
                    Move_On (True);
                when Glut.Middle =>
                    Eye_Move := Down_Eye_Move;
                when Glut.Right =>
                    null;
            end case;
        end if;
    end Handle_Button;

    --  Changes the elevation, azimuth and position as the mouse moves
    --  with a button down.
    procedure Handle_Motion
           (X, Y : in Integer)
    is
        Delta_X : constant Integer := X - Down_X;
        Delta_Y : constant Integer := Y - Down_Y;
    begin
        if Down_Held then
            case Down_B is
                when Glut.Left =>
                    Eye_El := Down_El + El_Sens * GLfloat (Delta_Y);
                    if Constrain_El then
                        null;
                    end if;
                    Eye_Az := Down_Az + Az_Sens * GLfloat (Delta_X);
                    D_Az := Prev_Daz * D_Az + Cur_Daz * (Last_Az - Eye_Az);
                    D_El := Prev_Del * D_El + Cur_Del * (Last_El - Eye_El);
                    Last_Az := Eye_Az;
                    Last_El := Eye_El;
                when Glut.Middle =>
                    Eye_Dist := Down_Dist + Dist_Sens * GLfloat (Delta_Y);
                    Move_Eye (E_Sens * GLfloat (Delta_Y));
                when Glut.Right =>
                    null;
            end case;
        end if;
        Glut.Post_Redisplay;
    end Handle_Motion;

    --  Sets the speed in flying mode.
    procedure Set_Move
           (New_Move : in GLfloat) is
    begin
        if New_Move > Min_Move then
            Eye_Move := New_Move;
            Move_On (True);
        else
            Eye_Move := 0.0;
            Move_On (False);
        end if;
    end Set_Move;

    --  0 to 9 set the speed, + and - change it, in flying mode.
    procedure Handle_Keys
           (Key  : in Character;
            X, Y : in Integer)
    is
        pragma Unreferenced (X, Y);
        N : Integer;
    begin
        if Move_Mode /= Flying then
            return;
        end if;
        case Key is
            when '0' .. '9' =>
                N := Character'Pos (Key) - Character'Pos ('0');
                Set_Move (GLfloat (N * N) * 0.001);
            when '+' =>
                if Eye_Move = 0.0 then
                    Set_Move (Min_Move);
                else
                    Eye_Move := Eye_Move * (1.0 + Move_Fraction);
                    Set_Move (Eye_Move);
                end if;
            when '-' =>
                Eye_Move := Eye_Move * (1.0 - Move_Fraction);
                Set_Move (Eye_Move);
            when others =>
                null;
        end case;
    end Handle_Keys;

    procedure Viewer_Init
           (Allow : in Boolean) is
    begin
        Glut.Mouse_Func (Handle_Button'Unrestricted_Access);
        Glut.Motion_Func (Handle_Motion'Unrestricted_Access);
        Glut.Keyboard_Func (Handle_Keys'Unrestricted_Access);
        Redisplay_Window := Glut.Get_Window;
        Set_Allow_Idle (Allow);
    end Viewer_Init;

    --  The axes, which helped to design things.
    procedure Make_Axes_List
           (List : in GLuint)
    is
        Trans : constant GLfloat := -10.0;

        --  C's (b), as 1.0 or 0.0
        function F
               (B : in Boolean)
            return GLfloat is
        begin
            return (if B then 1.0 else 0.0);
        end F;
    begin
        glNewList (List, GL_COMPILE);
        glPushAttrib (GL_LIGHTING_BIT);
        glMatrixMode (GL_MODELVIEW);
        glMaterialfv (GL_FRONT, GL_AMBIENT_AND_DIFFUSE, (0.5, 0.0, 0.0, 1.0));
        glBegin (GL_LINES);
        glVertex3f (15.0, 0.0, 0.0);
        glVertex3f (-15.0, 0.0, 0.0);
        glVertex3f (0.0, 15.0, 0.0);
        glVertex3f (0.0, -15.0, 0.0);
        glVertex3f (0.0, 0.0, 15.0);
        glVertex3f (0.0, 0.0, -15.0);
        glEnd;
        for I in 0 .. 2 loop
            glPushMatrix;
            glTranslatef (Trans * F (I = 0), Trans * F (I = 1), Trans * F (I = 2));
            for J in 1 .. 21 loop
                glTranslatef (F (I = 0), F (I = 1), F (I = 2));
            end loop;
            glPopMatrix;
        end loop;
        glPopAttrib;
        glEndList;
    end Make_Axes_List;




    --  GLUT Callbacks  --

    procedure Reshape
           (W, H : in Integer) is
    begin
        glViewport (0, 0, GLsizei (W), GLsizei (H));
        Win_Width := W;
        Win_Height := H;
    end Reshape;

    procedure Display
    is
        Cur_Time : Long_Long_Integer;
    begin
        glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
        glMatrixMode (GL_PROJECTION);
        glLoadIdentity;
        GLU.Perspective (60.0, Long_Float (Win_Width) / Long_Float (Win_Height), 0.01, 100.0);
        View_Transform;
        glMatrixMode (GL_MODELVIEW);
        glLoadIdentity;
        if Rebuild then
            Create (Fractal);
            Rebuild := False;
        end if;
        glCallList (Fractal);
        if Draw_Axes then
            glCallList (Axes_List);
        end if;

        glMatrixMode (GL_PROJECTION);
        glLoadIdentity;
        GLU.Ortho_2D (0.0, Long_Float (Win_Width), 0.0, Long_Float (Win_Height));
        glColor3f (1.0, 1.0, 1.0);
        GLD.Set_Font (FLTK.Helvetica, 12);
        GLD.Draw_Text (10, 10, "FPS=" & Image (Fps));
        glFinish;

        Fps_Count := Fps_Count + 1;
        Cur_Time := Now;
        if Cur_Time - Fps_Time >= 2 then
            Fps := (Fps + Fps_Count / Integer (Cur_Time - Fps_Time)) / 2;
            Fps_Time := Cur_Time;
            Fps_Count := 0;
        end if;
    end Display;

    procedure Visibility_Changed
           (State : in Glut.Visibility_State) is
    begin
        if State = Glut.Visible then
            Set_Allow_Idle (True);
        else
            Glut.Idle_Func (null);
            Set_Allow_Idle (False);
        end if;
    end Visibility_Changed;

    procedure Menu_Use
           (State : in Glut.Menu_State) is
    begin
        if State = Glut.Not_In_Use then
            Set_Allow_Idle (True);
        else
            Glut.Idle_Func (null);
            Set_Allow_Idle (False);
        end if;
    end Menu_Use;




    --  The Window  --

    type Level_Button is new Btn.Button with record
        Level : Natural := 0;
    end record;

    type Fract_Button is new Btn.Button with record
        Fract : GLuint := Tree_List;
    end record;

    type Command_Button is new Btn.Button with record
        Value : Integer := Menu_Rand;
    end record;

    Window : Win.Window := Win.Forge.Create (512 + 20, 512 + 100);
    Group  : Grp.Group := Grp.Forge.Create (Window, 110, 50, 400 - 110, 30, "Level:");
    L0     : Level_Button := (Btn.Forge.Create (Group, 110, 50, 30, 30, "0") with Level => 0);
    L1     : Level_Button := (Btn.Forge.Create (Group, 140, 50, 30, 30, "1") with Level => 1);
    L2     : Level_Button := (Btn.Forge.Create (Group, 170, 50, 30, 30, "2") with Level => 2);
    L3     : Level_Button := (Btn.Forge.Create (Group, 200, 50, 30, 30, "3") with Level => 3);
    L4     : Level_Button := (Btn.Forge.Create (Group, 230, 50, 30, 30, "4") with Level => 4);
    L5     : Level_Button := (Btn.Forge.Create (Group, 260, 50, 30, 30, "5") with Level => 5);
    L6     : Level_Button := (Btn.Forge.Create (Group, 290, 50, 30, 30, "6") with Level => 6);
    L7     : Level_Button := (Btn.Forge.Create (Group, 320, 50, 30, 30, "7") with Level => 7);
    L8     : Level_Button := (Btn.Forge.Create (Group, 350, 50, 30, 30, "8") with Level => 8);
    New_B  : Command_Button :=
        (Btn.Forge.Create (Window, 400, 50, 100, 30, "New Fractal") with Value => Menu_Rand);
    Mtn_B  : Fract_Button :=
        (Btn.Forge.Create (Window, 10, 10, 100, 30, "Mountain") with Fract => Mountain_List);
    Tree_B : Fract_Button :=
        (Btn.Forge.Create (Window, 110, 10, 100, 30, "Tree") with Fract => Tree_List);
    Isl_B  : Fract_Button :=
        (Btn.Forge.Create (Window, 210, 10, 100, 30, "Island") with Fract => Island_List);
    Quit_B : Command_Button :=
        (Btn.Forge.Create (Window, 400, 10, 100, 30, "Quit") with Value => Menu_Quit);




    --  Menus  --

    procedure Set_Level
           (Value : in Integer) is
    begin
        Level := Value;
        Rebuild := True;
        Glut.Post_Redisplay;
    end Set_Level;

    procedure Choose_Fract
           (Value : in Integer) is
    begin
        Fractal := GLuint (Value);
        Rebuild := True;
        Glut.Post_Redisplay;
    end Choose_Fract;

    procedure Handle_Menu
           (Value : in Integer) is
    begin
        case Value is
            when Menu_Quit =>
                Window.Hide;
            when Menu_Rand =>
                New_Fractals;
                Rebuild := True;
                Glut.Post_Redisplay;
            when Menu_Axes =>
                Draw_Axes := not Draw_Axes;
                Glut.Post_Redisplay;
            when others =>
                null;
        end case;
    end Handle_Menu;

    procedure Menu_Init
    is
        Submenu1, Submenu2, Submenu3, Main_Menu : Glut.Valid_Menu_Number;
    begin
        Submenu1 := Glut.Create_Menu (Set_Level'Unrestricted_Access);
        for I in 0 .. Max_Level loop
            Glut.Add_Menu_Entry (Image (I), I);
        end loop;
        Submenu2 := Glut.Create_Menu (Choose_Fract'Unrestricted_Access);
        Glut.Add_Menu_Entry ("Moutain", Integer (Mountain_List));  --  sic
        Glut.Add_Menu_Entry ("Tree", Integer (Tree_List));
        Glut.Add_Menu_Entry ("Island", Integer (Island_List));
        Submenu3 := Glut.Create_Menu (Switch_Move_Mode'Unrestricted_Access);
        Glut.Add_Menu_Entry ("Flying", Movement'Pos (Flying));
        Glut.Add_Menu_Entry ("Polar", Movement'Pos (Polar));
        Main_Menu := Glut.Create_Menu (Handle_Menu'Unrestricted_Access);
        Glut.Add_Sub_Menu ("Level", Submenu1);
        Glut.Add_Sub_Menu ("Fractal", Submenu2);
        Glut.Add_Sub_Menu ("Movement", Submenu3);
        Glut.Add_Menu_Entry ("New Fractal", Menu_Rand);
        Glut.Add_Menu_Entry ("Toggle Axes", Menu_Axes);
        Glut.Add_Menu_Entry ("Quit", Menu_Quit);
        Glut.Attach_Menu (Glut.Right);
        pragma Unreferenced (Main_Menu);
    end Menu_Init;




    --  FLTK Callbacks  --

    procedure Level_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Set_Level (Level_Button (Item).Level);
    end Level_CB;

    procedure Fract_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Choose_Fract (Integer (Fract_Button (Item).Fract));
    end Fract_CB;

    procedure Command_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Handle_Menu (Command_Button (Item).Value);
    end Command_CB;


begin

    FLTK.Static.Set_Use_High_Res_GL (True);
    Window.Set_Resizable (Window);
    Group.Set_Alignment (FLTK.Align_Left);
    L0.Set_Callback (Level_CB'Unrestricted_Access);
    L1.Set_Callback (Level_CB'Unrestricted_Access);
    L2.Set_Callback (Level_CB'Unrestricted_Access);
    L3.Set_Callback (Level_CB'Unrestricted_Access);
    L4.Set_Callback (Level_CB'Unrestricted_Access);
    L5.Set_Callback (Level_CB'Unrestricted_Access);
    L6.Set_Callback (Level_CB'Unrestricted_Access);
    L7.Set_Callback (Level_CB'Unrestricted_Access);
    L8.Set_Callback (Level_CB'Unrestricted_Access);
    New_B.Set_Callback (Command_CB'Unrestricted_Access);
    Mtn_B.Set_Callback (Fract_CB'Unrestricted_Access);
    Tree_B.Set_Callback (Fract_CB'Unrestricted_Access);
    Isl_B.Set_Callback (Fract_CB'Unrestricted_Access);
    Quit_B.Set_Callback (Command_CB'Unrestricted_Access);
    Window.Show_With_Args;  --  GLUT dies unless the parent window is shown

    --  glutCreateWindow, inside the shown window, as the C++ makes it
    --  between window.begin () and window.end ().
    Glut.Init_Display_Mode
       ((Double => True, Depth => True, Multisample => True, others => False));
    declare
        Planet : Glt.Glut_Window := Glt.Forge.Create (Window, 10, 90, 512, 512, "Fractal Planet?");
    begin
        Planet.Set_Resizable (Planet);
        Planet.Show;
        Planet.Set_Valid (False);
        Planet.Set_Context_Valid (False);
        Planet.Make_Current;
        Planet.Redraw;
        Window.Set_Resizable (Planet);

        Viewer_Init (True);  --  True, since there is no other idle procedure
        Glut.Reshape_Func (Reshape'Unrestricted_Access);
        Glut.Display_Func (Display'Unrestricted_Access);
        Glut.Visibility_Func (Visibility_Changed'Unrestricted_Access);
        Glut.Menu_State_Func (Menu_Use'Unrestricted_Access);
        New_Fractals;
        Make_Axes_List (Axes_List);
        My_GL_Init;
        Menu_Init;
        Glut.Main_Loop;
    end;
    return 0;

end Fractals;
