package Corporation is
   
   -- Records
   type Corpo_Task is record
      First_Arg : Integer;
      Second_Arg : Integer;
      Operator   : Character;
   end record;
   
   type Product is record
      Product_Value : Integer;
   end record;
   
   -- Arrays
   type Tasks_To_Do is array (Integer range<>) of Corpo_Task;
   type Products is array (Integer range<>) of Product;
   
   --  function Get_Boss_Delay return Duration;
   procedure Production;
end Corporation;
