

--  Programmed by Jedidiah Barber
--  Released into the public domain


with

    Ada.Unchecked_Deallocation,
    Interfaces.C,
    System;


package body FLTK.Devices.Surface is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_surface_device
           (G : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_surface_device, "new_fl_surface_device");
    pragma Inline (new_fl_surface_device);

    procedure free_fl_surface_device
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_surface_device, "free_fl_surface_device");
    pragma Inline (free_fl_surface_device);

    procedure free_fl_surface_device_any
           (S : in Storage.Integer_Address);
    pragma Import (C, free_fl_surface_device_any, "free_fl_surface_device_any");
    pragma Inline (free_fl_surface_device_any);




    --  Surfaces  --

    procedure fl_surface_device_set_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_surface_device_set_current, "fl_surface_device_set_current");
    pragma Inline (fl_surface_device_set_current);

    function fl_surface_device_get_surface
        return Storage.Integer_Address;
    pragma Import (C, fl_surface_device_get_surface, "fl_surface_device_get_surface");
    pragma Inline (fl_surface_device_get_surface);

    procedure fl_surface_device_push_current
           (S : in Storage.Integer_Address);
    pragma Import (C, fl_surface_device_push_current, "fl_surface_device_push_current");
    pragma Inline (fl_surface_device_push_current);

    procedure fl_surface_device_pop_current;
    pragma Import (C, fl_surface_device_pop_current, "fl_surface_device_pop_current");
    pragma Inline (fl_surface_device_pop_current);

    function fl_surface_device_is_current
           (S : in Storage.Integer_Address)
        return Interfaces.C.int;
    pragma Import (C, fl_surface_device_is_current, "fl_surface_device_is_current");
    pragma Inline (fl_surface_device_is_current);




    --  Drivers  --

    function fl_surface_device_get_driver
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_surface_device_get_driver, "fl_surface_device_get_driver");
    pragma Inline (fl_surface_device_get_driver);

    procedure fl_surface_device_set_driver
           (S, G : in Storage.Integer_Address);
    pragma Import (C, fl_surface_device_set_driver, "fl_surface_device_set_driver");
    pragma Inline (fl_surface_device_set_driver);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Surface_Device) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if Release_Current (This) then
                free_fl_surface_device (This.Void_Ptr);
            end if;
            This.Void_Ptr := Null_Pointer;
        end if;
    end Finalize;




    --------------------
    --  Constructors  --
    --------------------

    package body Forge is

        function Create
               (Graphics : in out FLTK.Devices.Graphics.Graphics_Driver)
            return Surface_Device is
        begin
            return This : Surface_Device do
                This.Void_Ptr := new_fl_surface_device (Wrapper (Graphics).Void_Ptr);
                This.My_Driver := Graphics'Unchecked_Access;
            end return;
        end Create;

    end Forge;




    -------------------------
    --  Static Attributes  --
    -------------------------

    Original_Surface  : aliased Surface_Device;
    Original_Graphics : aliased FLTK.Devices.Graphics.Graphics_Driver;

    Current_Surface : access Surface_Device'Class := Original_Surface'Access;

    --  Mirrors the stack kept by Fl_Surface_Device::push_current
    type Surface_Access is access all Surface_Device'Class;
    Surface_Stack  : array (1 .. 16) of Surface_Access;
    Stack_Height   : Natural := 0;

    --  The stand-ins Release_Current made, each for a surface freed while
    --  remembered below another.  Each owns its FLTK object, and both are
    --  freed by Reclaim once FLTK no longer keeps it.  At most one for each
    --  place in the stack can be remembered.
    Stand_Ins      : array (1 .. Surface_Stack'Last) of Surface_Access;

    procedure Free is new Ada.Unchecked_Deallocation (Surface_Device'Class, Surface_Access);

    procedure Reclaim is
    begin
        for Item of Stand_Ins loop
            if Item /= null and then not Is_Remembered (Item.all) then
                free_fl_surface_device_any (Item.Void_Ptr);
                Item.Void_Ptr := Null_Pointer;
                Free (Item);
            end if;
        end loop;
    end Reclaim;


    procedure Set_Current_Bookkeep
           (Surface : in out Surface_Device'Class) is
    begin
        Current_Surface := Surface'Unchecked_Access;
        Reclaim;
    end Set_Current_Bookkeep;


    --  Whether Item is This.
    function Same
           (Item : access Surface_Device'Class;
            This : in     Surface_Device'Class)
        return Boolean
    is
        use type System.Address;
    begin
        return Item /= null and then Item.all'Address = This'Address;
    end Same;


    function Is_Remembered
           (This : in Surface_Device'Class)
        return Boolean is
    begin
        if Same (Current_Surface, This) then
            return True;
        end if;
        for Index in 1 .. Stack_Height loop
            if Same (Surface_Stack (Index), This) then
                return True;
            end if;
        end loop;
        return False;
    end Is_Remembered;


    function Release_Current
           (This : in out Surface_Device'Class)
        return Boolean
    is
        Stand_In : Surface_Access := null;
    begin
        while Same (Current_Surface, This) and Stack_Height > 0 loop
            Pop_Current;
        end loop;
        if Same (Current_Surface, This) then
            Original_Surface.Set_Current;
        end if;
        for Index in 1 .. Stack_Height loop
            if Same (Surface_Stack (Index), This) then
                if Stand_In = null then
                    Stand_In := new Surface_Device;
                    Stand_In.Void_Ptr := This.Void_Ptr;
                    Stand_In.Needs_Dealloc := False;
                    for Item of Stand_Ins loop
                        if Item = null then
                            Item := Stand_In;
                            exit;
                        end if;
                    end loop;
                end if;
                Surface_Stack (Index) := Stand_In;
            end if;
        end loop;
        return Stand_In = null;
    end Release_Current;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Surfaces  --

    function Get_Current
        return Surface_Device_Reference is
    begin
        return Ref : Surface_Device_Reference (Data => Current_Surface);
    end Get_Current;


    procedure Set_Current
           (This : in out Surface_Device) is
    begin
        fl_surface_device_set_current (This.Void_Ptr);
        This.Set_Current_Bookkeep;
    end Set_Current;


    function Get_Original
        return Surface_Device_Reference is
    begin
        return Ref : Surface_Device_Reference (Data => Original_Surface'Access);
    end Get_Original;


    procedure Push_Current
           (This : in out Surface_Device'Class) is
    begin
        if Stack_Height < Surface_Stack'Last then
            Stack_Height := Stack_Height + 1;
            Surface_Stack (Stack_Height) := Surface_Access (Current_Surface);
        end if;
        fl_surface_device_push_current (This.Void_Ptr);
        Current_Surface := This'Unchecked_Access;
    end Push_Current;


    function Is_Current
           (This : in Surface_Device)
        return Boolean
    is
        use type Interfaces.C.int;
    begin
        return This.Void_Ptr /= Null_Pointer and then
            fl_surface_device_is_current (This.Void_Ptr) /= 0;
    end Is_Current;


    procedure Pop_Current is
    begin
        fl_surface_device_pop_current;
        if Stack_Height > 0 then
            Current_Surface := Surface_Stack (Stack_Height);
            Stack_Height := Stack_Height - 1;
        end if;
        Reclaim;
    end Pop_Current;




    --  Drivers  --

    function Has_Driver
           (This : in Surface_Device)
        return Boolean is
    begin
        return This.My_Driver /= null and then
            Wrapper (This.My_Driver.all).Void_Ptr /= Null_Pointer;
    end Has_Driver;


    function Get_Driver
           (This : in out Surface_Device)
        return FLTK.Devices.Graphics.Graphics_Driver_Reference is
    begin
        return Ref : FLTK.Devices.Graphics.Graphics_Driver_Reference (Data => This.My_Driver);
    end Get_Driver;


    procedure Set_Driver
           (This   : in out Surface_Device;
            Driver : in out FLTK.Devices.Graphics.Graphics_Driver'Class) is
    begin
        fl_surface_device_set_driver (This.Void_Ptr, Wrapper (Driver).Void_Ptr);
        This.My_Driver := Driver'Unchecked_Access;
    end Set_Driver;


begin


    Original_Surface.Void_Ptr := fl_surface_device_get_surface;
    Original_Surface.Needs_Dealloc := False;

    Wrapper (Original_Graphics).Void_Ptr :=
        fl_surface_device_get_driver (Original_Surface.Void_Ptr);
    Wrapper (Original_Graphics).Needs_Dealloc := False;

    Original_Surface.My_Driver := Original_Graphics'Access;


end FLTK.Devices.Surface;


