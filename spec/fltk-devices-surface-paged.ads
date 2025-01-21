

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups.Windows;

private with

    Ada.Strings.Unbounded;


package FLTK.Devices.Surface.Paged is


    pragma Elaborate_Body (FLTK.Devices.Surface.Paged);


    type Paged_Device is new Surface_Device with private;

    type Paged_Device_Reference (Data : not null access Paged_Device'Class) is
        limited null record with Implicit_Dereference => Data;


    type Page_Format is
       (A0, A1, A2, A3, A4, A5, A6, A7, A8, A9,
        B0, B1, B2, B3, B4, B5, B6, B7, B8, B9, B10,
        C5E, DLE, Executive, Folio, Ledger,
        Legal, Letter, Tabloid, Envelope, Media);


    --  Note that the Name in the format information may not quite
    --  correspond to the 'Image of the indexing Page_Format enumeration!
    type Page_Format_Info is tagged private;

    function Name
           (This : in Page_Format_Info)
        return String;

    function Width
           (This : in Page_Format_Info)
        return Natural;

    function Height
           (This : in Page_Format_Info)
        return Natural;

    type Page_Format_Info_Array is array (Page_Format range <>) of Page_Format_Info;


    type Page_Layout is
       (Portrait, Landscape, Reversed, Orientation);


    --  Information for everything except for Media
    Page_Formats : constant Page_Format_Info_Array (A0 .. Envelope);


    Page_Error : exception;




    package Forge is

        --  Docs say there should be no reason to use this but it's here anyway.
        function Create
            return Paged_Device;

    end Forge;




    procedure Start_Job
           (This  : in out Paged_Device;
            Count : in     Natural := 0);

    procedure Start_Job
           (This     : in out Paged_Device;
            Count    : in     Natural := 0;
            From, To :    out Positive);

    procedure End_Job
           (This : in out Paged_Device);

    procedure Start_Page
           (This : in out Paged_Device);

    procedure End_Page
           (This : in out Paged_Device);




    procedure Get_Margins
           (This                     : in     Paged_Device;
            Left, Top, Right, Bottom :    out Integer);

    procedure Get_Printable_Rect
           (This : in     Paged_Device;
            W, H :    out Integer);

    procedure Get_Origin
           (This : in     Paged_Device;
            X, Y :    out Integer);

    procedure Set_Origin
           (This : in out Paged_Device;
            X, Y : in     Integer);

    procedure Rotate
           (This    : in out Paged_Device;
            Degrees : in     Float);

    procedure Scale
           (This   : in out Paged_Device;
            Factor : in     Float);

    procedure Scale
           (This               : in out Paged_Device;
            Factor_X, Factor_Y : in     Float);

    procedure Translate
           (This             : in out Paged_Device;
            Delta_X, Delta_Y : in     Integer);

    procedure Untranslate
           (This : in out Paged_Device);




    procedure Print_Widget
           (This               : in out Paged_Device;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    procedure Print_Window
           (This               : in out Paged_Device;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    procedure Print_Window_Part
           (This               : in out Paged_Device;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0);


private


    type Paged_Device is new Surface_Device with null record;

    overriding procedure Finalize
           (This : in out Paged_Device);


    function To_Cint
           (Value : in Page_Format)
        return Interfaces.C.int;

    function To_Page_Format
           (Value : in Interfaces.C.int)
        return Page_Format;

    function To_Cint
           (Value : in Page_Layout)
        return Interfaces.C.int;

    function To_Page_Layout
           (Value : in Interfaces.C.int)
        return Page_Layout;


    type Page_Format_Info is tagged record
        My_Name   : Ada.Strings.Unbounded.Unbounded_String;
        My_Width  : Natural;
        My_Height : Natural;
    end record;

    function Get_Page_Formats
        return Page_Format_Info_Array;

    Page_Formats : constant Page_Format_Info_Array (A0 .. Envelope) := Get_Page_Formats;


    pragma Inline (Name);
    pragma Inline (Width);
    pragma Inline (Height);

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

    pragma Inline (Print_Widget);
    pragma Inline (Print_Window);
    pragma Inline (Print_Window_Part);


end FLTK.Devices.Surface.Paged;


