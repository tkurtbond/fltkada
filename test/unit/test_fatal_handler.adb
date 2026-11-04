--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 66: FLTK.Errors.Current_Fatal is Fl::fatal, which must
--  not return (Fl.H:557-559).  A handler that returned let FLTK go on, and
--  it crashed (Fl_x.cxx:550-551).  Now the program ends with status 1, as
--  FLTK's own handler ends it, and a handler that raises still carries on
--  where the exception is handled.
--
--  Each case must fail to open the display, so with no argument this
--  program runs itself once per case, with X11 forced and DISPLAY naming
--  a server that isn't there.


with

    Ada.Command_Line,
    Ada.Directories,
    Ada.Environment_Variables,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    Checks,
    FLTK.Errors,
    FLTK.Static,
    GNAT.OS_Lib;


procedure Test_Fatal_Handler is

    type Case_Name is (Returns, Raises);

    Gone : exception;

    procedure Returning
           (Message : in String) is
    begin
        Ada.Text_IO.Put_Line ("told: " & Message);
    end Returning;

    procedure Raising
           (Message : in String) is
    begin
        raise Gone with Message;
    end Raising;

    procedure Run
           (Which : in Case_Name) is
    begin
        case Which is
            when Returns =>
                FLTK.Errors.Current_Fatal := Returning'Unrestricted_Access;
                FLTK.Static.Open_Display;
                Ada.Text_IO.Put_Line ("came back");
            when Raises =>
                FLTK.Errors.Current_Fatal := Raising'Unrestricted_Access;
                begin
                    FLTK.Static.Open_Display;
                    Ada.Text_IO.Put_Line ("came back");
                exception
                    when Gone =>
                        Ada.Text_IO.Put_Line ("caught");
                end;
        end case;
    end Run;


    Output_Name : constant String := "test_fatal_handler.out";

    function Contents
           (Name : in String)
        return String
    is
        File   : Ada.Text_IO.File_Type;
        Result : Ada.Strings.Unbounded.Unbounded_String;
    begin
        Ada.Text_IO.Open (File, Ada.Text_IO.In_File, Name);
        while not Ada.Text_IO.End_Of_File (File) loop
            Ada.Strings.Unbounded.Append (Result, Ada.Text_IO.Get_Line (File));
            Ada.Strings.Unbounded.Append (Result, ASCII.LF);
        end loop;
        Ada.Text_IO.Close (File);
        return Ada.Strings.Unbounded.To_String (Result);
    end Contents;

    function Has
           (Output, Text : in String)
        return Boolean is
    begin
        return Ada.Strings.Fixed.Index (Output, Text) /= 0;
    end Has;

    procedure Spawn
           (Which    : in Case_Name;
            Expected : in Integer;
            Printed  : in String)
    is
        Arg     : GNAT.OS_Lib.String_Access := new String'(Case_Name'Image (Which));
        Success : Boolean;
        Code    : Integer;
    begin
        GNAT.OS_Lib.Spawn
           (Ada.Command_Line.Command_Name, (1 => Arg), Output_Name, Success, Code);
        GNAT.OS_Lib.Free (Arg);
        declare
            Output : constant String := Contents (Output_Name);
            Name   : constant String := Case_Name'Image (Which);
        begin
            Ada.Directories.Delete_File (Output_Name);
            Checks.Check (Success and then Code = Expected,
                Name & ": the program exits" & Integer'Image (Code));
            Checks.Check (Has (Output, Printed) and not Has (Output, "came back"),
                Name & ": FLTK carries on no further");
            Checks.Check (not Has (Output, "raised "),
                Name & ": and doesn't crash, as it did (STORAGE_ERROR)");
            if Code /= Expected or else not Has (Output, Printed)
                or else Has (Output, "raised ")
            then
                Ada.Text_IO.Put (Output);
            end if;
        end;
    end Spawn;

begin

    if Ada.Command_Line.Argument_Count = 1 then
        Run (Case_Name'Value (Ada.Command_Line.Argument (1)));
    else
        Ada.Environment_Variables.Clear ("WAYLAND_DISPLAY");
        Ada.Environment_Variables.Set ("FLTK_BACKEND", "x11");
        Ada.Environment_Variables.Set ("DISPLAY", ":987");
        Spawn (Returns, 1, "told: Can't open display");
        Spawn (Raises, 0, "caught");
        Checks.Summary;
    end if;

end Test_Fatal_Handler;
