package Corporation is
   
   -- Records
   type Corpo_Task is record
      First_Arg : Integer;
      Second_Arg : Integer;
      Operator   : Character;
      Result : Integer;
      Machine_ID : Integer;
   end record;
   
   type Product is record
      Product_Value : Integer;
   end record;
   
   type Task_For_Machine is record
      Task_From_Worker : access Corpo_Task;
      Worker_ID : Integer;
   end record;
      
   type Breakdown_Report is record
      Machine_ID : Integer;
      Machine_Type : Character;
   end record;
  
   type Repair_Task is record
      Machine_ID : Integer;
      Machine_Type : Character;
   end record;
   
   type Repair_Confirmation is record
      Machine_ID : Integer;
      Machine_Type : Character;
   end record;      
      
   -- Arrays
   type Tasks_To_Do is array (Integer range<>) of Corpo_Task;
   type Products is array (Integer range<>) of Product;
   
   function Get_Boss_Delay return Duration;
   procedure Production;
end Corporation;
