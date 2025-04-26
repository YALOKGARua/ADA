with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package body Security is

   Correct_Password : constant String := "Secure123";
   Current_Attempts : Natural := 0;
   Current_Status : Access_Status := Locked;

   procedure Check_Password (Success : out Boolean) is
      User_Input : Unbounded_String;
      Password : String (1 .. 50);
      Last : Natural;
   begin
      Put_Line("Enter password:");
      Get_Line(Password, Last);
      User_Input := To_Unbounded_String(Password(1 .. Last));

      if To_String(User_Input) = Correct_Password then
         Success := True;
         Set_Status(Unlocked);
      else
         Success := False;
         Increment_Attempts;
         if Current_Attempts >= Max_Attempts then
            Put_Line("Too many attempts! System locked.");
            raise Program_Error with "Maximum login attempts exceeded.";
         end if;
      end if;
   end Check_Password;

   procedure Increment_Attempts is
   begin
      Current_Attempts := Current_Attempts + 1;
   end Increment_Attempts;

   function Get_Attempts return Natural is
   begin
      return Current_Attempts;
   end Get_Attempts;

   procedure Set_Status (New_Status : Access_Status) is
   begin
      Current_Status := New_Status;
   end Set_Status;

   function Get_Status return Access_Status is
   begin
      return Current_Status;
   end Get_Status;

   procedure Reset is
   begin
      Current_Attempts := 0;
      Current_Status := Locked;
   end Reset;

end Security;