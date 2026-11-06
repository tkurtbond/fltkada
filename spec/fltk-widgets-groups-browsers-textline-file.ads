

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Filenames;

private with

    Interfaces.C.Strings;


package FLTK.Widgets.Groups.Browsers.Textline.File is


    --  Due to the inherited methods being made private in C++, overriding
    --
    --      Item_Width
    --      Item_Height
    --      Item_Draw
    --      Full_List_Height
    --      Average_Item_Height
    --
    --  will have no effect on the behaviour of this widget in FLTK.
    --
    --  This may change in versions beyond 1.3.


    type File_Browser is new Textline_Browser with private;

    type File_Browser_Reference (Data : not null access File_Browser'Class) is
        limited null record with Implicit_Dereference => Data;

    type File_Kind is (Files, Directories);

    type Icon_Size is mod 256;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return File_Browser;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return File_Browser;

    end Forge;




    --  Directory  --

    --  Returns the number of the directory's entries, counting ./ and the
    --  files the filter hides, not the number of lines listed; that is
    --  Number_Of_Lines (Fl_File_Browser.cxx:442-474, pofltk 40).  Load ("")
    --  lists the mount points.
    function Load
           (This : in out File_Browser;
            Dir  : in     String;
            Sort : in not null FLTK.Filenames.Compare_Function :=
                FLTK.Filenames.Numeric_Sort'Access)
        return Natural;

    --  Lists a directory with Numeric_Sort, as Fl_File_Browser::load hides
    --  Fl_Browser::load, instead of reading a text file as a
    --  Textline_Browser's Load does; through Textline_Browser'Class too
    --  (FLTKAda-BUGS.md 108).
    overriding procedure Load
           (This : in out File_Browser;
            Dir  : in     String);

    --  Sort has no default here, or Load ("dir") would match both.
    procedure Load
           (This : in out File_Browser;
            Dir  : in     String;
            Sort : in not null FLTK.Filenames.Compare_Function);




    --  Settings  --

    function Get_File_Kind
           (This : in File_Browser)
        return File_Kind;

    procedure Set_File_Kind
           (This  : in out File_Browser;
            Value : in     File_Kind);

    function Get_Filter
           (This : in File_Browser)
        return String;

    procedure Set_Filter
           (This  : in out File_Browser;
            Value : in     String);

    function Get_Icon_Size
           (This : in File_Browser)
        return Icon_Size;

    procedure Set_Icon_Size
           (This  : in out File_Browser;
            Value : in     Icon_Size);

    function Get_Text_Size
           (This : in File_Browser)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out File_Browser;
            Size : in     Font_Size);




    --  List Implementation  --

    function Full_List_Height
           (This : in File_Browser)
        return Integer;

    function Average_Item_Height
           (This : in File_Browser)
        return Integer;




    --  Item Implementation  --

    function Item_Width
           (This : in File_Browser;
            Item : in Item_Cursor)
        return Integer;

    function Item_Height
           (This : in File_Browser;
            Item : in Item_Cursor)
        return Integer;

    procedure Item_Draw
           (This       : in File_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer);


private


    --  FLTK keeps the filter's pointer without copying it, so the record
    --  keeps the copy.
    type File_Browser is new Textline_Browser with record
        My_Filter : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.Null_Ptr;
    end record;

    overriding procedure Initialize
           (This : in out File_Browser);

    overriding procedure Finalize
           (This : in out File_Browser);

    procedure Extra_Init
           (This       : in out File_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out File_Browser);


    pragma Inline (Set_File_Kind);
    pragma Inline (Set_Filter);
    pragma Inline (Get_Icon_Size);
    pragma Inline (Set_Icon_Size);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Full_List_Height);
    pragma Inline (Average_Item_Height);

    pragma Inline (Item_Width);
    pragma Inline (Item_Height);
    pragma Inline (Item_Draw);


end FLTK.Widgets.Groups.Browsers.Textline.File;


