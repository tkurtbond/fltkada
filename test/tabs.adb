--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/tabs.fl: the same pages in a Tabbed_Group, on the left,
--  and in a Wizard, on the right.  Four of the tabs can be closed, more
--  can be added, and a choice says what the tabs do when there are too
--  many to fit.  Ported from the C++ that FLUID writes from it, guided by
--  pofltk's Tabs.Mod.


with

    Ada.Containers.Vectors,
    Ada.Strings.Fixed,
    Ada.Text_IO,
    Ada.Unchecked_Deallocation,
    FLTK.Asks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Clocks.Updated,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Groups.Wizards,
    FLTK.Widgets.Inputs.Text,
    FLTK.Widgets.Menus.Choices;

use type

    FLTK.Alignment,
    FLTK.Callback_Reason;


function Tabs
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Ent renames FLTK.Widgets.Buttons.Enter;
    package Clk renames FLTK.Widgets.Clocks.Updated;
    package Grp renames FLTK.Widgets.Groups;
    package Tab renames FLTK.Widgets.Groups.Tabbed;
    package Win renames FLTK.Widgets.Groups.Windows;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Wiz renames FLTK.Widgets.Groups.Wizards;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Cho renames FLTK.Widgets.Menus.Choices;


    Status : Integer := 0;


    --  The tabs that "add tab" makes, freed after Run.

    type Group_Access is access Grp.Group;
    type Box_Access is access Bx.Box;

    procedure Free is new Ada.Unchecked_Deallocation (Grp.Group, Group_Access);
    procedure Free is new Ada.Unchecked_Deallocation (Bx.Box, Box_Access);

    package Group_Vectors is new Ada.Containers.Vectors (Positive, Group_Access);
    package Box_Vectors is new Ada.Containers.Vectors (Positive, Box_Access);

    Added_Tabs  : Group_Vectors.Vector;
    Added_Boxes : Box_Vectors.Vector;
    Next_Tab    : Positive := 6;


    Foo_Window : Dbl.Double_Window := Dbl.Forge.Create
        (660, 400, "Comparison of Fl_Tab (left) vs. Fl_Wizard (right)");

    Tabs_Title : Bx.Box := Bx.Forge.Create (Foo_Window, 95, 0, 130, 35, "class Fl_Tabs");
    Tabs_Group : Tab.Tabbed_Group := Tab.Forge.Create (Foo_Window, 10, 35, 315, 260);

    T1        : Grp.Group := Grp.Forge.Create (Tabs_Group, 10, 60, 315, 235, "Label&1");
    T1_Input  : Inp.Text_Input := Inp.Forge.Create (T1, 70, 80, 240, 40, "input:");
    T1_Input2 : Inp.Text_Input := Inp.Forge.Create (T1, 70, 120, 240, 30, "input2:");
    T1_Input3 : Inp.Text_Input := Inp.Forge.Create (T1, 70, 150, 240, 80, "input3:");

    T2         : Grp.Group := Grp.Forge.Create (Tabs_Group, 10, 60, 315, 235, "tab&2");
    T2_Button1 : Btn.Button := Btn.Forge.Create (T2, 20, 85, 100, 30, "button1");
    T2_Input   : Inp.Text_Input := Inp.Forge.Create (T2, 130, 130, 175, 30, "input in box2");
    T2_Stuff   : Btn.Button := Btn.Forge.Create
        (T2, 25, 170, 280, 30, "This is stuff inside the Fl_Group ""tab2""");
    T2_Test    : Btn.Button := Btn.Forge.Create
        (T2, 25, 200, 280, 30, "Test event blocking by modal window");

    T3        : Grp.Group := Grp.Forge.Create (Tabs_Group, 10, 60, 315, 235, "tab&3");
    T3_Button : Btn.Button := Btn.Forge.Create (T3, 20, 80, 60, 80, "button2");
    T3_B2     : Btn.Button := Btn.Forge.Create (T3, 80, 80, 60, 80, "button");
    T3_B3     : Btn.Button := Btn.Forge.Create (T3, 140, 80, 60, 80, "button");

    T4        : Grp.Group := Grp.Forge.Create (Tabs_Group, 10, 60, 315, 235, "&tab4");
    T4_Button : Btn.Button := Btn.Forge.Create (T4, 20, 80, 60, 120, "button2");
    T4_B2     : Btn.Button := Btn.Forge.Create (T4, 80, 80, 60, 120, "button");
    T4_B3     : Btn.Button := Btn.Forge.Create (T4, 140, 80, 60, 120, "button");

    Clock_Label : constant String :=
        "Make sure this clock does not use processor time when this tab is hidden or w" &
        "indow is iconized";

    T5        : Grp.Group := Grp.Forge.Create (Tabs_Group, 10, 60, 315, 235, "@fileprint  &print");
    T5_Button : Btn.Button := Btn.Forge.Create (T5, 20, 80, 60, 80, "button2");
    T5_B2     : Btn.Button := Btn.Forge.Create (T5, 90, 80, 60, 80, "button");
    T5_Clock  : Clk.Updated_Clock := Clk.Forge.Create (T5, 185, 80, 120, 120, Clock_Label);
    T5_Sub1   : Win.Window := Win.Forge.Create (T5, 20, 190, 40, 55);
    T5_Sub2   : Win.Window := Win.Forge.Create (T5, 65, 190, 40, 55, "subwindows:");
    T5_Sub3   : Win.Window := Win.Forge.Create (T5, 110, 190, 40, 55);

    Wizard_Title : Bx.Box := Bx.Forge.Create (Foo_Window, 410, 0, 130, 35, "class Fl_Wizard");
    The_Wizard   : Wiz.Wizard := Wiz.Forge.Create (Foo_Window, 330, 35, 320, 260);

    W1        : Grp.Group := Grp.Forge.Create (The_Wizard, 330, 60, 320, 235, "Label1");
    W1_Input  : Inp.Text_Input := Inp.Forge.Create (W1, 390, 80, 240, 40, "input:");
    W1_Input2 : Inp.Text_Input := Inp.Forge.Create (W1, 390, 120, 240, 30, "input2:");
    W1_Input3 : Inp.Text_Input := Inp.Forge.Create (W1, 390, 150, 240, 80, "input3:");

    W2         : Grp.Group := Grp.Forge.Create (The_Wizard, 330, 60, 320, 235, "tab2");
    W2_Button1 : Btn.Button := Btn.Forge.Create (W2, 350, 85, 100, 30, "button1");
    W2_Input   : Inp.Text_Input := Inp.Forge.Create (W2, 455, 130, 175, 30, "input in box2");
    W2_Stuff   : Btn.Button := Btn.Forge.Create
        (W2, 350, 170, 280, 30, "This is stuff inside the Fl_Group ""tab2""");
    W2_Test    : Btn.Button := Btn.Forge.Create
        (W2, 350, 200, 280, 30, "Test event blocking by modal window");

    W3        : Grp.Group := Grp.Forge.Create (The_Wizard, 330, 60, 320, 235, "tab3");
    W3_Button : Btn.Button := Btn.Forge.Create (W3, 350, 80, 60, 80, "button2");
    W3_B2     : Btn.Button := Btn.Forge.Create (W3, 410, 80, 60, 80, "button");
    W3_B3     : Btn.Button := Btn.Forge.Create (W3, 470, 80, 60, 80, "button");

    W4        : Grp.Group := Grp.Forge.Create (The_Wizard, 330, 60, 320, 235, "tab4");
    W4_Button : Btn.Button := Btn.Forge.Create (W4, 350, 80, 60, 120, "button2");
    W4_B2     : Btn.Button := Btn.Forge.Create (W4, 410, 80, 60, 120, "button");
    W4_B3     : Btn.Button := Btn.Forge.Create (W4, 470, 80, 60, 120, "button");

    W5        : Grp.Group := Grp.Forge.Create (The_Wizard, 330, 60, 320, 235, "     tab5      ");
    W5_Button : Btn.Button := Btn.Forge.Create (W5, 350, 80, 60, 80, "button2");
    W5_B2     : Btn.Button := Btn.Forge.Create (W5, 420, 80, 60, 80, "button");
    W5_Clock  : Clk.Updated_Clock := Clk.Forge.Create (W5, 510, 80, 120, 120, Clock_Label);
    W5_Sub1   : Win.Window := Win.Forge.Create (W5, 350, 190, 40, 55);
    W5_Sub2   : Win.Window := Win.Forge.Create (W5, 395, 190, 40, 55, "subwindows:");
    W5_Sub3   : Win.Window := Win.Forge.Create (W5, 440, 190, 40, 55);

    Pager : Grp.Group := Grp.Forge.Create (Foo_Window, 410, 305, 130, 25);
    First : Btn.Button := Btn.Forge.Create (Pager, 410, 305, 30, 25, "@|<");
    Prev  : Btn.Button := Btn.Forge.Create (Pager, 440, 305, 30, 25, "@<");
    Next  : Btn.Button := Btn.Forge.Create (Pager, 480, 305, 30, 25, "@>");
    Last  : Btn.Button := Btn.Forge.Create (Pager, 510, 305, 30, 25, "@>|");

    Add_Tab  : Btn.Button := Btn.Forge.Create (Foo_Window, 60, 309, 70, 25, "add tab");
    Overflow : Cho.Choice := Cho.Forge.Create (Foo_Window, 212, 309, 95, 25, "overflow:");
    Input    : Inp.Text_Input := Inp.Forge.Create (Foo_Window, 60, 345, 250, 25, "input:");
    Cancel   : Btn.Button := Btn.Forge.Create (Foo_Window, 490, 345, 70, 30, "cancel");
    OK       : Ent.Enter_Button := Ent.Forge.Create (Foo_Window, 570, 345, 70, 30, "OK");


    procedure Tabs_Group_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class)
    is
        Selected : constant access FLTK.Widgets.Widget'Class := Tabs_Group.Get_Visible;
    begin
        if Selected /= null then
            Ada.Text_IO.Put_Line ("Callback called for tab """ & Selected.Get_Label & """");
        else
            Ada.Text_IO.Put_Line ("Callback called");
        end if;
    end Tabs_Group_Callback;

    procedure Tab_Callback
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        if FLTK.Static.Get_Callback_Reason = FLTK.Reason_Closed then
            Item.Parent.Remove (Item);
        end if;
    end Tab_Callback;

    procedure Button1_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        FLTK.Asks.Message_Box
           ("Test to see if this modal window prevents you from " &
            "changing the tabs. It should.");
    end Button1_Callback;

    procedure Test_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        FLTK.Asks.Message_Box
           ("Make sure you cannot change the tabs while this modal window is up");
    end Test_Callback;

    procedure First_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Wizard.Set_Visible (The_Wizard.Child (1).Data.all);
    end First_Callback;

    procedure Prev_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Wizard.Prev;
    end Prev_Callback;

    procedure Next_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Wizard.Next;
    end Next_Callback;

    procedure Last_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        The_Wizard.Set_Visible (The_Wizard.Child (The_Wizard.Number_Of_Children).Data.all);
    end Last_Callback;

    procedure Add_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class)
    is
        X : constant Integer := Tabs_Group.Get_X;
        Y : constant Integer := Tabs_Group.Get_Y + 25;
        W : constant Integer := Tabs_Group.Get_W;
        H : constant Integer := Tabs_Group.Get_H - 25;
        N : constant String := Ada.Strings.Fixed.Trim (Next_Tab'Image, Ada.Strings.Left);

        New_Tab : constant Group_Access :=
            new Grp.Group'(Grp.Forge.Create (X, Y, W, H, "tab" & N));
        Box     : constant Box_Access :=
            new Bx.Box'(Bx.Forge.Create (New_Tab.all, X + 5, Y + 5, W - 10, H - 10,
                "Empty tab " & N & "."));
    begin
        New_Tab.Set_When (FLTK.When_Closed);
        New_Tab.Set_Callback (Tab_Callback'Unrestricted_Access);
        Box.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);
        Tabs_Group.Add (New_Tab.all);
        Added_Tabs.Append (New_Tab);
        Added_Boxes.Append (Box);
        Next_Tab := Next_Tab + 1;
    end Add_Callback;

    procedure Compress_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Tabs_Group.Handle_Overflow (Tab.Compress_Overflow);
    end Compress_Callback;

    procedure Clip_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Tabs_Group.Handle_Overflow (Tab.Clip_Overflow);
    end Clip_Callback;

    procedure Pulldown_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Tabs_Group.Handle_Overflow (Tab.Pulldown_Overflow);
    end Pulldown_Callback;

    procedure Drag_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Tabs_Group.Handle_Overflow (Tab.Drag_Overflow);
    end Drag_Callback;

    --  FLTK's cancel and OK call exit (1) and exit (0).  Here they hide
    --  the window, and the program returns the status after Run.
    procedure Cancel_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Status := 1;
        Foo_Window.Hide;
    end Cancel_Callback;

    procedure OK_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class) is
    begin
        Status := 0;
        Foo_Window.Hide;
    end OK_Callback;


    procedure Title
           (Item : in out Bx.Box) is
    begin
        Item.Set_Label_Kind (FLTK.Engraved_Label);
        Item.Set_Label_Font (FLTK.Helvetica_Bold);
    end Title;

    procedure Page
           (Item      : in out Grp.Group;
            Tip       : in     String;
            Selection : in     FLTK.Color;
            Closable  : in     Boolean;
            Hidden    : in     Boolean) is
    begin
        Item.Set_Tooltip (Tip);
        Item.Set_Selection_Color (Selection);
        if Closable then
            Item.Set_Callback (Tab_Callback'Unrestricted_Access);
            Item.Set_When (FLTK.When_Closed);
        end if;
        if Hidden then
            Item.Hide;
        end if;
    end Page;

    procedure Clock_Style
           (Item : in out Clk.Updated_Clock) is
    begin
        Item.Set_Box (FLTK.OShadow_Box);
        Item.Set_Background_Color (238);
        Item.Set_Selection_Color (FLTK.Foreground_Color);
        Item.Set_Label_Font (FLTK.Times);
        Item.Set_Label_Size (10);
        Item.Set_Alignment (FLTK.Align_Wrap + FLTK.Align_Bottom);
    end Clock_Style;

    procedure Subwindow
           (Item  : in out Win.Window;
            Color : in     FLTK.Color) is
    begin
        Item.Set_Box (FLTK.Thin_Down_Box);
        Item.Set_Background_Color (Color);
        if Item.Get_Label = "" then
            Item.Set_Alignment (FLTK.Align_Center + FLTK.Align_Inside);
        else
            Item.Set_Alignment (FLTK.Align_Top);
        end if;
    end Subwindow;

    procedure Pager_Button
           (Item   : in out Btn.Button;
            Tip    : in     String;
            Key    : in     FLTK.Keypress;
            Action : in     FLTK.Widgets.Widget_Callback) is
    begin
        Item.Set_Tooltip (Tip);
        Item.Set_Shortcut (FLTK.Press (Key));
        Item.Set_Callback (Action);
    end Pager_Button;


    Tab2_Tip : constant String :=
        "tab2 tests among other things the cooperation of modal windows and tabs";
    Tab4_Tip : constant String :=
        "this tab shows the issue of indicating a selected tab if the tab layouts are " &
        "very similar";
    Tab5_Tip : constant String := "tab5 verifies if visibility requests are handled correctly";
    Input_Tip : constant String :=
        "this tab tests correct keyboard navigation between text input fields";
    Button2_Tip : constant String := "button2 has a different tooltip than tab5";

begin

    Title (Tabs_Title);
    Tabs_Group.Set_Tooltip
       ("the various index cards test different aspects of the Fl_Tabs widget");
    Tabs_Group.Set_Selection_Color (4);
    Tabs_Group.Set_Label_Color (FLTK.Background2_Color);
    Tabs_Group.Set_Callback (Tabs_Group_Callback'Unrestricted_Access);

    Page (T1, Input_Tip, 1, Closable => True, Hidden => False);
    T1_Input.Set_Tooltip ("This is the first input field");
    T1_Input2.Set_Tooltip ("");
    Tabs_Group.Set_Resizable (T1);

    Page (T2, Tab2_Tip, 2, Closable => True, Hidden => True);
    T2_Button1.Set_Callback (Button1_Callback'Unrestricted_Access);
    T2_Test.Set_Callback (Test_Callback'Unrestricted_Access);

    Page (T3, "tab3 checks for correct keyboard navigation", 3, Closable => True, Hidden => True);

    Page (T4, Tab4_Tip, 5, Closable => True, Hidden => True);
    T4.Set_Label_Kind (FLTK.Engraved_Label);
    T4.Set_Label_Font (FLTK.Helvetica_Italic);

    T5.Set_Tooltip (Tab5_Tip);
    T5.Hide;
    T5_Button.Set_Tooltip (Button2_Tip);
    Clock_Style (T5_Clock);
    Subwindow (T5_Sub1, 173);
    Subwindow (T5_Sub2, 167);
    Subwindow (T5_Sub3, 239);

    Foo_Window.Set_Resizable (Tabs_Group);

    Title (Wizard_Title);

    Page (W1, Input_Tip, 1, Closable => False, Hidden => True);
    W1_Input.Set_Tooltip ("This is the first input field");
    W1_Input2.Set_Tooltip ("");
    The_Wizard.Set_Resizable (W1);

    Page (W2, Tab2_Tip, 2, Closable => False, Hidden => False);
    W2_Button1.Set_Callback (Button1_Callback'Unrestricted_Access);
    W2_Test.Set_Callback (Test_Callback'Unrestricted_Access);

    Page (W3, "tab3 checks for correct keyboard navigation", 3, Closable => False, Hidden => True);

    Page (W4, Tab4_Tip, 5, Closable => False, Hidden => True);
    W4.Set_Label_Font (FLTK.Helvetica_Italic);

    W5.Set_Tooltip (Tab5_Tip);
    W5.Set_Label_Kind (FLTK.Engraved_Label);
    W5.Hide;
    W5_Button.Set_Tooltip (Button2_Tip);
    Clock_Style (W5_Clock);
    Subwindow (W5_Sub1, 173);
    Subwindow (W5_Sub2, 167);
    Subwindow (W5_Sub3, 239);

    Pager_Button (First, "go to first page [Home]", FLTK.Home_Key,
        First_Callback'Unrestricted_Access);
    Pager_Button (Prev, "go to previous page [left arrow]", FLTK.Left_Key,
        Prev_Callback'Unrestricted_Access);
    Pager_Button (Next, "go to next page in wizard [right arrow]", FLTK.Right_Key,
        Next_Callback'Unrestricted_Access);
    Pager_Button (Last, "go to last page [End]", FLTK.End_Key,
        Last_Callback'Unrestricted_Access);

    Add_Tab.Set_Tooltip ("Add more tabs to check overflow handling.");
    Add_Tab.Set_Callback (Add_Callback'Unrestricted_Access);

    Overflow.Set_Tooltip ("Change how Fl_Tabs handles more tabs than fit into the tabs space.");
    Overflow.Set_Down_Box (FLTK.Border_Box);
    Overflow.Add ("compress", Compress_Callback'Unrestricted_Access);
    Overflow.Add ("clip", Clip_Callback'Unrestricted_Access);
    Overflow.Add ("pulldown", Pulldown_Callback'Unrestricted_Access);
    Overflow.Add ("drag", Drag_Callback'Unrestricted_Access);
    --  FLUID gives the choice its items with menu (), which makes the first
    --  the value too.  Add doesn't.
    Overflow.Set_Chosen (1);

    Cancel.Set_Callback (Cancel_Callback'Unrestricted_Access);
    OK.Set_Callback (OK_Callback'Unrestricted_Access);

    Foo_Window.Show_With_Args;

    declare
        Ignore : constant Integer := FLTK.Run;
    begin
        null;
    end;

    for T of Added_Tabs loop
        if T.Parent /= null then
            T.Parent.Remove (T.all);
        end if;
    end loop;
    for B of Added_Boxes loop
        Free (B);
    end loop;
    for T of Added_Tabs loop
        Free (T);
    end loop;

    return Status;

end Tabs;
