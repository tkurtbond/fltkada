


--  Programmed by T. Kurt Bond and Claude Opus 5.5
--  Released into the public domain


package body FLTK.Hook_Exceptions is


    protected Kept is

        procedure Save
               (Occurrence : in Ada.Exceptions.Exception_Occurrence);

        procedure Take
               (Occurrence : out Ada.Exceptions.Exception_Occurrence);

    private

        Held : Ada.Exceptions.Exception_Occurrence;
        Full : Boolean := False;

    end Kept;


    protected body Kept is

        procedure Save
               (Occurrence : in Ada.Exceptions.Exception_Occurrence) is
        begin
            if not Full then
                Ada.Exceptions.Save_Occurrence (Held, Occurrence);
                Full := True;
            end if;
        end Save;

        procedure Take
               (Occurrence : out Ada.Exceptions.Exception_Occurrence) is
        begin
            if Full then
                Ada.Exceptions.Save_Occurrence (Occurrence, Held);
                Ada.Exceptions.Save_Occurrence (Held, Ada.Exceptions.Null_Occurrence);
                Full := False;
            else
                Ada.Exceptions.Save_Occurrence (Occurrence, Ada.Exceptions.Null_Occurrence);
            end if;
        end Take;

    end Kept;




    procedure Save
           (Occurrence : in Ada.Exceptions.Exception_Occurrence) is
    begin
        Kept.Save (Occurrence);
    end Save;


    procedure Save
           (Occurrence : in Ada.Exceptions.Exception_Occurrence;
            Since      : in Mark) is
    begin
        FLTK.Drawing_State.Undo_To (Since);
        Kept.Save (Occurrence);
    end Save;


    procedure Save_New
           (Id      : in Ada.Exceptions.Exception_Id;
            Message : in String) is
    begin
        Ada.Exceptions.Raise_Exception (Id, Message);
    exception
    when Occurrence : others =>
        Kept.Save (Occurrence);
    end Save_New;


    procedure Reraise
    is
        Occurrence : Ada.Exceptions.Exception_Occurrence;
    begin
        Kept.Take (Occurrence);
        --  Does nothing if Occurrence is Null_Occurrence.
        Ada.Exceptions.Reraise_Occurrence (Occurrence);
    end Reraise;


end FLTK.Hook_Exceptions;


