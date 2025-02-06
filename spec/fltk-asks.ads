

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Color_Choosers;

private with

    Ada.Finalization,
    Interfaces.C.Strings;


package FLTK.Asks is


    type Beep_Kind is
       (Default_Beep, Message_Beep, Error_Beep,
        Question_Beep, Password_Beep, Notification_Beep);

    type Confirm_Result is (Cancel, Confirm);

    type Choice_Result is (First, Second, Third);

    type Extended_Choice_Result is (First, Second, Third, Blocked, Closed, Escaped);

    type RGB_Float is new Long_Float range 0.0 .. 1.0;

    subtype RGB_Int is Color_Component;

    type File_Chooser_Callback is access procedure
           (Item : in String);




    --  Static Attributes  --

    function Get_Cancel_String
        return String;

    procedure Set_Cancel_String
           (Value : in String);

    function Get_Close_String
        return String;

    procedure Set_Close_String
           (Value : in String);

    function Get_No_String
        return String;

    procedure Set_No_String
           (Value : in String);

    function Get_OK_String
        return String;

    procedure Set_OK_String
           (Value : in String);

    function Get_Yes_String
        return String;

    procedure Set_Yes_String
           (Value : in String);




    --  Simple Messages  --

    procedure Alert
           (Message : String);

    procedure Beep
           (Kind : in Beep_Kind := Default_Beep);

    function Choice
           (Message, Button1 : in String)
        return Choice_Result;

    function Choice
           (Message, Button1, Button2 : in String)
        return Choice_Result;

    function Choice
           (Message, Button1, Button2, Button3 : in String)
        return Choice_Result;

    function Extended_Choice
           (Message, Button1 : in String)
        return Extended_Choice_Result;

    function Extended_Choice
           (Message, Button1, Button2 : in String)
        return Extended_Choice_Result;

    function Extended_Choice
           (Message, Button1, Button2, Button3 : in String)
        return Extended_Choice_Result;

    function Text_Input
           (Message : in String;
            Default : in String := "")
        return String;

    procedure Message_Box
           (Message : in String);

    function Password
           (Message : in String;
            Default : in String := "")
        return String;




    --  Choosers  --

    function Color_Chooser
           (Title   : in     String;
            R, G, B : in out RGB_Float;
            Mode    : in     FLTK.Widgets.Groups.Color_Choosers.Color_Mode :=
                FLTK.Widgets.Groups.Color_Choosers.RGB)
        return Confirm_Result;

    function Color_Chooser
           (Title   : in     String;
            R, G, B : in out RGB_Int;
            Mode    : in     FLTK.Widgets.Groups.Color_Choosers.Color_Mode :=
                FLTK.Widgets.Groups.Color_Choosers.RGB)
        return Confirm_Result;

    function Show_Colormap
           (Old_Hue : in Color)
        return Color;

    function Dir_Chooser
           (Message, Default : in String;
            Relative         : in Boolean := False)
        return String;

    function File_Chooser
           (Message, Filter_Pattern, Default : in String;
            Relative                         : in Boolean := False)
        return String;

    procedure Set_File_Chooser_Callback
           (Func : in File_Chooser_Callback);

    procedure Set_File_Chooser_OK_String
           (Value : in String);




    --  Settings  --

    function Get_Message_Hotspot
        return Boolean;

    procedure Set_Message_Hotspot
           (To : in Boolean);

    procedure Set_Message_Font
           (Font : in Font_Kind;
            Size : in Font_Size);

    function Get_Message_Icon
        return FLTK.Widgets.Boxes.Box_Reference;

    procedure Set_Message_Title
           (To : in String);

    procedure Set_Message_Title_Default
           (To : in String);


private


    Icon_Box : aliased FLTK.Widgets.Boxes.Box;


    Cancel_Str, Close_Str, No_Str, OK_Str, Yes_Str : Interfaces.C.Strings.chars_ptr;

    Chooser_OK_Str : Interfaces.C.Strings.chars_ptr;
    Chooser_Func   : File_Chooser_Callback;


    pragma Inline (Get_Cancel_String);
    pragma Inline (Get_Close_String);
    pragma Inline (Get_No_String);
    pragma Inline (Get_OK_String);
    pragma Inline (Get_Yes_String);

    pragma Inline (Alert);
    pragma Inline (Beep);
    pragma Inline (Text_Input);
    pragma Inline (Message_Box);
    pragma Inline (Password);

    pragma Inline (Color_Chooser);
    pragma Inline (Show_Colormap);
    pragma Inline (Dir_Chooser);
    pragma Inline (File_Chooser);
    pragma Inline (Set_File_Chooser_Callback);

    pragma Inline (Get_Message_Hotspot);
    pragma Inline (Set_Message_Hotspot);
    pragma Inline (Set_Message_Font);
    pragma Inline (Get_Message_Icon);
    pragma Inline (Set_Message_Title);
    pragma Inline (Set_Message_Title_Default);


    --  Needed to ensure chars_ptr storage is properly cleaned up
    type Dialog_String_Final_Controller is new Ada.Finalization.Controlled with null record;

    overriding procedure Finalize
           (This : in out Dialog_String_Final_Controller);

    Cleanup : Dialog_String_Final_Controller;


end FLTK.Asks;


