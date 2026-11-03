

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    FLTK.Hook_Exceptions,
    FLTK.Labels,
    FLTK.Registry,
    FLTK.Static,
    Interfaces.C;

use type

    FLTK.Static.Label_Draw_Function,
    FLTK.Static.Label_Measure_Function;


package body FLTK.Label_Draw_Marshal is


    package Chk renames Ada.Assertions;




    Draw_Array    : array (Label_Kind) of FLTK.Static.Label_Draw_Function;
    Measure_Array : array (Label_Kind) of FLTK.Static.Label_Measure_Function;




    procedure Label_Draw_Hook
           (L          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            A          : in Interfaces.Unsigned_16)
    with Convention => C;

    procedure Label_Draw_Hook
           (L          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            A          : in Interfaces.Unsigned_16)
    is
        My_Label : access FLTK.Labels.Label'Class;
    begin
        pragma Assert (FLTK.Registry.Label_Store.Contains (L));
        My_Label := FLTK.Registry.Label_Store.Element (L);
        Draw_Array (My_Label.Get_Kind)
           (My_Label.all,
            Integer (X), Integer (Y),
            Integer (W), Integer (H),
            Alignment (A));
    exception
    when Chk.Assertion_Error =>
        Hook_Exceptions.Save_New
           (Internal_FLTK_Error'Identity,
            "Label_Draw_Hook was handed Label with no back reference to Ada in registry");
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Label_Draw_Hook;


    procedure Label_Measure_Hook
           (L    : in     Storage.Integer_Address;
            W, H :    out Interfaces.C.int)
    with Convention => C;

    procedure Label_Measure_Hook
           (L    : in     Storage.Integer_Address;
            W, H :    out Interfaces.C.int)
    is
        My_Label : access FLTK.Labels.Label'Class;
    begin
        pragma Assert (FLTK.Registry.Label_Store.Contains (L));
        My_Label := FLTK.Registry.Label_Store.Element (L);
        Measure_Array (My_Label.Get_Kind)
           (My_Label.all,
            Integer (W), Integer (H));
    exception
    when Chk.Assertion_Error =>
        Hook_Exceptions.Save_New
           (Internal_FLTK_Error'Identity,
            "Label_Measure_Hook was handed Label with no back reference to Ada in registry");
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence);
    end Label_Measure_Hook;




    function To_C
           (Kind : in Label_Kind;
            Func : in FLTK.Static.Label_Draw_Function)
        return Storage.Integer_Address is
    begin
        if Func = null then
            return Null_Pointer;
        end if;
        Draw_Array (Kind) := Func;
        return Storage.To_Integer (Label_Draw_Hook'Address);
    end To_C;


    function To_C
           (Kind : in Label_Kind;
            Func : in FLTK.Static.Label_Measure_Function)
        return Storage.Integer_Address is
    begin
        if Func = null then
            return Null_Pointer;
        end if;
        Measure_Array (Kind) := Func;
        return Storage.To_Integer (Label_Measure_Hook'Address);
    end To_C;


end FLTK.Label_Draw_Marshal;


