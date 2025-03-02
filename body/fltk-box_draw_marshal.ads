

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Static;


private package FLTK.Box_Draw_Marshal is


    function To_Ada
           (Kind : in Box_Kind;
            Ptr  : in Storage.Integer_Address)
        return FLTK.Static.Box_Draw_Function;

    function To_C
           (Kind : in Box_Kind;
            Func : in FLTK.Static.Box_Draw_Function)
        return Storage.Integer_Address;


end FLTK.Box_Draw_Marshal;


