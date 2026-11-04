

--  Programmed by Jedidiah Barber
--  Released into the public domain


package body FLTK.Devices.Surface.Display is


    ------------------------
    --  Functions From C  --
    ------------------------

    --  Allocation  --

    function new_fl_display_device
           (G : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, new_fl_display_device, "new_fl_display_device");
    pragma Inline (new_fl_display_device);

    procedure free_fl_display_device
           (D : in Storage.Integer_Address);
    pragma Import (C, free_fl_display_device, "free_fl_display_device");
    pragma Inline (free_fl_display_device);




    --  Displays  --

    function fl_display_device_display_device
        return Storage.Integer_Address;
    pragma Import (C, fl_display_device_display_device, "fl_display_device_display_device");
    pragma Inline (fl_display_device_display_device);




    --  Drivers  --

    function fl_surface_device_get_driver
           (S : in Storage.Integer_Address)
        return Storage.Integer_Address;
    pragma Import (C, fl_surface_device_get_driver, "fl_surface_device_get_driver");
    pragma Inline (fl_surface_device_get_driver);




    -------------------
    --  Destructors  --
    -------------------

    procedure Finalize
           (This : in out Display_Device) is
    begin
        if This.Void_Ptr /= Null_Pointer and This.Needs_Dealloc then
            if Release_Current (This) then
                free_fl_display_device (This.Void_Ptr);
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
            return Display_Device is
        begin
            return This : Display_Device do
                This.Void_Ptr := new_fl_display_device (Wrapper (Graphics).Void_Ptr);
                This.My_Driver := Graphics'Unchecked_Access;
            end return;
        end Create;

    end Forge;




    -------------------------
    --  Static Attributes  --
    -------------------------

    Platform_Display  : aliased Display_Device;
    Platform_Graphics : aliased FLTK.Devices.Graphics.Graphics_Driver;




    -----------------------
    --  API Subprograms  --
    -----------------------

    --  Displays  --

    function Get_Platform_Display
        return Display_Device_Reference is
    begin
        return Ref : Display_Device_Reference (Data => Platform_Display'Access);
    end Get_Platform_Display;


begin


    Platform_Display.Void_Ptr := fl_display_device_display_device;
    Platform_Display.Needs_Dealloc := False;

    Wrapper (Platform_Graphics).Void_Ptr :=
        fl_surface_device_get_driver (Platform_Display.Void_Ptr);
    Wrapper (Platform_Graphics).Needs_Dealloc := False;

    Platform_Display.My_Driver := Platform_Graphics'Access;


end FLTK.Devices.Surface.Display;


