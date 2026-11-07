

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups.Windows,
    System;

private with

    Ada.Finalization,
    System.Address_To_Access_Conversions;


package FLTK.Events is


    type Event_Handler is access function
           (Event : in Event_Kind)
        return Event_Outcome;

    type Event_Dispatch is access function
           (Event : in     Event_Kind;
            Win   : access FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome;


    type System_Event is new System.Address;

    type System_Handler is access function
           (Event : in System_Event)
        return Event_Outcome;




    --  Handlers  --

    procedure Add_Handler
           (Func : in not null Event_Handler);

    procedure Remove_Handler
           (Func : in not null Event_Handler);

    procedure Add_System_Handler
           (Func : in not null System_Handler);

    procedure Remove_System_Handler
           (Func : in not null System_Handler);




    --  Dispatch  --

    function Get_Dispatch
        return Event_Dispatch;

    --  Any Event_Dispatch function set must call Handle
    --  if you want the Event to actually be acknowledged.
    procedure Set_Dispatch
           (Func : in Event_Dispatch);

    function Handle_Dispatch
           (Event  : in     Event_Kind;
            Origin : in out FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome;

    function Handle
           (Event  : in     Event_Kind;
            Origin : in out FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome;

    --  These two accept the possibly null Win given to an Event_Dispatch
    --  function, since FLTK dispatches some events without a window, and
    --  gives it a window FLTK made itself, such as a pop-up menu's, as null.
    --  Inside an Event_Dispatch function a null Origin is the window FLTK
    --  gave the dispatch, so Handle (Event, Win) passes the event on to it;
    --  outside one it is no window.
    function Handle_Dispatch
           (Event  : in Event_Kind;
            Origin : access FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome;

    function Handle
           (Event  : in Event_Kind;
            Origin : access FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome;




    --  Receiving  --

    function Get_Grab
        return access FLTK.Widgets.Groups.Windows.Window'Class;

    --  Raises Program_Error if To is not shown (pofltk 129).  A window's
    --  grab is released when the window is finalized.
    procedure Set_Grab
           (To : in FLTK.Widgets.Groups.Windows.Window'Class);

    procedure Release_Grab;

    function Get_Pushed
        return access FLTK.Widgets.Widget'Class;

    procedure Set_Pushed
           (To : in FLTK.Widgets.Widget'Class);

    function Get_Below_Mouse
        return access FLTK.Widgets.Widget'Class;

    procedure Set_Below_Mouse
           (To : in FLTK.Widgets.Widget'Class);

    function Get_Focus
        return access FLTK.Widgets.Widget'Class;

    procedure Set_Focus
           (To : in FLTK.Widgets.Widget'Class);

    --  Leaves no widget with the focus, as Fl::focus (nullptr) does.  Like
    --  Set_Focus, it does nothing while a window has the grab.
    procedure Clear_Focus;

    function Has_Visible_Focus
        return Boolean;

    procedure Set_Visible_Focus
           (To : in Boolean);




    --  Clipboard  --

    --  In a Paste event, the text pasted, or "" if it is an image.
    function Clipboard_Text
        return String;

    --  In a Paste event, "text/plain" or "image".
    function Clipboard_Kind
        return String;

    --  In a Paste event, whether it carries an image, which
    --  FLTK.Images.RGB.Forge.Pasted takes.  An image not taken is deleted
    --  when the Handle that FLTK called returns, whatever it returned
    --  (pofltk 48).
    function Has_Clipboard_Image
        return Boolean;




    --  Multikey  --

    function Compose
           (Del : out Natural)
        return Boolean;

    procedure Compose_Reset;

    function Text
        return String;

    function Text_Length
        return Natural;

    --  Replaces the text of the current keyboard event, as an Event_Dispatch
    --  function might to translate a key before it is handled.
    procedure Set_Text
           (To : in String);

    function Test_Shortcut
           (Shortcut : in Key_Combo)
        return Boolean;




    --  Modifiers  --

    function Last
        return Event_Kind;

    --  Focuses on keyboard modifiers only, not mouse buttons
    function Last_Modifier
        return Modifier;

    --  Focuses on keyboard modifiers only, not mouse buttons
    function Last_Modifier
           (Had : in Modifier)
        return Boolean;




    --  Mouse  --

    function Mouse_X
        return Integer;

    function Mouse_X_Root
        return Integer;

    function Mouse_Y
        return Integer;

    function Mouse_Y_Root
        return Integer;

    function Mouse_DX
        return Integer;

    function Mouse_DY
        return Integer;

    procedure Get_Mouse
           (X, Y : out Integer);

    function Is_Click
        return Boolean;

    procedure Clear_Click;

    function Is_Multi_Click
        return Boolean;

    --  Returns the actual number of clicks.
    --  So no clicks is 0, a single click is 1, a double click is 2, etc.
    function Get_Clicks
        return Natural;

    --  Will set the actual number of clicks.
    --  This means setting it to 0 will make Is_Click return False.
    procedure Set_Clicks
           (To : in Natural);

    function Last_Button
        return Mouse_Button;

    function Mouse_Left
        return Boolean;

    function Mouse_Middle
        return Boolean;

    function Mouse_Right
        return Boolean;

    function Mouse_Back
        return Boolean;

    function Mouse_Forward
        return Boolean;

    procedure Mouse_Buttons
           (Left, Middle, Right, Back, Forward : out Boolean);

    function Is_Inside
           (Child : in FLTK.Widgets.Widget'Class)
        return Boolean;

    function Is_Inside
           (X, Y, W, H : in Integer)
        return Boolean;




    --  Keyboard  --

    function Last_Key
        return Keypress;

    function Original_Last_Key
        return Keypress;

    --  Replaces the key of the current keyboard event, as an Event_Dispatch
    --  function might to translate a key before it is handled.
    procedure Set_Last_Key
           (To : in Keypress);

    function Pressed_During
           (Key : in Keypress)
        return Boolean;

    function Key_Now
           (Key : in Keypress)
        return Boolean;

    function Key_Ctrl
        return Boolean;

    function Key_Alt
        return Boolean;

    function Key_Command
        return Boolean;

    function Key_Shift
        return Boolean;


private


    package Widget_Convert is new System.Address_To_Access_Conversions
        (FLTK.Widgets.Widget'Class);
    package Window_Convert is new System.Address_To_Access_Conversions
        (FLTK.Widgets.Groups.Windows.Window'Class);


    Current_Dispatch : Event_Dispatch := null;


    function fl_widget_get_user_data
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_get_user_data, "fl_widget_get_user_data");
    pragma Inline (fl_widget_get_user_data);


    pragma Import (C, Compose_Reset, "fl_event_compose_reset");


    pragma Inline (Add_Handler);
    pragma Inline (Remove_Handler);
    pragma Inline (Add_System_Handler);
    pragma Inline (Remove_System_Handler);

    pragma Inline (Get_Dispatch);
    pragma Inline (Set_Dispatch);
    pragma Inline (Handle_Dispatch);
    pragma Inline (Handle);

    pragma Inline (Get_Grab);
    pragma Inline (Set_Grab);
    pragma Inline (Release_Grab);
    pragma Inline (Get_Pushed);
    pragma Inline (Set_Pushed);
    pragma Inline (Get_Below_Mouse);
    pragma Inline (Set_Below_Mouse);
    pragma Inline (Get_Focus);
    pragma Inline (Set_Focus);
    pragma Inline (Clear_Focus);
    pragma Inline (Has_Visible_Focus);
    pragma Inline (Set_Visible_Focus);

    pragma Inline (Clipboard_Text);
    pragma Inline (Clipboard_Kind);
    pragma Inline (Has_Clipboard_Image);

    pragma Inline (Compose);
    pragma Inline (Compose_Reset);
    pragma Inline (Text);
    pragma Inline (Text_Length);
    pragma Inline (Set_Text);
    pragma Inline (Test_Shortcut);

    pragma Inline (Last);
    pragma Inline (Last_Modifier);

    pragma Inline (Mouse_X);
    pragma Inline (Mouse_X_Root);
    pragma Inline (Mouse_Y);
    pragma Inline (Mouse_Y_Root);
    pragma Inline (Mouse_DX);
    pragma Inline (Mouse_DY);
    pragma Inline (Get_Mouse);
    pragma Inline (Is_Click);
    pragma Inline (Clear_Click);
    pragma Inline (Is_Multi_Click);
    pragma Inline (Get_Clicks);
    pragma Inline (Set_Clicks);
    pragma Inline (Mouse_Left);
    pragma Inline (Mouse_Middle);
    pragma Inline (Mouse_Right);
    pragma Inline (Mouse_Back);
    pragma Inline (Mouse_Forward);
    pragma Inline (Is_Inside);

    pragma Inline (Last_Key);
    pragma Inline (Original_Last_Key);
    pragma Inline (Set_Last_Key);
    pragma Inline (Pressed_During);
    pragma Inline (Key_Now);
    pragma Inline (Key_Ctrl);
    pragma Inline (Key_Alt);
    pragma Inline (Key_Command);
    pragma Inline (Key_Shift);


    --  Needed to deregister the handlers
    type FLTK_Events_Final_Controller is new Ada.Finalization.Limited_Controlled with null record;

    overriding procedure Finalize
           (This : in out FLTK_Events_Final_Controller);

    Cleanup : FLTK_Events_Final_Controller;


end FLTK.Events;


