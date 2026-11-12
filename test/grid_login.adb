--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/grid_login.cxx: flex_login's login dialog laid out with
--  one Fl_Grid of six rows and six columns, its spare space given by
--  weights.  FLTK's rows and columns are numbered from 0, FLTKAda's from
--  1.  Guided by pofltk's GridLogin.Mod.


with

    FLTK.Static,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Grids,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text;

use type

    FLTK.Widgets.Groups.Grids.Grid_Alignment;


function Grid_Login
    return Integer
is

    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Grd renames FLTK.Widgets.Groups.Grids;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;

begin

    FLTK.Static.Parse_Args;

    declare

        Win : Dbl.Double_Window := Dbl.Forge.Create (480, 200, "Fl_Grid ""Login"" Layout");

        Grid : Grd.Grid := Grd.Forge.Create (Win, 5, 5, 470, 190);

        IBox  : Bx.Box := Bx.Forge.Create (Grid, 0, 0, 150, 200, "Image");
        Title : Bx.Box := Bx.Forge.Create (Grid, 0, 0, 200, 60);
        I1    : constant Inp.Text_Input := Inp.Forge.Create (Grid, 0, 0, 150, 30, "Username:");
        I2    : constant Inp.Text_Input := Inp.Forge.Create (Grid, 0, 0, 150, 30, "Password:");
        BtR   : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "Register");
        BtL   : constant Btn.Button := Btn.Forge.Create (Grid, 0, 0, 80, 30, "Login");

    begin

        Grid.Set_Layout (6, 6, 2, 2);  --  6 rows, 6 columns, margin 2, gap 2

        IBox.Set_Box (FLTK.Border_Box);
        IBox.Set_Background_Color (FLTK.RGB_Color (0, 200, 0));
        Grid.Set_Widget (IBox, 2, 2, 4, 1, Grd.Grid_Center);

        Title.Set_Label ("Welcome to Fl_Grid");
        Title.Set_Alignment (FLTK.Align_Center);
        Title.Set_Label_Font (FLTK.Helvetica_Bold_Italic);
        Title.Set_Label_Size (16);
        Grid.Set_Widget (Title, 2, 4, 1, 2, Grd.Grid_Horizontal + Grd.Grid_Center);

        Grid.Set_Column_Width (3, 90);  --  placeholder for labels

        Grid.Set_Widget (I1, 3, 4, 1, 2, Grd.Grid_Horizontal);
        Grid.Set_Row_Gap (3, 10);  --  gap below username

        Grid.Set_Widget (I2, 4, 4, 1, 2, Grd.Grid_Horizontal);
        Grid.Set_Row_Gap (4, 10);  --  gap below password

        Grid.Set_Widget (BtR, 5, 4, 1, 1, Grd.Grid_Horizontal);
        Grid.Set_Column_Gap (4, 20);  --  gap right of the register button

        Grid.Set_Widget (BtL, 5, 5, 1, 1, Grd.Grid_Horizontal);

        Grid.Set_Column_Weight (Grd.Size_Array'(20, 0, 0, 10, 10, 20));
        Grid.Set_Row_Weight (Grd.Size_Array'(10, 0, 0, 0, 0, 10));

        Grid.End_Current;
        Grid.Layout;
        Win.End_Current;
        Grid.Set_Background_Color (FLTK.RGB_Color (250, 250, 250));
        Win.Set_Background_Color (FLTK.RGB_Color (250, 250, 250));

        Win.Set_Resizable (Grid);
        Win.Resize (0, 0, 600, 300);  --  same size as flex_login
        Win.Set_Size_Range (550, 250);
        Win.Show_With_Args;

        return FLTK.Run;

    end;

end Grid_Login;

