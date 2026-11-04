

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Ada.Containers.Ordered_Maps,
    Ada.Finalization,
    Ada.Unchecked_Deallocation,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;


package body FLTK.Images.File_Icons is


    package ICS renames Interfaces.C.Strings;


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_file_icon
           (P : in Interfaces.C.char_array;
            T : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_file_icon, "new_fl_file_icon");
    pragma Inline (new_fl_file_icon);

    procedure free_fl_file_icon
           (I : in Storage.Integer_Address);
    pragma Import (C, free_fl_file_icon, "free_fl_file_icon");
    pragma Inline (free_fl_file_icon);




    procedure fl_file_icon_add
           (I : in Storage.Integer_Address;
            D : in Interfaces.C.int);
    pragma Import (C, fl_file_icon_add, "fl_file_icon_add");
    pragma Inline (fl_file_icon_add);

    procedure fl_file_icon_add_color
           (I : in Storage.Integer_Address;
            C : in Interfaces.C.unsigned);
    pragma Import (C, fl_file_icon_add_color, "fl_file_icon_add_color");
    pragma Inline (fl_file_icon_add_color);

    procedure fl_file_icon_add_vertex
           (I    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_file_icon_add_vertex, "fl_file_icon_add_vertex");
    pragma Inline (fl_file_icon_add_vertex);

    procedure fl_file_icon_clear
           (I : in Storage.Integer_Address);
    pragma Import (C, fl_file_icon_clear, "fl_file_icon_clear");
    pragma Inline (fl_file_icon_clear);

    function fl_file_icon_size
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_icon_size, "fl_file_icon_size");
    pragma Inline (fl_file_icon_size);




    function fl_file_icon_load
           (I : in Storage.Integer_Address;
            F : in Interfaces.C.char_array)
        return Interfaces.C.int;
    pragma Import (C, fl_file_icon_load, "fl_file_icon_load");
    pragma Inline (fl_file_icon_load);

    procedure fl_file_icon_load_system_icons;
    pragma Import (C, fl_file_icon_load_system_icons, "fl_file_icon_load_system_icons");
    pragma Inline (fl_file_icon_load_system_icons);




    function fl_file_icon_find
           (N : in Interfaces.C.char_array;
            T : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_icon_find, "fl_file_icon_find");
    pragma Inline (fl_file_icon_find);

    function fl_file_icon_first
        return Storage.Integer_Address;
    pragma Import (C, fl_file_icon_first, "fl_file_icon_first");
    pragma Inline (fl_file_icon_first);

    function fl_file_icon_next
           (I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_icon_next, "fl_file_icon_next");
    pragma Inline (fl_file_icon_next);

    function fl_file_icon_pattern
           (I : in Storage.Integer_Address)
        return ICS.chars_ptr;
    pragma Import (C, fl_file_icon_pattern, "fl_file_icon_pattern");
    pragma Inline (fl_file_icon_pattern);

    function fl_file_icon_type
           (I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_file_icon_type, "fl_file_icon_type");
    pragma Inline (fl_file_icon_type);




    procedure fl_file_icon_draw
           (I          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int;
            C          : in Interfaces.C.unsigned;
            A          : in Interfaces.C.int);
    pragma Import (C, fl_file_icon_draw, "fl_file_icon_draw");
    pragma Inline (fl_file_icon_draw);

    procedure fl_file_icon_label
           (I, W : in Storage.Integer_Address);
    pragma Import (C, fl_file_icon_label, "fl_file_icon_label");
    pragma Inline (fl_file_icon_label);


    procedure fl_file_icon_browser_add
           (B : in Storage.Integer_Address;
            T : in Interfaces.C.char_array;
            I : in Storage.Integer_Address);
    pragma Import (C, fl_file_icon_browser_add, "fl_file_icon_browser_add");
    pragma Inline (fl_file_icon_browser_add);

    procedure fl_file_icon_browser_set
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int;
            I : in Storage.Integer_Address);
    pragma Import (C, fl_file_icon_browser_set, "fl_file_icon_browser_set");
    pragma Inline (fl_file_icon_browser_set);

    function fl_file_icon_browser_get
           (B : in Storage.Integer_Address;
            L : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_file_icon_browser_get, "fl_file_icon_browser_get");
    pragma Inline (fl_file_icon_browser_get);




    ----------------------
    --  FLTK's Icons    --
    ----------------------

    --  Fl_File_Icon's opcodes (Fl_File_Icon.H).
    Code_End            : constant Interfaces.C.int := 0;
    Code_Line           : constant Interfaces.C.int := 2;
    Code_Closed_Line    : constant Interfaces.C.int := 3;
    Code_Polygon        : constant Interfaces.C.int := 4;
    Code_Outline_Polygon : constant Interfaces.C.int := 5;


    package Address_Maps is new Ada.Containers.Ordered_Maps
       (Key_Type     => Storage.Integer_Address,
        Element_Type => File_Icon_Access,
        "<"          => Storage."<");

    --  The Ada object of each icon on FLTK's list that has one:  those made
    --  by Forge.Create, and those made here for FLTK's own icons, which
    --  don't own their icons and last until the program ends.
    Known : Address_Maps.Map;


    procedure Free is new Ada.Unchecked_Deallocation (File_Icon'Class, File_Icon_Access);


    type Cleanup is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out Cleanup);

    overriding procedure Finalize
           (This : in out Cleanup)
    is
        pragma Unreferenced (This);
        Item : File_Icon_Access;
    begin
        for Place in Known.Iterate loop
            Item := Address_Maps.Element (Place);
            if not Item.Needs_Dealloc then
                Free (Item);
            end if;
        end loop;
        Known.Clear;
    end Finalize;

    Cleaner : Cleanup;
    pragma Unreferenced (Cleaner);


    --  The Ada object of FLTK's icon at Ptr.
    function Object
           (Ptr : in Storage.Integer_Address)
        return not null File_Icon_Access
    is
        Place : constant Address_Maps.Cursor := Known.Find (Ptr);
        Made  : File_Icon_Access;
    begin
        if Address_Maps.Has_Element (Place) then
            return Address_Maps.Element (Place);
        end if;
        Made := new File_Icon;
        Made.Void_Ptr := Ptr;
        Made.Needs_Dealloc := False;
        Known.Insert (Ptr, Made);
        return Made;
    end Object;


    procedure Register
           (This : in out File_Icon'Class) is
    begin
        Known.Insert (This.Void_Ptr, This'Unchecked_Access);
    end Register;




    -------------------
    --  Destructors  --
    -------------------

    overriding procedure Finalize
           (This : in out File_Icon) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            Known.Exclude (This.Void_Ptr);
            free_fl_file_icon (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Pattern : in String;
                Kind    : in File_Kind := Any_File)
            return File_Icon is
        begin
            return This : File_Icon do
                This.Void_Ptr := new_fl_file_icon
                   (Interfaces.C.To_C (Pattern), File_Kind'Pos (Kind));
                if This.Void_Ptr = Null_Pointer then
                    raise Storage_Error with "Fl_File_Icon allocation failed";
                end if;
                Register (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Contents  --

    procedure Add_Color
           (This  : in out File_Icon;
            Value : in     Color) is
    begin
        fl_file_icon_add_color (This.Void_Ptr, Interfaces.C.unsigned (Value));
    end Add_Color;


    procedure Add_Part
           (This   : in out File_Icon;
            Code   : in     Interfaces.C.int;
            Points : in     Vertex_Array) is
    begin
        fl_file_icon_add (This.Void_Ptr, Code);
        for Point of Points loop
            fl_file_icon_add_vertex
               (This.Void_Ptr, Interfaces.C.int (Point.X), Interfaces.C.int (Point.Y));
        end loop;
        fl_file_icon_add (This.Void_Ptr, Code_End);
    end Add_Part;


    procedure Add_Line
           (This   : in out File_Icon;
            Points : in     Vertex_Array) is
    begin
        Add_Part (This, Code_Line, Points);
    end Add_Line;


    procedure Add_Closed_Line
           (This   : in out File_Icon;
            Points : in     Vertex_Array) is
    begin
        Add_Part (This, Code_Closed_Line, Points);
    end Add_Closed_Line;


    procedure Add_Polygon
           (This   : in out File_Icon;
            Points : in     Vertex_Array) is
    begin
        Add_Part (This, Code_Polygon, Points);
    end Add_Polygon;


    --  OUTLINEPOLYGON is followed by the outline color's two halves, as
    --  COLOR is (Fl_File_Icon.H, add_color).
    procedure Add_Outline_Polygon
           (This    : in out File_Icon;
            Outline : in     Color;
            Points  : in     Vertex_Array) is
    begin
        fl_file_icon_add (This.Void_Ptr, Code_Outline_Polygon);
        fl_file_icon_add (This.Void_Ptr, Interfaces.C.int (Outline / 16#1_0000#));
        fl_file_icon_add (This.Void_Ptr, Interfaces.C.int (Outline mod 16#1_0000#));
        for Point of Points loop
            fl_file_icon_add_vertex
               (This.Void_Ptr, Interfaces.C.int (Point.X), Interfaces.C.int (Point.Y));
        end loop;
        fl_file_icon_add (This.Void_Ptr, Code_End);
    end Add_Outline_Polygon;


    procedure Clear
           (This : in out File_Icon) is
    begin
        fl_file_icon_clear (This.Void_Ptr);
    end Clear;


    function Size
           (This : in File_Icon)
        return Natural is
    begin
        return Natural (fl_file_icon_size (This.Void_Ptr));
    end Size;


    procedure Load
           (This : in out File_Icon;
            Name : in     String)
    is
        Result : constant Interfaces.C.int :=
            fl_file_icon_load (This.Void_Ptr, Interfaces.C.To_C (Name));
    begin
        Hook_Exceptions.Reraise;
        case Result is
        when 0 =>
            null;
        when 1 =>
            raise File_Access_Error with "cannot read " & Name;
        when others =>
            raise Format_Error with Name & " is not a picture a file icon can show";
        end case;
    end Load;




    --  Attributes  --

    function Get_Pattern
           (This : in File_Icon)
        return String
    is
        Result : constant ICS.chars_ptr := fl_file_icon_pattern (This.Void_Ptr);
    begin
        if ICS."=" (Result, ICS.Null_Ptr) then
            return "";
        end if;
        return ICS.Value (Result);
    end Get_Pattern;


    function Get_Kind
           (This : in File_Icon)
        return File_Kind
    is
        Result : constant Interfaces.C.int := fl_file_icon_type (This.Void_Ptr);
    begin
        if Result not in File_Kind'Pos (File_Kind'First) .. File_Kind'Pos (File_Kind'Last) then
            raise Internal_FLTK_Error with
                "Fl_File_Icon::type returned unexpected value of " &
                Interfaces.C.int'Image (Result);
        end if;
        return File_Kind'Val (Result);
    end Get_Kind;




    --  Drawing  --

    procedure Draw
           (This       : in out File_Icon;
            X, Y, W, H : in     Integer;
            Tint       : in     Color;
            Active     : in     Boolean := True) is
    begin
        fl_file_icon_draw
           (This.Void_Ptr,
            Interfaces.C.int (X), Interfaces.C.int (Y),
            Interfaces.C.int (W), Interfaces.C.int (H),
            Interfaces.C.unsigned (Tint),
            Boolean'Pos (Active));
    end Draw;


    procedure Set_Icon_Label
           (Item : in out FLTK.Widgets.Widget'Class;
            Icon : in out File_Icon'Class) is
    begin
        fl_file_icon_label (Icon.Void_Ptr, Wrapper (Item).Void_Ptr);
    end Set_Icon_Label;




    --  File Browsers  --

    function Handle
           (Icon : in File_Icon_Access)
        return Storage.Integer_Address is
    begin
        if Icon = null then
            return Null_Pointer;
        else
            return Icon.Void_Ptr;
        end if;
    end Handle;


    procedure Check_Line
           (Browser : in FLTK.Widgets.Groups.Browsers.Textline.File.File_Browser'Class;
            Line    : in Positive) is
    begin
        if Line > Browser.Number_Of_Lines then
            raise Constraint_Error with "line" & Positive'Image (Line) & " is past the last, " &
                Natural'Image (Browser.Number_Of_Lines);
        end if;
    end Check_Line;


    procedure Add_File
           (Browser : in out FLTK.Widgets.Groups.Browsers.Textline.File.File_Browser'Class;
            Text    : in     String;
            Icon    : in     File_Icon_Access) is
    begin
        fl_file_icon_browser_add
           (Wrapper (Browser).Void_Ptr,
            Interfaces.C.To_C (Text),
            Handle (Icon));
    end Add_File;


    procedure Set_File_Icon
           (Browser : in out FLTK.Widgets.Groups.Browsers.Textline.File.File_Browser'Class;
            Line    : in     Positive;
            Icon    : in     File_Icon_Access) is
    begin
        Check_Line (Browser, Line);
        fl_file_icon_browser_set
           (Wrapper (Browser).Void_Ptr,
            Interfaces.C.int (Line),
            Handle (Icon));
    end Set_File_Icon;


    function Get_File_Icon
           (Browser : in FLTK.Widgets.Groups.Browsers.Textline.File.File_Browser'Class;
            Line    : in Positive)
        return File_Icon_Access
    is
        Ptr : Storage.Integer_Address;
    begin
        Check_Line (Browser, Line);
        Ptr := fl_file_icon_browser_get (Wrapper (Browser).Void_Ptr, Interfaces.C.int (Line));
        if Ptr = Null_Pointer then
            return null;
        else
            return Object (Ptr);
        end if;
    end Get_File_Icon;




    --  FLTK's List  --

    procedure Load_System_Icons is
    begin
        fl_file_icon_load_system_icons;
        Hook_Exceptions.Reraise;
    end Load_System_Icons;


    function Find
           (Name : in String;
            Kind : in File_Kind := Any_File)
        return File_Icon_Access
    is
        Result : constant Storage.Integer_Address :=
            fl_file_icon_find (Interfaces.C.To_C (Name), File_Kind'Pos (Kind));
    begin
        if Result = Null_Pointer then
            return null;
        end if;
        return Object (Result);
    end Find;


    --  The icons from Ptr to the end of the list.
    function From
           (Ptr : in Storage.Integer_Address)
        return File_Icon_Array
    is
        None : File_Icon_Array (1 .. 0);
    begin
        if Ptr = Null_Pointer then
            return None;
        end if;
        return Object (Ptr) & From (fl_file_icon_next (Ptr));
    end From;


    function Icons
        return File_Icon_Array is
    begin
        return From (fl_file_icon_first);
    end Icons;


end FLTK.Images.File_Icons;


