

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Containers.Vectors;

private with

    Interfaces.C;


package FLTK.Widgets.Groups.Text_Displays.Text_Editors is


    type Text_Editor is new Text_Display with private;

    type Text_Editor_Reference (Data : not null access Text_Editor'Class) is
        limited null record with Implicit_Dereference => Data;

    type Insert_Mode is (Before, After);

    type Tab_Navigation is (Insert_Char, Widget_Focus);

    type Key_Func is access procedure
           (This : in out Text_Editor'Class);

    type Default_Key_Func is access procedure
           (This : in out Text_Editor'Class;
            Key  : in     Key_Combo);

    type Key_Binding is record
        Key  : Key_Combo;
        Func : Key_Func;
    end record;

    type Key_Binding_Array is array (Positive range <>) of Key_Binding;

    package Key_Binding_Vectors is new Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Key_Binding);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Text_Editor;

        function Create
               (Parent     : in out Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Text_Editor;

    end Forge;




    --  Default Key Function  --

    procedure KF_Default
           (This : in out Text_Editor'Class;
            Key  : in     Key_Combo);




    --  Operation Key Functions  --

    procedure KF_Undo
           (This : in out Text_Editor'Class);

    procedure KF_Cut
           (This : in out Text_Editor'Class);

    procedure KF_Copy
           (This : in out Text_Editor'Class);

    procedure KF_Paste
           (This : in out Text_Editor'Class);

    procedure KF_Delete
           (This : in out Text_Editor'Class);

    procedure KF_Select_All
           (This : in out Text_Editor'Class);




    -- Special Key Functions  --

    procedure KF_Backspace
           (This : in out Text_Editor'Class);

    procedure KF_Insert
           (This : in out Text_Editor'Class);

    procedure KF_Enter
           (This : in out Text_Editor'Class);

    procedure KF_Ignore
           (This : in out Text_Editor'Class);

    procedure KF_Tab
           (This : in out Text_Editor'Class);




    --  Movement Key Functions  --

    procedure KF_Home
           (This : in out Text_Editor'Class);

    procedure KF_End
           (This : in out Text_Editor'Class);

    procedure KF_Page_Down
           (This : in out Text_Editor'Class);

    procedure KF_Page_Up
           (This : in out Text_Editor'Class);

    procedure KF_Down
           (This : in out Text_Editor'Class);

    procedure KF_Left
           (This : in out Text_Editor'Class);

    procedure KF_Right
           (This : in out Text_Editor'Class);

    procedure KF_Up
           (This : in out Text_Editor'Class);




    --  Shift Key Functions  --

    procedure KF_Shift_Home
           (This : in out Text_Editor'Class);

    procedure KF_Shift_End
           (This : in out Text_Editor'Class);

    procedure KF_Shift_Page_Down
           (This : in out Text_Editor'Class);

    procedure KF_Shift_Page_Up
           (This : in out Text_Editor'Class);

    procedure KF_Shift_Down
           (This : in out Text_Editor'Class);

    procedure KF_Shift_Left
           (This : in out Text_Editor'Class);

    procedure KF_Shift_Right
           (This : in out Text_Editor'Class);

    procedure KF_Shift_Up
           (This : in out Text_Editor'Class);




    --  Control Key Functions  --

    procedure KF_Ctrl_Home
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_End
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Page_Down
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Page_Up
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Down
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Left
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Right
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Up
           (This : in out Text_Editor'Class);




    --  Control Shift Key Functions  --

    procedure KF_Ctrl_Shift_Home
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Shift_End
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Shift_Page_Down
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Shift_Page_Up
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Shift_Down
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Shift_Left
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Shift_Right
           (This : in out Text_Editor'Class);

    procedure KF_Ctrl_Shift_Up
           (This : in out Text_Editor'Class);




    --  Meta Key Functions  --

    procedure KF_Meta_Home
           (This : in out Text_Editor'Class);

    procedure KF_Meta_End
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Page_Down
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Page_Up
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Down
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Left
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Right
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Up
           (This : in out Text_Editor'Class);




    --  Meta Shift Key Functions  --

    procedure KF_Meta_Shift_Home
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Shift_End
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Shift_Page_Down
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Shift_Page_Up
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Shift_Down
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Shift_Left
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Shift_Right
           (This : in out Text_Editor'Class);

    procedure KF_Meta_Shift_Up
           (This : in out Text_Editor'Class);




    --  Default / Global Key Bindings  --

    Default_Key_Bindings : constant Key_Binding_Array :=
       ((Mod_None + Escape_Key,       KF_Ignore'Access),
        (Mod_None + Enter_Key,        KF_Enter'Access),
        (Mod_None + Keypad_Enter_Key, KF_Enter'Access),
        (Mod_None + Backspace_Key,    KF_Backspace'Access),
        (Mod_None + Insert_Key,       KF_Insert'Access),
        (Mod_None + Tab_Key,          KF_Tab'Access),

        (Mod_None + Delete_Key, KF_Delete'Access),
        (Mod_Command + 'c',     KF_Copy'Access),
        (Mod_Command + 'v',     KF_Paste'Access),
        (Mod_Command + 'x',     KF_Cut'Access),
        (Mod_Command + 'z',     KF_Undo'Access),
        (Mod_Command + 'a',     KF_Select_All'Access),

        --  Ctrl+'/' Shift+Del Ctrl+Insert Shift+Insert all intentionally absent

        (Mod_None + Home_Key,      KF_Home'Access),
        (Mod_None + End_Key,       KF_End'Access),
        (Mod_None + Page_Down_Key, KF_Page_Down'Access),
        (Mod_None + Page_Up_Key,   KF_Page_Up'Access),
        (Mod_None + Down_Key,      KF_Down'Access),
        (Mod_None + Left_Key,      KF_Left'Access),
        (Mod_None + Right_Key,     KF_Right'Access),
        (Mod_None + Up_Key,        KF_Up'Access),

        (Mod_Shift + Home_Key,      KF_Shift_Home'Access),
        (Mod_Shift + End_Key,       KF_Shift_End'Access),
        (Mod_Shift + Page_Down_Key, KF_Shift_Page_Down'Access),
        (Mod_Shift + Page_Up_Key,   KF_Shift_Page_Up'Access),
        (Mod_Shift + Down_Key,      KF_Shift_Down'Access),
        (Mod_Shift + Left_Key,      KF_Shift_Left'Access),
        (Mod_Shift + Right_Key,     KF_Shift_Right'Access),
        (Mod_Shift + Up_Key,        KF_Shift_Up'Access),

        (Mod_Ctrl + Home_Key,      KF_Ctrl_Home'Access),
        (Mod_Ctrl + End_Key,       KF_Ctrl_End'Access),
        (Mod_Ctrl + Page_Down_Key, KF_Ctrl_Page_Down'Access),
        (Mod_Ctrl + Page_Up_Key,   KF_Ctrl_Page_Up'Access),
        (Mod_Ctrl + Down_Key,      KF_Ctrl_Down'Access),
        (Mod_Ctrl + Left_Key,      KF_Ctrl_Left'Access),
        (Mod_Ctrl + Right_Key,     KF_Ctrl_Right'Access),
        (Mod_Ctrl + Up_Key,        KF_Ctrl_Up'Access),

        (Mod_Ctrl + Mod_Shift + Home_Key,      KF_Ctrl_Shift_Home'Access),
        (Mod_Ctrl + Mod_Shift + End_Key,       KF_Ctrl_Shift_End'Access),
        (Mod_Ctrl + Mod_Shift + Page_Down_Key, KF_Ctrl_Shift_Page_Down'Access),
        (Mod_Ctrl + Mod_Shift + Page_Up_Key,   KF_Ctrl_Shift_Page_Up'Access),
        (Mod_Ctrl + Mod_Shift + Down_Key,      KF_Ctrl_Shift_Down'Access),
        (Mod_Ctrl + Mod_Shift + Left_Key,      KF_Ctrl_Shift_Left'Access),
        (Mod_Ctrl + Mod_Shift + Right_Key,     KF_Ctrl_Shift_Right'Access),
        (Mod_Ctrl + Mod_Shift + Up_Key,        KF_Ctrl_Shift_Up'Access),

        (Mod_Meta + Home_Key,      KF_Meta_Home'Access),
        (Mod_Meta + End_Key,       KF_Meta_End'Access),
        (Mod_Meta + Page_Down_Key, KF_Meta_Page_Down'Access),
        (Mod_Meta + Page_Up_Key,   KF_Meta_Page_Up'Access),
        (Mod_Meta + Down_Key,      KF_Meta_Down'Access),
        (Mod_Meta + Left_Key,      KF_Meta_Left'Access),
        (Mod_Meta + Right_Key,     KF_Meta_Right'Access),
        (Mod_Meta + Up_Key,        KF_Meta_Up'Access),

        (Mod_Meta + Mod_Shift + Home_Key,      KF_Meta_Shift_Home'Access),
        (Mod_Meta + Mod_Shift + End_Key,       KF_Meta_Shift_End'Access),
        (Mod_Meta + Mod_Shift + Page_Down_Key, KF_Meta_Shift_Page_Down'Access),
        (Mod_Meta + Mod_Shift + Page_Up_Key,   KF_Meta_Shift_Page_Up'Access),
        (Mod_Meta + Mod_Shift + Down_Key,      KF_Meta_Shift_Down'Access),
        (Mod_Meta + Mod_Shift + Left_Key,      KF_Meta_Shift_Left'Access),
        (Mod_Meta + Mod_Shift + Right_Key,     KF_Meta_Shift_Right'Access),
        (Mod_Meta + Mod_Shift + Up_Key,        KF_Meta_Shift_Up'Access));


    Global_Key_Bindings : Key_Binding_Vectors.Vector;




    --  Key Binding Modification  --

    --  A key that types text, with no Ctrl, Alt or Meta, never reaches a
    --  binding or the default key function:  Fl_Text_Editor::handle_key
    --  gives it to Fl::compose first, which inserts it
    --  (Fl_Text_Editor.cxx:639, pofltk 147).  Function keys and keys with
    --  Ctrl, Alt or Meta can be bound.

    --  As in FLTK, a key's newest binding wins, and the Global_Key_Bindings
    --  come before an editor's own.  Remove_Key_Binding of a Key removes
    --  only the newest binding of it, which uncovers the one before.  A
    --  bound function may change the bindings, or free the editor.

    procedure Add_Key_Binding
           (This : in out Text_Editor;
            Key  : in     Key_Combo;
            Func : in     Key_Func);

    procedure Add_Key_Binding
           (This : in out Text_Editor;
            Bind : in     Key_Binding);

    procedure Add_Key_Bindings
           (This : in out Text_Editor;
            Bind : in     Key_Binding_Array);

    function Get_Bound_Key_Function
           (This : in Text_Editor;
            Key  : in Key_Combo)
        return Key_Func;

    function Get_All_Bound_Key_Functions
           (This : in Text_Editor)
        return Key_Binding_Array;

    procedure Remove_Key_Binding
           (This : in out Text_Editor;
            Key  : in     Key_Combo);

    procedure Remove_Key_Binding
           (This : in out Text_Editor;
            Bind : in     Key_Binding);

    procedure Remove_Key_Bindings
           (This : in out Text_Editor;
            Bind : in     Key_Binding_Array);

    procedure Remove_All_Key_Bindings
           (This : in out Text_Editor);

    function Get_Default_Key_Function
           (This : in Text_Editor)
        return Default_Key_Func;

    procedure Set_Default_Key_Function
           (This : in out Text_Editor;
            Func : in     Default_Key_Func);




    --  Settings  --

    function Get_Insert_Mode
           (This : in Text_Editor)
        return Insert_Mode;

    procedure Set_Insert_Mode
           (This : in out Text_Editor;
            To   : in     Insert_Mode);

    function Get_Tab_Mode
           (This : in Text_Editor)
        return Tab_Navigation;

    --  Can be called any number of times:  one call to Insert_Char undoes
    --  any number to Widget_Focus, which FLTK's own tab_nav doesn't (F35).
    procedure Set_Tab_Mode
           (This : in out Text_Editor;
            To   : in     Tab_Navigation);




    --  Events  --

    function Handle
           (This  : in out Text_Editor;
            Event : in     Event_Kind)
        return Event_Outcome;

    function Handle_Key
           (This : in out Text_Editor)
        return Event_Outcome;

    procedure Maybe_Do_Callback
           (This : in out Text_Editor);


private


    type Text_Editor is new Text_Display with record
        Bindings     : Key_Binding_Vectors.Vector;
        Default_Func : Default_Key_Func;
    end record;

    overriding procedure Initialize
           (This : in out Text_Editor);

    overriding procedure Finalize
           (This : in out Text_Editor);

    procedure Extra_Init
           (This       : in out Text_Editor;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Text_Editor);


    function Key_Func_Hook
           (K : in Interfaces.C.int;
            E : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Convention (C, Key_Func_Hook);


    package Editor_Convert is new System.Address_To_Access_Conversions (Text_Editor'Class);


    pragma Inline (KF_Default);

    pragma Inline (KF_Undo);
    pragma Inline (KF_Cut);
    pragma Inline (KF_Copy);
    pragma Inline (KF_Paste);
    pragma Inline (KF_Delete);
    pragma Inline (KF_Select_All);

    pragma Inline (KF_Backspace);
    pragma Inline (KF_Insert);
    pragma Inline (KF_Enter);
    pragma Inline (KF_Ignore);
    pragma Inline (KF_Tab);

    pragma Inline (KF_Home);
    pragma Inline (KF_End);
    pragma Inline (KF_Page_Down);
    pragma Inline (KF_Page_Up);
    pragma Inline (KF_Down);
    pragma Inline (KF_Left);
    pragma Inline (KF_Right);
    pragma Inline (KF_Up);

    pragma Inline (KF_Shift_Home);
    pragma Inline (KF_Shift_End);
    pragma Inline (KF_Shift_Page_Down);
    pragma Inline (KF_Shift_Page_Up);
    pragma Inline (KF_Shift_Down);
    pragma Inline (KF_Shift_Left);
    pragma Inline (KF_Shift_Right);
    pragma Inline (KF_Shift_Up);

    pragma Inline (KF_Ctrl_Home);
    pragma Inline (KF_Ctrl_End);
    pragma Inline (KF_Ctrl_Page_Down);
    pragma Inline (KF_Ctrl_Page_Up);
    pragma Inline (KF_Ctrl_Down);
    pragma Inline (KF_Ctrl_Left);
    pragma Inline (KF_Ctrl_Right);
    pragma Inline (KF_Ctrl_Up);

    pragma Inline (KF_Ctrl_Shift_Home);
    pragma Inline (KF_Ctrl_Shift_End);
    pragma Inline (KF_Ctrl_Shift_Page_Down);
    pragma Inline (KF_Ctrl_Shift_Page_Up);
    pragma Inline (KF_Ctrl_Shift_Down);
    pragma Inline (KF_Ctrl_Shift_Left);
    pragma Inline (KF_Ctrl_Shift_Right);
    pragma Inline (KF_Ctrl_Shift_Up);

    pragma Inline (KF_Meta_Home);
    pragma Inline (KF_Meta_End);
    pragma Inline (KF_Meta_Page_Down);
    pragma Inline (KF_Meta_Page_Up);
    pragma Inline (KF_Meta_Down);
    pragma Inline (KF_Meta_Left);
    pragma Inline (KF_Meta_Right);
    pragma Inline (KF_Meta_Up);

    pragma Inline (KF_Meta_Shift_Home);
    pragma Inline (KF_Meta_Shift_End);
    pragma Inline (KF_Meta_Shift_Page_Down);
    pragma Inline (KF_Meta_Shift_Page_Up);
    pragma Inline (KF_Meta_Shift_Down);
    pragma Inline (KF_Meta_Shift_Left);
    pragma Inline (KF_Meta_Shift_Right);
    pragma Inline (KF_Meta_Shift_Up);

    pragma Inline (Add_Key_Binding);
    pragma Inline (Remove_All_Key_Bindings);
    pragma Inline (Get_Default_Key_Function);
    pragma Inline (Set_Default_Key_Function);

    pragma Inline (Get_Insert_Mode);
    pragma Inline (Set_Insert_Mode);
    pragma Inline (Get_Tab_Mode);
    pragma Inline (Set_Tab_Mode);

    pragma Inline (Handle);
    pragma Inline (Handle_Key);
    pragma Inline (Maybe_Do_Callback);


end FLTK.Widgets.Groups.Text_Displays.Text_Editors;


