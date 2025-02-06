

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Interfaces.C.Strings;


package body FLTK.Widgets.Groups.Browsers.Textline.Hold is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_hold_browser
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_hold_browser, "new_fl_hold_browser");
    pragma Inline (new_fl_hold_browser);

    procedure free_fl_hold_browser
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_hold_browser, "free_fl_hold_browser");
    pragma Inline (free_fl_hold_browser);




    --  Item Implementation  --

    function fl_hold_browser_item_width
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_item_width, "fl_hold_browser_item_width");
    pragma Inline (fl_hold_browser_item_width);

    function fl_hold_browser_item_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_item_height, "fl_hold_browser_item_height");
    pragma Inline (fl_hold_browser_item_height);

    function fl_hold_browser_item_first
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_hold_browser_item_first, "fl_hold_browser_item_first");
    pragma Inline (fl_hold_browser_item_first);

    function fl_hold_browser_item_last
           (B : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_hold_browser_item_last, "fl_hold_browser_item_last");
    pragma Inline (fl_hold_browser_item_last);

    function fl_hold_browser_item_next
           (B, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_hold_browser_item_next, "fl_hold_browser_item_next");
    pragma Inline (fl_hold_browser_item_next);

    function fl_hold_browser_item_prev
           (B, I : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_hold_browser_item_prev, "fl_hold_browser_item_prev");
    pragma Inline (fl_hold_browser_item_prev);

    function fl_hold_browser_item_at
           (B : in Storage.Integer_Address;
            N : in Interfaces.C.int)
        return Storage.Integer_Address;
    pragma Import (C, fl_hold_browser_item_at, "fl_hold_browser_item_at");
    pragma Inline (fl_hold_browser_item_at);

    procedure fl_hold_browser_item_select
           (B, I : in Storage.Integer_Address;
            V    : in Interfaces.C.int);
    pragma Import (C, fl_hold_browser_item_select, "fl_hold_browser_item_select");
    pragma Inline (fl_hold_browser_item_select);

    function fl_hold_browser_item_selected
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_item_selected, "fl_hold_browser_item_selected");
    pragma Inline (fl_hold_browser_item_selected);

    procedure fl_hold_browser_item_swap
           (B, X, Y : in Storage.Integer_Address);
    pragma Import (C, fl_hold_browser_item_swap, "fl_hold_browser_item_swap");
    pragma Inline (fl_hold_browser_item_swap);

    function fl_hold_browser_item_text
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.Strings.chars_ptr;
    pragma Import (C, fl_hold_browser_item_text, "fl_hold_browser_item_text");
    pragma Inline (fl_hold_browser_item_text);

    procedure fl_hold_browser_item_draw
           (B, I       : in Storage.Integer_Address;
            X, Y, W, H : in Interfaces.C.int);
    pragma Import (C, fl_hold_browser_item_draw, "fl_hold_browser_item_draw");
    pragma Inline (fl_hold_browser_item_draw);




    --  List Implementation  --

    function fl_hold_browser_full_width
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_full_width, "fl_hold_browser_full_width");
    pragma Inline (fl_hold_browser_full_width);

    function fl_hold_browser_full_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_full_height, "fl_hold_browser_full_height");
    pragma Inline (fl_hold_browser_full_height);

    function fl_hold_browser_incr_height
           (B : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_incr_height, "fl_hold_browser_incr_height");
    pragma Inline (fl_hold_browser_incr_height);

    function fl_hold_browser_item_quick_height
           (B, I : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_item_quick_height, "fl_hold_browser_item_quick_height");
    pragma Inline (fl_hold_browser_item_quick_height);




    --  Drawing, Events  --

    procedure fl_hold_browser_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_hold_browser_draw, "fl_hold_browser_draw");
    pragma Inline (fl_hold_browser_draw);

    function fl_hold_browser_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_hold_browser_handle, "fl_hold_browser_handle");
    pragma Inline (fl_hold_browser_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Hold_Browser) is
    begin
        Extra_Final (Textline_Browser (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Hold_Browser) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_hold_browser (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Hold_Browser;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Textline_Browser (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Hold_Browser) is
    begin
        This.Item_Override_Ptrs :=
           (Item_Width_Ptr    => fl_hold_browser_item_width'Address,
            Item_Height_Ptr   => fl_hold_browser_item_height'Address,
            Item_First_Ptr    => fl_hold_browser_item_first'Address,
            Item_Last_Ptr     => fl_hold_browser_item_last'Address,
            Item_Next_Ptr     => fl_hold_browser_item_next'Address,
            Item_Previous_Ptr => fl_hold_browser_item_prev'Address,
            Item_At_Ptr       => fl_hold_browser_item_at'Address,
            Item_Select_Ptr   => fl_hold_browser_item_select'Address,
            Item_Selected_Ptr => fl_hold_browser_item_selected'Address,
            Item_Swap_Ptr     => fl_hold_browser_item_swap'Address,
            Item_Text_Ptr     => fl_hold_browser_item_text'Address,
            Item_Draw_Ptr     => fl_hold_browser_item_draw'Address);
        This.Wide_High_Ptrs :=
           (Full_List_Width_Ptr     => fl_hold_browser_full_width'Address,
            Full_List_Height_Ptr    => fl_hold_browser_full_height'Address,
            Average_Item_Height_Ptr => fl_hold_browser_incr_height'Address,
            Item_Quick_Height_Ptr   => fl_hold_browser_item_quick_height'Address);
        This.Draw_Ptr   := fl_hold_browser_draw'Address;
        This.Handle_Ptr := fl_hold_browser_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Hold_Browser is
        begin
            return This : Hold_Browser do
                This.Void_Ptr := new_fl_hold_browser
                   (Interfaces.C.int (X),
                    Interfaces.C.int (Y),
                    Interfaces.C.int (W),
                    Interfaces.C.int (H),
                    Interfaces.C.To_C (Text));
                Extra_Init (This, X, Y, W, H, Text);
            end return;
        end Create;


        function Create
               (Parent     : in out Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Hold_Browser is
        begin
            return This : Hold_Browser := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;


end FLTK.Widgets.Groups.Browsers.Textline.Hold;


