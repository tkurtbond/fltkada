#!/usr/bin/env python3
# Programmed by T. Kurt Bond and Claude Opus 5.5
# Released into the public domain
# Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
# author releases this derived work into the public domain, as FLTKAda is.
#
# gen-constants.py: write the constants test (PLAN.md, Phase 0).
#
#   python3 tools/gen-constants.py
#
# FLTKAda's constants are written by hand in spec/fltk.ads: the
# enumerations, whose positions are FLTK's values, and the colours, keys,
# modifiers, flags, alignments and cursors.  This script writes a test
# that compares each one with FLTK's own value, so that an FLTK upgrade
# which renumbers or adds to them fails loudly instead of silently.  It
# writes two files:
#
#   test/unit/c_constants.cpp      FLTK's values, compiled from FL/*.H
#   test/unit/fltk-test_constants.adb
#                                  FLTKAda's values, in the same order;
#                                  a child of FLTK, so it can see the
#                                  private conversions (To_C,
#                                  Flag_To_UChar, Cursor_Values, ...)
#
# test/unit/test_constants.adb, written by hand, runs it.  The Forms
# library's constants get the same two files in test/unit/forms, named
# c_forms_constants.cpp and fltk-test_forms_constants.adb, run by
# test_forms_constants.adb there, and the Cairo library's, in
# test/unit/cairo, c_cairo_constants.cpp and
# fltk-test_cairo_constants.adb, run by test_cairo_constants.adb.  The C++ is
# compiled against the installed headers, so an FLTK upgrade needs no new
# run of this script; rerun it only when the list below changes, such as
# when FLTKAda gains an enumerator.  pofltk's gen-constants.py writes the
# Oberon constants themselves; FLTKAda's are hand-written Ada types, so
# this one writes only the test.

import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

#  Each check is (Ada expression, C++ expression); the test passes when
#  they have the same value.  Sections become comments.
CHECKS = []


def section(title):
    CHECKS.append(title)


def add(ada, c):
    CHECKS.append((ada, c))


def enum(typ, pairs):
    for ada, c in pairs:
        add(f"{typ}'Pos ({ada})", c)


def consts(pairs):
    for ada, c in pairs:
        add(f"Long_Long_Integer ({ada})", c)


def upper(names):
    return [(n, "FL_" + n.upper()) for n in names.split()]


section("Box types (Fl_Boxtype).  The ones FLTK defines as functions, such as\n"
        "--  FL_SHADOW_BOX, are compared with the enumerator behind them.")
PLAIN_BOXES = """No_Box Flat_Box Up_Box Down_Box Up_Frame Down_Frame Thin_Up_Box
Thin_Down_Box Thin_Up_Frame Thin_Down_Frame Engraved_Box Embossed_Box
Engraved_Frame Embossed_Frame Border_Box Border_Frame""".split()
BOXES = """No_Box Flat_Box Up_Box Down_Box Up_Frame Down_Frame Thin_Up_Box
Thin_Down_Box Thin_Up_Frame Thin_Down_Frame Engraved_Box Embossed_Box
Engraved_Frame Embossed_Frame Border_Box Shadow_Box Border_Frame Shadow_Frame
Rounded_Box RShadow_Box Rounded_Frame RFlat_Box Round_Up_Box Round_Down_Box
Diamond_Up_Box Diamond_Down_Box Oval_Box OShadow_Box Oval_Frame OFlat_Box
Plastic_Up_Box Plastic_Down_Box Plastic_Up_Frame Plastic_Down_Frame
Plastic_Thin_Up_Box Plastic_Thin_Down_Box Plastic_Round_Up_Box
Plastic_Round_Down_Box Gtk_Up_Box Gtk_Down_Box Gtk_Up_Frame Gtk_Down_Frame
Gtk_Thin_Up_Box Gtk_Thin_Down_Box Gtk_Thin_Up_Frame Gtk_Thin_Down_Frame
Gtk_Round_Up_Box Gtk_Round_Down_Box Gleam_Up_Box Gleam_Down_Box Gleam_Up_Frame
Gleam_Down_Frame Gleam_Thin_Up_Box Gleam_Thin_Down_Box Gleam_Round_Up_Box
Gleam_Round_Down_Box Oxy_Up_Box Oxy_Down_Box Oxy_Up_Frame Oxy_Down_Frame
Oxy_Thin_Up_Box Oxy_Thin_Down_Box Oxy_Thin_Up_Frame Oxy_Thin_Down_Frame
Oxy_Round_Up_Box Oxy_Round_Down_Box Oxy_Button_Up_Box
Oxy_Button_Down_Box""".split()
enum("Box_Kind", [(b, ("FL_" if b in PLAIN_BOXES else "_FL_") + b.upper()) for b in BOXES]
     + [("Free_Box", "FL_FREE_BOXTYPE")])

