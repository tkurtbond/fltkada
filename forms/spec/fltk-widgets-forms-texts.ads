

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain
--  Derived from pofltk (BSD 3-Clause, copyright T. Kurt Bond), whose
--  author releases this derived work into the public domain, as FLTKAda is.


--  Fl_FormsText:  a widget that shows its label inside it, at the left.
--  Drawing it adds Align_Inside to its alignment.


limited with

    FLTK.Widgets.Groups;


package FLTK.Widgets.Forms.Texts is


    type Forms_Text is new Widget with private;

    type Forms_Text_Reference (Data : not null access Forms_Text'Class) is limited null record
        with Implicit_Dereference => Data;




    package Forge is

        --  With no box, and so with nothing drawn around what it shows.
        function Create
               (X, Y, W, H : in Integer;
                Text       : in String := "")
            return Forms_Text;

        function Create
               (Parent     : in out FLTK.Widgets.Groups.Group'Class;
                X, Y, W, H : in     Integer;
                Text       : in     String := "")
            return Forms_Text;

    end Forge;




    --  Drawing, Events  --

    procedure Draw
           (This : in out Forms_Text);

    function Handle
           (This  : in out Forms_Text;
            Event : in     Event_Kind)
        return Event_Outcome;


private


    type Forms_Text is new Widget with null record;

    overriding procedure Initialize
           (This : in out Forms_Text);

    overriding procedure Finalize
           (This : in out Forms_Text);

    procedure Extra_Init
           (This       : in out Forms_Text;
            X, Y, W, H : in     Integer;
            Text       : in     String)
    with Inline;

    procedure Extra_Final
           (This : in out Forms_Text)
    with Inline;


    pragma Inline (Draw);
    pragma Inline (Handle);


end FLTK.Widgets.Forms.Texts;


