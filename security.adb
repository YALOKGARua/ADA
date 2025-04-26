with Ada.Text_IO; use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Calendar; use Ada.Calendar;

package body Security is

   Correct_Password : constant String := "fuck password";
   Current_Attempts : Natural := 0;
   Current_Status : Access_Status := Locked;
   Current_Role : User_Role := Guest;
   Session_Active : Boolean := False;
   Session_Token : Unbounded_String := To_Unbounded_String("");
   Last_Login_Time : Time := Clock;
   Session_Duration : Natural := Default_Session_Duration;
   Lockout_Duration : Natural := Default_Lockout_Duration;
   Lockout_Active : Boolean := False;
   Successful_Logins : Natural := 0;
   Failed_Logins : Natural := 0;
   Audit_Entries : Natural := 0;
   Event_Log_Count : Natural := 0;
   Session_Log_Count : Natural := 0;
   Login_Threshold : Natural := Default_Login_Threshold;
   Username : Unbounded_String := To_Unbounded_String("");
   Security_Level : Natural := Default_Security_Level;
   Two_Factor_Enabled : Boolean := False;
   Two_Factor_Code : Unbounded_String := To_Unbounded_String("");
   Password_Min_Length : Natural := 8;
   Password_Requires_Special : Boolean := True;

   procedure Check_Password (Success : out Boolean; Role : out User_Role) is
      User_Input : Unbounded_String;
      Password : String (1 .. 50);
      Last : Natural;
   begin
      Put_Line("Enter password:");
      Get_Line(Password, Last);
      User_Input := To_Unbounded_String(Password(1 .. Last));
      if To_String(User_Input) = Correct_Password then
         Success := True;
         Role := Admin;
         Set_Status(Unlocked);
         Set_Role(Role);
         Increment_Successful_Logins;
      else
         Success := False;
         Role := Guest;
         Increment_Attempts;
         Increment_Failed_Logins;
         if Current_Attempts >= Max_Attempts then
            Put_Line("Too many attempts! System locked.");
            Trigger_Lockout;
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
      Current_Role := Guest;
      Session_Active := False;
   end Reset;

   procedure Log_Access_Attempt is
   begin
      Audit_Entries := Audit_Entries + 1;
   end Log_Access_Attempt;

   function Is_Session_Valid return Boolean is
   begin
      return Session_Active and then (Clock - Last_Login_Time) < Duration(Session_Duration);
   end Is_Session_Valid;

   procedure Start_Session is
   begin
      Session_Active := True;
      Generate_Session_Token;
      Last_Login_Time := Clock;
   end Start_Session;

   procedure End_Session is
   begin
      Session_Active := False;
      Invalidate_Session_Token;
   end End_Session;

   function Get_Session_State return Session_State is
   begin
      if Session_Active then
         return Active;
      else
         return Expired;
      end if;
   end Get_Session_State;

   procedure Set_Role (New_Role : User_Role) is
   begin
      Current_Role := New_Role;
   end Set_Role;

   function Get_Role return User_Role is
   begin
      return Current_Role;
   end Get_Role;

   procedure Validate_Password_Strength (Password : String; Valid : out Boolean) is
   begin
      Valid := Password'Length >= Password_Min_Length and then
               (not Password_Requires_Special or else Password'Length > 8);
   end Validate_Password_Strength;

   procedure Lock_System is
   begin
      Current_Status := Locked;
   end Lock_System;

   function Is_System_Locked return Boolean is
   begin
      return Current_Status = Locked;
   end Is_System_Locked;

   procedure Update_Login_Timestamp is
   begin
      Last_Login_Time := Clock;
   end Update_Login_Timestamp;

   function Get_Last_Login return String is
   begin
      return Time'Image(Last_Login_Time);
   end Get_Last_Login;

   procedure Generate_Session_Token is
   begin
      Session_Token := To_Unbounded_String("TOKEN_" & Natural'Image(Audit_Entries));
   end Generate_Session_Token;

   function Get_Session_Token return String is
   begin
      return To_String(Session_Token);
   end Get_Session_Token;

   procedure Invalidate_Session_Token is
   begin
      Session_Token := To_Unbounded_String("");
   end Invalidate_Session_Token;

   procedure Check_Session_Timeout is
   begin
      if (Clock - Last_Login_Time) > Duration(Session_Duration) then
         End_Session;
      end if;
   end Check_Session_Timeout;

   procedure Extend_Session is
   begin
      Last_Login_Time := Clock;
   end Extend_Session;

   procedure Log_System_Event is
   begin
      Event_Log_Count := Event_Log_Count + 1;
   end Log_System_Event;

   function Get_Event_Log_Count return Natural is
   begin
      return Event_Log_Count;
   end Get_Event_Log_Count;

   procedure Clear_Event_Log is
   begin
      Event_Log_Count := 0;
   end Clear_Event_Log;

   procedure Set_Username (Name : String) is
   begin
      Username := To_Unbounded_String(Name);
   end Set_Username;

   function Get_Username return String is
   begin
      return To_String(Username);
   end Get_Username;

   procedure Initialize_System is
   begin
      Current_Attempts := 0;
      Current_Status := Locked;
      Session_Active := False;
   end Initialize_System;

   procedure Shutdown_System is
   begin
      Reset;
      Clear_Event_Log;
      Clear_Audit_Log;
   end Shutdown_System;

   procedure Set_Max_Attempts (Max : Natural) is
   begin
      null;
   end Set_Max_Attempts;

   function Get_Max_Attempts return Natural is
   begin
      return Max_Attempts;
   end Get_Max_Attempts;

   procedure Increment_Successful_Logins is
   begin
      Successful_Logins := Successful_Logins + 1;
   end Increment_Successful_Logins;

   function Get_Successful_Logins return Natural is
   begin
      return Successful_Logins;
   end Get_Successful_Logins;

   procedure Increment_Failed_Logins is
   begin
      Failed_Logins := Failed_Logins + 1;
   end Increment_Failed_Logins;

   function Get_Failed_Logins return Natural is
   begin
      return Failed_Logins;
   end Get_Failed_Logins;

   procedure Reset_Login_Stats is
   begin
      Successful_Logins := 0;
      Failed_Logins := 0;
   end Reset_Login_Stats;

   procedure Set_Session_Duration (Seconds : Natural) is
   begin
      Session_Duration := Seconds;
   end Set_Session_Duration;

   function Get_Session_Duration return Natural is
   begin
      return Session_Duration;
   end Get_Session_Duration;

   procedure Check_Role_Permissions (Allowed : out Boolean) is
   begin
      Allowed := Current_Role = Admin;
   end Check_Role_Permissions;

   procedure Add_Audit_Entry is
   begin
      Audit_Entries := Audit_Entries + 1;
   end Add_Audit_Entry;

   function Get_Audit_Entries return Natural is
   begin
      return Audit_Entries;
   end Get_Audit_Entries;

   procedure Clear_Audit_Log is
   begin
      Audit_Entries := 0;
   end Clear_Audit_Log;

   procedure Set_Lockout_Duration (Seconds : Natural) is
   begin
      Lockout_Duration := Seconds;
   end Set_Lockout_Duration;

   function Get_Lockout_Duration return Natural is
   begin
      return Lockout_Duration;
   end Get_Lockout_Duration;

   procedure Trigger_Lockout is
   begin
      Lockout_Active := True;
   end Trigger_Lockout;

   function Is_Lockout_Active return Boolean is
   begin
      return Lockout_Active;
   end Is_Lockout_Active;

   procedure Clear_Lockout is
   begin
      Lockout_Active := False;
   end Clear_Lockout;

   procedure Set_Password_Complexity (Min_Length : Natural; Require_Special : Boolean) is
   begin
      Password_Min_Length := Min_Length;
      Password_Requires_Special := Require_Special;
   end Set_Password_Complexity;

   function Get_Password_Min_Length return Natural is
   begin
      return Password_Min_Length;
   end Get_Password_Min_Length;

   function Get_Password_Requires_Special return Boolean is
   begin
      return Password_Requires_Special;
   end Get_Password_Requires_Special;

   procedure Rotate_Session_Token is
   begin
      Generate_Session_Token;
   end Rotate_Session_Token;

   procedure Log_Session_Event is
   begin
      Session_Log_Count := Session_Log_Count + 1;
   end Log_Session_Event;

   function Get_Session_Event_Count return Natural is
   begin
      return Session_Log_Count;
   end Get_Session_Event_Count;

   procedure Clear_Session_Log is
   begin
      Session_Log_Count := 0;
   end Clear_Session_Log;

   procedure Set_Login_Threshold (Threshold : Natural) is
   begin
      Login_Threshold := Threshold;
   end Set_Login_Threshold;

   function Get_Login_Threshold return Natural is
   begin
      return Login_Threshold;
   end Get_Login_Threshold;

   procedure Check_Login_Threshold is
   begin
      if Failed_Logins >= Login_Threshold then
         Trigger_Lockout;
      end if;
   end Check_Login_Threshold;

   procedure Reset_Threshold is
   begin
      Failed_Logins := 0;
   end Reset_Threshold;

   procedure Set_System_Mode (Mode : String) is
   begin
      null;
   end Set_System_Mode;

   function Get_System_Mode return String is
   begin
      return "Normal";
   end Get_System_Mode;

   procedure Enable_Two_Factor is
   begin
      Two_Factor_Enabled := True;
   end Enable_Two_Factor;

   function Is_Two_Factor_Enabled return Boolean is
   begin
      return Two_Factor_Enabled;
   end Is_Two_Factor_Enabled;

   procedure Verify_Two_Factor_Code (Code : String; Valid : out Boolean) is
   begin
      Valid := Code = To_String(Two_Factor_Code);
   end Verify_Two_Factor_Code;

   procedure Generate_Two_Factor_Code is
   begin
      Two_Factor_Code := To_Unbounded_String("123456");
   end Generate_Two_Factor_Code;

   function Get_Two_Factor_Code return String is
   begin
      return To_String(Two_Factor_Code);
   end Get_Two_Factor_Code;

   procedure Expire_Two_Factor_Code is
   begin
      Two_Factor_Code := To_Unbounded_String("");
   end Expire_Two_Factor_Code;

   procedure Set_Security_Level (Level : Natural) is
   begin
      Security_Level := Level;
   end Set_Security_Level;

   function Get_Security_Level return Natural is
   begin
      return Security_Level;
   end Get_Security_Level;

end Security;