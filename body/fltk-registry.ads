

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Containers.Ordered_Maps,
    FLTK.Labels;


private package FLTK.Registry is


    --  It finally became untenable to keep only ad hoc back-references to Ada
    --  when some crucial structs and objects don't have handy built-in space
    --  for user data already available.


    type Label_Access is access all FLTK.Labels.Label'Class;

    package Label_Backref_Maps is new Ada.Containers.Ordered_Maps
       (Key_Type     => Storage.Integer_Address,
        Element_Type => Label_Access);

    Label_Store : Label_Backref_Maps.Map;


end FLTK.Registry;


