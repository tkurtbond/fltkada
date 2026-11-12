--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTK's test/windowfocus.cxx: typing in the input shows a second
--  window, and the focus must stay on the input.


with

    FLTK.Widgets.Boxes,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;

use type

    FLTK.Alignment;


function Windowfocus
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;

    Win1   : Dbl.Double_Window := Dbl.Forge.Create (300, 200);
    B      : Bx.Box            := Bx.Forge.Create (Win1, 10, 10, 280, 130);
    Input1 : Inp.Text_Input    := Inp.Forge.Create (Win1, 10, 150, 150, 25);

    Win2 : Dbl.Double_Window := Dbl.Forge.Create (300, 200);

    procedure Popup
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        Ignore : Boolean;
    begin
        Win2.Reposition (Win1.Get_X + Win1.Get_W, Win1.Get_Y);
        Win2.Show;
        Win2.Wait_For_Expose;
        Ignore := Input1.Take_Focus;
    end Popup;

begin

    Win1.Set_Label ("show() focus test");

    B.Set_Label
       ("Type something to pop the subwindow up. " &
        "The focus should stay on the input, " &
        "and you should be able to continue typing.");
    B.Set_Alignment (FLTK.Align_Wrap + FLTK.Align_Left + FLTK.Align_Inside);

    Input1.Set_When (FLTK.When_Changed);
    Input1.Set_Callback (Popup'Unrestricted_Access);

    Win2.Set_Label ("window2");

    Win1.Show_With_Args;

    return FLTK.Run;

end Windowfocus;
