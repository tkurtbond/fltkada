

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;

use type

    Interfaces.C.int;


package body FLTK.Widgets.Groups.Browsers.Check is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_check_browser
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_check_browser, "new_fl_check_browser");
    pragma Inline (new_fl_check_browser);

    procedure free_fl_check_browser
           (C : in Storage.Integer_Address);
    pragma Import (C, free_fl_check_browser, "free_fl_check_browser");
    pragma Inline (free_fl_check_browser);




    function fl_check_browser_add
           (C : in Storage.Integer_Address;
            S : in Interfaces.C.char_array;
            B : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_add, "fl_check_browser_add");
    pragma Inline (fl_check_browser_add);

    function fl_check_browser_remove
           (C : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_remove, "fl_check_browser_remove");
    pragma Inline (fl_check_browser_remove);

    procedure fl_check_browser_clear
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_clear, "fl_check_browser_clear");
    pragma Inline (fl_check_browser_clear);

    function fl_check_browser_nitems
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_nitems, "fl_check_browser_nitems");
    pragma Inline (fl_check_browser_nitems);




    procedure fl_check_browser_check_all
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_check_all, "fl_check_browser_check_all");
    pragma Inline (fl_check_browser_check_all);

    procedure fl_check_browser_check_none
           (C : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_check_none, "fl_check_browser_check_none");
    pragma Inline (fl_check_browser_check_none);

    function fl_check_browser_get_checked
           (C : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_get_checked, "fl_check_browser_get_checked");
    pragma Inline (fl_check_browser_get_checked);

    procedure fl_check_browser_set_checked
           (C    : in Storage.Integer_Address;
            I, B : in Interfaces.C.int);
    pragma Import (C, fl_check_browser_set_checked, "fl_check_browser_set_checked");
    pragma Inline (fl_check_browser_set_checked);

    function fl_check_browser_nchecked
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_nchecked, "fl_check_browser_nchecked");
    pragma Inline (fl_check_browser_nchecked);




    function fl_check_browser_text
           (C : in Storage.Integer_Address;
            I : in Interfaces.C.int)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_check_browser_text, "fl_check_browser_text");
    pragma Inline (fl_check_browser_text);

    function fl_check_browser_value
           (C : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_value, "fl_check_browser_value");
    pragma Inline (fl_check_browser_value);




    function fl_check_browser_full_width
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_full_width, "fl_check_browser_full_width");
    pragma Inline (fl_check_browser_full_width);

    function fl_check_browser_full_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_full_height, "fl_check_browser_full_height");
    pragma Inline (fl_check_browser_full_height);

    function fl_check_browser_incr_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_incr_height, "fl_check_browser_incr_height");
    pragma Inline (fl_check_browser_incr_height);

    function fl_check_browser_item_quick_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_item_quick_height, "fl_check_browser_item_quick_height");
    pragma Inline (fl_check_browser_item_quick_height);




    function fl_check_browser_item_width
           (C, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_item_width, "fl_check_browser_item_width");
    pragma Inline (fl_check_browser_item_width);

    function fl_check_browser_item_height
           (C, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_item_height, "fl_check_browser_item_height");
    pragma Inline (fl_check_browser_item_height);

    function fl_check_browser_item_first
           (C : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_check_browser_item_first, "fl_check_browser_item_first");
    pragma Inline (fl_check_browser_item_first);

    --  Missing item_last

    function fl_check_browser_item_next
           (C, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_check_browser_item_next, "fl_check_browser_item_next");
    pragma Inline (fl_check_browser_item_next);

    function fl_check_browser_item_prev
           (C, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_check_browser_item_prev, "fl_check_browser_item_prev");
    pragma Inline (fl_check_browser_item_prev);

    --  Missing item_at

    procedure fl_check_browser_item_select
           (C, I : in Storage.Integer_Address;
            V    : in Interfaces.C.int);
    pragma Import (C, fl_check_browser_item_select, "fl_check_browser_item_select");
    pragma Inline (fl_check_browser_item_select);

    function fl_check_browser_item_selected
           (C, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_item_selected, "fl_check_browser_item_selected");
    pragma Inline (fl_check_browser_item_selected);

    --  Missing item_swap and item_text

    procedure fl_check_browser_item_draw
           (C, I       : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_check_browser_item_draw, "fl_check_browser_item_draw");
    pragma Inline (fl_check_browser_item_draw);




    procedure fl_check_browser_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_draw, "fl_check_browser_draw");
    pragma Inline (fl_check_browser_draw);

    function fl_check_browser_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_handle, "fl_check_browser_handle");
    pragma Inline (fl_check_browser_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Check_Browser) is
    begin
        Extra_Final (Browser (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Check_Browser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_check_browser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Check_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Browser (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Check_Browser) is
    begin
        This.Wide_High_Ptrs :=
           (Full_List_Width_Ptr     => fl_check_browser_full_width'Address,
            Full_List_Height_Ptr    => fl_check_browser_full_height'Address,
            Average_Item_Height_Ptr => fl_check_browser_incr_height'Address,
            Item_Quick_Height_Ptr   => fl_check_browser_item_quick_height'Address);
        This.Draw_Ptr   := fl_check_browser_draw'Address;
        This.Handle_Ptr := fl_check_browser_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Check_Browser is
        begin
            return This : Check_Browser do
                This.Void_Ptr := new_fl_check_browser
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;

    end Forge;




    -------------------------
    --  Check_Browser API  --
    -------------------------

    procedure Add
           (This    : in out Check_Browser;
            Text    : in     String;
            Checked : in     Boolean := False)
    is
        Code : Interfaces.C.int := fl_check_browser_add
           (This.Void_Ptr,
            Interfaces.C.To_C (Text),
            Boolean'Pos (Checked));
    begin
        null;
    end Add;


    procedure Remove
           (This  : in out Check_Browser;
            Index : in     Positive)
    is
        Code : Interfaces.C.int := fl_check_browser_remove
           (This.Void_Ptr,
            Interfaces.C.int (Index));
    begin
        null;
    end Remove;


    procedure Clear
           (This : in out Check_Browser) is
    begin
        fl_check_browser_clear (This.Void_Ptr);
    end Clear;


    function Number_Of_Items
           (This : in Check_Browser)
        return Natural is
    begin
        return Natural (fl_check_browser_nitems (This.Void_Ptr));
    end Number_Of_Items;




    procedure Check_All
           (This : in out Check_Browser) is
    begin
        fl_check_browser_check_all (This.Void_Ptr);
    end Check_All;


    procedure Check_None
           (This : in out Check_Browser) is
    begin
        fl_check_browser_check_none (This.Void_Ptr);
    end Check_None;


    function Is_Checked
           (This  : in Check_Browser;
            Index : in Positive)
        return Boolean is
    begin
        return fl_check_browser_get_checked (This.Void_Ptr, Interfaces.C.int (Index)) /= 0;
    end Is_Checked;


    procedure Set_Checked
           (This  : in out Check_Browser;
            Index : in     Positive;
            State : in     Boolean := True) is
    begin
        fl_check_browser_set_checked
           (This.Void_Ptr,
            Interfaces.C.int (Index),
            Boolean'Pos (State));
    end Set_Checked;


    function Number_Checked
           (This : in Check_Browser)
        return Natural is
    begin
        return Natural (fl_check_browser_nchecked (This.Void_Ptr));
    end Number_Checked;




    function Item_Text
           (This  : in Check_Browser;
            Index : in Positive)
        return String is
    begin
        return Interfaces.C.Strings.Value
            (fl_check_browser_text (This.Void_Ptr, Interfaces.C.int (Index)));
    end Item_Text;


    function Selected_Index
           (This : in Check_Browser)
        return Positive is
    begin
        return Positive (fl_check_browser_value (This.Void_Ptr));
    end Selected_Index;




    function Item_Width
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return Integer (fl_check_browser_item_width
           (This.Void_Ptr,
            Cursor_To_Address (Item)));
    end Item_Width;


    function Item_Height
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return Integer (fl_check_browser_item_height
           (This.Void_Ptr,
            Cursor_To_Address (Item)));
    end Item_Height;


    function Item_First
           (This : in Check_Browser)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_check_browser_item_first (This.Void_Ptr));
    end Item_First;


    --  Note that Item_Last is not implemented


    function Item_Next
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_check_browser_item_next
           (This.Void_Ptr,
            Cursor_To_Address (Item)));
    end Item_Next;


    function Item_Previous
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_check_browser_item_prev
           (This.Void_Ptr,
            Cursor_To_Address (Item)));
    end Item_Previous;


    --  Note that Item_At is not implemented


    procedure Item_Select
           (This  : in out Check_Browser;
            Item  : in     Item_Cursor;
            State : in     Boolean := True) is
    begin
        fl_check_browser_item_select
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Boolean'Pos (State));
    end Item_Select;


    function Item_Selected
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Boolean is
    begin
        return fl_check_browser_item_selected (This.Void_Ptr, Cursor_To_Address (Item)) /= 0;
    end Item_Selected;


    --  Note that Item_Swap and Item_Text are not implemented


    procedure Item_Draw
           (This       : in Check_Browser;
            Item       : in Item_Cursor;
            X, Y, W, H : in Integer) is
    begin
        fl_check_browser_item_draw
           (This.Void_Ptr,
            Cursor_To_Address (Item),
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Item_Draw;


end FLTK.Widgets.Groups.Browsers.Check;


