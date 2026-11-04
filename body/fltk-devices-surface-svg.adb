

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Devices.Surface.SVG is


    ------------------------
    --  Functions From C  --
    ------------------------

    function fl_svg_file_surface_supported
        return Interfaces.C.int;
    pragma Import (C, fl_svg_file_surface_supported, "fl_svg_file_surface_supported");
    pragma Inline (fl_svg_file_surface_supported);

    function fl_file_sink_message
           (E : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_file_sink_message, "fl_file_sink_message");
    pragma Inline (fl_file_sink_message);




    --  Allocation  --

    function new_fl_svg_file_surface
           (N    : in     Interfaces.C.char_array;
            W, H : in     Interfaces.C.int;
            E    :    out Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_svg_file_surface, "new_fl_svg_file_surface");
    pragma Inline (new_fl_svg_file_surface);

    procedure free_fl_svg_file_surface
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_svg_file_surface, "free_fl_svg_file_surface");
    pragma Inline (free_fl_svg_file_surface);




    --  Completion  --

    function fl_svg_file_surface_finish
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_svg_file_surface_finish, "fl_svg_file_surface_finish");
    pragma Inline (fl_svg_file_surface_finish);




    --  Dimensions  --

    procedure fl_svg_file_surface_printable_rect
           (S    : in     Storage.Integer_Address;
            W, H :    out Interfaces.C.int);
    pragma Import (C, fl_svg_file_surface_printable_rect,
        "fl_svg_file_surface_printable_rect");
    pragma Inline (fl_svg_file_surface_printable_rect);

    procedure fl_svg_file_surface_get_origin
           (S    : in     Storage.Integer_Address;
            X, Y :    out Interfaces.C.int);
    pragma Import (C, fl_svg_file_surface_get_origin, "fl_svg_file_surface_get_origin");
    pragma Inline (fl_svg_file_surface_get_origin);

    procedure fl_svg_file_surface_set_origin
           (S    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_svg_file_surface_set_origin, "fl_svg_file_surface_set_origin");
    pragma Inline (fl_svg_file_surface_set_origin);

    procedure fl_svg_file_surface_translate
           (S    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int);
    pragma Import (C, fl_svg_file_surface_translate, "fl_svg_file_surface_translate");
    pragma Inline (fl_svg_file_surface_translate);

    procedure fl_svg_file_surface_untranslate
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_svg_file_surface_untranslate, "fl_svg_file_surface_untranslate");
    pragma Inline (fl_svg_file_surface_untranslate);




    --  Drawing  --

    procedure fl_svg_file_surface_draw
           (S, W   : in Storage.Integer_Address;
            DX, DY : in Interfaces.C.int);
    pragma Import (C, fl_svg_file_surface_draw, "fl_svg_file_surface_draw");
    pragma Inline (fl_svg_file_surface_draw);

    procedure fl_svg_file_surface_draw_decorated_window
           (S, W   : in Storage.Integer_Address;
            DX, DY : in Interfaces.C.int);
    pragma Import (C, fl_svg_file_surface_draw_decorated_window,
        "fl_svg_file_surface_draw_decorated_window");
    pragma Inline (fl_svg_file_surface_draw_decorated_window);

    procedure fl_svg_file_surface_print_window_part
           (S, W           : in Storage.Integer_Address;
            X, Y, WD, HT   : in Interfaces.C.int;
            DX, DY         : in Interfaces.C.int);
    pragma Import (C, fl_svg_file_surface_print_window_part,
        "fl_svg_file_surface_print_window_part");
    pragma Inline (fl_svg_file_surface_print_window_part);




    --  Surfaces  --

    procedure fl_svg_file_surface_set_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_svg_file_surface_set_current, "fl_svg_file_surface_set_current");
    pragma Inline (fl_svg_file_surface_set_current);




    -------------------
    --  Destructors  --
    -------------------

    --  The shim's destructor finishes the file, if Finish hasn't.
    procedure Finalize
           (This : in out SVG_File_Surface) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if Release_Current (This) then
                free_fl_svg_file_surface (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Name : in String;
                W, H : in Positive)
            return SVG_File_Surface
        is
            Error : Interfaces.C.int := 0;
        begin
            if not Is_Supported then
                raise Unsupported_Error with "this FLTK was built without SVG";
            end if;
            return This : SVG_File_Surface do
                This.Void_Ptr := new_fl_svg_file_surface
                   (Interfaces.C.To_C (Name),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Error);
                if This.Void_Ptr = Null_Pointer then
                    raise File_Open_Error with Name & ": " &
                        Interfaces.C.Strings.Value (fl_file_sink_message (Error));
                end if;
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Is_Supported
        return Boolean is
    begin
        return fl_svg_file_surface_supported /= 0;
    end Is_Supported;


    procedure Check_Drawable
           (This : in SVG_File_Surface) is
    begin
        if This.Finished then
            raise Program_Error with "the SVG surface is finished";
        end if;
    end Check_Drawable;




    --  Completion  --

    procedure Finish
           (This : in out SVG_File_Surface)
    is
        Result : Interfaces.C.int;
    begin
        if This.Finished then
            return;
        end if;
        if Is_Remembered (This) then
            raise Program_Error with "Finish of an SVG surface that is current or pushed";
        end if;
        while This.Shifts > 0 loop
            This.Untranslate;
        end loop;
        This.Finished := True;
        Result := fl_svg_file_surface_finish (This.Void_Ptr);
        if Result /= 0 then
            raise File_Write_Error with "the SVG couldn't all be written";
        end if;
    end Finish;


    function Is_Finished
           (This : in SVG_File_Surface)
        return Boolean is
    begin
        return This.Finished;
    end Is_Finished;




    --  Dimensions  --

    procedure Get_Printable_Rect
           (This : in     SVG_File_Surface;
            W, H :    out Integer)
    is
        C_W, C_H : Interfaces.C.int;
    begin
        This.Check_Drawable;
        fl_svg_file_surface_printable_rect (This.Void_Ptr, C_W, C_H);
        W := Integer (C_W);
        H := Integer (C_H);
    end Get_Printable_Rect;


    procedure Get_Origin
           (This : in     SVG_File_Surface;
            X, Y :    out Integer)
    is
        C_X, C_Y : Interfaces.C.int;
    begin
        This.Check_Drawable;
        fl_svg_file_surface_get_origin (This.Void_Ptr, C_X, C_Y);
        X := Integer (C_X);
        Y := Integer (C_Y);
    end Get_Origin;


    procedure Set_Origin
           (This : in out SVG_File_Surface;
            X, Y : in     Integer) is
    begin
        This.Check_Drawable;
        fl_svg_file_surface_set_origin
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y));
    end Set_Origin;


    procedure Translate
           (This             : in out SVG_File_Surface;
            Delta_X, Delta_Y : in     Integer) is
    begin
        This.Check_Drawable;
        This.Shifts := This.Shifts + 1;
        fl_svg_file_surface_translate
           (This.Void_Ptr,
            Interfaces.C.int (Delta_X),
            Interfaces.C.int (Delta_Y));
    end Translate;


    procedure Untranslate
           (This : in out SVG_File_Surface) is
    begin
        This.Check_Drawable;
        if This.Shifts = 0 then
            raise Constraint_Error with "Untranslate with no Translate to undo";
        end if;
        This.Shifts := This.Shifts - 1;
        fl_svg_file_surface_untranslate (This.Void_Ptr);
    end Untranslate;




    --  Drawing  --

    procedure Draw_Widget
           (This               : in out SVG_File_Surface;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        This.Check_Drawable;
        fl_svg_file_surface_draw
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Draw_Widget;


    procedure Draw_Decorated_Window
           (This               : in out SVG_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        This.Check_Drawable;
        fl_svg_file_surface_draw_decorated_window
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Draw_Decorated_Window;


    procedure Print_Window_Part
           (This               : in out SVG_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0) is
    begin
        This.Check_Drawable;
        fl_svg_file_surface_print_window_part
           (This.Void_Ptr,
            Wrapper (Item).Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Offset_X),
            Interfaces.C.int (Offset_Y));
    end Print_Window_Part;




    --  Surfaces  --

    procedure Set_Current
           (This : in out SVG_File_Surface) is
    begin
        This.Check_Drawable;
        fl_svg_file_surface_set_current (This.Void_Ptr);
        This.Set_Current_Bookkeep;
    end Set_Current;


end FLTK.Devices.Surface.SVG;


