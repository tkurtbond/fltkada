

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/draggable-group.cxx: a group whose children
--  can be dragged around inside it with the right mouse button.
--
--  The original was contributed by K Dmitrij to fltk.general on 26 Jul 2017.
--
--  The original checks that the widget below the mouse is a child by
--  comparing its parent with the group; here Find does the same job, since
--  it only finds direct children.  Find and Insert use 1-based indices, so
--  the saved index needs no adjustment.


with

    FLTK.Events,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment,
    FLTK.Mouse_Button;


function Draggable_Group
    return Integer
is


    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package DW  renames FLTK.Widgets.Groups.Windows.Double;

    use type Grp.Extended_Index;


    type Widget_Access is access all FLTK.Widgets.Widget'Class;


    --  A group with draggable children
    --
    --  Use this type if you want the user to be able to drag the children
    --  of a group inside the borders of the group.  Drag_Group widgets
    --  can be nested, but only direct children of the Drag_Group widget
    --  can be dragged.
    --
    --  Design decisions:
    --    - Widgets can be dragged with the right mouse button.
    --      This was chosen to avoid conflicts with other mouse button
    --      events such as clicking a button.
    --    - The dragged widget is raised to the top within its group for better
    --      visual feedback while dragging by making it the last child of the group.
    --    - The order of widgets is restored when the mouse button is released.
    --      This can result in hiding the widget behind another widget, but this
    --      was chosen to keep the order given by the programmer.  If this
    --      is not desired it can be changed easily.
    type Drag_Group is new Grp.Group with record
        X_Off, Y_Off : Integer := 0;                  --  start offsets while dragging
        Drag_Index   : Grp.Extended_Index := Grp.No_Index;   --  index of dragged child
        Drag_Widget  : Widget_Access;                 --  dragged child widget
    end record;

    --  Handle Push, Drag, and Release events.
    --  All other events are handled by the parent Group's Handle.
    --  Dragged widgets are limited inside the borders of their parent group.
    overriding function Handle
           (This  : in out Drag_Group;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    function Create
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String := "")
        return Drag_Group is
    begin
        return This : Drag_Group :=
            (Grp.Forge.Create (Parent, X, Y, W, H, Text) with others => <>)
        do
            This.Set_Box (FLTK.Up_Box);
        end return;
    end Create;


    --  Raise the dragged widget to the top (last child) of its group.
    --
    --  This ensures that the widget is always visible while it is dragged.
    --  The original index is saved in Drag_Index and restored when the
    --  mouse button is released.
    --
    --  Since we allow only direct children of the Drag_Group widget to be
    --  dragged the argument Item is always a child of This.  Note: Add first
    --  removes the widget from its parent group (This) and then adds it
    --  again as its last child.
    procedure Top_Level
           (This : in out Drag_Group;
            Item : in out FLTK.Widgets.Widget'Class) is
    begin
        This.Drag_Index := This.Find (Item);   --  save the widget's current index
        This.Add (Item);                       --  raise to top (make it the last child)
    end Top_Level;


    overriding function Handle
           (This  : in out Drag_Group;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome is
    begin
        case Event is
        when FLTK.Push =>
            if FLTK.Events.Last_Button = FLTK.Right_Button then
                declare
                    Below : constant access FLTK.Widgets.Widget'Class :=
                        FLTK.Events.Get_Below_Mouse;
                begin
                    if Below /= null and then This.Find (Below.all) /= Grp.No_Index then
                        This.Drag_Widget := Below.all'Unchecked_Access;

                        --  save pointer offsets relative to Drag_Widget's x/y position
                        This.X_Off := FLTK.Events.Mouse_X - Below.Get_X;
                        This.Y_Off := FLTK.Events.Mouse_Y - Below.Get_Y;

                        Top_Level (This, Below.all);   --  raise to top for visible feedback
                        This.Redraw;
                        return FLTK.Handled;
                    end if;
                end;
            end if;

        when FLTK.Drag =>
            if This.Drag_Widget /= null then
                declare
                    Item : FLTK.Widgets.Widget'Class renames This.Drag_Widget.all;

                    N_X : Integer := FLTK.Events.Mouse_X - This.X_Off;   --  new x coordinate
                    N_Y : Integer := FLTK.Events.Mouse_Y - This.Y_Off;   --  new y coordinate

                    --  left and right border width
                    BBX : constant Integer := FLTK.Static.Get_Box_X_Offset (This.Get_Box);
                    --  top and bottom border width
                    BBY : constant Integer := FLTK.Static.Get_Box_Y_Offset (This.Get_Box);
                begin
                    --  keep the widget inside its parent's borders

                    if N_X < This.Get_X + BBX then
                        N_X := This.Get_X + BBX;
                    elsif N_X + Item.Get_W > This.Get_X + This.Get_W - BBX then
                        N_X := This.Get_X + This.Get_W - Item.Get_W - BBX;
                    end if;

                    if N_Y < This.Get_Y + BBY then
                        N_Y := This.Get_Y + BBY;
                    elsif N_Y + Item.Get_H > This.Get_Y + This.Get_H - BBY then
                        N_Y := This.Get_Y + This.Get_H - Item.Get_H - BBY;
                    end if;

                    Item.Reposition (N_X, N_Y);   --  set the new position
                    This.Redraw;
                    return FLTK.Handled;
                end;
            end if;

        when FLTK.Release =>
            if This.Drag_Widget /= null and then FLTK.Events.Last_Button = FLTK.Right_Button then

                --  Optional: restore the original widget order in the group.
                --  Remove the next statement (or comment it out) if not desired.
                This.Insert (This.Drag_Widget.all, This.Drag_Index);

                This.Reset_Sizes;   --  save widget positions for later resizing
                This.Drag_Widget := null;
                This.Redraw;
                if This.Parent /= null then
                    This.Parent.Redraw;
                end if;
                return FLTK.Handled;
            end if;

        when others =>
            null;
        end case;

        return Grp.Group (This).Handle (Event);
    end Handle;


    type Box_Access is access Bx.Box;

    Status : Box_Access;


    --  clear status message box after timeout
    procedure Clear_Status is
    begin
        Status.Set_Label ("");
        Status.Redraw;
    end Clear_Status;


    --  button callback: display status message for two seconds
    procedure Button_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Status.Set_Label ("button_cb: '" & Item.Get_Label & "'." & ASCII.LF);
        Status.Redraw;
        --  remove any pending timeout
        FLTK.Static.Remove_Timeout (Clear_Status'Unrestricted_Access);
        FLTK.Static.Add_Timeout (2.0, Clear_Status'Unrestricted_Access);
    end Button_CB;


    --  tooltips:

    TT_Drag   : constant String :=
        "Drag this DraggableGroup and/or its child groups and squares. " &
        "Use the right mouse button (MB3) to drag objects.";
    TT_Group  : constant String :=
        "You can drag this Fl_Group, but not its children (squares).";
    TT_Button : constant String :=
        "You can drag this button with the right mouse button " &
        "and you can click it with the left mouse button.";


    --  main program:

    Win : DW.Double_Window :=
        DW.Forge.Create (500, 500, "Drag children within their parent group");

    Area : Drag_Group := Create
       (Win, 0, 0, 500, 400, "Use the right mouse button (MB3)" & ASCII.LF & "to drag objects");

    --  draggable group inside draggable area
    D_Obj : Drag_Group := Create (Area, 5, 5, 140, 140, "DraggableGroup");
    B1    : Bx.Box := Bx.Forge.Create (D_Obj, 25, 25, 20, 20);
    B2    : Bx.Box := Bx.Forge.Create (D_Obj, 105, 105, 20, 20);

    --  regular group inside draggable area
    D_Obj_2 : Grp.Group := Grp.Forge.Create (Area, 5, 280, 110, 110, "Fl_Group");
    B3      : Bx.Box := Bx.Forge.Create (D_Obj_2, 15, 290, 20, 20);
    B4      : Bx.Box := Bx.Forge.Create (D_Obj_2, 85, 360, 20, 20);

    --  draggable group inside draggable area
    D_Obj_3 : Drag_Group := Create (Area, 245, 5, 150, 150, "DraggableGroup");

    --  nested draggable group
    D_Obj_4 : Drag_Group := Create (D_Obj_3, 250, 10, 50, 50);
    B5      : Bx.Box := Bx.Forge.Create (D_Obj_4, 255, 15, 15, 15);
    B6      : Bx.Box := Bx.Forge.Create (D_Obj_4, 275, 30, 15, 15);

    Button_1 : Btn.Button :=
        Btn.Forge.Create (Area, 200, 350, 180, 40, "Fl_Button inside DraggableGroup");

    Button_2 : Btn.Button :=
        Btn.Forge.Create (Win, 200, 410, 180, 40, "Fl_Button outside DraggableGroup");


begin


    Area.Set_Alignment (FLTK.Align_Inside);
    Area.Set_Tooltip (TT_Drag);

    D_Obj.Set_Alignment (FLTK.Align_Inside);
    B1.Set_Background_Color (FLTK.Red_Color);
    B1.Set_Box (FLTK.Flat_Box);
    B2.Set_Background_Color (FLTK.Green_Color);
    B2.Set_Box (FLTK.Flat_Box);
    D_Obj.End_Current;
    D_Obj.Set_Tooltip (TT_Drag);

    D_Obj_2.Set_Box (FLTK.Down_Box);
    D_Obj_2.Set_Alignment (FLTK.Align_Inside);
    B3.Set_Background_Color (FLTK.Blue_Color);
    B3.Set_Box (FLTK.Flat_Box);
    B4.Set_Background_Color (FLTK.Yellow_Color);
    B4.Set_Box (FLTK.Flat_Box);
    D_Obj_2.End_Current;
    D_Obj_2.Set_Tooltip (TT_Group);

    D_Obj_3.Set_Alignment (FLTK.Align_Inside);
    D_Obj_3.Set_Tooltip (TT_Drag);

    B5.Set_Background_Color (FLTK.Black_Color);
    B5.Set_Box (FLTK.Flat_Box);
    B6.Set_Background_Color (FLTK.White_Color);
    B6.Set_Box (FLTK.Flat_Box);
    D_Obj_4.End_Current;
    D_Obj_4.Set_Tooltip (TT_Drag);

    D_Obj_3.End_Current;

    Button_1.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Wrap);
    Button_1.Set_Tooltip (TT_Button);

    Area.End_Current;

    Button_2.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Wrap);
    Button_2.Set_Tooltip ("This is a normal button and can't be dragged.");

    Status := new Bx.Box'(Bx.Forge.Create (Win, 0, 460, Win.Get_W, 40, "Messages ..."));
    Status.Set_Box (FLTK.Down_Box);

    Button_1.Set_Callback (Button_CB'Unrestricted_Access);
    Button_2.Set_Callback (Button_CB'Unrestricted_Access);

    Win.End_Current;
    Win.Set_Resizable (Win);
    Win.Show;

    return FLTK.Run;


end Draggable_Group;
