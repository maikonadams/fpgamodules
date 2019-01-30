----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:34:30 01/27/2019 
-- Design Name: 
-- Module Name:    variance_top - Behavioral 
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

entity variance_top is
generic(constant XK_WIDTH : integer := 3;
		  constant SUM_WIDTH : integer := 9
	 );
    Port ( xk : in  STD_LOGIC_VECTOR (XK_WIDTH -1 downto 0);
			  reset : in std_logic;
           clock : in  STD_LOGIC;
			  mean : out std_logic_vector(XK_WIDTH -1 downto 0);
           variance : out  STD_LOGIC_VECTOR (SUM_WIDTH -4 downto 0));
end variance_top;

architecture Behavioral of variance_top is

component sum 
	 generic(constant XK_WIDTH : integer := 3;
				constant SUMOUT_WIDTH : integer := 6);
    Port ( xk : in  STD_LOGIC_VECTOR (XK_WIDTH -1 downto 0);
           reset : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           sumout : out  STD_LOGIC_VECTOR (SUMOUT_WIDTH -1 downto 0));
end component;
-- TOP branch
signal xk2 : STD_LOGIC_VECTOR (2*XK_WIDTH -1 downto 0);
signal outFirstSum : STD_LOGIC_VECTOR (SUM_WIDTH -1 downto 0);
signal outDivTop : STD_LOGIC_VECTOR (SUM_WIDTH -4 downto 0);

-- BOTTOM branch
signal outBotSum : STD_LOGIC_VECTOR (5 downto 0);
signal s_mean : STD_LOGIC_VECTOR (2 downto 0);
signal s_meanx2 : STD_LOGIC_VECTOR (11 downto 0);
signal s_meanx2prec : STD_LOGIC_VECTOR (5 downto 0);

begin
-- TOP branch
xk2 <= xk * xk;
entrysum :  sum generic map(2*XK_WIDTH, SUM_WIDTH)
					 port map(xk2, reset, clock, outFirstSum);	
outDivTop <= outFirstSum(SUM_WIDTH -1 downto 3);
variance <= outDivTop - s_meanx2prec;

-- Bottom branch 
botsum :   sum generic map(XK_WIDTH, 6)
					 port map(xk, reset, clock, outBotSum);	
s_mean <= outBotSum(5 downto 3);
mean <= s_mean;
s_meanx2 <= outBotSum*outBotSum; -- to keep the precision
s_meanx2prec <= s_meanx2(11 downto 6);

end Behavioral;

