----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:25:09 01/10/2019 
-- Design Name: 
-- Module Name:    slave_master_ctrl - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity slave_master_ctrlv2 is
	 generic( constant DATA_WIDTH : integer := 8;
				 constant NUM_PIXELS : integer := 25;
				 constant ISP_LATENCY : integer := 6
	 );
    Port ( s00_axis_tdata : in  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
           s00_axis_tvalid	: in std_logic;
			  s00_axis_tready	: out std_logic;
			  s00_axis_tlast	: in std_logic;
			  s00_axis_aresetn	: in std_logic;
           s00_axis_aclk : in  STD_LOGIC;
			  m00_axis_aresetn	: in std_logic;
			  m00_axis_aclk : in  STD_LOGIC;
           m00_axis_tvalid : out  STD_LOGIC;
			  m00_axis_tready	: in std_logic;
			  m00_axis_tlast	: out std_logic;
           m00_axis_tdata : out  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0));
end slave_master_ctrlv2;

architecture Behavioral of slave_master_ctrlv2 is

-- function called clogb2 that returns an integer which has the 
	-- value of the ceiling of the log base 2.
	function clogb2 (bit_depth : integer) return integer is 
	variable depth  : integer := bit_depth;
	  begin
	    if (depth = 0) then
	      return(0);
	    else
	      for clogb2 in 1 to bit_depth loop  -- Works for up to 32 bit integers
	        if(depth <= 1) then 
	          return(clogb2);      
	        else
	          depth := depth / 2;
	        end if;
	      end loop;
	    end if;
	end;    
	
constant WIDTH_PIXELS : integer := clogb2(NUM_PIXELS );

signal s_ready: std_logic;
signal m_valid: std_logic:='0';

signal wr : std_logic:='0';
signal rd : std_logic:='0';
signal s_sw : std_logic:='0';
signal m_sw : std_logic:='0';
signal lock_m : std_logic:='0';
	
signal wr_ptr_reg : std_logic_vector(WIDTH_PIXELS -1 downto 0) := (others=>'0');
signal wr_ptr_regz1 : std_logic_vector(WIDTH_PIXELS -1 downto 0) := (others=>'0');
signal wr_ptr_next : std_logic_vector(WIDTH_PIXELS -1 downto 0) := (others=>'0');

signal rd_ptr_reg : std_logic_vector(WIDTH_PIXELS -1 downto 0) := (others=>'1');
signal rd_ptr_regz1 : std_logic_vector(WIDTH_PIXELS -1 downto 0) := (others=>'0');
signal rd_ptr_next : std_logic_vector(WIDTH_PIXELS -1 downto 0) := (others=>'0');

signal temp0 : std_logic_vector(7 downto 0);
signal temp1 : std_logic_vector(7 downto 0);
signal temp2 : std_logic_vector(7 downto 0);
signal temp3 : std_logic_vector(7 downto 0);
signal temp4 : std_logic_vector(7 downto 0);
signal temp5 : std_logic_vector(7 downto 0);

begin
---- SLAVE 
s_ready <= s00_axis_aresetn and s_sw;
s00_axis_tready <= s_ready;
s_sw <= '1' when wr_ptr_regz1 < NUM_PIXELS -1 else '0';
wr <= s_ready and s00_axis_tvalid;

---- MASTER
m_sw <= '1' when rd_ptr_regz1 < NUM_PIXELS -1 or m_valid = '1' else '0';
rd <= m_valid and m00_axis_tready;
m_valid <= '1' when (rd_ptr_reg >= 0 and  rd_ptr_reg <= NUM_PIXELS -1) else '0';
m00_axis_tvalid <= m_valid;
m00_axis_tlast <= '1' when rd_ptr_reg = NUM_PIXELS -1 else '0';
---- HS

--- RECEIVING or WRITING
wr_counter : process(s00_axis_aclk) 
    begin
        if rising_edge(s00_axis_aclk) then
         if (s00_axis_aresetn='0' or s00_axis_tlast='1') then
				wr_ptr_reg <= (others=>'0');
			else
				wr_ptr_reg <= wr_ptr_next;
			end if;
			wr_ptr_regz1 <= wr_ptr_reg;
		end if;
end process wr_counter;
wr_ptr_next <= 	wr_ptr_reg + 1 when (wr='1') else wr_ptr_reg;

--- TRANSMITTING or READING
rd_counter : process(m00_axis_aclk) 
    begin
        if rising_edge(m00_axis_aclk) then
            if (wr_ptr_regz1 = ISP_LATENCY -1) then
					rd_ptr_reg <= (others=>'0');
				else
					rd_ptr_reg <= rd_ptr_next;
				end if;
				rd_ptr_regz1 <= rd_ptr_reg;
		  end if;
end process rd_counter;
rd_ptr_next <= rd_ptr_reg + 1 when (rd='1') else rd_ptr_reg;

--- SIMULATING ISP
process(s00_axis_aclk)
begin
	if rising_edge(s00_axis_aclk) then
		temp0 <= s00_axis_tdata;
		temp1 <= temp0;
		temp2 <= temp1;
		temp3 <= temp2;
		temp4 <= temp3;
		temp5 <= temp4;
		m00_axis_tdata <= temp5;
	end if;
end process;


end Behavioral;

