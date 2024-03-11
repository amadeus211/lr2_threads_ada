with Ada.Text_IO; use Ada.Text_IO;

procedure Main is

   Dim : constant Integer := 100000;
   Thread_Num : constant Integer := 2;

   Arr : array(1..Dim) of Integer;
   Min_Element : Integer := Integer'Last;
   Min_Index : Integer := 1;

   procedure Replace_Element  is
   begin
      Arr(100) := -100;
   end Replace_Element;

   procedure Init_Arr is
   begin
      for I in 1..Dim loop
         Arr(I) := I;
      end loop;
      Replace_Element;
   end Init_Arr;

   procedure Part_Min(Start_Index, Finish_Index : in Integer) is
   begin
      for I in Start_Index..Finish_Index loop
         if Arr(I) < Min_Element then
            Min_Element := Arr(I);
            Min_Index := I;
         end if;
      end loop;
   end Part_Min;

   task type Starter_Thread is
      entry Start(Start_Index, Finish_Index : in Integer);
   end Starter_Thread;

   protected Part_Manager is
      procedure Set_Part_Min(Element : in Integer; Index : in Integer);
      entry Get_Min(Element : out Integer; Index : out Integer);
   private
      Tasks_Count : Integer := 0;
      Min_Element1 : Integer := Integer'Last;
      Min_Index1 : Integer := 1;
   end Part_Manager;

   protected body Part_Manager is
      procedure Set_Part_Min(Element : in Integer; Index : in Integer) is
      begin
         if Element < Min_Element1 then
            Min_Element1 := Element;
            Min_Index1 := Index;
         end if;
         Tasks_Count := Tasks_Count + 1;
      end Set_Part_Min;

      entry Get_Min(Element : out Integer; Index : out Integer) when Tasks_Count = Thread_Num is
      begin
         Element := Min_Element1;
         Index := Min_Index1;
      end Get_Min;

   end Part_Manager;

   task body Starter_Thread is
      Start_Index, Finish_Index : Integer;
   begin
      accept Start(Start_Index, Finish_Index : in Integer) do
         Starter_Thread.Start_Index := Start_Index;
         Starter_Thread.Finish_Index := Finish_Index;
      end Start;
      Part_Min(Start_Index  => Start_Index,
               Finish_Index => Finish_Index);
      Part_Manager.Set_Part_Min(Min_Element, Min_Index);
   end Starter_Thread;

   function Parallel_Min return Integer is
      Min : Integer := Integer'Last;
      Index : Integer := 1;
      Thread : array(1..Thread_Num) of Starter_Thread;
   begin
      for I in 1..Thread_Num loop
         Thread(I).Start((I - 1) * Dim / Thread_Num + 1, I * Dim / Thread_Num);
      end loop;
      Part_Manager.Get_Min(Min, Index);
      return Min;
   end Parallel_Min;

begin
   Init_Arr;
   Put_Line("Minimum element: " & Parallel_Min'Img);
   Put_Line("Index of minimum element: " & Min_Index'Img);
end Main;
