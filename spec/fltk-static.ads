

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Labels,
    FLTK.Widgets.Groups.Windows;

private with

    Ada.Containers.Ordered_Maps,
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


    --  Called when the user closes a window that has no callback of its
    --  own, in place of FLTK's default, which hides the window
    --  (Fl::set_atclose; Fl_Window.cxx:172-181).
    type Window_Close_Handler is access procedure
           (Item : in out FLTK.Widgets.Groups.Windows.Window'Class);


    --  When FLTK.Contrast is in Custom_Contrast mode it calls this.  Context
    --  and Size are what the caller of Contrast passed.
    type Contrast_Function is access function
           (Fore, Back    : in Color;
            Context, Size : in Integer)
        return Color;

    subtype Contrast_Level is Integer range 0 .. 100;


    --  A moment, for measuring time between events.  FLTK says it is not the
    --  time of day (Fl_Timeout.cxx); use Ada.Calendar for that.
    type Timestamp is private;


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




    --  Shutdown  --

    --  Set by FLTK on macOS when the user chooses Quit from the application
    --  menu and every window has closed (Fl.H:457-460, Fl_cocoa.mm:1624).
    --  A program can set it too, for a quit command of its own.
    function Get_Program_Should_Quit
        return Boolean;

    procedure Set_Program_Should_Quit
           (To : in Boolean);

    --  Hides every shown window.  An exception from a widget's Handle that
    --  this runs is raised again here.
    procedure Hide_All_Windows;

    --  Runs the Add_Check handlers once, and the idle handlers once.  An
    --  exception from one is raised again here.
    procedure Run_Checks;

    procedure Run_Idle;

    --  Null restores FLTK's default.  An exception from the handler is
    --  raised again from the event loop call it ran in.
    procedure Set_Window_Close_Handler
           (Func : in Window_Close_Handler);




    --  Timestamps  --

    --  Seconds are fractional; Offset is added to the moment.
    function Now
           (Offset : in Long_Float := 0.0)
        return Timestamp;

    function Seconds_Since
           (Moment : in Timestamp)
        return Long_Float;

    --  Later minus Earlier.
    function Seconds_Between
           (Earlier, Later : in Timestamp)
        return Long_Float;

    --  In sixtieths of a second (Fl_Timeout.cxx).
    function Ticks_Since
           (Moment : in Timestamp)
        return Long_Integer;

    function Ticks_Between
           (Earlier, Later : in Timestamp)
        return Long_Integer;




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

    --  How FLTK.Contrast chooses.  CIELAB_Contrast is the default.
    function Get_Contrast_Mode
        return Contrast_Mode;

    procedure Set_Contrast_Mode
           (To : in Contrast_Mode);

    --  How strongly FLTK.Contrast prefers black or white.  Each mode keeps
    --  its own level: Legacy_Contrast 50 and CIELAB_Contrast 39 to start
    --  (fl_contrast.cxx:37-43), so set the mode first.
    function Get_Contrast_Level
        return Contrast_Level;

    procedure Set_Contrast_Level
           (To : in Contrast_Level);

    --  Null takes the function away.  Custom_Contrast then uses CIELAB's
    --  method, but with Custom_Contrast's own level, which is 0 to start:
    --  Contrast returns Fore until that level is set (FLTK-issues.md F12).
    --  An exception from Func is raised again from the
    --  next event loop call, and Contrast returns Fore meanwhile.
    procedure Set_Contrast_Function
           (Func : in Contrast_Function);

    --  Reads a colour given as #rgb, #rrggbb, #rrrgggbbb or #rrrrggggbbbb (the
    --  # can be left out), or under X11 as a name the X server knows, such
    --  as "red".  Wayland reads hexadecimal alone (pofltk 47).  Returns
    --  whether it could; R, G and B are unchanged if not.
    function Parse_Color
           (Name    : in     String;
            R, G, B : in out Color_Component)
        return Boolean;

    procedure Get_Color
           (From       : in     Color;
            R, G, B, A :    out Color_Component);

    procedure Set_Color
           (Target     : in Color;
            R, G, B, A : in Color_Component);




    --  Custom Fonts  --

    --  Fonts are numbered from 0 to Last_Font.  Every subprogram that takes
    --  a font, here and elsewhere, raises Constraint_Error on one past
    --  Last_Font (pofltk 130).  Setup_Fonts and Set_Font_Kind (Target, ...)
    --  raise Last_Font, and Set_Font_Kind takes a Target up to Max_Font;
    --  the fonts in any gap this leaves are empty.

    --  Free_Font is empty, and its images are "", until it is set.  Using
    --  it here, or in FLTK.Draw, first opens the display.  A widget's font
    --  is checked only against Last_Font: set Free_Font before a widget
    --  draws in it (pofltk 130).

    Max_Font : constant Font_Kind := 65_535;

    function Last_Font
        return Font_Kind;

    --  What Fl::get_font_name gives as the font's attributes.
    type Font_Attributes is record
        Bold   : Boolean := False;
        Italic : Boolean := False;
    end record;

    function Font_Image
           (Kind : in Font_Kind)
        return String;

    function Font_Family_Image
           (Kind : in Font_Kind)
        return String;

    --  Plain for an empty font.
    function Font_Family_Attributes
           (Kind : in Font_Kind)
        return Font_Attributes;

    --  Target gets its own copy of Source's name.
    procedure Set_Font_Kind
           (Target, Source : in Font_Kind);

    --  Source is cut to 126 bytes, before any UTF-8 character that would
    --  cross that (pofltk 130).  Raises Constraint_Error if Target is past
    --  Max_Font.
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

    --  The largest corner radius of the rounded box kinds, at least 5
    --  (Fl.H:188).
    function Get_Box_Border_Radius_Max
        return Integer;

    procedure Set_Box_Border_Radius_Max
           (To : in Integer);

    --  The width of the shadow box kinds' shadow, at least 1 (Fl.H:170).
    function Get_Box_Shadow_Width
        return Integer;

    procedure Set_Box_Shadow_Width
           (To : in Integer);

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

    --  Wayland has no selection buffer.  There, Copy to Selection keeps the
    --  text but offers it to no one, and Paste from Selection does nothing
    --  (fl_wayland_clipboard_dnd.cxx:617-618, 659-686, pofltk 50).  X11 has
    --  both, and Clipboard works on both.
    procedure Copy
           (Text : in String;
            Dest : in Buffer_Kind);

    --  Copies Text to the clipboard and the selection buffer at once, as
    --  Fl::copy's destination 2 does.  On Wayland, which has no selection
    --  buffer, it is Copy to Clipboard (fl_wayland_clipboard_dnd.cxx:663-664;
    --  Fl_x.cxx:830-833).
    procedure Copy_To_Both
           (Text : in String);

    procedure Paste
           (Receiver : in FLTK.Widgets.Widget'Class;
            Source   : in Buffer_Kind);

    --  Sends Receiver a Paste event carrying the image on the clipboard, if
    --  there is one: at once if this program copied it, else later or
    --  never, as for Paste.  Its Handle takes the image with
    --  FLTK.Images.RGB.Forge.Pasted.
    procedure Paste_Image
           (Receiver : in FLTK.Widgets.Widget'Class);

    --  The widget that owned the selection before is not sent
    --  Selection_Clear: FLTK never sends it (pofltk 132).
    procedure Selection
           (Owner : in FLTK.Widgets.Widget'Class;
            Text  : in String);

    function Clipboard_Contains
           (Kind : in String)
        return Boolean;

    --  The widget that owns the selection: the last one given to Selection
    --  or to Set_Selection_Owner.  Null if none is, or if the owner isn't
    --  an FLTKAda widget.  FLTKAda clears it when the owner is deleted
    --  (pofltk 129).
    function Get_Selection_Owner
        return access FLTK.Widgets.Widget'Class;

    --  Only records the owner (Fl.cxx:1639); Selection also copies the text.
    procedure Set_Selection_Owner
           (To : in FLTK.Widgets.Widget'Class);

    procedure Clear_Selection_Owner;

    --  Whether text copied to the selection is copied to the clipboard too.
    function Get_Selection_To_Clipboard
        return Boolean;

    procedure Set_Selection_To_Clipboard
           (To : in Boolean);




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

    --  The shown windows, most recently active first.  A window FLTK made,
    --  such as a file chooser's or a dialog's, has no Ada object, and is
    --  skipped.  Get_Next_Window of a window not shown is null.
    function Get_First_Window
        return access FLTK.Widgets.Groups.Windows.Window'Class;

    procedure Set_First_Window
           (To : in FLTK.Widgets.Groups.Windows.Window'Class);

    function Get_Next_Window
           (From : in FLTK.Widgets.Groups.Windows.Window'Class)
        return access FLTK.Widgets.Groups.Windows.Window'Class;

    --  Null too when the top modal window is one FLTK made.
    function Get_Top_Modal
        return access FLTK.Widgets.Groups.Windows.Window'Class;




    --  Callback Reasons  --

    --  Why the callback that is running was called.  FLTK sets it before a
    --  widget's callback, and leaves it set after.  Do_Callback calls the
    --  Ada callback directly, and so leaves it as it was.
    function Get_Callback_Reason
        return Callback_Reason;




    --  Menus  --

    --  The space between menu items, in pixels; 4 by default (Fl.cxx:64).
    function Get_Menu_Line_Spacing
        return Integer;

    procedure Set_Menu_Line_Spacing
           (To : in Integer);




    --  Queue  --

    function Read_Queue
        return access FLTK.Widgets.Widget'Class;




    --  Schemes  --

    function Get_Scheme
        return String;

    --  Also sets the environment variable FLTK_SCHEME to the scheme
    --  chosen, or to "" for none, which a program this one starts inherits
    --  (Fl_get_system_colors.cxx:217, pofltk 156).  Names are
    --  case-insensitive, and an unknown one is no scheme.
    procedure Set_Scheme
           (To : in String);

    --  Fl::scheme (NULL): sets the scheme the environment asks for.  That
    --  is the environment variable FLTK_SCHEME, then on X11 only the X
    --  resource <class>.scheme (Fl_get_system_colors.cxx:196, pofltk 156).
    --  Set_Scheme sets FLTK_SCHEME too, so call this before any Set_Scheme
    --  to get what the user asked for.
    procedure Set_System_Scheme;

    function Is_Scheme
           (Scheme : in String)
        return Boolean;

    procedure Reload_Scheme;

    --  The schemes Set_Scheme knows, numbered from 1: "base", "plastic",
    --  "gtk+", "gleam" and "oxy", then any Add_Scheme_Name added
    --  (Fl_Scheme.cxx).
    function Scheme_Count
        return Natural;

    --  Index outside 1 .. Scheme_Count raises Constraint_Error.
    function Scheme_Name
           (Index : in Positive)
        return String;

    --  Adds a name to the list, for a scheme a program draws itself.  Names
    --  are up to 12 characters of a .. z, 0 .. 9, $, +, _ and "."; another
    --  raises Constraint_Error.  Returns False if the name is already
    --  there.  FLTK keeps a copy of the name until the program ends
    --  (Fl_Scheme.cxx:106-153).
    function Add_Scheme_Name
           (Name : in String)
        return Boolean;




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


    type Timestamp is record
        Sec  : Long_Long_Integer := 0;
        Usec : Interfaces.C.int  := 0;
    end record;


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


    --  The names given to Set_Font_Kind, which FLTK keeps (bug 33).
    package Font_Name_Maps is new Ada.Containers.Ordered_Maps
       (Key_Type     => Font_Kind,
        Element_Type => Interfaces.C.Strings.chars_ptr,
        "="          => Interfaces.C.Strings."=");

    Font_Overrides : Font_Name_Maps.Map;


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

    pragma Inline (Last_Font);
    pragma Inline (Font_Image);
    pragma Inline (Font_Family_Image);
    pragma Inline (Font_Family_Attributes);
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
    pragma Inline (Copy_To_Both);
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
    pragma Inline (Set_System_Scheme);
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


