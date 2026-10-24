

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/simple-terminal.cxx: a window whose bottom
--  part is an Fl_Terminal that receives a timestamped message every 2 seconds.
--
--  Deliberate differences from the C++:
--
--  * C's ctime() is not available, so Ctime_Image below rebuilds its exact
--    "Www Mmm dd hh:mm:ss yyyy" + LF format (day of month space-padded, local
--    time) from Ada.Calendar.Formatting.
--
--  * printf is replaced by building the message as an Ada String and passing
--    it to Print.


with

    Ada.Calendar.Formatting,
    Ada.Calendar.Time_Zones,
    Ada.Characters.Latin_1,
    Ada.Strings.Fixed,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double;


function Simple_Terminal
    return Integer
is


    package Cal   renames Ada.Calendar;
    package Fmt   renames Ada.Calendar.Formatting;
    package Latin renames Ada.Characters.Latin_1;
    package Stc   renames FLTK.Static;
    package Bx    renames FLTK.Widgets.Boxes;
    package Term  renames FLTK.Widgets.Groups.Terminals;
    package WD    renames FLTK.Widgets.Groups.Windows.Double;


    Terminal_Height : constant Integer := 120;


    G_Win : WD.Double_Window :=
        WD.Forge.Create (500, 200 + Terminal_Height, "Your App");

    G_Box : Bx.Box := Bx.Forge.Create
       (G_Win, 0, 0, G_Win.Get_W, 200,
        "Your app GUI in this area." & Latin.LF & Latin.LF &
        "Your app's debugging output in tty below");

    --  Add simple terminal to bottom of app window for scrolling history of status messages.
    G_Tty : Term.Terminal := Term.Forge.Create
        (G_Win, 0, 200, G_Win.Get_W, Terminal_Height);


    --  Equivalent of C's ctime(): "Www Mmm dd hh:mm:ss yyyy" followed by a newline
    function Ctime_Image
           (Moment : in Cal.Time)
        return String
    is
        Day_Names : constant array (Fmt.Day_Name) of String (1 .. 3) :=
           ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun");
        Month_Names : constant array (Cal.Month_Number) of String (1 .. 3) :=
           ("Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

        function Two_Digits
               (Value : in Natural;
                Pad   : in Character := '0')
            return String
        is
            Digits_Image : constant String := Natural'Image (Value);
        begin
            if Value < 10 then
                return Pad & Digits_Image (Digits_Image'Last);
            else
                return Digits_Image (Digits_Image'Last - 1 .. Digits_Image'Last);
            end if;
        end Two_Digits;

        Year       : Cal.Year_Number;
        Month      : Cal.Month_Number;
        Day        : Cal.Day_Number;
        Hour       : Fmt.Hour_Number;
        Minute     : Fmt.Minute_Number;
        Second     : Fmt.Second_Number;
        Sub_Second : Fmt.Second_Duration;
    begin
        --  Split in local time, as ctime() does (Day_Of_Week is already local in GNAT)
        Fmt.Split (Moment, Year, Month, Day, Hour, Minute, Second, Sub_Second,
            Time_Zone => Cal.Time_Zones.Local_Time_Offset (Moment));
        return Day_Names (Fmt.Day_Of_Week (Moment)) & " " &
            Month_Names (Month) & " " &
            Two_Digits (Day, ' ') & " " &
            Two_Digits (Hour) & ":" &
            Two_Digits (Minute) & ":" &
            Two_Digits (Second) & " " &
            Ada.Strings.Fixed.Trim (Cal.Year_Number'Image (Year), Ada.Strings.Left) & Latin.LF;
    end Ctime_Image;


    --  Append a date/time message to the terminal every 2 seconds
    procedure Tick is
    begin
        G_Tty.Print ("Timer tick: " & Latin.ESC & "[32m" & Ctime_Image (Cal.Clock) &
            Latin.ESC & "[0m" & Latin.LF);
        Stc.Repeat_Timeout (2.0, Tick'Unrestricted_Access);
    end Tick;


begin


    pragma Unreferenced (G_Box);

    G_Tty.Set_ANSI (True);  --  enable use of ESC & "[32m"

    G_Win.Set_Resizable (G_Win);
    G_Win.Show_With_Args;
    Stc.Add_Timeout (0.5, Tick'Unrestricted_Access);
    return FLTK.Run;


end Simple_Terminal;

