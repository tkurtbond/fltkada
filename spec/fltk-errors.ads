

--  Programmed by Jedidiah Barber
--  Released into the public domain


package FLTK.Errors is


    type Error_Function is not null access procedure
           (Message : in String);


    procedure Default_Warning
           (Message : in String);

    procedure Default_Error
           (Message : in String);

    procedure Default_Fatal
           (Message : in String);


    Current_Warning : Error_Function := Default_Warning'Access;
    Current_Error   : Error_Function := Default_Error'Access;
    --  FLTK's Fl::fatal, which Fl::set_abort sets.  FLTK calls it when it
    --  can't go on, such as when it can't open the display.  The program
    --  ends with exit status 1 when it returns, as with FLTK's own
    --  (Fl.H:557-559; FLTKAda-BUGS.md 66).  It may raise an exception
    --  instead, to carry on elsewhere, but must not call FLTK again.
    Current_Fatal   : Error_Function := Default_Fatal'Access;


private


    pragma Inline (Default_Warning);
    pragma Inline (Default_Error);
    pragma Inline (Default_Fatal);


end FLTK.Errors;


