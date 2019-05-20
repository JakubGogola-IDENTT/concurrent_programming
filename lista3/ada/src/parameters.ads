package Parameters is

   -- Sizes
   Size_Of_Task_List : constant Integer := 8;
   Size_Of_Magazine  : constant Integer := 10;
   
   -- Delays
   Worker_Delay      : constant Duration := 3.5;
   Client_Delay      : constant Duration := 8.0;
   Adding_Machine_Delay : constant Duration := 1.0;
   Multiplying_Machine_Delay : constant Duration := 3.0;
   Impatient_Worker_Delay : constant := 0.5;
   Wait_For_Task_Delay : constant := 5.0;
   
   
   -- Numbers
   Num_Of_Workers    : constant Integer := 4;
   Num_Of_Clients    : constant Integer := 6;
   Num_Of_Adding_Machines : constant Integer := 3;
   Num_Of_Multiplying_Machines : constant Integer := 3;
   
   -- Verbose mode flag
   Is_Verbose_Mode_ON : Boolean := True;

end Parameters;
