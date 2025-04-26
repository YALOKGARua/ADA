with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Security; use Security;

procedure Main is
   Choice : Integer := 0;
   Is_Logged_In : Boolean := False;
   System_Running : Boolean := True;

   procedure Show_Menu is
   begin
      Put_Line("=== System Access Control ===");
      if Get_Status = Locked then
         Put_Line("1. Login");
      else
         Put_Line("1. View System Status");
         Put_Line("2. Perform Action (View Data)");
         Put_Line("3. Logout");
      end if;
      Put_Line("4. Exit");
      Put("Select an option: ");
   end Show_Menu;

begin
   while System_Running loop
      Show_Menu;
      Get(Choice);
      Skip_Line;

      case Choice is
         when 1 =>
            if Get_Status = Locked then
               Check_Password(Is_Logged_In);
               if Is_Logged_In then
                  Put_Line("Access granted! Welcome to the system.");
               else
                  Put_Line("Access denied! Incorrect password.");
                  Put_Line("Attempts made: " & Natural'Image(Get_Attempts));
               end if;
            else
               Put_Line("System Status: Unlocked");
               Put_Line("Login Attempts: " & Natural'Image(Get_Attempts));
            end if;

         when 2 =>
            if Get_Status = Unlocked then
               Put_Line("Viewing secure data...");
               Put_Line("Data: [Classified Information]");
            else
               Put_Line("Please login first.");
            end if;

         when 3 =>
            if Get_Status = Unlocked then
               Reset;
               Is_Logged_In := False;
               Put_Line("Logged out successfully.");
            else
               Put_Line("Please login first.");
            end if;

         when 4 =>
            System_Running := False;
            Put_Line("Exiting system. Goodbye!");

         when others =>
            Put_Line("Invalid option. Please try again.");
      end case;

   end loop;

exception
   when Program_Error =>
      Put_Line("System shutdown due to security violation.");
      System_Running := False;
end Main;