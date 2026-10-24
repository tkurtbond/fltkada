

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


private with

    Ada.Finalization,
    Interfaces.C.Strings;


package FLTK.Native_File_Choosers is


    type Native_File_Chooser is new Wrapper with private;

    type Native_File_Chooser_Reference (Data : not null access Native_File_Chooser'Class) is
        limited null record with Implicit_Dereference => Data;

    type Chooser_Kind is
       (Browse_File,
        Browse_Directory,
        Browse_Multi_File,
        Browse_Multi_Directory,
        Browse_Save_File,
        Browse_Save_Directory);

    type Chooser_Option is private;

    function "+" (Left, Right : in Chooser_Option) return Chooser_Option;
    function "-" (Left, Right : in Chooser_Option) return Chooser_Option;

    function Includes
           (Options : in Chooser_Option;
            Item    : in Chooser_Option)
        return Boolean;

    No_Options     : constant Chooser_Option;
    Saveas_Confirm : constant Chooser_Option;
    New_Folder     : constant Chooser_Option;
    Preview        : constant Chooser_Option;
    Use_Filter_Ext : constant Chooser_Option;

    --  Result of Show: -1, 0 and 1 respectively in FLTK
    type Show_Result is (Error, Picked, Cancelled);




    package Forge is

        function Create
               (Kind : in Chooser_Kind := Browse_File)
            return Native_File_Chooser;

    end Forge;




    --  Static Messages  --

    function Get_File_Exists_Message
        return String;

    procedure Set_File_Exists_Message
           (Value : in String);




    --  Settings  --

    function Get_Kind
           (This : in Native_File_Chooser)
        return Chooser_Kind;

    procedure Set_Kind
           (This : in out Native_File_Chooser;
            Kind : in     Chooser_Kind);

    function Get_Options
           (This : in Native_File_Chooser)
        return Chooser_Option;

    procedure Set_Options
           (This    : in out Native_File_Chooser;
            Options : in     Chooser_Option);

    function Get_Title
           (This : in Native_File_Chooser)
        return String;

    procedure Set_Title
           (This : in out Native_File_Chooser;
            Text : in     String);




    --  Browsing  --

    function Get_Directory
           (This : in Native_File_Chooser)
        return String;

    procedure Set_Directory
           (This  : in out Native_File_Chooser;
            Value : in     String);

    function Get_Filter
           (This : in Native_File_Chooser)
        return String;

    procedure Set_Filter
           (This  : in out Native_File_Chooser;
            Value : in     String);

    function Filter_Count
           (This : in Native_File_Chooser)
        return Natural;

    function Get_Filter_Index
           (This : in Native_File_Chooser)
        return Positive;

    procedure Set_Filter_Index
           (This  : in out Native_File_Chooser;
            Value : in     Positive);

    function Get_Preset_File
           (This : in Native_File_Chooser)
        return String;

    procedure Set_Preset_File
           (This  : in out Native_File_Chooser;
            Value : in     String);




    --  Results  --

    function Number_Selected
           (This : in Native_File_Chooser)
        return Natural;

    function Get_Filename
           (This : in Native_File_Chooser)
        return String;

    function Get_Filename
           (This  : in Native_File_Chooser;
            Index : in Positive)
        return String
    with Pre => Index <= This.Number_Selected;

    function Get_Error_Message
           (This : in Native_File_Chooser)
        return String;




    --  Visibility  --

    function Show
           (This : in out Native_File_Chooser)
        return Show_Result;


private


    type Chooser_Option is new Interfaces.C.unsigned;

    No_Options     : constant Chooser_Option := 0;
    Saveas_Confirm : constant Chooser_Option := 1;
    New_Folder     : constant Chooser_Option := 2;
    Preview        : constant Chooser_Option := 4;
    Use_Filter_Ext : constant Chooser_Option := 8;


    type Native_File_Chooser is new Wrapper with record
        My_Title : Interfaces.C.Strings.chars_ptr;
    end record;

    overriding procedure Finalize
           (This : in out Native_File_Chooser);


    File_Exists_Message : Interfaces.C.Strings.chars_ptr;


    pragma Inline ("+");
    pragma Inline ("-");
    pragma Inline (Includes);

    pragma Inline (Get_Kind);
    pragma Inline (Set_Kind);
    pragma Inline (Get_Options);
    pragma Inline (Set_Options);

    pragma Inline (Filter_Count);
    pragma Inline (Get_Filter_Index);
    pragma Inline (Set_Filter_Index);

    pragma Inline (Number_Selected);


    --  Needed to ensure chars_ptr storage is properly cleaned up
    type Native_File_Chooser_Final_Controller is
        new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out Native_File_Chooser_Final_Controller);

    Cleanup : Native_File_Chooser_Final_Controller;


end FLTK.Native_File_Choosers;


