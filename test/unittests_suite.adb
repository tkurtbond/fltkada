--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain

--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Ada.Containers.Indefinite_Vectors,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO.Text_Streams;

use

    Ada.Strings.Unbounded;


package body Unittests_Suite is


    type Test is record
        Name   : Unbounded_String;
        Call   : Test_Call;
        Failed : Boolean := False;
        Done   : Boolean := False;
    end record;

    package Test_Vectors is new Ada.Containers.Indefinite_Vectors (Positive, Test);

    type Suite_Type is record
        Name  : Unbounded_String;
        Tests : Test_Vectors.Vector;
        Done  : Boolean := False;
    end record;

    package Suite_Vectors is new Ada.Containers.Indefinite_Vectors (Positive, Suite_Type);

    Suites : Suite_Vectors.Vector;

    Num_Tests, Num_Passed, Num_Failed : Natural := 0;

    Red    : Unbounded_String := To_Unbounded_String (ASCII.ESC & "[31m");
    Green  : Unbounded_String := To_Unbounded_String (ASCII.ESC & "[32m");
    Normal : Unbounded_String := To_Unbounded_String (ASCII.ESC & "[0m");

    Tty : Terminal_Access := null;




    function Image
           (Value : in Integer)
        return String is
    begin
        return Ada.Strings.Fixed.Trim (Integer'Image (Value), Ada.Strings.Left);
    end Image;


    function Plural
           (Count : in Integer)
        return String is
    begin
        return (if Count = 1 then "" else "s");
    end Plural;


    procedure Print
           (Text : in String) is
    begin
        if Tty /= null then
            Tty.Append (Text);
        else
            --  A stream write, so that Text_IO doesn't add a line terminator at exit.
            String'Write
               (Ada.Text_IO.Text_Streams.Stream (Ada.Text_IO.Standard_Output), Text);
        end if;
    end Print;


    procedure Line
           (Text : in String) is
    begin
        Print (Text & ASCII.LF);
    end Line;




    procedure Add
           (Suite : in String;
            Name  : in String;
            Call  : in Test_Call)
    is
        New_Test : constant Test :=
           (Name => To_Unbounded_String (Name), Call => Call, others => <>);
    begin
        for S of Suites loop
            if S.Name = Suite then
                S.Tests.Append (New_Test);
                return;
            end if;
        end loop;
        Suites.Append
           ((Name  => To_Unbounded_String (Suite),
             Tests => Test_Vectors.To_Vector (New_Test, 1),
             Done  => False));
    end Add;


    procedure Set_Color
           (Value : in Boolean) is
    begin
        if Value then
            Red    := To_Unbounded_String (ASCII.ESC & "[31m");
            Green  := To_Unbounded_String (ASCII.ESC & "[32m");
            Normal := To_Unbounded_String (ASCII.ESC & "[0m");
        else
            Red    := Null_Unbounded_String;
            Green  := Null_Unbounded_String;
            Normal := Null_Unbounded_String;
        end if;
    end Set_Color;


    procedure Set_Terminal
           (Value : in Terminal_Access) is
    begin
        Tty := Value;
    end Set_Terminal;




    --  Run one test and return whether it passed.
    function Run
           (Suite : in     Suite_Type;
            T     : in out Test)
        return Boolean
    is
        Full : constant String := To_String (Suite.Name) & "." & To_String (T.Name);
    begin
        Line (To_String (Green) & "[ RUN      ]" & To_String (Normal) & " " & Full);
        T.Failed := not T.Call.all;
        if T.Failed then
            Line (To_String (Red) & "[  FAILED  ]" & To_String (Normal) & " " & Full);
        else
            Line (To_String (Green) & "[       OK ]" & To_String (Normal) & " " & Full);
        end if;
        T.Done := True;
        return not T.Failed;
    end Run;


    procedure Print_Suite_Epilog
           (Suite : in Suite_Type)
    is
        Count : constant Natural := Natural (Suite.Tests.Length);
    begin
        Line (To_String (Green) & "[----------]" & To_String (Normal) & " " & Image (Count) &
            " test" & Plural (Count) & " from " & To_String (Suite.Name));
    end Print_Suite_Epilog;


    procedure Print_Prolog
    is
        Count : constant Natural := Natural (Suites.Length);
    begin
        Num_Tests  := 0;
        Num_Passed := 0;
        Num_Failed := 0;
        for S of Suites loop
            Num_Tests := Num_Tests + Natural (S.Tests.Length);
        end loop;
        Line (To_String (Green) & "[==========]" & To_String (Normal) & " Running " &
            Image (Num_Tests) & " tests from " & Image (Count) & " test case" & Plural (Count) &
            ".");
    end Print_Prolog;


    procedure Print_Epilog
    is
        Count : constant Natural := Natural (Suites.Length);
    begin
        Line (To_String (Green) & "[==========]" & To_String (Normal) & " " & Image (Num_Tests) &
            " tests from " & Image (Count) & " test case" & Plural (Count) & " ran.");
        if Num_Passed > 0 then
            Line (To_String (Green) & "[  PASSED  ]" & To_String (Normal) & " " &
                Image (Num_Passed) & " test" & Plural (Num_Passed) & ".");
        end if;
        if Num_Failed > 0 then
            Line (To_String (Red) & "[  FAILED  ]" & To_String (Normal) & " " &
                Image (Num_Failed) & " test" & Plural (Num_Failed) & ", listed below:");
            for S of Suites loop
                for T of S.Tests loop
                    if T.Failed then
                        Line (To_String (Red) & "[  FAILED  ]" & To_String (Normal) & " " &
                            To_String (S.Name) & "." & To_String (T.Name));
                    end if;
                end loop;
            end loop;
        end if;
    end Print_Epilog;




    function Run_All_Tests
        return Natural is
    begin
        Print_Prolog;
        for S of Suites loop
            Print_Suite_Epilog (S);
            declare
                Failed : Natural := 0;
            begin
                for T of S.Tests loop
                    if not Run (S, T) then
                        Failed := Failed + 1;
                    end if;
                end loop;
                Num_Failed := Num_Failed + Failed;
                Num_Passed := Num_Passed + Natural (S.Tests.Length) - Failed;
            end;
        end loop;
        Print_Epilog;
        return Num_Failed;
    end Run_All_Tests;


    function Run_Next_Test
        return Boolean is
    begin
        if Suites.Is_Empty or else Suites.Last_Element.Done then
            Print_Epilog;
            return False;
        end if;
        if not Suites.First_Element.Done
            and then not Suites.First_Element.Tests.First_Element.Done
        then
            Print_Prolog;
        end if;
        for S of Suites loop
            if not S.Done then
                if not S.Tests.First_Element.Done then
                    Print_Suite_Epilog (S);
                end if;
                for T of S.Tests loop
                    if not T.Done then
                        if Run (S, T) then
                            Num_Passed := Num_Passed + 1;
                        else
                            Num_Failed := Num_Failed + 1;
                        end if;
                        return True;
                    end if;
                end loop;
                S.Done := True;
                return True;
            end if;
        end loop;
        return True;
    end Run_Next_Test;




    function Expect_Equal
           (Actual        : in String;
            Expected      : in String;
            Actual_Text   : in String;
            Expected_Text : in String;
            File          : in String;
            Line          : in Positive)
        return Boolean is
    begin
        if Actual = Expected then
            return True;
        end if;
        Print (File & "(" & Image (Line) & "): error:" & ASCII.LF);
        Print ("Value of: " & Actual_Text & ASCII.LF);
        Print ("  Actual: " & Actual & ASCII.LF);
        Print ("Expected: " & Expected_Text & ASCII.LF);
        return False;
    end Expect_Equal;


end Unittests_Suite;
