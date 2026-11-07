

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Assertions,
    Ada.Containers.Vectors,
    FLTK.Hook_Exceptions,
    Interfaces.C.Strings;

use type

    Interfaces.C.int,
    Interfaces.C.Strings.chars_ptr;


package body FLTK.Events is


    package Chk renames Ada.Assertions;




    ------------------------
    --  Constants From C  --
    ------------------------

    fl_enum_button1 : constant Interfaces.C.int;
    pragma Import (C, fl_enum_button1, "fl_enum_button1");

    fl_enum_button2 : constant Interfaces.C.int;
    pragma Import (C, fl_enum_button2, "fl_enum_button2");

    fl_enum_button3 : constant Interfaces.C.int;
    pragma Import (C, fl_enum_button3, "fl_enum_button3");

    fl_enum_button4 : constant Interfaces.C.int;
    pragma Import (C, fl_enum_button4, "fl_enum_button4");

    fl_enum_button5 : constant Interfaces.C.int;
    pragma Import (C, fl_enum_button5, "fl_enum_button5");

    fl_enum_left_mouse : constant Interfaces.C.int;
    pragma Import (C, fl_enum_left_mouse, "fl_enum_left_mouse");

    fl_enum_middle_mouse : constant Interfaces.C.int;
    pragma Import (C, fl_enum_middle_mouse, "fl_enum_middle_mouse");

    fl_enum_right_mouse : constant Interfaces.C.int;
    pragma Import (C, fl_enum_right_mouse, "fl_enum_right_mouse");

    fl_enum_back_mouse : constant Interfaces.C.int;
    pragma Import (C, fl_enum_back_mouse, "fl_enum_back_mouse");

    fl_enum_forward_mouse : constant Interfaces.C.int;
    pragma Import (C, fl_enum_forward_mouse, "fl_enum_forward_mouse");




    ------------------------
    --  Functions From C  --
    ------------------------

    --  Handlers  --

    procedure fl_event_add_handler
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_event_add_handler, "fl_event_add_handler");
    pragma Inline (fl_event_add_handler);

    procedure fl_event_remove_handler
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_event_remove_handler, "fl_event_remove_handler");
    pragma Inline (fl_event_remove_handler);

    procedure fl_event_add_system_handler
           (H, F : in Storage.Integer_Address);
    pragma Import (C, fl_event_add_system_handler, "fl_event_add_system_handler");
    pragma Inline (fl_event_add_system_handler);

    procedure fl_event_remove_system_handler
           (H : in Storage.Integer_Address);
    pragma Import (C, fl_event_remove_system_handler, "fl_event_remove_system_handler");
    pragma Inline (fl_event_remove_system_handler);




    --  Dispatch  --

    procedure fl_event_set_dispatch
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_event_set_dispatch, "fl_event_set_dispatch");
    pragma Inline (fl_event_set_dispatch);

    function fl_event_handle_dispatch
           (E : in Interfaces.C.int;
            W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_event_handle_dispatch, "fl_event_handle_dispatch");
    pragma Inline (fl_event_handle_dispatch);

    function fl_event_handle
           (E : in Interfaces.C.int;
            W : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_event_handle, "fl_event_handle");
    pragma Inline (fl_event_handle);




    --  Receiving  --

    function fl_event_get_grab
        return Storage.Integer_Address;
    pragma Import (C, fl_event_get_grab, "fl_event_get_grab");
    pragma Inline (fl_event_get_grab);

    function fl_event_set_grab
           (T : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_event_set_grab, "fl_event_set_grab");
    pragma Inline (fl_event_set_grab);

    function fl_event_get_pushed
        return Storage.Integer_Address;
    pragma Import (C, fl_event_get_pushed, "fl_event_get_pushed");
    pragma Inline (fl_event_get_pushed);

    procedure fl_event_set_pushed
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_event_set_pushed, "fl_event_set_pushed");
    pragma Inline (fl_event_set_pushed);

    function fl_event_get_belowmouse
        return Storage.Integer_Address;
    pragma Import (C, fl_event_get_belowmouse, "fl_event_get_belowmouse");
    pragma Inline (fl_event_get_belowmouse);

    procedure fl_event_set_belowmouse
           (T : in Storage.Integer_Address);
    pragma Import (C, fl_event_set_belowmouse, "fl_event_set_belowmouse");
    pragma Inline (fl_event_set_belowmouse);

    function fl_event_get_focus
        return Storage.Integer_Address;
    pragma Import (C, fl_event_get_focus, "fl_event_get_focus");
    pragma Inline (fl_event_get_focus);

    procedure fl_event_set_focus
           (To : in Storage.Integer_Address);
    pragma Import (C, fl_event_set_focus, "fl_event_set_focus");
    pragma Inline (fl_event_set_focus);

    function fl_event_get_visible_focus
        return Interfaces.C.int;
    pragma Import (C, fl_event_get_visible_focus, "fl_event_get_visible_focus");
    pragma Inline (fl_event_get_visible_focus);

    procedure fl_event_set_visible_focus
           (T : in Interfaces.C.int);
    pragma Import (C, fl_event_set_visible_focus, "fl_event_set_visible_focus");
    pragma Inline (fl_event_set_visible_focus);




    --  Clipboard  --

    function fl_event_clipboard_text
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_event_clipboard_text, "fl_event_clipboard_text");
    pragma Inline (fl_event_clipboard_text);

    function fl_event_clipboard_type
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_event_clipboard_type, "fl_event_clipboard_type");
    pragma Inline (fl_event_clipboard_type);

    function fl_event_clipboard_length
        return Interfaces.C.int;
    pragma Import (C, fl_event_clipboard_length, "fl_event_clipboard_length");
    pragma Inline (fl_event_clipboard_length);

    function fl_event_has_clipboard_image
        return Interfaces.C.int;
    pragma Import (C, fl_event_has_clipboard_image, "fl_event_has_clipboard_image");
    pragma Inline (fl_event_has_clipboard_image);




    --  Multikey  --

    function fl_event_compose
           (D : out Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_event_compose, "fl_event_compose");
    pragma Inline (fl_event_compose);

    function fl_event_text
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_event_text, "fl_event_text");
    pragma Inline (fl_event_text);

    function fl_event_length
        return Interfaces.C.int;
    pragma Import (C, fl_event_length, "fl_event_length");
    pragma Inline (fl_event_length);

    procedure fl_event_set_text
           (T : in Interfaces.C.char_array;
            L : in Interfaces.C.int);
    pragma Import (C, fl_event_set_text, "fl_event_set_text");
    pragma Inline (fl_event_set_text);

    function fl_event_test_shortcut
           (S : in Interfaces.C.unsigned)
        return Interfaces.C.int;
    pragma Import (C, fl_event_test_shortcut, "fl_event_test_shortcut");
    pragma Inline (fl_event_test_shortcut);




    --  Modifiers  --

    function fl_event_get
        return Interfaces.C.int;
    pragma Import (C, fl_event_get, "fl_event_get");
    pragma Inline (fl_event_get);

    function fl_event_state
        return Interfaces.C.int;
    pragma Import (C, fl_event_state, "fl_event_state");
    pragma Inline (fl_event_state);

    function fl_event_check_state
           (S : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_event_check_state, "fl_event_check_state");
    pragma Inline (fl_event_check_state);




    --  Mouse  --

    function fl_event_x
        return Interfaces.C.int;
    pragma Import (C, fl_event_x, "fl_event_x");
    pragma Inline (fl_event_x);

    function fl_event_x_root
        return Interfaces.C.int;
    pragma Import (C, fl_event_x_root, "fl_event_x_root");
    pragma Inline (fl_event_x_root);

    function fl_event_y
        return Interfaces.C.int;
    pragma Import (C, fl_event_y, "fl_event_y");
    pragma Inline (fl_event_y);

    function fl_event_y_root
        return Interfaces.C.int;
    pragma Import (C, fl_event_y_root, "fl_event_y_root");
    pragma Inline (fl_event_y_root);

    function fl_event_dx
        return Interfaces.C.int;
    pragma Import (C, fl_event_dx, "fl_event_dx");
    pragma Inline (fl_event_dx);

    function fl_event_dy
        return Interfaces.C.int;
    pragma Import (C, fl_event_dy, "fl_event_dy");
    pragma Inline (fl_event_dy);

    procedure fl_event_get_mouse
           (X, Y : out Interfaces.C.int);
    pragma Import (C, fl_event_get_mouse, "fl_event_get_mouse");
    pragma Inline (fl_event_get_mouse);

    function fl_event_is_click
        return Interfaces.C.int;
    pragma Import (C, fl_event_is_click, "fl_event_is_click");
    pragma Inline (fl_event_is_click);

    procedure fl_event_set_click
           (C : in Interfaces.C.int);
    pragma Import (C, fl_event_set_click, "fl_event_set_click");
    pragma Inline (fl_event_set_click);

    function fl_event_get_clicks
        return Interfaces.C.int;
    pragma Import (C, fl_event_get_clicks, "fl_event_get_clicks");
    pragma Inline (fl_event_get_clicks);

    procedure fl_event_set_clicks
           (C : in Interfaces.C.int);
    pragma Import (C, fl_event_set_clicks, "fl_event_set_clicks");
    pragma Inline (fl_event_set_clicks);

    function fl_event_button
        return Interfaces.C.int;
    pragma Import (C, fl_event_button, "fl_event_button");
    pragma Inline (fl_event_button);

    function fl_event_button1
        return Interfaces.C.int;
    pragma Import (C, fl_event_button1, "fl_event_button1");
    pragma Inline (fl_event_button1);

    function fl_event_button2
        return Interfaces.C.int;
    pragma Import (C, fl_event_button2, "fl_event_button2");
    pragma Inline (fl_event_button2);

    function fl_event_button3
        return Interfaces.C.int;
    pragma Import (C, fl_event_button3, "fl_event_button3");
    pragma Inline (fl_event_button3);

    function fl_event_button4
        return Interfaces.C.int;
    pragma Import (C, fl_event_button4, "fl_event_button4");
    pragma Inline (fl_event_button4);

    function fl_event_button5
        return Interfaces.C.int;
    pragma Import (C, fl_event_button5, "fl_event_button5");
    pragma Inline (fl_event_button5);

    function fl_event_buttons
        return Interfaces.C.int;
    pragma Import (C, fl_event_buttons, "fl_event_buttons");
    pragma Inline (fl_event_buttons);

    function fl_event_inside2
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_event_inside2, "fl_event_inside2");
    pragma Inline (fl_event_inside2);

    function fl_event_inside
           (X, Y, W, H : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_event_inside, "fl_event_inside");
    pragma Inline (fl_event_inside);




    --  Keyboard  --

    function fl_event_key
        return Interfaces.C.int;
    pragma Import (C, fl_event_key, "fl_event_key");
    pragma Inline (fl_event_key);

    function fl_event_original_key
        return Interfaces.C.int;
    pragma Import (C, fl_event_original_key, "fl_event_original_key");
    pragma Inline (fl_event_original_key);

    procedure fl_event_set_key
           (K : in Interfaces.C.int);
    pragma Import (C, fl_event_set_key, "fl_event_set_key");
    pragma Inline (fl_event_set_key);

    function fl_event_key_during
           (K : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_event_key_during, "fl_event_key_during");
    pragma Inline (fl_event_key_during);

    function fl_event_get_key
           (K : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_event_get_key, "fl_event_get_key");
    pragma Inline (fl_event_get_key);

    function fl_event_ctrl
        return Interfaces.C.int;
    pragma Import (C, fl_event_ctrl, "fl_event_ctrl");
    pragma Inline (fl_event_ctrl);

    function fl_event_alt
        return Interfaces.C.int;
    pragma Import (C, fl_event_alt, "fl_event_alt");
    pragma Inline (fl_event_alt);

    function fl_event_command
        return Interfaces.C.int;
    pragma Import (C, fl_event_command, "fl_event_command");
    pragma Inline (fl_event_command);

    function fl_event_shift
        return Interfaces.C.int;
    pragma Import (C, fl_event_shift, "fl_event_shift");
    pragma Inline (fl_event_shift);




    -------------
    --  Hooks  --
    -------------

    --  This is handled on the Ada side since otherwise marshalling the
    --  types from C++ to Ada would be extremely difficult. This hook is
    --  passed during package init.
    package Handler_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Event_Handler);

    Handlers : Handler_Vectors.Vector;

    --  Whether FLTK's Num is an Event_Kind, checked before converting it so
    --  that a Constraint_Error raised by the program's own code isn't taken
    --  for FLTK's (FLTKAda-BUGS.md 45).
    function Is_Event
           (Num : in Interfaces.C.int)
        return Boolean is
    begin
        return Num in Event_Kind'Pos (Event_Kind'First) .. Event_Kind'Pos (Event_Kind'Last);
    end Is_Event;

    function Event_Handler_Hook
           (Num : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Convention (C, Event_Handler_Hook);

    function Event_Handler_Hook
           (Num : in Interfaces.C.int)
        return Interfaces.C.int
    is
        Mark    : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        --  A copy, so that a handler can add or remove handlers.  Those it
        --  removes are still called for this event, and those it adds
        --  aren't.
        Current : constant Handler_Vectors.Vector := Handlers;
    begin
        if not Is_Event (Num) then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "Event_Handler hook received unexpected event int value of " &
                Interfaces.C.int'Image (Num));
            return 0;
        end if;
        for Call of reverse Current loop
            if Call (Event_Kind'Val (Num)) /= Not_Handled then
                return Event_Outcome'Pos (Handled);
            end if;
        end loop;
        return Event_Outcome'Pos (Not_Handled);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Event_Handler_Hook;


    --  This is handled on the Ada side because otherwise there would be
    --  no way to specify which callback to remove in FLTK once one was
    --  added. This is because Fl::remove_system_handler does not pay
    --  attention to the void * data. This hook is passed during package init.
    package System_Handler_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => System_Handler);

    System_Handlers : System_Handler_Vectors.Vector;

    function System_Handler_Hook
           (E, U : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Convention (C, System_Handler_Hook);

    function System_Handler_Hook
           (E, U : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark    : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        --  A copy, as in Event_Handler_Hook.
        Current : constant System_Handler_Vectors.Vector := System_Handlers;
    begin
        for Call of reverse Current loop
            if Call (System_Event (Storage.To_Address (E))) = Handled then
                return Event_Outcome'Pos (Handled);
            end if;
        end loop;
        return Event_Outcome'Pos (Not_Handled);
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end System_Handler_Hook;


    --  The window FLTK gave the dispatch function running, which Handle and
    --  Handle_Dispatch use for a null Origin.  It may be one FLTK made, such
    --  as a pop-up menu's, which the dispatch function is given as null.
    Dispatch_Window : Storage.Integer_Address := Null_Pointer;

    function Dispatch_Hook
           (Num : in Interfaces.C.int;
            Ptr : in Storage.Integer_Address)
        return Interfaces.C.int
    is
        Mark    : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Ptr : Storage.Integer_Address := Null_Pointer;
        Actual_Window : access FLTK.Widgets.Groups.Windows.Window'Class;
        Outer : constant Storage.Integer_Address := Dispatch_Window;
        Result : Event_Outcome;
    begin
        if not Is_Event (Num) then
            Hook_Exceptions.Save_New
               (Internal_FLTK_Error'Identity,
                "Event_Dispatch hook received unexpected event int value of " &
                Interfaces.C.int'Image (Num));
            return 0;
        end if;
        if Ptr /= Null_Pointer then
            Ada_Ptr := fl_widget_get_user_data (Ptr);
        end if;
        if Ada_Ptr /= Null_Pointer then
            Actual_Window := Window_Convert.To_Pointer (Storage.To_Address (Ada_Ptr));
        end if;
        Dispatch_Window := Ptr;
        Result := Current_Dispatch (Event_Kind'Val (Num), Actual_Window);
        Dispatch_Window := Outer;
        return Event_Outcome'Pos (Result);
    exception
    when Occurrence : others =>
        Dispatch_Window := Outer;
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Dispatch_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out FLTK_Events_Final_Controller) is
    begin
        fl_event_remove_handler (Storage.To_Integer (Event_Handler_Hook'Address));
        fl_event_remove_system_handler (Storage.To_Integer (System_Handler_Hook'Address));
    end Finalize;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Handlers  --

    procedure Add_Handler
           (Func : in not null Event_Handler) is
    begin
        Handlers.Append (Func);
    end Add_Handler;


    procedure Remove_Handler
           (Func : in not null Event_Handler) is
    begin
        for I in reverse Handlers.First_Index .. Handlers.Last_Index loop
            if Handlers (I) = Func then
                Handlers.Delete (I);
                return;
            end if;
        end loop;
    end Remove_Handler;


    procedure Add_System_Handler
           (Func : in not null System_Handler) is
    begin
        System_Handlers.Append (Func);
    end Add_System_Handler;


    procedure Remove_System_Handler
           (Func : in not null System_Handler) is
    begin
        for I in reverse System_Handlers.First_Index .. System_Handlers.Last_Index loop
            if System_Handlers (I) = Func then
                System_Handlers.Delete (I);
                return;
            end if;
        end loop;
    end Remove_System_Handler;




    --  Dispatch  --

    function Get_Dispatch
        return Event_Dispatch is
    begin
        return Current_Dispatch;
    end Get_Dispatch;


    procedure Set_Dispatch
           (Func : in Event_Dispatch) is
    begin
        Current_Dispatch := Func;
        if Current_Dispatch /= null then
            fl_event_set_dispatch (Storage.To_Integer (Dispatch_Hook'Address));
        else
            fl_event_set_dispatch (Null_Pointer);
        end if;
    end Set_Dispatch;


    function Handle_Dispatch
           (Event  : in     Event_Kind;
            Origin : in out FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome
    is
        Result : constant Interfaces.C.int := fl_event_handle_dispatch
           (Event_Kind'Pos (Event),
            Wrapper (Origin).Void_Ptr);
    begin
        Hook_Exceptions.Reraise;
        return (if Result = 0 then Not_Handled else Handled);
    end Handle_Dispatch;


    function Handle
           (Event  : in     Event_Kind;
            Origin : in out FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome
    is
        Result : constant Interfaces.C.int := fl_event_handle
           (Event_Kind'Pos (Event),
            Wrapper (Origin).Void_Ptr);
    begin
        Hook_Exceptions.Reraise;
        return (if Result = 0 then Not_Handled else Handled);
    end Handle;


    function Handle_Dispatch
           (Event  : in Event_Kind;
            Origin : access FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome
    is
        Result : constant Interfaces.C.int := fl_event_handle_dispatch
           (Event_Kind'Pos (Event),
            (if Origin = null then Dispatch_Window else Wrapper (Origin.all).Void_Ptr));
    begin
        Hook_Exceptions.Reraise;
        return (if Result = 0 then Not_Handled else Handled);
    end Handle_Dispatch;


    function Handle
           (Event  : in Event_Kind;
            Origin : access FLTK.Widgets.Groups.Windows.Window'Class)
        return Event_Outcome
    is
        Result : constant Interfaces.C.int := fl_event_handle
           (Event_Kind'Pos (Event),
            (if Origin = null then Dispatch_Window else Wrapper (Origin.all).Void_Ptr));
    begin
        Hook_Exceptions.Reraise;
        return (if Result = 0 then Not_Handled else Handled);
    end Handle;




    --  Receiving  --

    function Get_Grab
        return access FLTK.Widgets.Groups.Windows.Window'Class
    is
        Grab_Ptr : Storage.Integer_Address := fl_event_get_grab;
        Actual_Grab : access FLTK.Widgets.Groups.Windows.Window'Class;
    begin
        if Grab_Ptr /= Null_Pointer then
            Grab_Ptr := fl_widget_get_user_data (Grab_Ptr);
            pragma Assert (Grab_Ptr /= Null_Pointer);
            Actual_Grab := Window_Convert.To_Pointer (Storage.To_Address (Grab_Ptr));
        end if;
        return Actual_Grab;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::grab did not have user_data reference back to Ada";
    end Get_Grab;


    procedure Set_Grab
           (To : in FLTK.Widgets.Groups.Windows.Window'Class) is
    begin
        if fl_event_set_grab (Wrapper (To).Void_Ptr) = 0 then
            raise Program_Error with "Set_Grab on a window not shown";
        end if;
    end Set_Grab;


    procedure Release_Grab
    is
        Ignore : constant Interfaces.C.int := fl_event_set_grab (Null_Pointer);
    begin
        null;
    end Release_Grab;


    function Get_Pushed
        return access FLTK.Widgets.Widget'Class
    is
        Pushed_Ptr : Storage.Integer_Address := fl_event_get_pushed;
        Actual_Pushed : access FLTK.Widgets.Widget'Class;
    begin
        if Pushed_Ptr /= Null_Pointer then
            Pushed_Ptr := fl_widget_get_user_data (Pushed_Ptr);
            pragma Assert (Pushed_Ptr /= Null_Pointer);
            Actual_Pushed := Widget_Convert.To_Pointer (Storage.To_Address (Pushed_Ptr));
        end if;
        return Actual_Pushed;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::pushed did not have user_data reference back to Ada";
    end Get_Pushed;


    procedure Set_Pushed
           (To : in FLTK.Widgets.Widget'Class) is
    begin
        fl_event_set_pushed (Wrapper (To).Void_Ptr);
    end Set_Pushed;


    function Get_Below_Mouse
        return access FLTK.Widgets.Widget'Class
    is
        Below_Ptr : Storage.Integer_Address := fl_event_get_belowmouse;
        Actual_Below : access FLTK.Widgets.Widget'Class;
    begin
        if Below_Ptr /= Null_Pointer then
            Below_Ptr := fl_widget_get_user_data (Below_Ptr);
            pragma Assert (Below_Ptr /= Null_Pointer);
            Actual_Below := Widget_Convert.To_Pointer (Storage.To_Address (Below_Ptr));
        end if;
        return Actual_Below;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::belowmouse did not have user_data reference back to Ada";
    end Get_Below_Mouse;


    procedure Set_Below_Mouse
           (To : in FLTK.Widgets.Widget'Class) is
    begin
        fl_event_set_belowmouse (Wrapper (To).Void_Ptr);
    end Set_Below_Mouse;


    function Get_Focus
        return access FLTK.Widgets.Widget'Class
    is
        Focus_Ptr : Storage.Integer_Address := fl_event_get_focus;
        Actual_Focus : access FLTK.Widgets.Widget'Class;
    begin
        if Focus_Ptr /= Null_Pointer then
            Focus_Ptr := fl_widget_get_user_data (Focus_Ptr);
            pragma Assert (Focus_Ptr /= Null_Pointer);
            Actual_Focus := Widget_Convert.To_Pointer (Storage.To_Address (Focus_Ptr));
        end if;
        return Actual_Focus;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Widget returned by Fl::focus did not have user_data reference back to Ada";
    end Get_Focus;


    procedure Set_Focus
           (To : in FLTK.Widgets.Widget'Class) is
    begin
        fl_event_set_focus (Wrapper (To).Void_Ptr);
    end Set_Focus;


    procedure Clear_Focus is
    begin
        fl_event_set_focus (Null_Pointer);
    end Clear_Focus;


    function Has_Visible_Focus
        return Boolean is
    begin
        return fl_event_get_visible_focus /= 0;
    end Has_Visible_Focus;


    procedure Set_Visible_Focus
           (To : in Boolean) is
    begin
        fl_event_set_visible_focus (Boolean'Pos (To));
    end Set_Visible_Focus;




    --  Clipboard  --

    function Clipboard_Text
        return String
    is
        Text_Ptr : constant Interfaces.C.Strings.chars_ptr := fl_event_clipboard_text;
    begin
        if Text_Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value
                (Text_Ptr, Interfaces.C.size_t (fl_event_clipboard_length));
        end if;
    end Clipboard_Text;


    function Clipboard_Kind
        return String
    is
        Text_Ptr : constant Interfaces.C.Strings.chars_ptr := fl_event_clipboard_type;
    begin
        if Text_Ptr = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Text_Ptr);
        end if;
    end Clipboard_Kind;


    function Has_Clipboard_Image
        return Boolean is
    begin
        return fl_event_has_clipboard_image /= 0;
    end Has_Clipboard_Image;




    --  Multikey  --

    function Compose
           (Del : out Natural)
        return Boolean is
    begin
        return fl_event_compose (Interfaces.C.int (Del)) /= 0;
    end Compose;


    function Text
        return String
    is
        Str : constant Interfaces.C.Strings.chars_ptr := fl_event_text;
    begin
        if Str = Interfaces.C.Strings.Null_Ptr then
            return "";
        else
            return Interfaces.C.Strings.Value (Str, Interfaces.C.size_t (fl_event_length));
        end if;
    end Text;


    function Text_Length
        return Natural is
    begin
        return Natural (fl_event_length);
    end Text_Length;


    procedure Set_Text
           (To : in String) is
    begin
        fl_event_set_text (Interfaces.C.To_C (To), To'Length);
    end Set_Text;


    function Test_Shortcut
           (Shortcut : in Key_Combo)
        return Boolean is
    begin
        return fl_event_test_shortcut (To_C (Shortcut)) /= 0;
    end Test_Shortcut;




    --  Modifiers  --

    function Last
        return Event_Kind
    is
        Value : constant Interfaces.C.int := fl_event_get;
    begin
        return Event_Kind'Val (Value);
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::event returned unexpected int value of " & Interfaces.C.int'Image (Value);
    end Last;


    function Last_Modifier
        return Modifier is
    begin
        return To_Ada (Interfaces.C.unsigned (fl_event_state));
    end Last_Modifier;


    function Last_Modifier
           (Had : in Modifier)
        return Boolean is
    begin
        return fl_event_check_state (Interfaces.C.int (To_C (Had))) /= 0;
    end Last_Modifier;




    --  Mouse  --

    function Mouse_X
        return Integer is
    begin
        return Integer (fl_event_x);
    end Mouse_X;


    function Mouse_X_Root
        return Integer is
    begin
        return Integer (fl_event_x_root);
    end Mouse_X_Root;


    function Mouse_Y
        return Integer is
    begin
        return Integer (fl_event_y);
    end Mouse_Y;


    function Mouse_Y_Root
        return Integer is
    begin
        return Integer (fl_event_y_root);
    end Mouse_Y_Root;



    function Mouse_DX
        return Integer is
    begin
        return Integer (fl_event_dx);
    end Mouse_DX;


    function Mouse_DY
        return Integer is
    begin
        return Integer (fl_event_dy);
    end Mouse_DY;


    procedure Get_Mouse
           (X, Y : out Integer) is
    begin
        fl_event_get_mouse (Interfaces.C.int (X), Interfaces.C.int (Y));
    end Get_Mouse;


    function Is_Click
        return Boolean is
    begin
        return fl_event_is_click /= 0;
    end Is_Click;


    procedure Clear_Click is
    begin
        fl_event_set_click (0);
    end Clear_Click;


    function Is_Multi_Click
        return Boolean is
    begin
        return fl_event_get_clicks /= 0;
    end Is_Multi_Click;


    function Get_Clicks
        return Natural
    is
        Raw : constant Interfaces.C.int := fl_event_get_clicks;
    begin
        if Is_Click then
            return Positive (Raw + 1);
        else
            return 0;
        end if;
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::event_clicks returned unexpected int value of " &
        Interfaces.C.int'Image (Raw);
    end Get_Clicks;


    procedure Set_Clicks
           (To : in Natural) is
    begin
        if To = 0 then
            fl_event_set_clicks (0);
            Clear_Click;
        elsif To = 1 then
            fl_event_set_clicks (0);
        else
            fl_event_set_clicks (Interfaces.C.int (To) - 1);
        end if;
    end Set_Clicks;


    function Last_Button
        return Mouse_Button
    is
        Code : constant Interfaces.C.int := fl_event_button;
    begin
        pragma Assert (Last = Push or Last = Release);
        if Code = fl_enum_left_mouse then
            return Left_Button;
        elsif Code = fl_enum_middle_mouse then
            return Middle_Button;
        elsif Code = fl_enum_right_mouse then
            return Right_Button;
        elsif Code = fl_enum_back_mouse then
            return Back_Button;
        elsif Code = fl_enum_forward_mouse then
            return Forward_Button;
        else
            raise Internal_FLTK_Error with "Fl::event_button returned unexpected int value of " &
                Interfaces.C.int'Image (Code);
        end if;
    exception
    when Chk.Assertion_Error => raise Internal_FLTK_Error with
        "Fl::event_button was called when the most recent event was not Push or Release";
    end Last_Button;


    function Mouse_Left
        return Boolean is
    begin
        return fl_event_button1 /= 0;
    end Mouse_Left;


    function Mouse_Middle
        return Boolean is
    begin
        return fl_event_button2 /= 0;
    end Mouse_Middle;


    function Mouse_Right
        return Boolean is
    begin
        return fl_event_button3 /= 0;
    end Mouse_Right;


    function Mouse_Back
        return Boolean is
    begin
        return fl_event_button4 /= 0;
    end Mouse_Back;


    function Mouse_Forward
        return Boolean is
    begin
        return fl_event_button5 /= 0;
    end Mouse_Forward;


    procedure Mouse_Buttons
           (Left, Middle, Right, Back, Forward : out Boolean)
    is
        type Cint_Mod is mod 2 ** Interfaces.C.int'Size;
        Mask : constant Interfaces.C.int := fl_event_buttons;
    begin
        Left    := (Cint_Mod (Mask) and Cint_Mod (fl_enum_button1)) /= 0;
        Middle  := (Cint_Mod (Mask) and Cint_Mod (fl_enum_button2)) /= 0;
        Right   := (Cint_Mod (Mask) and Cint_Mod (fl_enum_button3)) /= 0;
        Back    := (Cint_Mod (Mask) and Cint_Mod (fl_enum_button4)) /= 0;
        Forward := (Cint_Mod (Mask) and Cint_Mod (fl_enum_button5)) /= 0;
    exception
    when Constraint_Error => raise Internal_FLTK_Error with
        "Fl::event_buttons returned unexpected int value of " &
        Interfaces.C.int'Image (Mask);
    end Mouse_Buttons;


    function Is_Inside
           (Child : in FLTK.Widgets.Widget'Class)
        return Boolean is
    begin
        return fl_event_inside2 (Wrapper (Child).Void_Ptr) /= 0;
    end Is_Inside;


    function Is_Inside
           (X, Y, W, H : in Integer)
        return Boolean is
    begin
        return fl_event_inside
           (Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H)) /= 0;
    end Is_Inside;




    --  Keyboard  --

    function Last_Key
        return Keypress is
    begin
        return To_Ada (Interfaces.C.unsigned (fl_event_key));
    end Last_Key;


    function Original_Last_Key
        return Keypress is
    begin
        return To_Ada (Interfaces.C.unsigned (fl_event_original_key));
    end Original_Last_Key;


    procedure Set_Last_Key
           (To : in Keypress) is
    begin
        fl_event_set_key (Interfaces.C.int (To_C (To)));
    end Set_Last_Key;


    function Pressed_During
           (Key : in Keypress)
        return Boolean is
    begin
        return fl_event_key_during (Interfaces.C.int (To_C (Key))) /= 0;
    end Pressed_During;


    function Key_Now
           (Key : in Keypress)
        return Boolean is
    begin
        return fl_event_get_key (Interfaces.C.int (To_C (Key))) /= 0;
    end Key_Now;


    function Key_Ctrl
        return Boolean is
    begin
        return fl_event_ctrl /= 0;
    end Key_Ctrl;


    function Key_Alt
        return Boolean is
    begin
        return fl_event_alt /= 0;
    end Key_Alt;


    function Key_Command
        return Boolean is
    begin
        return fl_event_command /= 0;
    end Key_Command;


    function Key_Shift
        return Boolean is
    begin
        return fl_event_shift /= 0;
    end Key_Shift;


begin


    fl_event_add_handler (Storage.To_Integer (Event_Handler_Hook'Address));
    fl_event_add_system_handler (Storage.To_Integer (System_Handler_Hook'Address), Null_Pointer);


end FLTK.Events;


