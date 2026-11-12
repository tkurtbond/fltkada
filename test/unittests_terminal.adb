--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Static,
    FLTK.Widgets.Groups.Terminals,
    Interfaces.C.Strings;


package body Unittests_Terminal is


    package Grp renames FLTK.Widgets.Groups;
    package Trm renames FLTK.Widgets.Groups.Terminals;

    use Unittests_Common;


    --  test the Terminal drawing capabilities

    type Terminal_Access is access Trm.Terminal;
    type Group_Access is access Grp.Group;

    Tty1, Tty2 : Terminal_Access;


    procedure ANSI_Test_Pattern
           (Tty : in out Trm.Terminal) is
    begin
        Tty.Append
           (ASCII.ESC & "[30mBlack          Courier 14" & ASCII.ESC & "[0m Normal text" &
            ASCII.LF & ASCII.ESC & "[31mRed            Courier 14" & ASCII.ESC &
            "[0m Normal text" & ASCII.LF & ASCII.ESC & "[32mGreen          Courier 14" &
            ASCII.ESC & "[0m Normal text" & ASCII.LF & ASCII.ESC &
            "[33mYellow         Courier 14" & ASCII.ESC & "[0m Normal text" & ASCII.LF &
            ASCII.ESC & "[34mBlue           Courier 14" & ASCII.ESC & "[0m Normal text" &
            ASCII.LF & ASCII.ESC & "[35mMagenta        Courier 14" & ASCII.ESC &
            "[0m Normal text" & ASCII.LF & ASCII.ESC & "[36mCyan           Courier 14" &
            ASCII.ESC & "[0m Normal text" & ASCII.LF & ASCII.ESC &
            "[37mWhite          Courier 14" & ASCII.ESC & "[0m Normal text" & ASCII.LF &
            ASCII.ESC & "[1;30mBright Black   Courier 14" & ASCII.ESC & "[0m Normal text" &
            ASCII.LF & ASCII.ESC & "[1;31mBright Red     Courier 14" & ASCII.ESC &
            "[0m Normal text" & ASCII.LF & ASCII.ESC & "[1;32mBright Green   Courier 14" &
            ASCII.ESC & "[0m Normal text" & ASCII.LF & ASCII.ESC &
            "[1;33mBright Yellow  Courier 14" & ASCII.ESC & "[0m Normal text" & ASCII.LF &
            ASCII.ESC & "[1;34mBright Blue    Courier 14" & ASCII.ESC & "[0m Normal text" &
            ASCII.LF & ASCII.ESC & "[1;35mBright Magenta Courier 14" & ASCII.ESC &
            "[0m Normal text" & ASCII.LF & ASCII.ESC & "[1;36mBright Cyan    Courier 14" &
            ASCII.ESC & "[0m Normal text" & ASCII.LF & ASCII.ESC &
            "[1;37mBright White   Courier 14" & ASCII.ESC & "[0m Normal text" & ASCII.LF &
            ASCII.LF & ASCII.ESC & "[31mRed" & ASCII.ESC & "[32mGreen" & ASCII.ESC & "[33mYellow" &
            ASCII.ESC & "[34mBlue" & ASCII.ESC & "[35mMagenta" & ASCII.ESC & "[36mCyan" &
            ASCII.ESC & "[37mWhite" & ASCII.ESC & "[0m - " & ASCII.ESC & "[31mX" & ASCII.ESC &
            "[32mX" & ASCII.ESC & "[33mX" & ASCII.ESC & "[34mX" & ASCII.ESC & "[35mX" & ASCII.ESC &
            "[36mX" & ASCII.ESC & "[37mX" & ASCII.ESC & "[0m" & ASCII.LF & ASCII.ESC &
            "[1;31mRed" & ASCII.ESC & "[1;32mGreen" & ASCII.ESC & "[1;33mYellow" & ASCII.ESC &
            "[34mBlue" & ASCII.ESC & "[35mMagenta" & ASCII.ESC & "[36mCyan" & ASCII.ESC &
            "[1;37mWhite" & ASCII.ESC & "[1;0m - " & ASCII.ESC & "[1;31mX" & ASCII.ESC &
            "[1;32mX" & ASCII.ESC & "[1;33mX" & ASCII.ESC & "[1;34mX" & ASCII.ESC & "[1;35mX" &
            ASCII.ESC & "[1;36mX" & ASCII.ESC & "[1;37mX" & ASCII.ESC & "[0m" & ASCII.LF);
    end ANSI_Test_Pattern;


    procedure Gray_Test_Pattern
           (Tty : in out Trm.Terminal) is
    begin
        Tty.Append
           ("Grayscale Test Pattern" & ASCII.LF & "--------------------------" & ASCII.LF &
            ASCII.ESC & "[38;2;255;255;255m 100% white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;230;230;230m 90%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;205;205;205m 80%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;179;179;179m 70%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;154;154;154m 60%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;128;128;128m 50%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;102;102;102m 40%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;77;77;77m 30%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;51;51;51m 20%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;26;26;26m 10%  white     Courier 14" & ASCII.LF & ASCII.ESC &
            "[38;2;0;0;0m  0%  white     Courier 14" & ASCII.LF & ASCII.ESC & "[0m");
    end Gray_Test_Pattern;


    --  The C++ uses time() and ctime(), and so does this, for the same
    --  text.
    type Time_T is new Interfaces.C.long;

    function C_Time
           (T : access Time_T)
        return Time_T;
    pragma Import (C, C_Time, "time");

    function C_Ctime
           (T : access Time_T)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, C_Ctime, "ctime");


    procedure Date_Timer
           (Tty : in out Trm.Terminal)
    is
        LT : aliased Time_T := C_Time (null);
    begin
        Tty.Print ("The time and date is now: " & Interfaces.C.Strings.Value (C_Ctime (LT'Access)));
    end Date_Timer;


    --  FLTKAda's timeouts take no data, so each terminal has its own.
    procedure Date_Timer_CB_1 is
    begin
        Date_Timer (Tty1.all);
        FLTK.Static.Repeat_Timeout (3.0, Date_Timer_CB_1'Access);
    end Date_Timer_CB_1;


    procedure Date_Timer_CB_2 is
    begin
        Date_Timer (Tty2.all);
        FLTK.Static.Repeat_Timeout (3.0, Date_Timer_CB_2'Access);
    end Date_Timer_CB_2;


    function Create
        return Widget_Access
    is
        X : constant Integer := Test_Area_X;
        Y : constant Integer := Test_Area_Y;
        W : constant Integer := Test_Area_W;
        H : constant Integer := Test_Area_H;
        Tty_H  : constant Integer := Integer (Long_Float'Floor (Long_Float (H) / 2.25 + 0.5));
        Tty_Y1 : constant Integer := Y + (Tty_H * 0) + 20;
        Tty_Y2 : constant Integer := Y + (Tty_H * 1) + 40;
        Page : constant Group_Access := new Grp.Group'(Grp.Forge.Create (X, Y, W, H));
    begin
        Page.Begin_Current;
        --  TTY1
        Tty1 := new Trm.Terminal'(Trm.Forge.Create (X, Tty_Y1, W, Tty_H, "Tty 1: Colors"));
        ANSI_Test_Pattern (Tty1.all);
        FLTK.Static.Add_Timeout (0.5, Date_Timer_CB_1'Access);

        --  TTY2
        Tty2 := new Trm.Terminal'(Trm.Forge.Create (X, Tty_Y2, W, Tty_H, "Tty 2: Grayscale"));
        Gray_Test_Pattern (Tty2.all);
        FLTK.Static.Add_Timeout (0.5, Date_Timer_CB_2'Access);

        Page.End_Current;
        return Widget_Access (Page);
    end Create;


end Unittests_Terminal;
