----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:25:25 02/01/2019 
-- Design Name: 
-- Module Name:    fsm_axis4 - Behavioral 
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

entity fsm_axis4 is
generic( constant DATA_WIDTH : integer := 64;
				 constant NUM_PIXELS : integer := 16;
				 constant ISP_LATENCY : integer := 8 -1
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
end fsm_axis4;

architecture Behavioral of fsm_axis4 is

component 	fpncoreFlex_q3 
	 generic (width_data : positive := 16;
			 tk3: positive :=11;
			 tk2: positive :=12;
			 tk1: positive :=13;
			 tk0: positive :=12);
	 Port ( clock : in  STD_LOGIC;
			 yij : in  STD_LOGIC_VECTOR ((width_data - 1) downto 0);
			 aj : in  STD_LOGIC_VECTOR ((48 - 1) downto 0);
			 yhj : out  STD_LOGIC_VECTOR ((width_data - 1) downto 0));
end component;

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

component generic1bitdelay 
	 generic(constant delay : integer := 4);
    Port ( in1bit : in  STD_LOGIC;
           clock : in  STD_LOGIC;
           delayed1bit : out  STD_LOGIC);
end component;	
	
constant WIDTH_PIXELS : integer := clogb2(NUM_PIXELS );
constant FPN_SPN_WIDTH : integer := 16;

signal s_ready: std_logic;
signal m_valid: std_logic:='0';

signal wr : std_logic:='0';
signal rd : std_logic:='0';
signal s_sw : std_logic:='0';
signal m_sw : std_logic:='0';
signal lock_m : std_logic:='0';
	
signal wr_ptr_reg : unsigned(WIDTH_PIXELS  downto 0) := (others=>'0');
signal wr_ptr_regz1 : unsigned(WIDTH_PIXELS  downto 0) := (others=>'0');
signal wr_ptr_next : unsigned(WIDTH_PIXELS  downto 0) := (others=>'0');

signal rd_ptr_reg : unsigned(WIDTH_PIXELS  downto 0) := (others=>'1');
signal rd_ptr_regz1 : unsigned(WIDTH_PIXELS  downto 0) := (others=>'0');
signal rd_ptr_next : unsigned(WIDTH_PIXELS  downto 0) := (others=>'0');

signal coefin : std_logic_vector(48 -1 downto 0):= (others=>'0');
signal fpnout : std_logic_vector(FPN_SPN_WIDTH -1 downto 0) := (others=>'0');
signal s_last_delayed : std_logic := '0';
signal m00_axis_tlast_int : std_logic:='0';

type state_axis4 is (idle, s_filling, transmitting, m_flushing);
signal current_state, next_state : state_axis4;

begin
-- SLAVE INTERFACE
s_ready <= s00_axis_aresetn;
s00_axis_tready <= s_ready;
wr <= s_ready and s00_axis_tvalid;

-- MASTER INTERFACE
rd <= m_valid and m00_axis_tready;
m_valid <= '1' when (current_state = transmitting OR current_state = m_flushing) else '0';
m00_axis_tvalid <= m_valid;
m00_axis_tlast_int <= '1' when rd_ptr_reg = NUM_PIXELS -1 else '0';
m00_axis_tlast <= m00_axis_tlast_int or s_last_delayed;
m00_axis_tdata(63 downto FPN_SPN_WIDTH) <= (others=>'0');
m00_axis_tdata(FPN_SPN_WIDTH -1 downto 0) <= fpnout;


delay_s_last_U : generic1bitdelay generic map(ISP_LATENCY +1 )
                 port map(s00_axis_tlast,s00_axis_aclk, s_last_delayed);
              
-- FSM
update_FSM: process(s00_axis_aclk)
begin
	if rising_edge(s00_axis_aclk) then
		if s00_axis_aresetn='0' then
			current_state <= idle;
		else
			current_state <= next_state;
		end if;
	end if;
end process update_FSM;

process(current_state, wr_ptr_reg, rd_ptr_reg)
begin
	
	case current_state is
		when idle =>
			if (wr_ptr_reg >=0) then
				next_state <= s_filling;
			else
			
			end if;
		when s_filling =>
			if (wr_ptr_reg < ISP_LATENCY) then
			   next_state <= s_filling;
			else
				next_state <= transmitting;
			end if;
		when transmitting =>
			if (rd_ptr_reg >= 0 and rd_ptr_reg < (NUM_PIXELS - ISP_LATENCY)) then
			   next_state <= transmitting;
			else
				next_state <= m_flushing;
			end if;
		when m_flushing =>
			if (rd_ptr_reg = NUM_PIXELS -1) then
			   next_state <= idle;
			else
				next_state <= m_flushing;
			end if;
		when others =>
	
	end case;
end process;

------------------------- RECEIVING or WRITING
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
            if (current_state = transmitting OR current_state = m_flushing) then
					rd_ptr_reg <= rd_ptr_next;
				else
					rd_ptr_reg <= (others=>'0');
				end if;
				rd_ptr_regz1 <= rd_ptr_reg;
		  end if;
end process rd_counter;
rd_ptr_next <= rd_ptr_reg + 1 when (rd='1') else rd_ptr_reg;

fpn_u : fpncoreFlex_q3 
        generic map(FPN_SPN_WIDTH, 11,12,13,12)
        port map(s00_axis_aclk, 
		           s00_axis_tdata(FPN_SPN_WIDTH -1 downto 0), 
					  s00_axis_tdata(63 downto FPN_SPN_WIDTH), 
					  fpnout); 

end Behavioral;

