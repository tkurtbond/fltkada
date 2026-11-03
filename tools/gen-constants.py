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
# test/unit/test_constants.adb, written by hand, runs it.  The C++ is
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
enum("Font_Kind", upper("""Helvetica Helvetica_Bold Helvetica_Italic
Helvetica_Bold_Italic Courier Courier_Bold Courier_Italic Courier_Bold_Italic
Times Times_Bold Times_Italic Times_Bold_Italic Symbol""")
     + [("Monospace", "FL_SCREEN"), ("Monospace_Bold", "FL_SCREEN_BOLD"),
        ("Zapf_Dingbats", "FL_ZAPF_DINGBATS"), ("Free_Font", "FL_FREE_FONT")])
add("Long_Long_Integer (Normal_Size)", "FL_NORMAL_SIZE")

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
for a, c in [("Enter", "Enter"), ("Keypad_Enter", "KP_Enter"), ("Backspace", "BackSpace"),
             ("Insert", "Insert"), ("Delete", "Delete"), ("Home", "Home"), ("End", "End"),
             ("Page_Down", "Page_Down"), ("Page_Up", "Page_Up"), ("Down", "Down"),
             ("Left", "Left"), ("Right", "Right"), ("Up", "Up"), ("Escape", "Escape"),
             ("Tab", "Tab")]:
    add(f"Long_Long_Integer (To_C ({a}_Key))", "FL_" + c)

section("Shift keys held (Fl::event_state); Mod_Command is Ctrl, or Meta on macOS")
for a, c in [("None", "0"), ("Shift", "FL_SHIFT"), ("Caps_Lock", "FL_CAPS_LOCK"),
             ("Ctrl", "FL_CTRL"), ("Alt", "FL_ALT"), ("Num_Lock", "FL_NUM_LOCK"),
             ("Meta", "FL_META"), ("Scroll_Lock", "FL_SCROLL_LOCK"), ("Command", "FL_COMMAND")]:
    add(f"Long_Long_Integer (To_C (Mod_{a}))", c)

section("When a widget calls back (Fl_When)")
for a, c in [("Call_Never", "NEVER"), ("When_Changed", "CHANGED"),
             ("When_Interact", "NOT_CHANGED"), ("When_Release", "RELEASE"),
             ("When_Release_Always", "RELEASE_ALWAYS"), ("When_Enter_Key", "ENTER_KEY"),
             ("When_Enter_Key_Always", "ENTER_KEY_ALWAYS")]:
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


def cpp():
    out = [HEADER.format(c="//"), "",
           "//  FLTK's value of each constant the Ada test, fltk-test_constants.adb,",
           "//  checks, in the same order.", "", "",
           "#include <FL/Enumerations.H>", "#include <FL/Fl_Menu_Item.H>", "", "",
           'extern "C" const long long c_constants[];', "",
           'extern "C" const long long c_constants[] =', "{"]
    for item in CHECKS:
        if isinstance(item, str):
            out.append("    //  " + item.replace("\n--  ", "\n    //  "))
        else:
            out.append(f"    {item[1]},")
    out[-1] = out[-1].rstrip(",")
    out += ["};", ""]
    write("test/unit/c_constants.cpp", "\n".join(out))


def ada():
    count = sum(1 for item in CHECKS if not isinstance(item, str))
    out = [HEADER.format(c="--"), "",
           "--  Checks each of FLTKAda's constants against FLTK's value, from",
           "--  c_constants.cpp.  A child of FLTK, so it can see the private",
           "--  conversions.  Run by test_constants.adb.", "", "",
           "with", "", "    Checks;", "", "",
           "procedure FLTK.Test_Constants is", "", "",
           f"    type Value_Array is array (1 .. {count}) of Long_Long_Integer;",
           "    pragma Convention (C, Value_Array);", "",
           "    FLTK_Values : Value_Array;",
           '    pragma Import (C, FLTK_Values, "c_constants");', "", "",
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
    for item in CHECKS:
        if isinstance(item, str):
            if index > 0:
                out.append("")
            out.append("    --  " + item.replace("\n--  ", "\n    --  "))
        else:
            index += 1
            ada_expr, c_expr = item
            call = f'    Same ({ada_expr}, {index}, "{ada_expr} = {c_expr}");'
            if len(call) > 99:
                call = (f"    Same\n       ({ada_expr},\n        {index},\n"
                        f'        "{ada_expr} = {c_expr}");')
            out.append(call)
    out += ["", "end FLTK.Test_Constants;", ""]
    write("test/unit/fltk-test_constants.adb", "\n".join(out))


cpp()
ada()
