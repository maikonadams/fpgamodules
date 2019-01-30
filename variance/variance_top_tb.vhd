--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   08:45:51 01/28/2019
-- Design Name:   
-- Module Name:   /home/maikon/Dropbox/hdl_fpga/projects/variance/variance_top_tb.vhd
-- Project Name:  variance
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: variance_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY variance_top_tb IS
END variance_top_tb;
 
ARCHITECTURE behavior OF variance_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT variance_top
    PORT(
         xk : IN  std_logic_vector(2 downto 0);
         reset : IN  std_logic;
         clock : IN  std_logic;
         mean : OUT  std_logic_vector(2 downto 0);
         variance : OUT  std_logic_vector(5 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal xk : std_logic_vector(2 downto 0) := (others => '0');
   signal reset : std_logic := '0';
   signal clock : std_logic := '0';

 	--Outputs
   signal mean : std_logic_vector(2 downto 0);
   signal variance : std_logic_vector(5 downto 0);

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: variance_top PORT MAP (
          xk => xk,
          reset => reset,
          clock => clock,
          mean => mean,
          variance => variance
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clock_period*10;

      -- insert stimulus here 
		reset <= '1';
		wait for clock_period*1;
		reset <= '0';
		xk <="101";
		wait for clock_period*1;
		xk <="010";
		wait for clock_period*1;
		xk <="001";
		wait for clock_period*1;
		xk <="011";
		wait for clock_period*1;
		xk <="100";
		wait for clock_period*1;
		xk <="100";
		wait for clock_period*1;
		xk <="101";
		wait for clock_period*1;
		xk <="110";
		wait for clock_period*1;
		reset <= '1';
		wait for clock_period*1;

      wait;
   end process;

END;
