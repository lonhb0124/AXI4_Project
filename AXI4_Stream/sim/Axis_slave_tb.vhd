----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/11/2024 02:37:04 PM
-- Design Name: 
-- Module Name: Axis_slave_tb - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Axis_slave_tb is
--  Port ( );
end Axis_slave_tb;

architecture Behavioral of Axis_slave_tb is
component Axis_slave_mem
    port (
        AXI_ACLK : in std_logic;
        AXI_RESET : in std_logic;
        AXI_DATA : in std_logic_vector(31 downto 0);
        AXI_STRB : in std_logic_vector(3 downto 0);
        AXI_KEEP : in std_logic_vector(3 downto 0);
        AXI_LAST : in std_logic;
        AXI_VALID : in std_logic;
        AXI_READY : out std_logic 
    );
end component;

signal AXI_ACLK : std_logic := '0';
signal AXI_RESET : std_logic;
signal AXI_DATA : std_logic_vector(31 downto 0);
signal AXI_STRB : std_logic_vector(3 downto 0);
signal AXI_KEEP : std_logic_vector(3 downto 0);
signal AXI_LAST : std_logic;
signal AXI_VALID : std_logic;
signal AXI_READY : std_logic;
signal shift_reg : std_logic_vector(5 downto 0) := "110000";
signal tlast : std_logic;

constant CLK_PERIOD : time := 100 ns;

begin

UUT : Axis_slave_mem port map (
    AXI_ACLK => AXI_ACLK,
    AXI_RESET => AXI_RESET,
    AXI_DATA => AXI_DATA,
    AXI_STRB => AXI_STRB,
    AXI_KEEP => AXI_KEEP,
    AXI_LAST => AXI_LAST,
    AXI_VALID => AXI_VALID,
    AXI_READY => AXI_READY
);

AXI_ACLK <= not AXI_ACLK after CLK_PERIOD/2;

process(AXI_ACLK)
begin
    if rising_edge(AXI_ACLK) then
        if AXI_READY = '1' or (AXI_READY = '0' and shift_reg(5) = '1') then
            shift_reg(0) <= shift_reg(5) xor shift_reg(4) xor '1';
            shift_reg(5 downto 1) <= shift_reg(4 downto 0);
            end if;
    end if; 
end process;

AXI_VALID <= shift_reg(5);
AXI_LAST <= shift_reg(5) and tlast;

process
begin
    AXI_RESET <= '0';
    AXI_STRB <= "1111";
    AXI_KEEP <= "1111";
    tlast <= '0';
    AXI_DATA <= (others => '0');
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    AXI_RESET <= '1';
    wait for CLK_PERIOD;
    for i in 0 to 5 loop
        for j in 0 to 127 loop
            AXI_DATA <= std_logic_vector(to_unsigned(j,32));
            if j = 127 then
                tlast <= '1';
            else
                tlast <= '0';
            end if;
        wait until rising_edge(AXI_ACLK) and AXI_VALID = '1' and AXI_READY = '1';          
        end loop;
    end loop;    
end process;

end Behavioral;
