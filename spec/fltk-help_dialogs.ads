

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Help_Dialogs is


    type Help_Dialog is new Wrapper with private;

    type Help_Dialog_Reference (Data : not null access Help_Dialog'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        --  Both leave the current group as it was.  FLTK's constructor leaves
        --  none (Fl_Window.cxx:82, Fl_Help_Dialog.cxx:198), and the binding
        --  puts it back (pofltk 93).
        function Create
            return Help_Dialog;

        function Create
               (X, Y, W, H : in Integer)
            return Help_Dialog;

    end Forge;




    --  Visibility  --

    procedure Show
           (This : in out Help_Dialog);

    procedure Show_With_Args
           (This : in out Help_Dialog);

    procedure Hide
           (This : in out Help_Dialog);

    function Is_Visible
           (This : in Help_Dialog)
        return Boolean;




    --  Topline  --

    procedure Set_Topline_Number
           (This : in out Help_Dialog;
            Line : in     Positive);

    procedure Set_Topline_Target
           (This  : in out Help_Dialog;
            Value : in     String);




    --  Content  --

    --  Name here can be either a ftp/http/https/ipp/mailto/news URL or a filename.
    --  See Load procedure in FLTK.Widgets.Groups.Help_Views: a URL opens in
    --  the user's web browser, not here.
    procedure Load
           (This : in out Help_Dialog;
            Name : in     String);

    function Get_Content
           (This : in Help_Dialog)
        return String;

    procedure Set_Content
           (This  : in out Help_Dialog;
            Value : in     String);




    --  Settings  --

    function Get_Text_Size
           (This : in Help_Dialog)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Help_Dialog;
            Size : in     Font_Size);




    --  Dimensions  --

    function Get_X
           (This : in Help_Dialog)
        return Integer;

    function Get_Y
           (This : in Help_Dialog)
        return Integer;

    function Get_W
           (This : in Help_Dialog)
        return Integer;

    function Get_H
           (This : in Help_Dialog)
        return Integer;

    procedure Resize
           (This       : in out Help_Dialog;
            X, Y, W, H : in     Integer);

    procedure Reposition
           (This : in out Help_Dialog;
            X, Y : in     Integer);


private


    type Help_Dialog is new Wrapper with null record;

    overriding procedure Finalize
           (This : in out Help_Dialog);


    pragma Inline (Show);
    pragma Inline (Show_With_Args);
    pragma Inline (Hide);
    pragma Inline (Is_Visible);

    pragma Inline (Set_Topline_Number);
    pragma Inline (Set_Topline_Target);

    pragma Inline (Load);
    pragma Inline (Set_Content);

    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Get_X);
    pragma Inline (Get_Y);
    pragma Inline (Get_W);
    pragma Inline (Get_H);
    pragma Inline (Resize);
    pragma Inline (Reposition);


end FLTK.Help_Dialogs;


