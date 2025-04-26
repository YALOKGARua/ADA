package Security is

   type Access_Status is (Locked, Unlocked);

   procedure Check_Password (Success : out Boolean);

   procedure Increment_Attempts;

   function Get_Attempts return Natural;

   procedure Set_Status (New_Status : Access_Status);

   function Get_Status return Access_Status;

   procedure Reset;

private
   Max_Attempts : constant Natural := 3;
end Security;