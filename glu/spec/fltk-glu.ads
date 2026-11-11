--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  The part of GLU, the OpenGL utility library, that FLTK's programs use,
--  after pofltk's FlGlu: setting up the view, and drawing quadrics.  Call
--  these in a GL window's Draw, or between Draw_Begin and Draw_End; GL
--  ignores them anywhere else.  It is a library of its own, fltkada_glu,
--  so that a program using only widgets isn't linked with libGLU.


with

    Ada.Finalization;


package FLTK.GLU is


    -------------
    --  Types  --
    -------------

    --  How a quadric is drawn: as points, lines, filled polygons, or lines
    --  only at edges between faces that aren't coplanar.
    type Draw_Style is (Point, Line, Fill, Silhouette);

    --  Which normals a quadric gives: one per vertex, one per face, none.
    type Normal_Kind is (Smooth_Normals, Flat_Normals, No_Normals);

    --  Which way a quadric's normals point.
    type Orientation is (Outside, Inside);

    --  A viewport, as glGetIntegerv (GL_VIEWPORT) gives it.
    type Viewport_Area is record
        X, Y, W, H : Integer;
    end record;

    --  A quadric's settings.  It is closed when finalized, or by Close.
    type Quadric is new Ada.Finalization.Limited_Controlled with private;




    ------------
    --  View  --
    ------------

    --  Multiplies the current matrix by a perspective projection.
    procedure Perspective
           (Field_Of_View_Y : in Long_Float;
            Aspect          : in Long_Float;
            Near, Far       : in Long_Float);

    --  Multiplies the current matrix by a view from the eye towards the
    --  centre, with Up upwards.
    procedure Look_At
           (Eye_X, Eye_Y, Eye_Z          : in Long_Float;
            Centre_X, Centre_Y, Centre_Z : in Long_Float;
            Up_X, Up_Y, Up_Z             : in Long_Float);

    --  Multiplies the current matrix by an orthographic projection, with
    --  near -1 and far 1.
    procedure Ortho_2D
           (Left, Right, Bottom, Top : in Long_Float);

    --  Multiplies the current matrix by one that draws only the region
    --  W by H centred on X, Y, in window coordinates, of Viewport.
    procedure Pick_Matrix
           (X, Y, W, H : in Long_Float;
            Viewport   : in Viewport_Area);




    ----------------
    --  Quadrics  --
    ----------------

    package Forge is

        --  A new quadric, filled, with smooth normals pointing outside and
        --  no texture coordinates.  Raises Storage_Error if GLU has no
        --  memory for it.
        function Create
            return Quadric;

    end Forge;

    --  These raise Program_Error if This is closed, and Constraint_Error
    --  for a count less than 1.

    procedure Set_Draw_Style
           (This  : in out Quadric;
            Style : in     Draw_Style);

    procedure Set_Normals
           (This    : in out Quadric;
            Normals : in     Normal_Kind);

    procedure Set_Orientation
           (This : in out Quadric;
            Way  : in     Orientation);

    --  Whether to give texture coordinates.
    procedure Set_Texture
           (This : in out Quadric;
            To   : in     Boolean);

    --  A cylinder along Z, from Z = 0 to Height, of radius Base at Z = 0
    --  and Top at Height.
    procedure Cylinder
           (This           : in out Quadric;
            Base, Top      : in     Long_Float;
            Height         : in     Long_Float;
            Slices, Stacks : in     Positive);

    procedure Sphere
           (This           : in out Quadric;
            Radius         : in     Long_Float;
            Slices, Stacks : in     Positive);

    --  A disk at Z = 0, with a hole of radius Inner.
    procedure Disk
           (This          : in out Quadric;
            Inner, Outer  : in     Long_Float;
            Slices, Loops : in     Positive);

    --  Part of a disk, from Start degrees clockwise from +Y, through Sweep.
    procedure Partial_Disk
           (This          : in out Quadric;
            Inner, Outer  : in     Long_Float;
            Slices, Loops : in     Positive;
            Start, Sweep  : in     Long_Float);

    --  May be called again.
    procedure Close
           (This : in out Quadric);

    function Is_Closed
           (This : in Quadric)
        return Boolean;


private


    pragma Linker_Options ("-lGLU");


    for Draw_Style use
       (Point      => 100_010,
        Line       => 100_011,
        Fill       => 100_012,
        Silhouette => 100_013);

    for Normal_Kind use
       (Smooth_Normals => 100_000,
        Flat_Normals   => 100_001,
        No_Normals     => 100_002);

    for Orientation use
       (Outside => 100_020,
        Inside  => 100_021);

    type Quadric is new Ada.Finalization.Limited_Controlled with record
        Handle : Storage.Integer_Address := Null_Pointer;
    end record;

    overriding procedure Finalize
           (This : in out Quadric);


end FLTK.GLU;
