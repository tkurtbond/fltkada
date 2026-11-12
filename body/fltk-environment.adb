

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Directories,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Environment is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Constants From C  --
    ------------------------

    root_fl_prefs_system : constant Interfaces.C.int;
    pragma Import (C, root_fl_prefs_system, "root_fl_prefs_system");

    root_fl_prefs_user : constant Interfaces.C.int;
    pragma Import (C, root_fl_prefs_user, "root_fl_prefs_user");

    const_fl_path_max : constant Interfaces.C.int;
    pragma Import (C, const_fl_path_max, "const_fl_path_max");




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Static  --

    function fl_preferences_new_uuid
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_preferences_new_uuid, "fl_preferences_new_uuid");
    pragma Inline (fl_preferences_new_uuid);




    --  Allocation  --

    function new_fl_pref_database_path
           (P, V, A : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pref_database_path, "new_fl_pref_database_path");
    pragma Inline (new_fl_pref_database_path);

    function new_fl_pref_database_file
           (F : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pref_database_file, "new_fl_pref_database_file");
    pragma Inline (new_fl_pref_database_file);

    function new_fl_pref_database_scope
           (S    : in Interfaces.C.int;
            V, A : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pref_database_scope, "new_fl_pref_database_scope");
    pragma Inline (new_fl_pref_database_scope);

    procedure free_fl_pref_database
           (E : in Storage.Integer_Address);
    pragma Import (C, free_fl_pref_database, "free_fl_pref_database");
    pragma Inline (free_fl_pref_database);




    --  More Allocation  --

    function new_fl_pref_group_copy
           (D : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pref_group_copy, "new_fl_pref_group_copy");
    pragma Inline (new_fl_pref_group_copy);

    function new_fl_pref_group_memory
           (N : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pref_group_memory, "new_fl_pref_group_memory");
    pragma Inline (new_fl_pref_group_memory);

    function new_fl_pref_group_name
           (G : in Storage.Integer_Address;
            N : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pref_group_name, "new_fl_pref_group_name");
    pragma Inline (new_fl_pref_group_name);

    function new_fl_pref_group_index
           (G : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pref_group_index, "new_fl_pref_group_index");
    pragma Inline (new_fl_pref_group_index);

    procedure free_fl_pref_group
           (G : in Storage.Integer_Address);
    pragma Import (C, free_fl_pref_group, "free_fl_pref_group");
    pragma Inline (free_fl_pref_group);

    function fl_pref_group_exists
           (G : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_pref_group_exists, "fl_pref_group_exists");
    pragma Inline (fl_pref_group_exists);




    --  Disk Activity  --

    function fl_preferences_flush
           (E : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_flush, "fl_preferences_flush");
    pragma Inline (fl_preferences_flush);

    function fl_preferences_getuserdatapath
           (E : in     Storage.Integer_Address;
            P :    out Interfaces.C.char_array;
            L : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_getuserdatapath, "fl_preferences_getuserdatapath");
    pragma Inline (fl_preferences_getuserdatapath);

    procedure fl_preferences_filename
           (E : in     Storage.Integer_Address;
            P :    out Interfaces.C.char_array;
            L : in     Interfaces.C.int);
    pragma Import (C, fl_preferences_filename, "fl_preferences_filename");
    pragma Inline (fl_preferences_filename);

    procedure fl_preferences_static_filename
           (P    :    out Interfaces.C.char_array;
            L    : in     Interfaces.C.int;
            S    : in     Interfaces.C.int;
            V, A : in     Interfaces.C.char_array);
    pragma Import (C, fl_preferences_static_filename, "fl_preferences_static_filename");
    pragma Inline (fl_preferences_static_filename);




    --  Deletion  --

    function fl_preferences_deleteentry
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_deleteentry, "fl_preferences_deleteentry");
    pragma Inline (fl_preferences_deleteentry);

    function fl_preferences_deleteallentries
           (E : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_deleteallentries, "fl_preferences_deleteallentries");
    pragma Inline (fl_preferences_deleteallentries);

    function fl_preferences_deletegroup
           (P : in Storage.Integer_Address;
            G : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_deletegroup, "fl_preferences_deletegroup");
    pragma Inline (fl_preferences_deletegroup);

    function fl_preferences_deleteallgroups
           (P : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_deleteallgroups, "fl_preferences_deleteallgroups");
    pragma Inline (fl_preferences_deleteallgroups);

    function fl_preferences_clear
           (E : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_clear, "fl_preferences_clear");
    pragma Inline (fl_preferences_clear);




    --  Key Values  --

    function fl_preferences_entries
           (E : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_entries, "fl_preferences_entries");
    pragma Inline (fl_preferences_entries);

    function fl_preferences_entry
           (E : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_preferences_entry, "fl_preferences_entry");
    pragma Inline (fl_preferences_entry);

    function fl_preferences_entryexists
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_entryexists, "fl_preferences_entryexists");
    pragma Inline (fl_preferences_entryexists);

    function fl_preferences_size
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_size, "fl_preferences_size");
    pragma Inline (fl_preferences_size);




    --  Groups  --

    function fl_preferences_groups
           (P : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_groups, "fl_preferences_groups");
    pragma Inline (fl_preferences_groups);

    function fl_preferences_group
           (P : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_preferences_group, "fl_preferences_group");
    pragma Inline (fl_preferences_group);

    function fl_preferences_groupexists
           (P : in Storage.Integer_Address;
            G : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_groupexists, "fl_preferences_groupexists");
    pragma Inline (fl_preferences_groupexists);




    --  Names  --

    function fl_preferences_name
           (P : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_preferences_name, "fl_preferences_name");
    pragma Inline (fl_preferences_name);

    function fl_preferences_path
           (P : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_preferences_path, "fl_preferences_path");
    pragma Inline (fl_preferences_path);




    --  Retrieval  --

    function fl_preferences_get_int
           (E : in     Storage.Integer_Address;
            K : in     Interfaces.C.char_array;
            V :    out Interfaces.C.int;
            D : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_get_int, "fl_preferences_get_int");
    pragma Inline (fl_preferences_get_int);

    function fl_preferences_get_float
           (E : in     Storage.Integer_Address;
            K : in     Interfaces.C.char_array;
            V :    out Interfaces.C.C_float;
            D : in     Interfaces.C.C_float)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_get_float, "fl_preferences_get_float");
    pragma Inline (fl_preferences_get_float);

    function fl_preferences_get_double
           (E : in     Storage.Integer_Address;
            K : in     Interfaces.C.char_array;
            V :    out Interfaces.C.double;
            D : in     Interfaces.C.double)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_get_double, "fl_preferences_get_double");
    pragma Inline (fl_preferences_get_double);

    function fl_preferences_get_str
           (E : in     Storage.Integer_Address;
            K : in     Interfaces.C.char_array;
            V :    out Interfaces.C.Strings.chars_ptr;
            D : in     Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_get_str, "fl_preferences_get_str");
    pragma Inline (fl_preferences_get_str);

    function fl_preferences_get_str_limit
           (E : in     Storage.Integer_Address;
            K : in     Interfaces.C.char_array;
            V :    out Interfaces.C.char_array;
            D : in     Interfaces.C.char_array;
            M : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_get_str_limit, "fl_preferences_get_str_limit");
    pragma Inline (fl_preferences_get_str_limit);

    function fl_preferences_get_void
           (E  : in     Storage.Integer_Address;
            K  : in     Interfaces.C.char_array;
            V  :    out Storage.Integer_Address;
            D  : in     Storage.Integer_Address;
            DS : in     Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_get_void, "fl_preferences_get_void");
    pragma Inline (fl_preferences_get_void);

    function fl_preferences_get_void_limit
           (E      : in Storage.Integer_Address;
            K      : in Interfaces.C.char_array;
            V, D   : in Storage.Integer_Address;
            DS, MS : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_get_void_limit, "fl_preferences_get_void_limit");
    pragma Inline (fl_preferences_get_void_limit);

    procedure free_fl_preferences_void_data
           (V : in Storage.Integer_Address);
    pragma Import (C, free_fl_preferences_void_data, "free_fl_preferences_void_data");
    pragma Inline (free_fl_preferences_void_data);




    --  Storage  --

    function fl_preferences_set_int
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array;
            V : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_set_int, "fl_preferences_set_int");
    pragma Inline (fl_preferences_set_int);

    function fl_preferences_set_float
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array;
            V : in Interfaces.C.C_float)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_set_float, "fl_preferences_set_float");
    pragma Inline (fl_preferences_set_float);

    function fl_preferences_set_float_prec
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array;
            V : in Interfaces.C.C_float;
            P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_set_float_prec, "fl_preferences_set_float_prec");
    pragma Inline (fl_preferences_set_float_prec);

    function fl_preferences_set_double
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array;
            V : in Interfaces.C.double)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_set_double, "fl_preferences_set_double");
    pragma Inline (fl_preferences_set_double);

    function fl_preferences_set_double_prec
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array;
            V : in Interfaces.C.double;
            P : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_set_double_prec, "fl_preferences_set_double_prec");
    pragma Inline (fl_preferences_set_double_prec);

    function fl_preferences_set_str
           (E : in Storage.Integer_Address;
            K : in Interfaces.C.char_array;
            V : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_set_str, "fl_preferences_set_str");
    pragma Inline (fl_preferences_set_str);

    function fl_preferences_set_void
           (E  : in Storage.Integer_Address;
            K  : in Interfaces.C.char_array;
            D  : in Storage.Integer_Address;
            DS : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_preferences_set_void, "fl_preferences_set_void");
    pragma Inline (fl_preferences_set_void);




    ------------------------
    --  Internal Utility  --
    ------------------------

    function To_Cint
           (Extent : in Scope)
        return Interfaces.C.int is
    begin
        case Extent is
        when Global =>
            return root_fl_prefs_system;
        when User =>
            return root_fl_prefs_user;
        end case;
    end To_Cint;

    function To_Scope
           (Num : in Interfaces.C.int)
        return Scope is
    begin
        if Num = root_fl_prefs_system then
            return Global;
        else
            pragma Assert (Num = root_fl_prefs_user);
            return User;
        end if;
    exception
    when Chk.Assertion_Error => raise Constraint_Error;
    end To_Scope;

    --  The group's pointer, for a call.  The shim keeps a group as its base
    --  and its path, so a group deleted from above is one that is missing
    --  (pofltk 51).
    function Group_Ptr
           (This : in Pref_Group'Class)
        return Storage.Integer_Address is
    begin
        if fl_pref_group_exists (This.Void_Ptr) = 0 then
            raise Preference_Error with "the group was deleted";
        end if;
        return This.Void_Ptr;
    end Group_Ptr;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Database) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_pref_database (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;


    procedure Finalize
           (This : in out Pref_Group) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_pref_group (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is


        function From_Filesystem
               (Directory, Vendor, Application : in String)
            return Database is
        begin
            return This : Database do
                This.Void_Ptr := new_fl_pref_database_path
                   (Interfaces.C.To_C (Directory),
                    Interfaces.C.To_C (Vendor),
                    Interfaces.C.To_C (Application));
            end return;
        end From_Filesystem;


        function From_File
               (Name : in String)
            return Database is
        begin
            return This : Database do
                This.Void_Ptr := new_fl_pref_database_file (Interfaces.C.To_C (Name));
            end return;
        end From_File;


        function From_Scope
               (Extent              : in Scope;
                Vendor, Application : in String)
            return Database is
        begin
            return This : Database do
                This.Void_Ptr := new_fl_pref_database_scope
                   (To_Cint (Extent),
                    Interfaces.C.To_C (Vendor),
                    Interfaces.C.To_C (Application));
            end return;
        end From_Scope;


        function Root
               (From : in Database)
            return Pref_Group'Class is
        begin
            return Result : Pref_Group do
                Result.Void_Ptr := new_fl_pref_group_copy (From.Void_Ptr);
            end return;
        end Root;


        function In_Memory
               (Name : in String)
            return Pref_Group is
        begin
            return Result : Pref_Group do
                Result.Void_Ptr := new_fl_pref_group_memory (Interfaces.C.To_C (Name));
            end return;
        end In_Memory;


        function By_Name
               (From : in Pref_Group;
                Name : in String)
            return Pref_Group'Class is
        begin
            return Result : Pref_Group do
                Result.Void_Ptr := new_fl_pref_group_name
                   (Group_Ptr (From),
                    Interfaces.C.To_C (Name));
            end return;
        end By_Name;


        function By_Index
               (From  : in Pref_Group;
                Index : in Positive)
            return Pref_Group'Class is
        begin
            return Result : Pref_Group do
                Result.Void_Ptr := new_fl_pref_group_index
                   (Group_Ptr (From),
                    Interfaces.C.int (Index - 1));
            end return;
        end By_Index;


    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Static  --

    function New_UUID
        return String
    is
        Text : constant Interfaces.C.Strings.chars_ptr := fl_preferences_new_uuid;
    begin
        return Interfaces.C.Strings.Value (Text);
    end New_UUID;


    --  FLTK cuts a file's name to fit the buffer, so a name that fills it
    --  is tried again with a longer one.
    function Whole_Name
           (Fill : not null access procedure
                  (Buffer : out Interfaces.C.char_array;
                   Length : in  Interfaces.C.int))
        return String
    is
        Length : Natural := Natural (const_fl_path_max);
    begin
        loop
            declare
                Buffer : Interfaces.C.char_array (1 .. Interfaces.C.size_t (Length)) :=
                    (others => Interfaces.C.nul);
                Name   : String (1 .. Length);
                Last   : Natural;
            begin
                Fill (Buffer, Interfaces.C.int (Length));
                Interfaces.C.To_Ada (Buffer, Name, Last);
                if Last < Length - 1 then
                    return Name (1 .. Last);
                end if;
            end;
            Length := Length * 2;
        end loop;
    end Whole_Name;


    function File_Name
           (Extent              : in Scope;
            Vendor, Application : in String)
        return String
    is
        procedure Fill
               (Buffer : out Interfaces.C.char_array;
                Length : in  Interfaces.C.int) is
        begin
            fl_preferences_static_filename
               (Buffer, Length, To_Cint (Extent),
                Interfaces.C.To_C (Vendor), Interfaces.C.To_C (Application));
        end Fill;
    begin
        return Whole_Name (Fill'Access);
    end File_Name;




    --  Disk Activity  --

    procedure Flush
           (This : in Database) is
    begin
        --  -1 is a file that couldn't be written, 0 one written, and
        --  1 nothing changed to write.
        if fl_preferences_flush (This.Void_Ptr) = -1 then
            raise Preference_Error;
        end if;
    end Flush;


    function File_Name
           (This : in Database)
        return String
    is
        procedure Fill
               (Buffer : out Interfaces.C.char_array;
                Length : in  Interfaces.C.int) is
        begin
            fl_preferences_filename (This.Void_Ptr, Buffer, Length);
        end Fill;
    begin
        return Whole_Name (Fill'Access);
    end File_Name;


    function Userdata_Path
           (This : in Database)
        return String
    is
        Buffer : Interfaces.C.char_array :=
            (1 .. Interfaces.C.size_t (const_fl_path_max + 1) => ' ');
    begin
        if fl_preferences_getuserdatapath
           (This.Void_Ptr,
            Buffer,
            const_fl_path_max) = 0
        then
            raise Preference_Error;
        end if;
        declare
            Path : constant String := Interfaces.C.To_Ada (Buffer);
            use type Ada.Directories.File_Kind;
        begin
            --  FLTK says it made the directory whether it could or not
            --  (fl_make_path ignores fl_mkdir, fl_utf8.cxx:618; pofltk 157).
            if not Ada.Directories.Exists (Path)
                or else Ada.Directories.Kind (Path) /= Ada.Directories.Directory
            then
                raise Preference_Error with "Userdata_Path:  FLTK couldn't make " & Path;
            end if;
            return Path;
        end;
    end Userdata_Path;




    --  Deletion  --

    procedure Delete_Entry
           (This : in out Pref_Group;
            Key  : in     String) is
    begin
        if fl_preferences_deleteentry (Group_Ptr (This), Interfaces.C.To_C (Key)) = 0 then
            raise Preference_Error;
        end if;
    end Delete_Entry;


    procedure Delete_All_Entries
           (This : in out Pref_Group) is
    begin
        if fl_preferences_deleteallentries (Group_Ptr (This)) = 0 then
            raise Preference_Error;
        end if;
    end Delete_All_Entries;


    procedure Delete_Group
           (This : in out Pref_Group;
            Name : in     String) is
    begin
        if fl_preferences_deletegroup (Group_Ptr (This), Interfaces.C.To_C (Name)) = 0 then
            raise Preference_Error;
        end if;
    end Delete_Group;


    procedure Delete_All_Groups
           (This : in out Pref_Group) is
    begin
        if fl_preferences_deleteallgroups (Group_Ptr (This)) = 0 then
            raise Preference_Error;
        end if;
    end Delete_All_Groups;


    procedure Clear
           (This : in out Pref_Group) is
    begin
        if fl_preferences_clear (Group_Ptr (This)) = 0 then
            raise Preference_Error;
        end if;
    end Clear;




    --  Key Values  --

    function Number_Of_Entries
           (This : in Pref_Group)
        return Natural is
    begin
        return Natural (fl_preferences_entries (Group_Ptr (This)));
    end Number_Of_Entries;


    function Entry_Key
           (This  : in Pref_Group;
            Index : in Positive)
        return String
    is
        Key : constant Interfaces.C.Strings.chars_ptr :=
            fl_preferences_entry (Group_Ptr (This), Interfaces.C.int (Index) - 1);
    begin
        --  no need for dealloc?
        if Key = Interfaces.C.Strings.Null_Ptr then
            raise Preference_Error;
        else
            return Interfaces.C.Strings.Value (Key);
        end if;
    end Entry_Key;


    function Key_Exists
           (This : in Pref_Group;
            Key  : in String)
        return Boolean is
    begin
        return fl_preferences_entryexists (Group_Ptr (This), Interfaces.C.To_C (Key)) /= 0;
    end Key_Exists;


    function Value_Size
           (This : in Pref_Group;
            Key  : in String)
        return Natural is
    begin
        return Natural (fl_preferences_size (Group_Ptr (This), Interfaces.C.To_C (Key)));
    end Value_Size;




    --  Groups  --

    function Number_Of_Groups
           (This : in Pref_Group)
        return Natural is
    begin
        return Natural (fl_preferences_groups (Group_Ptr (This)));
    end Number_Of_Groups;


    function Group_Name
           (This  : in Pref_Group;
            Index : in Positive)
        return String
    is
        Name : constant Interfaces.C.Strings.chars_ptr :=
            fl_preferences_group (Group_Ptr (This), Interfaces.C.int (Index) - 1);
    begin
        --  no need for dealloc?
        if Name = Interfaces.C.Strings.Null_Ptr then
            raise Preference_Error;
        else
            return Interfaces.C.Strings.Value (Name);
        end if;
    end Group_Name;


    function Group_Exists
           (This : in Pref_Group;
            Name : in String)
        return Boolean is
    begin
        return fl_preferences_groupexists (Group_Ptr (This), Interfaces.C.To_C (Name)) /= 0;
    end Group_Exists;




    --  Names  --

    function At_Name
           (This : in Pref_Group)
        return String
    is
        Text : constant Interfaces.C.Strings.chars_ptr := fl_preferences_name (Group_Ptr (This));
    begin
        if Text = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Text);
        end if;
    end At_Name;


    function At_Path
           (This : in Pref_Group)
        return String
    is
        Text : constant Interfaces.C.Strings.chars_ptr := fl_preferences_path (Group_Ptr (This));
    begin
        if Text = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Text);
        end if;
    end At_Path;




    --  Retrieval  --

    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Integer
    is
        Value : Interfaces.C.int;
    begin
        if fl_preferences_get_int
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Value, 0) = 0
        then
            raise Preference_Error;
        end if;
        return Integer (Value);
    end Get;


    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Integer)
        return Integer
    is
        Value, Ignore : Interfaces.C.int;
    begin
        Ignore := fl_preferences_get_int
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Value,
            Interfaces.C.int (Default));
        return Integer (Value);
    end Get;


    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Float
    is
        Value : Interfaces.C.C_float;
    begin
        if fl_preferences_get_float
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Value, 0.0) = 0
        then
            raise Preference_Error;
        end if;
        return Float (Value);
    end Get;


    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Float)
        return Float
    is
        Value : Interfaces.C.C_float;
        Ignore : Interfaces.C.int;
    begin
        Ignore := fl_preferences_get_float
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Value,
            Interfaces.C.C_float (Default));
        return Float (Value);
    end Get;


    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Long_Float
    is
        Value : Interfaces.C.double;
    begin
        if fl_preferences_get_double
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Value, 0.0) = 0
        then
            raise Preference_Error;
        end if;
        return Long_Float (Value);
    end Get;


    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Long_Float)
        return Long_Float
    is
        Value : Interfaces.C.double;
        Ignore : Interfaces.C.int;
    begin
        Ignore := fl_preferences_get_double
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Value,
            Interfaces.C.double (Default));
        return Long_Float (Value);
    end Get;


    function Get
           (This : in Pref_Group;
            Key  : in String)
        return String
    is
        Text : Interfaces.C.Strings.chars_ptr;
        Check : constant Interfaces.C.int := fl_preferences_get_str
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Text,
            Interfaces.C.To_C ("default"));
    begin
        if Check = 0 then
            raise Preference_Error;
        end if;
        if Text = Interfaces.C.Strings.Null_Ptr then
            return "";
        end if;
        return Str : constant String := Interfaces.C.Strings.Value (Text) do
            Interfaces.C.Strings.Free (Text);
        end return;
    end Get;


    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in String)
        return String
    is
        Text : Interfaces.C.Strings.chars_ptr;
        Ignore : Interfaces.C.int := fl_preferences_get_str
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Text,
            Interfaces.C.To_C (Default));
    begin
        if Text = Interfaces.C.Strings.Null_Ptr then
            return Default;
        end if;
        return Str : constant String := Interfaces.C.Strings.Value (Text) do
            Interfaces.C.Strings.Free (Text);
        end return;
    end Get;


    function Get
           (This       : in Pref_Group;
            Key        : in String;
            Default    : in String;
            Max_Length : in Natural)
        return String
    is
        Text : Interfaces.C.char_array := (1 .. Interfaces.C.size_t (Max_Length + 1) => ' ');
        Check : constant Interfaces.C.int := fl_preferences_get_str_limit
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Text,
            Interfaces.C.To_C (Default),
            Interfaces.C.int (Max_Length + 1));
    begin
        if Check = 0 then
            return Default
               (Default'First .. Default'First - 1 + Natural'Min (Default'Length, Max_Length));
        else
            return Interfaces.C.To_Ada (Text);
        end if;
    end Get;


    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Binary_Data
    is
        Thing : Storage.Integer_Address;
        Dummy : Interfaces.C.int := 42;
        Check : constant Interfaces.C.int := fl_preferences_get_void
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Thing,
            Storage.To_Integer (Dummy'Address),
            1);
    begin
        if Check = 0 then
            free_fl_preferences_void_data (Thing);
            raise Preference_Error;
        end if;
        declare
            --  FLTK keeps the data as hexadecimal text (Fl_Preferences.cxx,
            --  decodeHex), two characters a byte.
            Length : constant Natural := This.Value_Size (Key) / 2;
            Actual : Binary_Data (1 .. Length);
            for Actual'Address use Storage.To_Address (Thing);
            pragma Import (Ada, Actual);
        begin
            return Result : constant Binary_Data := Actual do
                free_fl_preferences_void_data (Thing);
            end return;
        end;
    end Get;


    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Binary_Data)
        return Binary_Data
    is
        Thing : Storage.Integer_Address;
        Found : constant Interfaces.C.int := fl_preferences_get_void
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Thing,
            Storage.To_Integer (Default'Address),
            Default'Length);
    begin
        if Found = 0 then
            free_fl_preferences_void_data (Thing);
            return Default;
        end if;
        declare
            Length : constant Natural := This.Value_Size (Key) / 2;
            Actual : Binary_Data (1 .. Length);
            for Actual'Address use Storage.To_Address (Thing);
            pragma Import (Ada, Actual);
        begin
            return Result : constant Binary_Data := Actual do
                free_fl_preferences_void_data (Thing);
            end return;
        end;
    end Get;


    function Get
           (This       : in Pref_Group;
            Key        : in String;
            Default    : in Binary_Data;
            Max_Length : in Natural)
        return Binary_Data
    is
        Actual : Binary_Data (1 .. Max_Length);
        Found  : constant Interfaces.C.int := fl_preferences_get_void_limit
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Storage.To_Integer (Actual'Address),
            Storage.To_Integer (Default'Address),
            Default'Length,
            Interfaces.C.int (Max_Length));
        Length : constant Natural :=
            (if Found = 0 then Default'Length else This.Value_Size (Key) / 2);
    begin
        return Actual (1 .. Natural'Min (Length, Max_Length));
    end Get;




    --  Storage  --

    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Integer) is
    begin
        if fl_preferences_set_int
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Interfaces.C.int (Value)) = 0
        then
            raise Preference_Error;
        end if;
    end Set;


    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Float) is
    begin
        if fl_preferences_set_float
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Interfaces.C.C_float (Value)) = 0
        then
            raise Preference_Error;
        end if;
    end Set;


    procedure Set
           (This      : in out Pref_Group;
            Key       : in     String;
            Value     : in     Float;
            Precision : in     Natural) is
    begin
        if fl_preferences_set_float_prec
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Interfaces.C.C_float (Value),
            Interfaces.C.int (Precision)) = 0
        then
            raise Preference_Error;
        end if;
    end Set;


    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Long_Float) is
    begin
        if fl_preferences_set_double
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Interfaces.C.double (Value)) = 0
        then
            raise Preference_Error;
        end if;
    end Set;


    procedure Set
           (This      : in out Pref_Group;
            Key       : in     String;
            Value     : in     Long_Float;
            Precision : in     Natural) is
    begin
        if fl_preferences_set_double_prec
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Interfaces.C.double (Value),
            Interfaces.C.int (Precision)) = 0
        then
            raise Preference_Error;
        end if;
    end Set;


    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     String) is
    begin
        if fl_preferences_set_str
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Interfaces.C.To_C (Value)) = 0
        then
            raise Preference_Error;
        end if;
    end Set;


    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Binary_Data) is
    begin
        if fl_preferences_set_void
           (Group_Ptr (This),
            Interfaces.C.To_C (Key),
            Storage.To_Integer (Value'Address),
            Value'Length) = 0
        then
            raise Preference_Error;
        end if;
    end Set;


end FLTK.Environment;


