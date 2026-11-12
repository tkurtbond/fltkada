

--  Programmed by Jedidiah Barber
--  Released into the public domain


--  Bitmap label test program functionality reproduced in Ada


with

    FLTK.Images.Bitmaps,
    FLTK.Widgets.Buttons.Toggle,
    FLTK.Widgets.Groups.Windows.Double;

use type

    FLTK.Alignment;


function Bitmap
    return Integer
is


    package IT  renames FLTK.Images.Bitmaps;
    package BTN renames FLTK.Widgets.Buttons;
    package TOG renames FLTK.Widgets.Buttons.Toggle;
    package WD  renames FLTK.Widgets.Groups.Windows.Double;


    Sorceress_Width  : constant Integer := 75;
    Sorceress_Height : constant Integer := 75;


    --  It would be slightly more concise to write these numbers in base 10 here
    --  but it is vastly easier to use copy/replace on the 0x syntax
    Sorceress_Bits : constant FLTK.Color_Component_Array :=
    (16#fc#, 16#7e#, 16#40#, 16#20#, 16#90#, 16#00#, 16#07#, 16#80#, 16#23#, 16#00#, 16#00#, 16#c6#,
     16#c1#, 16#41#, 16#98#, 16#b8#, 16#01#, 16#07#, 16#66#, 16#00#, 16#15#, 16#9f#, 16#03#, 16#47#,
     16#8c#, 16#c6#, 16#dc#, 16#7b#, 16#cc#, 16#00#, 16#b0#, 16#71#, 16#0e#, 16#4d#, 16#06#, 16#66#,
     16#73#, 16#8e#, 16#8f#, 16#01#, 16#18#, 16#c4#, 16#39#, 16#4b#, 16#02#, 16#23#, 16#0c#, 16#04#,
     16#1e#, 16#03#, 16#0c#, 16#08#, 16#c7#, 16#ef#, 16#08#, 16#30#, 16#06#, 16#07#, 16#1c#, 16#02#,
     16#06#, 16#30#, 16#18#, 16#ae#, 16#c8#, 16#98#, 16#3f#, 16#78#, 16#20#, 16#06#, 16#02#, 16#20#,
     16#60#, 16#a0#, 16#c4#, 16#1d#, 16#c0#, 16#ff#, 16#41#, 16#04#, 16#fa#, 16#63#, 16#80#, 16#a1#,
     16#a4#, 16#3d#, 16#00#, 16#84#, 16#bf#, 16#04#, 16#0f#, 16#06#, 16#fc#, 16#a1#, 16#34#, 16#6b#,
     16#01#, 16#1c#, 16#c9#, 16#05#, 16#06#, 16#c7#, 16#06#, 16#be#, 16#11#, 16#1e#, 16#43#, 16#30#,
     16#91#, 16#05#, 16#c3#, 16#61#, 16#02#, 16#30#, 16#1b#, 16#30#, 16#cc#, 16#20#, 16#11#, 16#00#,
     16#c1#, 16#3c#, 16#03#, 16#20#, 16#0a#, 16#00#, 16#e8#, 16#60#, 16#21#, 16#00#, 16#61#, 16#1b#,
     16#c1#, 16#63#, 16#08#, 16#f0#, 16#c6#, 16#c7#, 16#21#, 16#03#, 16#f8#, 16#08#, 16#e1#, 16#cf#,
     16#0a#, 16#fc#, 16#4d#, 16#99#, 16#43#, 16#07#, 16#3c#, 16#0c#, 16#f1#, 16#9f#, 16#0b#, 16#fc#,
     16#5b#, 16#81#, 16#47#, 16#02#, 16#16#, 16#04#, 16#31#, 16#1c#, 16#0b#, 16#1f#, 16#17#, 16#89#,
     16#4d#, 16#06#, 16#1a#, 16#04#, 16#31#, 16#38#, 16#02#, 16#07#, 16#56#, 16#89#, 16#49#, 16#04#,
     16#0b#, 16#04#, 16#b1#, 16#72#, 16#82#, 16#a1#, 16#54#, 16#9a#, 16#49#, 16#04#, 16#1d#, 16#66#,
     16#50#, 16#e7#, 16#c2#, 16#f0#, 16#54#, 16#9a#, 16#58#, 16#04#, 16#0d#, 16#62#, 16#c1#, 16#1f#,
     16#44#, 16#fc#, 16#51#, 16#90#, 16#90#, 16#04#, 16#86#, 16#63#, 16#e0#, 16#74#, 16#04#, 16#ef#,
     16#31#, 16#1a#, 16#91#, 16#00#, 16#02#, 16#e2#, 16#c1#, 16#fd#, 16#84#, 16#f9#, 16#30#, 16#0a#,
     16#91#, 16#00#, 16#82#, 16#a9#, 16#c0#, 16#b9#, 16#84#, 16#f9#, 16#31#, 16#16#, 16#81#, 16#00#,
     16#42#, 16#a9#, 16#db#, 16#7f#, 16#0c#, 16#ff#, 16#1c#, 16#16#, 16#11#, 16#00#, 16#02#, 16#28#,
     16#0b#, 16#07#, 16#08#, 16#60#, 16#1c#, 16#02#, 16#91#, 16#00#, 16#46#, 16#29#, 16#0e#, 16#00#,
     16#00#, 16#00#, 16#10#, 16#16#, 16#11#, 16#02#, 16#06#, 16#29#, 16#04#, 16#00#, 16#00#, 16#00#,
     16#10#, 16#16#, 16#91#, 16#06#, 16#a6#, 16#2a#, 16#04#, 16#00#, 16#00#, 16#00#, 16#18#, 16#24#,
     16#91#, 16#04#, 16#86#, 16#2a#, 16#04#, 16#00#, 16#00#, 16#00#, 16#18#, 16#27#, 16#93#, 16#04#,
     16#96#, 16#4a#, 16#04#, 16#00#, 16#00#, 16#00#, 16#04#, 16#02#, 16#91#, 16#04#, 16#86#, 16#4a#,
     16#0c#, 16#00#, 16#00#, 16#00#, 16#1e#, 16#23#, 16#93#, 16#04#, 16#56#, 16#88#, 16#08#, 16#00#,
     16#00#, 16#00#, 16#90#, 16#21#, 16#93#, 16#04#, 16#52#, 16#0a#, 16#09#, 16#80#, 16#01#, 16#00#,
     16#d0#, 16#21#, 16#95#, 16#04#, 16#57#, 16#0a#, 16#0f#, 16#80#, 16#27#, 16#00#, 16#d8#, 16#20#,
     16#9d#, 16#04#, 16#5d#, 16#08#, 16#1c#, 16#80#, 16#67#, 16#00#, 16#e4#, 16#01#, 16#85#, 16#04#,
     16#79#, 16#8a#, 16#3f#, 16#00#, 16#00#, 16#00#, 16#f4#, 16#11#, 16#85#, 16#06#, 16#39#, 16#08#,
     16#7d#, 16#00#, 16#00#, 16#18#, 16#b7#, 16#10#, 16#81#, 16#03#, 16#29#, 16#12#, 16#cb#, 16#00#,
     16#7e#, 16#30#, 16#28#, 16#00#, 16#85#, 16#03#, 16#29#, 16#10#, 16#be#, 16#81#, 16#ff#, 16#27#,
     16#0c#, 16#10#, 16#85#, 16#03#, 16#29#, 16#32#, 16#fa#, 16#c1#, 16#ff#, 16#27#, 16#94#, 16#11#,
     16#85#, 16#03#, 16#28#, 16#20#, 16#6c#, 16#e1#, 16#ff#, 16#07#, 16#0c#, 16#01#, 16#85#, 16#01#,
     16#28#, 16#62#, 16#5c#, 16#e3#, 16#8f#, 16#03#, 16#4e#, 16#91#, 16#80#, 16#05#, 16#39#, 16#40#,
     16#f4#, 16#c2#, 16#ff#, 16#00#, 16#9f#, 16#91#, 16#84#, 16#05#, 16#31#, 16#c6#, 16#e8#, 16#07#,
     16#7f#, 16#80#, 16#cd#, 16#00#, 16#c4#, 16#04#, 16#31#, 16#06#, 16#c9#, 16#0e#, 16#00#, 16#c0#,
     16#48#, 16#88#, 16#e0#, 16#04#, 16#79#, 16#04#, 16#db#, 16#12#, 16#00#, 16#30#, 16#0c#, 16#c8#,
     16#e4#, 16#04#, 16#6d#, 16#06#, 16#b6#, 16#23#, 16#00#, 16#18#, 16#1c#, 16#c0#, 16#84#, 16#04#,
     16#25#, 16#0c#, 16#ff#, 16#c2#, 16#00#, 16#4e#, 16#06#, 16#b0#, 16#80#, 16#04#, 16#3f#, 16#8a#,
     16#b3#, 16#83#, 16#ff#, 16#c3#, 16#03#, 16#91#, 16#84#, 16#04#, 16#2e#, 16#d8#, 16#0f#, 16#3f#,
     16#00#, 16#00#, 16#5f#, 16#83#, 16#84#, 16#04#, 16#2a#, 16#70#, 16#fd#, 16#7f#, 16#00#, 16#00#,
     16#c8#, 16#c0#, 16#84#, 16#04#, 16#4b#, 16#e2#, 16#2f#, 16#01#, 16#00#, 16#08#, 16#58#, 16#60#,
     16#80#, 16#04#, 16#5b#, 16#82#, 16#ff#, 16#01#, 16#00#, 16#08#, 16#d0#, 16#a0#, 16#84#, 16#04#,
     16#72#, 16#80#, 16#e5#, 16#00#, 16#00#, 16#08#, 16#d2#, 16#20#, 16#44#, 16#04#, 16#ca#, 16#02#,
     16#ff#, 16#00#, 16#00#, 16#08#, 16#de#, 16#a0#, 16#44#, 16#04#, 16#82#, 16#02#, 16#6d#, 16#00#,
     16#00#, 16#08#, 16#f6#, 16#b0#, 16#40#, 16#02#, 16#82#, 16#07#, 16#3f#, 16#00#, 16#00#, 16#08#,
     16#44#, 16#58#, 16#44#, 16#02#, 16#93#, 16#3f#, 16#1f#, 16#00#, 16#00#, 16#30#, 16#88#, 16#4f#,
     16#44#, 16#03#, 16#83#, 16#23#, 16#3e#, 16#00#, 16#00#, 16#00#, 16#18#, 16#60#, 16#e0#, 16#07#,
     16#e3#, 16#0f#, 16#fe#, 16#00#, 16#00#, 16#00#, 16#70#, 16#70#, 16#e4#, 16#07#, 16#c7#, 16#1b#,
     16#fe#, 16#01#, 16#00#, 16#00#, 16#e0#, 16#3c#, 16#e4#, 16#07#, 16#c7#, 16#e3#, 16#fe#, 16#1f#,
     16#00#, 16#00#, 16#ff#, 16#1f#, 16#fc#, 16#07#, 16#c7#, 16#03#, 16#f8#, 16#33#, 16#00#, 16#c0#,
     16#f0#, 16#07#, 16#ff#, 16#07#, 16#87#, 16#02#, 16#fc#, 16#43#, 16#00#, 16#60#, 16#f0#, 16#ff#,
     16#ff#, 16#07#, 16#8f#, 16#06#, 16#be#, 16#87#, 16#00#, 16#30#, 16#f8#, 16#ff#, 16#ff#, 16#07#,
     16#8f#, 16#14#, 16#9c#, 16#8f#, 16#00#, 16#00#, 16#fc#, 16#ff#, 16#ff#, 16#07#, 16#9f#, 16#8d#,
     16#8a#, 16#0f#, 16#00#, 16#00#, 16#fe#, 16#ff#, 16#ff#, 16#07#, 16#bf#, 16#0b#, 16#80#, 16#1f#,
     16#00#, 16#00#, 16#ff#, 16#ff#, 16#ff#, 16#07#, 16#7f#, 16#3a#, 16#80#, 16#3f#, 16#00#, 16#80#,
     16#ff#, 16#ff#, 16#ff#, 16#07#, 16#ff#, 16#20#, 16#c0#, 16#3f#, 16#00#, 16#80#, 16#ff#, 16#ff#,
     16#ff#, 16#07#, 16#ff#, 16#01#, 16#e0#, 16#7f#, 16#00#, 16#c0#, 16#ff#, 16#ff#, 16#ff#, 16#07#,
     16#ff#, 16#0f#, 16#f8#, 16#ff#, 16#40#, 16#e0#, 16#ff#, 16#ff#, 16#ff#, 16#07#, 16#ff#, 16#ff#,
     16#ff#, 16#ff#, 16#40#, 16#f0#, 16#ff#, 16#ff#, 16#ff#, 16#07#, 16#ff#, 16#ff#, 16#ff#, 16#ff#,
     16#41#, 16#f0#, 16#ff#, 16#ff#, 16#ff#, 16#07#);


    The_Window : WD.Double_Window := WD.Forge.Create (400, 400);

    The_Button : BTN.Button := BTN.Forge.Create (The_Window, 140, 160, 120, 120, "Bitmap");

    Left_Btn   : TOG.Toggle_Button := TOG.Forge.Create (The_Window,  25, 50,  50, 25, "left");
    Right_Btn  : TOG.Toggle_Button := TOG.Forge.Create (The_Window,  75, 50,  50, 25, "right");
    Top_Btn    : TOG.Toggle_Button := TOG.Forge.Create (The_Window, 125, 50,  50, 25, "top");
    Bottom_Btn : TOG.Toggle_Button := TOG.Forge.Create (The_Window, 175, 50,  50, 25, "bottom");
    Inside_Btn : TOG.Toggle_Button := TOG.Forge.Create (The_Window, 225, 50,  50, 25, "inside");
    Over_Btn   : TOG.Toggle_Button := TOG.Forge.Create (The_Window,  25, 75, 100, 25, "text over");
    Inact_Btn  : TOG.Toggle_Button := TOG.Forge.Create (The_Window, 125, 75, 100, 25, "inactive");

    Sorceress : IT.Bitmap := IT.Forge.Create (Sorceress_Bits, Sorceress_Width, Sorceress_Height);


    procedure Button_Callback
           (Ignore : in out FLTK.Widgets.Widget'Class)
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


    The_Button.Set_Image (Sorceress);

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


end Bitmap;


