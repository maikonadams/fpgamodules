----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:57:33 01/27/2019 
-- Design Name: 
-- Module Name:    sum - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sum is
	 generic(constant XK_WIDTH : integer := 3;
				constant SUMOUT_WIDTH : integer := 6
	 );
    Port ( xk : in  STD_LOGIC_VECTOR (XK_WIDTH -1 downto 0);
           reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           sumout : out  STD_LOGIC_VECTOR (SUMOUT_WIDTH -1 downto 0));
end sum;

architecture Behavioral of sum is

signal reset_z1 : std_logic;
signal xk_reg : STD_LOGIC_VECTOR (XK_WIDTH -1 downto 0);
signal sum_int : STD_LOGIC_VECTOR (SUMOUT_WIDTH -1 downto 0):=(others=>'0');
signal sum_intz1 : STD_LOGIC_VECTOR (SUMOUT_WIDTH -1 downto 0);
constant zero : STD_LOGIC_VECTOR (SUMOUT_WIDTH -1 downto 0) := (others=>'0');

begin

sum_int <= xk_reg + sum_intz1 when reset_z1='0' else zero;

delayz1:process(clock)
begin
	if rising_edge(clock) then
		xk_reg <= xk;
		sum_intz1 <= sum_int;
		reset_z1 <= reset;
		sumout <= sum_int;
	end if;
end process delayz1;

end Behavioral;