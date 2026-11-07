

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_Plugin and Fl_Plugin_Manager: objects found by the class they were
--  opened under, so a program can use what it knows only by its class.
--
--  A plugin is an object of a type of the program's own, derived from
--  Plugin, opened under a class and a name.  A Plugin_Manager of the class
--  finds it again, by number or by name, and gives back the object itself.
--  FLTK keeps the plugins of every class in a database in memory.
--
--  A shared library loaded with Load or Load_All can make plugins as it
--  is loaded, such as a C++ library with a static object of a class
--  derived from Fl_Plugin.  A plugin made in C++ has a name and is
--  counted, but has no Ada object, so Plugin_At and Plugin_Named give null
--  for it.  The library's plugins join the program's database only if the
--  two share one FLTK.  When the program links FLTK statically, it must be
--  linked with -rdynamic (in a .gpr file, "-rdynamic" in package Linker's
--  Default_Switches), so that the library uses the program's FLTK.


private with

    Ada.Strings.Unbounded;


package FLTK.Environment.Plugins is


    type Plugin is new Wrapper with private;

    type Plugin_Manager is tagged private;




    package Forge is

        --  The plugins of Class.  Raises Constraint_Error for a Class that
        --  is empty or has a "/" in it.
        function Create
               (Class : in String)
            return Plugin_Manager;

    end Forge;




    --  Plugins  --

    --  Puts This in Class under Name, where every Plugin_Manager of Class
    --  finds it, until it is closed or finalized.  Raises Constraint_Error
    --  for a Class or Name that is empty or has a "/" in it, which would
    --  make nested groups in FLTK's database.  Raises Program_Error if This
    --  is open already, or Class already has a plugin named Name: FLTK
    --  would keep both in one node, and remove it twice (pofltk 108).
    procedure Open
           (This        : in out Plugin;
            Class, Name : in     String);

    --  Takes This out of its class.  Does nothing if it isn't open.
    procedure Close
           (This : in out Plugin);

    function Is_Open
           (This : in Plugin)
        return Boolean;

    --  What This was last opened under; "" if it never was.
    function Get_Class
           (This : in Plugin)
        return String;

    function Get_Name
           (This : in Plugin)
        return String;




    --  Plugin Managers  --

    function Get_Class
           (This : in Plugin_Manager)
        return String;

    --  The plugins of the class, opened by Ada or made in C++, in the
    --  order they were opened.
    function Number_Of_Plugins
           (This : in Plugin_Manager)
        return Natural;

    --  Raises Constraint_Error for an Index above Number_Of_Plugins, for
    --  which FLTK would make a new, empty plugin (pofltk 108).  Null for a
    --  plugin made in C++.
    function Plugin_At
           (This  : in Plugin_Manager;
            Index : in Positive)
        return access Plugin'Class;

    --  Null if the class has no plugin of that name, or it was made in C++.
    function Plugin_Named
           (This : in Plugin_Manager;
            Name : in String)
        return access Plugin'Class;

    function Has_Plugin
           (This : in Plugin_Manager;
            Name : in String)
        return Boolean;

    --  Raises Constraint_Error for an Index above Number_Of_Plugins.
    function Plugin_Name
           (This  : in Plugin_Manager;
            Index : in Positive)
        return String;




    --  Loading  --

    --  Loads the shared library File, whose plugins open themselves as it
    --  loads.  False if it isn't one, or can't be loaded.  FLTK never
    --  unloads a library.
    function Load
           (File : in String)
        return Boolean;

    --  Loads each file in Directory whose name matches Pattern (as
    --  FLTK.Filenames.Match matches), or every file for an empty Pattern,
    --  in the order of FLTK.Filenames.Numeric_Sort.  Files that aren't
    --  shared libraries are passed over.  Unlike Fl_Plugin_Manager::loadAll,
    --  Directory needn't end in "/", and the sort reads only the names
    --  (pofltk 63).  Raises Ada.IO_Exceptions.Name_Error if Directory
    --  can't be listed.
    procedure Load_All
           (Directory : in String;
            Pattern   : in String := "");


private


    type Plugin is new Wrapper with record
        Class, Name : Ada.Strings.Unbounded.Unbounded_String;
    end record;

    overriding procedure Finalize
           (This : in out Plugin);


    type Plugin_Manager is tagged record
        Class : Ada.Strings.Unbounded.Unbounded_String;
    end record;


end FLTK.Environment.Plugins;