section("Fonts (Fl_Font)")
consts(upper("""Helvetica Helvetica_Bold Helvetica_Italic
Helvetica_Bold_Italic Courier Courier_Bold Courier_Italic Courier_Bold_Italic
Times Times_Bold Times_Italic Times_Bold_Italic Symbol""")
     + [("Monospace", "FL_SCREEN"), ("Monospace_Bold", "FL_SCREEN_BOLD"),
        ("Zapf_Dingbats", "FL_ZAPF_DINGBATS"), ("Free_Font", "FL_FREE_FONT")])
add("Long_Long_Integer (Get_Normal_Size)", "FL_NORMAL_SIZE")

section("Label types (Fl_Labeltype)")
enum("Label_Kind", [("Normal_Label", "FL_NORMAL_LABEL"), ("No_Label", "FL_NO_LABEL")]
     + [(n, "_FL_" + n.upper()) for n in
        "Shadow_Label Engraved_Label Embossed_Label Multi_Label Icon_Label Image_Label".split()]
     + [("Free_Label", "FL_FREE_LABELTYPE")])

section("Events (Fl_Event).  The last check fails when FLTK has events that\n"
        "--  Event_Kind lacks.")
enum("Event_Kind", upper("""No_Event Push Release Enter Leave Drag Focus Unfocus
Keydown Keyup Close Move Shortcut Deactivate Activate Hide Show Paste""")
     + [("Selection_Clear", "FL_SELECTIONCLEAR"), ("Mouse_Wheel", "FL_MOUSEWHEEL")]
     + upper("DnD_Enter DnD_Drag DnD_Leave DnD_Release")
     + [("Screen_Config_Changed", "FL_SCREEN_CONFIGURATION_CHANGED"),
        ("Fullscreen", "FL_FULLSCREEN"), ("Zoom_Gesture", "FL_ZOOM_GESTURE"),
        ("Zoom_Event", "FL_ZOOM_EVENT"), ("Event_Kind'Last", "FL_ZOOM_EVENT")])

section("Mouse buttons: Fl::event_button, and the bits in Fl::event_state")
enum("Mouse_Button", [("Left_Button", "FL_LEFT_MOUSE"), ("Middle_Button", "FL_MIDDLE_MOUSE"),
                      ("Right_Button", "FL_RIGHT_MOUSE"), ("Back_Button", "FL_BACK_MOUSE"),
                      ("Forward_Button", "FL_FORWARD_MOUSE")])
for b, c in [("No_Button", "0"), ("Left_Button", "FL_BUTTON1"), ("Middle_Button", "FL_BUTTON2"),
             ("Right_Button", "FL_BUTTON3"), ("Back_Button", "FL_BUTTON4"),
             ("Forward_Button", "FL_BUTTON5"), ("Any_Button", "FL_BUTTONS")]:
    add(f"Long_Long_Integer (To_C ({b}))", c)

section("Mouse cursors (Fl_Cursor)")
CURSORS = [("Default", "DEFAULT"), ("Arrow", "ARROW"), ("Crosshair", "CROSS"),
           ("Wait", "WAIT"), ("Insert", "INSERT"), ("Hand", "HAND"), ("Help", "HELP"),
           ("Move", "MOVE")] + [(d, d) for d in
                                "NS WE NWSE NESW N NE E SE S SW W NW".split()] + [("None", "NONE")]
for a, c in CURSORS:
    add(f"Long_Long_Integer (Cursor_Values ({a}_Mouse))", "FL_CURSOR_" + c)

