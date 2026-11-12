--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/message.cxx: each common dialog in turn, with what each
--  returns printed.  C's printf formats the numbers there; here they are
--  formatted as %g formats these two.


with

    Ada.Long_Float_Text_IO,
    Ada.Strings.Fixed,
    Ada.Strings.Unbounded,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Static;

use type

    FLTK.Asks.Confirm_Result;


function Message
    return Integer
is

    package SU renames Ada.Strings.Unbounded;
    package AK renames FLTK.Asks;
    package St renames FLTK.Static;

    LF : constant Character := ASCII.LF;

    --  %g of 100 * (15 / 77.0), which is 19.4805.
    function Confidence
        return String
    is
        Text : String (1 .. 20);
    begin
        Ada.Long_Float_Text_IO.Put (Text, 100.0 * (15.0 / 77.0), Aft => 4, Exp => 0);
        return Ada.Strings.Fixed.Trim (Text, Ada.Strings.Left);
    end Confidence;

    procedure Print_Choice
           (Result : in AK.Choice_Result) is
    begin
        Ada.Text_IO.Put_Line
           ("fl_choice returned" & Integer'Image (AK.Choice_Result'Pos (Result)));
    end Print_Choice;

    --  fl_input and fl_password return NULL when cancelled.
    procedure Print_Answer
           (Name   : in String;
            Result : in AK.Confirm_Result;
            Answer : in SU.Unbounded_String) is
    begin
        if Result = AK.Confirm then
            Ada.Text_IO.Put_Line (Name & " returned """ & SU.To_String (Answer) & """");
        else
            Ada.Text_IO.Put_Line (Name & " returned ""NULL""");
        end if;
    end Print_Answer;

    Answer : SU.Unbounded_String;
    Result : AK.Confirm_Result;

begin

    St.Set_System_Scheme;
    St.Parse_Args;
    St.System_Colors;

    AK.Message_Box
       ("Spelling check sucessful, 1002 errors found with " & Confidence & "% confidence");

    AK.Alert
       ("Quantum fluctuations in the space-time continuum detected," & LF &
        "you have 10 seconds to comply." & LF & LF &
        """In physics, spacetime is any mathematical model that combines" & LF &
        "space and time into a single construct called the space-time" & LF &
        "continuum. Spacetime is usually interpreted with space being" & LF &
        "three-dimensional and time playing the role of the" & LF &
        "fourth dimension."" - Wikipedia");

    Print_Choice (AK.Choice ("Do you really want to continue?", "No", "Yes"));

    Print_Choice (AK.Choice ("Choose one of the following:", "choice0", "choice1", "choice2"));

    Answer := SU.To_Unbounded_String ("this is the default value");
    Result := AK.Text_Input ("Please enter a string for 'testing':", Answer);
    Print_Answer ("fl_input", Result, Answer);

    Answer := SU.Null_Unbounded_String;
    Result := AK.Password ("Enter somebody's password:", Answer);
    Print_Answer ("fl_password", Result, Answer);

    return 0;

end Message;
