

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Standard dialog test program functionality reproduced in Ada


with

    Ada.Characters.Latin_1,
    Ada.Command_Line,
    FLTK.Asks,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Buttons.Enter,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Asks.Choice_Result,
    FLTK.Color;


function Ask
    return Integer
is


    package Latin renames Ada.Characters.Latin_1;
    package ACom  renames Ada.Command_Line;

    package AK  renames FLTK.Asks;
    package Stc renames FLTK.Static;
    package BX  renames FLTK.Widgets.Boxes;
    package BTN renames FLTK.Widgets.Buttons;
    package ENT renames FLTK.Widgets.Buttons.Enter;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;


    procedure Update_Input_Text
           (Item : in out FLTK.Widgets.Widget'Class;
            Text : in     String) is
    begin
        Item.Set_Label (Text);
        Item.Redraw;
    end Update_Input_Text;


    procedure Rename_Me
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Input : constant String := AK.Text_Input ("Input:", Item.Get_Label);
    begin
        Update_Input_Text (Item, Input);
    end Rename_Me;


    procedure Rename_Me_Pwd
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Input : constant String := AK.Password ("Input PWD:", Item.Get_Label);
    begin
        Update_Input_Text (Item, Input);
    end Rename_Me_Pwd;


    procedure Window_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Hotspot : constant Boolean := AK.Get_Message_Hotspot;
        Reply   : AK.Choice_Result;
    begin
        AK.Set_Message_Hotspot (False);
        AK.Set_Message_Title ("Note: No hotspot set for this dialog");
        Reply := AK.Choice ("Are you sure you want to quit?", "Cancel", "Quit", "Dunno");
        AK.Set_Message_Hotspot (Hotspot);
        if Reply = AK.Second then
            ACom.Set_Exit_Status (ACom.Success);
            WD.Double_Window (Item).Hide;
        elsif Reply = AK.Third then
            AK.Message_Box ("Well, maybe you should know before we quit.");
        end if;
    end Window_Callback;


    Stop : Boolean := False;

    procedure Timer_Callback is
        Message_Icon : constant BX.Box_Reference := AK.Get_Message_Icon;
        My_Color     : FLTK.Color;
    begin
        if Stop then
            Message_Icon.Set_Background_Color (FLTK.White_Color);
            return;
        end if;

        Stc.Repeat_Timeout (5.0, Timer_Callback'Unrestricted_Access);

        My_Color := Message_Icon.Get_Background_Color;
        My_Color := (My_Color + 1) mod 32;
        if My_Color = Message_Icon.Get_Label_Color then
            My_Color := (My_Color + 1) mod 32;
        end if;
        Message_Icon.Set_Background_Color (My_Color);

        Stop := AK.Choice
           ("Timeout. Click the 'Close' button." & Latin.LF &
            "Note: This message is blocked in FLTK 1.3" & Latin.LF &
            "if another message window is open." & Latin.LF &
            "This message should pop up every 5 seconds.",
            "Close", "Stop these funny popups") = AK.Second;
    end Timer_Callback;


    The_Window : WD.Double_Window := WD.Forge.Create (200, 105, "Ask Test");

    Button_One : ENT.Enter_Button := ENT.Forge.Create (The_Window, 20, 10, 160, 35, "Test text");
    Button_Two : BTN.Button       := BTN.Forge.Create (The_Window, 20, 50, 160, 35, "MyPassword");


begin


    Button_One.Set_Callback (Rename_Me'Unrestricted_Access);
    Button_Two.Set_Callback (Rename_Me_Pwd'Unrestricted_Access);

    The_Window.Set_Resizable (Button_One);
    The_Window.Set_Callback (Window_Callback'Unrestricted_Access);
    The_Window.Show_With_Args;

    Stc.Add_Timeout (5.0, Timer_Callback'Unrestricted_Access);

    return FLTK.Run;


end Ask;


