

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


with

    FLTK.Widgets.Groups,
    Interfaces.C;


package body FLTK.Widgets.Forms.Texts is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_forms_text
           (X, Y, W, H : in Interfaces.C.int;
            Text       : in Interfaces.C.char_array)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_forms_text, "new_fl_forms_text");
    pragma Inline (new_fl_forms_text);

    procedure free_fl_forms_text
           (B : in Storage.Integer_Address);
    pragma Import (C, free_fl_forms_text, "free_fl_forms_text");
    pragma Inline (free_fl_forms_text);




    --  Drawing, Events  --

    procedure fl_forms_text_draw
           (B : in Storage.Integer_Address);
    pragma Import (C, fl_forms_text_draw, "fl_forms_text_draw");
    pragma Inline (fl_forms_text_draw);

    function fl_forms_text_handle
           (B : in Storage.Integer_Address;
            E : in Interfaces.C.int)
        return Interfaces.C.int;
    pragma Import (C, fl_forms_text_handle, "fl_forms_text_handle");
    pragma Inline (fl_forms_text_handle);




    -------------------
    --  Destructors  --
    -------------------

    procedure Extra_Final
           (This : in out Forms_Text) is
    begin
        Extra_Final (Widget (This));
    end Extra_Final;


    procedure Finalize
           (This : in out Forms_Text) is
    begin
        Extra_Final (This);
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_forms_text (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Extra_Init
           (This       : in out Forms_Text;
            X, Y, W, H : in     Integer;
            Text       : in     String) is
    begin
        Extra_Init (Widget (This), X, Y, W, H, Text);
    end Extra_Init;


    procedure Initialize
           (This : in out Forms_Text) is
    begin
        This.Draw_Ptr   := fl_forms_text_draw'Address;
        This.Handle_Ptr := fl_forms_text_handle'Address;
    end Initialize;


    package body Forge is

        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Forms_Text is
        begin
            return This : Forms_Text do
                This.Void_Ptr := new_fl_forms_text
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
            return Forms_Text is
        begin
            return This : Forms_Text := Create (X, Y, W, H, Text) do
                Parent.Add (This);
            end return;
        end Create;

    end Forge;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Drawing, Events  --

    procedure Draw
           (This : in out Forms_Text) is
    begin
        Widget (This).Draw;
    end Draw;


    function Handle
           (This  : in out Forms_Text;
            Event : in     Event_Kind)
        return Event_Outcome is
    begin
        return Widget (This).Handle (Event);
    end Handle;


end FLTK.Widgets.Forms.Texts;


