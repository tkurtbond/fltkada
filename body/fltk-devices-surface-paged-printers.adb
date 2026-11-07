

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Drawing_State,
    Ada.Unchecked_Deallocation,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Devices.Surface.Paged.Printers is


    --  FLTK's print panel is built once, the first time a job starts, from the
    --  static label pointers, which its widgets keep (print_panel.cxx:249-503).
    --  The panel is never deleted (Fl_Posix_Printer_Driver.cxx:282), so a
    --  replaced label may be read until the program ends.  Its copy waits here,
    --  and the final controller frees it.  This is a plain list, not a
    --  container, since the body's objects are finalized before the spec's
    --  Cleanup.
    type Retired_Label;

    type Retired_Label_Access is access Retired_Label;

    type Retired_Label is record
        Text : Interfaces.C.Strings.chars_ptr;
        Next : Retired_Label_Access;
    end record;

    procedure Free is new Ada.Unchecked_Deallocation (Retired_Label, Retired_Label_Access);

    Retired_Labels : Retired_Label_Access := null;

    procedure Retire
           (Text : in Interfaces.C.Strings.chars_ptr) is
    begin
        if Interfaces.C.Strings."/=" (Text, Interfaces.C.Strings.Null_Ptr) then
            Retired_Labels := new Retired_Label'(Text => Text, Next => Retired_Labels);
        end if;
    end Retire;




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_printer
        return Storage.Integer_Address;
    pragma Import (C, new_fl_printer, "new_fl_printer");
    pragma Inline (new_fl_printer);

    procedure free_fl_printer
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_printer, "free_fl_printer");
    pragma Inline (free_fl_printer);




    --  Static Attributes  --

    function fl_printer_get_dialog_title
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_title, "fl_printer_get_dialog_title");
    pragma Inline (fl_printer_get_dialog_title);

    procedure fl_printer_set_dialog_title
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_title, "fl_printer_set_dialog_title");
    pragma Inline (fl_printer_set_dialog_title);

    function fl_printer_get_dialog_printer
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_printer, "fl_printer_get_dialog_printer");
    pragma Inline (fl_printer_get_dialog_printer);

    procedure fl_printer_set_dialog_printer
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_printer, "fl_printer_set_dialog_printer");
    pragma Inline (fl_printer_set_dialog_printer);

    function fl_printer_get_dialog_range
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_range, "fl_printer_get_dialog_range");
    pragma Inline (fl_printer_get_dialog_range);

    procedure fl_printer_set_dialog_range
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_range, "fl_printer_set_dialog_range");
    pragma Inline (fl_printer_set_dialog_range);

    function fl_printer_get_dialog_copies
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_copies, "fl_printer_get_dialog_copies");
    pragma Inline (fl_printer_get_dialog_copies);

    procedure fl_printer_set_dialog_copies
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_copies, "fl_printer_set_dialog_copies");
    pragma Inline (fl_printer_set_dialog_copies);

    function fl_printer_get_dialog_all
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_all, "fl_printer_get_dialog_all");
    pragma Inline (fl_printer_get_dialog_all);

    procedure fl_printer_set_dialog_all
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_all, "fl_printer_set_dialog_all");
    pragma Inline (fl_printer_set_dialog_all);

    function fl_printer_get_dialog_pages
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_pages, "fl_printer_get_dialog_pages");
    pragma Inline (fl_printer_get_dialog_pages);

    procedure fl_printer_set_dialog_pages
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_pages, "fl_printer_set_dialog_pages");
    pragma Inline (fl_printer_set_dialog_pages);

    function fl_printer_get_dialog_from
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_from, "fl_printer_get_dialog_from");
    pragma Inline (fl_printer_get_dialog_from);

    procedure fl_printer_set_dialog_from
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_from, "fl_printer_set_dialog_from");
    pragma Inline (fl_printer_set_dialog_from);

    function fl_printer_get_dialog_to
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_to, "fl_printer_get_dialog_to");
    pragma Inline (fl_printer_get_dialog_to);

    procedure fl_printer_set_dialog_to
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_to, "fl_printer_set_dialog_to");
    pragma Inline (fl_printer_set_dialog_to);

    function fl_printer_get_dialog_properties
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_properties, "fl_printer_get_dialog_properties");
    pragma Inline (fl_printer_get_dialog_properties);

    procedure fl_printer_set_dialog_properties
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_properties, "fl_printer_set_dialog_properties");
    pragma Inline (fl_printer_set_dialog_properties);

    function fl_printer_get_dialog_copyno
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_copyno, "fl_printer_get_dialog_copyno");
    pragma Inline (fl_printer_get_dialog_copyno);

    procedure fl_printer_set_dialog_copyno
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_copyno, "fl_printer_set_dialog_copyno");
    pragma Inline (fl_printer_set_dialog_copyno);

    function fl_printer_get_dialog_print_button
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_print_button, "fl_printer_get_dialog_print_button");
    pragma Inline (fl_printer_get_dialog_print_button);

    procedure fl_printer_set_dialog_print_button
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_print_button, "fl_printer_set_dialog_print_button");
    pragma Inline (fl_printer_set_dialog_print_button);

    function fl_printer_get_dialog_cancel_button
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_cancel_button, "fl_printer_get_dialog_cancel_button");
    pragma Inline (fl_printer_get_dialog_cancel_button);

    procedure fl_printer_set_dialog_cancel_button
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_cancel_button, "fl_printer_set_dialog_cancel_button");
    pragma Inline (fl_printer_set_dialog_cancel_button);

    function fl_printer_get_dialog_print_to_file
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_dialog_print_to_file, "fl_printer_get_dialog_print_to_file");
    pragma Inline (fl_printer_get_dialog_print_to_file);

    procedure fl_printer_set_dialog_print_to_file
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_dialog_print_to_file, "fl_printer_set_dialog_print_to_file");
    pragma Inline (fl_printer_set_dialog_print_to_file);

    function fl_printer_get_property_title
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_property_title, "fl_printer_get_property_title");
    pragma Inline (fl_printer_get_property_title);

    procedure fl_printer_set_property_title
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_property_title, "fl_printer_set_property_title");
    pragma Inline (fl_printer_set_property_title);

    function fl_printer_get_property_pagesize
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_property_pagesize, "fl_printer_get_property_pagesize");
    pragma Inline (fl_printer_get_property_pagesize);

    procedure fl_printer_set_property_pagesize
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_property_pagesize, "fl_printer_set_property_pagesize");
    pragma Inline (fl_printer_set_property_pagesize);

    function fl_printer_get_property_mode
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_property_mode, "fl_printer_get_property_mode");
    pragma Inline (fl_printer_get_property_mode);

    procedure fl_printer_set_property_mode
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_property_mode, "fl_printer_set_property_mode");
    pragma Inline (fl_printer_set_property_mode);

    function fl_printer_get_property_use
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_property_use, "fl_printer_get_property_use");
    pragma Inline (fl_printer_get_property_use);

    procedure fl_printer_set_property_use
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_property_use, "fl_printer_set_property_use");
    pragma Inline (fl_printer_set_property_use);

    function fl_printer_get_property_save
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_property_save, "fl_printer_get_property_save");
    pragma Inline (fl_printer_get_property_save);

    procedure fl_printer_set_property_save
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_property_save, "fl_printer_set_property_save");
    pragma Inline (fl_printer_set_property_save);

    function fl_printer_get_property_cancel
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_printer_get_property_cancel, "fl_printer_get_property_cancel");
    pragma Inline (fl_printer_get_property_cancel);

    procedure fl_printer_set_property_cancel
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_printer_set_property_cancel, "fl_printer_set_property_cancel");
    pragma Inline (fl_printer_set_property_cancel);




    --  Job Control  --

    function fl_printer_start_job
           (D : in Storage.Integer_Address;
            C : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_printer_start_job, "fl_printer_start_job");
    pragma Inline (fl_printer_start_job);

    function fl_printer_start_job2
           (D    : in     Storage.Integer_Address;
            C    : in     Interfaces.C.int;
            F, T :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_printer_start_job2, "fl_printer_start_job2");
    pragma Inline (fl_printer_start_job2);

    procedure fl_printer_end_job
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_printer_end_job, "fl_printer_end_job");
    pragma Inline (fl_printer_end_job);

    function fl_printer_start_page
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_printer_start_page, "fl_printer_start_page");
    pragma Inline (fl_printer_start_page);

    function fl_printer_end_page
           (D : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_printer_end_page, "fl_printer_end_page");
    pragma Inline (fl_printer_end_page);




    --  Spacing and Orientation  --

    procedure fl_printer_margins
           (D          : in     Storage.Integer_Address;
            L, T, R, B :    out Interfaces.C.int);
    pragma Import (C, fl_printer_margins, "fl_printer_margins");
    pragma Inline (fl_printer_margins);

    function fl_printer_printable_rect
           (D    : in     Storage.Integer_Address;
            W, H :    out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_printer_printable_rect, "fl_printer_printable_rect");
    pragma Inline (fl_printer_printable_rect);

    procedure fl_printer_get_origin
           (D    : in     Storage.Integer_Address;
            X, Y :    out Interfaces.C.int);
    pragma Import (C, fl_printer_get_origin, "fl_printer_get_origin");
    pragma Inline (fl_printer_get_origin);

    procedure fl_printer_set_origin
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_printer_set_origin, "fl_printer_set_origin");
    pragma Inline (fl_printer_set_origin);

    procedure fl_printer_rotate
           (D : in Storage.Integer_Address;
            R : in Interfaces.C.C_float);
    pragma Import (C, fl_printer_rotate, "fl_printer_rotate");
    pragma Inline (fl_printer_rotate);

    procedure fl_printer_scale
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.C_float);
    pragma Import (C, fl_printer_scale, "fl_printer_scale");
    pragma Inline (fl_printer_scale);

    procedure fl_printer_translate
           (D    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_printer_translate, "fl_printer_translate");
    pragma Inline (fl_printer_translate);

    procedure fl_printer_untranslate
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_printer_untranslate, "fl_printer_untranslate");
    pragma Inline (fl_printer_untranslate);




    --  Printing  --

    procedure fl_printer_print_widget
           (D, I   : in Storage.Integer_Address;
            DX, DY : in Interfaces.C.int);
    pragma Import (C, fl_printer_print_widget, "fl_printer_print_widget");
    pragma Inline (fl_printer_print_widget);

    procedure fl_printer_print_window_part
           (D, I               : in Storage.Integer_Address;
            X, Y, W, H, DX, DY : in Interfaces.C.int);
    pragma Import (C, fl_printer_print_window_part, "fl_printer_print_window_part");
    pragma Inline (fl_printer_print_window_part);




    --  Printer  --

    procedure fl_printer_set_current
           (D : in Storage.Integer_Address);
    pragma Import (C, fl_printer_set_current, "fl_printer_set_current");
    pragma Inline (fl_printer_set_current);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Printer) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if Release_Current (This) then
                free_fl_printer (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
        Drawing_State.Forget_All (This'Address);
    end Finalize;


    procedure Finalize
           (This : in out Printer_Final_Controller)
    is
        use Interfaces.C.Strings;
    begin
        Free (Dialog_Title);
        Free (Dialog_Printer);
        Free (Dialog_Range);
        Free (Dialog_Copies);
        Free (Dialog_All);
        Free (Dialog_Pages);
        Free (Dialog_From);
        Free (Dialog_To);
        Free (Dialog_Properties);
        Free (Dialog_Copyno);
        Free (Dialog_Print_Button);
        Free (Dialog_Cancel_Button);
        Free (Dialog_Print_To_File);
        Free (Property_Title);
        Free (Property_Pagesize);
        Free (Property_Mode);
        Free (Property_Use);
        Free (Property_Save);
        Free (Property_Cancel);
        while Retired_Labels /= null loop
            declare
                Next : constant Retired_Label_Access := Retired_Labels.Next;
            begin
                Free (Retired_Labels.Text);
                Free (Retired_Labels);
                Retired_Labels := Next;
            end;
        end loop;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
            return Printer is
        begin
            return This : Printer do
                This.Void_Ptr := new_fl_printer;
            end return;
        end Create;

        pragma Inline (Create);

    end Forge;




    -------------------------
    --  Static Attributes  --
    -------------------------

    function Get_Dialog_Title
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_title);
    end Get_Dialog_Title;


    procedure Set_Dialog_Title
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Title;
    begin
        Dialog_Title := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_title (Dialog_Title);
        Retire (Old);
    end Set_Dialog_Title;


    function Get_Dialog_Printer
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_printer);
    end Get_Dialog_Printer;


    procedure Set_Dialog_Printer
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Printer;
    begin
        Dialog_Printer := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_printer (Dialog_Printer);
        Retire (Old);
    end Set_Dialog_Printer;


    function Get_Dialog_Range
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_range);
    end Get_Dialog_Range;


    procedure Set_Dialog_Range
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Range;
    begin
        Dialog_Range := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_range (Dialog_Range);
        Retire (Old);
    end Set_Dialog_Range;


    function Get_Dialog_Copies
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_copies);
    end Get_Dialog_Copies;


    procedure Set_Dialog_Copies
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Copies;
    begin
        Dialog_Copies := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_copies (Dialog_Copies);
        Retire (Old);
    end Set_Dialog_Copies;


    function Get_Dialog_All
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_all);
    end Get_Dialog_All;


    procedure Set_Dialog_All
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_All;
    begin
        Dialog_All := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_all (Dialog_All);
        Retire (Old);
    end Set_Dialog_All;


    function Get_Dialog_Pages
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_pages);
    end Get_Dialog_Pages;


    procedure Set_Dialog_Pages
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Pages;
    begin
        Dialog_Pages := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_pages (Dialog_Pages);
        Retire (Old);
    end Set_Dialog_Pages;


    function Get_Dialog_From
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_from);
    end Get_Dialog_From;


    procedure Set_Dialog_From
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_From;
    begin
        Dialog_From := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_from (Dialog_From);
        Retire (Old);
    end Set_Dialog_From;


    function Get_Dialog_To
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_to);
    end Get_Dialog_To;


    procedure Set_Dialog_To
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_To;
    begin
        Dialog_To := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_to (Dialog_To);
        Retire (Old);
    end Set_Dialog_To;


    function Get_Dialog_Properties
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_properties);
    end Get_Dialog_Properties;


    procedure Set_Dialog_Properties
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Properties;
    begin
        Dialog_Properties := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_properties (Dialog_Properties);
        Retire (Old);
    end Set_Dialog_Properties;


    function Get_Dialog_Number_Copies
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_copyno);
    end Get_Dialog_Number_Copies;


    procedure Set_Dialog_Number_Copies
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Copyno;
    begin
        Dialog_Copyno := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_copyno (Dialog_Copyno);
        Retire (Old);
    end Set_Dialog_Number_Copies;


    function Get_Dialog_Print_Button
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_print_button);
    end Get_Dialog_Print_Button;


    procedure Set_Dialog_Print_Button
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Print_Button;
    begin
        Dialog_Print_Button := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_print_button (Dialog_Print_Button);
        Retire (Old);
    end Set_Dialog_Print_Button;


    function Get_Dialog_Cancel_Button
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_cancel_button);
    end Get_Dialog_Cancel_Button;


    procedure Set_Dialog_Cancel_Button
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Dialog_Cancel_Button;
    begin
        Dialog_Cancel_Button := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_cancel_button (Dialog_Cancel_Button);
        Retire (Old);
    end Set_Dialog_Cancel_Button;


    function Get_Dialog_Print_To_File
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_dialog_print_to_file);
    end Get_Dialog_Print_To_File;


    procedure Set_Dialog_Print_To_File
           (Value : in String)
    is
        Old : Interfaces.C.Strings.chars_ptr := Dialog_Print_To_File;
    begin
        Dialog_Print_To_File := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_dialog_print_to_file (Dialog_Print_To_File);
        Interfaces.C.Strings.Free (Old);
    end Set_Dialog_Print_To_File;


    function Get_Property_Title
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_property_title);
    end Get_Property_Title;


    procedure Set_Property_Title
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Property_Title;
    begin
        Property_Title := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_property_title (Property_Title);
        Retire (Old);
    end Set_Property_Title;


    function Get_Property_Page_Size
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_property_pagesize);
    end Get_Property_Page_Size;


    procedure Set_Property_Page_Size
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Property_Pagesize;
    begin
        Property_Pagesize := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_property_pagesize (Property_Pagesize);
        Retire (Old);
    end Set_Property_Page_Size;


    function Get_Property_Mode
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_property_mode);
    end Get_Property_Mode;


    procedure Set_Property_Mode
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Property_Mode;
    begin
        Property_Mode := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_property_mode (Property_Mode);
        Retire (Old);
    end Set_Property_Mode;


    function Get_Property_Use
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_property_use);
    end Get_Property_Use;


    procedure Set_Property_Use
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Property_Use;
    begin
        Property_Use := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_property_use (Property_Use);
        Retire (Old);
    end Set_Property_Use;


    function Get_Property_Save
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_property_save);
    end Get_Property_Save;


    procedure Set_Property_Save
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Property_Save;
    begin
        Property_Save := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_property_save (Property_Save);
        Retire (Old);
    end Set_Property_Save;


    function Get_Property_Cancel
        return String is
    begin
        return Interfaces.C.Strings.Value (fl_printer_get_property_cancel);
    end Get_Property_Cancel;


    procedure Set_Property_Cancel
           (Value : in String)
    is
        Old : constant Interfaces.C.Strings.chars_ptr := Property_Cancel;
    begin
        Property_Cancel := Interfaces.C.Strings.New_String (Value);
        fl_printer_set_property_cancel (Property_Cancel);
        Retire (Old);
    end Set_Property_Cancel;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Driver  --

    function Get_Original_Driver
           (This : in out Printer)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference is
    begin
        return raise Program_Error with "Won't be implemented until Graphics_Drivers taken care of";
    end Get_Original_Driver;




    --  Job Control  --

    procedure Start_Job
           (This  : in out Printer;
            Count : in     Natural := 0) is
    begin
        if fl_printer_start_job
            (This.Void_Ptr, Interfaces.C.int (Count)) /= 0
        then
            raise Page_Error;
        end if;
    end Start_Job;


    procedure Start_Job
           (This     : in out Printer;
            Count    : in     Natural := 0;
            From, To :    out Positive) is
    begin
        if fl_printer_start_job2
           (This.Void_Ptr,
            Interfaces.C.int (Count),
            Interfaces.C.int (From),
            Interfaces.C.int (To)) /= 0
        then
            raise Page_Error;
        end if;
    end Start_Job;


    procedure End_Job
           (This : in out Printer) is
    begin
        --  FLTK's end_job doesn't pop the device that begin_page pushed
        --  (FLTKAda-BUGS.md 123).
        if This.In_Page then
            End_Page (This);
        end if;
        This.Shifts := 0;
        fl_printer_end_job (This.Void_Ptr);
    end End_Job;


    procedure Start_Page
           (This : in out Printer) is
    begin
        if This.In_Page then
            raise Page_Error with "a page is already started";
        end if;
        This.Shifts := 0;
        if fl_printer_start_page (This.Void_Ptr) /= 0 then
            raise Page_Error;
        end if;
        --  FLTK's begin_page pushed the device (FLTKAda-BUGS.md 75).
        Push_Bookkeep (This);
        This.In_Page := True;
        Remember_Page (This);
    end Start_Page;


    procedure End_Page
           (This : in out Printer) is
    begin
        --  FLTK's end_page pops the stack of surfaces whatever is on top,
        --  so outside a page it would pop some other surface.
        if not This.In_Page then
            raise Page_Error with "no page is started";
        end if;
        This.In_Page := False;
        Forget_Page (This);
        This.Shifts := 0;
        declare
            Result : constant Interfaces.C.int := fl_printer_end_page (This.Void_Ptr);
        begin
            Pop_Bookkeep;
            if Result /= 0 then
                raise Page_Error;
            end if;
        end;
    end End_Page;




    --  Spacing and Orientation  --

    procedure Get_Margins
           (This                     : in     Printer;
            Left, Top, Right, Bottom :    out Integer) is
    begin
        fl_printer_margins
           (This.Void_Ptr,
            Interfaces.C.int (Left),
            Interfaces.C.int (Top),
            Interfaces.C.int (Right),
            Interfaces.C.int (Bottom));
    end Get_Margins;


    procedure Get_Printable_Rect
           (This : in     Printer;
            W, H :    out Integer) is
    begin
        if fl_printer_printable_rect
            (This.Void_Ptr, Interfaces.C.int (W), Interfaces.C.int (H)) /= 0
        then
            raise Page_Error;
        end if;
    end Get_Printable_Rect;


    procedure Get_Origin
           (This : in     Printer;
            X, Y :    out Integer) is
    begin
        fl_printer_get_origin (This.Void_Ptr, Interfaces.C.int (X), Interfaces.C.int (Y));
    end Get_Origin;


    procedure Set_Origin
           (This : in out Printer;
            X, Y : in     Integer) is
    begin
        Check_In_Page (This, "Set_Origin");
        fl_printer_set_origin
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Set_Origin;


    procedure Rotate
           (This    : in out Printer;
            Degrees : in     Float) is
    begin
        Check_Rotation (Degrees);
        Check_In_Page (This, "Rotate");
        fl_printer_rotate (This.Void_Ptr, Interfaces.C.C_float (Degrees));
    end Rotate;


    procedure Scale
           (This   : in out Printer;
            Factor : in     Float) is
    begin
        Check_Scale (Factor, 0.0);
        Check_In_Page (This, "Scale");
        fl_printer_scale (This.Void_Ptr, Interfaces.C.C_float (Factor), 0.0);
    end Scale;


    procedure Scale
           (This               : in out Printer;
            Factor_X, Factor_Y : in     Float) is
    begin
        Check_Scale (Factor_X, Factor_Y);
        Check_In_Page (This, "Scale");
        fl_printer_scale
           (This.Void_Ptr,
            Interfaces.C.C_float (Factor_X),
            Interfaces.C.C_float (Factor_Y));
    end Scale;


    procedure Translate
           (This             : in out Printer;
            Delta_X, Delta_Y : in     Integer) is
    begin
        Check_In_Page (This, "Translate");
        This.Shifts := This.Shifts + 1;
        fl_printer_translate
           (This.Void_Ptr,
            Interfaces.C.int (Delta_X),
            Interfaces.C.int (Delta_Y));
    end Translate;


    procedure Untranslate
           (This : in out Printer) is
    begin
        Check_Untranslate (This);
        This.Shifts := This.Shifts - 1;
        fl_printer_untranslate (This.Void_Ptr);
    end Untranslate;




    --  Printing  --

    procedure Print_Widget
           (This               : in out Printer;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        fl_printer_print_widget
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Print_Widget;


    procedure Print_Window_Part
           (This               : in out Printer;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        fl_printer_print_window_part
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Print_Window_Part;




    --  Printer  --

    procedure Set_Current
           (This : in out Printer) is
    begin
        fl_printer_set_current (This.Void_Ptr);
        This.Set_Current_Bookkeep;
    end Set_Current;


end FLTK.Devices.Surface.Paged.Printers;


