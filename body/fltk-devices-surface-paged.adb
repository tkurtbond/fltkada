

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Devices.Surface.Paged is


    package Chk renames Ada.Assertions;
    package SU  renames Ada.Strings.Unbounded;




    ------------------------
    --  Constants From C  --
    ------------------------

    fl_page_format_media : constant Interfaces.C.int;
    pragma Import (C, fl_page_format_media);

    fl_page_layout_portrait : constant Interfaces.C.int;
    pragma Import (C, fl_page_layout_portrait);

    fl_page_layout_landscape : constant Interfaces.C.int;
    pragma Import (C, fl_page_layout_landscape);

    fl_page_layout_reversed : constant Interfaces.C.int;
    pragma Import (C, fl_page_layout_reversed);

    fl_page_layout_orientation : constant Interfaces.C.int;
    pragma Import (C, fl_page_layout_orientation);

    fl_no_page_formats : constant Interfaces.C.int;
    pragma Import (C, fl_no_page_formats);




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Static Attributes  --

    procedure fl_paged_device_get_page_format
           (Index  : in     Interfaces.C.int;
            Name   :    out Interfaces.C.Strings.chars_ptr;
            Width  :    out Interfaces.C.int;
            Height :    out Interfaces.C.int);
    pragma Import (C, fl_paged_device_get_page_format, "fl_paged_device_get_page_format");
    pragma Inline (fl_paged_device_get_page_format);




    --  Allocation  --

    function new_fl_paged_device
        return Storage.Integer_Address;
    pragma Import (C, new_fl_paged_device, "new_fl_paged_device");
    pragma Inline (new_fl_paged_device);

    procedure free_fl_paged_device
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_paged_device, "free_fl_paged_device");
    pragma Inline (free_fl_paged_device);




    --  Job Control  --

    function fl_paged_device_start_job
           (D : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_paged_device_start_job, "fl_paged_device_start_job");
    pragma Inline (fl_paged_device_start_job);

    function fl_paged_device_start_job2
           (D    : in     Storage.Integer_Address;
            C    : in     Interfaces.C.int;
            F, T :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_paged_device_start_job2, "fl_paged_device_start_job2");
    pragma Inline (fl_paged_device_start_job2);

    procedure fl_paged_device_end_job
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_paged_device_end_job, "fl_paged_device_end_job");
    pragma Inline (fl_paged_device_end_job);

    function fl_paged_device_start_page
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_paged_device_start_page, "fl_paged_device_start_page");
    pragma Inline (fl_paged_device_start_page);

    function fl_paged_device_end_page
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_paged_device_end_page, "fl_paged_device_end_page");
    pragma Inline (fl_paged_device_end_page);




    --  Spacing and Orientation  --

    procedure fl_paged_device_margins
           (D          : in     Storage.Integer_Address;
            L, T, R, B :    out Interfaces.C.int);
    pragma Import (C, fl_paged_device_margins, "fl_paged_device_margins");
    pragma Inline (fl_paged_device_margins);

    function fl_paged_device_printable_rect
           (D    : in     Storage.Integer_Address;
            W, H :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_paged_device_printable_rect, "fl_paged_device_printable_rect");
    pragma Inline (fl_paged_device_printable_rect);

    procedure fl_paged_device_get_origin
           (D    : in     Storage.Integer_Address;
            X, Y :    out Interfaces.C.int);
    pragma Import (C, fl_paged_device_get_origin, "fl_paged_device_get_origin");
    pragma Inline (fl_paged_device_get_origin);

    procedure fl_paged_device_set_origin
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_paged_device_set_origin, "fl_paged_device_set_origin");
    pragma Inline (fl_paged_device_set_origin);

    procedure fl_paged_device_rotate
           (D : in Storage.Integer_Address;
            R : in Interfaces.C.C_float);
    pragma Import (C, fl_paged_device_rotate, "fl_paged_device_rotate");
    pragma Inline (fl_paged_device_rotate);

    procedure fl_paged_device_scale
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.C_float);
    pragma Import (C, fl_paged_device_scale, "fl_paged_device_scale");
    pragma Inline (fl_paged_device_scale);

    procedure fl_paged_device_translate
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_paged_device_translate, "fl_paged_device_translate");
    pragma Inline (fl_paged_device_translate);

    procedure fl_paged_device_untranslate
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_paged_device_untranslate, "fl_paged_device_untranslate");
    pragma Inline (fl_paged_device_untranslate);




    --  Printing  --

    procedure fl_paged_device_print_widget
           (D, I   : in Storage.Integer_Address;
            DX, DY : in Interfaces.C.int);
    pragma Import (C, fl_paged_device_print_widget, "fl_paged_device_print_widget");
    pragma Inline (fl_paged_device_print_widget);

    procedure fl_paged_device_print_window
           (D, I   : in Storage.Integer_Address;
            DX, DY : in Interfaces.C.int);
    pragma Import (C, fl_paged_device_print_window, "fl_paged_device_print_window");
    pragma Inline (fl_paged_device_print_window);

    procedure fl_paged_device_print_window_part
           (D, I               : in Storage.Integer_Address;
            X, Y, W, H, DX, DY : in Interfaces.C.int);
    pragma Import (C, fl_paged_device_print_window_part, "fl_paged_device_print_window_part");
    pragma Inline (fl_paged_device_print_window_part);




    ------------------------
    --  Internal Utility  --
    ------------------------

    function To_Cint
           (Value : in Page_Format)
        return Interfaces.C.int is
    begin
        case Value is
        when A0 .. Envelope => return Page_Format'Pos (Value);
        when Media => return fl_page_format_media;
        end case;
    end To_Cint;


    function To_Page_Format
           (Value : in Interfaces.C.int)
        return Page_Format is
    begin
        if Value in Page_Format'Pos (A0) .. Page_Format'Pos (Envelope) then
            return Page_Format'Val (Value);
        else
            pragma Assert (Value = fl_page_format_media);
            return Media;
        end if;
    exception
    when Chk.Assertion_Error => raise Constraint_Error;
    end To_Page_Format;


    function To_Cint
           (Value : in Page_Layout)
        return Interfaces.C.int is
    begin
        case Value is
        when Portrait    => return fl_page_layout_portrait;
        when Landscape   => return fl_page_layout_landscape;
        when Reversed    => return fl_page_layout_reversed;
        when Orientation => return fl_page_layout_orientation;
        end case;
    end To_Cint;


    function To_Page_Layout
           (Value : in Interfaces.C.int)
        return Page_Layout is
    begin
        if Value = fl_page_layout_portrait then
            return Portrait;
        elsif Value = fl_page_layout_landscape then
            return Landscape;
        elsif Value = fl_page_layout_reversed then
            return Reversed;
        else
            pragma Assert (Value = fl_page_layout_orientation);
            return Orientation;
        end if;
    exception
    when Chk.Assertion_Error => raise Constraint_Error;
    end To_Page_Layout;


    function Get_Page_Formats
        return Page_Format_Info_Array
    is
        C_Name   : Interfaces.C.Strings.chars_ptr;
        C_Width  : Interfaces.C.int;
        C_Height : Interfaces.C.int;
    begin
        return Data : Page_Format_Info_Array (A0 .. To_Page_Format (fl_no_page_formats - 1)) do
            for Index in Data'Range loop
                fl_paged_device_get_page_format (To_Cint (Index), C_Name, C_Width, C_Height);
                if C_Name = Interfaces.C.Strings.Null_Ptr then
                    Data (Index).My_Name := SU.To_Unbounded_String ("");
                else
                    Data (Index).My_Name := SU.To_Unbounded_String
                        (Interfaces.C.Strings.Value (C_Name));
                end if;
                Data (Index).My_Width := Natural (C_Width);
                Data (Index).My_Height := Natural (C_Height);
            end loop;
        end return;
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl_Paged_Device::NO_PAGE_FORMATS has inconsistent value of " &
        Interfaces.C.int'Image (fl_no_page_formats);
    end Get_Page_Formats;




    ----------------------------
    --  Datatype Subprograms  --
    ----------------------------

    function Name
           (This : in Page_Format_Info)
        return String is
    begin
        return SU.To_String (This.My_Name);
    end Name;


    function Width
           (This : in Page_Format_Info)
        return Natural is
    begin
        return This.My_Width;
    end Width;


    function Height
           (This : in Page_Format_Info)
        return Natural is
    begin
        return This.My_Height;
    end Height;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Paged_Device) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_paged_device (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return Paged_Device is
        begin
            return This : Paged_Device do
                This.Void_Ptr := new_fl_paged_device;
            end return;
        end Create;

        pragma Inline (Create);

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Job Control  --

    procedure Start_Job
           (This  : in out Paged_Device;
            Count : in     Natural := 0) is
    begin
        if fl_paged_device_start_job
            (This.Void_Ptr, Interfaces.C.int (Count)) /= 0
        then
            raise Page_Error;
        end if;
    end Start_Job;


    procedure Start_Job
           (This     : in out Paged_Device;
            Count    : in     Natural := 0;
            From, To :    out Positive) is
    begin
        if fl_paged_device_start_job2
           (This.Void_Ptr,
            Interfaces.C.int (Count),
            Interfaces.C.int (From),
            Interfaces.C.int (To)) /= 0
        then
            raise Page_Error;
        end if;
    end Start_Job;


    procedure End_Job
           (This : in out Paged_Device) is
    begin
        fl_paged_device_end_job (This.Void_Ptr);
    end End_Job;


    procedure Start_Page
           (This : in out Paged_Device) is
    begin
        if fl_paged_device_start_page (This.Void_Ptr) /= 0 then
            raise Page_Error;
        end if;
    end Start_Page;


    procedure End_Page
           (This : in out Paged_Device) is
    begin
        if fl_paged_device_end_page (This.Void_Ptr) /= 0 then
            raise Page_Error;
        end if;
    end End_Page;




    --  Spacing and Orientation  --

    procedure Get_Margins
           (This                     : in     Paged_Device;
            Left, Top, Right, Bottom :    out Integer) is
    begin
        fl_paged_device_margins
           (This.Void_Ptr,
            Interfaces.C.int (Left),
            Interfaces.C.int (Top),
            Interfaces.C.int (Right),
            Interfaces.C.int (Bottom));
    end Get_Margins;


    procedure Get_Printable_Rect
           (This : in     Paged_Device;
            W, H :    out Integer) is
    begin
        if fl_paged_device_printable_rect
            (This.Void_Ptr, Interfaces.C.int (W), Interfaces.C.int (H)) /= 0
        then
            raise Page_Error;
        end if;
    end Get_Printable_Rect;


    procedure Get_Origin
           (This : in     Paged_Device;
            X, Y :    out Integer) is
    begin
        fl_paged_device_get_origin (This.Void_Ptr, Interfaces.C.int (X), Interfaces.C.int (Y));
    end Get_Origin;


    procedure Set_Origin
           (This : in out Paged_Device;
            X, Y : in     Integer) is
    begin
        fl_paged_device_set_origin
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Set_Origin;


    procedure Rotate
           (This    : in out Paged_Device;
            Degrees : in     Float) is
    begin
        fl_paged_device_rotate (This.Void_Ptr, Interfaces.C.C_float (Degrees));
    end Rotate;


    procedure Scale
           (This   : in out Paged_Device;
            Factor : in     Float) is
    begin
        fl_paged_device_scale (This.Void_Ptr, Interfaces.C.C_float (Factor), 0.0);
    end Scale;


    procedure Scale
           (This               : in out Paged_Device;
            Factor_X, Factor_Y : in     Float) is
    begin
        fl_paged_device_scale
           (This.Void_Ptr,
            Interfaces.C.C_float (Factor_X),
            Interfaces.C.C_float (Factor_Y));
    end Scale;


    procedure Translate
           (This             : in out Paged_Device;
            Delta_X, Delta_Y : in     Integer) is
    begin
        fl_paged_device_translate
           (This.Void_Ptr,
            Interfaces.C.int (Delta_X),
            Interfaces.C.int (Delta_Y));
    end Translate;


    procedure Untranslate
           (This : in out Paged_Device) is
    begin
        fl_paged_device_untranslate (This.Void_Ptr);
    end Untranslate;




    --  Printing  --

    procedure Print_Widget
           (This               : in out Paged_Device;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        fl_paged_device_print_widget
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Print_Widget;


    procedure Print_Window
           (This               : in out Paged_Device;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        fl_paged_device_print_window
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Print_Window;


    procedure Print_Window_Part
           (This               : in out Paged_Device;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        fl_paged_device_print_window_part
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Print_Window_Part;


end FLTK.Devices.Surface.Paged;


