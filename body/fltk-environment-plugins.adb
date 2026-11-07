

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Ada.Strings.Fixed,
    FLTK.Filenames,
    Interfaces.C.Strings,
    System.Address_To_Access_Conversions;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Environment.Plugins is


    package SU renames Ada.Strings.Unbounded;

    package Plugin_Convert is new System.Address_To_Access_Conversions (Plugin'Class);




    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_plugin
           (K, N : in Interfaces.C.char_array;
            A    : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_plugin, "new_fl_plugin");
    pragma Inline (new_fl_plugin);

    procedure free_fl_plugin
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_plugin, "free_fl_plugin");
    pragma Inline (free_fl_plugin);

    function fl_plugin_manager_plugins
           (K : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_plugin_manager_plugins, "fl_plugin_manager_plugins");
    pragma Inline (fl_plugin_manager_plugins);

    function fl_plugin_manager_has
           (K, N : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_plugin_manager_has, "fl_plugin_manager_has");
    pragma Inline (fl_plugin_manager_has);

    function fl_plugin_manager_object_at
           (K : in Interfaces.C.char_array;
            I : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_plugin_manager_object_at, "fl_plugin_manager_object_at");
    pragma Inline (fl_plugin_manager_object_at);

    function fl_plugin_manager_object_named
           (K, N : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, fl_plugin_manager_object_named, "fl_plugin_manager_object_named");
    pragma Inline (fl_plugin_manager_object_named);

    function fl_plugin_manager_name
           (K : in Interfaces.C.char_array;
            I : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_plugin_manager_name, "fl_plugin_manager_name");
    pragma Inline (fl_plugin_manager_name);

    function fl_plugin_manager_load
           (F : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_plugin_manager_load, "fl_plugin_manager_load");
    pragma Inline (fl_plugin_manager_load);




    -------------------
    --  Subprograms  --
    -------------------

    --  A class or a plugin's name is one group of FLTK's plugin database.
    procedure Check_Name
           (Name, What : in String) is
    begin
        if Name = "" then
            raise Constraint_Error with What & " is empty";
        elsif Ada.Strings.Fixed.Index (Name, "/") /= 0 then
            raise Constraint_Error with What & " has a ""/"": " & Name;
        end if;
    end Check_Name;


    function To_Object
           (Address : in Storage.Integer_Address)
        return access Plugin'Class is
    begin
        if Address = Null_Pointer then
            return null;
        else
            return Plugin_Convert.To_Pointer (Storage.To_Address (Address));
        end if;
    end To_Object;


    procedure Check_Index
           (This  : in Plugin_Manager;
            Index : in Positive) is
    begin
        if Index > This.Number_Of_Plugins then
            raise Constraint_Error with "plugin" & Positive'Image (Index)
                & " of" & Natural'Image (This.Number_Of_Plugins)
                & " in class " & This.Get_Class;
        end if;
    end Check_Index;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Class : in String)
            return Plugin_Manager is
        begin
            Check_Name (Class, "a plugin class");
            return (Class => SU.To_Unbounded_String (Class));
        end Create;

    end Forge;




    --------------------
    --  Destructors  --
    --------------------

    overriding procedure Finalize
           (This : in out Plugin) is
    begin
        Close (This);
    end Finalize;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Plugins  --

    procedure Open
           (This        : in out Plugin;
            Class, Name : in     String) is
    begin
        Check_Name (Class, "a plugin class");
        Check_Name (Name, "a plugin's name");
        if This.Is_Open then
            raise Program_Error with "plugin " & Name & " is open already, as "
                & This.Get_Name & " of class " & This.Get_Class;
        end if;
        if fl_plugin_manager_has (Interfaces.C.To_C (Class), Interfaces.C.To_C (Name)) /= 0 then
            raise Program_Error with "class " & Class & " has a plugin " & Name & " already";
        end if;
        This.Void_Ptr := new_fl_plugin
           (Interfaces.C.To_C (Class),
            Interfaces.C.To_C (Name),
            Storage.To_Integer (Plugin_Convert.To_Address (This'Unchecked_Access)));
        if This.Void_Ptr = Null_Pointer then
            raise Storage_Error with "out of memory opening plugin " & Name;
        end if;
        This.Class := SU.To_Unbounded_String (Class);
        This.Name := SU.To_Unbounded_String (Name);
    end Open;


    procedure Close
           (This : in out Plugin) is
    begin
        if This.Void_Ptr /= Null_Pointer then
            free_fl_plugin (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Close;


    function Is_Open
           (This : in Plugin)
        return Boolean is
    begin
        return This.Void_Ptr /= Null_Pointer;
    end Is_Open;


    function Get_Class
           (This : in Plugin)
        return String is
    begin
        return SU.To_String (This.Class);
    end Get_Class;


    function Get_Name
           (This : in Plugin)
        return String is
    begin
        return SU.To_String (This.Name);
    end Get_Name;




    --  Plugin Managers  --

    function Get_Class
           (This : in Plugin_Manager)
        return String is
    begin
        return SU.To_String (This.Class);
    end Get_Class;


    function Number_Of_Plugins
           (This : in Plugin_Manager)
        return Natural is
    begin
        return Natural (fl_plugin_manager_plugins (Interfaces.C.To_C (This.Get_Class)));
    end Number_Of_Plugins;


    function Plugin_At
           (This  : in Plugin_Manager;
            Index : in Positive)
        return access Plugin'Class is
    begin
        Check_Index (This, Index);
        return To_Object (fl_plugin_manager_object_at
           (Interfaces.C.To_C (This.Get_Class), Interfaces.C.int (Index - 1)));
    end Plugin_At;


    function Plugin_Named
           (This : in Plugin_Manager;
            Name : in String)
        return access Plugin'Class is
    begin
        if not This.Has_Plugin (Name) then
            return null;
        end if;
        return To_Object (fl_plugin_manager_object_named
           (Interfaces.C.To_C (This.Get_Class), Interfaces.C.To_C (Name)));
    end Plugin_Named;


    function Has_Plugin
           (This : in Plugin_Manager;
            Name : in String)
        return Boolean is
    begin
        if Name = "" or else Ada.Strings.Fixed.Index (Name, "/") /= 0 then
            return False;
        end if;
        return fl_plugin_manager_has
           (Interfaces.C.To_C (This.Get_Class), Interfaces.C.To_C (Name)) /= 0;
    end Has_Plugin;


    function Plugin_Name
           (This  : in Plugin_Manager;
            Index : in Positive)
        return String
    is
        Name : Interfaces.C.Strings.chars_ptr;
    begin
        Check_Index (This, Index);
        Name := fl_plugin_manager_name
           (Interfaces.C.To_C (This.Get_Class), Interfaces.C.int (Index - 1));
        if Name = Interfaces.C.Strings.Null_Ptr then
            raise Internal_FLTK_Error with "no name for plugin" & Positive'Image (Index);
        end if;
        return Interfaces.C.Strings.Value (Name);
    end Plugin_Name;




    --  Loading  --

    function Load
           (File : in String)
        return Boolean is
    begin
        return fl_plugin_manager_load (Interfaces.C.To_C (File)) /= 0;
    end Load;


    procedure Load_All
           (Directory : in String;
            Pattern   : in String := "")
    is
        Path : constant String :=
            (if Directory = "" or else Directory (Directory'Last) = '/'
             then Directory else Directory & "/");
        List : constant FLTK.Filenames.File_List := FLTK.Filenames.Get_Listing (Path);
        Unused : Boolean;
    begin
        for I in 1 .. List.Length loop
            declare
                Name : constant String := List.Item (I);
            begin
                if Pattern = "" or else FLTK.Filenames.Match (Name, Pattern) then
                    Unused := Load (Path & Name);
                end if;
            end;
        end loop;
    end Load_All;


end FLTK.Environment.Plugins;


