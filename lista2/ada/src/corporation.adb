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
           
      package Tasks_To_Do_Vectors is new Ada.Containers.Vectors 
        (Index_Type => Natural,
         Element_Type => Corpo_Task);
      use Tasks_To_Do_Vectors;
      
      package Products_Vectors is new Ada.Containers.Vectors
        (Index_Type => Natural,
         Element_Type => Product);
      use Products_Vectors;
      
      -- Tasks
      task type Boss;
      task type Listener;
      task type Worker (ID : Integer) is 
         entry Notifications_Entry (Notification : Boolean);
      end Worker;   
      type Worker_Access is access Worker;
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
      
      -- Array of workers
      Workers : array (0 .. Num_Of_Workers) of access Worker;
      
      -- Array of clients
      Clients : array (0 .. Num_Of_Clients) of access Client;

      -- Machines
      task type Adding_Machine(Machine_ID: Integer) is 
         entry Task_Stream (Task_To_Do : in Task_For_Machine);
--        private
--           Task_To_Do : Task_For_Machine;
      end Adding_Machine;
     
      task type Multiplying_Machine(Machine_ID : Integer) is 
         entry Task_Stream (Task_To_Do : in Task_For_Machine);
--        private
--           Tasks_To_Do : Task_For_Machine;
      end Multiplying_Machine;
      
      task body Adding_Machine is 
         T : Task_For_Machine;
      begin
         loop
            accept Task_Stream (Task_To_Do : in Task_For_Machine) do
               T := Task_To_Do;
            end Task_Stream;
            
            delay Adding_Machine_Delay;
            T.Task_From_Worker.Result := T.Task_From_Worker.First_Arg + T.Task_From_Worker.Second_Arg;
            T.Task_From_Worker.Machine_ID := Machine_ID;
            
--              Workers(T.Worker_ID).Notifications_Entry(True);
            select
               Workers(T.Worker_ID).Notifications_Entry(True);
            or
               delay 0.1;
            end select;
         end loop;
      end Adding_Machine;
      
      task body Multiplying_Machine is
         T: Task_For_Machine;
      begin
         loop
            accept Task_Stream (Task_To_Do : in Task_For_Machine) do
               T := Task_To_Do;
            end Task_Stream;
            
            delay Multiplying_Machine_Delay;
            T.Task_From_Worker.Result := T.Task_From_Worker.First_Arg * T.Task_From_Worker.Second_Arg;
            T.Task_From_Worker.Machine_ID := Machine_ID;
            
--              Workers(T.Worker_ID).Notifications_Entry(True);
            select
               Workers(T.Worker_ID).Notifications_Entry(True);
            or 
               delay 0.1;
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
         
      Magazine : Magazine_Server;
      
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
      begin
         Random_Type := Random_Generator(0, 1);
         
         if Random_Type = 0 then
            Worker_Type := "patient  ";
         else
            Worker_Type := "impatient";
         end if;
         
	 loop
	    List.Get_Task (New_Task);
            if Worker_Type = "impatient" then
               case New_Task.Operator is
                  when '+' =>
                     Result_Found := False;
                     
                     while not Result_Found loop
                        for I in Adding_Machines_Array'Range loop
                           New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                           Task_To_Do := (New_Task_Pointer, ID);
                           Adding_Machines_Array (I).Task_Stream(Task_To_Do);
                        
                           select
                              accept Notifications_Entry (Notification : in Boolean) do
                                 Result := New_Task_Pointer.Result;
                                 Result_Found := True;
                              end Notifications_Entry;
                           or
                              delay Impatient_Worker_Delay;
                           end select;
                           exit when Result_Found;
                        end loop;
                     end loop;
                  when '*' =>
                     Result_Found := False;
                     
                     while not Result_Found loop
                        for I in Multiplying_Machines_Array'Range loop
                           New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                           Task_To_Do := (New_Task_Pointer, ID);
                           Multiplying_Machines_Array (I).Task_Stream(Task_To_Do);
                           
                           select 
                              accept Notifications_Entry (Notification : in Boolean) do
                                 Result := New_Task_Pointer.Result;
                                 Result_Found := True;
                              end Notifications_Entry;
                           or
                              delay Impatient_Worker_Delay;
                           end select;
                           exit when Result_Found;
                        end loop;
                     end loop;
                  when others =>
                     Result := 0;
               end case;
            else 
               case New_Task.Operator is
                  when '+' =>
                     Index := Random_Generator(0, Num_Of_Adding_Machines);
                     
                     New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                     Task_To_Do := (New_Task_Pointer, ID);
                     Adding_Machines_Array (Index).Task_Stream(Task_To_Do);
                     Result_Found := False;
                     
                     while not Result_Found loop
                        select
                           accept Notifications_Entry (Notification : in Boolean) do
                              Result := New_Task_Pointer.Result;
                              Result_Found := True;
                           end Notifications_Entry;
                        end select;
                     end loop;
                  when '*' =>
                     
                     Index := Random_Generator(0, Num_Of_Multiplying_Machines);
                     New_Task_Pointer := new Corpo_Task'(New_Task.First_Arg, New_Task.Second_Arg, New_Task.Operator, New_Task.Result, New_Task.Machine_ID);
                     Task_To_Do := (New_Task_Pointer, ID);
                     Multiplying_Machines_Array (Index).Task_Stream(Task_To_Do);
                     
                     Result_Found := False;
                     
                     while not Result_Found loop
                        select
                           accept Notifications_Entry (Notification : in Boolean) do
                              Result := New_Task_Pointer.Result;
                              Result_Found := True;
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
		& New_Task.Operator & New_Task.Second_Arg'Image & " = " & Result'Image & " using machine " & New_Task.Machine_ID'Image);
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
	 
	 loop
	    Get (Command);
	    
	    case Command is 
	    when 't' =>
	       List.Print_Tasks;
	    when 'm' =>
	       Magazine.Print_Products;
	    when others =>
	       Put_Line ("Unkown command");
	    end case;
	 end loop;
      end Listener;
     
      New_Boss : Boss;
      -- New_Worker : Worker_Access;
      New_Client : Client_Access;
      New_Listener : Listener_Access;
      
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
         -- Clients(I) := new Client (I);
         New_Client := new Client (I);
      end loop;
   end Production;
end Corporation;
