

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Devices.Surface.Paged.PDF is


    ------------------------
    --  Functions From C  --
    ------------------------

    function fl_pdf_file_surface_supported
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_supported, "fl_pdf_file_surface_supported");
    pragma Inline (fl_pdf_file_surface_supported);

    function fl_pdf_file_surface_get_text
           (I : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_pdf_file_surface_get_text, "fl_pdf_file_surface_get_text");
    pragma Inline (fl_pdf_file_surface_get_text);

    function fl_pdf_file_surface_set_text
           (I : in Interfaces.C.int;
            V : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_set_text, "fl_pdf_file_surface_set_text");
    pragma Inline (fl_pdf_file_surface_set_text);




    --  Allocation  --

    function new_fl_pdf_file_surface
        return Storage.Integer_Address;
    pragma Import (C, new_fl_pdf_file_surface, "new_fl_pdf_file_surface");
    pragma Inline (new_fl_pdf_file_surface);

    procedure free_fl_pdf_file_surface
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_pdf_file_surface, "free_fl_pdf_file_surface");
    pragma Inline (free_fl_pdf_file_surface);




    --  Job Control  --

    function fl_pdf_file_surface_begin_document
           (S    : in Storage.Integer_Address;
            N    : in Interfaces.C.char_array;
            F, L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_begin_document, "fl_pdf_file_surface_begin_document");
    pragma Inline (fl_pdf_file_surface_begin_document);

    function fl_pdf_file_surface_begin_job
           (S : in Storage.Integer_Address;
            N : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_begin_job, "fl_pdf_file_surface_begin_job");
    pragma Inline (fl_pdf_file_surface_begin_job);

    function fl_pdf_file_surface_end_job
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_end_job, "fl_pdf_file_surface_end_job");
    pragma Inline (fl_pdf_file_surface_end_job);

    function fl_pdf_file_surface_message
           (S : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_pdf_file_surface_message, "fl_pdf_file_surface_message");
    pragma Inline (fl_pdf_file_surface_message);

    function fl_pdf_file_surface_file_name
           (S : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_pdf_file_surface_file_name, "fl_pdf_file_surface_file_name");
    pragma Inline (fl_pdf_file_surface_file_name);

    function fl_pdf_file_surface_begin_page
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_begin_page, "fl_pdf_file_surface_begin_page");
    pragma Inline (fl_pdf_file_surface_begin_page);

    function fl_pdf_file_surface_end_page
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_end_page, "fl_pdf_file_surface_end_page");
    pragma Inline (fl_pdf_file_surface_end_page);




    --  Spacing and Orientation  --

    procedure fl_pdf_file_surface_margins
           (S          : in     Storage.Integer_Address;
            L, T, R, B :    out Interfaces.C.int);
    pragma Import (C, fl_pdf_file_surface_margins, "fl_pdf_file_surface_margins");
    pragma Inline (fl_pdf_file_surface_margins);

    function fl_pdf_file_surface_printable_rect
           (S    : in     Storage.Integer_Address;
            W, H :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_pdf_file_surface_printable_rect, "fl_pdf_file_surface_printable_rect");
    pragma Inline (fl_pdf_file_surface_printable_rect);

    procedure fl_pdf_file_surface_get_origin
           (S    : in     Storage.Integer_Address;
            X, Y :    out Interfaces.C.int);
    pragma Import (C, fl_pdf_file_surface_get_origin, "fl_pdf_file_surface_get_origin");
    pragma Inline (fl_pdf_file_surface_get_origin);

    procedure fl_pdf_file_surface_set_origin
           (S    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_pdf_file_surface_set_origin, "fl_pdf_file_surface_set_origin");
    pragma Inline (fl_pdf_file_surface_set_origin);

    procedure fl_pdf_file_surface_rotate
           (S : in Storage.Integer_Address;
            R : in Interfaces.C.C_float);
    pragma Import (C, fl_pdf_file_surface_rotate, "fl_pdf_file_surface_rotate");
    pragma Inline (fl_pdf_file_surface_rotate);

    procedure fl_pdf_file_surface_scale
           (S    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.C_float);
    pragma Import (C, fl_pdf_file_surface_scale, "fl_pdf_file_surface_scale");
    pragma Inline (fl_pdf_file_surface_scale);

    procedure fl_pdf_file_surface_translate
           (S    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_pdf_file_surface_translate, "fl_pdf_file_surface_translate");
    pragma Inline (fl_pdf_file_surface_translate);

    procedure fl_pdf_file_surface_untranslate
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_pdf_file_surface_untranslate, "fl_pdf_file_surface_untranslate");
    pragma Inline (fl_pdf_file_surface_untranslate);




    --  Surfaces  --

    procedure fl_pdf_file_surface_set_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_pdf_file_surface_set_current, "fl_pdf_file_surface_set_current");
    pragma Inline (fl_pdf_file_surface_set_current);




    -------------------
    --  Destructors  --
    -------------------

    --  The shim's destructor ends the document, if End_Job hasn't, with no
    --  alert left waiting for the user.
    procedure Finalize
           (This : in out PDF_File_Surface)
    is
        Ignore : Interfaces.C.int;
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if This.In_Page then
                This.In_Page := False;
                Ignore := fl_pdf_file_surface_end_page (This.Void_Ptr);
                Pop_Bookkeep;
            end if;
            This.Open := False;
            if Release_Current (This) then
                free_fl_pdf_file_surface (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return PDF_File_Surface is
        begin
            if not Is_Supported then
                raise Unsupported_Error with "this FLTK can't write PDF";
            end if;
            return This : PDF_File_Surface do
                This.Void_Ptr := new_fl_pdf_file_surface;
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "no memory for a PDF surface";
                end if;
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Message
           (This : in PDF_File_Surface)
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_pdf_file_surface_message (This.Void_Ptr));
    end Message;


    procedure Check_Drawable
           (This : in PDF_File_Surface) is
    begin
        if not This.Open then
            raise Program_Error with "the PDF surface has no document open";
        end if;
    end Check_Drawable;


    procedure Check_Unbegun
           (This : in PDF_File_Surface) is
    begin
        if This.Begun then
            raise Page_Error with "the PDF surface has begun a document before";
        end if;
    end Check_Unbegun;




    --  Static Attributes  --

    function Is_Supported
        return Boolean is
    begin
        return fl_pdf_file_surface_supported /= 0;
    end Is_Supported;


    function Get_Dialog_Text
           (Which : in Dialog_Text)
        return String is
    begin
        return Interfaces.C.Strings.Value
            (fl_pdf_file_surface_get_text (Dialog_Text'Pos (Which)));
    end Get_Dialog_Text;


    procedure Set_Dialog_Text
           (Which : in Dialog_Text;
            Value : in String) is
    begin
        if fl_pdf_file_surface_set_text (Dialog_Text'Pos (Which), Interfaces.C.To_C (Value)) = 0
        then
            raise Unsupported_Error with "this FLTK has no PDF format dialog";
        end if;
    end Set_Dialog_Text;




    --  Job Control  --

    procedure Start_Document
           (This   : in out PDF_File_Surface;
            Name   : in     String;
            Format : in     Page_Format := A4;
            Layout : in     Page_Layout := Portrait) is
    begin
        Check_Unbegun (This);
        Check_Format (Format);
        if fl_pdf_file_surface_begin_document
            (This.Void_Ptr,
             Interfaces.C.To_C (Name),
             To_Cint (Format),
             To_Cint (Layout)) /= 0
        then
            raise File_Open_Error with Message (This);
        end if;
        This.Begun := True;
        This.Open := True;
    end Start_Document;


    procedure Start_Job
           (This         : in out PDF_File_Surface;
            Default_Name : in     String) is
    begin
        Check_Unbegun (This);
        case fl_pdf_file_surface_begin_job (This.Void_Ptr, Interfaces.C.To_C (Default_Name)) is
        when 0 =>
            This.Begun := True;
            This.Open := True;
        when 1 =>
            raise User_Cancel_Error;
        when others =>
            raise File_Open_Error with Message (This);
        end case;
    end Start_Job;


    procedure Start_Job
           (This  : in out PDF_File_Surface;
            Count : in     Natural := 0)
    is
        pragma Unreferenced (This, Count);
    begin
        raise Page_Error with "a PDF surface has no print dialog";
    end Start_Job;


    procedure Start_Job
           (This     : in out PDF_File_Surface;
            Count    : in     Natural := 0;
            From, To :    out Positive)
    is
        pragma Unreferenced (This, Count, From, To);
    begin
        raise Page_Error with "a PDF surface has no print dialog";
    end Start_Job;


    procedure End_Job
           (This : in out PDF_File_Surface) is
    begin
        if not This.Open then
            return;
        end if;
        if This.In_Page then
            raise Page_Error with "End_Job in a page";
        end if;
        This.Open := False;
        if fl_pdf_file_surface_end_job (This.Void_Ptr) /= 0 then
            raise File_Write_Error with Message (This);
        end if;
    end End_Job;


    function Is_Open
           (This : in PDF_File_Surface)
        return Boolean is
    begin
        return This.Open;
    end Is_Open;


    function Get_File_Name
           (This : in PDF_File_Surface)
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_pdf_file_surface_file_name (This.Void_Ptr));
    end Get_File_Name;


    procedure Start_Page
           (This : in out PDF_File_Surface) is
    begin
        This.Check_Drawable;
        if This.In_Page then
            raise Page_Error with "a page is already started";
        end if;
        This.Shifts := 0;
        if fl_pdf_file_surface_begin_page (This.Void_Ptr) /= 0 then
            raise Page_Error;
        end if;
        --  FLTK's begin_page pushed the device (FLTKAda-BUGS.md 75).
        Push_Bookkeep (This);
        This.In_Page := True;
    end Start_Page;


    procedure End_Page
           (This : in out PDF_File_Surface) is
    begin
        if not This.In_Page then
            raise Page_Error with "no page is started";
        end if;
        This.In_Page := False;
        This.Shifts := 0;
        declare
            Result : constant Interfaces.C.int := fl_pdf_file_surface_end_page (This.Void_Ptr);
        begin
            Pop_Bookkeep;
            if Result /= 0 then
                raise Page_Error;
            end if;
        end;
    end End_Page;




    --  Spacing and Orientation  --

    procedure Get_Margins
           (This                     : in     PDF_File_Surface;
            Left, Top, Right, Bottom :    out Integer)
    is
        L, T, R, B : Interfaces.C.int;
    begin
        This.Check_Drawable;
        fl_pdf_file_surface_margins (This.Void_Ptr, L, T, R, B);
        Left := Integer (L);
        Top := Integer (T);
        Right := Integer (R);
        Bottom := Integer (B);
    end Get_Margins;


    procedure Get_Printable_Rect
           (This : in     PDF_File_Surface;
            W, H :    out Integer)
    is
        C_W, C_H : Interfaces.C.int;
    begin
        This.Check_Drawable;
        if fl_pdf_file_surface_printable_rect (This.Void_Ptr, C_W, C_H) /= 0 then
            raise Page_Error;
        end if;
        W := Integer (C_W);
        H := Integer (C_H);
    end Get_Printable_Rect;


    procedure Get_Origin
           (This : in     PDF_File_Surface;
            X, Y :    out Integer)
    is
        C_X, C_Y : Interfaces.C.int;
    begin
        This.Check_Drawable;
        fl_pdf_file_surface_get_origin (This.Void_Ptr, C_X, C_Y);
        X := Integer (C_X);
        Y := Integer (C_Y);
    end Get_Origin;


    procedure Set_Origin
           (This : in out PDF_File_Surface;
            X, Y : in     Integer) is
    begin
        This.Check_Drawable;
        Check_In_Page (This, "Set_Origin");
        fl_pdf_file_surface_set_origin
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Set_Origin;


    procedure Rotate
           (This    : in out PDF_File_Surface;
            Degrees : in     Float) is
    begin
        This.Check_Drawable;
        Check_Rotation (Degrees);
        Check_In_Page (This, "Rotate");
        fl_pdf_file_surface_rotate (This.Void_Ptr, Interfaces.C.C_float (Degrees));
    end Rotate;


    procedure Scale
           (This   : in out PDF_File_Surface;
            Factor : in     Float) is
    begin
        This.Check_Drawable;
        Check_Scale (Factor, 0.0);
        Check_In_Page (This, "Scale");
        fl_pdf_file_surface_scale (This.Void_Ptr, Interfaces.C.C_float (Factor), 0.0);
    end Scale;


    procedure Scale
           (This               : in out PDF_File_Surface;
            Factor_X, Factor_Y : in     Float) is
    begin
        This.Check_Drawable;
        Check_Scale (Factor_X, Factor_Y);
        Check_In_Page (This, "Scale");
        fl_pdf_file_surface_scale
           (This.Void_Ptr,
            Interfaces.C.C_float (Factor_X),
            Interfaces.C.C_float (Factor_Y));
    end Scale;


    procedure Translate
           (This             : in out PDF_File_Surface;
            Delta_X, Delta_Y : in     Integer) is
    begin
        This.Check_Drawable;
        Check_In_Page (This, "Translate");
        This.Shifts := This.Shifts + 1;
        fl_pdf_file_surface_translate
           (This.Void_Ptr,
            Interfaces.C.int (Delta_X),
            Interfaces.C.int (Delta_Y));
    end Translate;


    procedure Untranslate
           (This : in out PDF_File_Surface) is
    begin
        This.Check_Drawable;
        Check_Untranslate (This);
        This.Shifts := This.Shifts - 1;
        fl_pdf_file_surface_untranslate (This.Void_Ptr);
    end Untranslate;




    --  Printing  --

    procedure Print_Widget
           (This               : in out PDF_File_Surface;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        This.Check_Drawable;
        Paged_Device (This).Print_Widget (Item, Offset_X, Offset_Y);
    end Print_Widget;


    procedure Print_Window
           (This               : in out PDF_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        This.Check_Drawable;
        Paged_Device (This).Print_Window (Item, Offset_X, Offset_Y);
    end Print_Window;


    procedure Print_Window_Part
           (This               : in out PDF_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        This.Check_Drawable;
        Paged_Device (This).Print_Window_Part (Item, X, Y, W, H, Offset_X, Offset_Y);
    end Print_Window_Part;




    --  Surfaces  --

    procedure Set_Current
           (This : in out PDF_File_Surface) is
    begin
        This.Check_Drawable;
        fl_pdf_file_surface_set_current (This.Void_Ptr);
        This.Set_Current_Bookkeep;
    end Set_Current;


end FLTK.Devices.Surface.Paged.PDF;


