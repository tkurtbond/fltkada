

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Forms.Bitmaps is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_forms_bitmap
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_forms_bitmap, "new_fl_forms_bitmap");
    pragma Inline (new_fl_forms_bitmap);

    procedure free_fl_forms_bitmap
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_forms_bitmap, "free_fl_forms_bitmap");
    pragma Inline (free_fl_forms_bitmap);




    --  Bitmap  --

    procedure fl_forms_bitmap_set_bitmap
           (B, I : in Storage.Integer_Address);
    pragma Import (C, fl_forms_bitmap_set_bitmap, "fl_forms_bitmap_set_bitmap");
    pragma Inline (fl_forms_bitmap_set_bitmap);





    --  Drawing, Events  --

    procedure fl_forms_bitmap_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_forms_bitmap_draw, "fl_forms_bitmap_draw");
    pragma Inline (fl_forms_bitmap_draw);

    function fl_forms_bitmap_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_forms_bitmap_handle, "fl_forms_bitmap_handle");
    pragma Inline (fl_forms_bitmap_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Forms_Bitmap) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Forms_Bitmap) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_forms_bitmap (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Forms_Bitmap;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Forms_Bitmap) is
    begin
        This.Draw_Ptr   := fl_forms_bitmap_draw'Address;
        This.Handle_Ptr := fl_forms_bitmap_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Forms_Bitmap is
        begin
            return This : Forms_Bitmap do
                This.Void_Ptr := new_fl_forms_bitmap
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
            return Forms_Bitmap is
        begin
            return This : Forms_Bitmap := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Bitmap  --

    function Get_Bitmap
           (This : in Forms_Bitmap)
        return access FLTK.Images.Bitmaps.Bitmap'Class is
    begin
        return This.Current_Bitmap;
    end Get_Bitmap;


    procedure Set_Bitmap
           (This : in out Forms_Bitmap;
            Pic  : in out FLTK.Images.Bitmaps.Bitmap'Class) is
    begin
        This.Current_Bitmap := Pic'Unchecked_Access;
        fl_forms_bitmap_set_bitmap (This.Void_Ptr, Wrapper (Pic).Void_Ptr);
    end Set_Bitmap;


    procedure Clear_Bitmap
           (This : in out Forms_Bitmap) is
    begin
        This.Current_Bitmap := null;
        fl_forms_bitmap_set_bitmap (This.Void_Ptr, Null_Pointer);
    end Clear_Bitmap;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Forms_Bitmap) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Forms_Bitmap;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Forms.Bitmaps;


