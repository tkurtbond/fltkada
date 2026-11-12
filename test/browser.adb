--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/browser.cxx: a browser showing a file (by default
--  browser.cxx), buttons that scroll to, swap and sort its lines, choices
--  that change its type () and when (), and a terminal where its callback
--  prints the selection and the clicks.  Guided by pofltk's Browser.Mod.


with

    Ada.Command_Line,
    Ada.Exceptions,
    FLTK.Asks,
    FLTK.Events,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Browsers.Textline.Choice,
    FLTK.Widgets.Groups.Terminals,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Whole_Number,
    FLTK.Widgets.Menus.Choices,
    System;

use type

    FLTK.Callback_Flag,
    System.Address;


function Browser
    return Integer
is

    package Brw renames FLTK.Widgets.Groups.Browsers;
    package Sel renames FLTK.Widgets.Groups.Browsers.Textline.Choice;
    package Btn renames FLTK.Widgets.Buttons;
    package Trm renames FLTK.Widgets.Groups.Terminals;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Int renames FLTK.Widgets.Inputs.Text.Whole_Number;
    package Chc renames FLTK.Widgets.Menus.Choices;

    Count : Natural;

begin

    FLTK.Static.Parse_Args (Count);

    declare

        File_Name : constant String :=
           (if Count < Ada.Command_Line.Argument_Count
            then Ada.Command_Line.Argument (Count + 1)
            else "browser.cxx");

        Window : Dbl.Double_Window := Dbl.Forge.Create (720, 520, File_Name);

        Lines : Sel.Choice_Browser := Sel.Forge.Create (Window, 0, 0, 720, 350);

        Field   : Int.Integer_Input := Int.Forge.Create (Window, 55, 350, 720 - 55, 25, "Line #:");
        Top     : Btn.Button := Btn.Forge.Create (Window, 0, 375, 80, 25, "Top");
        Bottom  : Btn.Button := Btn.Forge.Create (Window, 80, 375, 80, 25, "Bottom");
        Middle  : Btn.Button := Btn.Forge.Create (Window, 160, 375, 80, 25, "Middle");
        Visible : Btn.Button := Btn.Forge.Create (Window, 240, 375, 80, 25, "Make Vis.");
        Swap    : Btn.Button := Btn.Forge.Create (Window, 320, 375, 80, 25, "Swap");
        Sort    : Btn.Button := Btn.Forge.Create (Window, 400, 375, 80, 25, "Sort");
        BType   : Chc.Choice := Chc.Forge.Create (Window, 480, 375, 80, 25);
        WType   : Chc.Choice := Chc.Forge.Create (Window, 560, 375, 160, 25);

        TTY : Trm.Terminal := Trm.Forge.Create (Window, 0, 400, 720, 120);

        type When_Item is record
            Name  : access constant String;
            Value : FLTK.Callback_Flag;
        end record;

        Never_Name             : aliased constant String := "FL_WHEN_NEVER";
        Changed_Name           : aliased constant String := "FL_WHEN_CHANGED";
        Not_Changed_Name       : aliased constant String := "FL_WHEN_NOT_CHANGED";
        Release_Name           : aliased constant String := "FL_WHEN_RELEASE";
        Release_Always_Name    : aliased constant String := "FL_WHEN_RELEASE_ALWAYS";
        Enter_Key_Name         : aliased constant String := "FL_WHEN_ENTER_KEY";
        Enter_Key_Always_Name  : aliased constant String := "FL_WHEN_ENTER_KEY_ALWAYS";
        Enter_Key_Changed_Name : aliased constant String := "FL_WHEN_ENTER_KEY_CHANGED";
        Sum_Name               : aliased constant String :=
            "FL_WHEN_ENTER_KEY + FL_WHEN_RELEASE_ALWAYS";

        --  FLTK's program adds the last one's numbers, 11 + 6, which is 17:
        --  FL_WHEN_CLOSED and FL_WHEN_CHANGED.
        When_Items : constant array (Positive range <>) of When_Item :=
           ((Never_Name'Access, FLTK.Call_Never),
            (Changed_Name'Access, FLTK.When_Changed),
            (Not_Changed_Name'Access, FLTK.When_Interact),
            (Release_Name'Access, FLTK.When_Release),
            (Release_Always_Name'Access, FLTK.When_Release_Always),
            (Enter_Key_Name'Access, FLTK.When_Enter_Key),
            (Enter_Key_Always_Name'Access, FLTK.When_Enter_Key_Always),
            (Enter_Key_Changed_Name'Access, FLTK.When_Enter_Key_Always + FLTK.When_Changed),
            (Sum_Name'Access, FLTK.When_Closed + FLTK.When_Changed));


        function Trim
               (Text : in String)
            return String is
        begin
            return (if Text'Length > 0 and then Text (Text'First) = ' '
                    then Text (Text'First + 1 .. Text'Last)
                    else Text);
        end Trim;


        procedure B_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            Clicks : constant Natural := FLTK.Events.Get_Clicks;
        begin
            --  Get_Clicks counts the first click; Fl::event_clicks doesn't.
            TTY.Print
               ("callback, selection = " & ASCII.ESC & "[31m" &
                Trim (Lines.Selected_Index'Image) & ASCII.ESC & "[0m, event_clicks = " &
                ASCII.ESC & "[32m" & Trim (Natural'Image (Natural'Max (Clicks, 1) - 1)) &
                ASCII.ESC & "[0m" & ASCII.LF);
        end B_CB;


        procedure Show_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            Line : Long_Integer;
        begin
            begin
                Line := Field.Get_Value;
            exception
            when Constraint_Error => Line := 0;
            end;

            if Line = 0 then
                FLTK.Asks.Alert
                   ("Please enter a number in the text field" & ASCII.LF &
                    "before clicking on the buttons.");
                return;
            end if;

            --  FLTK's topline and the rest ignore a line out of range.
            if Line < 1 or Line > Long_Integer (Lines.Number_Of_Lines) then
                return;
            end if;

            if Item'Address = Top'Address then
                Lines.Set_Top_Line (Positive (Line));
            elsif Item'Address = Bottom'Address then
                Lines.Set_Bottom_Line (Positive (Line));
            elsif Item'Address = Middle'Address then
                Lines.Set_Middle_Line (Positive (Line));
            else
                Lines.Make_Visible (Positive (Line));
            end if;
        end Show_CB;


        --  Like FLTK's, this never looks at the last line.
        procedure Swap_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
            A, B : Natural := 0;
        begin
            for T in 1 .. Lines.Number_Of_Lines - 1 loop
                if Lines.Is_Selected (T) then
                    if A = 0 then
                        A := T;
                    else
                        B := T;
                        exit;
                    end if;
                end if;
            end loop;
            if A /= 0 and B /= 0 then
                Lines.Swap (A, B);
            end if;
        end Swap_CB;


        procedure Sort_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            Lines.Sort (Brw.Ascending);
        end Sort_CB;


        procedure BType_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            for T in 1 .. Lines.Number_Of_Lines loop
                Lines.Set_Select (Line => T, State => False);
            end loop;
            if Lines.Number_Of_Lines >= 1 then
                Lines.Set_Select (Line => 1, State => False);  --  leave focus box on first line
            end if;
            if BType.Chosen_Index /= FLTK.Widgets.Menus.No_Index then
                Lines.Set_Kind (Brw.Browser_Kind'Val (BType.Chosen_Index - 1));
            end if;
            Lines.Redraw;
        end BType_CB;


        procedure WType_CB
               (Item : in out FLTK.Widgets.Widget'Class)
        is
            pragma Unreferenced (Item);
        begin
            if WType.Chosen_Index = FLTK.Widgets.Menus.No_Index then
                return;
            end if;
            Lines.Set_When (When_Items (WType.Chosen_Index).Value);
        end WType_CB;


    begin

        Window.End_Current;

        Lines.Set_Kind (Brw.Multi_Kind);
        Lines.Set_Callback (B_CB'Unrestricted_Access);
        begin
            Lines.Load (File_Name);
        exception
        when E : Brw.Textline.Browser_Load_Error =>
            FLTK.Asks.Message_Box
               ("Can't load '" & File_Name & "'" & ASCII.LF &
                Ada.Exceptions.Exception_Message (E) & ASCII.LF);
            Lines.Add ("This is a test of how the browser draws lines.");
            Lines.Add ("This is a second line.");
            Lines.Add ("This is a third.");
            Lines.Add ("@bBold text");
            Lines.Add ("@iItalic text");
        end;
        Lines.Set_V_Position (0);

        Field.Set_Callback (Show_CB'Unrestricted_Access);
        Top.Set_Callback (Show_CB'Unrestricted_Access);
        Bottom.Set_Callback (Show_CB'Unrestricted_Access);
        Middle.Set_Callback (Show_CB'Unrestricted_Access);
        Visible.Set_Callback (Show_CB'Unrestricted_Access);

        Swap.Set_Callback (Swap_CB'Unrestricted_Access);
        Swap.Set_Tooltip
           ("Swaps two selected lines" & ASCII.LF & "(Use CTRL-click to select two lines)");

        Sort.Set_Callback (Sort_CB'Unrestricted_Access);

        BType.Add ("Normal");
        BType.Add ("Select");
        BType.Add ("Hold");
        BType.Add ("Multi");
        BType.Set_Callback (BType_CB'Unrestricted_Access);
        BType.Set_Chosen (4);
        BType.Set_Tooltip ("Changes the browser type()");

        WType.Set_Text_Size (8);
        for W of When_Items loop
            WType.Add (W.Name.all);
        end loop;
        WType.Set_Callback (WType_CB'Unrestricted_Access);
        WType.Set_Chosen (5);  --  FL_WHEN_RELEASE_ALWAYS is Fl_Browser's default

        TTY.Set_History_Lines (50);
        TTY.Set_ANSI (True);

        Window.Set_Resizable (Lines);
        Window.Show_With_Args;

        return FLTK.Run;

    end;

end Browser;
