--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 86: a File_Chooser's kind is FLTK's bit mask, SINGLE 0,
--  MULTI 1, CREATE 2 and DIRECTORY 4, which FLTK lets a program combine
--  (Fl_File_Chooser.H:50-55).  Fl_File_Chooser::type activates the New
--  button exactly when CREATE is in it (Fl_File_Chooser.cxx:428-431), so
--  the button shows which kind FLTK was given.


with

    Ada.Exceptions,
    Checks,
    FLTK.File_Choosers;

use

    Checks;


procedure Test_Chooser_Kind is

    package FC renames FLTK.File_Choosers;

    use type FC.Chooser_Kind;

    Chooser : FC.File_Chooser := FC.Forge.Create ("Test_Chooser_Kind", "*", ".");

begin

    Chooser.Set_Kind (FC.Create);
    Check (Chooser.New_Button.Is_Active, "Create: the New button is active");

    Chooser.Set_Kind (FC.Directory);
    Check (not Chooser.New_Button.Is_Active, "Directory: the New button is inactive");
    Check (Chooser.Get_Kind = FC.Directory, "Directory: Get_Kind gives it back");

    Chooser.Set_Kind (FC.Create + FC.Directory);
    Check (Chooser.New_Button.Is_Active, "Create + Directory: the New button is active");
    Check (Chooser.Get_Kind = FC.Create + FC.Directory,
           "Create + Directory: Get_Kind gives it back");
    Check (FC.Includes (Chooser.Get_Kind, FC.Directory), "Create + Directory includes Directory");
    Check (not FC.Includes (Chooser.Get_Kind, FC.Multi), "Create + Directory excludes Multi");
    Check (FC.Multi - FC.Multi = FC.Single, "Multi - Multi is Single");
    Check (FC.Includes (FC.Multi, FC.Single), "every kind includes Single");

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Chooser_Kind;
