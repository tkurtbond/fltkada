--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/navigation.cxx: inputs of random sizes, placed at random
--  where they don't overlap, and inserted in the window in reading order,
--  to try navigating with the keyboard.  An argument seeds the C library's
--  rand, as in FLTK's program, so the same inputs are made.


with

    Ada.Command_Line,
    Ada.Containers.Vectors,
    Ada.Unchecked_Deallocation,
    FLTK.Static,
    FLTK.Widgets.Buttons.Light,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text,
    Interfaces.C;


function Navigation
    return Integer
is

    package Lit renames FLTK.Widgets.Buttons.Light;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Inp renames FLTK.Widgets.Inputs.Text;

    function Rand
        return Interfaces.C.int
    with Import, Convention => C, External_Name => "rand";

    procedure Srand
           (Seed : in Interfaces.C.unsigned)
    with Import, Convention => C, External_Name => "srand";

    function Random
           (Modulus : in Positive)
        return Natural is (Natural (Rand) mod Modulus);

    Width  : constant := 600;
    Height : constant := 300;
    Grid   : constant := 25;

    type Input_Access is access Inp.Text_Input;
    procedure Free is new Ada.Unchecked_Deallocation (Inp.Text_Input, Input_Access);
    package Input_Vectors is new Ada.Containers.Vectors (Positive, Input_Access);

    Inputs : Input_Vectors.Vector;

    Window : Win.Window := Win.Forge.Create (Width, Height + 40, Ada.Command_Line.Command_Name);

    Arrow_Focus_Button : Lit.Light_Button :=
        Lit.Forge.Create (Window, 10, Height + 10, 130, 20, " Arrow Focus");

    procedure Toggle_Arrow_Focus
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        FLTK.Static.Set_Option
           (FLTK.Static.Arrow_Focus, Lit.Light_Button (Item).Is_On);
    end Toggle_Arrow_Focus;

    Result : Integer;

begin

    if Ada.Command_Line.Argument_Count > 0 then
        Srand (Interfaces.C.unsigned'Mod (Integer'Value (Ada.Command_Line.Argument (1))));
    end if;

    Arrow_Focus_Button.Set_Callback (Toggle_Arrow_Focus'Unrestricted_Access);
    Arrow_Focus_Button.Set_State
       (if FLTK.Static.Get_Option (FLTK.Static.Arrow_Focus)
        then FLTK.Widgets.Buttons.On
        else FLTK.Widgets.Buttons.Off);
    Arrow_Focus_Button.Set_Tooltip
       ("Control horizontal arrow key focus navigation behavior." & ASCII.LF &
        "e.g. Fl::OPTION_ARROW_FOCUS");

    for I in 1 .. 10_000 loop
        declare
            X : Integer := Random (Width / Grid + 1) * Grid;
            Y : Integer := Random (Height / Grid + 1) * Grid;
            W : Integer := Random (Width / Grid + 1) * Grid;
            H : Integer;
            Place : Natural := 0;    --  where to insert it, if before a child
            N     : Positive := 1;
        begin
            if W < X then
                W := X - W;
                X := X - W;
            else
                W := W - X;
            end if;
            H := Random (Height / Grid + 1) * Grid;
            if H < Y then
                H := Y - H;
                Y := Y - H;
            else
                H := H - Y;
            end if;
            if W >= Grid and H >= Grid and W >= H then
                --  Find where to insert it, and whether it overlaps something.
                while N <= Window.Number_Of_Children loop
                    declare
                        O : FLTK.Widgets.Widget'Class renames Window.Child (N).Data.all;
                    begin
                        exit when X < O.Get_X + O.Get_W and X + W > O.Get_X and
                            Y < O.Get_Y + O.Get_H and Y + H > O.Get_Y;
                        if Place = 0 and
                            (Y < O.Get_Y or (Y = O.Get_Y and X < O.Get_X))
                        then
                            Place := N;
                        end if;
                    end;
                    N := N + 1;
                end loop;
                if N > Window.Number_Of_Children then
                    Inputs.Append (new Inp.Text_Input'(Inp.Forge.Create (X, Y, W, H)));
                    Window.Insert
                       (Inputs.Last_Element.all,
                        (if Place = 0 then Window.Number_Of_Children + 1 else Place));
                end if;
            end if;
        end;
    end loop;

    Window.Show_With_Args;

    Result := FLTK.Run;

    for Item of Inputs loop
        Window.Remove (Item.all);
        Free (Item);
    end loop;

    return Result;

end Navigation;
