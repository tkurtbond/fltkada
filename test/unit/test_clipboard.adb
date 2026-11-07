

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Ported from pofltk's TestClipboard: the clipboard and the selection
--  buffer, images on the clipboard from a Copy_Surface, and drag and drop
--  as FLTK routes it.  What test_paste_image (taking a pasted image, and
--  refusing one), test_clipboard_kinds and test_selection_buffer check is
--  left to them.  pofltk's Copy to both buffers at once is
--  Copy_To_Both.  Its Image.CopyToClipboard has no counterpart, as it is
--  pofltk's own, which is pofltk's own; images reach the
--  clipboard here through a Copy_Surface.  Nor have its counts of open
--  surfaces, images and widgets: Ada finalizes them, and valgrind covers
--  it.


with

    Checks,
    FLTK.Devices.Surface.Copy,
    FLTK.Devices.Surface.Image,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Images.RGB,
    FLTK.Probe,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows,
    FLTK.Widgets.Inputs.Text,
    System;

use

    Checks,
    FLTK;


procedure Test_Clipboard is

    package Bx  renames FLTK.Widgets.Boxes;
    package Cs  renames FLTK.Devices.Surface.Copy;
    package Drw renames FLTK.Draw;
    package Ev  renames FLTK.Events;
    package Ims renames FLTK.Devices.Surface.Image;
    package Prb renames FLTK.Probe;
    package RGB renames FLTK.Images.RGB;
    package St  renames FLTK.Static;
    package Srf renames FLTK.Devices.Surface;
    package Txt renames FLTK.Widgets.Inputs.Text;
    package Wdg renames FLTK.Widgets;
    package Win renames FLTK.Widgets.Groups.Windows;


    --  Keeps what is pasted into it: the text, or the image's size and two
    --  of its pixels if Take.
    type Receiver_Box is new Bx.Box with record
        Pastes   : Natural := 0;
        Text     : String (1 .. 16) := (others => ' ');
        Is_Image : Boolean := False;
        Take     : Boolean := False;
        Accepts   : Boolean := True;
        Took     : Boolean := False;
        W, H     : Integer := 0;
        Left     : Prb.RGB := -1;
        Right    : Prb.RGB := -1;
    end record;

    overriding function Handle
           (This  : in out Receiver_Box;
            Event : in     Event_Kind)
        return Event_Outcome;

    --  The pixel at X, Y of a depth-3 image, as 16#RRGGBB#.
    function Pixel
           (Image : in RGB.RGB_Image;
            X, Y  : in Natural)
        return Prb.RGB
    is
        Base : constant Size_Type := Size_Type ((Y * Image.Get_Data_W + X) * Image.Get_D);
    begin
        return Prb.To_RGB
           (Natural (Image.Get_Datum (Base + 1)),
            Natural (Image.Get_Datum (Base + 2)),
            Natural (Image.Get_Datum (Base + 3)));
    end Pixel;

    function Handle
           (This  : in out Receiver_Box;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        if Event /= Paste then
            return Bx.Box (This).Handle (Event);
        end if;
        This.Pastes := This.Pastes + 1;
        This.Is_Image := Ev.Has_Clipboard_Image;
        if This.Is_Image then
            if This.Take then
                declare
                    Image : constant RGB.RGB_Image := RGB.Forge.Pasted;
                begin
                    This.Took := True;
                    This.W := Image.Get_Data_W;
                    This.H := Image.Get_Data_H;
                    This.Left := Pixel (Image, 1, This.H / 2);
                    This.Right := Pixel (Image, This.W - 2, This.H / 2);
                end;
            end if;
        else
            This.Text := (others => ' ');
            This.Text (1 .. Ev.Clipboard_Text'Length) := Ev.Clipboard_Text;
        end if;
        return (if This.Accepts then Handled else Not_Handled);
    end Handle;


    --  Takes part in drag and drop if Accepts: keeps the last such event it
    --  got, and how many.
    type DnD_Box is new Bx.Box with record
        Accepts : Boolean    := True;
        Last   : Event_Kind := No_Event;
        Events : Natural    := 0;
    end record;

    overriding function Handle
           (This  : in out DnD_Box;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle
           (This  : in out DnD_Box;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        if Event in DnD_Enter .. DnD_Release then
            This.Last := Event;
            This.Events := This.Events + 1;
            return (if This.Accepts then Handled else Not_Handled);
        end if;
        return Bx.Box (This).Handle (Event);
    end Handle;


    function Same
           (Item   : access Wdg.Widget'Class;
            Wanted : in     Wdg.Widget'Class)
        return Boolean
    is
        use type System.Address;
    begin
        return Item /= null and then Item.all'Address = Wanted'Address;
    end Same;

    function Starts
           (Text, Prefix : in String)
        return Boolean is
    begin
        return Text'Length >= Prefix'Length
            and then Text (Text'First .. Text'First + Prefix'Length - 1) = Prefix
            and then (for all C of Text (Text'First + Prefix'Length .. Text'Last) => C = ' ');
    end Starts;

    function Has_Text return Boolean is
        (St.Clipboard_Contains (Clipboard_Plain_Text));

    function Has_Image return Boolean is
        (St.Clipboard_Contains (Clipboard_Image));


    Window   : Win.Window := Win.Forge.Create (0, 0, 100, 100, "Test_Clipboard");
    Receiver : Receiver_Box := (Bx.Forge.Create (Window, 0, 0, 10, 10) with others => <>);
    Input    : Txt.Text_Input := Txt.Forge.Create (Window, 0, 20, 100, 20);


    --  Drawing on a Copy_Surface and pasting it back: red, with a blue box
    --  drawn at its right.
    procedure Copy_Surfaces is
        Small : Win.Window := Win.Forge.Create (0, 0, 8, 6);
        Blue  : Bx.Box := Bx.Forge.Create (Small, Flat_Box, 0, 0, 4, 6);
    begin
        Small.End_Current;
        Blue.Set_Background_Color (RGB_Blue_Color);
        St.Copy ("before", St.Clipboard);
        declare
            Surface : Cs.Copy_Surface := Cs.Forge.Create (8, 6);
        begin
            Srf.Push_Current (Surface);
            Drw.Set_Color (RGB_Red_Color);
            Drw.Rect_Fill (0, 0, 8, 6);
            Surface.Draw_Widget (Blue, 4, 0);
            Srf.Pop_Current;
            Check (not Has_Image, "the clipboard isn't written while the Copy_Surface lives");
        end;
        Check (Has_Image, "finalizing it puts it on the clipboard");
        Receiver.Take := True;
        Receiver.Took := False;
        St.Paste_Image (Receiver);
        Check (Receiver.Took and Receiver.W = 8 and Receiver.H = 6
                and Receiver.Left = 16#FF0000# and Receiver.Right = 16#0000FF#,
            "and it pastes as drawn");
        Receiver.Take := False;

        --  Copy surfaces and image surfaces nest.
        declare
            Image_Surface : Ims.Image_Surface := Ims.Forge.Create (2, 2);
        begin
            Srf.Push_Current (Image_Surface);
            declare
                Surface : Cs.Copy_Surface := Cs.Forge.Create (2, 2);
            begin
                Srf.Push_Current (Surface);
                Drw.Set_Color (RGB_Red_Color);
                Drw.Rect_Fill (0, 0, 2, 2);
                Srf.Pop_Current;
            end;
            Drw.Set_Color (RGB_Blue_Color);
            Drw.Rect_Fill (0, 0, 2, 2);
            Srf.Pop_Current;
            declare
                Image : constant RGB.RGB_Image := Image_Surface.Get_Image;
            begin
                Check (Pixel (Image, 1, 1) = 16#0000FF#,
                    "they nest with image surfaces");
            end;
        end;

        --  A window, with its title bar where FLTK can get at it.
        St.Copy ("before", St.Clipboard);
        Small.Show;
        Small.Wait_For_Expose;
        declare
            Surface : Cs.Copy_Surface :=
                Cs.Forge.Create (Small.Get_Decorated_W, Small.Get_Decorated_H);
        begin
            Surface.Draw_Decorated_Window (Small);
        end;
        Check (Has_Image, "Draw_Decorated_Window");
        Small.Hide;
    end Copy_Surfaces;


    procedure Drag_And_Drop is
        --  In a window of its own, with no input: DnD_Leave to a window
        --  never shown crashes FLTK in an Fl_Input (pofltk 53).
        Drop_Window : Win.Window := Win.Forge.Create (0, 0, 100, 100, "drag and drop");
        Target      : DnD_Box := (Bx.Forge.Create (Drop_Window, 50, 50, 20, 20) with others => <>);
        Ignore      : Boolean;
    begin
        Drop_Window.End_Current;
        Check (Prb.Mouse (Drop_Window, DnD_Enter, 55, 55, No_Button)
                and Target.Last = DnD_Enter and Same (Ev.Get_Below_Mouse, Target),
            "DnD_Enter: a widget that takes it is below the mouse");
        Check (Prb.Mouse (Drop_Window, DnD_Drag, 60, 60, No_Button)
                and Target.Last = DnD_Drag and Target.Events = 2,
            "DnD_Drag over it");
        Check (Prb.Mouse (Drop_Window, DnD_Release, 60, 60, No_Button)
                and Target.Last = DnD_Release,
            "DnD_Release: Handled takes the drop");
        --  Not handled: the window has no use for it.
        Ignore := Prb.Mouse (Drop_Window, DnD_Drag, 90, 5, No_Button);
        Check (Target.Last = DnD_Leave and Target.Events = 4
                and Same (Ev.Get_Below_Mouse, Drop_Window),
            "DnD_Leave: dragged off it");
        Ignore := Prb.Mouse (Drop_Window, DnD_Leave, 90, 5, No_Button);
        Check (Target.Events = 5 and Target.Last = DnD_Leave and Ev.Get_Below_Mouse = null,
            "DnD_Leave: out of the window, which passes it to each child again");
        Target.Accepts := False;
        Target.Events := 0;
        Check (not Prb.Mouse (Drop_Window, DnD_Enter, 55, 55, No_Button)
                and Target.Last = DnD_Enter and not Same (Ev.Get_Below_Mouse, Target),
            "DnD_Enter refused: not below the mouse");
        Ignore := Prb.Mouse (Drop_Window, DnD_Leave, 90, 5, No_Button);
    end Drag_And_Drop;


    Before : Natural;

begin

    Window.End_Current;

    --  Before the program owns either, under X11 no window is shown to ask
    --  for another program's data: nothing is pasted.
    St.Paste (Receiver, St.Selection);
    St.Paste (Receiver, St.Clipboard);
    Check (Receiver.Pastes = 0, "Paste with nothing to paste");

    --  Text.
    St.Copy ("hello", St.Clipboard);
    Check (Has_Text and not Has_Image, "Copy: the clipboard holds text");
    St.Paste (Receiver, St.Clipboard);
    Check (Receiver.Pastes = 1 and not Receiver.Is_Image and Starts (Receiver.Text, "hello"),
        "Paste of the program's own text: at once");
    Input.Set_Value ("ab");
    Input.Set_Position (1);
    St.Paste (Input, St.Clipboard);
    Check (Input.Get_Value = "ahellob", "an input pastes at its cursor: " & Input.Get_Value);
    if not Prb.On_Wayland then
        St.Copy ("sel", St.Selection);
        St.Paste (Receiver, St.Selection);
        Check (Receiver.Pastes = 2 and Starts (Receiver.Text, "sel"),
            "the selection buffer (X11)");
        St.Paste (Receiver, St.Clipboard);
        Check (Starts (Receiver.Text, "hello"), "apart from the clipboard");
    else
        St.Copy ("sel", St.Selection);
        St.Paste (Receiver, St.Selection);
        Check (Receiver.Pastes = 1, "no selection buffer (Wayland)");
        St.Paste (Receiver, St.Clipboard);
    end if;
    St.Copy_To_Both ("both");
    St.Paste (Receiver, St.Clipboard);
    Check (Starts (Receiver.Text, "both"), "Copy_To_Both: the clipboard");
    if not Prb.On_Wayland then
        Receiver.Text := (others => ' ');
        St.Paste (Receiver, St.Selection);
        Check (Starts (Receiver.Text, "both"), "and the selection buffer (X11)");
    end if;

    --  Images.
    Copy_Surfaces;
    Check (Has_Image and not Has_Text, "an image replaces the text");
    Before := Receiver.Pastes;
    Receiver.Took := False;
    St.Paste_Image (Receiver);
    Check (Receiver.Pastes = Before + 1 and Receiver.Is_Image and not Receiver.Took,
        "Paste_Image: a Paste with an image, which needn't be taken");
    --  An image not taken is freed, whatever Handle returns: valgrind sees
    --  no leak and no double free.
    Receiver.Accepts := False;
    St.Paste_Image (Receiver);
    Receiver.Accepts := True;
    Check (Receiver.Pastes = Before + 2, "an image not taken, refused or accepted");

    Drag_And_Drop;

    Summary;

end Test_Clipboard;
