

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups.Windows;


package FLTK.Devices.Surface.Paged.PDF is


    --  Draws pages into a PDF document, which Start_Document or Start_Job
    --  begins and End_Job ends.  A surface writes one document.  Each page
    --  is drawn between Start_Page and End_Page, as on a Printer.
    --
    --  Under X11 and Wayland this needs an FLTK built with Pango; see
    --  Is_Supported.  The document is written through the binding, so that
    --  a failed write raises File_Write_Error in End_Job, where FLTK would
    --  alert and wait for the user (pofltk 102).
    type PDF_File_Surface is new Paged_Device with private;

    type PDF_File_Surface_Reference (Data : not null access PDF_File_Surface'Class) is
        limited null record with Implicit_Dereference => Data;


    File_Open_Error   : exception;
    File_Write_Error  : exception;
    User_Cancel_Error : exception;


    --  The texts of the dialog in which Start_Job asks for the page format
    --  and orientation, under X11 and Wayland.
    type Dialog_Text is
       (Title_Text, Page_Size_Text, Orientation_Text, Default_Text);




    package Forge is

        --  Raises FLTK.Unsupported_Error unless Is_Supported.
        function Create
            return PDF_File_Surface;

    end Forge;




    --  Static Attributes  --

    --  False if this FLTK can't write PDF: one built without Pango under
    --  X11 and Wayland (FL/Fl_PDF_File_Surface.H), or with --disable-print.
    function Is_Supported
        return Boolean;

    --  In an FLTK built with --disable-print, which has no such dialog,
    --  each text is "", and Set_Dialog_Text raises FLTK.Unsupported_Error
    --  (pofltk 104), as Postscript.Set_File_Chooser_Title does.
    function Get_Dialog_Text
           (Which : in Dialog_Text)
        return String;

    procedure Set_Dialog_Text
           (Which : in Dialog_Text;
            Value : in String);




    --  Job Control  --

    --  Begins a document in file Name, of pages of size Format, Landscape
    --  or else Portrait.  Raises File_Open_Error, with the reason, if Name
    --  can't be written, Constraint_Error for the Media format (pofltk
    --  103), and Page_Error if the surface has begun a document before.
    procedure Start_Document
           (This   : in out PDF_File_Surface;
            Name   : in     String;
            Format : in     Page_Format := A4;
            Layout : in     Page_Layout := Portrait);

    --  Begins a document in a file the user chooses, offered Default_Name,
    --  after asking for the format and orientation.  Raises
    --  User_Cancel_Error if the user cancels, File_Open_Error, with the
    --  reason, if FLTK can't begin it, and Page_Error as Start_Document
    --  does.  FLTK writes the file itself, so a failed write is known only
    --  by FLTK's alert, which End_Job closes, and then raises
    --  File_Write_Error.
    procedure Start_Job
           (This         : in out PDF_File_Surface;
            Default_Name : in     String);

    --  A PDF surface has no print dialog: these raise Page_Error.
    overriding procedure Start_Job
           (This  : in out PDF_File_Surface;
            Count : in     Natural := 0);

    overriding procedure Start_Job
           (This     : in out PDF_File_Surface;
            Count    : in     Natural := 0;
            From, To :    out Positive);

    --  Ends the document.  Raises Page_Error in a page, and
    --  File_Write_Error, with the reason, if the PDF couldn't all be
    --  written or FLTK reported an error.  Does nothing with no document
    --  begun, or once ended.
    overriding procedure End_Job
           (This : in out PDF_File_Surface);

    --  Whether a document is begun and not ended.
    function Is_Open
           (This : in PDF_File_Surface)
        return Boolean;

    --  The document's file, "" before one is begun.
    function Get_File_Name
           (This : in PDF_File_Surface)
        return String;

    --  As for Paged_Device.  Start_Page raises Program_Error unless
    --  Is_Open.
    overriding procedure Start_Page
           (This : in out PDF_File_Surface);

    overriding procedure End_Page
           (This : in out PDF_File_Surface);




    --  Spacing and Orientation  --

    --  As for Paged_Device.  They raise Program_Error unless Is_Open:
    --  before a document FLTK has no page size, and no Cairo context to draw
    --  with.
    overriding procedure Get_Margins
           (This                     : in     PDF_File_Surface;
            Left, Top, Right, Bottom :    out Integer);

    overriding procedure Get_Printable_Rect
           (This : in     PDF_File_Surface;
            W, H :    out Integer);

    overriding procedure Get_Origin
           (This : in     PDF_File_Surface;
            X, Y :    out Integer);

    overriding procedure Set_Origin
           (This : in out PDF_File_Surface;
            X, Y : in     Integer);

    overriding procedure Rotate
           (This    : in out PDF_File_Surface;
            Degrees : in     Float);

    overriding procedure Scale
           (This   : in out PDF_File_Surface;
            Factor : in     Float);

    overriding procedure Scale
           (This               : in out PDF_File_Surface;
            Factor_X, Factor_Y : in     Float);

    overriding procedure Translate
           (This             : in out PDF_File_Surface;
            Delta_X, Delta_Y : in     Integer);

    overriding procedure Untranslate
           (This : in out PDF_File_Surface);




    --  Printing  --

    --  As for Paged_Device; they raise Program_Error unless Is_Open.
    overriding procedure Print_Widget
           (This               : in out PDF_File_Surface;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    overriding procedure Print_Window
           (This               : in out PDF_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    overriding procedure Print_Window_Part
           (This               : in out PDF_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0);




    --  Surfaces  --

    --  Raises Program_Error unless Is_Open.
    overriding procedure Set_Current
           (This : in out PDF_File_Surface);


private


    type PDF_File_Surface is new Paged_Device with record
        Open  : Boolean := False;  --  A document is begun and not ended
        Begun : Boolean := False;  --  A document has been begun
    end record;

    --  Ends the page and the document, if not ended, without raising.
    overriding procedure Finalize
           (This : in out PDF_File_Surface);

    overriding procedure Check_Drawable
           (This : in PDF_File_Surface);


    pragma Linker_Options ("-pthread");


    pragma Inline (Is_Open);


end FLTK.Devices.Surface.Paged.PDF;