section("Colours (Fl_Color)")
for a, c in [("Foreground", "FOREGROUND_COLOR"), ("Background2", "BACKGROUND2_COLOR"),
             ("Inactive", "INACTIVE_COLOR"), ("Selection", "SELECTION_COLOR"),
             ("Free", "FREE_COLOR"), ("Grey0", "GRAY0"), ("Dark3", "DARK3"), ("Dark2", "DARK2"),
             ("Dark1", "DARK1"), ("Background", "BACKGROUND_COLOR"), ("Light1", "LIGHT1"),
             ("Light2", "LIGHT2"), ("Light3", "LIGHT3")] + \
        [(n, n.upper()) for n in """Black Red Green Yellow Blue Magenta Cyan Dark_Red
        Dark_Green Dark_Yellow Dark_Blue Dark_Magenta Dark_Cyan White""".split()]:
    add(f"Long_Long_Integer ({a}_Color)", "FL_" + c)
for a, rgb in [("Red", "255, 0, 0"), ("Green", "0, 255, 0"), ("Blue", "0, 0, 255"),
               ("White", "255, 255, 255")]:
    add(f"Long_Long_Integer (RGB_{a}_Color)", f"fl_rgb_color ({rgb})")

section("Alignments (Fl_Align)")
for a in """Center Top Bottom Left Right Inside Text_Over_Image Image_Over_Text Clip Wrap
Image_Next_To_Text Text_Next_To_Image Image_Backdrop Top_Left Top_Right Bottom_Left
Bottom_Right Left_Top Right_Top Left_Bottom Right_Bottom Nowrap""".split():
    add(f"Long_Long_Integer (Align_{a})", "FL_ALIGN_" + a.upper())
add("Long_Long_Integer (Align_All_Position)", "FL_ALIGN_POSITION_MASK")
add("Long_Long_Integer (Align_All_Image)", "FL_ALIGN_IMAGE_MASK")

section("Keys (Fl::event_key)")
for a, c in ([("Enter", "Enter"), ("Keypad_Enter", "KP_Enter"), ("Backspace", "BackSpace"),
             ("Insert", "Insert"), ("Delete", "Delete"), ("Home", "Home"), ("End", "End"),
             ("Page_Down", "Page_Down"), ("Page_Up", "Page_Up"), ("Down", "Down"),
             ("Left", "Left"), ("Right", "Right"), ("Up", "Up"), ("Escape", "Escape"),
             ("Tab", "Tab"), ("ISO", "Iso_Key"), ("Pause", "Pause"),
             ("Scroll_Lock", "Scroll_Lock"), ("Kana", "Kana"), ("Eisu", "Eisu"),
             ("Yen", "Yen"), ("JIS_Underscore", "JIS_Underscore"), ("Print", "Print"),
             ("Menu", "Menu"), ("Help", "Help"), ("Num_Lock", "Num_Lock"),
             ("Left_Shift", "Shift_L"), ("Right_Shift", "Shift_R"),
             ("Left_Control", "Control_L"), ("Right_Control", "Control_R"),
             ("Caps_Lock", "Caps_Lock"), ("Left_Meta", "Meta_L"), ("Right_Meta", "Meta_R"),
             ("Left_Alt", "Alt_L"), ("Right_Alt", "Alt_R"), ("Alt_Gr", "Alt_Gr")]
            + [("Volume_Down", "Volume_Down"), ("Volume_Mute", "Volume_Mute"),
               ("Volume_Up", "Volume_Up"), ("Media_Play", "Media_Play"),
               ("Media_Stop", "Media_Stop"), ("Media_Previous", "Media_Prev"),
               ("Media_Next", "Media_Next"), ("Home_Page", "Home_Page"), ("Mail", "Mail"),
               ("Search", "Search"), ("Back", "Back"), ("Forward", "Forward"),
               ("Stop", "Stop"), ("Refresh", "Refresh"), ("Sleep", "Sleep"),
               ("Favorites", "Favorites")]):
    add(f"Long_Long_Integer (To_C ({a}_Key))", "FL_" + c)
add("Long_Long_Integer (To_C (Function_Key (1)))", "FL_F + 1")
add("Long_Long_Integer (To_C (Function_Key (12)))", "FL_F + 12")
add("Long_Long_Integer (To_C (Function_Key (Function_Key_Number'Last)))", "FL_F_Last")

