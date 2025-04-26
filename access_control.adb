with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

procedure Access_Control is
   Correct_Password : constant String := "Secure123";
   User_Input : Unbounded_String;
   Password : String (1 .. 50);
   Last : Natural;

begin
   Put_Line("Enter the password to access the system:");
   Get_Line(Password, Last);
   User_Input := To_Unbounded_String(Password(1 .. Last));

   if To_String(User_Input) = Correct_Password then
      Put_Line("Access granted! Welcome to the system.");
   else
      Put_Line("Access denied! Incorrect password.");
      raise Program_Error with "Unauthorized access attempt.";
   end if;

exception
   when Program_Error =>
      Put_Line("System shutdown due to security violation.");
end Access_Control;