with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Parameters; use Parameters;
with Operations; use Operations;
with Ada.Containers; use Ada.Containers;
with Ada.Containers.Vectors;
with Ada.Strings.Fixed;
package body Corporation is
   function Get_Boss_Delay return Duration is
      G      : Ada.Numerics.Float_Random.Generator;
      Result : Float;
   begin
      Ada.Numerics.Float_Random.Reset (G);
      Result := Ada.Numerics.Float_Random.Random (G);
      return Duration (Result);
   end Get_Boss_Delay;
   
   procedure Production is
      
      function Random_Generator(Lower_Bound : Integer; Upper_Bound : Integer) return Integer is
         subtype Random_Range is Integer range Lower_Bound .. Upper_Bound;
         
         package R is new Ada.Numerics.Discrete_Random(Random_Range);
         use R;
         
         G : Generator;
         Random_Value : Integer;
      begin
         Reset(G);
         Random_Value := Random(G);
         return Random_Value;
      end Random_Generator;
      
      function Float_Random_Generator return Float is
         G : Ada.Numerics.Float_Random.Generator;
         X : Ada.Numerics.Float_Random.Uniformly_Distributed;
      begin
         Ada.Numerics.Float_Random.Reset (G);
         X := Ada.Numerics.Float_Random.Random (G);
         return X;
      end Float_Random_Generator;
           
      package Tasks_To_Do_Vectors is new Ada.Containers.Vectors 
        (Index_Type => Natural,
         Element_Type => Corpo_Task);
      use Tasks_To_Do_Vectors;
      
      package Products_Vectors is new Ada.Containers.Vectors
        (Index_Type => Natural,
         Element_Type => Product);
      use Products_Vectors;
      
      package Reports_Vector is new Ada.Containers.Vectors
        (Index_Type  => Natural,
         Element_Type => Breakdown_Report);
      use Reports_Vector;
      
      -- Tasks
      task type Boss;
      task type Listener;
      task type Worker (ID : Integer) is 
         entry Notifications_Entry (Notification : Boolean);
         entry Worker_Info_Request;
      end Worker;   
      task type Repairer(ID : Integer);
      
      type Worker_Access is access Worker;
      type Repairer_Access is access Repairer;
      task type Client (ID : Integer);
      type Client_Access is access Client;
      type Listener_Access is access Listener;
   
      protected type List_Server is
	 entry Add_New_Task (New_Task : in Corpo_Task);
	 entry Get_Task (New_Task : out Corpo_Task);
	 procedure Print_Tasks;
      private
	 Elements : Integer := 0;
         Tasks_List : Tasks_To_Do_Vectors.Vector;
      end List_Server;
      
      protected type Magazine_Server is
	 entry Add_New_Product (New_Product : in Product);
	 entry Get_Product (New_Product : out Product);
	 procedure Print_Products;
      private
	 Elements : Integer := 0; 
	 Products_List : Products_Vectors.Vector;
      end Magazine_Server;
      
      protected type Repair_Service is
         entry Report_Breakdown(Report : in Breakdown_Report);
         entry Get_Repair_Task(Repair : out Repair_Task);
         entry Confirm_Repair(Confirmation : in Repair_Confirmation);
         function Contains_Report(V : Reports_Vector.Vector; Report : Breakdown_Report) return Boolean;
         function Find_Position(V : Reports_Vector.Vector; Confirmation : Repair_Confirmation) return Natural;
      private
         Machines_To_Repair : Reports_Vector.Vector;
         Machines_In_Repair : Reports_Vector.Vector;
         Position : Natural;
      end Repair_Service;
      
      -- Array of workers
      Workers : array (0 .. Num_Of_Workers) of access Worker;
      
      -- Machines
      task type Adding_Machine(Machine_ID: Integer) is 
         entry Task_Stream (Task_To_Do : in Task_For_Machine);
         entry Repair;
      end Adding_Machine;
     
      task type Multiplying_Machine(Machine_ID : Integer) is 
         entry Task_Stream (Task_To_Do : in Task_For_Machine);
         entry Repair;
      end Multiplying_Machine;
      
      task body Adding_Machine is 
         T : Task_For_Machine;
         Is_Broken : Boolean := False;
         R : Float;
      begin
         loop
            select
               accept Task_Stream (Task_To_Do : in Task_For_Machine) do
                  T := Task_To_Do;
               end Task_Stream;
               delay Adding_Machine_Delay;
               if Is_Broken then
                  T.Task_From_Worker.Result := -1;
               else 
                  T.Task_From_Worker.Result := T.Task_From_Worker.First_Arg + T.Task_From_Worker.Second_Arg;
               end if;
               
               T.Task_From_Worker.Machine_ID := Machine_ID;
               select
                  Workers(T.Worker_ID).Notifications_Entry(True);
               or
                  delay 0.1;
               end select;
               
               R := Float_Random_Generator;
               
               if R <= Breakdown_Probabilty then
                  Is_Broken := True;
               end if;
               
            or
               accept Repair  do
                  Is_Broken := False;
               end Repair; 
            end select;
         end loop;
      end Adding_Machine;
      
      task body Multiplying_Machine is
         T: Task_For_Machine;
         Is_Broken : Boolean := False;
         R : Float;
      begin
         loop
            select
               accept Task_Stream (Task_To_Do : in Task_For_Machine) do
                  T := Task_To_Do;
               end Task_Stream;
               delay Multiplying_Machine_Delay;
               
               if Is_Broken then
                  T.Task_From_Worker.Result := -1;
               else
                  T.Task_From_Worker.Result := T.Task_From_Worker.First_Arg * T.Task_From_Worker.Second_Arg;
               end if;
               
               T.Task_From_Worker.Machine_ID := Machine_ID;
            
               select
                  Workers(T.Worker_ID).Notifications_Entry(True);
               or 
                  delay 0.1;
               end select;
               
               R := Float_Random_Generator;
               if R <= Breakdown_Probabilty then
                  Is_Broken := True;
               end if; 
            or
               accept Repair  do
                  Is_Broken := False;
               end Repair; 
            end select;


         end loop;
      end Multiplying_Machine;
      
      -- Machine arrays
      Adding_Machines_Array : array (0 .. Num_Of_Adding_Machines) of access Adding_Machine;
      Multiplying_Machines_Array : array (0 .. Num_Of_Multiplying_Machines) of access Multiplying_Machine;
      
      protected body List_Server is 
	 entry Add_New_Task (New_Task : in Corpo_Task)  
	      when Size_Of_Task_List - Elements > 0 is
	 begin
	    Tasks_List.Append(New_Task);
	    Elements := Integer(Tasks_List.Length);
	 end Add_New_Task;
	 
         entry Get_Task (New_Task : out Corpo_Task) 
	      when Elements > 0 is
	 begin
            New_Task := Tasks_List.First_Element;
            Tasks_List.Delete_First;
	    Elements := Integer(Tasks_List.Length);
	 end Get_Task;
	 
         procedure Print_Tasks is 
            Index : Integer := 0;
	 begin
	    if Elements = 0 then
	       Put_Line ("List of tasks is empty!");
	    else
	       Put_Line ("Tasks: ");
	       for E of Tasks_List loop
                  Put_Line(Index'Image & ": " & E.First_Arg'Image & E.Operator & E.Second_Arg'Image);
                  Index := Index + 1;
	       end loop;
	    end if;
	 end Print_Tasks;
      end List_Server;
     
      List : List_Server;
   
      task body Boss is 
	 subtype Random_Range is Integer range 1 .. 2137;
      
	 package R is new Ada.Numerics.Discrete_Random (Random_Range);
	 use R;
      
	 G : Generator;
      
	 First_Arg : Integer;
	 Second_Arg : Integer;
	 Operator : Character;
	 Operator_Type : Integer;
	 New_Task : Corpo_Task;
      begin
	 Reset (G);
	 
	 loop 
	    First_Arg := Random (G);
	    Second_Arg := Random (G);
      
	    Operator_Type := (abs (First_Arg + Second_Arg)) mod 2;
      
	    case Operator_Type is 
	    when 0 =>
	       Operator := '+';
	    when 1 =>
	       Operator := '*';
	    when others =>
	       Operator := '+';
	    end case;
      
	    New_Task := (First_Arg, Second_Arg, Operator, 0, -1);
	 
	    if Is_Verbose_Mode_ON then
	       Put_Line ("President added new task: " & First_Arg'Image & Operator & Second_Arg'Image);
	    end if;
	 
	    List.Add_New_Task (New_Task);
	    delay Get_Boss_Delay;
	 end loop;
      end Boss;

      protected body Magazine_Server is 
	 entry Add_New_Product (New_Product : in Product)
	      when Size_Of_Magazine - Elements > 0 is
	 begin
            Products_List.Append(New_Product);
            Elements := Integer(Products_List.Length);
	    if Is_Verbose_Mode_ON then
	       Put_Line ("Product was added to magazine with value: " & New_Product.Product_Value'Image);
	    end if;
	    
	 end Add_New_Product;
	 
	 entry Get_Product (New_Product : out Product) 
	      when Elements > 0 is
	 begin
            New_Product := Products_List.First_Element;
            Products_List.Delete_First;
	    Elements := Integer(Products_List.Length);
	 end Get_Product;
	 
         procedure Print_Products is 
            Index : Integer := 0;
	 begin
	    if Elements = 0 then
	       Put_Line ("Magazine is empty!");
	    else
	       Put_Line ("Products: ");
               for E of Products_List loop
                  Put_Line(Index'Image & ": " & E.Product_Value'Image);
                  Index := Index + 1;
               end loop;
	    end if;
	 end Print_Products;
	 
      end Magazine_Server;
         
      protected body Repair_Service is
         entry Report_Breakdown(Report : in Breakdown_Report) 
           when True 
         is
         begin
            if not Contains(Machines_To_Repair, Report) and 
              not Contains(Machines_In_Repair, Report) then
               Machines_To_Repair.Append(Report);
            end if;
            
         end Report_Breakdown;
         
         entry Get_Repair_Task(Repair : out Repair_Task)
           when True
         is
            Report : Breakdown_Report;
            Task_For_Repairer : Repair_Task;
         begin
            if Machines_To_Repair.Length /= 0 then
               Report := Machines_To_Repair.First_Element;
               Machines_To_Repair.Delete_First;
               Task_For_Repairer := (Report.Machine_ID, Report.Machine_Type);
               Repair := Task_For_Repairer;
               Machines_In_Repair.Append(Report);
            else
               Repair := (-1, '/');
            end if;
         end Get_Repair_Task;
         
         entry Confirm_Repair(Confirmation : in Repair_Confirmation)
           when True
         is
         begin
            Position := Find_Position(Machines_In_Repair, Confirmation);
            
            if Position /= 1000 then
               Machines_In_Repair.Delete (Position);
            end if;

         end Confirm_Repair;
         
         function Contains_Report(V : Reports_Vector.Vector; Report : Breakdown_Report) return Boolean
         is
         begin
            for R in V.First_Index .. V.Last_Index loop
               if V(R).Machine_ID = Report.Machine_ID and V(R).Machine_Type = Report.Machine_Type then
                  return True;
               end if;
            end loop;
            return False;
         end Contains_Report;
         
         function Find_Position(V : Reports_Vector.Vector; Confirmation : Repair_Confirmation) return Natural
         is
         begin
            for R in V.First_Index .. V.Last_Index loop
               if V(R).Machine_ID = Confirmation.Machine_ID and V(R).Machine_Type = Confirmation.Machine_Type then
                  return R;
               end if;
            end loop;
            return 1000;
         end Find_Position;
         
      end Repair_Service;
      
      Magazine : Magazine_Server;
      Service : Repair_Service;
      
      task body Repairer is
         Request : Repair_Task;
         Machine_ID : Integer;
         Machine_Type : Character;
         Confirmation : Repair_Confirmation;
      begin
         loop
            Service.Get_Repair_Task(Request);
            Machine_ID := Request.Machine_ID;
            Machine_Type := Request.Machine_Type;
            
            if Machine_ID /= -1 then
               delay Repirer_Delay;
               if Machine_Type = '+' then
                  Adding_Machines_Array (Machine_ID).Repair;
               else
                  Multiplying_Machines_Array (Machine_ID).Repair;
               end if;
               Confirmation := (Machine_ID, Machine_Type);
               Service.Confirm_Repair(Confirmation);
               
               Put_Line ("***Repairer " & ID'Image & " repaired " & Machine_Type & " machine with ID " & Machine_ID'Image);
            end if;
         end loop;
      end Repairer;
      
      task body Worker is
         subtype Random_Range is Integer range 0 .. 1;
         Index: Integer;
         Result : Integer;
         New_Task : Corpo_Task;
         New_Task_Pointer : access Corpo_Task;
         New_Product : Product;
         Task_To_Do : Task_For_Machine;
         Worker_Type : String(1..9);
         Random_Type : Integer;
         Result_Found : Boolean;
         Tasks_Done : Integer := 0;
         Task_Accepted : Boolean;
         Machine_ID : Integer := -1;
         Report : Breakdown_Report;
      begin
         Random_Type := Random_Generator(0, 1);
         
         if Random_Type = 0 then
            Worker_Type := "patient  ";
         else
            Worker_Type := "impatient";
         end if;

         loop
            select 
               accept Worker_Info_Request  do
                  Put_Line ("Worker " & ID'Image & "which is " & Worker_Type & "has already done " & Tasks_Done'Image);
               end Worker_Info_Request;
            else
               null;
            end select;
            
            List.Get_Task (New_Task);
            if Worker_Type = "impatient" then
               case New_Task.Operator is
                  when '+' =>
                     Result_Found := False;
                     Task_Accepted := False;
                     
                     while not Result_Found loop
                        for I in Adding_Machines_Array'Range loop
                           New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                           Task_To_Do := (New_Task_Pointer, ID);
                           select 
                              Adding_Machines_Array (I).Task_Stream(Task_To_Do);
                              Task_Accepted := True;
                           or
                              delay Impatient_Worker_Delay;
                           end select;
                           
                           if Task_Accepted then
                              accept Notifications_Entry (Notification : in Boolean) do
                                 Result := New_Task_Pointer.Result;
                                 Machine_ID := New_Task_Pointer.Machine_ID;
                                 
                                 -- Send Report
                                 if Result = -1 then
                                    Report := (Machine_ID, New_Task.Operator);
                                    Service.Report_Breakdown(Report);
                                 else
                                     Result_Found := True;
                                    Tasks_Done := Tasks_Done + 1;
                                 end if;
                              end Notifications_Entry;
                           end if;
                           exit when Result_Found;
                        end loop;
                     end loop;
                  when '*' =>
                     Result_Found := False;
                     Task_Accepted := True;
                     
                     while not Result_Found loop
                        for I in Multiplying_Machines_Array'Range loop
                           New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                           Task_To_Do := (New_Task_Pointer, ID);
                           
                           select 
                              Multiplying_Machines_Array (I).Task_Stream(Task_To_Do);
                              Task_Accepted := True;
                           or
                              delay Impatient_Worker_Delay;
                           end select;
                           
                           if Task_Accepted then
                              accept Notifications_Entry (Notification : in Boolean) do
                                 Result := New_Task_Pointer.Result;
                                 Machine_ID := New_Task_Pointer.Machine_ID;
                                 
                                 -- Send Report
                                 if Result = -1 then
                                    Report := (Machine_ID, New_Task.Operator);
                                    Service.Report_Breakdown(Report);
                                 else
                                    Result_Found := True;
                                    Tasks_Done := Tasks_Done + 1;
                                 end if;
                                 
                              end Notifications_Entry;
                           end if;
                           exit when Result_Found;
                        end loop;
                     end loop;
                  when others =>
                     Result := 0;
               end case;
            else 
               case New_Task.Operator is
                  when '+' =>
                     
                     Result_Found := False;
                     
                     while not Result_Found loop
                        Index := Random_Generator(0, Num_Of_Adding_Machines);
                     
                        New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                        Task_To_Do := (New_Task_Pointer, ID);
                        Adding_Machines_Array (Index).Task_Stream(Task_To_Do);
                        select
                           accept Notifications_Entry (Notification : in Boolean) do
                              Result := New_Task_Pointer.Result;
                              Machine_ID := New_Task_Pointer.Machine_ID;
                              
                              -- Send Report
                              if Result = -1 then
                                 Report := (Machine_ID, New_Task.Operator);
                                 Service.Report_Breakdown(Report);
                              else
                                 Result_Found := True;
                                 Tasks_Done := Tasks_Done + 1;
                              end if;
                           end Notifications_Entry;
                        end select;
                     end loop;
                  when '*' =>
                     Result_Found := False;
                     
                     while not Result_Found loop
                        Index := Random_Generator(0, Num_Of_Multiplying_Machines);
                     New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                     Task_To_Do := (New_Task_Pointer, ID);
                     Multiplying_Machines_Array (Index).Task_Stream(Task_To_Do);
                        select
                           accept Notifications_Entry (Notification : in Boolean) do
                              Result := New_Task_Pointer.Result;
                              Machine_ID := New_Task_Pointer.Machine_ID;
                              
                              -- Send Report
                              if Result = -1 then
                                 Report := (Machine_ID, New_Task.Operator);
                                 Service.Report_Breakdown(Report);
                              else
                                 Result_Found := True;
                                 Tasks_Done := Tasks_Done + 1;
                              end if;
                              
                           end Notifications_Entry;
                        end select;
                     end loop;
                  when others =>
                     Result := 0;
               end case;
            end if;

	    New_Product := (Product_Value => Result);
	    
	    if Is_Verbose_Mode_ON then
	       Put_Line ("Worker " & ID'Image & " which is " & Worker_Type & " has already done task : " & New_Task.First_Arg'Image 
		& New_Task.Operator & New_Task.Second_Arg'Image & " = " & Result'Image & " using machine " & Machine_ID'Image);
	    end if;
	   
	    Magazine.Add_New_Product(New_Product);
	    delay Worker_Delay;
	 end loop;
      end Worker;
      
      task body Client is 
	 New_Product : Product;
      begin
	 loop
	    Magazine.Get_Product (New_Product);
	    
	    if Is_Verbose_Mode_ON then
	       Put_Line ("Client " & ID'Image 
		  & " has already bought product with value: " & New_Product.Product_Value'Image);
	    end if;
	    
	    delay Client_Delay;
	 end loop;
      end Client;
      
      task body Listener is 
	 Command : Character;
      begin 
	 Put_Line ("Usage (avaiable commands): ");
	 Put_Line ("m - print list of products stored in magazine");
         Put_Line ("t - print list of tasks to do");
         Put_Line ("W - print info about workers");
	 
	 loop
	    Get (Command);
	    
	    case Command is 
	    when 't' =>
	       List.Print_Tasks;
	    when 'm' =>
               Magazine.Print_Products;
            when 'w' =>
               for I in Workers'Range loop
                  Workers(I).Worker_Info_Request;
               end loop;
	    when others =>
	       Put_Line ("Unkown command");
	    end case;
	 end loop;
      end Listener;
      
      New_Boss : Boss;
      New_Client : Client_Access;
      New_Listener : Listener_Access;
      New_Repairer : Repairer_Access;
      
   begin
      if not Is_Verbose_Mode_ON then
	 New_Listener := new Listener;
      end if;
      
      for I in 0 .. Num_Of_Adding_Machines loop
         Adding_Machines_Array (I) := new Adding_Machine (I);
      end loop;
      
      for I in 0 .. Num_Of_Multiplying_Machines loop
         Multiplying_Machines_Array (I) := new Multiplying_Machine (I);
      end loop;
      
      for I in 0 .. Num_Of_Workers loop
	 Workers (I) := new Worker (I);
      end loop;
      
      for I in 0 .. Num_Of_Clients loop
         New_Client := new Client (I);
      end loop;
      
      for I in 0 .. Num_Of_Repairers loop
         New_Repairer := new Repairer (I);
      end loop;
      
   end Production;
end Corporation;
