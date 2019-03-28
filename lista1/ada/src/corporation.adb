with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Parameters; use Parameters;
with Operations; use Operations;

package body Corporation is
   function Get_Boss_Delay return Duration is
      G      : Ada.Numerics.Float_Random.Generator;
      Result : Float;
   begin
      Ada.Numerics.Float_Random.Reset (G);
      Result := Ada.Numerics.Float_Random.Random (G);
      --Result := 2.0 * Result + 0.5; 
      return Duration (Result);
   end Get_Boss_Delay;
   
   procedure Production is
      
      -- Tasks
      task type Boss;
      task type Listener;
      task type Worker (ID : Integer);
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
	 Tasks_List : Tasks_To_Do (0 .. Size_Of_Task_List - 1);
      end List_Server;
      
      protected type Magazine_Server is
	 entry Add_New_Product (New_Product : in Product);
	 entry Get_Product (New_Product : out Product);
	 procedure Print_Products;
      private
	 Elements : Integer := 0; 
	 Products_List : Products (0 .. Size_Of_Magazine - 1);
      end Magazine_Server;
      
      protected body List_Server is 
	 entry Add_New_Task (New_Task : in Corpo_Task)  
	      when Size_Of_Task_List - Elements > 0 is
	 begin
	    Tasks_List (Elements) := New_Task;
	    Elements := Elements + 1;
	 end Add_New_Task;
	 
	 entry Get_Task (New_Task : out Corpo_Task) 
	      when Elements > 0 is
	 begin
	    New_Task := Tasks_List (Elements - 1);
	    Elements := Elements - 1;
	 end Get_Task;
	 
	 procedure Print_Tasks is 
	 begin
	    if Elements = 0 then
	       Put_Line ("List of tasks is empty!");
	    else
	       Put_Line ("Tasks: ");
	       for I in Tasks_List'First .. Elements - 1 loop
		  Put_Line (I'Image & ": " & Tasks_List (I).First_Arg'Image & Tasks_List (I).Operator
	      & Tasks_List (I).Second_Arg'Image);
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
      
	    Operator_Type := (abs (First_Arg + Second_Arg)) mod 4;
      
	    case Operator_Type is 
	    when 0 =>
	       Operator := '+';
	    when 1 =>
	       Operator := '-';
	    when 2 =>
	       Operator := '*';
	    when 3 =>
	       Operator := '/';
	    when others =>
	       Operator := '+';
	    end case;
      
	    New_Task := (First_Arg, Second_Arg, Operator);
	 
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
	    Products_List (Elements) := New_Product;
	    Elements := Elements + 1;
	    
	    if Is_Verbose_Mode_ON then
	       Put_Line ("Product was added to magazine with value: " & New_Product.Product_Value'Image);
	    end if;
	    
	 end Add_New_Product;
	 
	 entry Get_Product (New_Product : out Product) 
	      when Elements > 0 is
	 begin
	    New_Product := Products_List (Elements - 1);
	    Elements := Elements - 1;
	 end Get_Product;
	 
	 procedure Print_Products is 
	 begin
	    if Elements = 0 then
	       Put_Line ("Magazine is empty!");
	    else
	       Put_Line ("Products: ");
	       for I in Products_List'First .. Elements - 1 loop
		  Put_Line (I'Image & ": " & Products_List (I).Product_Value'Image);
	       end loop;
	    end if;
	 end Print_Products;
	 
      end Magazine_Server;
         
      Magazine : Magazine_Server;
      
      task body Worker is
	 Result : Integer;
	 New_Task : Corpo_Task;
	 New_Product : Product;
      begin
	 loop
	    List.Get_Task (New_Task);
	    
	    case New_Task.Operator is
	    when '+' =>
	       Result := Add (New_Task.First_Arg, New_Task.Second_Arg);
	    when '-' =>
	       Result := Sub (New_Task.First_Arg, New_Task.Second_Arg);
	    when '*' =>
	       Result := Mul (New_Task.First_Arg, New_Task.Second_Arg);
	    when '/' => 
	       Result := Div (New_Task.First_Arg, New_Task.Second_Arg);
	    when others =>
	       Result := 0;
	    end case;
	    
	    New_Product := (Product_Value => Result);
	    
	    if Is_Verbose_Mode_ON then
	       Put_Line ("Worker " & ID'Image & " has already done task: " & New_Task.First_Arg'Image 
		& New_Task.Operator & New_Task.Second_Arg'Image & " = " & Result'Image);
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
      New_Worker : Worker_Access;
      New_Client : Client_Access;
      New_Listener : Listener_Access;
      
   begin
      if not Is_Verbose_Mode_ON then
	 New_Listener := new Listener;
      end if;
      
      for I in 1 .. Num_Of_Workers loop
	 New_Worker := new Worker (I);
      end loop;
      
      for I in 1 .. Num_Of_Clients loop
	 New_Client := new Client (I);
      end loop;
   end Production;
end Corporation;
