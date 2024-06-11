----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/29/2024 03:14:44 PM
-- Design Name: 
-- Module Name: Axis_slave_mem - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Axis_slave_mem is
  generic(FLOW_SIM : boolean := TRUE);
  Port (AXI_ACLK : in std_logic;
  AXI_RESET : in std_logic;
  AXI_DATA : in std_logic_vector(31 downto 0);
  AXI_STRB : in std_logic_vector(3 downto 0);
  AXI_KEEP : in std_logic_vector(3 downto 0);
  AXI_LAST : in std_logic;
  AXI_VALID : in std_logic;
  AXI_READY : out std_logic
   );
end Axis_slave_mem;

architecture Behavioral of Axis_slave_mem is

signal memory_address : integer range 0 to 127;
type data_memory_type is array (0 to 127) of std_logic_vector(31 downto 0);
signal data_memory : data_memory_type :=(others =>(others=>'0'));
signal AXI_RESET_reg : std_logic;
signal axi_rd : std_logic;
signal shift_reg : std_logic_vector(5 downto 0);

begin

process(AXI_ACLK)
begin
    if rising_edge(AXI_ACLK) then
        AXI_RESET_reg <= AXI_RESET;
        if AXI_RESET = '0' then
            shift_reg <= "000111";
        elsif AXI_VALID = '1' or (AXI_VALID = '0' and shift_reg(5) = '0') then
            shift_reg(0) <= shift_reg(5) xor shift_reg(4) xor '1';
            shift_reg(5 downto 1) <= shift_reg(4 downto 0);
        end if;        
    end if;
end process;

axi_rd <= '0' when AXI_RESET = '0' or AXI_RESET_reg = '0'
            else  shift_reg(5) when FLOW_SIM else '1';
AXI_READY <= axi_rd;

process(AXI_ACLK)
begin
    if rising_edge(AXI_ACLK) then
        if AXI_RESET = '0' then
            memory_address <= 0;
        else 
            if AXI_VALID = '1' and axi_rd = '1' and AXI_LAST = '0' then
                memory_address <= memory_address + 1;
            elsif AXI_VALID = '1' and axi_rd = '1'and  AXI_LAST = '1' then
                memory_address <= 0;
            end if;
        end if;        
    end if;
end process;

process(AXI_ACLK)
begin
    if rising_edge(AXI_ACLK) then
        if AXI_VALID = '1' and axi_rd = '1' then
            data_memory(memory_address) <=  AXI_DATA;
        end if;
    end if;

end process;

end Behavioral;
