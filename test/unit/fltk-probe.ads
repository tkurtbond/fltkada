

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  For the unit tests only: a widget's pixels, events sent as if from the
--  user, and a few things about this FLTK.  The C++ part is c_probe.cpp.
--  Neither is part of the library: tests_unit.gpr compiles them (PLAN.md,
--  "Architecture decisions", 6).  Ported from pofltk's test/Probe.Mod.
--
--  It is a child of FLTK so that it can reach a widget's C++ object.


with

    FLTK.Widgets.Groups.Windows;


package FLTK.Probe is


    --  Pixels  --

    --  A pixel as 16#RRGGBB#, or -1 for none.
    subtype RGB is Integer range -1 .. 16#FF_FFFF#;

    function To_RGB
           (R, G, B : in Natural)
        return RGB;

    --  Draws Item as FLTK would in its window, on white, into an image of
    --  its size, for Pixel.  The window need not be shown.  True if the
    --  image is Item's size.
    function Capture
           (Item : in FLTK.Widgets.Widget'Class)
        return Boolean;

    --  Pixel X, Y of the last capture, from the widget's top left; -1
    --  outside it.
    function Pixel
           (X, Y : in Integer)
        return RGB;

    --  Frees the last capture.
    procedure Release;

    --  Pixel X, Y of what shown window Item shows.  Works on X11 and
    --  Wayland, where a capture would draw the window anew.
    function Shown_Pixel
           (Item : in FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y : in Integer)
        return RGB;




    --  Events  --

    --  Each sends an event as if from the window system, and returns True
    --  if a widget used it.  X and Y are in Win's coordinates.

    --  A push on a button takes the focus, and on X11 with no window manager
    --  that supports EWMH, such as bare Xvfb, giving the focus shows a window
    --  never shown (Fl_X11_Window_Driver::take_focus; pofltk 176).  So a test
    --  that checks a window stays hidden after a push should clear the
    --  button's visible focus first.  Under Wayland it stays hidden.

    function Mouse
           (Win    : in FLTK.Widgets.Groups.Windows.Window'Class;
            Event  : in Event_Kind;
            X, Y   : in Integer;
            Button : in Mouse_Button := Left_Button;
            State  : in Modifier     := Mod_None;
            Clicks : in Natural      := 0)
        return Boolean;

    function Wheel
           (Win    : in FLTK.Widgets.Groups.Windows.Window'Class;
            X, Y   : in Integer;
            DX, DY : in Integer)
        return Boolean;

    --  A Keydown or Keyup, typing Text, sent to the focus widget alone,
    --  which FLTK offers it first; False if there is no focus widget.
    function Key
           (Event : in Event_Kind;
            Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean;

    --  A key offered to Win's widgets as a shortcut, as FLTK offers one the
    --  focus doesn't use.
    function Shortcut
           (Win   : in FLTK.Widgets.Groups.Windows.Window'Class;
            Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean;

    --  A Keydown or Shortcut sent by FLTK's own route (Fl::handle): to a
    --  pop-up menu if one is up, else to Win's widgets and then a global
    --  menu.  Never a key no widget uses, after mouse events, in a window
    --  never shown: that crashes FLTK 1.4.5 (pofltk 3).
    function Handle_Key
           (Win   : in FLTK.Widgets.Groups.Windows.Window'Class;
            Event : in Event_Kind;
            Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean;

    --  Makes Code and Text the current event's key, without sending one.
    procedure Set_Key
           (Code : in Keypress;
            Text : in String := "");




    --  Dialogs  --

    --  True if a modal window, a dialog, is shown.
    function Modal
        return Boolean;

    --  True if a window has the grab (Fl::grab), even one FLTK made itself,
    --  such as a pop-up menu's, which FLTK.Events.Get_Grab gives as null.
    --  (FLTK.Events.Has_Grab now does the same; FLTKAda-BUGS.md 44.)
    function Grabbed
        return Boolean;

    --  How many windows FLTK has shown, counting its own, such as a
    --  tooltip's or a menu's.
    function Shown_Windows
        return Natural;

    --  The screen rectangle of the window that has the grab (an open menu's),
    --  with Found True, or Found False if none has.
    procedure Get_Grab
           (Found      :    out Boolean;
            X, Y, W, H :    out Integer);

    --  The title of the modal window shown, or "".
    function Modal_Title
        return String;

    --  The height of the modal window shown, or 0.
    function Modal_H
        return Natural;

    --  Where the modal window shown is, as FLTK has it, or 0.
    function Modal_X
        return Integer;

    function Modal_Y
        return Integer;

    --  The label of the icon of the message dialog shown (FLTK.Asks), or "".
    function Modal_Icon
        return String;

    --  A key sent to the modal window as if from the window system; False
    --  if none is shown.  Give a key the text the window system gives it:
    --  on Wayland, a key with no text is typed text to an input
    --  (Fl_Wayland_Screen_Driver::compose, Fl_Wayland_Screen_Driver.cxx:
    --  707-711), so an Enter with Text "" doesn't reach its callback there.
    function Modal_Key
           (Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean;

    --  A Keydown sent by Fl::handle to the window with the grab, such as a
    --  pop-up menu's, which FLTK made; False if nothing has the grab.
    function Grab_Key
           (Code  : in Keypress;
            State : in Modifier := Mod_None;
            Text  : in String   := "")
        return Boolean;

    --  Closes the modal window as an Escape no widget takes does, by its
    --  callback; False if none is shown.  On a headless sway, Modal_Key
    --  (Escape_Key) leaves a file chooser up though FLTK says it took the key.
    function Close_Modal
        return Boolean;

    --  Closes the modal window as its close button does, by FL_CLOSE; False
    --  if none is shown.
    function Close_Modal_Window
        return Boolean;

    --  Whether a widget in a shown window has Text as its label or tooltip.
    --  For a widget the binding doesn't expose, such as a chooser's parts.
    function Has_Label
           (Text : in String)
        return Boolean;

    --  Does the callback of the widget labelled Text in the modal window, not
    --  the window itself, as a click on a button does; False if there is none.
    function Press_In_Modal
           (Text : in String)
        return Boolean;

    --  Chooses Item, counted from 0 as FLTK does, in the menu labelled Text
    --  in the modal window, such as a choice, and does its callback; False if
    --  there is no such menu or item.
    function Choose_In_Modal
           (Text : in String;
            Item : in Natural)
        return Boolean;

    --  The text of the item chosen in the menu labelled Text in the modal
    --  window, or "" if there is none.
    function Chosen_In_Modal
           (Text : in String)
        return String;

    --  A window, with a button in it, that FLTK made with no Ada object
    --  (FLTKAda-BUGS.md 44).  Show_Foreign makes it, the first time, and
    --  shows it.  Take_Foreign gives the window the grab, or the button
    --  what What names; Release_Foreign takes them all away, and
    --  Delete_Foreign deletes the window.
    type Foreign_Kind is (Foreign_Grab, Foreign_Pushed, Foreign_Below_Mouse, Foreign_Focus);

    procedure Show_Foreign;

    procedure Take_Foreign
           (What : in Foreign_Kind);

    procedure Release_Foreign;

    procedure Delete_Foreign;

    --  With On, this process can start no other (RLIMIT_NPROC), so popen
    --  fails; with On False, it can again.  Raises Probe_Error if the limit
    --  can't be set.
    procedure Limit_Processes
           (On : in Boolean);

    --  A shown window's title as the X server has it.  Raises Probe_Error
    --  if not on X11 or the window isn't shown.
    function X11_Title
           (Item : in FLTK.Widgets.Groups.Windows.Window'Class)
        return String;

    --  The number of 32-bit words in a shown window's _NET_WM_ICON property,
    --  the icons FLTK gave the window manager:  for each, its width, its
    --  height and its pixels.  -1 if not on X11 or the window isn't shown.
    function Icon_Words
           (Item : in FLTK.Widgets.Groups.Windows.Window'Class)
        return Integer;

    --  Whether a Printer's Start_Job shows GTK's dialog (the default) or FLTK's
    --  own print panel.  Call it before the first Printer is made.
    procedure Set_Printer_Uses_GTK
           (On : in Boolean);




    --  This FLTK  --

    --  What fl_config.h says this FLTK was built with.
    function Has_SVG return Boolean;
    function Has_Wayland return Boolean;
    function Has_X11 return Boolean;
    function Has_Cairo return Boolean;
    function Has_Forms return Boolean;

    --  FLTK_USE_CAIRO: X11 draws with Cairo too, not only Wayland.
    function Uses_Cairo return Boolean;

    --  Opens the display, and returns True if FLTK is using Wayland.
    function On_Wayland
        return Boolean;

    --  The width of what FLTK's own Fl_Shared_Image::get makes of the file
    --  Name, or 0.
    function Shared_Width
           (Name : in String)
        return Natural;

    --  As if the window system told FLTK of another program's copy.
    procedure Clipboard_Notice
           (Source : in Integer);




    --  The process  --

    type File_Descriptor is new Integer;

    --  A pipe, for FLTK.Static's file descriptor watches.
    procedure Make_Pipe
           (Read_End, Write_End : out File_Descriptor);

    --  Writes Text to FD; the bytes written, or -1.
    function Write
           (FD   : in File_Descriptor;
            Text : in String)
        return Integer;

    --  Reads what FD has, up to Max bytes.
    function Read
           (FD  : in File_Descriptor;
            Max : in Positive := 256)
        return String;

    procedure Close
           (FD : in File_Descriptor);

    procedure Set_Env
           (Name, Value : in String);

    Probe_Error : exception;


end FLTK.Probe;

