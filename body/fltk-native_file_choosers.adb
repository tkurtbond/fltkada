

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


with

    Ada.Strings.Fixed,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Native_File_Choosers is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_native_file_chooser
           (T : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_native_file_chooser, "new_fl_native_file_chooser");
    pragma Inline (new_fl_native_file_chooser);

    procedure free_fl_native_file_chooser
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_native_file_chooser, "free_fl_native_file_chooser");
    pragma Inline (free_fl_native_file_chooser);




    --  Static Messages  --

    function fl_native_file_chooser_get_file_exists_message
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_get_file_exists_message,
        "fl_native_file_chooser_get_file_exists_message");
    pragma Inline (fl_native_file_chooser_get_file_exists_message);

    procedure fl_native_file_chooser_set_file_exists_message
           (V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_native_file_chooser_set_file_exists_message,
        "fl_native_file_chooser_set_file_exists_message");
    pragma Inline (fl_native_file_chooser_set_file_exists_message);




    --  Settings  --

    function fl_native_file_chooser_get_type
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_native_file_chooser_get_type, "fl_native_file_chooser_get_type");
    pragma Inline (fl_native_file_chooser_get_type);

    procedure fl_native_file_chooser_set_type
           (F : in Storage.Integer_Address;
            T : in Interfaces.C.int);
    pragma Import (C, fl_native_file_chooser_set_type, "fl_native_file_chooser_set_type");
    pragma Inline (fl_native_file_chooser_set_type);

    function fl_native_file_chooser_get_options
           (F : in Storage.Integer_Address)
        return Interfaces.C.unsigned;
    pragma Import (C, fl_native_file_chooser_get_options, "fl_native_file_chooser_get_options");
    pragma Inline (fl_native_file_chooser_get_options);

    procedure fl_native_file_chooser_set_options
           (F : in Storage.Integer_Address;
            O : in Interfaces.C.unsigned);
    pragma Import (C, fl_native_file_chooser_set_options, "fl_native_file_chooser_set_options");
    pragma Inline (fl_native_file_chooser_set_options);

    function fl_native_file_chooser_get_title
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_get_title, "fl_native_file_chooser_get_title");
    pragma Inline (fl_native_file_chooser_get_title);

    procedure fl_native_file_chooser_set_title
           (F : in Storage.Integer_Address;
            T : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_native_file_chooser_set_title, "fl_native_file_chooser_set_title");
    pragma Inline (fl_native_file_chooser_set_title);




    --  Browsing  --

    function fl_native_file_chooser_get_directory
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_get_directory,
        "fl_native_file_chooser_get_directory");
    pragma Inline (fl_native_file_chooser_get_directory);

    procedure fl_native_file_chooser_set_directory
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_native_file_chooser_set_directory,
        "fl_native_file_chooser_set_directory");
    pragma Inline (fl_native_file_chooser_set_directory);

    function fl_native_file_chooser_get_filter
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_get_filter, "fl_native_file_chooser_get_filter");
    pragma Inline (fl_native_file_chooser_get_filter);

    procedure fl_native_file_chooser_set_filter
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_native_file_chooser_set_filter, "fl_native_file_chooser_set_filter");
    pragma Inline (fl_native_file_chooser_set_filter);

    function fl_native_file_chooser_filters
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_native_file_chooser_filters, "fl_native_file_chooser_filters");
    pragma Inline (fl_native_file_chooser_filters);

    function fl_native_file_chooser_get_filter_value
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_native_file_chooser_get_filter_value,
        "fl_native_file_chooser_get_filter_value");
    pragma Inline (fl_native_file_chooser_get_filter_value);

    procedure fl_native_file_chooser_set_filter_value
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.int);
    pragma Import (C, fl_native_file_chooser_set_filter_value,
        "fl_native_file_chooser_set_filter_value");
    pragma Inline (fl_native_file_chooser_set_filter_value);

    function fl_native_file_chooser_get_preset_file
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_get_preset_file,
        "fl_native_file_chooser_get_preset_file");
    pragma Inline (fl_native_file_chooser_get_preset_file);

    procedure fl_native_file_chooser_set_preset_file
           (F : in Storage.Integer_Address;
            V : in Interfaces.C.Strings.chars_ptr);
    pragma Import (C, fl_native_file_chooser_set_preset_file,
        "fl_native_file_chooser_set_preset_file");
    pragma Inline (fl_native_file_chooser_set_preset_file);




    --  Results  --

    function fl_native_file_chooser_count
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_native_file_chooser_count, "fl_native_file_chooser_count");
    pragma Inline (fl_native_file_chooser_count);

    function fl_native_file_chooser_filename
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_filename, "fl_native_file_chooser_filename");
    pragma Inline (fl_native_file_chooser_filename);

    function fl_native_file_chooser_filename2
           (F : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_filename2, "fl_native_file_chooser_filename2");
    pragma Inline (fl_native_file_chooser_filename2);

    function fl_native_file_chooser_errmsg
           (F : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_native_file_chooser_errmsg, "fl_native_file_chooser_errmsg");
    pragma Inline (fl_native_file_chooser_errmsg);




    --  Visibility  --

    function fl_native_file_chooser_show
           (F : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_native_file_chooser_show, "fl_native_file_chooser_show");
    pragma Inline (fl_native_file_chooser_show);




    ------------------------
    --  Internal Utility  --
    ------------------------

    function To_String
           (C_Ptr : in Interfaces.C.Strings.chars_ptr)
        return String is
    begin
        if C_Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (C_Ptr);
        end if;
    end To_String;


    --  FLTK copies the directory, filter and preset file strings, so a
    --  temporary is enough; an empty Ada string maps to NULL, i.e. unset.
    generic
        with procedure Setter
               (F : in Storage.Integer_Address;
                V : in Interfaces.C.Strings.chars_ptr);
    procedure Set_Copied_String
           (This  : in out Native_File_Chooser;
            Value : in     String);

    procedure Set_Copied_String
           (This  : in out Native_File_Chooser;
            Value : in     String)
    is
        use Interfaces.C;
        C_Arr : aliased char_array := To_C (Value);
    begin
        if Value = "" then
            Setter (This.Void_Ptr, Strings.Null_Ptr);
        else
            Setter (This.Void_Ptr, Strings.To_Chars_Ptr (C_Arr'Unchecked_Access));
        end if;
    end Set_Copied_String;




    -------------------
    --  Option Sets  --
    -------------------

    function "+"
           (Left, Right : in Chooser_Option)
        return Chooser_Option is
    begin
        return Left or Right;
    end "+";


    function "-"
           (Left, Right : in Chooser_Option)
        return Chooser_Option is
    begin
        return Left and not Right;
    end "-";


    function Includes
           (Options : in Chooser_Option;
            Item    : in Chooser_Option)
        return Boolean is
    begin
        return (Options and Item) = Item;
    end Includes;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Native_File_Chooser) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_native_file_chooser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
        Interfaces.C.Strings.Free (This.My_Title);
    end Finalize;


    procedure Finalize
           (This : in out Native_File_Chooser_Final_Controller) is
    begin
        Interfaces.C.Strings.Free (File_Exists_Message);
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Kind : in Chooser_Kind := Browse_File)
            return Native_File_Chooser is
        begin
            return This : Native_File_Chooser do
                This.Void_Ptr := new_fl_native_file_chooser (Chooser_Kind'Pos (Kind));
            end return;
        end Create;

    end Forge;




    -------------------------
    --  Static Attributes  --
    -------------------------

    --  Static Messages  --

    function Get_File_Exists_Message
        return String is
    begin
        return To_String (fl_native_file_chooser_get_file_exists_message);
    end Get_File_Exists_Message;


    procedure Set_File_Exists_Message
           (Value : in String)
    is
        Old : Interfaces.C.Strings.chars_ptr := File_Exists_Message;
    begin
        File_Exists_Message := Interfaces.C.Strings.New_String (Value);
        fl_native_file_chooser_set_file_exists_message (File_Exists_Message);
        Interfaces.C.Strings.Free (Old);
    end Set_File_Exists_Message;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Settings  --

    function Get_Kind
           (This : in Native_File_Chooser)
        return Chooser_Kind is
    begin
        return Chooser_Kind'Val (fl_native_file_chooser_get_type (This.Void_Ptr));
    end Get_Kind;


    procedure Set_Kind
           (This : in out Native_File_Chooser;
            Kind : in     Chooser_Kind) is
    begin
        fl_native_file_chooser_set_type (This.Void_Ptr, Chooser_Kind'Pos (Kind));
    end Set_Kind;


    function Get_Options
           (This : in Native_File_Chooser)
        return Chooser_Option is
    begin
        return Chooser_Option (fl_native_file_chooser_get_options (This.Void_Ptr));
    end Get_Options;


    procedure Set_Options
           (This    : in out Native_File_Chooser;
            Options : in     Chooser_Option) is
    begin
        fl_native_file_chooser_set_options (This.Void_Ptr, Interfaces.C.unsigned (Options));
    end Set_Options;


    function Get_Title
           (This : in Native_File_Chooser)
        return String is
    begin
        return To_String (fl_native_file_chooser_get_title (This.Void_Ptr));
    end Get_Title;


    --  Not every platform driver copies the title, so the Ada side keeps it
    procedure Set_Title
           (This : in out Native_File_Chooser;
            Text : in     String)
    is
        Old : Interfaces.C.Strings.chars_ptr := This.My_Title;
    begin
        if Text = "" then
            This.My_Title := Interfaces.C.Strings.Null_Ptr;
        else
            This.My_Title := Interfaces.C.Strings.New_String (Text);
        end if;
        fl_native_file_chooser_set_title (This.Void_Ptr, This.My_Title);
        Interfaces.C.Strings.Free (Old);
    end Set_Title;




    --  Browsing  --

    function Get_Directory
           (This : in Native_File_Chooser)
        return String is
    begin
        return To_String (fl_native_file_chooser_get_directory (This.Void_Ptr));
    end Get_Directory;


    procedure Set_Directory_Impl is new Set_Copied_String (fl_native_file_chooser_set_directory);

    procedure Set_Directory
           (This  : in out Native_File_Chooser;
            Value : in     String)
        renames Set_Directory_Impl;


    function Get_Filter
           (This : in Native_File_Chooser)
        return String is
    begin
        return To_String (fl_native_file_chooser_get_filter (This.Void_Ptr));
    end Get_Filter;


    procedure Set_Filter_Impl is new Set_Copied_String (fl_native_file_chooser_set_filter);

    procedure Set_Filter
           (This  : in out Native_File_Chooser;
            Value : in     String)
        renames Set_Filter_Impl;


    procedure Add_Filter
           (This    : in out Native_File_Chooser;
            Name    : in     String;
            Pattern : in     String)
    is
        function Has_Break
               (Text : in String)
            return Boolean is
        begin
            return (for some C of Text => C = ASCII.HT or C = ASCII.LF);
        end Has_Break;

        --  FLTK reads a line as a name and a pattern if a tab comes anywhere
        --  after the line's start, so a line with no name before one with a
        --  name is dropped (FLTK-issues.md F41).  So every line is given a
        --  name, the pattern if it has none.
        function Named
               (Lines : in String)
            return String
        is
            Stop : constant Natural := Ada.Strings.Fixed.Index (Lines, (1 => ASCII.LF));
            Line : constant String :=
                (if Stop = 0 then Lines else Lines (Lines'First .. Stop - 1));
            Rest : constant String :=
                (if Stop = 0 then "" else ASCII.LF & Named (Lines (Stop + 1 .. Lines'Last)));
        begin
            if Line = "" or else Ada.Strings.Fixed.Index (Line, (1 => ASCII.HT)) /= 0 then
                return Line & Rest;
            else
                return Line & ASCII.HT & Line & Rest;
            end if;
        end Named;

        Old : constant String := This.Get_Filter;
    begin
        if Has_Break (Name) or Has_Break (Pattern) then
            raise Constraint_Error with "a filter's name or pattern holds a tab or a line feed";
        end if;
        This.Set_Filter
           ((if Old = "" then "" else Named (Old) & ASCII.LF) &
            (if Name = "" then Pattern else Name) & ASCII.HT & Pattern);
    end Add_Filter;


    function Filter_Count
           (This : in Native_File_Chooser)
        return Natural is
    begin
        return Natural (fl_native_file_chooser_filters (This.Void_Ptr));
    end Filter_Count;


    function Get_Filter_Index
           (This : in Native_File_Chooser)
        return Positive is
    begin
        return Positive (fl_native_file_chooser_get_filter_value (This.Void_Ptr) + 1);
    end Get_Filter_Index;


    procedure Set_Filter_Index
           (This  : in out Native_File_Chooser;
            Value : in     Positive) is
    begin
        fl_native_file_chooser_set_filter_value (This.Void_Ptr, Interfaces.C.int (Value) - 1);
    end Set_Filter_Index;


    function Get_Preset_File
           (This : in Native_File_Chooser)
        return String is
    begin
        return To_String (fl_native_file_chooser_get_preset_file (This.Void_Ptr));
    end Get_Preset_File;


    procedure Set_Preset_File_Impl is new Set_Copied_String
        (fl_native_file_chooser_set_preset_file);

    procedure Set_Preset_File
           (This  : in out Native_File_Chooser;
            Value : in     String)
        renames Set_Preset_File_Impl;




    --  Results  --

    function Number_Selected
           (This : in Native_File_Chooser)
        return Natural is
    begin
        return Natural (fl_native_file_chooser_count (This.Void_Ptr));
    end Number_Selected;


    function Get_Filename
           (This : in Native_File_Chooser)
        return String is
    begin
        return To_String (fl_native_file_chooser_filename (This.Void_Ptr));
    end Get_Filename;


    function Get_Filename
           (This  : in Native_File_Chooser;
            Index : in Positive)
        return String is
    begin
        return To_String
            (fl_native_file_chooser_filename2 (This.Void_Ptr, Interfaces.C.int (Index) - 1));
    end Get_Filename;


    function Get_Error_Message
           (This : in Native_File_Chooser)
        return String is
    begin
        return To_String (fl_native_file_chooser_errmsg (This.Void_Ptr));
    end Get_Error_Message;




    --  Visibility  --

    function Show
           (This : in out Native_File_Chooser)
        return Show_Result
    is
        Result : constant Interfaces.C.int := fl_native_file_chooser_show (This.Void_Ptr);
    begin
        Hook_Exceptions.Reraise;
        case Result is
            when -1     => return Error;
            when 1      => return Cancelled;
            when others => return Picked;
        end case;
    end Show;


end FLTK.Native_File_Choosers;


