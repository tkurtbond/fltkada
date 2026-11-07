

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK.Environment.Plugins: finding objects by class, and loading shared
--  libraries, after pofltk's TestPlugins and its halt tests (pofltk 108).
--  ../../bin/unit/plugins holds one.so and two.so, each a C++ plugin of class
--  "loaded" (test/plugins/c_plugin.cpp), which the Makefile builds.


with

    Ada.Exceptions,
    Ada.IO_Exceptions,
    Checks,
    FLTK.Environment.Plugins;

use

    Checks;


procedure Test_Plugins is

    package Plg renames FLTK.Environment.Plugins;

    type Effect is new Plg.Plugin with record
        Strength : Integer := 0;
    end record;

    Libraries : constant String := "../../bin/unit/plugins";

    M : constant Plg.Plugin_Manager := Plg.Forge.Create ("effect");
    L : constant Plg.Plugin_Manager := Plg.Forge.Create ("loaded");
    A, B, C : aliased Effect;


    function Same
           (Got  : access Plg.Plugin'Class;
            Want : access Plg.Plugin'Class)
        return Boolean is
    begin
        return Plg."=" (Got, Want);
    end Same;


    procedure Open_Twice is
        Other : Effect;
    begin
        Other.Open ("effect", "sharpen");
    end Open_Twice;

    procedure Open_Open is
    begin
        B.Open ("effect", "other");
    end Open_Open;

    procedure Open_Slash is
        Other : Effect;
    begin
        Other.Open ("effect", "a/b");
    end Open_Slash;

    procedure Open_Empty is
        Other : Effect;
    begin
        Other.Open ("effect", "");
    end Open_Empty;

    procedure Class_Slash is
        Unused : constant Plg.Plugin_Manager := Plg.Forge.Create ("a/b");
    begin
        null;
    end Class_Slash;

    procedure At_Beyond is
        Unused : constant access Plg.Plugin'Class := M.Plugin_At (M.Number_Of_Plugins + 1);
    begin
        null;
    end At_Beyond;

    procedure Name_Beyond is
        Unused : constant String := M.Plugin_Name (M.Number_Of_Plugins + 1);
    begin
        null;
    end Name_Beyond;

    procedure Load_Missing_Directory is
    begin
        Plg.Load_All ("no-such-directory");
    end Load_Missing_Directory;

    Count : Natural;

begin

    Check (M.Get_Class = "effect", "a manager's class");
    Check (M.Number_Of_Plugins = 0, "a class starts with no plugins");
    Check (M.Plugin_Named ("blur") = null, "a name not there gives null");
    Check (not M.Has_Plugin ("blur"), "and isn't had");
    Check (not A.Is_Open and A.Get_Name = "", "a plugin starts closed");

    A.Strength := 1;
    A.Open ("effect", "blur");
    B.Strength := 2;
    B.Open ("effect", "sharpen");
    Check (A.Is_Open, "an opened plugin is open");
    Check (A.Get_Class = "effect" and A.Get_Name = "blur", "under its class and name");
    Check (M.Number_Of_Plugins = 2, "the manager counts what was opened after it");
    Check (M.Has_Plugin ("blur"), "and has it");
    Check (Same (M.Plugin_Named ("sharpen"), B'Access), "a name gives the object");
    Check (Effect (M.Plugin_Named ("sharpen").all).Strength = 2,
        "of the program's own type");
    Check (M.Plugin_Named ("sharpen").all in Effect'Class, "with its own tag");

    Check (M.Plugin_Name (1) = "blur", "a plugin's name is its own, not a path");
    Check (M.Plugin_Name (2) = "sharpen", "and they are in the order they were opened");
    Check (Same (M.Plugin_At (1), A'Access), "an index gives the object");
    C.Open ("effect", "alpha");
    Check (Same (M.Plugin_At (3), C'Access), "the newest is last, whatever its name");
    C.Close;

    Check (Same (Plg.Forge.Create ("effect").Plugin_Named ("blur"), A'Access),
        "a second manager sees the same plugins");
    Check (Plg.Forge.Create ("other").Number_Of_Plugins = 0, "another class doesn't");

    --  pofltk 108.
    Raises (Open_Twice'Access, Program_Error'Identity, "a name its class has already");
    Check (M.Number_Of_Plugins = 2, "and nothing was added");
    Raises (Open_Open'Access, Program_Error'Identity, "a plugin open already");
    Check (B.Get_Name = "sharpen" and M.Number_Of_Plugins = 2, "stays as it was");
    Raises (Open_Slash'Access, Constraint_Error'Identity, "a name with a /");
    Raises (Open_Empty'Access, Constraint_Error'Identity, "an empty name");
    Raises (Class_Slash'Access, Constraint_Error'Identity, "a class with a /");
    Check (not M.Has_Plugin ("a/b") and not M.Has_Plugin (""), "and neither is had");
    Raises (At_Beyond'Access, Constraint_Error'Identity, "Plugin_At beyond the last");
    Raises (Name_Beyond'Access, Constraint_Error'Identity, "Plugin_Name beyond the last");
    Check (M.Number_Of_Plugins = 2, "and no plugin was made by either");

    A.Close;
    Check (not A.Is_Open, "a closed plugin isn't open");
    Check (M.Number_Of_Plugins = 1, "and is gone from its class");
    Check (M.Plugin_Named ("blur") = null, "and from its name");
    Check (Same (M.Plugin_At (1), B'Access), "the other stays");
    A.Close;
    Check (M.Number_Of_Plugins = 1, "closing twice does nothing");
    A.Open ("effect", "blur");
    Check (Same (M.Plugin_Named ("blur"), A'Access), "a closed plugin can be opened again");

    declare
        D : Effect;
    begin
        D.Open ("effect", "scoped");
        Check (M.Number_Of_Plugins = 3, "a plugin in a block");
    end;
    Check (M.Number_Of_Plugins = 2 and not M.Has_Plugin ("scoped"),
        "is closed as it is finalized");
    A.Close;
    B.Close;

    --  Loading.
    Check (not Plg.Load (Libraries & "/missing.so"), "a missing library doesn't load");
    Check (not Plg.Load ("checks.ads"), "nor does a file that isn't one");
    Check (L.Number_Of_Plugins = 0, "and adds nothing");
    Plg.Load_All (".", "checks.*");
    Check (L.Number_Of_Plugins = 0, "Load_All passes over what isn't a library");
    Plg.Load_All (Libraries, "no*");
    Check (L.Number_Of_Plugins = 0, "and what doesn't match");
    Raises (Load_Missing_Directory'Access, Ada.IO_Exceptions.Name_Error'Identity,
        "Load_All of a directory that isn't there");
    Check (Plg.Load (Libraries & "/one.so"), "a library loads");
    Check (L.Number_Of_Plugins = 1, "and its C++ plugin joins the class");
    Check (L.Has_Plugin ("one"), "under its name");
    Check (L.Plugin_Named ("one") = null, "a C++ plugin has no object");
    Check (L.Plugin_At (1) = null, "by index either");
    Check (L.Plugin_Name (1) = "one", "but it has a name");
    Plg.Load_All (Libraries, "t*.so");
    Check (L.Has_Plugin ("two"), "Load_All loads what matches, given no final /");
    Plg.Load_All (Libraries & "/");
    Count := L.Number_Of_Plugins;
    Check (Count = 2, "and everything for no pattern, each once:" & Natural'Image (Count));

    Summary;

exception
when Occurrence : others =>
    Check (False, Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Plugins;
