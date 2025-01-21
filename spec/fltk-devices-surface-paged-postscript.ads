

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Devices.Graphics;

private with

    Ada.Finalization,
    Interfaces.C.Strings;


package FLTK.Devices.Surface.Paged.Postscript is


    type Postscript_File_Device is new Paged_Device with private;

    type Postscript_File_Device_Reference (Data : not null access Postscript_File_Device'Class) is
        limited null record with Implicit_Dereference => Data;


    --  This will autoclose when it goes out of scope.
    type File_Type is tagged limited private;

    --  Calling this on a file already open will close it then open the new name.
    procedure Open
           (File : in out File_Type;
            Name : in     String);

    function Is_Open
           (File : in File_Type)
        return Boolean;

    --  Calling this on a file already closed will have no effect.
    procedure Close
           (File : in out File_Type);


    File_Open_Error   : exception;

    File_Close_Error  : exception;

    User_Cancel_Error : exception;




    --  The initial Graphics_Driver this is supposed to have upon construction
    --  is not currently implemented properly. Please wait warmly until the
    --  binding for the Graphics sub-hierarchy is done.




    package Forge is

        function Create
            return Postscript_File_Device;

    end Forge;




    function Get_File_Chooser_Title
        return String;

    procedure Set_File_Chooser_Title
           (Value : in String);




    --  Not currently implemented,
    --  will return a Postscript_Graphics_Driver when done.
    function Get_Postscript_Driver
           (This : in out Postscript_File_Device)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference;




    --  Docs say don't use this version.
    procedure Start_Job
           (This  : in out Postscript_File_Device;
            Count : in     Natural := 0);

    --  Docs say don't use this version.
    procedure Start_Job
           (This     : in out Postscript_File_Device;
            Count    : in     Natural := 0;
            From, To :    out Positive);

    procedure Start_Job
           (This   : in out Postscript_File_Device;
            Output : in     File_Type'Class;
            Count  : in     Natural := 0;
            Format : in     Page_Format := A4;
            Layout : in     Page_Layout := Portrait)
    with Pre => Output.Is_Open;

    procedure Start_Job
           (This   : in out Postscript_File_Device;
            Count  : in     Natural := 0;
            Format : in     Page_Format := A4;
            Layout : in     Page_Layout := Portrait);

    procedure End_Job
           (This : in out Postscript_File_Device);

    procedure Start_Page
           (This : in out Postscript_File_Device);

    procedure End_Page
           (This : in out Postscript_File_Device);




    procedure Get_Margins
           (This                     : in     Postscript_File_Device;
            Left, Top, Right, Bottom :    out Integer);

    procedure Get_Printable_Rect
           (This : in     Postscript_File_Device;
            W, H :    out Integer);

    procedure Get_Origin
           (This : in     Postscript_File_Device;
            X, Y :    out Integer);

    procedure Set_Origin
           (This : in out Postscript_File_Device;
            X, Y : in     Integer);

    procedure Rotate
           (This    : in out Postscript_File_Device;
            Degrees : in     Float);

    procedure Scale
           (This   : in out Postscript_File_Device;
            Factor : in     Float);

    procedure Scale
           (This               : in out Postscript_File_Device;
            Factor_X, Factor_Y : in     Float);

    procedure Translate
           (This             : in out Postscript_File_Device;
            Delta_X, Delta_Y : in     Integer);

    procedure Untranslate
           (This : in out Postscript_File_Device);


private


    type File_Type is new Ada.Finalization.Limited_Controlled with record
        C_File     : Storage.Integer_Address;
        Open_State : Boolean := False;
    end record;

    overriding procedure Finalize
           (This : in out File_Type);


    type Postscript_File_Device is new Paged_Device with null record;

    overriding procedure Finalize
           (This : in out Postscript_File_Device);


    File_Chooser_Title : Interfaces.C.Strings.chars_ptr;


    pragma Inline (Is_Open);

    pragma Inline (Get_File_Chooser_Title);

    pragma Inline (Get_Postscript_Driver);

    pragma Inline (Start_Job);
    pragma Inline (End_Job);
    pragma Inline (Start_Page);
    pragma Inline (End_Page);

    pragma Inline (Get_Margins);
    pragma Inline (Get_Printable_Rect);
    pragma Inline (Get_Origin);
    pragma Inline (Set_Origin);
    pragma Inline (Rotate);
    pragma Inline (Scale);
    pragma Inline (Translate);
    pragma Inline (Untranslate);


    --  Needed to ensure chars_ptr storage is properly cleaned up
    type Postscript_File_Device_Final_Controller is new Ada.Finalization.Limited_Controlled
        with null record;

    overriding procedure Finalize
           (This : in out Postscript_File_Device_Final_Controller);

    Cleanup : Postscript_File_Device_Final_Controller;


end FLTK.Devices.Surface.Paged.Postscript;


