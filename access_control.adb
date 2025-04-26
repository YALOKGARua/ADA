with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Security; use Security;

procedure Access_Control is
   Correct_Password : constant String := "Secure123";
   User_Input : Unbounded_String;
   Password : String (1 .. 50);
   Last : Natural;
   Username : String (1 .. 50);
   Is_Logged_In : Boolean := False;
   Current_Role : User_Role := Guest;
   Valid : Boolean;
   Two_Factor_Code : String (1 .. 6);
   Last_Code : Natural;

   procedure Perform_Admin_Action is
   begin
      if Get_Role = Admin then
         Put_Line("Performing admin action...");
      else
         Put_Line("Admin access required.");
      end if;
   end Perform_Admin_Action;

   procedure View_User_Data is
   begin
      if Get_Role in User | Admin then
         Put_Line("User data: [Profile Information]");
      else
         Put_Line("User access required.");
      end if;
   end View_User_Data;

   procedure Guest_Access is
   begin
      Put_Line("Guest access: Limited functionality.");
   end Guest_Access;

begin
   Initialize_System;
   Put_Line("Enter username:");
   Get_Line(Username, Last);
   Set_Username(Username(1 .. Last));
   Put_Line("Enter the password to access the system:");
   Get_Line(Password, Last);
   User_Input := To_Unbounded_String(Password(1 .. Last));
   Validate_Password_Strength(Password(1 .. Last), Valid);

   if Valid and then To_String(User_Input) = Correct_Password then
      Check_Password(Is_Logged_In, Current_Role);
      if Is_Logged_In then
         Put_Line("Access granted! Welcome to the system.");
         Start_Session;
         Log_Access_Attempt(Get_Username, True);
         Update_Login_Timestamp;
         if Is_Two_Factor_Enabled then
            Generate_Two_Factor_Code;
            Put_Line("Enter two-factor code:");
            Get_Line(Two_Factor_Code, Last_Code);
            Verify_Two_Factor_Code(Two_Factor_Code(1 .. Last_Code), Valid);
            if not Valid then
               Put_Line("Invalid two-factor code.");
               raise Program_Error with "Two-factor authentication failed.";
            end if;
            Expire_Two_Factor_Code;
         end if;
         case Current_Role is
            when Admin =>
               Perform_Admin_Action;
            when User =>
               View_User_Data;
            when Guest =>
               Guest_Access;
         end case;
      else
         Put_Line("Access denied! Incorrect password.");
         Log_Access_Attempt(Get_Username, False);
         Increment_Failed_Logins;
         Check_Login_Threshold;
      end if;
   else
      Put_Line("Access denied! Invalid password format.");
      Log_Access_Attempt(Get_Username, False);
      Increment_Failed_Logins;
      Check_Login_Threshold;
   end if;

   if Is_Session_Valid then
      Put_Line("Session active. Token: " & Get_Session_Token);
      Put_Line("Last login: " & Get_Last_Login);
      Put_Line("Successful logins: " & Natural'Image(Get_Successful_Logins));
      Put_Line("Failed logins: " & Natural'Image(Get_Failed_Logins));
      Put_Line("Audit entries: " & Natural'Image(Get_Audit_Entries));
      Put_Line("Session events: " & Natural'Image(Get_Session_Event_Count));
      Put_Line("System mode: " & Get_System_Mode);
      Put_Line("Security level: " & Natural'Image(Get_Security_Level));
      Extend_Session;
   else
      Put_Line("Session invalid or expired.");
      End_Session;
   end if;

   if Is_Lockout_Active then
      Put_Line("System locked due to excessive attempts.");
      raise Program_Error with "System in lockout state.";
   end if;

exception
   when Program_Error =>
      Put_Line("System shutdown due to security violation.");
      Shutdown_System;
end Access_Control;