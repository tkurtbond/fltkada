--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 20:  the versions of the FLTK headers the shim was
--  compiled with, beside those of the library running, after pofltk's
--  checks in test/TestStatics.Mod.  Version was a Version_Number, and so
--  1 (FLTKAda-BUGS.md 126).


with

    Checks,
    FLTK;

use

    Checks;

use type

    FLTK.Version_Number;


procedure Test_Versions is
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

    Summary;

end Test_Versions;
