-- Toplevel file for EMS11-BB21 board

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity EMS11_BB21Toplevel is
port
(
	CLK50 : in std_logic;
	TXD1_TO_FPGA : in std_logic;
	RXD1_FROM_FPGA : out std_logic;
	N_RTS1_TO_FPGA : in std_logic;
	N_CTS1_FROM_FPGA : out std_logic
);
end entity;


architecture rtl of EMS11_BB21Toplevel is

begin
N_CTS1_FROM_FPGA<='1';  -- safe default since we're not using handshaking.

project: entity work.VirtualToplevel
	generic map (
		sysclk_frequency => 500 -- Sysclk frequency * 10
	)
	port map (
		clk => CLK50,
		reset_in => '1',
	
		-- UART
		rxd => TXD1_TO_FPGA,
		txd => RXD1_FROM_FPGA
);

end architecture;
