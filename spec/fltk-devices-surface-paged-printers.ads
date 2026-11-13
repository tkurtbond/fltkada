

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups.Windows;

private with

    Ada.Finalization,
    Interfaces.C.Strings;


package FLTK.Devices.Surface.Paged.Printers is


    type Printer is new Paged_Device with private;

    --  Raised by Start_Job when the user cancels the print dialog.
    User_Cancel_Error : exception;

    type Printer_Reference (Data : not null access Printer'Class) is limited null record
        with Implicit_Dereference => Data;




    --  The initial Graphics_Driver this is supposed to have upon construction
    --  is not currently implemented properly. Please wait warmly until the
    --  binding for the Graphics sub-hierarchy is done.




    package Forge is

        function Create
            return Printer;

    end Forge;




    --  Static Attributes  --

    --  FLTK's own print panel takes these texts as its labels when the
    --  first dialog builds it, and keeps it (print_panel.cxx:249,
    --  Fl_Posix_Printer_Driver.cxx:282):  a text set after that is never
    --  shown, though FLTKAda keeps the old one valid (FLTKAda-BUGS.md 36,
    --  pofltk 144).  GTK's dialog reads Dialog_Title each time.

    function Get_Dialog_Title
        return String;

    procedure Set_Dialog_Title
           (Value : in String);

    function Get_Dialog_Printer
        return String;

    procedure Set_Dialog_Printer
           (Value : in String);

    function Get_Dialog_Range
        return String;

    procedure Set_Dialog_Range
           (Value : in String);

    function Get_Dialog_Copies
        return String;

    procedure Set_Dialog_Copies
           (Value : in String);

    function Get_Dialog_All
        return String;

    procedure Set_Dialog_All
           (Value : in String);

    function Get_Dialog_Pages
        return String;

    procedure Set_Dialog_Pages
           (Value : in String);

    function Get_Dialog_From
        return String;

    procedure Set_Dialog_From
           (Value : in String);

    function Get_Dialog_To
        return String;

    procedure Set_Dialog_To
           (Value : in String);

    function Get_Dialog_Properties
        return String;

    procedure Set_Dialog_Properties
           (Value : in String);

    function Get_Dialog_Number_Copies
        return String;

    procedure Set_Dialog_Number_Copies
           (Value : in String);

    function Get_Dialog_Print_Button
        return String;

    procedure Set_Dialog_Print_Button
           (Value : in String);

    function Get_Dialog_Cancel_Button
        return String;

    procedure Set_Dialog_Cancel_Button
           (Value : in String);

    function Get_Dialog_Print_To_File
        return String;

    procedure Set_Dialog_Print_To_File
           (Value : in String);

    function Get_Property_Title
        return String;

    procedure Set_Property_Title
           (Value : in String);

    function Get_Property_Page_Size
        return String;

    procedure Set_Property_Page_Size
           (Value : in String);

    function Get_Property_Mode
        return String;

    procedure Set_Property_Mode
           (Value : in String);

    function Get_Property_Use
        return String;

    procedure Set_Property_Use
           (Value : in String);

    function Get_Property_Save
        return String;

    procedure Set_Property_Save
           (Value : in String);

    function Get_Property_Cancel
        return String;

    procedure Set_Property_Cancel
           (Value : in String);




    --  Driver  --

    --  Not currently implemented
    function Get_Original_Driver
           (This : in out Printer)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference;




    --  Job Control  --

    procedure Start_Job
           (This  : in out Printer;
            Count : in     Natural := 0);

    procedure Start_Job
           (This     : in out Printer;
            Count    : in     Natural := 0;
            From, To :    out Positive);
    --  Both show the print dialog.  They raise User_Cancel_Error if the user
    --  cancels it, and Page_Error, with FLTK's message if it gives one, if
    --  the job can't start, such as when the print command can't be run
    --  (FLTKAda-BUGS.md 85).  From and To are the pages to print, set only
    --  if the job starts (FLTKAda-BUGS.md 140).

    --  End_Job in a page ends the page first; if that raises Page_Error, the
    --  job is not ended (FLTKAda-BUGS.md 123).
    procedure End_Job
           (This : in out Printer);

    procedure Start_Page
           (This : in out Printer);

    procedure End_Page
           (This : in out Printer);




    --  Spacing and Orientation  --

    procedure Get_Margins
           (This                     : in     Printer;
            Left, Top, Right, Bottom :    out Integer);

    procedure Get_Printable_Rect
           (This : in     Printer;
            W, H :    out Integer);

    procedure Get_Origin
           (This : in     Printer;
            X, Y :    out Integer);

    procedure Set_Origin
           (This : in out Printer;
            X, Y : in     Integer);

    --  Rotate, Scale and Untranslate raise Constraint_Error as
    --  Paged_Device's do (pofltk 101).  Set_Origin, Rotate, Scale and
    --  Translate raise Page_Error outside a page, as Paged_Device's do
    --  (pofltk 103).
    procedure Rotate
           (This    : in out Printer;
            Degrees : in     Float);

    procedure Scale
           (This   : in out Printer;
            Factor : in     Float);

    procedure Scale
           (This               : in out Printer;
            Factor_X, Factor_Y : in     Float);

    procedure Translate
           (This             : in out Printer;
            Delta_X, Delta_Y : in     Integer);

    procedure Untranslate
           (This : in out Printer);




    --  Printing  --

    procedure Print_Widget
           (This               : in out Printer;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    procedure Print_Window_Part
           (This               : in out Printer;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0);




    --  Printer  --

    procedure Set_Current
           (This : in out Printer);


private


    type Printer is new Paged_Device with null record;

    overriding procedure Finalize
           (This : in out Printer);


    Dialog_Title,         Dialog_Printer,
    Dialog_Range,         Dialog_Copies,
    Dialog_All,           Dialog_Pages,
    Dialog_From,          Dialog_To,
    Dialog_Properties,    Dialog_Copyno,
    Dialog_Print_Button,  Dialog_Cancel_Button,
    Dialog_Print_To_File,
    Property_Title,       Property_Pagesize,
    Property_Mode,        Property_Use,
    Property_Save,        Property_Cancel      : Interfaces.C.Strings.chars_ptr;


    pragma Inline (Get_Dialog_Title);
    pragma Inline (Get_Dialog_Printer);
    pragma Inline (Get_Dialog_Range);
    pragma Inline (Get_Dialog_Copies);
    pragma Inline (Get_Dialog_All);
    pragma Inline (Get_Dialog_Pages);
    pragma Inline (Get_Dialog_From);
    pragma Inline (Get_Dialog_To);
    pragma Inline (Get_Dialog_Properties);
    pragma Inline (Get_Dialog_Number_Copies);
    pragma Inline (Get_Dialog_Print_Button);
    pragma Inline (Get_Dialog_Cancel_Button);
    pragma Inline (Get_Dialog_Print_To_File);
    pragma Inline (Get_Property_Title);
    pragma Inline (Get_Property_Page_Size);
    pragma Inline (Get_Property_Mode);
    pragma Inline (Get_Property_Use);
    pragma Inline (Get_Property_Save);
    pragma Inline (Get_Property_Cancel);

    pragma Inline (Get_Original_Driver);

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
    pragma Inline (Print_Window_Part);

    pragma Inline (Set_Current);


    --  Needed to ensure chars_ptr storage is properly cleaned up
    type Printer_Final_Controller is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out Printer_Final_Controller);

    Cleanup : Printer_Final_Controller;


end FLTK.Devices.Surface.Paged.Printers;


