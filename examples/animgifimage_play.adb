

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  An Ada port of FLTK's examples/animgifimage-play.cxx: plays animated
--  GIFs under application control, using its own timeouts rather than
--  letting the animation play itself.
--
--  Usage: animgifimage-play [-r] [-s speed] file.gif [file.gif ...]
--
--  Keys: N = next file, I = toggle frame info, R = play reverse,
--  + / - / Enter = change speed, Space = pause, Right = next frame
--  while paused, Z / Shift-Z = zoom in / out.
--
--  Deliberate differences:
--
--  The C++ version cycles through argv itself, blanking out the value
--  that follows -s. Here the file arguments are collected into a vector
--  once, and cycled through in the same order.
--
--  The speed given with -s is parsed with Long_Float'Value rather than
--  atof, and anything that does not parse is treated as 0, which (as in
--  the C++ version) then resets the speed to 1.
--
--  Showing the next frame of an animation with no frames (a file that
--  failed to load) does nothing, where the C++ version passes an out of
--  range frame number to Fl_Anim_GIF_Image::frame.


with

    Ada.Command_Line,
    Ada.Containers.Indefinite_Vectors,
    Ada.Long_Float_Text_IO,
    Ada.Strings.Fixed,
    Ada.Text_IO,
    FLTK.Events,
    FLTK.Images.Pixmaps.GIF.Animated,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Event_Kind,
    FLTK.Keypress;


function Animgifimage_Play
    return Integer
