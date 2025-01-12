

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

    type Border_State is (None, Visible);

    type Modal_State is (Normal, Non_Modal, Modal);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Window;

        function Create
               (W, H : in Integer;
                Text : in String := "")
            return Window;

    end Forge;




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

    procedure Make_Current
           (This : in out Window);

    function Last_Made_Current
        return access Window'Class;

    procedure Free_Position
           (This : in out Window);




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




    procedure Set_Icon
           (This : in out Window;
            Pic  : in out FLTK.Images.RGB.RGB_Image'Class);

    procedure Set_Default_Icon
           (Pic : in out FLTK.Images.RGB.RGB_Image'Class);

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
            Pic          : in out FLTK.Images.RGB.RGB_Image'Class;
            Hot_X, Hot_Y : in     Integer);

    procedure Set_Default_Cursor
           (This : in out Window;
            To   : in     Mouse_Cursor_Kind);




    function Get_Border_State
           (This : in Window)
        return Border_State;

    procedure Set_Border_State
           (This : in out Window;
            To   : in     Border_State);

    function Is_Override
           (This : in Window)
        return Boolean;

    procedure Set_Override
           (This : in out Window);

    function Get_Modal_State
           (This : in Window)
        return Modal_State;

    procedure Set_Modal_State
           (This : in out Window;
            To   : in     Modal_State);




    function Get_Label
           (This : in Window)
        return String;

    procedure Set_Label
           (This : in out Window;
            Text : in     String);

    procedure Hotspot
           (This      : in out Window;
            X, Y      : in     Integer;
            Offscreen : in     Boolean := False);

    procedure Hotspot
           (This      : in out Window;
            Item      : in     Widget'Class;
            Offscreen : in     Boolean := False);

    procedure Set_Size_Range
           (This                           : in out Window;
            Min_W, Min_H                   : in     Integer;
            Max_W, Max_H, Incre_W, Incre_H : in     Integer := 0;
            Keep_Aspect                    : in     Boolean := False);

    procedure Shape
           (This : in out Window;
            Pic  : in out FLTK.Images.Image'Class);




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




    procedure Draw
           (This : in out Window);

    function Handle
           (This  : in out Window;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Window is new Group with null record;

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
    pragma Inline (Free_Position);

    pragma Inline (Is_Fullscreen);
    pragma Inline (Fullscreen_On);
    pragma Inline (Fullscreen_Off);
    pragma Inline (Fullscreen_Screens);

    pragma Inline (Set_Icon);
    pragma Inline (Set_Default_Icon);
    pragma Inline (Get_Icon_Label);
    pragma Inline (Set_Icon_Label);
    pragma Inline (Set_Cursor);
    pragma Inline (Set_Default_Cursor);

    pragma Inline (Get_Border_State);
    pragma Inline (Set_Border_State);
    pragma Inline (Is_Override);
    pragma Inline (Set_Override);
    pragma Inline (Get_Modal_State);
    pragma Inline (Set_Modal_State);

    pragma Inline (Get_Label);
    pragma Inline (Set_Label);
    pragma Inline (Hotspot);
    pragma Inline (Set_Size_Range);
    pragma Inline (Shape);

    pragma Inline (Get_X_Root);
    pragma Inline (Get_Y_Root);
    pragma Inline (Get_Decorated_W);
    pragma Inline (Get_Decorated_H);

    pragma Inline (Draw);
    pragma Inline (Handle);


    Last_Current : access Window'Class := null;


end FLTK.Widgets.Groups.Windows;


