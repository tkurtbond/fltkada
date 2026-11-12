--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 20:  the versions of the FLTK headers the shim was
--  compiled with, beside those of the library running, after pofltk's
--  checks in test/TestStatics.Mod.  Version was a Version_Number, and so
--  1 (FLTKAda-BUGS.md 126).  Phase 22:  the display's platform, which
--  FLTK's test/fltk-versions.cxx prints, against the one the environment
--  chooses (fl_wayland_platform_init.cxx:52-81):  FLTK_BACKEND's "x11" or
--  "wayland", or else Wayland if it connects.  Unset, WAYLAND_DISPLAY is
--  "wayland-0" to libwayland, which the desktop's socket isn't here, so
--  the test takes it as X11:  under xvfb-run with WAYLAND_DISPLAY unset
--  X11, and on tools/with-sway.sh Wayland.


with

    Ada.Environment_Variables,
    Checks,
    FLTK.Static;

use

    Checks;

use type

    FLTK.Static.Display_Platform,
    FLTK.Version_Number;


procedure Test_Versions is

    package Env renames Ada.Environment_Variables;

    function Set
           (Name : in String)
        return Boolean is
    begin
        return Env.Exists (Name) and then Env.Value (Name) /= "";
    end Set;

    Backend : constant String :=
        (if Env.Exists ("FLTK_BACKEND") then Env.Value ("FLTK_BACKEND") else "");

    Expected : constant FLTK.Static.Display_Platform :=
        (if Backend = "wayland" or (Backend /= "x11" and Set ("WAYLAND_DISPLAY"))
         then FLTK.Static.Wayland_Platform
         else FLTK.Static.X11_Platform);

begin

    Check (FLTK.Version >= 1.04 and FLTK.Version < 2.0,
        "Version is major + minor / 100 + patch / 10000:" & Long_Float'Image (FLTK.Version));
    Check (FLTK.API_Version >= 10400, "API_Version:" & FLTK.API_Version'Image);
    Check (FLTK.ABI_Version >= 10400, "ABI_Version:" & FLTK.ABI_Version'Image);
    Check (abs (FLTK.Version - Long_Float (FLTK.API_Version) / 10_000.0) < 1.0E-9,
        "Version and API_Version agree");
    Check (FLTK.Built_Version = FLTK.Version, "Built_Version");
    Check (FLTK.Built_API_Version = FLTK.API_Version, "Built_API_Version");
    Check (FLTK.Built_ABI_Version = FLTK.ABI_Version, "Built_ABI_Version");
    Check (FLTK.Built_ABI_Version = FLTK.Built_API_Version / 100 * 100,
        "the ABI version is the API version without the patch");
    Check (FLTK.ABI_Check, "ABI_Check, by default of the version built with");
    Check (not FLTK.ABI_Check (FLTK.ABI_Version + 100), "ABI_Check of another version");

    Check (FLTK.Static.Get_Display_Platform = Expected,
        "Get_Display_Platform is " & FLTK.Static.Get_Display_Platform'Image &
        ", expected " & Expected'Image);

    Summary;

end Test_Versions;
