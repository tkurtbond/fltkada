

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  Ada port of FLTK's examples/howto-text-over-image-button.cxx: buttons
--  with text drawn over an image used as a backdrop.
--
--  The rows of the XPM image are wider than a source line, so they are
--  written as concatenated strings and copied into the Pixmap_Data that
--  Pixmaps.Forge.Create wants.


with

    Ada.Strings.Unbounded,
    FLTK.Images.Pixmaps,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Groups.Windows;

use type

    FLTK.Alignment;


function Howto_Text_Over_Image_Button
    return Integer
is


    package SU  renames Ada.Strings.Unbounded;

    function "+" (Str : in String) return SU.Unbounded_String renames SU.To_Unbounded_String;

    package Pix renames FLTK.Images.Pixmaps;
    package Btn renames FLTK.Widgets.Buttons;
    package Win renames FLTK.Widgets.Groups.Windows;


    type Pixel_Rows is array (1 .. 20) of String (1 .. 135);

    function To_Data
           (Rows : in Pixel_Rows)
        return Pix.Pixmap_Data
    is
        Data : Pix.Pixmap_Data (Rows'Range, Rows (Rows'First)'Range);
    begin
        for R in Data'Range (1) loop
            for C in Data'Range (2) loop
                Data (R, C) := Rows (R) (C);
            end loop;
        end loop;
        return Data;
    end To_Data;


    --  XPM
    Gradient_Header : constant Pix.Header := (135, 20, 26, 1);

    Gradient_Colors : constant Pix.Color_Definition_Array :=
       ((+"a", Pix.Colorful, +"#e0e0e0"), (+"b", Pix.Colorful, +"#dcdcdc"),
        (+"c", Pix.Colorful, +"#d8d8d8"), (+"d", Pix.Colorful, +"#d4d4d4"),
        (+"e", Pix.Colorful, +"#d2d2d2"), (+"f", Pix.Colorful, +"#d0d0d0"),
        (+"g", Pix.Colorful, +"#cccccc"), (+"h", Pix.Colorful, +"#c8c8c8"),
        (+"i", Pix.Colorful, +"#c4c4c4"), (+"j", Pix.Colorful, +"#c2c2c2"),
        (+"k", Pix.Colorful, +"#c0c0c0"), (+"l", Pix.Colorful, +"#bcbcbc"),
        (+"m", Pix.Colorful, +"#b8b8b8"), (+"n", Pix.Colorful, +"#b4b4b4"),
        (+"o", Pix.Colorful, +"#b2b2b2"), (+"p", Pix.Colorful, +"#b0b0b0"),
        (+"q", Pix.Colorful, +"#acacac"), (+"r", Pix.Colorful, +"#a8a8a8"),
        (+"s", Pix.Colorful, +"#a4a4a4"), (+"t", Pix.Colorful, +"#a2a2a2"),
        (+"u", Pix.Colorful, +"#a0a0a0"), (+"v", Pix.Colorful, +"#9c9c9c"),
        (+"w", Pix.Colorful, +"#989898"), (+"x", Pix.Colorful, +"#949494"),
        (+"y", Pix.Colorful, +"#929292"), (+"z", Pix.Colorful, +"#909090"));

    Gradient_Rows : constant Pixel_Rows :=
       ("aaaaaaaaabbbbbbbbcccccccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjj" &
         "jjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrssss",
        "aaaaaabbbbbbbbcccccccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjj" &
         "jkkkkkkkklllllllmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssst",
        "aaabbbbbbbbcccccccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkk" &
         "kkkkkklllllllmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssssstt",
        "bbbbbbbbcccccccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkk" &
         "kkklllllllmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrssssssssstttt",
        "bbbbbcccccccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkk" &
         "lllllllmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttu",
        "bbcccccccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklll" &
         "llllmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuu",
        "ccccccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkkllllll" &
         "lmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuu",
        "cccddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmm" &
         "mmmmmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvv",
        "ddddddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmm" &
         "mmnnnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvv",
        "dddeeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmn" &
         "nnnnnnnnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvw",
        "eeeeeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnn" &
         "nnnnnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwww",
        "eeefffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnn" &
         "nnoooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwww",
        "fffffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnno" &
         "ooooooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxx",
        "ffffgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnoooo" &
         "oooppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxxxxx",
        "fgggggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnooooooo" &
         "ppppppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxxxxxxyy",
        "gggggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnoooooooppp" &
         "pppppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxxxxxxyyyyy",
        "ggghhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnooooooopppppp" &
         "ppqqqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxxxxxxyyyyyyyy",
        "hhhhhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnoooooooppppppppq" &
         "qqqqqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxxxxxxyyyyyyyyzzz",
        "hhhhiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnoooooooppppppppqqqq" &
         "qqrrrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxxxxxxyyyyyyyyzzzzzz",
        "hiiiiiiijjjjjjjkkkkkkkklllllllmmmmmmmnnnnnnnnnoooooooppppppppqqqqqqr" &
         "rrrrrrsssssssssttttttuuuuuuuuvvvvvvvwwwwwwwwxxxxxxyyyyyyyyzzzzzzzzz");


    Gradient : Pix.Pixmap :=
        Pix.Forge.Create (Gradient_Header, Gradient_Colors, To_Data (Gradient_Rows));

    --  create window
    The_Window : Win.Window := Win.Forge.Create (160, 75, "test");

    --  create regular button
    But_1 : Btn.Button := Btn.Forge.Create (The_Window, 10, 10, 140, 25, "Button 1");

    --  create second instance of button
    But_2 : Btn.Button := Btn.Forge.Create (The_Window, 10, 40, 140, 25, "Button 2");


begin


    But_1.Set_Image (Gradient);   --  assign it an image
    --  use image as a 'backdrop'
    But_1.Set_Alignment (FLTK.Align_Image_Backdrop + But_1.Get_Alignment);

    But_2.Set_Image (Gradient);   --  assign it same image
    --  use image as a 'backdrop'
    But_2.Set_Alignment (FLTK.Align_Image_Backdrop + But_2.Get_Alignment);

    The_Window.End_Current;
    The_Window.Show_With_Args;
    return FLTK.Run;


end Howto_Text_Over_Image_Button;
