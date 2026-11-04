

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups.Windows;


package FLTK.Devices.Surface.SVG is


    --  A surface that writes what is drawn on it to a file as SVG, one
    --  picture of a fixed size (Fl_SVG_File_Surface).  Finish completes the
    --  file; finalizing an unfinished surface finishes it, quietly.
    type SVG_File_Surface is new Surface_Device with private;

    type SVG_File_Surface_Reference (Data : not null access SVG_File_Surface'Class) is
        limited null record with Implicit_Dereference => Data;


    --  The file couldn't be opened.
    File_Open_Error : exception;

    --  The SVG couldn't all be written.
    File_Write_Error : exception;


    --  Whether this FLTK can write SVG: one built without FLTK_USE_SVG
    --  can't (Fl_SVG_File_Surface.cxx:1003-1013).
    function Is_Supported
        return Boolean;




    package Forge is

        --  A surface W by H that writes file Name.  Raises
        --  File_Open_Error, with the system's reason, if Name can't be
        --  opened, and Unsupported_Error unless Is_Supported.  The picture
        --  is scaled by the scale of the screen the first window is on, or
        --  1 if there is no window (Fl_SVG_File_Surface.cxx:346-347).
        function Create
               (Name : in String;
                W, H : in Positive)
            return SVG_File_Surface;

    end Forge;




    --  Completion  --

    --  Undoes any Translate not yet undone, which FLTK's close() would
    --  leave unclosed in the SVG (FLTK-issues.md F18), then completes and
    --  closes the file.  Raises File_Write_Error if the SVG couldn't all be
    --  written, and Program_Error while the surface is current or
    --  remembered by Push_Current.  After it, Set_Current, Push_Current
    --  and everything below but Is_Finished raise Program_Error: FLTK has
    --  deleted what draws (Fl_SVG_File_Surface.cxx:373-374), and making
    --  the surface current would use it (Fl_Device.cxx:91-98).  A second
    --  Finish does nothing.
    procedure Finish
           (This : in out SVG_File_Surface);

    function Is_Finished
           (This : in SVG_File_Surface)
        return Boolean;




    --  Dimensions  --

    procedure Get_Printable_Rect
           (This : in     SVG_File_Surface;
            W, H :    out Integer);

    procedure Get_Origin
           (This : in     SVG_File_Surface;
            X, Y :    out Integer);

    procedure Set_Origin
           (This : in out SVG_File_Surface;
            X, Y : in     Integer);

    procedure Translate
           (This             : in out SVG_File_Surface;
            Delta_X, Delta_Y : in     Integer);

    --  Raises Constraint_Error unless there is a Translate it hasn't
    --  undone: it would close a group of the SVG that FLTK's close()
    --  closes.
    procedure Untranslate
           (This : in out SVG_File_Surface);




    --  Drawing  --

    --  Each draws the item at the origin, plus Offset_X and Offset_Y.
    --  FLTK draws only what is visible (pofltk 103).

    procedure Draw_Widget
           (This               : in out SVG_File_Surface;
            Item               : in     FLTK.Widgets.Widget'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    procedure Draw_Decorated_Window
           (This               : in out SVG_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            Offset_X, Offset_Y : in     Integer := 0);

    --  The part X, Y, W, H of Item.
    procedure Print_Window_Part
           (This               : in out SVG_File_Surface;
            Item               : in     FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y, W, H         : in     Integer;
            Offset_X, Offset_Y : in     Integer := 0);




    --  Surfaces  --

    procedure Set_Current
           (This : in out SVG_File_Surface);


private


    type SVG_File_Surface is new Surface_Device with record
        Finished : Boolean := False;
        Shifts   : Natural := 0;
    end record;

    overriding procedure Finalize
           (This : in out SVG_File_Surface);

    overriding procedure Check_Drawable
           (This : in SVG_File_Surface);


    pragma Inline (Is_Finished);
    pragma Inline (Get_Printable_Rect);
    pragma Inline (Get_Origin);


end FLTK.Devices.Surface.SVG;


