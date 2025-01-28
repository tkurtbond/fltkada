

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Pixmap label test program functionality reproduced in Ada


with

    Ada.Strings.Unbounded,
    FLTK.Images.Pixmaps,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment;


function Pixmap
    return Integer
is


    package SU  renames Ada.Strings.Unbounded;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;

    package Pix renames FLTK.Images.Pixmaps;
    package Btn renames FLTK.Widgets.Buttons;
    package Tog renames FLTK.Widgets.Buttons.Toggle;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;


    Porsche_Header : Pix.Header := (64, 64, 4, 1);

    Porsche_Colors : Pix.Color_Definition_Array :=
       ((Name => +" ", Kind => Pix.Colorful, Value => +"#background"),
        (Name => +".", Kind => Pix.Colorful, Value => +"#000000000000"),
        (Name => +"X", Kind => Pix.Colorful, Value => +"#ffd100"),
        (Name => +"o", Kind => Pix.Colorful, Value => +"#FFFF00000000"));

    Porsche_Data : Pix.Pixmap_Data :=
       ("                                                                ",
        "                   ..........................                   ",
        "              .....................................             ",
        "        ............XXXXXXXXXXXXXXXXXXXXXXXX............        ",
        "        ......XXXXXXX...XX...XXXXXXXX...XXXXXXXXXX......        ",
        "        ..XXXXXXXXXX..X..XX..XXXX.XXXX..XXXXXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..X..XX..XXX..XXXX..X...XXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XX.....XX..XX.XXXXXXXXXXX..        ",
        "        ..XXXXXXXXX.....XXX..XXX..XXXX..X.XXXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XXX..XXXX....XXXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XXX..XXXX..X..XXXXXXXXXXX..        ",
        "        ..XXXXXXXXXX..XXXXX..XXX..X.XX..XX..XXXXXXXXXX..        ",
        "        ..XXXXXXXXX....XXX....XXX..XX....XX..XXXXXXXXX..        ",
        "        ..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..        ",
        "        ..XXXXXXXXX..........................XXXXXXXXX..        ",
        "        ..XXX.......XXXXXXXXXXX...................XXXX..        ",
        "        ......XX.XXX.XXX..XXXXX.........................        ",
        "        ..XXXXX.XXX.XXX.XXXX.XX.........................        ",
        "        ..XXXX.XXX.XX.......XXX.........................        ",
        "        ..XXXX.......XXXXXX..XX..ooooooooooooooooooooo..        ",
        "        ..X.....XXXXXXXXXXXXXXX..ooooooooooooooooooooo..        ",
        "        ..X...XXXXXXXXXXXXXXXXX..ooooooooooooooooooooo..        ",
        "        ..X..XXXXXXX.XX.XXXXXXX..ooooooooooooooooooooo..        ",
        "        ..XXXXX.XXX.XX.XXXXXXXX..ooooooooooooooooooooo..        ",
        "        ..XXXX.XXX.XX.XX................................        ",
        "        ..XXXX.X.........X....X.X.X.....................        ",
        "        ..XXXX...XXXXXXX.X..X...X.X.X.X.................        ",
        "        ..X....XXXXXXXXXX.X...X.X.X.....................        ",
        "        ..X...XXXXXXXXXX.XXXXXXXXXXXXXX.................        ",
        "        ..X..XXXXXX.XX.X.XXX...XXXXXXXX.................        ",
        "        ..XXXXX.XX.XX.XX.XX.....XXXXXXX.oooooooooooooo..        ",
        "        ..XXXX.XX.XX.XX..XX.X...XXXXX.X.oooooooooooooo..        ",
        "        ..XXXX.X.......X.XXXX...XXXX..X.oooooooooooooo..        ",
        "        ..X......XXXXXX..XXXX...XXXX..X.oooooooooooooo..        ",
        "        ..X...XXXXXXXXXX.XXX.....XXX.XX.oooooooooooooo..        ",
        "        ..X..XXXXXXXXXXX.X...........XX.oooooooooooooo..        ",
        "        .................X.X.........XX.................        ",
        "        .................X.X.XXXX....XX.XXXXXXXXXXXXXX..        ",
        "        .................XXX.XXXXX.X.XX.XXX.XX.XXXXXXX..        ",
        "         ................XXXX.XXX..X..X.XX.XX.XXX.XXX..         ",
        "         ................XXXXXXXX.XX.XX.X.XX.XXX.XXXX..         ",
        "         .................XXXXXX.XX.XX.X..........XXX..         ",
        "          ..oooooooooooooo.XXXXXXXXXX....XXXXXXXX..X..          ",
        "          ..ooooooooooooooo.XXXXXXXX....XXXXXXXXXXXX..          ",
        "           ..ooooooooooooooo........XXXXXXX.XX.XXXX..           ",
        "           ..oooooooooooooooooo..XXXXX.XXX.XX.XX.XX..           ",
        "            ..ooooooooooooooooo..XXXX.XXX.XX.XX.XX..            ",
        "            ..ooooooooooooooooo..XXX.XX........XXX..            ",
        "             ....................XXX....XXXXXX..X..             ",
        "              ...................XX...XXXXXXXXXXX.              ",
        "              ...................X...XXXXXXXXXXX..              ",
        "               ..................X..XXXX.XXXXXX..               ",
        "                .................XXX.XX.XX.XXX..                ",
        "                 ................XX.XX.XX.XXX..                 ",
        "                  ..ooooooooooo..XX.......XX..                  ",
        "                   ..oooooooooo..X...XXXX.X..                   ",
        "                    ..ooooooooo..X..XXXXXX..                    ",
        "                     ...ooooooo..X..XXXX...                     ",
        "                      ....ooooo..XXXXX....                      ",
        "                        ....ooo..XXX....                        ",
        "                          ....o..X....                          ",
        "                            ........                            ",
        "                              ....                              ",
        "                                                                ");


    The_Window : WD.Double_Window := WD.Forge.Create (400, 400, "Badgery of Pixmap Labels");

    The_Button : Btn.Button := Btn.Forge.Create (The_Window, 140, 160, 120, 120, "Pixmap");

    The_Pixmap : Pix.Pixmap := Pix.Forge.Create (Porsche_Header, Porsche_Colors, Porsche_Data);
    De_Pixmap  : Pix.Pixmap'Class := The_Pixmap.Copy;

    Left_Btn   : Tog.Toggle_Button := Tog.Forge.Create (The_Window,  25, 50,  50, 25, "left");
    Right_Btn  : Tog.Toggle_Button := Tog.Forge.Create (The_Window,  75, 50,  50, 25, "right");
    Top_Btn    : Tog.Toggle_Button := Tog.Forge.Create (The_Window, 125, 50,  50, 25, "top");
    Bottom_Btn : Tog.Toggle_Button := Tog.Forge.Create (The_Window, 175, 50,  50, 25, "bottom");
    Inside_Btn : Tog.Toggle_Button := Tog.Forge.Create (The_Window, 225, 50,  50, 25, "inside");
    Over_Btn   : Tog.Toggle_Button := Tog.Forge.Create (The_Window,  25, 75, 100, 25, "text over");
    Inact_Btn  : Tog.Toggle_Button := Tog.Forge.Create (The_Window, 125, 75, 100, 25, "inactive");


    procedure Button_Callback
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        New_Align : FLTK.Alignment;
    begin
        if Left_Btn.Is_On   then New_Align := New_Align + FLTK.Align_Left;            end if;
        if Right_Btn.Is_On  then New_Align := New_Align + FLTK.Align_Right;           end if;
        if Top_Btn.Is_On    then New_Align := New_Align + FLTK.Align_Top;             end if;
        if Bottom_Btn.Is_On then New_Align := New_Align + FLTK.Align_Bottom;          end if;
        if Inside_Btn.Is_On then New_Align := New_Align + FLTK.Align_Inside;          end if;
        if Over_Btn.Is_On   then New_Align := New_Align + FLTK.Align_Text_Over_Image; end if;
        The_Button.Set_Alignment (New_Align);

        if Inact_Btn.Is_On then
            The_Button.Deactivate;
        else
            The_Button.Activate;
        end if;

        The_Window.Redraw;
    end Button_Callback;


begin


    De_Pixmap.Inactive;

    The_Button.Set_Image (The_Pixmap);
    The_Button.Set_Inactive_Image (De_Pixmap);

    Left_Btn.Set_Callback   (Button_Callback'Unrestricted_Access);
    Right_Btn.Set_Callback  (Button_Callback'Unrestricted_Access);
    Top_Btn.Set_Callback    (Button_Callback'Unrestricted_Access);
    Bottom_Btn.Set_Callback (Button_Callback'Unrestricted_Access);
    Inside_Btn.Set_Callback (Button_Callback'Unrestricted_Access);
    Over_Btn.Set_Callback   (Button_Callback'Unrestricted_Access);
    Inact_Btn.Set_Callback  (Button_Callback'Unrestricted_Access);

    The_Window.Set_Resizable (The_Window);
    The_Window.Show_With_Args;

    return FLTK.Run;


end Pixmap;


