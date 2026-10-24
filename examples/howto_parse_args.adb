

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-parse-args.cxx: handling your own
--  command line switches alongside FLTK's standard ones.
--
--  Example 1:
--
--  ./howto-parse-args -o "FLTK is great" -fg yellow -bg red
--
--  Example 2: translated to Japanese and simplified Chinese, respectively,
--             by a well known internet translation service.
--
--  ./howto-parse-args -ti "FLTKは素晴らしいです" -o "FLTK 是一个很棒的 GUI 工具"
--
--  The original first calls Fl::args_to_utf8, which is a no-op on all
--  platforms but Windows; FLTKAda doesn't bind it.
--
--  Fl::args reports where it stopped by updating its index argument, both
--  for a word that isn't a switch and for a switch it doesn't recognise.
--  Parse_Args raises Argument_Error for the second case instead, leaving
--  its Count undefined, so the handler remembers the last index it was
--  given: FLTK always offers an argument to the handler before trying its
--  own switches, so that is where parsing stopped.


with

    Ada.Command_Line,
    Ada.Strings.Unbounded,
    FLTK.Errors,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows;


function Howto_Parse_Args
    return Integer
is


    package ACL renames Ada.Command_Line;
    package SU  renames Ada.Strings.Unbounded;
    package Bx  renames FLTK.Widgets.Boxes;
    package Win renames FLTK.Widgets.Groups.Windows;

    use type SU.Unbounded_String;


    Help_Flag     : Boolean := False;
    Option_String : SU.Unbounded_String := SU.Null_Unbounded_String;

    Last_Index : Positive := 1;   --  the last argument offered to Arg


    --  Callback function passed to Parse_Args to parse individual arguments.
    --  If there is no match, Parse_Args will then call Parse_Arg as fallback
    --  to try to match the "standard" FLTK parameters.
    --
    --  Returns 2 if Argument (I) matches with required parameter in Argument (I + 1),
    --  returns 1 if Argument (I) matches on its own,
    --  returns 0 if Argument (I) does not match.
    function Arg
           (I : in Positive)
        return Natural is
    begin
        Last_Index := I;

        if ACL.Argument (I) = "-h" or else ACL.Argument (I) = "--help" then
            Help_Flag := True;
            return 1;
        end if;

        if ACL.Argument (I) = "-o" or else ACL.Argument (I) = "--option" then
            if I < ACL.Argument_Count then
                Option_String := SU.To_Unbounded_String (ACL.Argument (I + 1));
                return 2;
            end if;
        end if;
        return 0;
    end Arg;


    LF : constant Character := ASCII.LF;

    Count : Natural;


begin


    begin
        FLTK.Static.Parse_Args (Count, Arg'Unrestricted_Access);
    exception
        when FLTK.Static.Argument_Error =>
            Count := Last_Index - 1;
    end;
    if Count < ACL.Argument_Count then
        FLTK.Errors.Current_Fatal
           ("error: unknown option: " & ACL.Argument (Count + 1) & LF &
            "usage: " & ACL.Command_Name & " [options]" & LF &
            " -h | --help     : print extended help message" & LF &
            " -o | --option # : example option with parameter" & LF &
            " plus standard fltk options" & LF);
    end if;
    if Help_Flag then
        FLTK.Errors.Current_Fatal
           ("usage: " & ACL.Command_Name & " [options]" & LF &
            " -h | --help     : print extended help message" & LF &
            " -o | --option # : example option with parameter" & LF &
            " plus standard fltk options:" & LF &
            FLTK.Static.Help_Message & LF);
    end if;

    declare
        Main_Win : Win.Window := Win.Forge.Create (300, 200);
        Text_Box : Bx.Box := Bx.Forge.Create (Main_Win, 0, 0, 300, 200);
    begin
        if Option_String /= SU.Null_Unbounded_String then
            Text_Box.Set_Label (SU.To_String (Option_String));
        else
            Text_Box.Set_Label ("re-run with [-o|--option] text");
        end if;

        Main_Win.Set_Resizable (Main_Win);
        Main_Win.Show_With_Args;
        return FLTK.Run;
    end;


end Howto_Parse_Args;
