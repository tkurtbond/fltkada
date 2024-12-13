

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




    function fl_check_browser_selection
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_check_browser_selection, "fl_check_browser_selection");
    pragma Inline (fl_check_browser_selection);

    function fl_check_browser_displayed
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_displayed, "fl_check_browser_displayed");
    pragma Inline (fl_check_browser_displayed);

    function fl_check_browser_find_item
           (B : in Storage.Integer_Address;
            Y : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_check_browser_find_item, "fl_check_browser_find_item");
    pragma Inline (fl_check_browser_find_item);

    function fl_check_browser_top
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_check_browser_top, "fl_check_browser_top");
    pragma Inline (fl_check_browser_top);




    procedure fl_check_browser_bbox
           (B          : in     Storage.Integer_Address;
            X, Y, W, H :    out Interfaces.C.int);
    pragma Import (C, fl_check_browser_bbox, "fl_check_browser_bbox");
    pragma Inline (fl_check_browser_bbox);

    function fl_check_browser_leftedge
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_check_browser_leftedge, "fl_check_browser_leftedge");
    pragma Inline (fl_check_browser_leftedge);

    procedure fl_check_browser_redraw_line
           (B, I : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_redraw_line, "fl_check_browser_redraw_line");
    pragma Inline (fl_check_browser_redraw_line);

    procedure fl_check_browser_redraw_lines
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_redraw_lines, "fl_check_browser_redraw_lines");
    pragma Inline (fl_check_browser_redraw_lines);




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




    procedure fl_check_browser_new_list
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_new_list, "fl_check_browser_new_list");
    pragma Inline (fl_check_browser_new_list);

    procedure fl_check_browser_inserting
           (B, A1, A2 : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_inserting, "fl_check_browser_inserting");
    pragma Inline (fl_check_browser_inserting);

    procedure fl_check_browser_deleting
           (B, I : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_deleting, "fl_check_browser_deleting");
    pragma Inline (fl_check_browser_deleting);

    procedure fl_check_browser_replacing
           (B, A1, A2 : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_replacing, "fl_check_browser_replacing");
    pragma Inline (fl_check_browser_replacing);

    procedure fl_check_browser_swapping
           (B, A1, A2 : in Storage.Integer_Address);
    pragma Import (C, fl_check_browser_swapping, "fl_check_browser_swapping");
    pragma Inline (fl_check_browser_swapping);




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
            State : in     Boolean) is
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




    function Current_Selection
           (This : in Check_Browser)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_check_browser_selection (This.Void_Ptr));
    end Current_Selection;


    function Is_Displayed
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Boolean
    is
        Code : Interfaces.C.int := fl_check_browser_displayed
           (This.Void_Ptr,
            Cursor_To_Address (Item));
    begin
        if Code not in 0 .. 1 then
            raise Internal_FLTK_Error;
        end if;
        return Boolean'Val (Code);
    end Is_Displayed;


    function Find_Item
           (This  : in Check_Browser;
            Y_Pos : in Integer)
        return Item_Cursor is
    begin
        return Address_To_Cursor
            (fl_check_browser_find_item (This.Void_Ptr, Interfaces.C.int (Y_Pos)));
    end Find_Item;


    function Top_Item
           (This : in Check_Browser)
        return Item_Cursor is
    begin
        return Address_To_Cursor (fl_check_browser_top (This.Void_Ptr));
    end Top_Item;




    procedure Bounding_Box
           (This       : in     Check_Browser;
            X, Y, W, H :    out Integer) is
    begin
        fl_check_browser_bbox
           (This.Void_Ptr,
            Interfaces.C.int (X),
            Interfaces.C.int (Y),
            Interfaces.C.int (W),
            Interfaces.C.int (H));
    end Bounding_Box;


    function Left_Edge
           (This : in Check_Browser)
        return Integer is
    begin
        return Integer (fl_check_browser_leftedge (This.Void_Ptr));
    end Left_Edge;


    procedure Redraw_Line
           (This : in out Check_Browser;
            Item : in     Item_Cursor) is
    begin
        fl_check_browser_redraw_line (This.Void_Ptr, Cursor_To_Address (Item));
    end Redraw_Line;


    procedure Redraw_List
           (This : in out Check_Browser) is
    begin
        fl_check_browser_redraw_lines (This.Void_Ptr);
    end Redraw_List;




    function Full_List_Width
           (This : in Check_Browser)
        return Integer is
    begin
        return Integer (fl_check_browser_full_width (This.Void_Ptr));
    end Full_List_Width;


    function Full_List_Height
           (This : in Check_Browser)
        return Integer is
    begin
        return Integer (fl_check_browser_full_height (This.Void_Ptr));
    end Full_List_Height;


    function Average_Item_Height
           (This : in Check_Browser)
        return Integer is
    begin
        return Integer (fl_check_browser_incr_height (This.Void_Ptr));
    end Average_Item_Height;


    function Item_Quick_Height
           (This : in Check_Browser;
            Item : in Item_Cursor)
        return Integer is
    begin
        return Integer (fl_check_browser_item_quick_height
           (This.Void_Ptr,
            Cursor_To_Address (Item)));
    end Item_Quick_Height;




    --  function Item_Width
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Integer is
    --  begin
    --      return Integer (fl_check_browser_item_width
    --         (This.Void_Ptr,
    --          Cursor_To_Address (Item)));
    --  end Item_Width;


    --  function Item_Height
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Integer is
    --  begin
    --      return Integer (fl_check_browser_item_height
    --         (This.Void_Ptr,
    --          Cursor_To_Address (Item)));
    --  end Item_Height;


    --  function Item_First
    --         (This : in Check_Browser)
    --      return Item_Cursor is
    --  begin
    --      return Address_To_Cursor (fl_check_browser_item_first (This.Void_Ptr));
    --  end Item_First;


    --  Note that Item_Last is not implemented


    --  function Item_Next
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Item_Cursor is
    --  begin
    --      return Address_To_Cursor (fl_check_browser_item_next
    --         (This.Void_Ptr,
    --          Cursor_To_Address (Item)));
    --  end Item_Next;


    --  function Item_Previous
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Item_Cursor is
    --  begin
    --      return Address_To_Cursor (fl_check_browser_item_prev
    --         (This.Void_Ptr,
    --          Cursor_To_Address (Item)));
    --  end Item_Previous;


    --  Note that Item_At is not implemented


    --  procedure Item_Select
    --         (This  : in out Check_Browser;
    --          Item  : in     Item_Cursor;
    --          State : in     Boolean := True) is
    --  begin
    --      fl_check_browser_item_select
    --         (This.Void_Ptr,
    --          Cursor_To_Address (Item),
    --          Boolean'Pos (State));
    --  end Item_Select;


    --  function Item_Selected
    --         (This : in Check_Browser;
    --          Item : in Item_Cursor)
    --      return Boolean is
    --  begin
    --      return fl_check_browser_selected (This.Void_Ptr, Cursor_To_Address (Item)) /= 0;
    --  end Item_Selected;


    --  Note that Item_Swap and Item_Text are not implemented


    --  procedure Item_Draw
    --         (This       : in Check_Browser;
    --          Item       : in Item_Cursor;
    --          X, Y, W, H : in Integer) is
    --  begin
    --      fl_check_browser_item_draw
    --         (This.Void_Ptr,
    --          Cursor_To_Address (Item),
    --          Interfaces.C.int (X),
    --          Interfaces.C.int (Y),
    --          Interfaces.C.int (W),
    --          Interfaces.C.int (H));
    --  end Item_Draw;




    procedure New_List
           (This : in out Check_Browser) is
    begin
        fl_check_browser_new_list (This.Void_Ptr);
    end New_List;


    procedure Inserting
           (This : in out Check_Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_check_browser_inserting
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Inserting;


    procedure Deleting
           (This : in out Check_Browser;
            Item : in     Item_Cursor) is
    begin
        fl_check_browser_deleting
           (This.Void_Ptr,
            Cursor_To_Address (Item));
    end Deleting;


    procedure Replacing
           (This : in out Check_Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_check_browser_replacing
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Replacing;


    procedure Swapping
           (This : in out Check_Browser;
            A, B : in     Item_Cursor) is
    begin
        fl_check_browser_swapping
           (This.Void_Ptr,
            Cursor_To_Address (A),
            Cursor_To_Address (B));
    end Swapping;




    procedure Draw
           (This : in out Check_Browser) is
    begin
        fl_check_browser_draw (This.Void_Ptr);
    end Draw;


    function Handle
           (This  : in out Check_Browser;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Event_Outcome'Val
           (fl_check_browser_handle (This.Void_Ptr, Event_Kind'Pos (Event)));
    end Handle;


end FLTK.Widgets.Groups.Browsers.Check;


