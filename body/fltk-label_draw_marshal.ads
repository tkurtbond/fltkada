

--  Programmed by Jedidiah Barber
--  Released into the public domain


limited with

    FLTK.Static;


private package FLTK.Label_Draw_Marshal is


    function To_C
           (Kind : in Label_Kind;
            Func : in FLTK.Static.Label_Draw_Function)
        return Storage.Integer_Address;

    function To_C
           (Kind : in Label_Kind;
            Func : in FLTK.Static.Label_Measure_Function)
        return Storage.Integer_Address;


end FLTK.Label_Draw_Marshal;


