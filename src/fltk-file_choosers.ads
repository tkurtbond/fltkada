

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Filenames,
    FLTK.Widgets.Buttons.Light.Check;

private with

    Ada.Finalization,
    Interfaces.C.Strings;


package FLTK.File_Choosers is


    type File_Chooser is new Wrapper with private;

    type File_Chooser_Reference (Data : not null access File_Chooser'Class) is
        limited null record with Implicit_Dereference => Data;

    type Chooser_Kind is (Single, Multi, Create, Directory);

    type Chooser_Callback is access procedure
           (Item : in out File_Chooser'Class);

    type Icon_Size is mod 256;




    package Forge is

        function Create
               (Title    : in String;
                Pattern  : in String;
                Pathname : in String;
                Kind     : in Chooser_Kind := Single)
            return File_Chooser;

    end Forge;




    Sort_Method : not null FLTK.Filenames.Compare_Function :=
        FLTK.Filenames.Numeric_Sort'Access;




    function New_Button
           (This : in out File_Chooser)
        return FLTK.Widgets.Buttons.Button_Reference;

    function Preview_Button
           (This : in out File_Chooser)
        return FLTK.Widgets.Buttons.Light.Check.Check_Button_Reference;

    function Show_Hidden_Button
           (This : in out File_Chooser)
        return FLTK.Widgets.Buttons.Light.Check.Check_Button_Reference;




    function Get_Add_Favorites_Label
        return String;

    procedure Set_Add_Favorites_Label
           (Value : in String);

    function Get_All_Files_Label
        return String;

    procedure Set_All_Files_Label
           (Value : in String);

    function Get_Custom_Filter_Label
        return String;

    procedure Set_Custom_Filter_Label
           (Value : in String);

    function Get_Existing_File_Label
        return String;

    procedure Set_Existing_File_Label
           (Value : in String);

    function Get_Favorites_Label
        return String;

    procedure Set_Favorites_Label
           (Value : in String);

    function Get_Filename_Label
        return String;

    procedure Set_Filename_Label
           (Value : in String);

    function Get_Filesystems_Label
        return String;

    procedure Set_Filesystems_Label
           (Value : in String);

    function Get_Hidden_Label
        return String;

    procedure Set_Hidden_Label
           (Value : in String);

    function Get_Manage_Favorites_Label
        return String;

    procedure Set_Manage_Favorites_Label
           (Value : in String);

    function Get_New_Directory_Label
        return String;

    procedure Set_New_Directory_Label
           (Value : in String);

    function Get_New_Directory_Tooltip
        return String;

    procedure Set_New_Directory_Tooltip
           (Value : in String);

    function Get_Preview_Label
        return String;

    procedure Set_Preview_Label
           (Value : in String);

    function Get_Save_Label
        return String;

    procedure Set_Save_Label
           (Value : in String);

    function Get_Show_Label
        return String;

    procedure Set_Show_Label
           (Value : in String);




    procedure Add_Extra
           (This : in out File_Chooser;
            Item : in out Widgets.Widget'Class);

    procedure Remove_Extra
           (This : in out File_Chooser);

    function Eject_Extra
           (This : in out File_Chooser;
            Item : in out Widgets.Widget'Class)
        return access Widgets.Widget'Class;

    procedure Set_Callback
           (This : in out File_Chooser;
            Func : in     Chooser_Callback);




    function Get_Background_Color
           (This : in File_Chooser)
        return Color;

    procedure Set_Background_Color
           (This  : in out File_Chooser;
            Value : in     Color);

    function Get_Icon_Size
           (This : in File_Chooser)
        return Icon_Size;

    procedure Set_Icon_Size
           (This  : in out File_Chooser;
            Value : in     Icon_Size);

    function Get_Label
           (This : in File_Chooser)
        return String;

    procedure Set_Label
           (This : in out File_Chooser;
            Text : in     String);

    function Get_OK_Label
           (This : in File_Chooser)
        return String;

    procedure Set_OK_Label
           (This : in out File_Chooser;
            Text : in     String);

    function Has_Preview
           (This : in File_Chooser)
        return Boolean;

    procedure Set_Preview
           (This  : in out File_Chooser;
            Value : in     Boolean);

    function Get_Text_Color
           (This : in File_Chooser)
        return Color;

    procedure Set_Text_Color
           (This  : in out File_Chooser;
            Value : in     Color);

    function Get_Text_Font
           (This : in File_Chooser)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out File_Chooser;
            Font : in     Font_Kind);

    function Get_Text_Size
           (This : in File_Chooser)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out File_Chooser;
            Size : in     Font_Size);

    function Get_Chooser_Kind
           (This : in File_Chooser)
        return Chooser_Kind;

    procedure Set_Chooser_Kind
           (This : in out File_Chooser;
            Kind : in     Chooser_Kind);




    function Number_Selected
           (This : in File_Chooser)
        return Natural;

    function Get_Directory
           (This : in File_Chooser)
        return String;

    procedure Set_Directory
           (This  : in out File_Chooser;
            Value : in     String);

    function Get_Filter
           (This : in File_Chooser)
        return String;

    procedure Set_Filter
           (This  : in out File_Chooser;
            Value : in     String);

    function Get_Filter_Index
           (This : in File_Chooser)
        return Positive;

    procedure Set_Filter_Index
           (This  : in out File_Chooser;
            Value : in     Positive);

    procedure Rescan
           (This : in out File_Chooser);

    procedure Rescan_Keep_Filename
           (This : in out File_Chooser);

    function Get_Selected
           (This  : in File_Chooser;
            Index : in Positive := 1)
        return String
    with Pre => Index <= This.Number_Selected;

    procedure Set_Selected
           (This  : in out File_Chooser;
            Value : in     String);




    procedure Show
           (This : in out File_Chooser);

    procedure Hide
           (This : in out File_Chooser);

    function Is_Shown
           (This : in File_Chooser)
        return Boolean;

    function Is_Visible
           (This : in File_Chooser)
        return Boolean;


private


    type File_Chooser is new Wrapper with record
        New_Butt     : aliased Widgets.Buttons.Button;
        Preview_Butt : aliased Widgets.Buttons.Light.Check.Check_Button;
        Hidden_Butt  : aliased Widgets.Buttons.Light.Check.Check_Button;
        My_Callback  : Chooser_Callback;
        My_Label     : Interfaces.C.Strings.chars_ptr;
        My_OK_Label  : Interfaces.C.Strings.chars_ptr;
    end record;

    overriding procedure Finalize
           (This : in out File_Chooser);

    procedure Extra_Init
           (This : in out File_Chooser);

    procedure Extra_Final
           (This : in out File_Chooser);


    Add_Favorites_Label,    All_Files_Label,
    Custom_Filter_Label,    Existing_File_Label,
    Favorites_Label,        Filename_Label,
    Filesystems_Label,      Hidden_Label,
    Manage_Favorites_Label, New_Directory_Label,
    New_Directory_Tooltip,  Preview_Label,
    Save_Label,             Show_Label          : Interfaces.C.Strings.chars_ptr;


    pragma Inline (New_Button);
    pragma Inline (Preview_Button);
    pragma Inline (Show_Hidden_Button);

    pragma Inline (Get_Add_Favorites_Label);
    pragma Inline (Get_All_Files_Label);
    pragma Inline (Get_Custom_Filter_Label);
    pragma Inline (Get_Existing_File_Label);
    pragma Inline (Get_Favorites_Label);
    pragma Inline (Get_Filename_Label);
    pragma Inline (Get_Filesystems_Label);
    pragma Inline (Get_Hidden_Label);
    pragma Inline (Get_Manage_Favorites_Label);
    pragma Inline (Get_New_Directory_Label);
    pragma Inline (Get_New_Directory_Tooltip);
    pragma Inline (Get_Preview_Label);
    pragma Inline (Get_Save_Label);
    pragma Inline (Get_Show_Label);

    pragma Inline (Add_Extra);
    pragma Inline (Remove_Extra);
    pragma Inline (Eject_Extra);
    pragma Inline (Set_Callback);

    pragma Inline (Get_Background_Color);
    pragma Inline (Set_Background_Color);
    pragma Inline (Get_Icon_Size);
    pragma Inline (Set_Icon_Size);
    pragma Inline (Get_Label);
    pragma Inline (Get_OK_Label);
    pragma Inline (Set_Preview);
    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);
    pragma Inline (Set_Chooser_Kind);

    pragma Inline (Number_Selected);
    pragma Inline (Get_Filter_Index);
    pragma Inline (Set_Filter_Index);
    pragma Inline (Rescan);
    pragma Inline (Rescan_Keep_Filename);
    pragma Inline (Set_Selected);

    pragma Inline (Show);
    pragma Inline (Hide);
    pragma Inline (Is_Shown);
    pragma Inline (Is_Visible);


    --  Needed to ensure chars_ptr storage is properly cleaned up
    type File_Chooser_Final_Controller is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out File_Chooser_Final_Controller);

    Cleanup : File_Chooser_Final_Controller;


end FLTK.File_Choosers;


