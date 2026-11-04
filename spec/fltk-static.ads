

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Labels,
    FLTK.Widgets.Groups.Windows;

private with

    Ada.Finalization,
    Ada.Unchecked_Conversion,
    FLTK.Args_Marshal,
    Interfaces.C.Strings;


package FLTK.Static is


    --  Input is the argument index usable with Ada.Command_Line.
    --  Output is how many arguments parsed starting from that index.
    type Args_Handler is access function
           (Index : in Positive)
        return Natural;

    type Awake_Handler is access procedure;

    type Idle_Handler is access procedure;

    type Timeout_Handler is access procedure;


    type Buffer_Kind is (Selection, Clipboard);

    type Clipboard_Notify_Handler is access procedure
           (Kind : in Buffer_Kind);


    type File_Descriptor is new Integer;

    type File_Mode is record
        Read   : Boolean := False;
        Write  : Boolean := False;
        Except : Boolean := False;
    end record;

    function "+" (Left, Right : in File_Mode) return File_Mode;
    function "-" (Left, Right : in File_Mode) return File_Mode;

    Read_Mode   : constant File_Mode;
    Write_Mode  : constant File_Mode;
    Except_Mode : constant File_Mode;

    type File_Handler is access procedure
           (FD : in File_Descriptor);


    subtype Byte_Integer is Integer range 0 .. 255;

    type Box_Draw_Function is access procedure
           (X, Y, W, H : in Integer;
            Tone       : in Color);


    type Label_Draw_Function is access procedure
           (Item       : in FLTK.Labels.Label'Class;
            X, Y, W, H : in Integer;
            Position   : in Alignment);

    type Label_Measure_Function is access procedure
           (Item : in     FLTK.Labels.Label'Class;
            W, H :    out Integer);


    type Option is
       (Arrow_Focus,
        Visible_Focus,
        DND_Text,
        Show_Tooltips,
        FNFC_Uses_GTK);


    --  According to docs this should be customisable,
    --  but in C++ it is a constant pointer to constant.
    Help_Message : constant String;


    Argument_Error : exception;




    --  Display  --

    --  Connects to the display (fl_open_display).  Showing the first window
    --  does this, and so do the calls FLTK 1.4.5 would crash in with no
    --  display open, which call it themselves: Ready, Copy, Paste, Selection,
    --  Clipboard_Contains, Enable_System_Input, Disable_System_Input,
    --  Set_Box_Color, Widget.Take_Focus, Events.Set_Focus, GL_Window.Can_Do,
    --  GLUT.Get and Copy_Surface's Forge.Create (PLAN.md, decision 5).  Call
    --  it first to choose when the connection is made, and so when FLTK
    --  stops the program if there is no display: it prints "Can't open
    --  display" (X11) or "No Wayland connection" and exits.  Calling it
    --  again does nothing.
    procedure Open_Display;




    --  Command Line Arguments  --

    --  Index past the last argument raises Constraint_Error.
    function Parse_Arg
           (Index : in Positive)
        return Natural;

    procedure Parse_Args;

    --  Not task safe, but you won't need to call this more than once anyway.
    --  An option neither Func nor FLTK knows, or one missing its value,
    --  raises Argument_Error, in every call: FLTK's Fl::args stops saying so
    --  once a call has stopped at a word that isn't an option (pofltk 57).
    procedure Parse_Args
           (Count :    out Natural;
            Func  : in     Args_Handler := null);




    --  Thread Notify  --

    --  Unsure if it is worth actually using this or if mixing tasks, pthreads,
    --  and whatever other platforms use causes errors in some unexpected way.
    --  Might be better to rely on FLTK.Check, Ada tasking, and Ada protected types.
    --  You'll need appropriately declared protected objects to pass messages anyway.

    procedure Add_Awake_Handler
           (Func : in Awake_Handler);

    function Get_Awake_Handler
        return Awake_Handler;

    procedure Awake
           (Func : in Awake_Handler);

    procedure Awake;

    procedure Lock;

    procedure Unlock;




    --  Pre-Eventloop Callbacks  --

    procedure Add_Check
           (Func : in not null Timeout_Handler);

    function Has_Check
           (Func : in not null Timeout_Handler)
        return Boolean;

    procedure Remove_Check
           (Func : in not null Timeout_Handler);




    --  Timer Callbacks  --

    procedure Add_Timeout
           (Seconds : in          Long_Float;
            Func    : in not null Timeout_Handler);

    function Has_Timeout
           (Func : in not null Timeout_Handler)
        return Boolean;

    procedure Remove_Timeout
           (Func : in not null Timeout_Handler);

    procedure Repeat_Timeout
           (Seconds : in          Long_Float;
            Func    : in not null Timeout_Handler);




    --  Clipboard Callbacks  --

    procedure Add_Clipboard_Notify
           (Func : in not null Clipboard_Notify_Handler);

    procedure Remove_Clipboard_Notify
           (Func : in not null Clipboard_Notify_Handler);




    --  File Descriptor Waiting Callbacks  --

    procedure Add_File_Descriptor
           (FD   : in          File_Descriptor;
            Func : in not null File_Handler);

    procedure Add_File_Descriptor
           (FD   : in          File_Descriptor;
            Mode : in          File_Mode;
            Func : in not null File_Handler);

    procedure Remove_File_Descriptor
           (FD : in File_Descriptor);

    procedure Remove_File_Descriptor
           (FD   : in File_Descriptor;
            Mode : in File_Mode);




    --  Idle Callbacks  --

    procedure Add_Idle
           (Func : in not null Idle_Handler);

    function Has_Idle
           (Func : in not null Idle_Handler)
        return Boolean;

    procedure Remove_Idle
           (Func : in not null Idle_Handler);




    --  Custom Colors  --

    function Get_Color
           (From : in Color)
        return Color;

    procedure Get_Color
           (From    : in     Color;
            R, G, B :    out Color_Component);

    procedure Set_Color
           (Target, Source : in Color);

    procedure Set_Color
           (Target  : in Color;
            R, G, B : in Color_Component);

    procedure Free_Color
           (Value   : in Color;
            Overlay : in Boolean := False);

    function Get_Box_Color
           (Tone : in Color)
        return Color;

    procedure Set_Box_Color
           (Tone : in Color);

    procedure Own_Colormap;

    procedure Set_Foreground
           (R, G, B : in Color_Component);

    procedure Set_Background
           (R, G, B : in Color_Component);

    procedure Set_Alt_Background
           (R, G, B : in Color_Component);

    procedure System_Colors;

    procedure Get_Color
           (From       : in     Color;
            R, G, B, A :    out Color_Component);

    procedure Set_Color
           (Target     : in Color;
            R, G, B, A : in Color_Component);




    --  Custom Fonts  --

    --  Free_Font is empty, and its images are "", until it is set.  Using
    --  it here, or in FLTK.Draw, first opens the display.  A widget's font
    --  isn't checked: set Free_Font before a widget draws in it (pofltk 130).
    function Font_Image
           (Kind : in Font_Kind)
        return String;

    function Font_Family_Image
           (Kind : in Font_Kind)
        return String;

    procedure Set_Font_Kind
           (Target, Source : in Font_Kind);

    --  Source is cut to 126 bytes, before any UTF-8 character that would
    --  cross that (pofltk 130).
    procedure Set_Font_Kind
           (Target : in Font_Kind;
            Source : in String);

    function Font_Sizes
           (Kind : in Font_Kind)
        return Font_Size_Array;

    procedure Setup_Fonts
           (How_Many_Set_Up : out Natural);




    --  Box_Kind Attributes  --

    function Get_Box_Height_Offset
           (Kind : in Box_Kind)
        return Integer;

    function Get_Box_Width_Offset
           (Kind : in Box_Kind)
        return Integer;

    function Get_Box_X_Offset
           (Kind : in Box_Kind)
        return Integer;

    function Get_Box_Y_Offset
           (Kind : in Box_Kind)
        return Integer;

    procedure Set_Box_Kind
           (To, From : in Box_Kind);

    function Draw_Box_Active
        return Boolean;

    function Get_Box_Draw_Function
           (Kind : in Box_Kind)
        return Box_Draw_Function;

    procedure Set_Box_Draw_Function
           (Kind               : in Box_Kind;
            Func               : in Box_Draw_Function;
            Offset_X, Offset_Y : in Byte_Integer := 0;
            Offset_W, Offset_H : in Byte_Integer := 0);




    --  Label_Kind Attributes  --

    procedure Set_Label_Kind
           (Target, Source : in Label_Kind);

    procedure Set_Label_Draw_Function
           (Kind         : in Label_Kind;
            Draw_Func    : in Label_Draw_Function;
            Measure_Func : in Label_Measure_Function);




    --  Clipboard / Selection  --

    procedure Copy
           (Text : in String;
            Dest : in Buffer_Kind);

    procedure Paste
           (Receiver : in FLTK.Widgets.Widget'Class;
            Source   : in Buffer_Kind);

    procedure Selection
           (Owner : in FLTK.Widgets.Widget'Class;
            Text  : in String);

    function Clipboard_Contains
           (Kind : in String)
        return Boolean;




    --  Dragon Drop  --

    procedure Drag_Drop_Start;

    function Get_Drag_Drop_Text_Support
        return Boolean;

    procedure Set_Drag_Drop_Text_Support
           (To : in Boolean);




    --  Input Methods  --

    procedure Enable_System_Input;

    procedure Disable_System_Input;




    --  Windows  --

    procedure Default_Window_Close
           (Item : in out FLTK.Widgets.Widget'Class);

    function Get_First_Window
        return access FLTK.Widgets.Groups.Windows.Window'Class;

    procedure Set_First_Window
           (To : in FLTK.Widgets.Groups.Windows.Window'Class);

    function Get_Next_Window
           (From : in FLTK.Widgets.Groups.Windows.Window'Class)
        return access FLTK.Widgets.Groups.Windows.Window'Class;

    function Get_Top_Modal
        return access FLTK.Widgets.Groups.Windows.Window'Class;




    --  Queue  --

    function Read_Queue
        return access FLTK.Widgets.Widget'Class;




    --  Schemes  --

    function Get_Scheme
        return String;

    procedure Set_Scheme
           (To : in String);

    function Is_Scheme
           (Scheme : in String)
        return Boolean;

    procedure Reload_Scheme;




    --  Library Options  --

    function Get_Option
           (Opt : in Option)
        return Boolean;

    procedure Set_Option
           (Opt : in Option;
            To  : in Boolean);

    function Get_Use_High_Res_GL
        return Boolean;

    procedure Set_Use_High_Res_GL
           (To : in Boolean);




    --  Scrollbars  --

    function Get_Default_Scrollbar_Size
        return Natural;

    procedure Set_Default_Scrollbar_Size
           (To : in Natural);


private


    for File_Mode use record
        Read   at 0 range 0 .. 0;
        --  bit position 1 is unused
        Write  at 0 range 2 .. 2;
        Except at 0 range 3 .. 3;
    end record;

    for File_Mode'Size use Interfaces.C.int'Size;

    Read_Mode   : constant File_Mode := (Read   => True, others => False);
    Write_Mode  : constant File_Mode := (Write  => True, others => False);
    Except_Mode : constant File_Mode := (Except => True, others => False);

    function FMode_To_Cint is new
        Ada.Unchecked_Conversion (File_Mode, Interfaces.C.int);


    help_usage_string_ptr : Interfaces.C.Strings.chars_ptr;
    pragma Import (C, help_usage_string_ptr, "fl_help_usage_string_ptr");

    Help_Message : constant String := Interfaces.C.Strings.Value (help_usage_string_ptr);


    Font_Overrides : array (Font_Kind) of Interfaces.C.Strings.chars_ptr;


    pragma Import (C, Open_Display, "fl_static_open_display");

    pragma Import (C, Lock, "fl_static_lock");
    pragma Import (C, Unlock, "fl_static_unlock");

    pragma Import (C, Own_Colormap, "fl_static_own_colormap");
    pragma Import (C, System_Colors, "fl_static_get_system_colors");

    pragma Import (C, Enable_System_Input, "fl_static_enable_im");
    pragma Import (C, Disable_System_Input, "fl_static_disable_im");

    pragma Import (C, Reload_Scheme, "fl_static_reload_scheme");


    pragma Inline (Parse_Arg);

    pragma Inline (Add_Awake_Handler);
    pragma Inline (Get_Awake_Handler);
    pragma Inline (Awake);
    pragma Inline (Lock);
    pragma Inline (Unlock);

    pragma Inline (Add_Check);
    pragma Inline (Has_Check);
    pragma Inline (Remove_Check);

    pragma Inline (Add_Timeout);
    pragma Inline (Has_Timeout);
    pragma Inline (Remove_Timeout);
    pragma Inline (Repeat_Timeout);

    pragma Inline (Add_Clipboard_Notify);
    pragma Inline (Remove_Clipboard_Notify);

    pragma Inline (Add_File_Descriptor);
    pragma Inline (Remove_File_Descriptor);

    pragma Inline (Add_Idle);
    pragma Inline (Has_Idle);
    pragma Inline (Remove_Idle);

    pragma Inline (Get_Color);
    pragma Inline (Set_Color);
    pragma Inline (Free_Color);
    pragma Inline (Get_Box_Color);
    pragma Inline (Set_Box_Color);
    pragma Inline (Own_Colormap);
    pragma Inline (Set_Foreground);
    pragma Inline (Set_Background);
    pragma Inline (Set_Alt_Background);
    pragma Inline (System_Colors);

    pragma Inline (Font_Image);
    pragma Inline (Font_Family_Image);
    pragma Inline (Set_Font_Kind);
    pragma Inline (Font_Sizes);
    pragma Inline (Setup_Fonts);

    pragma Inline (Get_Box_Height_Offset);
    pragma Inline (Get_Box_Width_Offset);
    pragma Inline (Get_Box_X_Offset);
    pragma Inline (Get_Box_Y_Offset);
    pragma Inline (Set_Box_Kind);
    pragma Inline (Draw_Box_Active);
    pragma Inline (Get_Box_Draw_Function);
    pragma Inline (Set_Box_Draw_Function);

    pragma Inline (Set_Label_Kind);
    pragma Inline (Set_Label_Draw_Function);

    pragma Inline (Copy);
    pragma Inline (Paste);
    pragma Inline (Selection);
    pragma Inline (Clipboard_Contains);

    pragma Inline (Drag_Drop_Start);
    pragma Inline (Get_Drag_Drop_Text_Support);
    pragma Inline (Set_Drag_Drop_Text_Support);

    pragma Inline (Enable_System_Input);
    pragma Inline (Disable_System_Input);

    pragma Inline (Default_Window_Close);
    pragma Inline (Get_First_Window);
    pragma Inline (Set_First_Window);
    pragma Inline (Get_Next_Window);
    pragma Inline (Get_Top_Modal);

    pragma Inline (Read_Queue);

    pragma Inline (Get_Scheme);
    pragma Inline (Set_Scheme);
    pragma Inline (Is_Scheme);
    pragma Inline (Reload_Scheme);

    pragma Inline (Get_Option);
    pragma Inline (Set_Option);
    pragma Inline (Get_Use_High_Res_GL);
    pragma Inline (Set_Use_High_Res_GL);

    pragma Inline (Get_Default_Scrollbar_Size);
    pragma Inline (Set_Default_Scrollbar_Size);


    --  Needed to dealloc the argv array and deregister the clipboard notify handler
    type FLTK_Static_Final_Controller is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out FLTK_Static_Final_Controller);

    Cleanup : FLTK_Static_Final_Controller;


end FLTK.Static;


