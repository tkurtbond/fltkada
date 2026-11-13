


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


--  FLTKAda-BUGS.md 41: Text_Display.Get_Buffer after its Ada buffer is
--  gone.  Set_Buffer kept an access to the Ada Text_Buffer and nothing
--  cleared it, so once the buffer was finalized Get_Buffer gave a
--  reference to freed memory.  Now a buffer knows the displays it was
--  given to, and as it goes each display forgets it: Get_Buffer gives a
--  null reference, as for a display never given one.  The C++ buffer is
--  reference counted, so the display still shows and edits it.
--
--  The buffers and displays here are on the heap, so valgrind sees a
--  buffer that touches a freed display, or the reverse.


with

    Ada.Unchecked_Deallocation,
    Checks,
    FLTK.Text_Buffers,
    FLTK.Widgets.Groups.Text_Displays.Text_Editors,
    System;

use

    Checks,
    FLTK;


procedure Test_Display_Buffer is

    package TB renames FLTK.Text_Buffers;
    package TD renames FLTK.Widgets.Groups.Text_Displays;
    package TE renames FLTK.Widgets.Groups.Text_Displays.Text_Editors;

    use type System.Address;

    type Buffer_Access is access TB.Text_Buffer;
    type Display_Access is access TD.Text_Display;
    type Editor_Access is access TE.Text_Editor;

    procedure Free is new Ada.Unchecked_Deallocation (TB.Text_Buffer, Buffer_Access);
    procedure Free is new Ada.Unchecked_Deallocation (TD.Text_Display, Display_Access);
    procedure Free is new Ada.Unchecked_Deallocation (TE.Text_Editor, Editor_Access);

    function New_Buffer
        return Buffer_Access is
    begin
        return new TB.Text_Buffer'(TB.Forge.Create);
    end New_Buffer;

    function New_Display
        return Display_Access is
    begin
        return new TD.Text_Display'(TD.Forge.Create (0, 0, 200, 100));
    end New_Display;

    --  Whether Display's buffer is Buffer, or with Buffer null, none.
    function Shows
           (Display : in TD.Text_Display'Class;
            Buffer  : in Buffer_Access)
        return Boolean
    is
        Ref : constant TB.Text_Buffer_Reference := Display.Get_Buffer;
    begin
        if Buffer = null then
            return Ref.Data = null;
        else
            return Ref.Data /= null and then Ref.Data.all'Address = Buffer.all'Address;
        end if;
    end Shows;

    procedure One_Display is
        Display : Display_Access := New_Display;
        Buffer  : Buffer_Access  := New_Buffer;
    begin
        Check (Shows (Display.all, null), "a new display has no buffer");
        Display.Set_Buffer (Buffer.all);
        Check (Shows (Display.all, Buffer), "Get_Buffer gives the buffer set");
        Display.Insert_Text ("hello");
        Free (Buffer);
        Check (Shows (Display.all, null), "once the buffer is gone, Get_Buffer gives none");
        Display.Insert_Text (" world");
        Check (Display.Get_Insert_Position = 11,
            "and the display still edits FLTK's buffer:" &
            Natural'Image (Display.Get_Insert_Position));
        Free (Display);
    end One_Display;

    procedure Shared is
        First  : Display_Access := New_Display;
        Second : Display_Access := New_Display;
        Buffer : Buffer_Access  := New_Buffer;
    begin
        First.Set_Buffer (Buffer.all);
        Second.Set_Buffer (Buffer.all);
        Free (First);
        Check (Shows (Second.all, Buffer), "a display outlived by its buffer's other display");
        Free (Buffer);
        Check (Shows (Second.all, null), "a shared buffer gone: the display left has none");
        Free (Second);
    end Shared;

    procedure Replaced is
        Display : Display_Access := New_Display;
        Old     : Buffer_Access  := New_Buffer;
        Buffer  : Buffer_Access  := New_Buffer;
    begin
        Display.Set_Buffer (Old.all);
        Display.Set_Buffer (Buffer.all);
        Free (Old);
        Check (Shows (Display.all, Buffer), "a replaced buffer going leaves the new one");
        Display.Set_Buffer (Buffer.all);
        Free (Display);
        --  Valgrind: the buffer must not touch the freed display, though
        --  it was given to it twice.
        Free (Buffer);
        Check (True, "a buffer given twice outlives its display");
    end Replaced;

    procedure Editor is
        Edit   : Editor_Access := new TE.Text_Editor'(TE.Forge.Create (0, 0, 200, 100));
        Buffer : Buffer_Access := New_Buffer;
    begin
        Edit.Set_Buffer (Buffer.all);
        Check (Shows (Edit.all, Buffer), "an editor's Get_Buffer gives the buffer set");
        Free (Buffer);
        Check (Shows (Edit.all, null), "once its buffer is gone, an editor's gives none");
        Free (Edit);
    end Editor;

begin

    One_Display;
    Shared;
    Replaced;
    Editor;

    Summary;

end Test_Display_Buffer;
