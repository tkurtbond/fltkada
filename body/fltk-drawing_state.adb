

--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package body FLTK.Drawing_State is


    use type System.Address;


    type Entry_Record is record
        Undo : Undo_Action;
        Item : System.Address;
    end record;

    type Entry_Array is array (Positive range 1 .. Capacity) of Entry_Record;

    Log    : Entry_Array;
    Length : Mark := 0;




    procedure Delete
           (Index : in Positive) is
    begin
        Log (Index .. Length - 1) := Log (Index + 1 .. Length);
        Length := Length - 1;
    end Delete;


    procedure Remember
           (Undo : in Undo_Action;
            Item : in System.Address := System.Null_Address) is
    begin
        if Length < Capacity then
            Length := Length + 1;
            Log (Length) := (Undo => Undo, Item => Item);
        end if;
    end Remember;


    procedure Forget
           (Undo : in Undo_Action) is
    begin
        for Index in reverse 1 .. Length loop
            if Log (Index).Undo = Undo then
                Delete (Index);
                return;
            end if;
        end loop;
    end Forget;


    procedure Forget
           (Undo : in Undo_Action;
            Item : in System.Address) is
    begin
        for Index in reverse 1 .. Length loop
            if Log (Index).Undo = Undo and then Log (Index).Item = Item then
                Delete (Index);
                return;
            end if;
        end loop;
    end Forget;


    procedure Forget_All
           (Item : in System.Address) is
    begin
        for Index in reverse 1 .. Length loop
            if Log (Index).Item = Item then
                Delete (Index);
            end if;
        end loop;
    end Forget_All;


    function Current
        return Mark is
    begin
        return Length;
    end Current;


    procedure Undo_To
           (Level : in Mark) is
    begin
        while Length > Level loop
            declare
                Top    : constant Mark         := Length;
                Undone : constant Entry_Record := Log (Top);
            begin
                begin
                    Undone.Undo (Undone.Item);
                exception
                when others =>
                    null;
                end;
                --  An undo that didn't Forget its entry: drop it, so the
                --  loop ends.
                if Length >= Top and then Log (Top) = Undone then
                    Delete (Top);
                end if;
            end;
        end loop;
    end Undo_To;


end FLTK.Drawing_State;

