

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C;


package body FLTK.Widgets.Groups.Wizards is


    procedure wizard_set_draw_hook
           (W, D : in Storage.Integer_Address);
    pragma Import (C, wizard_set_draw_hook, "wizard_set_draw_hook");
    pragma Inline (wizard_set_draw_hook);

    procedure wizard_set_handle_hook
           (W, H : in Storage.Integer_Address);
    pragma Import (C, wizard_set_handle_hook, "wizard_set_handle_hook");
    pragma Inline (wizard_set_handle_hook);




    function new_fl_wizard
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_wizard, "new_fl_wizard");
    pragma Inline (new_fl_wizard);

    procedure free_fl_wizard
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_wizard, "free_fl_wizard");
    pragma Inline (free_fl_wizard);




    procedure fl_wizard_next
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_wizard_next, "fl_wizard_next");
    pragma Inline (fl_wizard_next);

    procedure fl_wizard_prev
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_wizard_prev, "fl_wizard_prev");
    pragma Inline (fl_wizard_prev);




    function fl_wizard_get_visible
           (W : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_wizard_get_visible, "fl_wizard_get_visible");
    pragma Inline (fl_wizard_get_visible);

    procedure fl_wizard_set_visible
           (W, I : in Storage.Integer_Address);
    pragma Import (C, fl_wizard_set_visible, "fl_wizard_set_visible");
    pragma Inline (fl_wizard_set_visible);




    procedure fl_wizard_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_wizard_draw, "fl_wizard_draw");
    pragma Inline (fl_wizard_draw);

    function fl_wizard_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_wizard_handle, "fl_wizard_handle");
    pragma Inline (fl_wizard_handle);




    procedure Extra_Final
           (This : in out Wizard) is
    begin
        Extra_Final (Group (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Wizard) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_wizard (This.Void_Ptr);
        end if;
    end Finalize;




    procedure Extra_Init
           (This       : in out Wizard;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Group (This), X, Y, W, H, Text);
    end Extra_Init;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Wizard is
        begin
            return This : Wizard do
                This.Void_Ptr := new_fl_wizard
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
                wizard_set_draw_hook (This.Void_Ptr, Storage.To_Integer (Draw_Hook'Address));
                wizard_set_handle_hook (This.Void_Ptr, Storage.To_Integer (Handle_Hook'Address));
            end return;
        end Create;

    end Forge;




    procedure Next
           (This : in out Wizard) is
    begin
        fl_wizard_next (This.Void_Ptr);
    end Next;


    procedure Prev
           (This : in out Wizard) is
    begin
        fl_wizard_prev (This.Void_Ptr);
    end Prev;




    function Get_Visible
           (This : in Wizard)
        return access Widget'Class
    is
        Widget_Ptr : Storage.Integer_Address :=
            fl_wizard_get_visible (This.Void_Ptr);
        Actual_Widget : access Widget'Class :=
            Widget_Convert.To_Pointer (Storage.To_Address (fl_widget_get_user_data (Widget_Ptr)));
    begin
        return Actual_Widget;
    end Get_Visible;


    procedure Set_Visible
           (This : in out Wizard;
            Item : in out Widget'Class) is
    begin
        fl_wizard_set_visible (This.Void_Ptr, Item.Void_Ptr);
    end Set_Visible;




    procedure Draw
           (This : in out Wizard) is
    begin
        fl_wizard_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Wizard;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
               (fl_wizard_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Wizards;

