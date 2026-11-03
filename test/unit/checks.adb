

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    Ada.Command_Line,
    Ada.Text_IO;


package body Checks is


    package TIO renames Ada.Text_IO;


    Failed : Natural := 0;


    procedure Check
           (OK    : in Boolean;
            Label : in String) is
    begin
        if OK then
            TIO.Put_Line ("ok   - " & Label);
        else
            TIO.Put_Line ("FAIL - " & Label);
            Failed := Failed + 1;
        end if;
        TIO.Flush;
    end Check;


    procedure Skip
           (Label : in String) is
    begin
        TIO.Put_Line ("skip - " & Label);
        TIO.Flush;
    end Skip;


    procedure Raises
           (Action   : not null access procedure;
            Expected : in Ada.Exceptions.Exception_Id;
            Label    : in String)
    is
        use type Ada.Exceptions.Exception_Id;
    begin
        Action.all;
        Check (False, Label & ": raised nothing, expected "
            & Ada.Exceptions.Exception_Name (Expected));
    exception
        when E : others =>
            if Ada.Exceptions.Exception_Identity (E) = Expected then
                Check (True, Label);
            else
                Check (False, Label & ": raised "
                    & Ada.Exceptions.Exception_Name (E) & ", expected "
                    & Ada.Exceptions.Exception_Name (Expected));
            end if;
    end Raises;


    procedure No_Raise
           (Action : not null access procedure;
            Label  : in String) is
    begin
        Action.all;
        Check (True, Label);
    exception
        when E : others =>
            Check (False, Label & ": raised " & Ada.Exceptions.Exception_Information (E));
    end No_Raise;


    function Failures
        return Natural is
    begin
        return Failed;
    end Failures;


    procedure Summary is
    begin
        if Failed = 0 then
            TIO.Put_Line ("All checks passed.");
        else
            TIO.Put_Line (Natural'Image (Failed) & " check(s) failed.");
            Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
        end if;
    end Summary;


end Checks;

