

--  Programmed by Jedidiah Barber
--  Released into the public domain


private with

    Interfaces.C.Strings;


package FLTK.Widgets.Groups.Help_Views is


    type Help_View is new Group with private;

    type Help_View_Reference (Data : not null access Help_View'Class) is limited null record
        with Implicit_Dereference => Data;

    subtype Position is Positive;
    subtype Extended_Position is Natural;

    No_Position : constant Extended_Position := 0;

    type Link_Callback is access function
           (Item : in out Help_View'Class;
            URI  : in     String)
        return String;




    --  You have no idea how tempting it is to give this
    --  a more tongue in cheek name
    Load_Help_Error : exception;




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Help_View;

    end Forge;




    procedure Clear_Selection
           (This : in out Help_View);

    procedure Select_All
           (This : in out Help_View);




    function Find
           (This : in Help_View;
            Item : in String;
            From : in Position := 1)
        return Extended_Position;

    function Get_Leftline_Pixel
           (This : in Help_View)
        return Natural;

    procedure Set_Leftline_Pixel
           (This  : in out Help_View;
            Value : in     Natural);

    function Get_Topline_Pixel
           (This : in Help_View)
        return Natural;

    procedure Set_Topline_Pixel
           (This  : in out Help_View;
            Value : in     Natural);

    procedure Set_Topline_Target
           (This  : in out Help_View;
            Value : in     String);




    function Current_Directory
           (This : in Help_View)
        return String;

    function Current_File
           (This : in Help_View)
        return String;

    --  Name here can be either a ftp/http/https/ipp/mailto/news URL or a filename
    procedure Load
           (This : in out Help_View;
            Name : in     String);

    function Document_Title
           (This : in Help_View)
        return String;

    function Get_Content
           (This : in Help_View)
        return String;

    procedure Set_Content
           (This  : in out Help_View;
            Value : in     String);

    procedure Set_Link_Callback
           (This : in out Help_View;
            Func : in     Link_Callback);




    function Get_Scrollbar_Size
           (This : in Help_View)
        return Natural;

    procedure Set_Scrollbar_Size
           (This  : in out Help_View;
            Value : in     Natural);

    function Get_Size
           (This : in Help_View)
        return Integer;

    procedure Resize
           (This : in out Help_View;
            W, H : in     Integer);

    function Get_Text_Color
           (This : in Help_View)
        return Color;

    procedure Set_Text_Color
           (This  : in out Help_View;
            Value : in     Color);

    function Get_Text_Font
           (This : in Help_View)
        return Font_Kind;

    procedure Set_Text_Font
           (This : in out Help_View;
            Font : in     Font_Kind);

    function Get_Text_Size
           (This : in Help_View)
        return Font_Size;

    procedure Set_Text_Size
           (This : in out Help_View;
            Size : in     Font_Size);




    procedure Draw
           (This : in out Help_View);

    function Handle
           (This  : in out Help_View;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Help_View is new Group with record
        Zelda : Link_Callback;
        Hilda : Interfaces.C.Strings.chars_ptr;
    end record;

    overriding procedure Finalize
           (This : in out Help_View);

    procedure Extra_Init
           (This       : in out Help_View;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;


    pragma Inline (Clear_Selection);
    pragma Inline (Select_All);

    pragma Inline (Find);
    pragma Inline (Get_Leftline_Pixel);
    pragma Inline (Set_Leftline_Pixel);
    pragma Inline (Get_Topline_Pixel);
    pragma Inline (Set_Topline_Pixel);
    pragma Inline (Set_Topline_Target);

    pragma Inline (Current_Directory);
    pragma Inline (Current_File);
    pragma Inline (Set_Content);
    pragma Inline (Set_Link_Callback);

    pragma Inline (Get_Scrollbar_Size);
    pragma Inline (Set_Scrollbar_Size);
    pragma Inline (Get_Size);
    pragma Inline (Resize);
    pragma Inline (Get_Text_Color);
    pragma Inline (Set_Text_Color);
    pragma Inline (Get_Text_Font);
    pragma Inline (Set_Text_Font);
    pragma Inline (Get_Text_Size);
    pragma Inline (Set_Text_Size);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Groups.Help_Views;


