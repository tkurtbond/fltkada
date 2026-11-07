

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_FormsPixmap:  a widget that shows a pixmap, such as an XPM or GIF
--  image, on its box drawn in its selection color.


with

    FLTK.Images.Pixmaps;

limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Forms.Pixmaps is


    type Forms_Pixmap is new Widget with private;

    type Forms_Pixmap_Reference (Data : not null access Forms_Pixmap'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        --  With no box, and so with nothing drawn around what it shows.
        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Forms_Pixmap;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Forms_Pixmap;

    end Forge;




    --  Pixmap  --

    --  The pixmap shown, at the top left, or null for none.  The widget
    --  keeps only an access to it: it is the caller's, to keep while it is
    --  shown and to free after.
    function Get_Pixmap
           (This : in Forms_Pixmap)
        return access FLTK.Images.Pixmaps.Pixmap'Class;

    --  Shows Pic, which must stay while it is shown.  It is never copied or
    --  freed here, and the widget's old pixmap stays the caller's.  FLTK's
    --  set(), which would delete an image not its own, isn't bound (pofltk
    --  106).
    procedure Set_Pixmap
           (This : in out Forms_Pixmap;
            Pic  : in out FLTK.Images.Pixmaps.Pixmap'Class);

    --  Shows no pixmap: Get_Pixmap is then null.
    procedure Clear_Pixmap
           (This : in out Forms_Pixmap);





    --  Drawing, Events  --

    procedure Draw
           (This : in out Forms_Pixmap);

    function Handle
           (This  : in out Forms_Pixmap;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Forms_Pixmap is new Widget with
        record
            Current_Pixmap : access FLTK.Images.Pixmaps.Pixmap'Class;
        end record;

    overriding procedure Initialize
           (This : in out Forms_Pixmap);

    overriding procedure Finalize
           (This : in out Forms_Pixmap);

    procedure Extra_Init
           (This       : in out Forms_Pixmap;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Forms_Pixmap)
    with Inline;


    pragma Inline (Get_Pixmap);
    pragma Inline (Set_Pixmap);
    pragma Inline (Clear_Pixmap);

    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Forms.Pixmaps;


