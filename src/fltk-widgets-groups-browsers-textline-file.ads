

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Filenames;


package FLTK.Widgets.Groups.Browsers.Textline.File is


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

    end Forge;




    function Load
           (This : in out File_Browser;
            Dir  : in     String;
            Sort : in not null FLTK.Filenames.Compare_Function :=
                FLTK.Filenames.Numeric_Sort'Access)
        return Natural;

    procedure Load
           (This : in out File_Browser;
            Dir  : in     String;
            Sort : in not null FLTK.Filenames.Compare_Function :=
                FLTK.Filenames.Numeric_Sort'Access);




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


private


    type File_Browser is new Textline_Browser with null record;

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


end FLTK.Widgets.Groups.Browsers.Textline.File;


