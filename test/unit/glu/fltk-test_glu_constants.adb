--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.
--
--  Written by tools/gen-constants.py; edit that, not this.


--  Checks each of FLTKAda's constants against FLTK's value, from
--  c_glu_constants.cpp.  A child of FLTK, so it can see the private
--  conversions.  Run by test_glu_constants.adb.


with

    Checks,
    FLTK.GLU;


procedure FLTK.Test_GLU_Constants is


    package GLU renames FLTK.GLU;


    type Value_Array is array (1 .. 9) of Long_Long_Integer;
    pragma Convention (C, Value_Array);

    FLTK_Values : Value_Array;
    pragma Import (C, FLTK_Values, "c_glu_constants");


    procedure Same
           (Ada_Value : in Long_Long_Integer;
            Index     : in Positive;
            Label     : in String)
    is
        FLTK_Value : constant Long_Long_Integer := FLTK_Values (Index);
    begin
        if Ada_Value = FLTK_Value then
            Checks.Check (True, Label & " =" & Long_Long_Integer'Image (FLTK_Value));
        else
            Checks.Check
               (False, Label & ": FLTKAda has" & Long_Long_Integer'Image (Ada_Value) &
                ", FLTK" & Long_Long_Integer'Image (FLTK_Value));
        end if;
    end Same;


begin

    --  Quadric draw styles (gluQuadricDrawStyle)
    Same
       (Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Point)),
        1,
        "Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Point)) = GLU_POINT");
    Same
       (Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Line)),
        2,
        "Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Line)) = GLU_LINE");
    Same
       (Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Fill)),
        3,
        "Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Fill)) = GLU_FILL");
    Same
       (Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Silhouette)),
        4,
        "Long_Long_Integer (GLU.Draw_Style'Enum_Rep (GLU.Silhouette)) = GLU_SILHOUETTE");

    --  Quadric normals (gluQuadricNormals)
    Same
       (Long_Long_Integer (GLU.Normal_Kind'Enum_Rep (GLU.Smooth_Normals)),
        5,
        "Long_Long_Integer (GLU.Normal_Kind'Enum_Rep (GLU.Smooth_Normals)) = GLU_SMOOTH");
    Same
       (Long_Long_Integer (GLU.Normal_Kind'Enum_Rep (GLU.Flat_Normals)),
        6,
        "Long_Long_Integer (GLU.Normal_Kind'Enum_Rep (GLU.Flat_Normals)) = GLU_FLAT");
    Same
       (Long_Long_Integer (GLU.Normal_Kind'Enum_Rep (GLU.No_Normals)),
        7,
        "Long_Long_Integer (GLU.Normal_Kind'Enum_Rep (GLU.No_Normals)) = GLU_NONE");

    --  Quadric orientations (gluQuadricOrientation)
    Same
       (Long_Long_Integer (GLU.Orientation'Enum_Rep (GLU.Outside)),
        8,
        "Long_Long_Integer (GLU.Orientation'Enum_Rep (GLU.Outside)) = GLU_OUTSIDE");
    Same
       (Long_Long_Integer (GLU.Orientation'Enum_Rep (GLU.Inside)),
        9,
        "Long_Long_Integer (GLU.Orientation'Enum_Rep (GLU.Inside)) = GLU_INSIDE");

end FLTK.Test_GLU_Constants;
