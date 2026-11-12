--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/flex_login.cxx: a login dialog laid out with nested
--  Fl_Flex rows and columns, a fixed-size middle panel between flexible
--  separators.  Guided by pofltk's FlexLogin.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Flex,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;

use type

    FLTK.Alignment;


function Flex_Login
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Flx renames FLTK.Widgets.Groups.Flex;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;


    function Spacer
           (Parent : in out Flx.Flex_Group)
        return Bx.Box is
    begin
        return Bx.Forge.Create (Parent, 0, 0, 0, 0, "");
    end Spacer;


    --  FLTK's create_button.
    function Create_Button
           (Parent  : in out Flx.Flex_Group;
            Caption : in     String)
        return Btn.Button is
    begin
        return This : Btn.Button := Btn.Forge.Create (Parent, 0, 0, 100, 25, Caption) do
            This.Set_Background_Color (FLTK.RGB_Color (225, 225, 225));
        end return;
    end Create_Button;


    --  A label inside a row, to the right.
    function Label
           (Parent : in out Flx.Flex_Group;
            Text   : in     String)
        return Bx.Box is
    begin
        return This : Bx.Box := Bx.Forge.Create (Parent, 0, 0, 0, 0, Text) do
            This.Set_Alignment (FLTK.Align_Inside + FLTK.Align_Right);
        end return;
    end Label;

begin

    FLTK.Static.Parse_Args;

    declare

        Win : Dbl.Double_Window := Dbl.Forge.Create (100, 100, "Fl_Flex ""Login"" Layout");

        Col : Flx.Flex_Group := Flx.Forge.Create (Win, 5, 5, 90, 90, Flx.Vertical_Flex);

        --  mainPanel (col)
        Sep1 : constant Bx.Box := Spacer (Col);  --  flexible separator
        MP   : Flx.Flex_Group := Flx.Forge.Create (Col, Flx.Horizontal_Flex);

        --  middle_panel (mp)
        M_Space : constant Bx.Box := Spacer (MP);
        Image   : Bx.Box := Bx.Forge.Create (MP, 0, 0, 0, 0, "Image");
        Gap     : constant Bx.Box := Spacer (MP);
        BP      : Flx.Flex_Group := Flx.Forge.Create (MP, Flx.Vertical_Flex);

        --  buttons_panel (bp)
        B_Space  : constant Bx.Box := Spacer (BP);
        Title    : Bx.Box := Bx.Forge.Create (BP, 0, 0, 0, 0, "Welcome to Fl_Flex");
        U_Row    : Flx.Flex_Group := Flx.Forge.Create (BP, Flx.Horizontal_Flex);
        U_Label  : constant Bx.Box := Label (U_Row, "Username:");
        Username : constant Inp.Text_Input := Inp.Forge.Create (U_Row, 0, 0, 0, 0, "");
        P_Row    : Flx.Flex_Group := Flx.Forge.Create (BP, Flx.Horizontal_Flex);
        P_Label  : constant Bx.Box := Label (P_Row, "Password:");
        Password : constant Inp.Text_Input := Inp.Forge.Create (P_Row, 0, 0, 0, 0, "");
        Pad      : constant Bx.Box := Spacer (BP);
        B_Row    : Flx.Flex_Group := Flx.Forge.Create (BP, Flx.Horizontal_Flex);
        R_Space  : constant Bx.Box := Spacer (B_Row);
        Reg      : constant Btn.Button := Create_Button (B_Row, "Register");
        Login    : constant Btn.Button := Create_Button (B_Row, "Login");
        B_Bottom : constant Bx.Box := Spacer (BP);

        M_End : constant Bx.Box := Spacer (MP);

        Sep2 : constant Bx.Box := Spacer (Col);  --  flexible separator

        pragma Unreferenced (Sep1, M_Space, B_Space, U_Label, P_Label, R_Space, M_End, Sep2);

    begin

        Title.Set_Alignment (FLTK.Align_Center);
        Title.Set_Label_Font (FLTK.Helvetica_Bold_Italic);
        Title.Set_Label_Size (16);

        U_Row.Set_Fixed (Username, 180);
        U_Row.End_Current;

        P_Row.Set_Fixed (Password, 180);
        P_Row.End_Current;

        B_Row.Set_Fixed (Reg, 80);
        B_Row.Set_Fixed (Login, 80);
        B_Row.Set_Gap (20);
        B_Row.End_Current;

        BP.Set_Fixed (Title, 60);
        BP.Set_Fixed (U_Row, 30);
        BP.Set_Fixed (P_Row, 30);
        BP.Set_Fixed (Pad, 1);
        BP.Set_Fixed (B_Row, 30);
        BP.Set_Fixed (B_Bottom, 30);

        Image.Set_Box (FLTK.Border_Box);
        Image.Set_Background_Color (FLTK.RGB_Color (0, 200, 0));
        BP.End_Current;

        MP.Set_Fixed (Image, 150);
        MP.Set_Fixed (Gap, 10);
        MP.Set_Fixed (BP, 300);
        MP.End_Current;

        Col.Set_Fixed (MP, 200);
        Col.End_Current;

        Win.Set_Resizable (Col);
        Win.Set_Background_Color (FLTK.RGB_Color (250, 250, 250));
        Win.End_Current;

        Win.Resize (0, 0, 600, 300);  --  same size as grid_login
        Win.Set_Size_Range (550, 250);
        Win.Show_With_Args;

        return FLTK.Run;

    end;

end Flex_Login;

