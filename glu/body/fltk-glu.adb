--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Interfaces.C;


package body FLTK.GLU is


    package C renames Interfaces.C;

    subtype C_Double is Interfaces.C.double;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  View  --

    procedure fl_glu_perspective
           (Fovy, Aspect, N, F : in C_Double);
    pragma Import (C, fl_glu_perspective, "fl_glu_perspective");
    pragma Inline (fl_glu_perspective);

    procedure fl_glu_look_at
           (EX, EY, EZ, CX, CY, CZ, UX, UY, UZ : in C_Double);
    pragma Import (C, fl_glu_look_at, "fl_glu_look_at");
    pragma Inline (fl_glu_look_at);

    procedure fl_glu_ortho_2d
           (L, R, B, T : in C_Double);
    pragma Import (C, fl_glu_ortho_2d, "fl_glu_ortho_2d");
    pragma Inline (fl_glu_ortho_2d);

    procedure fl_glu_pick_matrix
           (X, Y, W, H     : in C_Double;
            VX, VY, VW, VH : in C.int);
    pragma Import (C, fl_glu_pick_matrix, "fl_glu_pick_matrix");
    pragma Inline (fl_glu_pick_matrix);




    --  Quadrics  --

    function fl_glu_new_quadric
        return Storage.Integer_Address;
    pragma Import (C, fl_glu_new_quadric, "fl_glu_new_quadric");
    pragma Inline (fl_glu_new_quadric);

    procedure fl_glu_delete_quadric
           (Q : in Storage.Integer_Address);
    pragma Import (C, fl_glu_delete_quadric, "fl_glu_delete_quadric");
    pragma Inline (fl_glu_delete_quadric);

    procedure fl_glu_quadric_draw_style
           (Q     : in Storage.Integer_Address;
            Style : in C.unsigned);
    pragma Import (C, fl_glu_quadric_draw_style, "fl_glu_quadric_draw_style");
    pragma Inline (fl_glu_quadric_draw_style);

    procedure fl_glu_quadric_normals
           (Q       : in Storage.Integer_Address;
            Normals : in C.unsigned);
    pragma Import (C, fl_glu_quadric_normals, "fl_glu_quadric_normals");
    pragma Inline (fl_glu_quadric_normals);

    procedure fl_glu_quadric_orientation
           (Q   : in Storage.Integer_Address;
            Way : in C.unsigned);
    pragma Import (C, fl_glu_quadric_orientation, "fl_glu_quadric_orientation");
    pragma Inline (fl_glu_quadric_orientation);

    procedure fl_glu_quadric_texture
           (Q  : in Storage.Integer_Address;
            On : in C.int);
    pragma Import (C, fl_glu_quadric_texture, "fl_glu_quadric_texture");
    pragma Inline (fl_glu_quadric_texture);

    procedure fl_glu_cylinder
           (Q              : in Storage.Integer_Address;
            Base, Top, H   : in C_Double;
            Slices, Stacks : in C.int);
    pragma Import (C, fl_glu_cylinder, "fl_glu_cylinder");
    pragma Inline (fl_glu_cylinder);

    procedure fl_glu_sphere
           (Q              : in Storage.Integer_Address;
            R              : in C_Double;
            Slices, Stacks : in C.int);
    pragma Import (C, fl_glu_sphere, "fl_glu_sphere");
    pragma Inline (fl_glu_sphere);

    procedure fl_glu_disk
           (Q             : in Storage.Integer_Address;
            Inner, Outer  : in C_Double;
            Slices, Loops : in C.int);
    pragma Import (C, fl_glu_disk, "fl_glu_disk");
    pragma Inline (fl_glu_disk);

    procedure fl_glu_partial_disk
           (Q             : in Storage.Integer_Address;
            Inner, Outer  : in C_Double;
            Slices, Loops : in C.int;
            Start, Sweep  : in C_Double);
    pragma Import (C, fl_glu_partial_disk, "fl_glu_partial_disk");
    pragma Inline (fl_glu_partial_disk);




    ---------------
    --  Helpers  --
    ---------------

    function Live
           (This : in Quadric'Class)
        return Storage.Integer_Address is
    begin
        if This.Handle = Null_Pointer then
            raise Program_Error with "a GLU quadric used after it was closed";
        end if;
        return This.Handle;
    end Live;




    ------------
    --  View  --
    ------------

    procedure Perspective
           (Field_Of_View_Y : in Long_Float;
            Aspect          : in Long_Float;
            Near, Far       : in Long_Float) is
    begin
        fl_glu_perspective
           (C_Double (Field_Of_View_Y), C_Double (Aspect), C_Double (Near), C_Double (Far));
    end Perspective;


    procedure Look_At
           (Eye_X, Eye_Y, Eye_Z          : in Long_Float;
            Centre_X, Centre_Y, Centre_Z : in Long_Float;
            Up_X, Up_Y, Up_Z             : in Long_Float) is
    begin
        fl_glu_look_at
           (C_Double (Eye_X), C_Double (Eye_Y), C_Double (Eye_Z),
            C_Double (Centre_X), C_Double (Centre_Y), C_Double (Centre_Z),
            C_Double (Up_X), C_Double (Up_Y), C_Double (Up_Z));
    end Look_At;


    procedure Ortho_2D
           (Left, Right, Bottom, Top : in Long_Float) is
    begin
        fl_glu_ortho_2d (C_Double (Left), C_Double (Right), C_Double (Bottom), C_Double (Top));
    end Ortho_2D;


    procedure Pick_Matrix
           (X, Y, W, H : in Long_Float;
            Viewport   : in Viewport_Area) is
    begin
        fl_glu_pick_matrix
           (C_Double (X), C_Double (Y), C_Double (W), C_Double (H),
            C.int (Viewport.X), C.int (Viewport.Y), C.int (Viewport.W), C.int (Viewport.H));
    end Pick_Matrix;




    ----------------
    --  Quadrics  --
    ----------------

    package body Forge is

        function Create
            return Quadric is
        begin
            return This : Quadric do
                This.Handle := fl_glu_new_quadric;
                if This.Handle = Null_Pointer then
                    raise Storage_Error with "GLU has no memory for a quadric";
                end if;
            end return;
        end Create;

    end Forge;


    procedure Set_Draw_Style
           (This  : in out Quadric;
            Style : in     Draw_Style) is
    begin
        fl_glu_quadric_draw_style (Live (This), Draw_Style'Enum_Rep (Style));
    end Set_Draw_Style;


    procedure Set_Normals
           (This    : in out Quadric;
            Normals : in     Normal_Kind) is
    begin
        fl_glu_quadric_normals (Live (This), Normal_Kind'Enum_Rep (Normals));
    end Set_Normals;


    procedure Set_Orientation
           (This : in out Quadric;
            Way  : in     Orientation) is
    begin
        fl_glu_quadric_orientation (Live (This), Orientation'Enum_Rep (Way));
    end Set_Orientation;


    procedure Set_Texture
           (This : in out Quadric;
            To   : in     Boolean) is
    begin
        fl_glu_quadric_texture (Live (This), Boolean'Pos (To));
    end Set_Texture;


    procedure Cylinder
           (This           : in out Quadric;
            Base, Top      : in     Long_Float;
            Height         : in     Long_Float;
            Slices, Stacks : in     Positive) is
    begin
        fl_glu_cylinder
           (Live (This), C_Double (Base), C_Double (Top), C_Double (Height),
            C.int (Slices), C.int (Stacks));
    end Cylinder;


    procedure Sphere
           (This           : in out Quadric;
            Radius         : in     Long_Float;
            Slices, Stacks : in     Positive) is
    begin
        fl_glu_sphere (Live (This), C_Double (Radius), C.int (Slices), C.int (Stacks));
    end Sphere;


    procedure Disk
           (This          : in out Quadric;
            Inner, Outer  : in     Long_Float;
            Slices, Loops : in     Positive) is
    begin
        fl_glu_disk
           (Live (This), C_Double (Inner), C_Double (Outer), C.int (Slices), C.int (Loops));
    end Disk;


    procedure Partial_Disk
           (This          : in out Quadric;
            Inner, Outer  : in     Long_Float;
            Slices, Loops : in     Positive;
            Start, Sweep  : in     Long_Float) is
    begin
        fl_glu_partial_disk
           (Live (This), C_Double (Inner), C_Double (Outer), C.int (Slices), C.int (Loops),
            C_Double (Start), C_Double (Sweep));
    end Partial_Disk;


    procedure Close
           (This : in out Quadric) is
    begin
        if This.Handle /= Null_Pointer then
            fl_glu_delete_quadric (This.Handle);
            This.Handle := Null_Pointer;
        end if;
    end Close;


    function Is_Closed
           (This : in Quadric)
        return Boolean is
    begin
        return This.Handle = Null_Pointer;
    end Is_Closed;


    procedure Finalize
           (This : in out Quadric) is
    begin
        Close (This);
    end Finalize;


end FLTK.GLU;
