

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Negative control: a C string that FLTKAda's code makes with New_String
--  and never frees, which vg-check.sh must flag.  GNAT's run-time library
--  allocates it, so the frames from i-cstrin.adb down are skipped.


with

    FLTK.Control_Strings;


procedure Control_String_Leak is
begin
    FLTK.Control_Strings.Leak ("leaked string");
end Control_String_Leak;