section("Options (Fl::Fl_Option)")
enum("Static.Option", [(f"Static.{a}", "Fl::OPTION_" + a.upper()) for a in
                       """Arrow_Focus Visible_Focus DND_Text Show_Tooltips FNFC_Uses_GTK
                       FNFC_Uses_Zenity FNFC_Uses_KDialog Printer_Uses_GTK Show_Scaling
                       Simple_Zoom_Shortcut""".split()])
add("Long_Long_Integer (Static.Option'Pos (Static.Option'Last) + 1)", "Fl::OPTION_LAST")

section("Shift keys held (Fl::event_state); Mod_Command is Ctrl, or Meta on macOS")
for a, c in [("None", "0"), ("Shift", "FL_SHIFT"), ("Caps_Lock", "FL_CAPS_LOCK"),
             ("Ctrl", "FL_CTRL"), ("Alt", "FL_ALT"), ("Num_Lock", "FL_NUM_LOCK"),
             ("Meta", "FL_META"), ("Scroll_Lock", "FL_SCROLL_LOCK"), ("Command", "FL_COMMAND")]:
    add(f"Long_Long_Integer (To_C (Mod_{a}))", c)

section("When a widget calls back (Fl_When)")
for a, c in [("Call_Never", "NEVER"), ("When_Changed", "CHANGED"),
             ("When_Interact", "NOT_CHANGED"), ("When_Release", "RELEASE"),
             ("When_Release_Always", "RELEASE_ALWAYS"), ("When_Enter_Key", "ENTER_KEY"),
             ("When_Enter_Key_Always", "ENTER_KEY_ALWAYS"), ("When_Closed", "CLOSED")]:
    add(f"Long_Long_Integer (Flag_To_UChar ({a}))", "FL_WHEN_" + c)

section("Menu item flags (Fl_Menu_Item::flags)")
for a, c in [("Normal", "0"), ("Inactive", "FL_MENU_INACTIVE"), ("Toggle", "FL_MENU_TOGGLE"),
             ("Value", "FL_MENU_VALUE"), ("Radio", "FL_MENU_RADIO"),
             ("Invisible", "FL_MENU_INVISIBLE"), ("Submenu", "FL_SUBMENU"),
             ("Divider", "FL_MENU_DIVIDER")]:
    add(f"Long_Long_Integer (MFlag_To_Cint (Flag_{a}))", c)

section("What needs redrawing (Fl_Damage)")
for a, c in [("None", "0"), ("Child", "CHILD"), ("Expose", "EXPOSE"), ("Scroll", "SCROLL"),
             ("Overlay", "OVERLAY"), ("User_1", "USER1"), ("User_2", "USER2"),
             ("Full", "ALL")]:
    add(f"Long_Long_Integer (Mask_To_UChar (Damage_{a}))", c if c == "0" else "FL_DAMAGE_" + c)

section("Contrast modes (fl_contrast_mode)")
enum("Contrast_Mode", [("No_Contrast", "FL_CONTRAST_NONE"), ("Legacy_Contrast", "FL_CONTRAST_LEGACY"),
                       ("CIELAB_Contrast", "FL_CONTRAST_CIELAB"),
                       ("Custom_Contrast", "FL_CONTRAST_CUSTOM")])

section("Callback reasons (Fl_Callback_Reason)")
for a in """Unknown Selected Deselected Reselected Opened Closed Dragged Cancelled Changed
            Got_Focus Lost_Focus Released Enter_Key User""".split():
    add(f"Long_Long_Integer (Reason_{a})", "FL_REASON_" + a.upper())

section("Screen scaling support (Fl::screen_scaling_supported); FLTK's enum is\n"
        "--  private to Fl_Screen_Driver, so these are its values (Fl_Screen_Driver.H:228-231)")
enum("Screen.Scaling_Kind", [("Screen.No_Scaling", "0"), ("Screen.Systemwide_Scaling", "1"),
                             ("Screen.Per_Screen_Scaling", "2")])

section("Arrow types (Fl_Arrow_Type); FLTK.Draw passes Pos + 1")
for a in "Single Double Choice Return".split():
    add(f"Long_Long_Integer (Draw.Arrow_Kind'Pos (Draw.{a}_Arrow) + 1)", "FL_ARROW_" + a.upper())

section("Orientations (Fl_Orientation)")
enum("Draw.Orientation_Kind", [(f"Draw.Orient_{a}", "FL_ORIENT_" + a.upper())
                               for a in "Right NE Up NW Left SW Down SE".split()])

