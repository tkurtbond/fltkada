--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/twowin.cxx: two windows, each with a button that gives
--  the focus to the input in the other window.


with

    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;


function Twowin
    return Integer
is

    package Btn renames FLTK.Widgets.Buttons;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;

    Win1 : Dbl.Double_Window := Dbl.Forge.Create (200, 200);
    BB1  : Btn.Button        := Btn.Forge.Create (Win1, 10, 10, 100, 100, "b1");
    B1   : Inp.Text_Input    := Inp.Forge.Create (Win1, 10, 150, 100, 25);

    Win2 : Dbl.Double_Window := Dbl.Forge.Create (200, 200);
    BB2  : Btn.Button        := Btn.Forge.Create (Win2, 10, 10, 100, 100, "b2");
    B2   : Inp.Text_Input    := Inp.Forge.Create (Win2, 10, 150, 100, 25);

    Ignore : Boolean;

    procedure Callback_1
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Ignore := B2.Take_Focus;
    end Callback_1;

    procedure Callback_2
           (Item : in out FLTK.Widgets.Widget'Class) is
    begin
        Ignore := B1.Take_Focus;
    end Callback_2;

begin

    BB1.Set_Callback (Callback_1'Unrestricted_Access);
    Win1.Set_Label ("win1");
    BB2.Set_Callback (Callback_2'Unrestricted_Access);
    Win2.Set_Label ("win2");

    Win1.Reposition (200, 200);
    Win2.Reposition (400, 200);

    Win1.Show_With_Args;
    Win2.Show;

    return FLTK.Run;

end Twowin;
