

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Forms.Pixmaps is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_forms_pixmap
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_forms_pixmap, "new_fl_forms_pixmap");
    pragma Inline (new_fl_forms_pixmap);

    procedure free_fl_forms_pixmap
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_forms_pixmap, "free_fl_forms_pixmap");
    pragma Inline (free_fl_forms_pixmap);




    --  Pixmap  --

    procedure fl_forms_pixmap_set_pixmap
           (B, I : in Storage.Integer_Address);
    pragma Import (C, fl_forms_pixmap_set_pixmap, "fl_forms_pixmap_set_pixmap");
    pragma Inline (fl_forms_pixmap_set_pixmap);





    --  Drawing, Events  --

    procedure fl_forms_pixmap_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_forms_pixmap_draw, "fl_forms_pixmap_draw");
    pragma Inline (fl_forms_pixmap_draw);

    function fl_forms_pixmap_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_forms_pixmap_handle, "fl_forms_pixmap_handle");
    pragma Inline (fl_forms_pixmap_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Forms_Pixmap) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Forms_Pixmap) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_forms_pixmap (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Forms_Pixmap;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Forms_Pixmap) is
    begin
        This.Draw_Ptr   := fl_forms_pixmap_draw'Address;
        This.Handle_Ptr := fl_forms_pixmap_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Forms_Pixmap is
        begin
            return This : Forms_Pixmap do
                This.Void_Ptr := new_fl_forms_pixmap
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
            return Forms_Pixmap is
        begin
            return This : Forms_Pixmap := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Pixmap  --

    function Get_Pixmap
           (This : in Forms_Pixmap)
        return access FLTK.Images.Pixmaps.Pixmap'Class is
    begin
        return This.Current_Pixmap;
    end Get_Pixmap;


    procedure Set_Pixmap
           (This : in out Forms_Pixmap;
            Pic  : in out FLTK.Images.Pixmaps.Pixmap'Class) is
    begin
        This.Current_Pixmap := Pic'Unchecked_Access;
        fl_forms_pixmap_set_pixmap (This.Void_Ptr, Wrapper (Pic).Void_Ptr);
    end Set_Pixmap;


    procedure Clear_Pixmap
           (This : in out Forms_Pixmap) is
    begin
        This.Current_Pixmap := null;
        fl_forms_pixmap_set_pixmap (This.Void_Ptr, Null_Pointer);
    end Clear_Pixmap;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Forms_Pixmap) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Forms_Pixmap;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Forms.Pixmaps;


