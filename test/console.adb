

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  A terminal showing the output of commands typed in a line below it,
--  after pofltk's examples/Console.Mod.
--
--  Enter runs the line with the shell, and its output and errors come into
--  the terminal as they are written, with their colours, if they have any:
--  try "ls --color=always /" or "ping -c 3 localhost".  The line takes no
--  input until the command ends.  The window takes events meanwhile, since
--  FLTK calls Output_Ready only when the pipe has something to read.
--
--  What is read is appended as it comes, not a line at a time as pofltk
--  does:  the terminal keeps a UTF-8 character or an escape sequence cut
--  in two by a read until the rest of it comes.
--
--  If the window is closed while a command runs, the program waits for it
--  to end before it exits.


with

    Interfaces.C.Strings,
    FLTK.Static,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text,
    GNAT.OS_Lib,
    System;


function Console
    return Integer
is


    package Sta renames FLTK.Static;
    package Wdg renames FLTK.Widgets;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package ICS renames Interfaces.C.Strings;

    use type Interfaces.C.int;
    use type System.Address;


    Green  : constant String := "1;32";
    Red    : constant String := "1;31";
    Normal : constant String := "0";


    --  C's popen, fileno and pclose.  The stream is used only for its file
    --  descriptor, which is read directly, so stdio never reads ahead of
    --  what Add_File_Descriptor reports.
    function Popen
           (Command, Mode : in ICS.chars_ptr)
        return System.Address
        with Import, Convention => C, External_Name => "popen";

    function Fileno
           (Stream : in System.Address)
        return Interfaces.C.int
        with Import, Convention => C, External_Name => "fileno";

    function Pclose
           (Stream : in System.Address)
        return Interfaces.C.int
        with Import, Convention => C, External_Name => "pclose";


    Window : Dbl.Double_Window := Dbl.Forge.Create (640, 400, "Console");
    Output : Trm.Terminal := Trm.Forge.Create (Window, 0, 0, 640, 365);
    Line   : Inp.Text_Input := Inp.Forge.Create (Window, 70, 370, 560, 25, "Run:");

    --  The running command's stream, or Null_Address.
    Stream : System.Address := System.Null_Address;


    --  The sequence that sets the text's colour or attributes.
    function SGR
           (Code : in String)
        return String is (ASCII.ESC & "[" & Code & "m");


    procedure Say
           (Colour, Text : in String) is
    begin
        Output.Append (SGR (Colour) & Text & ASCII.LF & SGR (Normal));
    end Say;


    --  pclose's result as an exit status, or -1 if the command didn't exit,
    --  as WIFEXITED and WEXITSTATUS read it on Linux and the BSDs.
    function Exit_Status
           (Status : in Interfaces.C.int)
        return Integer is
    begin
        if Status = -1 or else Status mod 16#80# /= 0 then
            return -1;
        else
            return Integer (Status / 16#100# mod 16#100#);
        end if;
    end Exit_Status;


    --  The command is over:  the line takes the next one.
    procedure Ready is
    begin
        Line.Set_Value ("");
        Line.Activate;
        if Line.Take_Focus then
            null;
        end if;
    end Ready;


    --  Closes the command's stream, and reports its exit status if that
    --  isn't 0.
    procedure Finish is
        Status : constant Integer := Exit_Status (Pclose (Stream));
        Text   : constant String := Integer'Image (Status);
    begin
        Stream := System.Null_Address;
        --  The command may have left a colour set.
        Output.Append (SGR (Normal));
        if Status < 0 then
            Say (Red, "exit status unknown");
        elsif Status /= 0 then
            Say (Red, "exit status" & Text);
        end if;
    end Finish;


    procedure Output_Ready
           (FD : in Sta.File_Descriptor)
    is
        Buffer : String (1 .. 4096);
        Count  : constant Integer :=
            GNAT.OS_Lib.Read (GNAT.OS_Lib.File_Descriptor (FD), Buffer'Address, Buffer'Length);
    begin
        if Count > 0 then
            Output.Append (Buffer (1 .. Count));
        else
            Sta.Remove_File_Descriptor (FD);
            Finish;
            Ready;
        end if;
    end Output_Ready;


    procedure Command_CB
           (Ignore : in out Wdg.Widget'Class)
    is
        Text    : constant String := Line.Get_Value;
        Command : ICS.chars_ptr;
        Mode    : ICS.chars_ptr := ICS.New_String ("r");
    begin
        if Text = "" then
            ICS.Free (Mode);
            return;
        end if;
        Say (Green, "$ " & Text);
        --  The braces send the errors of every command in the line.
        Command := ICS.New_String ("{ " & Text & ASCII.LF & "} 2>&1");
        Stream := Popen (Command, Mode);
        ICS.Free (Command);
        ICS.Free (Mode);
        if Stream = System.Null_Address then
            Say (Red, "popen failed");
            Ready;
        else
            Line.Deactivate;
            Sta.Add_File_Descriptor
               (Sta.File_Descriptor (Fileno (Stream)),
                Sta.Read_Mode,
                Output_Ready'Unrestricted_Access);
        end if;
    end Command_CB;


begin


    Output.Set_ANSI (True);
    Output.Set_History_Rows (1000);
    --  The callback on Enter.
    Line.Set_When (FLTK.When_Enter_Key_Always);
    Line.Set_Callback (Command_CB'Unrestricted_Access);
    Window.Set_Resizable (Output);
    Say (Green, "Type a command below, and press Enter.");
    Window.Show_With_Args;

    return Result : constant Integer := FLTK.Run do
        if Stream /= System.Null_Address then
            Sta.Remove_File_Descriptor (Sta.File_Descriptor (Fileno (Stream)));
            if Pclose (Stream) = -1 then
                null;
            end if;
        end if;
    end return;


end Console;