section("File icons (Fl_File_Icon)")
enum("Images.File_Icons.File_Kind",
     [(f"Images.File_Icons.{a}_File", "Fl_File_Icon::" + c) for a, c in
      [("Any", "ANY"), ("Plain", "PLAIN"), ("Fifo", "FIFO"), ("Device", "DEVICE"),
       ("Link", "LINK"), ("Directory", "DIRECTORY")]])
add("Long_Long_Integer (Images.File_Icons.Icon_Color)", "FL_ICON_COLOR")

section("Tab overflow (Fl_Tabs::handle_overflow)")
enum("Tabbed.Overflow_Kind",
     [(f"Tabbed.{a}_Overflow", "Fl_Tabs::OVERFLOW_" + a.upper())
      for a in "Compress Clip Pulldown Drag".split()])

section("Window menu styles (Fl_Sys_Menu_Bar::window_menu_style_enum)")
enum("Sys_Menu.Window_Menu_Style_Kind",
     [(f"Sys_Menu.{a}", "Fl_Sys_Menu_Bar::" + a.lower())
      for a in "No_Window_Menu Tabbing_Mode_None Tabbing_Mode_Automatic Tabbing_Mode_Preferred"
      .split()])

section("Clock faces (Fl_Clock_Output::type)")
enum("Clocks.Clock_Kind", [("Clocks.Square_Face", "FL_SQUARE_CLOCK"),
                           ("Clocks.Round_Face", "FL_ROUND_CLOCK")])

section("Roller kinds (Fl_Roller::type)")
enum("Rollers.Roller_Kind", [("Rollers.Vertical_Roller", "FL_VERTICAL"),
                             ("Rollers.Horizontal_Roller", "FL_HORIZONTAL")])

section("Browser kinds (Fl_Browser_::type)")
enum("Browsers.Browser_Kind", [(f"Browsers.{a}_Kind", f"FL_{a.upper()}_BROWSER")
                               for a in "Normal Select Hold Multi".split()])

section("Scroll kinds (Fl_Scroll::type)")
enum("Scrolls.Scroll_Kind", [("Scrolls.Neither", "0")] +
     [(f"Scrolls.{a}", f"Fl_Scroll::{a.upper()}")
      for a in "Horizontal Vertical Both Always_On Horizontal_Always Vertical_Always "
               "Both_Always".split()])

section("Button kinds (Fl_Button::type); a representation clause gives FLTK's values")
for a, c in [("Normal", "NORMAL"), ("Toggle", "TOGGLE"), ("Hidden", "HIDDEN"), ("Radio", "RADIO")]:
    add(f"Long_Long_Integer (Buttons.Button_Kind'Enum_Rep (Buttons.{a}_Kind))",
        f"FL_{c}_BUTTON")


HEADER = """{c}  Programmed by T. Kurt Bond and Claude Opus 5.5
{c}  Released into the public domain
{c}  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
{c}  author releases this derived work into the public domain, as FLTKAda is.
{c}
{c}  Written by tools/gen-constants.py; edit that, not this.
"""


def write(path, text):
    with open(os.path.join(ROOT, path), "w") as f:
        f.write(text)


class Suite:
    """One generated test: the checks, the files and the names it uses."""

    def __init__(self, checks, directory, prefix, unit, includes, withs, renames):
        self.checks = checks
        self.directory = directory
        self.symbol = f"c_{prefix}constants"
        self.unit = unit
        self.includes = includes
        self.withs = withs
        self.renames = renames


def cpp(suite):
    out = [HEADER.format(c="//"), "",
           f"//  FLTK's value of each constant the Ada test, {suite.unit.lower().replace('.', '-')}.adb,",
           "//  checks, in the same order.", "", ""]
    out += [f"#include <FL/{h}>" if h.endswith(".H") else f"#include <{h}>"
            for h in suite.includes]
    out += ["", "",
           f'extern "C" const long long {suite.symbol}[];', "",
           f'extern "C" const long long {suite.symbol}[] =', "{"]
    for item in suite.checks:
        if isinstance(item, str):
            out.append("    //  " + item.replace("\n--  ", "\n    //  "))
        else:
            out.append(f"    {item[1]},")
    out[-1] = out[-1].rstrip(",")
    out += ["};", ""]
    write(f"{suite.directory}/{suite.symbol}.cpp", "\n".join(out))


