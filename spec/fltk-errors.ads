

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
    Current_Fatal   : Error_Function := Default_Fatal'Access;


private


    pragma Inline (Default_Warning);
    pragma Inline (Default_Error);
    pragma Inline (Default_Fatal);


end FLTK.Errors;


