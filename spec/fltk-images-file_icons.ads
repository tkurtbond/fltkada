

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups.Browsers.Textline.File;


package FLTK.Images.File_Icons is


    --  A small picture of a kind of file, for file browsers and labels:
    --  colors, lines and polygons on a grid 10_000 by 10_000, its origin
    --  at the lower left.  Each icon is put on FLTK's list of icons, which
    --  Find searches, for files whose names match its pattern.
    --
    --  It is not an Image.  A widget or a file browser showing an icon
    --  doesn't copy it, so the icon must last as long as they do.
    type File_Icon is new Wrapper with private;

    type File_Icon_Access is access all File_Icon'Class;

    --  None of its elements is null.
    type File_Icon_Array is array (Positive range <>) of File_Icon_Access;


    --  What kind of file an icon is for.  Any_File is any kind.
    type File_Kind is
       (Any_File,
        Plain_File,
        Fifo_File,
        Device_File,
        Link_File,
        Directory_File);


    subtype Coordinate is Integer range 0 .. 10_000;

    type Vertex is record
        X, Y : Coordinate;
    end record;

    type Vertex_Array is array (Positive range <>) of Vertex;


    --  As a color in an icon, the color the icon is drawn in.
    Icon_Color : constant Color := 16#FFFF_FFFF#;




    package Forge is

        --  An empty icon for files of kind Kind whose names match
        --  Pattern, as FLTK.Filenames.Match matches them.  It goes first
        --  on FLTK's list, so Find finds it before any made earlier.
        function Create
               (Pattern : in String;
                Kind    : in File_Kind := Any_File)
            return File_Icon;

    end Forge;




    --  Contents  --

    --  Each adds one whole part, so an icon is never left with a part that
    --  FLTK would read past.

    --  The parts after this are drawn in Value.
    procedure Add_Color
           (This  : in out File_Icon;
            Value : in     Color);

    procedure Add_Line
           (This   : in out File_Icon;
            Points : in     Vertex_Array);

    procedure Add_Closed_Line
           (This   : in out File_Icon;
            Points : in     Vertex_Array);

    procedure Add_Polygon
           (This   : in out File_Icon;
            Points : in     Vertex_Array);

    --  A polygon in the current color, outlined in Outline.
    procedure Add_Outline_Polygon
           (This    : in out File_Icon;
            Outline : in     Color;
            Points  : in     Vertex_Array);

    procedure Clear
           (This : in out File_Icon);

    --  How many values the icon's data has, 0 for an empty icon.
    function Size
           (This : in File_Icon)
        return Natural;

    --  Adds the picture in file Name: an SGI .fti, or an image of any kind
    --  FLTK.Images.Shared reads but a bitmap, drawn as a polygon for each
    --  run of one color in a row, its pixels of alpha 127 or under left
    --  out.  Raises File_Access_Error if Name can't be read, and
    --  Format_Error if it isn't a picture an icon can show; a bad .fti
    --  leaves the icon empty (pofltk 86).
    procedure Load
           (This : in out File_Icon;
            Name : in     String);




    --  Attributes  --

    function Get_Pattern
           (This : in File_Icon)
        return String;

    function Get_Kind
           (This : in File_Icon)
        return File_Kind;




    --  Drawing  --

    --  Draws the icon, scaled to the larger square that fits, centred in
    --  X, Y, W, H, with Tint for Icon_Color.
    procedure Draw
           (This       : in out File_Icon;
            X, Y, W, H : in     Integer;
            Tint       : in     Color;
            Active     : in     Boolean := True);

    --  Item shows Icon as its label, an Icon_Label in the label color.
    --  Set_Label replaces it with text, as a Normal_Label; Get_Label is ""
    --  meanwhile, and Set_Label_Kind changes nothing (pofltk 85).
    procedure Set_Icon_Label
           (Item : in out FLTK.Widgets.Widget'Class;
            Icon : in out File_Icon'Class);




    --  File Browsers  --

    --  Fl_File_Browser shows each line's icon, if any, when FLTK's list
    --  has at least one icon (Fl_File_Browser.cxx:264).

    --  Adds a line of Text to Browser, showing Icon, or none if Icon is
    --  null.
    procedure Add_File
           (Browser : in out FLTK.Widgets.Groups.Browsers.Textline.File.File_Browser'Class;
            Text    : in     String;
            Icon    : in     File_Icon_Access);

    --  Line of Browser shows Icon, or none if Icon is null, in place of
    --  the icon it had.  Raises Constraint_Error for a line past the last.
    procedure Set_File_Icon
           (Browser : in out FLTK.Widgets.Groups.Browsers.Textline.File.File_Browser'Class;
            Line    : in     Positive;
            Icon    : in     File_Icon_Access);

    --  The icon Line of Browser shows, null if none.  Raises
    --  Constraint_Error for a line past the last.
    function Get_File_Icon
           (Browser : in FLTK.Widgets.Groups.Browsers.Textline.File.File_Browser'Class;
            Line    : in Positive)
        return File_Icon_Access;




    --  FLTK's List  --

    --  Adds icons for the system's kinds of files, once:  KDE's, CDE's or
    --  IRIX's, the first FLTK finds, or else pictures of its own
    --  (Fl_File_Icon2.cxx:649-760).  FLTK keeps them for the program's
    --  life.
    procedure Load_System_Icons;

    --  The first icon on the list for file Name of kind Kind, as FLTK
    --  matches Name with the icons' patterns; null if there is none.
    --  Name's own kind is found from the file system for Any_File.
    function Find
           (Name : in String;
            Kind : in File_Kind := Any_File)
        return File_Icon_Access;

    --  The icons on the list, in its order, both those made here and
    --  FLTK's own.
    function Icons
        return File_Icon_Array;


private


    type File_Icon is new Wrapper with null record;

    overriding procedure Finalize
           (This : in out File_Icon);


    pragma Inline (Add_Color);
    pragma Inline (Clear);
    pragma Inline (Size);
    pragma Inline (Draw);


end FLTK.Images.File_Icons;


