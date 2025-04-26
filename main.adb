with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Security; use Security;

procedure Main is
   Choice : Integer := 0;
   Is_Logged_In : Boolean := False;
   System_Running : Boolean := True;
   Current_Role : User_Role := Guest;
   Username : String (1 .. 50);
   Last : Natural;

   procedure Show_Menu is
   begin
      Put_Line("=== System Access Control ===");
      if Get_Status = Locked then
         Put_Line("1. Login");
         Put_Line("2. Register");
      else
         Put_Line("1. View System Status");
         Put_Line("2. Perform Action (View Data)");
         Put_Line("3. Change Password");
         Put_Line("4. View Audit Log");
         Put_Line("5. Manage Users (Admin)");
         Put_Line("6. Logout");
      end if;
      Put_Line("7. Exit");
      Put("Select an option: ");
   end Show_Menu;

   procedure Register_User is
      Password : String (1 .. 50);
      Valid : Boolean;
   begin
      Put_Line("Enter username:");
      Get_Line(Username, Last);
      Set_Username(Username(1 .. Last));
      Put_Line("Enter new password:");
      Get_Line(Password, Last);
      Validate_Password_Strength(Password(1 .. Last), Valid);
      if Valid then
         Put_Line("User registered successfully.");
      else
         Put_Line("Password does not meet complexity requirements.");
      end if;
   end Register_User;

   procedure Change_Password is
      Password : String (1 .. 50);
      Valid : Boolean;
   begin
      Put_Line("Enter new password:");
      Get_Line(Password, Last);
      Validate_Password_Strength(Password(1 .. Last), Valid);
      if Valid then
         Put_Line("Password changed successfully.");
      else
         Put_Line("Password does not meet complexity requirements.");
      end if;
   end Change_Password;

   procedure View_Audit_Log is
   begin
      if Get_Role = Admin then
         Put_Line("Audit Log Entries: " & Natural'Image(Get_Audit_Entries));
      else
         Put_Line("Access denied. Admin role required.");
      end if;
   end View_Audit_Log;

   procedure Manage_Users is
   begin
      if Get_Role = Admin then
         Put_Line("User Management: [List Users]");
      else
         Put_Line("Access denied. Admin role required.");
      end if;
   end Manage_Users;

begin
   Initialize_System;
   while System_Running loop
      Show_Menu;
      Get(Choice);
      Skip_Line;

      case Choice is
         when 1 =>
            if Get_Status = Locked then
               Check_Password(Is_Logged_In, Current_Role);
               if Is_Logged_In then
                  Put_Line("Access granted! Welcome to the system.");
                  Start_Session;
                  Log_Access_Attempt(Get_Username, True);
                  Update_Login_Timestamp;
               else
                  Put_Line("Access denied! Incorrect password.");
                  Put_Line("Attempts made: " & Natural'Image(Get_Attempts));
                  Log_Access_Attempt(Get_Username, False);
               end if;
            else
               Put_Line("System Status: Unlocked");
               Put_Line("Login Attempts: " & Natural'Image(Get_Attempts));
               Put_Line("Session Token: " & Get_Session_Token);
               Put_Line("Last Login: " & Get_Last_Login);
            end if;

         when 2 =>
            if Get_Status = Locked then
               Register_User;
            else
               Put_Line("Viewing secure data...");
               Put_Line("Data: [Classified Information]");
            end if;

         when 3 =>
            if Get_Status = Unlocked then
               Change_Password;
            else
               Put_Line("Please login first.");
            end if;

         when 4 =>
            if Get_Status = Unlocked then
               View_Audit_Log;
            else
               Put_Line("Please login first.");
            end if;

         when 5 =>
            if Get_Status = Unlocked then
               Manage_Users;
            else
               Put_Line("Please login first.");
            end if;

         when 6 =>
            if Get_Status = Unlocked then
               Reset;
               End_Session;
               Is_Logged_In := False;
               Put_Line("Logged out successfully.");
            else
               Put_Line("Please login first.");
            end if;

         when 7 =>
            System_Running := False;
            Shutdown_System;
            Put_Line("Exiting system. Goodbye!");

         when others =>
            Put_Line("Invalid option. Please try again.");
      end case;

      if Is_Session_Valid then
         Extend_Session;
      else
         Put_Line("Session expired. Please login again.");
         Reset;
         Is_Logged_In := False;
      end if;

      if Is_Lockout_Active then
         Put_Line("System locked due to excessive attempts.");
         System_Running := False;
      end if;

   end loop;

exception
   when Program_Error =>
      Put_Line("System shutdown due to security violation.");
      Shutdown_System;
      System_Running := False;
end Main;