def ada(suite):
    count = sum(1 for item in suite.checks if not isinstance(item, str))
    out = [HEADER.format(c="--"), "",
           "--  Checks each of FLTKAda's constants against FLTK's value, from",
           f"--  {suite.symbol}.cpp.  A child of FLTK, so it can see the private",
           f"--  conversions.  Run by {suite.unit[5:].lower()}.adb.", "", "",
           "with", "", "    Checks,"]
    out += [f"    {w}," for w in suite.withs]
    out[-1] = out[-1].rstrip(",") + ";"
    out += ["", "", f"procedure {suite.unit} is", "", ""]
    out += [f"    package {a} renames {b};" for a, b in suite.renames]
    out += ["", "",
           f"    type Value_Array is array (1 .. {count}) of Long_Long_Integer;",
           "    pragma Convention (C, Value_Array);", "",
           "    FLTK_Values : Value_Array;",
           f'    pragma Import (C, FLTK_Values, "{suite.symbol}");', "", "",
           "    procedure Same",
           "           (Ada_Value : in Long_Long_Integer;",
           "            Index     : in Positive;",
           "            Label     : in String)",
           "    is",
           "        FLTK_Value : constant Long_Long_Integer := FLTK_Values (Index);",
           "    begin",
           "        if Ada_Value = FLTK_Value then",
           "            Checks.Check (True, Label & \" =\" & Long_Long_Integer'Image (FLTK_Value));",
           "        else",
           "            Checks.Check",
           "               (False, Label & \": FLTKAda has\" & Long_Long_Integer'Image (Ada_Value) &",
           "                \", FLTK\" & Long_Long_Integer'Image (FLTK_Value));",
           "        end if;",
           "    end Same;", "", "",
           "begin", ""]
    index = 0
    for item in suite.checks:
        if isinstance(item, str):
            if index > 0:
                out.append("")
            out.append("    --  " + item.replace("\n--  ", "\n    --  "))
        else:
            index += 1
            ada_expr, c_expr = item
            call = f'    Same ({ada_expr}, {index}, "{ada_expr} = {c_expr}");'
            if len(call) > 99:
                label = f'        "{ada_expr} = {c_expr}");'
                if len(label) > 100:
                    label = f'        "{ada_expr}" &\n        " = {c_expr}");'
                call = f"    Same\n       ({ada_expr},\n        {index},\n{label}"
            out.append(call)
    out += ["", f"end {suite.unit};", ""]
    write(f"{suite.directory}/{suite.unit.lower().replace('.', '-')}.adb", "\n".join(out))


MAIN = Suite(
    CHECKS, "test/unit", "", "FLTK.Test_Constants",
    ["Enumerations.H", "Fl.H", "Fl_Button.H", "Fl_Clock.H", "Fl_File_Icon.H", "Fl_Menu_Item.H",
     "Fl_Sys_Menu_Bar.H", "Fl_Tabs.H", "Fl_Roller.H", "Fl_Browser_.H", "Fl_Scroll.H"],
    ["FLTK.Draw", "FLTK.Images.File_Icons", "FLTK.Screen", "FLTK.Static", "FLTK.Widgets.Buttons",
     "FLTK.Widgets.Clocks", "FLTK.Widgets.Groups.Tabbed", "FLTK.Widgets.Menus.Menu_Bars.Systemwide",
     "FLTK.Widgets.Valuators.Rollers", "FLTK.Widgets.Groups.Browsers",
     "FLTK.Widgets.Groups.Scrolls"],
    [("Buttons", "FLTK.Widgets.Buttons"), ("Clocks", "FLTK.Widgets.Clocks"),
     ("Tabbed", "FLTK.Widgets.Groups.Tabbed"),
     ("Sys_Menu", "FLTK.Widgets.Menus.Menu_Bars.Systemwide"),
     ("Rollers", "FLTK.Widgets.Valuators.Rollers"), ("Browsers", "FLTK.Widgets.Groups.Browsers"),
     ("Scrolls", "FLTK.Widgets.Groups.Scrolls")])


#  The Forms library's constants, checked by a test of their own, which is
#  built only with that library (tests_forms.gpr).
FORMS_CHECKS = []
CHECKS = FORMS_CHECKS

