

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  PLAN.md Phase 12: where FLTK.Asks puts the next dialog, and the text of
--  its icon.  fl_message_icon_label keeps its pointer until the next dialog
--  (Fl_Message.cxx:169-171, 561-563), so the label is made at run time and
--  the secondary stack scribbled over before the dialog is shown.


with

    Checks,
    FLTK.Asks,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Ask_Placement is

    package Ask renames FLTK.Asks;
    package Prb renames FLTK.Probe;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type Ask.Message_Position_Kind;

    Serial : Natural := 0;

    function Fresh
           (Base : in String)
        return String is
    begin
        Serial := Serial + 1;
        return Base & Integer'Image (Serial);
    end Fresh;

    function Expected
           (Base : in String)
        return String is
    begin
        return Base & Integer'Image (Serial);
    end Expected;

    function Filler
           (Length : in Positive)
        return String is
    begin
        return (1 .. Length => 'X');
    end Filler;

    procedure Scribble is
        Count : Natural := 0;
    begin
        for N in 1 .. 8 loop
            declare
                Junk : constant String := Filler (4096 * N);
            begin
                Count := Count + Junk'Length;
            end;
        end loop;
        pragma Assert (Count > 0);
    end Scribble;


    --  What the dialog shown looked like.

    Seen_X, Seen_Y, Seen_H : Integer := 0;
    Seen_Icon : String (1 .. 64) := (others => ' ');
    Seen_Last : Natural := 0;

    procedure Note_And_Close is
        Icon   : constant String := Prb.Modal_Icon;
        Ignore : Boolean;
    begin
        Seen_X := Prb.Modal_X;
        Seen_Y := Prb.Modal_Y;
        Seen_H := Prb.Modal_H;
        Seen_Last := Natural'Min (Icon'Length, Seen_Icon'Length);
        Seen_Icon (1 .. Seen_Last) := Icon (Icon'First .. Icon'First + Seen_Last - 1);
        Ignore := Prb.Close_Modal;
    end Note_And_Close;

    procedure Show_Message is
    begin
        Seen_H := 0;
        Seen_Last := 0;
        FLTK.Static.Add_Timeout (0.2, Note_And_Close'Unrestricted_Access);
        Ask.Message_Box ("Test_Ask_Placement");
    end Show_Message;

    function Icon_Seen
        return String is
    begin
        return Seen_Icon (1 .. Seen_Last);
    end Icon_Seen;


    X, Y : Integer;
    Kind : Ask.Message_Position_Kind;

    Window : Win.Window := Win.Forge.Create (0, 0, 300, 200, "Test_Ask_Placement");

    Button : constant FLTK.Widgets.Buttons.Button := FLTK.Widgets.Buttons.Forge.Create
       (Window, 100, 80, 60, 40, "Over");

    Wayland : constant Boolean := Prb.On_Wayland;

begin

    Ask.Set_Message_Hotspot (False);

    --  Placement.
    Ask.Get_Message_Position (X, Y, Kind);
    Check (Kind = Ask.Default_Position and X = -1 and Y = -1,
        "no position is set at first");

    Ask.Set_Message_Position (50, 60);
    Ask.Get_Message_Position (X, Y, Kind);
    Check (Kind = Ask.Corner_Position and X = 50 and Y = 60,
        "Set_Message_Position sets the corner:" & Integer'Image (X) & Integer'Image (Y));

    Show_Message;
    Check (Seen_H > 0, "the dialog was shown");
    if Wayland then
        Skip ("a Wayland window's place isn't the program's to set");
    else
        Check (Seen_X = 50 and Seen_Y = 60, "the dialog's corner is there:"
            & Integer'Image (Seen_X) & Integer'Image (Seen_Y));
    end if;
    Ask.Get_Message_Position (X, Y, Kind);
    Check (Kind = Ask.Default_Position, "the position is for the next dialog only");

    Ask.Set_Message_Position (300, 200, Centered => True);
    Ask.Get_Message_Position (X, Y, Kind);
    Check (Kind = Ask.Center_Position and X = 300 and Y = 200,
        "Set_Message_Position sets the centre");
    Show_Message;
    if not Wayland then
        Check (Seen_Y = 200 - Seen_H / 2, "the dialog's centre is there:"
            & Integer'Image (Seen_Y) & Integer'Image (Seen_H));
    end if;

    Window.Show;
    for N in 1 .. 10 loop
        exit when FLTK.Wait (0.02) < 0.0;
    end loop;
    Ask.Set_Message_Position_Over (Button);
    Ask.Get_Message_Position (X, Y, Kind);
    Check (Kind = Ask.Center_Position
        and X = Window.Get_X + 130 and Y = Window.Get_Y + 100,
        "Set_Message_Position_Over centres on the widget:"
        & Integer'Image (X) & Integer'Image (Y));
    Ask.Set_Message_Position (0, 0);
    Show_Message;

    --  The icon's text.
    Show_Message;
    Check (Icon_Seen = "i", "a message's own icon is ""i"": " & Icon_Seen);

    Ask.Set_Message_Icon_Label (Fresh ("next"));
    Scribble;
    Show_Message;
    Check (Icon_Seen = Expected ("next"), "Set_Message_Icon_Label's text is kept: " & Icon_Seen);
    Show_Message;
    Check (Icon_Seen = "i", "Set_Message_Icon_Label is for the next dialog only: " & Icon_Seen);

    Ask.Set_Message_Icon_Label_Default (Fresh ("every"));
    Scribble;
    Show_Message;
    Check (Icon_Seen = Expected ("every"), "Set_Message_Icon_Label_Default's text: " & Icon_Seen);
    Check (Ask.Get_Message_Icon.Get_Label = Expected ("every"),
        "the default is Get_Message_Icon's label");
    Show_Message;
    Check (Icon_Seen = Expected ("every"), "the default stays: " & Icon_Seen);

    Ask.Set_Message_Icon_Label ("once");
    Show_Message;
    Check (Icon_Seen = "once", "the next dialog's text comes before the default: " & Icon_Seen);

    Ask.Set_Message_Icon_Label ("unused");
    Ask.Set_Message_Icon_Label ("");
    Show_Message;
    Check (Icon_Seen = Expected ("every"), "an empty text unsets the next one: " & Icon_Seen);

    Ask.Set_Message_Icon_Label_Default ("");
    Show_Message;
    Check (Icon_Seen = "i", "an empty default gives the dialog its own again: " & Icon_Seen);

    Window.Hide;
    Summary;

end Test_Ask_Placement;
