

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  FLTK's test/preferences.fl: a morning's preferences, kept between
--  runs in the user's preferences database (FLTK.Environment, FLTK's
--  Fl_Preferences).  OK writes them and closes the window, Cancel closes
--  it alone.  The texts are English or German, from a small table that
--  stands in for GNU gettext as FLTK's program does; the language is read
--  before the window is made, so a change of it shows at the next start,
--  and it translates an input's Cut, Copy and Paste menu too.  On
--  starting, it prints where the preferences file is.
--
--  The "memory mapped" case can't arise for a user database, and
--  File_Name gives "" for it as for an unknown root.  FLTK's program
--  deletes the window with Fl::delete_widget; here it is hidden, which
--  ends Run the same way.  FLTK's commented-out sample code for binary
--  data is left out.  Guided by pofltk's Preferences.Mod.


with

    Ada.Strings.Unbounded,
    Ada.Text_IO,
    FLTK.Asks,
    FLTK.Environment,
    FLTK.Widgets.Boxes,
    FLTK.Widgets.Buttons.Light.Check,
    FLTK.Widgets.Buttons.Light.Round,
    FLTK.Widgets.Groups.Windows.Double,
    FLTK.Widgets.Inputs.Text.Whole_Number,
    FLTK.Widgets.Menus.Choices,
    FLTK.Widgets.Valuators.Sliders.Value.Horizontal;


function Preferences
    return Integer
