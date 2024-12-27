

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  This is a tool that reads in a file with an exact template
--  and a file with sets of substitution rules with each rule
--  of the form X=Y and with each set of rules separated by
--  one or more blank lines.

--  It then applies each set of rules to a copy of the template
--  and puts the result to standard output.

--  The specific use this tool was written for was to deal with
--  very repetitive codegen such as binding static char get/set.
--  But of course, it can be useful for other things too.


with

    Ada.Characters.Latin_1,
    Ada.Command_Line,
    Ada.Containers.Indefinite_Ordered_Maps,
    Ada.Direct_IO,
    Ada.Directories,
    Ada.Strings.Maps,
    Ada.Strings.Unbounded,
    Ada.Text_IO;


procedure Template is


    package Latin renames Ada.Characters.Latin_1;
    package ACom  renames Ada.Command_Line;
    package ADir  renames Ada.Directories;
    package SMap  renames Ada.Strings.Maps;
    package SU    renames Ada.Strings.Unbounded;
    package TIO   renames Ada.Text_IO;


    package Char_IO is new Ada.Direct_IO (Character);


    My_Template  : Char_IO.File_Type;
    My_Rule_List : TIO.File_Type;


    Element_In : Character;
    Template_Input, Copy_Input : SU.Unbounded_String;


    Sub_Line : SU.Unbounded_String;
    Cut_At   : Natural;


    package String_Maps is new Ada.Containers.Indefinite_Ordered_Maps
       (Key_Type     => String,
        Element_Type => String);

    Rule_Map : String_Maps.Map;


    procedure Process
           (Text  : in out SU.Unbounded_String;
            Rules : in     String_Maps.Map)
    is
        Token_At : Natural;
    begin
        for C in Rules.Iterate loop
            Token_At := 1;
            while Token_At <= SU.Length (Text) loop
                Token_At := SU.Index (Text, String_Maps.Key (C), Token_At);
                exit when Token_At = 0;
                SU.Replace_Slice
                   (Text,
                    Token_At,
                    Token_At + String_Maps.Key (C)'Length - 1,
                    String_Maps.Element (C));
                Token_At := Token_At + String_Maps.Element (C)'Length;
            end loop;
        end loop;
    end Process;


begin


    if ACom.Argument_Count /= 2 then
        TIO.Put_Line
           (TIO.Standard_Error,
            "ERROR: Need an input template file and a substitution list file");
        ACom.Set_Exit_Status (ACom.Failure);
        return;
    end if;

    if not ADir.Exists (ACom.Argument (1)) then
        TIO.Put_Line
           (TIO.Standard_Error,
            "ERROR: Input template file does not exist");
        ACom.Set_Exit_Status (ACom.Failure);
        return;
    end if;

    if not ADir.Exists (ACom.Argument (2)) then
        TIO.Put_Line
           (TIO.Standard_Error,
            "ERROR: Substitution list file does not exist");
        ACom.Set_Exit_Status (ACom.Failure);
        return;
    end if;


    Char_IO.Open (My_Template, Char_IO.In_File, ACom.Argument (1));
    while not Char_IO.End_Of_File (My_Template) loop
        Char_IO.Read (My_Template, Element_In);
        SU.Append (Template_Input, Element_In);
    end loop;
    Char_IO.Close (My_Template);


    TIO.Open (My_Rule_List, TIO.In_File, ACom.Argument (2));
    while not TIO.End_Of_File (My_Rule_List) loop
        SU.Set_Unbounded_String (Sub_Line, TIO.Get_Line (My_Rule_List));
        Cut_At := SU.Index (Sub_Line, SMap.To_Set ('='));
        if Cut_At = 0 and SU.Length (Sub_Line) > 0 then
            TIO.Put_Line
               (TIO.Standard_Error,
                "WARNING: Malformed rule """ & SU.To_String (Sub_Line) & """ with no production");
        end if;
        if Cut_At = 0 and not Rule_Map.Is_Empty then
            Copy_Input := Template_Input;
            Process (Copy_Input, Rule_Map);
            TIO.Put (SU.To_String (Copy_Input));
            Rule_Map.Clear;
        elsif Cut_At = 1 then
            TIO.Put_Line
               (TIO.Standard_Error,
                "WARNING: Malformed rule """ & SU.To_String (Sub_Line) & """ with null pattern");
        elsif Cut_At > 1 then
            Rule_Map.Include
               (SU.Slice (Sub_Line, 1, Cut_At - 1),
                SU.Slice (Sub_Line, Cut_At + 1, SU.Length (Sub_Line)));
        end if;
    end loop;
    if not Rule_Map.Is_Empty then
        Process (Template_Input, Rule_Map);
        TIO.Put (SU.To_String (Template_Input));
    end if;
    TIO.Close (My_Rule_List);


end Template;


