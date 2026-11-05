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
    FLTK.Widgets.Groups.Tabbed,
    FLTK.Widgets.Menus.Menu_Bars.Systemwide;


procedure FLTK.Test_Constants is


    package Tabbed renames FLTK.Widgets.Groups.Tabbed;
    package Sys_Menu renames FLTK.Widgets.Menus.Menu_Bars.Systemwide;


    type Value_Array is array (1 .. 308) of Long_Long_Integer;
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
    Same (Font_Kind'Pos (Helvetica), 70, "Font_Kind'Pos (Helvetica) = FL_HELVETICA");
    Same
       (Font_Kind'Pos (Helvetica_Bold),
        71,
        "Font_Kind'Pos (Helvetica_Bold) = FL_HELVETICA_BOLD");
    Same
       (Font_Kind'Pos (Helvetica_Italic),
        72,
        "Font_Kind'Pos (Helvetica_Italic) = FL_HELVETICA_ITALIC");
    Same
       (Font_Kind'Pos (Helvetica_Bold_Italic),
        73,
        "Font_Kind'Pos (Helvetica_Bold_Italic) = FL_HELVETICA_BOLD_ITALIC");
    Same (Font_Kind'Pos (Courier), 74, "Font_Kind'Pos (Courier) = FL_COURIER");
    Same (Font_Kind'Pos (Courier_Bold), 75, "Font_Kind'Pos (Courier_Bold) = FL_COURIER_BOLD");
    Same
       (Font_Kind'Pos (Courier_Italic),
        76,
        "Font_Kind'Pos (Courier_Italic) = FL_COURIER_ITALIC");
    Same
       (Font_Kind'Pos (Courier_Bold_Italic),
        77,
        "Font_Kind'Pos (Courier_Bold_Italic) = FL_COURIER_BOLD_ITALIC");
    Same (Font_Kind'Pos (Times), 78, "Font_Kind'Pos (Times) = FL_TIMES");
    Same (Font_Kind'Pos (Times_Bold), 79, "Font_Kind'Pos (Times_Bold) = FL_TIMES_BOLD");
    Same (Font_Kind'Pos (Times_Italic), 80, "Font_Kind'Pos (Times_Italic) = FL_TIMES_ITALIC");
    Same
       (Font_Kind'Pos (Times_Bold_Italic),
        81,
        "Font_Kind'Pos (Times_Bold_Italic) = FL_TIMES_BOLD_ITALIC");
    Same (Font_Kind'Pos (Symbol), 82, "Font_Kind'Pos (Symbol) = FL_SYMBOL");
    Same (Font_Kind'Pos (Monospace), 83, "Font_Kind'Pos (Monospace) = FL_SCREEN");
    Same (Font_Kind'Pos (Monospace_Bold), 84, "Font_Kind'Pos (Monospace_Bold) = FL_SCREEN_BOLD");
    Same (Font_Kind'Pos (Zapf_Dingbats), 85, "Font_Kind'Pos (Zapf_Dingbats) = FL_ZAPF_DINGBATS");
    Same (Font_Kind'Pos (Free_Font), 86, "Font_Kind'Pos (Free_Font) = FL_FREE_FONT");
    Same (Long_Long_Integer (Normal_Size), 87, "Long_Long_Integer (Normal_Size) = FL_NORMAL_SIZE");

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

    --  Shift keys held (Fl::event_state); Mod_Command is Ctrl, or Meta on macOS
    Same (Long_Long_Integer (To_C (Mod_None)), 229, "Long_Long_Integer (To_C (Mod_None)) = 0");
    Same
       (Long_Long_Integer (To_C (Mod_Shift)),
        230,
        "Long_Long_Integer (To_C (Mod_Shift)) = FL_SHIFT");
    Same
       (Long_Long_Integer (To_C (Mod_Caps_Lock)),
        231,
        "Long_Long_Integer (To_C (Mod_Caps_Lock)) = FL_CAPS_LOCK");
    Same
       (Long_Long_Integer (To_C (Mod_Ctrl)),
        232,
        "Long_Long_Integer (To_C (Mod_Ctrl)) = FL_CTRL");
    Same (Long_Long_Integer (To_C (Mod_Alt)), 233, "Long_Long_Integer (To_C (Mod_Alt)) = FL_ALT");
    Same
       (Long_Long_Integer (To_C (Mod_Num_Lock)),
        234,
        "Long_Long_Integer (To_C (Mod_Num_Lock)) = FL_NUM_LOCK");
    Same
       (Long_Long_Integer (To_C (Mod_Meta)),
        235,
        "Long_Long_Integer (To_C (Mod_Meta)) = FL_META");
    Same
       (Long_Long_Integer (To_C (Mod_Scroll_Lock)),
        236,
        "Long_Long_Integer (To_C (Mod_Scroll_Lock)) = FL_SCROLL_LOCK");
    Same
       (Long_Long_Integer (To_C (Mod_Command)),
        237,
        "Long_Long_Integer (To_C (Mod_Command)) = FL_COMMAND");

    --  When a widget calls back (Fl_When)
    Same
       (Long_Long_Integer (Flag_To_UChar (Call_Never)),
        238,
        "Long_Long_Integer (Flag_To_UChar (Call_Never)) = FL_WHEN_NEVER");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Changed)),
        239,
        "Long_Long_Integer (Flag_To_UChar (When_Changed)) = FL_WHEN_CHANGED");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Interact)),
        240,
        "Long_Long_Integer (Flag_To_UChar (When_Interact)) = FL_WHEN_NOT_CHANGED");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Release)),
        241,
        "Long_Long_Integer (Flag_To_UChar (When_Release)) = FL_WHEN_RELEASE");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Release_Always)),
        242,
        "Long_Long_Integer (Flag_To_UChar (When_Release_Always)) = FL_WHEN_RELEASE_ALWAYS");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Enter_Key)),
        243,
        "Long_Long_Integer (Flag_To_UChar (When_Enter_Key)) = FL_WHEN_ENTER_KEY");
    Same
       (Long_Long_Integer (Flag_To_UChar (When_Enter_Key_Always)),
        244,
        "Long_Long_Integer (Flag_To_UChar (When_Enter_Key_Always)) = FL_WHEN_ENTER_KEY_ALWAYS");

    --  Menu item flags (Fl_Menu_Item::flags)
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Normal)),
        245,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Normal)) = 0");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Inactive)),
        246,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Inactive)) = FL_MENU_INACTIVE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Toggle)),
        247,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Toggle)) = FL_MENU_TOGGLE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Value)),
        248,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Value)) = FL_MENU_VALUE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Radio)),
        249,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Radio)) = FL_MENU_RADIO");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Invisible)),
        250,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Invisible)) = FL_MENU_INVISIBLE");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Submenu)),
        251,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Submenu)) = FL_SUBMENU");
    Same
       (Long_Long_Integer (MFlag_To_Cint (Flag_Divider)),
        252,
        "Long_Long_Integer (MFlag_To_Cint (Flag_Divider)) = FL_MENU_DIVIDER");

    --  What needs redrawing (Fl_Damage)
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_None)),
        253,
        "Long_Long_Integer (Mask_To_UChar (Damage_None)) = 0");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Child)),
        254,
        "Long_Long_Integer (Mask_To_UChar (Damage_Child)) = FL_DAMAGE_CHILD");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Expose)),
        255,
        "Long_Long_Integer (Mask_To_UChar (Damage_Expose)) = FL_DAMAGE_EXPOSE");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Scroll)),
        256,
        "Long_Long_Integer (Mask_To_UChar (Damage_Scroll)) = FL_DAMAGE_SCROLL");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Overlay)),
        257,
        "Long_Long_Integer (Mask_To_UChar (Damage_Overlay)) = FL_DAMAGE_OVERLAY");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_User_1)),
        258,
        "Long_Long_Integer (Mask_To_UChar (Damage_User_1)) = FL_DAMAGE_USER1");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_User_2)),
        259,
        "Long_Long_Integer (Mask_To_UChar (Damage_User_2)) = FL_DAMAGE_USER2");
    Same
       (Long_Long_Integer (Mask_To_UChar (Damage_Full)),
        260,
        "Long_Long_Integer (Mask_To_UChar (Damage_Full)) = FL_DAMAGE_ALL");

    --  Contrast modes (fl_contrast_mode)
    Same
       (Contrast_Mode'Pos (No_Contrast),
        261,
        "Contrast_Mode'Pos (No_Contrast) = FL_CONTRAST_NONE");
    Same
       (Contrast_Mode'Pos (Legacy_Contrast),
        262,
        "Contrast_Mode'Pos (Legacy_Contrast) = FL_CONTRAST_LEGACY");
    Same
       (Contrast_Mode'Pos (CIELAB_Contrast),
        263,
        "Contrast_Mode'Pos (CIELAB_Contrast) = FL_CONTRAST_CIELAB");
    Same
       (Contrast_Mode'Pos (Custom_Contrast),
        264,
        "Contrast_Mode'Pos (Custom_Contrast) = FL_CONTRAST_CUSTOM");

    --  Callback reasons (Fl_Callback_Reason)
    Same
       (Long_Long_Integer (Reason_Unknown),
        265,
        "Long_Long_Integer (Reason_Unknown) = FL_REASON_UNKNOWN");
    Same
       (Long_Long_Integer (Reason_Selected),
        266,
        "Long_Long_Integer (Reason_Selected) = FL_REASON_SELECTED");
    Same
       (Long_Long_Integer (Reason_Deselected),
        267,
        "Long_Long_Integer (Reason_Deselected) = FL_REASON_DESELECTED");
    Same
       (Long_Long_Integer (Reason_Reselected),
        268,
        "Long_Long_Integer (Reason_Reselected) = FL_REASON_RESELECTED");
    Same
       (Long_Long_Integer (Reason_Opened),
        269,
        "Long_Long_Integer (Reason_Opened) = FL_REASON_OPENED");
    Same
       (Long_Long_Integer (Reason_Closed),
        270,
        "Long_Long_Integer (Reason_Closed) = FL_REASON_CLOSED");
    Same
       (Long_Long_Integer (Reason_Dragged),
        271,
        "Long_Long_Integer (Reason_Dragged) = FL_REASON_DRAGGED");
    Same
       (Long_Long_Integer (Reason_Cancelled),
        272,
        "Long_Long_Integer (Reason_Cancelled) = FL_REASON_CANCELLED");
    Same
       (Long_Long_Integer (Reason_Changed),
        273,
        "Long_Long_Integer (Reason_Changed) = FL_REASON_CHANGED");
    Same
       (Long_Long_Integer (Reason_Got_Focus),
        274,
        "Long_Long_Integer (Reason_Got_Focus) = FL_REASON_GOT_FOCUS");
    Same
       (Long_Long_Integer (Reason_Lost_Focus),
        275,
        "Long_Long_Integer (Reason_Lost_Focus) = FL_REASON_LOST_FOCUS");
    Same
       (Long_Long_Integer (Reason_Released),
        276,
        "Long_Long_Integer (Reason_Released) = FL_REASON_RELEASED");
    Same
       (Long_Long_Integer (Reason_Enter_Key),
        277,
        "Long_Long_Integer (Reason_Enter_Key) = FL_REASON_ENTER_KEY");
    Same
       (Long_Long_Integer (Reason_User),
        278,
        "Long_Long_Integer (Reason_User) = FL_REASON_USER");

    --  Screen scaling support (Fl::screen_scaling_supported); FLTK's enum is
    --  private to Fl_Screen_Driver, so these are its values (Fl_Screen_Driver.H:228-231)
    Same
       (Screen.Scaling_Kind'Pos (Screen.No_Scaling),
        279,
        "Screen.Scaling_Kind'Pos (Screen.No_Scaling) = 0");
    Same
       (Screen.Scaling_Kind'Pos (Screen.Systemwide_Scaling),
        280,
        "Screen.Scaling_Kind'Pos (Screen.Systemwide_Scaling) = 1");
    Same
       (Screen.Scaling_Kind'Pos (Screen.Per_Screen_Scaling),
        281,
        "Screen.Scaling_Kind'Pos (Screen.Per_Screen_Scaling) = 2");

    --  Arrow types (Fl_Arrow_Type); FLTK.Draw passes Pos + 1
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Single_Arrow) + 1),
        282,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Single_Arrow) + 1) = FL_ARROW_SINGLE");
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Double_Arrow) + 1),
        283,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Double_Arrow) + 1) = FL_ARROW_DOUBLE");
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Choice_Arrow) + 1),
        284,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Choice_Arrow) + 1) = FL_ARROW_CHOICE");
    Same
       (Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Return_Arrow) + 1),
        285,
        "Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.Return_Arrow) + 1) = FL_ARROW_RETURN");

    --  Orientations (Fl_Orientation)
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Right),
        286,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Right) = FL_ORIENT_RIGHT");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_NE),
        287,
        "Draw.Orientation_Kind'Pos (Draw.Orient_NE) = FL_ORIENT_NE");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Up),
        288,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Up) = FL_ORIENT_UP");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_NW),
        289,
        "Draw.Orientation_Kind'Pos (Draw.Orient_NW) = FL_ORIENT_NW");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Left),
        290,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Left) = FL_ORIENT_LEFT");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_SW),
        291,
        "Draw.Orientation_Kind'Pos (Draw.Orient_SW) = FL_ORIENT_SW");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_Down),
        292,
        "Draw.Orientation_Kind'Pos (Draw.Orient_Down) = FL_ORIENT_DOWN");
    Same
       (Draw.Orientation_Kind'Pos (Draw.Orient_SE),
        293,
        "Draw.Orientation_Kind'Pos (Draw.Orient_SE) = FL_ORIENT_SE");

    --  File icons (Fl_File_Icon)
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Any_File),
        294,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Any_File) = Fl_File_Icon::ANY");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Plain_File),
        295,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Plain_File) = Fl_File_Icon::PLAIN");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Fifo_File),
        296,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Fifo_File) = Fl_File_Icon::FIFO");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Device_File),
        297,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Device_File) = Fl_File_Icon::DEVICE");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Link_File),
        298,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Link_File) = Fl_File_Icon::LINK");
    Same
       (Images.File_Icons.File_Kind'Pos (Images.File_Icons.Directory_File),
        299,
        "Images.File_Icons.File_Kind'Pos (Images.File_Icons.Directory_File)" &
        " = Fl_File_Icon::DIRECTORY");
    Same
       (Long_Long_Integer (Images.File_Icons.Icon_Color),
        300,
        "Long_Long_Integer (Images.File_Icons.Icon_Color) = FL_ICON_COLOR");

    --  Tab overflow (Fl_Tabs::handle_overflow)
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Compress_Overflow),
        301,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Compress_Overflow) = Fl_Tabs::OVERFLOW_COMPRESS");
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Clip_Overflow),
        302,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Clip_Overflow) = Fl_Tabs::OVERFLOW_CLIP");
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Pulldown_Overflow),
        303,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Pulldown_Overflow) = Fl_Tabs::OVERFLOW_PULLDOWN");
    Same
       (Tabbed.Overflow_Kind'Pos (Tabbed.Drag_Overflow),
        304,
        "Tabbed.Overflow_Kind'Pos (Tabbed.Drag_Overflow) = Fl_Tabs::OVERFLOW_DRAG");

    --  Window menu styles (Fl_Sys_Menu_Bar::window_menu_style_enum)
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.No_Window_Menu),
        305,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.No_Window_Menu)" &
        " = Fl_Sys_Menu_Bar::no_window_menu");
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_None),
        306,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_None)" &
        " = Fl_Sys_Menu_Bar::tabbing_mode_none");
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Automatic),
        307,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Automatic)" &
        " = Fl_Sys_Menu_Bar::tabbing_mode_automatic");
    Same
       (Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Preferred),
        308,
        "Sys_Menu.Window_Menu_Style_Kind'Pos (Sys_Menu.Tabbing_Mode_Preferred)" &
        " = Fl_Sys_Menu_Bar::tabbing_mode_preferred");

end FLTK.Test_Constants;