section("Timer kinds (Fl_Timer::type)")
enum("Timers.Timer_Kind", [("Timers.Normal_Timer", "FL_NORMAL_TIMER"),
                           ("Timers.Value_Timer", "FL_VALUE_TIMER"),
                           ("Timers.Hidden_Timer", "FL_HIDDEN_TIMER")])

section("Free kinds (Fl_Free::type); a representation clause gives FLTK's values")
for a in "Normal Sleeping Input Continuous All".split():
    add(f"Long_Long_Integer (Frees.Free_Kind'Enum_Rep (Frees.{a}_Free))",
        f"FL_{a.upper()}_FREE")

FORMS = Suite(
    FORMS_CHECKS, "test/unit/forms", "forms_", "FLTK.Test_Forms_Constants",
    ["Fl_Free.H", "Fl_Timer.H"],
    ["FLTK.Widgets.Forms.Frees", "FLTK.Widgets.Forms.Timers"],
    [("Frees", "FLTK.Widgets.Forms.Frees"), ("Timers", "FLTK.Widgets.Forms.Timers")])


#  The Cairo library's constants: cairo's, not FLTK's, which FLTK.Cairo
#  passes as each enumerator's position.  Built only with that library
#  (tests_cairo.gpr).
CAIRO_CHECKS = []
CHECKS = CAIRO_CHECKS

section("Font slants (cairo_font_slant_t)")
enum("Cairo.Font_Slant", [(f"Cairo.{a}_Slant", f"CAIRO_FONT_SLANT_{a.upper()}")
                          for a in "Normal Italic Oblique".split()])

section("Font weights (cairo_font_weight_t)")
enum("Cairo.Font_Weight", [(f"Cairo.{a}_Weight", f"CAIRO_FONT_WEIGHT_{a.upper()}")
                           for a in "Normal Bold".split()])

section("Antialiasing (cairo_antialias_t)")
enum("Cairo.Antialias_Mode",
     [(f"Cairo.{'No' if a == 'None' else a}_Antialias", f"CAIRO_ANTIALIAS_{a.upper()}")
      for a in "Default None Gray Subpixel Fast Good Best".split()])

section("Pattern extends (cairo_extend_t)")
enum("Cairo.Extend_Mode",
     [(f"Cairo.{'No' if a == 'None' else a}_Extend", f"CAIRO_EXTEND_{a.upper()}")
      for a in "None Repeat Reflect Pad".split()])

CAIRO = Suite(
    CAIRO_CHECKS, "test/unit/cairo", "cairo_", "FLTK.Test_Cairo_Constants",
    ["cairo.h"],
    ["FLTK.Cairo"],
    [("Cairo", "FLTK.Cairo")])


#  The GLU library's constants, which the C++ side has as GLU_*.  Its
#  enumerations have representation clauses, so the checks use 'Enum_Rep.
#  Built only with that library (tests_glu.gpr).
GLU_CHECKS = []
CHECKS = GLU_CHECKS


def enum_rep(typ, pairs):
    for ada, c in pairs:
        add(f"Long_Long_Integer ({typ}'Enum_Rep ({ada}))", c)


section("Quadric draw styles (gluQuadricDrawStyle)")
enum_rep("GLU.Draw_Style", [(f"GLU.{a}", f"GLU_{a.upper()}")
                            for a in "Point Line Fill Silhouette".split()])

section("Quadric normals (gluQuadricNormals)")
enum_rep("GLU.Normal_Kind", [("GLU.Smooth_Normals", "GLU_SMOOTH"),
                             ("GLU.Flat_Normals", "GLU_FLAT"),
                             ("GLU.No_Normals", "GLU_NONE")])

section("Quadric orientations (gluQuadricOrientation)")
enum_rep("GLU.Orientation", [("GLU.Outside", "GLU_OUTSIDE"),
                             ("GLU.Inside", "GLU_INSIDE")])

GLU = Suite(
    GLU_CHECKS, "test/unit/glu", "glu_", "FLTK.Test_GLU_Constants",
    ["GL/glu.h"],
    ["FLTK.GLU"],
    [("GLU", "FLTK.GLU")])


for suite in (MAIN, FORMS, CAIRO, GLU):
    cpp(suite)
    ada(suite)
