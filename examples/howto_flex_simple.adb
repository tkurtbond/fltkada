

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  An Ada port of FLTK's examples/howto-flex-simple.cxx, a simple Fl_Flex demo.
--  There are no deliberate differences in behaviour. The widgets are added to
--  their parents through the Forge.Create Parent overloads rather than by being
--  created while a group is current, as is usual in this binding.


with

    FLTK.Asks,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Flex,
    FLTK.Widgets.Groups.Windows.Double;


function Howto_Flex_Simple
    return Integer
is


    package Box renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Flx renames FLTK.Widgets.Groups.Flex;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;


    --  The 'Exit' button callback closes the window and terminates the program
    procedure Exit_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        FLTK.Asks.Message_Box
           ("The '" & Item.Get_Label & "' button closes the window" & ASCII.LF &
            "and terminates the program.");
        Item.Nearest_Window.Hide;
    end Exit_CB;


    --  Common callback for all other buttons
    procedure Button_CB
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        FLTK.Asks.Message_Box ("The '" & Item.Get_Label & "' button does nothing.");
    end Button_CB;


    The_Window : Dbl.Double_Window := Dbl.Forge.Create (410, 40, "Simple Fl_Flex Demo");

    The_Flex : Flx.Flex_Group := Flx.Forge.Create
       (The_Window, 5, 5, The_Window.Get_W - 10, The_Window.Get_H - 10, Flx.Horizontal_Flex);

    B1 : Btn.Button := Btn.Forge.Create (The_Flex, 0, 0, 0, 0, "File");
    B2 : Btn.Button := Btn.Forge.Create (The_Flex, 0, 0, 0, 0, "New");
    B3 : Btn.Button := Btn.Forge.Create (The_Flex, 0, 0, 0, 0, "Save");
    BX : constant Box.Box := Box.Forge.Create (The_Flex, 0, 0, 0, 0);  --  empty space
    EB : Btn.Button := Btn.Forge.Create (The_Flex, 0, 0, 0, 0, "Exit");


begin


    --  Assign callbacks to buttons
    B1.Set_Callback (Button_CB'Unrestricted_Access);
    B2.Set_Callback (Button_CB'Unrestricted_Access);
    B3.Set_Callback (Button_CB'Unrestricted_Access);
    EB.Set_Callback (Exit_CB'Unrestricted_Access);

    --  Set gap between adjacent buttons and extra spacing (invisible box size)
    The_Flex.Set_Gap (10);
    The_Flex.Set_Fixed (BX, 30);  --  total 50: 2 * gap + 30

    --  End groups
    The_Flex.End_Current;
    The_Window.End_Current;

    --  Set resizable, minimal window size, show window, and execute event loop
    The_Window.Set_Resizable (The_Flex);
    The_Window.Set_Size_Range (300, 30);
    The_Window.Show_With_Args;

    return FLTK.Run;


end Howto_Flex_Simple;


