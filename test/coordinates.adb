--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/coordinates.cxx: where a widget's x and y are measured
--  from.  Two subwindows, whose boxes are placed relative to them, and
--  two groups, whose boxes are placed relative to the main window; below
--  them, the mouse's position in the main window as it moves.  Guided by
--  pofltk's Coordinates.Mod.


with

    Ada.Strings.Fixed,
    FLTK.Events,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use type

    FLTK.Alignment;


function Coordinates
    return Integer
is

    package Ev  renames FLTK.Events;
    package Bx  renames FLTK.Widgets.Boxes;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;

    LF : constant Character := ASCII.LF;


    --  FLTK's Box and Title.
    function Make
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Hue        : in     FLTK.Color;
            Text       : in     String;
            Title      : in     Boolean)
        return Bx.Box is
    begin
        return This : Bx.Box := Bx.Forge.Create (Parent, X, Y, W, H, Text) do
            if Title then
                This.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center + FLTK.Align_Top);
                This.Set_Box (FLTK.No_Box);
                This.Set_Label_Color (Hue);
                This.Set_Label_Size (12);
            else
                This.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center);
                This.Set_Box (FLTK.Down_Box);
                This.Set_Label_Color (Hue);
                This.Set_Label_Size (11);
            end if;
        end return;
    end Make;


    --  printf's "%3d".
    function Int
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Tail
            (Ada.Strings.Fixed.Trim (Value'Image, Ada.Strings.Left), 3);
    end Int;


    type Main_Window is new Win.Window with null record;

    overriding function Handle
           (This  : in out Main_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome;


    Window : Main_Window :=
       (Win.Forge.Create (500, 232, "FLTK Coordinate Systems") with null record);

    TL_Window : Win.Window := Win.Forge.Create (Window, 0, 0, 250, 100);
    TL_Title  : constant Bx.Box := Make (TL_Window, 10, 10, 230, 40, FLTK.Red_Color,
        "Fl_Window TL(0, 0, 250, 100)" & LF & "x, y relative to main window", True);
    TL_Box    : constant Bx.Box := Make (TL_Window, 25, 50, 200, 40, FLTK.Red_Color,
        "Fl_Box tl(25, 50, 200, 40)" & LF & "x, y relative to TL window", False);

    BR_Window : Win.Window := Win.Forge.Create (Window, 250, 100, 250, 100);
    BR_Title  : constant Bx.Box := Make (BR_Window, 10, 10, 230, 40, FLTK.Magenta_Color,
        "Fl_Window BR(250, 100, 250, 100)" & LF & "x, y relative to main window", True);
    BR_Box    : constant Bx.Box := Make (BR_Window, 25, 50, 200, 40, FLTK.Magenta_Color,
        "Fl_Box br(25, 50, 200, 40)" & LF & "x, y relative to BR window", False);

    TR_Group : Grp.Group := Grp.Forge.Create (Window, 250, 0, 250, 100);
    TR_Title : constant Bx.Box := Make (TR_Group, 260, 10, 230, 40, FLTK.Blue_Color,
        "Fl_Group TR(250, 0, 250, 100)" & LF & "x, y relative to main window", True);
    TR_Box   : constant Bx.Box := Make (TR_Group, 275, 50, 200, 40, FLTK.Blue_Color,
        "Fl_Box tr(275, 50, 200, 40)" & LF & "x, y relative to main window", False);

    BL_Group : Grp.Group := Grp.Forge.Create (Window, 0, 100, 250, 100);
    BL_Title : constant Bx.Box := Make (BL_Group, 10, 110, 230, 40, FLTK.Black_Color,
        "Fl_Group BL(0, 100, 250, 100)" & LF & "x, y relative to main window", True);
    BL_Box   : constant Bx.Box := Make (BL_Group, 25, 150, 200, 40, FLTK.Black_Color,
        "Fl_Box bl(25, 150, 200, 40)" & LF & "x, y relative to main window", False);

    Message_Box : Bx.Box := Bx.Forge.Create (Window, 0, 201, 500, 30);

    pragma Unreferenced
       (TL_Title, TL_Box, BR_Title, BR_Box, TR_Title, TR_Box, BL_Title, BL_Box);


    function Handle
           (This  : in out Main_Window;
            Event : in     FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Result : FLTK.Event_Outcome := Win.Window (This).Handle (Event);
    begin
        case Event is
            when FLTK.Enter | FLTK.Leave =>
                Result := FLTK.Handled;
                Message_Box.Set_Label ("");
            when FLTK.Move | FLTK.Drag =>
                Result := FLTK.Handled;
                if 0 < Ev.Mouse_X and Ev.Mouse_X < This.Get_W and
                    0 < Ev.Mouse_Y and Ev.Mouse_Y < This.Get_H
                then
                    Message_Box.Set_Label
                       ("Mouse position relative to main window: " &
                        Int (Ev.Mouse_X) & "," & Int (Ev.Mouse_Y));
                else
                    Message_Box.Set_Label ("");
                end if;
            when others =>
                null;
        end case;
        return Result;
    end Handle;

begin

    TL_Window.Set_Box (FLTK.Engraved_Box);
    BR_Window.Set_Box (FLTK.Engraved_Box);
    TR_Group.Set_Box (FLTK.Engraved_Box);
    BL_Group.Set_Box (FLTK.Engraved_Box);

    Message_Box.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Center);
    Message_Box.Set_Box (FLTK.Engraved_Box);
    Message_Box.Set_Label_Font (FLTK.Courier);
    Message_Box.Set_Label_Size (12);

    Window.End_Current;
    Window.Show_With_Args;

    return FLTK.Run;

end Coordinates;
