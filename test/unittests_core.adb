--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK 1.4.5's core page tests its Fl_String class, which FLTKAda doesn't
--  bind: Ada has strings of its own.  These are instead the tests of the
--  fl_filename_* functions that unittest_core.cxx has under "#if (0)",
--  run through FLTK.Filenames.  FLTKAda binds fl_filename_relative and
--  fl_filename_absolute only as relative to the current directory, so
--  where the C++ passes "/var/tmp/somedir", these change to /var/tmp and
--  expect what that directory and its parent give.


with

    Ada.Directories,
    FLTK.Filenames,
    FLTK.Static,
    FLTK.Widgets.Groups.Terminals,
    GNAT.Source_Info,
    Unittests_Suite;


package body Unittests_Core is


    package Term renames FLTK.Widgets.Groups.Terminals;
    package FN renames FLTK.Filenames;

    use Unittests_Common;


    function Check
           (Actual        : in String;
            Expected      : in String;
            Actual_Text   : in String;
            Expected_Text : in String;
            Line          : in Positive := GNAT.Source_Info.Line)
        return Boolean is
    begin
        return Unittests_Suite.Expect_Equal
           (Actual, Expected, Actual_Text, Expected_Text, GNAT.Source_Info.File, Line);
    end Check;




    function Test_Ext
        return Boolean is
    begin
        return
            Check (FN.Extension ("test.txt"), ".txt",
                   "FN.Extension (""test.txt"")", """.txt""") and then
            Check (FN.Extension ("test"), "", "FN.Extension (""test"")", """""") and then
            Check (FN.Extension (""), "", "FN.Extension ("""")", """""");
    end Test_Ext;


    function Test_Setext
        return Boolean is
    begin
        return
            Check (FN.Set_Extension ("test.txt", ".rtf"), "test.rtf",
                   "FN.Set_Extension (""test.txt"", "".rtf"")", """test.rtf""") and then
            Check (FN.Set_Extension ("test", ".rtf"), "test.rtf",
                   "FN.Set_Extension (""test"", "".rtf"")", """test.rtf""") and then
            Check (FN.Set_Extension ("test.txt", ""), "test",
                   "FN.Set_Extension (""test.txt"", """")", """test""") and then
            Check (FN.Set_Extension ("", ".rtf"), ".rtf",
                   "FN.Set_Extension ("""", "".rtf"")", """.rtf""") and then
            Check (FN.Set_Extension ("path/test", ".rtf"), "path/test.rtf",
                   "FN.Set_Extension (""path/test"", "".rtf"")", """path/test.rtf""");
    end Test_Setext;


    --  Run Test with /var/tmp as the current directory, passing it the
    --  directory and its parent as the system names them (on macOS, /var
    --  is /private/var).
    function In_Var_Tmp
           (Test : not null access function (Base, Parent : String) return Boolean)
        return Boolean
    is
        Saved  : constant String := Ada.Directories.Current_Directory;
        Result : Boolean;
    begin
        Ada.Directories.Set_Directory ("/var/tmp");
        declare
            Base : constant String := Ada.Directories.Current_Directory;
        begin
            Result := Test (Base, Ada.Directories.Containing_Directory (Base));
        end;
        Ada.Directories.Set_Directory (Saved);
        return Result;
    exception
        when others =>
            Ada.Directories.Set_Directory (Saved);
            raise;
    end In_Var_Tmp;


    function Relative_Tests
           (Base, Parent : in String)
        return Boolean is
    begin
        return
            Check (FN.Relative (Base & "/foo.txt"), "foo.txt",
                   "FN.Relative (Base & ""/foo.txt"")", """foo.txt""") and then
            Check (FN.Relative (Parent & "/foo.txt"), "../foo.txt",
                   "FN.Relative (Parent & ""/foo.txt"")", """../foo.txt""") and then
            Check (FN.Relative ("./foo.txt"), "./foo.txt",
                   "FN.Relative (""./foo.txt"")", """./foo.txt""") and then
            Check (FN.Relative ("../foo.txt"), "../foo.txt",
                   "FN.Relative (""../foo.txt"")", """../foo.txt""");
    end Relative_Tests;


    function Test_Relative
        return Boolean is
    begin
        return In_Var_Tmp (Relative_Tests'Access);
    end Test_Relative;


    function Absolute_Tests
           (Base, Parent : in String)
        return Boolean is
    begin
        return
            Check (FN.Absolute ("foo.txt"), Base & "/foo.txt",
                   "FN.Absolute (""foo.txt"")", "Base & ""/foo.txt""") and then
            Check (FN.Absolute (Parent & "/foo.txt"), Parent & "/foo.txt",
                   "FN.Absolute (Parent & ""/foo.txt"")", "Parent & ""/foo.txt""") and then
            Check (FN.Absolute ("./foo.txt"), Base & "/foo.txt",
                   "FN.Absolute (""./foo.txt"")", "Base & ""/foo.txt""") and then
            Check (FN.Absolute ("../foo.txt"), Parent & "/foo.txt",
                   "FN.Absolute (""../foo.txt"")", "Parent & ""/foo.txt""");
    end Absolute_Tests;


    function Test_Absolute
        return Boolean is
    begin
        return In_Var_Tmp (Absolute_Tests'Access);
    end Test_Absolute;




    procedure Register is
    begin
        Unittests_Suite.Add ("fl_filename", "ext", Test_Ext'Access);
        Unittests_Suite.Add ("fl_filename", "setext", Test_Setext'Access);
        Unittests_Suite.Add ("fl_filename", "relative", Test_Relative'Access);
        Unittests_Suite.Add ("fl_filename", "absolute", Test_Absolute'Access);
    end Register;




    --  The page: a terminal that shows the tests running, one every 0.15
    --  seconds, from the first time the page is shown.

    type Core_Test is new FLTK.Widgets.Groups.Group with record
        Suite_Ran : Boolean := False;
    end record;

    overriding procedure Show
           (This : in out Core_Test);


    procedure Timer_CB is
    begin
        if Unittests_Suite.Run_Next_Test then
            FLTK.Static.Repeat_Timeout (0.15, Timer_CB'Access);
        end if;
    end Timer_CB;


    procedure Show
           (This : in out Core_Test) is
    begin
        FLTK.Widgets.Groups.Group (This).Show;
        if not This.Suite_Ran then
            FLTK.Static.Add_Timeout (0.5, Timer_CB'Access);
            This.Suite_Ran := True;
        end if;
    end Show;


    type Core_Test_Access is access Core_Test;


    function Create
        return Widget_Access
    is
        X : constant := Test_Area_X;
        Y : constant := Test_Area_Y;
        W : constant := Test_Area_W;
        H : constant := Test_Area_H;
        Page : constant Core_Test_Access := new Core_Test'
           (FLTK.Widgets.Groups.Forge.Create (X, Y, W, H) with others => <>);
        Tty : Unittests_Suite.Terminal_Access;
    begin
        Page.Begin_Current;
        Tty := new Term.Terminal'
           (Term.Forge.Create (X + 4, Y + 4, W - 8, H - 8, "Unittest Log"));
        Tty.Set_ANSI (True);
        Page.End_Current;
        Unittests_Suite.Set_Terminal (Tty);
        return Widget_Access (Page);
    end Create;


end Unittests_Core;
