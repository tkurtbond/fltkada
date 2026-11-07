

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_FormsBitmap:  a widget that shows a bitmap, drawn in its color, on
--  its box drawn in its selection color.


with

    FLTK.Images.Bitmaps;

limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Forms.Bitmaps is


    type Forms_Bitmap is new Widget with private;

    type Forms_Bitmap_Reference (Data : not null access Forms_Bitmap'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        --  With no box, and so with nothing drawn around what it shows.
        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Forms_Bitmap;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Forms_Bitmap;

    end Forge;




    --  Bitmap  --

    --  The bitmap shown, at the top left, or null for none.  The widget
    --  keeps only an access to it: it is the caller's, to keep while it is
    --  shown and to free after.
    function Get_Bitmap
           (This : in Forms_Bitmap)
        return access FLTK.Images.Bitmaps.Bitmap'Class;

    --  Shows Pic, which must stay while it is shown.  It is never copied or
    --  freed here, and the widget's old bitmap stays the caller's.  FLTK's
    --  set(), which would delete an image not its own, isn't bound (pofltk
    --  106).
    procedure Set_Bitmap
           (This : in out Forms_Bitmap;
            Pic  : in out FLTK.Images.Bitmaps.Bitmap'Class);

    --  Shows no bitmap: Get_Bitmap is then null.
    procedure Clear_Bitmap
           (This : in out Forms_Bitmap);





    --  Drawing, Events  --

    procedure Draw
           (This : in out Forms_Bitmap);

    function Handle
           (This  : in out Forms_Bitmap;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Forms_Bitmap is new Widget with
        record
            Current_Bitmap : access FLTK.Images.Bitmaps.Bitmap'Class;
        end record;

    overriding procedure Initialize
           (This : in out Forms_Bitmap);

    overriding procedure Finalize
           (This : in out Forms_Bitmap);

    procedure Extra_Init
           (This       : in out Forms_Bitmap;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Forms_Bitmap)
    with Inline;


    pragma Inline (Get_Bitmap);
    pragma Inline (Set_Bitmap);
    pragma Inline (Clear_Bitmap);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Forms.Bitmaps;


