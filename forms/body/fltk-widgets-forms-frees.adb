

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Hook_Exceptions,
    FLTK.Widgets.Groups,
    Interfaces.C;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Forms.Frees is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_free
           (K, X, Y, W, H : in Interfaces.C.int;
            Text          : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_free, "new_fl_free");
    pragma Inline (new_fl_free);

    procedure free_fl_free
           (F : in Storage.Integer_Address);
    pragma Import (C, free_fl_free, "free_fl_free");
    pragma Inline (free_fl_free);




    --  Drawing, Events  --

    procedure fl_free_draw
           (F : in Storage.Integer_Address);
    pragma Import (C, fl_free_draw, "fl_free_draw");
    pragma Inline (fl_free_draw);

    function fl_free_handle
           (F : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_free_handle, "fl_free_handle");
    pragma Inline (fl_free_handle);




    -------------
    --  Hooks  --
    -------------

    --  Every Free's Forms handler calls this (c_fl_free.cpp).  Kind is 0
    --  for an event, 1 to draw and 2 for a step.
    function Free_Handle_Hook
           (U          : in Storage.Integer_Address;
            K, E, X, Y : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Export (C, Free_Handle_Hook, "free_handle_hook");

    function Free_Handle_Hook
           (U          : in Storage.Integer_Address;
            K, E, X, Y : in Interfaces.C.int)
        return Interfaces.C.int
    is
        Mark       : constant Hook_Exceptions.Mark := Hook_Exceptions.Entry_Mark;
        Ada_Widget : constant access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (U));
        Kind       : Free_Event_Kind;
        Event      : Event_Kind := No_Event;
    begin
        if Ada_Widget = null or else Ada_Widget.all not in Free'Class then
            return 0;
        end if;
        case K is
        when 1 =>
            Kind := Draw_Event;
        when 2 =>
            Kind := Step_Event;
        when others =>
            --  An event FLTKAda has no name for isn't passed on.
            if E < Event_Kind'Pos (Event_Kind'First) or E > Event_Kind'Pos (Event_Kind'Last) then
                return 0;
            end if;
            Kind  := FLTK_Event;
            Event := Event_Kind'Val (E);
        end case;
        return Boolean'Pos (Free'Class (Ada_Widget.all).Handle_Free
           (Kind, Event, Integer (X), Integer (Y)));
    exception
    when Occurrence : others =>
        Hook_Exceptions.Save (Occurrence, Mark);
        return 0;
    end Free_Handle_Hook;




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Free) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Free) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_free (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Free;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Free) is
    begin
        This.Draw_Ptr   := fl_free_draw'Address;
        This.Handle_Ptr := fl_free_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (Kind       : in Free_Kind;
                X, Y, W, H : in Integer;
                Text       : in String := "")
            return Free is
        begin
            return This : Free do
                This.Void_Ptr := new_fl_free
                   (Free_Kind'Enum_Rep (Kind),
                    Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                Kind       : in     Free_Kind;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Free is
        begin
            return This : Free := Create (Kind, X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Handling  --

    function Handle_Free
           (This  : in out Free;
            Kind  : in     Free_Event_Kind;
            Event : in     Event_Kind;
            X, Y  : in     Integer)
        return Boolean
    is
        pragma Unreferenced (This, Kind, Event, X, Y);
    begin
        return False;
    end Handle_Free;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Free) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Free;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Forms.Frees;


