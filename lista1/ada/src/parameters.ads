package Parameters is

   -- Sizes
   Size_Of_Task_List : constant Integer := 5;
   Size_Of_Magazine  : constant Integer := 10;
   
   -- Delays
   Worker_Delay      : constant Duration := 1.5;
   Client_Delay      : constant Duration := 2.0;
   Boss_Delay        : constant Duration := 1.0; -- Temporary solution - should be random
   
   
   -- Numbers
   Num_Of_Workers    : constant Integer := 4;
   Num_Of_Clients    : constant Integer := 6;
   
   -- Verbose mode flag
   Is_Verbose_Mode_ON : Boolean := True;

end Parameters;
