

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Images,
    System;

limited with

    FLTK.Widgets.Groups.Windows;

private with

    System.Address_To_Access_Conversions,
    Interfaces.C,
    FLTK.Widget_Callback_Conversions;


package FLTK.Widgets is


    type Widget is new Wrapper with private;

    type Widget_Reference (Data : not null access Widget'Class) is limited null record
        with Implicit_Dereference => Data;

    type Widget_Callback is access procedure
           (Item : in out Widget'Class);




    package Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Widget;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Widget;

    end Forge;




    --  Activity  --

    procedure Activate
           (This : in out Widget);

    procedure Deactivate
           (This : in out Widget);

    function Is_Active
           (This : in Widget)
        return Boolean;

    function Is_Tree_Active
           (This : in Widget)
        return Boolean;

    procedure Set_Active
           (This : in out Widget);

    procedure Set_Active
           (This : in out Widget;
            To   : in     Boolean);

    procedure Clear_Active
           (This : in out Widget);




    --  Changed and Output  --

    function Has_Changed
           (This : in Widget)
        return Boolean;

    procedure Set_Changed
           (This : in out Widget);

    procedure Set_Changed
           (This : in out Widget;
            To   : in     Boolean);

    procedure Clear_Changed
           (This : in out Widget);

    function Is_Output_Only
           (This : in Widget)
        return Boolean;

    procedure Set_Output_Only
           (This : in out Widget);

    procedure Set_Output_Only
           (This : in out Widget;
            To   : in     Boolean);

    procedure Clear_Output_Only
           (This : in out Widget);




    --  Visibility  --

    function Is_Visible
           (This : in Widget)
        return Boolean;

    function Is_Tree_Visible
           (This : in Widget)
        return Boolean;

    procedure Set_Visible
           (This : in out Widget);

    procedure Set_Visible
           (This : in out Widget;
            To   : in     Boolean);

    procedure Clear_Visible
           (This : in out Widget);

    procedure Show
           (This : in out Widget);

    procedure Hide
           (This : in out Widget);




    --  Focus  --

    function Has_Visible_Focus
           (This : in Widget)
        return Boolean;

    procedure Set_Visible_Focus
           (This : in out Widget);

    procedure Set_Visible_Focus
           (This : in out Widget;
            To   : in     Boolean);

    procedure Clear_Visible_Focus
           (This : in out Widget);

    function Take_Focus
           (This : in out Widget)
        return Boolean;

    function Takes_Events
           (This : in Widget)
        return Boolean;




    --  Colors  --

    function Get_Background_Color
           (This : in Widget)
        return Color;

    procedure Set_Background_Color
           (This : in out Widget;
            To   : in     Color);

    function Get_Selection_Color
           (This : in Widget)
        return Color;

    procedure Set_Selection_Color
           (This : in out Widget;
            To   : in     Color);

    procedure Set_Colors
           (This      : in out Widget;
            Back, Sel : in     Color);




    --  Relatives  --

    function Parent
           (This : in Widget)
        return access FLTK.Widgets.Groups.Group'Class;

    function Contains
           (This : in Widget;
            Item : in Widget'Class)
        return Boolean;

    function Inside
           (This   : in Widget;
            Parent : in Widget'Class)
        return Boolean;

    function Nearest_Window
           (This : in Widget)
        return access FLTK.Widgets.Groups.Windows.Window'Class;

    function Top_Window
           (This : in Widget)
        return access FLTK.Widgets.Groups.Windows.Window'Class;

    function Top_Window_Offset
           (This               : in     Widget;
            Offset_X, Offset_Y :    out Integer)
        return access FLTK.Widgets.Groups.Windows.Window'Class;




    --  Alignment, Box, Tooltip  --

    function Get_Alignment
           (This : in Widget)
        return Alignment;

    procedure Set_Alignment
           (This      : in out Widget;
            New_Align : in     Alignment);

    function Get_Box
           (This : in Widget)
        return Box_Kind;

    procedure Set_Box
           (This : in out Widget;
            Box  : in     Box_Kind);

    function Get_Tooltip
           (This : in Widget)
        return String;

    procedure Set_Tooltip
           (This : in out Widget;
            Text : in     String);




    --  Labels  --

    function Get_Label
           (This : in Widget)
        return String;

    procedure Set_Label
           (This : in out Widget;
            Text : in     String);

    --  Dispatches to Set_Label_Kind and Set_Label, so on a window it also
    --  sets the title (pofltk 6).
    procedure Set_Label
           (This : in out Widget;
            Kind : in     Label_Kind;
            Text : in     String);

    function Get_Label_Color
           (This : in Widget)
        return Color;

    procedure Set_Label_Color
           (This  : in out Widget;
            Value : in     Color);

    function Get_Label_Font
           (This : in Widget)
        return Font_Kind;

    procedure Set_Label_Font
           (This : in out Widget;
            Font : in     Font_Kind);

    function Get_Label_Size
           (This : in Widget)
        return Font_Size;

    procedure Set_Label_Size
           (This : in out Widget;
            Size : in     Font_Size);

    function Get_Label_Kind
           (This : in Widget)
        return Label_Kind;

    procedure Set_Label_Kind
           (This  : in out Widget;
            Label : in     Label_Kind);

    procedure Measure_Label
           (This : in     Widget;
            W, H :    out Integer);




    --  Callbacks  --

    function Get_Callback
           (This : in Widget)
        return Widget_Callback;

    procedure Set_Callback
           (This : in out Widget;
            Func : in     Widget_Callback);

    procedure Do_Callback
           (This : in out Widget);

    procedure Do_Callback
           (This  : in     Widget;
            Using : in out Widget);

    procedure Default_Callback
           (This : in out Widget'Class);

    function Get_When
           (This : in Widget)
        return Callback_Flag;

    procedure Set_When
           (This : in out Widget;
            To   : in     Callback_Flag);




    --  Dimensions  --

    function Get_X
           (This : in Widget)
        return Integer;

    function Get_Y
           (This : in Widget)
        return Integer;

    function Get_W
           (This : in Widget)
        return Integer;

    function Get_H
           (This : in Widget)
        return Integer;

    procedure Resize
           (This : in out Widget;
            W, H : in     Integer);

    procedure Resize
           (This       : in out Widget;
            X, Y, W, H : in     Integer);

    procedure Reposition
           (This : in out Widget;
            X, Y : in     Integer);




    --  Images  --

    function Get_Image
           (This : in Widget)
        return access FLTK.Images.Image'Class;

    procedure Set_Image
           (This : in out Widget;
            Pic  : in out FLTK.Images.Image'Class);

    --  Shows no image again: Get_Image is then null.  The image shown
    --  before is still the caller's to free.
    procedure Clear_Image
           (This : in out Widget);

    function Get_Inactive_Image
           (This : in Widget)
        return access FLTK.Images.Image'Class;

    procedure Set_Inactive_Image
           (This : in out Widget;
            Pic  : in out FLTK.Images.Image'Class);




    --  Damage, Drawing, Events  --

    function Is_Damaged
           (This : in Widget)
        return Boolean;

    function Get_Damage
           (This : in Widget)
        return Damage_Mask;

    procedure Set_Damage
           (This : in out Widget;
            Mask : in     Damage_Mask);

    procedure Set_Damage
           (This       : in out Widget;
            Mask       : in     Damage_Mask;
            X, Y, W, H : in     Integer);

    procedure Clear_Damage
           (This : in out Widget;
            Mask : in     Damage_Mask := Damage_None);

    procedure Draw
           (This : in out Widget);

    procedure Draw_Label
           (This : in out Widget);

    procedure Draw_Label
           (This       : in out Widget;
            X, Y, W, H : in     Integer);

    procedure Draw_Label
           (This       : in out Widget;
            X, Y, W, H : in     Integer;
            Align      : in     Alignment);

    procedure Draw_Backdrop
           (This : in out Widget);

    procedure Draw_Box
           (This : in out Widget);

    procedure Draw_Box
           (This : in out Widget;
            Kind : in     Box_Kind;
            Hue  : in     Color);

    procedure Draw_Box
           (This       : in out Widget;
            Kind       : in     Box_Kind;
            X, Y, W, H : in     Integer;
            Hue        : in     Color);

    procedure Draw_Focus
           (This : in out Widget);

    procedure Draw_Focus
           (This       : in out Widget;
            Kind       : in     Box_Kind;
            X, Y, W, H : in     Integer);

    procedure Redraw
           (This : in out Widget);

    procedure Redraw_Label
           (This : in out Widget);

    function Handle
           (This  : in out Widget;
            Event : in     Event_Kind)
        return Event_Outcome;




    --  Miscellaneous  --

    --  Only relevant to MacOS
    function Uses_Accents_Menu
           (This : in Widget)
        return Boolean;

    --  Escape hatches for other FLTK child packages (namely
    --  FLTK.Tree_Items) that need to hand a Widget's underlying C
    --  pointer across the boundary, eg. to embed it in a tree item, or
    --  recover the Ada object on the way back. Application code should
    --  never need these.
    function Address_Of
           (This : in Widget'Class)
        return System.Address;

    --  Returns null if Addr isn't a live FLTK-side widget with an Ada
    --  twin (eg. one Extra_Init never ran for).
    function Widget_At
           (Addr : in System.Address)
        return access Widget'Class;


private


    type Widget is new Wrapper with
        record
            Callback       : Widget_Callback;
            Current_Image  : access FLTK.Images.Image'Class;
            Inactive_Image : access FLTK.Images.Image'Class;
            Draw_Ptr       : System.Address;
            Handle_Ptr     : System.Address;
        end record;

    overriding procedure Initialize
           (This : in out Widget);

    overriding procedure Finalize
           (This : in out Widget);

    --  Widgets that might cause problems for this setup in the future:
    --    Menus (gets various Menu_Items added to it)
    --    Groups.Text_Displays (gets a Text_Buffer attached)
    --    Groups.Text_Displays.Text_Editors (also gets a Text_Buffer attached)
    --  If weird Init/Final errors start mysteriously occuring then check there first.

    --  Extra_Init functionality is also duplicated in FLTK.File_Choosers
    --  for reasons of hierarchy visibility. Really, the File_Chooser should be in
    --  the Widget hierarchy like Color_Chooser but for some reason it isn't.

    procedure Extra_Init
           (This       : in out Widget;
            X, Y, W, H : in     Integer;
            Text       : in     String);

    procedure Extra_Final
           (This : in out Widget);


    --  the user data portion should always be a reference back to the Ada binding
    procedure Callback_Hook
           (W, U : in Storage.Integer_Address);
    pragma Export (C, Callback_Hook, "widget_callback_hook");

    procedure Draw_Hook
           (U : in Storage.Integer_Address);
    pragma Export (C, Draw_Hook, "widget_draw_hook");

    function Handle_Hook
           (U : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Export (C, Handle_Hook, "widget_handle_hook");

    procedure Resize_Hook
           (U          : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Export (C, Resize_Hook, "widget_resize_hook");


    package Widget_Convert is new System.Address_To_Access_Conversions (Widget'Class);
    package Callback_Convert renames FLTK.Widget_Callback_Conversions;


    function fl_widget_get_user_data
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_widget_get_user_data, "fl_widget_get_user_data");
    pragma Inline (fl_widget_get_user_data);

    procedure fl_widget_set_user_data
           (W, D : in Storage.Integer_Address);
    pragma Import (C, fl_widget_set_user_data, "fl_widget_set_user_data");
    pragma Inline (fl_widget_set_user_data);


    procedure fl_widget_set_label
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.char_array);
    pragma Import (C, fl_widget_set_label, "fl_widget_set_label");
    pragma Inline (fl_widget_set_label);


    function fl_widget_get_type
           (W : in Storage.Integer_Address)
        return Interfaces.C.unsigned_char;
    pragma Import (C, fl_widget_get_type, "fl_widget_get_type");
    pragma Inline (fl_widget_get_type);

    procedure fl_widget_set_type
           (W : in Storage.Integer_Address;
            T : in Interfaces.C.unsigned_char);
    pragma Import (C, fl_widget_set_type, "fl_widget_set_type");
    pragma Inline (fl_widget_set_type);


    pragma Inline (Activate);
    pragma Inline (Deactivate);
    pragma Inline (Is_Active);
    pragma Inline (Is_Tree_Active);
    pragma Inline (Set_Active);
    pragma Inline (Clear_Active);

    pragma Inline (Has_Changed);
    pragma Inline (Set_Changed);
    pragma Inline (Clear_Changed);
    pragma Inline (Is_Output_Only);
    pragma Inline (Set_Output_Only);
    pragma Inline (Clear_Output_Only);

    pragma Inline (Is_Visible);
    pragma Inline (Set_Visible);
    pragma Inline (Clear_Visible);
    pragma Inline (Show);
    pragma Inline (Hide);

    pragma Inline (Has_Visible_Focus);
    pragma Inline (Set_Visible_Focus);
    pragma Inline (Clear_Visible_Focus);
    pragma Inline (Take_Focus);
    pragma Inline (Takes_Events);

    pragma Inline (Get_Background_Color);
    pragma Inline (Set_Background_Color);
    pragma Inline (Get_Selection_Color);
    pragma Inline (Set_Selection_Color);
    pragma Inline (Set_Colors);

    pragma Inline (Parent);
    pragma Inline (Contains);
    pragma Inline (Inside);
    pragma Inline (Nearest_Window);
    pragma Inline (Top_Window);
    pragma Inline (Top_Window_Offset);

    pragma Inline (Get_Alignment);
    pragma Inline (Set_Alignment);
    pragma Inline (Get_Box);
    pragma Inline (Set_Box);
    pragma Inline (Get_Tooltip);
    pragma Inline (Set_Tooltip);

    pragma Inline (Get_Label);
    pragma Inline (Set_Label);
    pragma Inline (Get_Label_Color);
    pragma Inline (Set_Label_Color);
    pragma Inline (Get_Label_Font);
    pragma Inline (Set_Label_Font);
    pragma Inline (Get_Label_Size);
    pragma Inline (Set_Label_Size);
    pragma Inline (Get_Label_Kind);
    pragma Inline (Set_Label_Kind);
    pragma Inline (Measure_Label);

    pragma Inline (Get_Callback);
    pragma Inline (Set_Callback);
    pragma Inline (Do_Callback);
    pragma Inline (Default_Callback);
    pragma Inline (Get_When);
    pragma Inline (Set_When);

    pragma Inline (Get_X);
    pragma Inline (Get_Y);
    pragma Inline (Get_W);
    pragma Inline (Get_H);
    pragma Inline (Resize);
    pragma Inline (Reposition);

    pragma Inline (Get_Image);
    pragma Inline (Set_Image);
    pragma Inline (Clear_Image);
    pragma Inline (Get_Inactive_Image);
    pragma Inline (Set_Inactive_Image);

    pragma Inline (Is_Damaged);
    pragma Inline (Get_Damage);
    pragma Inline (Set_Damage);
    pragma Inline (Draw);
    pragma Inline (Draw_Label);
    pragma Inline (Draw_Backdrop);
    pragma Inline (Draw_Box);
    pragma Inline (Draw_Focus);
    pragma Inline (Redraw);
    pragma Inline (Redraw_Label);
    pragma Inline (Handle);

    pragma Inline (Uses_Accents_Menu);
    pragma Inline (Address_Of);
    pragma Inline (Widget_At);


end FLTK.Widgets;


