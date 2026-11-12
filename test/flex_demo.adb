--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/flex_demo.cxx: rows of buttons, boxes and inputs in a
--  column of Fl_Flex groups.  The "hide OK button" button hides the
--  second row's OK button and box and lays the row out again, and adds a
--  box to the first row, or deletes the one it added.  Guided by pofltk's
--  FlexDemo.Mod.


with

    Ada.Unchecked_Deallocation,
    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Flex,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;


function Flex_Demo
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Flx renames FLTK.Widgets.Groups.Flex;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;

    type Box_Access is access Bx.Box;

    procedure Free is new Ada.Unchecked_Deallocation (Bx.Box, Box_Access);


    --  FLTK's create_button.
    function Create_Button
           (Parent  : in out Flx.Flex_Group;
            Caption : in     String)
        return Btn.Button is
    begin
        return This : Btn.Button := Btn.Forge.Create (Parent, 0, 0, 120, 30, Caption) do
            This.Set_Background_Color (FLTK.RGB_Color (225, 225, 225));
        end return;
    end Create_Button;

begin

    FLTK.Static.Parse_Args;

    declare

        Window : Dbl.Double_Window := Dbl.Forge.Create (100, 100, "Simple GUI Example");
        Col    : Flx.Flex_Group := Flx.Forge.Create (Window, 5, 5, 90, 90, Flx.Vertical_Flex);

        Row1    : Flx.Flex_Group := Flx.Forge.Create (Col, Flx.Horizontal_Flex);
        Cancel1 : constant Btn.Button := Create_Button (Row1, "Cancel");
        Box1    : constant Bx.Box := Bx.Forge.Create (Row1, 0, 0, 120, 10, "Box1");
        OK1     : constant Btn.Button := Create_Button (Row1, "OK");
        Input1  : constant Inp.Text_Input := Inp.Forge.Create (Row1, 0, 0, 120, 10, "");
        Col1    : Flx.Flex_Group := Flx.Forge.Create (Row1, Flx.Vertical_Flex);
        Top1    : constant Btn.Button := Create_Button (Col1, "Top1");
        Bottom1 : constant Btn.Button := Create_Button (Col1, "Bottom1");

        --  create_row ()
        Row     : Flx.Flex_Group := Flx.Forge.Create (Col, Flx.Horizontal_Flex);
        Toggle  : Btn.Button := Create_Button (Row, "hide OK button");
        Box2    : Bx.Box := Bx.Forge.Create (Row, 0, 0, 120, 10, "Box2");
        Okay    : Btn.Button := Create_Button (Row, "OK");
        Input2  : constant Inp.Text_Input := Inp.Forge.Create (Row, 0, 0, 120, 10, "");
        Col2    : Flx.Flex_Group := Flx.Forge.Create (Row, Flx.Vertical_Flex);
        Top2    : constant Btn.Button := Create_Button (Col2, "Top2");
        Bottom2 : constant Btn.Button := Create_Button (Col2, "Bottom2");

        Something1 : constant Btn.Button := Create_Button (Col, "Something1");  --  "row" #3

        Row4    : Flx.Flex_Group := Flx.Forge.Create (Col, Flx.Horizontal_Flex);
        Cancel4 : constant Btn.Button := Create_Button (Row4, "Cancel");
        OK4     : constant Btn.Button := Create_Button (Row4, "OK");
        Input4  : constant Inp.Text_Input := Inp.Forge.Create (Row4, 0, 0, 120, 10, "");

        Something2 : constant Btn.Button := Create_Button (Col, "Something2");  --  "row" #5

        pragma Unreferenced
           (Cancel1, Box1, OK1, Input1, Top1, Bottom1, Input2, Top2, Bottom2,
            Something1, Input4, Something2);

        --  The box the toggle adds to the first row.
        Box3 : Box_Access := null;


        --  FLTK's toggle_cb, with the OK button as its data.
        procedure Toggle_CB
               (Item : in out FLTK.Widgets.Widget'Class) is
        begin
            if Okay.Is_Visible then
                Okay.Hide;
                Item.Set_Label ("show OK button");
                Box2.Hide;
            else
                Okay.Show;
                Item.Set_Label ("hide OK button");
                Box2.Show;
            end if;
            Row.Layout;

            --  Yet another test: modify the first (top) Fl_Flex widget
            if Box3 = null then
                Box3 := new Bx.Box'(Bx.Forge.Create (0, 0, 0, 0, "Box3"));
                Row1.Insert (Box3.all, Before => Col1);
            else
                Free (Box3);
            end if;
            Row1.Layout;
        end Toggle_CB;

    begin

        Row1.Set_Background_Color (FLTK.Yellow_Color);
        Row1.Set_Box (FLTK.Flat_Box);

        Col1.Set_Box (FLTK.Flat_Box);
        Col1.Set_Background_Color (FLTK.RGB_Color (255, 128, 128));
        Col1.Set_Margin (5, 5);
        Col1.End_Current;
        Row1.End_Current;

        Toggle.Set_Tooltip ("hide() or show() OK button");
        Toggle.Set_Callback (Toggle_CB'Unrestricted_Access);

        Col2.End_Current;
        Col2.Set_Margin (0, 5);
        Col2.Set_Box (FLTK.Flat_Box);
        Col2.Set_Background_Color (FLTK.RGB_Color (255, 128, 128));

        Row.Set_Fixed (Box2, 50);
        Row.Set_Fixed (Col2, 100);
        Row.End_Current;

        --  TEST
        Row.Set_Box (FLTK.Down_Box);
        Row.Set_Background_Color (FLTK.Green_Color);

        Col.Set_Fixed (Row, 90);  --  sets height of row #2

        Row4.Set_Fixed (Cancel4, 100);
        Row4.Set_Fixed (OK4, 100);
        Row4.End_Current;

        Col.Set_Fixed (Row4, 30);
        Col.Set_Margin (6, 10, 6, 10);
        Col.Set_Gap (6);
        Col.End_Current;

        Window.Set_Resizable (Col);
        Window.Set_Background_Color (FLTK.RGB_Color (160, 180, 240));
        Window.Set_Box (FLTK.Flat_Box);
        Window.End_Current;

        Window.Set_Size_Range (550, 330);
        Window.Resize (0, 0, 640, 480);
        Window.Show_With_Args;

        return Result : constant Integer := FLTK.Run do
            Free (Box3);
        end return;

    end;

end Flex_Demo;

