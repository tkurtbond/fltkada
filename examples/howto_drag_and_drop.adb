

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-drag-and-drop.cxx: a simple example
--  of drag and drop between two windows.
--
--  1) Run the program.
--  2) Click and drag the red box to the green box.
--  3) Release the mouse button on the green box.
--  4) A message dialog appears with the dropped text.
--
--  Set_Label always copies its text, so the original's distinction between
--  label() and copy_label() disappears.  Timeout handlers take no data, so
--  the dropped text is kept in a global rather than in the receiver.


with

    Ada.Strings.Unbounded,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Events,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;


function Howto_Drag_And_Drop
    return Integer
is


    package SU  renames Ada.Strings.Unbounded;
    package TIO renames Ada.Text_IO;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type SU.Unbounded_String;


    --  The text dropped on the receiver, waiting to be shown by Timer_CB
    DnD_Text : SU.Unbounded_String;


    --  SENDER CLASS
    type Sender is new Bx.Box with null record;

    --  Sender event handler
    overriding function Handle
           (This  : in out Sender;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    --  RECEIVER CLASS
    type Receiver is new Bx.Box with record
        DnD_Inside : Boolean := False;
    end record;

    --  Receiver event handler
    overriding function Handle
           (This  : in out Receiver;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    function Create
           (Parent     : in out Win.Window'Class;
            X, Y, W, H : in     Integer)
        return Sender is
    begin
        return This : Sender := (Bx.Forge.Create (Parent, X, Y, W, H) with null record) do
            This.Set_Box (FLTK.Flat_Box);
            This.Set_Background_Color (9);
            This.Set_Label ("Drag" & ASCII.LF & "from" & ASCII.LF & "here..");
        end return;
    end Create;


    overriding function Handle
           (This  : in out Sender;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Ret : FLTK.Event_Outcome := Bx.Box (This).Handle (Event);
    begin
        case Event is
        when FLTK.Push =>   --  do 'copy/dnd' when someone clicks on box
            FLTK.Static.Copy ("It works!", FLTK.Static.Selection);
            FLTK.Static.Drag_Drop_Start;
            Ret := FLTK.Handled;
        when others =>
            null;
        end case;
        return Ret;
    end Handle;


    function Create
           (Parent     : in out Win.Window'Class;
            X, Y, W, H : in     Integer)
        return Receiver is
    begin
        return This : Receiver := (Bx.Forge.Create (Parent, X, Y, W, H) with others => <>) do
            This.Set_Box (FLTK.Flat_Box);
            This.Set_Background_Color (10);
            This.Set_Label ("..to" & ASCII.LF & "here");
        end return;
    end Create;


    --  dnd (Paste) popup
    procedure Timer_CB is
    begin
        if DnD_Text /= SU.Null_Unbounded_String then
            FLTK.Asks.Message_Box (SU.To_String (DnD_Text));
            DnD_Text := SU.Null_Unbounded_String;
        end if;
    end Timer_CB;


    overriding function Handle
           (This  : in out Receiver;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Ret : FLTK.Event_Outcome := Bx.Box (This).Handle (Event);
    begin
        case Event is
        when FLTK.DnD_Enter =>   --  return Handled for this event to 'accept' dnd
            This.Set_Label ("ENTER");   --  visible only if you stop the mouse at the border
            TIO.Put_Line (TIO.Standard_Error, "FL_DND_ENTER");
            This.DnD_Inside := True;    --  status: inside the widget, accept drop
            Ret := FLTK.Handled;

        when FLTK.DnD_Drag =>    --  return Handled for this event to 'accept' dnd
            This.Set_Label ("drop" & ASCII.LF & "here");
            TIO.Put_Line (TIO.Standard_Error, "FL_DND_DRAG");
            Ret := FLTK.Handled;

        when FLTK.DnD_Release =>   --  return Handled for this event to 'accept' the drop
            TIO.Put_Line (TIO.Standard_Error, "FL_DND_RELEASE");
            if This.DnD_Inside then
                Ret := FLTK.Handled;   --  return Handled and expect Paste event to follow
                This.Set_Label ("RELEASE");
            else
                Ret := FLTK.Not_Handled;   --  return Not_Handled to reject the drop
                This.Set_Label ("DND" & ASCII.LF & "REJECTED!");
            end if;

        when FLTK.Paste =>   --  handle actual drop (paste) operation
            TIO.Put_Line (TIO.Standard_Error, "FL_PASTE");
            This.Set_Label (FLTK.Events.Text);
            TIO.Put_Line (TIO.Standard_Error, "Pasted '" & FLTK.Events.Text & "'");

            --  Don't pop up dialog windows in DnD_* or Paste event handling
            --  resulting from DND operations.  This may hang or even crash the
            --  application on *some* platforms.  Use a short timer to delay the
            --  message display after the event processing is completed.

            DnD_Text := SU.To_Unbounded_String (FLTK.Events.Text);
            if DnD_Text /= SU.Null_Unbounded_String then
                FLTK.Static.Add_Timeout (0.001, Timer_CB'Unrestricted_Access);   --  delay popup
            end if;
            Ret := FLTK.Handled;

        when FLTK.DnD_Leave =>   --  not strictly necessary to return Handled for this event
            This.Set_Label ("..to" & ASCII.LF & "here");   --  reset label
            TIO.Put_Line (TIO.Standard_Error, "FL_DND_LEAVE");
            This.DnD_Inside := False;   --  status: mouse is outside, don't accept drop
            Ret := FLTK.Handled;        --  return Handled anyway..

        when others =>
            null;
        end case;
        return Ret;
    end Handle;


    --  Create sender window and widget
    Win_A : Win.Window := Win.Forge.Create (0, 0, 200, 100, "Sender");
    A     : Sender := Create (Win_A, 0, 0, 100, 100);


begin


    Win_A.End_Current;
    Win_A.Show;

    --  Create receiver window and widget
    declare
        Win_B : Win.Window := Win.Forge.Create (400, 0, 200, 100, "Receiver");
        B     : Receiver := Create (Win_B, 100, 0, 100, 100);
    begin
        Win_B.End_Current;
        Win_B.Show;
        return FLTK.Run;
    end;


end Howto_Drag_And_Drop;