is

    package ACL  renames Ada.Command_Line;
    package TIO  renames Ada.Text_IO;
    package Anim renames FLTK.Images.Pixmaps.GIF.Animated;
    package Box  renames FLTK.Widgets.Boxes;
    package WD   renames FLTK.Widgets.Groups.Windows.Double;

    package String_Vectors is new Ada.Containers.Indefinite_Vectors
       (Index_Type   => Positive,
        Element_Type => String);


    Speed_Factor : Long_Float := 1.0;    --  slow down/speed up playback by factor
    Reverse_Play : Boolean    := False;  --  True = play animation backwards
    Paused       : Boolean    := False;  --  flag for paused animation
    Frame_Info   : Boolean    := False;  --  flag to update current frame info in title

    Files        : String_Vectors.Vector;  --  the file arguments, in order
    Current_File : Natural := 0;           --  current index in Files

    Animation    : Anim.Animated_GIF_Image := Anim.Forge.Create;  --  the animation object


    function Img
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Left);
    end Img;


    --  Like C's "%3.2f".
    function Fixed_2
           (Value : in Long_Float)
        return String
    is
        Result : String (1 .. 40);
    begin
        Ada.Long_Float_Text_IO.Put (Result, Value, Aft => 2, Exp => 0);
        return Ada.Strings.Fixed.Trim (Result, Ada.Strings.Left);
    end Fixed_2;


    function Next_File
        return String is
    begin
        Current_File := (if Current_File >= Files.Last_Index then 1 else Current_File + 1);
        return Files (Current_File);
    end Next_File;


    procedure Set_Title
    is
        function Info
            return String is
        begin
            if Frame_Info then
                return "frame " & Img (Animation.Get_Frame) & "/" & Img (Animation.Frames);
            else
                return Img (Animation.Frames) & " frames";
            end if;
        end Info;
    begin
        FLTK.Static.Get_First_Window.Set_Label
           (Files (Current_File) & " (" & Info & ") x " & Fixed_2 (Speed_Factor) & " " &
            (if Reverse_Play then "reverse" else "") &
            (if Paused then " PAUSED" else ""));
    end Set_Title;


    procedure Anim_Callback
    is
        Frame : Integer := Animation.Get_Frame;
    begin
        if Animation.Frames = 0 then
            return;
        end if;

        --  switch to next/previous frame
        if Reverse_Play then
            Animation.Get_Canvas.Nearest_Window.Redraw;
            Frame := Frame - 1;
            if Frame < 1 then
                Frame := Animation.Frames;
            end if;
        else
            Frame := Frame + 1;
            if Frame > Animation.Frames then
                Frame := 1;
            end if;
        end if;

        --  set the frame (and update canvas)
        Animation.Set_Frame (Frame);

        --  setup timer for next frame
        if not Paused and Animation.Get_Delay (Frame) /= 0.0 then
            FLTK.Static.Repeat_Timeout
               (Animation.Get_Delay (Frame) / Speed_Factor,
                Anim_Callback'Unrestricted_Access);
        end if;
        if Frame_Info then
            Set_Title;
        end if;
    end Anim_Callback;


    procedure Next_Frame is
    begin
        Anim_Callback;
    end Next_Frame;


    procedure Toggle_Pause is
    begin
        Paused := not Paused;
        Set_Title;
        if Paused then
            FLTK.Static.Remove_Timeout (Anim_Callback'Unrestricted_Access);
        else
            Next_Frame;
        end if;
        Set_Title;
    end Toggle_Pause;


    procedure Toggle_Info is
    begin
        Frame_Info := not Frame_Info;
        Set_Title;
    end Toggle_Info;


    procedure Toggle_Reverse is
    begin
        Reverse_Play := not Reverse_Play;
        Set_Title;
    end Toggle_Reverse;


    procedure Zoom
           (Zoom_Out : in Boolean)
    is
        W : constant Natural := Animation.Get_W;
        H : constant Natural := Animation.Get_H;
        --  Note: deliberately no range check (use key 'N' to reset)
        F : constant Long_Float := 1.05;
    begin
        if Zoom_Out then
            Animation.Resize
               (Natural (Long_Float'Truncation (Long_Float (W) / F)),
                Natural (Long_Float'Truncation (Long_Float (H) / F)));
        else
            Animation.Resize
               (Natural (Long_Float'Truncation (F * Long_Float (W))),
                Natural (Long_Float'Truncation (F * Long_Float (H))));
        end if;
    end Zoom;


    procedure Change_Speed
           (Direction : in Integer) is
    begin
        if Direction > 0 then
            Speed_Factor := Speed_Factor + (if Speed_Factor < 1.0 then 0.01 else 0.1);
            if Speed_Factor > 100.0 then
                Speed_Factor := 100.0;
            end if;
        elsif Direction < 0 then
            Speed_Factor := Speed_Factor - (if Speed_Factor > 1.0 then 0.1 else 0.01);
            if Speed_Factor < 0.01 then
                Speed_Factor := 0.01;
            end if;
        else
            Speed_Factor := 1.0;
        end if;
        Set_Title;
    end Change_Speed;


    procedure Load_Next is
    begin
        FLTK.Static.Remove_Timeout (Anim_Callback'Unrestricted_Access);
        Paused := False;
        Animation.Load (Next_File);
        Animation.Get_Canvas.Nearest_Window.Redraw;
        --  check if loading succeeded
        TIO.Put_Line
           ("valid: " & Img (Boolean'Pos (Animation.Is_Loaded)) &
            " frames: " & Img (Animation.Frames));
        if Animation.Is_Loaded then
            TIO.Put_Line
               ("play '" & Animation.Name & "'" &
                (if Reverse_Play then " reverse" else "") &
                " with " & Fixed_2 (Speed_Factor) & " x speed");
            Animation.Set_Frame (if Reverse_Play then Animation.Frames else 1);
            --  setup first timeout, but check for zero-delay (normal GIF)!
            if Animation.Get_Delay (Animation.Get_Frame) /= 0.0 then
                FLTK.Static.Add_Timeout
                   (Animation.Get_Delay (Animation.Get_Frame) / Speed_Factor,
                    Anim_Callback'Unrestricted_Access);
            end if;
        end if;
        Set_Title;
    end Load_Next;


    function Events
           (Event : in FLTK.Event_Kind)
        return FLTK.Event_Outcome
    is
        Key : FLTK.Keypress;
    begin
        if Event = FLTK.Shortcut and FLTK.Static.Get_First_Window /= null then
            Key := FLTK.Events.Last_Key;
            if Key = FLTK.Press ('+') then
                Change_Speed (1);
            elsif Key = FLTK.Press ('-') then
                Change_Speed (-1);
            elsif Key = FLTK.Enter_Key then
                Change_Speed (0);
            elsif Key = FLTK.Press ('n') then
                Load_Next;
            elsif Key = FLTK.Press ('z') then
                Zoom (FLTK.Events.Key_Shift);
            elsif Key = FLTK.Press ('i') then
                Toggle_Info;  --  Note: this can raise cpu usage considerably!
            elsif Key = FLTK.Press ('r') then
                Toggle_Reverse;
            elsif Key = FLTK.Press (' ') then
                Toggle_Pause;
            elsif Key = FLTK.Right_Key then
                if Paused and FLTK.Events.Key_Now (FLTK.Right_Key) then
                    Next_Frame;
                end if;
            else
                return FLTK.Not_Handled;
            end if;
            FLTK.Static.Get_First_Window.Redraw;
            return FLTK.Handled;
        end if;
        return FLTK.Not_Handled;
    end Events;


    Arg : Positive := 1;


begin

    --  setup play parameters from args
    while Arg <= ACL.Argument_Count loop
        declare
            Item : constant String := ACL.Argument (Arg);
        begin
            if Item = "-r" then
                Reverse_Play := not Reverse_Play;
            elsif Item = "-s" and Arg < ACL.Argument_Count then
                Arg := Arg + 1;
                begin
                    Speed_Factor := Long_Float'Value (ACL.Argument (Arg));
                exception
                    when Constraint_Error =>
                        Speed_Factor := 0.0;
                end;
            elsif Item'Length = 0 or else Item (Item'First) /= '-' then
                Files.Append (Item);
            else
                TIO.Put_Line ("Invalid argument: '" & Item & "'");
                return 1;
            end if;
        end;
        Arg := Arg + 1;
    end loop;

    if Files.Is_Empty then
        TIO.Put_Line (TIO.Standard_Error, "Test program for application controlled GIF animation.");
        TIO.Put_Line (TIO.Standard_Error, "Please specify one or more image files!");
        return 0;
    end if;
    if Speed_Factor < 0.01 or Speed_Factor > 100.0 then
        Speed_Factor := 1.0;
    end if;

    declare
        The_Window : WD.Double_Window := WD.Forge.Create (800, 600);

        --  prepare a canvas for the animation
        --  (we want to show it in the center of the window)
        Canvas : Box.Box := Box.Forge.Create
           (The_Window, 0, 0, The_Window.Get_W, The_Window.Get_H);
        Help   : constant Box.Box := Box.Forge.Create
           (The_Window, 0, The_Window.Get_H - 20, The_Window.Get_W, 20,
            "Keys: N=next file, I=toggle info, R=play reverse, " &
            "+/-/Enter/Space=change speed, Z=Zoom");
        pragma Unreferenced (Help);
    begin
        The_Window.Set_Resizable (The_Window);

        The_Window.Show;
        FLTK.Events.Add_Handler (Events'Unrestricted_Access);

        --  use the Dont_Resize_Canvas flag to tell the animation
        --  not to change the canvas size (which is the default).
        Animation.Set_Canvas (Canvas, Anim.Flag_Dont_Resize_Canvas);
        --  Animation.Set_Canvas (Canvas, Anim.Flag_Dont_Resize_Canvas +
        --      Anim.Flag_Debug + Anim.Flag_Log);

        Load_Next;
        return FLTK.Run;
    end;

end Animgifimage_Play;


