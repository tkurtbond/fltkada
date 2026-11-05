

--  Programmed by Jedidiah Barber
--  Released into the public domain


private with

    Ada.Containers.Vectors,
    System.Address_To_Access_Conversions,
    Interfaces.C.Strings;


package FLTK.Text_Buffers is


    type Text_Buffer is new Wrapper with private;

    type Text_Buffer_Reference (Data : access Text_Buffer'Class) is limited null record
        with Implicit_Dereference => Data;

    --  A place in the text, as FLTK has it: the number of bytes before it,
    --  so the first is 0, where the text as a String starts at 1.  A
    --  Text_Display's places are the same.
    subtype Position is Natural;

    type Modification is (Insert, Restyle, Delete, None);

    type Modify_Callback is access procedure
           (Action       : in Modification;
            Place        : in Position;
            Length       : in Natural;
            Deleted_Text : in String);

    type Predelete_Callback is access procedure
           (Place  : in Position;
            Length : in Natural);

    --  Unlike Modify_Callback, receives every count FLTK reports, so a
    --  single modification that both inserts and deletes (such as typing
    --  over a selection) is not reduced to just its insertion
    type Modify_Details_Callback is access procedure
           (Place        : in Position;
            Inserted     : in Natural;
            Deleted      : in Natural;
            Restyled     : in Natural;
            Deleted_Text : in String);




    package Forge is

        function Create
               (Requested_Size     : in Natural := 0;
                Preferred_Gap_Size : in Natural := 1024)
            return Text_Buffer;

    end Forge;




    --  Callbacks  --

    procedure Add_Modify_Callback
           (This : in out Text_Buffer;
            Func : in     Modify_Callback);

    procedure Add_Predelete_Callback
           (This : in out Text_Buffer;
            Func : in     Predelete_Callback);

    procedure Remove_Modify_Callback
           (This : in out Text_Buffer;
            Func : in     Modify_Callback);

    procedure Remove_Predelete_Callback
           (This : in out Text_Buffer;
            Func : in     Predelete_Callback);

    procedure Add_Modify_Details_Callback
           (This : in out Text_Buffer;
            Func : in     Modify_Details_Callback);

    procedure Remove_Modify_Details_Callback
           (This : in out Text_Buffer;
            Func : in     Modify_Details_Callback);

    procedure Call_Modify_Callbacks
           (This : in out Text_Buffer);

    procedure Call_Predelete_Callbacks
           (This : in out Text_Buffer);

    procedure Enable_Callbacks
           (This : in out Text_Buffer);

    procedure Disable_Callbacks
           (This : in out Text_Buffer);




    --  Files  --

    --  A file that can't be opened, read or written raises Storage_Error
    --  with the system's reason.  A file that isn't UTF-8 is read as
    --  CP1252 and made UTF-8, all of it (FLTK-issues.md F26); then
    --  Was_Transcoded is True and, unless Set_Transcoding_Warning turned
    --  it off, FLTK shows File_Encoding_Warning in an alert before the
    --  load returns.  Buffer is how many bytes are read at a time.

    procedure Load_File
           (This   : in out Text_Buffer;
            Name   : in     String;
            Buffer : in     Positive := 128 * 1024);

    procedure Append_File
           (This   : in out Text_Buffer;
            Name   : in     String;
            Buffer : in     Positive := 128 * 1024);

    procedure Insert_File
           (This   : in out Text_Buffer;
            Name   : in     String;
            Place  : in     Position;
            Buffer : in     Positive := 128 * 1024);

    procedure Output_File
           (This          : in Text_Buffer;
            Name          : in String;
            Start, Finish : in Position;
            Buffer        : in Positive := 128 * 1024);

    procedure Save_File
           (This   : in Text_Buffer;
            Name   : in String;
            Buffer : in Positive := 128 * 1024);

    --  Whether the last file read wasn't UTF-8 and so was changed.
    function Was_Transcoded
           (This : in Text_Buffer)
        return Boolean;

    --  Whether FLTK alerts the user to a file read that wasn't UTF-8.  It
    --  does by default.
    function Has_Transcoding_Warning
           (This : in Text_Buffer)
        return Boolean;

    procedure Set_Transcoding_Warning
           (This : in out Text_Buffer;
            To   : in     Boolean);

    --  What FLTK's alert says.
    function File_Encoding_Warning
        return String;




    --  Modification  --

    procedure Insert_Text
           (This  : in out Text_Buffer;
            Place : in     Position;
            Text  : in     String);

    procedure Append_Text
           (This : in out Text_Buffer;
            Text : in     String);

    procedure Replace_Text
           (This          : in out Text_Buffer;
            Start, Finish : in     Position;
            Text          : in     String);

    procedure Remove_Text
           (This          : in out Text_Buffer;
            Start, Finish : in     Position);

    function Get_Entire_Text
           (This : in Text_Buffer)
        return String;

    procedure Set_Entire_Text
           (This : in out Text_Buffer;
            Text : in     String);

    function Byte_At
           (This  : in Text_Buffer;
            Place : in Position)
        return Character;

    function Character_At
           (This  : in Text_Buffer;
            Place : in Position)
        return Character;

    function Text_At
           (This          : in Text_Buffer;
            Start, Finish : in Position)
        return String;

    --  The place of the character after the one at Place, or Length at
    --  the end.  A composed character, such as an emoji sequence, is one.
    function Next_Char
           (This  : in Text_Buffer;
            Place : in Position)
        return Position;

    --  The place of the character before Place, or 0 at the start.  From
    --  past the end, the last character's.
    function Prev_Char
           (This  : in Text_Buffer;
            Place : in Position)
        return Position;




    --  Measurement  --

    function Count_Displayed_Characters
           (This          : in Text_Buffer;
            Start, Finish : in Position)
        return Integer;

    function Count_Lines
           (This          : in Text_Buffer;
            Start, Finish : in Position)
        return Integer;

    --  Line feeds from Start up to Finish, plus a line break every
    --  Line_Length bytes of a line, as if the text were wrapped there.
    function Estimate_Lines
           (This          : in Text_Buffer;
            Start, Finish : in Position;
            Line_Length   : in Positive)
        return Natural;

    function Length
           (This : in Text_Buffer)
        return Natural;

    function Get_Tab_Width
           (This : in Text_Buffer)
        return Natural;

    procedure Set_Tab_Width
           (This : in out Text_Buffer;
            To   : in     Natural);




    --  Selection  --

    function Get_Selection
           (This          : in     Text_Buffer;
            Start, Finish :    out Position)
        return Boolean;

    function Get_Secondary_Selection
           (This          : in     Text_Buffer;
            Start, Finish :    out Position)
        return Boolean;

    procedure Set_Selection
           (This          : in out Text_Buffer;
            Start, Finish : in     Position);

    procedure Set_Secondary_Selection
           (This          : in out Text_Buffer;
            Start, Finish : in     Position);

    function Has_Selection
           (This : in Text_Buffer)
        return Boolean;

    function Has_Secondary_Selection
           (This : in Text_Buffer)
        return Boolean;

    function Selection_Text
           (This : in Text_Buffer)
        return String;

    function Secondary_Selection_Text
           (This : in Text_Buffer)
        return String;

    procedure Replace_Selection
           (This : in out Text_Buffer;
            Text : in     String);

    procedure Replace_Secondary_Selection
           (This : in out Text_Buffer;
            Text : in     String);

    procedure Remove_Selection
           (This : in out Text_Buffer);

    procedure Remove_Secondary_Selection
           (This : in out Text_Buffer);

    procedure Unselect
           (This : in out Text_Buffer);

    procedure Secondary_Unselect
           (This : in out Text_Buffer);




    --  Highlighting  --

    function Has_Highlight
           (This : in Text_Buffer)
        return Boolean;

    --  0 and 0 if nothing is highlighted.  FLTK moves the highlight as
    --  the text changes.
    procedure Get_Highlight
           (This          : in     Text_Buffer;
            Start, Finish :    out Position);

    procedure Set_Highlight
           (This          : in out Text_Buffer;
            Start, Finish : in     Position);

    function Get_Highlighted_Text
           (This : in Text_Buffer)
        return String;

    procedure Unhighlight
           (This : in out Text_Buffer);




    --  Search  --

    function Findchar_Forward
           (This     : in     Text_Buffer;
            Start_At : in     Position;
            Item     : in     Character;
            Found_At :    out Position)
        return Boolean;

    function Findchar_Backward
           (This     : in     Text_Buffer;
            Start_At : in     Position;
            Item     : in     Character;
            Found_At :    out Position)
        return Boolean;

    --  With Match_Case the binding does the search itself, since FLTK's
    --  reads past the text.  Search_Backward takes a start past the end as
    --  the end.

    function Search_Forward
           (This       : in     Text_Buffer;
            Start_At   : in     Position;
            Item       : in     String;
            Found_At   :    out Position;
            Match_Case : in     Boolean := False)
        return Boolean;

    function Search_Backward
           (This       : in     Text_Buffer;
            Start_At   : in     Position;
            Item       : in     String;
            Found_At   :    out Position;
            Match_Case : in     Boolean := False)
        return Boolean;




    --  Navigation  --

    --  Whether the character at Place ends a word: an ASCII character that
    --  isn't a letter, digit or underscore, a no-break space, or CJK
    --  punctuation.  Place past the end is a separator.
    function Is_Word_Separator
           (This  : in Text_Buffer;
            Place : in Position)
        return Boolean;

    function Word_Start
           (This  : in Text_Buffer;
            Place : in Position)
        return Position;

    function Word_End
           (This  : in Text_Buffer;
            Place : in Position)
        return Position;

    function Line_Start
           (This  : in Text_Buffer;
            Place : in Position)
        return Position;

    function Line_End
           (This  : in Text_Buffer;
            Place : in Position)
        return Position;

    function Line_Text
           (This  : in Text_Buffer;
            Place : in Position)
        return String;

    --  only takes into account newline characters, not word wrap
    function Skip_Lines
           (This  : in out Text_Buffer;
            Start : in     Position;
            Lines : in     Natural)
        return Position;

    --  only takes into account newline characters, not word wrap
    function Rewind_Lines
           (This  : in out Text_Buffer;
            Start : in     Position;
            Lines : in     Natural)
        return Position;

    function Skip_Displayed_Characters
           (This  : in Text_Buffer;
            Start : in Position;
            Chars : in Natural)
        return Position;




    --  Miscellaneous  --

    --  Turns undo and redo on or off.  They are on by default.
    procedure Can_Undo
           (This : in out Text_Buffer;
            Flag : in     Boolean);

    --  Whether there is a change to undo, or an undone one to redo.
    function Can_Undo
           (This : in Text_Buffer)
        return Boolean;

    function Can_Redo
           (This : in Text_Buffer)
        return Boolean;

    --  Undoes the last change, or redoes the last undone one.  The
    --  functions return False if there was none.  Cursor is where the
    --  change leaves the cursor, or 0 if there was none.
    procedure Undo
           (This : in out Text_Buffer);

    function Undo
           (This : in out Text_Buffer)
        return Boolean;

    function Undo
           (This   : in out Text_Buffer;
            Cursor :    out Position)
        return Boolean;

    procedure Redo
           (This : in out Text_Buffer);

    function Redo
           (This : in out Text_Buffer)
        return Boolean;

    function Redo
           (This   : in out Text_Buffer;
            Cursor :    out Position)
        return Boolean;

    procedure Copy
           (This          : in out Text_Buffer;
            From          : in     Text_Buffer;
            Start, Finish : in     Position;
            Insert_Pos    : in     Position);

    function UTF8_Align
           (This  : in Text_Buffer;
            Place : in Position)
        return Position;


private


    package Modify_Vectors is new Ada.Containers.Vectors
           (Index_Type => Positive,
            Element_Type => Modify_Callback);
    package Predelete_Vectors is new Ada.Containers.Vectors
           (Index_Type => Positive,
            Element_Type => Predelete_Callback);
    package Modify_Details_Vectors is new Ada.Containers.Vectors
           (Index_Type => Positive,
            Element_Type => Modify_Details_Callback);


    type Text_Buffer is new Wrapper with
        record
            CB_Active          : Boolean := True;
            Modify_CBs         : Modify_Vectors.Vector;
            Predelete_CBs      : Predelete_Vectors.Vector;
            Modify_Details_CBs : Modify_Details_Vectors.Vector;
        end record;

    overriding procedure Finalize
           (This : in out Text_Buffer);


    procedure Modify_Callback_Hook
           (Pos, Inserted, Deleted, Restyled : in Interfaces.C.int;
            Text                             : in Interfaces.C.Strings.chars_ptr;
            UD                               : in Storage.Integer_Address);
    pragma Convention (C, Modify_Callback_Hook);

    procedure Predelete_Callback_Hook
           (Pos, Deleted : in Interfaces.C.int;
            UD           : in Storage.Integer_Address);
    pragma Convention (C, Predelete_Callback_Hook);


    package Text_Buffer_Convert is new System.Address_To_Access_Conversions (Text_Buffer);


    pragma Inline (Add_Modify_Callback);
    pragma Inline (Add_Predelete_Callback);
    pragma Inline (Remove_Modify_Callback);
    pragma Inline (Add_Modify_Details_Callback);
    pragma Inline (Remove_Modify_Details_Callback);
    pragma Inline (Remove_Predelete_Callback);
    pragma Inline (Call_Modify_Callbacks);
    pragma Inline (Call_Predelete_Callbacks);
    pragma Inline (Enable_Callbacks);
    pragma Inline (Disable_Callbacks);

    pragma Inline (Was_Transcoded);
    pragma Inline (Has_Transcoding_Warning);
    pragma Inline (Set_Transcoding_Warning);
    pragma Inline (Load_File);
    pragma Inline (Append_File);
    pragma Inline (Insert_File);
    pragma Inline (Output_File);
    pragma Inline (Save_File);

    pragma Inline (Insert_Text);
    pragma Inline (Append_Text);
    pragma Inline (Replace_Text);
    pragma Inline (Remove_Text);
    pragma Inline (Get_Entire_Text);
    pragma Inline (Set_Entire_Text);
    pragma Inline (Byte_At);
    pragma Inline (Character_At);
    pragma Inline (Text_At);
    pragma Inline (Next_Char);
    pragma Inline (Prev_Char);

    pragma Inline (Count_Displayed_Characters);
    pragma Inline (Count_Lines);
    pragma Inline (Estimate_Lines);
    pragma Inline (Length);
    pragma Inline (Get_Tab_Width);
    pragma Inline (Set_Tab_Width);

    pragma Inline (Get_Selection);
    pragma Inline (Get_Secondary_Selection);
    pragma Inline (Set_Selection);
    pragma Inline (Set_Secondary_Selection);
    pragma Inline (Has_Selection);
    pragma Inline (Has_Secondary_Selection);
    pragma Inline (Selection_Text);
    pragma Inline (Secondary_Selection_Text);
    pragma Inline (Replace_Selection);
    pragma Inline (Replace_Secondary_Selection);
    pragma Inline (Remove_Selection);
    pragma Inline (Remove_Secondary_Selection);
    pragma Inline (Unselect);
    pragma Inline (Secondary_Unselect);

    pragma Inline (Has_Highlight);
    pragma Inline (Get_Highlight);
    pragma Inline (Set_Highlight);
    pragma Inline (Get_Highlighted_Text);
    pragma Inline (Unhighlight);

    pragma Inline (Findchar_Forward);
    pragma Inline (Findchar_Backward);
    pragma Inline (Search_Forward);
    pragma Inline (Search_Backward);

    pragma Inline (Is_Word_Separator);
    pragma Inline (Word_Start);
    pragma Inline (Word_End);
    pragma Inline (Line_Start);
    pragma Inline (Line_End);
    pragma Inline (Line_Text);
    pragma Inline (Skip_Lines);
    pragma Inline (Rewind_Lines);
    pragma Inline (Skip_Displayed_Characters);

    pragma Inline (Can_Undo);
    pragma Inline (Can_Redo);
    pragma Inline (Undo);
    pragma Inline (Redo);
    pragma Inline (Copy);
    pragma Inline (UTF8_Align);


end FLTK.Text_Buffers;


