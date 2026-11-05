


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Phase 12's Resize overrides: FLTK's resize() reaches an Ada Resize
--  override on every widget, not only a Box, a Table or a Table_Row, as
--  a group lays out its children.  The default calls FLTK's own resize,
--  so an override that calls it is run once, whoever started the resize.


with

    Checks,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text;

use

    Checks;


procedure Test_Resize_Hook is

    package Btn renames FLTK.Widgets.Buttons;
    package Grp renames FLTK.Widgets.Groups;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Txt renames FLTK.Widgets.Inputs.Text;

    type Place is record
        X, Y, W, H : Integer := 0;
    end record;

    function Image
           (P : in Place)
        return String is
    begin
        return Integer'Image (P.X) & Integer'Image (P.Y) & Integer'Image (P.W)
            & Integer'Image (P.H);
    end Image;

    Window_Calls, Group_Calls, Button_Calls, Frozen_Calls, Input_Calls : Natural := 0;
    Group_Got, Button_Got, Input_Got : Place;


    type Counted_Window is new Win.Window with null record;

    overriding procedure Resize
           (This       : in out Counted_Window;
            X, Y, W, H : in     Integer);

    overriding procedure Resize
           (This       : in out Counted_Window;
            X, Y, W, H : in     Integer) is
    begin
        Window_Calls := Window_Calls + 1;
        Win.Window (This).Resize (X, Y, W, H);
    end Resize;


    type Counted_Group is new Grp.Group with null record;

    overriding procedure Resize
           (This       : in out Counted_Group;
            X, Y, W, H : in     Integer);

    overriding procedure Resize
           (This       : in out Counted_Group;
            X, Y, W, H : in     Integer) is
    begin
        Group_Calls := Group_Calls + 1;
        Group_Got := (X, Y, W, H);
        Grp.Group (This).Resize (X, Y, W, H);
    end Resize;


    type Counted_Button is new Btn.Button with null record;

    overriding procedure Resize
           (This       : in out Counted_Button;
            X, Y, W, H : in     Integer);

    overriding procedure Resize
           (This       : in out Counted_Button;
            X, Y, W, H : in     Integer) is
    begin
        Button_Calls := Button_Calls + 1;
        Button_Got := (X, Y, W, H);
        Btn.Button (This).Resize (X, Y, W, H);
    end Resize;


    --  It takes FLTK's place, and doesn't call it.
    type Frozen_Button is new Btn.Button with null record;

    overriding procedure Resize
           (This       : in out Frozen_Button;
            X, Y, W, H : in     Integer);

    overriding procedure Resize
           (This       : in out Frozen_Button;
            X, Y, W, H : in     Integer)
    is
        pragma Unreferenced (This, X, Y, W, H);
    begin
        Frozen_Calls := Frozen_Calls + 1;
    end Resize;


    type Counted_Input is new Txt.Text_Input with null record;

    overriding procedure Resize
           (This       : in out Counted_Input;
            X, Y, W, H : in     Integer);

    overriding procedure Resize
           (This       : in out Counted_Input;
            X, Y, W, H : in     Integer) is
    begin
        Input_Calls := Input_Calls + 1;
        Input_Got := (X, Y, W, H);
        Txt.Text_Input (This).Resize (X, Y, W, H);
    end Resize;


    Window : Counted_Window :=
        (Win.Forge.Create (0, 0, 200, 200, "Test_Resize_Hook") with null record);
    Group  : Counted_Group := (Grp.Forge.Create (Window, 0, 0, 200, 200) with null record);
    Button : Counted_Button :=
        (Btn.Forge.Create (Group, 10, 10, 50, 50, "b") with null record);
    Frozen : constant Frozen_Button :=
        (Btn.Forge.Create (Group, 100, 10, 50, 50, "f") with null record);
    Input  : Counted_Input :=
        (Txt.Forge.Create (Group, 10, 100, 80, 30) with null record);

    procedure Settle is
    begin
        for N in 1 .. 10 loop
            exit when FLTK.Wait (0.02) < 0.0;
        end loop;
    end Settle;

    procedure Reset is
    begin
        Window_Calls := 0;
        Group_Calls := 0;
        Button_Calls := 0;
        Frozen_Calls := 0;
        Input_Calls := 0;
    end Reset;

    function Now
           (Item : in FLTK.Widgets.Widget'Class)
        return Place is
    begin
        return (Item.Get_X, Item.Get_Y, Item.Get_W, Item.Get_H);
    end Now;

begin

    Window.Set_Resizable (Group);
    Window.Show;
    while not Window.Is_Shown loop
        exit when FLTK.Wait < 0;
    end loop;
    Settle;

    --  A group laying out its children, which isn't Ada's doing.
    Reset;
    Group.Resize (0, 0, 400, 400);
    Check (Group_Calls = 1, "Ada's Resize on a group runs its override once:" &
        Natural'Image (Group_Calls));
    Check (Button_Calls = 1, "FLTK's resize of a button in it reaches the button's override:" &
        Natural'Image (Button_Calls));
    Check (Button_Got = (20, 20, 100, 100) and Now (Button) = (20, 20, 100, 100),
        "with the place FLTK gave, which the default applies:" & Image (Button_Got) & " ->" &
        Image (Now (Button)));
    Check (Frozen_Calls = 1 and Now (Frozen) = (100, 10, 50, 50),
        "an override that doesn't call the default keeps FLTK from moving it:" &
        Natural'Image (Frozen_Calls) & Image (Now (Frozen)));
    Check (Input_Calls = 1, "so is an input's:" & Natural'Image (Input_Calls));

    --  A window resized from Ada lays out its resizable group.
    Group.Resize (0, 0, 200, 200);
    Reset;
    Window.Resize (0, 0, 300, 300);
    Check (Window_Calls = 1, "Ada's Resize on a window runs its override once:" &
        Natural'Image (Window_Calls));
    Check (Group_Calls = 1 and Group_Got = (0, 0, 300, 300),
        "and FLTK's resize of its resizable group reaches the group's override:" &
        Natural'Image (Group_Calls) & Image (Group_Got));
    Settle;

    --  Resize (W, H) is FLTK's size(), which calls the virtual resize.
    Reset;
    Input.Resize (60, 20);
    Check (Input_Calls = 1, "Resize (W, H) reaches the override once:" &
        Natural'Image (Input_Calls));
    Check (Input_Got.W = 60 and Input_Got.H = 20 and Now (Input) = Input_Got,
        "with the new size and the same place:" & Image (Input_Got) & " ->" & Image (Now (Input)));

    --  An override called from Ada, and not by FLTK, runs once too.
    Reset;
    Button.Resize (1, 2, 30, 40);
    Check (Button_Calls = 1 and Now (Button) = (1, 2, 30, 40),
        "Ada's Resize on a button runs its override once:" & Natural'Image (Button_Calls) &
        Image (Now (Button)));

    Window.Hide;
    Summary;

end Test_Resize_Hook;
