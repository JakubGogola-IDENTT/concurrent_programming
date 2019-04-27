package Parameters is

   -- Sizes
   Size_Of_Task_List : constant Integer := 8;
   Size_Of_Magazine  : constant Integer := 10;
   
   -- Delays
   Worker_Delay      : constant Duration := 3.5;
   Client_Delay      : constant Duration := 8.0;
   
   
   -- Numbers
   Num_Of_Workers    : constant Integer := 4;
   Num_Of_Clients    : constant Integer := 6;
   
   -- Verbose mode flag
   Is_Verbose_Mode_ON : Boolean := False;

end Parameters;
