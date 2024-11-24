

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Tabbed is


    procedure tabs_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, tabs_set_draw_hook, "tabs_set_draw_hook");
    pragma Inline (tabs_set_draw_hook);

    procedure tabs_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, tabs_set_handle_hook, "tabs_set_handle_hook");
    pragma Inline (tabs_set_handle_hook);




    function new_fl_tabs
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_tabs, "new_fl_tabs");
    pragma Inline (new_fl_tabs);

    procedure free_fl_tabs
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_tabs, "free_fl_tabs");
    pragma Inline (free_fl_tabs);




    procedure fl_tabs_client_area
           (T          : in     Storage.Integer_Address;
            X, Y, W, H :    out Interfaces.C.int;
            I          : in     Interfaces.C.int);
    pragma Import (C, fl_tabs_client_area, "fl_tabs_client_area");
    pragma Inline (fl_tabs_client_area);




    function fl_tabs_get_push
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tabs_get_push, "fl_tabs_get_push");
    pragma Inline (fl_tabs_get_push);

    procedure fl_tabs_set_push
           (T, I : in Storage.Integer_Address);
    pragma Import (C, fl_tabs_set_push, "fl_tabs_set_push");
    pragma Inline (fl_tabs_set_push);

    function fl_tabs_get_value
           (T : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_tabs_get_value, "fl_tabs_get_value");
    pragma Inline (fl_tabs_get_value);

    procedure fl_tabs_set_value
           (T, V : in Storage.Integer_Address);
    pragma Import (C, fl_tabs_set_value, "fl_tabs_set_value");
    pragma Inline (fl_tabs_set_value);

    function fl_tabs_which
           (T    : in Storage.Integer_Address;
            X, Y : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_tabs_which, "fl_tabs_which");
    pragma Inline (fl_tabs_which);




    procedure fl_tabs_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_tabs_draw, "fl_tabs_draw");
    pragma Inline (fl_tabs_draw);

    function fl_tabs_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_tabs_handle, "fl_tabs_handle");
    pragma Inline (fl_tabs_handle);




    procedure Extra_Final
           (This : in out Tabbed_Group) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Tabbed_Group) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_tabs (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Tabbed_Group;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Tabbed_Group is
        begin
            return This : Tabbed_Group do
                This.Void_Ptr := new_fl_tabs
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                tabs_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                tabs_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Get_Client_Area
           (This       : in     Tabbed_Group;
            Tab_Height : in     Natural;
            X, Y, W, H :    out Integer) is
    begin
        fl_tabs_client_area
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H),
            Interfaces.C.int (Tab_Height));
    end Get_Client_Area;




    function Get_Push
           (This : in Tabbed_Group)
        return access Widget'Class
    is
        Widget_Ptr : Storage.Integer_Address :=
            fl_tabs_get_push (This.Void_Ptr);
        Actual_Widget : access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (fl_widget_get_user_data (Widget_Ptr)));
    begin
        return Actual_Widget;
    end Get_Push;


    procedure Set_Push
           (This : in out Tabbed_Group;
            Item : in out Widget'Class) is
    begin
        fl_tabs_set_push (This.Void_Ptr, Item.Void_Ptr);
    end Set_Push;


    function Get_Visible
           (This : in Tabbed_Group)
        return access Widget'Class
    is
        Widget_Ptr : Storage.Integer_Address :=
            fl_tabs_get_value (This.Void_Ptr);
        Actual_Widget : access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (fl_widget_get_user_data (Widget_Ptr)));
    begin
        return Actual_Widget;
    end Get_Visible;


    procedure Set_Visible
           (This : in out Tabbed_Group;
            Item : in out Widget'Class) is
    begin
        fl_tabs_set_value (This.Void_Ptr, Item.Void_Ptr);
    end Set_Visible;


    function Get_Which
           (This             : in Tabbed_Group;
            Event_X, Event_Y : in Integer)
        return access Widget'Class
    is
        Widget_Ptr : Storage.Integer_Address :=
            fl_tabs_which (This.Void_Ptr, Interfaces.C.int (Event_X), Interfaces.C.int (Event_Y));
        Actual_Widget : access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (fl_widget_get_user_data (Widget_Ptr)));
    begin
        return Actual_Widget;
    end Get_Which;




    procedure Draw
           (This : in out Tabbed_Group) is
    begin
        fl_tabs_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Tabbed_Group;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_tabs_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Tabbed;

