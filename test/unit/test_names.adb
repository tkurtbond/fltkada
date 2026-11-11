--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  PLAN.md, Phase 20:  FL/names.h's names for events, fonts and callback
--  reasons, after pofltk's checks in test/TestEvents.Mod.


with

    Checks,
    FLTK;

use

    Checks,
    FLTK;


procedure Test_Names is
begin

    Check (Event_Name (Push) = "FL_PUSH", "Event_Name of Push: " & Event_Name (Push));
    Check (Event_Name (No_Event) = "FL_NO_EVENT", "Event_Name of No_Event");
    Check (Event_Name (Zoom_Event) = "FL_ZOOM_EVENT",
        "Event_Name of the last event: " & Event_Name (Zoom_Event));
    for E in Event_Kind loop
        Check (Event_Name (E)'Length > 3 and then Event_Name (E) (1 .. 3) = "FL_",
            "every event has a name: " & Event_Name (E));
    end loop;

    Check (Font_Constant_Name (Courier) = "FL_COURIER", "Font_Constant_Name of Courier");
    Check (Font_Constant_Name (Monospace) = "FL_SCREEN",
        "Font_Constant_Name of Monospace is C++'s name, FL_SCREEN");
    Check (Font_Constant_Name (Zapf_Dingbats) = "FL_ZAPF_DINGBATS",
        "Font_Constant_Name of Zapf_Dingbats");
    Check (Font_Constant_Name (Free_Font) = "",
        "Font_Constant_Name past Zapf_Dingbats is empty");
    Check (Font_Constant_Name (Font_Kind'Last) = "", "Font_Constant_Name of Font_Kind'Last");

    Check (Reason_Name (Reason_Unknown) = "FL_REASON_UNKNOWN", "Reason_Name of Reason_Unknown");
    Check (Reason_Name (Reason_Enter_Key) = "FL_REASON_ENTER_KEY",
        "Reason_Name of Reason_Enter_Key");
    Check (Reason_Name (Reason_Enter_Key + 1) = "", "Reason_Name of an unused reason is empty");
    Check (Reason_Name (Reason_User) = "FL_REASON_USER", "Reason_Name of Reason_User");
    Check (Reason_Name (Reason_User + 3) = "FL_REASON_USER+3", "Reason_Name of Reason_User + 3");
    Check (Reason_Name (Reason_User + 4) = "", "Reason_Name past Reason_User + 3 is empty");
    Check (Reason_Name (Callback_Reason'Last) = "", "Reason_Name of Callback_Reason'Last");

    Summary;

end Test_Names;
