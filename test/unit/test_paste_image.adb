--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Pasting text and images (PLAN.md Phase 8; pofltk 48).  This program
--  copies a 20x10 red image to the clipboard with a Copy_Surface and pastes
--  it into a box, which takes it with FLTK.Images.RGB.Forge.Pasted.  A
--  second paste the box refuses must not leak the image: under Wayland FLTK
--  never deletes an image this program copied (pofltk 48), and
--  make valgrind-sway shows the leak if FLTKAda doesn't delete it either.
--  A text paste checks FLTK.Events.Clipboard_Text (FLTKAda-BUGS.md 67).


with

    Ada.Exceptions,
    Ada.Strings.Unbounded,
    Checks,
    FLTK.Devices.Surface.Copy,
    FLTK.Draw,
    FLTK.Events,
    FLTK.Images.RGB,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;

use

    Checks,
    FLTK;


procedure Test_Paste_Image is

    package SU  renames Ada.Strings.Unbounded;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;
    package RGB renames FLTK.Images.RGB;
    package Cs  renames FLTK.Devices.Surface.Copy;

    type Paste_Box is new Bx.Box with record
        Take       : Boolean := False;
        Pastes     : Natural := 0;
        Has_Image  : Boolean := False;
        Text       : SU.Unbounded_String;
        Kind       : SU.Unbounded_String;
        Took_W     : Integer := -1;
        Took_H     : Integer := -1;
        Took_Red   : Integer := -1;
        Took_Green : Integer := -1;
        Again      : Boolean := False;
    end record;

    overriding function Handle
           (This  : in out Paste_Box;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle
           (This  : in out Paste_Box;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        if Event /= Paste then
            return Bx.Box (This).Handle (Event);
        end if;
        This.Pastes    := This.Pastes + 1;
        This.Has_Image := FLTK.Events.Has_Clipboard_Image;
        This.Text      := SU.To_Unbounded_String (FLTK.Events.Clipboard_Text);
        This.Kind      := SU.To_Unbounded_String (FLTK.Events.Clipboard_Kind);
        if not This.Take then
            return Not_Handled;
        end if;
        declare
            Image : constant RGB.RGB_Image := RGB.Forge.Pasted;
        begin
            This.Took_W     := Image.Get_W;
            This.Took_H     := Image.Get_H;
            This.Took_Red   := Integer (Image.Get_Datum (1));
            This.Took_Green := Integer (Image.Get_Datum (2));
        end;
        --  The image is the program's now; taking it again must refuse.
        begin
            declare
                Image : constant RGB.RGB_Image := RGB.Forge.Pasted;
                pragma Unreferenced (Image);
            begin
                null;
            end;
        exception
        when Program_Error =>
            This.Again := True;
        end;
        return Handled;
    end Handle;

    Window : Win.Window := Win.Forge.Create (100, 100, 80, 60, "paste");
    The_Box : Paste_Box := (Bx.Forge.Create (Window, Flat_Box, 10, 10, 60, 40) with others => <>);

    procedure Take_Outside is
        Image : constant RGB.RGB_Image := RGB.Forge.Pasted;
        pragma Unreferenced (Image);
    begin
        null;
    end Take_Outside;

begin

    Window.Show;
    FLTK.Check;

    --  Text  --

    FLTK.Static.Copy ("hello, paste", FLTK.Static.Clipboard);
    FLTK.Static.Paste (The_Box, FLTK.Static.Clipboard);
    Check (The_Box.Pastes = 1, "pasting our own text reaches the box at once");
    Check (SU.To_String (The_Box.Text) = "hello, paste",
        "Clipboard_Text is the pasted text, got """ & SU.To_String (The_Box.Text) & '"');
    Check (not The_Box.Has_Image, "a text paste carries no image");
    Check (SU.To_String (The_Box.Kind) = "text/plain",
        "Clipboard_Kind is ""text/plain"", got """ & SU.To_String (The_Box.Kind) & '"');

    --  An image  --

    declare
        Surface : Cs.Copy_Surface := Cs.Forge.Create (20, 10);
    begin
        FLTK.Devices.Surface.Push_Current (Surface);
        FLTK.Draw.Rect_Fill (0, 0, 20, 10, 255, 0, 0);
        FLTK.Devices.Surface.Pop_Current;
    end;

    The_Box.Take := True;
    FLTK.Static.Paste_Image (The_Box);
    Check (The_Box.Pastes = 2, "pasting our own image reaches the box at once");
    Check (The_Box.Has_Image, "the paste carries an image");
    Check (SU.To_String (The_Box.Kind) = "image",
        "Clipboard_Kind is ""image"", got """ & SU.To_String (The_Box.Kind) & '"');
    Check (SU.To_String (The_Box.Text) = "", "Clipboard_Text is """" for an image");
    Check (The_Box.Took_W = 20 and The_Box.Took_H = 10, "the image taken is 20x10, got"
        & Integer'Image (The_Box.Took_W) & " x" & Integer'Image (The_Box.Took_H));
    Check (The_Box.Took_Red = 255 and The_Box.Took_Green = 0, "the image taken is red");
    Check (The_Box.Again, "taking the image a second time raises Program_Error");

    --  Refused: FLTKAda deletes it  --

    The_Box.Take := False;
    FLTK.Static.Paste_Image (The_Box);
    Check (The_Box.Pastes = 3 and The_Box.Has_Image, "a refused image paste reaches the box");

    --  Text again: FLTK leaves the type at "image" (FLTK-issues.md F13)  --

    FLTK.Static.Copy ("and again", FLTK.Static.Clipboard);
    FLTK.Static.Paste (The_Box, FLTK.Static.Clipboard);
    Check (The_Box.Pastes = 4, "the text paste after an image reaches the box");
    Check (SU.To_String (The_Box.Kind) = "text/plain",
        "after an image, Clipboard_Kind is ""text/plain"", got """
        & SU.To_String (The_Box.Kind) & '"');
    Check (SU.To_String (The_Box.Text) = "and again",
        "after an image, Clipboard_Text is the text, got """ & SU.To_String (The_Box.Text) & '"');
    Check (not The_Box.Has_Image, "after an image, a text paste carries no image");

    --  Outside a paste  --

    Check (not FLTK.Events.Has_Clipboard_Image, "no image outside a paste");
    Raises (Take_Outside'Access, Program_Error'Identity, "Pasted outside a paste raises");

    Window.Hide;
    Summary;

exception
when Occurrence : others =>
    Check (False, "unexpected " & Ada.Exceptions.Exception_Information (Occurrence));
    Summary;
end Test_Paste_Image;
