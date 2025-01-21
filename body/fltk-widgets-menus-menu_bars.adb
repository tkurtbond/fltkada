

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Menus.Menu_Bars is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_menu_bar
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_menu_bar, "new_fl_menu_bar");
    pragma Inline (new_fl_menu_bar);

    procedure free_fl_menu_bar
           (M : in Storage.Integer_Address);
    pragma Import (C, free_fl_menu_bar, "free_fl_menu_bar");
    pragma Inline (free_fl_menu_bar);




    procedure fl_menu_bar_draw
           (W : in Storage.Integer_Address);
    pragma Import (C, fl_menu_bar_draw, "fl_menu_bar_draw");
    pragma Inline (fl_menu_bar_draw);

    function fl_menu_bar_handle
           (W : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_bar_handle, "fl_menu_bar_handle");
    pragma Inline (fl_menu_bar_handle);




    function fl_menu_get_item
           (M : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_menu_get_item, "fl_menu_get_item");
    pragma Inline (fl_menu_get_item);

    function fl_menu_value
           (M : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_menu_value, "fl_menu_value");
    pragma Inline (fl_menu_value);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Menu_Bar) is
    begin
        Extra_Final (Menu (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Menu_Bar) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_menu_bar (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Menu_Bar;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Menu (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Menu_Bar) is
    begin
        This.Draw_Ptr     := fl_menu_bar_draw'Address;
        This.Handle_Ptr   := fl_menu_bar_handle'Address;
        This.Get_Item_Ptr := fl_menu_get_item'Address;
        This.Value_Ptr    := fl_menu_value'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Menu_Bar is
        begin
            return This : Menu_Bar do
                This.Void_Ptr := new_fl_menu_bar
                       (Interfaces.C.int (X),
                        Interfaces.C.int (Y),
                        Interfaces.C.int (W),
                        Interfaces.C.int (H),
                        Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Menu_Bar is
        begin
            return This : Menu_Bar := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    procedure Draw
           (This : in out Menu_Bar) is
    begin
        Menu (This).Draw;
    end Draw;


    function Handle
           (This  : in out Menu_Bar;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Menu (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Menus.Menu_Bars;


