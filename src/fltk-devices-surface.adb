

--  Programmed by Jedidiah Barber
--  Released into the public domain


package body FLTK.Devices.Surface is


    ------------------------
    --  Functions From C  --
    ------------------------

    function new_fl_surface
           (G : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_surface, "new_fl_surface");
    pragma Inline (new_fl_surface);

    procedure free_fl_surface
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_surface, "free_fl_surface");
    pragma Inline (free_fl_surface);




    procedure fl_surface_set_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_surface_set_current, "fl_surface_set_current");
    pragma Inline (fl_surface_set_current);

    function fl_surface_get_surface
        return Storage.Integer_Address;
    pragma Import (C, fl_surface_get_surface, "fl_surface_get_surface");
    pragma Inline (fl_surface_get_surface);




    procedure fl_surface_set_driver
           (S, G : in Storage.Integer_Address);
    pragma Import (C, fl_surface_set_driver, "fl_surface_set_driver");
    pragma Inline (fl_surface_set_driver);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Surface_Device) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            free_fl_surface (This.Void_Ptr);
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    procedure Initialize
           (This : in out Surface_Device) is
    begin
        Wrapper (This.My_Driver).Needs_Dealloc := False;
    end Initialize;


    package body Forge is

        function Create
               (Graphics : in FLTK.Devices.Graphics.Graphics_Driver)
            return Surface_Device is
        begin
            return This : Surface_Device do
                This.Void_Ptr := new_fl_surface (Wrapper (Graphics).Void_Ptr);
                Wrapper (This.My_Driver).Void_Ptr := Wrapper (Graphics).Void_Ptr;
            end return;
        end Create;

    end Forge;




    -------------------------
    --  Static Attributes  --
    -------------------------

    Original_Surface : aliased Surface_Device;
    Current_Surface  : aliased Surface_Device;


    procedure Set_Current_Bookkeep
           (Surface : in Surface_Device'Class) is
    begin
        Current_Surface.Void_Ptr := Surface.Void_Ptr;
        Wrapper (Current_Surface.My_Driver).Void_Ptr := Wrapper (Surface.My_Driver).Void_Ptr;
    end Set_Current_Bookkeep;




    -----------------------
    --  API Subprograms  --
    -----------------------

    function Get_Current
        return Surface_Device_Reference is
    begin
        return Ref : Surface_Device_Reference (Data => Current_Surface'Access);
    end Get_Current;


    procedure Set_Current
           (This : in out Surface_Device) is
    begin
        fl_surface_set_current (This.Void_Ptr);
        This.Set_Current_Bookkeep;
    end Set_Current;


    function Get_Original
        return Surface_Device_Reference is
    begin
        return Ref : Surface_Device_Reference (Data => Original_Surface'Access);
    end Get_Original;




    function Has_Driver
           (This : in Surface_Device)
        return Boolean is
    begin
        return Wrapper (This.My_Driver).Void_Ptr /= Null_Pointer;
    end Has_Driver;


    function Get_Driver
           (This : in out Surface_Device)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference is
    begin
        return Ref : FLTK.Devices.Graphics.Graphics_Driver_Reference
            (Data => This.My_Driver'Unchecked_Access);
    end Get_Driver;


    procedure Set_Driver
           (This   : in out Surface_Device;
            Driver : in     FLTK.Devices.Graphics.Graphics_Driver'Class) is
    begin
        fl_surface_set_driver (This.Void_Ptr, Wrapper (Driver).Void_Ptr);
        Wrapper (This.My_Driver).Void_Ptr := Wrapper (Driver).Void_Ptr;
    end Set_Driver;


begin


    Original_Surface.Void_Ptr := fl_surface_get_surface;
    Original_Surface.Needs_Dealloc := False;

    Current_Surface.Void_Ptr := Original_Surface.Void_Ptr;
    Current_Surface.Needs_Dealloc := False;


end FLTK.Devices.Surface;


