

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Devices.Surface.Paged.Postscript is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Files  --

    function fopen
           (Name, Mode : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, fopen, "fopen");

    function fclose
           (Handle : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fclose, "fclose");




    --  Allocation  --

    function new_fl_postscript_file_device
        return Storage.Integer_Address;
    pragma Import (C, new_fl_postscript_file_device, "new_fl_postscript_file_device");
    pragma Inline (new_fl_postscript_file_device);

    procedure free_fl_postscript_file_device
           (P : in Storage.Integer_Address);
    pragma Import (C, free_fl_postscript_file_device, "free_fl_postscript_file_device");
    pragma Inline (free_fl_postscript_file_device);




    --  Static Attributes  --

    function fl_postscript_file_device_supported
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_supported,
        "fl_postscript_file_device_supported");
    pragma Inline (fl_postscript_file_device_supported);

    function fl_postscript_file_device_get_file_chooser_title
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_postscript_file_device_get_file_chooser_title,
        "fl_postscript_file_device_get_file_chooser_title");
    pragma Inline (fl_postscript_file_device_get_file_chooser_title);

    procedure fl_postscript_file_device_set_file_chooser_title
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_postscript_file_device_set_file_chooser_title,
        "fl_postscript_file_device_set_file_chooser_title");
    pragma Inline (fl_postscript_file_device_set_file_chooser_title);




    --  Driver  --

    --  function fl_postscript_file_device_get_driver
    --         (D : in Storage.Integer_Address)
    --      return Storage.Integer_Address;
    --  pragma Import (C, fl_postscript_file_device_get_driver,
    --      "fl_postscript_file_device_get_driver");
    --  pragma Inline (fl_postscript_file_device_get_driver);




    --  Job Control  --

    function fl_postscript_file_device_start_job
           (D : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_start_job, "fl_postscript_file_device_start_job");
    pragma Inline (fl_postscript_file_device_start_job);

    function fl_postscript_file_device_start_job2
           (D    : in     Storage.Integer_Address;
            C    : in     Interfaces.C.int;
            F, T :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_start_job2, "fl_postscript_file_device_start_job2");
    pragma Inline (fl_postscript_file_device_start_job2);

    function fl_postscript_file_device_start_job3
           (D, O    : in Storage.Integer_Address;
            C, F, L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_start_job3, "fl_postscript_file_device_start_job3");
    pragma Inline (fl_postscript_file_device_start_job3);

    function fl_postscript_file_device_start_job4
           (D       : in Storage.Integer_Address;
            C, F, L : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_start_job4, "fl_postscript_file_device_start_job4");
    pragma Inline (fl_postscript_file_device_start_job4);

    function fl_postscript_file_device_end_job
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_end_job, "fl_postscript_file_device_end_job");
    pragma Inline (fl_postscript_file_device_end_job);

    function fl_postscript_file_device_start_page
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_start_page, "fl_postscript_file_device_start_page");
    pragma Inline (fl_postscript_file_device_start_page);

    function fl_postscript_file_device_end_page
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_end_page, "fl_postscript_file_device_end_page");
    pragma Inline (fl_postscript_file_device_end_page);




    --  Spacing and Orientation  --

    procedure fl_postscript_file_device_margins
           (D          : in     Storage.Integer_Address;
            L, T, R, B :    out Interfaces.C.int);
    pragma Import (C, fl_postscript_file_device_margins, "fl_postscript_file_device_margins");
    pragma Inline (fl_postscript_file_device_margins);

    function fl_postscript_file_device_printable_rect
           (D    : in     Storage.Integer_Address;
            W, H :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_postscript_file_device_printable_rect,
        "fl_postscript_file_device_printable_rect");
    pragma Inline (fl_postscript_file_device_printable_rect);

    procedure fl_postscript_file_device_get_origin
           (D    : in     Storage.Integer_Address;
            X, Y :    out Interfaces.C.int);
    pragma Import (C, fl_postscript_file_device_get_origin, "fl_postscript_file_device_get_origin");
    pragma Inline (fl_postscript_file_device_get_origin);

    procedure fl_postscript_file_device_set_origin
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_postscript_file_device_set_origin, "fl_postscript_file_device_set_origin");
    pragma Inline (fl_postscript_file_device_set_origin);

    procedure fl_postscript_file_device_rotate
           (D : in Storage.Integer_Address;
            R : in Interfaces.C.C_float);
    pragma Import (C, fl_postscript_file_device_rotate, "fl_postscript_file_device_rotate");
    pragma Inline (fl_postscript_file_device_rotate);

    procedure fl_postscript_file_device_scale
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.C_float);
    pragma Import (C, fl_postscript_file_device_scale, "fl_postscript_file_device_scale");
    pragma Inline (fl_postscript_file_device_scale);

    procedure fl_postscript_file_device_translate
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_postscript_file_device_translate, "fl_postscript_file_device_translate");
    pragma Inline (fl_postscript_file_device_translate);

    procedure fl_postscript_file_device_untranslate
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_postscript_file_device_untranslate,
        "fl_postscript_file_device_untranslate");
    pragma Inline (fl_postscript_file_device_untranslate);




    -----------------------------
    --  Auxiliary Subprograms  --
    -----------------------------

    procedure Open
           (File : in out File_Type;
            Name : in     String)
    is
        Result : Storage.Integer_Address;
    begin
        File.Close;
        Result := fopen
           (Interfaces.C.To_C (Name),
            Interfaces.C.To_C ("w"));
        if Result = Null_Pointer then
            raise File_Open_Error;
        else
            File.C_File := Result;
            File.Open_State := True;
        end if;
    end Open;


    function Is_Open
           (File : in File_Type)
        return Boolean is
    begin
        return File.Open_State;
    end Is_Open;


    procedure Close
           (File : in out File_Type)
    is
        Result : Interfaces.C.int;
    begin
        if File.Is_Open then
            Result := fclose (File.C_File);
            if Result /= 0 then
                raise File_Close_Error;
            end if;
            File.Open_State := False;
        end if;
    end Close;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out File_Type) is
    begin
        This.Close;
    end Finalize;


    procedure Finalize
           (This : in out Postscript_File_Device) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if Release_Current (This) then
                free_fl_postscript_file_device (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;


    procedure Finalize
           (This : in out Postscript_File_Device_Final_Controller) is
    begin
        Interfaces.C.Strings.Free (File_Chooser_Title);
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return Postscript_File_Device is
        begin
            return This : Postscript_File_Device do
                This.Void_Ptr := new_fl_postscript_file_device;
            end return;
        end Create;

    end Forge;




    -------------------------
    --  Static Attributes  --
    -------------------------

    function Is_Supported
        return Boolean is
    begin
        return fl_postscript_file_device_supported /= 0;
    end Is_Supported;


    function Get_File_Chooser_Title
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_postscript_file_device_get_file_chooser_title);
    end Get_File_Chooser_Title;


    procedure Set_File_Chooser_Title
           (Value : in String) is
    begin
        if not Is_Supported then
            raise Unsupported_Error with "this FLTK was built without printing";
        end if;
        Interfaces.C.Strings.Free (File_Chooser_Title);
        File_Chooser_Title := Interfaces.C.Strings.New_String (Value);
        fl_postscript_file_device_set_file_chooser_title (File_Chooser_Title);
    end Set_File_Chooser_Title;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Driver  --

    function Get_Postscript_Driver
           (This : in out Postscript_File_Device)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference is
    begin
        return raise Program_Error with "Get_Postscript_Driver unimplemented";
    end Get_Postscript_Driver;




    --  Job Control  --

    procedure Start_Job
           (This  : in out Postscript_File_Device;
            Count : in     Natural := 0) is
    begin
        if fl_postscript_file_device_start_job
            (This.Void_Ptr, Interfaces.C.int (Count)) /= 0
        then
            raise Page_Error;
        end if;
    end Start_Job;


    procedure Start_Job
           (This     : in out Postscript_File_Device;
            Count    : in     Natural := 0;
            From, To :    out Positive) is
    begin
        if fl_postscript_file_device_start_job2
           (This.Void_Ptr,
            Interfaces.C.int (Count),
            Interfaces.C.int (From),
            Interfaces.C.int (To)) /= 0
        then
            raise Page_Error;
        end if;
    end Start_Job;


    procedure Start_Job
           (This   : in out Postscript_File_Device;
            Output : in     File_Type'Class;
            Count  : in     Natural := 0;
            Format : in     Page_Format := A4;
            Layout : in     Page_Layout := Portrait)
    is
        Code : Interfaces.C.int;
    begin
        if not Output.Is_Open then
            raise File_Open_Error with "the file isn't open";
        end if;
        Check_Format (Format);
        Code := fl_postscript_file_device_start_job3
           (This.Void_Ptr,
            Output.C_File,
            Interfaces.C.int (Count),
            To_Cint (Format),
            To_Cint (Layout));
        if Code = 3 then
            raise File_Open_Error with "no stream for the PostScript to go through";
        end if;
        pragma Assert (Code = 0);
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_PostScript_File_Device::start_job returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Start_Job;


    procedure Start_Job
           (This   : in out Postscript_File_Device;
            Count  : in     Natural := 0;
            Format : in     Page_Format := A4;
            Layout : in     Page_Layout := Portrait)
    is
        Code : Interfaces.C.int;
    begin
        Check_Format (Format);
        Code := fl_postscript_file_device_start_job4
           (This.Void_Ptr,
            Interfaces.C.int (Count),
            To_Cint (Format),
            To_Cint (Layout));
        case Code is
        when 1 => raise User_Cancel_Error;
        when 2 => raise File_Open_Error;
        when others => pragma Assert (Code = 0);
        end case;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl_PostScript_File_Device::start_job returned unexpected int value of " &
        Interfaces.C.int'Image (Code);
    end Start_Job;


    procedure End_Job
           (This : in out Postscript_File_Device) is
    begin
        This.In_Page := False;
        This.Shifts := 0;
        case fl_postscript_file_device_end_job (This.Void_Ptr) is
        when 0 => null;
        when 1 => raise File_Write_Error with "the PostScript couldn't all be written";
        when others => raise File_Write_Error with "Cairo refused the drawing";
        end case;
    end End_Job;


    procedure Start_Page
           (This : in out Postscript_File_Device) is
    begin
        if This.In_Page then
            raise Page_Error with "a page is already started";
        end if;
        This.Shifts := 0;
        if fl_postscript_file_device_start_page (This.Void_Ptr) /= 0 then
            raise Page_Error;
        end if;
        --  FLTK's begin_page pushed the device (FLTKAda-BUGS.md 75).
        Push_Bookkeep (This);
        This.In_Page := True;
    end Start_Page;


    procedure End_Page
           (This : in out Postscript_File_Device) is
    begin
        --  FLTK's end_page pops the stack of surfaces whatever is on top,
        --  so outside a page it would pop some other surface.
        if not This.In_Page then
            raise Page_Error with "no page is started";
        end if;
        This.In_Page := False;
        This.Shifts := 0;
        declare
            Result : constant Interfaces.C.int :=
                fl_postscript_file_device_end_page (This.Void_Ptr);
        begin
            Pop_Bookkeep;
            if Result /= 0 then
                raise Page_Error;
            end if;
        end;
    end End_Page;




    --  Spacing and Orientation  --

    procedure Get_Margins
           (This                     : in     Postscript_File_Device;
            Left, Top, Right, Bottom :    out Integer) is
    begin
        fl_postscript_file_device_margins
           (This.Void_Ptr,
            Interfaces.C.int (Left),
            Interfaces.C.int (Top),
            Interfaces.C.int (Right),
            Interfaces.C.int (Bottom));
    end Get_Margins;


    procedure Get_Printable_Rect
           (This : in     Postscript_File_Device;
            W, H :    out Integer) is
    begin
        if fl_postscript_file_device_printable_rect
            (This.Void_Ptr, Interfaces.C.int (W), Interfaces.C.int (H)) /= 0
        then
            raise Page_Error;
        end if;
    end Get_Printable_Rect;


    procedure Get_Origin
           (This : in     Postscript_File_Device;
            X, Y :    out Integer) is
    begin
        fl_postscript_file_device_get_origin
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Get_Origin;


    procedure Set_Origin
           (This : in out Postscript_File_Device;
            X, Y : in     Integer) is
    begin
        Check_In_Page (This, "Set_Origin");
        fl_postscript_file_device_set_origin
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Set_Origin;


    procedure Rotate
           (This    : in out Postscript_File_Device;
            Degrees : in     Float) is
    begin
        Check_Rotation (Degrees);
        Check_In_Page (This, "Rotate");
        fl_postscript_file_device_rotate (This.Void_Ptr, Interfaces.C.C_float (Degrees));
    end Rotate;


    procedure Scale
           (This   : in out Postscript_File_Device;
            Factor : in     Float) is
    begin
        Check_Scale (Factor, 0.0);
        Check_In_Page (This, "Scale");
        fl_postscript_file_device_scale (This.Void_Ptr, Interfaces.C.C_float (Factor), 0.0);
    end Scale;


    procedure Scale
           (This               : in out Postscript_File_Device;
            Factor_X, Factor_Y : in     Float) is
    begin
        Check_Scale (Factor_X, Factor_Y);
        Check_In_Page (This, "Scale");
        fl_postscript_file_device_scale
           (This.Void_Ptr,
            Interfaces.C.C_float (Factor_X),
            Interfaces.C.C_float (Factor_Y));
    end Scale;


    procedure Translate
           (This             : in out Postscript_File_Device;
            Delta_X, Delta_Y : in     Integer) is
    begin
        Check_In_Page (This, "Translate");
        This.Shifts := This.Shifts + 1;
        fl_postscript_file_device_translate
           (This.Void_Ptr,
            Interfaces.C.int (Delta_X),
            Interfaces.C.int (Delta_Y));
    end Translate;


    procedure Untranslate
           (This : in out Postscript_File_Device) is
    begin
        Check_Untranslate (This);
        This.Shifts := This.Shifts - 1;
        fl_postscript_file_device_untranslate (This.Void_Ptr);
    end Untranslate;


end FLTK.Devices.Surface.Paged.Postscript;


