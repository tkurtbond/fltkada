

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces;

private with

    Interfaces.C;


package FLTK.Environment is


    type Database is new Wrapper with private;

    type Database_Reference (Data : not null access Database'Class) is
        limited null record with Implicit_Dereference => Data;

    type Pref_Group is new Wrapper with private;

    type Pref_Group_Reference (Data : not null access Pref_Group'Class) is
        limited null record with Implicit_Dereference => Data;

    type Scope is (Global, User);

    type Binary_Data is array (Positive range <>) of Interfaces.Unsigned_8;




    Preference_Error : exception;




    function New_UUID
        return String;




    package Forge is

        function From_Filesystem
               (Directory, Vendor, Application : in String)
            return Database;

        function From_Scope
               (Extent              : in Scope;
                Vendor, Application : in String)
            return Database;

        function Root
               (From : in Database)
            return Pref_Group'Class;

        function In_Memory
               (Name : in String)
            return Pref_Group;

        function By_Name
               (From : in Pref_Group;
                Name : in String)
            return Pref_Group'Class;

        function By_Index
               (From  : in Pref_Group;
                Index : in Positive)
            return Pref_Group'Class;

    end Forge;




    procedure Flush
           (This : in Database);

    function Userdata_Path
           (This : in Database)
        return String;




    procedure Delete_Entry
           (This : in out Pref_Group;
            Key  : in     String)
    with Post => This.Key_Exists (Key) = False;

    procedure Delete_All_Entries
           (This : in out Pref_Group)
    with Post => This.Number_Of_Entries = 0;

    procedure Delete_Group
           (This : in out Pref_Group;
            Name : in     String)
    with Post => This.Group_Exists (Name) = False;

    procedure Delete_All_Groups
           (This : in out Pref_Group)
    with Post => This.Number_Of_Groups = 0;

    procedure Clear
           (This : in out Pref_Group)
    with Post => This.Number_Of_Entries = 0 and
            This.Number_Of_Groups = 0;




    function Number_Of_Entries
           (This : in Pref_Group)
        return Natural;

    function Entry_Key
           (This  : in Pref_Group;
            Index : in Positive)
        return String
    with Pre => Index in 1 .. This.Number_Of_Entries;

    function Key_Exists
           (This : in Pref_Group;
            Key  : in String)
        return Boolean;

    function Value_Size
           (This : in Pref_Group;
            Key  : in String)
        return Natural;




    function Number_Of_Groups
           (This : in Pref_Group)
        return Natural;

    function Group_Name
           (This  : in Pref_Group;
            Index : in Positive)
        return String
    with Pre => Index in 1 .. This.Number_Of_Groups;

    function Group_Exists
           (This : in Pref_Group;
            Name : in String)
        return Boolean;




    function At_Name
           (This : in Pref_Group)
        return String;

    function At_Path
           (This : in Pref_Group)
        return String;




    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Integer;

    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Integer)
        return Integer;

    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Float;

    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Float)
        return Float;

    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Long_Float;

    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Long_Float)
        return Long_Float;

    function Get
           (This : in Pref_Group;
            Key  : in String)
        return String;

    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in String)
        return String;

    function Get
           (This       : in Pref_Group;
            Key        : in String;
            Default    : in String;
            Max_Length : in Natural)
        return String
    with Post => Get'Result'Length <= Max_Length;

    function Get
           (This : in Pref_Group;
            Key  : in String)
        return Binary_Data;

    function Get
           (This    : in Pref_Group;
            Key     : in String;
            Default : in Binary_Data)
        return Binary_Data;

    function Get
           (This       : in Pref_Group;
            Key        : in String;
            Default    : in Binary_Data;
            Max_Length : in Natural)
        return Binary_Data
    with Post => Get'Result'Length <= Max_Length;




    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Integer)
    with Post => This.Key_Exists (Key);

    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Float)
    with Post => This.Key_Exists (Key);

    procedure Set
           (This      : in out Pref_Group;
            Key       : in     String;
            Value     : in     Float;
            Precision : in     Natural)
    with Post => This.Key_Exists (Key);

    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Long_Float)
    with Post => This.Key_Exists (Key);

    procedure Set
           (This      : in out Pref_Group;
            Key       : in     String;
            Value     : in     Long_Float;
            Precision : in     Natural)
    with Post => This.Key_Exists (Key);

    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     String)
    with Post => This.Key_Exists (Key);

    procedure Set
           (This  : in out Pref_Group;
            Key   : in     String;
            Value : in     Binary_Data)
    with Post => This.Key_Exists (Key);


private


    type Database is new Wrapper with null record;

    overriding procedure Finalize
           (This : in out Database);


    type Pref_Group is new Wrapper with record
        Root_Ptr : Storage.Integer_Address;
    end record;

    overriding procedure Finalize
           (This : in out Pref_Group);


    pragma Convention (C, Binary_Data);
    pragma Pack (Binary_Data);
    for Binary_Data'Component_Size use Interfaces.C.CHAR_BIT;


    pragma Inline (New_UUID);

    pragma Inline (Flush);

    pragma Inline (Delete_Entry);
    pragma Inline (Delete_All_Entries);
    pragma Inline (Delete_Group);
    pragma Inline (Delete_All_Groups);
    pragma Inline (Clear);

    pragma Inline (Number_Of_Entries);
    pragma Inline (Entry_Key);
    pragma Inline (Key_Exists);
    pragma Inline (Value_Size);

    pragma Inline (Number_Of_Groups);
    pragma Inline (Group_Name);
    pragma Inline (Group_Exists);

    pragma Inline (At_Name);
    pragma Inline (At_Path);

    pragma Inline (Set);


    function To_Cint
           (Extent : in Scope)
        return Interfaces.C.int;

    function To_Scope
           (Num : in Interfaces.C.int)
        return Scope;


end FLTK.Environment;


