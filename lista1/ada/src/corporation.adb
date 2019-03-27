with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Parameters; use Parameters;
with Operations; use Operations;

package body Corporation is
   procedure Production is
      
      -- Tasks
      task type Boss;
      task type Worker (ID : Integer);
      task type Client (ID : Integer);
   
      task type List_Server is
	 entry Add_New_Task (New_Task : in Corpo_Task);
	 entry Get_Task (New_Task : out Corpo_Task);
      end List_Server;
      
      task type Magazine_Server is
	 entry Add_New_Product (New_Product : in Product);
	 entry Get_Product (New_Product : out Product);
      end Magazine_Server;
      
      -- Global variables
      
      -- Arrays
      Tasks_List : Tasks_To_Do (0 .. Size_Of_Task_List - 1);
      Products_List : Products (0 .. Size_Of_Magazine - 1);
      
      Is_Verbose_Mode_ON : Boolean := True;
      
      -- Implementations
      
      task body List_Server is 
	 Elements : Integer := 0;
      begin
	 loop
	    select
	       when Size_Of_Task_List - Elements > 0 =>
		  accept Add_New_Task (New_Task : in Corpo_Task) do
		     Tasks_List (Elements) := New_Task;
		     Elements := Elements + 1;
		  end Add_New_Task;
		  
	    or
	       when Elements > 0 =>
		  accept Get_Task (New_Task : out Corpo_Task) do
		     New_Task := Tasks_List (Elements);
		     Elements := Elements - 1;
		  end Get_Task;
	    or
	       terminate;
	    end select;
	    
	 end loop;
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
	    Put_Line ("President added new task: " & First_Arg'Image & Operator'Image & Second_Arg'Image);
	 end if;
	 
	 List.Add_New_Task(New_Task);
      
      end Boss;
      
      task body Magazine_Server is 
	 Elements : Integer := 0;
      begin
	 loop
	    select
	       when Size_Of_Magazine - Elements > 0 =>
		  accept Add_New_Product (New_Product : in Product) do
		     Products_List (Elements) := New_Product;
		     Elements := Elements + 1;
		     
		     if Is_Verbose_Mode_ON then
			Put_Line ("Product was added to magazine with value: " & New_Product.Product_Value'Image);
		     end if;
		     
		     
		  end Add_New_Product;
	    or
	       when Elements > 0 =>
		  accept Get_Product (New_Product : out Product) do
		     New_Product := Products_List (Elements);
		     Elements := Elements - 1;
		  end Get_Product;
	    or
	       terminate;
	    end select;
	 end loop;
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
	       Put_Line ("Wroker has already done task: " & New_Task.First_Arg'Image 
		& New_Task.Operator'Image & New_Task.Second_Arg'Image);
	    end if;
	   
	    Magazine.Add_New_Product(New_Product);
	    
	    --delay Worker_Delay;
	 end loop;
      end Worker;
      
      task body Client is 
	 New_Product : Product;
      begin
	 loop
	    Magazine.Get_Product (New_Product);
	    Put_Line ("Client has already bought product with value: " & New_Product.Product_Value'Image);
	 end loop;
      end Client;
      
   begin
      null;
   end Production;
end Corporation;
