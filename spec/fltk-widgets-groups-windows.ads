

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images.RGB;

private with

    Interfaces.C.Strings;


package FLTK.Widgets.Groups.Windows is


    type Window is new Group with private;

    type Window_Reference (Data : not null access Window'Class) is limited null record
        with Implicit_Dereference => Data;

    type Modal_State is (Normal, Non_Modal, Modal);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Window;

        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Window;

        function Create
               (Parent : in out Group'Class;
                W, H   : in     Integer;
                Text   : in     String := "")
            return Window;

    end Forge;




    --  Visibility  --

    procedure Show
           (This : in out Window);

    procedure Show_With_Args
           (This : in out Window);

    procedure Hide
           (This : in out Window);

    function Is_Shown
           (This : in Window)
        return Boolean;

    procedure Wait_For_Expose
           (This : in out Window);

    procedure Iconify
           (This : in out Window);

    --  Raises Program_Error if the window is not shown, where FLTK would
    --  end the program.
    procedure Make_Current
           (This : in out Window);

    function Last_Made_Current
        return access Window'Class;




    --  Fullscreen  --

    function Is_Fullscreen
           (This : in Window)
        return Boolean;

    procedure Fullscreen_On
           (This : in out Window);

    procedure Fullscreen_Off
           (This : in out Window);

    procedure Fullscreen_Off
           (This       : in out Window;
            X, Y, W, H : in     Integer);

    procedure Fullscreen_Screens
           (This                     : in out Window;
            Top, Bottom, Left, Right : in     Natural);




    --  Icons, Cursors  --

    procedure Set_Icon
           (This : in out Window;
            Pic  : in     FLTK.Images.RGB.RGB_Image'Class);

    procedure Set_Icons
           (This : in out Window;
            Pics : in     FLTK.Images.RGB.RGB_Image_Array);

    procedure Reset_Icons
           (This : in out Window);

    procedure Set_Default_Icon
           (Pic : in FLTK.Images.RGB.RGB_Image'Class);

    procedure Set_Default_Icons
           (Pics : in FLTK.Images.RGB.RGB_Image_Array);

    procedure Reset_Default_Icons;

    function Get_Icon_Label
           (This : in Window)
        return String;

    procedure Set_Icon_Label
           (This : in out Window;
            To   : in     String);

    procedure Set_Cursor
           (This : in out Window;
            To   : in     Mouse_Cursor_Kind);

    procedure Set_Cursor
           (This         : in out Window;
            Pic          : in     FLTK.Images.RGB.RGB_Image'Class;
            Hot_X, Hot_Y : in     Integer);

    procedure Set_Default_Cursor
           (This : in out Window;
            To   : in     Mouse_Cursor_Kind);




    --  Settings  --

    function Has_Border
           (This : in Window)
        return Boolean;

    procedure Set_Border
           (This  : in out Window;
            Value : in     Boolean := True);

    procedure Clear_Border
           (This : in out Window);

    function Is_Override
           (This : in Window)
        return Boolean;

    procedure Set_Override
           (This : in out Window);

    function Is_Modal
           (This : in Window)
        return Boolean;

    function Is_Non_Modal
           (This : in Window)
        return Boolean;

    function Get_Modal_State
           (This : in Window)
        return Modal_State;

    procedure Set_Modal
           (This : in out Window);

    procedure Set_Non_Modal
           (This : in out Window);

    procedure Set_Modal_State
           (This  : in out Window;
            Value : in     Modal_State);

    procedure Clear_Modal_State
           (This : in out Window);




    --  Labels, Hotspot, Shape  --

    function Get_Label
           (This : in Window)
        return String;

    procedure Set_Label
           (This : in out Window;
            Text : in     String);

    procedure Set_Labels
           (This            : in out Window;
            Text, Icon_Text : in     String);

    procedure Hotspot
           (This      : in out Window;
            X, Y      : in     Integer;
            Offscreen : in     Boolean := False);

    procedure Hotspot
           (This      : in out Window;
            Item      : in     Widget'Class;
            Offscreen : in     Boolean := False);

    --  The window is shaped by a copy of Pic at its drawn size, which the
    --  window keeps, so Pic can go at once (pofltk 61).  An image with no
    --  data raises Constraint_Error.
    procedure Shape
           (This : in out Window;
            Pic  : in     FLTK.Images.Image'Class);




    --  Dimensions  --

    procedure Set_Size_Range
           (This                           : in out Window;
            Min_W, Min_H                   : in     Integer;
            Max_W, Max_H, Incre_W, Incre_H : in     Integer := 0;
            Keep_Aspect                    : in     Boolean := False);

    procedure Resize
           (This       : in out Window;
            X, Y, W, H : in     Integer);

    function Is_Position_Forced
           (This : in Window)
        return Boolean;

    procedure Force_Position
           (This  : in out Window;
            State : in     Boolean := True);

    function Get_X_Root
           (This : in Window)
        return Integer;

    function Get_Y_Root
           (This : in Window)
        return Integer;

    function Get_Decorated_W
           (This : in Window)
        return Integer;

    function Get_Decorated_H
           (This : in Window)
        return Integer;




    -- Class Info  --

    function Get_X_Class
           (This : in Window)
        return String;

    procedure Set_X_Class
           (This  : in out Window;
            Value : in     String);

    function Get_Default_X_Class
        return String;

    procedure Set_Default_X_Class
           (Value : in String);

    function Is_Menu_Window
           (This : in Window)
        return Boolean;

    function Is_Tooltip_Window
           (This : in Window)
        return Boolean;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Window);

    procedure Flush
           (This : in out Window);

    function Handle
           (This  : in out Window;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    --  FLTK keeps the icon label's pointer without copying it, and has no
    --  copy_iconlabel, so the record keeps the copy.
    type Window is new Group with record
        My_Icon_Label : Interfaces.C.Strings.chars_ptr := Interfaces.C.Strings.Null_Ptr;
    end record;

    overriding procedure Initialize
           (This : in out Window);

    overriding procedure Finalize
           (This : in out Window);

    procedure Extra_Init
           (This       : in out Window;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Window)
    with Inline;


    pragma Inline (Show);
    pragma Inline (Show_With_Args);
    pragma Inline (Hide);
    pragma Inline (Is_Shown);
    pragma Inline (Wait_For_Expose);
    pragma Inline (Iconify);
    pragma Inline (Make_Current);
    pragma Inline (Last_Made_Current);

    pragma Inline (Is_Fullscreen);
    pragma Inline (Fullscreen_On);
    pragma Inline (Fullscreen_Off);
    pragma Inline (Fullscreen_Screens);

    pragma Inline (Set_Icon);
    pragma Inline (Set_Icons);
    pragma Inline (Reset_Icons);
    pragma Inline (Set_Default_Icon);
    pragma Inline (Set_Default_Icons);
    pragma Inline (Reset_Default_Icons);
    pragma Inline (Get_Icon_Label);
    pragma Inline (Set_Icon_Label);
    pragma Inline (Set_Cursor);
    pragma Inline (Set_Default_Cursor);

    pragma Inline (Has_Border);
    pragma Inline (Set_Border);
    pragma Inline (Clear_Border);
    pragma Inline (Is_Override);
    pragma Inline (Set_Override);
    pragma Inline (Is_Modal);
    pragma Inline (Is_Non_Modal);
    pragma Inline (Get_Modal_State);
    pragma Inline (Set_Modal);
    pragma Inline (Set_Non_Modal);
    pragma Inline (Set_Modal_State);
    pragma Inline (Clear_Modal_State);

    pragma Inline (Get_Label);
    pragma Inline (Set_Label);
    pragma Inline (Set_Labels);
    pragma Inline (Hotspot);
    pragma Inline (Shape);

    pragma Inline (Set_Size_Range);
    pragma Inline (Resize);
    pragma Inline (Is_Position_Forced);
    pragma Inline (Force_Position);
    pragma Inline (Get_X_Root);
    pragma Inline (Get_Y_Root);
    pragma Inline (Get_Decorated_W);
    pragma Inline (Get_Decorated_H);

    pragma Inline (Get_X_Class);
    pragma Inline (Set_X_Class);
    pragma Inline (Get_Default_X_Class);
    pragma Inline (Set_Default_X_Class);
    pragma Inline (Is_Menu_Window);
    pragma Inline (Is_Tooltip_Window);

    pragma Inline (Draw);
    pragma Inline (Flush);
    pragma Inline (Handle);


    Last_Current : access Window'Class := null;


end FLTK.Widgets.Groups.Windows;