is

    package SU  renames Ada.Strings.Unbounded;
    package Env renames FLTK.Environment;
    package Bx  renames FLTK.Widgets.Boxes;
    package Btn renames FLTK.Widgets.Buttons;
    package Chk renames FLTK.Widgets.Buttons.Light.Check;
    package Rnd renames FLTK.Widgets.Buttons.Light.Round;
    package Grp renames FLTK.Widgets.Groups;
    package Dbl renames FLTK.Widgets.Groups.Windows.Double;
    package Inp renames FLTK.Widgets.Inputs.Text;
    package Int renames FLTK.Widgets.Inputs.Text.Whole_Number;
    package Chc renames FLTK.Widgets.Menus.Choices;
    package Sld renames FLTK.Widgets.Valuators.Sliders.Value.Horizontal;

    use type SU.Unbounded_String;


    Project     : constant String := "fltk.org";
    Application : constant String := "test/preferences";


    --  The current language: 0 English, 1 German.
    subtype Language_Number is Natural range 0 .. 1;

    function Read_Language
        return Language_Number;

    --  The language setting, read before the window is made.
    function Read_Language
        return Language_Number
    is
        App_Db : constant Env.Database := Env.Forge.From_Scope (Env.User, Project, Application);
        App    : constant Env.Pref_Group'Class := Env.Forge.Root (App_Db);
        Number : constant Integer := App.Get ("language", 0);
    begin
        --  FLTK's program indexes its table with any number found.
        if Number in Language_Number then
            return Number;
        else
            return 0;
        end if;
    end Read_Language;

    Language : constant Language_Number := Read_Language;


    function "+"
           (Item : in String)
        return SU.Unbounded_String
    renames SU.To_Unbounded_String;

    type Translation is array (Language_Number) of SU.Unbounded_String;

    Table : constant array (Positive range <>) of Translation :=
       ((+"Alarm at:", +"Wecken um:"),
        (+"Bread:", +"Brot:"),
        (+"Breakfast:", +"Frühstück:"),
        (+"Cancel", +"Abbrechen"),
        (+"Copy", +"Kopieren"),
        (+"Cut", +"Ausschneiden"),
        (+"Drink:", +"Getränk:"),
        (+"English", +"Englisch"),
        (+"German", +"Deutsch"),
        (+"Get Up:", +"Aufstehen:"),
        (+"Language:", +"Sprache:"),
        (+"My Preferences", +"Meine Vorlieben"),
        (+"NY Times", +"Der Spiegel"),
        (+"Newspaper:", +"Tageszeitung:"),
        (+"OK", +"OK"),
        (+"Paste", +"Einfügen"),
        (+"Please restart the app to use your new language setting.",
         +"Bitte starten Sie die App erneut um Ihre Spracheinstellung zu nutzen."),
        (+"Wear:", +"Schuhwerk:"),
        (+"a.m.", +"früh"),
        (+"bare foot", +"barfuß"),
        (+"brush teeth", +"Zähne putzen"),
        (+"coffee", +"Kaffee"),
        (+"eggs", +"Eier"),
        (+"flip flops", +"Schlappen"),
        (+"juice", +"Saft"),
        (+"left side", +"linke Seite"),
        (+"min.", +"Min."),
        (+"of the bed", +"vom Bett"),
        (+"p.m.", +"spät"),
        (+"right side", +"rechte Seite"),
        (+"rye", +"Roggen"),
        (+"sandals", +"Sandalen"),
        (+"shave", +"rasieren"),
        (+"shoes", +"Schuhe"),
        (+"shower", +"duschen"),
        (+"sourdough", +"Sauerteig"),
        (+"tea", +"Tee"),
        (+"wheat", +"Weizen"),
        (+"white", +"Weißbrot"),
        (+"with butter", +"mit Butter"),
        (+"with milk", +"mit Milch"));

    --  Text in the current language, or as it is if the table doesn't
    --  have it: a minimal gettext.
    function Tr
           (Text : in String)
        return String is
    begin
        for Pair of Table loop
            if Pair (0) = Text then
                return SU.To_String (Pair (Language));
            end if;
        end loop;
        return Text;
    end Tr;


    --  A Choice with FLUID's settings, its label and items translated.
    function Make_Choice
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String;
            Items      : in     String)
        return Chc.Choice
    is
        Item_First : Positive := Items'First;
    begin
        return This : Chc.Choice := Chc.Forge.Create (Parent, X, Y, W, H, Tr (Text)) do
            This.Set_Down_Box (FLTK.Border_Box);
            for Place in Items'Range loop
                if Items (Place) = '|' then
                    This.Add (Tr (Items (Item_First .. Place - 1)));
                    Item_First := Place + 1;
                end if;
            end loop;
            This.Add (Tr (Items (Item_First .. Items'Last)));
        end return;
    end Make_Choice;

    function Make_Check
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String)
        return Chk.Check_Button is
    begin
        return This : Chk.Check_Button := Chk.Forge.Create (Parent, X, Y, W, H, Tr (Text)) do
            This.Set_Down_Box (FLTK.Down_Box);
        end return;
    end Make_Check;

    function Make_Round
           (Parent     : in out Grp.Group'Class;
            X, Y, W, H : in     Integer;
            Text       : in     String)
        return Rnd.Round_Button is
    begin
        return This : Rnd.Round_Button := Rnd.Forge.Create (Parent, X, Y, W, H, Tr (Text)) do
            This.Set_Kind (Btn.Radio_Kind);
            This.Set_Down_Box (FLTK.Round_Down_Box);
        end return;
    end Make_Round;


    My_Window : Dbl.Double_Window := Dbl.Forge.Create (322, 355, Tr ("My Preferences"));

    Cancel : Btn.Button := Btn.Forge.Create (My_Window, 118, 316, 90, 24, Tr ("Cancel"));
    OK     : Btn.Button := Btn.Forge.Create (My_Window, 217, 316, 90, 24, Tr ("OK"));

    Get_Up  : Grp.Group := Grp.Forge.Create (My_Window, 15, 22, 144, 248, Tr ("Get Up:"));
    W_Alarm : Inp.Text_Input := Inp.Forge.Create (Get_Up, 25, 47, 60, 20, Tr ("Alarm at:"));
    W_Am_Pm : Chc.Choice := Make_Choice (Get_Up, 85, 47, 60, 20, "", "a.m.|p.m.");
    W_Wear  : Chc.Choice := Make_Choice
       (Get_Up, 25, 92, 120, 20, "Wear:", "shoes|sandals|flip flops|bare foot");

    Side    : Grp.Group := Grp.Forge.Create (Get_Up, 25, 112, 120, 76);
    W_Left  : Rnd.Round_Button := Make_Round (Side, 35, 112, 100, 24, "left side");
    W_Right : Rnd.Round_Button := Make_Round (Side, 35, 136, 100, 24, "right side");
    Of_Bed  : Bx.Box := Bx.Forge.Create (Side, 35, 160, 100, 24, Tr ("of the bed"));

    W_Shower : Chk.Check_Button := Make_Check (Get_Up, 25, 188, 105, 24, "shower");
    W_Shave  : Chk.Check_Button := Make_Check (Get_Up, 25, 212, 105, 24, "shave");
    W_Brush  : Chk.Check_Button := Make_Check (Get_Up, 25, 236, 105, 24, "brush teeth");

    Breakfast : Grp.Group := Grp.Forge.Create (My_Window, 163, 22, 144, 248, Tr ("Breakfast:"));
    W_Drink   : Chc.Choice := Make_Choice
       (Breakfast, 173, 48, 120, 20, "Drink:", "coffee|tea|juice");
    W_Milk    : Chk.Check_Button := Make_Check (Breakfast, 173, 68, 100, 24, "with milk");
    W_Bread   : Chc.Choice := Make_Choice
       (Breakfast, 173, 116, 120, 20, "Bread:", "wheat|white|rye|sourdough");
    W_Butter  : Chk.Check_Button := Make_Check (Breakfast, 173, 136, 100, 24, "with butter");
    W_Eggs    : Int.Integer_Input := Int.Forge.Create (Breakfast, 173, 168, 30, 20, Tr ("eggs"));
    W_Minutes : Sld.Horizontal_Value_Slider := Sld.Forge.Create
       (Breakfast, 173, 196, 70, 20, Tr ("min."));
    W_Paper   : Inp.Text_Input := Inp.Forge.Create
       (Breakfast, 173, 239, 120, 20, Tr ("Newspaper:"));

    W_Language : Chc.Choice := Make_Choice
       (My_Window, 185, 283, 105, 20, "Language:", "English|German");

    pragma Unreferenced (Of_Bed);


    procedure Put_Line
           (Text : in String) is
    begin
        Ada.Text_IO.Put_Line (Text);
        Ada.Text_IO.Flush;
    end Put_Line;


    procedure Read_Prefs is
        Future : constant String := Env.File_Name (Env.User, Project, Application);
        App_Db : constant Env.Database := Env.Forge.From_Scope (Env.User, Project, Application);
        App    : constant Env.Pref_Group'Class := Env.Forge.Root (App_Db);
        Actual : constant String := Env.File_Name (App_Db);
    begin
        if Future = "" then
            Put_Line ("Location of future Preferences file not found.");
        else
            Put_Line ("Preferences file will be located at:");
            Put_Line (Future);
        end if;
        if Actual = "" then
            Put_Line ("Location of app Preferences file not found.");
        else
            Put_Line ("App Preferences file is actually located at:");
            Put_Line (Actual);
        end if;
        begin
            Put_Line ("Preferences user data directory is located at:");
            Put_Line (Env.Userdata_Path (App_Db));
        exception
        when Env.Preference_Error =>
            Put_Line ("Location of Preferences user data directory not found.");
        end;

        W_Language.Set_Chosen (Language + 1);

        declare
            Bed   : constant Env.Pref_Group'Class :=
                Env.Forge.By_Name (Env.Pref_Group (App), "Bed");
            Place : constant Integer := Bed.Get ("side", 2);
            Tasks : constant Integer := Bed.Get ("taskFlags", 16#05#);
        begin
            W_Alarm.Set_Value (Bed.Get ("alarm", "8:00", 78));
            W_Am_Pm.Set_Chosen (Bed.Get ("ampm", 0) + 1);
            W_Wear.Set_Chosen (Bed.Get ("wear", 1) + 1);
            if Place = 1 then
                W_Left.Set_State (Btn.On);
            end if;
            if Place = 2 then
                W_Right.Set_State (Btn.On);
            end if;
            if Tasks mod 2 = 1 then
                W_Shower.Set_State (Btn.On);
            end if;
            if Tasks / 2 mod 2 = 1 then
                W_Shave.Set_State (Btn.On);
            end if;
            if Tasks / 4 mod 2 = 1 then
                W_Brush.Set_State (Btn.On);
            end if;
        end;

        declare
            Eat  : constant Env.Pref_Group'Class :=
                Env.Forge.By_Name (Env.Pref_Group (App), "Breakfast");
            Eggs : constant String := Integer'Image (Eat.Get ("nEggs", 2));
        begin
            W_Drink.Set_Chosen (Eat.Get ("drink", 1) + 1);
            W_Milk.Set_State (if Eat.Get ("wMilk", 0) /= 0 then Btn.On else Btn.Off);
            W_Bread.Set_Chosen (Eat.Get ("bread", 0) + 1);
            W_Butter.Set_State (if Eat.Get ("wButter", 1) /= 0 then Btn.On else Btn.Off);
            if Eggs (Eggs'First) = ' ' then
                W_Eggs.Set_Value (Eggs (Eggs'First + 1 .. Eggs'Last));
            else
                W_Eggs.Set_Value (Eggs);
            end if;
            W_Minutes.Set_Value (Eat.Get ("minutes", Long_Float'(3.2)));
            W_Paper.Set_Value (Eat.Get ("newspaper", Tr ("NY Times")));
            declare
                Foo : constant String := Eat.Get ("foo", "bar", 79);
                pragma Unreferenced (Foo);
            begin
                null;
            end;
        end;
    end Read_Prefs;


    procedure Write_Prefs is
        App_Db : constant Env.Database := Env.Forge.From_Scope (Env.User, Project, Application);
        App    : Env.Pref_Group'Class := Env.Forge.Root (App_Db);
        Bed    : Env.Pref_Group'Class := Env.Forge.By_Name (Env.Pref_Group (App), "Bed");
        Eat    : Env.Pref_Group'Class := Env.Forge.By_Name (Env.Pref_Group (App), "Breakfast");
        Side   : Integer := 0;
        Tasks  : Integer := 0;
        Sum    : Natural := 0;

        procedure Found
               (Group : in Env.Pref_Group'Class;
                Name  : in String) is
        begin
            if Group.Group_Exists (Name) then
                Sum := Sum + 1;
            end if;
        end Found;
    begin
        App.Set ("language", W_Language.Chosen_Index - 1);

        Bed.Set ("alarm", W_Alarm.Get_Value);
        Bed.Set ("ampm", W_Am_Pm.Chosen_Index - 1);
        Bed.Set ("wear", W_Wear.Chosen_Index - 1);
        if W_Left.Is_On then
            Side := 1;
        end if;
        if W_Right.Is_On then
            Side := 2;
        end if;
        Bed.Set ("side", Side);
        if W_Shower.Is_On then
            Tasks := Tasks + 16#01#;
        end if;
        if W_Shave.Is_On then
            Tasks := Tasks + 16#02#;
        end if;
        if W_Brush.Is_On then
            Tasks := Tasks + 16#04#;
        end if;
        Bed.Set ("taskFlags", Tasks);

        Eat.Set ("drink", W_Drink.Chosen_Index - 1);
        Eat.Set ("wMilk", Boolean'Pos (W_Milk.Is_On));
        Eat.Set ("bread", W_Bread.Chosen_Index - 1);
        Eat.Set ("wButter", Boolean'Pos (W_Butter.Is_On));
        Eat.Set ("nEggs", W_Eggs.Get_Value);
        Eat.Set ("minutes", W_Minutes.Get_Value);
        Eat.Set ("newspaper", W_Paper.Get_Value);
        Eat.Set ("foo", "bar" & ASCII.LF & "fly" & ASCII.CR & "Backslash: \ and bell: " &
            ASCII.BEL & " and delete: " & ASCII.DEL & ASCII.LF);
        Eat.Set ("3", "Test3");  --  Fl_Preferences::Name (3)

        --  A group in a group.
        declare
            Eat_More : Env.Pref_Group'Class := Env.Forge.By_Name (Env.Pref_Group (Eat), "More");
        begin
            Eat_More.Set ("more", "stuff");
        end;

        --  Each of these is found.
        Found (App, "Breakfast");         --  eat, from app
        Found (App, "Breakfast/More");    --  eatMore, from app
        Found (App, "./Breakfast/More");  --  eatMore, from the database
        Found (Eat, "More");              --  eatMore, from eat
        Found (Eat, "./Breakfast/More");  --  eatMore, from the database
        Found (Eat, ".");                 --  eat itself
        Found (Eat, "./");                --  the database, app
        if Sum /= 7 then
            FLTK.Asks.Message_Box ("Assertion failed:" & ASCII.LF &
                "Not all group entries were found!");
        end if;
    end Write_Prefs;


    procedure Close_Window
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        My_Window.Hide;
    end Close_Window;

    procedure Save_And_Close_Window
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        Write_Prefs;
        My_Window.Hide;
    end Save_And_Close_Window;

    procedure Language_Changed
           (Item : in out FLTK.Widgets.Widget'Class)
    is
        pragma Unreferenced (Item);
    begin
        FLTK.Asks.Message_Box (Tr ("Please restart the app to use your new language setting."));
    end Language_Changed;


begin

    Inp.Set_Cut_Menu_Text (Tr ("Cut"));
    Inp.Set_Copy_Menu_Text (Tr ("Copy"));
    Inp.Set_Paste_Menu_Text (Tr ("Paste"));

    My_Window.Set_Callback (Close_Window'Unrestricted_Access);
    Cancel.Set_Callback (Close_Window'Unrestricted_Access);
    OK.Set_Callback (Save_And_Close_Window'Unrestricted_Access);

    Get_Up.Set_Box (FLTK.Engraved_Frame);
    Get_Up.Set_Alignment (FLTK.Align_Top_Left);
    W_Alarm.Set_Alignment (FLTK.Align_Top_Left);
    W_Wear.Set_Alignment (FLTK.Align_Top_Left);

    Breakfast.Set_Box (FLTK.Engraved_Frame);
    Breakfast.Set_Alignment (FLTK.Align_Top_Left);
    W_Drink.Set_Alignment (FLTK.Align_Top_Left);
    W_Bread.Set_Alignment (FLTK.Align_Top_Left);
    W_Eggs.Set_Alignment (FLTK.Align_Right);
    W_Minutes.Set_Minimum (2.0);
    W_Minutes.Set_Maximum (6.0);
    W_Minutes.Set_Value (3.1);
    W_Minutes.Set_Alignment (FLTK.Align_Right);
    W_Paper.Set_Alignment (FLTK.Align_Top_Left);

    W_Language.Set_Callback (Language_Changed'Unrestricted_Access);

    My_Window.End_Current;

    Read_Prefs;

    My_Window.Show_With_Args;

    return FLTK.Run;

end Preferences;

