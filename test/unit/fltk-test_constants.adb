--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.
--
--  Written by tools/gen-constants.py; edit that, not this.


--  Checks each of FLTKAda's constants against FLTK's value, from
--  c_constants.cpp.  A child of FLTK, so it can see the private
--  conversions.  Run by test_constants.adb.


with

    Checks,
    FLTK.Draw,
    FLTK.Images.File_Icons,
    FLTK.Screen,
    FLTK.Static,
    FLTK.Widgets.Buttons,
    FLTK.Widgets.Clocks,
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide,
    FLTK.Widgets.Valuators.Rollers,
    FLTK.Widgets.Groups.Browsers,
    FLTK.Widgets.Groups.Scrolls,
    FLTK.Tree_Items,
    FLTK.Widgets.Groups.Trees;


procedure FLTK.Test_Constants is


    package Buttons renames FLTK.Widgets.Buttons;
    package Clocks renames FLTK.Widgets.Clocks;
    package Tabbed renames FLTK.Widgets.Groups.Tabbed;
    package Sys_Menu renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;
    package Rollers renames FLTK.Widgets.Valuators.Rollers;
    package Browsers renames FLTK.Widgets.Groups.Browsers;
    package Scrolls renames FLTK.Widgets.Groups.Scrolls;
    package Trees renames FLTK.Widgets.Groups.Trees;


    type Value_Array is array (1 .. 399) of Long_Long_Integer;
    pragma Convention (C, Value_Array);

    FLTK_Values : Value_Array;
    pragma Import (C, FLTK_Values, "c_constants");


    procedure Same
           (Ada_Value : in Long_Long_Integer;
            Index     : in Positive;
            Label     : in String)
    is
        FLTK_Value : constant Long_Long_Integer := FLTK_Values (Index);
    begin
        if Ada_Value = FLTK_Value then
            Checks.Check (True, Label & " =" & Long_Long_Integer'Image (FLTK_Value));
        else
            Checks.Check
               (False, Label & ": FLTKAda has" & Long_Long_Integer'Image (Ada_Value) &
                ", FLTK" & Long_Long_Integer'Image (FLTK_Value));
        end if;
    end Same;


begin

    --  Box types (Fl_Boxtype).  The ones FLTK defines as functions, such as
    --  FL_SHADOW_BOX, are compared with the enumerator behind them.
    Same (Box_Kind'Pos (No_Box), 1, "Box_Kind'Pos (No_Box) = FL_NO_BOX");
    Same (Box_Kind'Pos (Flat_Box), 2, "Box_Kind'Pos (Flat_Box) = FL_FLAT_BOX");
    Same (Box_Kind'Pos (Up_Box), 3, "Box_Kind'Pos (Up_Box) = FL_UP_BOX");
    Same (Box_Kind'Pos (Down_Box), 4, "Box_Kind'Pos (Down_Box) = FL_DOWN_BOX");
    Same (Box_Kind'Pos (Up_Frame), 5, "Box_Kind'Pos (Up_Frame) = FL_UP_FRAME");
    Same (Box_Kind'Pos (Down_Frame), 6, "Box_Kind'Pos (Down_Frame) = FL_DOWN_FRAME");
    Same (Box_Kind'Pos (Thin_Up_Box), 7, "Box_Kind'Pos (Thin_Up_Box) = FL_THIN_UP_BOX");
    Same (Box_Kind'Pos (Thin_Down_Box), 8, "Box_Kind'Pos (Thin_Down_Box) = FL_THIN_DOWN_BOX");
    Same (Box_Kind'Pos (Thin_Up_Frame), 9, "Box_Kind'Pos (Thin_Up_Frame) = FL_THIN_UP_FRAME");
    Same
       (Box_Kind'Pos (Thin_Down_Frame),
        10,
        "Box_Kind'Pos (Thin_Down_Frame) = FL_THIN_DOWN_FRAME");
    Same (Box_Kind'Pos (Engraved_Box), 11, "Box_Kind'Pos (Engraved_Box) = FL_ENGRAVED_BOX");
    Same (Box_Kind'Pos (Embossed_Box), 12, "Box_Kind'Pos (Embossed_Box) = FL_EMBOSSED_BOX");
    Same (Box_Kind'Pos (Engraved_Frame), 13, "Box_Kind'Pos (Engraved_Frame) = FL_ENGRAVED_FRAME");
    Same (Box_Kind'Pos (Embossed_Frame), 14, "Box_Kind'Pos (Embossed_Frame) = FL_EMBOSSED_FRAME");
    Same (Box_Kind'Pos (Border_Box), 15, "Box_Kind'Pos (Border_Box) = FL_BORDER_BOX");
    Same (Box_Kind'Pos (Shadow_Box), 16, "Box_Kind'Pos (Shadow_Box) = _FL_SHADOW_BOX");
    Same (Box_Kind'Pos (Border_Frame), 17, "Box_Kind'Pos (Border_Frame) = FL_BORDER_FRAME");
    Same (Box_Kind'Pos (Shadow_Frame), 18, "Box_Kind'Pos (Shadow_Frame) = _FL_SHADOW_FRAME");
    Same (Box_Kind'Pos (Rounded_Box), 19, "Box_Kind'Pos (Rounded_Box) = _FL_ROUNDED_BOX");
    Same (Box_Kind'Pos (RShadow_Box), 20, "Box_Kind'Pos (RShadow_Box) = _FL_RSHADOW_BOX");
    Same (Box_Kind'Pos (Rounded_Frame), 21, "Box_Kind'Pos (Rounded_Frame) = _FL_ROUNDED_FRAME");
    Same (Box_Kind'Pos (RFlat_Box), 22, "Box_Kind'Pos (RFlat_Box) = _FL_RFLAT_BOX");
    Same (Box_Kind'Pos (Round_Up_Box), 23, "Box_Kind'Pos (Round_Up_Box) = _FL_ROUND_UP_BOX");
    Same (Box_Kind'Pos (Round_Down_Box), 24, "Box_Kind'Pos (Round_Down_Box) = _FL_ROUND_DOWN_BOX");
    Same (Box_Kind'Pos (Diamond_Up_Box), 25, "Box_Kind'Pos (Diamond_Up_Box) = _FL_DIAMOND_UP_BOX");
    Same
       (Box_Kind'Pos (Diamond_Down_Box),
        26,
        "Box_Kind'Pos (Diamond_Down_Box) = _FL_DIAMOND_DOWN_BOX");
    Same (Box_Kind'Pos (Oval_Box), 27, "Box_Kind'Pos (Oval_Box) = _FL_OVAL_BOX");
    Same (Box_Kind'Pos (OShadow_Box), 28, "Box_Kind'Pos (OShadow_Box) = _FL_OSHADOW_BOX");
    Same (Box_Kind'Pos (Oval_Frame), 29, "Box_Kind'Pos (Oval_Frame) = _FL_OVAL_FRAME");
    Same (Box_Kind'Pos (OFlat_Box), 30, "Box_Kind'Pos (OFlat_Box) = _FL_OFLAT_BOX");
    Same (Box_Kind'Pos (Plastic_Up_Box), 31, "Box_Kind'Pos (Plastic_Up_Box) = _FL_PLASTIC_UP_BOX");
    Same
       (Box_Kind'Pos (Plastic_Down_Box),
        32,
        "Box_Kind'Pos (Plastic_Down_Box) = _FL_PLASTIC_DOWN_BOX");
    Same
       (Box_Kind'Pos (Plastic_Up_Frame),
        33,
        "Box_Kind'Pos (Plastic_Up_Frame) = _FL_PLASTIC_UP_FRAME");
    Same
       (Box_Kind'Pos (Plastic_Down_Frame),
        34,
        "Box_Kind'Pos (Plastic_Down_Frame) = _FL_PLASTIC_DOWN_FRAME");
    Same
       (Box_Kind'Pos (Plastic_Thin_Up_Box),
        35,
        "Box_Kind'Pos (Plastic_Thin_Up_Box) = _FL_PLASTIC_THIN_UP_BOX");
    Same
       (Box_Kind'Pos (Plastic_Thin_Down_Box),
        36,
        "Box_Kind'Pos (Plastic_Thin_Down_Box) = _FL_PLASTIC_THIN_DOWN_BOX");
    Same
       (Box_Kind'Pos (Plastic_Round_Up_Box),
        37,
        "Box_Kind'Pos (Plastic_Round_Up_Box) = _FL_PLASTIC_ROUND_UP_BOX");
    Same
       (Box_Kind'Pos (Plastic_Round_Down_Box),
        38,
        "Box_Kind'Pos (Plastic_Round_Down_Box) = _FL_PLASTIC_ROUND_DOWN_BOX");
    Same (Box_Kind'Pos (Gtk_Up_Box), 39, "Box_Kind'Pos (Gtk_Up_Box) = _FL_GTK_UP_BOX");
    Same (Box_Kind'Pos (Gtk_Down_Box), 40, "Box_Kind'Pos (Gtk_Down_Box) = _FL_GTK_DOWN_BOX");
    Same (Box_Kind'Pos (Gtk_Up_Frame), 41, "Box_Kind'Pos (Gtk_Up_Frame) = _FL_GTK_UP_FRAME");
    Same (Box_Kind'Pos (Gtk_Down_Frame), 42, "Box_Kind'Pos (Gtk_Down_Frame) = _FL_GTK_DOWN_FRAME");
    Same
       (Box_Kind'Pos (Gtk_Thin_Up_Box),
        43,
        "Box_Kind'Pos (Gtk_Thin_Up_Box) = _FL_GTK_THIN_UP_BOX");
    Same
       (Box_Kind'Pos (Gtk_Thin_Down_Box),
        44,
        "Box_Kind'Pos (Gtk_Thin_Down_Box) = _FL_GTK_THIN_DOWN_BOX");
    Same
       (Box_Kind'Pos (Gtk_Thin_Up_Frame),
        45,
        "Box_Kind'Pos (Gtk_Thin_Up_Frame) = _FL_GTK_THIN_UP_FRAME");
    Same
       (Box_Kind'Pos (Gtk_Thin_Down_Frame),
        46,
        "Box_Kind'Pos (Gtk_Thin_Down_Frame) = _FL_GTK_THIN_DOWN_FRAME");
    Same
       (Box_Kind'Pos (Gtk_Round_Up_Box),
        47,
        "Box_Kind'Pos (Gtk_Round_Up_Box) = _FL_GTK_ROUND_UP_BOX");
    Same
       (Box_Kind'Pos (Gtk_Round_Down_Box),
        48,
        "Box_Kind'Pos (Gtk_Round_Down_Box) = _FL_GTK_ROUND_DOWN_BOX");
    Same (Box_Kind'Pos (Gleam_Up_Box), 49, "Box_Kind'Pos (Gleam_Up_Box) = _FL_GLEAM_UP_BOX");
    Same (Box_Kind'Pos (Gleam_Down_Box), 50, "Box_Kind'Pos (Gleam_Down_Box) = _FL_GLEAM_DOWN_BOX");
    Same (Box_Kind'Pos (Gleam_Up_Frame), 51, "Box_Kind'Pos (Gleam_Up_Frame) = _FL_GLEAM_UP_FRAME");
    Same
       (Box_Kind'Pos (Gleam_Down_Frame),
        52,
        "Box_Kind'Pos (Gleam_Down_Frame) = _FL_GLEAM_DOWN_FRAME");
    Same
       (Box_Kind'Pos (Gleam_Thin_Up_Box),
        53,
        "Box_Kind'Pos (Gleam_Thin_Up_Box) = _FL_GLEAM_THIN_UP_BOX");
    Same
       (Box_Kind'Pos (Gleam_Thin_Down_Box),
        54,
        "Box_Kind'Pos (Gleam_Thin_Down_Box) = _FL_GLEAM_THIN_DOWN_BOX");
    Same
       (Box_Kind'Pos (Gleam_Round_Up_Box),
        55,
        "Box_Kind'Pos (Gleam_Round_Up_Box) = _FL_GLEAM_ROUND_UP_BOX");
    Same
       (Box_Kind'Pos (Gleam_Round_Down_Box),
        56,
        "Box_Kind'Pos (Gleam_Round_Down_Box) = _FL_GLEAM_ROUND_DOWN_BOX");
    Same (Box_Kind'Pos (Oxy_Up_Box), 57, "Box_Kind'Pos (Oxy_Up_Box) = _FL_OXY_UP_BOX");
    Same (Box_Kind'Pos (Oxy_Down_Box), 58, "Box_Kind'Pos (Oxy_Down_Box) = _FL_OXY_DOWN_BOX");
    Same (Box_Kind'Pos (Oxy_Up_Frame), 59, "Box_Kind'Pos (Oxy_Up_Frame) = _FL_OXY_UP_FRAME");
    Same (Box_Kind'Pos (Oxy_Down_Frame), 60, "Box_Kind'Pos (Oxy_Down_Frame) = _FL_OXY_DOWN_FRAME");
    Same
       (Box_Kind'Pos (Oxy_Thin_Up_Box),
        61,
        "Box_Kind'Pos (Oxy_Thin_Up_Box) = _FL_OXY_THIN_UP_BOX");
    Same
       (Box_Kind'Pos (Oxy_Thin_Down_Box),
        62,
        "Box_Kind'Pos (Oxy_Thin_Down_Box) = _FL_OXY_THIN_DOWN_BOX");
    Same
       (Box_Kind'Pos (Oxy_Thin_Up_Frame),
        63,
        "Box_Kind'Pos (Oxy_Thin_Up_Frame) = _FL_OXY_THIN_UP_FRAME");
    Same
       (Box_Kind'Pos (Oxy_Thin_Down_Frame),
        64,
        "Box_Kind'Pos (Oxy_Thin_Down_Frame) = _FL_OXY_THIN_DOWN_FRAME");
    Same
       (Box_Kind'Pos (Oxy_Round_Up_Box),
        65,
        "Box_Kind'Pos (Oxy_Round_Up_Box) = _FL_OXY_ROUND_UP_BOX");
    Same
       (Box_Kind'Pos (Oxy_Round_Down_Box),
        66,
        "Box_Kind'Pos (Oxy_Round_Down_Box) = _FL_OXY_ROUND_DOWN_BOX");
    Same
       (Box_Kind'Pos (Oxy_Button_Up_Box),
        67,
        "Box_Kind'Pos (Oxy_Button_Up_Box) = _FL_OXY_BUTTON_UP_BOX");
    Same
       (Box_Kind'Pos (Oxy_Button_Down_Box),
        68,
        "Box_Kind'Pos (Oxy_Button_Down_Box) = _FL_OXY_BUTTON_DOWN_BOX");
    Same (Box_Kind'Pos (Free_Box), 69, "Box_Kind'Pos (Free_Box) = FL_FREE_BOXTYPE");

    --  Fonts (Fl_Font)
    Same (Long_Long_Integer (Helvetica), 70, "Long_Long_Integer (Helvetica) = FL_HELVETICA");
    Same
       (Long_Long_Integer (Helvetica_Bold),
        71,
        "Long_Long_Integer (Helvetica_Bold) = FL_HELVETICA_BOLD");
    Same
       (Long_Long_Integer (Helvetica_Italic),
        72,
        "Long_Long_Integer (Helvetica_Italic) = FL_HELVETICA_ITALIC");
    Same
       (Long_Long_Integer (Helvetica_Bold_Italic),
        73,
        "Long_Long_Integer (Helvetica_Bold_Italic) = FL_HELVETICA_BOLD_ITALIC");
    Same (Long_Long_Integer (Courier), 74, "Long_Long_Integer (Courier) = FL_COURIER");
    Same
       (Long_Long_Integer (Courier_Bold),
        75,
        "Long_Long_Integer (Courier_Bold) = FL_COURIER_BOLD");
    Same
       (Long_Long_Integer (Courier_Italic),
        76,
        "Long_Long_Integer (Courier_Italic) = FL_COURIER_ITALIC");
    Same
       (Long_Long_Integer (Courier_Bold_Italic),
        77,
        "Long_Long_Integer (Courier_Bold_Italic) = FL_COURIER_BOLD_ITALIC");
    Same (Long_Long_Integer (Times), 78, "Long_Long_Integer (Times) = FL_TIMES");
    Same (Long_Long_Integer (Times_Bold), 79, "Long_Long_Integer (Times_Bold) = FL_TIMES_BOLD");
    Same
       (Long_Long_Integer (Times_Italic),
        80,
        "Long_Long_Integer (Times_Italic) = FL_TIMES_ITALIC");
    Same
       (Long_Long_Integer (Times_Bold_Italic),
        81,
        "Long_Long_Integer (Times_Bold_Italic) = FL_TIMES_BOLD_ITALIC");
    Same (Long_Long_Integer (Symbol), 82, "Long_Long_Integer (Symbol) = FL_SYMBOL");
    Same (Long_Long_Integer (Monospace), 83, "Long_Long_Integer (Monospace) = FL_SCREEN");
    Same
       (Long_Long_Integer (Monospace_Bold),
        84,
        "Long_Long_Integer (Monospace_Bold) = FL_SCREEN_BOLD");
    Same
       (Long_Long_Integer (Zapf_Dingbats),
        85,
        "Long_Long_Integer (Zapf_Dingbats) = FL_ZAPF_DINGBATS");
    Same (Long_Long_Integer (Free_Font), 86, "Long_Long_Integer (Free_Font) = FL_FREE_FONT");
    Same
       (Long_Long_Integer (Get_Normal_Size),
        87,
        "Long_Long_Integer (Get_Normal_Size) = FL_NORMAL_SIZE");

    --  Label types (Fl_Labeltype)
    Same (Label_Kind'Pos (Normal_Label), 88, "Label_Kind'Pos (Normal_Label) = FL_NORMAL_LABEL");
    Same (Label_Kind'Pos (No_Label), 89, "Label_Kind'Pos (No_Label) = FL_NO_LABEL");
    Same (Label_Kind'Pos (Shadow_Label), 90, "Label_Kind'Pos (Shadow_Label) = _FL_SHADOW_LABEL");
    Same
       (Label_Kind'Pos (Engraved_Label),
        91,
        "Label_Kind'Pos (Engraved_Label) = _FL_ENGRAVED_LABEL");
    Same
       (Label_Kind'Pos (Embossed_Label),
        92,
        "Label_Kind'Pos (Embossed_Label) = _FL_EMBOSSED_LABEL");
    Same (Label_Kind'Pos (Multi_Label), 93, "Label_Kind'Pos (Multi_Label) = _FL_MULTI_LABEL");
    Same (Label_Kind'Pos (Icon_Label), 94, "Label_Kind'Pos (Icon_Label) = _FL_ICON_LABEL");
    Same (Label_Kind'Pos (Image_Label), 95, "Label_Kind'Pos (Image_Label) = _FL_IMAGE_LABEL");
    Same (Label_Kind'Pos (Free_Label), 96, "Label_Kind'Pos (Free_Label) = FL_FREE_LABELTYPE");

    --  Events (Fl_Event).  The last check fails when FLTK has events that
    --  Event_Kind lacks.
    Same (Event_Kind'Pos (No_Event), 97, "Event_Kind'Pos (No_Event) = FL_NO_EVENT");
    Same (Event_Kind'Pos (Push), 98, "Event_Kind'Pos (Push) = FL_PUSH");
    Same (Event_Kind'Pos (Release), 99, "Event_Kind'Pos (Release) = FL_RELEASE");
    Same (Event_Kind'Pos (Enter), 100, "Event_Kind'Pos (Enter) = FL_ENTER");
    Same (Event_Kind'Pos (Leave), 101, "Event_Kind'Pos (Leave) = FL_LEAVE");
    Same (Event_Kind'Pos (Drag), 102, "Event_Kind'Pos (Drag) = FL_DRAG");
    Same (Event_Kind'Pos (Focus), 103, "Event_Kind'Pos (Focus) = FL_FOCUS");
    Same (Event_Kind'Pos (Unfocus), 104, "Event_Kind'Pos (Unfocus) = FL_UNFOCUS");
    Same (Event_Kind'Pos (Keydown), 105, "Event_Kind'Pos (Keydown) = FL_KEYDOWN");
    Same (Event_Kind'Pos (Keyup), 106, "Event_Kind'Pos (Keyup) = FL_KEYUP");
    Same (Event_Kind'Pos (Close), 107, "Event_Kind'Pos (Close) = FL_CLOSE");
    Same (Event_Kind'Pos (Move), 108, "Event_Kind'Pos (Move) = FL_MOVE");
    Same (Event_Kind'Pos (Shortcut), 109, "Event_Kind'Pos (Shortcut) = FL_SHORTCUT");
    Same (Event_Kind'Pos (Deactivate), 110, "Event_Kind'Pos (Deactivate) = FL_DEACTIVATE");
    Same (Event_Kind'Pos (Activate), 111, "Event_Kind'Pos (Activate) = FL_ACTIVATE");
    Same (Event_Kind'Pos (Hide), 112, "Event_Kind'Pos (Hide) = FL_HIDE");
    Same (Event_Kind'Pos (Show), 113, "Event_Kind'Pos (Show) = FL_SHOW");
    Same (Event_Kind'Pos (Paste), 114, "Event_Kind'Pos (Paste) = FL_PASTE");
    Same
       (Event_Kind'Pos (Selection_Clear),
        115,
        "Event_Kind'Pos (Selection_Clear) = FL_SELECTIONCLEAR");
    Same (Event_Kind'Pos (Mouse_Wheel), 116, "Event_Kind'Pos (Mouse_Wheel) = FL_MOUSEWHEEL");
    Same (Event_Kind'Pos (DnD_Enter), 117, "Event_Kind'Pos (DnD_Enter) = FL_DND_ENTER");
    Same (Event_Kind'Pos (DnD_Drag), 118, "Event_Kind'Pos (DnD_Drag) = FL_DND_DRAG");
    Same (Event_Kind'Pos (DnD_Leave), 119, "Event_Kind'Pos (DnD_Leave) = FL_DND_LEAVE");
    Same (Event_Kind'Pos (DnD_Release), 120, "Event_Kind'Pos (DnD_Release) = FL_DND_RELEASE");
    Same
       (Event_Kind'Pos (Screen_Config_Changed),
        121,
        "Event_Kind'Pos (Screen_Config_Changed) = FL_SCREEN_CONFIGURATION_CHANGED");
    Same (Event_Kind'Pos (Fullscreen), 122, "Event_Kind'Pos (Fullscreen) = FL_FULLSCREEN");
    Same (Event_Kind'Pos (Zoom_Gesture), 123, "Event_Kind'Pos (Zoom_Gesture) = FL_ZOOM_GESTURE");
    Same (Event_Kind'Pos (Zoom_Event), 124, "Event_Kind'Pos (Zoom_Event) = FL_ZOOM_EVENT");
    Same
       (Event_Kind'Pos (Event_Kind'Last),
        125,
        "Event_Kind'Pos (Event_Kind'Last) = FL_ZOOM_EVENT");

    --  Mouse buttons: Fl::event_button, and the bits in Fl::event_state
    Same (Mouse_Button'Pos (Left_Button), 126, "Mouse_Button'Pos (Left_Button) = FL_LEFT_MOUSE");
    Same
       (Mouse_Button'Pos (Middle_Button),
        127,
        "Mouse_Button'Pos (Middle_Button) = FL_MIDDLE_MOUSE");
    Same
       (Mouse_Button'Pos (Right_Button),
        128,
        "Mouse_Button'Pos (Right_Button) = FL_RIGHT_MOUSE");
    Same (Mouse_Button'Pos (Back_Button), 129, "Mouse_Button'Pos (Back_Button) = FL_BACK_MOUSE");
    Same
       (Mouse_Button'Pos (Forward_Button),
        130,
        "Mouse_Button'Pos (Forward_Button) = FL_FORWARD_MOUSE");
    Same (Long_Long_Integer (To_C (No_Button)), 131, "Long_Long_Integer (To_C (No_Button)) = 0");
    Same
       (Long_Long_Integer (To_C (Left_Button)),
        132,
        "Long_Long_Integer (To_C (Left_Button)) = FL_BUTTON1");
    Same
       (Long_Long_Integer (To_C (Middle_Button)),
        133,
        "Long_Long_Integer (To_C (Middle_Button)) = FL_BUTTON2");
    Same
       (Long_Long_Integer (To_C (Right_Button)),
        134,
        "Long_Long_Integer (To_C (Right_Button)) = FL_BUTTON3");
    Same
       (Long_Long_Integer (To_C (Back_Button)),
        135,
        "Long_Long_Integer (To_C (Back_Button)) = FL_BUTTON4");
    Same
       (Long_Long_Integer (To_C (Forward_Button)),
        136,
        "Long_Long_Integer (To_C (Forward_Button)) = FL_BUTTON5");
    Same
       (Long_Long_Integer (To_C (Any_Button)),
        137,
        "Long_Long_Integer (To_C (Any_Button)) = FL_BUTTONS");

    --  Mouse cursors (Fl_Cursor)
    Same
       (Long_Long_Integer (Cursor_Values (Default_Mouse)),
        138,
        "Long_Long_Integer (Cursor_Values (Default_Mouse)) = FL_CURSOR_DEFAULT");
    Same
       (Long_Long_Integer (Cursor_Values (Arrow_Mouse)),
        139,
        "Long_Long_Integer (Cursor_Values (Arrow_Mouse)) = FL_CURSOR_ARROW");
    Same
       (Long_Long_Integer (Cursor_Values (Crosshair_Mouse)),
        140,
        "Long_Long_Integer (Cursor_Values (Crosshair_Mouse)) = FL_CURSOR_CROSS");
    Same
       (Long_Long_Integer (Cursor_Values (Wait_Mouse)),
        141,
        "Long_Long_Integer (Cursor_Values (Wait_Mouse)) = FL_CURSOR_WAIT");
    Same
       (Long_Long_Integer (Cursor_Values (Insert_Mouse)),
        142,
        "Long_Long_Integer (Cursor_Values (Insert_Mouse)) = FL_CURSOR_INSERT");
    Same
       (Long_Long_Integer (Cursor_Values (Hand_Mouse)),
        143,
        "Long_Long_Integer (Cursor_Values (Hand_Mouse)) = FL_CURSOR_HAND");
    Same
       (Long_Long_Integer (Cursor_Values (Help_Mouse)),
        144,
        "Long_Long_Integer (Cursor_Values (Help_Mouse)) = FL_CURSOR_HELP");
    Same
       (Long_Long_Integer (Cursor_Values (Move_Mouse)),
        145,
        "Long_Long_Integer (Cursor_Values (Move_Mouse)) = FL_CURSOR_MOVE");
    Same
       (Long_Long_Integer (Cursor_Values (NS_Mouse)),
        146,
        "Long_Long_Integer (Cursor_Values (NS_Mouse)) = FL_CURSOR_NS");
    Same
       (Long_Long_Integer (Cursor_Values (WE_Mouse)),
        147,
        "Long_Long_Integer (Cursor_Values (WE_Mouse)) = FL_CURSOR_WE");
    Same
       (Long_Long_Integer (Cursor_Values (NWSE_Mouse)),
        148,
        "Long_Long_Integer (Cursor_Values (NWSE_Mouse)) = FL_CURSOR_NWSE");
    Same
       (Long_Long_Integer (Cursor_Values (NESW_Mouse)),
        149,
        "Long_Long_Integer (Cursor_Values (NESW_Mouse)) = FL_CURSOR_NESW");
    Same
       (Long_Long_Integer (Cursor_Values (N_Mouse)),
        150,
        "Long_Long_Integer (Cursor_Values (N_Mouse)) = FL_CURSOR_N");
    Same
       (Long_Long_Integer (Cursor_Values (NE_Mouse)),
        151,
        "Long_Long_Integer (Cursor_Values (NE_Mouse)) = FL_CURSOR_NE");
    Same
       (Long_Long_Integer (Cursor_Values (E_Mouse)),
        152,
        "Long_Long_Integer (Cursor_Values (E_Mouse)) = FL_CURSOR_E");
    Same
       (Long_Long_Integer (Cursor_Values (SE_Mouse)),
        153,
        "Long_Long_Integer (Cursor_Values (SE_Mouse)) = FL_CURSOR_SE");
    Same
       (Long_Long_Integer (Cursor_Values (S_Mouse)),
        154,
        "Long_Long_Integer (Cursor_Values (S_Mouse)) = FL_CURSOR_S");
    Same
       (Long_Long_Integer (Cursor_Values (SW_Mouse)),
        155,
        "Long_Long_Integer (Cursor_Values (SW_Mouse)) = FL_CURSOR_SW");
    Same
       (Long_Long_Integer (Cursor_Values (W_Mouse)),
        156,
        "Long_Long_Integer (Cursor_Values (W_Mouse)) = FL_CURSOR_W");
    Same
       (Long_Long_Integer (Cursor_Values (NW_Mouse)),
        157,
        "Long_Long_Integer (Cursor_Values (NW_Mouse)) = FL_CURSOR_NW");
    Same
       (Long_Long_Integer (Cursor_Values (None_Mouse)),
        158,
        "Long_Long_Integer (Cursor_Values (None_Mouse)) = FL_CURSOR_NONE");

    --  Colours (Fl_Color)
    Same
       (Long_Long_Integer (Foreground_Color),
        159,
        "Long_Long_Integer (Foreground_Color) = FL_FOREGROUND_COLOR");
    Same
       (Long_Long_Integer (Background2_Color),
        160,
        "Long_Long_Integer (Background2_Color) = FL_BACKGROUND2_COLOR");
    Same
       (Long_Long_Integer (Inactive_Color),
        161,
        "Long_Long_Integer (Inactive_Color) = FL_INACTIVE_COLOR");
    Same
       (Long_Long_Integer (Selection_Color),
        162,
        "Long_Long_Integer (Selection_Color) = FL_SELECTION_COLOR");
    Same (Long_Long_Integer (Free_Color), 163, "Long_Long_Integer (Free_Color) = FL_FREE_COLOR");
    Same (Long_Long_Integer (Grey0_Color), 164, "Long_Long_Integer (Grey0_Color) = FL_GRAY0");
    Same (Long_Long_Integer (Dark3_Color), 165, "Long_Long_Integer (Dark3_Color) = FL_DARK3");
    Same (Long_Long_Integer (Dark2_Color), 166, "Long_Long_Integer (Dark2_Color) = FL_DARK2");
    Same (Long_Long_Integer (Dark1_Color), 167, "Long_Long_Integer (Dark1_Color) = FL_DARK1");
    Same
       (Long_Long_Integer (Background_Color),
        168,
        "Long_Long_Integer (Background_Color) = FL_BACKGROUND_COLOR");
    Same (Long_Long_Integer (Light1_Color), 169, "Long_Long_Integer (Light1_Color) = FL_LIGHT1");
    Same (Long_Long_Integer (Light2_Color), 170, "Long_Long_Integer (Light2_Color) = FL_LIGHT2");
    Same (Long_Long_Integer (Light3_Color), 171, "Long_Long_Integer (Light3_Color) = FL_LIGHT3");
    Same (Long_Long_Integer (Black_Color), 172, "Long_Long_Integer (Black_Color) = FL_BLACK");
    Same (Long_Long_Integer (Red_Color), 173, "Long_Long_Integer (Red_Color) = FL_RED");
    Same (Long_Long_Integer (Green_Color), 174, "Long_Long_Integer (Green_Color) = FL_GREEN");
    Same (Long_Long_Integer (Yellow_Color), 175, "Long_Long_Integer (Yellow_Color) = FL_YELLOW");
    Same (Long_Long_Integer (Blue_Color), 176, "Long_Long_Integer (Blue_Color) = FL_BLUE");
    Same
       (Long_Long_Integer (Magenta_Color),
        177,
        "Long_Long_Integer (Magenta_Color) = FL_MAGENTA");
    Same (Long_Long_Integer (Cyan_Color), 178, "Long_Long_Integer (Cyan_Color) = FL_CYAN");
    Same
       (Long_Long_Integer (Dark_Red_Color),
        179,
        "Long_Long_Integer (Dark_Red_Color) = FL_DARK_RED");
    Same
       (Long_Long_Integer (Dark_Green_Color),
        180,
        "Long_Long_Integer (Dark_Green_Color) = FL_DARK_GREEN");
    Same
       (Long_Long_Integer (Dark_Yellow_Color),
        181,
        "Long_Long_Integer (Dark_Yellow_Color) = FL_DARK_YELLOW");
    Same
       (Long_Long_Integer (Dark_Blue_Color),
        182,
        "Long_Long_Integer (Dark_Blue_Color) = FL_DARK_BLUE");
    Same
       (Long_Long_Integer (Dark_Magenta_Color),
        183,
        "Long_Long_Integer (Dark_Magenta_Color) = FL_DARK_MAGENTA");
    Same
       (Long_Long_Integer (Dark_Cyan_Color),
        184,
        "Long_Long_Integer (Dark_Cyan_Color) = FL_DARK_CYAN");
    Same (Long_Long_Integer (White_Color), 185, "Long_Long_Integer (White_Color) = FL_WHITE");
    Same
       (Long_Long_Integer (RGB_Red_Color),
        186,
        "Long_Long_Integer (RGB_Red_Color) = fl_rgb_color (255, 0, 0)");
    Same
       (Long_Long_Integer (RGB_Green_Color),
        187,
        "Long_Long_Integer (RGB_Green_Color) = fl_rgb_color (0, 255, 0)");
    Same
       (Long_Long_Integer (RGB_Blue_Color),
        188,
        "Long_Long_Integer (RGB_Blue_Color) = fl_rgb_color (0, 0, 255)");
    Same
       (Long_Long_Integer (RGB_White_Color),
        189,
        "Long_Long_Integer (RGB_White_Color) = fl_rgb_color (255, 255, 255)");

    --  Alignments (Fl_Align)
    Same
       (Long_Long_Integer (Align_Center),
        190,
        "Long_Long_Integer (Align_Center) = FL_ALIGN_CENTER");
    Same (Long_Long_Integer (Align_Top), 191, "Long_Long_Integer (Align_Top) = FL_ALIGN_TOP");
    Same
       (Long_Long_Integer (Align_Bottom),
        192,
        "Long_Long_Integer (Align_Bottom) = FL_ALIGN_BOTTOM");
    Same (Long_Long_Integer (Align_Left), 193, "Long_Long_Integer (Align_Left) = FL_ALIGN_LEFT");
    Same
       (Long_Long_Integer (Align_Right),
        194,
        "Long_Long_Integer (Align_Right) = FL_ALIGN_RIGHT");
    Same
       (Long_Long_Integer (Align_Inside),
        195,
        "Long_Long_Integer (Align_Inside) = FL_ALIGN_INSIDE");
    Same
       (Long_Long_Integer (Align_Text_Over_Image),
        196,
        "Long_Long_Integer (Align_Text_Over_Image) = FL_ALIGN_TEXT_OVER_IMAGE");
    Same
       (Long_Long_Integer (Align_Image_Over_Text),
        197,
        "Long_Long_Integer (Align_Image_Over_Text) = FL_ALIGN_IMAGE_OVER_TEXT");
    Same (Long_Long_Integer (Align_Clip), 198, "Long_Long_Integer (Align_Clip) = FL_ALIGN_CLIP");
    Same (Long_Long_Integer (Align_Wrap), 199, "Long_Long_Integer (Align_Wrap) = FL_ALIGN_WRAP");
    Same
       (Long_Long_Integer (Align_Image_Next_To_Text),
        200,
        "Long_Long_Integer (Align_Image_Next_To_Text) = FL_ALIGN_IMAGE_NEXT_TO_TEXT");
    Same
       (Long_Long_Integer (Align_Text_Next_To_Image),
        201,
        "Long_Long_Integer (Align_Text_Next_To_Image) = FL_ALIGN_TEXT_NEXT_TO_IMAGE");
    Same
       (Long_Long_Integer (Align_Image_Backdrop),
        202,
        "Long_Long_Integer (Align_Image_Backdrop) = FL_ALIGN_IMAGE_BACKDROP");
    Same
       (Long_Long_Integer (Align_Top_Left),
        203,
        "Long_Long_Integer (Align_Top_Left) = FL_ALIGN_TOP_LEFT");
    Same
       (Long_Long_Integer (Align_Top_Right),
        204,
        "Long_Long_Integer (Align_Top_Right) = FL_ALIGN_TOP_RIGHT");
    Same
       (Long_Long_Integer (Align_Bottom_Left),
        205,
        "Long_Long_Integer (Align_Bottom_Left) = FL_ALIGN_BOTTOM_LEFT");
    Same
       (Long_Long_Integer (Align_Bottom_Right),
        206,
        "Long_Long_Integer (Align_Bottom_Right) = FL_ALIGN_BOTTOM_RIGHT");
    Same
       (Long_Long_Integer (Align_Left_Top),
        207,
        "Long_Long_Integer (Align_Left_Top) = FL_ALIGN_LEFT_TOP");
    Same
       (Long_Long_Integer (Align_Right_Top),
        208,
        "Long_Long_Integer (Align_Right_Top) = FL_ALIGN_RIGHT_TOP");
    Same
       (Long_Long_Integer (Align_Left_Bottom),
        209,
        "Long_Long_Integer (Align_Left_Bottom) = FL_ALIGN_LEFT_BOTTOM");
    Same
       (Long_Long_Integer (Align_Right_Bottom),
        210,
        "Long_Long_Integer (Align_Right_Bottom) = FL_ALIGN_RIGHT_BOTTOM");
    Same
       (Long_Long_Integer (Align_Nowrap),
        211,
        "Long_Long_Integer (Align_Nowrap) = FL_ALIGN_NOWRAP");
    Same
       (Long_Long_Integer (Align_All_Position),
        212,
        "Long_Long_Integer (Align_All_Position) = FL_ALIGN_POSITION_MASK");
    Same
       (Long_Long_Integer (Align_All_Image),
        213,
        "Long_Long_Integer (Align_All_Image) = FL_ALIGN_IMAGE_MASK");

    --  Keys (Fl::event_key)
    Same
       (Long_Long_Integer (To_C (Enter_Key)),
        214,
        "Long_Long_Integer (To_C (Enter_Key)) = FL_Enter");
    Same
       (Long_Long_Integer (To_C (Keypad_Enter_Key)),
        215,
        "Long_Long_Integer (To_C (Keypad_Enter_Key)) = FL_KP_Enter");
    Same
       (Long_Long_Integer (To_C (Backspace_Key)),
        216,
        "Long_Long_Integer (To_C (Backspace_Key)) = FL_BackSpace");
    Same
       (Long_Long_Integer (To_C (Insert_Key)),
        217,
        "Long_Long_Integer (To_C (Insert_Key)) = FL_Insert");
    Same
       (Long_Long_Integer (To_C (Delete_Key)),
        218,
        "Long_Long_Integer (To_C (Delete_Key)) = FL_Delete");
    Same
       (Long_Long_Integer (To_C (Home_Key)),
        219,
        "Long_Long_Integer (To_C (Home_Key)) = FL_Home");
    Same (Long_Long_Integer (To_C (End_Key)), 220, "Long_Long_Integer (To_C (End_Key)) = FL_End");
    Same
       (Long_Long_Integer (To_C (Page_Down_Key)),
        221,
        "Long_Long_Integer (To_C (Page_Down_Key)) = FL_Page_Down");
    Same
       (Long_Long_Integer (To_C (Page_Up_Key)),
        222,
        "Long_Long_Integer (To_C (Page_Up_Key)) = FL_Page_Up");
    Same
       (Long_Long_Integer (To_C (Down_Key)),
        223,
        "Long_Long_Integer (To_C (Down_Key)) = FL_Down");
    Same
       (Long_Long_Integer (To_C (Left_Key)),
        224,
        "Long_Long_Integer (To_C (Left_Key)) = FL_Left");
    Same
       (Long_Long_Integer (To_C (Right_Key)),
        225,
        "Long_Long_Integer (To_C (Right_Key)) = FL_Right");
    Same (Long_Long_Integer (To_C (Up_Key)), 226, "Long_Long_Integer (To_C (Up_Key)) = FL_Up");
    Same
       (Long_Long_Integer (To_C (Escape_Key)),
        227,
        "Long_Long_Integer (To_C (Escape_Key)) = FL_Escape");
    Same (Long_Long_Integer (To_C (Tab_Key)), 228, "Long_Long_Integer (To_C (Tab_Key)) = FL_Tab");
    Same
       (Long_Long_Integer (To_C (ISO_Key)),
        229,
        "Long_Long_Integer (To_C (ISO_Key)) = FL_Iso_Key");
    Same
       (Long_Long_Integer (To_C (Pause_Key)),
        230,
        "Long_Long_Integer (To_C (Pause_Key)) = FL_Pause");
    Same
       (Long_Long_Integer (To_C (Scroll_Lock_Key)),
        231,
        "Long_Long_Integer (To_C (Scroll_Lock_Key)) = FL_Scroll_Lock");
    Same
       (Long_Long_Integer (To_C (Kana_Key)),
        232,
        "Long_Long_Integer (To_C (Kana_Key)) = FL_Kana");
    Same
       (Long_Long_Integer (To_C (Eisu_Key)),
        233,
        "Long_Long_Integer (To_C (Eisu_Key)) = FL_Eisu");
    Same (Long_Long_Integer (To_C (Yen_Key)), 234, "Long_Long_Integer (To_C (Yen_Key)) = FL_Yen");
    Same
       (Long_Long_Integer (To_C (JIS_Underscore_Key)),
        235,
        "Long_Long_Integer (To_C (JIS_Underscore_Key)) = FL_JIS_Underscore");
    Same
       (Long_Long_Integer (To_C (Print_Key)),
        236,
        "Long_Long_Integer (To_C (Print_Key)) = FL_Print");
    Same
       (Long_Long_Integer (To_C (Menu_Key)),
        237,
        "Long_Long_Integer (To_C (Menu_Key)) = FL_Menu");
    Same
       (Long_Long_Integer (To_C (Help_Key)),
        238,
        "Long_Long_Integer (To_C (Help_Key)) = FL_Help");
    Same
       (Long_Long_Integer (To_C (Num_Lock_Key)),
        239,
        "Long_Long_Integer (To_C (Num_Lock_Key)) = FL_Num_Lock");
    Same
       (Long_Long_Integer (To_C (Left_Shift_Key)),
        240,
        "Long_Long_Integer (To_C (Left_Shift_Key)) = FL_Shift_L");
    Same
       (Long_Long_Integer (To_C (Right_Shift_Key)),
        241,
        "Long_Long_Integer (To_C (Right_Shift_Key)) = FL_Shift_R");
    Same
       (Long_Long_Integer (To_C (Left_Control_Key)),
        242,
        "Long_Long_Integer (To_C (Left_Control_Key)) = FL_Control_L");
    Same
       (Long_Long_Integer (To_C (Right_Control_Key)),
        243,
        "Long_Long_Integer (To_C (Right_Control_Key)) = FL_Control_R");
    Same
       (Long_Long_Integer (To_C (Caps_Lock_Key)),
        244,
        "Long_Long_Integer (To_C (Caps_Lock_Key)) = FL_Caps_Lock");
    Same
       (Long_Long_Integer (To_C (Left_Meta_Key)),
        245,
        "Long_Long_Integer (To_C (Left_Meta_Key)) = FL_Meta_L");
    Same
       (Long_Long_Integer (To_C (Right_Meta_Key)),
        246,
        "Long_Long_Integer (To_C (Right_Meta_Key)) = FL_Meta_R");
    Same
       (Long_Long_Integer (To_C (Left_Alt_Key)),
        247,
        "Long_Long_Integer (To_C (Left_Alt_Key)) = FL_Alt_L");
    Same
       (Long_Long_Integer (To_C (Right_Alt_Key)),
        248,
        "Long_Long_Integer (To_C (Right_Alt_Key)) = FL_Alt_R");
    Same
       (Long_Long_Integer (To_C (Alt_Gr_Key)),
        249,
        "Long_Long_Integer (To_C (Alt_Gr_Key)) = FL_Alt_Gr");
    Same
       (Long_Long_Integer (To_C (Volume_Down_Key)),
        250,
        "Long_Long_Integer (To_C (Volume_Down_Key)) = FL_Volume_Down");
    Same
       (Long_Long_Integer (To_C (Volume_Mute_Key)),
        251,
        "Long_Long_Integer (To_C (Volume_Mute_Key)) = FL_Volume_Mute");
    Same
       (Long_Long_Integer (To_C (Volume_Up_Key)),
        252,
        "Long_Long_Integer (To_C (Volume_Up_Key)) = FL_Volume_Up");
    Same
       (Long_Long_Integer (To_C (Media_Play_Key)),
        253,
        "Long_Long_Integer (To_C (Media_Play_Key)) = FL_Media_Play");
    Same
       (Long_Long_Integer (To_C (Media_Stop_Key)),
        254,
        "Long_Long_Integer (To_C (Media_Stop_Key)) = FL_Media_Stop");
    Same
       (Long_Long_Integer (To_C (Media_Previous_Key)),
        255,
        "Long_Long_Integer (To_C (Media_Previous_Key)) = FL_Media_Prev");
    Same
       (Long_Long_Integer (To_C (Media_Next_Key)),
        256,
        "Long_Long_Integer (To_C (Media_Next_Key)) = FL_Media_Next");
    Same
       (Long_Long_Integer (To_C (Home_Page_Key)),
        257,
        "Long_Long_Integer (To_C (Home_Page_Key)) = FL_Home_Page");
    Same
       (Long_Long_Integer (To_C (Mail_Key)),
        258,
        "Long_Long_Integer (To_C (Mail_Key)) = FL_Mail");
    Same
       (Long_Long_Integer (To_C (Search_Key)),
        259,
        "Long_Long_Integer (To_C (Search_Key)) = FL_Search");
    Same
       (Long_Long_Integer (To_C (Back_Key)),
        260,
        "Long_Long_Integer (To_C (Back_Key)) = FL_Back");
    Same
       (Long_Long_Integer (To_C (Forward_Key)),
        261,
        "Long_Long_Integer (To_C (Forward_Key)) = FL_Forward");
    Same
       (Long_Long_Integer (To_C (Stop_Key)),
        262,
        "Long_Long_Integer (To_C (Stop_Key)) = FL_Stop");
    Same
       (Long_Long_Integer (To_C (Refresh_Key)),
        263,
        "Long_Long_Integer (To_C (Refresh_Key)) = FL_Refresh");
    Same
       (Long_Long_Integer (To_C (Sleep_Key)),
        264,
        "Long_Long_Integer (To_C (Sleep_Key)) = FL_Sleep");
    Same
       (Long_Long_Integer (To_C (Favorites_Key)),
        265,
        "Long_Long_Integer (To_C (Favorites_Key)) = FL_Favorites");
    Same
       (Long_Long_Integer (To_C (Function_Key (1))),
        266,
        "Long_Long_Integer (To_C (Function_Key (1))) = FL_F + 1");
    Same
       (Long_Long_Integer (To_C (Function_Key (12))),
        267,
        "Long_Long_Integer (To_C (Function_Key (12))) = FL_F + 12");
    Same
       (Long_Long_Integer (To_C (Function_Key (Function_Key_Number'Last))),
        268,
        "Long_Long_Integer (To_C (Function_Key (Function_Key_Number'Last))) = FL_F_Last");

    --  Options (Fl::Fl_Option)
    Same
       (Static.Option'Pos (Static.Arrow_Focus),
        269,
        "Static.Option'Pos (Static.Arrow_Focus) = Fl::OPTION_ARROW_FOCUS");
    Same
       (Static.Option'Pos (Static.Visible_Focus),
        270,
        "Static.Option'Pos (Static.Visible_Focus) = Fl::OPTION_VISIBLE_FOCUS");
    Same
       (Static.Option'Pos (Static.DND_Text),
        271,
        "Static.Option'Pos (Static.DND_Text) = Fl::OPTION_DND_TEXT");
    Same
       (Static.Option'Pos (Static.Show_Tooltips),
        272,
        "Static.Option'Pos (Static.Show_Tooltips) = Fl::OPTION_SHOW_TOOLTIPS");
    Same
       (Static.Option'Pos (Static.FNFC_Uses_GTK),
        273,
        "Static.Option'Pos (Static.FNFC_Uses_GTK) = Fl::OPTION_FNFC_USES_GTK");
    Same
       (Static.Option'Pos (Static.FNFC_Uses_Zenity),
        274,
        "Static.Option'Pos (Static.FNFC_Uses_Zenity) = Fl::OPTION_FNFC_USES_ZENITY");
    Same
       (Static.Option'Pos (Static.FNFC_Uses_KDialog),
        275,
        "Static.Option'Pos (Static.FNFC_Uses_KDialog) = Fl::OPTION_FNFC_USES_KDIALOG");
    Same
       (Static.Option'Pos (Static.Printer_Uses_GTK),
        276,
        "Static.Option'Pos (Static.Printer_Uses_GTK) = Fl::OPTION_PRINTER_USES_GTK");
    Same
       (Static.Option'Pos (Static.Show_Scaling),
        277,
        "Static.Option'Pos (Static.Show_Scaling) = Fl::OPTION_SHOW_SCALING");
    Same
       (Static.Option'Pos (Static.Simple_Zoom_Shortcut),
        278,
        "Static.Option'Pos (Static.Simple_Zoom_Shortcut) = Fl::OPTION_SIMPLE_ZOOM_SHORTCUT");
    Same
       (Long_Long_Integer (Static.Option'Pos (Static.Option'Last) + 1),
        279,
        "Long_Long_Integer (Static.Option'Pos (Static.Option'Last) + 1) = Fl::OPTION_LAST");

    --  Shift keys held (Fl::event_state); Mod_Command is Ctrl, or Meta on macOS
    Same (Long_Long_Integer (To_C (Mod_None)), 280, "Long_Long_Integer (To_C (Mod_None)) = 0");
    Same
       (Long_Long_Integer (To_C (Mod_Shift)),
        281,
        "Long_Long_Integer (To_C (Mod_Shift)) = FL_SHIFT");
    Same
       (Long_Long_Integer (To_C (Mod_Caps_Lock)),
        282,
        "Long_Long_Integer (To_C (Mod_Caps_Lock)) = FL_CAPS_LOCK");
    Same
       (Long_Long_Integer (To_C (Mod_Ctrl)),
        283,
        "Long_Long_Integer (To_C (Mod_Ctrl)) = FL_CTRL");
    Same (Long_Long_Integer (To_C (Mod_Alt)), 284, "Long_Long_Integer (To_C (Mod_Alt)) = FL_ALT");
    Same
       (Long_Long_Integer (To_C (Mod_Num_Lock)),
        285,
        "Long_Long_Integer (To_C (Mod_Num_Lock)) = FL_NUM_LOCK");
    Same
       (Long_Long_Integer (To_C (Mod_Meta)),
        286,
        "Long_Long_Integer (To_C (Mod_Meta)) = FL_META");
    Same
       (Long_Long_Integer (To_C (Mod_Scroll_Lock)),
        287,
        "Long_Long_Integer (To_C (Mod_Scroll_Lock)) = FL_SCROLL_LOCK");
    Same
       (Long_Long_Integer (To_C (Mod_Command)),
        288,
        "Long_Long_Integer (To_C (Mod_Command)) = FL_COMMAND");

    --  When a widget calls back (Fl_When)
    Same
       (Long_Long_Integer (Flag_To_UChar (Call_Never)),
        289,
        "Long_Long_Integer (Flag_To_UChar (Call_Never)) = FL_WHEN_NEVER");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Changed)),
        290,
        "Long_Long_Integer (Flag_To_UChar (When_Changed)) = FL_WHEN_CHANGED");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Interact)),
        291,
        "Long_Long_Integer (Flag_To_UChar (When_Interact)) = FL_WHEN_NOT_CHANGED");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Release)),
        292,
        "Long_Long_Integer (Flag_To_UChar (When_Release)) = FL_WHEN_RELEASE");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Release_Always)),
        293,
        "Long_Long_Integer (Flag_To_UChar (When_Release_Always)) = FL_WHEN_RELEASE_ALWAYS");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Enter_Key)),
        294,
        "Long_Long_Integer (Flag_To_UChar (When_Enter_Key)) = FL_WHEN_ENTER_KEY");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Enter_Key_Always)),
        295,
        "Long_Long_Integer (Flag_To_UChar (When_Enter_Key_Always)) = FL_WHEN_ENTER_KEY_ALWAYS");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Closed)),
        296,
        "Long_Long_Integer (Flag_To_UChar (When_Closed)) = FL_WHEN_CLOSED");

    --  Menu item flags (Fl_Menu_Item::flags)
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Normal)),
        297,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Normal)) = 0");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Inactive)),
        298,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Inactive)) = FL_MENU_INACTIVE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Toggle)),
        299,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Toggle)) = FL_MENU_TOGGLE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Value)),
        300,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Value)) = FL_MENU_VALUE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Radio)),
        301,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Radio)) = FL_MENU_RADIO");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Invisible)),
        302,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Invisible)) = FL_MENU_INVISIBLE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Submenu)),
        303,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Submenu)) = FL_SUBMENU");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Divider)),
        304,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Divider)) = FL_MENU_DIVIDER");

    --  What needs redrawing (Fl_Damage)
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_None)),
        305,
        "Long_Long_Integer (Mask_To_UChar (Damage_None)) = 0");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Child)),
        306,
        "Long_Long_Integer (Mask_To_UChar (Damage_Child)) = FL_DAMAGE_CHILD");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Expose)),
        307,
        "Long_Long_Integer (Mask_To_UChar (Damage_Expose)) = FL_DAMAGE_EXPOSE");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Scroll)),
        308,
        "Long_Long_Integer (Mask_To_UChar (Damage_Scroll)) = FL_DAMAGE_SCROLL");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Overlay)),
        309,
        "Long_Long_Integer (Mask_To_UChar (Damage_Overlay)) = FL_DAMAGE_OVERLAY");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_User_1)),
        310,
        "Long_Long_Integer (Mask_To_UChar (Damage_User_1)) = FL_DAMAGE_USER1");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_User_2)),
        311,
        "Long_Long_Integer (Mask_To_UChar (Damage_User_2)) = FL_DAMAGE_USER2");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Full)),
        312,
        "Long_Long_Integer (Mask_To_UChar (Damage_Full)) = FL_DAMAGE_ALL");

    --  Contrast modes (fl_contrast_mode)
    Same
       (Contrast_Mode'Pos (No_Contrast),
        313,
        "Contrast_Mode'Pos (No_Contrast) = FL_CONTRAST_NONE");
    Same
       (Contrast_Mode'Pos (Legacy_Contrast),
        314,
        "Contrast_Mode'Pos (Legacy_Contrast) = FL_CONTRAST_LEGACY");
    Same
       (Contrast_Mode'Pos (CIELAB_Contrast),
        315,
        "Contrast_Mode'Pos (CIELAB_Contrast) = FL_CONTRAST_CIELAB");
    Same
       (Contrast_Mode'Pos (Custom_Contrast),
        316,
        "Contrast_Mode'Pos (Custom_Contrast) = FL_CONTRAST_CUSTOM");

    --  Callback reasons (Fl_Callback_Reason)
    Same
       (Long_Long_Integer (Reason_Unknown),
        317,
        "Long_Long_Integer (Reason_Unknown) = FL_REASON_UNKNOWN");
    Same
       (Long_Long_Integer (Reason_Selected),
        318,
        "Long_Long_Integer (Reason_Selected) = FL_REASON_SELECTED");
    Same
       (Long_Long_Integer (Reason_Deselected),
        319,
        "Long_Long_Integer (Reason_Deselected) = FL_REASON_DESELECTED");
    Same
       (Long_Long_Integer (Reason_Reselected),
        320,
        "Long_Long_Integer (Reason_Reselected) = FL_REASON_RESELECTED");
    Same
       (Long_Long_Integer (Reason_Opened),
        321,
        "Long_Long_Integer (Reason_Opened) = FL_REASON_OPENED");
    Same
       (Long_Long_Integer (Reason_Closed),
        322,
        "Long_Long_Integer (Reason_Closed) = FL_REASON_CLOSED");
    Same
       (Long_Long_Integer (Reason_Dragged),
        323,
        "Long_Long_Integer (Reason_Dragged) = FL_REASON_DRAGGED");
    Same
       (Long_Long_Integer (Reason_Cancelled),
        324,
        "Long_Long_Integer (Reason_Cancelled) = FL_REASON_CANCELLED");
    Same
       (Long_Long_Integer (Reason_Changed),
        325,
        "Long_Long_Integer (Reason_Changed) = FL_REASON_CHANGED");
    Same
       (Long_Long_Integer (Reason_Got_Focus),
        326,
        "Long_Long_Integer (Reason_Got_Focus) = FL_REASON_GOT_FOCUS");
    Same
       (Long_Long_Integer (Reason_Lost_Focus),
        327,
        "Long_Long_Integer (Reason_Lost_Focus) = FL_REASON_LOST_FOCUS");
    Same
       (Long_Long_Integer (Reason_Released),
        328,
        "Long_Long_Integer (Reason_Released) = FL_REASON_RELEASED");
    Same
       (Long_Long_Integer (Reason_Enter_Key),
        329,
        "Long_Long_Integer (Reason_Enter_Key) = FL_REASON_ENTER_KEY");
    Same
       (Long_Long_Integer (Reason_User),
        330,
        "Long_Long_Integer (Reason_User) = FL_REASON_USER");

    --  Screen scaling support (Fl::screen_scaling_supported); FLTK's enum is
    --  private to Fl_Screen_Driver, so these are its values (Fl_Screen_Driver.H:228-231)
    Same
       (Screen.Scaling_Kind'Pos (Screen.No_Scaling),
        331,
        "Screen.Scaling_Kind'Pos (Screen.No_Scaling) = 0");
    Same
       (Screen.Scaling_Kind'Pos (Screen.Systemwide_Scaling),
        332,
        "Screen.Scaling_Kind'Pos (Screen.Systemwide_Scaling) = 1");
    Same
       (Screen.Scaling_Kind'Pos (Screen.Per_Screen_Scaling),
        333,
        "Screen.Scaling_Kind'Pos (Screen.Per_Screen_Scaling) = 2");

    --  Arrow types (Fl_Arrow_Type); FLTK.Draw passes Pos + 1
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Single_Arrow) + 1),
        334,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Single_Arrow) + 1) = FL_ARROW_SINGLE");
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Double_Arrow) + 1),
        335,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Double_Arrow) + 1) = FL_ARROW_DOUBLE");
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Choice_Arrow) + 1),
        336,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Choice_Arrow) + 1) = FL_ARROW_CHOICE");
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Return_Arrow) + 1),
        337,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Return_Arrow) + 1) = FL_ARROW_RETURN");

    --  Orientations (Fl_Orientation)
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Right),
        338,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Right) = FL_ORIENT_RIGHT");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_NE),
        339,
        "Draw.Orientation_Kind'Pos (Draw.Orient_NE) = FL_ORIENT_NE");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Up),
        340,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Up) = FL_ORIENT_UP");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_NW),
        341,
        "Draw.Orientation_Kind'Pos (Draw.Orient_NW) = FL_ORIENT_NW");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Left),
        342,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Left) = FL_ORIENT_LEFT");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_SW),
        343,
        "Draw.Orientation_Kind'Pos (Draw.Orient_SW) = FL_ORIENT_SW");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Down),
        344,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Down) = FL_ORIENT_DOWN");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_SE),
        345,
        "Draw.Orientation_Kind'Pos (Draw.Orient_SE) = FL_ORIENT_SE");

    --  File icons (Fl_File_Icon)
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Any_File),
        346,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Any_File) = Fl_File_Icon::ANY");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Plain_File),
        347,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Plain_File) = Fl_File_Icon::PLAIN");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Fifo_File),
        348,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Fifo_File) = Fl_File_Icon::FIFO");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Device_File),
        349,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Device_File) = Fl_File_Icon::DEVICE");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Link_File),
        350,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Link_File) = Fl_File_Icon::LINK");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Directory_File),
        351,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Directory_File)" &
        " = Fl_File_Icon::DIRECTORY");
    Same
       (Long_Long_Integer (Images.File_Icons.Icon_Color),
        352,
        "Long_Long_Integer (Images.File_Icons.Icon_Color) = FL_ICON_COLOR");

    --  Tab overflow (Fl_Tabs::handle_overflow)
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Compress_Overflow),
        353,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Compress_Overflow) = Fl_Tabs::OVERFLOW_COMPRESS");
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Clip_Overflow),
        354,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Clip_Overflow) = Fl_Tabs::OVERFLOW_CLIP");
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Pulldown_Overflow),
        355,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Pulldown_Overflow) = Fl_Tabs::OVERFLOW_PULLDOWN");
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Drag_Overflow),
        356,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Drag_Overflow) = Fl_Tabs::OVERFLOW_DRAG");

    --  Window menu styles (Fl_Sys_Menu_Bar::window_menu_style_enum)
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.No_Window_Menu),
        357,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.No_Window_Menu)" &
        " = Fl_Sys_Menu_Bar::no_window_menu");
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_None),
        358,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_None)" &
        " = Fl_Sys_Menu_Bar::tabbing_mode_none");
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Automatic),
        359,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Automatic)" &
        " = Fl_Sys_Menu_Bar::tabbing_mode_automatic");
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Preferred),
        360,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Preferred)" &
        " = Fl_Sys_Menu_Bar::tabbing_mode_preferred");

    --  Clock faces (Fl_Clock_Output::type)
    Same
       (Clocks.Clock_Kind'Pos (Clocks.Square_Face),
        361,
        "Clocks.Clock_Kind'Pos (Clocks.Square_Face) = FL_SQUARE_CLOCK");
    Same
       (Clocks.Clock_Kind'Pos (Clocks.Round_Face),
        362,
        "Clocks.Clock_Kind'Pos (Clocks.Round_Face) = FL_ROUND_CLOCK");

    --  Roller kinds (Fl_Roller::type)
    Same
       (Rollers.Roller_Kind'Pos (Rollers.Vertical_Roller),
        363,
        "Rollers.Roller_Kind'Pos (Rollers.Vertical_Roller) = FL_VERTICAL");
    Same
       (Rollers.Roller_Kind'Pos (Rollers.Horizontal_Roller),
        364,
        "Rollers.Roller_Kind'Pos (Rollers.Horizontal_Roller) = FL_HORIZONTAL");

    --  Browser kinds (Fl_Browser_::type)
    Same
       (Browsers.Browser_Kind'Pos (Browsers.Normal_Kind),
        365,
        "Browsers.Browser_Kind'Pos (Browsers.Normal_Kind) = FL_NORMAL_BROWSER");
    Same
       (Browsers.Browser_Kind'Pos (Browsers.Select_Kind),
        366,
        "Browsers.Browser_Kind'Pos (Browsers.Select_Kind) = FL_SELECT_BROWSER");
    Same
       (Browsers.Browser_Kind'Pos (Browsers.Hold_Kind),
        367,
        "Browsers.Browser_Kind'Pos (Browsers.Hold_Kind) = FL_HOLD_BROWSER");
    Same
       (Browsers.Browser_Kind'Pos (Browsers.Multi_Kind),
        368,
        "Browsers.Browser_Kind'Pos (Browsers.Multi_Kind) = FL_MULTI_BROWSER");

    --  Scroll kinds (Fl_Scroll::type)
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Neither),
        369,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Neither) = 0");
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Horizontal),
        370,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Horizontal) = Fl_Scroll::HORIZONTAL");
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Vertical),
        371,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Vertical) = Fl_Scroll::VERTICAL");
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Both),
        372,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Both) = Fl_Scroll::BOTH");
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Always_On),
        373,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Always_On) = Fl_Scroll::ALWAYS_ON");
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Horizontal_Always),
        374,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Horizontal_Always) = Fl_Scroll::HORIZONTAL_ALWAYS");
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Vertical_Always),
        375,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Vertical_Always) = Fl_Scroll::VERTICAL_ALWAYS");
    Same
       (Scrolls.Scroll_Kind'Pos (Scrolls.Both_Always),
        376,
        "Scrolls.Scroll_Kind'Pos (Scrolls.Both_Always) = Fl_Scroll::BOTH_ALWAYS");

    --  Button kinds (Fl_Button::type); a representation clause gives FLTK's values
    Same
       (Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Normal_Kind)),
        377,
        "Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Normal_Kind))" &
        " = FL_NORMAL_BUTTON");
    Same
       (Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Toggle_Kind)),
        378,
        "Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Toggle_Kind))" &
        " = FL_TOGGLE_BUTTON");
    Same
       (Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Hidden_Kind)),
        379,
        "Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Hidden_Kind))" &
        " = FL_HIDDEN_BUTTON");
    Same
       (Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Radio_Kind)),
        380,
        "Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.Radio_Kind)) = FL_RADIO_BUTTON");

    --  Tree kinds (Fl_Tree_Prefs.H, Fl_Tree.H)
    Same
       (Tree_Items.Sort_Kind'Pos (Tree_Items.No_Sort),
        381,
        "Tree_Items.Sort_Kind'Pos (Tree_Items.No_Sort) = FL_TREE_SORT_NONE");
    Same
       (Tree_Items.Sort_Kind'Pos (Tree_Items.Ascending),
        382,
        "Tree_Items.Sort_Kind'Pos (Tree_Items.Ascending) = FL_TREE_SORT_ASCENDING");
    Same
       (Tree_Items.Sort_Kind'Pos (Tree_Items.Descending),
        383,
        "Tree_Items.Sort_Kind'Pos (Tree_Items.Descending) = FL_TREE_SORT_DESCENDING");
    Same
       (Tree_Items.Connector_Kind'Pos (Tree_Items.No_Connector),
        384,
        "Tree_Items.Connector_Kind'Pos (Tree_Items.No_Connector) = FL_TREE_CONNECTOR_NONE");
    Same
       (Tree_Items.Connector_Kind'Pos (Tree_Items.Dotted_Connector),
        385,
        "Tree_Items.Connector_Kind'Pos (Tree_Items.Dotted_Connector) = FL_TREE_CONNECTOR_DOTTED");
    Same
       (Tree_Items.Connector_Kind'Pos (Tree_Items.Solid_Connector),
        386,
        "Tree_Items.Connector_Kind'Pos (Tree_Items.Solid_Connector) = FL_TREE_CONNECTOR_SOLID");
    Same
       (Tree_Items.Selection_Kind'Pos (Tree_Items.No_Selection),
        387,
        "Tree_Items.Selection_Kind'Pos (Tree_Items.No_Selection) = FL_TREE_SELECT_NONE");
    Same
       (Tree_Items.Selection_Kind'Pos (Tree_Items.Single_Selection),
        388,
        "Tree_Items.Selection_Kind'Pos (Tree_Items.Single_Selection) = FL_TREE_SELECT_SINGLE");
    Same
       (Tree_Items.Selection_Kind'Pos (Tree_Items.Multi_Selection),
        389,
        "Tree_Items.Selection_Kind'Pos (Tree_Items.Multi_Selection) = FL_TREE_SELECT_MULTI");
    Same
       (Tree_Items.Selection_Kind'Pos (Tree_Items.Single_Draggable_Selection),
        390,
        "Tree_Items.Selection_Kind'Pos (Tree_Items.Single_Draggable_Selection)" &
        " = FL_TREE_SELECT_SINGLE_DRAGGABLE");
    Same
       (Tree_Items.Reselect_Kind'Pos (Tree_Items.Selectable_Once),
        391,
        "Tree_Items.Reselect_Kind'Pos (Tree_Items.Selectable_Once) = FL_TREE_SELECTABLE_ONCE");
    Same
       (Tree_Items.Reselect_Kind'Pos (Tree_Items.Selectable_Always),
        392,
        "Tree_Items.Reselect_Kind'Pos (Tree_Items.Selectable_Always) = FL_TREE_SELECTABLE_ALWAYS");
    Same
       (Trees.Reason_Kind'Pos (Trees.No_Reason),
        393,
        "Trees.Reason_Kind'Pos (Trees.No_Reason) = FL_TREE_REASON_NONE");
    Same
       (Trees.Reason_Kind'Pos (Trees.Selected),
        394,
        "Trees.Reason_Kind'Pos (Trees.Selected) = FL_TREE_REASON_SELECTED");
    Same
       (Trees.Reason_Kind'Pos (Trees.Deselected),
        395,
        "Trees.Reason_Kind'Pos (Trees.Deselected) = FL_TREE_REASON_DESELECTED");
    Same
       (Trees.Reason_Kind'Pos (Trees.Reselected),
        396,
        "Trees.Reason_Kind'Pos (Trees.Reselected) = FL_TREE_REASON_RESELECTED");
    Same
       (Trees.Reason_Kind'Pos (Trees.Opened),
        397,
        "Trees.Reason_Kind'Pos (Trees.Opened) = FL_TREE_REASON_OPENED");
    Same
       (Trees.Reason_Kind'Pos (Trees.Closed),
        398,
        "Trees.Reason_Kind'Pos (Trees.Closed) = FL_TREE_REASON_CLOSED");
    Same
       (Trees.Reason_Kind'Pos (Trees.Dragged),
        399,
        "Trees.Reason_Kind'Pos (Trees.Dragged) = FL_TREE_REASON_DRAGGED");

end FLTK.Test_Constants;
